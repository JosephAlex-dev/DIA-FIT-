import 'package:flutter/material.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});
  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  int _dailyStepGoal = 8000;
  int _currentSteps = 0;
  final _stepsCtrl = TextEditingController();

  final List<Map<String, dynamic>> _activities = [
    {'name': 'Morning Walk', 'duration': '30 min', 'calories': 150, 'icon': Icons.directions_walk, 'done': false},
    {'name': 'Light Stretching', 'duration': '15 min', 'calories': 50, 'icon': Icons.self_improvement, 'done': false},
    {'name': 'Cycling', 'duration': '20 min', 'calories': 200, 'icon': Icons.directions_bike, 'done': false},
    {'name': 'Swimming', 'duration': '30 min', 'calories': 300, 'icon': Icons.pool, 'done': false},
    {'name': 'Yoga', 'duration': '30 min', 'calories': 120, 'icon': Icons.sports_gymnastics, 'done': false},
  ];

  double get _progress => _dailyStepGoal > 0 ? (_currentSteps / _dailyStepGoal).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('🏃 Fitness Planner', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Step Goal Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Daily Step Goal', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text('$_dailyStepGoal steps', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress, minHeight: 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('$_currentSteps done', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${(_progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // Log steps
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _stepsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Log steps walked today', hintStyle: TextStyle(color: Color(0xFF4A5568)),
                  prefixIcon: Icon(Icons.directions_walk, color: Color(0xFF8899AA)),
                  border: InputBorder.none),
              )),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  final steps = int.tryParse(_stepsCtrl.text) ?? 0;
                  setState(() { _currentSteps = steps; _stepsCtrl.clear(); });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)]),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Text('Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          const Text('Suggested Activities', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activities.length,
            itemBuilder: (_, i) {
              final act = _activities[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2940),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: act['done'] ? const Color(0xFF00D4FF).withOpacity(0.5) : const Color(0xFF2D4060))),
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: (act['done'] ? const Color(0xFF00D4FF) : const Color(0xFF7B2FBE)).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(act['icon'] as IconData,
                      color: act['done'] ? const Color(0xFF00D4FF) : const Color(0xFF7B2FBE))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(act['name'] as String, style: TextStyle(color: act['done'] ? const Color(0xFF00D4FF) : Colors.white, fontWeight: FontWeight.bold)),
                    Text('${act['duration']} • ${act['calories']} kcal', style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                  ])),
                  Checkbox(
                    value: act['done'] as bool,
                    activeColor: const Color(0xFF00D4FF),
                    onChanged: (v) => setState(() => _activities[i]['done'] = v ?? false)),
                ]),
              );
            }),
        ]),
      ),
    );
  }

  @override
  void dispose() { _stepsCtrl.dispose(); super.dispose(); }
}
