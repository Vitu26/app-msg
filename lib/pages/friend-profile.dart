import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:msg_app/model/friend_profile.dart';
import 'package:msg_app/pages/chat_page.dart';


class FriendProfilePage extends StatefulWidget {
  final FriendProfile friendProfile;

  FriendProfilePage({required this.friendProfile});

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  @override
  Widget build(BuildContext context) {
    final FriendProfile? friendProfile = widget.friendProfile;
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Amigo'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: friendProfile?.profilePictureUrl != null
                  ? CachedNetworkImageProvider(friendProfile!.profilePictureUrl!)
                  : AssetImage('assets/images/gato-obeso.jpg') as ImageProvider<Object>?,
            ),
            SizedBox(height: 16),
            Text(friendProfile?.name ?? 'Nome Desconhecido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(friendProfile?.lastName ?? 'Sobrenome Desconhecido', style: TextStyle(fontSize: 16)),
            if (friendProfile?.phone != null) ...[
              Icon(Icons.phone),
              Text(friendProfile!.phone!),
              SizedBox(height: 8),
            ],
            if (friendProfile?.email != null) ...[
              Icon(Icons.email),
              Text(friendProfile!.email!),
              SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatWidget(
                      recipientUID: friendProfile?.uid ?? '',
                      recipientName: friendProfile?.name ?? 'Desconhecido',
                    ),
                  ),
                );
              },
              child: Text('Iniciar Chat'),
            ),
          ],
        ),
      ),
    );
  }
}


