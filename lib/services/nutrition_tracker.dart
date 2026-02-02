import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cosarc/models/food_log.dart';

// Cosarc Cinematic Palette
const Color cosarcPink = Color(0xFFE91E63);
const Color cosarcDark = Color(0xFF080808);
const Color cosarcSurface = Color(0xFF141414);
const Color cosarcAccent = Color(0xFF00E676); // Progress Green

/// ======================================================
/// 1. NUTRITION SERVICE (India-Specific Logic)
/// ======================================================
class NutritionService {
  static const String _baseUrl = 'https://in.openfoodfacts.org/cgi/search.pl';

  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    if (query.trim().length < 3) return [];

    final url = Uri.parse(
      '$_baseUrl?search_terms=$query&search_simple=1&action=process&json=1&page_size=30&cc=in&lc=en&sort_by=unique_scans_n'
    );
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List products = data['products'] ?? [];

        return products.map((p) {
          final n = p['nutriments'] ?? {};
          final String name = p['product_name'] ?? 'Unknown Item';
          final String brands = p['brands'] ?? 'Generic';
          
          double cals = _parse(n['energy-kcal_100g']);
          if (cals <= 0 && !name.toLowerCase().contains("water")) return null;

          return {
            'name': name,
            'brand': brands,
            'calories': cals,
            'protein': _parse(n['proteins_100g']),
            'carbs': _parse(n['carbohydrates_100g']),
            'fat': _parse(n['fat_100g']),
          };
        }).whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  double _parse(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

/// ======================================================
/// 2. MAIN FUEL LOG SCREEN
/// ======================================================
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final double dailyTarget = 2500;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cosarcDark,
      appBar: AppBar(
        title: const Text('FUEL LOG', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 13)),
        centerTitle: true, backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
        builder: (context, Box<FoodLog> box, _) {
          final now = DateTime.now();
          final logs = box.values.where((l) => l.dateTime.day == now.day && l.dateTime.month == now.month).toList();

          double tCal = logs.fold(0, (s, i) => s + i.calories);
          double tP = logs.fold(0, (s, i) => s + i.protein);
          double tC = logs.fold(0, (s, i) => s + i.carbs);
          double tF = logs.fold(0, (s, i) => s + i.fat);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildEnergyDashboard(tCal, tP, tC, tF)),
              
              _mealGroup("Breakfast", Icons.wb_twilight_rounded, logs.where((l) => l.mealType == "Breakfast").toList()),
              _mealGroup("Lunch", Icons.wb_sunny_rounded, logs.where((l) => l.mealType == "Lunch").toList()),
              _mealGroup("Dinner", Icons.dark_mode_rounded, logs.where((l) => l.mealType == "Dinner").toList()),
              _mealGroup("Snacks", Icons.cookie_outlined, logs.where((l) => l.mealType == "Snack").toList()),
              
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnergyDashboard(double c, double p, double carb, double f) {
    double rem = dailyTarget - c;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cosarcSurface, borderRadius: BorderRadius.circular(30)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _stat("REMAINING", rem < 0 ? "0" : rem.toInt().toString(), cosarcAccent),
          _stat("CONSUMED", c.toInt().toString(), cosarcPink),
        ]),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: (c/dailyTarget).clamp(0, 1), minHeight: 10, backgroundColor: Colors.white10, color: cosarcPink),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _miniMacro("PROT", p, Colors.blueAccent),
          _miniMacro("CARB", carb, Colors.orangeAccent),
          _miniMacro("FAT", f, Colors.purpleAccent),
        ])
      ]),
    );
  }

  Widget _stat(String l, String v, Color col) => Column(children: [
    Text(l, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
    Text(v, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: col)),
  ]);

  Widget _miniMacro(String l, double v, Color col) => Column(children: [
    Text(l, style: const TextStyle(color: Colors.white24, fontSize: 9)),
    Text("${v.toInt()}g", style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 15)),
  ]);

  Widget _mealGroup(String name, IconData icon, List<FoodLog> logs) {
    double mCals = logs.fold(0, (s, i) => s + i.calories);
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Row(children: [
          Icon(icon, color: cosarcPink, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Text("${mCals.toInt()} kcal", style: const TextStyle(color: Colors.white38)),
          const SizedBox(width: 10),
          IconButton(onPressed: () => _openSearch(context, name), icon: const Icon(Icons.add_circle, color: cosarcAccent, size: 28)),
        ]),
      )),
      SliverList(delegate: SliverChildBuilderDelegate((_, i) => _foodTile(logs[i]), childCount: logs.length)),
    ]);
  }

  Widget _foodTile(FoodLog log) => Dismissible(
    key: Key(log.dateTime.toString()),
    onDismissed: (_) => log.delete(),
    background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, child: const Icon(Icons.delete)),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(log.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text("${log.quantity.toInt()}g • P: ${log.protein.toInt()}g", style: const TextStyle(color: Colors.white24, fontSize: 11)),
        ])),
        Text("${log.calories.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ]),
    ),
  );

  void _openSearch(BuildContext context, String meal) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => FoodSearchComponent(preSelectedMeal: meal));
  }
}

