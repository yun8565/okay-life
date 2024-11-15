import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _jwt;
  Map<String, dynamic>? _userInfo;

  // Getter
  bool get isAuthenticated => _isAuthenticated;
  String? get jwt => _jwt;
  Map<String, dynamic>? get userInfo => _userInfo;

  // JWT 로컬 저장
  Future<void> saveJwtToLocal(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', jwt);
  }

  // JWT 로컬에서 가져오기
  Future<String?> getJwtFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  // 로그인 처리
  void login(String token, Map<String, dynamic> user) {
    _isAuthenticated = true;
    _jwt = token;
    _userInfo = user;
    notifyListeners(); // 상태 변경 알림
  }

  // 로그아웃 처리
  void logout() async {
    _isAuthenticated = false;
    _jwt = null;
    _userInfo = null;
    notifyListeners();

    // 로컬에서 JWT 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
  }
}