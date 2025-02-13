import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:async';

class AuthFailure implements Exception {
  final String message;
  final String? code;

  AuthFailure(this.message, {this.code});
}

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure('Operação cancelada pelo usuário.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        _getFirebaseAuthErrorMessage(e.code),
        code: e.code.toString(),
      );
    } catch (e) {
      throw AuthFailure('Erro ao realizar login com Google: ${e.toString()}');
    }
  }

  // Apple sign in
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _firebaseAuth.signInWithCredential(oAuthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthFailure(
        'Erro no login com Apple: ${e.message}',
        code: e.code.toString(),
      );
    } catch (e) {
      throw AuthFailure('Erro ao realizar login com Apple: ${e.toString()}');
    }
  }

  // Phone sign in
  Future<String> verifyPhoneNumber(String phoneNumber) async {
    try {
      Completer<String> verificationIdCompleter = Completer<String>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationIdCompleter.completeError(AuthFailure(
            _getFirebaseAuthErrorMessage(e.code),
            code: e.code,
          ));
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationIdCompleter.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.complete(verificationId);
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await verificationIdCompleter.future;
    } catch (e) {
      throw AuthFailure(
          'Erro ao verificar número de telefone: ${e.toString()}');
    }
  }

  Future<UserCredential> verifySMSCode({
    required String smsCode,
    required String verificationId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        _getFirebaseAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthFailure('Erro ao verificar código SMS: ${e.toString()}');
    }
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'O número de telefone fornecido é inválido.';
      case 'invalid-verification-code':
        return 'O código de verificação é inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Ocorreu um erro na autenticação.';
    }
  }
}
