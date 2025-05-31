import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal_tracking_model.dart';
import '../../viewmodels/meal_tracking_viewmodel.dart';
import 'meal_tracking_widgets.dart';

class MealTrackingScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const MealTrackingScreen({
    Key? key,
    required this.petId,
    required this.petName,
  }) : super(key: key);

  @override
  State<MealTrackingScreen> createState() => _MealTrackingScreenState();
}

class _MealTrackingScreenState extends State<MealTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  YemekTuru _secilenYemekTuru = YemekTuru.kuruMama;
  YemekSaati _secilenYemekSaati = YemekSaati.sabah;
  final _miktarController = TextEditingController();
  bool _suIcti = false;
  List<BeslenmeKaydi> _beslenmeKayitlari = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _beslenmeKayitlariniYukle();
  }

  @override
  void dispose() {
    _miktarController.dispose();
    super.dispose();
  }

  Future<void> _beslenmeKayitlariniYukle() async {
    setState(() => _isLoading = true);
    
    try {
      final viewModel = Provider.of<MealTrackingViewModel>(context, listen: false);
      final kayitlar = await viewModel.petBeslenmeKayitlariniGetir(widget.petId);
      
      if (mounted) {
        setState(() {
          _beslenmeKayitlari = kayitlar;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıtlar yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _beslenmeKaydet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final viewModel = Provider.of<MealTrackingViewModel>(context, listen: false);
        final beslenmeKaydi = BeslenmeKaydi(
          petId: widget.petId,
          yemekTuru: _secilenYemekTuru,
          yemekSaati: _secilenYemekSaati,
          miktar: double.parse(_miktarController.text),
          suIcti: _suIcti,
          tarih: DateTime.now(),
        );

        await viewModel.beslenmeKaydiEkle(beslenmeKaydi);
        await _beslenmeKayitlariniYukle();

        if (mounted) {
          _miktarController.clear();
          setState(() {
            _suIcti = false;
            _secilenYemekTuru = YemekTuru.kuruMama;
            _secilenYemekSaati = YemekSaati.sabah;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Beslenme kaydı başarıyla eklendi')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayıt eklenirken hata oluştu: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.petName} - Beslenme Takibi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BeslenmeKayitFormu(
                      secilenYemekTuru: _secilenYemekTuru,
                      secilenYemekSaati: _secilenYemekSaati,
                      miktarController: _miktarController,
                      suIcti: _suIcti,
                      onYemekTuruChanged: (YemekTuru? yeniDeger) {
                        if (yeniDeger != null) {
                          setState(() => _secilenYemekTuru = yeniDeger);
                        }
                      },
                      onYemekSaatiChanged: (YemekSaati? yeniDeger) {
                        if (yeniDeger != null) {
                          setState(() => _secilenYemekSaati = yeniDeger);
                        }
                      },
                      onSuIctiChanged: (bool yeniDeger) {
                        setState(() => _suIcti = yeniDeger);
                      },
                    ),
                    const SizedBox(height: 20),
                    BeslenmeGecmisi(beslenmeKayitlari: _beslenmeKayitlari),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _beslenmeKaydet,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
      ),
    );
  }
} 