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
  String? _selectedBank;
  final _ibanController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _ibanController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectPayoutMethod(PayoutMethod method) {
    setState(() {
      _selectedMethod = method;
    });
    SoundService().playClick();
  }

  void _requestPayout() {
    if (_formKey.currentState!.validate() && _selectedMethod != null) {
      SoundService().playClick();

      // TODO: Implement backend call when available
      final amount = double.tryParse(_amountController.text) ?? 0;
      final method = _selectedMethod == PayoutMethod.multicaixaExpress
          ? 'Multicaixa Express'
          : 'Bank: ${_selectedBank ?? 'Unknown'}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payout request submitted!\nMethod: $method\nAmount: ${amount.toStringAsFixed(2)} HC',
          ),
          backgroundColor: AppColors.angolaYellow.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );

      // Clear form after successful submission
      _amountController.clear();
      setState(() {
        _selectedMethod = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        imagePath: 'assets/images/CEO.png', // Default background
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
          hintText: '+244 123 456 789',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return ref.t(LocalizationKeys.phoneNumberRequired);
            }
            return null;
          },
        ),
        SizedBox(height: 15.s),
        _buildTextField(
          controller: _accountHolderController,
          label: ref.t(LocalizationKeys.accountHolderName),
          icon: FontAwesomeIcons.user,
          hintText: ref.t(LocalizationKeys.enterFullName),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return ref.t(LocalizationKeys.accountHolderNameRequired);
            }
            return null;
          },
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
        _buildBankDropdown(),
        SizedBox(height: 15.s),
        _buildTextField(
          controller: _ibanController,
          label: 'IBAN',
          icon: FontAwesomeIcons.creditCard,
          hintText: 'AO06 0000 0000 0000 0000 0000 0',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return ref.t(LocalizationKeys.ibanRequired);
            }
            return null;
          },
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
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18.f,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
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
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return ref.t(LocalizationKeys.enterValidAmount);
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestButton() {
    final isFormValid =
        _selectedMethod != null && _amountController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: PressableScaleWidget(
        onTap: isFormValid ? _requestPayout : null,
        child: Container(
          padding: ResponsiveUtils.pSymmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: isFormValid
                  ? [AppColors.angolaYellow, AppColors.orange]
                  : [
                      AppColors.angolaYellow.withValues(alpha: 0.5),
                      AppColors.orange.withValues(alpha: 0.5),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isFormValid
                ? [
                    BoxShadow(
                      color: AppColors.glowYellow.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Text(
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
    );
  }
}
