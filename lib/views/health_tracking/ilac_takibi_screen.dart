import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pet_model.dart';
import '../../models/health_tracking_model.dart';
import '../../viewmodels/health_tracking_viewmodel.dart';

class IlacTakibiScreen extends StatefulWidget {
  final Pet pet;

  const IlacTakibiScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<IlacTakibiScreen> createState() => _IlacTakibiScreenState();
}

class _IlacTakibiScreenState extends State<IlacTakibiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ilacAdiController = TextEditingController();
  final _dozajController = TextEditingController();
  final _kullanimSikligiController = TextEditingController();
  final _notlarController = TextEditingController();
  DateTime _baslangicTarihi = DateTime.now();
  DateTime? _bitisTarihi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ilacKayitlariniYukle();
  }

  @override
  void dispose() {
    _ilacAdiController.dispose();
    _dozajController.dispose();
    _kullanimSikligiController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _ilacKayitlariniYukle() async {
    setState(() => _isLoading = true);
    try {
      final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
      await viewModel.ilacKayitlariniYukle(widget.pet.ad);
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

  Future<void> _ilacKaydiEkle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
        await viewModel.ilacKaydiEkle(
          widget.pet.ad,
          _ilacAdiController.text,
          _baslangicTarihi,
          _bitisTarihi,
          _dozajController.text,
          _kullanimSikligiController.text,
          _notlarController.text.isEmpty ? null : _notlarController.text,
        );

        if (mounted) {
          _ilacAdiController.clear();
          _dozajController.clear();
          _kullanimSikligiController.clear();
          _notlarController.clear();
          _baslangicTarihi = DateTime.now();
          _bitisTarihi = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İlaç kaydı başarıyla eklendi')),
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

  void _showIlacKaydiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni İlaç Kaydı'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _ilacAdiController,
                    decoration: const InputDecoration(labelText: 'İlaç Adı'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen ilaç adını girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dozajController,
                    decoration: const InputDecoration(labelText: 'Dozaj'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen dozaj bilgisini girin';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _kullanimSikligiController,
                    decoration: const InputDecoration(labelText: 'Kullanım Sıklığı'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen kullanım sıklığını girin';
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
                await _ilacKaydiEkle();
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
                final kayitlar = viewModel.ilacKayitlari;
                if (kayitlar.isEmpty) {
                  return const Center(
                    child: Text('Henüz ilaç kaydı bulunmuyor'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: kayitlar.length,
                  itemBuilder: (context, index) {
                    final kayit = kayitlar[index];
                    final devamEdiyor = kayit.bitisTarihi == null;

                    return Card(
                      color: devamEdiyor ? Colors.green.shade50 : null,
                      child: ListTile(
                        title: Text(kayit.ilacAdi),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dozaj: ${kayit.dozaj}'),
                            Text('Kullanım Sıklığı: ${kayit.kullanimSikligi}'),
                            Text('Başlangıç: ${DateFormat('dd.MM.yyyy').format(kayit.baslangicTarihi)}'),
                            if (kayit.bitisTarihi != null)
                              Text('Bitiş: ${DateFormat('dd.MM.yyyy').format(kayit.bitisTarihi!)}')
                            else
                              const Text('Devam Ediyor', style: TextStyle(color: Colors.green)),
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
                                content: const Text('Bu ilaç kaydını silmek istediğinizden emin misiniz?'),
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
                                await viewModel.ilacKaydiSil(kayit.id, kayit.petId);
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
        onPressed: _showIlacKaydiDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 