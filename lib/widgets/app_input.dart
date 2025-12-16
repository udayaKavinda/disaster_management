import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController controller;

  const AppInput({super.key, required this.hint, required this.icon, required this.controller, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (v) => (v!.trim().isEmpty) ? "$hint required" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
      ),
    );
  }
}
