import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

class EventCountdown extends ConsumerStatefulWidget {
  final DateTime targetDate;
  final String label;
  final Color? color;

  const EventCountdown({
    super.key,
    required this.targetDate,
    required this.label,
    this.color,
  });

  @override
  ConsumerState<EventCountdown> createState() => _EventCountdownState();
}

class _EventCountdownState extends ConsumerState<EventCountdown> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = ref.read(serverTimeProvider.notifier).currentServerTime;
    // Using server time to ensure consistency across timezones
    final difference = widget.targetDate.difference(now);

    if (mounted) {
      if (difference.isNegative) {
        setState(() {
          _timeLeft = Duration.zero;
        });
        _timer.cancel();
      } else {
        setState(() {
          _timeLeft = difference;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "00d 00h 00m 00s";

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String days = twoDigits(duration.inDays);
    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "${days}d ${hours}h ${minutes}m ${seconds}s";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.s, vertical: 8.s),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: widget.color ?? AppColors.textGrey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 10.f,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4.s),
          Text(
            _formatDuration(_timeLeft),
            style: TextStyle(
              color: widget.color ?? AppColors.textLight,
              fontSize: 14.f,
              fontWeight: FontWeight.bold,
              fontFamily:
                  'Monospace', // Use monospaced font if available or rely on default
            ),
          ),
        ],
      ),
    );
  }
}
