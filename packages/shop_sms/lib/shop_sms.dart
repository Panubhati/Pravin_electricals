import 'package:flutter/services.dart';

/// Sends a plain SMS through the phone's own SIM (Android SmsManager). Only
/// sends; it never reads messages. Works in the app and in the background job.
class ShopSms {
  static const _channel = MethodChannel('com.pravinelectricals.shop_sms');

  /// True when the app may send SMS.
  static Future<bool> hasPermission() async => await _channel.invokeMethod<bool>('hasPermission') ?? false;

  /// Asks the person for the SMS permission (needs the app on screen).
  static Future<bool> requestPermission() async => await _channel.invokeMethod<bool>('requestPermission') ?? false;

  /// Sends [text] to [number] (country code and digits). Long texts are split
  /// into parts by the phone. Returns false when it could not be handed to the SIM.
  static Future<bool> send(String number, String text) async =>
      await _channel.invokeMethod<bool>('send', {'number': number, 'text': text}) ?? false;
}
