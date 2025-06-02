import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/pet_model.dart';
import '../../models/pet_photo_model.dart';
import '../../viewmodels/pet_photo_viewmodel.dart';


class PetPhotoGalleryScreen extends StatefulWidget {
  final Pet pet;

  const PetPhotoGalleryScreen({super.key, required this.pet});

  @override
  State<PetPhotoGalleryScreen> createState() => _PetPhotoGalleryScreenState();
}

class _PetPhotoGalleryScreenState extends State<PetPhotoGalleryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<PetPhotoViewModel>(context, listen: false)
        .loadPhotos(widget.pet.ad)
    );
  }

  Future<void> _addPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final File imageFile = File(image.path);
      final String dosyaAdi = 'pet_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Directory uygulamaDizini = await getApplicationDocumentsDirectory();
      final String hedefYol = '${uygulamaDizini.path}/$dosyaAdi';
      
      await imageFile.copy(hedefYol);

      String? aciklama;
      if (mounted) {
        aciklama = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Fotoğraf Açıklaması'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Açıklama ekleyin (isteğe bağlı)',
              ),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(''),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        );
      }

      if (mounted) {
        await Provider.of<PetPhotoViewModel>(context, listen: false)
          .addPhoto(widget.pet.ad, hedefYol, aciklama: aciklama);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.ad} - Fotoğraf Galerisi'),
      ),
      body: Consumer<PetPhotoViewModel>(
        builder: (context, viewModel, child) {
          final photos = viewModel.getPhotos();
          
          if (photos.isEmpty) {
            return const Center(
              child: Text('Henüz fotoğraf eklenmemiş.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return GestureDetector(
                onTap: () => _showPhotoDetail(context, photo),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(photo.photoPath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPhoto,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, PetPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(photo.photoPath),
              fit: BoxFit.contain,
            ),
            if (photo.aciklama?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(photo.aciklama!),
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