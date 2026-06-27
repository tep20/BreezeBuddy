import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class JurnalScreen extends StatefulWidget {
  @override
  _JurnalScreenState createState() => _JurnalScreenState();
}

class _JurnalScreenState extends State<JurnalScreen> {
  List<Map<String, dynamic>> jurnalList = [];
  final TextEditingController inputController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final data = await DBHelper.getData();
      if (mounted) {
        setState(() {
          jurnalList = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat jurnal: $e')));
      }
    }
  }

  Future<void> simpanData(int? id) async {
    final aktivitas = inputController.text.trim();
    if (aktivitas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama aktivitas tidak boleh kosong.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      isSubmitting = true;
    });

    try {
      if (id == null) {
        await DBHelper.insert({
          'aktivitas': aktivitas,
          'tanggal': DateTime.now().toString().split(' ')[0],
          'cuaca': 'Cerah',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aktivitas berhasil disimpan!')),
          );
        }
      } else {
        await DBHelper.update({
          'id': id,
          'aktivitas': aktivitas,
          'tanggal': DateTime.now().toString().split(' ')[0],
          'cuaca': 'Cerah',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aktivitas berhasil diperbarui!')),
          );
        }
      }

      if (mounted) {
        inputController.clear();
        Navigator.of(context).pop();
        await loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void tampilkanForm(int? id, String? teksLama) {
    if (id != null) {
      inputController.text = teksLama ?? '';
    } else {
      inputController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Catat Aktivitas Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: inputController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Aktivitas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isSubmitting ? null : () => simpanData(id),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jurnal?'),
        content: const Text('Tindakan ini menghapus data secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await DBHelper.delete(id);
                if (mounted) {
                  Navigator.pop(context);
                  await loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus data: $e')),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Daily Journal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: jurnalList.isEmpty
            ? const Center(
                child: Text('Belum ada aktivitas. Tekan + untuk menambah.'),
              )
            : ListView.builder(
                itemCount: jurnalList.length,
                itemBuilder: (context, index) {
                  var item = jurnalList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(
                          Icons.directions_run,
                          color: Colors.teal,
                        ),
                      ),
                      title: Text(item['aktivitas']),
                      subtitle: Text(item['tanggal']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                tampilkanForm(item['id'], item['aktivitas']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => konfirmasiHapus(item['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => tampilkanForm(null, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
