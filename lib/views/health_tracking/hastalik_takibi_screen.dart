import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pet_model.dart';
import '../../models/health_tracking_model.dart';
import '../../viewmodels/health_tracking_viewmodel.dart';

class HastalikTakibiScreen extends StatefulWidget {
  final Pet pet;

  const HastalikTakibiScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<HastalikTakibiScreen> createState() => _HastalikTakibiScreenState();
}

class _HastalikTakibiScreenState extends State<HastalikTakibiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hastalikAdiController = TextEditingController();
  final _tedaviDetaylariController = TextEditingController();
  final _notlarController = TextEditingController();
  DateTime _baslangicTarihi = DateTime.now();
  DateTime? _bitisTarihi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hastalikKayitlariniYukle();
  }

  @override
  void dispose() {
    _hastalikAdiController.dispose();
    _tedaviDetaylariController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _hastalikKayitlariniYukle() async {
    setState(() => _isLoading = true);
    try {
      final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
      await viewModel.hastalikKayitlariniYukle(widget.pet.ad);
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

  Future<void> _hastalikKaydiEkle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
        await viewModel.hastalikKaydiEkle(
          widget.pet.ad,
          _hastalikAdiController.text,
          _baslangicTarihi,
          _bitisTarihi,
          _tedaviDetaylariController.text,
          _notlarController.text.isEmpty ? null : _notlarController.text,
        );

        if (mounted) {
          _hastalikAdiController.clear();
          _tedaviDetaylariController.clear();
          _notlarController.clear();
          _baslangicTarihi = DateTime.now();
          _bitisTarihi = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hastalık kaydı başarıyla eklendi')),
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

  Future<void> _selectDate(BuildContext context, bool isBitisTarihi) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBitisTarihi ? (_bitisTarihi ?? DateTime.now()) : _baslangicTarihi,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isBitisTarihi) {
          _bitisTarihi = picked;
        } else {
          _baslangicTarihi = picked;
        }
      });
    }
  }

  void _showHastalikKaydiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Hastalık Kaydı'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _hastalikAdiController,
                    decoration: const InputDecoration(labelText: 'Hastalık Adı'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen hastalık adını girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Başlangıç Tarihi'),
                    subtitle: Text(DateFormat('dd.MM.yyyy').format(_baslangicTarihi)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                  ListTile(
                    title: const Text('Bitiş Tarihi (Opsiyonel)'),
                    subtitle: Text(_bitisTarihi != null
                        ? DateFormat('dd.MM.yyyy').format(_bitisTarihi!)
                        : 'Seçilmedi'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, true),
                        ),
                        if (_bitisTarihi != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _bitisTarihi = null);
                            },
                          ),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _tedaviDetaylariController,
                    decoration: const InputDecoration(labelText: 'Tedavi Detayları'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen tedavi detaylarını girin';
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
                await _hastalikKaydiEkle();
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
                final kayitlar = viewModel.hastalikKayitlari;
                if (kayitlar.isEmpty) {
                  return const Center(
                    child: Text('Henüz hastalık kaydı bulunmuyor'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: kayitlar.length,
                  itemBuilder: (context, index) {
                    final kayit = kayitlar[index];
                    final devamEdiyor = kayit.bitisTarihi == null;

                    return Card(
                      color: devamEdiyor ? Colors.red.shade50 : null,
                      child: ListTile(
                        title: Text(kayit.hastalikAdi),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Başlangıç: ${DateFormat('dd.MM.yyyy').format(kayit.baslangicTarihi)}'),
                            if (kayit.bitisTarihi != null)
                              Text('Bitiş: ${DateFormat('dd.MM.yyyy').format(kayit.bitisTarihi!)}')
                            else
                              const Text('Devam Ediyor', style: TextStyle(color: Colors.red)),
                            Text('Tedavi: ${kayit.tedaviDetaylari}'),
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
                                content: const Text('Bu hastalık kaydını silmek istediğinizden emin misiniz?'),
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
                                await viewModel.hastalikKaydiSil(kayit.id, kayit.petId);
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
        onPressed: _showHastalikKaydiDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 