import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/report_service.dart';
import '../models/report_data.dart';
import '../config/app_routes.dart';
import '../widgets/report_search_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/styled_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/dialog_utils.dart';
import '../widgets/flashing_status_text.dart';

class ViewReportsPageAdmin extends StatefulWidget {
  const ViewReportsPageAdmin({super.key});

  @override
  State<ViewReportsPageAdmin> createState() => _ViewReportsPageAdminState();
}

class _ViewReportsPageAdminState extends State<ViewReportsPageAdmin>
    with WidgetsBindingObserver {
  late Future<List<ReportResponse>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReports();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ✅ Reload when app comes back from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _loadReports());
    }
  }

  void _loadReports() {
    _reportsFuture = ReportService.fetchAllReports();
  }

  void _openSearchDialog() {
    showDialog(context: context, builder: (_) => const ReportSearchDialog());
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
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
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
            child: const Text("Delete"),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: StyledAppBar(
          title: "Submitted Reports",
          actions: [
            IconButton(
              tooltip: 'Search reports',
              icon: const Icon(Icons.search),
              onPressed: _openSearchDialog,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppTheme.white,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Reviewed"),
            ],
          ),
        ),
        body: FutureBuilder<List<ReportResponse>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyStateWidget(
                message: "No reports submitted",
                icon: Icons.folder_open,
              );
            }

            final reports = snapshot.data!;

            final pendingReports = reports
                .where((r) => r.reviewStatus == 'Under review')
                .toList();

            final reviewedReports = reports
                .where((r) => r.reviewStatus != 'Under review')
                .toList();

            return TabBarView(
              children: [
                _buildReportList(pendingReports),
                _buildReportList(reviewedReports),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportList(List<ReportResponse> reports) {
    if (reports.isEmpty) {
      return const EmptyStateWidget(message: "No reports", icon: Icons.inbox);
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _loadReports());
      },
      child: ListView.builder(
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

              /// ✅ Reload list after coming back from details page
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.reportDetailAdmin,
                  arguments: r.id,
                );

                if (mounted) {
                  setState(() => _loadReports());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
