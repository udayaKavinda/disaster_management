import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: AppTheme.getStatusColor(status),
      label: Text(
        status,
        style: const TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
