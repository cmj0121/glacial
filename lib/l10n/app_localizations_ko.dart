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
  String get txt_invalid_instance => '유효하지 않은 Mastodon 서버';

  @override
  String get txt_server_contact => '연락처';

  @override
  String get txt_search_helper => '흥미로운 것을 검색해보세요';

  @override
  String get txt_search_history => '검색 기록';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => '서버 규칙';

  @override
  String get txt_show_less => '간략히 보기';

  @override
  String get txt_show_more => '더 보기';

  @override
  String txt_trends_uses(Object uses) {
    return '최근 며칠 동안 $uses회 사용됨';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return '$keyword에 대한 결과가 없습니다';
  }

  @override
  String get txt_copied_to_clipboard => '클립보드에 복사됨';

  @override
  String get txt_public => '공개';

  @override
  String get txt_unlisted => '미등록';

  @override
  String get txt_private => '팔로워 전용';

  @override
  String get txt_direct => '다이렉트';

  @override
  String get btn_clean_all => '모두 지우기';

  @override
  String get btn_timeline => '타임라인';

  @override
  String get btn_trending => '지금 유행 중';

  @override
  String get btn_notifications => '알림';

  @override
  String get btn_settings => '설정';

  @override
  String get btn_management => '관리';

  @override
  String get btn_trends_links => '소식';

  @override
  String get btn_trends_statuses => '게시물';

  @override
  String get btn_trends_tags => '해시태그';

  @override
  String get btn_home => '홈';

  @override
  String get btn_user => '사용자';

  @override
  String get btn_profile => '프로필';

  @override
  String get btn_pin => '고정하기';

  @override
  String get btn_schedule => '예약됨';

  @override
  String get btn_local => '이 서버';

  @override
  String get btn_federal => '다른 서버';

  @override
  String get btn_public => '모두';

  @override
  String get btn_bookmarks => '북마크';

  @override
  String get btn_favourites => '좋아요';

  @override
  String get btn_post => '새 게시물';

  @override
  String get btn_follow_mutual => '맞팔로우';

  @override
  String get btn_following => '팔로잉 중';

  @override
  String get btn_followed_by => '팔로워';

  @override
  String get btn_follow => '팔로우';

  @override
  String get btn_block => '차단';

  @override
  String get btn_unblock => '차단 해제';

  @override
  String get btn_mute => '음소거';

  @override
  String get btn_unmute => '음소거 해제';

  @override
  String get btn_report => '신고';

  @override
  String get dots => '...';
}
