// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get btn_search => '검색';

  @override
  String get btn_close => '닫기';

  @override
  String get btn_clear => '지우기';

  @override
  String get btn_exit => '종료';

  @override
  String get btn_reload => '새로고침';

  @override
  String get btn_history => '기록';

  @override
  String get btn_sidebar_timelines => '타임라인';

  @override
  String get btn_sidebar_lists => '리스트';

  @override
  String get btn_sidebar_trendings => '트렌드';

  @override
  String get btn_sidebar_notifications => '알림';

  @override
  String get btn_sidebar_management => '관리';

  @override
  String get btn_sidebar_post => '글쓰기';

  @override
  String get btn_sidebar_sign_in => '로그인';

  @override
  String get btn_drawer_switch_server => '서버 변경';

  @override
  String get btn_drawer_directory => '계정 탐색';

  @override
  String get btn_drawer_preference => '설정';

  @override
  String get btn_drawer_logout => '로그아웃';

  @override
  String get btn_trends_links => '링크';

  @override
  String get btn_trends_toots => '글';

  @override
  String get btn_trends_users => '사용자';

  @override
  String get btn_trends_tags => '태그';

  @override
  String get btn_timeline_home => '홈';

  @override
  String get btn_timeline_local => '로컬';

  @override
  String get btn_timeline_federal => '연방';

  @override
  String get btn_timeline_public => '공개';

  @override
  String get btn_timeline_favourites => '즐겨찾기';

  @override
  String get btn_timeline_bookmarks => '북마크';

  @override
  String get btn_timeline_list => '리스트';

  @override
  String get btn_timeline_vote => '투표';

  @override
  String btn_timeline_unread(Object count) {
    return '읽지 않은 툿 #$count개';
  }

  @override
  String get btn_preference_theme => '테마';

  @override
  String get btn_preference_engineer => '개발자 설정';

  @override
  String get btn_preference_about => '앱 정보';

  @override
  String get btn_preference_engineer_clear_cache => '캐시 삭제';

  @override
  String get btn_preference_engineer_reset => '시스템 초기화';

  @override
  String get btn_preference_engineer_test_notifier => '알림 테스트';

  @override
  String get btn_interaction_reply => '답글';

  @override
  String get btn_interaction_reblog => '리블로그';

  @override
  String get btn_interaction_favourite => '즐겨찾기';

  @override
  String get btn_interaction_bookmark => '북마크';

  @override
  String get btn_interaction_share => '공유';

  @override
  String get btn_interaction_mute => '뮤트';

  @override
  String get btn_interaction_block => '차단';

  @override
  String get btn_interaction_report => '신고';

  @override
  String get btn_interaction_edit => '편집';

  @override
  String get btn_interaction_delete => '삭제';

  @override
  String get btn_profile_core => '프로필';

  @override
  String get btn_profile_post => '글';

  @override
  String get btn_profile_pin => '고정 글';

  @override
  String get btn_profile_followers => '팔로워';

  @override
  String get btn_profile_following => '팔로잉';

  @override
  String get btn_profile_scheduled => '예약 글';

  @override
  String get btn_profile_hashtag => '팔로우 중인 해시태그';

  @override
  String get btn_profile_mute => '뮤트한 사용자';

  @override
  String get btn_profile_block => '차단한 사용자';

  @override
  String get btn_profile_general_info => '기본 정보';

  @override
  String get btn_profile_privacy => '개인정보 설정';

  @override
  String get btn_status_toot => '글쓰기';

  @override
  String get btn_status_edit => '편집';

  @override
  String get btn_status_scheduled => '예약 글';

  @override
  String get btn_relationship_following => '팔로잉';

  @override
  String get btn_relationship_followed_by => '팔로워';

  @override
  String get btn_relationship_follow_each_other => '친구';

  @override
  String get btn_relationship_follow_request => '팔로우 요청 (승인 대기 중)';

  @override
  String get btn_relationship_stranger => '낯선 사람';

  @override
  String get btn_relationship_blocked_by => '차단됨';

  @override
  String btn_relationship_mute(Object acct) {
    return '$acct 뮤트';
  }

  @override
  String btn_relationship_unmute(Object acct) {
    return '$acct 뮤트 해제';
  }

  @override
  String btn_relationship_block(Object acct) {
    return '$acct 차단';
  }

  @override
  String btn_relationship_unblock(Object acct) {
    return '$acct 차단 해제';
  }

  @override
  String btn_relationship_report(Object acct) {
    return '$acct 신고';
  }

  @override
  String get btn_notification_mention => '멘션';

  @override
  String get btn_notification_status => '알림';

  @override
  String get btn_notification_reblog => '리블로그';

  @override
  String get btn_notification_follow => '팔로우됨';

  @override
  String get btn_notification_follow_request => '팔로우 요청';

  @override
  String get btn_notification_favourite => '즐겨찾기';

  @override
  String get btn_notification_poll => '투표';

  @override
  String get btn_notification_update => '업데이트';

  @override
  String get btn_notification_admin_sign_up => '새 가입';

  @override
  String get btn_notification_admin_report => '새 보고서';

  @override
  String get btn_notification_unknown => '알 수 없음';

  @override
  String get btn_follow_request_accept => '수락';

  @override
  String get btn_follow_request_reject => '거절';

  @override
  String get btn_report_back => '뒤로';

  @override
  String get btn_report_next => '다음';

  @override
  String get btn_report_file => '신고 제출';

  @override
  String get btn_report_statuses => '툿(Toot)';

  @override
  String get btn_report_rules => '규칙';

  @override
  String get desc_preference_engineer_clear_cache => '모든 캐시 데이터 삭제';

  @override
  String get desc_preference_engineer_reset => '모든 설정 초기화 및 앱 재설정';

  @override
  String get desc_preference_engineer_test_notifier => '로컬 기기에서 알림 테스트';

  @override
  String get txt_spoiler => '스포일러';

  @override
  String get txt_search_history => '검색 기록';

  @override
  String get txt_helper_server_explorer => 'Mastodon 서버 검색';

  @override
  String get txt_hint_server_explorer => 'mastodon.social 또는 키워드';

  @override
  String get txt_desc_preference_system_theme => '시스템 테마';

  @override
  String get txt_visibility_public => '공개';

  @override
  String get txt_visibility_unlisted => '비공개';

  @override
  String get txt_visibility_private => '팔로워만';

  @override
  String get txt_visibility_direct => '다이렉트';

  @override
  String get txt_suggestion_staff => '관리자 추천';

  @override
  String get txt_suggestion_past_interactions => '과거 상호작용';

  @override
  String get txt_suggestion_global => '전 세계 인기';

  @override
  String get txt_poll_show_total => '총합 표시';

  @override
  String get txt_poll_hide_total => '총합 숨기기';

  @override
  String get txt_poll_single => '단일 선택';

  @override
  String get txt_poll_multiple => '복수 선택';

  @override
  String get txt_preference_status => '상태 설정';

  @override
  String get txt_preference_visibiliby => '가시성';

  @override
  String get txt_preference_sensitive => '민감 콘텐츠';

  @override
  String get txt_preference_refresh_interval => '갱신 간격';

  @override
  String get txt_preference_loaded_top => '최신 불러올 때 정렬';

  @override
  String get txt_preference_reply_all => '모든 멘션';

  @override
  String get txt_preference_reply_only => '작성자만';

  @override
  String get txt_preference_reply_none => '태그 없음';

  @override
  String get txt_show_less => '간략 표시';

  @override
  String get txt_show_more => '더보기';

  @override
  String get txt_no_result => '결과 없음';

  @override
  String get txt_profile_bot => '봇 계정';

  @override
  String get txt_profile_locked => '계정 잠김';

  @override
  String get txt_profile_discoverable => '검색 가능';

  @override
  String get txt_profile_post_indexable => '공개 글 검색 가능';

  @override
  String get txt_profile_hide_collections => '팔로워 및 팔로잉 표시';

  @override
  String get txt_profile_general_name => '표시 이름';

  @override
  String get txt_profile_general_bio => '소개';

  @override
  String get txt_list_policy_followed => '팔로우한 사용자의 답글 표시';

  @override
  String get txt_list_policy_list => '리스트 멤버의 답글만 표시';

  @override
  String get txt_list_policy_none => '답글 표시 안함';

  @override
  String get txt_list_exclusive => '홈 타임라인에서 제외';

  @override
  String get txt_list_inclusive => '홈 타임라인에 표시';

  @override
  String get txt_report_spam => '스팸';

  @override
  String get txt_report_legal => '불법 콘텐츠';

  @override
  String get txt_report_violation => '규칙 위반';

  @override
  String get txt_report_other => '기타';

  @override
  String get desc_preference_status => '기본 상태 동작 설정 및 제어';

  @override
  String get desc_poll_show_hide_total => '투표 종료까지 투표 수 표시/숨김';

  @override
  String get desc_preference_visibility => '상태를 볼 수 있는 사용자 제어';

  @override
  String get desc_preference_sensitive => '민감 콘텐츠 기본 표시/숨김';

  @override
  String get desc_visibility_public => '모든 사용자가 글 보기 가능';

  @override
  String get desc_visibility_unlisted => '공개지만 타임라인에 표시되지 않음';

  @override
  String get desc_visibility_private => '팔로워 및 멘션된 사용자만';

  @override
  String get desc_visibility_direct => '멘션된 사용자만';

  @override
  String get desc_preference_refresh_interval => '앱 데이터 갱신 간격';

  @override
  String get desc_preference_loaded_top => '아이콘을 탭하면 최신 데이터를 불러오고 맨 위로 이동합니다';

  @override
  String get desc_preference_locale => '시스템 로케일 사용';

  @override
  String get desc_profile_bot => '자동으로 동작하는 계정, 인간의 감시는 없음';

  @override
  String get desc_profile_locked => '팔로우 요청 수동 승인';

  @override
  String get desc_profile_discoverable => '프로필 디렉터리에서 검색 가능';

  @override
  String get desc_profile_post_indexable => '공개 글 검색 가능';

  @override
  String get desc_profile_hide_collections => '프로필에서 팔로워 및 팔로잉 표시';

  @override
  String get desc_preference_reply_all => '멘션된 모든 사용자 태그';

  @override
  String get desc_preference_reply_only => '작성자만 태그';

  @override
  String get desc_preference_reply_none => '태그 없음';

  @override
  String get desc_create_list => '새 리스트 만들기';

  @override
  String get desc_list_search_following => '리스트에 추가할 팔로잉 계정 검색';

  @override
  String get desc_report_spam => '이 계정은 원치 않는 광고를 게시하고 있습니다';

  @override
  String get desc_report_legal => '이 계정은 불법 콘텐츠를 게시하거나 불법 행위를 요청하고 있습니다';

  @override
  String get desc_report_violation => '이 계정은 인스턴스 규칙을 위반하는 콘텐츠를 게시하고 있습니다';

  @override
  String get desc_report_other => '기타 나열되지 않은 이유';

  @override
  String get desc_report_comment => '신고에 대한 추가 설명을 위해 선택적으로 댓글을 추가하세요.';

  @override
  String err_invalid_instance(Object domain) {
    return '유효하지 않은 Mastodon 서버: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache => '캐시 삭제 완료';

  @override
  String get msg_preference_engineer_reset => '리셋 완료';

  @override
  String get msg_copied_to_clipboard => '클립보드에 복사됨';

  @override
  String get msg_notification_title => '새 알림';

  @override
  String msg_notification_body(Object count) {
    return '$count개의 읽지 않은 알림이 있습니다';
  }

  @override
  String msg_follow_request(Object name) {
    return '$name로부터 팔로우 요청';
  }

  @override
  String get dots => '...';
}
