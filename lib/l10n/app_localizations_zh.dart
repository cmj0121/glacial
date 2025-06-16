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
  String txt_no_results_found(Object keyword) {
    return '搜尋 $keyword 無結果';
  }

  @override
  String get txt_copied_to_clipboard => '複製到剪貼簿';

  @override
  String get txt_public => '公開';

  @override
  String get txt_unlisted => '不公開';

  @override
  String get txt_private => '追隨';

  @override
  String get txt_direct => '私訊';

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
  String get btn_post => '嘟出去';

  @override
  String get btn_follow_mutual => '互相跟隨';

  @override
  String get btn_following => '跟隨中';

  @override
  String get btn_followed_by => '被跟隨';

  @override
  String get btn_follow => '跟隨';

  @override
  String get btn_block => '封鎖';

  @override
  String get btn_unblock => '解除封鎖';

  @override
  String get btn_mute => '靜音';

  @override
  String get btn_unmute => '解除靜音';

  @override
  String get btn_report => '檢舉';

  @override
  String get dots => '...';
}
