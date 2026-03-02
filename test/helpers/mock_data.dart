// Mock data factories for widget tests.
import 'package:glacial/features/models.dart';

/// Factory for creating mock AccountSchema instances.
class MockAccount {
  static AccountSchema create({
    String id = '123',
    String username = 'testuser',
    String? acct,
    String displayName = 'Test User',
    String note = 'This is a test account.',
    String avatar = 'https://example.com/avatar.png',
    String header = 'https://example.com/header.png',
    bool locked = false,
    bool bot = false,
    int statusesCount = 100,
    int followersCount = 50,
    int followingCount = 25,
    DateTime? createdAt,
  }) {
    return AccountSchema(
      id: id,
      username: username,
      acct: acct ?? username,
      url: 'https://example.com/@$username',
      displayName: displayName,
      note: note,
      avatar: avatar,
      avatarStatic: avatar,
      header: header,
      locked: locked,
      bot: bot,
      indexable: true,
      createdAt: createdAt ?? DateTime(2023, 1, 1),
      statusesCount: statusesCount,
      followersCount: followersCount,
      followingCount: followingCount,
    );
  }
}

/// Factory for creating mock StatusSchema instances.
class MockStatus {
  static StatusSchema create({
    String id = '456',
    String content = '<p>This is a test status.</p>',
    VisibilityType visibility = VisibilityType.public,
    bool sensitive = false,
    String spoiler = '',
    AccountSchema? account,
    String uri = 'https://example.com/statuses/456',
    int reblogsCount = 5,
    int favouritesCount = 10,
    int repliesCount = 2,
    bool? favourited,
    bool? reblogged,
    bool? bookmarked,
    bool? pinned,
    bool? muted,
    DateTime? createdAt,
    DateTime? editedAt,
    DateTime? scheduledAt,
    StatusSchema? reblog,
    String? inReplyToID,
    String? inReplyToAccountID,
    List<TagSchema> tags = const [],
    List<MentionSchema> mentions = const [],
    List<AttachmentSchema> attachments = const [],
    PollSchema? poll,
    PreviewCardSchema? card,
    String? language,
  }) {
    return StatusSchema(
      id: id,
      content: content,
      visibility: visibility,
      sensitive: sensitive,
      spoiler: spoiler,
      account: account ?? MockAccount.create(),
      uri: uri,
      reblogsCount: reblogsCount,
      favouritesCount: favouritesCount,
      repliesCount: repliesCount,
      favourited: favourited,
      reblogged: reblogged,
      bookmarked: bookmarked,
      pinned: pinned,
      muted: muted,
      createdAt: createdAt ?? DateTime.now(),
      editedAt: editedAt,
      scheduledAt: scheduledAt,
      reblog: reblog,
      inReplyToID: inReplyToID,
      inReplyToAccountID: inReplyToAccountID,
      mentions: mentions,
      tags: tags,
      attachments: attachments,
      poll: poll,
      card: card,
      language: language,
    );
  }

  /// Creates a reblog status.
  static StatusSchema createReblog({
    String id = '789',
    AccountSchema? reblogger,
    StatusSchema? originalStatus,
  }) {
    return create(
      id: id,
      account: reblogger ?? MockAccount.create(id: '999', username: 'reblogger'),
      reblog: originalStatus ?? create(),
    );
  }

  /// Creates a reply status.
  static StatusSchema createReply({
    String id = '789',
    String inReplyToID = '456',
    String inReplyToAccountID = '123',
    AccountSchema? account,
  }) {
    return create(
      id: id,
      account: account ?? MockAccount.create(id: '888', username: 'replier'),
      inReplyToID: inReplyToID,
      inReplyToAccountID: inReplyToAccountID,
    );
  }

  /// Creates a sensitive status with spoiler.
  static StatusSchema createSensitive({
    String id = '789',
    String spoiler = 'Content Warning',
    bool sensitive = true,
  }) {
    return create(
      id: id,
      sensitive: sensitive,
      spoiler: spoiler,
    );
  }

