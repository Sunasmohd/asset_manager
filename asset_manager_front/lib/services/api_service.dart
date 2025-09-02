import 'dart:convert';
import 'package:asset_manager_front/models/asset.dart';
import 'package:asset_manager_front/models/user.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5050';
  static const String assetsEndpoint = '$baseUrl/assets';
  static const String authEndpoint = '$baseUrl/auth';

  Future<String> login(UserLoginDto user) async {
    final response = await http.post(
      Uri.parse('$authEndpoint/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['token'];
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await User.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getAllAssets({
    int pageNumber = 1,
    String? status,
  }) async {
    final queryParams = {
      'pageNumber': pageNumber.toString(),
      if (status != null) 'status': status,
    };

    final uri = Uri.parse(assetsEndpoint).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return {
        'totalRecords': body['totalRecords'],
        'pageNumber': body['pageNumber'],
        'pageSize': body['pageSize'],
        'data': (body['data'] as List).map((item) => Asset.fromJson(item)).toList(),
      };
    } else {
      throw Exception('Failed to load assets: ${response.body}');
    }
  }

  Future<Asset> createAsset(Asset asset) async {
    final response = await http.post(
      Uri.parse(assetsEndpoint),
      headers: await _getHeaders(),
      body: jsonEncode(asset.toJson()),
    );

    if (response.statusCode == 201) {
      return Asset.fromJson(jsonDecode(response.body));
    } else {
      final Map<String, dynamic> responseBodyErr = jsonDecode(response.body);
      if (responseBodyErr.containsKey('errors')) {
        throw Exception(responseBodyErr['errors'].toString());
      } else {
        throw Exception('Something went wrong');
      }
    }
  }

  Future<void> updateAsset(int id, Asset asset) async {
    final response = await http.put(
      Uri.parse('$assetsEndpoint/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(asset.toJson()),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update asset: ${response.body}');
    }
  }

  Future<void> deleteAsset(int id) async {
    final response = await http.delete(
      Uri.parse('$assetsEndpoint/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete asset: ${response.body}');
    }
  }
}