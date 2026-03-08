import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.account_balance_wallet,
      color: AppColors.primary,
      title: 'Bienvenido a Cuentas Claras',
      description:
          'Lleva el control de tus ingresos y gastos de forma simple y organizada.',
    ),
    _OnboardingPage(
      icon: Icons.group,
      color: Color(0xFF10B981),
      title: 'Cuentas Claras en Grupo',
      description:
          'Crea un grupo y comparte el codigo con tu pareja, familia o roommates para gestionar las finanzas juntos.',
    ),
    _OnboardingPage(
      icon: Icons.pie_chart,
      color: Color(0xFFF59E0B),
      title: 'Visualiza tus Gastos',
      description:
          'Dashboard con graficos, categorias y resumen mensual para entender a donde va tu dinero.',
    ),
    _OnboardingPage(
      icon: Icons.fingerprint,
      color: Color(0xFFEC4899),
      title: 'Seguro y Privado',
      description:
          'Protege tu app con huella dactilar o reconocimiento facial. Tus datos siempre seguros.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await StorageService.setOnboardingDone();
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Saltar',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // Dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    _pages.length,
                    (i) => Container(
                          width: _page == i ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _page == i
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                      _page == _pages.length - 1 ? 'Comenzar' : 'Siguiente'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: color),
          ),
          const SizedBox(height: 40),
          Text(title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(description,
              style: const TextStyle(
                  fontSize: 16, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
