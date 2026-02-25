import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_models.dart';
import 'token_storage.dart';

class HealthService {
  // Android emulator → use 'http://10.0.2.2:5103/api'
  // Windows desktop → use 'http://localhost:5103/api'
  static const String _baseUrl = 'http://localhost:5103/api';

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.read();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Health Logs ─────────────────────────────────────
  Future<List<HealthLog>> getHealthLogs() async {
    final res = await http.get(Uri.parse('$_baseUrl/healthlog'), headers: await _authHeaders());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => HealthLog.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> addHealthLog(HealthLog log) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/healthlog'),
      headers: await _authHeaders(),
      body: jsonEncode(log.toJson()),
    );
    return res.statusCode == 201;
  }

  Future<bool> deleteHealthLog(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/healthlog/$id'), headers: await _authHeaders());
    return res.statusCode == 204;
  }

  // ── Diet Logs ────────────────────────────────────────
  Future<List<DietLog>> getDietLogs() async {
    final res = await http.get(Uri.parse('$_baseUrl/dietlog'), headers: await _authHeaders());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => DietLog.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> addDietLog(DietLog log) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/dietlog'),
      headers: await _authHeaders(),
      body: jsonEncode(log.toJson()),
    );
    return res.statusCode == 201;
  }

  Future<bool> deleteDietLog(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/dietlog/$id'), headers: await _authHeaders());
    return res.statusCode == 204;
  }

  // ── Medication Logs ──────────────────────────────────
  Future<List<MedicationLog>> getMedicationLogs() async {
    final res = await http.get(Uri.parse('$_baseUrl/medicationlog'), headers: await _authHeaders());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => MedicationLog.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> addMedicationLog(MedicationLog log) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/medicationlog'),
      headers: await _authHeaders(),
      body: jsonEncode(log.toJson()),
    );
    return res.statusCode == 201;
  }

  Future<bool> markMedicationTaken(int id) async {
    final res = await http.patch(Uri.parse('$_baseUrl/medicationlog/$id/taken'), headers: await _authHeaders());
    return res.statusCode == 200;
  }

  Future<bool> deleteMedicationLog(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/medicationlog/$id'), headers: await _authHeaders());
    return res.statusCode == 204;
  }
}
