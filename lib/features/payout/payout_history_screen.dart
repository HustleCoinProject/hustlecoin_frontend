import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/providers/payout_provider.dart';
import 'package:hustlecoin/data/models/payout.dart';

class PayoutHistoryScreen extends ConsumerWidget {
  const PayoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ScreenBackground(
        imagePath: 'assets/images/CEO.jpg',
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, ref),
              Expanded(child: _buildHistoryList(context, ref)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
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
                'Payout History',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 20.f,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            FaIcon(
              FontAwesomeIcons.history,
              color: AppColors.angolaYellow,
              size: 24.s,
              shadows: [Shadow(color: AppColors.glowYellow, blurRadius: 10)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      payoutHistoryProvider(const PayoutHistoryParams(limit: 50, offset: 0)),
    );

    return historyAsync.when(
      data: (payouts) => payouts.isEmpty
          ? _buildEmptyState(context, ref)
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(payoutHistoryProvider);
              },
              color: AppColors.angolaYellow,
              child: ListView.builder(
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                itemCount: payouts.length,
                itemBuilder: (context, index) =>
                    _buildPayoutCard(payouts[index]),
              ),
            ),
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.angolaYellow),
        ),
      ),
      error: (error, stackTrace) =>
          _buildErrorState(context, ref, error.toString()),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.receipt,
            color: AppColors.textGrey,
            size: 64.s,
          ),
          SizedBox(height: 20.s),
          Text(
            'No Payout History',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 20.f,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.s),
          Padding(
            padding: ResponsiveUtils.pSymmetric(horizontal: 40),
            child: Text(
              'You haven\'t made any payout requests yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 14.f),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.exclamationTriangle,
            color: Colors.red,
            size: 48.s,
          ),
          SizedBox(height: 20.s),
          Text(
            'Failed to Load History',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18.f,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.s),
          PressableScaleWidget(
            onTap: () {
              SoundService().playClick();
              ref.invalidate(payoutHistoryProvider);
            },
            child: Container(
              padding: ResponsiveUtils.pSymmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: const LinearGradient(
                  colors: [AppColors.angolaYellow, AppColors.orange],
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14.f,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(Payout payout) {
    return Padding(
      padding: ResponsiveUtils.pLTRB(0, 0, 0, 15),
      child: GlassContainer(
        child: Padding(
          padding: ResponsiveUtils.pSymmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        payout.payoutMethod ==
                                PayoutMethodType.multicaixaExpress
                            ? FontAwesomeIcons.mobileAlt
                            : FontAwesomeIcons.university,
                        color: AppColors.angolaYellow,
                        size: 16.s,
                      ),
                      SizedBox(width: 8.s),
                      Text(
                        payout.methodDisplayText,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14.f,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusChip(payout.status),
                ],
              ),
              SizedBox(height: 12.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12.f,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${payout.amountHc} HC',
                            style: TextStyle(
                              color: AppColors.angolaYellow,
                              fontSize: 16.f,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8.s),
                          Text(
                            '(${payout.amountKwanza.toStringAsFixed(2)} AOA)',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12.f,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12.f,
                        ),
                      ),
                      Text(
                        '${payout.createdAt.day}/${payout.createdAt.month}/${payout.createdAt.year}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12.f,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (payout.status == PayoutStatus.rejected &&
                  payout.rejectionReason != null) ...[
                SizedBox(height: 12.s),
                Container(
                  padding: ResponsiveUtils.pSymmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.exclamationCircle,
                        color: Colors.red,
                        size: 12.s,
                      ),
                      SizedBox(width: 8.s),
                      Expanded(
                        child: Text(
                          'Reason: ${payout.rejectionReason}',
                          style: TextStyle(color: Colors.red, fontSize: 12.f),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(PayoutStatus status) {
    Color chipColor;
    IconData iconData;

    switch (status) {
      case PayoutStatus.pending:
        chipColor = Colors.orange;
        iconData = FontAwesomeIcons.clock;
        break;
      case PayoutStatus.processing:
        chipColor = Colors.blue;
        iconData = FontAwesomeIcons.spinner;
        break;
      case PayoutStatus.completed:
        chipColor = Colors.green;
        iconData = FontAwesomeIcons.check;
        break;
      case PayoutStatus.rejected:
        chipColor = Colors.red;
        iconData = FontAwesomeIcons.times;
        break;
    }

    return Container(
      padding: ResponsiveUtils.pSymmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(iconData, color: chipColor, size: 10.s),
          SizedBox(width: 4.s),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 10.f,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
