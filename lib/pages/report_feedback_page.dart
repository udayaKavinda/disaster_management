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
    return text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  Future<void> _submit() async {
    final feedback = _feedbackCtrl.text.trim();
    final words = _wordCount(feedback);

    if (_selected == null) {
      setState(() => _error = 'Select a state');
      return;
    }

    if (words > 500) {
      setState(() => _error = 'Feedback must be 500 words or less');
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
      appBar: AppBar(title: const Text('Add Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feedback (max 500 words)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackCtrl,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                helperText: '$words / 500 words',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select state (one)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _statuses.map((status) {
                final selected = _selected == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = status),
                );
              }).toList(),
            ),
            const Spacer(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
