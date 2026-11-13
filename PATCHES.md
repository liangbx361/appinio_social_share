# JoyReels fork patches

Source: [appinio_social_share 0.3.3](https://pub.dev/packages/appinio_social_share/versions/0.3.3),
published by Appinio GmbH under the included MIT license. The source was copied from the published
package archive. Upstream: <https://github.com/appinioGmbH/flutter_packages/tree/main/packages/appinio_social_share>.

This standalone repository contains plugin sources, package/build metadata, documentation and the license. Examples,
Gradle wrappers and lockfiles are omitted. Existing public Dart methods and media APIs are retained.

Repository: https://github.com/liangbx361/appinio_social_share

Compatibility changes:

- Normalize inherited trailing whitespace when importing the standalone repository.

- Pin iOS Facebook Core/Share SDKs to 18.1.1 for both CocoaPods and SwiftPM, matching JoyReels' Facebook Login.
- Use the host Android Gradle plugin, an explicit namespace and compile SDK 36; retain Facebook Share 17.0.0.
- Build iOS WhatsApp, Telegram, Instagram Direct, Messenger and X text-share URLs with encoded query values.
  `SUCCESS` means `UIApplication.open` reported that the target opened, never that a message was sent.
  Missing targets return `ERROR_APP_NOT_AVAILABLE`; a failed open returns `ERROR_OPEN_FAILED`.
- Require an independent HTTP(S) URL for the iOS Messenger `message` argument, since Messenger receives it
  as the `link` query parameter. Callers handle copying supplementary text.
- Add `shareFacebookLink(String url)` / `facebook_link` using native Facebook `ShareLinkContent` and
  `ShareDialog` on both platforms. It accepts only HTTP(S) URLs, keeps iOS dialog lifetime ownership,
  and reports dialog dispatch instead of claiming a post was completed.
- Open X's text composer through `twitter://post?message=...`; keep the existing media path with safe
  optional handling instead of a force unwrap of the legacy Social composer.
- Correct the iOS TikTok availability check and expose `tiktok`, retaining the legacy `snssdk1233` alias.

These changes do not add a TikTok text share API, new platform credentials, permissions or a target picker.

Run the Foundation-only URL encoding check from this package directory:

```sh
xcrun swiftc -module-cache-path /private/tmp/joyreels-share-swift-cache \
  ios/appinio_social_share/Sources/appinio_social_share/ShareURLBuilder.swift \
  test/ios_share_url_check.swift -o /private/tmp/joyreels-share-url-check
/private/tmp/joyreels-share-url-check
```
