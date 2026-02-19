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
  String get btn_save => '儲存';

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
  String get btn_drawer_announcement => '公告';

  @override
  String get btn_drawer_preference => '偏好設定';

  @override
  String get btn_drawer_logout => '登出';

  @override
  String get btn_dismiss => '已讀';

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
  String get btn_timeline_vote => '投票';

  @override
  String btn_timeline_unread(Object count) {
    return '#$count 未讀嘟文';
  }

  @override
  String get btn_preference_theme => '主題';

  @override
  String get btn_preference_engineer => '工程設定';

  @override
  String get btn_preference_about => '系統資訊';

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
  String get btn_interaction_mute => '靜音對話';

  @override
  String get btn_interaction_block => '封鎖';

  @override
  String get btn_interaction_report => '檢舉';

  @override
  String get btn_interaction_edit => '編輯';

  @override
  String get btn_interaction_delete => '刪除';

  @override
  String get btn_interaction_quote => '引用';

  @override
  String get btn_interaction_filter => '過濾';

  @override
  String get btn_interaction_pin => '置頂';

  @override
  String get btn_interaction_policy => '策略';

  @override
  String get btn_status_info => '查看互動';

  @override
  String get btn_status_history => '查看編輯歷史';

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
  String get btn_profile_filter => '過濾器';

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
  String get btn_relationship_note => '個人備註';

  @override
  String get desc_relationship_note => '為此帳號新增個人備註';

  @override
  String get btn_relationship_endorse => '在個人頁面推薦';

  @override
  String get btn_relationship_unendorse => '取消個人頁面推薦';

  @override
  String get btn_relationship_remove_follower => '移除追隨者';

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
  String get btn_notification_admin_sign_up => '新使用者註冊';

  @override
  String get btn_notification_admin_report => '新的回報';

  @override
  String get btn_notification_unknown => '未知';

  @override
  String get btn_follow_request_accept => '同意';

  @override
  String get btn_follow_request_reject => '拒絕';

  @override
  String get btn_report_back => '返回';

  @override
  String get btn_report_next => '下一步';

  @override
  String get btn_report_file => '提交檢舉';

  @override
  String get btn_report_statuses => '嘟文';

  @override
  String get btn_report_rules => '規則';

  @override
  String get btn_filter_warn => '警告';

  @override
  String get btn_filter_hide => '隱藏';

  @override
  String get btn_filter_blur => '模糊';

  @override
  String get btn_filter_context_home => '首頁時間軸';

  @override
  String get btn_filter_context_notification => '通知';

  @override
  String get btn_filter_context_public => '公開時間軸';

  @override
  String get btn_filter_context_thread => '討論串';

  @override
  String get btn_filter_context_account => '個人檔案';

  @override
  String get btn_filter_whole_match => '完整詞彙';

  @override
  String get btn_filter_partial_match => '部分詞彙';

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
  String get txt_preference_loaded_top => '對齊最新的內容';

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
  String get btn_translate_show => '翻譯';

  @override
  String get btn_translate_hide => '顯示原文';

  @override
  String get txt_familiar_followers => '你追蹤的人也追蹤了';

  @override
  String get txt_featured_tags => '精選標籤';

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
  String get txt_report_spam => '垃圾訊息';

  @override
  String get txt_report_legal => '非法內容';

  @override
  String get txt_report_violation => '違反守則';

  @override
  String get txt_report_other => '其他';

  @override
  String get txt_filter_title => '選擇並套用過濾器';

  @override
  String get txt_filter_applied => '過濾器已套用';

  @override
  String get txt_filter_name => '過濾器名稱';

  @override
  String get txt_filter_expired => '已過期';

  @override
  String get txt_filter_never => '從不';

  @override
  String get txt_quote_policy_public => '任意';

  @override
  String get txt_quote_policy_followers => '追蹤者';

  @override
  String get txt_quote_policy_nobody => '沒有人';

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
  String get desc_preference_loaded_top => '點擊時加載最新內容且跳到開頭';

  @override
  String get desc_preference_locale => '在系統中使用的語系';

  @override
  String get txt_preference_timeline => '時間軸設定';

  @override
  String get desc_preference_timeline => '控制時間軸中顯示的內容';

  @override
  String get txt_preference_hide_replies => '隱藏回覆';

  @override
  String get desc_preference_hide_replies => '在時間軸中隱藏回覆';

  @override
  String get txt_preference_hide_reblogs => '隱藏轉發';

  @override
  String get desc_preference_hide_reblogs => '在時間軸中隱藏轉發';

  @override
  String get txt_preference_auto_play => '自動播放影片';

  @override
  String get desc_preference_auto_play => '在時間軸中自動播放影片';

  @override
  String get txt_preference_timeline_limit => '時間軸大小';

  @override
  String get desc_preference_timeline_limit => '一次載入的最大貼文數量';

  @override
  String get txt_preference_image_quality => '圖片品質';

  @override
  String get txt_preference_image_low => '低（節省流量）';

  @override
  String get txt_preference_image_medium => '中';

  @override
  String get txt_preference_image_high => '高（原始）';

  @override
  String get txt_preference_appearance => '外觀';

  @override
  String get desc_preference_appearance => '自訂應用程式的外觀';

  @override
  String get txt_preference_font_scale => '字體大小';

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
  String get desc_report_spam => '此帳號正在張貼未經請求的廣告';

  @override
  String get desc_report_legal => '此帳號正在張貼非法內容或要求非法行為';

  @override
  String get desc_report_violation => '此帳號正在張貼違反此實例規則的內容';

  @override
  String get desc_report_other => '其他未列出的原因';

  @override
  String get desc_report_comment => '可選擇新增評論以提供更多檢舉事項';

  @override
  String get desc_filter_warn => '隱藏於警告標示之後';

  @override
  String get desc_filter_hide => '完全隱藏內容';

  @override
  String get desc_filter_blur => '模糊內容';

  @override
  String get desc_filter_context_home => '任何在首頁時間軸匹配的嘟文';

  @override
  String get desc_filter_context_notification => '任何匹配的通知';

  @override
  String get desc_filter_context_public => '任何在公開時間軸匹配的嘟文';

  @override
  String get desc_filter_context_thread => '任何符合的討論串';

  @override
  String get desc_filter_context_account => '任何符合的個人頁面';

  @override
  String get desc_filter_expiration => '過濾器過期時效';

  @override
  String get desc_filter_context => '過濾器套用的情境';

  @override
  String get desc_quote_approval_public => '任何人都可以引用嘟文.';

  @override
  String get desc_quote_approval_followers => '限追蹤者可以引用嘟文';

  @override
  String get desc_quote_approval_following => '限追蹤中可以引用嘟文';

  @override
  String get desc_quote_approval_unsupport => '不支援引用嘟文';

  @override
  String get desc_quote_policy => '嘟文引用原則';

  @override
  String get desc_quote_policy_public => '任何人都可以引用嘟文.';

  @override
  String get desc_quote_policy_followers => '限追蹤者可以引用嘟文';

  @override
  String get desc_quote_policy_nobody => '禁止其他人引用嘟文';

  @override
  String get desc_quote_removed => '無法取得引用嘟文';

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
  String get txt_notification_policy => '通知策略';

  @override
  String get txt_notification_policy_not_following => '你未追蹤的人';

  @override
  String get txt_notification_policy_not_followers => '未追蹤你的人';

  @override
  String get txt_notification_policy_new_accounts => '新帳號';

  @override
  String get txt_notification_policy_private_mentions => '私人提及';

  @override
  String get txt_notification_policy_limited_accounts => '受管制帳號';

  @override
  String get txt_notification_policy_accept => '接受';

  @override
  String get txt_notification_policy_filter => '過濾';

  @override
  String get txt_notification_policy_drop => '丟棄';

  @override
  String get txt_no_announcements => '此伺服器沒有公告';

  @override
  String txt_poll_votes(int count) {
    return '$count 票';
  }

  @override
  String get txt_media_alt_text => '替代文字';

  @override
  String get txt_media_image_info => '圖片資訊';

  @override
  String get txt_media_no_exif => '無 EXIF 資料';

  @override
  String get txt_server_rules => '伺服器規則';

  @override
  String get txt_server_registration => '開放註冊';

  @override
  String get txt_about_app_version => '應用程式版本';

  @override
  String get txt_about_author => '作者';

  @override
  String get txt_about_repository => '程式碼庫';

  @override
  String get txt_about_copyright => '版權';

  @override
  String get btn_sidebar_conversations => '私訊';

  @override
  String get txt_no_conversations => '沒有私訊';

  @override
  String get txt_no_notifications => '還沒有通知';

  @override
  String get txt_conversation_unread => '未讀';

  @override
  String get btn_drawer_domain_blocks => '已封鎖網域';

  @override
  String get btn_drawer_endorsed => '推薦用戶';

  @override
  String get txt_no_domain_blocks => '沒有已封鎖的網域';

  @override
  String get btn_admin_reports => '檢舉';

  @override
  String get btn_admin_accounts => '帳號';

  @override
  String get btn_admin_approve => '核准';

  @override
  String get btn_admin_reject => '拒絕';

  @override
  String get btn_admin_suspend => '停權';

  @override
  String get btn_admin_silence => '限制';

  @override
  String get btn_admin_enable => '啟用';

  @override
  String get btn_admin_unsilence => '解除限制';

  @override
  String get btn_admin_unsuspend => '解除停權';

  @override
  String get btn_admin_unsensitive => '解除敏感標記';

  @override
  String get btn_admin_assign => '指派給我';

  @override
  String get btn_admin_unassign => '取消指派';

  @override
  String get btn_admin_resolve => '解決';

  @override
  String get btn_admin_reopen => '重新開啟';

  @override
  String get txt_admin_no_permission => '需要管理員權限';

  @override
  String get txt_admin_no_reports => '沒有檢舉';

  @override
  String get txt_admin_no_accounts => '未找到帳號';

  @override
  String get txt_admin_report_resolved => '已解決';

  @override
  String get txt_admin_report_unresolved => '未解決';

  @override
  String get txt_admin_account_active => '啟用中';

  @override
  String get txt_admin_account_pending => '待審核';

  @override
  String get txt_admin_account_disabled => '已停用';

  @override
  String get txt_admin_account_silenced => '已限制';

  @override
  String get txt_admin_account_suspended => '已停權';

  @override
  String get txt_admin_confirm_action => '確認操作';

  @override
  String get desc_admin_confirm_action => '此操作無法輕易復原，確定要執行嗎？';

  @override
  String get txt_admin_report_by => '檢舉人';

  @override
  String get txt_admin_assigned_to => '受理人';

  @override
  String get btn_register => '建立帳號';

  @override
  String get txt_register_title => '建立帳號';

  @override
  String get txt_username => '使用者名稱';

  @override
  String get txt_email => '電子信箱';

  @override
  String get txt_password => '密碼';

  @override
  String get txt_confirm_password => '確認密碼';

  @override
  String get txt_agreement => '我同意伺服器規則與服務條款';

  @override
  String get txt_reason => '加入原因';

  @override
  String get txt_registration_success => '請檢查您的電子信箱以確認帳號';

  @override
  String get err_registration_failed => '註冊失敗';

  @override
  String get err_field_required => '此欄位為必填';

  @override
  String get err_invalid_email => '無效的電子信箱地址';

  @override
  String get err_password_too_short => '密碼必須至少 8 個字元';

  @override
  String get err_password_mismatch => '密碼不一致';

  @override
  String get err_agreement_required => '您必須同意條款';

  @override
  String get txt_admin_account_confirmed => '已確認';

  @override
  String get txt_admin_account_unconfirmed => '未確認';

  @override
  String get txt_admin_account_approved => '已批准';

  @override
  String get txt_admin_account_not_approved => '未批准';

  @override
  String get txt_work_in_progress => '進行中';

  @override
  String get txt_default_server_name => 'Glacial 伺服器';

  @override
  String txt_hashtag_usage(int uses) {
    return '過去幾天使用了$uses次';
  }

  @override
  String get dots => '...';

  @override
  String get btn_drawer_switch_account => '切換帳號';

  @override
  String get btn_account_picker_add => '新增帳號';

  @override
  String get txt_account_picker_title => '帳號';

  @override
  String msg_account_switched(String username) {
    return '已切換至 $username';
  }

  @override
  String get msg_account_removed => '帳號已移除';

  @override
  String get btn_drawer_drafts => '草稿';

  @override
  String get txt_drafts_title => '草稿';

  @override
  String get txt_no_drafts => '沒有草稿';

  @override
  String get msg_draft_saved => '草稿已儲存';

  @override
  String get msg_draft_deleted => '草稿已刪除';

  @override
  String get txt_draft_reply => '回覆草稿';

  @override
  String get btn_undo => '復原';

  @override
  String get txt_offline_banner => '您已離線';

  @override
  String get txt_cached_data => '正在顯示快取資料';

  @override
  String get msg_network_restored => '連線已恢復';

  @override
  String get msg_confirm_reset => '這將刪除所有資料、帳號和設定，此操作無法復原。';

  @override
  String get btn_confirm => '確認';

  @override
  String get msg_loading_error => '載入時發生錯誤，請重試。';

  @override
  String get btn_retry => '重試';

  @override
  String get msg_test_notification_pending => '測試通知將在 5 秒後發送...';

  @override
  String get msg_test_notification_foreground => '應用程式在前景時不會發送通知。';

  @override
  String get lbl_swipe_back => '滑動返回';

  @override
  String get lbl_swipe_remove => '滑動移除';

  @override
  String get lbl_swipe_delete => '滑動刪除';

  @override
  String get lbl_avatar => '頭像';

  @override
  String get msg_admin_only => '需要管理員權限';

  @override
  String get msg_confirm_delete_post => '確定要刪除這篇貼文嗎？此操作無法復原。';

  @override
  String msg_confirm_block(String account) {
    return '封鎖 $account？您將不再看到他們的貼文。';
  }

  @override
  String msg_confirm_mute(String account) {
    return '靜音 $account？他們的貼文將從您的動態中隱藏。';
  }

  @override
  String get msg_confirm_delete_conversation => '刪除這則對話？';

  @override
  String get msg_confirm_delete_filter => '刪除此過濾器？';

  @override
  String get msg_network_error => '發生錯誤，請重試。';

  @override
  String get btn_tap_retry => '輕觸重試';

  @override
  String get btn_change_server => '更換伺服器';

  @override
  String get msg_server_unreachable => '無法連線至伺服器。請檢查連線或嘗試其他伺服器。';
}
