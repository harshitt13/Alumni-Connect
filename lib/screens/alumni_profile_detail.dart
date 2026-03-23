import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/alumni_model.dart';
import '../data/app_provider.dart';
import 'chat_screen.dart';

class AlumniProfileDetail extends StatelessWidget {
  final AlumniModel student;

  const AlumniProfileDetail({super.key, required this.student});

  String _generateChatId(String email1, String email2) {
    final sorted = [email1.toLowerCase(), email2.toLowerCase()]..sort();
    return '${sorted[0]}_${sorted[1]}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currentEmail = provider.currentUser?.email ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'profile_${student.id}',
                child: Image.network(
                  student.profileImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('${student.role} at ${student.company}', style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(LucideIcons.graduationCap, color: Theme.of(context).textTheme.bodyMedium?.color, size: 20),
                      const SizedBox(width: 8),
                      Text('${student.major}, Class of ${student.graduationYear}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.award, color: Theme.of(context).textTheme.bodyMedium?.color, size: 20),
                      const SizedBox(width: 8),
                      Text('CGPA: ${student.cgpa.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Send Message button (1v1 chat)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (currentEmail.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You need a profile with an email to chat.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        final chatId = _generateChatId(currentEmail, student.email);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              currentUserEmail: currentEmail,
                              otherUserName: student.name,
                              otherUserEmail: student.email,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.messageCircle),
                      label: const Text('Send Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contact Admin / Support button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (currentEmail.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You need a profile with an email to contact support.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        final supportChatId = _generateChatId(currentEmail, 'admin@admin.com');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: supportChatId,
                              currentUserEmail: currentEmail,
                              otherUserName: 'Admin Support',
                              otherUserEmail: 'admin@admin.com',
                            ),
                          ),
                        );
                      },
                      icon: Icon(LucideIcons.helpCircle, color: Theme.of(context).primaryColor),
                      label: Text('Contact Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
