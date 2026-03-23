class AlumniModel {
  final String id;
  final String email;
  final String name;
  final String profileImageUrl;
  final String major;
  final int graduationYear;
  final String company;
  final String role;
  final double cgpa;

  AlumniModel({
    required this.id,
    required this.email,
    required this.name,
    required this.profileImageUrl,
    required this.major,
    required this.graduationYear,
    required this.company,
    required this.role,
    required this.cgpa,
  });

  factory AlumniModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AlumniModel(
      id: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? 'https://i.pravatar.cc/150',
      major: data['major'] ?? '',
      graduationYear: data['graduationYear'] ?? 2026,
      company: data['company'] ?? '',
      role: data['role'] ?? '',
      cgpa: (data['cgpa'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'major': major,
      'graduationYear': graduationYear,
      'company': company,
      'role': role,
      'cgpa': cgpa,
    };
  }
}