  /// Creates a status with interactions.
  static StatusSchema createWithInteractions({
    String id = '789',
    int reblogsCount = 10,
    int favouritesCount = 25,
    int repliesCount = 5,
    bool favourited = true,
    bool reblogged = false,
    bool bookmarked = true,
  }) {
    return create(
      id: id,
      reblogsCount: reblogsCount,
      favouritesCount: favouritesCount,
      repliesCount: repliesCount,
      favourited: favourited,
      reblogged: reblogged,
      bookmarked: bookmarked,
    );
  }
}

/// Factory for creating mock PreviewCardSchema instances.
class MockPreviewCard {
  static PreviewCardSchema create({
    String url = 'https://example.com/article',
    String title = 'Test Article Title',
    String description = 'This is a test article description.',
    PreviewCardType type = PreviewCardType.link,
    String html = '',
    int width = 200,
    int height = 100,
    String? image = 'https://example.com/preview.png',
  }) {
    return PreviewCardSchema(
      url: url,
      title: title,
      description: description,
      type: type,
      html: html,
      width: width,
      height: height,
      image: image,
    );
  }

  /// Creates a preview card without image.
  static PreviewCardSchema createWithoutImage({
    String url = 'https://example.com/article',
    String title = 'Test Article',
    String description = 'Description without image.',
  }) {
    return create(
      url: url,
      title: title,
      description: description,
      image: null,
    );
  }
}

/// Factory for creating mock AccessStatusSchema instances.
class MockAccessStatus {
  static AccessStatusSchema create({
    String? accessToken,
    AccountSchema? account,
    ServerSchema? server,
    List<EmojiSchema> emojis = const [],
  }) {
    return AccessStatusSchema(
      accessToken: accessToken,
      account: account,
      server: server,
      emojis: emojis,
    );
  }

  /// Creates an authenticated access status.
  static AccessStatusSchema authenticated({
    AccountSchema? account,
    ServerSchema? server,
  }) {
    return create(
      accessToken: 'test_access_token',
      account: account ?? MockAccount.create(),
      server: server,
    );
  }

  /// Creates an anonymous (not signed in) access status.
  static AccessStatusSchema anonymous() {
    return create();
  }
}

/// Factory for creating mock StatusEditSchema instances.
class MockStatusEdit {
  static StatusEditSchema create({
    String content = '<p>Edited content.</p>',
    String spoiler = '',
    bool sensitive = false,
    DateTime? createdAt,
    AccountSchema? account,
    PollSchema? poll,
    List<AttachmentSchema> attachments = const [],
    List<EmojiSchema> emojis = const [],
  }) {
    return StatusEditSchema(
      content: content,
      spoiler: spoiler,
      sensitive: sensitive,
      createdAt: createdAt ?? DateTime(2023, 1, 1, 12, 0),
      account: account ?? MockAccount.create(),
      poll: poll,
      attachments: attachments,
      emojis: emojis,
    );
  }

  /// Creates a list of edits representing a status history.
  static List<StatusEditSchema> createHistory({
    int count = 3,
    AccountSchema? account,
  }) {
    final acc = account ?? MockAccount.create();
    return List.generate(count, (index) {
      return create(
        content: '<p>Edit version ${index + 1}.</p>',
        createdAt: DateTime(2023, 1, 1, 12 + index, 0),
        account: acc,
      );
    });
  }
}

/// Factory for creating mock PollOptionSchema instances.
class MockPollOption {
  static PollOptionSchema create({
    String title = 'Option',
    int? votesCount,
  }) {
    return PollOptionSchema(
      title: title,
      votesCount: votesCount,
    );
  }
}

