import 'package:flash_food/Core/app_colors.dart';
import 'package:flash_food/Core/assets_constantes.dart';
import 'package:flash_food/Core/response_conf.dart';
import 'package:flash_food/Presentation/Auth/screens/default_button.dart';
import 'package:flash_food/Presentation/Auth/screens/default_field.dart';
import 'package:flash_food/Presentation/Base/base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flash_food/Presentation/Auth/provider/auth_provider.dart';
import 'package:flash_food/Presentation/Auth/services/auth_service.dart';

class PersonalDataView extends StatefulWidget {
  const PersonalDataView({Key? key}) : super(key: key);

  @override
  State<PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends State<PersonalDataView> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final birthdayController = TextEditingController();
  final phoneController = TextEditingController();
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) return;
      final user = await AuthService.getProfile(token);
      if (user == null) return;
      setState(() {
        fullNameController.text = user['full_name'] ?? '';
        // Sửa: Hiển thị ngày sinh dạng dd/MM/yyyy nếu có dữ liệu
        if (user['birthday'] != null && user['birthday'].toString().isNotEmpty) {
          try {
            final date = DateTime.parse(user['birthday']);
            birthdayController.text = DateFormat('dd/MM/yyyy').format(date);
          } catch (e) {
            birthdayController.text = user['birthday'];
          }
        } else {
          birthdayController.text = '';
        }
        phoneController.text = user['phone'] ?? '';
        email = user['email'] ?? '';
      });
    } catch (e) {
      // Có thể show lỗi nếu muốn
    }
  }

  void _pickBirthday() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Sửa: Hiển thị ngày sinh dạng dd/MM/yyyy
        birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _onSave() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        if (token == null) return;
        // Sửa: Chuyển ngày sinh về ISO string trước khi gửi lên server
        String birthdayIso = '';
        if (birthdayController.text.isNotEmpty) {
          try {
            final date = DateFormat('dd/MM/yyyy').parse(birthdayController.text);
            birthdayIso = DateFormat('yyyy-MM-dd').format(date);
          } catch (e) {
            birthdayIso = birthdayController.text;
          }
        }
        await AuthService.updateProfile(
          token: token,
          fullName: fullNameController.text,
          birthday: birthdayIso,
          phone: phoneController.text,
        );
        await _loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu thông tin cá nhân!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi:  e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    birthdayController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(buildContext: context, screenTitle: "Thông tin cá nhân"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(24),
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: const AssetImage(AssetsConstants.user),
                  radius: getSize(50),
                ),
                Positioned(
                  left: getSize(72),
                  bottom: getSize(8),
                  child: Container(
                    width: getSize(32),
                    height: getSize(32),
                    padding: EdgeInsets.all(getSize(6)),
                    decoration: const BoxDecoration(
                        color: Color(0xFFF5F5FF), shape: BoxShape.circle),
                    child: Icon(
                      CupertinoIcons.camera_fill,
                      color: Pallete.orangePrimary,
                      size: getSize(20),
                    ),
                  ),
                )
              ],
            ),
            const Gap(24),
            Form(
              key: formKey,
              child: Column(
                children: [
                  DefaultField(
                    controller: fullNameController,
                    hintText: "Nhập họ và tên của bạn",
                    labelText: "Họ và tên",
                  ),
                  const Gap(12),
                  DefaultField(
                    controller: birthdayController,
                    hintText: "Chọn ngày sinh của bạn",
                    labelText: "Ngày sinh",
                    onTap: _pickBirthday,
                    readOnly: true,
                  ),
                  const Gap(12),
                  DefaultField(
                    controller: phoneController,
                    hintText: "Nhập số điện thoại của bạn",
                    labelText: "Số điện thoại",
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const Gap(12),
                  // Email chỉ hiển thị, không cho nhập
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(email, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const Gap(36),
                  DefaultButton(
                    btnContent: "Lưu",
                    function: _onSave,
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
