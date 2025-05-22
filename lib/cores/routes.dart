// The routes.dart file defines the routes for the app.

enum RoutePath {
  landing,           // The landing page of the app when user opens it.
  engineer,          // The engineer page of the app.
  explorer,          // The server explorer page of the app.
  webview,           // The in-app webview page of the app.
  userProfile,       // The user profile page of the app.
  statusContext,     // The status context page of the app.
  hashtagTimeline,   // The timeline with the specified hashtag.
  homeTimeline,      // The timeline page of the app.
  homeTrends,        // The trends page of the app.
  homeExplore,       // The explore page of the app.
  homeNotifications, // The notifications page of the app.
  homeSettings,      // The settings page of the app.
  wip;               // The work-in-progress page of the app.

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.landing:
        return '/';
      case RoutePath.engineer:
        return '/engineer';
      case RoutePath.explorer:
        return '/explorer';
      case RoutePath.webview:
        return '/webview';
      case RoutePath.userProfile:
        return '/user';
      case RoutePath.hashtagTimeline:
        return '/hashtag';
      case RoutePath.statusContext:
        return '/home/status/context';
      case RoutePath.homeTimeline:
        return '/home/timeline';
      case RoutePath.homeTrends:
        return '/home/trends';
      case RoutePath.homeExplore:
        return '/home/explore';
      case RoutePath.homeNotifications:
        return '/home/notifications';
      case RoutePath.homeSettings:
        return '/home/settings';
      case RoutePath.wip:
        return '/wip';
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
