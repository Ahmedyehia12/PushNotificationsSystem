import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Email & Password Authentication
  Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  await _analytics.logEvent(
    name: 'sign_in_email',
    parameters: {'email': email},
  );
}

 Future<void> createUserWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  await _analytics.logEvent(
    name: 'sign_up_email',
    parameters: {'email': email},
  );
}

Future<User?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null; // User canceled sign-in

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final OAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

  await _analytics.logEvent(
    name: 'sign_in_google',
    parameters: {'email': userCredential.user?.email ?? ''},
  );

  return userCredential.user;
}


  // Phone Number Sign-In
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: verificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> signInWithPhoneNumber({
  required String verificationId,
  required String smsCode,
}) async {
  final credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode,
  );
  UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

  await _analytics.logEvent(
    name: 'sign_in_phone',
    parameters: {'phone_number': userCredential.user?.phoneNumber ?? ''},
  );
}

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
