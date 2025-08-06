import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../models/models.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn.standard(
             scopes: [
               'email',
               'https://www.googleapis.com/auth/userinfo.profile',
             ],
           );

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String userType,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        userType: userType,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> signUpWithGoogle({required String userType}) async {
    try {
      // 1. Inicia sesión con Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // 2. Obtiene la autenticación
      final googleAuth = await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Missing Google ID token or access token');
      }

      // 3. Crea credenciales de Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // 4. Inicia sesión en Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null after Google sign-in');
      }

      // 5. Crea el modelo de usuario
      final user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '${googleUser.id}@google.com',
        fullName:
            firebaseUser.displayName ?? googleUser.displayName ?? 'Google User',
        userType: userType,
        createdAt: DateTime.now(),
      );

      // 6. Guarda en Firestore (merge para no sobrescribir)
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toMap(), SetOptions(merge: true));

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    } catch (e) {
      throw Exception('Google sign-in error: ${e.toString()}');
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Account already exists with different credentials';
      case 'invalid-credential':
        return 'Invalid Google credentials';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled';
      default:
        return 'Authentication failed: $code';
    }
  }
}
