import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _imagemPadraoEvento = "assets/images/icea.png";

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

  // --- AUTENTICAÇÃO ---
  Future<String?> logarUsuario({required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } catch (e) {
      return "E-mail ou senha incorretos.";
    }
  }

  Future<void> deslogarUsuario() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> recuperarSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return "Erro ao enviar e-mail de recuperação.";
    }
  }

  // --- CADASTRO PARTICIPANTE (ALUNO) ---
  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String matricula,
    required String senha,
    required String curso,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Salva dados no Firestore incluindo a Matrícula
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'matricula': matricula,
        'role': 'participante',
        'curso': curso,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user?.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Este e-mail já está em uso.";
      return "Erro ao cadastrar: ${e.message}";
    } catch (e) {
      return "Erro inesperado ao cadastrar.";
    }
  }

  // --- CADASTRO ADMIN (ORGANIZADOR) ---
  Future<String?> cadastrarAdm({
    required String nome,
    required String email,
    required String senha,
    required String tokenDigitado,
  }) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('configuracoes').doc('acesso').get();
      if (!snapshot.exists) return "Erro de configuração no servidor.";

      if (tokenDigitado != snapshot.get('token_adm')) return "Chave de acesso inválida.";

      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'role': 'admin',
        'eventosCriados': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user?.updateDisplayName(nome);
      return null;
    } catch (e) {
      return "Erro ao validar chave administrativa.";
    }
  }

  // --- GESTÃO DE EVENTOS ---
  Future<String?> criarEvento({
    required String titulo,
    required String local,
    required DateTime data,
    required String descricao,
    required int vagas,
    required String nomePalestrante,
    required List<String> palestrantesConvidados,
    required bool isOnline,
    String? link,
    String? imageUrl,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return "Sessão expirada.";

      String imagemFinal = (imageUrl == null || imageUrl.isEmpty) ? _imagemPadraoEvento : imageUrl;

      await _firestore.collection('eventos').add({
        'titulo': titulo,
        'local': local,
        'data': Timestamp.fromDate(data),
        'descricao': descricao,
        'vagas': vagas,
        'vagasIniciais': vagas,
        'numeroInscritos': 0,
        'isOnline': isOnline,
        'palestrantePrincipal': nomePalestrante,
        'organizadorUid': user.uid,
        'palestrantesConvidados': palestrantesConvidados,
        'link': link ?? "",
        'imageUrl': imagemFinal,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('usuarios').doc(user.uid).update({
        'eventosCriados': FieldValue.increment(1),
      });

      return null;
    } catch (e) {
      return "Erro ao criar evento.";
    }
  }

  Stream<QuerySnapshot> getEventosStream() {
    return _firestore.collection('eventos').orderBy('data', descending: false).snapshots();
  }

  Future<DocumentSnapshot> getEventoById(String eventId) {
    return _firestore.collection('eventos').doc(eventId).get();
  }

  // --- EDIÇÃO E EXCLUSÃO ---
  Future<String?> atualizarEvento({
    required String docId,
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
      Map<String, dynamic> updateData = {
        'titulo': titulo,
        'local': local,
        'data': Timestamp.fromDate(data),
        'descricao': descricao,
        'vagas': vagas,
        'isOnline': isOnline,
        'palestrantesConvidados': palestrantesConvidados,
        'link': link ?? "",
      };

      if (imageUrl != null && imageUrl.isNotEmpty) updateData['imageUrl'] = imageUrl;

      await _firestore.collection('eventos').doc(docId).update(updateData);
      return null;
    } catch (e) {
      return "Erro ao atualizar evento.";
    }
  }

  Future<String?> excluirEvento(String docId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('eventos').doc(docId).get();
      if (!doc.exists) return "Evento não encontrado.";
      
      String organizadorUid = doc['organizadorUid']; 

      await _firestore.collection('eventos').doc(docId).delete();

      // Limpa inscrições órfãs
      var inscricoes = await _firestore.collection('inscricoes').where('eventId', isEqualTo: docId).get();
      for (var d in inscricoes.docs) { await d.reference.delete(); }

      await _firestore.collection('usuarios').doc(organizadorUid).update({
        'eventosCriados': FieldValue.increment(-1),
      });

      return null;
    } catch (e) {
      return "Erro ao excluir evento.";
    }
  }

  // --- IMAGEM E PERFIL ---
  Future<String> uploadImagemImgBB(File imagem) async {
    try {
      const String apiKey = 'f30d8276f615120876f57a3e1dab86f5';
      var request = http.MultipartRequest('POST', Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'));
      request.files.add(await http.MultipartFile.fromPath('image', imagem.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return json.decode(responseData)['data']['url'];
      }
      return "";
    } catch (e) {
      return "";
    }
  }

  Future<String?> atualizarPerfilUsuario({required String nome, String? curso, String? fotoUrl}) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return "Sessão expirada.";

      await user.updateDisplayName(nome);
      if (fotoUrl != null) await user.updatePhotoURL(fotoUrl);

      Map<String, dynamic> updateData = {'nome': nome};
      if (curso != null) updateData['curso'] = curso;
      if (fotoUrl != null) updateData['fotoUrl'] = fotoUrl;

      await _firestore.collection('usuarios').doc(user.uid).update(updateData);
      return null;
    } catch (e) {
      return "Erro ao atualizar perfil.";
    }
  }

  // --- FAVORITOS ---
  Future<bool> alternarSalvarEvento(String eventId) async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return false;

    DocumentReference docRef = _firestore.collection('usuarios').doc(user.uid).collection('salvos').doc(eventId);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
      return false;
    } else {
      await docRef.set({'salvoEm': FieldValue.serverTimestamp()});
      return true;
    }
  }

  Future<bool> isEventoSalvo(String eventId) async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return false;
    DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).collection('salvos').doc(eventId).get();
    return doc.exists;
  }

  Stream<QuerySnapshot> getEventosSalvosStream() {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('usuarios').doc(user.uid).collection('salvos').orderBy('salvoEm', descending: true).snapshots();
  }
}