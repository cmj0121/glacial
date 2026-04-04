# Glacial v2 UI

## Design Philosophy

**Icon-first, less text.** The v2 interface prioritizes visual clarity through icons
and whitespace rather than text labels. Every screen should feel calm, focused, and
immediately understandable without reading.

### Principles

1. **Icon-first** — navigation, actions, and status use icons with tooltips.
   Text labels appear only where icons cannot communicate meaning (e.g., server names,
   post content).
2. **Responsive by default** — full-width on iPhone, centered `480px` max-width on
   iPad and macOS. No separate layouts; one adaptive widget (`V2CenteredLayout`).
3. **Platform-native feel** — `NavigationRail` on desktop, `NavigationBar` on mobile.
   Material 3 theming throughout. Glassmorphism on Apple platforms via existing
   `useLiquidGlass` flag.
4. **Parallel to v1** — v2 screens live in `lib/v2/`. Models, API, storage, and
   providers are reused from `lib/features/`. When v2 is complete, delete v1 screens
   and move v2 into place.

## Feature Gate

- **Fresh install**: v2 welcome screen shows automatically (no toggle required).
- **Existing users**: enable via **Settings > Appearance > New UI Design** toggle
  (`SystemPreferenceSchema.useNewUI`). Triggers app reload.
- Gate logic is in `LandingPage.onLoading()` — routes to `/v2/welcome` when
  `isFreshInstall || (useNewUI && !hasDomain)`.

## Screen Flow

```text
Fresh install / useNewUI enabled (no domain)
│
▼
┌─────────────────────┐
│   V2LandingScreen   │  /v2/welcome
│                     │
│   [app icon]        │
│   GLACIAL           │
│   tagline           │
│   [Get Started]     │
│   Powered by cmj    │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│   V2ServerPicker    │  /v2/servers
│                     │
│   [search field]    │
│   Popular Servers   │
│   ┌───────────────┐ │
│   │ mastodon.social│ │
│   │ mastodon.online│ │  tap → fetch server info
│   │ fosstodon.org  │ │  tap info → select server
│   │ mstdn.jp       │ │
│   └───────────────┘ │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│   V2HomeShell       │  /v2/home
│                     │
│   [☰] ─── drawer   │  hamburger → Switch Server / Settings
│   ┌───┐ ┌────────┐  │
│   │ ☷ │ │  WIP   │  │  sidebar (desktop) / bottom nav (mobile)
│   │ 🔍│ │        │  │  icon-only, no labels
│   │ 🔔│ │        │  │
│   │ 👤│ │        │  │
│   └───┘ └────────┘  │
└─────────────────────┘
```

## Directory Structure

```text
lib/v2/
├── core.dart                 # barrel export + module docs
├── theme.dart                # V2Theme design tokens
│                              - spacing scale (4/8/12/16/24/32/48)
│                              - border radius (12/16)
│                              - wide breakpoint (600px)
│                              - curated server list
├── widgets/
│   ├── core.dart             # widgets barrel
│   └── centered_layout.dart  # V2CenteredLayout (max-width container)
├── landing/
│   └── landing_screen.dart   # welcome screen
├── auth/
│   └── server_picker.dart    # server selection + info display
└── home/
    └── home_shell.dart       # home with NavigationRail/NavigationBar + drawer
```

## Design Tokens (V2Theme)

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXS` | 4 | Tight gaps |
| `spacingSM` | 8 | Between related items |
| `spacingMD` | 12 | Standard padding |
| `spacingLG` | 16 | Section padding |
| `spacingXL` | 24 | Between sections |
| `spacingXXL` | 32 | Large separation |
| `spacing3XL` | 48 | Hero spacing |
| `maxContentWidth` | 480 | Centered content cap |
| `borderRadius` | 12 | Cards, inputs |
| `borderRadiusLG` | 16 | Sheets, modals |
| `wideBreakpoint` | 600 | Sidebar vs bottom nav |

## Shared Infrastructure

v2 reuses these from the existing codebase:

| What | Where |
|------|-------|
| Models | `lib/features/models.dart` (AccessStatusSchema, ServerSchema, etc.) |
| API layer | `lib/features/mastodon/api/` |
| Server selection | `lib/features/mastodon/server_selection.dart` (selectServer) |
| OAuth flow | `lib/features/webview/screens/core.dart` (WebViewPage) |
| Storage/providers | `lib/cores/storage.dart` (accessStatusProvider, preferenceProvider) |
| Routing | `lib/cores/routes.dart` (RoutePath enum with v2Welcome/v2Servers) |
| Glass widgets | `lib/cores/screens/glass.dart` (reusable when needed) |

## Roadmap

- [x] Feature toggle (`useNewUI` in preferences)
- [x] Welcome / landing screen
- [x] Server picker with curated list + server info
- [x] Home shell with icon-only sidebar/bottom nav
- [ ] Timeline view (status cards)
- [ ] Post composer
- [ ] Notification feed
- [ ] Profile view
- [ ] Search
- [ ] Sign-in / OAuth integration
- [ ] Settings within v2 shell
