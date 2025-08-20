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
  String get btn_sidebar_notifications => '通知';

  @override
  String get btn_sidebar_management => '管理';

  @override
  String get btn_sidebar_post => '嘟文';

  @override
  String get btn_sidebar_sign_in => '登入';

  @override
  String get btn_drawer_switch_server => '切換伺服器';

  @override
  String get btn_drawer_directory => '探索帳戶';

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
  String get btn_timeline_list => '列表';

  @override
  String get btn_preference_theme => '主題';

  @override
  String get btn_preference_engineer => '工程設定';

  @override
  String get btn_preference_engineer_clear_cache => '清除快取';

  @override
  String get btn_preference_engineer_reset => '重置系統';

  @override
  String get btn_preference_engineer_test_notifier => '通知測試';

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
  String get btn_profile_core => '使用者頁面';

  @override
  String get btn_profile_post => '嘟文';

  @override
  String get btn_profile_pin => '釘選文章';

  @override
  String get btn_profile_followers => '追隨者';

  @override
  String get btn_profile_following => '追隨中';

  @override
  String get btn_profile_scheduled => '排程都文';

  @override
  String get btn_profile_hashtag => '追蹤標籤';

  @override
  String get btn_profile_mute => '靜音用戶';

  @override
  String get btn_profile_block => '封鎖用戶';

  @override
  String get btn_profile_general_info => '基本資料';

  @override
  String get btn_profile_privacy => '隱私設定';

  @override
  String get btn_status_toot => '嘟文';

  @override
  String get btn_status_edit => '編輯';

  @override
  String get btn_status_scheduled => '排程嘟文';

  @override
  String get btn_relationship_following => '追隨中';

  @override
  String get btn_relationship_followed_by => '被跟隨';

  @override
  String get btn_relationship_follow_each_other => '互為朋友';

  @override
  String get btn_relationship_follow_request => '追隨請求 (等待同意)';

  @override
  String get btn_relationship_stranger => '陌生人';

  @override
  String get btn_relationship_blocked_by => '被封鎖';

  @override
  String btn_relationship_mute(Object acct) {
    return '靜音 $acct';
  }

  @override
  String btn_relationship_unmute(Object acct) {
    return '解除靜音 $acct';
  }

  @override
  String btn_relationship_block(Object acct) {
    return '封鎖 $acct';
  }

  @override
  String btn_relationship_unblock(Object acct) {
    return '解除封鎖 $acct';
  }

  @override
  String btn_relationship_report(Object acct) {
    return '回報 $acct';
  }

  @override
  String get btn_notification_mention => '提及';

  @override
  String get btn_notification_status => '通知';

  @override
  String get btn_notification_reblog => '轉嘟';

  @override
  String get btn_notification_follow => '追隨';

  @override
  String get btn_notification_follow_request => '請求追隨';

  @override
  String get btn_notification_favourite => '加入最愛';

  @override
  String get btn_notification_poll => '投票結果';

  @override
  String get btn_notification_update => '編輯';

  @override
  String get btn_notification_unknown => '未知';

  @override
  String get btn_follow_request_accept => '同意';

  @override
  String get btn_follow_request_reject => '拒絕';

  @override
  String get desc_preference_engineer_clear_cache => '清除快取並移除快取資料';

  @override
  String get desc_preference_engineer_reset => '清除設定並且重置系統';

  @override
  String get desc_preference_engineer_test_notifier => '測試發送通知到本裝置';

  @override
  String get txt_spoiler => '暴雷';

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
  String get txt_poll_show_total => '顯示';

  @override
  String get txt_poll_hide_total => '隱藏';

  @override
  String get txt_poll_single => '單選';

  @override
  String get txt_poll_multiple => '多選';

  @override
  String get txt_preference_status => '嘟文設定';

  @override
  String get txt_preference_visibiliby => '能見度';

  @override
  String get txt_preference_sensitive => '敏感內容';

  @override
  String get txt_preference_refresh_interval => '更新頻率';

  @override
  String get txt_preference_reply_all => '所有提及的';

  @override
  String get txt_preference_reply_only => '發嘟文的人';

  @override
  String get txt_preference_reply_none => '不標記任何人';

  @override
  String get txt_show_less => '顯示更少';

  @override
  String get txt_show_more => '顯示更多';

  @override
  String get txt_no_result => '未找到結果';

  @override
  String get txt_profile_bot => '機器人帳號';

  @override
  String get txt_profile_locked => '帳號鎖定';

  @override
  String get txt_profile_discoverable => '可被探索';

  @override
  String get txt_profile_post_indexable => '公開嘟文的隱私';

  @override
  String get txt_profile_hide_collections => '顯示跟隨中與跟隨者';

  @override
  String get txt_profile_general_name => '顯示名稱';

  @override
  String get txt_profile_general_bio => '個人簡歷';

  @override
  String get txt_list_policy_followed => '顯示所有回覆';

  @override
  String get txt_list_policy_list => '僅顯示清單中的回覆';

  @override
  String get txt_list_policy_none => '不顯示回覆';

  @override
  String get txt_list_exclusive => '從首頁時間軸移除';

  @override
  String get txt_list_inclusive => '維持在首頁時間軸';

  @override
  String get desc_preference_status => '控制你嘟文的預設行為';

  @override
  String get desc_poll_show_hide_total => '投票前顯示/隱藏投票結果';

  @override
  String get desc_preference_visibility => '控制嘟文可以被哪些人看到';

  @override
  String get desc_preference_sensitive => '預設顯示/隱藏敏感內容';

  @override
  String get desc_visibility_public => '任何人';

  @override
  String get desc_visibility_unlisted => '公開但不會顯示在時間軸上';

  @override
  String get desc_visibility_private => '所有跟隨者跟提到的使用者';

  @override
  String get desc_visibility_direct => '僅提到的使用者';

  @override
  String get desc_preference_refresh_interval => '更新資料的頻率';

  @override
  String get desc_profile_bot => '該帳號可能會自動化操作且未受人為監控';

  @override
  String get desc_profile_locked => '手動批准好友請求';

  @override
  String get desc_profile_discoverable => '帳號可以公開瀏覽中被搜尋';

  @override
  String get desc_profile_post_indexable => '公開嘟文可以被任何人搜尋';

  @override
  String get desc_profile_hide_collections => '瀏覽你的追隨中與追隨者的帳號';

  @override
  String get desc_preference_reply_all => '標記所有在嘟文中提及的人';

  @override
  String get desc_preference_reply_only => '只標記發嘟文的人';

  @override
  String get desc_preference_reply_none => '不標記任何人';

  @override
  String get desc_create_list => '建立一個新列表';

  @override
  String get desc_list_search_following => '搜尋追隨中的帳號加入列表';

  @override
  String err_invalid_instance(Object domain) {
    return '不合法/不存在的 Mastodon 伺服器: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache => '清除快取成功';

  @override
  String get msg_preference_engineer_reset => '重置成功';

  @override
  String get msg_copied_to_clipboard => '複製到剪貼簿';

  @override
  String get msg_notification_title => '新的通知訊息';

  @override
  String msg_notification_body(Object count) {
    return '你有 $count 筆未讀訊息';
  }

  @override
  String msg_follow_request(Object name) {
    return '來自 $name 的好友請求';
  }

  @override
  String get dots => '...';
}
