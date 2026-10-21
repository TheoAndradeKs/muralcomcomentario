# Mural da Turma — Comentários em Tempo Real

Continuação do aplicativo Flutter/Firebase da aula de 19/10. Mantém autenticação, cadastro, perfil e publicações e adiciona comentários em tempo real.

## Executar

1. Abra esta pasta no VS Code com Flutter instalado.
2. Execute `flutter pub get`.
3. Confira o projeto Firebase em `lib/firebase_options.dart` (já configurado no projeto recebido). Caso utilize outro Firebase, rode `flutterfire configure`.
4. No Firebase Console, habilite Authentication (Email/Senha) e Cloud Firestore.
5. No Firestore Database > Regras, substitua as regras pelas do arquivo `firestore.rules` e **publique**. Antes de publicar, confira a compatibilidade com suas regras existentes.
6. Execute `flutter run -d chrome` ou escolha outro dispositivo.

**Importante:** As regras não são instaladas automaticamente ao executar o app. Não use regras abertas (`allow read, write: if true`).

## Estrutura dos dados

`publicacoes/{publicacaoId}/comentarios/{comentarioId}` contém `texto`, `autorNome`, `autorId` (UID), `publicacaoId` e `data` (timestamp do servidor).

## Teste com duas contas

Abra o aplicativo em dois navegadores ou em janelas com sessões separadas. Entre com contas diferentes. Publique com a primeira, abra os comentários dessa publicação em ambas, comente com a segunda e confira a atualização automática. Repita em outra publicação para validar o isolamento. Exclua o comentário na conta autora e confirme a remoção. Tente excluir o comentário alheio: o botão não aparece e as regras do Firestore também bloqueiam a operação.

## Respostas da atividade

1. O Firebase Authentication identifica o usuário pelo `currentUser.uid`. O comentário guarda esse UID em `autorId` e o nome do perfil em `autorNome`.
2. Cada comentário fica na subcoleção `publicacoes/{publicacaoId}/comentarios`, e também guarda o campo `publicacaoId`.
3. O `StreamBuilder` acompanha o fluxo de snapshots do Firestore e reconstrói a lista sempre que chegam mudanças, sem recarregar a página.
4. Todas as contas conectadas ao mesmo projeto Firestore acompanham a mesma subcoleção com `.snapshots()`. Novas gravações são transmitidas aos ouvintes automaticamente, desde que as regras permitam leitura e haja conexão.

## Enviar ao GitHub

```bash
git init
git add .
git commit -m "Implementa comentários em tempo real com Firestore"
git branch -M main
git remote add origin URL_DO_SEU_REPOSITORIO
git push -u origin main
```

**Observação:** O teste com duas contas precisa ser feito no seu ambiente Firebase. Não foi possível executar o Flutter neste ambiente de preparação.
