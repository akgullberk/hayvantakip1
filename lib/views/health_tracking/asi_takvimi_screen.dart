import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pet_model.dart';
import '../../models/health_tracking_model.dart';
import '../../viewmodels/health_tracking_viewmodel.dart';

class AsiTakvimiScreen extends StatefulWidget {
  final Pet pet;

  const AsiTakvimiScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<AsiTakvimiScreen> createState() => _AsiTakvimiScreenState();
}

class _AsiTakvimiScreenState extends State<AsiTakvimiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _asiAdiController = TextEditingController();
  final _notlarController = TextEditingController();
  DateTime _yapilmaTarihi = DateTime.now();
  DateTime? _tekrarTarihi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _asiKayitlariniYukle();
  }

  @override
  void dispose() {
    _asiAdiController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _asiKayitlariniYukle() async {
    setState(() => _isLoading = true);
    try {
      final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
      await viewModel.asiKayitlariniYukle(widget.pet.ad);
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

  Future<void> _asiKaydiEkle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final viewModel = Provider.of<HealthTrackingViewModel>(context, listen: false);
        await viewModel.asiKaydiEkle(
          widget.pet.ad,
          _asiAdiController.text,
          _yapilmaTarihi,
          _tekrarTarihi,
          _notlarController.text.isEmpty ? null : _notlarController.text,
        );

        if (mounted) {
          _asiAdiController.clear();
          _notlarController.clear();
          _yapilmaTarihi = DateTime.now();
          _tekrarTarihi = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aşı kaydı başarıyla eklendi')),
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

  Future<void> _selectDate(BuildContext context, bool isTekrarTarihi) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTekrarTarihi ? (_tekrarTarihi ?? DateTime.now()) : _yapilmaTarihi,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isTekrarTarihi) {
          _tekrarTarihi = picked;
        } else {
          _yapilmaTarihi = picked;
        }
      });
    }
  }

  void _showAsiKaydiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Aşı Kaydı'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _asiAdiController,
                    decoration: const InputDecoration(labelText: 'Aşı Adı'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen aşı adını girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Yapılma Tarihi'),
                    subtitle: Text(DateFormat('dd.MM.yyyy').format(_yapilmaTarihi)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                  ListTile(
                    title: const Text('Tekrar Tarihi (Opsiyonel)'),
                    subtitle: Text(_tekrarTarihi != null
                        ? DateFormat('dd.MM.yyyy').format(_tekrarTarihi!)
                        : 'Seçilmedi'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, true),
                        ),
                        if (_tekrarTarihi != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _tekrarTarihi = null);
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
                await _asiKaydiEkle();
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
                final kayitlar = viewModel.asiKayitlari;
                if (kayitlar.isEmpty) {
                  return const Center(
                    child: Text('Henüz aşı kaydı bulunmuyor'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: kayitlar.length,
                  itemBuilder: (context, index) {
                    final kayit = kayitlar[index];
                    final tekrarTarihiYaklasiyor = kayit.tekrarTarihi != null &&
                        kayit.tekrarTarihi!.difference(DateTime.now()).inDays <= 30 &&
                        kayit.tekrarTarihi!.isAfter(DateTime.now());

                    return Card(
                      color: tekrarTarihiYaklasiyor ? Colors.amber.shade100 : null,
                      child: ListTile(
                        title: Text(kayit.asiAdi),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Yapılma Tarihi: ${DateFormat('dd.MM.yyyy').format(kayit.yapilmaTarihi)}'),
                            if (kayit.tekrarTarihi != null)
                              Text(
                                'Tekrar Tarihi: ${DateFormat('dd.MM.yyyy').format(kayit.tekrarTarihi!)}',
                                style: TextStyle(
                                  color: tekrarTarihiYaklasiyor ? Colors.red : null,
                                  fontWeight: tekrarTarihiYaklasiyor ? FontWeight.bold : null,
                                ),
                              ),
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
                                content: const Text('Bu aşı kaydını silmek istediğinizden emin misiniz?'),
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
                                await viewModel.asiKaydiSil(kayit.id, kayit.petId);
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
        onPressed: _showAsiKaydiDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 