import 'package:hive/hive.dart';

class FoodLog extends HiveObject {
  String name;
  double calories;
  double protein;
  double carbs;
  double fat;
  double quantity; // grams
  String mealType; // breakfast, lunch, dinner, snack
  DateTime dateTime;

  FoodLog({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
    required this.mealType,
    required this.dateTime,
  });

  // 👇 Helpers (extra lines, useful later)
  bool get isBreakfast => mealType == "Breakfast";
  bool get isLunch => mealType == "Lunch";
  bool get isDinner => mealType == "Dinner";
  bool get isSnack => mealType == "Snack";

  double get caloriesPerGram {
    if (quantity == 0) return 0;
    return calories / quantity;
  }
}
