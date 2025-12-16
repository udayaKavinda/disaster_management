import 'package:flutter/material.dart';
import '../services/report_service.dart';
import 'report_detail_page.dart';
import 'package:intl/intl.dart';

class ViewReportsPageAdmin extends StatefulWidget {
  const ViewReportsPageAdmin({super.key});

  @override
  State<ViewReportsPageAdmin> createState() => _ViewReportsPageAdminState();
}

class _ViewReportsPageAdminState extends State<ViewReportsPageAdmin> {
  late Future<List<dynamic>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
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
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.pop(context);
              await ReportService.deleteReport(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report deleted successfully")),
              );
              setState(() => _loadReports());
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    return DateFormat('yyyy-MM-dd  HH:mm')
        .format(DateTime.parse(iso));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _styledAppBar("Submitted Reports"),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No reports submitted"));
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
                    _formatDate(r['createdAt']),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(r['reviewStatus']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(r['_id']),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailPage(reportId: r['_id']),
                    ),
                  ),
                ),
              );
            },
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


