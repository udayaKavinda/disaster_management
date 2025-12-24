import 'dart:io';

import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/report_service.dart';
import '../models/report_data.dart';
import '../theme/app_theme.dart';
import '../utils/dialog_utils.dart';

class SubmitReportPage extends StatefulWidget {
  final SubmitReport report;
  const SubmitReportPage({super.key, required this.report});

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  final TextEditingController _extraDesc = TextEditingController();
  bool _submitting = false;

  // 🔹 IMAGE PICKER
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    images = widget.report.riskImages["additional"] ?? [];
  }

  @override
  void dispose() {
    _extraDesc.dispose();
    super.dispose();
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

  // ================= LOCATION CHECK =================
  Future<Position?> _getLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return null;
    if (!serviceEnabled) {
      DialogUtils.showAlertDialog(
        context,
        title: "Location Disabled",
        message: "Please enable location services to submit the report.",
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return null;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted) return null;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      DialogUtils.showAlertDialog(
        context,
        title: "Permission Required",
        message: "Location permission is required to submit the report.",
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        images.add(File(picked.path));
      });
    }
  }

  // ================= PICK FROM GALLERY =================
  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> _submit(BuildContext context) async {
    setState(() => _submitting = true);

    final hasInternet = await _checkInternet(context);
    if (!hasInternet) {
      if (mounted) {
        setState(() => _submitting = false);
      }
      return;
    }

    final position = await _getLocation(context);
    if (position == null) {
      if (mounted) {
        setState(() => _submitting = false);
      }
      return;
    }

    widget.report.latitude = position.latitude;
    widget.report.longitude = position.longitude;
    widget.report.additionalNotes = _extraDesc.text.trim();

    // 🔹 SAVE IMAGES
    widget.report.riskImages["Additional"] = images;

    final success = await ReportService.submitReport(widget.report);
    if (!mounted) return;

    if (!success) {
      DialogUtils.showAlertDialog(
        context,
        title: "Submission Failed",
        message: "Could not submit the report. Please try again.",
      );
      if (mounted) {
        setState(() => _submitting = false);
      }
      return;
    }
    if (!mounted) return;

    if (mounted) {
      setState(() => _submitting = false);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: AppTheme.buttonPrimaryDark,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Your current location will be captured automatically when submitting the report.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _extraDesc,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Additional details about the risks (optional)",
                filled: true,
                fillColor: AppTheme.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 OPTIONAL IMAGE UPLOAD
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text("Upload Images (Optional)"),
              onPressed: _showImageSourceSheet,
            ),

            if (images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          images[i],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
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

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: Text(
                  _submitting ? "Submitting..." : "Submit Report",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _submitting ? null : () => _submit(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
