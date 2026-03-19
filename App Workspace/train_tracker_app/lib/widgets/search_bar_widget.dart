import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Reusable search widgets for both Train number and PNR entry
class TrainSearchWidget extends StatefulWidget {
  final void Function(String trainNo) onSearch;
  const TrainSearchWidget({super.key, required this.onSearch});
  @override
  State<TrainSearchWidget> createState() => _TrainSearchWidgetState();
}

class _TrainSearchWidgetState extends State<TrainSearchWidget> {
  final _ctrl = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _key,
        child: Column(
          children: [
            TextFormField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              maxLength: 5,
              style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '12951',
                hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 4),
                counterText: '',
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.train_outlined, color: Colors.white38),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white38),
                  onPressed: _ctrl.clear,
                ),
              ),
              validator: (v) => (v == null || v.length != 5) ? 'train_validation'.tr() : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_key.currentState!.validate()) widget.onSearch(_ctrl.text.trim());
                    },
                    icon: const Icon(Icons.search_rounded),
                    label: Text('search_train'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => widget.onSearch(_ctrl.text.trim()),
                  icon: const Icon(Icons.wifi_off_rounded, size: 18),
                  label: Text('offline'.tr(), style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PNRSearchWidget extends StatefulWidget {
  final void Function(String pnrNo) onSearch;
  const PNRSearchWidget({super.key, required this.onSearch});
  @override
  State<PNRSearchWidget> createState() => _PNRSearchWidgetState();
}

class _PNRSearchWidgetState extends State<PNRSearchWidget> {
  final _ctrl = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _key,
        child: Column(
          children: [
            TextFormField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: '1234567890',
                hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 2),
                counterText: '',
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.confirmation_number_outlined, color: Colors.white38),
              ),
              validator: (v) => (v == null || v.length != 10) ? 'pnr_validation'.tr() : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_key.currentState!.validate()) widget.onSearch(_ctrl.text.trim());
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
