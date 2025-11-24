import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:minkids/services/child_location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  bool _loading = true;
  bool _isRealTimeActive = false;
  List<Map<String, dynamic>> _locations = [];
  List<Marker> _markers = [];
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ChildLocationService.getChildrenLocations();
    _locations = data.where((e) => 
      e['latitude'] != null && e['longitude'] != null
    ).toList();
    
    _addMarkers();
    
    if (_locations.isNotEmpty) {
      // Centrar el mapa en la primera ubicación
      final first = _locations.first;
      final lat = double.parse(first['latitude'].toString());
      final lon = double.parse(first['longitude'].toString());
      _mapController.move(LatLng(lat, lon), 14);
    }
    
    setState(() => _loading = false);
  }

  /// Actualiza las ubicaciones sin mostrar loading (para tiempo real)
  Future<void> _updateSilently() async {
    final data = await ChildLocationService.getChildrenLocations();
    final newLocations = data.where((e) => 
      e['latitude'] != null && e['longitude'] != null
    ).toList();
    
    if (mounted) {
      setState(() {
        _locations = newLocations;
      });
      _addMarkers();
    }
  }

  void _toggleRealTime() {
    setState(() {
      _isRealTimeActive = !_isRealTimeActive;
    });

    if (_isRealTimeActive) {
      // Actualizar cada 10 segundos
      _updateTimer = Timer.periodic(
        const Duration(seconds: 10),
        (timer) => _updateSilently(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación en tiempo real activada'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _updateTimer?.cancel();
      _updateTimer = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación en tiempo real desactivada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getRelativeTime(String? timestamp) {
    if (timestamp == null) return 'Hace un momento';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inSeconds < 30) return 'Ahora mismo';
      if (difference.inMinutes < 1) return 'Hace ${difference.inSeconds} seg';
      if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
      if (difference.inHours < 24) return 'Hace ${difference.inHours}h';
      return 'Hace ${difference.inDays}d';
    } catch (e) {
      return 'Hace un momento';
    }
  }

  void _addMarkers() {
    final markers = <Marker>[];
    
    for (int i = 0; i < _locations.length; i++) {
      final loc = _locations[i];
      final lat = double.parse(loc['latitude'].toString());
      final lon = double.parse(loc['longitude'].toString());
      final childName = loc['child'] != null && loc['child']['name'] != null
          ? loc['child']['name'].toString()
          : 'Hijo ${i + 1}';
      final timestamp = loc['captured_at']?.toString();
      
      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 100,
          height: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre en etiqueta
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isRealTimeActive ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isRealTimeActive)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      childName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Pin de ubicación
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isRealTimeActive ? Colors.green : Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              // Tiempo
              if (timestamp != null)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRelativeTime(timestamp),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación en Tiempo Real'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          if (!_loading && _locations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  if (_isRealTimeActive)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _isRealTimeActive ? Icons.pause_circle : Icons.play_circle,
                      color: _isRealTimeActive ? Colors.green : Colors.grey,
                    ),
                    onPressed: _toggleRealTime,
                    tooltip: _isRealTimeActive ? 'Pausar tiempo real' : 'Activar tiempo real',
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 2,
              minZoom: 2,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.minkids',
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          if (_loading)
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Cargando ubicaciones...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (!_loading && _locations.isEmpty)
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay ubicaciones registradas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los hijos aparecerán aquí cuando se vinculen y activen su ubicación',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Botón de refresh manual
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'refresh_locations',
              onPressed: _load,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.refresh),
            ),
          ),
          // Info panel cuando está en tiempo real
          if (_isRealTimeActive && !_loading && _locations.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.radar,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rastreando en tiempo real',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Actualizando cada 10 segundos',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_locations.length} ${_locations.length == 1 ? 'hijo' : 'hijos'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
