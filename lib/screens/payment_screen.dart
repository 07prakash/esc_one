import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/rounded_button.dart';
import '../services/payment_service.dart';
import '../services/detox_enforcer.dart';
import 'timer_setup_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  late DetoxEnforcer _detoxEnforcer;
  
  @override
  void initState() {
    super.initState();
    _detoxEnforcer = DetoxEnforcer();
    PaymentService.initialize();
  }
  
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      await PaymentService.startEarlyExitPayment();
      
      // Note: In a real app, you would handle payment success/failure
      // through the payment service callbacks
      
      // For demo purposes, we'll simulate a successful payment
      await Future.delayed(const Duration(seconds: 2));
      
      // End detox mode
      await _detoxEnforcer.endDetox();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TimerSetupScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppConstants.warningColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          children: [
            const Spacer(),
            
            // Payment icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.payment,
                size: 60,
                color: AppConstants.accentColor,
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Payment amount
            Text(
                              '₹${AppConstants.earlyExitPenalty}',
              style: AppConstants.headingStyle.copyWith(
                fontSize: 48,
                color: AppConstants.accentColor,
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            Text(
              'Early Exit Penalty',
              style: AppConstants.captionStyle,
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Payment methods
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Text(
                    'Payment Methods',
                    style: AppConstants.subheadingStyle,
                  ),
                  const SizedBox(height: AppConstants.padding),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        'UPI / Net Banking',
                        style: AppConstants.bodyStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        'Credit / Debit Cards',
                        style: AppConstants.bodyStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        'Digital Wallets',
                        style: AppConstants.bodyStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Payment button
            RoundedButton(
                              text: 'Pay ₹${AppConstants.earlyExitPenalty}',
              onPressed: _isProcessing ? null : _processPayment,
              isLoading: _isProcessing,
              backgroundColor: AppConstants.accentColor,
              icon: Icons.payment,
            ),
            
            const SizedBox(height: AppConstants.padding),
            
            // Cancel button
            RoundedButton(
              text: 'Cancel',
                                  backgroundColor: AppConstants.textSecondaryColor.withValues(alpha: 0.1),
              textColor: AppConstants.textSecondaryColor,
              onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
} 