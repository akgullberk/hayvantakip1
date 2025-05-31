import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pet_model.dart';

class LocalStorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(join(await getDatabasesPath(), "pet_database.db"), version: 1, onCreate: (db, version) async {
      await db.execute("CREATE TABLE pets (ad TEXT, tur TEXT, yas INTEGER, cins TEXT, fotograf TEXT, agirlik REAL, saglikDurumu TEXT, sonVeterinerZiyaretiTarihi TEXT, alinanAsilar TEXT)");
    });
    return _database!;
  }

  Future<void> addPet(Pet pet) async {
    final db = await database;
    await db.insert("pets", {
      "ad": pet.ad,
      "tur": pet.tur,
      "yas": pet.yas,
      "cins": pet.cins,
      "fotograf": pet.fotograf,
      "agirlik": pet.agirlik,
      "saglikDurumu": pet.saglikDurumu,
      "sonVeterinerZiyaretiTarihi": pet.sonVeterinerZiyaretiTarihi,
      "alinanAsilar": pet.alinanAsilar.join(",")
    });
  }

  Future<List<Pet>> getPets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("pets");
    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Pet(
        ad: map["ad"] as String,
        tur: map["tur"] as String,
        yas: map["yas"] as int,
        cins: map["cins"] as String,
        fotograf: map["fotograf"] as String,
        agirlik: map["agirlik"] as double,
        saglikDurumu: map["saglikDurumu"] as String,
        sonVeterinerZiyaretiTarihi: map["sonVeterinerZiyaretiTarihi"] as String?,
        alinanAsilar: (map["alinanAsilar"] as String).split(",").map((e) => e.trim()).toList(),
      );
    });
  }

  Future<void> deletePet(Pet pet) async {
    final db = await database;
    await db.delete(
      "pets",
      where: "ad = ? AND tur = ? AND cins = ?",
      whereArgs: [pet.ad, pet.tur, pet.cins],
    );
  }

  Future<void> updatePet(Pet oldPet, Pet newPet) async {
    final db = await database;
    await db.update(
      "pets",
      {
        "ad": newPet.ad,
        "tur": newPet.tur,
        "yas": newPet.yas,
        "cins": newPet.cins,
        "fotograf": newPet.fotograf,
        "agirlik": newPet.agirlik,
        "saglikDurumu": newPet.saglikDurumu,
        "sonVeterinerZiyaretiTarihi": newPet.sonVeterinerZiyaretiTarihi,
        "alinanAsilar": newPet.alinanAsilar.join(",")
      },
      where: "ad = ? AND tur = ? AND cins = ?",
      whereArgs: [oldPet.ad, oldPet.tur, oldPet.cins],
    );
  }
} 