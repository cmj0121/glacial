// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get txt_app_name => '氷河';

  @override
  String get txt_invalid_instance => '無効な Mastodon サーバー';

  @override
  String get txt_server_contact => '連絡先';

  @override
  String get txt_search_helper => '興味のあるものを検索してください';

  @override
  String get txt_search_history => '検索履歴';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => 'サーバーのルール';

  @override
  String get txt_show_less => '注意事項を閉じる';

  @override
  String get txt_show_more => '注意事項';

  @override
  String txt_trends_uses(Object uses) {
    return '過去数日間で$uses回使用されました';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return '$keyword の検索結果が見つかりませんでした';
  }

  @override
  String get txt_copied_to_clipboard => 'クリップボードにコピーしました';

  @override
  String get txt_public => '公開';

  @override
  String get txt_unlisted => '未掲載';

  @override
  String get txt_private => 'フォロワー限定';

  @override
  String get txt_direct => 'ダイレクト';

  @override
  String get btn_clean_all => 'すべて削除';

  @override
  String get btn_timeline => 'タイムライン';

  @override
  String get btn_trending => 'トレンドタグ';

  @override
  String get btn_notifications => '通知';

  @override
  String get btn_settings => '設定';

  @override
  String get btn_management => '管理';

  @override
  String get btn_trends_links => 'ニュース';

  @override
  String get btn_trends_statuses => '投稿';

  @override
  String get btn_trends_tags => 'ハッシュタグ';

  @override
  String get btn_home => 'ホーム';

  @override
  String get btn_user => 'ユーザー';

  @override
  String get btn_profile => 'プロフィール';

  @override
  String get btn_pin => 'ピン留めする';

  @override
  String get btn_schedule => '予定済み';

  @override
  String get btn_local => 'このサーバー';

  @override
  String get btn_federal => 'ほかのサーバー';

  @override
  String get btn_public => 'すべて';

  @override
  String get btn_bookmarks => 'ブックマーク';

  @override
  String get btn_favourites => 'お気に入り';

  @override
  String get btn_post => '投稿';

  @override
  String get btn_follow_mutual => '相互フォロー';

  @override
  String get btn_following => 'フォロー中';

  @override
  String get btn_followed_by => 'フォロワー';

  @override
  String get btn_follow => 'フォロー';

  @override
  String get btn_block => 'ブロック';

  @override
  String get btn_unblock => 'ブロック解除';

  @override
  String get btn_mute => 'ミュート';

  @override
  String get btn_unmute => 'ミュート解除';

  @override
  String get btn_report => '報告';

  @override
  String get dots => '...';
}
