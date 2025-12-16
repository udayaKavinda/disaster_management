import 'package:flutter/material.dart';
import '../services/report_service.dart';
import 'report_detail_page.dart';
import 'package:intl/intl.dart';

class ViewReportsPage extends StatefulWidget {
  const ViewReportsPage({super.key});

  @override
  State<ViewReportsPage> createState() => _ViewReportsPageState();
}

class _ViewReportsPageState extends State<ViewReportsPage> {
  late Future<List<dynamic>> _reportsFuture;

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
                  subtitle: FlashingStatusText(text: r['reviewStatus']),
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
      case 'under review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
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
        style: TextStyle(
          color: _colorAnim.value,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
