import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/app_provider.dart';
import '../../models/alumni_model.dart';

class ManageAlumniScreen extends StatelessWidget {
  const ManageAlumniScreen({super.key});

  void _showAddAlumniDialog(BuildContext context) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final majorC = TextEditingController();
    final companyC = TextEditingController();
    final roleC = TextEditingController();
    final cgpaC = TextEditingController();
    final yearC = TextEditingController(text: '2026');
    final passC = TextEditingController();
    final imageC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Alumni'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: majorC, decoration: const InputDecoration(labelText: 'Major')),
              TextField(controller: companyC, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: roleC, decoration: const InputDecoration(labelText: 'Role')),
              TextField(controller: yearC, decoration: const InputDecoration(labelText: 'Graduation Year'), keyboardType: TextInputType.number),
              TextField(controller: cgpaC, decoration: const InputDecoration(labelText: 'CGPA'), keyboardType: TextInputType.number),
              TextField(controller: passC, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              TextField(controller: imageC, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AppProvider>(ctx, listen: false);
              await provider.addAlumni(AlumniModel(
                id: '',
                email: emailC.text.trim(),
                name: nameC.text.trim(),
                profileImageUrl: imageC.text.trim().isEmpty ? 'https://i.pravatar.cc/150?u=${emailC.text.trim()}' : imageC.text.trim(),
                major: majorC.text.trim(),
                graduationYear: int.tryParse(yearC.text.trim()) ?? 2026,
                company: companyC.text.trim(),
                role: roleC.text.trim(),
                cgpa: double.tryParse(cgpaC.text.trim()) ?? 0.0,
              ), password: passC.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditAlumniDialog(BuildContext context, AlumniModel student) {
    final nameC = TextEditingController(text: student.name);
    final emailC = TextEditingController(text: student.email);
    final majorC = TextEditingController(text: student.major);
    final companyC = TextEditingController(text: student.company);
    final roleC = TextEditingController(text: student.role);
    final cgpaC = TextEditingController(text: student.cgpa.toString());
    final yearC = TextEditingController(text: student.graduationYear.toString());
    final imageC = TextEditingController(text: student.profileImageUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Alumni'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: majorC, decoration: const InputDecoration(labelText: 'Major')),
              TextField(controller: companyC, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: roleC, decoration: const InputDecoration(labelText: 'Role')),
              TextField(controller: yearC, decoration: const InputDecoration(labelText: 'Graduation Year'), keyboardType: TextInputType.number),
              TextField(controller: cgpaC, decoration: const InputDecoration(labelText: 'CGPA'), keyboardType: TextInputType.number),
              TextField(controller: imageC, decoration: const InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AppProvider>(ctx, listen: false);
              await provider.updateAlumni(student.id, {
                'name': nameC.text.trim(),
                'email': emailC.text.trim(),
                'major': majorC.text.trim(),
                'profileImageUrl': imageC.text.trim().isEmpty ? 'https://i.pravatar.cc/150?u=${emailC.text.trim()}' : imageC.text.trim(),
                'company': companyC.text.trim(),
                'role': roleC.text.trim(),
                'graduationYear': int.tryParse(yearC.text.trim()) ?? student.graduationYear,
                'cgpa': double.tryParse(cgpaC.text.trim()) ?? student.cgpa,
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final provider = Provider.of<AppProvider>(ctx, listen: false);
              await provider.deleteAlumni(id);
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
      appBar: AppBar(title: const Text('Manage Alumni')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.alumni.length,
            itemBuilder: (context, index) {
              final student = provider.alumni[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(student.profileImageUrl)),
                  title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${student.role} • ${student.email}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit, color: Colors.blue),
                        onPressed: () => _showEditAlumniDialog(context, student),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, color: Colors.red),
                        onPressed: () => _confirmDelete(context, student.id, student.name),
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
        onPressed: () => _showAddAlumniDialog(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
