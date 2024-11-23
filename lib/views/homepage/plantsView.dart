import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/plants_viewmodel.dart';
import '../../models/plant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class PlantsView extends StatefulWidget {
  @override
  _PlantsViewState createState() => _PlantsViewState();
}

class _PlantsViewState extends State<PlantsView> {
  late PlantsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _viewModel = Provider.of<PlantsViewModel>(context, listen: false);
    _viewModel.fetchPlants(userId); // Kullanıcıya özel bitkileri getir
  }

  Future<void> _deleteLocalImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print("Yerel görsel silindi: $imagePath");
      }
    } catch (e) {
      print("Görsel silinirken bir hata oluştu: $e");
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Silme Onayı"),
          content: Text("Bu bitkiyi silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dialog'u kapat
                if (plant.id != null) {
                  // Firestore'dan sil
                  _viewModel.deletePlant(plant.id!);

                  // Yerel dosyadan sil
                  await _deleteLocalImage(plant.imageUrl);
                }
              },
              child: Text("Evet"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bitkilerim"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newPlant = await Navigator.pushNamed(context, '/addPlant');
              if (newPlant != null && newPlant is Plant) {
                _viewModel.addPlant(newPlant);
              }
            },
          ),
        ],
      ),
      body: Consumer<PlantsViewModel>(
        builder: (context, viewModel, child) {
          final plants = viewModel.plants;
          if (plants.isEmpty) {
            return Center(child: Text("Henüz bitkiniz yok."));
          }
          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: FileImage(File(plant.imageUrl)),
                  radius: 30,
                ),
                title: Text(plant.name),
                subtitle: Text("Tür: ${plant.type}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final updatedPlant = await Navigator.pushNamed(
                          context,
                          '/plantDetail',
                          arguments: plant,
                        );
                        if (updatedPlant != null) {
                          _viewModel.updatePlant(updatedPlant as Plant);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, plant);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/plantDetail',
                    arguments: plant,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
