import 'package:disaster_management/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_data.dart';
import '../widgets/styled_app_bar.dart';
import '../widgets/status_chip.dart';

class ReportDetailPage extends StatelessWidget {
  final String reportId;
  const ReportDetailPage({super.key, required this.reportId});

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StyledAppBar(title: "Report Details"),
      body: FutureBuilder<ReportResponse>(
        future: ReportService.fetchReportById(reportId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final r = snap.data!;
          final String reviewStatus = r.reviewStatus;
          final String feedback = (r.feedback ?? '').trim();

          final statusColor = AppTheme.getStatusColor(reviewStatus);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// ---------------- Status Indicator ----------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag, color: statusColor),
                    const SizedBox(width: 10),
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: reviewStatus),
                  ],
                ),
              ),

              /// ---------------- Owner Details ----------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _info("Owner Name", r.ownerName),
                      _info("Contact", r.contact),
                      _info("Address", r.address),
                      _info("District", r.district),
                      _info("GN Division", r.gnDivision),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ---------------- Risk Factors ----------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Risk Factors",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...r.riskAnswers.entries.map<Widget>((e) {
                        return Row(
                          children: [
                            Icon(
                              e.value ? Icons.warning : Icons.check,
                              color: e.value ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.key)),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              /// ---------------- Feedback (LAST) ----------------
              if (feedback.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.comment, color: statusColor),
                          const SizedBox(width: 8),
                          Text(
                            "Official Feedback",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(feedback, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
