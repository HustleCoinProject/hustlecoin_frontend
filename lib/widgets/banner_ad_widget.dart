import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hustlecoin/services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.backgroundColor,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adMobService = AdMobService();
      final bannerAd = await adMobService.loadBannerAd();

      if (bannerAd != null && mounted) {
        setState(() {
          _bannerAd = bannerAd;
          _isAdLoaded = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!_isAdLoaded || _bannerAd == null) {
      // Return empty container if ad failed to load
      return const SizedBox.shrink();
    }

    return Container(
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
