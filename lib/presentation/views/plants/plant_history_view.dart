import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
    final historyRef = FirebaseDatabase.instance.ref().child('plant_history');
    final snapshot = await historyRef.orderByChild('date').once();

    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> tempImages = [];

      data.forEach((key, value) {
        tempImages.add({
          'url': value['imageUrl'],
          'label': value['label'],
          'date': DateTime.parse(value['date']),
        });
      });

      tempImages.sort((a, b) => b['date'].compareTo(a['date'])); // En güncelden en eskiye sıralama

      setState(() {
        images = tempImages.take(8).toList(); // Son 8 görseli al
      });
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.all(20),
              child: Image.network(imageUrl, fit: BoxFit.fill),
            ),
          ),
        );
      },
    );
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
                  leading: GestureDetector(
                    onTap: () {
                      _showImageDialog(image['url']);
                    },
                    child: Image.network(
                      image['url'],
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      fit: BoxFit.fill,
                    ),
                  ),
                  title: Text(image['label']),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(image['date'])),
                );
              },
            ),
    );
  }
}