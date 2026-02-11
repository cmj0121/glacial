// The follow request page to show the list of pending follow requests.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class FollowRequests extends ConsumerStatefulWidget {
  const FollowRequests({super.key});

  @override
  ConsumerState<FollowRequests> createState() => _FollowRequestsState();
}

class _FollowRequestsState extends ConsumerState<FollowRequests> {
  Future<List<AccountSchema>>? _requestsFuture;

  @override
  void initState() {
    super.initState();
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    _requestsFuture = status?.fetchFollowRequests() ?? Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _requestsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<AccountSchema>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ClockProgressIndicator();
        } else if (snapshot.hasError) {
          logger.e("failed to load the follow requests: ${snapshot.error}");
          return const NoResult();
        }

        final List<AccountSchema> accounts = snapshot.data!;
        if (accounts.isEmpty) {
          final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
          return NoResult(message: message, icon: Icons.coffee);
        }

        return ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (BuildContext context, int index) => AccountLite(schema: accounts[index]),
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
