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

// vim: set ts=2 sw=2 sts=2 et:
