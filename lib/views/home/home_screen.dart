import 'package:flutter/material.dart';
import 'home_widgets.dart';
import '../gallery/all_photos_gallery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllPhotosGalleryScreen(),
                ),
              );
            },
            tooltip: 'Tüm Fotoğraflar',
          ),
        ],
      ),
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