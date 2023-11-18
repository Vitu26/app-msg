import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetLastName extends StatelessWidget {
  final String documentId;

  GetLastName({required this.documentId});

  @override
  Widget build(BuildContext context) {
    //get the collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(documentId).get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text('Last Name: ${data['lastname']}');
          }
          return Text('loading...');
        }));
  }
}