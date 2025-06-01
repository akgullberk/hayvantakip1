import 'package:flutter/material.dart';

class VeterinerKaydi {
  final String id;
  final String petId;
  final DateTime tarih;
  final String doktorAdi;
  final String aciklama;
  final String? notlar;

  VeterinerKaydi({
    required this.id,
    required this.petId,
    required this.tarih,
    required this.doktorAdi,
    required this.aciklama,
    this.notlar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'tarih': tarih.toIso8601String(),
      'doktorAdi': doktorAdi,
      'aciklama': aciklama,
      'notlar': notlar,
    };
  }

  factory VeterinerKaydi.fromMap(Map<String, dynamic> map) {
    return VeterinerKaydi(
      id: map['id'],
      petId: map['petId'],
      tarih: DateTime.parse(map['tarih']),
      doktorAdi: map['doktorAdi'],
      aciklama: map['aciklama'],
      notlar: map['notlar'],
    );
  }
}

class AsiKaydi {
  final String id;
  final String petId;
  final String asiAdi;
  final DateTime yapilmaTarihi;
  final DateTime? tekrarTarihi;
  final String? notlar;

  AsiKaydi({
    required this.id,
    required this.petId,
    required this.asiAdi,
    required this.yapilmaTarihi,
    this.tekrarTarihi,
    this.notlar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'asiAdi': asiAdi,
      'yapilmaTarihi': yapilmaTarihi.toIso8601String(),
      'tekrarTarihi': tekrarTarihi?.toIso8601String(),
      'notlar': notlar,
    };
  }

  factory AsiKaydi.fromMap(Map<String, dynamic> map) {
    return AsiKaydi(
      id: map['id'],
      petId: map['petId'],
      asiAdi: map['asiAdi'],
      yapilmaTarihi: DateTime.parse(map['yapilmaTarihi']),
      tekrarTarihi: map['tekrarTarihi'] != null ? DateTime.parse(map['tekrarTarihi']) : null,
      notlar: map['notlar'],
    );
  }
}

class HastalikKaydi {
  final String id;
  final String petId;
  final String hastalikAdi;
  final DateTime baslangicTarihi;
  final DateTime? bitisTarihi;
  final String tedaviDetaylari;
  final String? notlar;

  HastalikKaydi({
    required this.id,
    required this.petId,
    required this.hastalikAdi,
    required this.baslangicTarihi,
    this.bitisTarihi,
    required this.tedaviDetaylari,
    this.notlar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'hastalikAdi': hastalikAdi,
      'baslangicTarihi': baslangicTarihi.toIso8601String(),
      'bitisTarihi': bitisTarihi?.toIso8601String(),
      'tedaviDetaylari': tedaviDetaylari,
      'notlar': notlar,
    };
  }

  factory HastalikKaydi.fromMap(Map<String, dynamic> map) {
    return HastalikKaydi(
      id: map['id'],
      petId: map['petId'],
      hastalikAdi: map['hastalikAdi'],
      baslangicTarihi: DateTime.parse(map['baslangicTarihi']),
      bitisTarihi: map['bitisTarihi'] != null ? DateTime.parse(map['bitisTarihi']) : null,
      tedaviDetaylari: map['tedaviDetaylari'],
      notlar: map['notlar'],
    );
  }
}

class IlacKaydi {
  final String id;
  final String petId;
  final String ilacAdi;
  final DateTime baslangicTarihi;
  final DateTime? bitisTarihi;
  final String dozaj;
  final String kullanimSikligi;
  final String? notlar;

  IlacKaydi({
    required this.id,
    required this.petId,
    required this.ilacAdi,
    required this.baslangicTarihi,
    this.bitisTarihi,
    required this.dozaj,
    required this.kullanimSikligi,
    this.notlar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'ilacAdi': ilacAdi,
      'baslangicTarihi': baslangicTarihi.toIso8601String(),
      'bitisTarihi': bitisTarihi?.toIso8601String(),
      'dozaj': dozaj,
      'kullanimSikligi': kullanimSikligi,
      'notlar': notlar,
    };
  }

  factory IlacKaydi.fromMap(Map<String, dynamic> map) {
    return IlacKaydi(
      id: map['id'],
      petId: map['petId'],
      ilacAdi: map['ilacAdi'],
      baslangicTarihi: DateTime.parse(map['baslangicTarihi']),
      bitisTarihi: map['bitisTarihi'] != null ? DateTime.parse(map['bitisTarihi']) : null,
      dozaj: map['dozaj'],
      kullanimSikligi: map['kullanimSikligi'],
      notlar: map['notlar'],
    );
  }
} 