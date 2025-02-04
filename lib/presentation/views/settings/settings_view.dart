// lib/views/settings/settings_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_models/auth_notifier.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantTypesView()),
              );
            },
          ),
        ],
      ),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Account info card (placeholder for additional info if needed)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.account_circle, size: 40, color: Colors.green),
                      title: const Text(
                        "Hesabım",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Email: ${authState.user?.email ?? 'Bilinmiyor'}"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Logout Button Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red, size: 32),
                      title: const Text(
                        "Çıkış Yap",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("remember_me", false);
                        await authNotifier.logout();

                        if (authState.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Çıkış Yapılırken Hata Oluştu: ${authState.errorMessage}",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Başarıyla Çıkış Yapıldı"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class PlantTypesView extends StatelessWidget {
  const PlantTypesView({super.key});

  @override
  Widget build(BuildContext context) {
    // List of plant types supported by the model
    final plantTypes = <String>[
      'aloe_vera',
      'boston_fern',
      'chinese_money_plant',
      'dracaena',
      'jade_plant',
      'monstera_deliciosa',
      'peace_lily',
      'rubber_plant',
      'snake_plant',
    ]..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bitki Türleri"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card with gradient background
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                ),
                child: const Text(
                  "Uygulamadaki Modelin Desteklediği Bitki Türleri",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // List of Plant Types with tap navigation to details
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemCount: plantTypes.length,
                itemBuilder: (context, index) {
                  final type = plantTypes[index];
                  final displayType = type
                      .split('_')
                      .map((word) =>
                          word[0].toUpperCase() + word.substring(1).toLowerCase())
                      .join(' ');
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.nature, color: Colors.green),
                      title: Text(
                        displayType,
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlantTypeDetailView(plantType: type),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantTypeDetailView extends StatelessWidget {
  final String plantType;
  const PlantTypeDetailView({super.key, required this.plantType});

  // Returns sample details for the given plantType
  Map<String, String> getPlantDetails() {
    final details = <String, Map<String, String>>{
      'aloe_vera': {
        'Özellikler': "Etli yapraklar, hızlı çoğalma.",
        'Nem Koşulları': "Düşük nem, kuru ortam tercih eder.",
        'Bakım': "Az sulama, doğrudan güneş ışığından uzak tutunuz."
      },
      'boston_fern': {
        'Özellikler': "Yeşil, tüylü yapraklar.",
        'Nem Koşulları': "Yüksek nem ortam, parlatılmış hava.",
        'Bakım': "Sık sulama, dolaylı ışık idealdir."
      },
      'chinese_money_plant': {
        'Özellikler': "Yuvarlak yapraklar, parlak görünüm.",
        'Nem Koşulları': "Orta düzey nem idealdir.",
        'Bakım': "Düzenli sulama ve aralıklı gübreleme önerilir."
      },
      'dracaena': {
        'Özellikler': "Uzun yapraklar, hoş siluet.",
        'Nem Koşulları': "Düşük ila orta nem gerektirir.",
        'Bakım': "Doğrudan güneş ışığından kaçının, aralıklı sulama yapın."
      },
      'jade_plant': {
        'Özellikler': "Kalın yapraklı, sağlam gövde.",
        'Nem Koşulları': "Kuru ortam, düşük nem tercih eder.",
        'Bakım': "Nadiren sulayın, bolton güneş ışığı almasını sağlayın."
      },
      'monstera_deliciosa': {
        'Özellikler': "Delikli büyük yapraklar.",
        'Nem Koşulları': "Orta ila yüksek nem ortamı idealdir.",
        'Bakım': "Düzenli sulama ve yüksek nem önerilir."
      },
      'peace_lily': {
        'Özellikler': "Sade ve zarif çiçekler.",
        'Nem Koşulları': "Yüksek nem, serin ortam uygun.",
        'Bakım': "Toprağı sürekli nemli tutun, direkt güneş ışığından kaçının."
      },
      'rubber_plant': {
        'Özellikler': "Kalın ve parlak yapraklar.",
        'Nem Koşulları': "Orta nemde gelişir.",
        'Bakım': "Doğrudan güneş ışığından uzak, düzenli sulama yapın."
      },
      'snake_plant': {
        'Özellikler': "Dikey, uzun yapraklar.",
        'Nem Koşulları': "Düşük nem, kuru koşulları sever.",
        'Bakım': "Az sulama, doğrudan ışık yerine loş ortam idealdir."
      },
    };
    return details[plantType] ?? {
      'Özellikler': "Bilgi mevcut değil.",
      'Nem Koşulları': "Bilgi mevcut değil.",
      'Bakım': "Bilgi mevcut değil."
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayType = plantType
        .split('_')
        .map((word) =>
            word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
    final info = getPlantDetails();
    return Scaffold(
      appBar: AppBar(
        title: Text(displayType),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient background
            const SizedBox(height: 20),
            // Details Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Spesifik Özellikler",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info['Özellikler']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(height: 30),
                      Text(
                        "Sevdikleri Nem Koşulları",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info['Nem Koşulları']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(height: 30),
                      Text(
                        "Bakım İpuçları",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info['Bakım']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
