import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../i18n/tr.dart';

/// Green brand header that extends under the status bar, with a thin
/// orange / white / green flag stripe. The title always stays on one line.
class AppHeader extends StatelessWidget {
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
    this.bottom,
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

  /// Optional widget pinned inside the header, e.g. the search bar.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
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
              padding: EdgeInsets.fromLTRB(8, topInset + 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon:
                        Icon(Icons.menu_rounded, color: IvoryColors.onPrimary),
                    tooltip: 'Menu',
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: IvoryColors.onPrimary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: IvoryColors.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: IvoryColors.onPrimary,
                                    fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: IvoryColors.onPrimary.withOpacity(0.72),
                              fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  if (onRefresh != null)
                    IconButton(
                      onPressed: loading ? null : onRefresh,
                      tooltip: refreshTooltip ?? tr('Synchroniser'),
                      icon: loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: IvoryColors.onPrimary),
                            )
                          : Icon(Icons.sync_rounded,
                              color: IvoryColors.onPrimary),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConnectionStatusPill(
                    connected: connected,
                    online: online,
                    label: connectedLabel,
                    onDark: true),
              ),
            ),
            if (bottom != null)
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: bottom),
            const SizedBox(height: 16),
            const _FlagStripe(),
          ],
        ),
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
