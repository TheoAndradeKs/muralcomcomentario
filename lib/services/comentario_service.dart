import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComentarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _comentarios(String publicacaoId) =>
      _db.collection('publicacoes').doc(publicacaoId).collection('comentarios');

  Stream<QuerySnapshot<Map<String, dynamic>>> acompanhar(String publicacaoId) =>
      _comentarios(publicacaoId).orderBy('data').snapshots();

  Future<void> comentar(String publicacaoId, String texto) async {
    final usuario = _auth.currentUser;
    if (usuario == null) throw Exception('Faça login para comentar.');
    final mensagem = texto.trim();
    if (mensagem.isEmpty || mensagem.length > 500) {
      throw Exception('O comentário deve ter de 1 a 500 caracteres.');
    }
    final post = await _db.collection('publicacoes').doc(publicacaoId).get();
    if (!post.exists) throw Exception('Publicação não encontrada.');
    final perfil = await _db.collection('usuarios').doc(usuario.uid).get();
    final nome = perfil.data()?['nome'];
    if (nome is! String || nome.trim().isEmpty) {
      throw Exception('Perfil não encontrado.');
    }
    await _comentarios(publicacaoId).add({
      'texto': mensagem,
      'autorNome': nome,
      'autorId': usuario.uid,
      'publicacaoId': publicacaoId,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluir(String publicacaoId, String comentarioId) async {
    final ref = _comentarios(publicacaoId).doc(comentarioId);
    final comentario = await ref.get();
    if (!comentario.exists) return;
    if (comentario.data()?['autorId'] != _auth.currentUser?.uid) {
      throw Exception('Você só pode excluir seus próprios comentários.');
    }
    await ref.delete();
  }
}
