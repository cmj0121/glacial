// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get btn_search => '搜尋';

  @override
  String get btn_close => '關閉';

  @override
  String get btn_clear => '清除';

  @override
  String get btn_exit => '離開';

  @override
  String get btn_reload => '重新載入';

  @override
  String get btn_history => '歷史紀錄';

  @override
  String get btn_sidebar_timelines => '時間軸';

  @override
  String get btn_sidebar_lists => '列表';

  @override
  String get btn_sidebar_trendings => '趨勢';

  @override
  String get btn_sidebar_notificatios => '通知';

  @override
  String get btn_sidebar_management => '管理';

  @override
  String get btn_sidebar_post => '嘟文';

  @override
  String get btn_sidebar_sign_in => '登入';

  @override
  String get btn_drawer_switch_server => '切換伺服器';

  @override
  String get btn_drawer_profile => '個人檔案';

  @override
  String get btn_drawer_preference => '偏好設定';

  @override
  String get btn_drawer_logout => '登出';

  @override
  String get btn_trends_links => '連結';

  @override
  String get btn_trends_toots => '嘟文';

  @override
  String get btn_trends_users => '使用者';

  @override
  String get btn_trends_tags => '標籤';

  @override
  String get btn_timeline_home => '首頁';

  @override
  String get btn_timeline_local => '本站';

  @override
  String get btn_timeline_federal => '聯邦';

  @override
  String get btn_timeline_public => '公開';

  @override
  String get btn_timeline_favourites => '最愛';

  @override
  String get btn_timeline_bookmarks => '書籤';

  @override
  String get btn_preference_theme => '主題';

  @override
  String get btn_preference_engineer => '工程設定';

  @override
  String get btn_preference_engineer_clear_cache => '清除快取';

  @override
  String get btn_interaction_reply => '回嘟';

  @override
  String get btn_interaction_reblog => '轉發';

  @override
  String get btn_interaction_favourite => '最愛';

  @override
  String get btn_interaction_bookmark => '書籤';

  @override
  String get btn_interaction_share => '分享';

  @override
  String get btn_interaction_mute => '靜音';

  @override
  String get btn_interaction_block => '封鎖';

  @override
  String get btn_interaction_edit => '編輯';

  @override
  String get btn_interaction_delete => '刪除';

  @override
  String get desc_preference_engineer_clear_cache => '清除快取並重設';

  @override
  String get txt_search_history => '搜尋紀錄';

  @override
  String get txt_helper_server_explorer => '搜尋 Mastodon 伺服器';

  @override
  String get txt_hint_server_explorer => 'mastodon.social 或者關鍵字';

  @override
  String get txt_desc_preference_system_theme => '系統主題';

  @override
  String get txt_visibility_public => '公開';

  @override
  String get txt_visibility_unlisted => '不公開';

  @override
  String get txt_visibility_private => '追隨';

  @override
  String get txt_visibility_direct => '私訊';

  @override
  String get txt_suggestion_staff => '由管理者推薦';

  @override
  String get txt_suggestion_past_interactions => '最近互動過';

  @override
  String get txt_suggestion_global => '30 天內的活躍使用者';

  @override
  String err_invalid_instance(Object domain) {
    return '不合法/不存在的 Mastodon 伺服器: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache => '清除快取成功';

  @override
  String get msg_copied_to_clipboard => '複製到剪貼簿';

  @override
  String get dots => '...';
}
