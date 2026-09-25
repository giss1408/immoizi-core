import 'dart:async';

import 'package:flutter/material.dart';

import '../api/graphql_client.dart';
import '../api/notifications_poll.dart';
import '../cache/dashboard_cache.dart';
import '../config/app_config.dart';
import '../notifications/app_notification.dart';
import '../notifications/system_notifications.dart';
import 'session_store.dart';

/// Shared session, loading and polling logic for the apps' home pages.
///
/// - keeps the bearer token in [sessionStore] so users stay signed in;
/// - ignores responses that were overtaken by a newer request;
/// - polls only notification ids and reloads the dashboard when they change;
/// - caches only unfiltered dashboards, and clears everything on logout.
mixin DashboardSession<W extends StatefulWidget, D> on State<W> {
  GraphQLClient get client;
  DashboardCache get cache;
  SessionStore get sessionStore;

  /// The GraphQL query that loads the whole dashboard. Takes `$search`.
  String get dashboardQuery;

  /// Query used while signed out, limited to public fields: the backend
  /// rejects the whole response when a query touches a protected field.
  /// Null when the dashboard [requiresLogin].
  String? get signedOutQuery => null;

  /// Whether the dashboard can only be loaded by a signed-in user.
  bool get requiresLogin;

  D parseDashboard(Map<String, dynamic> json);
  D demoDashboard();
  Iterable<AppNotification> notificationsOf(D dashboard);

  static const pollInterval = Duration(seconds: 15);
  static const searchDebounceDelay = Duration(milliseconds: 350);

  final endpoint = TextEditingController(text: AppConfig.endpoint);
  final token = TextEditingController();
  final username = TextEditingController(text: AppConfig.demoUsername);
  final password = TextEditingController(text: AppConfig.demoPassword);
  final propertySearch = TextEditingController();

  late D dashboard = demoDashboard();
  bool loading = false;
  bool loggingIn = false;
  bool connected = false;

  /// The last load reached the backend (signed in or not), so the screen
  /// shows live data rather than demo data.
  bool online = false;
  bool hasData = false;
  DateTime? lastSynced;
  String? error;
  String searchQuery = '';

  Timer? _pollTimer;
  Timer? _searchDebounce;
  int _generation = 0;
  bool _polling = false;
  String? _persistedToken;

  /// Notification ids already known this session; null until the first
  /// signed-in load, so opening the app does not replay old alerts.
  Set<String>? _knownNotificationIds;

  bool get signedIn => token.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _pollTimer = Timer.periodic(pollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchDebounce?.cancel();
    endpoint.dispose();
    token.dispose();
    username.dispose();
    password.dispose();
    propertySearch.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final cached = await cache.restore();
    if (!mounted) return;
    if (cached != null) {
      setState(() {
        dashboard = parseDashboard(cached.data);
        hasData = true;
        lastSynced = cached.cachedAt;
      });
    }

    final session = await sessionStore.restore();
    if (!mounted) return;
    if (session != null) {
      if (session.endpoint.isNotEmpty) endpoint.text = session.endpoint;
      token.text = session.token;
      username.text = session.username;
      _persistedToken = session.token;
    }
    if (signedIn || !requiresLogin) await load();
  }

  Future<void> login() async {
    if (username.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Renseignez votre identifiant et mot de passe.');
      return;
    }
    setState(() {
      loggingIn = true;
      error = null;
    });
    try {
      final newToken = await client.login(
          endpoint.text.trim(), username.text.trim(), password.text);
      if (!mounted) return;
      token.text = newToken;
      password.clear();
      await _persistSession();
      await load();
    } catch (exception) {
      if (mounted) setState(() => error = describeError(exception));
    } finally {
      if (mounted) setState(() => loggingIn = false);
    }
  }

  Future<void> logout() async {
    _generation++; // Drop any response still in flight for the old session.
    _searchDebounce?.cancel();
    token.clear();
    password.clear();
    _persistedToken = null;
    _knownNotificationIds = null;
    setState(() {
      dashboard = demoDashboard();
      connected = false;
      online = false;
      hasData = false;
      lastSynced = null;
      loading = false;
      error = null;
    });
    await sessionStore.clear();
    await cache.clear();
    if (mounted && !requiresLogin) await load();
  }

  Future<void> load({String? search}) async {
    final generation = ++_generation;
    final activeSearch = (search ?? searchQuery).trim();
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await client.query(
        endpoint.text.trim(),
        token.text.trim(),
        signedIn ? dashboardQuery : (signedOutQuery ?? dashboardQuery),
        variables: {'search': activeSearch.isEmpty ? null : activeSearch},
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        dashboard = parseDashboard(data);
        connected = signedIn;
        online = true;
        hasData = true;
      });
      if (signedIn && token.text.trim() != _persistedToken) {
        await _persistSession();
      }
      if (signedIn) _alertNewNotifications();
      // A search result is partial; caching it would hide the rest of the
      // portfolio on the next offline start.
      if (activeSearch.isEmpty) {
        final savedAt = await cache.save(data);
        if (mounted) setState(() => lastSynced = savedAt);
      }
    } on AuthException catch (exception) {
      if (!mounted || generation != _generation) return;
      if (signedIn) {
        await _expireSession(exception.userMessage);
      } else {
        setState(() {
          connected = false;
          online = false;
          error = exception.userMessage;
        });
      }
    } catch (exception) {
      if (!mounted || generation != _generation) return;
      final message = describeError(exception);
      setState(() {
        connected = false;
        online = false;
        if (!hasData) {
          dashboard = demoDashboard();
          error = '$message Mode démonstration activé.';
        } else {
          error = '$message Dernières données affichées.';
        }
      });
    } finally {
      if (mounted && generation == _generation) {
        setState(() => loading = false);
      }
    }
  }

  void searchProperties(String value) {
    setState(() => searchQuery = value);
    _searchDebounce?.cancel();
    // Signed-out managers only filter what is already on screen.
    if (requiresLogin && !signedIn) return;
    _searchDebounce = Timer(searchDebounceDelay, () {
      if (mounted) load(search: value);
    });
  }

  Future<void> _poll() async {
    if (!mounted || !signedIn || loading || _polling) return;
    _polling = true;
    final generation = _generation;
    try {
      final data = await client.query(
          endpoint.text.trim(), token.text.trim(), notificationsPollQuery);
      if (!mounted || generation != _generation) return;
      final remote = notificationsSignature(
          (data['notifications'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((item) => (
                    id: '${item['id'] ?? ''}',
                    isRead: item['isRead'] == true,
                  )));
      final local = notificationsSignature(notificationsOf(dashboard)
          .map((item) => (id: item.id, isRead: item.isRead)));
      if (!connected) setState(() => connected = true);
      if (remote != local) await load();
    } on AuthException catch (exception) {
      if (mounted && generation == _generation) {
        await _expireSession(exception.userMessage);
      }
    } on NetworkException {
      if (mounted && connected) setState(() => connected = false);
    } catch (_) {
      // A failed background poll is retried on the next tick.
    } finally {
      _polling = false;
    }
  }

  /// Raises a system notification for each unread notification that
  /// appeared since the previous load.
  void _alertNewNotifications() {
    final current = notificationsOf(dashboard).toList();
    final known = _knownNotificationIds;
    _knownNotificationIds = {for (final item in current) item.id};
    if (known == null) {
      SystemNotifications.initialize();
      return;
    }
    for (final item in current) {
      if (!item.isRead && !known.contains(item.id)) {
        SystemNotifications.show(item);
      }
    }
  }

  /// Marks a notification as read on the backend, then refreshes.
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await client.query(
          endpoint.text.trim(), token.text.trim(), markNotificationReadMutation,
          variables: {'notificationId': notificationId});
      if (mounted) await load();
    } catch (_) {
      // Not critical: the notification simply stays unread.
    }
  }

  Future<void> _expireSession(String message) async {
    token.clear();
    _persistedToken = null;
    setState(() {
      connected = false;
      error = message;
    });
    await sessionStore.clear();
  }

  Future<void> _persistSession() async {
    final value = token.text.trim();
    _persistedToken = value;
    await sessionStore.save(StoredSession(
        endpoint: endpoint.text.trim(),
        token: value,
        username: username.text.trim()));
  }
}
