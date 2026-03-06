# Glacial

> The simple and easy to use Mastodon client

[![License: CC BY-NC-ND 4.0][0]][1]
![Testing](https://github.com/cmj0121/glacial/actions/workflows/test.yml/badge.svg?branch=main)

[English](README.md) | [繁體中文](README_zh.md)

It is the simple and cross-platform Mastodon client that helps you to access and manage
your Mastodon account, on any device, anywhere, anytime.

## Features

Below are the features that have been supported and implemented. All features are implemented
based on the [OpenAPI][2] specification after processing the official documentation.

### Explore & Discovery

- Explore Mastodon servers, users, hashtags, and trending posts.
- Browse the public account directory with ordering options (active, newest, alphabetical).
- View trending hashtags, statuses, and links.
- Follow and unfollow hashtags.

![Dictory](./images/01Directory.webp)

### Authentication & Multi-Account

- Sign in and register accounts on any Mastodon server via OAuth2.
- Switch between multiple accounts on the same server.
- Persistent saved accounts for quick switching.

![Sign In](./images/02SignIn.webp)

### Timelines

- Home, Local, and Federated timelines with real-time streaming updates.
- Favourites, Bookmarks, and Pinned posts timelines.
- List timelines and hashtag timelines.
- Configurable refresh interval and item limits.
- Hide replies or reblogs from timeline.
- Offline cache with stale-while-revalidate for reading without network.

### Search

- Search for users, posts, and hashtags on the connected Mastodon server.

![Search](./images/03Search.webp)

### Posts & Interactions

- Compose, edit, schedule, and delete posts.
- Visibility control (public, unlisted, private, direct).
- Media attachments (images, video, audio, GIF).
- Polls with voting support.
- Quote posts with approval policies.
- Content warnings and sensitive media marking.
- Favourite, reblog, bookmark, pin, and mute threads.
- Emoji reactions on statuses (Glitch/Pleroma/Akkoma compatible).
- Status translation.
- View edit history.
- Share posts via system share dialog.

### Profile

- View and edit your profile (avatar, header, display name, bio, fields).
- Browse followers, following, and lists.
- Endorse (feature) accounts on your profile.
- Add personal notes to other accounts.
- View familiar followers (mutuals).

![Profile](./images/04Profile.webp)

### Notifications

- Grouped notifications (Mastodon API v2) for mentions, follows, favourites, reblogs, polls, and updates.
- Background polling with rich local notifications on iOS.
- Per-type notification toggles (mentions, follows, favourites, reblogs, polls, statuses).
- Notification policy management.
- App badge number updates.

### Direct Messages

- View, manage, and delete conversations.
- Mark conversations as read.

### Lists

- Create, edit, and delete lists with reply policy and exclusive mode.
- Add and remove accounts from lists.
- Dedicated list timelines.

### Filters & Content Moderation

- Create, edit, and delete content filter groups with keywords.
- Filter actions: warn, hide, or blur media.
- Scope filters to home, notifications, public, threads, or accounts.
- Manage muted accounts, blocked accounts, and domain blocks.
- Report accounts with categorized reasons.

### Administration

- Admin dashboard for server moderators.
- Manage user reports (assign, resolve, reopen).
- Manage accounts (approve, reject, suspend, silence, unsensitive).
- Role-based permission controls.

### Instance Info

- View server metadata (title, version, description, active users, contact, languages,
  registration status, and rules) from the app drawer.

### Preferences & Settings

- **Theme**: Dark, Light, Auto, and OLED pure-black mode.
- **Display**: Adjustable font size (0.8x - 1.4x), image quality selection.
- **Timeline**: Auto-play video, hide replies/reblogs, item limits, refresh interval.
- **Posting**: Default visibility, sensitive content default, reply tag behavior, quote approval policy.
- **Notifications**: Per-type toggle switches.
- **Language**: 8 supported languages (English, German, Spanish, French, Japanese, Korean, Portuguese, Chinese).
- **Accessibility**: Haptic feedback toggle, semantic labels for screen readers.

### Technical Highlights

- **Real-time streaming** via Mastodon Streaming API (WebSocket) with auto-reconnect.
- **Offline support** with timeline caching and stale-while-revalidate.
- **HTTP resilience** with 30s timeout, exponential backoff with jitter, and rate limit handling.
- **In-memory LRU cache** for accounts and statuses.
- **Background fetch** for iOS notification polling.
- **Glass morphism UI** with shimmer loading states and skeleton screens.
- **3200+ automated tests** covering models, widgets, and integration.

## DDD (Dream-Driven Development)

This project is based on the DDD (dream-driven development) methodology which means the project
is based on what I dream of.

All the features are based on my needs and my dreams.

[0]: https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg
[1]: https://creativecommons.org/licenses/by-nc-nd/4.0/
[2]: https://cmj0121.github.io/mastodon_openapi/
