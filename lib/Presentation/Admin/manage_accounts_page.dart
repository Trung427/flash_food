import 'package:flutter/material.dart';
import 'manage_staff_page.dart';
import 'manage_customer_page.dart';

class ManageAccountsPage extends StatefulWidget {
  const ManageAccountsPage({Key? key}) : super(key: key);

  @override
  State<ManageAccountsPage> createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
  final GlobalKey<ManageStaffPageState> staffKey = GlobalKey<ManageStaffPageState>();
  final GlobalKey<ManageCustomerPageState> customerKey = GlobalKey<ManageCustomerPageState>();

  void refreshAll() {
    staffKey.currentState?.fetchStaffs();
    customerKey.currentState?.fetchCustomers();
  }

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
        body: TabBarView(
          children: [
            ManageStaffPage(key: staffKey, adminRole: 'admin', onRoleChanged: refreshAll),
            ManageCustomerPage(key: customerKey, onRoleChanged: refreshAll),
          ],
        ),
      ),
    );
  }
} 