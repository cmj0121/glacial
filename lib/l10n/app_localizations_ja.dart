// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get btn_search => '検索';

  @override
  String get btn_close => '閉じる';

  @override
  String get btn_clear => 'クリア';

  @override
  String get btn_exit => '終了';

  @override
  String get btn_reload => '再読み込み';

  @override
  String get btn_history => '履歴';

  @override
  String get btn_sidebar_timelines => 'タイムライン';

  @override
  String get btn_sidebar_lists => 'リスト';

  @override
  String get btn_sidebar_trendings => 'トレンド';

  @override
  String get btn_sidebar_notifications => '通知';

  @override
  String get btn_sidebar_management => '管理';

  @override
  String get btn_sidebar_post => 'トゥート';

  @override
  String get btn_sidebar_sign_in => 'サインイン';

  @override
  String get btn_drawer_switch_server => 'サーバー切替';

  @override
  String get btn_drawer_directory => 'アカウント探索';

  @override
  String get btn_drawer_preference => '設定';

  @override
  String get btn_drawer_logout => 'ログアウト';

  @override
  String get btn_trends_links => 'リンク';

  @override
  String get btn_trends_toots => 'トゥート';

  @override
  String get btn_trends_users => 'ユーザー';

  @override
  String get btn_trends_tags => 'タグ';

  @override
  String get btn_timeline_home => 'ホーム';

  @override
  String get btn_timeline_local => 'ローカル';

  @override
  String get btn_timeline_federal => '連邦';

  @override
  String get btn_timeline_public => '公開';

  @override
  String get btn_timeline_favourites => 'お気に入り';

  @override
  String get btn_timeline_bookmarks => 'ブックマーク';

  @override
  String get btn_timeline_list => 'リスト';

  @override
  String get btn_timeline_vote => '投票';

  @override
  String get btn_preference_theme => 'テーマ';

  @override
  String get btn_preference_engineer => '開発者設定';

  @override
  String get btn_preference_about => 'アプリ情報';

  @override
  String get btn_preference_engineer_clear_cache => 'キャッシュをクリア';

  @override
  String get btn_preference_engineer_reset => 'システムリセット';

  @override
  String get btn_preference_engineer_test_notifier => '通知テスト';

  @override
  String get btn_interaction_reply => '返信';

  @override
  String get btn_interaction_reblog => 'リブログ';

  @override
  String get btn_interaction_favourite => 'お気に入り';

  @override
  String get btn_interaction_bookmark => 'ブックマーク';

  @override
  String get btn_interaction_share => '共有';

  @override
  String get btn_interaction_mute => 'ミュート';

  @override
  String get btn_interaction_block => 'ブロック';

  @override
  String get btn_interaction_report => '報告';

  @override
  String get btn_interaction_edit => '編集';

  @override
  String get btn_interaction_delete => '削除';

  @override
  String get btn_profile_core => 'プロフィール';

  @override
  String get btn_profile_post => 'トゥート';

  @override
  String get btn_profile_pin => '固定トゥート';

  @override
  String get btn_profile_followers => 'フォロワー';

  @override
  String get btn_profile_following => 'フォロー中';

  @override
  String get btn_profile_scheduled => '約投稿';

  @override
  String get btn_profile_hashtag => 'フォロー中のハッシュタグ';

  @override
  String get btn_profile_mute => 'ミュートユーザー';

  @override
  String get btn_profile_block => 'ブロックユーザー';

  @override
  String get btn_profile_general_info => '基本情報';

  @override
  String get btn_profile_privacy => 'プライバシー設定';

  @override
  String get btn_status_toot => 'トゥート';

  @override
  String get btn_status_edit => '編集';

  @override
  String get btn_status_scheduled => '予約トゥート';

  @override
  String get btn_relationship_following => 'フォロー中';

  @override
  String get btn_relationship_followed_by => 'フォローされています';

  @override
  String get btn_relationship_follow_each_other => '友達';

  @override
  String get btn_relationship_follow_request => 'フォローリクエスト（承認待ち）';

  @override
  String get btn_relationship_stranger => '知らない人';

  @override
  String get btn_relationship_blocked_by => 'ブロックされている';

  @override
  String btn_relationship_mute(Object acct) {
    return '$acctをミュート';
  }

  @override
  String btn_relationship_unmute(Object acct) {
    return '$acctのミュート解除';
  }

  @override
  String btn_relationship_block(Object acct) {
    return '$acctをブロック';
  }

  @override
  String btn_relationship_unblock(Object acct) {
    return '$acctのブロック解除';
  }

  @override
  String btn_relationship_report(Object acct) {
    return '$acctを報告';
  }

  @override
  String get btn_notification_mention => 'メンション';

  @override
  String get btn_notification_status => '通知';

  @override
  String get btn_notification_reblog => 'リブログ';

  @override
  String get btn_notification_follow => 'フォローされました';

  @override
  String get btn_notification_follow_request => 'フォローリクエスト';

  @override
  String get btn_notification_favourite => 'お気に入り';

  @override
  String get btn_notification_poll => '投票';

  @override
  String get btn_notification_update => '更新';

  @override
  String get btn_notification_admin_sign_up => '新規登録';

  @override
  String get btn_notification_admin_report => '新しいレポート';

  @override
  String get btn_notification_unknown => '不明';

  @override
  String get btn_follow_request_accept => '承認';

  @override
  String get btn_follow_request_reject => '拒否';

  @override
  String get btn_report_back => '戻る';

  @override
  String get btn_report_next => '次へ';

  @override
  String get btn_report_file => '報告を提出';

  @override
  String get btn_report_statuses => 'トゥート';

  @override
  String get btn_report_rules => 'ルール';

  @override
  String get desc_preference_engineer_clear_cache => '全てのキャッシュをクリア';

  @override
  String get desc_preference_engineer_reset => '設定を全てクリアしてアプリをリセット';

  @override
  String get desc_preference_engineer_test_notifier => 'ローカル端末で通知をテスト';

  @override
  String get txt_spoiler => 'ネタバレ';

  @override
  String get txt_search_history => '検索履歴';

  @override
  String get txt_helper_server_explorer => 'Mastodonサーバーを検索';

  @override
  String get txt_hint_server_explorer => 'mastodon.social またはキーワード';

  @override
  String get txt_desc_preference_system_theme => 'システムテーマ';

  @override
  String get txt_visibility_public => '公開';

  @override
  String get txt_visibility_unlisted => '非公開';

  @override
  String get txt_visibility_private => 'プライベート';

  @override
  String get txt_visibility_direct => 'ダイレクト';

  @override
  String get txt_suggestion_staff => 'スタッフのおすすめ';

  @override
  String get txt_suggestion_past_interactions => '以前にやり取りしたユーザー';

  @override
  String get txt_suggestion_global => '世界で人気';

  @override
  String get txt_poll_show_total => '合計を表示';

  @override
  String get txt_poll_hide_total => '合計を非表示';

  @override
  String get txt_poll_single => '単一選択';

  @override
  String get txt_poll_multiple => '複数選択';

  @override
  String get txt_preference_status => 'ステータス設定';

  @override
  String get txt_preference_visibiliby => '可視性';

  @override
  String get txt_preference_sensitive => 'センシティブコンテンツ';

  @override
  String get txt_preference_refresh_interval => '更新間隔';

  @override
  String get txt_preference_reply_all => '全員に返信';

  @override
  String get txt_preference_reply_only => '投稿者のみ';

  @override
  String get txt_preference_reply_none => '誰もタグ付けしない';

  @override
  String get txt_show_less => '簡易表示';

  @override
  String get txt_show_more => '詳細表示';

  @override
  String get txt_no_result => '結果が見つかりません';

  @override
  String get txt_profile_bot => 'ボットアカウント';

  @override
  String get txt_profile_locked => 'アカウントロック中';

  @override
  String get txt_profile_discoverable => '公開可能';

  @override
  String get txt_profile_post_indexable => '公開投稿のプライバシー';

  @override
  String get txt_profile_hide_collections => 'フォロー・フォロワー表示';

  @override
  String get txt_profile_general_name => '表示名';

  @override
  String get txt_profile_general_bio => '自己紹介';

  @override
  String get txt_list_policy_followed => 'フォローしているユーザーの返信を表示';

  @override
  String get txt_list_policy_list => 'リストメンバーの返信のみ表示';

  @override
  String get txt_list_policy_none => '返信を表示しない';

  @override
  String get txt_list_exclusive => 'ホームタイムラインから除外';

  @override
  String get txt_list_inclusive => 'ホームタイムラインに表示';

  @override
  String get txt_report_spam => 'スパム';

  @override
  String get txt_report_legal => '違法コンテンツ';

  @override
  String get txt_report_violation => '規則違反';

  @override
  String get txt_report_other => 'その他';

  @override
  String get desc_preference_status => 'デフォルトのステータス動作を設定・管理';

  @override
  String get desc_poll_show_hide_total => '投票終了まで投票数を表示/非表示';

  @override
  String get desc_preference_visibility => '誰がステータスを見れるか設定';

  @override
  String get desc_preference_sensitive => 'センシティブコンテンツをデフォルトで表示/非表示';

  @override
  String get desc_visibility_public => '誰でもこのトゥートを表示・一覧可能';

  @override
  String get desc_visibility_unlisted => '公開だがタイムラインには表示されない';

  @override
  String get desc_visibility_private => 'フォロワーとメンションされたユーザーのみ';

  @override
  String get desc_visibility_direct => 'メンションされたユーザーのみ';

  @override
  String get desc_preference_refresh_interval => 'アプリデータ更新間隔';

  @override
  String get desc_preference_locale => 'システムのロケールが使用されます';

  @override
  String get desc_profile_bot => '自動操作可能なアカウントで、人間による監視はされていません';

  @override
  String get desc_profile_locked => 'フォローリクエストを手動承認';

  @override
  String get desc_profile_discoverable => 'プロフィールディレクトリで検索可能';

  @override
  String get desc_profile_post_indexable => '公開投稿は誰でも検索可能';

  @override
  String get desc_profile_hide_collections => 'フォロワーとフォロー中をプロフィルで表示可能';

  @override
  String get desc_preference_reply_all => '投稿でメンションされた全員をタグ付け';

  @override
  String get desc_preference_reply_only => '投稿者のみタグ付け';

  @override
  String get desc_preference_reply_none => '誰もタグ付けしない';

  @override
  String get desc_create_list => '新しいリストを作成';

  @override
  String get desc_list_search_following => 'リストに追加するアカウントを検索';

  @override
  String get desc_report_spam => 'このアカウントは迷惑な広告を投稿しています';

  @override
  String get desc_report_legal => 'このアカウントは違法なコンテンツを投稿するか、違法行為を求めています';

  @override
  String get desc_report_violation => 'このアカウントはインスタンスの規則に違反するコンテンツを投稿しています';

  @override
  String get desc_report_other => 'その他、記載されていない理由';

  @override
  String get desc_report_comment => '報告についての詳細を提供するため、任意でコメントを追加できます。';

  @override
  String err_invalid_instance(Object domain) {
    return '無効なMastodonサーバー: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache => 'キャッシュをクリアしました';

  @override
  String get msg_preference_engineer_reset => 'リセットしました';

  @override
  String get msg_copied_to_clipboard => 'クリップボードにコピーしました';

  @override
  String get msg_notification_title => '新しい通知';

  @override
  String msg_notification_body(Object count) {
    return '$count件の未読通知があります';
  }

  @override
  String msg_follow_request(Object name) {
    return '$nameからフォローリクエスト';
  }

  @override
  String get dots => '...';
}
