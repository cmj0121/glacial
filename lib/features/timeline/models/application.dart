// The Application used in the Timeline Status.

// The application used to post the status
class ApplicationSchema {
  final String name;             // The name of the application.
  final String? website;         // The website of the application.

  const ApplicationSchema({
    required this.name,
    this.website,
  });

  factory ApplicationSchema.fromJson(Map<String, dynamic> json) {
    return ApplicationSchema(
      name: json['name'] as String,
      website: json['website'] as String?,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
