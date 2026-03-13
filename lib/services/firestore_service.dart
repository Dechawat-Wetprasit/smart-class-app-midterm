import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkin_record.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'checkin_records';
  static const String _usersCollection = 'users';

  /// Save user profile to Firestore
  Future<void> saveUser(String studentId, String name) async {
    try {
      await _firestore.collection(_usersCollection).doc(studentId).set({
        'studentId': studentId,
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firebase save user failed: $e');
    }
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUser(String studentId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(studentId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Firebase get user failed: $e');
      return null;
    }
  }

  /// Save a check-in record to Firestore
  Future<void> saveCheckIn(CheckInRecord record) async {
    try {
      await _firestore.collection(_collection).doc(record.id).set(record.toMap());
    } catch (e) {
      // Silently fail - data is saved locally via SQLite as primary storage
      debugPrint('Firebase sync failed: $e');
    }
  }

  /// Update a record in Firestore (for check-out)
  Future<void> updateCheckOut(CheckInRecord record) async {
    try {
      await _firestore.collection(_collection).doc(record.id).update(record.toMap());
    } catch (e) {
      debugPrint('Firebase sync failed: $e');
    }
  }

  /// Delete a record from Firestore
  Future<void> deleteRecord(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      debugPrint('Firebase delete failed: $e');
    }
  }

  /// Get all records for a specific student from Firestore
  Future<List<CheckInRecord>> getAllRecords(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('checkInTime', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => CheckInRecord.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firebase fetch failed: $e');
      return [];
    }
  }
}
