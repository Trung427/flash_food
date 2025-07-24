import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Auth/provider/auth_provider.dart';

class ManageStaffPage extends StatefulWidget {
  final String? adminRole; // truyền role từ ngoài vào để kiểm tra quyền
  const ManageStaffPage({Key? key, this.adminRole}) : super(key: key);

  @override
  State<ManageStaffPage> createState() => _ManageStaffPageState();
}

class _ManageStaffPageState extends State<ManageStaffPage> {
  List<Map<String, dynamic>> staffs = [];
  bool isLoading = true;
  String? error;

  String get token => Provider.of<AuthProvider>(context, listen: false).token ?? '';
  final String apiBase = 'http://10.0.2.2:3000/api/user'; // Đổi lại IP nếu chạy thật

  @override
  void initState() {
    super.initState();
    if (widget.adminRole == 'admin') {
      fetchStaffs();
    } else {
      setState(() {
        isLoading = false;
        error = 'Bạn không có quyền truy cập trang này.';
      });
    }
  }

  Future<void> fetchStaffs() async {
    setState(() { isLoading = true; });
    try {
      final res = await http.get(
        Uri.parse('$apiBase/staffs'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          staffs = List<Map<String, dynamic>>.from(data['staffs'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Lỗi lấy danh sách nhân viên: \n${res.body}';
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

  void showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final emailCtrl = TextEditingController();
        final usernameCtrl = TextEditingController();
        final passwordCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Thêm nhân viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
            ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final username = usernameCtrl.text.trim();
                final password = passwordCtrl.text.trim();
                if (email.isEmpty || username.isEmpty || password.isEmpty) return;
                Navigator.pop(context);
                await addStaff(email, username, password);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addStaff(String email, String username, String password) async {
    setState(() { isLoading = true; });
    try {
      final res = await http.post(
        Uri.parse('$apiBase/staffs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );
      if (res.statusCode == 201) {
        await fetchStaffs();
      } else {
        setState(() {
          error = 'Lỗi thêm nhân viên: \n${res.body}';
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

  void showEditStaffDialog(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (context) {
        final usernameCtrl = TextEditingController(text: staff['username'] ?? '');
        final fullNameCtrl = TextEditingController(text: staff['full_name'] ?? '');
        final birthdayCtrl = TextEditingController(text: staff['birthday'] ?? '');
        final phoneCtrl = TextEditingController(text: staff['phone'] ?? '');
        return AlertDialog(
          title: const Text('Sửa nhân viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'Họ tên')),
              TextField(controller: birthdayCtrl, decoration: const InputDecoration(labelText: 'Ngày sinh (yyyy-mm-dd)')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await editStaff(
                  staff['id'].toString(),
                  usernameCtrl.text.trim(),
                  fullNameCtrl.text.trim(),
                  birthdayCtrl.text.trim(),
                  phoneCtrl.text.trim(),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editStaff(String id, String username, String fullName, String birthday, String phone) async {
    setState(() { isLoading = true; });
    try {
      final res = await http.put(
        Uri.parse('$apiBase/staffs/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'full_name': fullName,
          'birthday': birthday,
          'phone': phone,
        }),
      );
      if (res.statusCode == 200) {
        await fetchStaffs();
      } else {
        setState(() {
          error = 'Lỗi cập nhật: \n${res.body}';
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

  void deleteStaff(String id) async {
    final confirm = await showConfirmDeleteDialog(
      context: context,
      title: 'Xác nhận xoá',
      content: 'Bạn có chắc chắn muốn xoá nhân viên này?',
    );
    if (confirm != true) return;
    setState(() { isLoading = true; });
    try {
      final res = await http.delete(
        Uri.parse('$apiBase/staffs/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        await fetchStaffs();
      } else {
        setState(() {
          error = 'Lỗi xoá nhân viên: \n${res.body}';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }
    return Scaffold(
      // KHÔNG có appBar ở đây, vì đã có ở màn cha
      body: staffs.isEmpty
          ? const Center(child: Text('Chưa có nhân viên nào.'))
          : ListView.builder(
              itemCount: staffs.length,
              itemBuilder: (context, index) {
                final staff = staffs[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(staff['username'] ?? ''),
                  subtitle: Text(staff['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showEditStaffDialog(staff),
                        tooltip: 'Sửa',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteStaff(staff['id'].toString()),
                        tooltip: 'Xoá',
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddStaffDialog,
        child: const Icon(Icons.add),
        tooltip: 'Thêm nhân viên',
      ),
    );
  }
} 