/// Factory for creating mock PollSchema instances.
class MockPoll {
  static PollSchema create({
    String id = 'poll-123',
    DateTime? expiresAt,
    bool expired = false,
    bool multiple = false,
    int votesCount = 0,
    int? votersCount,
    List<PollOptionSchema>? options,
    bool? voted,
    List<int>? ownVotes,
  }) {
    return PollSchema(
      id: id,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 1)),
      expired: expired,
      multiple: multiple,
      votesCount: votesCount,
      votersCount: votersCount,
      options: options ?? [
        MockPollOption.create(title: 'Option A'),
        MockPollOption.create(title: 'Option B'),
      ],
      voted: voted,
      ownVotes: ownVotes,
    );
  }

  /// Creates an active poll that can be voted on.
  static PollSchema createActive({
    bool multiple = false,
    List<PollOptionSchema>? options,
  }) {
    return create(
      expired: false,
      voted: false,
      multiple: multiple,
      options: options,
    );
  }

  /// Creates an expired poll.
  static PollSchema createExpired({
    int votesCount = 10,
    List<PollOptionSchema>? options,
  }) {
    return create(
      expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      expired: true,
      voted: true,
      votesCount: votesCount,
      options: options ?? [
        MockPollOption.create(title: 'Option A', votesCount: 6),
        MockPollOption.create(title: 'Option B', votesCount: 4),
      ],
    );
  }

  /// Creates a poll that has been voted on.
  static PollSchema createVoted({
    List<int> ownVotes = const [0],
    int votesCount = 5,
  }) {
    return create(
      voted: true,
      ownVotes: ownVotes,
      votesCount: votesCount,
      options: [
        MockPollOption.create(title: 'Option A', votesCount: 3),
        MockPollOption.create(title: 'Option B', votesCount: 2),
      ],
    );
  }

  /// Creates a multiple-choice poll.
  static PollSchema createMultiple({
    List<PollOptionSchema>? options,
  }) {
    return create(
      multiple: true,
      voted: false,
      options: options ?? [
        MockPollOption.create(title: 'Choice 1'),
        MockPollOption.create(title: 'Choice 2'),
        MockPollOption.create(title: 'Choice 3'),
      ],
    );
  }
}

/// Factory for creating mock ServerConfigSchema instances.
class MockServerConfig {
  static ServerConfigSchema create({
    bool translationEnabled = false,
    StatusConfigSchema? statuses,
    PollConfigSchema? polls,
  }) {
    return ServerConfigSchema(
      translationEnabled: translationEnabled,
      statuses: statuses ?? const StatusConfigSchema(
        charReserved: 23,
        maxCharacters: 500,
        maxAttachments: 4,
      ),
      polls: polls ?? const PollConfigSchema(
        maxOptions: 4,
        maxCharacters: 50,
        minExpiresIn: 300,
        maxExpiresIn: 2592000,
      ),
    );
  }
}

/// Factory for creating mock ServerSchema instances.
class MockServer {
  static ServerSchema create({
    String domain = 'example.com',
    String title = 'Test Server',
    String desc = 'A test Mastodon server.',
    String version = '4.2.0',
    String thumbnail = 'https://example.com/thumbnail.png',
    bool translationEnabled = false,
    List<String> languages = const ['en'],
  }) {
    return ServerSchema(
      domain: domain,
      title: title,
      desc: desc,
      version: version,
      thumbnail: thumbnail,
      usage: const ServerUsageSchema(userActiveMonthly: 1000),
      config: MockServerConfig.create(translationEnabled: translationEnabled),
      registration: const RegisterConfigSchema(
        enabled: true,
        approvalRequired: false,
      ),
      contact: ContactSchema(email: 'admin@$domain'),
      languages: languages,
    );
  }

  /// Creates a server with translation enabled.
  static ServerSchema withTranslation({
    String domain = 'example.com',
  }) {
    return create(
      domain: domain,
      translationEnabled: true,
    );
  }
}

/// Factory for creating mock LinkSchema instances.
class MockLink {
  static LinkSchema create({
    String url = 'https://example.com/article',
    String title = 'Test Article Title',
    String desc = 'Test description text',
    String type = 'link',
    String authName = 'Test Author',
    String authUrl = 'https://example.com/author',
    String providerName = 'Example',
    String providerUrl = 'https://example.com',
    String html = '',
    int width = 400,
    int height = 300,
    String image = 'https://example.com/image.jpg',
    String embedUrl = '',
    List<HistorySchema>? history,
  }) {
    return LinkSchema(
      url: url,
      title: title,
      desc: desc,
      type: type,
      authName: authName,
      authUrl: authUrl,
      providerName: providerName,
      providerUrl: providerUrl,
      html: html,
      width: width,
      height: height,
      image: image,
      embedUrl: embedUrl,
      history: history ?? [],
    );
  }

