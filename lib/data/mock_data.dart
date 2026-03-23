import '../models/alumni_model.dart';
import '../models/event_model.dart';

class MockData {
  static final List<AlumniModel> alumniList = [
    AlumniModel(
      id: '1',
      email: 'sarah@alumni.edu',
      name: 'Sarah Jenkins',
      profileImageUrl: 'https://i.pravatar.cc/150?u=12',
      major: 'Computer Science',
      graduationYear: 2021,
      company: 'TechFlow Inc.',
      role: 'Software Engineer',
      cgpa: 3.8,
    ),
    AlumniModel(
      id: '2',
      email: 'david@alumni.edu',
      name: 'David Chen',
      profileImageUrl: 'https://i.pravatar.cc/150?u=8',
      major: 'Business Administration',
      graduationYear: 2018,
      company: 'Global Ventures',
      role: 'Investment Analyst',
      cgpa: 3.5,
    ),
    AlumniModel(
      id: '3',
      email: 'emily@alumni.edu',
      name: 'Emily Davis',
      profileImageUrl: 'https://i.pravatar.cc/150?u=5',
      major: 'Design',
      graduationYear: 2022,
      company: 'Creative Studio',
      role: 'UX Designer',
      cgpa: 3.9,
    ),
    AlumniModel(
      id: '4',
      email: 'michael@alumni.edu',
      name: 'Michael Torres',
      profileImageUrl: 'https://i.pravatar.cc/150?u=44',
      major: 'Engineering',
      graduationYear: 2015,
      company: 'BuildRight Construction',
      role: 'Project Manager',
      cgpa: 3.4,
    ),
  ];

  static final List<EventModel> eventsList = [
    EventModel(
      id: 'e1',
      title: 'Annual Tech Mixer 2026',
      description: 'Join us for an evening of networking with industry leaders.',
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'Silicon Valley Campus',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500&q=80',
    ),
    EventModel(
      id: 'e2',
      title: 'Startup Founders Panel',
      description: 'Hear from our alumni who have successfully launched their startups.',
      date: DateTime.now().add(const Duration(days: 30)),
      location: 'Downtown Innovation Hub',
      imageUrl: 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=500&q=80',
    ),
  ];
}
