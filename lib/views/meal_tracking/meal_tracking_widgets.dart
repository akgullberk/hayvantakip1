import 'package:flutter/material.dart';
import '../../models/meal_tracking_model.dart';
import '../../utils/meal_tracking_utils.dart';

class BeslenmeKayitFormu extends StatelessWidget {
  final YemekTuru secilenYemekTuru;
  final YemekSaati secilenYemekSaati;
  final TextEditingController miktarController;
  final bool suIcti;
  final Function(YemekTuru?) onYemekTuruChanged;
  final Function(YemekSaati?) onYemekSaatiChanged;
  final Function(bool) onSuIctiChanged;

  const BeslenmeKayitFormu({
    Key? key,
    required this.secilenYemekTuru,
    required this.secilenYemekSaati,
    required this.miktarController,
    required this.suIcti,
    required this.onYemekTuruChanged,
    required this.onYemekSaatiChanged,
    required this.onSuIctiChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yeni Beslenme Kaydı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<YemekTuru>(
              decoration: const InputDecoration(
                labelText: 'Yemek Türü',
                border: OutlineInputBorder(),
              ),
              value: secilenYemekTuru,
              items: YemekTuru.values.map((YemekTuru tur) {
                return DropdownMenuItem<YemekTuru>(
                  value: tur,
                  child: Text(yemekTuruToString(tur)),
                );
              }).toList(),
              onChanged: onYemekTuruChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<YemekSaati>(
              decoration: const InputDecoration(
                labelText: 'Yemek Saati',
                border: OutlineInputBorder(),
              ),
              value: secilenYemekSaati,
              items: YemekSaati.values.map((YemekSaati saat) {
                return DropdownMenuItem<YemekSaati>(
                  value: saat,
                  child: Text(yemekSaatiToString(saat)),
                );
              }).toList(),
              onChanged: onYemekSaatiChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: miktarController,
              decoration: const InputDecoration(
                labelText: 'Miktar (gram)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen miktar giriniz';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir sayı giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Su İçti mi?'),
              value: suIcti,
              onChanged: onSuIctiChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class BeslenmeGecmisi extends StatelessWidget {
  final List<BeslenmeKaydi> beslenmeKayitlari;

  const BeslenmeGecmisi({
    Key? key,
    required this.beslenmeKayitlari,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beslenme Geçmişi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (beslenmeKayitlari.isEmpty)
              const Center(
                child: Text('Henüz beslenme kaydı bulunmuyor'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: beslenmeKayitlari.length,
                itemBuilder: (context, index) {
                  final kayit = beslenmeKayitlari[index];
                  return ListTile(
                    leading: Icon(
                      kayit.suIcti ? Icons.water_drop : Icons.restaurant,
                      color: kayit.suIcti ? Colors.blue : Colors.orange,
                    ),
                    title: Text(
                      '${yemekTuruToString(kayit.yemekTuru)} - ${yemekSaatiToString(kayit.yemekSaati)}',
                    ),
                    subtitle: Text(
                      '${kayit.miktar} gram - ${kayit.tarih.toString().split('.')[0]}',
                    ),
                    trailing: Text(
                      kayit.suIcti ? 'Su İçti' : 'Su İçmedi',
                      style: TextStyle(
                        color: kayit.suIcti ? Colors.blue : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
} 