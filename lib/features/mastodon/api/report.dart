// The Report APIs for the mastdon server.
//
// ## Report APIs
//
//    - [+] POST /api/v1/reports
//
// ref:
//   - https://docs.joinmastodon.org/methods/reports/
import 'dart:async';

import 'package:glacial/features/models.dart';

extension ReportExtensions on AccessStatusSchema {
  // Report problematic accounts and contents to your moderators.
  Future<ReportSchema> report(ReportFileSchema schema) async {
    final String endpoint = '/api/v1/reports';
    final Map<String, dynamic> json = schema.toJson();
    final String body = await postAPI(endpoint, body: json) ?? "{}";

    return ReportSchema.fromString(body);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
