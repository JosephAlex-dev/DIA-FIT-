import 'package:flutter/material.dart';
import 'package:diafit_mobile/services/token_storage.dart';

class DashboardScreen extends StatelessWidget {
  final String? userName;
  const DashboardScreen({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good ${_greeting()}, 👋', style: const TextStyle(color: Color(0xFF8899AA), fontSize: 14)),
            Text(userName ?? 'DiaFit User', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const Spacer(),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2D4060))),
            child: const Icon(Icons.notifications_outlined, color: Color(0xFF8899AA))),
        ]),
        const SizedBox(height: 24),

        // Health Status Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Blood Sugar Status', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('Log your readings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Text('Tap to log today\'s reading', style: TextStyle(color: Colors.white, fontSize: 12))),
            ])),
            const Icon(Icons.water_drop, color: Colors.white, size: 60),
          ]),
        ),
        const SizedBox(height: 24),

        // Quick Stats Row
        const Text('Today\'s Summary', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          _StatCard(label: 'Blood Sugar', value: '-- mg/dL', icon: Icons.water_drop, color: const Color(0xFF00D4FF)),
          const SizedBox(width: 12),
          _StatCard(label: 'Steps', value: '-- steps', icon: Icons.directions_walk, color: const Color(0xFF7B2FBE)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatCard(label: 'Calories', value: '-- kcal', icon: Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 12),
          _StatCard(label: 'Medications', value: '-- taken', icon: Icons.medication, color: Colors.greenAccent),
        ]),
        const SizedBox(height: 24),

        // Quick Actions
        const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2,
          children: [
            _QuickAction(label: '💧 Log Blood Sugar', color: const Color(0xFF00D4FF)),
            _QuickAction(label: '🍽️ Log Meal', color: const Color(0xFF7B2FBE)),
            _QuickAction(label: '💊 Medications', color: Colors.orange),
            _QuickAction(label: '🤖 Analyze Food', color: Colors.greenAccent),
          ],
        ),
        const SizedBox(height: 24),

        // Health Tips
        const Text('Health Tips for Diabetics', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._tips.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Text(t['emoji']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(t['desc']!, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
            ])),
          ]),
        )),
      ]),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  static const List<Map<String, String>> _tips = [
    {'emoji': '🥗', 'title': 'Eat Low-GI Foods', 'desc': 'Choose whole grains, legumes, and non-starchy vegetables.'},
    {'emoji': '💧', 'title': 'Stay Hydrated', 'desc': 'Drink at least 8 glasses of water daily to support blood sugar control.'},
    {'emoji': '🏃', 'title': 'Exercise Daily', 'desc': 'Even a 30-minute walk can significantly lower blood sugar levels.'},
    {'emoji': '😴', 'title': 'Sleep Well', 'desc': 'Poor sleep raises blood sugar and insulin resistance.'},
  ];
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext ctx) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ])),
    ]),
  ));
}

class _QuickAction extends StatelessWidget {
  final String label;
  final Color color;
  const _QuickAction({required this.label, required this.color});
  @override
  Widget build(BuildContext ctx) => Container(
    decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Center(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))));
}
