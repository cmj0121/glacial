# 冰河

> The simple and easy to use Mastodon client

[![License: CC BY-NC-ND 4.0][0]][1]

**Glacial** 是一個簡單易用的跨平台 Mastodon 客戶端，幫助您隨時隨地在任何設備上訪問和管理您的 Mastodon 帳戶。

## 功能

這個專案是基於當前的 Mastodon [API 版本][2]，並實現了訪問和管理您的 Mastodon 帳戶所需的最小功能集。
這些功能旨在簡單、易用且直觀：

### 伺服器探索

<img src="images/mastodon_server_explorer.png" alt="Mastodon Server Explorer" />
- 根據伺服器名稱或伺服器 URL 搜尋 Mastodon 伺服器。
- 您訪問過的 Mastodon 伺服器的歷史列表。

### 時間軸

<img src="images/federal_timeline.png" alt="Federal Timeline" />
- 基於當前 Mastodon 伺服器的時間軸切換滑塊。
- 始終顯示時間軸中的最新帖子，並通過下拉刷新時間軸。

### 趨勢

<img src="images/trends_hashtag.png" alt="Trends Hashtag" />
- 當前 Mastodon 伺服器上熱門帖子、標籤、帳戶和鏈接的列表。

### 其他未完成功能

- [ ] 通知
- [x] 搜索 / 探索
- [ ] 編輯 / 發嘟
- [ ] 用戶資料
- [ ] 管理介面
- [ ] 自定義設置

## 設計概念

這個專案的設計概念是提供一個簡單易用的 Mastodon 客戶端，讓用戶能夠輕鬆訪問和管理他們的 Mastodon 帳戶。
所有介面都旨在直觀且易於使用，通過直觀的圖標和佈局設計。

使用者介面旨在減少雜亂和文字密集，專注於用戶生成的內容，而不是應用程序本身。使用者可以透過工具提示找到更具描述性的資訊
，並且這些提示與 [Mastodon 專案][3] 的本地化相同。

## 本地設置

要在本地環境中設置此專案，您需要按照以下步驟操作：

1. clone the repository
2. setup your .env file for the credentials
3. build the project by [fastlane][4] on ios/ or macos/ directory

```.env
MATCH_GIT_URL=
APP_IDENTIFIER=
APPLE_ID=
TEAM_ID=
KEY_ID=
ISSUE_ID=
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=
```

## DDD (夢想驅動開發)

這個專案基於 DDD（夢想驅動開發）方法論，這意味著專案是基於我的夢想而建立的。

所有功能都是基於我的需求和夢想。

[0]: https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg
[1]: https://creativecommons.org/licenses/by-nc-nd/4.0/
[2]: https://github.com/cmj0121/mastodon_openapi
[3]: https://github.com/mastodon/mastodon/tree/main/app/javascript/mastodon/locales
[4]: https://fastlane.tools/
