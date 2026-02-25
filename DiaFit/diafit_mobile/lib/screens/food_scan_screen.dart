import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});
  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  final _foodCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  static const String _baseUrl = 'http://localhost:5103/api/food/analyze';

  Future<void> _analyze() async {
    if (_foodCtrl.text.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    final token = await TokenStorage.read();
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'foodName': _foodCtrl.text.trim(),
        'calories': double.tryParse(_calCtrl.text) ?? 0,
        'carbohydratesGrams': double.tryParse(_carbCtrl.text) ?? 0,
        'proteinGrams': double.tryParse(_proteinCtrl.text) ?? 0,
        'fatGrams': double.tryParse(_fatCtrl.text) ?? 0,
      }),
    );
    setState(() { _loading = false; });
    if (res.statusCode == 200) setState(() => _result = jsonDecode(res.body));
  }

  Color _suitColor(String? s) {
    switch (s) {
      case 'Suitable': return const Color(0xFF00D4FF);
      case 'Limited': return Colors.orange;
      case 'NotRecommended': return Colors.redAccent;
      default: return const Color(0xFF8899AA);
    }
  }

  IconData _suitIcon(String? s) {
    switch (s) {
      case 'Suitable': return Icons.check_circle;
      case 'Limited': return Icons.warning_amber;
      case 'NotRecommended': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('🤖 AI Food Analyzer', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF00D4FF).withOpacity(0.1),
                const Color(0xFF7B2FBE).withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3))),
            child: const Row(children: [
              Icon(Icons.psychology, color: Color(0xFF00D4FF), size: 32),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Diabetic Food Suitability', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Enter food info to get instant AI analysis', style: TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Input form
          _card(children: [
            _field(_foodCtrl, 'Food Name *', Icons.fastfood),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_calCtrl, 'Calories', Icons.local_fire_department)),
              const SizedBox(width: 10),
              Expanded(child: _field(_carbCtrl, 'Carbs (g)', Icons.grain)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_proteinCtrl, 'Protein (g)', Icons.fitness_center)),
              const SizedBox(width: 10),
              Expanded(child: _field(_fatCtrl, 'Fat (g)', Icons.opacity)),
            ]),
            const SizedBox(height: 16),
            _gradientButton(_loading ? 'Analyzing...' : '🔍 Analyze Food', _loading ? null : _analyze),
          ]),

          // Result
          if (_result != null) ...[
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: 1, duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2940),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _suitColor(_result!['suitability']).withOpacity(0.6), width: 2)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(_suitIcon(_result!['suitability']), color: _suitColor(_result!['suitability']), size: 32),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_result!['foodName'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(_result!['suitability'] ?? '', style: TextStyle(color: _suitColor(_result!['suitability']), fontWeight: FontWeight.bold)),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: _suitColor(_result!['suitability']).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('GI: ${(_result!['glycemicScore'] as num).toStringAsFixed(0)}',
                        style: TextStyle(color: _suitColor(_result!['suitability']), fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text(_result!['reason'] ?? '', style: const TextStyle(color: Color(0xFFCCDDEE), fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _suitColor(_result!['suitability']).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(_result!['tip'] ?? '', style: TextStyle(color: _suitColor(_result!['suitability']), fontWeight: FontWeight.w600)),
                  ),
                  if ((_result!['warnings'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...(_result!['warnings'] as List).map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(w.toString(), style: const TextStyle(color: Colors.orange, fontSize: 12)))),
                  ],
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _field(TextEditingController ctrl, String hint, IconData icon) =>
    TextField(controller: ctrl, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF4A5568)),
        prefixIcon: Icon(icon, color: const Color(0xFF8899AA), size: 18),
        filled: true, fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D4060))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D4060))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00D4FF))),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12)));

  Widget _gradientButton(String label, VoidCallback? onTap) => SizedBox(
    width: double.infinity, height: 48,
    child: DecoratedBox(
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)]), borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))));

  @override
  void dispose() { _foodCtrl.dispose(); _calCtrl.dispose(); _carbCtrl.dispose(); _proteinCtrl.dispose(); _fatCtrl.dispose(); super.dispose(); }
}
