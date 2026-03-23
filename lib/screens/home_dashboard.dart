import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/app_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'alumni_directory.dart';
import 'chat_screen.dart';
import 'notification_panel.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () => provider.loadData(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      title: Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    actions: [
                      // Notifications Badge
                      StreamBuilder<List>(
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
                      ),
                      const SizedBox(width: 8),
                      // Messages Badge
                      StreamBuilder<QuerySnapshot>(
                        stream: provider.currentUser == null && !provider.isAdmin 
                            ? const Stream.empty() 
                            : FirebaseFirestore.instance
                                .collection('chats')
                                .where('participants', arrayContains: provider.isAdmin ? 'admin@admin.com' : provider.currentUser?.email)
                                .snapshots(),
                        builder: (context, snapshot) {
                          int unread = 0;
                          if (snapshot.hasData) {
                            final userEmail = provider.isAdmin ? 'admin@admin.com' : provider.currentUser?.email ?? '';
                            for (var doc in snapshot.data!.docs) {
                              final u = (doc.data() as Map<String, dynamic>)['unreadCount']?[userEmail] ?? 0;
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
                              if (provider.currentUser == null && !provider.isAdmin) return;
                              final currentUserEmail = provider.isAdmin ? 'admin@admin.com' : provider.currentUser!.email;
                              final otherEmail = provider.isAdmin ? provider.currentUser?.email ?? 'user@user.com' : 'admin@admin.com';
                              final supportChatId = [currentUserEmail.toLowerCase(), otherEmail.toLowerCase()]..sort();
                              final chatId = '${supportChatId[0]}_${supportChatId[1]}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatId: chatId,
                                    currentUserEmail: currentUserEmail,
                                    otherUserName: provider.isAdmin ? (provider.currentUser?.name ?? 'Alumni') : 'Admin Support',
                                    otherUserEmail: otherEmail,
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickActions(context),
                          const SizedBox(height: 32),
                          _buildUnreadSection(context, provider),
                          const SizedBox(height: 32),
                          Text('Upcoming Events', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          provider.isLoading
                              ? _buildEventsShimmer(isDark)
                              : _buildEventsList(context, provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionCard(icon: LucideIcons.search, title: 'Find Alumni', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AlumniDirectory()));
        }),
        _ActionCard(icon: LucideIcons.briefcase, title: 'Jobs', onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jobs portal coming soon!'), backgroundColor: Colors.orange));
        }),
        _ActionCard(icon: LucideIcons.users, title: 'Groups', onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Groups coming soon!'), backgroundColor: Colors.orange));
        }),
        _ActionCard(icon: LucideIcons.messageCircle, title: 'Mentorship', onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mentorship coming soon!'), backgroundColor: Colors.orange));
        }),
      ],
    );
  }

  Widget _buildUnreadSection(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Updates', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            // Unread Notifications Card
            Expanded(
              child: StreamBuilder<List>(
                stream: provider.getUnreadNotificationsStream(),
                builder: (context, snapshot) {
                  final notifications = snapshot.data ?? [];
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const NotificationPanel(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notifications.isNotEmpty
                            ? Colors.blue.withOpacity(0.1)
                            : (isDark ? Colors.grey[800] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(12),
                        border: notifications.isNotEmpty
                            ? Border.all(color: Colors.blue.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                            child: const Icon(LucideIcons.bell, color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${notifications.length} Notification${notifications.length != 1 ? 's' : ''}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                notifications.isEmpty ? 'All caught up!' : 'New updates',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Unread Messages Card
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: provider.currentUser == null && !provider.isAdmin
                    ? const Stream.empty()
                    : FirebaseFirestore.instance
                        .collection('chats')
                        .where('participants', arrayContains: provider.isAdmin ? 'admin@admin.com' : provider.currentUser?.email)
                        .snapshots(),
                builder: (context, snapshot) {
                  int unreadMessages = 0;
                  if (snapshot.hasData) {
                    final userEmail = provider.isAdmin ? 'admin@admin.com' : provider.currentUser?.email ?? '';
                    for (var doc in snapshot.data!.docs) {
                      final u = (doc.data() as Map<String, dynamic>)['unreadCount']?[userEmail] ?? 0;
                      unreadMessages += (u as num).toInt();
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      if (provider.currentUser == null && !provider.isAdmin) return;
                      final currentUserEmail = provider.isAdmin ? 'admin@admin.com' : provider.currentUser!.email;
                      final otherEmail = provider.isAdmin ? provider.currentUser?.email ?? 'user@user.com' : 'admin@admin.com';
                      final supportChatId = [currentUserEmail.toLowerCase(), otherEmail.toLowerCase()]..sort();
                      final chatId = '${supportChatId[0]}_${supportChatId[1]}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            currentUserEmail: currentUserEmail,
                            otherUserName: provider.isAdmin ? (provider.currentUser?.name ?? 'Alumni') : 'Admin Support',
                            otherUserEmail: otherEmail,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: unreadMessages > 0
                            ? Colors.green.withOpacity(0.1)
                            : (isDark ? Colors.grey[800] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(12),
                        border: unreadMessages > 0
                            ? Border.all(color: Colors.green.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.withOpacity(0.2),
                            ),
                            child: const Icon(LucideIcons.messageCircle, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$unreadMessages Message${unreadMessages != 1 ? 's' : ''}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                unreadMessages == 0 ? 'No new messages' : 'Unread',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventsShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: List.generate(
          2,
          (index) => Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, AppProvider provider) {
    return Column(
      children: provider.events.map((event) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(event.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${event.date.day.toString().padLeft(2,'0')}/${event.date.month.toString().padLeft(2,'0')} • ${event.location}'),
            trailing: const Icon(LucideIcons.chevronRight),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
