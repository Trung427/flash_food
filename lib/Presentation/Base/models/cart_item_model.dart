import 'food_model.dart';

class CartItem {
  final FoodModel food;
  int quantity;
 
  CartItem({required this.food, this.quantity = 1});
} 