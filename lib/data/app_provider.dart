import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/alumni_model.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import 'mock_data.dart';

class AppProvider with ChangeNotifier {
  bool isLoading = false;
  bool isAdmin = false;
  AlumniModel? currentUser;
  List<AlumniModel> alumni = [];
  List<EventModel> events = [];
  List<NotificationModel> notifications = [];
  ThemeMode themeMode = ThemeMode.light;
  int unreadMessageCount = 0;
  int unreadNotificationCount = 0;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppProvider() {
    loadData();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final alumniSnapshot = await _db.collection('alumni').get();
      if (alumniSnapshot.docs.isEmpty) {
        alumni = MockData.alumniList;
      } else {
        alumni = alumniSnapshot.docs.map((doc) => AlumniModel.fromMap(doc.data(), doc.id)).toList();
      }

      final eventsSnapshot = await _db.collection('events').get();
      if (eventsSnapshot.docs.isEmpty) {
        events = MockData.eventsList;
      } else {
        events = eventsSnapshot.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      alumni = MockData.alumniList;
      events = MockData.eventsList;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

      if (email.toLowerCase().trim() == 'admin@admin.com') {
        isAdmin = true;
        isLoading = false;
        notifyListeners();
        return 'ADMIN';
      } else {
        isAdmin = false;
        try {
          currentUser = alumni.firstWhere((s) => s.email.toLowerCase() == email.trim().toLowerCase());
        } catch (e) {
          if (alumni.isNotEmpty) currentUser = alumni.first;
        }
        isLoading = false;
        notifyListeners();
        return null;
      }
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      return e.message ?? 'Authentication failed';
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Invalid email or password';
    }
  }

  Future<String?> tryAutoLogin() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    if (user.email?.toLowerCase() == 'admin@admin.com') {
      await _auth.signOut();
      return null;
    }

    await loadData();

