import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/report_service.dart';
import 'report_detail_page_admin.dart';

class ViewReportsPageAdmin extends StatefulWidget {
  const ViewReportsPageAdmin({super.key});

  @override
  State<ViewReportsPageAdmin> createState() => _ViewReportsPageAdminState();
}

class _ViewReportsPageAdminState extends State<ViewReportsPageAdmin>
    with WidgetsBindingObserver {
  late Future<List<dynamic>> _reportsFuture;

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report deleted successfully")),
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
    return DateFormat(
      'yyyy-MM-dd  HH:mm',
    ).format(DateTime.parse(iso).toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _styledAppBar("Submitted Reports"),
        body: FutureBuilder<List<dynamic>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No reports submitted"));
            }

            final reports = snapshot.data!;

            final pendingReports = reports
                .where((r) => r['reviewStatus'] == 'Under review')
                .toList();

            final reviewedReports = reports
                .where((r) => r['reviewStatus'] != 'Under review')
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

  Widget _buildReportList(List<dynamic> reports) {
    if (reports.isEmpty) {
      return const Center(child: Text("No reports"));
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
                _formatDate(r['createdAt']),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: FlashingStatusText(text: r['reviewStatus']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(r['_id']),
              ),

              /// ✅ Reload list after coming back from details page
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportDetailPageAdmin(reportId: r['_id']),
                  ),
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
      bottom: const TabBar(
        indicatorColor: Colors.white,
        tabs: [
          Tab(text: "Pending"),
          Tab(text: "Reviewed"),
        ],
      ),
    );
  }
}

class FlashingStatusText extends StatefulWidget {
  final String text;
  const FlashingStatusText({super.key, required this.text});

  @override
  State<FlashingStatusText> createState() => _FlashingStatusTextState();
}

class _FlashingStatusTextState extends State<FlashingStatusText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'evacuate':
        return Colors.deepOrange;
      case 'discard':
        return Colors.green;
      case 'monitor':
        return Colors.blue;
      case 'watch':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  void initState() {
    super.initState();

    final baseColor = _statusColor(widget.text);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnim = ColorTween(
      begin: baseColor.withOpacity(0.4),
      end: baseColor,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (_, __) => Text(
        widget.text,
        style: TextStyle(color: _colorAnim.value, fontWeight: FontWeight.w600),
      ),
    );
  }
}
