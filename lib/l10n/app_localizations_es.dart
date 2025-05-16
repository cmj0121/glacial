// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get txt_app_name => 'glacial';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => 'Presiona Enter para buscar...';

  @override
  String get txt_search_helper => 'Busca algo interesante';

  @override
  String get txt_invalid_instance => 'Servidor de Mastodon no válido';

  @override
  String get dots => '...';
}
