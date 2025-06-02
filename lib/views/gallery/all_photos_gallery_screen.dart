import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/pet_model.dart';
import '../../models/pet_photo_model.dart';
import '../../viewmodels/pet_viewmodel.dart';
import '../../viewmodels/pet_photo_viewmodel.dart';
import '../../services/local_storage_service.dart';

class AllPhotosGalleryScreen extends StatefulWidget {
  const AllPhotosGalleryScreen({super.key});

  @override
  State<AllPhotosGalleryScreen> createState() => _AllPhotosGalleryScreenState();
}

class _AllPhotosGalleryScreenState extends State<AllPhotosGalleryScreen> {
  @override
  void initState() {
    super.initState();
    _loadAllPhotos();
  }

  Future<void> _loadAllPhotos() async {
    final petViewModel = Provider.of<PetViewModel>(context, listen: false);
    final photoViewModel = Provider.of<PetPhotoViewModel>(context, listen: false);
    final storageService = LocalStorageService();
    
    // Önce mevcut fotoğrafları temizle
    photoViewModel.clearPhotos();
    
    // Tüm evcil hayvanların fotoğraflarını tek seferde yükle
    final pets = petViewModel.getPets();
    final allPhotos = <PetPhoto>[];
    
    for (var pet in pets) {
      final photos = await storageService.getPetPhotos(pet.ad);
      allPhotos.addAll(photos);
    }
    
    // Fotoğrafları tarihe göre sırala (en yeniden en eskiye)
    allPhotos.sort((a, b) => b.eklenmeTarihi.compareTo(a.eklenmeTarihi));
    
    // Tüm fotoğrafları ekle
    photoViewModel.addPhotos(allPhotos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Fotoğraflar'),
      ),
      body: Consumer2<PetViewModel, PetPhotoViewModel>(
        builder: (context, petViewModel, photoViewModel, child) {
          final pets = petViewModel.getPets();
          final allPhotos = photoViewModel.getPhotos();

          if (allPhotos.isEmpty) {
            return const Center(
              child: Text('Henüz hiç fotoğraf eklenmemiş.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: allPhotos.length,
            itemBuilder: (context, index) {
              final photo = allPhotos[index];
              final pet = pets.firstWhere((p) => p.ad == photo.petId);
              
              return GestureDetector(
                onTap: () => _showPhotoDetail(context, photo, pet),
                child: Hero(
                  tag: 'all_photos_${photo.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photo.photoPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, PetPhoto photo, Pet pet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Fotoğrafı Sil'),
                      content: const Text('Bu fotoğrafı silmek istediğinizden emin misiniz?'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed ?? false) {
                    await Provider.of<PetPhotoViewModel>(context, listen: false)
                        .deletePhoto(photo.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Hero(
                    tag: 'all_photos_${photo.id}',
                    child: Image.file(
                      File(photo.photoPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pet.ad,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (photo.aciklama?.isNotEmpty ?? false) ...[
                        Text(
                          photo.aciklama!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Eklenme: ${photo.eklenmeTarihi.toString().split('.')[0]}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 