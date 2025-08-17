import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/constants.dart';

class PaymentService {
  static Razorpay? _razorpay;
  
  // Initialize Razorpay
  static void initialize() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  // Handle payment success
  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (kDebugMode) {
      print('Payment successful: ${response.paymentId}');
    }
    // Handle successful payment - end detox
  }
  
  // Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('Payment failed: ${response.message}');
    }
    // Handle payment failure
  }
  
  // Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print('External wallet selected: ${response.walletName}');
    }
  }
  
  // Start payment for early exit
  static Future<void> startEarlyExitPayment() async {
    if (_razorpay == null) {
      initialize();
    }
    
    final options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with actual key
                'amount': AppConstants.earlyExitPenalty * 100, // Amount in paise
      'name': AppConstants.appName,
      'description': 'Early Exit Penalty',
      'currency': 'INR',
      'prefill': {
        'contact': '',
        'email': '',
      },
      'theme': {
        'color': '#2C3E50',
      },
    };
    
    try {
      _razorpay!.open(options);
    } catch (e) {
      if (kDebugMode) {
        print('Error starting payment: $e');
      }
    }
  }
  
  // Dispose Razorpay
  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
} 