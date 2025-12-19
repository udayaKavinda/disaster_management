import 'dart:io';

import 'package:disaster_management/pages/submit_report_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/report_data.dart';
import '../utils/constants.dart';

class RiskFactorPage extends StatefulWidget {
  final ReportData report;
  final int index;

  const RiskFactorPage({super.key, required this.report, required this.index});

  @override
  State<RiskFactorPage> createState() => _RiskFactorPageState();
}

class _RiskFactorPageState extends State<RiskFactorPage> {
  bool? hasRisk;
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];

  static const int maxImages = 5;

  @override
  void initState() {
    super.initState();
    final title = riskFactors[widget.index]["title"]!;
    images = widget.report.riskImages[title] ?? [];
    hasRisk = widget.report.riskAnswers[title];
  }

  // ================= IMAGE COMPRESSION =================
  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final XFile? compressedXFile =
        await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: 70,
          minWidth: 1280,
          minHeight: 1280,
          format: CompressFormat.jpeg,
        );

    if (compressedXFile == null) return null;

    return File(compressedXFile.path);
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
    if (images.length >= maxImages) {
      _showLimitSnackBar();
      return;
    }

    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);

      if (!mounted || picked == null) return;

      final compressed = await _compressImage(File(picked.path));
      if (compressed == null) return;

      setState(() {
        images.add(compressed);
      });
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  // ================= PICK FROM GALLERY =================
  Future<void> _pickFromGallery() async {
    if (images.length >= maxImages) {
      _showLimitSnackBar();
      return;
    }

    try {
      final picked = await _picker.pickMultiImage();

      if (!mounted || picked.isEmpty) return;

      final remaining = maxImages - images.length;
      final selected = picked.take(remaining);

      for (final xFile in selected) {
        final compressed = await _compressImage(File(xFile.path));
        if (compressed != null) {
          images.add(compressed);
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint("Gallery error: $e");
    }
  }

  void _showLimitSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You can upload a maximum of 5 images"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void goNext() {
    final title = riskFactors[widget.index]["title"]!;
    widget.report.riskAnswers[title] = hasRisk ?? false;
    widget.report.riskImages[title] = images;

    if (widget.index < riskFactors.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RiskFactorPage(report: widget.report, index: widget.index + 1),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SubmitReportPage(report: widget.report),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final risk = riskFactors[widget.index];
    final title = risk["title"]!;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.lightBlue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 6,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          risk["image"]!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 16),

                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.lightBlue.shade700,
                                size: 34,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  risk["desc"]!,
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Colors.orange.shade700,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Do you see "$title" in your area?',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() => hasRisk = true),
                              child: const Text("YES"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => hasRisk = false);
                                goNext();
                              },
                              child: const Text("NO"),
                            ),
                          ),
                        ],
                      ),

                      if (hasRisk == true) ...[
                        const SizedBox(height: 16),
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
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
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
                                      cacheWidth: 180,
                                      cacheHeight: 180,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() => images.removeAt(i));
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: hasRisk == null ? null : goNext,
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
