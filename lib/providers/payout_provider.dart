import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/payout.dart';
import '../data/models/payout_info.dart';
import '../data/models/payout_request.dart';
import '../data/repositories/data_repository.dart';
import 'foundational_providers.dart';

// Provider for payout info
final payoutInfoProvider = FutureProvider<PayoutInfo>((ref) async {
  final dataRepository = ref.read(dataRepositoryProvider);
  return dataRepository.getPayoutInfo();
});

// Provider for payout methods
final payoutMethodsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dataRepository = ref.read(dataRepositoryProvider);
  return dataRepository.getPayoutMethods();
});

// Provider for payout history
final payoutHistoryProvider = FutureProvider.family<List<Payout>, PayoutHistoryParams>((ref, params) async {
  final dataRepository = ref.read(dataRepositoryProvider);
  return dataRepository.getPayoutHistory(limit: params.limit, offset: params.offset);
});

// Provider for system status
final payoutSystemStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dataRepository = ref.read(dataRepositoryProvider);
  return dataRepository.getPayoutSystemStatus();
});

// StateNotifier for payout operations
class PayoutNotifier extends StateNotifier<PayoutState> {
  PayoutNotifier(this._dataRepository) : super(PayoutState.initial());

  final DataRepository _dataRepository;

  Future<void> updatePayoutInfo({
    String? phoneNumber,
    String? fullName,
    String? nationalId,
    String? bankIban,
    String? bankName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _dataRepository.updatePayoutInfo(
        phoneNumber: phoneNumber,
        fullName: fullName,
        nationalId: nationalId,
        bankIban: bankIban,
        bankName: bankName,
      );
      state = state.copyWith(isLoading: false, updateSuccess: true);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<Payout?> requestPayout(PayoutRequest payoutRequest) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final payout = await _dataRepository.requestPayout(payoutRequest);
      state = state.copyWith(
        isLoading: false,
        lastPayout: payout,
        payoutSuccess: true,
      );
      return payout;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return null;
    }
  }

  void clearState() {
    state = PayoutState.initial();
  }

  void clearSuccess() {
    state = state.copyWith(updateSuccess: false, payoutSuccess: false);
  }
}

// StateNotifier provider
final payoutProvider = StateNotifierProvider<PayoutNotifier, PayoutState>((ref) {
  final dataRepository = ref.read(dataRepositoryProvider);
  return PayoutNotifier(dataRepository);
});

// State class for payout operations
class PayoutState {
  final bool isLoading;
  final String? error;
  final bool updateSuccess;
  final bool payoutSuccess;
  final Payout? lastPayout;

  const PayoutState({
    required this.isLoading,
    this.error,
    required this.updateSuccess,
    required this.payoutSuccess,
    this.lastPayout,
  });

  factory PayoutState.initial() {
    return const PayoutState(
      isLoading: false,
      error: null,
      updateSuccess: false,
      payoutSuccess: false,
      lastPayout: null,
    );
  }

  PayoutState copyWith({
    bool? isLoading,
    String? error,
    bool? updateSuccess,
    bool? payoutSuccess,
    Payout? lastPayout,
  }) {
    return PayoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      payoutSuccess: payoutSuccess ?? this.payoutSuccess,
      lastPayout: lastPayout ?? this.lastPayout,
    );
  }
}

// Helper class for payout history parameters
class PayoutHistoryParams {
  final int limit;
  final int offset;

  const PayoutHistoryParams({this.limit = 50, this.offset = 0});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PayoutHistoryParams &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => limit.hashCode ^ offset.hashCode;
}