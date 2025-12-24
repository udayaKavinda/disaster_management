import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';
import '../models/report_data.dart';
import '../theme/app_theme.dart';
import '../config/app_routes.dart';
import '../widgets/flashing_status_text.dart';
import '../widgets/styled_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/dialog_utils.dart';

class ViewReportsPage extends StatefulWidget {
  const ViewReportsPage({super.key});

  @override
  State<ViewReportsPage> createState() => _ViewReportsPageState();
}

class _ViewReportsPageState extends State<ViewReportsPage> {
  late Future<List<ResponseData>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = ReportService.fetchReports();
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Report"),
        content: const Text("Are you sure you want to delete this report?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.pop(context);
              await ReportService.deleteReport(id);
              if (!mounted) return;
              DialogUtils.showSuccessSnackBar(
                context,
                "Report deleted successfully",
              );
              setState(() => _loadReports());
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '-';
    try {
      return DateFormat(
        'yyyy-MM-dd  HH:mm',
      ).format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StyledAppBar(title: "Submitted Reports"),
      body: FutureBuilder<List<ResponseData>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              message: "No reports submitted",
              icon: Icons.folder_open,
            );
          }

          final reports = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (_, i) {
              final r = reports[i];
              return Card(
                child: ListTile(
                  title: Text(
                    _formatDate(r.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: FlashingStatusText(text: r.reviewStatus),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.danger),
                    onPressed: () => _confirmDelete(r.id),
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.reportDetail,
                    arguments: r.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
