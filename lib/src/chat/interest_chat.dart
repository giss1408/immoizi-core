import 'package:flutter/material.dart';

import '../api/graphql_client.dart';
import '../api/json.dart';
import '../theme.dart';

class InterestChatPage extends StatefulWidget {
  const InterestChatPage(
      {required this.interestRequestId,
      required this.propertyTitle,
      required this.endpoint,
      required this.token,
      required this.isManager,
      super.key});

  final String interestRequestId;
  final String propertyTitle;
  final String endpoint;
  final String token;

  /// Managers can propose a visit date; applicants can only reply to one.
  final bool isManager;

  @override
  State<InterestChatPage> createState() => _InterestChatPageState();
}

class _InterestChatPageState extends State<InterestChatPage> {
  final messageController = TextEditingController();
  List<InterestMessageItem> messages = [];
  String messageType = 'message';
  DateTime? proposedVisitAt;
  bool loading = true;
  bool sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final data = await GraphQLClient().query(
          widget.endpoint, widget.token, interestMessagesQuery,
          variables: {'interestRequestId': widget.interestRequestId});
      if (mounted) {
        setState(() => messages = jsonItems(data['propertyInterestMessages'])
            .map(InterestMessageItem.fromJson)
            .toList());
      }
    } catch (exception) {
      if (mounted) {
        setState(() =>
            error = 'Chargement impossible : ${describeError(exception)}');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _chooseVisitDate() async {
    final date = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: proposedVisitAt ?? DateTime.now());
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(proposedVisitAt ?? DateTime.now()));
    if (time != null) {
      setState(() => proposedVisitAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute));
    }
  }

  Future<void> _send() async {
    if (messageController.text.trim().isEmpty ||
        (messageType == 'visit_proposal' && proposedVisitAt == null)) return;
    setState(() {
      sending = true;
      error = null;
    });
    try {
      await GraphQLClient().query(
          widget.endpoint, widget.token, sendInterestMessageMutation,
          variables: {
            'interestRequestId': widget.interestRequestId,
            'message': messageController.text.trim(),
            'messageType': messageType,
            'proposedVisitAt': proposedVisitAt?.toUtc().toIso8601String(),
          });
      messageController.clear();
      await _loadMessages();
    } catch (exception) {
      if (mounted) {
        setState(
            () => error = 'Envoi impossible : ${describeError(exception)}');
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.propertyTitle)),
      body: Column(
        children: [
          if (error != null)
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text(error!, style: const TextStyle(color: Colors.red))),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(child: Text('Aucun message.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) =>
                            _MessageBubble(message: messages[index]),
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                      child: DropdownButtonFormField<String>(
                          value: messageType,
                          decoration: InputDecoration(
                              labelText: widget.isManager ? 'Type' : 'Réponse'),
                          items: [
                            const DropdownMenuItem(
                                value: 'message', child: Text('Message')),
                            if (widget.isManager)
                              const DropdownMenuItem(
                                  value: 'visit_proposal',
                                  child: Text('Proposer une visite')),
                            const DropdownMenuItem(
                                value: 'visit_confirmation',
                                child: Text('Confirmer la visite')),
                            const DropdownMenuItem(
                                value: 'visit_declined',
                                child: Text('Refuser la visite')),
                          ],
                          onChanged: (value) => setState(
                              () => messageType = value ?? 'message'))),
                  if (messageType == 'visit_proposal')
                    IconButton(
                        onPressed: _chooseVisitDate,
                        icon: const Icon(Icons.event),
                        tooltip: 'Choisir une date'),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: messageController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                              hintText: widget.isManager
                                  ? 'Votre message'
                                  : 'Votre réponse'))),
                  const SizedBox(width: 8),
                  IconButton(
                      onPressed: sending ? null : _send,
                      icon: sending
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.send),
                      color: IvoryColors.green,
                      tooltip: 'Envoyer'),
                ]),
                if (proposedVisitAt != null)
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Visite : ${proposedVisitAt!.day}/${proposedVisitAt!.month}/${proposedVisitAt!.year} à ${proposedVisitAt!.hour.toString().padLeft(2, '0')}:${proposedVisitAt!.minute.toString().padLeft(2, '0')}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InterestMessageItem {
  InterestMessageItem(this.message, this.messageType, this.proposedVisitAt,
      this.createdAt, this.senderUsername);

  final String message;
  final String messageType;
  final String? proposedVisitAt;
  final String createdAt;
  final String senderUsername;

  factory InterestMessageItem.fromJson(Map<String, dynamic> json) =>
      InterestMessageItem(
        json['message'] as String? ?? '',
        json['messageType'] as String? ?? 'message',
        json['proposedVisitAt'] as String?,
        json['createdAt'] as String? ?? '',
        (json['sender'] as Map<String, dynamic>?)?['username'] as String? ??
            'Utilisateur',
      );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final InterestMessageItem message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.senderUsername,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(message.message),
              if (message.proposedVisitAt != null)
                Text('Visite proposée : ${message.proposedVisitAt}'),
            ],
          ),
        ),
      ),
    );
  }
}

const interestMessagesQuery = r'''
query InterestMessages($interestRequestId: ID!) {
  propertyInterestMessages(interestRequestId: $interestRequestId) {
    id message messageType proposedVisitAt createdAt sender { username }
  }
}
''';

const sendInterestMessageMutation = r'''
mutation SendInterestMessage($interestRequestId: ID!, $message: String!, $messageType: String, $proposedVisitAt: DateTime) {
  sendPropertyInterestMessage(interestRequestId: $interestRequestId, message: $message, messageType: $messageType, proposedVisitAt: $proposedVisitAt) {
    interestMessage { id message messageType proposedVisitAt createdAt }
  }
}
''';
