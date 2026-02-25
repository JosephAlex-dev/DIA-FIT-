import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _alertSent = false;
  bool _sending = false;
  List<Map<String, dynamic>> _contacts = [];
  bool _loadingContacts = true;

  static const String _baseUrl = 'http://localhost:5103/api';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final token = await TokenStorage.read();
    final res = await http.get(Uri.parse('$_baseUrl/emergencycontact'),
      headers: {'Authorization': 'Bearer $token'});
    setState(() {
      _loadingContacts = false;
      if (res.statusCode == 200) _contacts = List<Map<String, dynamic>>.from(jsonDecode(res.body));
    });
  }

  Future<void> _sendAlert() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulated SMS send
    setState(() { _sending = false; _alertSent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('🚨 Emergency System', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Emergency Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
            child: Column(children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 8),
              const Text('Emergency Alert System', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('In case of diabetic emergency, press the button below to alert your emergency contacts.',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _alertSent
                ? Column(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF00D4FF), size: 48),
                    const SizedBox(height: 8),
                    const Text('✅ Emergency Alert Sent!', style: TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Your contacts have been notified.', style: TextStyle(color: Color(0xFF8899AA))),
                  ])
                : AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: GestureDetector(
                        onTap: _sending ? null : _sendAlert,
                        child: Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                            boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)]),
                          child: Center(child: _sending
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.sos, color: Colors.white, size: 36),
                                Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              ])),
                        ),
                      ),
                    ),
                  ),
            ]),
          ),
          const SizedBox(height: 24),

          // Emergency Contacts
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Emergency Contacts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00D4FF)), onPressed: () { setState(() => _loadingContacts = true); _loadContacts(); }),
          ]),
          const SizedBox(height: 12),
          _loadingContacts
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
            : _contacts.isEmpty
              ? _AddContactCard(onRefresh: _loadContacts)
              : Column(children: _contacts.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c['isPrimary'] == true ? Colors.redAccent.withOpacity(0.5) : const Color(0xFF2D4060))),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person, color: Colors.redAccent)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${c['relationship']} • ${c['phoneNumber']}', style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                    ])),
                    if (c['isPrimary'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text('Primary', style: TextStyle(color: Colors.redAccent, fontSize: 11))),
                  ]),
                )).toList()),

          const SizedBox(height: 20),
          // Blood Sugar Threshold Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(14)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('⚡ Auto-Alert Thresholds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _ThresholdRow(label: 'Hypoglycemia (Low)', value: '< 70 mg/dL', color: Colors.orange),
              _ThresholdRow(label: 'Hyperglycemia (High)', value: '> 300 mg/dL', color: Colors.redAccent),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }
}

class _ThresholdRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ThresholdRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13)),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    ]));
}

class _AddContactCard extends StatelessWidget {
  final VoidCallback onRefresh;
  const _AddContactCard({required this.onRefresh});
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF2D4060), style: BorderStyle.solid)),
    child: const Column(children: [
      Icon(Icons.person_add, color: Color(0xFF8899AA), size: 40),
      SizedBox(height: 8),
      Text('No emergency contacts yet', style: TextStyle(color: Colors.white)),
      Text('Add contacts from the Profile section', style: TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
    ]));
}
