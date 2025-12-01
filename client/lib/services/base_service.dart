import 'package:client/utils/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseService<T> {
  @protected
  final Dio dio = Dio(
    BaseOptions(contentType: "application/json", baseUrl: Constant.apiUrl),
  );

  BaseService() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = FlutterSecureStorage();
          final token = await storage.read(key: "token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }

  List<T> parseData(
    Object? data,
    String attribute,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // data should be a Map<String, dynamic>
    if (data is! Map<String, dynamic>) {
      return <T>[];
    }

    final rawList = data[attribute];
    if (rawList is! List) {
      return <T>[];
    }

    return rawList
        .whereType<Map<String, dynamic>>() // keep only proper maps
        .map(fromJson) // convert each map to T
        .toList();
  }
}
