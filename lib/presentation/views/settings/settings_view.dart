// lib/views/settings/settings_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../view_models/auth_notifier.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ayarlar",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: isDark 
            ? const Color(0xFF1E1E1E) // Dark mod için koyu gri
            : const Color(0xFF2E7D32), // Light mod için yeşil
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
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
                      leading: Icon(
                        Icons.account_circle,
                        size: 40,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: const Text(
                        "Hesabım",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Email: ${authState.user?.email ?? 'Bilinmiyor'}"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dark Mode Switch Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isDarkMode = ref.watch(themeProvider);
                        final switchTitle =
                            isDarkMode ? "Aydınlık Mod" : "Karanlık Mod";
                        final switchIcon =
                            isDarkMode ? Icons.wb_sunny : Icons.dark_mode;
                        return SwitchListTile(
                          title: Text(
                            switchTitle,
                            style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                          value: isDarkMode,
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme(value);
                          },
                          secondary: Icon(
                            switchIcon,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        );
                      },
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
                      leading: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.error,
                        size: 32,
                      ),
                      title: const Text(
                        "Çıkış Yap",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Çıkış"),
                            content: const Text("Çıkış yapmak istediğinize emin misiniz?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("İptal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Evet"),
                              ),
                            ],
                          ),
                        );
                        if (result == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool("remember_me", false);
                          await authNotifier.logout();

                          if (authState.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Çıkış Yapılırken Hata Oluştu: ${authState.errorMessage}",
                                ),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Başarıyla Çıkış Yapıldı"),
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card with updated style for light mode
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isDark
                    ? BorderSide.none
                    : const BorderSide(color: Colors.green, width: 2),
              ),
              color: isDark ? null : Colors.white,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? null : Colors.white,
                ),
                child: Text(
                  "Uygulamadaki Modelin Desteklediği Bitki Türleri",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // List of Plant Types with tap navigation to details
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: plantTypes.length,
                itemBuilder: (context, index) {
                  final type = plantTypes[index];
                  final displayType = type
                      .split('_')
                      .map((word) =>
                          word[0].toUpperCase() +
                          word.substring(1).toLowerCase())
                      .join(' ');
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isDark
                          ? BorderSide.none
                          : const BorderSide(color: Colors.green, width: 1),
                    ),
                    color: isDark ? null : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.nature,
                        color: isDark
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.green,
                      ),
                      title: Text(
                        displayType,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? null : Colors.green,
                        ),
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayType = plantType
        .split('_')
        .map((word) =>
            word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
    final info = getPlantDetails();
    return Scaffold(
      appBar: AppBar(
        title: Text(displayType),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Details Card with updated color scheme for light mode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: isDark ? null : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark
                      ? BorderSide.none
                      : const BorderSide(color: Colors.green, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlıklar: light mode'da yeşil, dark mode'da mevcut ayar
                      Text(
                        "Spesifik Özellikler",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Açıklamalar: light mode'da siyah tonlarında, dark mode'da varsayılan
                      Text(
                        info['Özellikler']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? null : Colors.black87,
                        ),
                      ),
                      Divider(
                          height: 30,
                          color: isDark ? Colors.white70 : Colors.green),
                      Text(
                        "Sevdikleri Nem Koşulları",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info['Nem Koşulları']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? null : Colors.black87,
                        ),
                      ),
                      Divider(
                          height: 30,
                          color: isDark ? Colors.white70 : Colors.green),
                      Text(
                        "Bakım İpuçları",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info['Bakım']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? null : Colors.black87,
                        ),
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
