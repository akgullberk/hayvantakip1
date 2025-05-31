import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../viewmodels/pet_viewmodel.dart';
import 'pet_detail_widgets.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  void _showEditPetDialog(BuildContext context, Pet pet, int index) {
    final petViewModel = Provider.of<PetViewModel>(context, listen: false);
    String ad = pet.ad;
    String tur = pet.tur;
    String cins = pet.cins;
    String fotograf = pet.fotograf;
    String saglikDurumu = pet.saglikDurumu;
    int yas = pet.yas;
    double agirlik = pet.agirlik;
    String? sonVeterinerZiyaretiTarihi = pet.sonVeterinerZiyaretiTarihi;
    List<String> alinanAsilar = List.from(pet.alinanAsilar);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Evcil Hayvan Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: ad),
                  onChanged: (value) { ad = value; },
                  decoration: const InputDecoration(labelText: "Ad")
                ),
                TextField(
                  controller: TextEditingController(text: tur),
                  onChanged: (value) { tur = value; },
                  decoration: const InputDecoration(labelText: "Tür")
                ),
                TextField(
                  controller: TextEditingController(text: cins),
                  onChanged: (value) { cins = value; },
                  decoration: const InputDecoration(labelText: "Cins")
                ),
                TextField(
                  controller: TextEditingController(text: fotograf),
                  onChanged: (value) { fotograf = value; },
                  decoration: const InputDecoration(labelText: "Fotoğraf (URL veya dosya yolu)")
                ),
                TextField(
                  controller: TextEditingController(text: saglikDurumu),
                  onChanged: (value) { saglikDurumu = value; },
                  decoration: const InputDecoration(labelText: "Sağlık Durumu")
                ),
                TextField(
                  controller: TextEditingController(text: yas.toString()),
                  onChanged: (value) { yas = int.tryParse(value) ?? 0; },
                  decoration: const InputDecoration(labelText: "Yaş"),
                  keyboardType: TextInputType.number
                ),
                TextField(
                  controller: TextEditingController(text: agirlik.toString()),
                  onChanged: (value) { agirlik = double.tryParse(value) ?? 0.0; },
                  decoration: const InputDecoration(labelText: "Ağırlık"),
                  keyboardType: TextInputType.number
                ),
                TextField(
                  controller: TextEditingController(text: sonVeterinerZiyaretiTarihi ?? ""),
                  onChanged: (value) { sonVeterinerZiyaretiTarihi = value.isEmpty ? null : value; },
                  decoration: const InputDecoration(labelText: "Son Veteriner Ziyareti Tarihi (YYYY-MM-DD)")
                ),
                TextField(
                  controller: TextEditingController(text: alinanAsilar.join(", ")),
                  onChanged: (value) { alinanAsilar = value.split(',').map((e) => e.trim()).toList(); },
                  decoration: const InputDecoration(labelText: "Alınan Aşılar (virgülle ayırın)")
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("İptal")
            ),
            TextButton(
              onPressed: () async {
                final updatedPet = Pet(
                  ad: ad,
                  tur: tur,
                  yas: yas,
                  cins: cins,
                  fotograf: fotograf,
                  agirlik: agirlik,
                  saglikDurumu: saglikDurumu,
                  sonVeterinerZiyaretiTarihi: sonVeterinerZiyaretiTarihi,
                  alinanAsilar: alinanAsilar,
                );
                await petViewModel.updatePet(index, updatedPet);
                Navigator.of(context).pop();
              },
              child: const Text("Kaydet")
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.ad),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context);
              _showEditPetDialog(context, pet, -1);
            },
          ),
        ],
      ),
      body: PetDetailWidget(pet: pet),
    );
  }
} 