import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../models/pet_model.dart';
import '../meal_tracking/meal_tracking_screen.dart';
import '../health_tracking/health_tracking_screen.dart';
import '../pet_photos/pet_photo_gallery_screen.dart';

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
                child: Image.file(
                  File(pet.fotograf),
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
                pet.sonVeterinerZiyaretiTarihi != null 
                  ? DateFormat('dd/MM/yyyy').format(pet.sonVeterinerZiyaretiTarihi!)
                  : "Belirtilmemiş"
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
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthTrackingScreen(pet: pet),
                ),
              );
            },
            icon: const Icon(Icons.medical_services),
            label: const Text('Sağlık Takibi'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetPhotoGalleryScreen(pet: pet),
                ),
              );
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Fotoğraf Galerisi'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
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