  /// Creates a link with empty author (no author URL).
  static LinkSchema withoutAuthor({
    String title = 'Test Article',
    String desc = 'Test description',
  }) {
    return create(
      title: title,
      desc: desc,
      authName: '',
      authUrl: '',
    );
  }
}

/// Factory for creating mock TagSchema instances.
class MockTag {
  static TagSchema create({
    String name = 'testtag',
    String? url,
  }) {
    return TagSchema(
      name: name,
      url: url ?? 'https://example.com/tags/$name',
    );
  }
}

/// Factory for creating mock HistorySchema instances.
class MockHistory {
  static HistorySchema create({
    String day = '1',
    String accounts = '10',
    String uses = '25',
  }) {
    return HistorySchema(
      day: day,
      accounts: accounts,
      uses: uses,
    );
  }

  /// Creates a list of history entries for testing.
  static List<HistorySchema> createList({int count = 7}) {
    return List.generate(count, (index) {
      return create(
        day: '${index + 1}',
        accounts: '${(index + 1) * 5}',
        uses: '${(index + 1) * 10}',
      );
    });
  }
}

/// Factory for creating mock HashtagSchema instances.
class MockHashtag {
  static HashtagSchema create({
    String name = 'testhashtag',
    String? url,
    List<HistorySchema>? history,
    bool? following,
    bool? featuring,
  }) {
    return HashtagSchema(
      name: name,
      url: url ?? 'https://example.com/tags/$name',
      history: history ?? MockHistory.createList(),
      following: following,
      featuring: featuring,
    );
  }
}

/// Factory for creating mock ConversationSchema instances.
class MockConversation {
  static ConversationSchema create({
    String id = 'conv-1',
    List<AccountSchema>? accounts,
    StatusSchema? lastStatus,
    bool unread = false,
  }) {
    return ConversationSchema(
      id: id,
      accounts: accounts ?? [MockAccount.create()],
      lastStatus: lastStatus,
      unread: unread,
    );
  }

  /// Creates a conversation with unread messages.
  static ConversationSchema createUnread({
    String id = 'conv-unread',
    List<AccountSchema>? accounts,
    StatusSchema? lastStatus,
  }) {
    return create(
      id: id,
      accounts: accounts,
      lastStatus: lastStatus ?? MockStatus.create(
        content: '<p>Unread message</p>',
        visibility: VisibilityType.direct,
      ),
      unread: true,
    );
  }

  /// Creates a conversation with multiple participants.
  static ConversationSchema createGroup({
    String id = 'conv-group',
    int participantCount = 3,
    bool unread = false,
  }) {
    final List<AccountSchema> accounts = List.generate(
      participantCount,
      (i) => MockAccount.create(
        id: '${100 + i}',
        username: 'user$i',
        displayName: 'User $i',
      ),
    );

    return create(
      id: id,
      accounts: accounts,
      lastStatus: MockStatus.create(
        content: '<p>Group message</p>',
        visibility: VisibilityType.direct,
      ),
      unread: unread,
    );
  }
}

/// Factory for creating mock AttachmentSchema instances.
class MockAttachment {
  static AttachmentSchema create({
    String id = 'att-1',
    MediaType type = MediaType.image,
    String url = 'https://example.com/media/image.png',
    String? previewUrl = 'https://example.com/media/preview.png',
    String? remoteUrl,
    String? description = 'A test image',
    String? blurhash = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
  }) {
    return AttachmentSchema(
      id: id,
      type: type,
      url: url,
      previewUrl: previewUrl,
      remoteUrl: remoteUrl,
      description: description,
      blurhash: blurhash,
    );
  }
}

