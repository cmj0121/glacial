// V2 UI module — redesigned interface gated behind useNewUI preference.
//
// Design principles:
//   - Icon-first: prefer icons over text labels for a clean, calm UI
//   - Responsive: full-width on iPhone, centered max-480px on iPad/Mac
//   - Parallel to v1: screens live here, models/API reused from features/
//
// Flow:
//   LandingPage (/) → loads prefs → if fresh install OR (useNewUI && no domain):
//     → V2LandingScreen (/v2/welcome)
//       → V2ServerPicker (/v2/servers)
//         → tap server → fetch info → tap info to select
//           → V2HomeShell (wraps /home/* via ShellRoute)
//
// Structure:
//   lib/v2/
//   ├── core.dart           — barrel export (this file)
//   ├── theme.dart          — design tokens, spacing, curated servers
//   ├── widgets/            — shared v2 components
//   ├── landing/            — welcome screen
//   ├── auth/               — server picker
//   └── home/               — home shell with sidebar/bottom nav

export 'theme.dart';
export 'widgets/core.dart';
export 'landing/landing_screen.dart';
export 'auth/server_picker.dart';
export 'home/home_shell.dart';
// vim: set ts=2 sw=2 sts=2 et:
