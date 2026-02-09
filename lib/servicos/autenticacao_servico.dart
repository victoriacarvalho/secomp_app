import 'dart:io'; // Necessário para File
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // --- CADASTRO DE PARTICIPANTE ---
  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String curso,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'role': 'participante',
        'curso': curso,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user?.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Este e-mail já está em uso.";
      if (e.code == 'weak-password') return "A senha é muito fraca.";
      return e.message;
    } catch (e) {
      return "Erro inesperado ao cadastrar participante.";
    }
  }

  // --- CADASTRO DE ADMIN ---
  Future<String?> cadastrarAdm({
    required String nome,
    required String email,
    required String senha,
    required String tokenDigitado,
  }) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('configuracoes').doc('acesso').get();

      if (!snapshot.exists) return "Erro de configuração no servidor.";

      String tokenNoServidor = snapshot.get('token_adm');

      if (tokenDigitado != tokenNoServidor) return "Chave de acesso inválida.";

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
      return "Erro ao validar chave: $e";
    }
  }

  // --- LOGIN ---
  Future<String?> logarUsuario({required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return "E-mail ou senha incorretos.";
    }
  }

  // --- RECUPERAR SENHA ---
  Future<String?> recuperarSenha({required String email}) async {
    try {
      await _firebaseAuth.setLanguageCode("pt-br");
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return "Erro ao resetar senha.";
    }
  }

  // --- DADOS DO USUÁRIO ---
  Future<Map<String, dynamic>?> getDadosUsuarioLogado() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  Future<String> getUserRole() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) return doc.get('role');
    }
    return 'participante';
  }


  // --- CRIAR EVENTO ---
  Future<String?> criarEvento({
    required String titulo,
    required String local,
    required DateTime data,
    required String descricao,
    required int vagas,
    required List<String> palestrantesConvidados,
    required bool isOnline,
    String? link,
    String? imageUrl,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return "Usuário não autenticado.";

      String uid = user.uid;
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(uid).get();
      String nomeUsuarioLogado = userDoc.exists ? (userDoc.get('nome') ?? "Organizador") : "Organizador";

      Map<String, dynamic> dadosDoEvento = {
        'titulo': titulo,
        'local': local,
        'data': Timestamp.fromDate(data),
        'descricao': descricao,
        'vagas': vagas,
        'isOnline': isOnline,
        'palestrantePrincipal': nomeUsuarioLogado,
        'palestrantesConvidados': palestrantesConvidados,
        'organizadorUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'link': link ?? "",
        'imageUrl': imageUrl ?? "",
      };

      await _firestore.collection('eventos').add(dadosDoEvento);
      return null;
    } catch (e) {
      return "Erro ao criar evento: $e";
    }
  }

  // --- LISTAR EVENTOS ---
  Stream<QuerySnapshot> getEventos() {
    // Ordena pela data de criação decrescente
    return _firestore.collection('eventos').orderBy('createdAt', descending: true).snapshots();
  }
}