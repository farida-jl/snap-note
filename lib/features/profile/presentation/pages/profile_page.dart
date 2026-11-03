import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appColors.subtle,
              shape: BoxShape.circle,
            ),
            child: Text(
              'AJ',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 28,
                color: context.appColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Your profile',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 32,
              letterSpacing: -1,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Account and preferences will live here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
