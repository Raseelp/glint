import 'package:flutter/material.dart';
import 'package:glint/pages/homepage.dart';
import 'package:glint/pages/phonenumber.dart';
import 'package:glint/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class Onbordeing extends StatefulWidget {
  const Onbordeing({super.key});

  @override
  State<Onbordeing> createState() => _OnbordeingState();
}

class _OnbordeingState extends State<Onbordeing> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
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
