import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiException(this.message, {this.code, this.statusCode, this.details});

  @override
  String toString() => code == null ? message : '$code: $message';
}

class ApiClient {
  final String baseUrl;
  final String? bearerToken;

  ApiClient({required this.baseUrl, this.bearerToken});

  Uri _uri(String path) {
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$root$p');
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (bearerToken != null && bearerToken!.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await http.get(_uri(path), headers: _headers());
    return _decode(res);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await http.post(_uri(path), headers: _headers(), body: jsonEncode(body));
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> payload = {};
    try {
      payload = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Invalid server response', statusCode: res.statusCode);
    }

    if (res.statusCode >= 200 && res.statusCode < 300 && payload['ok'] == true) {
      return payload;
    }

    throw ApiException(
      payload['message']?.toString() ?? 'Request failed',
      code: payload['error_code']?.toString(),
      statusCode: res.statusCode,
      details: payload['details'] is Map<String, dynamic> ? payload['details'] as Map<String, dynamic> : payload,
    );
  }
}
