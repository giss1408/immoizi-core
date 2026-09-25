import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A dashboard payload restored from [DashboardCache].
class CachedDashboard {
  const CachedDashboard(this.data, this.cachedAt);

  final Map<String, dynamic> data;
  final DateTime? cachedAt;
}

/// Persists the last successful GraphQL dashboard payload so the app can
/// start offline with real data instead of the demo fallback.
class DashboardCache {
  const DashboardCache({required this.dataKey, required this.timeKey});

  final String dataKey;
  final String timeKey;

  /// Returns null when nothing is cached or the cached payload is corrupt.
  Future<CachedDashboard?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(dataKey);
    if (cached == null) return null;

    try {
      final data = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAtMs = prefs.getInt(timeKey);
      return CachedDashboard(
        data,
        cachedAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(cachedAtMs)
            : null,
      );
    } catch (_) {
      // Corrupt or outdated cache format — ignore and keep the demo fallback.
      return null;
    }
  }

  /// Stores [data] and returns the time it was saved.
  Future<DateTime> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dataKey, jsonEncode(data));
    final now = DateTime.now();
    await prefs.setInt(timeKey, now.millisecondsSinceEpoch);
    return now;
  }

  /// Forgets the cached payload, e.g. on logout so the next user of the
  /// device does not see the previous account's data.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(dataKey);
    await prefs.remove(timeKey);
  }
}
