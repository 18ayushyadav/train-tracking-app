import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/train_provider.dart';

class PNRScreen extends StatefulWidget {
  const PNRScreen({super.key});
  @override
  State<PNRScreen> createState() => _PNRScreenState();
}

class _PNRScreenState extends State<PNRScreen> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('pnr_status'.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TrainProvider>(
        builder: (ctx, provider, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSearchCard(context, provider),
              const SizedBox(height: 24),
              if (provider.state == TrainLoadState.loading)
                const CircularProgressIndicator(),
              if (provider.state == TrainLoadState.loaded && provider.pnrStatus != null)
                _PNRResult(status: provider.pnrStatus!),
              if (provider.state == TrainLoadState.error)
                _ErrorCard(message: provider.errorMessage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, TrainProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('enter_pnr'.tr(),
                style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: '1234567890',
                hintStyle: const TextStyle(color: Colors.white24),
                counterText: '',
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.confirmation_number_outlined, color: Colors.white38),
              ),
              validator: (v) {
                if (v == null || v.length != 10) return 'pnr_validation'.tr();
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    provider.loadPNR(_ctrl.text.trim());
                  }
                },
                icon: const Icon(Icons.search_rounded),
                label: Text('check_pnr'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PNRResult extends StatelessWidget {
  final dynamic status;
  const _PNRResult({required this.status});

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
          Text(status.pnrNo,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('${status.trainNo} · ${status.trainName}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(icon: Icons.calendar_today_outlined, label: status.journeyDate),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.airline_seat_recline_normal_rounded, label: status.travelClass),
            ],
          ),
          const SizedBox(height: 8),
          _InfoChip(
            icon: Icons.info_outline_rounded,
            label: status.chartStatus ?? '',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 20),
          Text('passengers'.tr(),
              style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          ...((status.passengers as List).map((p) => _PassengerRow(passenger: p))),
        ],
      ),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  final dynamic passenger;
  const _PassengerRow({required this.passenger});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = (passenger.currentStatus as String).startsWith('CNF');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isConfirmed
                  ? const Color(0xFF4CAF50).withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_outline_rounded,
                color: isConfirmed ? const Color(0xFF4CAF50) : Colors.orange, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(passenger.name ?? 'Passenger',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(passenger.currentStatus ?? '',
                    style: TextStyle(
                      color: isConfirmed ? const Color(0xFF4CAF50) : Colors.orange,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, this.color = Colors.white54});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) => Text(message,
      style: const TextStyle(color: Colors.redAccent, fontSize: 14));
}

