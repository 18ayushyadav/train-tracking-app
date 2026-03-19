import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/train_provider.dart';
import '../widgets/train_card.dart';
import '../widgets/speed_indicator.dart';
import '../widgets/eta_widget.dart';
import '../widgets/alarm_widget.dart';

class TrainStatusScreen extends StatelessWidget {
  const TrainStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              provider.train?.trainName ?? 'train_status'.tr(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (provider.train != null)
                IconButton(
                  icon: const Icon(Icons.map_outlined, color: Colors.white70),
                  onPressed: () => Navigator.pushNamed(context, '/map'),
                ),
              IconButton(
                icon: Icon(
                  Icons.circle,
                  color: provider.isConnected ? const Color(0xFF4CAF50) : Colors.grey,
                  size: 12,
                ),
                tooltip: provider.isConnected ? 'Live' : 'Polling',
                onPressed: null,
              ),
            ],
          ),
          body: _buildBody(context, provider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TrainProvider provider) {
    switch (provider.state) {
      case TrainLoadState.loading:
        return const Center(child: _PulsingTrainLoader());
      case TrainLoadState.error:
        return _ErrorView(message: provider.errorMessage);
      case TrainLoadState.idle:
        return Center(child: Text('enter_train_number'.tr(),
            style: const TextStyle(color: Colors.white54)));
      case TrainLoadState.loaded:
      case TrainLoadState.offline:
        return _TrainStatusBody(train: provider.train!);
    }
  }
}

class _TrainStatusBody extends StatelessWidget {
  final dynamic train;
  const _TrainStatusBody({required this.train});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (train.isOffline)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text('offline_mode_notice'.tr(),
                      style: const TextStyle(color: Colors.orange, fontSize: 13))),
                ],
              ),
            ),
          TrainCard(train: train),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: SpeedIndicator(speedKmh: train.speed)),
              const SizedBox(width: 16),
              Expanded(child: ETAWidget(train: train)),
            ],
          ),
          const SizedBox(height: 20),
          AlarmWidget(train: train),
          const SizedBox(height: 20),
          _RouteInfo(train: train),
        ],
      ),
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final dynamic train;
  const _RouteInfo({required this.train});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('route_info'.tr(),
              style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StationDot(label: 'from'.tr(), code: train.from, color: const Color(0xFF4CAF50)),
              const Expanded(child: _DottedLine()),
              _StationDot(label: 'to'.tr(), code: train.to, color: const Color(0xFFEF5350)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${'current_station'.tr()}: ${train.currentStation}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (train.delayMinutes > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Text('delay_minutes'.tr(namedArgs: {'n': train.delayMinutes.toString()}),
                    style: const TextStyle(color: Colors.orange, fontSize: 13)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${'last_updated'.tr()}: ${_formatTime(train.lastUpdated)}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }
}

class _StationDot extends StatelessWidget {
  final String label, code;
  final Color color;
  const _StationDot({required this.label, required this.code, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
          const SizedBox(height: 4),
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 4),
          Text(code, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      );
}

class _DottedLine extends StatelessWidget {
  const _DottedLine();
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DottedLinePainter(),
        size: const Size(double.infinity, 2),
      );
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), paint);
      x += 12;
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _PulsingTrainLoader extends StatefulWidget {
  const _PulsingTrainLoader();
  @override
  State<_PulsingTrainLoader> createState() => _PulsingTrainLoaderState();
}

class _PulsingTrainLoaderState extends State<_PulsingTrainLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: Tween(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: Icon(Icons.train_rounded,
            size: 60, color: Theme.of(context).colorScheme.primary),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF5350), size: 56),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15)),
            ),
          ],
        ),
      );
}
