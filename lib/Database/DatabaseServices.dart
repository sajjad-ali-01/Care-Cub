import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static Future<void> saveUserData({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl':'',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e; // Re-throw for error handling in UI
    }
  }
  static Future<void> updateUserData({
    required String uid,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    final DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    final DocumentSnapshot userSnapshot = await userDoc.get();

    final Map<String, dynamic> updateData = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'lastLogin': FieldValue.serverTimestamp(),
    };

     if (!userSnapshot.exists || !userSnapshot.data().toString().contains('phone')) {
      updateData['phone'] = '';
    }
    await userDoc.set(updateData, SetOptions(merge: true));
  }
  static Future<void> saveDrData({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String title,
    required String city
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl':'',
        'createdAt': FieldValue.serverTimestamp(),
        'title':title,
        'city':city,
      });
    } catch (e) {
      throw e; // Re-throw for error handling in UI
    }
  }

  static Future<Map<String, dynamic>?> getDrData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>; // Convert DocumentSnapshot to Map
      } else {
        return null; // Return null if the document doesn't exist
      }
    } catch (e) {
      throw e; // Re-throw for error handling in UI
    }
  }

}
