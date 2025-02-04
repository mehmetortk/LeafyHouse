import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/plants_notifier.dart';
import '../../view_models/automation_notifier.dart';
import '../../../domain/entities/plant.dart';
import '../../../core/utils/ui_helpers.dart';

class PlantsView extends ConsumerStatefulWidget {
  @override
  _PlantsViewState createState() => _PlantsViewState();
}

class _PlantsViewState extends ConsumerState<PlantsView> {
  File? imageFile; // State'e ekle
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
              await Navigator.pushNamed(context, '/addPlant');
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundImage: _buildPlantImage(plant.imageUrl),
          radius: 30,
        ),
        title: Text(
          plant.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "Tür: ${plant.type}",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        trailing: FittedBox(
          child: Row(
            children: [
              IconButton(
                tooltip: "Ayarlar",
                icon: const Icon(Icons.settings, color: Colors.blueAccent),
                onPressed: () async {
                  // Clear automation settings before navigation
                  ref.read(automationProvider.notifier).clearSettings();
                  await Navigator.pushNamed(
                    context,
                    '/automation',
                    arguments: plant,
                  ).then((_) {
                    // Refresh plants list when returning
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      ref.read(plantsProvider.notifier).loadPlants(user.uid);
                    }
                  });
                },
              ),
              IconButton(
                tooltip: "Düzenle",
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final updatedPlant = await Navigator.pushNamed(
                    context,
                    '/plantEdit',
                    arguments: plant,
                  );
                  if (updatedPlant != null && updatedPlant is Plant) {
                    await notifier.updateExistingPlant(updatedPlant);
                    showSuccessMessage(
                      context,
                      "${updatedPlant.name} başarıyla güncellendi.",
                    );
                  }
                },
              ),
              IconButton(
                tooltip: "Sil",
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmationDialog(plant.id, plant);
                },
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/plantInfoDetails',
            arguments: plant,
          );
        },
      ),
    );
  }

  ImageProvider _buildPlantImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return FileImage(File(imageUrl));
    }
    return const AssetImage('assets/images/app_logo.png');
  }

  Future<void> _showDeleteConfirmationDialog(
      String plantId, Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bitkiyi Sil'),
        content: const Text('Bu bitkiyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(plantsProvider.notifier).removePlant(plantId, plant);

        if (mounted) {
          showSuccessMessage(context, 'Bitki başarı ile silindi.');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bitkiyi silerken hata: $e')),
          );
        }
      }
    }
  }
}