/// Factory for creating mock EmojiSchema instances.
class MockEmoji {
  static EmojiSchema create({
    String shortcode = 'blobcat',
    String url = 'https://example.com/emoji/blobcat.png',
    String? staticUrl,
    bool visible = true,
    String? category,
  }) {
    return EmojiSchema(
      shortcode: shortcode,
      url: url,
      staticUrl: staticUrl ?? url,
      visible: visible,
      category: category,
    );
  }
}

/// Factory for creating mock MentionSchema instances.
class MockMention {
  static MentionSchema create({
    String id = 'mention-1',
    String username = 'mentioned',
    String? url,
    String? acct,
  }) {
    return MentionSchema(
      id: id,
      username: username,
      url: url ?? 'https://example.com/@$username',
      acct: acct ?? username,
    );
  }
}

/// Factory for creating mock OAuth2Info instances.
class MockOAuth2Info {
  static OAuth2Info create({
    String id = 'oauth-123',
    String name = 'Glacial',
    String? website = 'https://glacial.app',
    List<String> scopes = const ['read', 'write', 'follow', 'push'],
    String clientId = 'client_id_abc',
    String clientSecret = 'client_secret_xyz',
    String redirectUri = 'glacial://auth',
    List<String>? redirectUris,
  }) {
    return OAuth2Info(
      id: id,
      name: name,
      website: website,
      scopes: scopes,
      clientId: clientId,
      clientSecret: clientSecret,
      redirectUri: redirectUri,
      redirectUris: redirectUris ?? [redirectUri],
    );
  }
}

/// Factory for creating mock AnnouncementSchema instances.
class MockAnnouncement {
  static AnnouncementSchema create({
    String id = 'ann-1',
    String content = '<p>Server maintenance tonight.</p>',
    String? startsAt,
    String? endsAt,
    bool allDay = false,
    String publishedAt = '2024-01-15T10:00:00.000Z',
    String? updatedAt,
    bool read = false,
    List<ReactionSchema>? reactions,
  }) {
    return AnnouncementSchema(
      id: id,
      content: content,
      startsAt: startsAt,
      endsAt: endsAt,
      allDay: allDay,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
      read: read,
      reactions: reactions ?? [],
    );
  }
}

/// Factory for creating mock ReactionSchema instances.
class MockReaction {
  static ReactionSchema create({
    String name = '👍',
    int count = 1,
    bool me = false,
    String? url,
    String? staticUrl,
  }) {
    return ReactionSchema(
      name: name,
      count: count,
      me: me,
      url: url,
      staticUrl: staticUrl,
    );
  }
}

/// Factory for creating mock ListSchema instances.
class MockListSchema {
  static ListSchema create({
    String id = 'list-1',
    String title = 'My List',
    ReplyPolicyType replyPolicy = ReplyPolicyType.list,
    bool exclusive = false,
  }) {
    return ListSchema(
      id: id,
      title: title,
      replyPolicy: replyPolicy,
      exclusive: exclusive,
    );
  }
}

/// Factory for creating mock NotificationPolicySchema instances.
class MockNotificationPolicy {
  static NotificationPolicySchema create({
    NotificationPolicyValue forNotFollowing = NotificationPolicyValue.accept,
    NotificationPolicyValue forNotFollowers = NotificationPolicyValue.accept,
    NotificationPolicyValue forNewAccounts = NotificationPolicyValue.filter,
    NotificationPolicyValue forPrivateMentions = NotificationPolicyValue.drop,
    NotificationPolicyValue forLimitedAccounts = NotificationPolicyValue.accept,
    int pendingRequestsCount = 0,
    int pendingNotificationsCount = 0,
  }) {
    return NotificationPolicySchema(
      forNotFollowing: forNotFollowing,
      forNotFollowers: forNotFollowers,
      forNewAccounts: forNewAccounts,
      forPrivateMentions: forPrivateMentions,
      forLimitedAccounts: forLimitedAccounts,
      pendingRequestsCount: pendingRequestsCount,
      pendingNotificationsCount: pendingNotificationsCount,
    );
  }
}

/// Factory for creating mock RelationshipSchema instances.
class MockRelationship {
  static RelationshipSchema create({
    String id = '123',
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
    List<String> languages = const [],
  }) {
    return RelationshipSchema(
      id: id,
      following: following,
      followedBy: followedBy,
      blocking: blocking,
      blockedBy: blockedBy,
      muting: muting,
      mutingNotifications: mutingNotifications,
      requested: requested,
      requestedBy: requestedBy,
      domainBlocking: domainBlocking,
      endorsed: endorsed,
      note: note,
      showingReblogs: showingReblogs,
      notifying: notifying,
      languages: languages,
    );
  }

  /// Creates a mutual-follow relationship.
  static RelationshipSchema mutual() {
    return create(following: true, followedBy: true);
  }

  /// Creates a stranger (no relationship).
  static RelationshipSchema stranger() {
    return create();
  }
}

/// Factory for creating mock RoleSchema instances.
class MockRole {
  static RoleSchema create({
    String id = 'role-1',
    String name = 'Admin',
    String color = '#ff0000',
    String permissions = '1',
    bool highlighted = true,
  }) {
    return RoleSchema(
      id: id,
      name: name,
      color: color,
      permissions: permissions,
      highlighted: highlighted,
    );
  }
}

/// Factory for creating mock ReportSchema instances.
class MockReport {
  static ReportSchema create({
    String id = 'report-1',
    bool actionTaken = false,
    DateTime? actionTakenAt,
    ReportCategoryType category = ReportCategoryType.spam,
    String comment = 'Spamming',
    bool forwarded = false,
    DateTime? createdAt,
    List<String>? statusIDs,
    List<String>? ruleIDs,
    AccountSchema? targetAccount,
  }) {
    return ReportSchema(
      id: id,
      actionTaken: actionTaken,
      actionTakenAt: actionTakenAt,
      category: category,
      comment: comment,
      forwarded: forwarded,
      createdAt: createdAt ?? DateTime(2024, 1, 1),
      statusIDs: statusIDs,
      ruleIDs: ruleIDs,
      targetAccount: targetAccount ?? MockAccount.create(),
    );
  }
}

/// Factory for creating mock TranslationSchema instances.
class MockTranslation {
  static TranslationSchema create({
    String content = '<p>Translated content</p>',
    String spoilerText = '',
    String language = 'en',
    String detectedSourceLanguage = 'ja',
    String provider = 'DeepL',
  }) {
    return TranslationSchema(
      content: content,
      spoilerText: spoilerText,
      language: language,
      detectedSourceLanguage: detectedSourceLanguage,
      provider: provider,
    );
  }
}

/// Factory for creating mock FeaturedTagSchema instances.
class MockFeaturedTag {
  static FeaturedTagSchema create({
    String id = 'ft-1',
    String name = 'flutter',
    String? url,
    int statusesCount = 10,
    String? lastStatusAt = '2024-06-15',
  }) {
    return FeaturedTagSchema(
      id: id,
      name: name,
      url: url ?? 'https://example.com/tags/$name',
      statusesCount: statusesCount,
      lastStatusAt: lastStatusAt,
    );
  }
}

/// Factory for creating mock SuggestionSchema instances.
class MockSuggestion {
  static SuggestionSchema create({
    SuggestionSourceType source = SuggestionSourceType.staff,
    List<String>? sources,
    AccountSchema? account,
  }) {
    return SuggestionSchema(
      source: source,
      sources: sources ?? [source.name],
      account: account ?? MockAccount.create(),
    );
  }
}

