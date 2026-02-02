import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String apartment,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'apartment': apartment,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ========== NEW METHOD ==========

  /// Delete user data from Firestore
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// Update user data in Firestore
  Future<void> updateUser(String uid, Map<String, dynamic> updateData) async {
    await _db.collection('users').doc(uid).update(updateData);
  }
  // ========== REQUESTS ==========

  Future<void> createRequest({
    required String uid,
    required String title,
    required String description,
    required String category,
    required String availableDate,
    required String availableTime,
    required String apartment,
    required String phone,
  }) async {
    await _db.collection('requests').add({
      'uid': uid,
      'title': title,
      'description': description,
      'category': category,
      'availableDate': availableDate,
      'availableTime': availableTime,
      'apartment': apartment,
      'phone': phone,
      'status': 'PENDING', // Default status
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create a notification for the user
    await createNotification(
      uid: uid,
      title: 'Request Submitted',
      subtitle: 'Your request "$title" has been successfully submitted.',
      type: 'request',
    );

    // Create a notification for the admin
    await createNotification(
      uid: 'admin',
      title: 'New Maintenance Request',
      subtitle: 'A new request "$title" has been submitted from $apartment.',
      type: 'request',
    );
  }

  Stream<QuerySnapshot> getAdminNotificationsStream() {
    return _db
        .collection('notifications')
        .where('uid', isEqualTo: 'admin')
        .snapshots();
  }

  Stream<QuerySnapshot> getRequestsStream(String uid) {
    return _db
        .collection('requests')
        .where('uid', isEqualTo: uid)
        // .orderBy('createdAt', descending: true) // Temporarily removed to fix index issue
        .snapshots();
  }

  Future<void> deleteRequest(String requestId) async {
    await _db.collection('requests').doc(requestId).delete();
  }

  // Admin: Get all requests
  Stream<QuerySnapshot> getAllRequestsStream() {
    return _db.collection('requests').snapshots();
    // In a real app, you might want to order by date, but make sure index exists
    // .orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateRequest(
    String requestId,
    Map<String, dynamic> updateData,
  ) async {
    await _db.collection('requests').doc(requestId).update(updateData);
  }

  // ========== NOTIFICATIONS ==========

  Stream<QuerySnapshot> getNotificationsStream(String uid) {
    return _db
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  Future<void> createNotification({
    required String uid,
    required String title,
    required String subtitle,
    required String type,
  }) async {
    await _db.collection('notifications').add({
      'uid': uid,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
