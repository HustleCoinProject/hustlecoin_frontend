import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart'; // Assuming you have this file from the previous steps

// --- Reusable Helper Widgets ---

// High-performance "smoky glass" container without blur
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const _GlassEffectContainer({
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
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}

// Lightweight press feedback widget
class PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const PressableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<PressableWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// Data model for a shop product
class Product {
  final IconData icon;
  final String title;
  final String description;
  final int price;

  const Product({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
  });
}

// --- Main Shop Screen Widget ---

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  // Dummy data for the shop
  final List<Product> products = const [
    Product(
      icon: FontAwesomeIcons.rocket,
      title: 'Nitro Boost',
      description: 'Double your earnings for the next 1 hour.',
      price: 150,
    ),
    Product(
      icon: FontAwesomeIcons.key,
      title: 'Silver Key',
      description: 'Unlocks a special mission with guaranteed rewards.',
      price: 300,
    ),
    Product(
      icon: FontAwesomeIcons.shieldHalved,
      title: 'Safety Shield',
      description: 'Protects your streak from being broken for 24 hours.',
      price: 500,
    ),
    Product(
      icon: FontAwesomeIcons.bolt,
      title: 'Full Energy',
      description: 'Instantly refills your energy to 100%.',
      price: 100,
    ),
    Product(
      icon: FontAwesomeIcons.gem,
      title: 'Rare Gem',
      description: 'A valuable item that can be traded with other players.',
      price: 1000,
    ),
    Product(
      icon: FontAwesomeIcons.mapLocationDot,
      title: 'New Area',
      description: 'Unlocks a new district with higher paying hustles.',
      price: 2500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Taxi Driver.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF101010).withOpacity(0.4),
                const Color(0xFF101010).withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(children: [_buildHeader(context), _buildContent()]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          PressableWidget(
            onTap: () {
              // Add navigation logic, e.g., Navigator.pop(context);
            },
            child: const _GlassEffectContainer(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(FontAwesomeIcons.arrowLeft, size: 20),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Shop',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ),
          _GlassEffectContainer(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.angolaRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.star,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1,250 HC',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '≈ Kz 12,507',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(15.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75, // Adjust this ratio to fit content
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(16, 16, 16, 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(product.icon, size: 40, color: AppColors.angolaYellow),
          ),
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              product.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
          const SizedBox(height: 15),
          PressableWidget(
            onTap: () {
              // Handle buy logic
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppColors.angolaYellow, AppColors.angolaRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.coins,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${product.price} HC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
