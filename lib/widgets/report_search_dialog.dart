import 'package:disaster_management/services/report_service.dart';
import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../models/report_data.dart';

class ReportSearchDialog extends StatefulWidget {
  const ReportSearchDialog({super.key});

  @override
  State<ReportSearchDialog> createState() => _ReportSearchDialogState();
}

class _ReportSearchDialogState extends State<ReportSearchDialog> {
  final TextEditingController _ctrl = TextEditingController();
  List<ReportResponse> _results = [];
  bool _loading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty || q == _lastQuery) return;

    setState(() {
      _loading = true;
      _lastQuery = q;
    });

    try {
      final data = await ReportService.searchReports(q);
      if (mounted) {
        setState(() => _results = data);
      }
    } catch (_) {
      // silently fail
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            /// -------- Search Bar --------
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                onChanged: _search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by name, contact number, etc...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),

            /// -------- Results --------
            Expanded(
              child: _results.isEmpty && !_loading
                  ? const Center(child: Text("No results"))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final r = _results[i];
                        return ListTile(
                          title: Text(
                            r.ownerName.isEmpty ? 'Unknown' : r.ownerName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '• ${r.reviewStatus} • ${r.district} • ${r.gnDivision} • ${r.contact}',
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 18),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed(
                              AppRoutes.reportDetailAdmin,
                              arguments: r.id,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
