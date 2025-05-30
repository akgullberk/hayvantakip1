import 'package:flutter/material.dart';

enum YemekTuru {
  kuruMama,
  yasMama,
  evYemegi,
  diger
}

enum YemekSaati {
  sabah,
  ogle,
  aksam
}

class BeslenmeKaydi {
  final String petId;
  final YemekTuru yemekTuru;
  final YemekSaati yemekSaati;
  final double miktar;
  final bool suIcti;
  final DateTime tarih;

  BeslenmeKaydi({
    required this.petId,
    required this.yemekTuru,
    required this.yemekSaati,
    required this.miktar,
    required this.suIcti,
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'yemekTuru': yemekTuru.toString(),
      'yemekSaati': yemekSaati.toString(),
      'miktar': miktar,
      'suIcti': suIcti,
      'tarih': tarih.toIso8601String(),
    };
  }

  factory BeslenmeKaydi.fromMap(Map<String, dynamic> map) {
    return BeslenmeKaydi(
      petId: map['petId'],
      yemekTuru: YemekTuru.values.firstWhere(
        (e) => e.toString() == map['yemekTuru'],
      ),
      yemekSaati: YemekSaati.values.firstWhere(
        (e) => e.toString() == map['yemekSaati'],
      ),
      miktar: map['miktar'],
      suIcti: map['suIcti'] == 1,
      tarih: DateTime.parse(map['tarih']),
    );
  }
} 