import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction.dart';

class HistoryService {
  static const _key = "history_predictions";

  Future<void> add(Prediction p) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(p.toJson()));
    await prefs.setStringList(_key, list);
  }

  Future<List<Prediction>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => Prediction.fromJson(jsonDecode(s))).toList().reversed.toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
