// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get txt_app_name => '빙하';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => '입력 후 검색하세요...';

  @override
  String get txt_search_helper => '흥미로운 것을 검색해보세요';

  @override
  String get txt_search_history => '검색 기록';

  @override
  String get txt_invalid_instance => '유효하지 않은 Mastodon 서버';

  @override
  String get txt_server_contact => '연락처';

  @override
  String get txt_server_rules => '서버 규칙';

  @override
  String get txt_public => '공개';

  @override
  String get txt_unlisted => '미등록';

  @override
  String get txt_private => '팔로워 전용';

  @override
  String get txt_direct => '다이렉트';

  @override
  String get txt_copied_to_clipboard => '클립보드에 복사됨';

  @override
  String txt_trends_uses(Object uses) {
    return '최근 며칠 동안 $uses회 사용됨';
  }

  @override
  String get txt_show_less => '간단히 보기';

  @override
  String get txt_show_more => '자세히 보기';

  @override
  String txt_user_profile(Object text) {
    return '사용자 $text 프로필';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return '$keyword에 대한 결과가 없습니다';
  }

  @override
  String get btn_clean_all => '모두 지우기';

  @override
  String get btn_back_to_explorer => '탐색 페이지로 돌아가기';

  @override
  String get btn_sign_in => '로그인';

  @override
  String get btn_timeline => '타임라인';

  @override
  String get btn_trending => '트렌드';

  @override
  String get btn_notifications => '알림';

  @override
  String get btn_explore => '탐색';

  @override
  String get btn_settings => '설정';

  @override
  String get btn_post => '게시';

  @override
  String get btn_home_timeline => '홈';

  @override
  String get btn_local_timeline => '로컬';

  @override
  String get btn_federal_timeline => '페더럴';

  @override
  String get btn_public_timeline => '공개';

  @override
  String get btn_bookmarks_timeline => '북마크';

  @override
  String get btn_favourites_timeline => '즐겨찾기';

  @override
  String get btn_hashtag_timeline => '해시태그';

  @override
  String get btn_reply => '답글';

  @override
  String get btn_reblog => '리블로그';

  @override
  String get btn_favourite => '즐겨찾기';

  @override
  String get btn_bookmark => '북마크';

  @override
  String get btn_share => '공유';

  @override
  String get btn_mute => '음소거';

  @override
  String get btn_block => '차단';

  @override
  String get btn_delete => '삭제';

  @override
  String get btn_trends_links => '인기 뉴스';

  @override
  String get btn_trends_statuses => '상태';

  @override
  String get btn_trends_tags => '태그';

  @override
  String get btn_management => '관리';

  @override
  String get dots => '...';
}