    isAdmin = false;
    try {
      currentUser = alumni.firstWhere((s) => s.email.toLowerCase() == user.email!.toLowerCase());
    } catch (e) {
      if (alumni.isNotEmpty) currentUser = alumni.first;
    }
    notifyListeners();
    return 'USER';
  }

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    isAdmin = false;
    notifyListeners();
  }

  Future<void> addAlumni(AlumniModel a, {String? password}) async {
    if (password != null && password.isNotEmpty) {
      try {
        final tempApp = await Firebase.initializeApp(name: 'TempApp', options: Firebase.app().options);
        await FirebaseAuth.instanceFor(app: tempApp).createUserWithEmailAndPassword(email: a.email, password: password);
        await tempApp.delete();
      } catch (e) {
        debugPrint('Failed to create user auth: $e');
      }
    }
    await _db.collection('alumni').add(a.toMap());
    await loadData();
  }

  Future<void> updateAlumni(String id, Map<String, dynamic> data) async {
    await _db.collection('alumni').doc(id).update(data);
    await loadData();
  }

  Future<void> deleteAlumni(String id) async {
    await _db.collection('alumni').doc(id).delete();
    await loadData();
  }

  Future<void> addEvent(EventModel event) async {
    await _db.collection('events').add(event.toMap());
    await loadData();
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _db.collection('events').doc(id).update(data);
    await loadData();
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
    await loadData();
  }

  Future<String?> updateUserProfile({String? name, String? major, String? company, String? role}) async {
    if (currentUser == null) return 'No user logged in';
    try {
      final updates = <String, dynamic>{};
      if (name != null && name.isNotEmpty) updates['name'] = name;
      if (major != null && major.isNotEmpty) updates['major'] = major;
      if (company != null && company.isNotEmpty) updates['company'] = company;
      if (role != null && role.isNotEmpty) updates['role'] = role;
      if (updates.isNotEmpty) {
        await _db.collection('alumni').doc(currentUser!.id).update(updates);
        await loadData();
        try {
          currentUser = alumni.firstWhere((s) => s.id == currentUser!.id);
        } catch (_) {}
        notifyListeners();
      }
      return null;
    } catch (e) {
      return 'Failed to update profile';
    }
  }

  Future<String?> updateEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Not logged in';
      final cred = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
      await user.verifyBeforeUpdateEmail(newEmail);
      if (currentUser != null) {
        await _db.collection('alumni').doc(currentUser!.id).update({'email': newEmail});
        await loadData();
        try {
          currentUser = alumni.firstWhere((s) => s.id == currentUser!.id);
        } catch (_) {}
        notifyListeners();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update email';
    } catch (e) {
      return 'Failed to update email';
    }
  }

  Future<String?> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Not logged in';
      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to update password';
    } catch (e) {
      return 'Failed to update password';
    }
  }

  /// Get unread message count for current user
  Future<void> updateUnreadMessageCount() async {
    if (currentUser == null && !isAdmin) return;
    
    try {
      final userEmail = isAdmin ? 'admin@admin.com' : currentUser!.email;
      final snapshot = await _db
          .collection('chats')
          .where('participants', arrayContains: userEmail)
          .get();

      int totalUnread = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadMap = data['unreadCount'] as Map<String, dynamic>? ?? {};
        final unread = unreadMap[userEmail] ?? 0;
        totalUnread += (unread as num).toInt();
      }
      
      unreadMessageCount = totalUnread;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating message count: $e');
    }
  }

  /// Stream for real-time unread message count
  Stream<int> getUnreadMessageStream() {
    if (currentUser == null && !isAdmin) return Stream.empty();
    
    final userEmail = isAdmin ? 'admin@admin.com' : currentUser!.email;
    return _db
        .collection('chats')
        .where('participants', arrayContains: userEmail)
        .snapshots()
        .map((snapshot) {
          int totalUnread = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final unreadMap = data['unreadCount'] as Map<String, dynamic>? ?? {};
            final unread = unreadMap[userEmail] ?? 0;
            totalUnread += (unread as num).toInt();
          }
          return totalUnread;
        });
  }

  /// Get unread notifications count
  Future<void> updateUnreadNotificationCount() async {
    if (currentUser == null && !isAdmin) return;
    
    try {
      final userId = isAdmin ? 'admin' : currentUser!.id;
      final snapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      unreadNotificationCount = snapshot.docs.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating notification count: $e');
    }
  }

  /// Stream for real-time unread notifications
  Stream<List<NotificationModel>> getUnreadNotificationsStream() {
    if (currentUser == null && !isAdmin) return Stream.empty();
    
    final userId = isAdmin ? 'admin' : currentUser!.id;
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create a new notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'relatedId': relatedId,
        'data': data,
      });
      
      // Update unread count
      if (userId == currentUser?.id || (isAdmin && userId == 'admin')) {
        await updateUnreadNotificationCount();
      }
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      await updateUnreadNotificationCount();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (currentUser == null && !isAdmin) return;
    
    try {
      final userId = isAdmin ? 'admin' : currentUser!.id;
      final snapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        await _db.collection('notifications').doc(doc.id).update({
          'isRead': true,
        });
      }
      
      await updateUnreadNotificationCount();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Send message notification
  Future<void> sendMessageNotification({
    required String recipientId,
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    try {
      await createNotification(
        userId: recipientId,
        title: 'New Message from $senderName',
        message: message.length > 50 ? '${message.substring(0, 50)}...' : message,
        type: 'message',
        relatedId: chatId,
        data: {'chatId': chatId, 'senderName': senderName},
      );
    } catch (e) {
      debugPrint('Error sending message notification: $e');
    }
  }

  /// Send event notification
  Future<void> sendEventNotification({
    required String eventName,
    required String eventDetails,
    required String eventId,
  }) async {
    try {
      // Send to all alumni
      for (var alumnus in alumni) {
        await createNotification(
          userId: alumnus.id,
          title: 'New Event: $eventName',
          message: eventDetails.length > 50 ? '${eventDetails.substring(0, 50)}...' : eventDetails,
          type: 'event',
          relatedId: eventId,
          data: {'eventId': eventId, 'eventName': eventName},
        );
      }
    } catch (e) {
      debugPrint('Error sending event notification: $e');
    }
  }
}

