import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Auth/provider/auth_provider.dart';

class ManageCustomerPage extends StatefulWidget {
  const ManageCustomerPage({Key? key}) : super(key: key);

  @override
  State<ManageCustomerPage> createState() => _ManageCustomerPageState();
}

class _ManageCustomerPageState extends State<ManageCustomerPage> {
  List<Map<String, dynamic>> customers = [];
  bool isLoading = true;
  String? error;

  String get token => Provider.of<AuthProvider>(context, listen: false).token ?? '';
  final String apiBase = 'http://10.0.2.2:3000/api/user';

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    setState(() { isLoading = true; });
    try {
      final res = await http.get(
        Uri.parse('$apiBase/customers'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          customers = List<Map<String, dynamic>>.from(data['customers'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Lỗi lấy danh sách khách hàng: \n${res.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  Future<bool?> showConfirmDeleteDialog({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Huỷ',
    String confirmText = 'Xoá',
    Color confirmColor = Colors.red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
  }

  void deleteCustomer(String id) async {
    final confirm = await showConfirmDeleteDialog(
      context: context,
      title: 'Xác nhận xoá',
      content: 'Bạn có chắc chắn muốn xoá khách hàng này?',
    );
    if (confirm != true) return;
    setState(() { isLoading = true; });
    try {
      final res = await http.delete(
        Uri.parse('$apiBase/customers/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        await fetchCustomers();
      } else {
        setState(() {
          error = 'Lỗi xoá khách hàng: \n${res.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  void showAddCustomerDialog() {
    // TODO: Hiển thị dialog thêm khách hàng (nếu muốn cho phép admin tạo tài khoản khách hàng)
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }
    return Scaffold(
      body: customers.isEmpty
          ? const Center(child: Text('Chưa có khách hàng nào.'))
          : ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(customer['username'] ?? ''),
                  subtitle: Text(customer['email'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteCustomer(customer['id'].toString()),
                    tooltip: 'Xoá',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCustomerDialog,
        child: const Icon(Icons.add),
        tooltip: 'Thêm khách hàng',
      ),
    );
  }
} 