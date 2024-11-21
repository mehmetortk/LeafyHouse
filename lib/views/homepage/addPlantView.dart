import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/plant.dart'; // Add this line

class AddPlantView extends StatefulWidget {
  @override
  _AddPlantViewState createState() => _AddPlantViewState();
}

class _AddPlantViewState extends State<AddPlantView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  void savePlant() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final plant = Plant(
    userId: userId,
    name: nameController.text,
    type: typeController.text,
    moisture: 0,
    health: 'Sağlıklı',
  );
  Navigator.pop(context, plant); // Return the Plant object
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
