// lib/main.dart
import 'package:landslide_risk_reporter/models/report_data.dart';
import 'package:landslide_risk_reporter/utils/gn_list.dart';
import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/dialog_utils.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});
  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _ownerName = TextEditingController();
  final _ownerContact = TextEditingController();
  final _address = TextEditingController();
  final _gnController = TextEditingController();

  String? _selectedDistrict;
  List<String> gnSuggestions = [];
  bool? _useCurrentLocation;
  bool _capturingLocation = false;

  final _formKey = GlobalKey<FormState>();
  final SubmitReport report = SubmitReport();

  final List<String> districts = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Mullaitivu",
    "Vavuniya",
    "Puttalam",
    "Kurunegala",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle",
    "Trincomalee",
    "Batticaloa",
    "Ampara",
  ];

  @override
  void dispose() {
    _ownerName.dispose();
    _ownerContact.dispose();
    _address.dispose();
    _gnController.dispose();
    super.dispose();
  }

  // ================= LOCATION CAPTURE =================
  Future<Position?> _getLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return null;
    if (!serviceEnabled) {
      DialogUtils.showAlertDialog(
        context,
        title: "Location Disabled",
        message: "Please enable location services to continue.",
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
        message: "Location permission is required to continue.",
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ------------------ FUZZY MATCH ------------------
  List<String> getFuzzyGNSuggestions(String query) {
    if (_selectedDistrict == null ||
        !locations.containsKey(_selectedDistrict!)) {
      return [];
    }

    final gnList = locations[_selectedDistrict!]!
        .map((e) => e['name']!)
        .toList();

    final scored = gnList.map((gn) {
      return {
        'name': gn,
        'score': ratio(query.toLowerCase(), gn.toLowerCase()),
      };
    }).toList();

    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return scored.map((e) => e['name'] as String).take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width.clamp(320.0, 480.0);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text(
          'Report Risk',
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
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // ---------- ADMINISTRATIVE AREA ----------
                Text(
                  "Administrative Area",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  decoration: const InputDecoration(labelText: "District"),
                  items: districts
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedDistrict = v;
                      _gnController.clear();
                      gnSuggestions.clear();
                    });
                  },
                  validator: (v) =>
                      v == null ? "Please select a district" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _gnController,
                  decoration: const InputDecoration(
                    labelText: "Grama Niladhari Division",
                  ),
                  onChanged: (v) {
                    setState(() {
                      gnSuggestions = getFuzzyGNSuggestions(v);
                    });
                  },
                  validator: (v) => v == null || v.isEmpty
                      ? "Please select a GN division"
                      : null,
                ),

                ...gnSuggestions.map(
                  (gn) => ListTile(
                    title: Text(gn),
                    onTap: () {
                      setState(() {
                        _gnController.text = gn;
                        gnSuggestions.clear();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ---------- OWNER DETAILS ----------
                Text(
                  "House Owner Details (Optional)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _ownerName,
                  decoration: const InputDecoration(
                    labelText: "Owner Name (Optional)",
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _ownerContact,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Contact Number (Optional)",
                  ),
                ),

                const SizedBox(height: 24),

                // ---------- LOCATION QUESTION ----------
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: AppTheme.accentDark,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Location access is required to verify the site location. Are you at the site right now?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ---------- YES/NO BUTTONS ----------
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _useCurrentLocation = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _useCurrentLocation == true
                              ? AppTheme.buttonPrimaryDark
                              : Colors.grey[300],
                        ),
                        child: Text(
                          "YES",
                          style: TextStyle(
                            color: _useCurrentLocation == true
                                ? AppTheme.white
                                : AppTheme.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _useCurrentLocation = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _useCurrentLocation == false
                              ? AppTheme.buttonPrimaryDark
                              : Colors.grey[300],
                        ),
                        child: Text(
                          "NO",
                          style: TextStyle(
                            color: _useCurrentLocation == false
                                ? AppTheme.white
                                : AppTheme.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------- CONDITIONAL ADDRESS FIELD ----------
                if (_useCurrentLocation == false)
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(
                      labelText: "Address of the site (Required)",
                    ),
                    validator: (v) =>
                        _useCurrentLocation == false && (v == null || v.isEmpty)
                        ? "Address is required when not using current location"
                        : null,
                  ),

                const SizedBox(height: 24),

                // ---------- NEXT ----------
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    child: Text(
                      _capturingLocation ? "Capturing Location..." : "Next",
                    ),
                    onPressed: _capturingLocation
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate() &&
                                _useCurrentLocation != null) {
                              report.ownerName = _ownerName.text.trim();
                              report.contact = _ownerContact.text.trim();
                              report.address = _address.text.trim();
                              report.district = _selectedDistrict!;
                              report.gnDivision = _gnController.text.trim();

                              if (_useCurrentLocation == true) {
                                setState(() => _capturingLocation = true);
                                final position = await _getLocation(context);
                                setState(() => _capturingLocation = false);

                                if (!mounted) return;

                                if (position == null) {
                                  // Location capture failed - don't proceed
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Unable to capture location. Please enable location services and grant permission.",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                report.latitude = position.latitude;
                                report.longitude = position.longitude;
                              }

                              if (!mounted) return;

                              Navigator.pushNamed(
                                context,
                                AppRoutes.riskFactor,
                                arguments: {'report': report, 'index': 0},
                              );
                            } else if (_useCurrentLocation == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select Yes or No for location",
                                  ),
                                ),
                              );
                            }
                          },
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
