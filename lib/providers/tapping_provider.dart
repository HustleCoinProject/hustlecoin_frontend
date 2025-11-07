import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tapping_service.dart';

// Simple tapping controller provider
final tappingControllerProvider = Provider<TappingService>((ref) {
  return ref.read(tappingServiceProvider);
});
