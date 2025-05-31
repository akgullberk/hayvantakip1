import 'package:flutter/material.dart';
import '../../models/pet_model.dart';
import 'pet_detail_widgets.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.ad),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context);
              showEditPetDialog(context, pet, -1);
            },
          ),
        ],
      ),
      body: PetDetailWidget(pet: pet),
    );
  }
} 