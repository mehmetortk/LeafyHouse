// lib/widgets/image_picker_widget.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final File? initialImage;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageFile = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        widget.onImageSelected(_imageFile!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Görsel seçilirken bir hata oluştu.")),
      );
    }
  }

  void _showImageOptions() {
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
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Galeriden Seç"),
                onTap: () {
                  Navigator.pop(context);
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
    return GestureDetector(
      onTap: _showImageOptions,
      child: _imageFile == null
          ? CircleAvatar(
              radius: 60,
              child: Icon(Icons.add_a_photo, size: 40),
            )
          : CircleAvatar(
              radius: 60,
              backgroundImage: FileImage(_imageFile!),
            ),
    );
  }
}
