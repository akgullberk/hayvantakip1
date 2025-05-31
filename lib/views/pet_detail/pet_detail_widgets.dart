import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../viewmodels/pet_viewmodel.dart';
import '../meal_tracking/meal_tracking_screen.dart';

class PetDetailWidget extends StatelessWidget {
  final Pet pet;

  const PetDetailWidget({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pet.fotograf.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  pet.fotograf,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 24),
          _buildActionButtons(context),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "Temel Bilgiler",
            children: [
              _buildInfoRow("Ad", pet.ad),
              _buildInfoRow("Tür", pet.tur),
              _buildInfoRow("Cins", pet.cins),
              _buildInfoRow("Yaş", "${pet.yas} yaş"),
              _buildInfoRow("Ağırlık", "${pet.agirlik} kg"),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "Sağlık Bilgileri",
            children: [
              _buildInfoRow("Sağlık Durumu", pet.saglikDurumu),
              _buildInfoRow(
                "Son Veteriner Ziyareti",
                pet.sonVeterinerZiyaretiTarihi ?? "Belirtilmemiş"
              ),
              if (pet.alinanAsilar.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Alınan Aşılar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ...pet.alinanAsilar.map((asi) => Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(asi),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealTrackingScreen(
                  petId: pet.ad,
                  petName: pet.ad,
                ),
              ),
            );
          },
          icon: const Icon(Icons.restaurant),
          label: const Text('Beslenme Takibi'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditPetDialog extends StatelessWidget {
  final Pet pet;
  final int index;

  const EditPetDialog({super.key, required this.pet, required this.index});

  @override
  Widget build(BuildContext context) {
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
  }
}

void showEditPetDialog(BuildContext context, Pet pet, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EditPetDialog(pet: pet, index: index);
    },
  );
} 