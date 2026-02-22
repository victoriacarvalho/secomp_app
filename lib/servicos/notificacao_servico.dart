import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificacaoServico {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> agendarNotificacoesEvento({
    required int idBase,
    required String titulo,
    required DateTime dataEvento,
  }) async {
    // 1. VERIFICAÇÃO DE PERMISSÃO (CORREÇÃO PARA O ERRO EXACT_ALARMS)
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Solicita permissão de alarme exato se necessário (Android 12+)
      final bool? hasPermission = await androidImplementation.requestExactAlarmsPermission();
      if (hasPermission == false) {
        print("⚠️ Notificação não agendada: Sem permissão de Alarme Exato.");
        return; 
      }
    }

    // 2. LISTA DE ANTECIPAÇÕES
    final antecipacoes = [24, 12, 1];

    for (var horas in antecipacoes) {
      final dataProgramada = dataEvento.subtract(Duration(hours: horas));
      
      // Só agenda se a data programada ainda não passou
      if (dataProgramada.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          idBase + horas, // ID único para evitar sobreposição
          "Lembrete de Evento: $titulo",
          "Faltam $horas ${horas == 1 ? 'hora' : 'horas'} para o início!",
          tz.TZDateTime.from(dataProgramada, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'secomp_lembretes', 'Lembretes SECOMP',
              channelDescription: 'Notificações de lembretes de eventos',
              importance: Importance.max, 
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  // FUNÇÃO DE DIAGNÓSTICO PARA TESTAR SE FUNCIONOU
  static Future<void> listarAgendamentos() async {
    final List<PendingNotificationRequest> pendentes = 
        await _notifications.pendingNotificationRequests();
    
    print("--- NOTIFICAÇÕES NA FILA DO SISTEMA (${pendentes.length}) ---");
    for (var n in pendentes) {
      print("ID: ${n.id} | Título: ${n.title}");
    }
    print("---------------------------------------");
  }
}