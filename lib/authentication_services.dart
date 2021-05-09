import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);
  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    //await _firebaseAuth.currentUser.delete().updatepaswword
  }

  Future<int> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return 0;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return 2;
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        return 1;
      }
    }
    return -1;
  }

  Future<void> forgotpass(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future signUp({String email, String password, String dname}) async {
    int f = 3;
    CollectionReference _userRef =
        FirebaseFirestore.instance.collection('users');
    Query q = _userRef.where('dname', isEqualTo: dname);
    await q.get().then((QuerySnapshot qs) {
      print('empty?' + qs.docs.isEmpty.toString());
      if (qs.docs.isNotEmpty) {
        f = 0;
      } else
        f = 1;
    });
    if (f == 0) return 0;
    if (f == 1) {
      try {
        await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: email.trim(), password: password.trim())
            .then((userSignedin) async {
          await _userRef.doc(userSignedin.user.uid).set({'dname': dname});
          await FirebaseFirestore.instance
              .collection('friends')
              .doc(userSignedin.user.uid)
              .set({'exists': true});
        });

        return 1;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
          return 0;
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          return 0;
        }
      } catch (e) {
        print(e);
        return 0;
      }
    }
  }
}
