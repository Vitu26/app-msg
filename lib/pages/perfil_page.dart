import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:msg_app/components/text_box.dart';
import 'package:msg_app/my_image_provider.dart';
import 'package:provider/provider.dart';

// Definindo uma nova página chamada ProfilePage
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image; // File para armazenar a imagem selecionada pelo usuário
  final picker = ImagePicker(); // Picker para selecionar imagens
  String? _errorMessage; // String para armazenar possíveis mensagens de erro
  final usersCollection = FirebaseFirestore.instance.collection('users');
  String? _imageUrl;

  // Método assíncrono para permitir que o usuário escolha uma imagem
  Future<void> _chooseImage() async {
    final User? user =
        FirebaseAuth.instance.currentUser; // Obtendo o usuário atual
    if (user == null) {
      setState(() {
        _errorMessage =
            'Usuário não autenticado'; // Configurando a mensagem de erro se o usuário não estiver autenticado
      });
      return;
    }

    // Exibindo um modal para o usuário escolher entre tirar uma foto ou escolher da galeria
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    // Se uma fonte de imagem foi selecionada, proceda para escolher a imagem
    if (source != null) {
      try {
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          final File image = File(pickedFile.path);
          await _uploadImage(image, user);
        } else {
          print('Nenhuma imagem selecionada.');
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Erro ao escolher imagem: $error';
        });
      }
    }
  }

  // Método assíncrono para fazer o upload da imagem para o Firebase Storage
  // Future<void> _uploadImage(File image, User user) async {
  //   try {
  //     final String filePath = 'users/${user.uid}/profile_picture.jpg';
  //     final Reference storageReference =
  //         FirebaseStorage.instance.ref().child(filePath);
  //     final UploadTask uploadTask = storageReference.putFile(image);

  //     await uploadTask.whenComplete(() async {
  //       final String downloadUrl = await storageReference.getDownloadURL();
  //       // Atualizando a URL da foto do perfil do usuário
  //       await user.updatePhotoURL(downloadUrl);
  //       setState(() {});
  //     });
  //   } catch (error) {
  //     setState(() {
  //       _errorMessage = 'Erro ao fazer upload da imagem: $error';
  //     });
  //   }
  // }

  Future<void> _uploadImage(File image, User user) async {
    try {
      final String userId = user.uid;
      final String fileName = 'profile_picture.jpg';

      // Faz o upload da imagem para o Firebase Storage
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/$userId/$fileName');
      await storageReference.putFile(image);

      // Obtém a URL da imagem recém-carregada
      final String imageUrl = await storageReference.getDownloadURL();

      // Atualiza a URL da imagem no Firestore
      await usersCollection.doc(userId).update({
        'profile_picture_url': imageUrl,
      });

      // Atualiza a variável de estado para a nova URL
      setState(() {
        _imageUrl = imageUrl;
      });

      Provider.of<MyImageProvider>(context, listen: false)
          .setImageUrl(imageUrl);

      print('Imagem enviada com sucesso');
    } catch (error) {
      setState(() {
        _errorMessage = 'Erro ao fazer upload da imagem: $error';
      });
      print('Erro ao fazer upload da imagem: $error');
    }
  }

  // Método para obter a imagem de fundo do perfil do usuário
  ImageProvider<Object> getBackgroundImage(User? user) {
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return CachedNetworkImageProvider(user.photoURL!);
    }
    // Retornando uma imagem padrão se o usuário não tiver uma imagem de perfil
    return const AssetImage('assets/images/gato-obeso.jpg');
  }

  // Obtendo o usuário atual
  final currentUser = FirebaseAuth.instance.currentUser!;

  String name = "";

  // Método para obter os dados do usuário do Firestore
  // Future<Map<String, dynamic>?> getUserData() async {
  //   // Obter o usuário atual e o email do usuário
  //   final user = FirebaseAuth.instance.currentUser!;
  //   final email = user.email;

  //   try {
  //     // Tentar obter o documento do usuário do Firestore
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .where('email', isEqualTo: email)
  //         .get();

  //     print('Número de documentos retornados: ${snapshot.docs.length}');

  //     // Verificar se um documento foi encontrado
  //     if (snapshot.docs.isNotEmpty) {
  //       // Retornar os dados do documento se encontrado
  //       return snapshot.docs.first.data() as Map<String, dynamic>;
  //     } else {
  //       // Logar uma mensagem se nenhum documento foi encontrado
  //       print('Nenhum documento encontrado para o email: $email');
  //       return null;
  //     }
  //   } catch (e) {
  //     // Logar qualquer erro que ocorra
  //     print('Erro ao obter dados do usuário: $e');
  //     return null;
  //   }
  // }
  Stream<Map<String, dynamic>> getUserData() {
    final user = FirebaseAuth.instance.currentUser!;
    final userId = user.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      // Handle empty case as needed.
      return {};
    });
  }

  @override
  void initState() {
    super.initState();
    name = FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;

    final usersCollection = FirebaseFirestore.instance.collection('users');

    // Método assíncrono para editar um campo específico no documento do usuário
    Future<void> editField(String field) async {
      String newValue = "";
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: Colors.grey[900],
                title: Text(
                  "Edit $field",
                  style: const TextStyle(color: Colors.white),
                ),
                content: TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter new $field',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  onChanged: (value) {
                    newValue = value;
                  },
                ),
                actions: [
                  // Botão para cancelar
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      )),

                  // Botão para salvar
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(newValue),
                      child: const Text(
                        'Alterar',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ));

      if (newValue.trim().isNotEmpty) {
        final User user = FirebaseAuth.instance.currentUser!;
        final DocumentReference docRef = FirebaseFirestore.instance
            .collection('users') // Acessando a coleção 'users' no Firestore
            .doc(user.uid); // Usando o UID do usuário como a chave do documento

        final DocumentSnapshot docSnap = await docRef.get();

        if (docSnap.exists) {
          await docRef.update({field: newValue});
          setState(
              () {}); // Chamar setState aqui para forçar a reconstrução do widget
        } else {
          print('UID do usuário: ${user.uid}');
          print('Documento não encontrado para o usuário: ${user.email}');
        }
      }
    }

    return Scaffold(
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Retornando um indicador de carregamento enquanto os dados estão sendo carregados
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Erro: ${snapshot.error}')); // Retornando uma mensagem de erro se houver um erro
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            return ListView(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 220,
                        width: 400,
                        decoration: const BoxDecoration(color: Colors.green),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      (snapshot.data?['profile_picture_url'] !=
                                                  null &&
                                              snapshot
                                                  .data!['profile_picture_url']
                                                  .isNotEmpty)
                                          ? NetworkImage(snapshot
                                                  .data!['profile_picture_url'])
                                              as ImageProvider<Object>?
                                          : AssetImage(
                                              'assets/images/gato-obeso.jpg'),
                                  backgroundColor: Colors.transparent,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: _chooseImage,
                                ),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                user.email!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Meus detalhes',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    MyTextBox(
                      sectionName: 'Nome',
                      text: userData['name'],
                      onPressed: () => editField('name'),
                    ),
                    MyTextBox(
                      sectionName: 'Sobrenome',
                      text: userData['last name'],
                      onPressed: () => editField('last name'),
                    ),
                    MyTextBox(
                      sectionName: 'Telefone',
                      text: userData['phone'],
                      onPressed: () => editField('phone'),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    MaterialButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      color: Colors.deepPurple[200],
                      child: Text('Log out'),
                    )
                  ])
            ]);
          } else {
            return const SizedBox
                .shrink(); // Retornando um widget vazio se não houver dados
          }
        },
      ),
    );
  }
}
