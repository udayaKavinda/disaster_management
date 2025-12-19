import 'package:flutter/material.dart';
import '../services/report_service.dart';

class ReportDetailPageAdmin extends StatelessWidget {
  final String reportId;
  const ReportDetailPageAdmin({super.key, required this.reportId});

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
      appBar: _styledAppBar("Report Details"),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ReportService.fetchReportById(reportId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final r = snap.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _info("Owner Name", r['ownerName']),
                      _info("Contact", r['contact']),
                      _info("Address", r['address']),
                      _info("District", r['district']),
                      _info("GN Division", r['gnDivision']),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
                      ...r['riskAnswers'].entries.map<Widget>((e) {
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
            ],
          );
        },
      ),
    );
  }

  AppBar _styledAppBar(String title) {
    return AppBar(
      elevation: 4,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.lightBlue.shade400],
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
