import 'app_localizations_en.dart';

/// French translations. Extends the English class so any not-yet-translated
/// string gracefully falls back to English. Running `flutter gen-l10n`
/// regenerates a full standalone class from app_fr.arb.
class AppLocalizationsFr extends AppLocalizationsEn {
  AppLocalizationsFr() : super('fr');

  @override
  String get tagline => 'Votre assistant intelligent pour plantes et sol';
  @override
  String get retry => 'Réessayer';
  @override
  String get cancel => 'Annuler';
  @override
  String get confirm => 'Confirmer';
  @override
  String get save => 'Enregistrer';
  @override
  String get delete => 'Supprimer';
  @override
  String get close => 'Fermer';
  @override
  String get next => 'Suivant';
  @override
  String get back => 'Retour';
  @override
  String get skip => 'Passer';
  @override
  String get getStarted => 'Commencer';
  @override
  String get openSettings => 'Ouvrir les réglages';
  @override
  String get loading => 'Chargement…';
  @override
  String get somethingWentWrong => 'Une erreur est survenue';

  @override
  String get navChat => 'Discussion';
  @override
  String get navDiagnose => 'Diagnostic';
  @override
  String get navWeather => 'Météo';
  @override
  String get navProfile => 'Profil';

  @override
  String get offlineBanner =>
      'Vous êtes hors ligne. Affichage des données en cache si disponibles.';

  @override
  String get onboardingTitle1 => 'Posez vos questions sur les plantes';
  @override
  String get onboardingBody1 =>
      'Discutez avec PlantSense AI de plantes, de nuisibles et de sol — par texte ou photo.';
  @override
  String get onboardingTitle2 => 'Diagnostic par photo';
  @override
  String get onboardingBody2 =>
      'Photographiez une feuille, un nuisible ou un problème de sol pour des conseils prudents et structurés.';
  @override
  String get onboardingTitle3 => 'Soins adaptés à la météo';
  @override
  String get onboardingBody3 =>
      'Partagez votre position pour une météo locale et des conseils de soins personnalisés.';
  @override
  String get onboardingTitle4 => 'Vous gardez le contrôle';
  @override
  String get onboardingBody4 =>
      "Les résultats de l'IA peuvent être inexacts. Vous contrôlez les autorisations, la conservation des images et vos données.";

  @override
  String get login => 'Se connecter';
  @override
  String get register => 'Créer un compte';
  @override
  String get email => 'E-mail';
  @override
  String get password => 'Mot de passe';
  @override
  String get confirmPassword => 'Confirmer le mot de passe';
  @override
  String get displayName => "Nom d'affichage";
  @override
  String get forgotPassword => 'Mot de passe oublié ?';
  @override
  String get continueWithGoogle => 'Continuer avec Google';
  @override
  String get noAccountPrompt => 'Nouveau ? Créez un compte';
  @override
  String get haveAccountPrompt => 'Déjà un compte ? Connectez-vous';

  @override
  String get chatTitle => 'Discussion PlantSense';
  @override
  String get chatEmptyTitle => 'Posez votre première question';
  @override
  String get chatEmptyBody =>
      'Touchez une suggestion ci-dessous ou saisissez votre question.';
  @override
  String get composerHint => 'Posez une question sur votre plante…';
  @override
  String get send => 'Envoyer';
  @override
  String get typing => 'PlantSense réfléchit…';
  @override
  String get conversations => 'Conversations';
  @override
  String get newChat => 'Nouvelle discussion';
  @override
  String get voiceInput => 'Saisie vocale';
  @override
  String get readAloud => 'Lire à voix haute';

  @override
  String get diagnoseTitle => 'Diagnostic';
  @override
  String get capture => 'Capturer';
  @override
  String get retake => 'Reprendre';
  @override
  String get cropImage => 'Recadrer';
  @override
  String get confirmPhoto => 'Utiliser cette photo';
  @override
  String get analyzing => 'Analyse de votre photo…';
  @override
  String get saveDiagnosis => 'Enregistrer le diagnostic';
  @override
  String get askFollowUp => 'Poser une question de suivi';
  @override
  String get diagnosisHistory => 'Historique des diagnostics';

  @override
  String get weatherTitle => 'Météo';
  @override
  String get currentWeather => 'Météo actuelle';
  @override
  String get humidity => 'Humidité';
  @override
  String get uvIndex => 'Indice UV';
  @override
  String get precipitation => 'Précipitations';
  @override
  String get hourlyForecast => 'Prévisions horaires';
  @override
  String get sevenDayForecast => 'Prévisions sur 7 jours';
  @override
  String get plantCareTips => 'Conseils de soins';

  @override
  String get profileTitle => 'Profil';
  @override
  String get editProfile => 'Modifier le profil';
  @override
  String get language => 'Langue';
  @override
  String get theme => 'Thème';
  @override
  String get themeSystem => 'Système';
  @override
  String get themeLight => 'Clair';
  @override
  String get themeDark => 'Sombre';
  @override
  String get units => 'Unités';
  @override
  String get notifications => 'Notifications';
  @override
  String get logout => 'Se déconnecter';
  @override
  String get deleteAccount => 'Supprimer le compte';
  @override
  String get deleteAllData => 'Supprimer toutes mes données';
  @override
  String get exportData => 'Télécharger mes données';

  @override
  String get myPlants => 'Mes plantes';
  @override
  String get addPlant => 'Ajouter une plante';
  @override
  String get editPlant => 'Modifier la plante';
  @override
  String get plantsEmpty => 'Aucune plante pour le moment';
  @override
  String get askAboutPlant => 'Poser une question sur cette plante';
  @override
  String get markWatered => 'Marquer comme arrosée';

  @override
  String get errorNoConnection =>
      'Pas de connexion Internet. Vérifiez votre réseau et réessayez.';
  @override
  String get errorTimeout => 'La requête a expiré. Veuillez réessayer.';
  @override
  String get errorRateLimited =>
      'Trop de requêtes. Patientez un instant puis réessayez.';
  @override
  String get errorUnknown => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get demoModeBanner =>
      'Mode démo — données d\'exemple. Configurez Firebase et Groq pour toutes les fonctionnalités.';
}
