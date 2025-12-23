import 'package:flutter/material.dart';
import '../services/report_service.dart';

class ReportFeedbackPage extends StatefulWidget {
  final String reportId;
  final String? currentStatus;

  const ReportFeedbackPage({
    super.key,
    required this.reportId,
    this.currentStatus,
  });

  @override
  State<ReportFeedbackPage> createState() => _ReportFeedbackPageState();
}

class _ReportFeedbackPageState extends State<ReportFeedbackPage> {
  final TextEditingController _feedbackCtrl = TextEditingController();

  final List<String> _statuses = [
    'Discard',
    'Evacuate',
    'Watch',
    'Monitor closely',
  ];

  String? _selected;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (_statuses.contains(widget.currentStatus)) {
      _selected = widget.currentStatus;
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  int _wordCount(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  Future<void> _submit() async {
    final feedback = _feedbackCtrl.text.trim();
    final words = _wordCount(feedback);

    if (_selected == null) {
      setState(() => _error = 'Please select a review status');
      return;
    }

    if (words > 100) {
      setState(() => _error = 'Feedback must be 100 words or less');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    final success = await ReportService.updateReportReview(
      id: widget.reportId,
      reviewStatus: _selected!,
      feedback: feedback,
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Failed to save. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _wordCount(_feedbackCtrl.text);

    return Scaffold(
      appBar: _styledAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ---------------- Feedback Card ----------------
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Admin Feedback",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _feedbackCtrl,
                    maxLines: 6,
                    minLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter observations, warnings or instructions",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: '$words / 100 words',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// ---------------- Status Card ----------------
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Review Status",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: _statuses.map((status) {
                      final selected = _selected == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: selected,
                        selectedColor: _statusColor(status),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _selected = status),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ---------------- Error ----------------
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),

          /// ---------------- Save Button ----------------
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text(
                "Save Feedback",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- Styled AppBar ----------------
  AppBar _styledAppBar() {
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
      title: const Text(
        "Review & Feedback",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// ---------------- Status Colors ----------------
  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('evacuate')) return Colors.deepOrange;
    if (s.contains('discard')) return Colors.red;
    if (s.contains('watch')) return Colors.amber;
    if (s.contains('monitor')) return Colors.blue;
    return Colors.grey;
  }
}
