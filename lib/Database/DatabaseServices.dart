import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // Save user data
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
      throw e; // Re-throw for error handling in UI
    }
  }

  // Update user data
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

  // Save doctor data
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
      throw e; // Re-throw for error handling in UI
    }
  }

  // Add professional info for a doctor
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

  // Add educational info for a doctor
  static Future<void> AddDrEducationalInfo({
    required String uid,
    String? Edu_Country,
    String? Edu_City,
    String? College,
    String? Degree,
    String? GraduationYear,
    String? PMCNumber,
  }) async {
    final DocumentReference userDoc = FirebaseFirestore.instance.collection('Doctors').doc(uid);

    final DocumentSnapshot userSnapshot = await userDoc.get();

    final Map<String, dynamic> updateData = {
      'Edu_Country': Edu_Country,
      'Edu_City': Edu_City,
      'College/University': College,
      'Degree': Degree,
      'GraduationYear': GraduationYear,
      'PMCNumber': PMCNumber,
    };

    if (!userSnapshot.exists || !userSnapshot.data().toString().contains('phone')) {
      updateData['phone'] = '';
    }
    await userDoc.set(updateData, SetOptions(merge: true));
  }

  // Fetch all data for a doctor
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

  // Fetch specific fields for a doctor
  static Future<Map<String, dynamic>?> getDoctorSpecificFields(String uid, List<String> fields) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> result = {};

        for (var field in fields) {
          if (data.containsKey(field)) {
            result[field] = data[field];
          }
        }

        return result;
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  // Fetch professional info for a doctor
  static Future<Map<String, dynamic>?> getDoctorProfessionalInfo(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> professionalInfo = {};

        professionalInfo['title'] = data['title'];
        professionalInfo['experience'] = data['experience'];
        professionalInfo['Primary_specialization'] = data['Primary_specialization'];
        professionalInfo['Secondary_specialization'] = data['Secondary_specialization'];
        professionalInfo['Service_Offered'] = data['Service_Offered'];
        professionalInfo['Condition'] = data['Condition'];

        return professionalInfo;
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  // Fetch educational info for a doctor
  static Future<Map<String, dynamic>?> getDoctorEducationalInfo(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> educationalInfo = {};

        educationalInfo['Edu_Country'] = data['Edu_Country'];
        educationalInfo['Edu_City'] = data['Edu_City'];
        educationalInfo['College/University'] = data['College/University'];
        educationalInfo['Degree'] = data['Degree'];
        educationalInfo['GraduationYear'] = data['GraduationYear'];
        educationalInfo['PMCNumber'] = data['PMCNumber'];

        return educationalInfo;
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  // Fetch clinic info for a doctor
  static Future<List<Map<String, dynamic>>> getDoctorClinics(String uid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(uid)
          .collection('clinics')
          .get();

      List<Map<String, dynamic>> clinics = [];

      for (var doc in querySnapshot.docs) {
        clinics.add(doc.data() as Map<String, dynamic>);
      }

      return clinics;
    } catch (e) {
      throw e; // Re-throw for error handling in UI
    }
  }
  static Future<List<Map<String, dynamic>>> getDoctorEducation(String uid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(uid)
          .collection('education')
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e;
    }
  }
}