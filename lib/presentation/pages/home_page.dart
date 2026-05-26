import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 60, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Bienvenido a GM Store',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('Explora las mejores gorras'),
          ],
        ),
      ),
    );
  }
}
