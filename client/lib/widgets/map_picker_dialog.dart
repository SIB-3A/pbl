import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;
  final double initialRadius;
  final Function(LatLng, double) onLocationSelected;

  const MapPickerDialog({
    super.key,
    this.initialLocation,
    this.initialRadius = 100.0,
    required this.onLocationSelected,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng _selectedLocation;
  late double _radius;
  MapController? _mapController;
  double _currentZoom = 15.0;
  bool _isGettingLocation = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ?? const LatLng(-7.966620, 112.632629);
    _radius = widget.initialRadius;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _handleMapTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
    if (_mapController != null) {
      _mapController!.move(latLng, _currentZoom);
    }
  }

  void _handleRadiusChange(double value) {
    setState(() {
      _radius = value;
    });
  }

  void _saveAndClose() {
    widget.onLocationSelected(_selectedLocation, _radius);
    Navigator.pop(context);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ====================================================
  // FITUR: DAPATKAN LOKASI SAAT INI
  // ====================================================

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      // 1. Cek apakah GPS/location service aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showLocationServiceDisabledDialog();
        return;
      }

      // 2. Cek dan minta permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedDialog();
        return;
      }

      // 3. Dapatkan posisi saat ini
      _showSnackBar('Sedang mencari lokasi Anda...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _currentPosition = position;

      // 4. Update UI
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      // 5. Pindahkan peta
      if (_mapController != null) {
        _mapController!.move(_selectedLocation, 16.0);
      }

      _showSnackBar('Lokasi berhasil ditemukan!');
    } on TimeoutException catch (_) {
      _showTimeoutDialog();
    } catch (e) {
      _showErrorDialog('Gagal mendapatkan lokasi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('GPS Tidak Aktif'),
        content: const Text(
          'GPS pada perangkat Anda tidak aktif. '
          'Silakan aktifkan GPS untuk menggunakan fitur ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B7FA8),
            ),
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text(
              'Buka Pengaturan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).then((_) {
      setState(() => _isGettingLocation = false);
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Izin Lokasi Ditolak'),
        content: const Text(
          'Aplikasi membutuhkan izin lokasi untuk menemukan posisi Anda. '
          'Silakan berikan izin lokasi di pengaturan perangkat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B7FA8),
            ),
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text(
              'Buka Pengaturan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).then((_) {
      setState(() => _isGettingLocation = false);
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Waktu Habis'),
        content: const Text(
          'Pencarian lokasi memakan waktu terlalu lama. '
          'Pastikan sinyal GPS Anda baik dan coba lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getCurrentLocation();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Terjadi Kesalahan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return OutlinedButton.icon(
      icon: _isGettingLocation
          ? const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.my_location, size: 18),
      label: _isGettingLocation
          ? const Text('Mencari...')
          : const Text('Lokasi Saat Ini'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1B7FA8),
        side: const BorderSide(color: Color(0xFF1B7FA8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: _isGettingLocation ? null : _getCurrentLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B7FA8),
        title: const Text(
          'Pilih Lokasi di Peta',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveAndClose,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: _currentZoom,
                maxZoom: 18.0,
                minZoom: 10.0,
                onTap: _handleMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.client',
                  subdomains: const ['a', 'b', 'c'],
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),

                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedLocation,
                      radius: _radius,
                      useRadiusInMeter: true,
                      color: const Color(0xFF1B7FA8).withOpacity(0.3),
                      borderColor: const Color(0xFF1B7FA8),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(
                        Uri.parse('https://www.openstreetmap.org/copyright'),
                      ),
                    ),
                    TextSourceAttribution(
                      'OpenStreetMap France',
                      onTap: () =>
                          launchUrl(Uri.parse('https://openstreetmap.fr/')),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi Terpilih:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B7FA8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Zoom: ${_currentZoom.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B7FA8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Radius Area:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B7FA8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_radius.round()} meter',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Slider(
                      value: _radius,
                      min: 10,
                      max: 1000,
                      divisions: 99,
                      label: '${_radius.round()} m',
                      activeColor: const Color(0xFF1B7FA8),
                      inactiveColor: Colors.grey.shade300,
                      thumbColor: const Color(0xFF1B7FA8),
                      onChanged: _handleRadiusChange,
                    ),

                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRadiusPreset(10, '10m'),
                        _buildRadiusPreset(100, '100m'),
                        _buildRadiusPreset(250, '250m'),
                        _buildRadiusPreset(500, '500m'),
                        _buildRadiusPreset(1000, '1km'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info,
                        size: 18,
                        color: Color(0xFF1B7FA8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentPosition != null
                              ? 'Lokasi Anda: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                              : 'Geser slider untuk mengubah radius',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildCurrentLocationButton()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Simpan Lokasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B7FA8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _saveAndClose,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusPreset(double value, String label) {
    return GestureDetector(
      onTap: () => _handleRadiusChange(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (_radius - value).abs() < 1
              ? const Color(0xFF1B7FA8)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (_radius - value).abs() < 1
                ? const Color(0xFF1B7FA8)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: (_radius - value).abs() < 1
                ? Colors.white
                : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
