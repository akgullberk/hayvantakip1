import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/health_tracking_model.dart';
import '../services/local_storage_service.dart';

class HealthTrackingViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  final _uuid = const Uuid();

  List<VeterinerKaydi> _veterinerKayitlari = [];
  List<AsiKaydi> _asiKayitlari = [];
  List<HastalikKaydi> _hastalikKayitlari = [];
  List<IlacKaydi> _ilacKayitlari = [];

  List<VeterinerKaydi> get veterinerKayitlari => _veterinerKayitlari;
  List<AsiKaydi> get asiKayitlari => _asiKayitlari;
  List<HastalikKaydi> get hastalikKayitlari => _hastalikKayitlari;
  List<IlacKaydi> get ilacKayitlari => _ilacKayitlari;

  // Veteriner Kayıtları
  Future<void> veterinerKaydiEkle(String petId, String doktorAdi, String aciklama, String? notlar) async {
    final kayit = VeterinerKaydi(
      id: _uuid.v4(),
      petId: petId,
      tarih: DateTime.now(),
      doktorAdi: doktorAdi,
      aciklama: aciklama,
      notlar: notlar,
    );

    await _storageService.addVeterinerKaydi(kayit);
    await veterinerKayitlariniYukle(petId);
  }

  Future<void> veterinerKayitlariniYukle(String petId) async {
    _veterinerKayitlari = await _storageService.getVeterinerKayitlari(petId);
    notifyListeners();
  }

  Future<void> veterinerKaydiGuncelle(VeterinerKaydi kayit) async {
    await _storageService.updateVeterinerKaydi(kayit);
    await veterinerKayitlariniYukle(kayit.petId);
  }

  Future<void> veterinerKaydiSil(String id, String petId) async {
    await _storageService.deleteVeterinerKaydi(id);
    await veterinerKayitlariniYukle(petId);
  }

  // Aşı Kayıtları
  Future<void> asiKaydiEkle(String petId, String asiAdi, DateTime yapilmaTarihi, DateTime? tekrarTarihi, String? notlar) async {
    final kayit = AsiKaydi(
      id: _uuid.v4(),
      petId: petId,
      asiAdi: asiAdi,
      yapilmaTarihi: yapilmaTarihi,
      tekrarTarihi: tekrarTarihi,
      notlar: notlar,
    );

    await _storageService.addAsiKaydi(kayit);
    await asiKayitlariniYukle(petId);
  }

  Future<void> asiKayitlariniYukle(String petId) async {
    _asiKayitlari = await _storageService.getAsiKayitlari(petId);
    notifyListeners();
  }

  Future<void> asiKaydiGuncelle(AsiKaydi kayit) async {
    await _storageService.updateAsiKaydi(kayit);
    await asiKayitlariniYukle(kayit.petId);
  }

  Future<void> asiKaydiSil(String id, String petId) async {
    await _storageService.deleteAsiKaydi(id);
    await asiKayitlariniYukle(petId);
  }

  // Hastalık Kayıtları
  Future<void> hastalikKaydiEkle(String petId, String hastalikAdi, DateTime baslangicTarihi, DateTime? bitisTarihi, String tedaviDetaylari, String? notlar) async {
    final kayit = HastalikKaydi(
      id: _uuid.v4(),
      petId: petId,
      hastalikAdi: hastalikAdi,
      baslangicTarihi: baslangicTarihi,
      bitisTarihi: bitisTarihi,
      tedaviDetaylari: tedaviDetaylari,
      notlar: notlar,
    );

    await _storageService.addHastalikKaydi(kayit);
    await hastalikKayitlariniYukle(petId);
  }

  Future<void> hastalikKayitlariniYukle(String petId) async {
    _hastalikKayitlari = await _storageService.getHastalikKayitlari(petId);
    notifyListeners();
  }

  Future<void> hastalikKaydiGuncelle(HastalikKaydi kayit) async {
    await _storageService.updateHastalikKaydi(kayit);
    await hastalikKayitlariniYukle(kayit.petId);
  }

  Future<void> hastalikKaydiSil(String id, String petId) async {
    await _storageService.deleteHastalikKaydi(id);
    await hastalikKayitlariniYukle(petId);
  }

  // İlaç Kayıtları
  Future<void> ilacKaydiEkle(String petId, String ilacAdi, DateTime baslangicTarihi, DateTime? bitisTarihi, String dozaj, String kullanimSikligi, String? notlar) async {
    final kayit = IlacKaydi(
      id: _uuid.v4(),
      petId: petId,
      ilacAdi: ilacAdi,
      baslangicTarihi: baslangicTarihi,
      bitisTarihi: bitisTarihi,
      dozaj: dozaj,
      kullanimSikligi: kullanimSikligi,
      notlar: notlar,
    );

    await _storageService.addIlacKaydi(kayit);
    await ilacKayitlariniYukle(petId);
  }

  Future<void> ilacKayitlariniYukle(String petId) async {
    _ilacKayitlari = await _storageService.getIlacKayitlari(petId);
    notifyListeners();
  }

  Future<void> ilacKaydiGuncelle(IlacKaydi kayit) async {
    await _storageService.updateIlacKaydi(kayit);
    await ilacKayitlariniYukle(kayit.petId);
  }

  Future<void> ilacKaydiSil(String id, String petId) async {
    await _storageService.deleteIlacKaydi(id);
    await ilacKayitlariniYukle(petId);
  }
} 