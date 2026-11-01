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
            decoration: const BoxDecoration(
              color: AppColors.subtle,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'AJ',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 28,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Your profile',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 32,
              letterSpacing: -1,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Account and preferences will live here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
