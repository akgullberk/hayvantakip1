import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_photo_model.dart';
import '../services/local_storage_service.dart';
import 'package:flutter/foundation.dart';

class PetPhotoViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  final _uuid = const Uuid();
  List<PetPhoto> _photos = [];

  List<PetPhoto> getPhotos() => List.unmodifiable(_photos);

  Future<void> loadPhotos(String petId) async {
    _photos = await _storageService.getPetPhotos(petId);
    notifyListeners();
  }

  Future<void> addPhoto(String petId, String photoPath, {String? aciklama}) async {
    final photo = PetPhoto(
      id: _uuid.v4(),
      petId: petId,
      photoPath: photoPath,
      eklenmeTarihi: DateTime.now(),
      aciklama: aciklama,
    );
    await _storageService.addPetPhoto(photo);
    _photos.insert(0, photo);
    notifyListeners();
  }

  Future<void> deletePhoto(String photoId) async {
    await _storageService.deletePetPhoto(photoId);
    _photos.removeWhere((photo) => photo.id == photoId);
    notifyListeners();
  }

  Future<void> updatePhoto(PetPhoto photo) async {
    await _storageService.updatePetPhoto(photo);
    final index = _photos.indexWhere((p) => p.id == photo.id);
    if (index != -1) {
      _photos[index] = photo;
      notifyListeners();
    }
  }

  void addPhotos(List<PetPhoto> photos) {
    _photos.addAll(photos);
    notifyListeners();
  }

  void clearPhotos() {
    _photos.clear();
    notifyListeners();
  }
} 