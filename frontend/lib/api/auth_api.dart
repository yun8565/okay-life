import 'package:okay_life_app/api/api_client.dart';

class AuthApi {
  // 소셜 로그인 주소 요청
  Future<String> getSocialLoginUrl(String provider) async {
    try {
      final response = await ApiClient.get('/oauth/$provider');
      return response['url'];
    } catch (error) {
      throw Exception('Failed to get social login URL: $error');
    }
  }

  // JWT 발급 요청
  Future<String> requestJwtToken(String provider, String authCode) async {
    try {
      final response = await ApiClient.get(
        '/oauth/login/$provider',
        queryParameters: {'code': authCode},
      );
      return response['jwt']; // JWT 반환
    } catch (error) {
      throw Exception('JWT 발급 요청 실패: $error');
    }
  }

  // 로그아웃 요청 (추후 구현 예정)
}