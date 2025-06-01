import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../services/local_storage_service.dart';

class PetViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  List<Pet> pets = [];


  Future<void> addPet(
      String ad,
      String tur,
      int yas,
      String cins,
      String fotograf,
      double agirlik,
      String saglikDurumu,
      DateTime? sonVeterinerZiyaretiTarihi,
      List<String> alinanAsilar
      ) async {
    final pet = Pet(ad: ad,
        tur: tur,
        yas: yas,
        cins: cins,
        fotograf: fotograf,
        agirlik: agirlik,
        saglikDurumu: saglikDurumu,
        sonVeterinerZiyaretiTarihi: sonVeterinerZiyaretiTarihi,
        alinanAsilar: alinanAsilar
    );
    await _storageService.addPet(pet);
    pets.add(pet);
    notifyListeners();
  }

  List<Pet> getPets() {
    return pets;
  }

  Future<void> init() async {
    pets = await _storageService.getPets();
    notifyListeners();
  }

  Future<void> deletePet(int index) async {
    if (index >= 0 && index < pets.length) {
      final pet = pets[index];
      await _storageService.deletePet(pet);
      pets.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> updatePet(int index, Pet updatedPet) async {
    if (index >= 0 && index < pets.length) {
      await _storageService.updatePet(pets[index], updatedPet);
      pets[index] = updatedPet;
      notifyListeners();
    }
  }
} 