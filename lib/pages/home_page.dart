// -------------------- HOME PAGE --------------------
// lib/main.dart
import 'package:disaster_management/pages/report_form_page.dart';
import 'package:disaster_management/pages/view_reports_page_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _menuCardButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width.clamp(320.0, 480.0);

    return Scaffold(
      // -------------------- TOP BAR --------------------
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.lightBlue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Landslide Risk Reporter',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              SizedBox(
                height: maxWidth * 0.36,
                child: Image.asset(
                  'assets/lottie/icon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, _, __) {
                    return Icon(
                      Icons.dashboard,
                      size: maxWidth * 0.22,
                      color: Colors.lightBlue.shade600,
                    );
                  },
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 22),

              // -------------------- BUTTON 1 (ROW 1) --------------------
              _menuCardButton(
                context: context,
                icon: Icons.report_outlined,
                label: 'Report Hazard',
                gradient: [
                  Colors.lightBlue.shade400,
                  Colors.lightBlue.shade600,
                ],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportFormPage()),
                ),
              ),

              const SizedBox(height: 16),

              // -------------------- BUTTON 2 (ROW 2) --------------------
              _menuCardButton(
                context: context,
                icon: Icons.map_outlined,
                label: 'View Reports',
                gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ViewReportsPageAdmin(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.lightBlue.shade700,
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'If you identify any landslide hazards in your area, please report them to us. We will respond promptly to protect your safety.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
