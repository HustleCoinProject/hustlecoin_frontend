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
import 'package:hustlecoin/features/payout/payout_history_screen.dart' show PayoutHistoryScreen;

enum PayoutMethod { multicaixaExpress, bank }

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
  String? _selectedBank;
  final _ibanController = TextEditingController();
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
  
  String? _validateIban(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IBAN is required';
    }
    
    final cleanIban = value.replaceAll(' ', '').toUpperCase();
    
    if (cleanIban.length < 15 || cleanIban.length > 34) {
      return 'IBAN must be 15-34 characters';
    }
    
    // Angolan IBAN starts with AO
    if (!cleanIban.startsWith('AO')) {
      return 'Angolan IBAN must start with AO';
    }
    
    return null;
  }

  final List<String> _angolanBanks = [
    'Banco Angolano de Investimentos (BAI)',
    'Banco de Fomento Angola (BFA)',
    'Banco Millennium Atlântico',
    'Standard Bank Angola',
    'Banco Económico',
    'Banco BIC',
    'Banco de Poupança e Crédito (BPC)',
    'Banco Caixa Geral Angola',
    'Banco Keve',
    'Banco Prestígio',
    'Banco Regional do Keve',
    'Banco Yetu',
    'Finibanco Angola',
    'Banco Sol',
    'Banco Valor',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _accountHolderController.dispose();
    _nationalIdController.dispose();
    _ibanController.dispose();
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
    if (_phoneController.text.isEmpty && payoutInfo.phoneNumber != null && payoutInfo.phoneNumber!.isNotEmpty) {
      _phoneController.text = payoutInfo.phoneNumber!;
      shouldRebuild = true;
    }
    
    if (_accountHolderController.text.isEmpty && payoutInfo.fullName != null && payoutInfo.fullName!.isNotEmpty) {
      _accountHolderController.text = payoutInfo.fullName!;
      shouldRebuild = true;
    }
    
    if (_nationalIdController.text.isEmpty && payoutInfo.nationalId != null && payoutInfo.nationalId!.isNotEmpty) {
      _nationalIdController.text = payoutInfo.nationalId!;
      shouldRebuild = true;
    }
    
    if (_ibanController.text.isEmpty && payoutInfo.bankIban != null && payoutInfo.bankIban!.isNotEmpty) {
      _ibanController.text = payoutInfo.bankIban!;
      shouldRebuild = true;
    }
    
    if (_selectedBank == null && payoutInfo.bankName != null && payoutInfo.bankName!.isNotEmpty) {
      _selectedBank = payoutInfo.bankName!;
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
      await ref.read(payoutProvider.notifier).updatePayoutInfo(
        phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        fullName: _accountHolderController.text.trim().isNotEmpty ? _accountHolderController.text.trim() : null,
        nationalId: _nationalIdController.text.trim().isNotEmpty ? _nationalIdController.text.trim() : null,
        bankIban: _ibanController.text.trim().isNotEmpty ? _ibanController.text.trim() : null,
        bankName: _selectedBank,
      );
    } catch (e) {
      // Don't show error to user as this is a background operation
    }
  }

  Future<void> _requestPayout() async {
    debugPrint('=== PAYOUT REQUEST DEBUG START ===');
    debugPrint('DEBUG: _requestPayout called');
    debugPrint('DEBUG: Selected method: $_selectedMethod');
    debugPrint('DEBUG: Form key current state: ${_formKey.currentState}');
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('DEBUG: Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix form errors'),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
        ),
      );
      return;
    }
    
    if (_selectedMethod == null) {
      debugPrint('DEBUG: No payout method selected');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payout method'),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
        ),
      );
      return;
    }
    
    SoundService().playClick();

    setState(() {
      _isLoading = true;
    });

    try {
      final amountHc = int.tryParse(_amountController.text) ?? 0;
      debugPrint('DEBUG: Amount HC: $amountHc');
      
      final payoutMethod = _selectedMethod == PayoutMethod.multicaixaExpress
          ? 'multicaixa_express'
          : 'bank_transfer';
      debugPrint('DEBUG: Payout method: $payoutMethod');
      debugPrint('DEBUG: Phone number: ${_phoneController.text.trim()}');
      debugPrint('DEBUG: Full name: ${_accountHolderController.text.trim()}');
      debugPrint('DEBUG: National ID: ${_nationalIdController.text.trim()}');
      debugPrint('DEBUG: Selected bank: $_selectedBank');
      debugPrint('DEBUG: IBAN: ${_ibanController.text.trim()}');

      final payoutRequest = PayoutRequest(
        amountHc: amountHc,
        payoutMethod: payoutMethod,
        phoneNumber: _selectedMethod == PayoutMethod.multicaixaExpress
            ? _phoneController.text.trim()
            : null,
        fullName: _accountHolderController.text.trim(),
        nationalId: _nationalIdController.text.trim().isNotEmpty 
            ? _nationalIdController.text.trim() 
            : null,
        bankIban: _selectedMethod == PayoutMethod.bank
            ? _ibanController.text.trim()
            : null,
        bankName: _selectedMethod == PayoutMethod.bank
            ? _selectedBank
            : null,
      );
      
      debugPrint('DEBUG: PayoutRequest created: ${payoutRequest.toJson()}');
      debugPrint('DEBUG: About to call payoutProvider.requestPayout...');
      
      // Check if provider is available
      final notifier = ref.read(payoutProvider.notifier);
      debugPrint('DEBUG: Payout provider notifier: $notifier');

      final payout = await notifier.requestPayout(payoutRequest);
      
      debugPrint('DEBUG: Payout response received: $payout');
      debugPrint('DEBUG: Payout is null: ${payout == null}');

      if (payout != null && mounted) {
        debugPrint('DEBUG: Showing success message');
        
        // Save form data to backend for future use
        await _saveFormDataToBackend();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payout request submitted successfully!\nAmount: $amountHc HC (${payout.amountKwanza.toStringAsFixed(2)} AOA)\nStatus: ${payout.statusDisplayText}',
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
        debugPrint('DEBUG: Payout was null or widget not mounted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Payout request failed - no response from server'),
              backgroundColor: Colors.red.withValues(alpha: 0.9),
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('DEBUG: Exception caught in _requestPayout: $error');
      debugPrint('DEBUG: Stack trace: $stackTrace');
      
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
      debugPrint('DEBUG: Finally block - setting loading to false');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('=== PAYOUT REQUEST DEBUG END ===');
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
                padding: ResponsiveUtils.p(8),
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
                padding: ResponsiveUtils.p(8),
                child: FaIcon(
                  FontAwesomeIcons.history,
                  color: AppColors.angolaYellow,
                  size: 20.s,
                  shadows: [Shadow(color: AppColors.glowYellow, blurRadius: 10)],
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
                PayoutMethod.bank,
                'Bank',
                FontAwesomeIcons.university,
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
                ? Border.all(color: AppColors.angolaYellow, width: 2)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.glowYellow.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: -5,
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
      return _buildBankFields();
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

  Widget _buildBankFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.t(LocalizationKeys.bankDetails),
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 16.f,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
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
        SizedBox(height: 15.s),
        _buildBankDropdown(),
        SizedBox(height: 15.s),
        _buildTextField(
          controller: _ibanController,
          label: 'IBAN',
          icon: FontAwesomeIcons.creditCard,
          hintText: 'AO06000000123456789101112',
          validator: _validateIban,
          onChanged: (_) => setState(() {}),
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

  Widget _buildBankDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.t(LocalizationKeys.bankName),
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14.f,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.s),
        GlassContainer(
          child: DropdownButtonFormField<String>(
            value: _selectedBank,
            style: TextStyle(color: AppColors.textLight, fontSize: 16.f),
            dropdownColor: AppColors.uiDarkBg,
            decoration: InputDecoration(
              hintText: ref.t(LocalizationKeys.selectBank),
              hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.f),
              prefixIcon: Container(
                width: 50.s,
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.university,
                  color: AppColors.angolaYellow,
                  size: 18.s,
                ),
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
            items: _angolanBanks.map((String bank) {
              return DropdownMenuItem<String>(
                value: bank,
                child: Text(
                  bank,
                  style: TextStyle(color: AppColors.textLight, fontSize: 14.f),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBank = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return ref.t(LocalizationKeys.bankNameRequired);
              }
              return null;
            },
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
              hintText: '100',
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
                      'HC',
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

              // Check against minimum payout amount from API
              final payoutInfoAsync = ref.read(payoutInfoProvider);
              return payoutInfoAsync.maybeWhen(
                data: (payoutInfo) {
                  if (amount < payoutInfo.minimumPayoutHc) {
                    return 'Minimum payout is ${payoutInfo.minimumPayoutHc} HC';
                  }
                  if (amount > payoutInfo.availableHc) {
                    return 'Insufficient balance. Available: ${payoutInfo.availableHc} HC';
                  }
                  return null;
                },
                orElse: () => null,
              );
            },
            onChanged: (_) => setState(() {}),
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
            
            return GlassContainer(
            child: Padding(
              padding: ResponsiveUtils.pSymmetric(horizontal: 20, vertical: 20),
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
                            '${payoutInfo.availableHc} HC',
                            style: TextStyle(
                              color: AppColors.angolaYellow,
                              fontSize: 18.f,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '≈ ${payoutInfo.availableKwanza.toStringAsFixed(2)} AOA',
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
                        'Minimum Payout:',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14.f,
                        ),
                      ),
                      Text(
                        '${payoutInfo.minimumPayoutHc} HC (${payoutInfo.minimumPayoutKwanza.toStringAsFixed(2)} AOA)',
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
                      padding: ResponsiveUtils.pSymmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
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
                  if (!payoutInfo.canPayout && !payoutInfo.hasPendingPayout) ...[
                    SizedBox(height: 10.s),
                    Container(
                      padding: ResponsiveUtils.pSymmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.angolaYellow),
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
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.f,
                      ),
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
    
    if (_selectedMethod != null && _amountController.text.isNotEmpty && !_isLoading) {
      if (_selectedMethod == PayoutMethod.multicaixaExpress) {
        // For Multicaixa Express: need phone, name, and national ID
        isFormValid = _phoneController.text.isNotEmpty &&
                     _accountHolderController.text.isNotEmpty &&
                     _nationalIdController.text.isNotEmpty;
      } else if (_selectedMethod == PayoutMethod.bank) {
        // For Bank Transfer: need IBAN, bank name, and account holder name
        isFormValid = _ibanController.text.isNotEmpty &&
                     _selectedBank != null &&
                     _accountHolderController.text.isNotEmpty;
      }
    }

    return Consumer(
      builder: (context, ref, child) {
        final payoutInfoAsync = ref.watch(payoutInfoProvider);
        
        return payoutInfoAsync.maybeWhen(
          data: (payoutInfo) => SizedBox(
            width: double.infinity,
            child: PressableScaleWidget(
              onTap: (isFormValid && payoutInfo.canPayout) ? _requestPayout : null,
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
                            blurRadius: 15,
                            spreadRadius: -2,
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
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
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
