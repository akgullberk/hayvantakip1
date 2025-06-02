class PetPhoto {
  final String id;
  final String petId;
  final String photoPath;
  final DateTime eklenmeTarihi;
  final String? aciklama;

  PetPhoto({
    required this.id,
    required this.petId,
    required this.photoPath,
    required this.eklenmeTarihi,
    this.aciklama,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'photoPath': photoPath,
      'eklenmeTarihi': eklenmeTarihi.toIso8601String(),
      'aciklama': aciklama,
    };
  }

  factory PetPhoto.fromMap(Map<String, dynamic> map) {
    return PetPhoto(
      id: map['id'],
      petId: map['petId'],
      photoPath: map['photoPath'],
      eklenmeTarihi: DateTime.parse(map['eklenmeTarihi']),
      aciklama: map['aciklama'],
    );
  }
} 