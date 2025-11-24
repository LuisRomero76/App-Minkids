import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:minkids/services/child_location_service.dart';

class RealtimeLocationService {
  static Timer? _locationTimer;
  static bool _isTracking = false;

  /// Inicia el seguimiento de ubicación en tiempo real para hijos
  /// Envía la ubicación cada [intervalSeconds] segundos
  static Future<void> startTracking({int intervalSeconds = 30}) async {
    if (_isTracking) return;
    
    _isTracking = true;
    
    // Enviar ubicación inmediatamente
    await _sendCurrentLocation();
    
    // Configurar timer para enviar periódicamente
    _locationTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) async {
        await _sendCurrentLocation();
      },
    );
  }

  /// Detiene el seguimiento de ubicación
  static void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;
  }

  /// Envía la ubicación actual al servidor
  static Future<bool> _sendCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        final success = await ChildLocationService.registerMyLocation(
          position.latitude,
          position.longitude,
        );
        
        return success;
      }
      return false;
    } catch (e) {
      print('Error enviando ubicación: $e');
      return false;
    }
  }

  /// Verifica si el servicio está activo
  static bool get isTracking => _isTracking;
}
