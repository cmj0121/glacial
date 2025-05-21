// The trends records of the tags.

// The trends of the tags that are being used more frequently within the past week.
class HashTagSchema {
  final String name;
  final String url;
  final List<HistorySchema> history;

  const HashTagSchema({
    required this.name,
    required this.url,
    required this.history,
  });

  factory HashTagSchema.fromJson(Map<String, dynamic> json) {
    return HashTagSchema(
      name: json['name'] as String,
      url: json['url'] as String,
      history: (json['history'] as List<dynamic>).map((e) => HistorySchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// THe history of the trends record that shows the day, the accounts and the users.
class HistorySchema {
  final String day;
  final String accounts;
  final String uses;

  const HistorySchema({
    required this.day,
    required this.accounts,
    required this.uses,
  });

  factory HistorySchema.fromJson(Map<String, dynamic> json) {
    return HistorySchema(
      day: json['day'] as String,
      accounts: json['accounts'] as String,
      uses: json['uses'] as String,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
