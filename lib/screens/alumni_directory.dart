import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../data/app_provider.dart';
import '../models/alumni_model.dart';
import 'alumni_profile_detail.dart';

class AlumniDirectory extends StatefulWidget {
  const AlumniDirectory({super.key});

  @override
  State<AlumniDirectory> createState() => _AlumniDirectoryState();
}

class _AlumniDirectoryState extends State<AlumniDirectory> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Network'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Apply search and filter
          List<AlumniModel> filtered = provider.alumni.where((s) {
            final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.major.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesFilter = _selectedFilter == 'All' || s.major == _selectedFilter;
            return matchesSearch && matchesFilter;
          }).toList();

          // Collect unique majors for filter
          final majors = ['All', ...provider.alumni.map((s) => s.major).toSet()];

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search by name, company, or major...',
                        prefixIcon: Icon(LucideIcons.search, color: Theme.of(context).primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: majors.length,
                    itemBuilder: (context, index) {
                      final major = majors.elementAt(index);
                      final isSelected = _selectedFilter == major;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(major),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                          checkmarkColor: Theme.of(context).primaryColor,
                          onSelected: (_) => setState(() => _selectedFilter = major),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No alumni found'))
                      : AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (BuildContext context, int index) {
                              final student = filtered[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _AlumniCard(student: student),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlumniCard extends StatelessWidget {
  final AlumniModel student;

  const _AlumniCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlumniProfileDetail(student: student),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: 'profile_${student.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      student.profileImageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${student.role} at ${student.company}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Class of ${student.graduationYear}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
