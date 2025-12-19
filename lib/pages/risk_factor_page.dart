import 'dart:io';

import 'package:disaster_management/pages/submit_report_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  @override
  void initState() {
    super.initState();
    final title = riskFactors[widget.index]["title"]!;
    images = widget.report.riskImages[title] ?? [];
    hasRisk = widget.report.riskAnswers[title];
  }

  // Future<void> pickImages() async {
  //   final picked = await _picker.pickMultiImage(imageQuality: 70);
  //   if (picked.isNotEmpty) {
  //     setState(() {
  //       images.addAll(picked.map((e) => File(e.path)));
  //     });
  //   }
  // }

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

  void goNext() {
    final title = riskFactors[widget.index]["title"]!;
    widget.report.riskAnswers[title] = hasRisk ?? false;
    widget.report.riskImages[title] = images;

    if (widget.index < riskFactors.length - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RiskFactorPage(report: widget.report, index: widget.index + 1),
        ),
      );
    } else {
      Navigator.push(
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
              /// SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// IMAGE CARD
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

                      /// DESCRIPTION CARD
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

                      /// QUESTION CARD
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

                      /// YES / NO
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

                      /// IMAGE UPLOAD
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

              /// FIXED NEXT BUTTON
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
