import 'dart:developer';

import 'package:client/services/base_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class AuthService extends BaseService {
  AuthService._();

  static final AuthService instance = AuthService._();
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    final login = await dio.post<Map<String, dynamic>>(
      "/login",
      data: {"email": email, "password": password, "device_name": "android"},
      options: Options(
        headers: Map.from({"accept": "application/json"}),
        validateStatus: (status) => true,
      ),
    );
    if (login.statusCode != 200) {
      log("Error: Login failed: ${login.data?["message"]}");
      return {"success": false};
    }
    await storage.write(key: "token", value: login.data?["data"]["token"]);
    await storage.write(
      key: "userId",
      value: login.data?["data"]["user_id"].toString(),
    );
    await storage.write(
      key: "isAdmin",
      value: login.data?["data"]["is_admin"].toString(),
    );
    return {"success": true, "isAdmin": login.data?["data"]["is_admin"]};
  }

  Future<String?> redirectUser(GoRouterState state) async {
    final token = await storage.read(key: "token");
    final isAdmin = await storage.read(key: "isAdmin");
    final loggingIn = state.uri.toString() == "/login";
    if (token == null) {
      return loggingIn ? null : "/login";
    }
    if (!loggingIn) {
      return "/home";
    }
    if (isAdmin == "true") {
      return "/admin";
    }
    if (state.uri.toString().startsWith("/admin") && isAdmin != "true") {
      return "/home";
    }
    return null;
  }
}