/// ======================================================
/// 3. SMART SEARCH UI (Precision Portions + Debouncing)
/// ======================================================
class FoodSearchComponent extends StatefulWidget {
  final String preSelectedMeal;
  const FoodSearchComponent({super.key, required this.preSelectedMeal});
  @override
  State<FoodSearchComponent> createState() => _FoodSearchComponentState();
}

class _FoodSearchComponentState extends State<FoodSearchComponent> {
  final NutritionService _service = NutritionService();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: "100");
  
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _onSearch(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (q.length < 2) return;
      setState(() => _loading = true);
      final data = await _service.searchFood(q);
      if (mounted) setState(() { _results = data; _loading = false; });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double qty = double.tryParse(_qtyCtrl.text) ?? 1.0;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0F0F0F), borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(children: [
        const SizedBox(height: 15),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10))),
        
        Padding(padding: const EdgeInsets.all(20), child: TextField(
          controller: _searchCtrl, onChanged: _onSearch, autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search brands (Amul, Maggi, Oreo)...",
            prefixIcon: const Icon(Icons.search, color: cosarcPink),
            filled: true, fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)
          ),
        )),
        
        // Precision Portion Row
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
          const Text("PORTION:", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
            child: TextField(
              controller: _qtyCtrl, keyboardType: TextInputType.number, 
              style: const TextStyle(color: cosarcAccent, fontWeight: FontWeight.bold, fontSize: 20),
              decoration: const InputDecoration(border: InputBorder.none, suffixText: "grams", suffixStyle: TextStyle(color: Colors.white24)),
              onChanged: (_) => setState((){}),
            ),
          )),
          const SizedBox(width: 10),
          _qBtn(100), _qBtn(250),
        ])),

        if (_loading) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: cosarcPink, strokeWidth: 2)),
        
        Expanded(child: ListView.builder(itemCount: _results.length, padding: const EdgeInsets.all(16), itemBuilder: (_, i) {
          final item = _results[i];
          double f = qty / 100;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              title: Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text("${item['brand']} • P: ${(item['protein']*f).toStringAsFixed(1)}g", style: const TextStyle(color: Colors.white24, fontSize: 11)),
              trailing: Text("${(item['calories'] * f).toInt()} kcal", style: const TextStyle(color: cosarcPink, fontWeight: FontWeight.w900, fontSize: 18)),
              onTap: () {
                Hive.box<FoodLog>('daily_logs').add(FoodLog(
                  name: "${item['name']} (${item['brand']})",
                  calories: item['calories'] * f,
                  protein: item['protein'] * f,
                  carbs: item['carbs'] * f,
                  fat: item['fat'] * f,
                  quantity: qty,
                  mealType: widget.preSelectedMeal,
                  dateTime: DateTime.now(),
                ));
                Navigator.pop(context);
              },
            ),
          );
        })),
      ]),
    );
  }

  Widget _qBtn(int v) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: ActionChip(
      label: Text("${v}g", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), 
      onPressed: () => setState(() => _qtyCtrl.text = v.toString()),
      backgroundColor: Colors.white10,
    ),
  );
}