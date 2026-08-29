// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get counterAppBarTitle => 'Compteur';

  @override
  String get invalidEmail => 'Adresse e-mail invalide';

  @override
  String get invalidPassword =>
      'Le mot de passe doit comporter au moins 8 caractères et contenir au moins une lettre et un chiffre';

  @override
  String get confirmPasswordMismatch =>
      'La confirmation du mot de passe ne correspond pas';
}
