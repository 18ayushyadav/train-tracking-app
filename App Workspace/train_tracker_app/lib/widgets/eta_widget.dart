import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/train.dart';

class ETAWidget extends StatelessWidget {
  final Train train;
  const ETAWidget({super.key, required this.train});

  @override
  Widget build(BuildContext context) {
    final isLate = train.delayMinutes > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text('eta'.tr(),
              style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(
            train.etaDisplay,
            style: TextStyle(
              color: isLate ? Colors.orange : const Color(0xFF4CAF50),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLate ? Icons.schedule_rounded : Icons.check_circle_outline_rounded,
                color: isLate ? Colors.orange : const Color(0xFF4CAF50),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isLate
                    ? 'delayed_by'.tr(namedArgs: {'n': train.delayMinutes.toString()})
                    : 'on_time'.tr(),
                style: TextStyle(
                  color: isLate ? Colors.orange : const Color(0xFF4CAF50),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