/// Factory for creating mock AdminAccountSchema instances.
class MockAdminAccount {
  static AdminAccountSchema create({
    String id = 'admin-acc-1',
    String username = 'testuser',
    String? domain,
    DateTime? createdAt,
    String email = 'test@example.com',
    String? ip = '192.168.1.1',
    String? locale = 'en',
    String? inviteRequest,
    RoleSchema? role,
    bool confirmed = true,
    bool approved = true,
    bool disabled = false,
    bool silenced = false,
    bool suspended = false,
    AccountSchema? account,
    List<AdminIpSchema> ips = const [],
  }) {
    return AdminAccountSchema(
      id: id,
      username: username,
      domain: domain,
      createdAt: createdAt ?? DateTime(2024, 1, 1),
      email: email,
      ip: ip,
      locale: locale,
      inviteRequest: inviteRequest,
      role: role,
      confirmed: confirmed,
      approved: approved,
      disabled: disabled,
      silenced: silenced,
      suspended: suspended,
      account: account ?? MockAccount.create(username: username),
      ips: ips,
    );
  }

  /// Creates a pending admin account.
  static AdminAccountSchema pending({String id = 'admin-pending'}) {
    return create(id: id, approved: false, confirmed: false);
  }

  /// Creates a suspended admin account.
  static AdminAccountSchema createSuspended({String id = 'admin-suspended'}) {
    return create(id: id, suspended: true);
  }

  /// Creates a silenced admin account.
  static AdminAccountSchema createSilenced({String id = 'admin-silenced'}) {
    return create(id: id, silenced: true);
  }

  /// Creates a disabled admin account.
  static AdminAccountSchema createDisabled({String id = 'admin-disabled'}) {
    return create(id: id, disabled: true);
  }

  /// Creates a remote admin account.
  static AdminAccountSchema remote({String id = 'admin-remote', String domain = 'remote.social'}) {
    return create(id: id, domain: domain, username: 'remoteuser');
  }
}

/// Factory for creating mock AdminReportSchema instances.
class MockAdminReport {
  static AdminReportSchema create({
    String id = 'report-1',
    bool actionTaken = false,
    DateTime? actionTakenAt,
    ReportCategoryType category = ReportCategoryType.spam,
    String comment = 'This is spam content',
    bool forwarded = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    AccountSchema? account,
    AccountSchema? targetAccount,
    AccountSchema? assignedAccount,
    AccountSchema? actionTakenByAccount,
    List<StatusSchema> statuses = const [],
    List<RuleSchema> rules = const [],
  }) {
    return AdminReportSchema(
      id: id,
      actionTaken: actionTaken,
      actionTakenAt: actionTakenAt,
      category: category,
      comment: comment,
      forwarded: forwarded,
      createdAt: createdAt ?? DateTime(2024, 1, 15),
      updatedAt: updatedAt,
      account: account ?? MockAccount.create(id: 'reporter', username: 'reporter'),
      targetAccount: targetAccount ?? MockAccount.create(id: 'target', username: 'spammer'),
      assignedAccount: assignedAccount,
      actionTakenByAccount: actionTakenByAccount,
      statuses: statuses,
      rules: rules,
    );
  }

  /// Creates a resolved report.
  static AdminReportSchema resolved({String id = 'report-resolved'}) {
    return create(
      id: id,
      actionTaken: true,
      actionTakenAt: DateTime(2024, 1, 16),
      actionTakenByAccount: MockAccount.create(id: 'mod', username: 'moderator'),
    );
  }

  /// Creates a report assigned to a moderator.
  static AdminReportSchema assigned({String id = 'report-assigned'}) {
    return create(
      id: id,
      assignedAccount: MockAccount.create(id: 'mod', username: 'moderator'),
    );
  }

  /// Creates a report with attached statuses and rules.
  static AdminReportSchema withDetails({String id = 'report-detail'}) {
    return create(
      id: id,
      category: ReportCategoryType.violation,
      comment: 'Violating community guidelines',
      statuses: [MockStatus.create()],
      rules: const [
        RuleSchema(id: 'rule-1', text: 'Be respectful', hint: 'Treat others with dignity'),
      ],
    );
  }
}

/// Factory for creating mock SearchResultSchema instances.
class MockSearchResult {
  static SearchResultSchema create({
    List<AccountSchema>? accounts,
    List<StatusSchema>? statuses,
    List<HashtagSchema>? hashtags,
  }) {
    return SearchResultSchema(
      accounts: accounts ?? [],
      statuses: statuses ?? [],
      hashtags: hashtags ?? [],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
