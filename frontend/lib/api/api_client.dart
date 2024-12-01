import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.spaceme.kro.kr',
      connectTimeout: const Duration(seconds: 60), // 요청 타임아웃 (5초)
      receiveTimeout: const Duration(seconds: 60), // 응답 타임아웃 (3초)
    ),
  );

  //! GET
  static Future<dynamic> get(
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
        return response.data;
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
static Future<dynamic> post(
  String path, {
  Map<String, dynamic>? data,
}) async {
  try {
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 응답이 JSON 객체인지 확인
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        // JSON 문자열일 경우 파싱
        return response.data; // 파싱을 원하면 `jsonDecode(response.data)` 추가
      }
      return response.data; // 기타 응답 처리
    } else if (response.statusCode == 204) {
      return null; // No Content
    } else {
      throw Exception('Unhandled status code: ${response.statusCode}');
    }
  } catch (error) {
    _handleError(error);
    rethrow;
  }
}

  //! POST with Headers
  static Future<Response> postWithHeaders(
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response; // 응답 전체 반환 (데이터와 헤더 포함)
      } else if (response.statusCode == 204) {
        // No Content
        throw Exception('No content returned from the server.');
      } else {
        throw Exception('Unhandled status code: ${response.statusCode}');
      }
    } catch (error) {
      _handleError(error); // 에러 처리
      rethrow; // 호출자에게 에러 전달
    }
  }

  //! PATCH
static Future<Map<String, dynamic>?> patch(
  String path, {
  Map<String, dynamic>? data,
}) async {
  try {
    final jwt = await getJwt();
    final response = await _dio.patch(
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
    if (error is DioException) {}
  }
}
