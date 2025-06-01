import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';
import '../models/health_tracking_model.dart';

class LocalStorageService {
  static Database? _database;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), "pet_database.db"),
      version: 2,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE pets (
            ad TEXT,
            tur TEXT,
            yas INTEGER,
            cins TEXT,
            fotograf TEXT,
            agirlik REAL,
            saglikDurumu TEXT,
            sonVeterinerZiyaretiTarihi TEXT,
            alinanAsilar TEXT
          )
        """);

        await db.execute("""
          CREATE TABLE veteriner_kayitlari (
            id TEXT PRIMARY KEY,
            petId TEXT,
            tarih TEXT,
            doktorAdi TEXT,
            aciklama TEXT,
            notlar TEXT,
            FOREIGN KEY (petId) REFERENCES pets (ad)
          )
        """);

        await db.execute("""
          CREATE TABLE asi_kayitlari (
            id TEXT PRIMARY KEY,
            petId TEXT,
            asiAdi TEXT,
            yapilmaTarihi TEXT,
            tekrarTarihi TEXT,
            notlar TEXT,
            FOREIGN KEY (petId) REFERENCES pets (ad)
          )
        """);

        await db.execute("""
          CREATE TABLE hastalik_kayitlari (
            id TEXT PRIMARY KEY,
            petId TEXT,
            hastalikAdi TEXT,
            baslangicTarihi TEXT,
            bitisTarihi TEXT,
            tedaviDetaylari TEXT,
            notlar TEXT,
            FOREIGN KEY (petId) REFERENCES pets (ad)
          )
        """);

        await db.execute("""
          CREATE TABLE ilac_kayitlari (
            id TEXT PRIMARY KEY,
            petId TEXT,
            ilacAdi TEXT,
            baslangicTarihi TEXT,
            bitisTarihi TEXT,
            dozaj TEXT,
            kullanimSikligi TEXT,
            notlar TEXT,
            FOREIGN KEY (petId) REFERENCES pets (ad)
          )
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("""
            CREATE TABLE veteriner_kayitlari (
              id TEXT PRIMARY KEY,
              petId TEXT,
              tarih TEXT,
              doktorAdi TEXT,
              aciklama TEXT,
              notlar TEXT,
              FOREIGN KEY (petId) REFERENCES pets (ad)
            )
          """);

          await db.execute("""
            CREATE TABLE asi_kayitlari (
              id TEXT PRIMARY KEY,
              petId TEXT,
              asiAdi TEXT,
              yapilmaTarihi TEXT,
              tekrarTarihi TEXT,
              notlar TEXT,
              FOREIGN KEY (petId) REFERENCES pets (ad)
            )
          """);

          await db.execute("""
            CREATE TABLE hastalik_kayitlari (
              id TEXT PRIMARY KEY,
              petId TEXT,
              hastalikAdi TEXT,
              baslangicTarihi TEXT,
              bitisTarihi TEXT,
              tedaviDetaylari TEXT,
              notlar TEXT,
              FOREIGN KEY (petId) REFERENCES pets (ad)
            )
          """);

          await db.execute("""
            CREATE TABLE ilac_kayitlari (
              id TEXT PRIMARY KEY,
              petId TEXT,
              ilacAdi TEXT,
              baslangicTarihi TEXT,
              bitisTarihi TEXT,
              dozaj TEXT,
              kullanimSikligi TEXT,
              notlar TEXT,
              FOREIGN KEY (petId) REFERENCES pets (ad)
            )
          """);
        }
      }
    );
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

  // Veteriner Kayıtları
  Future<void> addVeterinerKaydi(VeterinerKaydi kayit) async {
    final db = await database;
    await db.insert("veteriner_kayitlari", kayit.toMap());
  }

  Future<List<VeterinerKaydi>> getVeterinerKayitlari(String petId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "veteriner_kayitlari",
      where: "petId = ?",
      whereArgs: [petId],
      orderBy: "tarih DESC"
    );
    return List.generate(maps.length, (i) => VeterinerKaydi.fromMap(maps[i]));
  }

  Future<void> updateVeterinerKaydi(VeterinerKaydi kayit) async {
    final db = await database;
    await db.update(
      "veteriner_kayitlari",
      kayit.toMap(),
      where: "id = ?",
      whereArgs: [kayit.id]
    );
  }

  Future<void> deleteVeterinerKaydi(String id) async {
    final db = await database;
    await db.delete(
      "veteriner_kayitlari",
      where: "id = ?",
      whereArgs: [id]
    );
  }

  // Aşı Kayıtları
  Future<void> addAsiKaydi(AsiKaydi kayit) async {
    final db = await database;
    await db.insert("asi_kayitlari", kayit.toMap());
  }

  Future<List<AsiKaydi>> getAsiKayitlari(String petId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "asi_kayitlari",
      where: "petId = ?",
      whereArgs: [petId],
      orderBy: "yapilmaTarihi DESC"
    );
    return List.generate(maps.length, (i) => AsiKaydi.fromMap(maps[i]));
  }

  Future<void> updateAsiKaydi(AsiKaydi kayit) async {
    final db = await database;
    await db.update(
      "asi_kayitlari",
      kayit.toMap(),
      where: "id = ?",
      whereArgs: [kayit.id]
    );
  }

  Future<void> deleteAsiKaydi(String id) async {
    final db = await database;
    await db.delete(
      "asi_kayitlari",
      where: "id = ?",
      whereArgs: [id]
    );
  }

  // Hastalık Kayıtları
  Future<void> addHastalikKaydi(HastalikKaydi kayit) async {
    final db = await database;
    await db.insert("hastalik_kayitlari", kayit.toMap());
  }

  Future<List<HastalikKaydi>> getHastalikKayitlari(String petId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "hastalik_kayitlari",
      where: "petId = ?",
      whereArgs: [petId],
      orderBy: "baslangicTarihi DESC"
    );
    return List.generate(maps.length, (i) => HastalikKaydi.fromMap(maps[i]));
  }

  Future<void> updateHastalikKaydi(HastalikKaydi kayit) async {
    final db = await database;
    await db.update(
      "hastalik_kayitlari",
      kayit.toMap(),
      where: "id = ?",
      whereArgs: [kayit.id]
    );
  }

  Future<void> deleteHastalikKaydi(String id) async {
    final db = await database;
    await db.delete(
      "hastalik_kayitlari",
      where: "id = ?",
      whereArgs: [id]
    );
  }

  // İlaç Kayıtları
  Future<void> addIlacKaydi(IlacKaydi kayit) async {
    final db = await database;
    await db.insert("ilac_kayitlari", kayit.toMap());
  }

  Future<List<IlacKaydi>> getIlacKayitlari(String petId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "ilac_kayitlari",
      where: "petId = ?",
      whereArgs: [petId],
      orderBy: "baslangicTarihi DESC"
    );
    return List.generate(maps.length, (i) => IlacKaydi.fromMap(maps[i]));
  }

  Future<void> updateIlacKaydi(IlacKaydi kayit) async {
    final db = await database;
    await db.update(
      "ilac_kayitlari",
      kayit.toMap(),
      where: "id = ?",
      whereArgs: [kayit.id]
    );
  }

  Future<void> deleteIlacKaydi(String id) async {
    final db = await database;
    await db.delete(
      "ilac_kayitlari",
      where: "id = ?",
      whereArgs: [id]
    );
  }
} 