// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  const NotificationService();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _maintenanceChannel =
      AndroidNotificationChannel(
    'mecago_maintenance',
    'Rappels d\'entretien',
    description: 'Notifications pour les entretiens à venir',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel _alertChannel =
      AndroidNotificationChannel(
    'mecago_alerts',
    'Alertes critiques',
    description: 'Alertes urgentes de sécurité',
    importance: Importance.max,
    playSound: true,
  );

  /// Initialise les canaux de notification
  Future<void> initializeNotificationChannels() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_maintenanceChannel);
        await androidPlugin.createNotificationChannel(_alertChannel);
      }

      debugPrint('✅ Canaux de notification créés');
    } catch (e) {
      debugPrint('⚠️ Erreur init notifications : $e');
    }
  }

  /// Demande la permission
  Future<bool> requestPermission() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Erreur permission : $e');
      return false;
    }
  }

  /// Affiche une notification immédiate
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool isCritical = false,
  }) async {
    try {
      final channel = isCritical ? _alertChannel : _maintenanceChannel;

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: isCritical ? Priority.max : Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFFF6A00),
        enableLights: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details);
      debugPrint('✅ Notification affichée : $title');
    } catch (e) {
      debugPrint('❌ Erreur affichage : $e');
    }
  }

  /// 🔔 NOTIFICATION DE BIENVENUE
  Future<void> showWelcomeNotification(String vehicleName) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🚗 Nouveau véhicule ajouté !',
      body: '$vehicleName est maintenant dans votre garage MecaGo.',
    );
  }

  /// 🔔 NOTIFICATION DE RAPPEL D'ENTRETIEN
  Future<void> showMaintenanceReminder({
    required String vehicleName,
    required String maintenanceTitle,
    required String remainingKm,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔧 Entretien à prévoir',
      body: '$vehicleName · $maintenanceTitle dans $remainingKm',
    );
  }

  /// 🚨 NOTIFICATION CRITIQUE
  Future<void> showCriticalAlert({
    required String vehicleName,
    required String issue,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🚨 Alerte critique',
      body: '$vehicleName : $issue',
      isCritical: true,
    );
  }

  /// Annule une notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapée : ${response.payload}');
  }
}