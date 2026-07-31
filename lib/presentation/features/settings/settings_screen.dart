import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/custom_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CustomCard(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Koyu Tema (Dark Mode)'),
              subtitle: const Text('Uygulama renk temasını değiştirin'),
              value: themeProvider.isDarkMode,
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Uygulama Dili'),
              subtitle: const Text('Türkçe (TR)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Dil değiştirme seçeneği
              },
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Hakkında'),
              subtitle: const Text('Enterprise Template v1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
