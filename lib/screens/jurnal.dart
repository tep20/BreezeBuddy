import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';

class JurnalScreen extends StatefulWidget {
  @override
  _JurnalScreenState createState() => _JurnalScreenState();
}

class _JurnalScreenState extends State<JurnalScreen> {
  List<Map<String, dynamic>> jurnalList = [];
  
  // Controller untuk input aktivitas dan detail
  final TextEditingController aktivitasController = TextEditingController();
  final TextEditingController detailController = TextEditingController(); // Tambahan untuk isi aktivitas
  
  final List<Map<String, dynamic>> kategoriList = [
    {'nama': 'Belajar', 'icon': Icons.school},
    {'nama': 'Bekerja', 'icon': Icons.work},
    {'nama': 'Meeting', 'icon': Icons.groups},
    {'nama': 'Shopping', 'icon': Icons.shopping_cart},
    {'nama': 'Liburan', 'icon': Icons.beach_access},
    {'nama': 'Olahraga', 'icon': Icons.fitness_center},
    {'nama': 'Traveling', 'icon': Icons.flight},
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final data = await DBHelper.getData();
    if (mounted) setState(() => jurnalList = data);
  }

  void _showForm(Map<String, dynamic>? item) {
    aktivitasController.text = item?['aktivitas'] ?? '';
    detailController.text = item?['detail'] ?? ''; // Mengambil isi detail
    String? selectedKategori = item?['kategori'];
    DateTime selectedDate = item != null ? DateTime.parse(item['tanggal']) : DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: aktivitasController, decoration: const InputDecoration(labelText: 'Nama Aktivitas')),
              TextField(controller: detailController, decoration: const InputDecoration(labelText: 'Isi Aktivitas')), // Input isi aktivitas
             DropdownButtonFormField<String>(
  // 1. Tentukan nilai saat ini
  initialValue: selectedKategori, 
  hint: const Text("Pilih Kategori"),
  isExpanded: true,
  
  // 2. Berikan tipe data <String> secara eksplisit
  items: kategoriList.map<DropdownMenuItem<String>>((kat) {
    return DropdownMenuItem<String>(
      value: kat['nama'] as String,
      child: Row(
        children: [
          Icon(kat['icon'] as IconData, size: 20),
          const SizedBox(width: 10),
          Text(kat['nama'] as String),
        ],
      ),
    );
  }).toList(),
  
  // 3. Update state saat kategori dipilih
  onChanged: (val) {
    setModalState(() {
      selectedKategori = val;
    });
  },
  decoration: const InputDecoration(
    labelText: 'Kategori',
    border: OutlineInputBorder(),
  ),
),
              ListTile(
                title: Text("Tanggal Rencana: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  // Validasi: Tidak bisa memilih tanggal masa lalu
                  DateTime? picked = await showDatePicker(
                    context: context, 
                    initialDate: selectedDate, 
                    firstDate: DateTime.now(), // Kunci: Mulai dari hari ini
                    lastDate: DateTime(2100)
                  );
                  if (picked != null) setModalState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  final data = {
                    'aktivitas': aktivitasController.text.trim(),
                    'detail': detailController.text.trim(), // Simpan isi detail
                    'kategori': selectedKategori,
                    'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'cuaca': 'Cerah'
                  };
                  
                  if (item == null) await DBHelper.insert(data);
                  else await DBHelper.update({...data, 'id': item['id']});
                  
                  _refresh();
                  Navigator.pop(context);
                },
                child: const Text('Simpan Aktivitas'),
              )
            ],
          ),
        );
      }),
    );
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Jurnal Saya')),
    body: ListView.builder(
      itemCount: jurnalList.length,
      itemBuilder: (context, i) {
        final item = jurnalList[i];
        final kategori = kategoriList.firstWhere(
            (k) => k['nama'] == item['kategori'], 
            orElse: () => {'icon': Icons.event}
        );
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade50,
              child: Icon(kategori['icon'], color: Colors.teal),
            ),
            title: Text(item['aktivitas'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['tanggal']} - ${item['kategori']}"),
                const SizedBox(height: 4),
                Text(item['detail'] ?? "Tidak ada deskripsi", maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => DBHelper.delete(item['id']).then((_) => _refresh()),
            ),
            onTap: () => _showForm(item), // Klik untuk buka edit/lihat
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showForm(null), 
      child: const Icon(Icons.add)
    ),
  );
}
}