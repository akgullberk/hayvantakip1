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

      if (mounted) {
        await Provider.of<PetPhotoViewModel>(context, listen: false)
          .addPhoto(widget.pet.ad, hedefYol);
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
                child: Hero(
                  tag: 'photo_${photo.id}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addPhoto,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, PetPhoto photo) {
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
                    tag: 'photo_${photo.id}',
                    child: Image.file(
                      File(photo.photoPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              if (photo.aciklama?.isNotEmpty ?? false)
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
                    child: Text(
                      photo.aciklama!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
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