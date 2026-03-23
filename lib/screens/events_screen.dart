import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_provider.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & News'),
        centerTitle: false,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              return _EventCard(event: provider.events[index]);
            },
          );
        },
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final dynamic event;
  const _EventCard({required this.event});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _isRsvped = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(event.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${event.date.day.toString().padLeft(2,'0')}/${event.date.month.toString().padLeft(2,'0')}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Icon(LucideIcons.mapPin, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                    const SizedBox(width: 4),
                    Text(event.location, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(event.description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRsvped ? null : () async {
                      setState(() { _isRsvped = true; });
                      
                      final provider = Provider.of<AppProvider>(context, listen: false);
                      if (provider.currentUser != null) {
                        try {
                          final supportChatId = [provider.currentUser!.email.toLowerCase(), 'admin@admin.com']..sort();
                          final chatId = '${supportChatId[0]}_${supportChatId[1]}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
                          
                          await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
                            'lastMessage': 'I have RSVP\'d for the event: ${event.title}',
                            'lastTimestamp': FieldValue.serverTimestamp(),
                            'participants': supportChatId,
                          }, SetOptions(merge: true));
                          
                          await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
                            'text': 'I have RSVP\'d for the event: ${event.title}',
                            'senderEmail': provider.currentUser!.email,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                        } catch (_) {}
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('RSVP submitted successfully!'), backgroundColor: Colors.green),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRsvped ? Colors.grey : Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isRsvped ? 'RSVP Confirmed' : 'RSVP Now', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
