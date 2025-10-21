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
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:latlong2/latlong.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';

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

  // Constants
  static const int DATA_RESOLUTION = 8;
  static const double MAX_COLOR_ZOOM =
      10.0; // Lowered from 14.0 to show colors earlier
  static const int LAND_PRICE = 500; // Corresponds to backend LAND_PRICE
  static const int LAND_SELL_PRICE = 400; // 80% of purchase price

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // --- Core Logic ---

  int getVisualResolutionForZoom(double zoom) {
    if (zoom <= 3) return 1;
    if (zoom <= 5) return 2;
    if (zoom <= 7) return 4;
    if (zoom <= 9) return 5;
    if (zoom <= 12) return 6;
    if (zoom <= 14) return 7;
    return DATA_RESOLUTION;
  }

  // Debounced function to avoid spamming the API while panning the map
  void _onMapMove() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchAndDrawHexagons();
    });
  }

  Future<void> _fetchAndDrawHexagons() async {
    if (!mounted) return;

    final bounds = _mapController.camera.visibleBounds;
    final zoom = _mapController.camera.zoom;

    // Format the bounding box string for the API
    final bbox =
        '${bounds.southWest.longitude},${bounds.southWest.latitude},${bounds.northEast.longitude},${bounds.northEast.latitude}';
    _currentBbox = bbox; // Store for invalidation on purchase

    // Fetch owned tiles within the current view
    final currentUser = ref.read(userControllerProvider).value;
    if (currentUser == null) return;

    try {
      final ownedTilesData = await ref.read(landTilesProvider(bbox).future);
      // Update the local lookup map
      _ownedTilesInView = {for (var tile in ownedTilesData) tile.h3Index: tile};
      debugPrint("Loaded ${ownedTilesData.length} owned tiles in current view");
    } catch (e) {
      debugPrint("Failed to fetch owned tiles: $e");
      // Continue with empty owned tiles if fetch fails
      _ownedTilesInView = {};
    }

    final showColors = zoom >= MAX_COLOR_ZOOM;
    final renderResolution = showColors
        ? DATA_RESOLUTION
        : getVisualResolutionForZoom(zoom);

    final geoPolygon = [
      GeoCoord(lat: bounds.northWest.latitude, lon: bounds.northWest.longitude),
      GeoCoord(lat: bounds.northEast.latitude, lon: bounds.northEast.longitude),
      GeoCoord(lat: bounds.southEast.latitude, lon: bounds.southEast.longitude),
      GeoCoord(lat: bounds.southWest.latitude, lon: bounds.southWest.longitude),
    ];

    final visibleIndexes = h3.polygonToCells(
      perimeter: geoPolygon,
      resolution: renderResolution,
    );

    final List<Polygon> newHexes = [];
    for (final index in visibleIndexes) {
      final boundary = h3.cellToBoundary(index);
      final points = boundary.map((geo) => LatLng(geo.lat, geo.lon)).toList();

      Color borderColor = Colors.white;
      double borderOpacity = 0.15;
      Color? fillColor;
      double fillOpacity = 0.4;

      final h3IndexStr = index.toRadixString(16).toLowerCase();
      final ownedTile = _ownedTilesInView[h3IndexStr];

      // Always show owned land colors if there's an owned tile, regardless of zoom
      if (ownedTile != null) {
        if (ownedTile.ownerId == currentUser.id) {
          // Current user's land - Green
          borderColor = const Color(0xFF14DC78);
          fillColor = const Color(0xFF14DC78);
          borderOpacity = 1.0;
          fillOpacity = 0.6; // Make it more visible
        } else {
          // Other player's land - Orange/Red
          borderColor = AppColors
              .angolaYellow; // Changed to yellow/orange for better visibility
          fillColor = AppColors.angolaYellow;
          borderOpacity = 1.0;
          fillOpacity = 0.5;
        }
      } else if (showColors) {
        // Show subtle grid for unowned land only at high zoom
        borderOpacity = 0.15;
        fillOpacity = 0.1;
      }

      newHexes.add(
        Polygon(
          points: points,
          borderColor: borderColor.withValues(alpha: borderOpacity),
          borderStrokeWidth: 1,
          color:
              fillColor?.withValues(alpha: fillOpacity) ?? Colors.transparent,
        ),
      );
    }
    if (mounted) {
      setState(() => _visibleHexagons = newHexes);
    }
  }

  void _onMapTap(TapPosition pos, LatLng latlng) {
    final geoCoord = GeoCoord(lat: latlng.latitude, lon: latlng.longitude);
    final h3IndexInt = h3.geoToCell(geoCoord, DATA_RESOLUTION);
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
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
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
            top: 15,
            left: 15,
            child: GestureDetector(
              onTap: () {
                SoundService().playClick();
                Navigator.of(context).pop();
              },
              child: GlassContainer(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      ref.t(LocalizationKeys.back),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Daily Income Info Panel
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                const SizedBox(height: 60), // Space for back button
                GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.angolaYellow,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ref.t(LocalizationKeys.landDailyIncomeInfo),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
            bottom: 20,
            left: 20,
            right: 20,
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
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.yourLand),
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _selectedH3Index ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: !_isSelling
                  ? () {
                      SoundService().playClick();
                      _sellLand();
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isSelling
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.coins,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${ref.t(LocalizationKeys.sell)} $LAND_SELL_PRICE HC',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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
      final canAfford = user != null && user.hcBalance >= LAND_PRICE;

      return GlassContainer(
        key: const ValueKey('purchase_panel'),
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.selectedLand),
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _selectedH3Index ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: (canAfford && !_isPurchasing)
                  ? () {
                      SoundService().playClick();
                      _purchaseLand();
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isPurchasing
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.coins,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${LAND_PRICE} HC',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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
      priceText = '${LAND_SELL_PRICE} HC';
    } else {
      priceText = '${LAND_PRICE} HC';
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
              fontSize: 7,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
