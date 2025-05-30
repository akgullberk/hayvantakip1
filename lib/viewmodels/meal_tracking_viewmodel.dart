import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal_tracking_model.dart';

class MealTrackingViewModel extends ChangeNotifier {
  Database? _database;
  List<BeslenmeKaydi> _beslenmeKayitlari = [];

  List<BeslenmeKaydi> get beslenmeKayitlari => _beslenmeKayitlari;

  Future<void> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'beslenme_takibi.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE beslenme_kayitlari(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petId TEXT,
            yemekTuru TEXT,
            yemekSaati TEXT,
            miktar REAL,
            suIcti INTEGER,
            tarih TEXT
          )
        ''');
      },
    );
    await _beslenmeKayitlariniYukle();
  }

  Future<void> _beslenmeKayitlariniYukle() async {
    if (_database == null) {
      return;
    }

    try {
      final List<Map<String, dynamic>> maps = await _database!.query('beslenme_kayitlari');
      _beslenmeKayitlari = maps.map((map) => BeslenmeKaydi.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> beslenmeKaydiEkle(BeslenmeKaydi kayit) async {
    if (_database == null) {
      return;
    }

    try {
      final id = await _database!.insert(
        'beslenme_kayitlari',
        {
          'petId': kayit.petId,
          'yemekTuru': kayit.yemekTuru.toString(),
          'yemekSaati': kayit.yemekSaati.toString(),
          'miktar': kayit.miktar,
          'suIcti': kayit.suIcti ? 1 : 0,
          'tarih': kayit.tarih.toIso8601String(),
        },
      );

      await _beslenmeKayitlariniYukle();
    } catch (e) {
    }
  }

  Future<List<BeslenmeKaydi>> petBeslenmeKayitlariniGetir(String petId) async {
    if (_database == null) {
      return [];
    }

    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'beslenme_kayitlari',
        where: 'petId = ?',
        whereArgs: [petId],
        orderBy: 'tarih DESC',
      );
      
      final kayitlar = maps.map((map) {
        try {
          final kayit = BeslenmeKaydi.fromMap(map);
          return kayit;
        } catch (e) {
          rethrow;
        }
      }).toList();
      
      return kayitlar;
    } catch (e) {
      return [];
    }
  }
} 