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

      // Example: Delete user document from 'users' collection
      await firestore.collection('users').doc(uid).delete();
      print('User document deleted from Firestore');

      // Example: Delete all posts by the user from 'posts' collection
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
        // Step 1: Delete user from Firebase Authentication
        await deleteUserFromAuth();

        // Step 2: Delete user documents from Firestore
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
        // Reauthenticate the user
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // Delete the account
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