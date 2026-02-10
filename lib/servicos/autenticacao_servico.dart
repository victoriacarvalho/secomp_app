import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static final List<Map<String, dynamic>> _eventosLocais = [];


  List<String> getListaCursos() {
    return [
      "Engenharia de Computação",
      "Sistemas de Informação",
      "Engenharia Elétrica",
      "Engenharia de Produção",

    ];
  }

  // --- CADASTRO USUÁRIO ---
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


  // --- CADASTRO ADMIN  ---
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
    } catch (e) {
      return "Erro ao logar: ${e.toString()}";
    }
  }

  // --- RECUPERAR SENHA  ---
  Future<String?> recuperarSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return "Erro ao enviar e-mail.";
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
      String nomeCriador = user?.displayName ?? "Organizador";
      String uidCriador = user?.uid ?? "";

      await _firestore.collection('eventos').add({
        'titulo': titulo,
        'local': local,
        'data': Timestamp.fromDate(data),
        'descricao': descricao,
        'vagas': vagas,
        'vagasIniciais': vagas,
        'isOnline': isOnline,
        'palestrantePrincipal': nomeCriador,
        'organizadorUid': uidCriador,
        'palestrantesConvidados': palestrantesConvidados,
        'link': link ?? "",
        'imageUrl': imageUrl ?? "",
        'criadoEm': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return "Erro ao criar evento: $e";
    }
  }

  Stream<QuerySnapshot> getEventosStream() {
    return _firestore
        .collection('eventos')
        .orderBy('data', descending: false)
        .snapshots();
  }

  // --- 3. INSCREVER PARTICIPANTE ---
  Future<String?> inscreverParticipante({
    required String eventoId,
    required String nomeCompleto,
    required String email,
    required String cpf,
    required String telefone,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return "Usuário não logado";

      var query = await _firestore
          .collection('inscricoes')
          .where('eventoId', isEqualTo: eventoId)
          .where('uidUsuario', isEqualTo: user.uid)
          .get();

      if (query.docs.isNotEmpty) return "Você já está inscrito.";

      DocumentSnapshot docEvento = await _firestore.collection('eventos').doc(eventoId).get();
      int vagasAtuais = docEvento['vagas'];

      if (vagasAtuais <= 0) return "Evento lotado.";

      WriteBatch batch = _firestore.batch();
      DocumentReference inscricaoRef = _firestore.collection('inscricoes').doc();

      batch.set(inscricaoRef, {
        'eventoId': eventoId,
        'uidUsuario': user.uid,
        'nomeParticipante': nomeCompleto,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'dataInscricao': FieldValue.serverTimestamp(),
        'presencaConfirmada': false,
      });

      DocumentReference eventoRef = _firestore.collection('eventos').doc(eventoId);
      batch.update(eventoRef, {
        'vagas': FieldValue.increment(-1)
      });

      await batch.commit();
      return null;
    } catch (e) {
      return "Erro na inscrição: $e";
    }
  }

  // ---IMAGEM UPLOAD ---
  Future<String> uploadImagemImgBB(File imagem) async {
    try {

      const String apiKey = 'f30d8276f615120876f57a3e1dab86f5';

      var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey')
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagem.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return jsonResponse['data']['url'];
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // --- EDITAR EVENTO ---
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
      await _firestore.collection('eventos').doc(docId).update({
        'titulo': titulo,
        'local': local,
        'data': Timestamp.fromDate(data),
        'descricao': descricao,
        'vagas': vagas,
        'isOnline': isOnline,
        'palestrantesConvidados': palestrantesConvidados,
        'link': link ?? "",
        'imageUrl': imageUrl ?? "",
      });
      return null;
    } catch (e) {
      return "Erro ao atualizar: $e";
    }
  }

  // --- EXCLUIR EVENTO ---
  Future<String?> excluirEvento(String docId) async {
    try {
      await _firestore.collection('eventos').doc(docId).delete();

      var inscricoes = await _firestore.collection('inscricoes').where('eventoId', isEqualTo: docId).get();
      for (var doc in inscricoes.docs) {
        await doc.reference.delete();
      }

      return null;
    } catch (e) {
      return "Erro ao excluir: $e";
    }
  }

  // --- ATUALIZAR DADOS DO USUÁRIO ---
  Future<String?> atualizarPerfilUsuario({
    required String nome,
    required String curso,
    String? fotoUrl,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return "Usuário não logado";

      await user.updateDisplayName(nome);

      if (fotoUrl != null) await user.updatePhotoURL(fotoUrl);

      Map<String, dynamic> dadosAtualizar = {
        'nome': nome,
        'curso': curso,
      };

      if (fotoUrl != null) {
        dadosAtualizar['fotoUrl'] = fotoUrl;
      }

      await _firestore.collection('usuarios').doc(user.uid).update(dadosAtualizar);

      return null;
    } catch (e) {
      return "Erro ao atualizar perfil: $e";
    }
  }
}