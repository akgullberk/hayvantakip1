import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pet_model.dart';
import '../../models/health_tracking_model.dart';
import '../../viewmodels/health_tracking_viewmodel.dart';

class VeterinerKayitlariScreen extends StatefulWidget {
  final Pet pet;

  const VeterinerKayitlariScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<VeterinerKayitlariScreen> createState() => _VeterinerKayitlariScreenState();
}

class _VeterinerKayitlariScreenState extends State<VeterinerKayitlariScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doktorAdiController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _notlarController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _veterinerKayitlariniYukle();
  }

  @override
  void dispose() {
    _doktorAdiController.dispose();
    _aciklamaController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _veterinerKayitlariniYukle() async {
    setState(() => _isLoading = true);
    try {
      final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
      await viewModel.veterinerKayitlariniYukle(widget.pet.ad);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıtlar yüklenirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _veterinerKaydiEkle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
        await viewModel.veterinerKaydiEkle(
          widget.pet.ad,
          _doktorAdiController.text,
          _aciklamaController.text,
          _notlarController.text.isEmpty ? null : _notlarController.text,
        );

        if (mounted) {
          _doktorAdiController.clear();
          _aciklamaController.clear();
          _notlarController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veteriner kaydı başarıyla eklendi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayıt eklenirken hata oluştu: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showVeterinerKaydiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Veteriner Kaydı'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _doktorAdiController,
                    decoration: const InputDecoration(labelText: 'Doktor Adı'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen doktor adını girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _aciklamaController,
                    decoration: const InputDecoration(labelText: 'Açıklama'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen açıklama girin';
                      }
                      return null;
                    },
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: _notlarController,
                    decoration: const InputDecoration(labelText: 'Notlar (Opsiyonel)'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _veterinerKaydiEkle();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<HealthTrackingViewModel>(
              builder: (context, viewModel, child) {
                final kayitlar = viewModel.veterinerKayitlari;
                if (kayitlar.isEmpty) {
                  return const Center(
                    child: Text('Henüz veteriner kaydı bulunmuyor'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: kayitlar.length,
                  itemBuilder: (context, index) {
                    final kayit = kayitlar[index];
                    return Card(
                      child: ListTile(
                        title: Text(kayit.doktorAdi),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('dd.MM.yyyy HH:mm').format(kayit.tarih)),
                            Text(kayit.aciklama),
                            if (kayit.notlar != null && kayit.notlar!.isNotEmpty)
                              Text('Notlar: ${kayit.notlar}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final onay = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Kaydı Sil'),
                                content: const Text('Bu veteriner kaydını silmek istediğinizden emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Sil'),
                                  ),
                                ],
                              ),
                            );

                            if (onay == true && mounted) {
                              try {
                                await viewModel.veterinerKaydiSil(kayit.id, kayit.petId);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Kayıt başarıyla silindi')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Kayıt silinirken hata oluştu: $e')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showVeterinerKaydiDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 