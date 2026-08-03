import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfile();
    });
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: const Text('Şifre Değiştir'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Mevcut Şifre',
                  isPassword: true,
                  controller: currentPassController,
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Yeni Şifre',
                  isPassword: true,
                  controller: newPassController,
                  validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final cur = currentPassController.text.trim();
                  final newP = newPassController.text.trim();

                  final success = await context.read<UserProvider>().changePassword(cur, newP);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Şifreniz başarıyla değiştirildi.')),
                      );
                    } else {
                      final error = context.read<UserProvider>().errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Şifre değiştirilemedi.'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 60, color: theme.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile != null ? '${profile.firstName} ${profile.lastName}' : 'Kurumsal Kullanıcı',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? 'user@kurum.com',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                CustomCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shield_outlined),
                        title: const Text('Atanmış Rol & Yetkiler'),
                        subtitle: Text('${authProvider.userClaims.length} yetki mevcut'),
                      ),
                      if (authProvider.userClaims.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: authProvider.userClaims
                                .map((claim) => Chip(
                                      label: Text(claim),
                                      avatar: const Icon(Icons.check, size: 16),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  onTap: () => _showChangePasswordDialog(context),
                  child: const ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Şifre Değiştir'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Oturumu Kapat',
                  backgroundColor: theme.colorScheme.error,
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                    }
                  },
                ),
              ],
            ),
    );
  }
}
