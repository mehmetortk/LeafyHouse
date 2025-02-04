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
  File? imageFile;
  
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bitkilerim",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? 
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/addPlant');
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Ekle",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.green.shade700 : Colors.green,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark 
            ? BorderSide.none 
            : const BorderSide(color: Colors.green, width: 1.5),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: _buildPlantImage(plant.imageUrl),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          plant.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.green[900],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "Tür: ${plant.type}",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ),
        trailing: FittedBox(
          child: Row(
            children: [
              IconButton(
                tooltip: "Ayarlar",
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Theme.of(context).colorScheme.secondary : Colors.green,
                ),
                onPressed: () async {
                  ref.read(automationProvider.notifier).clearSettings();
                  await Navigator.pushNamed(
                    context,
                    '/automation',
                    arguments: plant,
                  ).then((_) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      ref.read(plantsProvider.notifier).loadPlants(user.uid);
                    }
                  });
                },
              ),
              IconButton(
                tooltip: "Düzenle",
                icon: Icon(
                  Icons.edit,
                  color: isDark ? Theme.of(context).colorScheme.secondary : Colors.green[700],
                ),
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

  Future<void> _showDeleteConfirmationDialog(String plantId, Plant plant) async {
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
