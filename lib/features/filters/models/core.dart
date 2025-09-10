// Represents a user-defined filter for determining which statuses should not be shown to the user.
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

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
        return AppLocalizations.of(context)?.btn_filter_context_home ?? "Home";
      case FilterContext.notifications:
        return AppLocalizations.of(context)?.btn_filter_context_notification ?? "Notifications";
      case FilterContext.public:
        return AppLocalizations.of(context)?.btn_filter_context_public ?? "Public";
      case FilterContext.thread:
        return AppLocalizations.of(context)?.btn_filter_context_thread ?? "Thread";
      case FilterContext.account:
        return AppLocalizations.of(context)?.btn_filter_context_account ?? "Account";
    }
  }

  String tooltip(BuildContext context) {
    switch (this) {
      case FilterContext.home:
        return AppLocalizations.of(context)?.desc_filter_context_home ?? "The home timeline";
      case FilterContext.notifications:
        return AppLocalizations.of(context)?.desc_filter_context_notification ?? "The notifications timeline";
      case FilterContext.public:
        return AppLocalizations.of(context)?.desc_filter_context_public ?? "The public timeline";
      case FilterContext.thread:
        return AppLocalizations.of(context)?.desc_filter_context_thread ?? "A status and its replies";
      case FilterContext.account:
        return AppLocalizations.of(context)?.desc_filter_context_account ?? "A profile page";
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
        return AppLocalizations.of(context)?.btn_filter_warn ?? "Warn";
      case FilterAction.hide:
        return AppLocalizations.of(context)?.btn_filter_hide ?? "Hide";
      case FilterAction.blur:
        return AppLocalizations.of(context)?.btn_filter_blur ?? "Blur";
    }
  }

  String desc(BuildContext context) {
    switch (this) {
      case FilterAction.warn:
        return AppLocalizations.of(context)?.desc_filter_warn ?? "Warn";
      case FilterAction.hide:
        return AppLocalizations.of(context)?.desc_filter_hide ?? "Hide";
      case FilterAction.blur:
        return AppLocalizations.of(context)?.desc_filter_blur ?? "Blur";
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

  factory FilterStatusSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return FilterStatusSchema.fromJson(json);
  }

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

  FilterFormSchema asForm() {
    return FilterFormSchema(
      title: title,
      context: context,
      action: action,
      expiresIn: expiresAt?.difference(DateTime.now()).inSeconds,
      keywords: keywords?.map((k) => FilterKeywordFormSchema(id: k.id, keyword: k.keyword, wholeWord: k.wholeWord)).toList() ?? [],
    );
  }
}

// A keyword to be added to the newly-created filter group.
class FilterKeywordFormSchema {
  final String? id;       // Provide the ID of an existing keyword to modify it, instead of creating a new keyword.
  final String keyword;   // The phrase to be matched against.
  final bool wholeWord;   // Should the filter consider word boundaries?
  final bool destroy;     // If true, will remove the keyword with the given ID.

  const FilterKeywordFormSchema({
    this.id,
    required this.keyword,
    required this.wholeWord,
    this.destroy = false,
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
      id: id,
      keyword: keyword ?? this.keyword,
      wholeWord: wholeWord ?? this.wholeWord,
    );
  }

  FilterKeywordFormSchema destroyed() {
    return FilterKeywordFormSchema(
      id: id,
      keyword: keyword,
      wholeWord: wholeWord,
      destroy: true,
    );
  }

  IconData get icon {
    return wholeWord ? Icons.check_box_outlined : Icons.check_box_outline_blank;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'whole_word': wholeWord,
      '_destroy': destroy,
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
      'filter_action': action.name,
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

// Represents a filter whose keywords matched a given status.
class FilterResultSchema {
  final FiltersSchema filter;   // The filter that was matched.
  final List<String>? keywords; // The keyword within the filter that was matched.
  final List<String>? statuses; // The status ID within the filter that was matched.

  const FilterResultSchema({
    required this.filter,
    this.keywords,
    this.statuses,
  });

  factory FilterResultSchema.fromJson(Map<String, dynamic> json) {
    return FilterResultSchema(
      filter: FiltersSchema.fromJson(json['filter']),
      keywords: (json['keyword_matches'] as List<dynamic>?)?.map((e) => e as String).toList(),
      statuses: (json['status_matches'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
