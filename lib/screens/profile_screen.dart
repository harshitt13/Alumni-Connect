import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../data/app_provider.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.settings),
                onPressed: () => _showSettingsSheet(context, provider),
              )
            ],
          ),
          body: user == null
              ? const Center(child: Text('No profile found.'))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(user.profileImageUrl),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${user.role} at ${user.company}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('CGPA: ${user.cgpa.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ),
                  const SizedBox(height: 32),
                  _buildProfileMenuItem(context, icon: LucideIcons.user, title: 'Edit Profile', onTap: () => _showEditProfileDialog(context, provider)),
                  _buildProfileMenuItem(context, icon: LucideIcons.mail, title: 'Change Email', onTap: () => _showChangeEmailDialog(context, provider)),
                  _buildProfileMenuItem(context, icon: LucideIcons.lock, title: 'Change Password', onTap: () => _showChangePasswordDialog(context, provider)),
                  _buildProfileMenuItem(context, icon: LucideIcons.helpCircle, title: 'Contact Admin', onTap: () {
                    if (user.email.isEmpty) return;
                    final supportChatId = [user.email.toLowerCase(), 'admin@admin.com']..sort();
                    final chatId = '${supportChatId[0]}_${supportChatId[1]}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: chatId,
                          currentUserEmail: user.email,
                          otherUserName: 'Admin Support',
                          otherUserEmail: 'admin@admin.com',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      await provider.signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(LucideIcons.logOut, color: Colors.red),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final user = provider.currentUser!;
    final nameC = TextEditingController(text: user.name);
    final majorC = TextEditingController(text: user.major);
    final companyC = TextEditingController(text: user.company);
    final roleC = TextEditingController(text: user.role);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: majorC, decoration: const InputDecoration(labelText: 'Major')),
              TextField(controller: companyC, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: roleC, decoration: const InputDecoration(labelText: 'Role')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final error = await provider.updateUserProfile(
                name: nameC.text.trim(),
                major: majorC.text.trim(),
                company: companyC.text.trim(),
                role: roleC.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error ?? 'Profile updated!'),
                  backgroundColor: error != null ? Colors.red : Colors.green,
                ));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, AppProvider provider) {
    final emailC = TextEditingController();
    final passC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: emailC, decoration: const InputDecoration(labelText: 'New Email')),
              TextField(controller: passC, decoration: const InputDecoration(labelText: 'Current Password'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final error = await provider.updateEmail(emailC.text.trim(), passC.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error ?? 'Email updated! A verification email has been sent.'),
                  backgroundColor: error != null ? Colors.red : Colors.green,
                ));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppProvider provider) {
    final currentC = TextEditingController();
    final newC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: currentC, decoration: const InputDecoration(labelText: 'Current Password'), obscureText: true),
              TextField(controller: newC, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final error = await provider.updatePassword(currentC.text, newC.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error ?? 'Password updated!'),
                  backgroundColor: error != null ? Colors.red : Colors.green,
                ));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(provider.themeMode == ThemeMode.dark ? LucideIcons.sun : LucideIcons.moon),
                title: const Text('Toggle Dark Mode'),
                trailing: Switch(value: provider.themeMode == ThemeMode.dark, onChanged: (_) => provider.toggleTheme()),
              ),
              ListTile(
                leading: const Icon(LucideIcons.info),
                title: const Text('About Alumni Connect'),
                onTap: () {
                  Navigator.pop(ctx);
                  showAboutDialog(context: context, applicationName: 'Alumni Connect', applicationVersion: '1.0.0');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
        onTap: onTap,
      ),
    );
  }
}
