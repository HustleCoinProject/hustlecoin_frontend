import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'app_colors.dart'; // Assuming you have this file

// --- Reusable "Smoky Glass" Widget ---
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const _GlassEffectContainer({
    Key? key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15),
        ],
      ),
      child: child,
    );
  }
}

// --- Main Land Map Screen Widget ---

class LandMapScreen extends StatefulWidget {
  const LandMapScreen({super.key});

  @override
  State<LandMapScreen> createState() => _LandMapScreenState();
}

class _LandMapScreenState extends State<LandMapScreen> {
  // H3 and Map Controllers
  final h3 = H3Factory().load();
  final _mapController = MapController();

  // State Variables
  List<Polygon> _visibleHexagons = [];
  Polygon? _selectedHexagon;
  String? _selectedH3Index;
  final Set<String> _ownedHexagons = {}; // Stores H3 indexes of purchased land

  // Constants
  static const int DATA_RESOLUTION = 8;
  static const double MAX_COLOR_ZOOM = 14.0;
  static const int LAND_PRICE = 500;

  @override
  void initState() {
    super.initState();
    // Add some pre-owned hexagons for demonstration
    _ownedHexagons.addAll(['8842a226bffffff', '8842a2267ffffff']);
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

  void updateVisibleHexagons() {
    if (!mounted) return;

    final bounds = _mapController.camera.visibleBounds;
    final zoom = _mapController.camera.zoom;
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

      if (showColors && _ownedHexagons.contains(index)) {
        borderColor = const Color(0xFF14DC78); // Green
        fillColor = const Color(0xFF14DC78);
        borderOpacity = 1.0;
      }

      newHexes.add(
        Polygon(
          points: points,
          borderColor: borderColor.withOpacity(borderOpacity),
          borderStrokeWidth: 1,
          color: fillColor?.withOpacity(fillOpacity) ?? Colors.transparent,
        ),
      );
    }
    setState(() => _visibleHexagons = newHexes);
  }

  void _onMapTap(TapPosition pos, LatLng latlng) {
    final geoCoord = GeoCoord(lat: latlng.latitude, lon: latlng.longitude);
    final h3Index = h3.geoToCell(geoCoord, DATA_RESOLUTION);

    // Don't allow selecting already owned land
    if (_ownedHexagons.contains(h3Index)) {
      setState(() {
        _selectedH3Index = null;
        _selectedHexagon = null;
      });
      return;
    }

    final boundary = h3.cellToBoundary(h3Index);
    final points = boundary.map((geo) => LatLng(geo.lat, geo.lon)).toList();

    setState(() {
      _selectedH3Index = h3Index.toRadixString(16);
      _selectedHexagon = Polygon(
        points: points,
        borderColor: AppColors.angolaYellow,
        borderStrokeWidth: 3,
      );
    });
  }

  void _purchaseLand() {
    if (_selectedH3Index != null) {
      setState(() {
        _ownedHexagons.add(_selectedH3Index!);
        _selectedH3Index = null;
        _selectedHexagon = null;
      });
      // Redraw the grid to show the newly purchased green hexagon
      updateVisibleHexagons();
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
              onMapReady: updateVisibleHexagons,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd || event is MapEventMoveEnd) {
                  updateVisibleHexagons();
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
              onTap: () => Navigator.of(context).pop(),
              child: const _GlassEffectContainer(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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
                  ? _buildPurchasePanel()
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasePanel() {
    return _GlassEffectContainer(
      key: const ValueKey('purchase_panel'),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Land (Res 8)',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
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
            onTap: _purchaseLand,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.angolaYellow, AppColors.angolaRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
