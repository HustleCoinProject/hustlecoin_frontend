import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/providers/payout_provider.dart';
import 'package:hustlecoin/data/models/payout_request.dart';
import 'package:hustlecoin/data/models/payout_info.dart';
import 'package:hustlecoin/features/payout/payout_history_screen.dart'
    show PayoutHistoryScreen;
import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/services/remote_config_service.dart';

enum PayoutMethod { multicaixaExpress, crypto }

class PayoutScreen extends ConsumerStatefulWidget {
  const PayoutScreen({super.key});

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  PayoutMethod? _selectedMethod;
  final _phoneController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _walletAddressController = TextEditingController();
  final String _selectedNetwork = 'Base'; // Default network
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String? _validateAngolanPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleanPhone = value.trim().replaceAll(' ', '').replaceAll('-', '');

    if (cleanPhone.length != 9) {
      return 'Phone number must be 9 digits';
    }

    if (!cleanPhone.startsWith('9')) {
      return 'Angolan mobile numbers must start with 9';
    }

    if (!RegExp(r'^9[0-9]{8}$').hasMatch(cleanPhone)) {
      return 'Invalid phone number format';
    }

    return null;
  }

  String? _validateAngolanNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'National ID is required';
    }

    // Angolan BI format: XXXXXXXXLA0XX (9 digits + LA + 0 + 2 digits)
    final cleanId = value.trim().toUpperCase();

    if (cleanId.length < 12 || cleanId.length > 14) {
      return 'National ID must be 12-14 characters';
    }

    if (!RegExp(r'^[0-9]{9}LA0[0-9]{2}$').hasMatch(cleanId)) {
      return 'Invalid National ID format (XXXXXXXXXLA0XX)';
    }

    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.trim().length > 100) {
      return 'Name must be less than 100 characters';
    }

    return null;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _accountHolderController.dispose();
    _nationalIdController.dispose();

    _walletAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _populateFormFields(PayoutInfo payoutInfo) {
    bool shouldRebuild = false;

    // Only populate if field is empty to avoid overwriting user input
    if (_phoneController.text.isEmpty &&
        payoutInfo.phoneNumber != null &&
        payoutInfo.phoneNumber!.isNotEmpty) {
      _phoneController.text = payoutInfo.phoneNumber!;
      shouldRebuild = true;
    }

    if (_accountHolderController.text.isEmpty &&
        payoutInfo.fullName != null &&
        payoutInfo.fullName!.isNotEmpty) {
      _accountHolderController.text = payoutInfo.fullName!;
      shouldRebuild = true;
    }

    if (_nationalIdController.text.isEmpty &&
        payoutInfo.nationalId != null &&
        payoutInfo.nationalId!.isNotEmpty) {
      _nationalIdController.text = payoutInfo.nationalId!;
      shouldRebuild = true;
    }

    if (_walletAddressController.text.isEmpty &&
        payoutInfo.cryptoWalletAddress != null &&
        payoutInfo.cryptoWalletAddress!.isNotEmpty) {
      _walletAddressController.text = payoutInfo.cryptoWalletAddress!;
      shouldRebuild = true;
    }

    // Trigger rebuild if any fields were populated
    if (shouldRebuild && mounted) {
      setState(() {});
    }
  }

  void _selectPayoutMethod(PayoutMethod method) {
    setState(() {
      _selectedMethod = method;
    });
    SoundService().playClick();
  }

  Future<void> _saveFormDataToBackend() async {
    try {
      await ref
          .read(payoutProvider.notifier)
          .updatePayoutInfo(
            phoneNumber: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
            fullName: _accountHolderController.text.trim().isNotEmpty
                ? _accountHolderController.text.trim()
                : null,
            nationalId: _nationalIdController.text.trim().isNotEmpty
                ? _nationalIdController.text.trim()
                : null,
            cryptoWalletAddress: _walletAddressController.text.trim().isNotEmpty
                ? _walletAddressController.text.trim()
                : null,
            cryptoNetwork: _selectedNetwork,
          );
    } catch (e) {
      // Don't show error to user as this is a background operation
    }
  }

  Future<void> _requestPayout() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix form errors'),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
        ),
      );
      return;
    }

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payout method'),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
        ),
      );
      return;
    }

    // Validate amount is within allowed range (10,000 - 30,000 HP)
    final amountHp = int.tryParse(_amountController.text) ?? 0;
    if (amountHp < 10000 || amountHp > 30000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Payout amount must be between 10,000 HP and 30,000 HP',
          ),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
        ),
      );
      return;
    }

    // Validate that today is Sunday in Angola time (UTC+1)
    final serverTime = ref.read(serverTimeProvider.notifier).currentServerTime;
    final angolaTime = serverTime.add(
      const Duration(hours: 1),
    ); // Angola is UTC+1
    if (angolaTime.weekday != DateTime.sunday) {
      final daysUntilSunday = (DateTime.sunday - angolaTime.weekday) % 7;
      final nextSunday = daysUntilSunday == 0 ? 7 : daysUntilSunday;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payouts are only allowed on Sundays (Angola time).\nNext available payout: in $nextSunday day${nextSunday > 1 ? "s" : ""}',
          ),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    SoundService().playClick();

    setState(() {
      _isLoading = true;
    });

    try {
      final amountHp = int.tryParse(_amountController.text) ?? 0;

      final payoutMethod = _selectedMethod == PayoutMethod.multicaixaExpress
          ? 'multicaixa_express'
          : 'crypto_transfer';

      final payoutRequest = PayoutRequest(
        amountHp: amountHp,
        payoutMethod: payoutMethod,
        phoneNumber: _selectedMethod == PayoutMethod.multicaixaExpress
            ? _phoneController.text.trim()
            : null,
        fullName: _accountHolderController.text.trim(),
        nationalId: _nationalIdController.text.trim().isNotEmpty
            ? _nationalIdController.text.trim()
            : null,
        cryptoWalletAddress: _selectedMethod == PayoutMethod.crypto
            ? _walletAddressController.text.trim()
            : null,
        cryptoNetwork: _selectedMethod == PayoutMethod.crypto
            ? _selectedNetwork
            : null,
      );

      // Check if provider is available
      final notifier = ref.read(payoutProvider.notifier);

      final payout = await notifier.requestPayout(payoutRequest);

      if (payout != null && mounted) {
        // Save form data to backend for future use
        await _saveFormDataToBackend();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payout request submitted successfully!\nAmount: $amountHp HP (${payout.amountKwanza.toStringAsFixed(2)} AOA)\nStatus: ${payout.statusDisplayText}',
            ),
            backgroundColor: AppColors.angolaYellow.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        // Clear form after successful submission
        _amountController.clear();
        setState(() {
          _selectedMethod = null;
        });

        // Refresh payout info to update available balance
        ref.invalidate(payoutInfoProvider);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Payout request failed - no response from server',
              ),
              backgroundColor: Colors.red.withValues(alpha: 0.9),
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit payout request: $error'),
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        imagePath: 'assets/images/CEO.jpg', // Default background
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: ResponsiveUtils.pSymmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.s),
                        _buildPayoutInfo(),
                        SizedBox(height: 30.s),
                        _buildPayoutMethodSelection(),
                        SizedBox(height: 30.s),
                        if (_selectedMethod != null) ...[
                          _buildPaymentDetails(),
                          SizedBox(height: 30.s),
                        ],
                        _buildAmountInput(),
                        SizedBox(height: 40.s),
                        _buildRequestButton(),
                        SizedBox(height: 20.s),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassContainer(
      borderRadius: 0,
      child: Padding(
        padding: ResponsiveUtils.pSymmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            PressableScaleWidget(
              onTap: () {
                SoundService().playClick();
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.transparent,
                padding: ResponsiveUtils.p(14),
                child: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: AppColors.textLight,
                  size: 20.s,
                ),
              ),
            ),
            SizedBox(width: 15.s),
            Expanded(
              child: Text(
                ref.t(LocalizationKeys.getPaid),
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 20.f,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            PressableScaleWidget(
              onTap: () {
                SoundService().playClick();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PayoutHistoryScreen(),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                padding: ResponsiveUtils.p(14),
                child: FaIcon(
                  FontAwesomeIcons.history,
                  color: AppColors.angolaYellow,
                  size: 20.s,
                  shadows: [
                    Shadow(color: AppColors.glowYellow, blurRadius: 10),
                  ],
                ),
              ),
            ),
            SizedBox(width: 15.s),
            FaIcon(
              FontAwesomeIcons.wallet,
              color: AppColors.angolaYellow,
              size: 24.s,
              shadows: [Shadow(color: AppColors.glowYellow, blurRadius: 10)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.t(LocalizationKeys.selectPayoutMethod),
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 18.f,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 15.s),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                PayoutMethod.multicaixaExpress,
                'Multicaixa Express',
                FontAwesomeIcons.mobileAlt,
              ),
            ),
            SizedBox(width: 15.s),
            Expanded(
              child: _buildMethodCard(
                PayoutMethod.crypto,
                'Crypto (HP)',
                FontAwesomeIcons.bitcoin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard(PayoutMethod method, String title, IconData icon) {
    final isSelected = _selectedMethod == method;

    return PressableScaleWidget(
      onTap: () => _selectPayoutMethod(method),
      child: GlassContainer(
        child: Container(
          padding: ResponsiveUtils.pSymmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isSelected
                ? Border.all(color: AppColors.angolaYellow, width: 2.s)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.glowYellow.withValues(alpha: 0.3),
                      blurRadius: 15.s,
                      spreadRadius: -5.s,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              FaIcon(
                icon,
                color: isSelected ? AppColors.angolaYellow : AppColors.textGrey,
                size: 32.s,
                shadows: isSelected
                    ? [Shadow(color: AppColors.glowYellow, blurRadius: 10)]
                    : null,
              ),
              SizedBox(height: 12.s),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.angolaYellow
                      : AppColors.textGrey,
                  fontSize: 14.f,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    if (_selectedMethod == PayoutMethod.multicaixaExpress) {
      return _buildMulticaixaExpressFields();
    } else {
      return _buildCryptoFields();
    }
  }

  Widget _buildMulticaixaExpressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.t(LocalizationKeys.multicaixaExpressDetails),
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 16.f,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 15.s),
        _buildTextField(
          controller: _phoneController,
          label: ref.t(LocalizationKeys.phoneNumber),
          icon: FontAwesomeIcons.phone,
          hintText: '923456789',
          validator: _validateAngolanPhoneNumber,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 15.s),
        _buildTextField(
          controller: _accountHolderController,
          label: ref.t(LocalizationKeys.accountHolderName),
          icon: FontAwesomeIcons.user,
          hintText: ref.t(LocalizationKeys.enterFullName),
          validator: _validateFullName,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 15.s),
        _buildTextField(
          controller: _nationalIdController,
          label: 'National ID',
          icon: FontAwesomeIcons.idCard,
          hintText: '123456789LA041',
          validator: _validateAngolanNationalId,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCryptoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.t(LocalizationKeys.cryptoDetails),
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 16.f,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 15.s),
        Container(
          padding: ResponsiveUtils.p(12),
          decoration: BoxDecoration(
            color: AppColors.angolaYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.angolaYellow.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                color: AppColors.angolaYellow,
                size: 16.s,
              ),
              SizedBox(width: 10.s),
              Expanded(
                child: Text(
                  'Only use Base Network address. Other networks may result in loss of funds.',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12.f),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.s),
        _buildTextField(
          controller: _walletAddressController,
          label: ref.t(LocalizationKeys.walletAddress),
          icon: FontAwesomeIcons.wallet,
          hintText: '0x...',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return ref.t(LocalizationKeys.walletAddressRequired);
            }
            if (!value.trim().startsWith('0x') || value.trim().length != 42) {
              return 'Invalid EVM wallet address';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 15.s),
        // Network is locked to Base, but displayed for clarity
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.t(LocalizationKeys.cryptoNetwork),
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14.f,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.s),
            GlassContainer(
              child: Container(
                width: double.infinity,
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.networkWired,
                      color: AppColors.angolaYellow,
                      size: 18.s,
                    ),
                    SizedBox(width: 15.s),
                    Text(
                      'Base',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16.f,
                      ),
                    ),
                    const Spacer(),
                    FaIcon(
                      FontAwesomeIcons.lock,
                      color: AppColors.textGrey,
                      size: 14.s,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14.f,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.s),
        GlassContainer(
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: AppColors.textLight, fontSize: 16.f),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.f),
              prefixIcon: Container(
                width: 50.s,
                alignment: Alignment.center,
                child: FaIcon(icon, color: AppColors.angolaYellow, size: 18.s),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: ResponsiveUtils.pSymmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRestrictionRow(String text, {bool isActive = false}) {
    return Row(
      children: [
        FaIcon(
          isActive ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circle,
          color: isActive ? Colors.green : AppColors.textGrey,
          size: 10.s,
        ),
        SizedBox(width: 8.s),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.green : AppColors.textLight,
              fontSize: 12.f,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.t(LocalizationKeys.payoutAmount),
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 18.f,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 15.s),
        GlassContainer(
          child: TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18.f,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '10000',
              hintStyle: TextStyle(
                color: AppColors.textGrey,
                fontSize: 18.f,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Container(
                width: 80.s,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.coins,
                      color: AppColors.angolaYellow,
                      size: 20.s,
                    ),
                    SizedBox(width: 8.s),
                    Text(
                      'HP',
                      style: TextStyle(
                        color: AppColors.angolaYellow,
                        fontSize: 16.f,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: ResponsiveUtils.pSymmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return ref.t(LocalizationKeys.amountRequired);
              }
              final amount = int.tryParse(value);
              if (amount == null || amount <= 0) {
                return ref.t(LocalizationKeys.enterValidAmount);
              }

              // Enforce prize range (10,000 - 30,000 HP)
              if (amount < 10000) {
                return 'Minimum prize value is 10,000 HP';
              }
              if (amount > 30000) {
                return 'Maximum prize value is 30,000 HP';
              }

              // Check against minimum prize value from API
              final payoutInfoAsync = ref.read(payoutInfoProvider);
              return payoutInfoAsync.maybeWhen(
                data: (payoutInfo) {
                  if (amount > payoutInfo.availableHc) {
                    return 'Insufficient balance. Available: ${payoutInfo.availableHc} HP';
                  }
                  return null;
                },
                orElse: () => null,
              );
            },
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(height: 12.s),
        // Prize restrictions info
        Container(
          padding: ResponsiveUtils.pSymmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.angolaRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.angolaRed.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: AppColors.angolaYellow,
                    size: 14.s,
                  ),
                  SizedBox(width: 8.s),
                  Text(
                    'Restrictions',
                    style: TextStyle(
                      color: AppColors.angolaYellow,
                      fontSize: 13.f,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.s),
              _buildRestrictionRow('Amount: 10,000 - 30,000 HP'),
              SizedBox(height: 4.s),
              Consumer(
                builder: (context, ref, child) {
                  final serverTime = ref
                      .watch(serverTimeProvider.notifier)
                      .currentServerTime;
                  final angolaTime = serverTime.add(const Duration(hours: 1));
                  final isSunday = angolaTime.weekday == DateTime.sunday;
                  final daysUntilSunday =
                      (DateTime.sunday - angolaTime.weekday) % 7;
                  final nextSunday = daysUntilSunday == 0 ? 7 : daysUntilSunday;

                  return _buildRestrictionRow(
                    isSunday
                        ? 'Day: Sundays only (Today ✓)'
                        : 'Day: Sundays only (Next: in $nextSunday day${nextSunday > 1 ? "s" : ""})',
                    isActive: isSunday,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutInfo() {
    return Consumer(
      builder: (context, ref, child) {
        final payoutInfoAsync = ref.watch(payoutInfoProvider);

        return payoutInfoAsync.when(
          data: (payoutInfo) {
            // Populate form fields when data is available
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFormFields(payoutInfo);
            });

            final rate = RemoteConfigService.instance.getHcToKzRate();
            final availableKz = payoutInfo.availableHc / rate;
            final minPayoutKz = payoutInfo.minimumPayoutHc / rate;

            return GlassContainer(
              child: Padding(
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16.f,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 10.s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.coins,
                              color: AppColors.angolaYellow,
                              size: 20.s,
                            ),
                            SizedBox(width: 8.s),
                            Text(
                              '${payoutInfo.availableHc} HP',
                              style: TextStyle(
                                color: AppColors.angolaYellow,
                                fontSize: 18.f,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '≈ ${availableKz.toStringAsFixed(2)} AOA',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14.f,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minimum Prize Value:',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14.f,
                          ),
                        ),
                        Text(
                          '${payoutInfo.minimumPayoutHc} HP (${minPayoutKz.toStringAsFixed(2)} AOA)',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14.f,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (payoutInfo.hasPendingPayout) ...[
                      SizedBox(height: 10.s),
                      Container(
                        padding: ResponsiveUtils.pSymmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.clock,
                              color: Colors.orange,
                              size: 14.s,
                            ),
                            SizedBox(width: 8.s),
                            Expanded(
                              child: Text(
                                'You have a pending payout request',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12.f,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!payoutInfo.canPayout &&
                        !payoutInfo.hasPendingPayout) ...[
                      SizedBox(height: 10.s),
                      Container(
                        padding: ResponsiveUtils.pSymmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.exclamationTriangle,
                              color: Colors.red,
                              size: 14.s,
                            ),
                            SizedBox(width: 8.s),
                            Expanded(
                              child: Text(
                                'Insufficient balance for payout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.f,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => GlassContainer(
            child: Padding(
              padding: ResponsiveUtils.pSymmetric(horizontal: 20, vertical: 30),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.angolaYellow,
                  ),
                ),
              ),
            ),
          ),
          error: (error, stackTrace) => GlassContainer(
            child: Padding(
              padding: ResponsiveUtils.pSymmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.exclamationTriangle,
                    color: Colors.red,
                    size: 16.s,
                  ),
                  SizedBox(width: 10.s),
                  Expanded(
                    child: Text(
                      'Failed to load balance info',
                      style: TextStyle(color: Colors.red, fontSize: 14.f),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestButton() {
    // Check if form is valid based on selected method and required fields
    bool isFormValid = false;

    if (_selectedMethod != null &&
        _amountController.text.isNotEmpty &&
        !_isLoading) {
      if (_selectedMethod == PayoutMethod.multicaixaExpress) {
        // For Multicaixa Express: need phone, name, and national ID
        isFormValid =
            _phoneController.text.isNotEmpty &&
            _accountHolderController.text.isNotEmpty &&
            _nationalIdController.text.isNotEmpty;
      } else if (_selectedMethod == PayoutMethod.crypto) {
        // For Crypto Transfer: need wallet address
        isFormValid = _walletAddressController.text.isNotEmpty;
      }
    }

    return Consumer(
      builder: (context, ref, child) {
        final payoutInfoAsync = ref.watch(payoutInfoProvider);

        return payoutInfoAsync.maybeWhen(
          data: (payoutInfo) => SizedBox(
            width: double.infinity,
            child: PressableScaleWidget(
              onTap: (isFormValid && payoutInfo.canPayout)
                  ? _requestPayout
                  : null,
              child: Container(
                padding: ResponsiveUtils.pSymmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    colors: (isFormValid && payoutInfo.canPayout)
                        ? [AppColors.angolaYellow, AppColors.orange]
                        : [
                            AppColors.angolaYellow.withValues(alpha: 0.5),
                            AppColors.orange.withValues(alpha: 0.5),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: (isFormValid && payoutInfo.canPayout)
                      ? [
                          BoxShadow(
                            color: AppColors.glowYellow.withValues(alpha: 0.5),
                            blurRadius: 15.s,
                            spreadRadius: -2.s,
                          ),
                        ]
                      : null,
                ),
                child: _isLoading
                    ? Center(
                        child: SizedBox(
                          height: 20.s,
                          width: 20.s,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.s,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textLight,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        ref.t(LocalizationKeys.requestPayout),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 18.f,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
          orElse: () => SizedBox(
            width: double.infinity,
            child: Container(
              padding: ResponsiveUtils.pSymmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColors.angolaYellow.withValues(alpha: 0.5),
              ),
              child: Text(
                ref.t(LocalizationKeys.requestPayout),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight.withValues(alpha: 0.7),
                  fontSize: 18.f,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
