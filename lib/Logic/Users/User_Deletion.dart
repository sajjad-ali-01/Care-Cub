import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User_Deletion{
  static Future<void> deleteUserFromAuth() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.delete();
        print('User deleted from Firebase Authentication');
      } catch (e) {
        print('Error deleting user from Firebase Authentication: $e');
        throw e;
      }
    } else {
      print('No user is currently signed in');
    }
  }
  static Future<void> deleteUserDocumentsFromFirestore(String uid) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('users').doc(uid).delete();
      print('User document deleted from Firestore');
      await firestore.collection('DayCare').doc(uid).delete();
      print('User document deleted from Firestore');
      await firestore.collection('Doctors').doc(uid).delete();
      print('User document deleted from Firestore');
      final QuerySnapshot postsSnapshot = await firestore
          .collection('posts')
          .where('authorId', isEqualTo: uid)
          .get();

      final WriteBatch batch = firestore.batch();
      for (final doc in postsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All user posts deleted from Firestore');
    } catch (e) {
      print('Error deleting user documents from Firestore: $e');
      throw e;
    }
  }

  static Future<void> deleteUserAccount() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {

        await deleteUserFromAuth();
await deleteUserDocumentsFromFirestore(user.uid);



        print('User account and associated data deleted successfully');
      } catch (e) {
        print('Error deleting user account: $e');
        throw e;
      }
    } else {
      print('No user is currently signed in');
    }
  }

  static Future<void> reauthenticateAndDelete(String password) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      try {

        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
await deleteUserAccount();
      } catch (e) {
        print('Error reauthenticating and deleting account: $e');
        throw e;
      }
    } else {
      print('No user is currently signed in');
    }
  }

}