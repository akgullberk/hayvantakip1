import 'package:flutter/material.dart';

class Pet {
  final String ad;
  final String tur;
  final int yas;
  final String cins;
  final String fotograf;
  final double agirlik;
  final String saglikDurumu;
  final DateTime? sonVeterinerZiyaretiTarihi;
  final List<String> alinanAsilar;

  Pet({
    required this.ad,
    required this.tur,
    required this.yas,
    required this.cins,
    required this.fotograf,
    required this.agirlik,
    required this.saglikDurumu,
    this.sonVeterinerZiyaretiTarihi,
    required this.alinanAsilar,
  });
} 