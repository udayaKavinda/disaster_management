// lib/main.dart
import 'package:disaster_management/pages/home_page.dart';
import 'package:disaster_management/pages/official_profile_page.dart';
import 'package:disaster_management/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

// -------------------- LOGIN PAGE --------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nic = TextEditingController();
  final password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;

  @override
  void dispose() {
    nic.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width.clamp(320.0, 480.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryLight100, AppTheme.primaryLight50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: maxWidth * 0.34,
                        child: Image.asset(
                          'assets/lottie/icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, _, __) => Icon(
                            Icons.safety_check_rounded,
                            size: maxWidth * 0.18,
                            color: AppTheme.buttonPrimary,
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        'Landslide Risk Reporter',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ).animate().fadeIn(duration: 350.ms),
                      const SizedBox(height: 6),
                      Text(
                        'Report Landslide Hazards quickly. Help responders act faster.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
                      const SizedBox(height: 18),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nic,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_3_outlined),
                                hintText: 'Nic',
                              ),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Nic required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: password,
                              obscureText: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                hintText: 'Password',
                              ),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Password required'
                                  : null,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: _busy
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    _busy ? 'Logging In...' : 'Log In',
                                  ),
                                ),
                                onPressed: _busy
                                    ? null
                                    : () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          setState(() => _busy = true);

                                          try {
                                            await AuthService.login(
                                              nic: nic.text.trim(),
                                              password: password.text.trim(),
                                            );

                                            if (!mounted) return;

                                            final user =
                                                await AuthService.getCurrentUser();
                                            if (!mounted) return;
                                            if ((user?.isAdmin ?? false) ==
                                                    false &&
                                                (user?.emptyFields ?? true) ==
                                                    true) {
                                              if (!mounted) return;
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                AppRoutes.officialProfile,
                                                (_) => false,
                                              );
                                            } else {
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                AppRoutes.home,
                                                (_) => false,
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.toString().replaceAll(
                                                    "Exception: ",
                                                    "",
                                                  ),
                                                ),
                                                backgroundColor:
                                                    AppTheme.danger,
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(() => _busy = false);
                                            }
                                          }
                                        }
                                      },
                              ).animate().fadeIn(duration: 250.ms),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Forgot password tapped'),
                                  ),
                                );
                              },
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
