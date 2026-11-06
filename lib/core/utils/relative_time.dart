String formatRelativeTime(DateTime createdAt, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  final difference = currentTime.difference(createdAt);

  if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays == 1) return 'Yesterday';
  if (difference.inDays < 7) return '${difference.inDays}d ago';

  return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}
