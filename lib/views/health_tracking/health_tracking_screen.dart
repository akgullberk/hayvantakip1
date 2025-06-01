import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../viewmodels/health_tracking_viewmodel.dart';
import 'veteriner_kayitlari_screen.dart';
import 'asi_takvimi_screen.dart';
import 'hastalik_takibi_screen.dart';
import 'ilac_takibi_screen.dart';

class HealthTrackingScreen extends StatelessWidget {
  final Pet pet;

  const HealthTrackingScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${pet.ad} - Sağlık Takibi'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Veteriner Kayıtları'),
              Tab(text: 'Aşı Takvimi'),
              Tab(text: 'Hastalık Takibi'),
              Tab(text: 'İlaç Takibi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            VeterinerKayitlariScreen(pet: pet),
            AsiTakvimiScreen(pet: pet),
            HastalikTakibiScreen(pet: pet),
            IlacTakibiScreen(pet: pet),
          ],
        ),
      ),
    );
  }
} 