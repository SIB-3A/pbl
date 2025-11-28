import 'package:client/utils/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BaseService<T> {
  @protected
  final Dio dio = Dio(
    BaseOptions(contentType: "application/json", baseUrl: Constant.apiUrl),
  );

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
