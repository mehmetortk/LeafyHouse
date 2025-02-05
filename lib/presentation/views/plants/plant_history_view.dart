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
  int currentPageIndex = 0;

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
          'key': key,
          'url': value['imageUrl'],
          'label': value['label'],
          'date': DateTime.parse(value['date']),
        });
      });
      // Sort from newest to oldest and take up to 24 images
      tempImages.sort((a, b) => b['date'].compareTo(a['date']));
      setState(() {
        images = tempImages.take(24).toList();
        currentPageIndex = 0;
      });
    }
  }

  Future<void> _deleteImage(dynamic key) async {
    final historyRef = FirebaseDatabase.instance.ref().child('plant_history');
    await historyRef.child(key.toString()).remove();
    setState(() {
      images = images.where((img) => img['key'] != key).toList();
    });
  }

  void _showImageDialog(String imageUrl, String label, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isDark
                ? BorderSide.none
                : const BorderSide(color: Colors.green, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                            Theme.of(context).colorScheme.secondary,
                          ]
                        : [
                            Colors.greenAccent[400]!,
                            Colors.green,
                          ],
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
              // Image preview
              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Label content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? Theme.of(context).colorScheme.secondary : Colors.green,
                  ),
                  child: const Text(
                    "Kapat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfoDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isDark
                ? BorderSide.none
                : const BorderSide(color: Colors.green, width: 1),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
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
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.green,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Bu sayfada son 3 günlük görseller bulunmaktadır.",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.greenAccent[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Tamam",
                    style: TextStyle(
                      color: isDark
                          ? Theme.of(context).colorScheme.onSecondary
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int perPage = 8;
    final int totalPages = (images.length / perPage).ceil();
    final int startIndex = currentPageIndex * perPage;
    final int endIndex = min(startIndex + perPage, images.length);
    final currentImages = images.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bitki Geçmişi',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: isDark 
            ? const Color(0xFF1E1E1E)  // Dark mod için koyu gri
            : const Color(0xFF2E7D32), // Light mod için yeşil
        centerTitle: true,
        elevation: isDark ? 0 : 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(isDark),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            color: isDark
                                ? Theme.of(context).colorScheme.error.withOpacity(0.7)
                                : Colors.green.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Icon(
                            Icons.delete,
                            color: isDark
                                ? Theme.of(context).colorScheme.onError
                                : Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (_) {
                          _deleteImage(image['key']);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isDark
                                ? BorderSide.none
                                : const BorderSide(color: Colors.green, width: 1),
                          ),
                          color: isDark ? null : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: SizedBox(
                              width: 60,
                              height: 60,
                              child: GestureDetector(
                                onTap: () {
                                  _showImageDialog(image['url'], image['label'], isDark);
                                },
                                child: Hero(
                                  tag: image['key'],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      image['url'],
                                      width: 60, // sabit genişlik
                                      height: 60, // sabit yükseklik
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () {
                                _showImageDialog(image['url'], image['label'], isDark);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  image['label'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.green,
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black54,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                                : Colors.greenAccent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Sayfa ${currentPageIndex + 1} / $totalPages',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.green,
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