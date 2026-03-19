import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('settings'.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'appearance'.tr()),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'dark_mode'.tr(),
            subtitle: 'dark_mode_desc'.tr(),
            trailing: Switch(
              value: settings.themeMode == ThemeMode.dark,
              onChanged: settings.setDarkMode,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'language'.tr(),
            subtitle: context.locale.languageCode == 'en' ? 'English' : 'हिन्दी',
            trailing: TextButton(
              onPressed: () => settings.toggleLanguage(context),
              child: Text(context.locale.languageCode == 'en' ? 'हिन्दी' : 'English',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'notifications'.tr()),
          _SettingsTile(
            icon: Icons.alarm_rounded,
            title: 'arrival_alarm'.tr(),
            subtitle: 'alarm_desc'.tr(),
            trailing: Switch(
              value: settings.alarmEnabled,
              onChanged: (v) => settings.setAlarm(v),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (settings.alarmEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${'alarm_before'.tr()}: ${settings.alarmMinutesBefore} min',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Slider(
                    value: settings.alarmMinutesBefore.toDouble(),
                    min: 5, max: 60, divisions: 11,
                    label: '${settings.alarmMinutesBefore} min',
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (v) => settings.setAlarm(true, minutesBefore: v.round()),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'battery_privacy'.tr()),
          _SettingsTile(
            icon: Icons.battery_saver_rounded,
            title: 'battery_optimize'.tr(),
            subtitle: 'battery_optimize_desc'.tr(),
            trailing: Switch(
              value: settings.batteryOptimize,
              onChanged: settings.setBatteryOptimize,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.cell_tower_rounded,
            title: 'crowdsource_towers'.tr(),
            subtitle: 'crowdsource_desc'.tr(),
            trailing: Switch(
              value: settings.crowdsourceEnabled,
              onChanged: settings.setCrowdsource,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'about'.tr()),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'app_version'.tr(),
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'privacy_policy'.tr(),
            subtitle: 'privacy_subtitle'.tr(),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(title.toUpperCase(),
            style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5,
                fontWeight: FontWeight.w600)),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title,
      required this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: trailing,
          onTap: onTap,
        ),
      );
}
