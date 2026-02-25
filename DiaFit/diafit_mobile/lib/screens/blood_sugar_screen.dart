import 'package:flutter/material.dart';
import '../models/health_models.dart';
import '../services/health_service.dart';

class BloodSugarScreen extends StatefulWidget {
  const BloodSugarScreen({super.key});

  @override
  State<BloodSugarScreen> createState() => _BloodSugarScreenState();
}

class _BloodSugarScreenState extends State<BloodSugarScreen> {
  final _service = HealthService();
  final _sugarCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _heartCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _measurementType = 'Fasting';
  List<HealthLog> _logs = [];
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _loading = true);
    _logs = await _service.getHealthLogs();
    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (_sugarCtrl.text.isEmpty) return;
    setState(() => _submitting = true);
    final log = HealthLog(
      bloodSugarLevel: double.tryParse(_sugarCtrl.text) ?? 0,
      measurementType: _measurementType,
      stepsCount: int.tryParse(_stepsCtrl.text),
      heartRate: int.tryParse(_heartCtrl.text),
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
    );
    final ok = await _service.addHealthLog(log);
    setState(() => _submitting = false);
    if (ok) {
      _sugarCtrl.clear(); _stepsCtrl.clear(); _heartCtrl.clear(); _notesCtrl.clear();
      _fetchLogs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Health log saved!'), backgroundColor: Color(0xFF00D4FF)));
    }
  }

  Color _sugarColor(double val) {
    if (val < 70) return Colors.orange;
    if (val <= 140) return const Color(0xFF00D4FF);
    if (val <= 180) return Colors.yellow;
    return Colors.redAccent;
  }

  String _sugarStatus(double val) {
    if (val < 70) return 'Low';
    if (val <= 140) return 'Normal';
    if (val <= 180) return 'High';
    return 'Very High';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Blood Sugar Log', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00D4FF)), onPressed: _fetchLogs)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input card
            _card(children: [
              const Text('Log New Reading', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _field(_sugarCtrl, 'Blood Sugar (mg/dL) *', Icons.water_drop, TextInputType.number),
              const SizedBox(height: 12),
              _dropdown('Measurement Type', _measurementType, ['Fasting', 'PostMeal', 'Random'],
                (v) => setState(() => _measurementType = v!)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_stepsCtrl, 'Steps', Icons.directions_walk, TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _field(_heartCtrl, 'Heart Rate', Icons.favorite, TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              _field(_notesCtrl, 'Notes (optional)', Icons.notes, TextInputType.text),
              const SizedBox(height: 16),
              _gradientButton(_submitting ? 'Saving...' : 'Save Log', _submitting ? null : _submit),
            ]),
            const SizedBox(height: 24),

            // History
            const Text('Recent Logs', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
              : _logs.isEmpty
                ? _emptyState('No logs yet. Add your first reading above!')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _logs.length,
                    itemBuilder: (_, i) {
                      final log = _logs[i];
                      final color = _sugarColor(log.bloodSugarLevel);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2940),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: color.withOpacity(0.5)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text(
                              '${log.bloodSugarLevel.toStringAsFixed(0)}',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_sugarStatus(log.bloodSugarLevel),
                              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                            Text(log.measurementType,
                              style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                            if (log.stepsCount != null)
                              Text('👟 ${log.stepsCount} steps  ❤️ ${log.heartRate ?? "-"} bpm',
                                style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                          ])),
                          Text(_formatDate(log.loggedAt),
                            style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11)),
                        ]),
                      );
                    }),
          ],
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, TextInputType type) =>
    TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Color(0xFF4A5568)),
        prefixIcon: Icon(icon, color: const Color(0xFF8899AA), size: 18),
        filled: true, fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D4060))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D4060))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00D4FF))),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) =>
    DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1A2940),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true, fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D4060))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D4060))),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );

  Widget _gradientButton(String label, VoidCallback? onTap) => SizedBox(
    width: double.infinity, height: 48,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)]),
        borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ),
  );

  Widget _emptyState(String msg) => Center(
    child: Padding(padding: const EdgeInsets.all(24),
      child: Text(msg, style: const TextStyle(color: Color(0xFF8899AA)), textAlign: TextAlign.center)));

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() { _sugarCtrl.dispose(); _stepsCtrl.dispose(); _heartCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }
}
