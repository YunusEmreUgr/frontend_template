import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../providers/subscription_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedProductId = 'subscription_premium_yearly'; // Default selection

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SubscriptionProvider>();
      provider.loadProducts([
        'subscription_premium_monthly',
        'subscription_premium_yearly',
      ]);
      provider.fetchSubscriptionStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final products = subscriptionProvider.products;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C20), // Deep Night Blue
              Color(0xFF15102A), // Dark Violet
              Color(0xFF07050F), // Near Black
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Background Glowing Orbs ──
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4EFF).withValues(alpha: 0.15),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE24EFF).withValues(alpha: 0.12),
                      blurRadius: 150,
                    ),
                  ],
                ),
              ),
            ),

            // ── Main Scrollable Content ──
            SafeArea(
              child: subscriptionProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B4EFF)))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          
                          // ── Premium Badge ──
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6B4EFF).withValues(alpha: 0.2),
                                    const Color(0xFFE24EFF).withValues(alpha: 0.2),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFF6B4EFF).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PRO SÜRÜME GEÇİN',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Title & Subtitle ──
                          Text(
                            'Sınırsız Gücü\nHissedin',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 36,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tüm gelişmiş özelliklere erişim kazanın ve üretkenliğinizi bir üst seviyeye taşıyın.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Current Subscription Status ──
                          if (subscriptionProvider.isPremium)
                            _buildCurrentSubscriptionCard(subscriptionProvider)
                          else ...[
                            // ── Feature Checklist ──
                            _buildFeatureList(theme),
                            const SizedBox(height: 36),

                            // ── Package Selection Header ──
                            Text(
                              'Abonelik Paketini Seçin',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Packages Cards ──
                            if (products.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'Paketler App Store\'dan yüklenemedi. Lütfen tekrar deneyin.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final isSelected = product.id == _selectedProductId;
                                  final isYearly = product.id.contains('yearly');

                                  return _buildPackageCard(
                                    product: product,
                                    isSelected: isSelected,
                                    isYearly: isYearly,
                                  );
                                },
                              ),
                            const SizedBox(height: 28),

                            // ── Call to Action Button ──
                            _buildGradientPurchaseButton(subscriptionProvider),
                            const SizedBox(height: 16),

                            // ── Restore Purchases ──
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  await subscriptionProvider.restorePurchases();
                                  if (mounted && subscriptionProvider.errorMessage == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Abonelikleriniz başarıyla geri yüklendi.')),
                                    );
                                  }
                                },
                                child: Text(
                                  'Satın Alımları Geri Yükle',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF6B4EFF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // ── Error Message Banner ──
                          if (subscriptionProvider.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                subscriptionProvider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),

                          // ── App Store Compliance Legal Footer ──
                          _buildLegalFooter(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-component widgets ──

  Widget _buildCurrentSubscriptionCard(SubscriptionProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF6B4EFF).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Color(0xFFE24EFF),
              ),
              const SizedBox(height: 16),
              Text(
                'Harika! Zaten Pro Üyesiniz',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paket: ${provider.subscriptionTier}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
              ),
              if (provider.expirationDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Yenilenme Tarihi: ${provider.expirationDate!.day}/${provider.expirationDate!.month}/${provider.expirationDate!.year}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EFF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Uygulamaya Dön', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList(ThemeData theme) {
    final features = [
      'Gelişmiş AI İşlem Kapasitesi',
      'Limitsiz Veri Analizi ve Dışa Aktarma',
      'Öncelikli Müşteri Desteği (7/24)',
      'Reklamsız ve Kesintisiz Kullanım Deneyimi',
      'Tüm Cihazlarda Eşzamanlı Bulut Senkronizasyonu',
    ];

    return Column(
      children: features
          .map(
            (feat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B4EFF), Color(0xFFE24EFF)],
                      ),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      feat,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPackageCard({
    required ProductDetails product,
    required bool isSelected,
    required bool isYearly,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductId = product.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B4EFF).withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE24EFF) : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B4EFF).withValues(alpha: 0.25),
                    blurRadius: 15,
                    spreadRadius: -2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFE24EFF) : Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE24EFF),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isYearly ? 'Yıllık Erişim' : 'Aylık Erişim',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF00CC), Color(0xFFFF9900)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '%40 AVANTAJLI',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.price,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isYearly)
                  Text(
                    '₺79.16 / ay',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientPurchaseButton(SubscriptionProvider provider) {
    return GestureDetector(
      onTap: () async {
        final product = provider.products.firstWhere((p) => p.id == _selectedProductId);
        await provider.purchaseSubscription(product);
        if (mounted && provider.isPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Satın alım tamamlandı! Teşekkür ederiz.')),
          );
          Navigator.pop(context);
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6B4EFF), Color(0xFFE24EFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE24EFF).withValues(alpha: 0.35),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            'Devam Et',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalFooter() {
    return Column(
      children: [
        Text(
          'Abonelik otomatik yenilenir. İstediğiniz zaman App Store hesap ayarlarından iptal edebilirsiniz. Ödemeler satın alma onayında iTunes Hesabınızdan tahsil edilecektir.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink('Kullanım Koşulları', () => _showTermsDialog(context)),
            Text('  •  ', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
            _buildFooterLink('Gizlilik Politikası', () => _showPrivacyDialog(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15102A),
          title: const Text('Kullanım Koşulları (EULA)', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                '1. Giriş\nBu Kullanım Koşulları (EULA), bu uygulamayı ve ilgili tüm hizmetleri kullanımınızı düzenler. Uygulamayı kullanarak bu koşulları kabul etmiş olursunuz.\n\n'
                '2. Abonelikler ve Faturalandırma\nUygulamamız otomatik yenilenen abonelik modelleri sunar. Satın alma onayıyla ödeme iTunes hesabınızdan tahsil edilir. Aboneliği iptal etmediğiniz sürece mevcut dönemin bitiminden en az 24 saat önce otomatik olarak yenilenir. Yenileme ücreti mevcut dönemin bitiminden önceki 24 saat içinde hesabınızdan tahsil edilecektir.\n\n'
                '3. İptal ve İade Koşulları\nAboneliğinizi dilediğiniz zaman App Store Hesap Ayarları üzerinden yönetebilir ve iptal edebilirsiniz. Apple politikaları gereği, aktif dönem içinde iptal edilen abonelikler için kısmi iade yapılmaz.\n\n'
                '4. Standart Lisans Sözleşmesi (EULA)\nBu uygulama Apple\'ın Standart Lisans Sözleşmesi (Standard Licensed Application End User License Agreement - EULA) koşullarına tabidir. Uygulamayı indirerek bu lisans koşullarını kabul etmiş sayılırsınız.\n\n'
                '5. Sorumluluk Sınırları\nHizmetlerimiz "olduğu gibi" sunulmaktadır. Yazılım hatalarından veya veri kayıplarından doğabilecek doğrudan veya dolaylı zararlardan firmamız sorumlu tutulamaz.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat', style: TextStyle(color: Color(0xFF6B4EFF))),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15102A),
          title: const Text('Gizlilik Politikası', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                '1. Toplanan Veriler\nÜyelik oluştururken verdiğiniz ad, soyad ve e-posta bilgileriniz veritabanımızda güvenli bir şekilde saklanır. Apple ile yaptığınız satın alma işlemleri cihazınız üzerinden doğrulanır ve ödeme kartı bilgileriniz hiçbir zaman sunucularımızda tutulmaz veya işlenmez.\n\n'
                '2. Veri Güvenliği\nVerilerinizin güvenliğini sağlamak için endüstri standardı şifreleme ve güvenlik önlemleri uygulamaktayız. Hesap verilerinize yetkisiz erişimi engellemek amacıyla sürekli izleme gerçekleştirilmektedir.\n\n'
                '3. Veri Paylaşımı\nKişisel verileriniz hiçbir üçüncü şahıs veya reklam şirketiyle ticari amaçlarla paylaşılmaz.\n\n'
                '4. Kullanıcı Hakları ve Hesap Silme\nKVKK ve GDPR kapsamında, verilerinizin silinmesini isteme hakkına sahipsiniz. Profil ayarları sayfanızda bulunan "Hesabımı Sil" butonuna tıklayarak veritabanımızdaki kişisel verilerinizin kalıcı olarak silinmesini anında sağlayabilirsiniz.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat', style: TextStyle(color: Color(0xFF6B4EFF))),
            ),
          ],
        );
      },
    );
  }
}
