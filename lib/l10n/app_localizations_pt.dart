// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get txt_app_name => 'Glacial';

  @override
  String get txt_invalid_instance => 'Servidor Mastodon inválido';

  @override
  String get txt_server_contact => 'Contacto';

  @override
  String get txt_search_helper => 'Pesquise algo interessante';

  @override
  String get txt_search_history => 'Histórico de pesquisa';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => 'Regras do servidor';

  @override
  String get btn_clean_all => 'Limpar tudo';

  @override
  String get dots => '...';
}
