import 'dart:math';
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
  int currentPageIndex = 0; // yeni eklendi

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
          'key': key, // include key for deletion
          'url': value['imageUrl'],
          'label': value['label'],
          'date': DateTime.parse(value['date']),
        });
      });

      // Sort from newest to oldest
      tempImages.sort((a, b) => b['date'].compareTo(a['date']));
      // Take the last 24 images, or fewer if not available
      setState(() {
        images = tempImages.take(24).toList();
        currentPageIndex = 0; // always start at the first page
      });
    }
  }

  // Create a helper to delete an image from Firebase and update the UI
  Future<void> _deleteImage(dynamic key) async {
    final historyRef = FirebaseDatabase.instance.ref().child('plant_history');
    await historyRef.child(key.toString()).remove();
    setState(() {
      images = images.where((img) => img['key'] != key).toList();
    });
  }

  // Updated _showImageDialog method:
  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int perPage = 8;
    final int totalPages = (images.length / perPage).ceil();
    final int startIndex = currentPageIndex * perPage;
    final int endIndex = min(startIndex + perPage, images.length);
    final currentImages = images.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitki Geçmişi'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Bilgi",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Bu sayfada son 3 günlük görseller bulunmaktadır.",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              "Tamam",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: images.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: currentImages.length,
                    itemBuilder: (context, index) {
                      final image = currentImages[index];
                      return Dismissible(
                        key: Key(image['key'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: const Icon(Icons.delete, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) {
                          _deleteImage(image['key']);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: GestureDetector(
                              onTap: () => _showImageDialog(image['url']),
                              child: Hero(
                                tag: image['key'],
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    image['url'],
                                    width: MediaQuery.of(context).size.width / 3.5,
                                    height: MediaQuery.of(context).size.width / 3.5,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Header with gradient background
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.green.shade700, Colors.green],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: const Text(
                                              "Görsel Değerlendirmesi",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          // Message content
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              image['label'],
                                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                                            ),
                                          ),
                                          // Close button
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.green,
                                              ),
                                              child: const Text(
                                                "Kapat",
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  image['label'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(image['date']),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: currentPageIndex > 0
                              ? () {
                                  setState(() {
                                    currentPageIndex--;
                                  });
                                }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Sayfa ${currentPageIndex + 1} / $totalPages',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: currentPageIndex < totalPages - 1
                              ? () {
                                  setState(() {
                                    currentPageIndex++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}