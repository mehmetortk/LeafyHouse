import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception("Görsel seçilirken bir hata oluştu: $e");
    }
  }

  Future<String> saveImageToLocalStorage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final plantImageDir = await Directory('${directory.path}/plant_images')
          .create(recursive: true);

      final fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
      final localImagePath = '${plantImageDir.path}/$fileName';

      await imageFile.copy(localImagePath);

      return localImagePath;
    } catch (e) {
      throw Exception("Görsel yerel depolamaya kaydedilemedi: $e");
    }
  }

  Future<void> deleteLocalImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception("Görsel silinirken bir hata oluştu: $e");
    }
  }
}
