import 'app_localizations_en.dart';

/// Spanish translations. Extends the English class so any not-yet-translated
/// string gracefully falls back to English. Running `flutter gen-l10n`
/// regenerates a full standalone class from app_es.arb.
class AppLocalizationsEs extends AppLocalizationsEn {
  AppLocalizationsEs() : super('es');

  @override
  String get tagline => 'Tu asistente inteligente de plantas y suelo';
  @override
  String get retry => 'Reintentar';
  @override
  String get cancel => 'Cancelar';
  @override
  String get confirm => 'Confirmar';
  @override
  String get save => 'Guardar';
  @override
  String get delete => 'Eliminar';
  @override
  String get close => 'Cerrar';
  @override
  String get next => 'Siguiente';
  @override
  String get back => 'Atrás';
  @override
  String get skip => 'Omitir';
  @override
  String get getStarted => 'Empezar';
  @override
  String get openSettings => 'Abrir ajustes';
  @override
  String get loading => 'Cargando…';
  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get navChat => 'Chat';
  @override
  String get navDiagnose => 'Diagnóstico';
  @override
  String get navWeather => 'Clima';
  @override
  String get navProfile => 'Perfil';

  @override
  String get offlineBanner =>
      'Estás sin conexión. Mostrando datos en caché si están disponibles.';

  @override
  String get onboardingTitle1 => 'Pregunta sobre cualquier planta';
  @override
  String get onboardingBody1 =>
      'Habla con PlantSense AI sobre plantas, plagas y suelo, con texto o fotos.';
  @override
  String get onboardingTitle2 => 'Diagnóstico por foto';
  @override
  String get onboardingBody2 =>
      'Fotografía una hoja, plaga o problema del suelo y recibe orientación prudente y estructurada.';
  @override
  String get onboardingTitle3 => 'Cuidado según el clima';
  @override
  String get onboardingBody3 =>
      'Comparte tu ubicación para obtener clima local y consejos de cuidado personalizados.';
  @override
  String get onboardingTitle4 => 'Tú tienes el control';
  @override
  String get onboardingBody4 =>
      'Los resultados de la IA pueden ser inexactos. Tú controlas los permisos, la retención de imágenes y tus datos.';

  @override
  String get login => 'Iniciar sesión';
  @override
  String get register => 'Crear cuenta';
  @override
  String get email => 'Correo electrónico';
  @override
  String get password => 'Contraseña';
  @override
  String get confirmPassword => 'Confirmar contraseña';
  @override
  String get displayName => 'Nombre visible';
  @override
  String get forgotPassword => '¿Olvidaste la contraseña?';
  @override
  String get continueWithGoogle => 'Continuar con Google';
  @override
  String get noAccountPrompt => '¿Nuevo aquí? Crea una cuenta';
  @override
  String get haveAccountPrompt => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get chatTitle => 'Chat de PlantSense';
  @override
  String get chatEmptyTitle => 'Haz tu primera pregunta';
  @override
  String get chatEmptyBody =>
      'Toca una sugerencia abajo o escribe tu propia pregunta.';
  @override
  String get composerHint => 'Pregunta sobre tu planta…';
  @override
  String get send => 'Enviar';
  @override
  String get typing => 'PlantSense está pensando…';
  @override
  String get conversations => 'Conversaciones';
  @override
  String get newChat => 'Nuevo chat';
  @override
  String get voiceInput => 'Entrada de voz';
  @override
  String get readAloud => 'Leer en voz alta';

  @override
  String get diagnoseTitle => 'Diagnóstico';
  @override
  String get capture => 'Capturar';
  @override
  String get retake => 'Repetir';
  @override
  String get cropImage => 'Recortar';
  @override
  String get confirmPhoto => 'Usar esta foto';
  @override
  String get analyzing => 'Analizando tu foto…';
  @override
  String get saveDiagnosis => 'Guardar diagnóstico';
  @override
  String get askFollowUp => 'Hacer una pregunta de seguimiento';
  @override
  String get diagnosisHistory => 'Historial de diagnósticos';

  @override
  String get weatherTitle => 'Clima';
  @override
  String get currentWeather => 'Clima actual';
  @override
  String get humidity => 'Humedad';
  @override
  String get uvIndex => 'Índice UV';
  @override
  String get precipitation => 'Precipitación';
  @override
  String get hourlyForecast => 'Pronóstico por horas';
  @override
  String get sevenDayForecast => 'Pronóstico de 7 días';
  @override
  String get plantCareTips => 'Consejos de cuidado';

  @override
  String get profileTitle => 'Perfil';
  @override
  String get editProfile => 'Editar perfil';
  @override
  String get language => 'Idioma';
  @override
  String get theme => 'Tema';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get themeLight => 'Claro';
  @override
  String get themeDark => 'Oscuro';
  @override
  String get units => 'Unidades';
  @override
  String get notifications => 'Notificaciones';
  @override
  String get logout => 'Cerrar sesión';
  @override
  String get deleteAccount => 'Eliminar cuenta';
  @override
  String get deleteAllData => 'Eliminar todos mis datos';
  @override
  String get exportData => 'Descargar mis datos';

  @override
  String get myPlants => 'Mis plantas';
  @override
  String get addPlant => 'Añadir planta';
  @override
  String get editPlant => 'Editar planta';
  @override
  String get plantsEmpty => 'Aún no hay plantas';
  @override
  String get askAboutPlant => 'Preguntar sobre esta planta';
  @override
  String get markWatered => 'Marcar como regada';

  @override
  String get errorNoConnection =>
      'Sin conexión a Internet. Revisa tu red e inténtalo de nuevo.';
  @override
  String get errorTimeout => 'La solicitud expiró. Inténtalo de nuevo.';
  @override
  String get errorRateLimited =>
      'Demasiadas solicitudes. Espera un momento e inténtalo de nuevo.';
  @override
  String get errorUnknown => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get demoModeBanner =>
      'Modo demo: datos de ejemplo. Configura Firebase y Groq para todas las funciones.';
}
