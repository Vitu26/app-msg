import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msg_app/components/my_button.dart';
import 'package:msg_app/components/my_textfield.dart';
import 'package:msg_app/components/square_tile.dart';
import 'package:msg_app/pages/esqueceu_senha.dart';
import 'package:msg_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //mensagem de usuário erro
  void showErrorMsg(String message) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }

  //login
  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMsg(e.code);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
              height: 5.0,
            ),
            // Image.asset(
            //   'assets/images/brogo.png',
            //   height: 250,
            //   width: 350,
            // ),
            const Icon(Icons.message_sharp, size: 230.0,),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              "Bem vindo!",
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),

            const SizedBox(
              height: 25.0,
            ),

            MyTextField(
                controller: _emailController,
                hintText: 'Email',
                obscureText: false),

            const SizedBox(
              height: 25.0,
            ),

            MyTextField(
                controller: _passwordController,
                hintText: 'Senha',
                obscureText: true),
                const SizedBox(
                height: 10,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ForgotPasswordPage();
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Forgot the password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              MyButton(
                text: 'Sign In',
                onTap: signIn,
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

              // //google + apple sign in buttons
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     // Image.asset(
              //     //   'assets/images/google.png',
              //     //   height: 72,
              //     //   ),
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
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register now!',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15,)
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}