import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class PlantHistoryView extends StatefulWidget {
  final String plantId;

  const PlantHistoryView({Key? key, required this.plantId}) : super(key: key);

  @override
  _PlantHistoryViewState createState() => _PlantHistoryViewState();
}

class _PlantHistoryViewState extends State<PlantHistoryView> {
  List<Map<String, dynamic>> images = [];

  @override
  void initState() {
    super.initState();
    _fetchPlantHistory();
  }

  Future<void> _fetchPlantHistory() async {
    final storageRef = FirebaseStorage.instance.ref().child('images/');
    final listResult = await storageRef.listAll();
    final allFiles = listResult.items;

    List<Map<String, dynamic>> tempImages = [];

    for (var item in allFiles) {
      final metadata = await item.getMetadata();
      final imageUrl = await item.getDownloadURL();
      final label = await _classifyImage(imageUrl); // Model değerlendirme sonucu
      tempImages.add({
        'url': imageUrl,
        'label': label,
        'date': metadata.timeCreated,
      });
    }

    tempImages.sort((a, b) => b['date'].compareTo(a['date'])); // En güncelden en eskiye sıralama

    setState(() {
      images = tempImages.take(8).toList(); // Son 8 görseli al
    });
  }

  Future<String> _classifyImage(String imageUrl) async {
    // Görseli sınıflandırma işlemi burada yapılacak
    // Bu örnekte sadece bir placeholder döndürüyoruz
    return 'Model Değerlendirme Sonucu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitki Geçmişi'),
      ),
      body: images.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return ListTile(
                  leading: Image.network(image['url']),
                  title: Text(image['label']),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(image['date'])),
                );
              },
            ),
    );
  }
}