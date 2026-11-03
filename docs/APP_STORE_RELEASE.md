# App Store release checklist

**Status: version 1.0.0 (build 2) uploaded for internal TestFlight on 2026-11-03.** Xcode confirmed upload success and Apple package processing has begun; the TestFlight build list had not yet refreshed at the last check. This includes the client's latest `master` changes through `5cb1258` (account deletion and duplicate-child fix). Build 1 was uploaded on 2026-10-31; the owner reports inviting internal testers. No App Store submission or production release has been performed.

## Repository preparation (done)

- CocoaPods integration (`ios/Podfile`, iOS 13 target, `ios/Podfile.lock`); Debug/Profile/Release xcconfig files include the Pods configs. Open `ios/Runner.xcworkspace`.
- iOS display name corrected to `MathMunch`.
- App icon artwork (all required sizes) and the matching launch image approved by the owner; promotional iPhone and iPad screenshot artwork approved by the owner.
- Screenshots captured on iOS 26.2 simulators and exported at App Store Connect dimensions.
- Known iPad issue (not changed): the Parent PIN pad in onboarding stretches to the full width and needs scrolling to reach the Create Account button.
- Runner Release uses manual Apple Distribution signing for team `2FXZ46CJ8Q` and `MathMunch App Store Distribution`; Debug/Profile settings are unchanged. Signing is scoped to the app target, not Pods.
- Signed archive: `build/ios/archive/MathMunch-TestFlight.xcarchive`.
- Exported IPA: `build/ios/ipa/internal-testflight/mathmunch.ipa`. The export explicitly restricts this build to internal TestFlight; it cannot be distributed externally or through the App Store.
- Local verification: analyzer clean, all 92 tests passed, archive and export succeeded, IPA signature verified, embedded profile/team/bundle checked, debugging entitlement disabled, internal-only export option confirmed. The owner reports a successful physical-iPad run; this is not full device QA.
- Apple initially rejected the upload because `App.framework` lacked `MinimumOSVersion`. Added `13.0` to `ios/Flutter/AppFrameworkInfo.plist`, rebuilt, and successfully uploaded the corrected archive; refreshed the local IPA to match.
- Non-blocking Apple warnings: iOS 15 or later will be required for uploads starting April 2027; `objective_c.framework` has no supplied dSYM. The matching native asset has no debug information, so generating an empty dSYM does not recover source-level crash symbols. Other archive dSYMs remain preserved.

Toolchain used: Flutter 3.38.7 / Dart 3.10.7, Xcode 26.2 (iOS SDK 26.2), CocoaPods 1.16.2.
Version/build: `1.0.0+2`; bundle ID `com.mathmunch.mathmunch`.

## Remaining gates (owner/developer actions)

