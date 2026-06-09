import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'FirestoreService.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign In with Email/Password
  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Create Auth account only (used when custom profile creation is needed)
  Future<UserCredential?> signUpAuth(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register with Email/Password and Save to Firestore (General)
  Future<UserCredential?> signUp(UserModel user, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );
    
    if (credential.user != null) {
      // User create hone ke baad Firestore mein save karein
      UserModel newUser = user.copyWith(uid: credential.user!.uid);
      await _firestoreService.createUser(newUser);
    }
    return credential;
  }

  // Phone Verification (OTP)
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber', // Indian format as default
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Verify OTP and Sign In
  Future<UserCredential> signInWithOtp(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Get User Data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    return await _firestoreService.getUser(uid);
  }

  // Get User Data by Email (For script users migration)
  Future<UserModel?> getUserByEmail(String email) async {
    return await _firestoreService.getUserByEmail(email);
  }

  // Migrate user record to Auth UID
  Future<void> migrateUser(String oldId, UserModel user) async {
    await _firestoreService.migrateUserToUid(oldId, user);
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
