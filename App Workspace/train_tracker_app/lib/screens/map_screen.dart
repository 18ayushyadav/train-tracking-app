import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/train_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainProvider>(
      builder: (ctx, provider, _) {
        final train = provider.train;
        final center = (train?.lat != null && train?.lon != null)
            ? LatLng(train!.lat!, train.lon!)
            : const LatLng(20.5937, 78.9629); // Geographic center of India

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              train != null ? '${train.trainNo} · ${train.currentStation}' : 'live_map'.tr(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: train != null ? 10.0 : 5.5,
                ),
                children: [
                  TileLayer(
                    // Using a dark CartoDB tile layer for visual consistency
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.train_tracker_app',
                  ),
                  if (train?.lat != null && train?.lon != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(train!.lat!, train.lon!),
                          width: 60,
                          height: 60,
                          child: _TrainMarker(trainNo: train.trainNo),
                        ),
                      ],
                    ),
                ],
              ),
              // Info overlay at bottom
              if (train != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _MapInfoCard(train: train),
                ),
              // Attribution
              Positioned(
                bottom: train != null ? 120 : 8,
                right: 8,
                child: const Text(
                  '© OpenStreetMap · © CARTO',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrainMarker extends StatefulWidget {
  final String trainNo;
  const _TrainMarker({required this.trainNo});

  @override
  State<_TrainMarker> createState() => _TrainMarkerState();
}

class _TrainMarkerState extends State<_TrainMarker> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 2.0).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeOut)),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    blurRadius: 12, spreadRadius: 2)
              ],
            ),
            child: const Icon(Icons.train_rounded, color: Colors.white, size: 18),
          ),
        ],
      );
}

class _MapInfoCard extends StatelessWidget {
  final dynamic train;
  const _MapInfoCard({required this.train});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E1A).withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.speed_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(train.trainName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  Text('${train.currentStation} → ${train.nextStation ?? train.to}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${train.speed.toStringAsFixed(0)} km/h',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(train.isOnTime ? 'On Time' : '${train.delayMinutes}m late',
                    style: TextStyle(
                      color: train.isOnTime ? const Color(0xFF4CAF50) : Colors.orange,
                      fontSize: 12,
                    )),
              ],
            ),
          ],
        ),
      );
}
