String formatDuration(int seconds) {
  if (seconds <= 0) return '0s';

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;

  final parts = <String>[];

  if (hours > 0) {
    parts.add('${hours}h');
  }
  if (minutes > 0) {
    parts.add('${minutes}m');
  }
  if (remainingSeconds > 0 || parts.isEmpty) {
    parts.add('${remainingSeconds}s');
  }

  return parts.join(' ');
}
