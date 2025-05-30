import 'package:flutter/material.dart';
import 'home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anasayfa')),
      body: const PetListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddPetDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 