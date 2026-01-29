import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
  // ========== REQUESTS ==========

  Future<void> createRequest({
    required String uid,
    required String title,
    required String description,
    required String category,
    required String availableDate,
    required String availableTime,
    required String apartment,
    String? imageUrl,
  }) async {
    await _db.collection('requests').add({
      'uid': uid,
      'title': title,
      'description': description,
      'category': category,
      'availableDate': availableDate,
      'availableTime': availableTime,
      'apartment': apartment,
      'imageUrl': imageUrl,
      'status': 'PENDING', // Default status
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> uploadRequestImage(File imageFile) async {
    try {
      final fileName = 'request_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('request_images').child(fileName);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> getRequestsStream(String uid) {
    return _db
        .collection('requests')
        .where('uid', isEqualTo: uid)
        // .orderBy('createdAt', descending: true) // Temporarily removed to fix index issue
        .snapshots();
  }
}
