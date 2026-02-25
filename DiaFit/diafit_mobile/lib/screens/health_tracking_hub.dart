import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/blood_sugar_screen.dart';
import '../screens/diet_log_screen.dart';
import '../screens/medication_screen.dart';
import '../screens/food_scan_screen.dart';
import '../screens/fitness_screen.dart';
import '../screens/emergency_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HealthTrackingHub extends StatefulWidget {
  const HealthTrackingHub({super.key});

  @override
  State<HealthTrackingHub> createState() => _HealthTrackingHubState();
}

class _HealthTrackingHubState extends State<HealthTrackingHub> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    BloodSugarScreen(),
    DietLogScreen(),
    MedicationScreen(),
    FoodScanScreen(),
    FitnessScreen(),
    EmergencyScreen(),
  ];

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)]),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.monitor_heart, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('DiaFit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
        actions: [
          // Emergency FAB button in appbar
          if (_currentIndex != 6)
            IconButton(
              icon: const Icon(Icons.sos, color: Colors.redAccent),
              tooltip: 'Emergency',
              onPressed: () => setState(() => _currentIndex = 6),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8899AA)),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2940),
          border: Border(top: BorderSide(color: Color(0xFF2D4060))),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: const Color(0xFF00D4FF),
          unselectedItemColor: const Color(0xFF4A5568),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Sugar'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
            BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Meds'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Food'),
            BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: 'Fitness'),
            BottomNavigationBarItem(icon: Icon(Icons.sos, color: Colors.redAccent), label: 'SOS'),
          ],
        ),
      ),
    );
  }
}
