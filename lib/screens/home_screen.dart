import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../game/game_screen.dart';
import '../services/game_settings.dart';
import '../services/score_service.dart';
import '../services/settings_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SettingsService _settingsService = SettingsService();

  final ScoreService _scoreService = ScoreService();

  GameSettings settings = const GameSettings();

  PlayerStats stats = const PlayerStats(
    highScore: 0,
    gamesPlayed: 0,
    totalLines: 0,
  );

  bool loading = true;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final loadedSettings = await _settingsService.load();

    final loadedStats = await _scoreService.loadStats();

    if (!mounted) return;

    setState(() {
      settings = loadedSettings;
      stats = loadedStats;
      loading = false;
    });
  }

  Future<void> _play() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => GameScreen(settings: settings)));

    await _refreshStats();
  }

  Future<void> _refreshStats() async {
    final value = await _scoreService.loadStats();

    if (!mounted) return;

    setState(() {
      stats = value;
    });
  }

  Future<void> _settings() async {
    final result = await Navigator.of(context).push<GameSettings>(
      MaterialPageRoute(builder: (_) => SettingsScreen(settings: settings)),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      settings = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090D18),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090D18),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      children: [
                        const SizedBox(height: 25),

                        const _Logo(),

                        const SizedBox(height: 45),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _HomeStat(
                                label: 'HIGH SCORE',
                                value: '${stats.highScore}',
                              ),
                              _HomeStat(
                                label: 'GAMES',
                                value: '${stats.gamesPlayed}',
                              ),
                              _HomeStat(
                                label: 'TOTAL LINES',
                                value: '${stats.totalLines}',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton.icon(
                            onPressed: _play,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow, size: 30),
                            label: const Text(
                              'PLAY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _settings,
                            icon: const Icon(Icons.settings_outlined),
                            label: const Text('SETTINGS'),
                          ),
                        ),

                        const SizedBox(height: 35),

                        const Text(
                          'Tap to rotate  •  Swipe to move\n'
                          'Swipe down to drop',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isBannerLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
                blurRadius: 30,
              ),
            ],
          ),
          child: const Icon(Icons.grid_view_rounded, size: 42),
        ),
        const SizedBox(height: 18),
        const Text(
          'BLOCK DROP',
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'FALL • BUILD • CLEAR',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HomeStat extends StatelessWidget {
  final String label;
  final String value;

  const _HomeStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFACC15),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
