import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/food_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  CartService? cartService;
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCartService(CartService service) {
    cartService = service;
  }

  Future<void> fetchCart() async {
    if (cartService == null) {
      _error = 'CartService chưa được khởi tạo';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final fetched = await cartService!.fetchCart();
      _items.clear();
      _items.addAll(fetched);
      print('Fetched ${fetched.length} items from cart');
    } catch (e) {
      _error = 'Lỗi khi tải giỏ hàng: $e';
      print('Error fetching cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(FoodModel food, {int quantity = 1}) async {
    if (cartService == null) {
      _error = 'CartService chưa được khởi tạo';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await cartService!.addToCart(food.id!, quantity);
      await fetchCart();
      print('Added ${food.name} to cart with quantity $quantity');
    } catch (e) {
      _error = 'Lỗi khi thêm vào giỏ hàng: $e';
      print('Error adding to cart: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(FoodModel food) async {
    if (cartService == null) {
      _error = 'CartService chưa được khởi tạo';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await cartService!.removeFromCart(food.id!);
      await fetchCart();
      print('Removed ${food.name} from cart');
    } catch (e) {
      _error = 'Lỗi khi xóa khỏi giỏ hàng: $e';
      print('Error removing from cart: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(FoodModel food, int quantity) async {
    if (cartService == null) {
      _error = 'CartService chưa được khởi tạo';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await cartService!.addToCart(food.id!, quantity);
      await fetchCart();
      print('Updated ${food.name} quantity to $quantity');
    } catch (e) {
      _error = 'Lỗi khi cập nhật số lượng: $e';
      print('Error updating quantity: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.food.price * item.quantity);

  Future<void> clearCart() async {
    if (cartService == null) {
      _error = 'CartService chưa được khởi tạo';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await cartService!.clearCart();
      await fetchCart();
      print('Cart cleared successfully');
    } catch (e) {
      _error = 'Lỗi khi xóa giỏ hàng: $e';
      print('Error clearing cart: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearLocal() {
    _items.clear();
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 