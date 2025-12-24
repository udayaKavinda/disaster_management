import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../config/api_config.dart';
import '../services/report_service.dart';
import 'report_feedback_page.dart';
import '../theme/app_theme.dart';
import '../widgets/styled_app_bar.dart';
import '../widgets/status_chip.dart';
import '../widgets/loading_widget.dart';

class ReportDetailPageAdmin extends StatefulWidget {
  final String reportId;
  const ReportDetailPageAdmin({super.key, required this.reportId});

  @override
  State<ReportDetailPageAdmin> createState() => _ReportDetailPageAdminState();
}

class _ReportDetailPageAdminState extends State<ReportDetailPageAdmin> {
  late Future<Map<String, dynamic>> _reportFuture;
  String? _latestStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _reportFuture = ReportService.fetchReportById(widget.reportId);
  }

  Future<void> _openFeedback() async {
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.reportFeedback,
      arguments: {'reportId': widget.reportId, 'currentStatus': _latestStatus},
    );

    if (updated == true && mounted) {
      setState(_load);
    }
  }

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
      appBar: StyledAppBar(
        title: "Report Details",
        actions: [
          IconButton(
            tooltip: 'Add feedback',
            icon: const Icon(Icons.save_alt),
            onPressed: _openFeedback,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reportFuture,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const LoadingWidget();
          }

          final r = snap.data!;
          final Map<String, dynamic>? submittedBy =
              r['submittedBy'] as Map<String, dynamic>?;
          final Map<String, dynamic> riskImages =
              (r['riskImages'] as Map<String, dynamic>?) ?? {};
          final String additionalNotes = (r['additionalNotes'] ?? '')
              .toString()
              .trim();

          final String reviewStatus = (r['reviewStatus'] ?? 'Under review')
              .toString();
          _latestStatus = reviewStatus;

          final String feedback = (r['feedback'] ?? '').toString().trim();
          final statusColor = AppTheme.getStatusColor(reviewStatus);

          final List<String> allImages = [];
          final List<Map<String, dynamic>> categorizedImages = [];

          riskImages.forEach((key, value) {
            final List<String> images =
                (value as List?)
                    ?.map((e) => e.toString())
                    .where((e) => e.isNotEmpty)
                    .toList() ??
                [];

            final resolvedImages = images
                .map((url) => _resolveImageUrl(url))
                .toList();

            final startIndex = allImages.length;
            allImages.addAll(resolvedImages);

            categorizedImages.add({
              'key': key,
              'resolved': resolvedImages,
              'start': startIndex,
              'hasImages': resolvedImages.isNotEmpty,
            });
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.getStatusColor(
                    reviewStatus,
                  ).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag),
                    const SizedBox(width: 10),
                    Text(
                      'Status: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    StatusChip(status: reviewStatus),
                  ],
                ),
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "House owner details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                        "Reporter details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _info("Name", submittedBy?['name']?.toString() ?? ""),
                      _info(
                        "Contact",
                        submittedBy?['contact']?.toString() ?? "",
                      ),
                      _info("NIC", submittedBy?['nic']?.toString() ?? ""),
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
                        "Uploaded Images",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (riskImages.isEmpty) const Text("No images uploaded"),
                      ...categorizedImages.map((cat) {
                        final String key = cat['key'] as String;
                        final List<String> resolvedImages =
                            (cat['resolved'] as List<String>);
                        final int startIndex = cat['start'] as int;
                        final bool hasImages = cat['hasImages'] as bool;

                        if (!hasImages) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text("$key: No images"),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(
                                  resolvedImages.length,
                                  (i) => _ImageThumb(
                                    url: resolvedImages[i],
                                    onTap: () => _showImageViewer(
                                      context,
                                      allImages,
                                      startIndex + i,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
                              color: e.value
                                  ? AppTheme.danger
                                  : AppTheme.success,
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
              if (additionalNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Additional Notes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          additionalNotes,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (feedback.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.comment, color: statusColor),
                          const SizedBox(width: 8),
                          Text(
                            "Official Feedback",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(feedback, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _resolveImageUrl(String raw) {
    if (raw.startsWith('http')) return raw;
    return Uri.parse(ApiConfig.base).resolve(raw).toString();
  }

  void _showImageViewer(
    BuildContext context,
    List<String> images,
    int startIndex,
  ) {
    final controller = PageController(initialPage: startIndex);
    int current = startIndex;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: AppTheme.black,
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: (i) => setState(() => current = i),
                      itemCount: images.length,
                      itemBuilder: (_, i) {
                        return InteractiveViewer(
                          child: Center(
                            child: Image.network(
                              images[i],
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, _, __) => const Icon(
                                Icons.broken_image,
                                color: AppTheme.white,
                                size: 48,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close, color: AppTheme.white),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: current > 0
                            ? AppTheme.white
                            : const Color.fromARGB(255, 192, 192, 192),
                        size: 32,
                      ),
                      onPressed: current > 0
                          ? () => controller.previousPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            )
                          : null,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: current < images.length - 1
                            ? AppTheme.white
                            : const Color.fromARGB(255, 192, 192, 192),
                        size: 32,
                      ),
                      onPressed: current < images.length - 1
                          ? () => controller.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${current + 1} / ${images.length}',
                        style: const TextStyle(color: AppTheme.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final String url;
  final VoidCallback? onTap;

  const _ImageThumb({required this.url, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: AppTheme.greyLight,
          height: 96,
          width: 96,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
            errorBuilder: (context, _, __) =>
                const Icon(Icons.broken_image, size: 32),
          ),
        ),
      ),
    );
  }
}
