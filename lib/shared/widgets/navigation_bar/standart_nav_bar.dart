import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StandartNavigationBar extends StatelessWidget {
  const StandartNavigationBar({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 64),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.appColors.primary,
              ),
            ),
          ),
          Positioned(
            left: 0,
            child: IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.chevron_left),
            ),
          ),
        ],
      ),
    );
  }
}
