import 'package:flutter/material.dart';
import 'manage_staff_page.dart';
import 'manage_customer_page.dart';

class ManageAccountsPage extends StatelessWidget {
  const ManageAccountsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý tài khoản'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Nhân viên', icon: Icon(Icons.people)),
              Tab(text: 'Khách hàng', icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ManageStaffPage(adminRole: 'admin'),
            ManageCustomerPage(),
          ],
        ),
      ),
    );
  }
} 