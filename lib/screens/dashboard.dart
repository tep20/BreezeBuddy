import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String suhu = "Memuat...";
  String kondisi = "-";
  String saran = "Mencari data cuaca...";

  @override
  void initState() {
    super.initState();
    fetchCuaca();
  }

  Future<void> fetchCuaca() async {
    String apiKey = "28c1ea6e639f9a9d385b010f051c0adc";
    String url =
        "https://api.openweathermap.org/data/2.5/weather?q=Tangerang Selatan&units=metric&appid=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          suhu = "${data['main']['temp']}°C";
          kondisi = data['weather'][0]['main'];
          saran = kondisi.toLowerCase().contains('rain')
              ? "Bawa jas hujan untuk perjalananmu."
              : "Cuaca bagus untuk aktivitas luar.";
        });
      } else {
        setState(() {
          suhu = "Tidak tersedia";
          kondisi = "-";
          saran = "Coba lagi nanti.";
        });
      }
    } catch (_) {
      setState(() {
        suhu = "Gagal";
        kondisi = "Error";
        saran = "Periksa koneksi internetmu.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hariIni = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome back, Tito!'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hariIni,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        suhu,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(kondisi, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal.shade100,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const Icon(
                      Icons.cloud,
                      size: 56,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insight Cuaca',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      saran,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: Colors.teal),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Sesi harian yang tenang membuat mood lebih stabil dan membantu menjaga fokus.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
