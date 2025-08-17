import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/rounded_button.dart';
import 'payment_screen.dart';

class EarlyExitScreen extends StatelessWidget {
  const EarlyExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Early Exit'),
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          children: [
            const Spacer(),
            
            // Warning icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.warning_amber,
                size: 60,
                color: AppConstants.warningColor,
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Warning message
            Text(
              'Are you sure you want to end your detox early?',
              style: AppConstants.headingStyle,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.padding),
            
            // Penalty message
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              decoration: BoxDecoration(
                color: AppConstants.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: AppConstants.warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Early Exit Penalty',
                    style: AppConstants.subheadingStyle.copyWith(
                      color: AppConstants.warningColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'You\'ll need to pay ₹${AppConstants.earlyExitPenalty} to exit early.',
                    style: AppConstants.bodyStyle.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Additional info
            Text(
              'This penalty helps you stay committed to your digital detox goals. Consider completing your detox to avoid the penalty.',
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const Spacer(),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: RoundedButton(
                    text: 'Cancel',
                    backgroundColor: AppConstants.textSecondaryColor.withValues(alpha: 0.1),
                    textColor: AppConstants.textSecondaryColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppConstants.padding),
                Expanded(
                  child: RoundedButton(
                    text: 'Continue to Payment',
                    backgroundColor: AppConstants.warningColor,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const PaymentScreen()),
                      );
                    },
                    icon: Icons.payment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 