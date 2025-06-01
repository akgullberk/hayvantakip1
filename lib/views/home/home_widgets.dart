import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/pet_model.dart';
import '../../viewmodels/pet_viewmodel.dart';
import '../pet_detail/pet_detail_screen.dart';

class PetListWidget extends StatelessWidget {
  const PetListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final petViewModel = Provider.of<PetViewModel>(context);
    final pets = petViewModel.getPets();

    if (pets.isEmpty) {
      return const Center(child: Text('Henüz evcil hayvan eklenmemiş.'));
    }

    return ListView.builder(
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return Dismissible(
          key: Key(pet.ad + pet.tur + pet.cins),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Silme Onayı"),
                    content: Text("${pet.ad} isimli evcil hayvanı silmek istediğinizden emin misiniz?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("İptal"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Sil"),
                      ),
                    ],
                  );
                },
              );
            } else {
              _showEditPetDialog(context, pet, index);
              return false;
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              petViewModel.deletePet(index);
            }
          },
          child: ListTile(
            title: Text(pet.ad),
            subtitle: Text(pet.tur + ", " + pet.cins + ", " + pet.yas.toString() + " yaş, " + pet.agirlik.toString() + " kg"),
            trailing: pet.fotograf.isNotEmpty 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(pet.fotograf),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.pets, size: 50);
                    },
                  ),
                )
              : const Icon(Icons.pets, size: 50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailScreen(pet: pet),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

void showAddPetDialog(BuildContext context) {
  final petViewModel = Provider.of<PetViewModel>(context, listen: false);
  String ad = "", tur = "", cins = "", fotograf = "", saglikDurumu = "";
  int yas = 0;
  double agirlik = 0.0;
  DateTime? sonVeterinerZiyaretiTarihi;
  List<String> alinanAsilar = [];
  File? secilenFotograf;

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
            title: const Text("Evcil Hayvan Ekle"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) { ad = value; }, 
                    decoration: const InputDecoration(labelText: "Ad")
                  ),
                  TextField(
                    onChanged: (value) { tur = value; }, 
                    decoration: const InputDecoration(labelText: "Tür")
                  ),
                  TextField(
                    onChanged: (value) { cins = value; }, 
                    decoration: const InputDecoration(labelText: "Cins")
                  ),
                  TextField(
                    onChanged: (value) { saglikDurumu = value; }, 
                    decoration: const InputDecoration(labelText: "Sağlık Durumu")
                  ),
                  TextField(
                    onChanged: (value) { yas = int.tryParse(value) ?? 0; }, 
                    decoration: const InputDecoration(labelText: "Yaş"), 
                    keyboardType: TextInputType.number
                  ),
                  TextField(
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
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (secilenTarih != null) {
                        setState(() {
                          sonVeterinerZiyaretiTarihi = secilenTarih;
                        });
                      }
                    },
                  ),
                  TextField(
                    onChanged: (value) { alinanAsilar = value.split(',').map((e) => e.trim()).toList(); }, 
                    decoration: const InputDecoration(labelText: "Alınan Aşılar (virgülle ayırın)")
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () { Navigator.of(context).pop(); }, 
                child: const Text("İptal")
              ),
              TextButton(
                onPressed: () async {
                  await petViewModel.addPet(
                    ad, 
                    tur, 
                    yas, 
                    cins, 
                    fotograf, 
                    agirlik, 
                    saglikDurumu, 
                    sonVeterinerZiyaretiTarihi, 
                    alinanAsilar
                  );
            Navigator.of(context).pop();
                }, 
                child: const Text("Ekle")
              ),
            ],
          );
        }
      );
    },
  );
}

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