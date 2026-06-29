import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../widgets/custom_widgets.dart';

class OceanSoundPlayerScreen extends StatefulWidget {
  const OceanSoundPlayerScreen({super.key});

  @override
  State<OceanSoundPlayerScreen> createState() => _OceanSoundPlayerScreenState();
}

class _OceanSoundPlayerScreenState extends State<OceanSoundPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final List<Map<String, String>> _playlist = [
    {
      "title": "Relaxing Ocean Waves",
      "artist": "Nature Sound",
      "file": "audio/Relaxing Music with Ocean Waves.mp3",
    },
    {
      "title": "Starry Night Calm",
      "artist": "Ambient Sleep",
      "file": "audio/Starry night Calming Music & Soothing Sounds for Stress Relief & Focus.mp3",
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Memuat lagu pertama secara otomatis saat layar terbuka
    _loadAndPlay(_currentIndex);
    
    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));
    _audioPlayer.onPlayerComplete.listen((_) => setState(() => _isPlaying = false));
  }

  Future<void> _loadAndPlay(int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.setSource(AssetSource(_playlist[index]['file']!));
    setState(() {
      _currentIndex = index;
      _isPlaying = true;
    });
    await _audioPlayer.resume();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) => "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F2),
      appBar: AppBar(
        title: Text("Now Playing", style: GoogleFonts.poppins(color: Colors.teal, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Menggunakan scroll agar tidak overflow
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              GlassCard(
                child: Container(
                  height: 200, width: double.infinity,
                  decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/logo.jpg'), fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 20),
              Text(_playlist[_currentIndex]['title']!, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              
              SizedBox(height: 50, child: _WaveformPainter(isPlaying: _isPlaying)),
              
              Slider(
                value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                max: _duration.inSeconds.toDouble() <= 0 ? 1 : _duration.inSeconds.toDouble(),
                activeColor: Colors.teal,
                onChanged: (val) async => await _audioPlayer.seek(Duration(seconds: val.toInt())),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () => _loadAndPlay((_currentIndex - 1) % _playlist.length), icon: const Icon(Icons.skip_previous, size: 40, color: Colors.teal)),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.resume();
                      setState(() => _isPlaying = !_isPlaying);
                    },
                    child: Container(padding: const EdgeInsets.all(15), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.teal), child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  IconButton(onPressed: () => _loadAndPlay((_currentIndex + 1) % _playlist.length), icon: const Icon(Icons.skip_next, size: 40, color: Colors.teal)),
                ],
              ),
              const SizedBox(height: 20),
              
              Align(alignment: Alignment.centerLeft, child: Text("Up Next", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              // ListView dalam SingleChildScrollView harus diberi tinggi spesifik atau shrinkWrap
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _playlist.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: NeumorphicContainer(
                    child: ListTile(
                      leading: const Icon(Icons.music_note, color: Colors.teal),
                      title: Text(_playlist[index]['title']!),
                      onTap: () => _loadAndPlay(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends StatelessWidget {
  final bool isPlaying;
  const _WaveformPainter({required this.isPlaying});
  
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(15, (index) => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 4,
      height: isPlaying ? 20 + (sin(index.toDouble()) * 15) : 10,
      decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(2)),
    )),
  );
}