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
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => '入力して検索...';

  @override
  String get txt_search_helper => '興味のあるものを検索してください';

  @override
  String get txt_search_history => '検索履歴';

  @override
  String get txt_invalid_instance => '無効な Mastodon サーバー';

  @override
  String get txt_server_contact => '連絡先';

  @override
  String get txt_server_rules => 'サーバールール';

  @override
  String get txt_public => '公開';

  @override
  String get txt_unlisted => '未掲載';

  @override
  String get txt_private => 'フォロワー限定';

  @override
  String get txt_direct => 'ダイレクト';

  @override
  String get txt_copied_to_clipboard => 'クリップボードにコピーしました';

  @override
  String txt_trends_uses(Object uses) {
    return '過去数日間で$uses回使用されました';
  }

  @override
  String get txt_show_less => '表示を減らす';

  @override
  String get txt_show_more => 'もっと表示';

  @override
  String txt_user_profile(Object text) {
    return 'ユーザー $text のプロフィール';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return '$keyword の検索結果が見つかりませんでした';
  }

  @override
  String get btn_clean_all => 'すべて削除';

  @override
  String get btn_back_to_explorer => '検索ページに戻る';

  @override
  String get btn_sign_in => 'サインイン';

  @override
  String get btn_timeline => 'タイムライン';

  @override
  String get btn_trending => 'トレンド';

  @override
  String get btn_notifications => '通知';

  @override
  String get btn_explore => '検索';

  @override
  String get btn_settings => '設定';

  @override
  String get btn_post => '投稿';

  @override
  String get btn_home_timeline => 'ホーム';

  @override
  String get btn_local_timeline => 'ローカル';

  @override
  String get btn_federal_timeline => 'フェデレーション';

  @override
  String get btn_public_timeline => 'パブリック';

  @override
  String get btn_bookmarks_timeline => 'ブックマーク';

  @override
  String get btn_favourites_timeline => 'お気に入り';

  @override
  String get btn_hashtag_timeline => 'ハッシュタグ';

  @override
  String get btn_reply => '返信';

  @override
  String get btn_reblog => '再投稿';

  @override
  String get btn_favourite => 'お気に入り';

  @override
  String get btn_bookmark => 'ブックマーク';

  @override
  String get btn_share => '共有';

  @override
  String get btn_mute => 'ミュート';

  @override
  String get btn_block => 'ブロック';

  @override
  String get btn_delete => '削除';

  @override
  String get btn_trends_links => '注目ニュース';

  @override
  String get btn_trends_statuses => '投稿';

  @override
  String get btn_trends_tags => 'タグ';

  @override
  String get btn_management => '管理（かんり）';

  @override
  String get btn_follow_mutual => '相互フォロー';

  @override
  String get btn_following => 'フォロー中';

  @override
  String get btn_followed_by => 'フォロワー';

  @override
  String get btn_follow => 'フォロー';

  @override
  String get dots => '...';
}
