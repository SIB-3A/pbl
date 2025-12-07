import 'package:flutter/material.dart';

class LocationPreviewCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final int? radius;
  final VoidCallback? onPickLocation; // Ubah menjadi nullable
  final bool isLoading;

  const LocationPreviewCard({
    super.key,
    this.latitude,
    this.longitude,
    this.radius,
    required this.onPickLocation, // Tetap required tapi nullable
    this.isLoading = false,
  });

  bool get hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📍 Lokasi Departemen',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1B7FA8),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (hasLocation)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Latitude:', latitude!.toStringAsFixed(6)),
                  _buildInfoRow('Longitude:', longitude!.toStringAsFixed(6)),
                  _buildInfoRow('Radius:', '$radius meter'),
                  const SizedBox(height: 12),
                  Text(
                    'Lokasi sudah dipilih di peta',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum ada lokasi yang dipilih',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik tombol di bawah untuk memilih lokasi di peta',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map, size: 20),
                label: Text(hasLocation ? 'Ubah Lokasi di Peta' : 'Pilih Lokasi di Peta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasLocation ? Colors.orange : const Color(0xFF1B7FA8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onPickLocation, // Bisa null, tombol akan disabled
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}