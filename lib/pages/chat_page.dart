import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  String recipientUID; // UID do destinatário do chat
  String recipientName; // Nome do destinatário do chat

  ChatWidget({required this.recipientUID, required this.recipientName});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String chatId = ""; // ID exclusivo da conversa

  @override
  void initState() {
    super.initState();
    // Gere um chat ID exclusivo com base nos UIDs dos usuários
    chatId = _generateChatId(_auth.currentUser!.uid, widget.recipientUID);
    print('RecipientUID: ${widget.recipientUID}');
    print('ChatID: $chatId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat com ${widget.recipientName}'), // Título da AppBar
        backgroundColor: Colors.green, // Cor de fundo da AppBar
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('chatId', isEqualTo: chatId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                List<Widget> messageWidgets = [];

                final currentUser = _auth.currentUser;
                final currentUserUID = currentUser?.uid;

                for (var message in messages) {
                  final messageText = message['content'];
                  final messageSender = message['senderUID'];

                  final isCurrentUser = currentUserUID == messageSender;

                  final messageWidget = MessageWidget(
                    text: messageText,
                    isCurrentUser: isCurrentUser,
                  );

                  messageWidgets.add(messageWidget);
                }

                if (messageWidgets.isEmpty) {
                  return Center(
                    child: Text('Nenhuma mensagem encontrada.'),
                  );
                }

                // Role para a parte inferior da lista de mensagens
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView(
                  controller: _scrollController,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função para enviar uma mensagem
  void _sendMessage(String text) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      print("Sending message to recipientUID: ${widget.recipientUID}");
      await _firestore.collection('messages').add({
        'senderUID': currentUser.uid,
        'recipientUID': widget.recipientUID,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
        'chatId': chatId,
        'name':
            currentUser.displayName, // Supondo que você tenha o nome do usuário
      });
    }
  }

  // Função para consultar mensagens
  Stream<QuerySnapshot> _getMessagesStream() {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots();
  }

  // Função para gerar um ID de chat exclusivo
  String _generateChatId(String uid1, String uid2) {
    final sortedUids = [uid1, uid2]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }
}

class MessageWidget extends StatelessWidget {
  final String text; // Texto da mensagem
  final bool isCurrentUser; // Indica se a mensagem foi enviada pelo usuário atual

  MessageWidget({required this.text, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
