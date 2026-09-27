import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../i18n/tr.dart';
import 'property_search_bar.dart';

/// Green brand header that extends under the status bar, with a thin
/// orange / white / green flag stripe. The title always stays on one line.
///
/// When [collapsed], the badge, subtitle and status pill fold away so the
/// list below gets more room; the title row stays visible.
///
/// With a [search], the title row shows search and filter buttons; tapping
/// search swaps the title row for the search field until it is closed.
class AppHeader extends StatefulWidget {
  const AppHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.connected = false,
    this.online = false,
    this.connectedLabel = '',
    this.loading = false,
    this.onRefresh,
    this.refreshTooltip,
    this.search,
    this.collapsed = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool connected;

  /// Live data without being signed in (visitor browsing public listings).
  final bool online;
  final String connectedLabel;
  final bool loading;
  final VoidCallback? onRefresh;

  /// Null shows the default tooltip.
  final String? refreshTooltip;

  /// Listing search, opened from a button in the title row.
  final PropertySearchBar? search;

  /// Compact form, used while the content below is scrolled down.
  final bool collapsed;

  /// Next [collapsed] value after [notification] from the list below the
  /// header. The gap between the two thresholds avoids flicker.
  static bool collapsedAfter(ScrollNotification notification,
      {required bool current}) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return current;
    }
    final offset = notification.metrics.pixels;
    if (offset > 56) return true;
    if (offset < 16) return false;
    return current;
  }

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  /// Keeps an active query visible, e.g. after switching tabs.
  late bool searching = widget.search?.controller.text.isNotEmpty ?? false;

  void _closeSearch() {
    final search = widget.search!;
    search.controller.clear();
    search.onChanged('');
    setState(() => searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final search = widget.search;
    final collapsed = widget.collapsed;
    final showSearch = searching && search != null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [IvoryColors.green, IvoryColors.greenDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.fromLTRB(8, topInset + (collapsed ? 4 : 8), 8, 0),
              child: AnimatedSwitcher(
                duration: _foldDuration,
                child: showSearch
                    ? Padding(
                        key: const ValueKey('search'),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: PropertySearchBar(
                          controller: search.controller,
                          onChanged: search.onChanged,
                          onOpenFilters: search.onOpenFilters,
                          activeFilterCount: search.activeFilterCount,
                          hintText: search.hintText,
                          autofocus: true,
                          onClose: _closeSearch,
                        ),
                      )
                    : Row(
                        key: const ValueKey('title'),
                        children: [
                          IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: Icon(Icons.menu_rounded,
                                color: IvoryColors.onPrimary),
                            tooltip: 'Menu',
                          ),
                          _Foldable(
                            collapsed: collapsed,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                      IvoryColors.onPrimary.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(widget.icon,
                                    color: IvoryColors.onPrimary),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            color: IvoryColors.onPrimary,
                                            fontWeight: FontWeight.w900),
                                  ),
                                ),
                                _Foldable(
                                  collapsed: collapsed,
                                  child: Text(
                                    widget.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: IvoryColors.onPrimary
                                            .withOpacity(0.72),
                                        fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (search != null) ...[
                            IconButton(
                              onPressed: () => setState(() => searching = true),
                              tooltip: tr('Rechercher'),
                              icon: Icon(Icons.search_rounded,
                                  color: IvoryColors.onPrimary),
                            ),
                            FilterButton(
                                onPressed: search.onOpenFilters,
                                activeCount: search.activeFilterCount),
                          ],
                          if (widget.onRefresh != null)
                            IconButton(
                              onPressed:
                                  widget.loading ? null : widget.onRefresh,
                              tooltip:
                                  widget.refreshTooltip ?? tr('Synchroniser'),
                              icon: widget.loading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: IvoryColors.onPrimary),
                                    )
                                  : Icon(Icons.sync_rounded,
                                      color: IvoryColors.onPrimary),
                            ),
                        ],
                      ),
              ),
            ),
            _Foldable(
              collapsed: collapsed,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConnectionStatusPill(
                      connected: widget.connected,
                      online: widget.online,
                      label: widget.connectedLabel,
                      onDark: true),
                ),
              ),
            ),
            AnimatedContainer(
                duration: _foldDuration,
                curve: Curves.easeOut,
                height: collapsed ? 10 : 16),
            const _FlagStripe(),
          ],
        ),
      ),
    );
  }
}

