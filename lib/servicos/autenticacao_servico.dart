import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- CADASTRO DE PARTICIPANTE (ALUNO) ---
  // Adicionado o parâmetro 'curso'
  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String curso, // Novo parâmetro
  }) async {
    try {
      // 1. Cria o usuário no Firebase Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // 2. Salva o perfil no Firestore usando o UID como ID do documento
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'role': 'participante',
        'curso': curso, // Campo adicionado aqui
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Atualiza o nome de exibição no Firebase Auth
      await userCredential.user?.updateDisplayName(nome);

      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Este e-mail já está em uso.";
      if (e.code == 'weak-password') return "A senha é muito fraca.";
      return e.message; 
    } catch (e) {
      return "Erro inesperado ao cadastrar participante.";
    }
  }

  // --- CADASTRO DE ADMINISTRADOR (ORGANIZADOR) ---
  Future<String?> cadastrarAdm({
    required String nome,
    required String email,
    required String senha,
    required String tokenDigitado,
  }) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('configuracoes')
          .doc('acesso')
          .get();

      if (!snapshot.exists) {
        return "Erro de configuração no servidor. Verifique a coleção no Firebase.";
      }

      String tokenNoServidor = snapshot.get('token_adm');

      if (tokenDigitado != tokenNoServidor) {
        return "Chave de acesso inválida. Contate a coordenação.";
      }

      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user?.updateDisplayName(nome);
      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Este e-mail já está em uso.";
      return e.message;
    } catch (e) {
      return "Erro ao validar chave ou criar perfil: $e";
    }
  }

  // --- LOGIN ---
  Future<String?> logarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "E-mail ou senha incorretos.";
      }
      return e.message;
    } catch (e) {
      return "Erro inesperado ao fazer login.";
    }
  }

  // --- RECUPERAÇÃO DE SENHA ---
  Future<String?> recuperarSenha({required String email}) async {
    try {
      await _firebaseAuth.setLanguageCode("pt-br");
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "E-mail não encontrado em nossa base.";
      }
      return "Ocorreu um erro: ${e.message}";
    } catch (e) {
      return "Erro inesperado ao tentar resetar a senha.";
    }
  }

  // --- BUSCA DE DADOS PARA O PERFIL (Com Debug) ---
  Future<Map<String, dynamic>?> getDadosUsuarioLogado() async {
    User? user = _firebaseAuth.currentUser;
    
    if (user == null) {
      print("DEBUG: Nenhum usuário logado no Firebase Auth.");
      return null;
    }

    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print("DEBUG: ERRO - O documento com ID ${user.uid} NÃO existe no Firestore.");
        return null;
      }
    } catch (e) {
      print("DEBUG: Erro técnico na busca: $e");
      return null;
    }
  }

  // --- BUSCA APENAS O PAPEL (ROLE) ---
  Future<String> getUserRole() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        return doc.get('role');
      }
    }
    return 'participante';
  }
}