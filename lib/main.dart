// The entry point of the app that initializes the environment and starts the app.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:glacial/app.dart';
import 'package:glacial/core.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Info.init();

  logger.d("completely preloaded ...");
  runApp(const GlacialApp());
}

// vim: set ts=2 sw=2 sts=2 et:
