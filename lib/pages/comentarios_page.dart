import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/comentario_service.dart';

class ComentariosPage extends StatefulWidget {
  final String publicacaoId;
  const ComentariosPage({super.key, required this.publicacaoId});

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  final controller = TextEditingController();
  final service = ComentarioService();
  bool enviando = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    if (controller.text.trim().isEmpty || enviando) return;
    setState(() => enviando = true);
    try {
      await service.comentar(widget.publicacaoId, controller.text);
      controller.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  Future<void> excluir(String comentarioId) async {
    try {
      await service.excluir(widget.publicacaoId, comentarioId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentários')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Column(children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('publicacoes').doc(widget.publicacaoId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Padding(padding: EdgeInsets.all(16), child: Text('Erro ao carregar publicação.'));
              if (!snapshot.hasData) return const LinearProgressIndicator();
              if (!snapshot.data!.exists) return const Padding(padding: EdgeInsets.all(16), child: Text('Esta publicação foi excluída.'));
              final post = snapshot.data!.data()!;
              return Card(margin: const EdgeInsets.all(12), child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(post['autorNome'] ?? 'Usuário'),
                subtitle: Text(post['texto'] ?? ''),
              ));
            },
          ),
          const Divider(),
          Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: service.acompanhar(widget.publicacaoId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Erro ao carregar comentários: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final comentarios = snapshot.data!.docs;
              if (comentarios.isEmpty) return const Center(child: Text('Nenhum comentário ainda.'));
              return ListView.builder(
                itemCount: comentarios.length,
                itemBuilder: (context, index) {
                  final doc = comentarios[index];
                  final comentario = doc.data();
                  final proprio = comentario['autorId'] == FirebaseAuth.instance.currentUser?.uid;
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
                    title: Text(comentario['autorNome'] ?? 'Usuário'),
                    subtitle: Text(comentario['texto'] ?? ''),
                    trailing: proprio ? IconButton(
                      tooltip: 'Excluir meu comentário',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => excluir(doc.id),
                    ) : null,
                  );
                },
              );
            },
          )),
          SafeArea(top: false, child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(
                controller: controller,
                maxLength: 500,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Escreva um comentário...', border: OutlineInputBorder(), counterText: ''),
                onSubmitted: (_) => enviar(),
              )),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Enviar comentário',
                onPressed: enviando ? null : enviar,
                icon: const Icon(Icons.send),
              ),
            ]),
          )),
        ]),
      )),
    );
  }
}
