import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
    DateTime? sonVeterinerZiyaretiTarihi = pet.sonVeterinerZiyaretiTarihi;
    List<String> alinanAsilar = List.from(pet.alinanAsilar);
    File? secilenFotograf = pet.fotograf.isNotEmpty ? File(pet.fotograf) : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> fotografSec() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              
              if (image != null) {
                final File imageFile = File(image.path);
                final String dosyaAdi = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
                final Directory uygulamaDizini = await getApplicationDocumentsDirectory();
                final String hedefYol = '${uygulamaDizini.path}/$dosyaAdi';
                
                await imageFile.copy(hedefYol);
                setState(() {
                  secilenFotograf = File(hedefYol);
                  fotograf = hedefYol;
                });
              }
            }

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
                    ListTile(
                      title: const Text("Fotoğraf Seç"),
                      trailing: const Icon(Icons.photo_library),
                      onTap: fotografSec,
                    ),
                    if (secilenFotograf != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(secilenFotograf!),
                            fit: BoxFit.cover,
                          ),
                        ),
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
                    ListTile(
                      title: Text(sonVeterinerZiyaretiTarihi == null 
                        ? "Son Veteriner Ziyareti Tarihi Seçin" 
                        : "Seçilen Tarih: ${DateFormat('dd/MM/yyyy').format(sonVeterinerZiyaretiTarihi!)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? secilenTarih = await showDatePicker(
                          context: context,
                          initialDate: sonVeterinerZiyaretiTarihi ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (secilenTarih != null) {
                          sonVeterinerZiyaretiTarihi = secilenTarih;
                          (context as Element).markNeedsBuild();
                        }
                      },
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
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petViewModel = Provider.of<PetViewModel>(context);
    final petIndex = petViewModel.getPets().indexWhere((p) => p.ad == pet.ad);

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.ad),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditPetDialog(context, pet, petIndex);
            },
          ),
        ],
      ),
      body: PetDetailWidget(pet: pet),
    );
  }
} 