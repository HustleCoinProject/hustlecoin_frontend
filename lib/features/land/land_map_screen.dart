import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:hustlecoin/data/models/land_tile_info.dart';
import 'package:hustlecoin/providers/land_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/land_income_claim_panel.dart';
import 'package:latlong2/latlong.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/services/remote_config_service.dart';

class LandMapScreen extends ConsumerStatefulWidget {
  const LandMapScreen({super.key});

  @override
  ConsumerState<LandMapScreen> createState() => _LandMapScreenState();
}

class _LandMapScreenState extends ConsumerState<LandMapScreen> {
  // H3 and Map Controllers
  final h3 = H3Factory().load();
  final _mapController = MapController();
  Timer? _debounce;

  // State Variables
  List<Polygon> _visibleHexagons = [];
  Polygon? _selectedHexagon;
  String? _selectedH3Index;
  bool _isPurchasing = false;
  bool _isSelling = false;
  bool _isOwnedLand = false; // Track if selected land is owned by user

  String _currentBbox = '';

  // A map for quick lookup of owned tiles in the current view
  Map<String, LandTileInfo> _ownedTilesInView = {};

  // Cooldown mechanism to prevent excessive server requests
  DateTime? _lastFetchTime;
  static const Duration _fetchCooldown = Duration(seconds: 3);

  // Zoom level tracking for fetch control
  double _currentZoom = 13.0;
  static const double MIN_ZOOM_FOR_FETCH =
      12.5; // Minimum zoom to fetch tiles from server

  // Constants
  // Constants
  // Fetched from Remote Config
  int get _h3TileIndexResolution =>
      RemoteConfigService.instance.getLandResolution();
  int get _landPrice => RemoteConfigService.instance.getLandBuyPrice();
  int get _landSellPrice => RemoteConfigService.instance.getLandSellPrice();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // --- Core Logic ---

