import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  bool get isLoggedIn => _token != null;
  String? get role => _role;
  String? get token => _token;

  AuthProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final result = await AuthService.login(email, password);
      if (result != null && result['token'] != null) {
        _token = result['token'];
        _role = result['role'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('role', _role ?? '');
        notifyListeners();
        // Gửi FCM token lên backend
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && _token != null) {
          await http.post(
            Uri.parse('http://10.0.2.2:3000/api/user/save-fcm-token'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'fcm_token': fcmToken}),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      // Đăng nhập Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Người dùng hủy đăng nhập Google');
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Đăng nhập Firebase bằng credential Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Lấy Firebase ID Token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        print('Không lấy được idToken');
        return false;
      }

      // Gửi token lên backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/google-login'),
        body: {'token': idToken},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _role = data['role'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('role', _role ?? '');
        notifyListeners();
        print('Đăng nhập Google + backend thành công');
        return true;
      } else {
        print('Lỗi backend: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi đăng nhập Google/backend: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    notifyListeners();
  }

  Future<bool> register(String email, String username, String password, String phone) async {
    try {
      final result = await AuthService.register(email, username, password, phone);
      if (result != null && result['message'] != null) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
} 