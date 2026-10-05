// lib/web_appcheck.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:flutter/foundation.dart';

void writeFirebaseAppCheckInfoToSessionStorage() {
  // ⚠️ REMPLACE PAR TA CLÉ (doit être la même que dans main.dart)
  const String recaptchaSiteKey = '6LdVcNctAAAAAGuzMxbqo7pP3-9KTBD4SVjOZ7N';
  try {
    window.sessionStorage['FlutterFire-[DEFAULT]-recaptchaType'] = 'recaptcha-enterprise';
    window.sessionStorage['FlutterFire-[DEFAULT]-recaptchaSiteKey'] = recaptchaSiteKey;
    if (kDebugMode) {
      debugPrint('✅ Clé reCAPTCHA injectée dans le sessionStorage');
    }
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'injection : $e');
  }
}