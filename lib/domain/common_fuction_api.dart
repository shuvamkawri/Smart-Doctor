import 'dart:convert';

import 'package:http/http.dart' as http;

const String baseUrl = 'https://www.smartmedi.app:3000/api/';

const String imageUrlBase = 'https://www.smartmedi.app:3000/';

// const String baseUrl = 'https://metacare.co.in:3006/api/';
//
// const String imageUrlBase = 'https://metacare.co.in:3006/';

Future<dynamic> get(String endpoint, {Map<String, String>? headers, String? imageUrl}) async {
  final response =
      await http.get(Uri.parse(baseUrl + endpoint), headers: headers);
  return imageUrl != null ? imageUrl + response.body : response.body;
}

Future<dynamic> post(String endpoint,
    {Map<String, String>? headers, dynamic body, String? imageUrl}) async {
  final response = await http.post(Uri.parse(baseUrl + endpoint),
      headers: headers, body: body);
  return imageUrl != null ? imageUrl + response.body : response.body;
}

Future<dynamic> put(String endpoint,
    {Map<String, String>? headers, dynamic body, String? imageUrl}) async {
  final response = await http.put(Uri.parse(baseUrl + endpoint),
      headers: headers, body: body);
  return imageUrl != null ? imageUrl + response.body : response.body;
}

// uu
Future<dynamic> delete(String endpoint,
    {Map<String, String>? headers,
    String? imageUrl,
    required Map<String, dynamic> body}) async {
  final response = await http.delete(Uri.parse(baseUrl + endpoint),
      headers: headers, body: jsonEncode(body)); // Encode the body as JSON
  return imageUrl != null ? imageUrl + response.body : response.body;
}
