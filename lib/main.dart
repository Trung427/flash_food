import 'package:flash_food/Core/Routes/routes.dart';
import 'package:flash_food/Core/Routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Presentation/Auth/provider/auth_provider.dart';
import 'Presentation/Auth/views/login_view.dart';
import 'Presentation/Main/main_view.dart';
import 'Presentation/Base/provider/food_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Presentation/Base/provider/cart_provider.dart';
import 'Presentation/Base/services/cart_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print('FCM Token: ' + (fcmToken ?? 'null'));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, CartProvider>(
      builder: (context, authProvider, cartProvider, _) {
        if (authProvider.isLoggedIn && (cartProvider.cartService == null)) {
          final token = authProvider.token!;
          final baseUrl = 'http://10.0.2.2:3000'; // Đổi thành backend của bạn
          cartProvider.setCartService(CartService(baseUrl: baseUrl, token: token));
          cartProvider.fetchCart();
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: authProvider.isLoggedIn ? const MainView() : const LoginView(),
          onGenerateRoute: Routes.onGenerateRoute,
          theme: ThemeData(canvasColor: Colors.white),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi'),
            Locale('en'),
          ],
          locale: const Locale('vi'),
        );
      },
    );
  }
}
