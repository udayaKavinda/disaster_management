import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../theme/app_theme.dart';
import '../widgets/styled_app_bar.dart';
import '../widgets/loading_widget.dart';

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

  Future<void> _submit() async {
    final feedback = _feedbackCtrl.text.trim();

    if (_selected == null) {
      setState(() => _error = 'Please select a review status');
      return;
    }

    if (feedback.length > 1000) {
      setState(() => _error = 'Feedback must be 1000 characters or less');
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
    return Scaffold(
      appBar: const StyledAppBar(title: "Review & Feedback"),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// ---------------- Feedback Card ----------------
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Admin Feedback",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _feedbackCtrl,
                                      maxLines: 10,
                                      minLines: 6,
                                      maxLength: 1000,
                                      onChanged: (_) => setState(() {}),
                                      decoration: InputDecoration(
                                        hintText:
                                            "Enter observations, warnings or instructions",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ---------------- Status Card ----------------
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Review Status",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: _statuses.map((status) {
                                        final selected = _selected == status;
                                        return ChoiceChip(
                                          label: Text(status),
                                          selected: selected,
                                          selectedColor:
                                              AppTheme.getStatusColor(status),
                                          labelStyle: TextStyle(
                                            color: selected
                                                ? AppTheme.white
                                                : AppTheme.black,
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          onSelected: (_) => setState(
                                            () => _selected = status,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppTheme.danger,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const ButtonLoadingWidget()
                  : const Icon(Icons.save),
              label: const Text(
                "Save Feedback",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
