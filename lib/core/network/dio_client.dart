import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://itunes.apple.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Add interceptors for logging or auth if needed later
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('Dio: $obj'),
    ));
  }

  Dio get dio => _dio;
}
