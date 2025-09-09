// Represents a user-defined filter for determining which statuses should not be shown to the user.
import 'package:flutter/material.dart';

enum FilterContext {
  home,         // The home timeline.
  notifications,// The notifications timeline.
  public,       // The public timeline.
  thread,       // A status and its replies.
  account;      // A profile page.

  factory FilterContext.fromString(String str) {
    return FilterContext.values.firstWhere((c) => c.name == str);
  }

  String title(BuildContext context) {
    switch (this) {
      case FilterContext.home:
        return "Home timeline";
      case FilterContext.notifications:
        return "Notifications timeline";
      case FilterContext.public:
        return "Public timeline";
      case FilterContext.thread:
        return "A status and its replies";
      case FilterContext.account:
        return "A profile page";
    }
  }

  String tooltip(BuildContext context) {
    switch (this) {
      case FilterContext.home:
        return "The home timeline";
      case FilterContext.notifications:
        return "The notifications timeline";
      case FilterContext.public:
        return "The public timeline";
      case FilterContext.thread:
        return "A status and its replies";
      case FilterContext.account:
        return "A profile page";
    }
  }
}

enum FilterAction {
  warn,   // show a warning that identifies the matching filter by title.
  hide,   // do not show this status if it is received.
  blur;   // hide/blur media attachments with a warning identifying the matching filter by title

  factory FilterAction.fromString(String str) {
    return FilterAction.values.firstWhere((a) => a.name == str);
  }

  IconData get icon {
    switch (this) {
      case FilterAction.warn:
        return Icons.warning_amber_outlined;
      case FilterAction.hide:
        return Icons.block_outlined;
      case FilterAction.blur:
        return Icons.blur_on_outlined;
    }
  }

  String title(BuildContext context) {
    switch (this) {
      case FilterAction.warn:
        return "Warn";
      case FilterAction.hide:
        return "Hide";
      case FilterAction.blur:
        return "Blur";
    }
  }

  String desc(BuildContext context) {
    switch (this) {
      case FilterAction.warn:
        return "Show a warning that identifies the matching filter by title.";
      case FilterAction.hide:
        return "Do not show this status if it is received.";
      case FilterAction.blur:
        return "Hide/blur media attachments with a warning identifying the matching filter by title.";
    }
  }
}

// Represents a keyword that, if matched, should cause the filter action to be taken.
class FilterKeywordSchema {
  final String id;          // The ID of the FilterKeyword in the database.
  final String keyword;     // The phrase to be matched against.
  final bool wholeWord;     //  Should the filter consider word boundaries?

  const FilterKeywordSchema({
    required this.id,
    required this.keyword,
    required this.wholeWord,
  });

  factory FilterKeywordSchema.fromJson(Map<String, dynamic> json) {
    return FilterKeywordSchema(
      id: json['id'],
      keyword: json['keyword'],
      wholeWord: json['whole_word'],
    );
  }
}

// Represents a status ID that, if matched, should cause the filter action to be taken.
class FilterStatusSchema {
  final String id;          // The ID of the FilterStatus in the database.
  final String statusId;    // The ID of the status to be filtered.

  const FilterStatusSchema({
    required this.id,
    required this.statusId,
  });

  factory FilterStatusSchema.fromJson(Map<String, dynamic> json) {
    return FilterStatusSchema(
      id: json['id'],
      statusId: json['status_id'],
    );
  }
}

class FiltersSchema {
  final String id;                           // The ID of the Filter in the database.
  final String title;                        // A title given by the user to name the filter.
  final List<FilterContext> context;         // The contexts in which the filter is applied.
  final DateTime? expiresAt;                  // When the filter should no longer be applied.
  final FilterAction action;                 // The action to be taken when a status matches this filter.
  final List<FilterKeywordSchema>? keywords; // The keywords grouped under this filter. Omitted when part of a FilterResult.
  final List<FilterStatusSchema>? statuses;  // The statuses grouped under this filter. Omitted when part of a FilterResult.

  const FiltersSchema({
    required this.id,
    required this.title,
    required this.context,
    this.expiresAt,
    required this.action,
    this.keywords,
    this.statuses,
  });

  factory FiltersSchema.fromJson(Map<String, dynamic> json) {
    return FiltersSchema(
      id: json['id'],
      title: json['title'],
      context: (json['context'] as List<dynamic>).map((e) => FilterContext.fromString(e as String)).toList(),
      expiresAt: json['expires_at'] == null ? null : DateTime.parse(json['expires_at']),
      action: FilterAction.fromString(json['filter_action']),
      keywords: json['keywords']?.map((e) => FilterKeywordSchema.fromJson(e)).toList().cast<FilterKeywordSchema>(),
      statuses: json['statuses']?.map((e) => FilterStatusSchema.fromJson(e)).toList().cast<FilterStatusSchema>(),
    );
  }
}

// A keyword to be added to the newly-created filter group.
class FilterKeywordFormSchema {
  final String keyword;   // The phrase to be matched against.
  final bool wholeWord;   // Should the filter consider word boundaries?

  const FilterKeywordFormSchema({
    required this.keyword,
    required this.wholeWord,
  });

  factory FilterKeywordFormSchema.empty() {
    return FilterKeywordFormSchema(
      keyword: '',
      wholeWord: false,
    );
  }

  FilterKeywordFormSchema copyWith({
    String? keyword,
    bool? wholeWord,
  }) {
    return FilterKeywordFormSchema(
      keyword: keyword ?? this.keyword,
      wholeWord: wholeWord ?? this.wholeWord,
    );
  }

  IconData get icon {
    return wholeWord ? Icons.check_box_outlined : Icons.check_box_outline_blank;
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'whole_word': wholeWord,
    };
  }
}

// The data schema for the new filter form.
class FilterFormSchema {
  final String title;                            // The name of the filter group.
  final List<FilterContext> context;             // Where the filter should be applied.
  final FilterAction action;                     // The policy to be applied when the filter is matched.
  final int? expiresIn;                          // How many seconds from now should the filter expire?
  final List<FilterKeywordFormSchema> keywords;  // The keywords to be added to the filter.

  const FilterFormSchema({
    required this.title,
    required this.context,
    required this.action,
    this.expiresIn,
    this.keywords = const [],
  });

  factory FilterFormSchema.fromTitle(String title) {
    return FilterFormSchema(
      title: title,
      context: [],
      action: FilterAction.hide,
      keywords: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'context': context.map((c) => c.name).toList(),
      'action': action.name,
      if (expiresIn != null) 'expires_in': expiresIn,
      'keywords_attributes': keywords.map((k) => k.toJson()).toList(),
    };
  }

  FilterFormSchema copyWith({
    String? title,
    List<FilterContext>? context,
    FilterAction? action,
    int? expiresIn,
    List<FilterKeywordFormSchema>? keywords,
  }) {
    return FilterFormSchema(
      title: title ?? this.title,
      context: context ?? this.context,
      action: action ?? this.action,
      expiresIn: expiresIn == 0 ? null : (expiresIn ?? this.expiresIn),
      keywords: keywords ?? this.keywords,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
