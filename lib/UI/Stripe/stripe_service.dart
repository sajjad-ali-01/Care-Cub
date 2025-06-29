import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripService {
  StripService._internal();

  static final StripService instance = StripService._internal();

  factory StripService() => instance;

  // Replace with your actual Stripe keys
  static const String secretKey = '';
  static const String publishableKey = '';
  static const String api = 'https://api.stripe.com/v1/payment_intents';

  Future<Map<String, dynamic>?> _paymentIntent(double amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse(api),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(), // Convert to cents
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(responseData.toString());
        return responseData;
      } else {
        throw Exception(
            'Failed to create Payment Intent ${response.statusCode} responsePhrase ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error while creating payment intent => $e');
      rethrow;
    }
  }

  Future<void> initPaymentSheet(double amount, String currency) async {
    try {
      // Initialize Stripe with publishable key
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();

      // Create payment intent
      final paymentIntent = await _paymentIntent(amount, currency);
      if (paymentIntent == null || paymentIntent['client_secret'] == null) {
        throw Exception('Invalid Payment intent data');
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Doctor Appointment App',
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.deepOrange,
              background: Colors.black,
              componentBackground: Colors.black!,
              componentBorder: Colors.grey[300]!,
              componentDivider: Colors.grey[300]!,
              primaryText: Colors.white,
              secondaryText: Colors.white!,
              componentText: Colors.white,
              icon: Colors.deepOrange,
              error: Colors.red,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error while init payment sheet: $e');
      rethrow;
    }
  }
}