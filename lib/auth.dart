import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  //Creation of the firebase Auth variable
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //User Variable
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  //Beginning of the Functions

  //For Users Signing in with email and password
  Future<void> signInWithEmailAndPassWord({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  //For creating a new user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  //For signing out the user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

//This is the google sign in here
signInWithGoogle() async {
  final GoogleSignInAccount? googleUser =
      await GoogleSignIn(scopes: <String>["email"]).signIn();
  final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

//Something different
Future<void> TheGoogleSign() async {
  print("THE Google Sign in Called");
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  try {
    print("Attemping Sign In");
    await _googleSignIn.signIn();
  } catch (error) {
    print("LAM ERROR BELOW");
    print(error);
  }
}
