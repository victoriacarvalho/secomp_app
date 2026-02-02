import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await userCredential.user?.updateDisplayName(nome);

      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Este e-mail já está em uso.";
      } else if (e.code == 'weak-password') {
        return "A senha é muito fraca.";
      }
      return e.message; 
    } catch (e) {
      return "Erro inesperado ao cadastrar.";
    }
  }
}