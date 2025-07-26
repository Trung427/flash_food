import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/food_service.dart';

class FoodProvider extends ChangeNotifier {
  List<FoodModel> _foods = [];
  bool _isLoading = false;
  String? _error;

  List<FoodModel> get foods => _foods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _foods = await FoodService.getFoods();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFood(FoodModel food) async {
    try {
      final newFood = await FoodService.addFood(food);
      _foods.add(newFood);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateFood(FoodModel food) async {
    try {
      final updated = await FoodService.updateFood(food);
      final idx = _foods.indexWhere((f) => f.id == food.id);
      if (idx != -1) {
        _foods[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFood(int id) async {
    try {
      await FoodService.deleteFood(id);
      _foods.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Hàm tìm kiếm món ăn theo từ khóa
  List<FoodModel> searchFoods(String keyword) {
    if (keyword.isEmpty) return _foods;
    final lower = keyword.toLowerCase();
    return _foods.where((food) =>
      food.name.toLowerCase().contains(lower)
    ).toList();
  }
} 