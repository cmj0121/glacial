// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get txt_app_name => '빙하';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => '입력 후 검색하세요...';

  @override
  String get txt_search_helper => '흥미로운 것을 검색해보세요';

  @override
  String get txt_search_history => '검색 기록';

  @override
  String get txt_invalid_instance => '유효하지 않은 Mastodon 서버';

  @override
  String get txt_server_contact => '연락처';

  @override
  String get txt_server_rules => '서버 규칙';

  @override
  String get btn_clean_all => '모두 지우기';

  @override
  String get dots => '...';
}
