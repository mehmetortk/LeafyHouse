import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/plants_notifier.dart';
import '../../view_models/automation_notifier.dart';
import '../../../domain/entities/plant.dart';
import '../../../domain/entities/automation_settings.dart';
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
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmationDialog(plant.id, plant);
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/plantInfoDetails',
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

  Future<void> _showDeleteConfirmationDialog(
      String plantId, Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: const Text('Are you sure you want to delete this plant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(plantsProvider.notifier).removePlant(plantId, plant);

        if (mounted) {
          showSuccessMessage(context, 'Plant deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting plant: $e')),
          );
        }
      }
    }
  }
}
