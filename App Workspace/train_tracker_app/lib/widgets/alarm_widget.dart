import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/train.dart';
import '../providers/settings_provider.dart';

class AlarmWidget extends StatelessWidget {
  final Train train;
  const AlarmWidget({super.key, required this.train});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: settings.alarmEnabled
            ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: settings.alarmEnabled
              ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            settings.alarmEnabled ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
            color: settings.alarmEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.white38,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('arrival_alarm'.tr(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(
                  settings.alarmEnabled
                      ? 'alarm_set_for'.tr(namedArgs: {
                          'dest': train.to,
                          'min': settings.alarmMinutesBefore.toString(),
                        })
                      : 'alarm_off_hint'.tr(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: settings.alarmEnabled,
            onChanged: (v) => settings.setAlarm(v),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
