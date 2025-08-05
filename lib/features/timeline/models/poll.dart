// The poll data schema and its options for the Glacial app.

// The poll data schema.
class PollSchema {
  final String id;                      // The ID of the poll in the database.
  final DateTime? expiresAt;            // When the poll ends.
  final bool expired;                   // Is the poll expired?
  final bool multiple;                  // Does the poll allow multiple-choice answers?
  final int votesCount;                 // How many votes have been received.
  final int? votersCount;               // How many unique users have voted in the poll (null if not available).
  final List<PollOptionSchema> options; // The options available in the poll.
  final bool? voted;                    // When called with a user token, has the authorized user voted?
  final List<int>? ownVotes;            // The list of the user's votes in the poll, if they have voted.

  const PollSchema({
    required this.id,
    this.expiresAt,
    required this.expired,
    required this.multiple,
    required this.votesCount,
    this.votersCount,
    required this.options,
    this.voted,
    this.ownVotes,
  });

  factory PollSchema.fromJson(Map<String, dynamic> json) {
    return PollSchema(
      id: json['id'] as String,
      expiresAt: json['expires_at'] == null ? null : DateTime.parse(json['expires_at'] as String),
      expired: json['expired'] as bool,
      multiple: json['multiple'] as bool,
      votesCount: json['votes_count'] as int,
      votersCount: json['voters_count'] as int?,
      options: (json['options'] as List<dynamic>).map((e) => PollOptionSchema.fromJson(e as Map<String, dynamic>)).toList(),
      voted: json['voted'] as bool?,
      ownVotes: (json['own_votes'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }
}

// The poll option data schema.
class PollOptionSchema {
  final String title;    // The text value of the poll option.
  final int? votesCount; // The total number of received votes for this option.

  const PollOptionSchema({
    required this.title,
    this.votesCount,
  });

  factory PollOptionSchema.fromJson(Map<String, dynamic> json) {
    return PollOptionSchema(
      title: json['title'] as String,
      votesCount: json['votes_count'] as int?,
    );
  }
}

// The options of the Poll in the status for create a new poll.
class NewPollSchema {
  final bool? hideTotals;     // Hide vote counts until the poll ends? Defaults to false.
  final bool? multiple;       // Allow multiple choices? Defaults to false.
  final int expiresIn;        // The duration in seconds until the poll expires. Defaults to 86400 seconds (1 day).
  final List<String> options; // Possible answers to the poll.

  const NewPollSchema({
    this.hideTotals,
    this.multiple,
    this.expiresIn = 86400,
    this.options = const ["", ""],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'hide_totals': hideTotals,
      'multiple': multiple,
      'options': options,
      'expires_in': expiresIn,
    };

    // only return the non-null values
    return json..removeWhere((key, value) => value == null);
  }

  NewPollSchema copyWith({
    bool? hideTotals,
    bool? multiple,
    int? expiresIn,
    List<String>? options,
  }) {
    return NewPollSchema(
      hideTotals: hideTotals ?? this.hideTotals,
      multiple: multiple ?? this.multiple,
      expiresIn: expiresIn ?? this.expiresIn,
      options: options ?? this.options,
    );
  }

  bool get isValid {
    return options.where((e) => e.isNotEmpty).length >= 2;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
