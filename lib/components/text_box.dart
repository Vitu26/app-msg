import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({
    super.key,
    required this.sectionName,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.grey[200]),
      padding: const EdgeInsets.only(
        left: 15,
        bottom: 20,
      ),
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(sectionName),
            IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey[400],
                )),
          ],
        ),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ]),
    );
  }
}