  // Debounced function to avoid spamming the API while panning the map
  void _onMapMove() {
    // Update current zoom immediately for UI updates
    if (mounted) {
      setState(() {
        _currentZoom = _mapController.camera.zoom;
      });
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchAndDrawHexagons();
    });
  }

  Future<void> _fetchAndDrawHexagons({bool forceFetch = false}) async {
    if (!mounted) return;

    final bounds = _mapController.camera.visibleBounds;
    final zoom = _mapController.camera.zoom;
    final currentUser = ref.read(userControllerProvider).value;
    if (currentUser == null) return;

    // Update current zoom for status indicator
    if (mounted) {
      setState(() {
        _currentZoom = zoom;
      });
    }

    // --- Fetching Logic (only when zoomed in enough) ---
    final shouldFetch = zoom >= MIN_ZOOM_FOR_FETCH;

    if (shouldFetch) {
      // Check cooldown period (unless forced)
      bool canFetch = forceFetch;
      if (!forceFetch) {
        if (_lastFetchTime != null) {
          final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
          canFetch = timeSinceLastFetch >= _fetchCooldown;
          if (!canFetch) {}
        } else {
          canFetch = true;
        }
      }

      if (canFetch) {
        // Format the bounding box string for the API
        final bbox =
            '${bounds.southWest.longitude},${bounds.southWest.latitude},${bounds.northEast.longitude},${bounds.northEast.latitude}';
        _currentBbox = bbox; // Store for invalidation on purchase

        try {
          final ownedTilesData = await ref.read(landTilesProvider(bbox).future);
          // Merge new tiles with existing ones (accumulate, don't replace)
          for (var tile in ownedTilesData) {
            _ownedTilesInView[tile.h3Index] = tile;
          }

          // Update last fetch time after successful fetch
          _lastFetchTime = DateTime.now();
        } catch (e) {
          // Don't clear existing tiles on error, just skip this fetch
        }
      }
    } else {}

    // --- Rendering Logic (always render all cached tiles) ---
    final List<Polygon> newHexes = [];

    // Render all cached tiles regardless of current viewport
    for (final tile in _ownedTilesInView.values) {
      try {
        // Convert h3 index string to H3Index type
        final h3IndexInt = BigInt.parse(tile.h3Index, radix: 16);
        final boundary = h3.cellToBoundary(h3IndexInt);
        final points = boundary.map((geo) => LatLng(geo.lat, geo.lon)).toList();

        Color borderColor;
        Color fillColor;
        double borderOpacity = 1.0;
        double fillOpacity;

        if (tile.ownerId == currentUser.id) {
          // Current user's land - Green
          borderColor = const Color(0xFF14DC78);
          fillColor = const Color(0xFF14DC78);
          fillOpacity = 0.6;
        } else {
          // Other player's land - Yellow/Orange
          borderColor = AppColors.angolaYellow;
          fillColor = AppColors.angolaYellow;
          fillOpacity = 0.5;
        }

        newHexes.add(
          Polygon(
            points: points,
            borderColor: borderColor.withValues(alpha: borderOpacity),
            borderStrokeWidth: 1,
            color: fillColor.withValues(alpha: fillOpacity),
          ),
        );
      } catch (e) {}
    }

    if (mounted) {
      setState(() => _visibleHexagons = newHexes);
    }
  }

  void _onMapTap(TapPosition pos, LatLng latlng) {
    final geoCoord = GeoCoord(lat: latlng.latitude, lon: latlng.longitude);
    final h3IndexInt = h3.geoToCell(geoCoord, _h3TileIndexResolution);
    final h3IndexStr = h3IndexInt.toRadixString(16).toLowerCase();
    final currentUser = ref.read(userControllerProvider).value;

    if (currentUser == null) return;

    // Check if this land is owned
    final ownedTile = _ownedTilesInView[h3IndexStr];
    final isOwnedByUser = ownedTile?.ownerId == currentUser.id;
    final isOwnedByOther = ownedTile != null && !isOwnedByUser;

    // Don't allow selecting land owned by other players
    if (isOwnedByOther) {
      setState(() {
        _selectedH3Index = null;
        _selectedHexagon = null;
        _isOwnedLand = false;
      });
      return;
    }

    final boundary = h3.cellToBoundary(h3IndexInt);
    final points = boundary.map((geo) => LatLng(geo.lat, geo.lon)).toList();

    setState(() {
      _selectedH3Index = h3IndexStr;
      _isOwnedLand = isOwnedByUser;
      _selectedHexagon = Polygon(
        points: points,
        borderColor: isOwnedByUser
            ? const Color(0xFFFF4444) // Red border for owned land (sell)
            : AppColors.angolaYellow, // Yellow border for unowned land (buy)
        borderStrokeWidth: 3,
        color: Colors.transparent,
      );
    });
  }

  Future<void> _purchaseLand() async {
    if (_selectedH3Index == null || _isPurchasing) return;

    setState(() => _isPurchasing = true);

    try {
      // Purchase the land - this will only update user balance
      await ref
          .read(userControllerProvider.notifier)
          .buyLand(_selectedH3Index!);

      if (mounted) {
        // Clear selection first
        setState(() {
          _selectedH3Index = null;
          _selectedHexagon = null;
          _isOwnedLand = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.t(LocalizationKeys.landPurchasedSuccessfully)),
            backgroundColor: Colors.green,
          ),
        );

        // Invalidate providers after a short delay to avoid circular dependency
        Future.delayed(const Duration(milliseconds: 200), () async {
          if (mounted) {
            // Invalidate both land-related providers to force fresh data
            ref.invalidate(landTilesProvider(_currentBbox));
            ref.invalidate(myLandsProvider);

            // Small additional delay to ensure providers are invalidated
            await Future.delayed(const Duration(milliseconds: 100));

            // Force refresh the hexagons display with new data
            await _fetchAndDrawHexagons();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${ref.t(LocalizationKeys.purchaseFailed)}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _sellLand() async {
    if (_selectedH3Index == null || _isSelling) return;

    setState(() => _isSelling = true);

    try {
      // Sell the land
      await ref
          .read(userControllerProvider.notifier)
          .sellLand(_selectedH3Index!);

      if (mounted) {
        // Clear selection first
        setState(() {
          _selectedH3Index = null;
          _selectedHexagon = null;
          _isOwnedLand = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.t(LocalizationKeys.landSoldSuccessfully)),
            backgroundColor: Colors.green,
          ),
        );

        // Invalidate providers after a short delay to avoid circular dependency
        Future.delayed(const Duration(milliseconds: 200), () async {
          if (mounted) {
            // Invalidate both land-related providers to force fresh data
            ref.invalidate(landTilesProvider(_currentBbox));
            ref.invalidate(myLandsProvider);

            // Small additional delay to ensure providers are invalidated
            await Future.delayed(const Duration(milliseconds: 100));

            // Force refresh the hexagons display with new data (bypass cooldown)
            await _fetchAndDrawHexagons(forceFetch: true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${ref.t(LocalizationKeys.saleFailed)}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSelling = false);
      }
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-8.83, 13.23),
              initialZoom: 13.0,
              onMapReady: _fetchAndDrawHexagons,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd || event is MapEventRotateEnd) {
                  _onMapMove();
                }
              },
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              PolygonLayer(polygons: _visibleHexagons),
              if (_selectedHexagon != null)
                PolygonLayer(polygons: [_selectedHexagon!]),
              if (_selectedHexagon != null && _selectedH3Index != null)
                _buildPriceOverlay(),
            ],
          ),
          _buildUIOverlay(),
        ],
      ),
    );
  }

  Widget _buildUIOverlay() {
    return SafeArea(
      child: Stack(
        children: [
          // Back Button
          Positioned(
            top: 15.h,
            left: 15.w,
            child: GestureDetector(
              onTap: () {
                SoundService().playClick();
                Navigator.of(context).pop();
              },
              child: GlassContainer(
                borderRadius: 12.r,
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 14.s),
                    SizedBox(width: 5.s),
                    Text(
                      ref.t(LocalizationKeys.back),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.f,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Zoom Status Indicator (Top-Right)
          Positioned(
            top: 15.h,
            right: 15.w,
            child: _buildZoomStatusIndicator(),
          ),
          // Land Income Claim Panel and Daily Income Info Panel
          Positioned(
            top: 15.h,
            left: 15.w,
            right: 15.w,
            child: Column(
              children: [
                SizedBox(height: 60.h), // Space for back button
                // Land Income Claim Panel
                const LandIncomeClaimPanel(),
                SizedBox(height: 10.h),
                // Daily Income Info Panel
                GlassContainer(
                  borderRadius: 12.r,
                  padding: ResponsiveUtils.pSymmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.angolaYellow,
                        size: 18.s,
                      ),
                      SizedBox(width: 10.s),
                      Expanded(
                        child: Text(
                          ref.t(LocalizationKeys.landDailyIncomeInfo),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.f,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Purchase Panel
          Positioned(
            bottom: 20.h,
            left: 20.w,
            right: 20.w,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: _selectedH3Index != null
                  ? _buildActionPanel()
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    final userAsyncValue = ref.watch(userControllerProvider);
    final user = userAsyncValue.value;

    if (_isOwnedLand) {
      // Show sell panel for owned land
      return GlassContainer(
        key: const ValueKey('sell_panel'),
        borderRadius: 16.r,
        padding: ResponsiveUtils.pSymmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.yourLand),
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12.f),
                  ),
                  Text(
                    _selectedH3Index ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.f,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.s),
            GestureDetector(
              onTap: !_isSelling
                  ? () {
                      SoundService().playClick();
                      _sellLand();
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: !_isSelling
                      ? const LinearGradient(
                          colors: [AppColors.angolaRed, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _isSelling ? Colors.grey.shade800 : null,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: _isSelling
                    ? SizedBox(
                        height: 16.s,
                        width: 16.s,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.coins,
                            size: 14.s,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.s),
                          Text(
                            '${ref.t(LocalizationKeys.sell)} $_landSellPrice HP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.f,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Show purchase panel for unowned land
      final canAfford = user != null && user.hpScore >= _landPrice;

      return GlassContainer(
        key: const ValueKey('purchase_panel'),
        borderRadius: 16.r,
        padding: ResponsiveUtils.pSymmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.selectedLand),
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12.f),
                  ),
                  Text(
                    _selectedH3Index ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.f,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.s),
            GestureDetector(
              onTap: (canAfford && !_isPurchasing)
                  ? () {
                      SoundService().playClick();
                      _purchaseLand();
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: (canAfford && !_isPurchasing)
                      ? const LinearGradient(
                          colors: [AppColors.angolaYellow, AppColors.angolaRed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !(canAfford && !_isPurchasing)
                      ? Colors.grey.shade800
                      : null,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: _isPurchasing
                    ? SizedBox(
                        height: 16.s,
                        width: 16.s,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.coins,
                            size: 14.s,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.s),
                          Text(
                            '${_landPrice} HP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.f,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPriceOverlay() {
    if (_selectedHexagon == null || _selectedH3Index == null) {
      return const SizedBox.shrink();
    }

    // Calculate the center of the selected hexagon
    final points = _selectedHexagon!.points;
    if (points.isEmpty) return const SizedBox.shrink();

    // Find center point of the hexagon
    double centerLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    double centerLon =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    final centerPoint = LatLng(centerLat, centerLon);

    // Determine price and text based on ownership
    String priceText;
    Color textColor = Colors.white;

    if (_isOwnedLand) {
      priceText = '${_landSellPrice} HP';
    } else {
      priceText = '${_landPrice} HP';
    }

    return MarkerLayer(
      markers: [
        Marker(
          point: centerPoint,
          alignment: Alignment.bottomCenter,
          child: Text(
            priceText,
            style: TextStyle(
              color: textColor,
              fontSize: 7.f,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 2.s,
                  offset: Offset(0, 1.s),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomStatusIndicator() {
    final isZoomedEnough = _currentZoom >= MIN_ZOOM_FOR_FETCH;
    final zoomText = _currentZoom.toStringAsFixed(1);
    final minZoomText = MIN_ZOOM_FOR_FETCH.toStringAsFixed(1);

    // Determine status icon, color, and text based on zoom level
    IconData statusIcon;
    Color statusColor;
    String statusText;
    String statusSubtext;

    if (isZoomedEnough) {
      statusIcon = Icons.check_circle;
      statusColor = const Color(0xFF14DC78); // Green
      statusText = 'Loading Tiles';
      statusSubtext = 'Zoom: $zoomText';
    } else {
      statusIcon = Icons.zoom_in;
      statusColor = AppColors.angolaYellow; // Yellow
      statusText = 'Zoom In to Load';
      statusSubtext = '$zoomText / $minZoomText';
    }

    return GlassContainer(
      borderRadius: 12.r,
      padding: ResponsiveUtils.pSymmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14.s, color: statusColor),
              SizedBox(width: 5.s),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.f,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            statusSubtext,
            style: TextStyle(
              color: statusColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 9.f,
            ),
          ),
        ],
      ),
    );
  }
}
