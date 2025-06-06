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
  String get txt_invalid_instance => '無效的 Mastodon 伺服器';

  @override
  String get txt_server_contact => '聯絡我們';

  @override
  String get txt_search_helper => '搜尋有興趣的東西';

  @override
  String get txt_search_history => '搜尋紀錄';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => '伺服器規則';

  @override
  String get txt_show_less => '減少顯示';

  @override
  String get txt_show_more => '顯示更多';

  @override
  String txt_trends_uses(Object uses) {
    return '$uses 人於過去幾天';
  }

  @override
  String get btn_clean_all => '清除全部';

  @override
  String get btn_timeline => '時間軸';

  @override
  String get btn_trending => '現正熱門趨勢';

  @override
  String get btn_notifications => '推播通知';

  @override
  String get btn_settings => '設定';

  @override
  String get btn_management => '管理介面';

  @override
  String get btn_trends_links => '最新消息';

  @override
  String get btn_trends_statuses => '嘟文';

  @override
  String get btn_trends_tags => '主題標籤';

  @override
  String get btn_home => '首頁';

  @override
  String get btn_user => '使用者';

  @override
  String get btn_local => '本站';

  @override
  String get btn_federal => '聯邦宇宙';

  @override
  String get btn_public => '全部';

  @override
  String get btn_bookmarks => '書籤';

  @override
  String get btn_favourites => '最愛';

  @override
  String get dots => '...';
}
