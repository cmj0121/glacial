import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  // JSON helpers
  Map<String, dynamic> relationshipJson({
    String id = '1',
    bool following = false,
    bool followedBy = false,
    bool blocking = false,
    bool blockedBy = false,
    bool muting = false,
    bool mutingNotifications = false,
    bool requested = false,
    bool requestedBy = false,
    bool domainBlocking = false,
    bool endorsed = false,
    String note = '',
    bool showingReblogs = true,
    bool notifying = false,
    List<String>? languages,
  }) => {
    'id': id,
    'following': following,
    'followed_by': followedBy,
    'blocking': blocking,
    'blocked_by': blockedBy,
    'muting': muting,
    'muting_notifications': mutingNotifications,
    'requested': requested,
    'requested_by': requestedBy,
    'domain_blocking': domainBlocking,
    'endorsed': endorsed,
    'note': note,
    'showing_reblogs': showingReblogs,
    'notifying': notifying,
    if (languages != null) 'languages': languages,
  };

  Map<String, dynamic> roleJson({
    String id = 'role-1',
    String name = 'Admin',
    String color = '#ff0000',
    String permissions = '1',
    bool highlighted = true,
  }) => {
    'id': id,
    'name': name,
    'color': color,
    'permissions': permissions,
    'highlighted': highlighted,
  };

  Map<String, dynamic> accountJson({String id = '1'}) => {
    'id': id,
    'username': 'testuser',
    'acct': 'testuser',
    'url': 'https://example.com/@testuser',
    'display_name': 'Test User',
    'note': '',
    'avatar': 'https://example.com/avatar.png',
    'avatar_static': 'https://example.com/avatar.png',
    'header': 'https://example.com/header.png',
    'locked': false,
    'bot': false,
    'indexable': true,
    'created_at': '2024-01-01T00:00:00.000Z',
    'statuses_count': 10,
    'followers_count': 5,
    'following_count': 3,
  };

  group('PermissionBitmap', () {
    test('fromInt returns correct permission', () {
      expect(PermissionBitmap.fromInt(0x0001), PermissionBitmap.administrator);
      expect(PermissionBitmap.fromInt(0x0002), PermissionBitmap.devops);
      expect(PermissionBitmap.fromInt(0x0010), PermissionBitmap.reports);
      expect(PermissionBitmap.fromInt(0x80000), PermissionBitmap.deleteUserData);
    });

    test('fromInt throws on invalid bit', () {
      expect(() => PermissionBitmap.fromInt(0xFFFF0), throwsArgumentError);
    });

    test('fromString parses string bit values', () {
      expect(PermissionBitmap.fromString('1'), PermissionBitmap.administrator);
      expect(PermissionBitmap.fromString('2'), PermissionBitmap.devops);
    });

    test('all values have unique bits', () {
      final bits = PermissionBitmap.values.map((e) => e.bit).toSet();
      expect(bits.length, PermissionBitmap.values.length);
    });
  });

  group('RelationshipType', () {
    test('isMoreActions identifies action types', () {
      expect(RelationshipType.mute.isMoreActions, true);
      expect(RelationshipType.unmute.isMoreActions, true);
      expect(RelationshipType.block.isMoreActions, true);
      expect(RelationshipType.report.isMoreActions, true);
      expect(RelationshipType.following.isMoreActions, false);
      expect(RelationshipType.stranger.isMoreActions, false);
      expect(RelationshipType.unblock.isMoreActions, false);
    });

    test('isDangerous identifies dangerous types', () {
      expect(RelationshipType.mute.isDangerous, true);
      expect(RelationshipType.block.isDangerous, true);
      expect(RelationshipType.report.isDangerous, true);
      expect(RelationshipType.following.isDangerous, false);
      expect(RelationshipType.unmute.isDangerous, false);
      expect(RelationshipType.unblock.isDangerous, false);
    });
  });

  group('RoleSchema', () {
    test('fromJson parses all fields', () {
      final json = roleJson();
      final role = RoleSchema.fromJson(json);

      expect(role.id, 'role-1');
      expect(role.name, 'Admin');
      expect(role.color, '#ff0000');
      expect(role.permissions, '1');
      expect(role.highlighted, true);
    });

    test('bits parses permissions string to int', () {
      final role = RoleSchema.fromJson(roleJson(permissions: '65535'));
      expect(role.bits, 65535);
    });

    test('hasPrivilege returns true for non-zero permissions', () {
      final admin = RoleSchema.fromJson(roleJson(permissions: '1'));
      expect(admin.hasPrivilege, true);
    });

    test('hasPrivilege returns false for zero permissions', () {
      final regular = RoleSchema.fromJson(roleJson(permissions: '0'));
      expect(regular.hasPrivilege, false);
    });
  });

  group('RelationshipSchema', () {
    test('fromJson parses all fields', () {
      final json = relationshipJson(
        following: true,
        followedBy: true,
        muting: true,
        mutingNotifications: true,
        endorsed: true,
        showingReblogs: false,
        notifying: true,
        note: 'A note about this person',
        languages: ['en', 'de'],
      );
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.id, '1');
      expect(rel.following, true);
      expect(rel.followedBy, true);
      expect(rel.blocking, false);
      expect(rel.blockedBy, false);
      expect(rel.muting, true);
      expect(rel.mutingNotifications, true);
      expect(rel.requested, false);
      expect(rel.requestedBy, false);
      expect(rel.domainBlocking, false);
      expect(rel.endorsed, true);
      expect(rel.note, 'A note about this person');
      expect(rel.showingReblogs, false);
      expect(rel.notifying, true);
      expect(rel.languages, ['en', 'de']);
    });

    test('fromJson defaults languages to empty list when null', () {
      final json = relationshipJson();
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.languages, isEmpty);
    });

    test('fromString round-trip', () {
      final json = relationshipJson(following: true);
      final rel = RelationshipSchema.fromString(jsonEncode(json));

      expect(rel.id, '1');
      expect(rel.following, true);
    });

    test('type returns blockedBy when blockedBy is true', () {
      final json = relationshipJson(blockedBy: true, following: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.blockedBy);
    });

    test('type returns unblock when blocking is true', () {
      final json = relationshipJson(blocking: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.unblock);
    });

    test('type returns followRequest when requested is true', () {
      final json = relationshipJson(requested: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.followRequest);
    });

    test('type returns followEachOther when mutual', () {
      final json = relationshipJson(following: true, followedBy: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.followEachOther);
    });

    test('type returns following when only following', () {
      final json = relationshipJson(following: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.following);
    });

    test('type returns followedBy when only followed by', () {
      final json = relationshipJson(followedBy: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.followedBy);
    });

    test('type returns stranger when no relationship', () {
      final json = relationshipJson();
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.stranger);
    });

    test('type priority: blockedBy > blocking', () {
      final json = relationshipJson(blockedBy: true, blocking: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.blockedBy);
    });

    test('type priority: blocking > requested', () {
      final json = relationshipJson(blocking: true, requested: true);
      final rel = RelationshipSchema.fromJson(json);

      expect(rel.type, RelationshipType.unblock);
    });
  });

  group('FieldSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'name': 'Website',
        'value': '<a href="https://example.com">example.com</a>',
        'verified_at': '2024-01-01T00:00:00.000Z',
      };
      final field = FieldSchema.fromJson(json);

      expect(field.name, 'Website');
      expect(field.value, '<a href="https://example.com">example.com</a>');
      expect(field.verifiedAt, '2024-01-01T00:00:00.000Z');
    });

    test('fromJson handles null verified_at', () {
      final json = {'name': 'Bio', 'value': 'Hello'};
      final field = FieldSchema.fromJson(json);

      expect(field.verifiedAt, isNull);
    });

    test('toJson produces correct output', () {
      const field = FieldSchema(name: 'Website', value: 'https://example.com');
      final json = field.toJson();

      expect(json['name'], 'Website');
      expect(json['value'], 'https://example.com');
    });
  });

  group('AccountSchema', () {
    test('fromJson parses role when present', () {
      final json = accountJson();
      json['role'] = roleJson();
      final account = AccountSchema.fromJson(json);

      expect(account.role, isNotNull);
      expect(account.role!.name, 'Admin');
    });

    test('fromJson role is null by default', () {
      final json = accountJson();
      final account = AccountSchema.fromJson(json);

      expect(account.role, isNull);
    });

    test('fromJson parses fields array', () {
      final json = accountJson();
      json['fields'] = [
        {'name': 'Website', 'value': 'https://example.com'},
      ];
      final account = AccountSchema.fromJson(json);

      expect(account.fields.length, 1);
      expect(account.fields[0].name, 'Website');
    });

    test('toCredentialSchema converts correctly', () {
      final json = accountJson();
      json['discoverable'] = true;
      json['hide_collections'] = false;
      final account = AccountSchema.fromJson(json);
      final cred = account.toCredentialSchema();

      expect(cred.displayName, 'Test User');
      expect(cred.locked, false);
      expect(cred.bot, false);
      expect(cred.discoverable, true);
      expect(cred.hideCollections, false);
      expect(cred.indexable, true);
    });
  });

  group('AccountCredentialSchema', () {
    test('toJson produces correct output', () {
      const cred = AccountCredentialSchema(
        displayName: 'Test',
        note: 'Bio',
        locked: false,
        bot: false,
        discoverable: true,
        hideCollections: false,
        indexable: true,
      );
      final json = cred.toJson();

      expect(json['display_name'], 'Test');
      expect(json['note'], 'Bio');
      expect(json['locked'], false);
      expect(json['bot'], false);
      expect(json['discoverable'], true);
    });

    test('copyWith updates specified fields', () {
      const original = AccountCredentialSchema(
        displayName: 'Original',
        note: 'Bio',
        locked: false,
        bot: false,
        discoverable: true,
        hideCollections: false,
        indexable: true,
      );
      final updated = original.copyWith(
        displayName: 'Updated',
        locked: true,
      );

      expect(updated.displayName, 'Updated');
      expect(updated.locked, true);
      expect(updated.note, 'Bio');
      expect(updated.bot, false);
    });
  });

  group('AccountProfileType', () {
    test('selfProfile returns correct values', () {
      expect(AccountProfileType.profile.selfProfile, true);
      expect(AccountProfileType.post.selfProfile, true);
      expect(AccountProfileType.pin.selfProfile, true);
      expect(AccountProfileType.followers.selfProfile, true);
      expect(AccountProfileType.following.selfProfile, true);
      expect(AccountProfileType.filter.selfProfile, false);
      expect(AccountProfileType.schedule.selfProfile, false);
      expect(AccountProfileType.hashtag.selfProfile, false);
      expect(AccountProfileType.mute.selfProfile, false);
      expect(AccountProfileType.block.selfProfile, false);
    });

    test('timelineType returns correct timeline types', () {
      expect(AccountProfileType.post.timelineType, TimelineType.user);
      expect(AccountProfileType.schedule.timelineType, TimelineType.schedule);
      expect(AccountProfileType.pin.timelineType, TimelineType.pin);
      expect(AccountProfileType.hashtag.timelineType, TimelineType.hashtag);
    });

    test('timelineType throws for invalid types', () {
      expect(() => AccountProfileType.profile.timelineType, throwsArgumentError);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
