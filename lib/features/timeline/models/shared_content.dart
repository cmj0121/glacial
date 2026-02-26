// The shared content model for receiving content from other apps.
class SharedContentSchema {
  final String? text;
  final List<String> imagePaths;

  const SharedContentSchema({
    this.text,
    this.imagePaths = const [],
  });

  bool get hasContent => (text?.isNotEmpty ?? false) || imagePaths.isNotEmpty;
}

// vim: set ts=2 sw=2 sts=2 et:
