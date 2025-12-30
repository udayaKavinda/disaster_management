import 'dart:io';

import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/report_service.dart';
import '../models/report_data.dart';
import '../theme/app_theme.dart';
import '../utils/dialog_utils.dart';
import '../widgets/water_fill_button.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SubmitReportPage extends StatefulWidget {
  final SubmitReport report;
  const SubmitReportPage({super.key, required this.report});

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  static const int _maxAdditionalImages = 5;
  static const int _maxUploadBytes = 10 * 1024 * 1024; // 5 MB soft cap
  static const int _targetMinSize = 1024;
  final TextEditingController _extraDesc = TextEditingController();
  bool _submitting = false;
  double _uploadProgress = 0.0;
  bool _compressing = false;
  bool _allCompressed = false;

  // 🔹 IMAGE PICKER
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    images = widget.report.riskImages["additional"] ?? [];
    Future.microtask(_recoverLostDataAdditional);
  }

  @override
  void dispose() {
    _extraDesc.dispose();
    super.dispose();
  }

  void _showImageLimitMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You can add up to $_maxAdditionalImages images."),
      ),
    );
  }

  Future<void> _recoverLostDataAdditional() async {
    final response = await _picker.retrieveLostData();
    if (!mounted || response.isEmpty) return;

    final addFile = (XFile x) {
      if (images.length >= _maxAdditionalImages) return;
      images.add(File(x.path));
    };

    if (response.file != null) addFile(response.file!);
    if (response.files != null) {
      for (final f in response.files!) {
        addFile(f);
      }
    }

    setState(() {
      _allCompressed = false;
    });
  }

  // ================= IMAGE COMPRESSION =================
  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'cmp_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}',
    );

    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        minWidth: _targetMinSize,
        minHeight: _targetMinSize,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      debugPrint('Compression failed for ${file.path}: $e');
      return file; // Return original on compression error
    }
  }

  Future<void> _compressAllImagesOnce() async {
    if (_allCompressed) return;
    setState(() => _compressing = true);

    try {
      final updated = <String, List<File>>{};

      for (final entry in widget.report.riskImages.entries) {
        final List<File> compressed = [];
        for (final f in entry.value) {
          compressed.add(await _compressImage(f));
        }
        updated[entry.key] = compressed;
      }

      // Ensure the local additional list stays in sync
      images = updated["additional"] ?? images;
      widget.report.riskImages
        ..clear()
        ..addAll(updated);
    } catch (e) {
      debugPrint('Batch compression error: $e');
    }

    if (!mounted) return;
    setState(() {
      _compressing = false;
      _allCompressed = true;
    });
  }

  Future<int> _computeTotalBytes() async {
    int total = 0;
    for (final entry in widget.report.riskImages.entries) {
      for (final f in entry.value) {
        total += await f.length();
      }
    }
    return total;
  }

  // ================= INTERNET CHECK =================
  Future<bool> _checkInternet(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!mounted) return false;

    if (connectivityResult == ConnectivityResult.none) {
      DialogUtils.showAlertDialog(
        context,
        title: "No Internet Connection",
        message: "Please turn on mobile data or Wi-Fi to submit the report.",
      );
      return false;
    }

    try {
      final response = await http
          .get(Uri.parse("https://www.google.com"))
          .timeout(const Duration(seconds: 5));
      if (!mounted) return false;

      return response.statusCode == 200;
    } catch (_) {
      DialogUtils.showAlertDialog(
        context,
        title: "No Internet Access",
        message:
            "You are connected to a network, but internet is not available.\nPlease try again.",
      );
      return false;
    }
  }

  // ================= ALERTS =================
  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppTheme.success),
            SizedBox(width: 8),
            Text("Report Submitted"),
          ],
        ),
        content: const Text(
          "Thank you for reporting.\n\n"
          "We will carefully review your case and take necessary action as soon as possible.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (_) => false,
              );
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE SOURCE SHEET =================
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= PICK FROM CAMERA =================
  Future<void> _pickFromCamera() async {
    if (images.length >= _maxAdditionalImages) {
      _showImageLimitMessage();
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        images.add(File(picked.path));
        _allCompressed = false;
      });
    }
  }

  // ================= PICK FROM GALLERY =================
  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      if (images.length >= _maxAdditionalImages) {
        _showImageLimitMessage();
        return;
      }

      final remainingSlots = _maxAdditionalImages - images.length;
      final limited = picked.take(remainingSlots).toList();

      if (limited.length < picked.length) {
        _showImageLimitMessage();
      }

      setState(() {
        images.addAll(limited.map((x) => File(x.path)));
        _allCompressed = false;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> _submit(BuildContext context) async {
    if (_compressing) return;

    setState(() {
      _submitting = true;
      _uploadProgress = 0.0;
    });

    final hasInternet = await _checkInternet(context);
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadProgress = 0.0;
        });
      }
      return;
    }

    // Simulate progress for initial processing
    setState(() => _uploadProgress = 0.1);
    await Future.delayed(const Duration(milliseconds: 300));

    widget.report.additionalNotes = _extraDesc.text.trim();

    // 🔹 SAVE IMAGES (uncompressed for now)
    widget.report.riskImages["additional"] = images;

    // Compress everything once before upload
    _allCompressed = false;
    await _compressAllImagesOnce();

    // Re-sync local additional list after compression
    images = widget.report.riskImages["additional"] ?? images;

    // Warn if total size is too large
    final totalBytes = await _computeTotalBytes();
    if (totalBytes > _maxUploadBytes) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadProgress = 0.0;
        });
      }
      DialogUtils.showAlertDialog(
        context,
        title: "Images Too Large",
        message:
            "Total upload size is ${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB. Please remove or replace some images and try again.",
      );
      return;
    }

    // Simulate progress for image preparation
    setState(() => _uploadProgress = 0.2);
    await Future.delayed(const Duration(milliseconds: 200));

    bool success = false;
    try {
      success = await ReportService.submitReport(widget.report);
    } catch (e) {
      success = false;
      debugPrint('Submit error: $e');
    }

    setState(() => _uploadProgress = 1.0);
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (!success) {
      DialogUtils.showAlertDialog(
        context,
        title: "Submission Failed",
        message: "Could not submit the report. Please try again.",
      );
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadProgress = 0.0;
        });
      }
      return;
    }
    if (!mounted) return;

    if (mounted) {
      setState(() {
        _submitting = false;
        _uploadProgress = 0.0;
      });
    }
    _showSuccess(context);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text(
          "Submit Report",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: AppTheme.white,
          ),
        ),
      ),
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
                            // Card(
                            //   elevation: 3,
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(14),
                            //   ),
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(14),
                            //     child: Row(
                            //       children: [
                            //         Icon(
                            //           Icons.my_location,
                            //           color: AppTheme.buttonPrimaryDark,
                            //           size: 32,
                            //         ),
                            //         const SizedBox(width: 12),
                            //         const Expanded(
                            //           child: Text(
                            //             "Your current location will be captured automatically when submitting the report.",
                            //             style: TextStyle(fontSize: 15),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 16),

                            /// 🔹 OPTIONAL IMAGE UPLOAD
                            GestureDetector(
                              onTap: _showImageSourceSheet,
                              child: Card(
                                elevation: 6,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  children: [
                                    if (images.isNotEmpty)
                                      Image.file(
                                        images.first,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    else
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                        ),
                                      ),
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withValues(
                                          alpha: 0.35,
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 48,
                                              color: AppTheme.white,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "Tap to upload additional \n supporting images (optional)",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Additional Details",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _extraDesc,
                                      minLines: 6,
                                      maxLines: 10,
                                      maxLength: 1000,
                                      decoration: InputDecoration(
                                        hintText:
                                            "Additional details about the risks (optional)",
                                        filled: true,
                                        fillColor: AppTheme.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (images.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (_, i) => Stack(
                                    children: [
                                      Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.file(
                                          images[i],
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          cacheWidth: 180,
                                          cacheHeight: 180,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              images.removeAt(i);
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: AppTheme.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: AppTheme.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
          child: WaterFillButton(
            label: _submitting ? "Uploading..." : "Submit Report",
            icon: Icons.send,
            isLoading: _submitting,
            progress: _uploadProgress,
            disabled: _compressing,
            onPressed: _submitting ? null : () => _submit(context),
          ),
        ),
      ),
    );
  }
}
