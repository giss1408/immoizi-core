import 'package:flutter/material.dart';

import '../theme.dart';
import '../i18n/tr.dart';

class ConnectionCard extends StatefulWidget {
  const ConnectionCard({
    required this.endpoint,
    required this.token,
    required this.username,
    required this.password,
    required this.loading,
    required this.loggingIn,
    required this.connected,
    required this.onPressed,
    required this.onLogin,
    required this.onLogout,
    this.loadLabel,
    super.key,
  });

  final TextEditingController endpoint;
  final TextEditingController token;
  final TextEditingController username;
  final TextEditingController password;
  final bool loading;
  final bool loggingIn;
  final bool connected;
  final VoidCallback onPressed;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  /// Null shows the default label.
  final String? loadLabel;

  @override
  State<ConnectionCard> createState() => _ConnectionCardState();
}

class _ConnectionCardState extends State<ConnectionCard> {
  late bool expanded = !widget.connected;

  @override
  void didUpdateWidget(covariant ConnectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connected != oldWidget.connected) {
      expanded = !widget.connected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    widget.connected
                        ? Icons.check_circle
                        : Icons.wifi_tethering,
                    color: widget.connected
                        ? IvoryColors.green
                        : IvoryColors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.connected
                          ? tr('Connecté en tant que {name}',
                              {'name': widget.username.text.trim()})
                          : tr('Connexion au backend'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: widget.connected
                            ? IvoryColors.green
                            : IvoryColors.ink,
                      ),
                    ),
                  ),
                  if (widget.connected)
                    TextButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout, size: 16),
                      label: Text(tr('D\u00e9connexion')),
                    ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more,
                      color: IvoryColors.muted),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  TextField(
                    controller: widget.endpoint,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint GraphQL',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.username,
                          decoration: InputDecoration(
                            labelText: tr('Identifiant'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: widget.password,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: tr('Mot de passe'),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: widget.loggingIn ? null : widget.onLogin,
                    icon: widget.loggingIn
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(widget.loggingIn
                        ? tr('Connexion...')
                        : (widget.connected
                            ? tr('Se reconnecter')
                            : tr('Se connecter'))),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: widget.token,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Token API',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: widget.loading ? null : widget.onPressed,
                    icon: widget.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(widget.loading
                        ? tr('Chargement...')
                        : widget.loadLabel ?? tr('Synchroniser')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
