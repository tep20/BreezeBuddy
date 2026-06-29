import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/db_helper.dart';
import '../widgets/custom_widgets.dart';
import 'jurnal.dart';
import 'audio.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _journals = [];
  String suhu = "--";
  String kualitasUdara = "--";
  bool _isLoadingWeather = true; // Indikator loading

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
    _loadData();
    _fetchCuaca();
  }

  void _loadData() async {
    final data = await DBHelper.getData();
    if (mounted) setState(() => _journals = data);
  }

  Future<void> _fetchCuaca() async {
    const String apiKey = "28c1ea6e639f9a9d385b010f051c0adc";
    const String url =
        "https://api.openweathermap.org/data/2.5/weather?q=Jakarta&units=metric&appid=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            suhu = "${(data['main']['temp'] as num).round()}°C";
            kualitasUdara = (data['main']['humidity'] as num) > 80
                ? "Humid"
                : "Good";
            _isLoadingWeather = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingWeather = false);
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  void _showDetailModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['aktivitas'],
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text("Tanggal: ${item['tanggal']}"),
            Text("Kategori: ${item['kategori']}"),
            const SizedBox(height: 10),
            Text("Isi Aktivitas: ${item['detail'] ?? 'Tidak ada deskripsi.'}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back, Tito!",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JurnalScreen()),
                      ),
                      child: NeumorphicContainer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.book, color: Colors.teal),
                            SizedBox(height: 8),
                            Text("Journal"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OceanSoundPlayerScreen(),
                        ),
                      ),
                      child: NeumorphicContainer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.music_note, color: Colors.teal),
                            SizedBox(height: 8),
                            Text("Audio"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                "Today's Insights",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.wb_sunny,
                              color: Colors.amber,
                              size: 30,
                            ),
                            Text(
                              _isLoadingWeather
                                  ? "Loading..."
                                  : "Weather: $suhu",
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            const Icon(Icons.air, color: Colors.blue, size: 30),
                            Text(
                              _isLoadingWeather
                                  ? "..."
                                  : "Quality: $kualitasUdara",
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                "Recent Journal Entries",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _journals.length,
                itemBuilder: (context, index) {
                  final item = _journals[index];
                  final kategori = kategoriList.firstWhere(
                    (k) => k['nama'] == item['kategori'],
                    orElse: () => {'nama': 'Lainnya', 'icon': Icons.event},
                  );

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: NeumorphicContainer(
                      child: ListTile(
                        leading: Icon(
                          kategori['icon'] as IconData,
                          color: Colors.teal,
                        ),
                        title: Text(
                          item['aktivitas'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          item['detail'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _showDetailModal(context, item),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
