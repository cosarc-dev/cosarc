import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:cosarc/models/food_log.dart';

/// ======================================================
/// 1. NUTRITION SERVICE (API + DATA SANITIZATION)
/// ======================================================
class NutritionService {
  static const String _endpoint =
      "https://world.openfoodfacts.org/cgi/search.pl";

  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    if (query.trim().length < 3) return [];

    final uri = Uri.parse(
      "$_endpoint"
      "?search_terms=$query"
      "&search_simple=1"
      "&action=process"
      "&json=1"
      "&page_size=25",
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) return [];

      final decoded = json.decode(response.body);
      final List products = decoded['products'] ?? [];

      final List<Map<String, dynamic>> results = [];

      for (final p in products) {
        final nutriments = p['nutriments'] ?? {};

        final String name =
            (p['product_name'] ?? "").toString().trim();

        if (name.isEmpty) continue;

        final double calories =
            _toDouble(nutriments['energy-kcal_100g']);
        if (calories <= 0) continue;

        results.add({
          'name': name,
          'calories': calories,
          'protein': _toDouble(nutriments['proteins_100g']),
          'carbs': _toDouble(nutriments['carbohydrates_100g']),
          'fat': _toDouble(nutriments['fat_100g']),
        });
      }

      return results;
    } catch (_) {
      return [];
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

/// ======================================================
/// 2. MAIN NUTRITION SCREEN
/// ======================================================
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final double dailyTarget = 2500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      appBar: AppBar(
        title: const Text(
          'FUEL LOG',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
        builder: (_, Box<FoodLog> box, __) {
          final now = DateTime.now();

          final todayLogs = box.values.where((log) =>
              log.dateTime.day == now.day &&
              log.dateTime.month == now.month &&
              log.dateTime.year == now.year).toList();

          final consumed = todayLogs.fold<double>(
              0, (sum, item) => sum + item.calories);

          return Column(
            children: [
              _summary(consumed),
              Expanded(child: _foodList(todayLogs)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _openSearch(context),
      ),
    );
  }

  Widget _summary(double consumed) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat("CONSUMED", consumed.toInt()),
          CircularProgressIndicator(
            value: (consumed / dailyTarget).clamp(0.0, 1.0),
            strokeWidth: 6,
            color: Colors.pinkAccent,
          ),
          _stat("REMAINING", (dailyTarget - consumed).toInt()),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(
          "$value",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _foodList(List<FoodLog> logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final log = logs[i];
        return ListTile(
          title: Text(log.name),
          subtitle: Text(
            "${log.calories.toInt()} kcal · ${log.mealType} · ${log.quantity}g",
            style: const TextStyle(color: Colors.pinkAccent),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38),
            onPressed: () => log.delete(),
          ),
        );
      },
    );
  }

  void _openSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      builder: (_) => const FoodSearchComponent(),
    );
  }
}

/// ======================================================
/// 3. SEARCH + LOGGING UI
/// ======================================================
class FoodSearchComponent extends StatefulWidget {
  const FoodSearchComponent({super.key});

  @override
  State<FoodSearchComponent> createState() => _FoodSearchComponentState();
}

class _FoodSearchComponentState extends State<FoodSearchComponent> {
  final NutritionService _service = NutritionService();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  double _quantity = 100;
  String _mealType = "Lunch";

  void _search(String query) async {
    setState(() => _loading = true);
    final data = await _service.searchFood(query);
    setState(() {
      _results = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          _searchBar(),
          _controls(),
          if (_loading)
            const LinearProgressIndicator(color: Colors.pinkAccent),
          Expanded(child: _resultList()),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        onChanged: _search,
        decoration: const InputDecoration(
          hintText: "Search food...",
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Slider(
            value: _quantity,
            min: 10,
            max: 500,
            divisions: 49,
            label: "${_quantity.toInt()} g",
            onChanged: (v) => setState(() => _quantity = v),
          ),
          DropdownButton<String>(
            value: _mealType,
            items: const [
              DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
              DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
              DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
              DropdownMenuItem(value: "Snack", child: Text("Snack")),
            ],
            onChanged: (v) => setState(() => _mealType = v!),
          ),
        ],
      ),
    );
  }

  Widget _resultList() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final item = _results[i];
        final factor = _quantity / 100;

        return ListTile(
          title: Text(item['name']),
          subtitle: Text(
            "${(item['calories'] * factor).toInt()} kcal · ${_quantity.toInt()}g",
          ),
          onTap: () {
            Hive.box<FoodLog>('daily_logs').add(
              FoodLog(
                name: item['name'],
                calories: item['calories'] * factor,
                protein: item['protein'] * factor,
                carbs: item['carbs'] * factor,
                fat: item['fat'] * factor,
                quantity: _quantity,
                mealType: _mealType,
                dateTime: DateTime.now(),
              ),
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }
}