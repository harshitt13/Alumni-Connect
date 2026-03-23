import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/app_provider.dart';
import '../chat_screen.dart';
import '../notification_panel.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        actions: [
          // Notifications Badge
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              return StreamBuilder<List>(
                stream: provider.getUnreadNotificationsStream(),
                builder: (context, snapshot) {
                  final unreadNotif = snapshot.data?.length ?? 0;
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: unreadNotif > 0,
                      label: Text(unreadNotif.toString()),
                      child: const Icon(LucideIcons.bell),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const NotificationPanel(),
                      );
                    },
                  );
                }
              );
            }
          ),
          const SizedBox(width: 8),
          // Messages Badge
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: 'admin@admin.com').snapshots(),
            builder: (context, snapshot) {
              int unread = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final u = (doc.data() as Map<String, dynamic>)['unreadCount']?['admin@admin.com'] ?? 0;
                  unread += (u as num).toInt();
                }
              }
              return IconButton(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text(unread.toString()),
                  child: const Icon(LucideIcons.messageCircle),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const _AdminSupportInbox()));
                },
              );
            }
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.red),
            onPressed: () async {
              await Provider.of<AppProvider>(context, listen: false).signOut();
              if (context.mounted) context.go('/login');
            },
          )
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('System Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Alumni', provider.alumni.length.toString(), LucideIcons.users, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Active Events', provider.events.length.toString(), LucideIcons.calendar, Colors.orange)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Support Messages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: 'admin@admin.com').snapshots(),
                    builder: (context, snapshot) {
                      int unread = 0;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final u = (doc.data() as Map<String, dynamic>)['unreadCount']?['admin@admin.com'] ?? 0;
                          unread += (u as num).toInt();
                        }
                      }
                      return TextButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const _AdminSupportInbox()));
                        },
                        icon: Badge(
                          isLabelVisible: unread > 0,
                          label: Text(unread.toString()),
                          child: const Icon(LucideIcons.inbox, size: 18),
                        ),
                        label: const Text('View All'),
                      );
                    }
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...provider.alumni.take(3).map((a) => ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(a.profileImageUrl)),
                title: Text(a.name),
                subtitle: Text('${a.role} at ${a.company}'),
              )),
            ],
          );
        }
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AdminSupportInbox extends StatelessWidget {
  const _AdminSupportInbox();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Inbox')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: 'admin@admin.com').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rawChats = snapshot.data?.docs ?? [];
          final chats = List<QueryDocumentSnapshot>.from(rawChats);
          chats.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>?;
            final dataB = b.data() as Map<String, dynamic>?;
            final t1 = dataA?['lastTimestamp'] as Timestamp?;
            final t2 = dataB?['lastTimestamp'] as Timestamp?;
            if (t1 == null || t2 == null) return 0;
            return t2.compareTo(t1);
          });
          
          if (chats.isEmpty) {
            return const Center(child: Text('No support messages yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final participants = List<String>.from(chatData['participants'] ?? []);
              final otherUser = participants.firstWhere((p) => p != 'admin@admin.com', orElse: () => 'Unknown');
              final unreadCount = (chatData['unreadCount']?['admin@admin.com'] ?? 0) as int;
              
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(otherUser[0].toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                  title: Text(otherUser, style: TextStyle(fontWeight: FontWeight.bold, color: unreadCount > 0 ? Theme.of(context).primaryColor : null)),
                  subtitle: Text(chatData['lastMessage'] ?? 'No messages', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: unreadCount > 0 
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    : null,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chats[index].id, 
                        currentUserEmail: 'admin@admin.com', 
                        otherUserName: otherUser,
                        otherUserEmail: otherUser,
                      ),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
