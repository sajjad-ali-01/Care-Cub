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
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
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
    required String city,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Doctors').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'title': title,
        'city': city,
      });
    } catch (e) {
      throw e;
    }
  }

  static Future<void> AddDrProfessional_Info({
    required String uid,
    String? name,
    String? title,
    String? experience,
    String? Primary_specialization,
    String? Secondary_specialization,
    required List<String> Service_Offered,
    required List<String> Condition,
  }) async {
    final DocumentReference userDoc = FirebaseFirestore.instance.collection('Doctors').doc(uid);

    final Map<String, dynamic> updateData = {
      'name': name,
      'title': title,
      'experience': experience,
      'Primary_specialization': Primary_specialization,
      'Secondary_specialization': Secondary_specialization,
      'Service_Offered': Service_Offered,
      'Condition': Condition,
    };

    await userDoc.set(updateData, SetOptions(merge: true));
  }
  static Future<void> AddDrEDU_INFO({
    required String uid,
    required String PMCNumber,
    required List<String> EDU_INFO,
  }) async {
    bool isVerified = false;
    final DocumentReference userDoc = FirebaseFirestore.instance.collection('Doctors').doc(uid);

    final Map<String, dynamic> updateData = {
      'EDU_INFO': EDU_INFO,
      'PMCNumber':PMCNumber,
      'isVerified' : isVerified,

    };

    await userDoc.set(updateData, SetOptions(merge: true));
  }


  static Future<void> AddDrEducationalInfo({
    required String uid,
    String? Edu_Country,
    String? Edu_City,
    String? College,
    String? Degree,
    String? GraduationYear,
    String? PMCNumber,
  }) async {
    bool isVerified = false;
    final DocumentReference userDoc = FirebaseFirestore.instance.collection('Doctors').doc(uid);

    final DocumentSnapshot userSnapshot = await userDoc.get();

    final Map<String, dynamic> updateData = {
      'Edu_Country': Edu_Country,
      'Edu_City': Edu_City,
      'College/University': College,
      'Degree': Degree,
      'GraduationYear': GraduationYear,
      'PMCNumber': PMCNumber,
      'isVerified' : isVerified,
    };

    if (!userSnapshot.exists || !userSnapshot.data().toString().contains('phone')) {
      updateData['phone'] = '';
    }
    await userDoc.set(updateData, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getDrData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<void> updateDaycareProfile({
    required String uid,
    required String name,
    required String description,
    required String license,
    required String address,
    required String phone,
    required String capacity,
    String? profileImageUrl,
    List<String>? galleryImageUrls,
  }) async {
    Map<String, dynamic> updateData = {
      'name': name,
      'description': description,
      'license': license,
      'address': address,
      'phone': phone,
      'capacity': capacity,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (profileImageUrl != null) {
      updateData['profileImageUrl'] = profileImageUrl;
    }

    if (galleryImageUrls != null) {
      updateData['galleryImages'] = galleryImageUrls;
    }

    await FirebaseFirestore.instance
        .collection('DayCare')
        .doc(uid)
        .update(updateData);
  }
}