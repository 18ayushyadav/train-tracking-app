import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/train_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heroAnim;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _heroAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut);
    _heroAnim.forward();
  }

  @override
  void dispose() {
    _heroAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E1A),
              cs.primary.withOpacity(0.15),
              const Color(0xFF0A0E1A),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                const SizedBox(height: 24),
                _buildHero(context),
                const SizedBox(height: 40),
                _buildSearchTabs(context),
                const Spacer(),
                _buildLiveFeedBanner(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.train_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('app_name'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('app_subtitle'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white70),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      );

  Widget _buildHero(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('hero_title'.tr(),
                style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
                  height: 1.2,
                )),
            const SizedBox(height: 8),
            Text('hero_subtitle'.tr(),
                style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6))),
          ],
        ),
      );

  Widget _buildSearchTabs(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                tabs: [
                  Tab(text: 'tab_train'.tr()),
                  Tab(text: 'tab_pnr'.tr()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: TabBarView(
              children: [
                TrainSearchWidget(onSearch: (no) => _searchTrain(context, no)),
                PNRSearchWidget(onSearch: (pnr) => _searchPNR(context, pnr)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFeedBanner(BuildContext context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.circle, color: Color(0xFF4CAF50), size: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Text('live_feed_active'.tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/map'),
              child: Text('view_map'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
      );

  void _searchTrain(BuildContext context, String trainNo) {
    if (trainNo.isEmpty) return;
    context.read<TrainProvider>().loadTrain(trainNo);
    Navigator.pushNamed(context, '/train');
  }

  void _searchPNR(BuildContext context, String pnrNo) {
    if (pnrNo.isEmpty) return;
    context.read<TrainProvider>().loadPNR(pnrNo);
    Navigator.pushNamed(context, '/pnr');
  }
}
