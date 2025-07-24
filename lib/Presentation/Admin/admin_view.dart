import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Base/models/food_model.dart';
import '../Base/provider/food_provider.dart';
import 'food_manager_page.dart';
import '../Base/services/order_service.dart';
import 'order_confirm_page.dart';
import '../Auth/provider/auth_provider.dart';
import 'manage_staff_page.dart';
import 'manage_accounts_page.dart';
import 'manage_revenue_page.dart';

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  bool showFoodManager = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<FoodProvider>(context, listen: false).fetchFoods());
  }

  void _showFoodForm({FoodModel? food}) {
    final nameController = TextEditingController(text: food?.name ?? '');
    final descController = TextEditingController(text: food?.description ?? '');
    final priceController = TextEditingController(text: food?.price.toString() ?? '');
    final imagesController = TextEditingController(text: food?.images.join(',') ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(food == null ? 'Thêm món ăn' : 'Sửa món ăn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món ăn')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
              TextField(controller: imagesController, decoration: const InputDecoration(labelText: 'Ảnh (dạng link, phân cách bằng dấu phẩy)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              final foodModel = FoodModel(
                id: food?.id,
                name: nameController.text.trim(),
                description: descController.text.trim(),
                price: double.tryParse(priceController.text.trim()) ?? 0,
                images: imagesController.text.split(',').map((e) => e.trim()).toList(),
                category: 'Burger',
              );
              final provider = Provider.of<FoodProvider>(context, listen: false);
              if (food == null) {
                await provider.addFood(foodModel);
              } else {
                await provider.updateFood(foodModel);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(food == null ? 'Thêm' : 'Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteFood(BuildContext context, int? id) async {
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa món ăn này?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<FoodProvider>(context, listen: false).deleteFood(id);
    }
  }

  Widget _buildFoodManager() {
    final foodProvider = Provider.of<FoodProvider>(context);
    final foods = foodProvider.foods;
    final isLoading = foodProvider.isLoading;
    final error = foodProvider.error;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm món ăn'),
            onPressed: () => _showFoodForm(),
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator()),
        if (error != null)
          Center(child: Text('Lỗi: ' + error)),
        if (!isLoading && error == null)
          Expanded(
            child: ListView.separated(
              itemCount: foods.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final food = foods[index];
                return ListTile(
                  leading: food.images.isNotEmpty ? Image.asset(food.images[0], width: 48, height: 48, fit: BoxFit.cover) : null,
                  title: Text(food.name),
                  subtitle: Text('Giá: ${food.price.toStringAsFixed(0)} VND'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showFoodForm(food: food),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFood(context, food.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color, {VoidCallback? onTap, bool enabled = true}) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.role == 'admin';

    if (authProvider.role == null) {
      // Nếu role chưa load xong, hiển thị loading
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildMenuItem(
                      Icons.fastfood,
                      'Quản lý món ăn',
                      Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FoodManagerPage()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuItem(
                      Icons.receipt_long,
                      'Quản lý đơn hàng',
                      Colors.green,
                      onTap: () {
                        final token = authProvider.token!;
                        final baseUrl = 'http://10.0.2.2:3000';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderConfirmPage(
                              orderService: OrderService(baseUrl: baseUrl, token: token),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildMenuItem(
                      Icons.people,
                      'Quản lý tài khoản',
                      isAdmin ? Colors.blue : Colors.grey,
                      enabled: isAdmin,
                      onTap: isAdmin
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManageAccountsPage(),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: isAdmin
                        ? _buildMenuItem(
                            Icons.bar_chart,
                            'Quản lý doanh thu',
                            Colors.purple,
                            enabled: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManageRevenuePage(),
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 