import 'package:flutter/material.dart';

import '../i18n/tr.dart';
import 'app_shell.dart';
import 'common.dart';

/// Home page layout shared by the apps: drawer, header, a listings tab and
/// "Mon espace", with pull-to-refresh and the sync status above [children].
///
/// The header folds while the listings tab is scrolled down.
class DashboardScaffold extends StatefulWidget {
  const DashboardScaffold({
    required this.drawer,
    required this.tab,
    required this.onTabChanged,
    required this.listingsDestination,
    required this.header,
    required this.onRefresh,
    required this.children,
    this.unreadCount = 0,
    this.lastSynced,
    this.loading = false,
    this.error,
    super.key,
  });

  final Widget drawer;

  /// 0 for the listings, 1 for "Mon espace".
  final int tab;
  final ValueChanged<int> onTabChanged;
  final NavigationDestination listingsDestination;

  /// Builds the header; `collapsed` is true while the listings are scrolled.
  final Widget Function(bool collapsed) header;
  final Future<void> Function() onRefresh;

  /// Content of the current tab, below the sync status.
  final List<Widget> children;

  /// Badge on the "Mon espace" tab.
  final int unreadCount;
  final DateTime? lastSynced;
  final bool loading;
  final String? error;

  @override
  State<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {
  bool headerCollapsed = false;

  bool _onListScroll(ScrollNotification notification) {
    final next =
        AppHeader.collapsedAfter(notification, current: headerCollapsed);
    if (next != headerCollapsed) setState(() => headerCollapsed = next);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.unreadCount;
    Widget badged(IconData icon) => Badge.count(
        count: unread, isLabelVisible: unread > 0, child: Icon(icon));
    return Scaffold(
      drawer: widget.drawer,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.tab,
        onDestinationSelected: widget.onTabChanged,
        destinations: [
          widget.listingsDestination,
          NavigationDestination(
            icon: badged(Icons.person_outline),
            selectedIcon: badged(Icons.person),
            label: tr('Mon espace'),
          ),
        ],
      ),
      body: Column(
        children: [
          widget.header(widget.tab == 0 && headerCollapsed),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onListScroll,
              child: RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CacheStatusBar(
                              lastSynced: widget.lastSynced,
                              loading: widget.loading),
                          if (widget.error != null) ...[
                            const SizedBox(height: 12),
                            ErrorCard(widget.error!),
                          ],
                          const SizedBox(height: 16),
                          ...widget.children,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
