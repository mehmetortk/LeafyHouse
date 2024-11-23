import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/plant.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddPlantView extends StatefulWidget {
  @override
  _AddPlantViewState createState() => _AddPlantViewState();
}

class _AddPlantViewState extends State<AddPlantView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Kamera veya galeriden fotoğraf seçme
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Görsel seçilirken bir hata oluştu.")),
      );
    }
  }
Future<String> _saveImageToLocalStorage(File imageFile) async {
  try {
    // Uygulamanın belgeler dizinini alın
    final directory = await getApplicationDocumentsDirectory();

    // Dosya adını oluştur
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.png";

    // Hedef dosya yolunu oluştur
    final localImagePath = '${directory.path}/$fileName';

    // Görseli hedef konuma kopyalayın
    final savedImage = await imageFile.copy(localImagePath);

    return savedImage.path; // Kaydedilen dosyanın yerel yolu
  } catch (e) {
    throw Exception("Görsel yerel depolamaya kaydedilemedi: $e");
  }
}
  // Görsel Firebase Storage'a Yükleme
  Future<String> _uploadImageToStorage() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final plantName = nameController.text.isNotEmpty
        ? nameController.text.replaceAll(RegExp(r'[^\w\s]+'), '_')
        : 'default_plant';

    final fileName =
        "$userId/${plantName}_${DateTime.now().millisecondsSinceEpoch}";
    final storageRef =
        FirebaseStorage.instance.ref().child("plant_images/$fileName");

    try {
      // Yükleme işlemini başlatıyoruz
      final uploadTask = storageRef.putFile(_imageFile!);

      // Yükleme işleminin tamamlanmasını bekliyoruz
      final snapshot = await uploadTask;

      // Yükleme başarılıysa indirme URL'sini alıyoruz
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      // Firebase'e özgü hataları yakalıyoruz
      throw Exception("Görsel yüklenemedi: ${e.message}");
    } catch (e) {
      // Diğer hataları yakalıyoruz
      throw Exception("Görsel yüklenemedi: $e");
    }
  }

  // Bitki Kaydetme İşlemi
  void savePlant() async {
    if (nameController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen bir isim ve görsel seçiniz.")),
      );
      return;
    }

    try {
      // Görseli yerel depolamaya kaydedin
      final localImagePath = await _saveImageToLocalStorage(_imageFile!);

      // Plant modelini oluştur
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final plant = Plant(
        id: '',
        userId: userId,
        name: nameController.text,
        type: typeController.text,
        moisture: 0,
        health: 'Sağlıklı',
        imageUrl: localImagePath, // Yerel dosya yolu
      );

      Navigator.pop(context, plant); // Bitkiyi geri gönder
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitki kaydedilirken bir hata oluştu: $e")),
      );
    }
  }

  // Kamera veya galeri seçimi için modal bottom sheet
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Fotoğraf Çek"),
                onTap: () {
                  Navigator.pop(context); // Modal bottom sheet'i kapat
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Galeriden Seç"),
                onTap: () {
                  Navigator.pop(context); // Modal bottom sheet'i kapat
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yeni Bitki Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Bitki Adı"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: "Bitki Türü"),
            ),
            SizedBox(height: 10),
            _imageFile == null
                ? Text("Görsel seçilmedi.")
                : Image.file(
                    _imageFile!,
                    height: 150,
                    width: 150,
                  ),
            ElevatedButton(
              onPressed: _showImageSourceOptions,
              child: Text("Görsel Ekle"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePlant,
              child: Text("Bitkiyi Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
