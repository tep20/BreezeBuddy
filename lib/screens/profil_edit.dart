import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});
  @override
  _EditProfilScreenState createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final nameCtrl = TextEditingController();
  final umurCtrl = TextEditingController();
  final kerjaCtrl = TextEditingController();
  final lokasiCtrl = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _getLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    List<Placemark> p = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    setState(() => lokasiCtrl.text = "${p[0].subAdministrativeArea}, ${p[0].country}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(padding: const EdgeInsets.all(20), child: ListView(children: [
        Center(child: GestureDetector(onTap: _pickImage, child: CircleAvatar(radius: 50, backgroundImage: _image != null ? FileImage(_image!) : null, child: _image == null ? const Icon(Icons.camera_alt) : null))),
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nama")),
        TextField(controller: umurCtrl, decoration: const InputDecoration(labelText: "Umur")),
        TextField(controller: kerjaCtrl, decoration: const InputDecoration(labelText: "Pekerjaan")),
        TextField(controller: lokasiCtrl, decoration: InputDecoration(labelText: "Tempat Tinggal", suffixIcon: IconButton(icon: const Icon(Icons.map), onPressed: _getLocation))),
        const SizedBox(height: 20),
        FilledButton(onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', nameCtrl.text);
          if(_image != null) await prefs.setString('profile_image', _image!.path);
          Navigator.pop(context);
        }, child: const Text("Simpan"))
      ])),
    );
  }
}