import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '',
      connectTimeout: Duration(seconds: 5), // 요청 타임아웃 (5초)
      receiveTimeout: Duration(seconds: 3), // 응답 타임아웃 (3초)
    )
  );

  //! GET
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // 인증 헤더 추가
      final jwt = await _getJwt();
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );
      return response.data; // JSON 응답 반환
    } catch (error) {
      _handleError(error); // 에러 처리
      rethrow; // 호출자에게 에러 전달
    }
  }

  //! POST
  // 2. POST 요청
  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      // 인증 헤더 추가
      final jwt = await _getJwt();
      final response = await _dio.post(
        path,
        data: data,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );
      return response.data; // JSON 응답 반환
    } catch (error) {
      _handleError(error); // 에러 처리
      rethrow; // 호출자에게 에러 전달
    }
  }

  //! PUT 
  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final jwt = await _getJwt();
      final response = await _dio.put(
        path,
        data: data,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );
      return response.data;
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  //! DELETE
  static Future<void> delete(String path) async {
    try {
      final jwt = await _getJwt();
      await _dio.delete(
        path,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  //! 로컬 저장소에서 JWT 가져오기
  static Future<String?> _getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt'); // 저장된 JWT 반환
  }

  //! 에러 처리
  static void _handleError(dynamic error) {
    if (error is DioException) {
    }
  }
}