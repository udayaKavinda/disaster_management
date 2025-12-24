// lib/main.dart
import 'package:disaster_management/models/report_data.dart';
import 'package:disaster_management/pages/risk_factor_page.dart';
import 'package:disaster_management/utils/gn_list.dart';
import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../theme/app_theme.dart';

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

                // ---------- QUESTION CARD ----------
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
                            "If you are not at the site, what is the address of the location?",
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

                const SizedBox(height: 12),

                // ---------- OPTIONAL ADDRESS ----------
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: "Address (Optional)",
                  ),
                ),

                const SizedBox(height: 24),

                // ---------- NEXT ----------
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    child: const Text("Next"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        report.ownerName = _ownerName.text.trim();
                        report.contact = _ownerContact.text.trim();
                        report.address = _address.text.trim();
                        report.district = _selectedDistrict!;
                        report.gnDivision = _gnController.text.trim();

                        Navigator.pushNamed(
                          context,
                          AppRoutes.riskFactor,
                          arguments: {'report': report, 'index': 0},
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
