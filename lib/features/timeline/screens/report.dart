// The report dialog form to report an account.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

class ReportDialog extends StatelessWidget {
  final AccountSchema account;

  const ReportDialog({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: const WIP(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
