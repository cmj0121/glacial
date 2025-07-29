// The Mastodon server data schema for rules and contact information.

// The Server rule to show the server info in the app.
class RuleSchema {
  final String id;
  final String text;
  final String hint;

  const RuleSchema({
    required this.id,
    required this.text,
    required this.hint,
  });

  factory RuleSchema.fromJson(Map<String, dynamic> json) {
    return RuleSchema(
      id: json['id'] as String,
      text: json['text'] as String,
      hint: json['hint'] as String,
    );
  }
}

// The hints related to contacting a representative of the website.
class ContactSchema {
  final String email;

  const ContactSchema({
    required this.email,
  });

  factory ContactSchema.fromJson(Map<String, dynamic> json) {
    return ContactSchema(
      email: json['email'] as String,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
