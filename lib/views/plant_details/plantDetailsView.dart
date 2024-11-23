import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../viewmodels/plants_viewmodel.dart';
import 'package:provider/provider.dart';

class PlantDetailView extends StatefulWidget {
  @override
  _PlantDetailViewState createState() => _PlantDetailViewState();
}

class _PlantDetailViewState extends State<PlantDetailView> {
  late TextEditingController nameController;
  late TextEditingController typeController;
  late Plant plant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    plant = ModalRoute.of(context)!.settings.arguments as Plant;
    nameController = TextEditingController(text: plant.name);
    typeController = TextEditingController(text: plant.type);
  }

  void saveChanges() {
    final updatedPlant = Plant(
      id: plant.id,
      userId: plant.userId,
      name: nameController.text,
      type: typeController.text,
      moisture: plant.moisture,
      health: plant.health,
      imageUrl: plant.imageUrl,
    );

    Provider.of<PlantsViewModel>(context, listen: false).updatePlant(updatedPlant);
    Navigator.pop(context, updatedPlant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${plant.name} Detayları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: Text("Değişiklikleri Kaydet"),
            ),
            SizedBox(height: 20),
            Text(
              "Nem Oranı: ${plant.moisture}%",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Sağlık Durumu: ${plant.health}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/automation',
                  arguments: plant,
                );
              },
              child: Text("Otomasyon Ayarları"),
            ),
          ],
        ),
      ),
    );
  }
}
