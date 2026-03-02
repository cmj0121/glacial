// Tests for RoutePath enum and path values.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/core.dart';

void main() {
  group('RoutePath.path', () {
    test('landing returns /', () {
      expect(RoutePath.landing.path, '/');
    });

    test('explorer returns /explorer', () {
      expect(RoutePath.explorer.path, '/explorer');
    });

    test('timeline returns /home/timeline', () {
      expect(RoutePath.timeline.path, '/home/timeline');
    });

    test('all paths start with /', () {
      for (final route in RoutePath.values) {
        expect(route.path, startsWith('/'), reason: '${route.name} path should start with /');
      }
    });

    test('home sub-routes contain /home/', () {
      final homeRoutes = [
        RoutePath.timeline, RoutePath.list, RoutePath.listItem,
        RoutePath.trends, RoutePath.notifications, RoutePath.conversations,
        RoutePath.admin, RoutePath.search, RoutePath.hashtag,
        RoutePath.profile, RoutePath.editProfile, RoutePath.status,
        RoutePath.post, RoutePath.edit, RoutePath.directory,
        RoutePath.adminReport, RoutePath.adminAccount, RoutePath.register,
      ];
      for (final route in homeRoutes) {
        expect(route.path, contains('/home/'), reason: '${route.name} should be under /home/');
      }
    });

    test('all paths are unique', () {
      final paths = RoutePath.values.map((r) => r.path).toList();
      expect(paths.toSet().length, paths.length, reason: 'All paths must be unique');
    });

    test('specific path values', () {
      expect(RoutePath.webview.path, '/webview');
      expect(RoutePath.preference.path, '/preference');
      expect(RoutePath.media.path, '/media');
      expect(RoutePath.wip.path, '/wip');
      expect(RoutePath.followRequests.path, '/follow_requests');
      expect(RoutePath.list.path, '/home/list');
      expect(RoutePath.listItem.path, '/home/list/item');
      expect(RoutePath.notifications.path, '/home/notifications');
      expect(RoutePath.conversations.path, '/home/conversations');
      expect(RoutePath.admin.path, '/home/admin');
      expect(RoutePath.adminReport.path, '/home/admin/report');
      expect(RoutePath.adminAccount.path, '/home/admin/account');
      expect(RoutePath.post.path, '/home/post');
      expect(RoutePath.postQuote.path, '/home/post/quote');
      expect(RoutePath.postDraft.path, '/home/post/draft');
      expect(RoutePath.postShared.path, '/home/post/shared');
      expect(RoutePath.createFilterForm.path, '/home/filter/form');
      expect(RoutePath.editFilterForm.path, '/home/filter/form/edit');
      expect(RoutePath.status.path, '/home/status');
      expect(RoutePath.statusInfo.path, '/home/status/info');
      expect(RoutePath.statusHistory.path, '/home/status/history');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
