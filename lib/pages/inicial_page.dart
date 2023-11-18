import 'package:flutter/material.dart';
import 'package:msg_app/components/nav_bar.dart';


class InicialPage extends StatefulWidget {
  const InicialPage({super.key});

  @override
  State<InicialPage> createState() => _InicialPageState();
}

class _InicialPageState extends State<InicialPage> {
  @override
  Widget build(BuildContext context) {
    return  NavBar();
  }
}