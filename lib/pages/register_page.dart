import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msg_app/components/my_button.dart';
import 'package:msg_app/components/my_textfield.dart';
import 'package:msg_app/components/square_tile.dart';
import 'package:msg_app/services/auth_service.dart';


class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();

  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPassController = TextEditingController();

    void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future signUp() async {
    try{
      if(passwordConfirmed()){
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);

            //add user details
        addUserDetails(
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
            _emailController.text.trim(),
            _phoneController.text.trim());
      
      }
    }on FirebaseAuthException catch (e){
      showErrorMsg(e.code);
    }
  }

  Future addUserDetails(String firstName, String lastName, String email, String phone) async{
    final User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': firstName,
        'last name': lastName,
        'email': email,
        'phone': phone,
      });

    }
  }


    bool passwordConfirmed() {
    if (_passwordController.text == _confirmPassController.text) {
      return true;
    } else {
      return false;
    }
  }

  Future addFriendToUser(String friendUID) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      //Recuperar detalhes do amigo usando seu UID
      DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUID)
          .get();

      if (friendSnapshot.exists) {
        Map<String, dynamic> friendDetails =
            friendSnapshot.data()! as Map<String, dynamic>;

        //Adicionar detalhes do amigo à subcoleção 'friends' do usuário atual
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(friendUID)
            .set({
          'friendName': friendDetails['name'],
          'friendLastName': friendDetails['last name'],
          'friendEmail': friendDetails['email'],
          'friendPhone': friendDetails['phone'],
        });
      }
    }
  }

    //mensagem de usuário erro
  void showErrorMsg(String message) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.white)),
              )
          ]);
        });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5,
              ),
              //logo
              // Image.asset(
              //   'assets/images/brogo.png',
              //   height: 250,
              //   width: 350,
              // ),

              const Icon(Icons.message_sharp, size: 230.0,),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Crie uma conta e acesse!!',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),

              const SizedBox(
                height: 25,
              ),

              //email
              MyTextField(
                controller: _firstNameController,
                hintText: 'Nome',
                obscureText: false,
              ),

              const SizedBox(
                height: 25,
              ),

              //email
              MyTextField(
                controller: _lastNameController,
                hintText: 'Last Name',
                obscureText: false,
              ),

              const SizedBox(
                height: 25,
              ),

              MyTextField(
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(
                height: 25,
              ),

              MyTextField(
                controller: _phoneController,
                hintText: 'Phone',
                obscureText: false,
              ),

              const SizedBox(
                height: 25,
              ),

              //pass
              MyTextField(
                controller: _passwordController,
                hintText: 'Pass',
                obscureText: true,
              ),

              const SizedBox(
                height: 25,
              ),

              //confirm pass
              MyTextField(
                controller: _confirmPassController,
                hintText: 'ConfirmPass',
                obscureText: true,
              ),

              const SizedBox(
                height: 10,
              ),

              const SizedBox(
                height: 25,
              ),

              MyButton(
                text: 'Sign Up',
                // onTap: signUserUp,
                onTap: signUp,
              ),

              const SizedBox(
                height: 25,
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Divider(
              //           thickness: 0.5,
              //           color: Colors.grey[400],
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //         child: Text(
              //           'Or contnue with',
              //           style: TextStyle(color: Colors.grey[700]),
              //         ),
              //       ),
              //       Expanded(
              //         child: Divider(
              //           thickness: 0.5,
              //           color: Colors.grey[400],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // const SizedBox(
              //   height: 50,
              // ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     SquareTile(
              //         onTap: () => AuthService().signInWithGoogle(),
              //         imagePath: 'assets/images/google.png'),
              //     SizedBox(width: 25),
              //     SquareTile(
              //         onTap: () {}, imagePath: 'assets/images/google.png'),
              //   ],
              // ),

              const SizedBox(
                height: 50,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now!',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15.0,)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
