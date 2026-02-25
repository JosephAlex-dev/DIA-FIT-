import 'package:flutter/material.dart';
import '../models/health_models.dart';
import '../services/health_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});
  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _service = HealthService();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _frequency = 'Once Daily';
  List<MedicationLog> _logs = [];
  bool _loading = false;
  bool _submitting = false;
  DateTime _scheduledAt = DateTime.now();

  @override
  void initState() { super.initState(); _fetchLogs(); }

  Future<void> _fetchLogs() async {
    setState(() => _loading = true);
    _logs = await _service.getMedicationLogs();
    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _submitting = true);
    final log = MedicationLog(
      medicationName: _nameCtrl.text.trim(),
      dosageMg: double.tryParse(_dosageCtrl.text) ?? 0,
      frequency: _frequency,
      scheduledAt: _scheduledAt,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
    );
    final ok = await _service.addMedicationLog(log);
    setState(() => _submitting = false);
    if (ok) {
      _nameCtrl.clear(); _dosageCtrl.clear(); _notesCtrl.clear();
      _fetchLogs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Medication logged!'), backgroundColor: Color(0xFF00D4FF)));
    }
  }

  Future<void> _markTaken(int id) async {
    await _service.markMedicationTaken(id);
    _fetchLogs();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_scheduledAt));
    if (t != null) setState(() => _scheduledAt = DateTime(
      _scheduledAt.year, _scheduledAt.month, _scheduledAt.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Medication Log', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00D4FF)), onPressed: _fetchLogs)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _card(children: [
            const Text('Add Medication', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _field(_nameCtrl, 'Medication Name *', Icons.medication),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field(_dosageCtrl, 'Dosage (mg)', Icons.straighten)),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2D4060))),
                  child: Row(children: [
                    const Icon(Icons.access_time, color: Color(0xFF8899AA), size: 18),
                    const SizedBox(width: 8),
                    Text('${_scheduledAt.hour.toString().padLeft(2,'0')}:${_scheduledAt.minute.toString().padLeft(2,'0')}',
                      style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              )),
            ]),
            const SizedBox(height: 12),
            _dropdown('Frequency', _frequency, ['Once Daily', 'Twice Daily', 'As Needed'],
              (v) => setState(() => _frequency = v!)),
            const SizedBox(height: 12),
            _field(_notesCtrl, 'Notes (optional)', Icons.notes),
            const SizedBox(height: 16),
            _gradientButton(_submitting ? 'Saving...' : 'Add Medication', _submitting ? null : _submit),
          ]),
          const SizedBox(height: 24),
          const Text('Medication Schedule', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
            : _logs.isEmpty
              ? _emptyState('No medications logged yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _logs.length,
                  itemBuilder: (_, i) {
                    final log = _logs[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2940),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: log.isTaken
                          ? const Color(0xFF00D4FF).withOpacity(0.5)
                          : const Color(0xFF2D4060))),
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: (log.isTaken ? const Color(0xFF00D4FF) : Colors.orange).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.medication,
                            color: log.isTaken ? const Color(0xFF00D4FF) : Colors.orange, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(log.medicationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('${log.dosageMg.toStringAsFixed(0)} mg • ${log.frequency}',
                            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                          Text('⏰ ${log.scheduledAt.hour.toString().padLeft(2,'0')}:${log.scheduledAt.minute.toString().padLeft(2,'0')}',
                            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                        ])),
                        if (!log.isTaken)
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Color(0xFF00D4FF)),
                            onPressed: () => _markTaken(log.id!),
                            tooltip: 'Mark as taken'),
                        if (log.isTaken)
                          const Icon(Icons.check_circle, color: Color(0xFF00D4FF)),
                      ]),
                    );
                  }),
        ]),
      ),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _field(TextEditingController ctrl, String hint, IconData icon) =>
    TextField(controller: ctrl, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Color(0xFF4A5568)),
        prefixIcon: Icon(icon, color: const Color(0xFF8899AA), size: 18),
        filled: true, fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D4060))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D4060))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00D4FF))),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12)));

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) =>
    DropdownButtonFormField<String>(
      value: value, dropdownColor: const Color(0xFF1A2940), style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(filled: true, fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D4060))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D4060))),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12)),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged);

  Widget _gradientButton(String label, VoidCallback? onTap) => SizedBox(
    width: double.infinity, height: 48,
    child: DecoratedBox(
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)]),
        borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))));

  Widget _emptyState(String msg) => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Text(msg, style: const TextStyle(color: Color(0xFF8899AA)), textAlign: TextAlign.center)));

  @override
  void dispose() { _nameCtrl.dispose(); _dosageCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }
}
