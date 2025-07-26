import 'package:flash_food/Core/Utils/utils.dart';
import 'package:flash_food/Core/app_colors.dart';
import 'package:flash_food/Core/font_size.dart';
import 'package:flash_food/Core/response_conf.dart';
import 'package:flash_food/Core/text_styles.dart';
import 'package:flash_food/Presentation/Auth/screens/account_status.dart';
import 'package:flash_food/Presentation/Auth/screens/default_button.dart';
import 'package:flash_food/Presentation/Auth/screens/default_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'package:flash_food/Core/Routes/routes_name.dart';
import 'package:flash_food/Presentation/Auth/views/email_verification.dart';


class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MathUtils.init(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final List<Map<String, dynamic>> socialIcons = [
      {
        'icon': 'assets/icons/google.svg',
        'onTap': () async {
          final success = await authProvider.loginWithGoogle();
          if (success) {
            Navigator.pushReplacementNamed(context, RoutesName.main);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng ký Google thất bại!')),
            );
          }
        }
      },
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Pallete.neutral100),
          onPressed: () => Navigator.pushReplacementNamed(context, RoutesName.login),
        ),
        title: Text('Đăng ký', style: TextStyles.headingH4SemiBold.copyWith(color: Pallete.neutral100)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: getWidth(24)).copyWith(
          top: MediaQuery.of(context).viewPadding.top,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(32),
            Text(
              "Create your new \naccount",
              style: TextStyles.headingH4SemiBold.copyWith(
                color: Pallete.neutral100,
                fontSize: getFontSize(FontSizes.h4),
              ),
            ),
            const Gap(8),
            Text(
              "Create an account to start looking for the food \nyou like ",
              style: TextStyles.bodyMediumMedium.copyWith(
                color: Pallete.neutral60,
                fontSize: getFontSize(FontSizes.medium),
              ),
            ),
            const Gap(12),
            DefaultField(
              hintText: "Enter Email",
              controller: emailController,
              labelText: "Email Address",
            ),
            const Gap(14),
            DefaultField(
              hintText: "User Name",
              controller: usernameController,
              labelText: "User Name",
            ),
            const Gap(14),
            DefaultField(
              hintText: "Phone Number",
              controller: phoneController,
              labelText: "Phone Number",
              keyboardType: TextInputType.phone,
            ),
            const Gap(14),
            DefaultField(
              hintText: "Password",
              controller: passwordController,
              labelText: "Password",
              isPasswordField: true,
            ),
            const Gap(24),
            Row(
              children: [
                Checkbox(
                  fillColor: const MaterialStatePropertyAll(Pallete.orangePrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(getSize(4)),
                  ),
                  value: true,
                  onChanged: (value) {},
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "I Agree with ",
                          style: TextStyles.bodyMediumMedium.copyWith(
                            color: Pallete.neutral100,
                            fontSize: getFontSize(FontSizes.medium),
                          ),
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyles.bodyMediumSemiBold.copyWith(
                            color: Pallete.orangePrimary,
                            fontSize: getFontSize(FontSizes.medium),
                          ),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: TextStyles.bodyMediumMedium.copyWith(
                            color: Pallete.neutral100,
                            fontSize: getFontSize(FontSizes.medium),
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyles.bodyMediumSemiBold.copyWith(
                            color: Pallete.orangePrimary,
                            fontSize: getFontSize(FontSizes.medium),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const Gap(24),
            DefaultButton(
              btnContent: "Register",
              function: () async {
                final email = emailController.text.trim();
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();
                final phone = phoneController.text.trim();

                try {
                  final success = await authProvider.register(
                    email,
                    username,
                    password,
                    phone,
                  );

                  if (success) {
                    // Chuyển đến màn hình xác minh
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmailVerificationScreen(email: email),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đăng ký thất bại!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              },

            ),

            const Gap(24),
            Row(
              children: [
                const Expanded(child: Divider(color: Pallete.neutral60, height: 0.5)),
                const Gap(16),
                Text(
                  "Or sign in with",
                  style: TextStyles.bodyMediumMedium.copyWith(
                    color: Pallete.neutral60,
                    fontSize: getFontSize(FontSizes.medium),
                  ),
                ),
                const Gap(16),
                const Expanded(child: Divider(color: Pallete.neutral60, height: 0.5)),
              ],
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: socialIcons.map((e) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: InkWell(
                  onTap: e['onTap'],
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Pallete.neutral40, width: 1),
                    ),
                    child: SvgPicture.asset(e['icon']),
                  ),
                ),
              )).toList(),
            ),
            const Gap(32),
            const AccountStatus(action: " Sign In", question: "Already have an account?"),
          ],
        ),
      ),
    );
  }
}
