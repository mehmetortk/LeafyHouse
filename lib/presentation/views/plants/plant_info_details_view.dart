import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/plant.dart';

class PlantInfoDetailsView extends ConsumerStatefulWidget {
  const PlantInfoDetailsView({Key? key}) : super(key: key);

  @override
  _PlantInfoDetailsViewState createState() => _PlantInfoDetailsViewState();
}

class _PlantInfoDetailsViewState extends ConsumerState<PlantInfoDetailsView> {
  Plant? plant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the Plant object from the navigation arguments
    plant = ModalRoute.of(context)?.settings.arguments as Plant?;
  }

  @override
  Widget build(BuildContext context) {
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Plant Details'),
        ),
        body: Center(
          child: Text('Plant data not available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant!.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: plant!.imageUrl.isNotEmpty
                      ? Image.file(
                          File(plant!.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : Placeholder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Display plant name
            Text(
              plant!.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Display plant type
            Text(
              'Tür: ${plant!.type}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            // Display other plant details
            Text('Nem Oranı: ${plant!.moisture}'),
            Text('Sağlık Durumu: ${plant!.health}'),
            // Add more fields as necessary
          ],
        ),
      ),
    );
  }
}