const _foldDuration = Duration(milliseconds: 200);

/// Shrinks [child] to nothing, with a fade, while [collapsed].
class _Foldable extends StatelessWidget {
  const _Foldable({required this.collapsed, required this.child});

  final bool collapsed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _foldDuration,
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: AnimatedOpacity(
        duration: _foldDuration,
        opacity: collapsed ? 0 : 1,
        child: collapsed ? const SizedBox.shrink() : child,
      ),
    );
  }
}

class _FlagStripe extends StatelessWidget {
  const _FlagStripe();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 4,
          child: Row(children: [
            Expanded(child: Container(color: IvoryColors.orange)),
            Expanded(child: Container(color: Colors.white)),
            Expanded(child: Container(color: const Color(0xFF7FD6A4))),
          ]),
        ),
      ),
    );
  }
}

class ConnectionStatusPill extends StatelessWidget {
  const ConnectionStatusPill(
      {required this.connected,
      required this.label,
      this.online = false,
      this.onDark = false,
      super.key});

  final bool connected;
  final bool online;
  final String label;

  /// Use light colours when placed on the green header or drawer.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final live = connected || online;
    final dotColor = live
        ? (onDark ? const Color(0xFF7FD6A4) : IvoryColors.green)
        : (onDark ? IvoryColors.orange : IvoryColors.muted);
    final textColor = onDark
        ? IvoryColors.onPrimary
        : (live ? IvoryColors.green : IvoryColors.muted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark
            ? IvoryColors.onPrimary.withOpacity(0.14)
            : IvoryColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              connected
                  ? tr('Connecté — {name}', {'name': label})
                  : online
                      ? tr('Visiteur — en ligne')
                      : tr('Mode démonstration'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.name,
    required this.role,
    required this.connected,
    required this.onLogout,
    required this.applicationName,
    this.homeLabel,
    this.extraComingSoonTiles = const [],
    super.key,
  });

  final String name;
  final String role;
  final bool connected;
  final VoidCallback onLogout;
  final String applicationName;

  /// Null shows the default label.
  final String? homeLabel;

  /// Role-specific "coming soon" entries shown right after the home entry.
  final List<DrawerComingSoonTile> extraComingSoonTiles;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [IvoryColors.green, IvoryColors.greenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: IvoryColors.onPrimary.withOpacity(0.24),
                    child: Icon(Icons.person, color: IvoryColors.onPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(name,
                      style: TextStyle(
                          color: IvoryColors.onPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  Text(role,
                      style: TextStyle(
                          color: IvoryColors.onPrimary.withOpacity(0.72),
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  ConnectionStatusPill(
                      connected: connected, label: name, onDark: true),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: IvoryColors.green),
                    title: Text(homeLabel ?? tr('Accueil')),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  ...extraComingSoonTiles,
                  const DrawerComingSoonTile(
                      icon: Icons.notifications_none, title: 'Notifications'),
                  DrawerComingSoonTile(
                      icon: Icons.support_agent, title: tr('Aide & support')),
                  DrawerComingSoonTile(
                      icon: Icons.privacy_tip_outlined,
                      title: tr('Confidentialité & conditions')),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: IvoryColors.green),
                    title: Text(tr('À propos')),
                    onTap: () {
                      Navigator.of(context).pop();
                      showAboutDialog(
                        context: context,
                        applicationName: applicationName,
                        applicationVersion: '1.0.0',
                        applicationLegalese: tr('© Immoizi — Côte d’Ivoire'),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(tr('Déconnexion')),
                    onTap: () {
                      Navigator.of(context).pop();
                      onLogout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerComingSoonTile extends StatelessWidget {
  const DrawerComingSoonTile(
      {required this.icon, required this.title, super.key});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: false,
      leading: Icon(icon, color: IvoryColors.muted.withOpacity(0.5)),
      title: Text(title,
          style: TextStyle(color: IvoryColors.muted.withOpacity(0.8))),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: IvoryColors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(tr('Bientôt'),
            style: TextStyle(
                fontSize: 11,
                color: IvoryColors.orange,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
