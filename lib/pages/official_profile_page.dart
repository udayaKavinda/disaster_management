import 'package:flutter/material.dart';
import '../services/report_service.dart'; // reuse or create official service
import 'home_page.dart'; // for HomePage

class OfficialProfilePage extends StatefulWidget {
  const OfficialProfilePage({super.key});

  @override
  State<OfficialProfilePage> createState() => _OfficialProfilePageState();
}

class _OfficialProfilePageState extends State<OfficialProfilePage> {
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String? _role;

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final success = await ReportService.saveOfficialDetails(
      name: _nameCtrl.text.trim(),
      contact: _contactCtrl.text.trim(),
      title: _role!,
    );

    setState(() => _saving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } else {
      _showError("Failed", "Could not save details. Please try again.");
    }
  }

  void _showError(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width.clamp(320.0, 480.0);

    return Scaffold(
      // ---------- TOP BAR ----------
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
        title: const Text(
          "Official Details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ---------- HUMAN ICON ----------
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Icon(
                        Icons.person,
                        size: 90,
                        color: Colors.lightBlue.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------- NAME ----------
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? "Name is required" : null,
                  ),

                  const SizedBox(height: 14),

                  // ---------- CONTACT ----------
                  TextFormField(
                    controller: _contactCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Contact Number",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) {
                      if (v!.trim().length < 10) {
                        return "Enter a valid contact number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // ---------- ROLE ----------
                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(
                      labelText: "Official Role",
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Grama Niladhari",
                        child: Text("Grama Niladhari"),
                      ),
                      DropdownMenuItem(
                        value: "District Secretariat",
                        child: Text("District Secretariat"),
                      ),
                    ],
                    onChanged: (v) => setState(() => _role = v),
                    validator: (v) => v == null ? "Please select a role" : null,
                  ),

                  const Spacer(),

                  // ---------- SAVE BUTTON ----------
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _saving ? "Saving..." : "Save Details",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _saving
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _save();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
