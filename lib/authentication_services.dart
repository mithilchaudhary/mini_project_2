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

  Future<int> signUp({String email, String password, String dname}) async {
    int f = 0;
    CollectionReference _userRef =
        FirebaseFirestore.instance.collection('users');
    Query q = _userRef.where('dname', isEqualTo: dname);
    q.get().then((QuerySnapshot qs) {
      String hehe = qs.docs[0].data().toString();
      if (hehe == null) {
        f = 1;
      } else
        f = 2;
    });
    if (f == 2)
      return 1;
    else if (f == 1) {
      try {
        await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: email.trim(), password: password.trim())
            .then((userSignedin) {
          _userRef.doc(userSignedin.user.uid).set({'dname': dname});
        });
        return 0;
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
      return 0;
    } else
      return 999;
  }
}
