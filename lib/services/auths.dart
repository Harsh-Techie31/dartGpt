import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
  }) async {
    var res = "Some error occured";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        // print("REACHED");

        // Userm hey = Userm(
        //     email: email,
        //     uid: cred.user!.uid,
        //     username: username,
        //     pfpLink: pfp_link ,
        //     followers: [],
        //     following: []);

        // await _firestore
        //     .collection("users")
        //     .doc(cred.user?.uid)
        //     .set(hey.toJson());

        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        res = "sucess";
      } else {
        res = "Fill all the details!!";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<String> logout() async {
    var res = "done";
    try {
      await _auth.signOut();
      // showSnackBar("Logged out Succesfully", context, Duration(seconds: 1));

      return res;
    } catch (err) {
      return err.toString();
    }
  }
}
