import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/plants_notifier.dart';
import '../../../domain/entities/plant.dart';
import '../../../core/utils/ui_helpers.dart';

class PlantsView extends ConsumerStatefulWidget {
  const PlantsView({super.key});

  @override
  _PlantsViewState createState() => _PlantsViewState();
}

class _PlantsViewState extends ConsumerState<PlantsView> {
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Delay the call to loadPlants
      Future.microtask(() {
        ref.read(plantsProvider.notifier).loadPlants(user.uid);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantsState = ref.watch(plantsProvider);
    final notifier = ref.read(plantsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bitkilerim"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newPlant = await Navigator.pushNamed(context, '/addPlant');
              if (newPlant != null && newPlant is Plant) {
                await notifier.addPlant(newPlant);
                showSuccessMessage(
                    context, "${newPlant.name} başarıyla eklendi.");
              }
            },
          ),
        ],
      ),
      body: _buildBody(context, plantsState, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PlantsState plantsState,
    PlantsNotifier notifier,
  ) {
    if (plantsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (plantsState.errorMessage != null) {
      return Center(child: Text("Hata: ${plantsState.errorMessage}"));
    }

    if (plantsState.plants.isEmpty) {
      return const Center(child: Text("Henüz bir bitkiniz yok."));
    }

    return ListView.builder(
      itemCount: plantsState.plants.length,
      itemBuilder: (context, index) {
        final plant = plantsState.plants[index];
        return _buildPlantTile(context, plant, notifier);
      },
    );
  }

  Widget _buildPlantTile(
    BuildContext context,
    Plant plant,
    PlantsNotifier notifier,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: _buildPlantImage(plant.imageUrl),
        radius: 30,
      ),
      title: Text(plant.name),
      subtitle: Text("Tür: ${plant.type}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final updatedPlant = await Navigator.pushNamed(
                context,
                '/plantDetail',
                arguments: plant,
              );
              if (updatedPlant != null && updatedPlant is Plant) {
                await notifier.updatePlant(updatedPlant);
                showSuccessMessage(
                  context,
                  "${updatedPlant.name} başarıyla güncellendi.",
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmationDialog(context, plant, notifier);
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
  }

  ImageProvider _buildPlantImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return FileImage(File(imageUrl));
    }
    return const AssetImage('assets/images/app_logo.png');
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Plant plant,
    PlantsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Silme Onayı"),
          content: const Text("Bu bitkiyi silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dialog'u kapat
                await notifier.deletePlant(plant.id);
                showSuccessMessage(context, "${plant.name} başarıyla silindi.");
              },
              child: const Text("Evet"),
            ),
          ],
        );
      },
    );
  }
}
