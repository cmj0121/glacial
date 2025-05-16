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
  String get btn_clean_all => 'すべて削除';

  @override
  String get dots => '...';
}
