import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/app_provider.dart';
import '../../models/event_model.dart';

class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});

  void _showAddEventDialog(BuildContext context) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final locationC = TextEditingController();
    final imageC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(controller: locationC, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: imageC, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AppProvider>(ctx, listen: false);
              await provider.addEvent(EventModel(
                id: '',
                title: titleC.text.trim(),
                description: descC.text.trim(),
                date: DateTime.now().add(const Duration(days: 7)),
                location: locationC.text.trim(),
                imageUrl: imageC.text.trim().isEmpty ? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500&q=80' : imageC.text.trim(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, EventModel event) {
    final titleC = TextEditingController(text: event.title);
    final descC = TextEditingController(text: event.description);
    final locationC = TextEditingController(text: event.location);
    final imageC = TextEditingController(text: event.imageUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(controller: locationC, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: imageC, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AppProvider>(ctx, listen: false);
              await provider.updateEvent(event.id, {
                'title': titleC.text.trim(),
                'description': descC.text.trim(),
                'location': locationC.text.trim(),
                'imageUrl': imageC.text.trim().isEmpty ? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500&q=80' : imageC.text.trim(),
                'date': Timestamp.fromDate(event.date),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final provider = Provider.of<AppProvider>(ctx, listen: false);
              await provider.deleteEvent(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${event.location} • ${event.date.day.toString().padLeft(2,'0')}/${event.date.month.toString().padLeft(2,'0')}/${event.date.year}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit, color: Colors.blue),
                        onPressed: () => _showEditEventDialog(context, event),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, color: Colors.red),
                        onPressed: () => _confirmDelete(context, event.id, event.title),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
