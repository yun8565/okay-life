import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.spaceme.kro.kr',
      connectTimeout: const Duration(seconds: 5), // 요청 타임아웃 (5초)
      receiveTimeout: const Duration(seconds: 3), // 응답 타임아웃 (3초)
    ),
  );

  //! GET
  static Future<Map<String, dynamic>?> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // 인증 헤더 추가
      final jwt = await getJwt();
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        // Not Found
        throw Exception('Resource not found: $path');
      } else {
        throw Exception('Unhandled status code: ${response.statusCode}');
      }
    } catch (error) {
      _handleError(error); // 에러 처리
      rethrow; // 호출자에게 에러 전달
    }
  }

  //! POST
  static Future<Map<String, dynamic>?> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      // 인증 헤더 추가
      final jwt = await getJwt();
      final response = await _dio.post(
        path,
        data: data,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 201) {
        // Created
        if (response.data != null) {
          return response.data as Map<String, dynamic>;
        } else {
          throw Exception('Response body is empty for status 201.');
        }
      } else if (response.statusCode == 204) {
        // No Content
        return null; // 반환값 없음
      } else {
        throw Exception('Unhandled status code: ${response.statusCode}');
      }
    } catch (error) {
      _handleError(error); // 에러 처리
      rethrow; // 호출자에게 에러 전달
    }
  }

  //! PUT
  static Future<Map<String, dynamic>?> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final jwt = await getJwt();
      final response = await _dio.put(
        path,
        data: data,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 204) {
        // No Content
        return null; // 반환값 없음
      } else {
        throw Exception('Unhandled status code: ${response.statusCode}');
      }
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  //! DELETE
  static Future<void> delete(String path) async {
    try {
      final jwt = await getJwt();
      final response = await _dio.delete(
        path,
        options: Options(
          headers: {
            if (jwt != null) 'Authorization': 'Bearer $jwt',
          },
        ),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Unhandled status code: ${response.statusCode}');
      }
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }


  //! 로컬 저장소에서 JWT 가져오기
  static Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt'); // 저장된 JWT 반환
  }

  //! JWT 저장
  static Future<void> setJwt(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', jwt); // JWT 저장
  }

  //! JWT 삭제 (로그아웃 시 사용 가능)
  static Future<void> deleteJwt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt'); // JWT 삭제
  }

  //! 에러 처리
  static void _handleError(dynamic error) {
    if (error is DioException) {
    }
  }
}