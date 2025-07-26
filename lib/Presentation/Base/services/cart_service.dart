import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item_model.dart';
import '../models/food_model.dart';

class CartService {
  final String baseUrl;
  final String token;

  CartService({required this.baseUrl, required this.token});

  Future<List<CartItem>> fetchCart() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final items = data['items'] as List;
        
        return items.map((item) => CartItem(
          food: FoodModel(
            id: item['food_id'],
            name: item['name'],
            description: '', // Backend không trả về description
            price: (item['price'] as num).toDouble(),
            images: item['images'] != null ? [item['images']] : [],
            category: '',
          ),
          quantity: item['quantity'],
        )).toList();
      } else {
        print('Error fetching cart: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to fetch cart: ${res.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchCart: $e');
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Future<void> addToCart(int foodId, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/cart/add'),
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'food_id': foodId, 'quantity': quantity}),
      );
      
      if (res.statusCode != 200) {
        print('Error adding to cart: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to add to cart: ${res.statusCode}');
      }
    } catch (e) {
      print('Exception in addToCart: $e');
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> updateCart(int foodId, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/cart/add'), // Sử dụng cùng endpoint với add
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'food_id': foodId, 'quantity': quantity}),
      );
      
      if (res.statusCode != 200) {
        print('Error updating cart: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to update cart: ${res.statusCode}');
      }
    } catch (e) {
      print('Exception in updateCart: $e');
      throw Exception('Failed to update cart: $e');
    }
  }

  Future<void> removeFromCart(int foodId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/cart/remove'),
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'food_id': foodId}),
      );
      
      if (res.statusCode != 200) {
        print('Error removing from cart: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to remove from cart: ${res.statusCode}');
      }
    } catch (e) {
      print('Exception in removeFromCart: $e');
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/cart/clear'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (res.statusCode != 200) {
        print('Error clearing cart: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to clear cart: ${res.statusCode}');
      }
    } catch (e) {
      print('Exception in clearCart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }
} 