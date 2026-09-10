// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  const NotificationService();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Canal Android pour les rappels d'entretien
  static const AndroidNotificationChannel _maintenanceChannel =
      AndroidNotificationChannel(
    'mecago_maintenance',
    'Rappels d\'entretien',
    description: 'Notifications pour les entretiens à venir',
    importance: Importance.high,
    playSound: true,
  );

  /// Canal Android pour les alertes critiques
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
      // Initialisation des paramètres
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

      // Création des canaux Android
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_maintenanceChannel);
        await androidPlugin.createNotificationChannel(_alertChannel);
      }

      debugPrint('✅ Canaux de notification créés');
    } catch (e) {
      debugPrint('⚠️ Erreur initialisation notifications : $e');
    }
  }

  /// Demande la permission (iOS + Android 13+)
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
    } catch (e) {
      debugPrint('❌ Erreur affichage notification : $e');
    }
  }

  /// Programme un rappel d'entretien
  Future<void> scheduleMaintenanceReminder({
    required int id,
    required String vehicleName,
    required String maintenanceTitle,
    required DateTime scheduledDate,
    required int remainingKm,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _maintenanceChannel.id,
        _maintenanceChannel.name,
        channelDescription: _maintenanceChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFFF6A00),
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

      await _notifications.zonedSchedule(
        id,
        '🔧 Entretien à prévoir',
        '$vehicleName · $maintenanceTitle dans $remainingKm km',
        _convertToTZDateTime(scheduledDate),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ Rappel programmé pour $scheduledDate');
    } catch (e) {
      debugPrint('❌ Erreur programmation rappel : $e');
    }
  }

  /// Affiche une alerte critique
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

  /// Callback quand l'utilisateur tape sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapée : ${response.payload}');
    // TODO: Naviguer vers la page concernée
  }

  /// Conversion DateTime → TZDateTime (pour zonedSchedule)
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // Note: nécessite le package timezone pour une vraie conversion
    return dateTime;
  }
}