| Gate | Action needed |
|---|---|
| App icon and launch image | ✅ Owner approved the smiling-apple icon artwork; all required icon sizes and matching launch image are present. |
| Privacy policy and support | Provide a real public privacy-policy URL and support URL/contact. Nothing has been invented. |
| Apple account and signing | Verified Multiplexer Lab / K M Sarwar Miral (Team ID `2FXZ46CJ8Q`). Registered explicit App ID `com.mathmunch.mathmunch` with no optional capabilities enabled. Generated Apple Distribution and Apple Development certificates using the supplied CSR. Registered the development iPad and generated `MathMunch Development iPad`. Generated and installed `MathMunch App Store Distribution` (expires 2027-10-31); local signed archive/export verifies the Distribution identity works with this profile. Created the [MathMunch App Store Connect record](https://appstoreconnect.apple.com/apps/6829225182/distribution) (Apple ID `6829225182`, iOS, English U.S., SKU `MATHMUNCH-IOS-001`, Full Access as approved). Last observed status is Prepare for Submission; initial store version is 1.0 and must match the intended build version before submission. Before each account change, verify this team remains selected. |
| Account deletion (Guideline 5.1.1(v)) | Latest client `master` adds account deletion in Settings. Verify the flow deletes all local account/child/progress data and passes device QA before submission; no server-side account backend is currently known. |
| Settings/feature claims | Daily Time Limit and Background Music are not implemented and are hidden on master. Do not mention them in store metadata. |
| Privacy and export compliance | Review the final archive's privacy report/manifests and answer App Privacy and encryption questions from verified facts. |
| Kids category and age rating | Decide category/age band and answer the questionnaire; confirm children's-privacy requirements. |
| Metadata and screenshots | ✅ Owner approved the promotional screenshot artwork. Original captures are in `docs/app-store/screenshots/`; promotional versions with headings and illustrated device frames are in `docs/app-store/promotional-screenshots/` (iPhone 6.9" 1320x2868, iPad 13" 2064x2752). Owner still provides description, keywords, copyright, and review contact. |
| Device QA | Test on real iPhone/iPad: onboarding, all worlds, sound effects, narration, relaunch, background/resume. Note Dart requests portrait while `Info.plist` declares landscape. |

Membership is verified as **Individual**, valid until October 23, 2027, with the Developer Program license agreement accepted. For individual memberships, invited App Store Connect users do not receive Developer Program team membership or Certificates, Identifiers & Profiles access, even with the Admin role. Earlier advice to grant that access through an organization-team invitation does not apply to this membership. Keep private keys local and do not share account credentials. EU trader-status information remains outstanding; the Account Holder must provide the correct declaration.

## Client information needed for App Store publication

| Item | Client input needed |
|---|---|
| Privacy Policy URL (required) | Public, working HTTPS page accurately covering local accounts, children's data, storage/deletion, third-party SDKs and any collection/sharing. Must also be accessible in the app. Do not assume offline means no data collected. |
| Support URL (required) | Public support page with a working contact method, such as support email or a form. |
| Terms / license agreement (optional custom agreement) | Confirm use of Apple's standard EULA, or provide legally reviewed custom EULA text and applicable territories. A separate Terms URL is not universally required for this app. Supply one if the client wants additional service terms. |
| Store copy | Approved description and keywords; confirm name. Subtitle and promotional text are optional. Claims must match implemented features. |
| Copyright | Year and the legal rights-holder name; confirm ownership/licensing of supplied content. |
| Category and age rating | Primary category; whether to opt into Kids category and which age band; truthful age-rating questionnaire answers. |
| App Privacy answers | Confirm actual data collection, purposes, linkage, tracking, third-party SDK behavior, and children's-privacy obligations with the developer. |
| App Review contact | Contact person's first/last name, email and phone. Supply review instructions and demo access if required; never share real customer credentials. |
| Price and availability | Free or paid, countries/regions, and desired release timing/manual versus automatic release. Paid apps require applicable agreements, banking and tax setup in Apple's portal. |
| EU trader status (if distributing in EU) | Account Holder's accurate trader/non-trader declaration and any verification/contact information Apple requests, entered directly in the portal. |
| Export compliance | Developer-confirmed encryption use and documentation only if Apple requires it. |
| Final approval | Confirm screenshot/store copy approval, real-device QA, and authorization to submit the final App Store build. Existing icon and promotional screenshots are already approved. |
| Marketing URL / preview video (optional) | Public product website and promotional video if desired; neither is required by default. |

Developer readiness remains separate from client paperwork: verify account deletion on device, ensure an in-app privacy-policy link, complete children's-app compliance/QA, and prepare a new build without the internal-only restriction. Build 1 and internal-only build 2 cannot be used for App Store release.

References: [Apple platform version fields](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [standard versus custom EULA](https://developer.apple.com/help/app-store-connect/manage-app-information/provide-a-custom-license-agreement).

## Future-build reminders

- Retain `MinimumOSVersion` in Flutter's framework plist and check embedded framework metadata before uploading.
- Apple's upload warning says iOS 15 or later is required starting April 2027. Recheck Apple's requirements before the next upload and coordinate a deployment-target change with the developer; do not silently drop iOS 13/14 support.
- Check whether an updated native dependency supplies genuine `objective_c.framework` debug symbols. Do not manufacture an empty dSYM to hide the warning.
- Use an unused build number; export the publication build without `testFlightInternalTestingOnly`.

## Build commands

To regenerate promotional screenshots, run `python3 docs/app-store/generate_promotional_screenshots.py` with Pillow installed. The script uses local macOS fonts by default; on other systems supply `--regular-font` and `--bold-font` paths to licensed fonts. Original captures are preserved and scaled proportionally inside illustrated frames. At the owner's request, promotional versions add illustrative system chrome within safe-area margins: a 9:41 clock, full cellular/Wi-Fi/battery indicators, a home indicator, and an iPhone Dynamic Island. These overlays are design elements, not a capture of actual device/network state. The iPad versions do not have a Dynamic Island. No app features or controls are changed. Review final images in App Store Connect before submission; artwork alone does not establish release readiness or guarantee approval.

```sh
flutter analyze
flutter test
flutter build ios --release --no-codesign
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/ios/archive/MathMunch-TestFlight.xcarchive archive
xcodebuild -exportArchive \
  -archivePath build/ios/archive/MathMunch-TestFlight.xcarchive \
  -exportPath build/ios/ipa/internal-testflight \
  -exportOptionsPlist ios/ExportOptions-TestFlight.plist
```

These commands require the named profile and a matching Apple Distribution identity in the signing Mac's keychain. Do not pass provisioning profile overrides globally to `xcodebuild`: Pods frameworks do not support app provisioning profiles. Do not use this App Store profile to run directly on an iPad; use development signing for Debug.

Before any future upload, refresh App Store Connect, confirm the intended build number is unused, review the version, and obtain explicit upload authorization. Confirm Apple processing/export-compliance status and tester build availability. Preserve the archive and its dSYMs for crash symbolication. A future external/App Store build must be exported without the internal-only restriction. **Stop before Upload/Submit/Release**, which require explicit authorization.

Builds `1` and `2` are uploaded; do not reuse either build number. Build `2` is pending Apple processing at the last check. Future uploads need a new build number and explicit authorization. Upload logs are local under `build/ios/upload-1.0.0-2.log`; do not publish authentication-related distribution logs. Confirm processing succeeds and assign build 2 to the existing internal group in [MathMunch TestFlight](https://appstoreconnect.apple.com/teams/8adb6439-9332-474f-8472-19fc898a3c88/apps/6829225182/testflight) if it is not automatically available. The owner reports inviting internal testers; no tester invitations were sent by this preparation agent.
