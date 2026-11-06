import 'package:flutter_test/flutter_test.dart';
import 'package:stash_shelf/core/utils/relative_time.dart';

void main() {
  final now = DateTime(2026, 11, 2, 12);

  test('formats created time relative to the current time', () {
    expect(formatRelativeTime(now, now: now), 'Just now');
    expect(
      formatRelativeTime(DateTime(2026, 11, 2, 11, 45), now: now),
      '15m ago',
    );
    expect(formatRelativeTime(DateTime(2026, 11, 2, 9), now: now), '3h ago');
    expect(
      formatRelativeTime(DateTime(2026, 11, 1, 12), now: now),
      'Yesterday',
    );
  });
}
