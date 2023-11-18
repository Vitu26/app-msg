import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msg_app/pages/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<Map<String, dynamic>> fetchFriendsWithLastMessages() async {
//   Map<String, dynamic> friendsMessages = {};
//   final User? user = _auth.currentUser;

//   if (user != null) {
//     QuerySnapshot messagesSnapshot = await _firestore
//         .collection('messages')
//         .where('recipientUID', isEqualTo: user.uid)
//         .get();

//     for (var message in messagesSnapshot.docs) {
//       var data = message.data() as Map<String, dynamic>; // Casting para Map<String, dynamic>
//       String friendUID = data['senderUID'];

//       DocumentSnapshot userDoc = await _firestore.collection('users').doc(friendUID).get();
//       var userData = userDoc.data() as Map<String, dynamic>; // Casting para Map<String, dynamic>
//       String senderName = userData['name'] ?? 'Usuário Desconhecido';

//       if (!friendsMessages.containsKey(friendUID) ||
//           (data['timestamp'] as Timestamp).toDate().isAfter(
//               (friendsMessages[friendUID]['timestamp'] as Timestamp).toDate())) {
//         data['senderName'] = senderName;
//         friendsMessages[friendUID] = data;
//       }
//     }
//   }

//   return friendsMessages;
// }

  Future<Map<String, dynamic>> fetchFriendsWithLastMessages() async {
    Map<String, dynamic> friendsMessages = {};
    final User? user = _auth.currentUser;

    if (user != null) {
      // Buscar mensagens onde o usuário é o remetente
      QuerySnapshot sentMessagesSnapshot = await _firestore
          .collection('messages')
          .where('senderUID', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      // Adicionando mensagens enviadas ao mapa
      for (var message in sentMessagesSnapshot.docs) {
        var data = message.data() as Map<String, dynamic>;
        String friendUID = data['recipientUID'];
        data['senderName'] = await fetchUserName(friendUID); // Buscar o nome do destinatário

        if (!friendsMessages.containsKey(friendUID) ||
            (data['timestamp'] as Timestamp).toDate().isAfter(
                (friendsMessages[friendUID]['timestamp'] as Timestamp).toDate())) {
          friendsMessages[friendUID] = data;
        }
        data['profilePictureUrl'] = data?['friendProfilePictureUrl'];
      }

      // Buscar mensagens onde o usuário é o destinatário
      QuerySnapshot receivedMessagesSnapshot = await _firestore
          .collection('messages')
          .where('recipientUID', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      // Adicionando mensagens recebidas ao mapa
      for (var message in receivedMessagesSnapshot.docs) {
        var data = message.data() as Map<String, dynamic>;
        String friendUID = data['senderUID'];
        data['senderName'] = await fetchUserName(friendUID); // Buscar o nome do remetente

        if (!friendsMessages.containsKey(friendUID) ||
            (data['timestamp'] as Timestamp).toDate().isAfter(
                (friendsMessages[friendUID]['timestamp'] as Timestamp).toDate())) {
          friendsMessages[friendUID] = data;
        }
      }
      
    }

    return friendsMessages;
  }

  Future<String> fetchUserName(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      
      return userData['name'] ?? 'Nome Desconhecido';
    }
    return 'Nome Desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchFriendsWithLastMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma mensagem encontrada'));
          }

          var friendsMessages = snapshot.data!;

          return Container(
            padding: EdgeInsets.only(top: 15.0),
            child: ListView.builder(
              itemCount: friendsMessages.length,
              itemBuilder: (context, index) {
                String friendUID = friendsMessages.keys.elementAt(index);
                var message = friendsMessages[friendUID];

                return ListTile(
                  leading: CircleAvatar(
                          radius: 40,
                          backgroundImage: message['profilePictureUrl'] != null
                              ? CachedNetworkImageProvider(
                                 message['profilePictureUrl']
                                ) 
                              : AssetImage('assets/images/gato-obeso.jpg')
                                  as ImageProvider<
                                      Object>?, // 
                        ),
                  title: Text('Chat com ${message['senderName'] ?? 'Usuário Desconhecido'}'),
                  subtitle: Text(message['content'] ?? ''),
                  onTap: () {
                    if (friendUID != null && message['senderName'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatWidget(
                            recipientUID: friendUID,
                            recipientName: message['senderName'] ?? 'Usuário Desconhecido',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Informações incompletas para iniciar o chat.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );}));}}

