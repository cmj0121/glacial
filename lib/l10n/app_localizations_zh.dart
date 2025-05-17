// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get txt_app_name => '冰河';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => '輸入並搜尋 ...';

  @override
  String get txt_search_helper => '搜尋有興趣的東西';

  @override
  String get txt_search_history => '搜尋紀錄';

  @override
  String get txt_invalid_instance => '無效的 Mastodon 伺服器';

  @override
  String get txt_server_contact => '聯絡我們';

  @override
  String get txt_server_rules => '伺服器規則';

  @override
  String get btn_clean_all => '清除全部';

  @override
  String get dots => '...';
}
