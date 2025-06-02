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
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photo.photoPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          pet.ad,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, PetPhoto photo, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Image.file(
                  File(photo.photoPath),
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pet.ad,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (photo.aciklama?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(photo.aciklama!),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Eklenme Tarihi: ${photo.eklenmeTarihi.toString().split('.')[0]}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Fotoğrafı Sil'),
                        content: const Text('Bu fotoğrafı silmek istediğinizden emin misiniz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed ?? false) {
                      await Provider.of<PetPhotoViewModel>(context, listen: false)
                        .deletePhoto(photo.id);
                    }
                  },
                  child: const Text('Sil'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 