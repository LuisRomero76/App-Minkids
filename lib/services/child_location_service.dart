import 'dart:convert';
import 'package:minkids/services/api_service.dart';
import 'package:minkids/services/auth_service.dart';

class ChildLocationService {
  static Future<bool> registerMyLocation(double lat, double lon) async {
    try {
      final user = await AuthService.currentUser();
      if (user == null || user.userId == null) return false;
      
      final resp = await ApiService.post('/child-location/register', {
        'child_id': user.userId,
        'latitude': lat,
        'longitude': lon,
      }, auth: true);
      
      return resp.statusCode == 201 || resp.statusCode == 200;
    } catch (e) {
      print('Error registrando ubicación: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getChildrenLocations() async {
    try {
      final resp = await ApiService.get('/child-location/my-children', auth: true);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{}).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo ubicaciones: $e');
      return [];
    }
  }
}
