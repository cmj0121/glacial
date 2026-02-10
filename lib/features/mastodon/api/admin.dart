// The Admin APIs for the mastodon server.
//
// ## Admin Report APIs
//
//    - [+] GET  /api/v1/admin/reports
//    - [+] GET  /api/v1/admin/reports/:id
//    - [+] POST /api/v1/admin/reports/:id/assign_to_self
//    - [+] POST /api/v1/admin/reports/:id/unassign
//    - [+] POST /api/v1/admin/reports/:id/resolve
//    - [+] POST /api/v1/admin/reports/:id/reopen
//
// ## Admin Account APIs
//
//    - [+] GET  /api/v2/admin/accounts
//    - [+] GET  /api/v1/admin/accounts/:id
//    - [+] POST /api/v1/admin/accounts/:id/approve
//    - [+] POST /api/v1/admin/accounts/:id/reject
//    - [+] POST /api/v1/admin/accounts/:id/action
//    - [+] POST /api/v1/admin/accounts/:id/enable
//    - [+] POST /api/v1/admin/accounts/:id/unsilence
//    - [+] POST /api/v1/admin/accounts/:id/unsuspend
//    - [+] POST /api/v1/admin/accounts/:id/unsensitive
//
// ref:
//   - https://docs.joinmastodon.org/methods/admin/reports/
//   - https://docs.joinmastodon.org/methods/admin/accounts/
import 'dart:convert';

import 'package:glacial/features/models.dart';

extension AdminExtensions on AccessStatusSchema {
  // Fetch the list of admin reports with optional filtering.
  Future<List<AdminReportSchema>> fetchAdminReports({bool? resolved, String? accountId, String? targetAccountId}) async {
    checkSignedIn();

    final Map<String, String> query = {
      if (resolved != null) 'resolved': resolved.toString(),
      if (accountId != null) 'account_id': accountId,
      if (targetAccountId != null) 'target_account_id': targetAccountId,
    };

    final String endpoint = '/api/v1/admin/reports';
    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => AdminReportSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Get a single admin report by ID.
  Future<AdminReportSchema> getAdminReport(String reportId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/reports/$reportId';
    final String body = await getAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminReportSchema.fromJson(json);
  }

  // Assign a report to yourself.
  Future<AdminReportSchema> assignReportToSelf(String reportId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/reports/$reportId/assign_to_self';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminReportSchema.fromJson(json);
  }

  // Unassign a report.
  Future<AdminReportSchema> unassignReport(String reportId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/reports/$reportId/unassign';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminReportSchema.fromJson(json);
  }

  // Resolve a report.
  Future<AdminReportSchema> resolveReport(String reportId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/reports/$reportId/resolve';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminReportSchema.fromJson(json);
  }

  // Reopen a resolved report.
  Future<AdminReportSchema> reopenReport(String reportId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/reports/$reportId/reopen';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminReportSchema.fromJson(json);
  }

  // Fetch the list of admin accounts with optional filtering.
  Future<List<AdminAccountSchema>> fetchAdminAccounts({
    AdminAccountOrigin? origin,
    AdminAccountStatus? status,
    String? username,
    String? displayName,
    String? email,
    String? ip,
  }) async {
    checkSignedIn();

    final Map<String, String> query = {
      if (origin != null) 'origin': origin.name,
      if (status != null) 'status': status.name,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (ip != null) 'ip': ip,
    };

    final String endpoint = '/api/v2/admin/accounts';
    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => AdminAccountSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Get a single admin account by ID.
  Future<AdminAccountSchema> getAdminAccount(String accountId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/accounts/$accountId';
    final String body = await getAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminAccountSchema.fromJson(json);
  }

  // Approve a pending account.
  Future<AdminAccountSchema> approveAccount(String accountId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/accounts/$accountId/approve';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminAccountSchema.fromJson(json);
  }

  // Reject a pending account.
  Future<AdminAccountSchema> rejectAccount(String accountId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/accounts/$accountId/reject';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminAccountSchema.fromJson(json);
  }

  // Perform a moderation action on an account (suspend or silence).
  Future<void> performAccountAction(String accountId, {required String type, String? reportId, String? text}) async {
    checkSignedIn();

    final Map<String, dynamic> requestBody = {
      'type': type,
      if (reportId != null) 'report_id': reportId,
      if (text != null) 'text': text,
    };

    final String endpoint = '/api/v1/admin/accounts/$accountId/action';
    await postAPI(endpoint, body: requestBody);
  }

  // Re-enable a disabled account.
  Future<AdminAccountSchema> enableAccount(String accountId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/accounts/$accountId/enable';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminAccountSchema.fromJson(json);
  }

  // Unsilence an account.
  Future<AdminAccountSchema> unsilenceAccount(String accountId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/accounts/$accountId/unsilence';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminAccountSchema.fromJson(json);
  }

  // Unsuspend an account.
  Future<AdminAccountSchema> unsuspendAccount(String accountId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/accounts/$accountId/unsuspend';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminAccountSchema.fromJson(json);
  }

  // Unmark an account as sensitive.
  Future<AdminAccountSchema> unsensitiveAccount(String accountId) async {
    checkSignedIn();

    final String endpoint = '/api/v1/admin/accounts/$accountId/unsensitive';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return AdminAccountSchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
