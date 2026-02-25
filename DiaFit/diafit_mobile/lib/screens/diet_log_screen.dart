import 'package:flutter/material.dart';
import '../models/health_models.dart';
import '../services/health_service.dart';

class DietLogScreen extends StatefulWidget {
  const DietLogScreen({super.key});
  @override
  State<DietLogScreen> createState() => _DietLogScreenState();
}

class _DietLogScreenState extends State<DietLogScreen> {
  final _service = HealthService();
  final _foodCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _mealType = 'Lunch';
  List<DietLog> _logs = [];
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() { super.initState(); _fetchLogs(); }

  Future<void> _fetchLogs() async {
    setState(() => _loading = true);
    _logs = await _service.getDietLogs();
    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (_foodCtrl.text.isEmpty) return;
    setState(() => _submitting = true);
    final log = DietLog(
      foodName: _foodCtrl.text.trim(),
      mealType: _mealType,
      calories: double.tryParse(_calCtrl.text) ?? 0,
      carbohydratesGrams: double.tryParse(_carbCtrl.text) ?? 0,
      proteinGrams: double.tryParse(_proteinCtrl.text) ?? 0,
      fatGrams: double.tryParse(_fatCtrl.text) ?? 0,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
    );
    final ok = await _service.addDietLog(log);
    setState(() => _submitting = false);
    if (ok) {
      _foodCtrl.clear(); _calCtrl.clear(); _carbCtrl.clear();
      _proteinCtrl.clear(); _fatCtrl.clear(); _notesCtrl.clear();
      _fetchLogs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Diet log saved!'), backgroundColor: Color(0xFF00D4FF)));
    }
  }

  Color _suitabilityColor(String s) {
    switch (s) {
      case 'Suitable': return const Color(0xFF00D4FF);
      case 'Limited': return Colors.orange;
      case 'NotRecommended': return Colors.redAccent;
      default: return const Color(0xFF8899AA);
    }
  }

  IconData _mealIcon(String type) {
    switch (type) {
      case 'Breakfast': return Icons.free_breakfast;
      case 'Dinner': return Icons.dinner_dining;
      case 'Snack': return Icons.cookie;
      default: return Icons.lunch_dining;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Diet Log', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00D4FF)), onPressed: _fetchLogs)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _card(children: [
            const Text('Log Meal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _field(_foodCtrl, 'Food Name *', Icons.fastfood),
            const SizedBox(height: 12),
            _dropdown('Meal Type', _mealType, ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
              (v) => setState(() => _mealType = v!)),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            _field(_notesCtrl, 'Notes (optional)', Icons.notes),
            const SizedBox(height: 16),
            _gradientButton(_submitting ? 'Saving...' : 'Save Meal', _submitting ? null : _submit),
          ]),
          const SizedBox(height: 24),
          const Text('Recent Meals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
            : _logs.isEmpty
              ? _emptyState('No meals logged yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _logs.length,
                  itemBuilder: (_, i) {
                    final log = _logs[i];
                    final sc = _suitabilityColor(log.suitabilityResult);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2940),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: sc.withOpacity(0.4)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: sc.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(_mealIcon(log.mealType), color: sc, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(log.foodName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('${log.mealType} • ${log.calories.toStringAsFixed(0)} kcal',
                            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                          Text('C:${log.carbohydratesGrams.toStringAsFixed(0)}g  P:${log.proteinGrams.toStringAsFixed(0)}g  F:${log.fatGrams.toStringAsFixed(0)}g',
                            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: sc.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text(log.suitabilityResult, style: TextStyle(color: sc, fontSize: 10)),
                        ),
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
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged);

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
  void dispose() { _foodCtrl.dispose(); _calCtrl.dispose(); _carbCtrl.dispose();
    _proteinCtrl.dispose(); _fatCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }
}
