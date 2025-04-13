import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseReadServices{
  static Future<DocumentSnapshot> fetchDaycareData(String uid) async {
    try {
      return await FirebaseFirestore.instance.collection('DayCare').doc(uid).get();
    } catch (e) {
      throw e;
    }
  }
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
      throw e;
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
  static Future<void> SaveDayCareData({
    required String uid,
    required Map<String, dynamic> daycareData,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('DayCare').doc(uid).set(daycareData);

    } catch (e) {
      throw e;
    }
  }}

