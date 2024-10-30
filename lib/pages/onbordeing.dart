import 'package:flutter/material.dart';
import 'package:glint/pages/phonenumber.dart';

class Onbordeing extends StatefulWidget {
  const Onbordeing({super.key});

  @override
  State<Onbordeing> createState() => _OnbordeingState();
}

class _OnbordeingState extends State<Onbordeing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Phonenumber()));
            },
            child: Text('Le5ts get started')),
      ),
    );
  }
}
