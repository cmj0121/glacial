// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get txt_app_name => 'glacial';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => 'Pressione Enter para pesquisar...';

  @override
  String get txt_search_helper => 'Pesquise algo interessante';

  @override
  String get txt_invalid_instance => 'Servidor Mastodon inválido';

  @override
  String get dots => '...';
}
