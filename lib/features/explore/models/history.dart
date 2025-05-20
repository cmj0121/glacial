// The history of the trends record.

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
