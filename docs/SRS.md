# MathMunch

## Software Requirements Specification (SRS)

Kids Math Gaming App • Ages 3–6

---

| | |
|---|---|
| **Document ref** | MM-SRS-001 |
| **Version** | 1.2 — Post-QA engineering fixes |
| **Date** | 31 October 2026 |
| **Author** | Product & Engineering Team |
| **Status** | Draft — For Review (status column maintained by engineering) |
| **Target platform** | iOS & Android (mobile-first) |

### Revision history

| Version | Date | Summary |
|---|---|---|
| 1.0 | — | Initial SRS |
| 1.1 | 18 Jul 2026 | Implementation status added |
| 1.2 | 31 Oct 2026 | Post-QA engineering pass: fixed a router bug that could strand new users on the splash screen during onboarding; corrected `pubspec.yaml` to stop declaring unused/missing asset directories and added the real sound-effect files that were silently missing; removed two Settings controls (Background Music, Daily Time Limit) that were visible but not wired to any actual behavior |

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification defines the functional and non-functional requirements for MathMunch, a mobile math gaming application designed for children aged 3–6. The document serves as a contractual reference between stakeholders, designers, and the development team throughout the product lifecycle.

### 1.2 Scope

MathMunch is a mobile-first application (iOS and Android) that delivers curriculum-aligned early mathematics through interactive, story-driven mini-games. The app targets pre-school and early primary children (ages 3–6) and their parents/guardians.

**In scope:**
- Child-facing gameplay, progression, and reward systems
- Parent dashboard, child profile management, and settings
- Adaptive difficulty engine and progress tracking
- Onboarding flow for new households

**Out of scope:**
- Web or desktop versions (Phase 2)
- Multiplayer or social features
- In-app purchases or subscription management

### 1.3 Definitions & Abbreviations

| Term | Definition |
|---|---|
| SRS | Software Requirements Specification |
| FR | Functional Requirement |
| NFR | Non-Functional Requirement |
| COPPA | Children's Online Privacy Protection Act (US) |
| GDPR-K | GDPR provisions applicable to children's data (EU) |
| EYFS | Early Years Foundation Stage (UK curriculum framework) |
| Mascot | The in-app character guide (default: cat named 'Munch') |
| World | A themed collection of levels sharing a topic (e.g. Apple Farm) |
| Level | A single gameplay session of 5–8 questions within a World |
| Parent lock | PIN-gated access to parent-only screens |

### 1.4 Document overview

Section 2 covers overall product description and constraints. Section 3 details functional requirements by feature area. Section 4 covers non-functional requirements. Section 5 outlines system interfaces.

---

## 2. Overall Description

### 2.1 Product perspective

MathMunch is a standalone mobile application with no dependency on external services except for optional parent account sync. The app functions fully offline; cloud features (progress sync, email reports) require an internet connection.

### 2.2 User classes

| User class | Description |
|---|---|
| Primary: Child (3–6) | The learner. Pre-literate or early-literate. Uses the app independently after initial setup. Cannot access settings without parent PIN. |
| Secondary: Parent / Guardian | Sets up profiles, reviews progress, adjusts settings. Interacts via the parent dashboard and settings screens. |
| Tertiary: App Admin | Anthropic/product team with backend CMS access. Out of scope for this SRS. |

### 2.3 Operating environment

- iOS 15+ (iPhone and iPad)
- Android 9.0+ (phones and tablets)
- Minimum 2 GB RAM, 200 MB free storage
- Screen sizes: 4.7" to 12.9" (responsive layout)
- Offline-first: all gameplay assets cached on install

### 2.4 Design & implementation constraints

- No third-party advertising SDKs permitted
- No social login; parent accounts use email + password only
- All child data must be stored on-device only (no cloud sync of PII without explicit opt-in)
- App Store rating: 4+ (Apple) and rated E (Google Play)
- Must pass COPPA and GDPR-K compliance audit before launch

### 2.5 Assumptions & dependencies

- Device supports touch input (tap and drag)
- Device has speakers or headphone output (audio is integral to the UX)
- Parent has a valid email address for account creation
- Curriculum alignment targets EYFS (UK), Common Core Kindergarten (US), and equivalent EU frameworks

---

## 3. Functional Requirements

Priority key — High: must-have for launch | Medium: target for v1.0 | Low: nice-to-have / v1.1

Status key — Implemented: built and working | Partial: built but incomplete/not fully wired up | Not Implemented: not built | Not Verified: cannot be confirmed from source (requires device testing, audit, or telemetry) | N/A: explicitly out of scope.

### 3.1 Onboarding & account setup

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-01 | The app shall display a splash screen with app name, mascot, and two CTAs: 'Let's play' (child) and 'Parent / new account'. | High | Splash | Implemented |
| FR-02 | New parent accounts shall require email address and password only. No social login. | High | Onboarding | Implemented |
| FR-03 | The onboarding flow shall allow entry of child name, age (3–6), and avatar selection before first play. | High | Onboarding | Implemented |
| FR-04 | The system shall support multiple child profiles under one parent account (minimum 4). | Medium | Onboarding | Implemented |
| FR-05 | Returning users shall bypass onboarding and land directly on the Home screen. | High | Splash | Implemented |

> **Engineering note (31 Oct 2026):** a full click-through test of this flow found that account registration could silently strand the user back on the splash screen instead of advancing to child setup. Root cause: the app router was being rebuilt from scratch on every auth-state change, which reset in-flight navigation. Fixed — see NFR 4.3.

### 3.2 Home screen

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-06 | The Home screen shall display the child's name, total stars earned, and current streak. | High | Home | Implemented |
| FR-07 | The Home screen shall display all available Worlds as tappable cards showing topic name, icon, and progress bar. | High | Home | Implemented |
| FR-08 | Locked worlds shall be visually distinguished (greyed out, lock icon) and non-tappable until prerequisite worlds reach 60% completion. | High | Home | Implemented |
| FR-09 | A streak banner shall appear when the child has played on consecutive days (minimum 2). | Medium | Home | Implemented |
| FR-10 | The bottom navigation bar shall provide access to Home, Sticker Book, Progress, and Parents (PIN-gated). | High | Home | Implemented |

### 3.3 Level selection

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-11 | Tapping a World card shall navigate to a Level Select screen listing all levels in that world. | High | Level Select | Implemented |
| FR-12 | Completed levels shall show a tick icon and star rating (1–3 stars). | High | Level Select | Implemented |
| FR-13 | The current in-progress level shall be visually highlighted. | High | Level Select | Implemented |
| FR-14 | Locked levels shall display a lock icon and be non-interactive. | High | Level Select | Implemented |

### 3.4 Gameplay

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-15 | Each level shall consist of 5–8 questions presented one at a time. | High | Gameplay | Implemented |
| FR-16 | Questions shall be presented with both a visual (object count or shape) and a numeral/symbol. | High | Gameplay | Implemented |
| FR-17 | Answer choices shall be presented as large tap targets (minimum 60 × 60 dp). | High | Gameplay | Implemented |
| FR-18 | Correct answers shall trigger an immediate positive animation and sound effect. | High | Gameplay | Implemented |
| FR-19 | Incorrect answers shall show a gentle 'try again' animation with no penalty score. | High | Gameplay | Implemented |
| FR-20 | The mascot shall provide a contextual audio hint when the child has not answered within 8 seconds. | Medium | Gameplay | Implemented |
| FR-21 | A progress bar shall indicate current question position within the level (e.g. Q 2/5). | Medium | Gameplay | Implemented |
| FR-22 | No reading shall be required to play; all instructions shall be delivered via audio narration. | High | Gameplay | Implemented |
| FR-23 | The gameplay screen shall include a back button that returns to Level Select after confirmation. | Medium | Gameplay | Implemented |

### 3.5 Reward & progression

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-24 | Upon level completion, the app shall display a reward screen with stars earned (1–3) and newly unlocked stickers. | High | Reward | Implemented |
| FR-25 | Stars shall be awarded based on accuracy: 3 stars ≥ 90%, 2 stars ≥ 70%, 1 star otherwise. | High | Reward | Implemented |
| FR-26 | The reward screen shall communicate progress toward the next world unlock. | Medium | Reward | Not Implemented — Reward screen does not show progress toward the next world unlock. |
| FR-27 | New stickers shall animate onto the screen on the reward screen to reinforce positive feedback. | Medium | Reward | Not Implemented — `newStickerIds` is hardcoded empty in `gameplay_screen.dart`; per-level sticker unlocking is not wired up. |
| FR-28 | The adaptive engine shall lower question difficulty after two consecutive levels with < 70% accuracy on the same topic. | Medium | Gameplay | Partial — `AdaptiveEngine` is implemented and unit-tested but never called from the gameplay flow, so difficulty is never actually lowered in a session. |

### 3.6 Sticker book

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-29 | The Sticker Book shall display all stickers organised by World, showing earned stickers in full colour and locked stickers as silhouettes. | High | Sticker Book | Implemented |
| FR-30 | Tapping an earned sticker shall play its associated sound effect. | Low | Sticker Book | Implemented |
| FR-31 | The total collection count (e.g. '12 of 30') shall be visible at the top of the screen. | Medium | Sticker Book | Implemented |

### 3.7 Progress screen

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-32 | The Progress screen shall display per-topic progress bars (Counting, Addition, Shapes, Subtraction). | High | Progress | Implemented |
| FR-33 | A recent activity feed shall list the last 10 sessions with world, level, date, duration, and stars. | Medium | Progress | Implemented |
| FR-34 | Topics not yet unlocked shall be shown as locked entries. | Medium | Progress | Partial — Locked topics show 0/total but have no distinct locked visual treatment. |

### 3.8 Parent dashboard

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-35 | The Parent Dashboard shall be accessible only after entering a 4-digit parent PIN. | High | Parent Dash | Implemented |
| FR-36 | The dashboard shall display weekly summary metrics: total time, stars earned, streak, and accuracy percentage. | High | Parent Dash | Implemented |
| FR-37 | Parents shall be able to view and switch between multiple child profiles. | High | Parent Dash | Implemented |
| FR-38 | A curriculum alignment note shall explain which learning goals the child is currently working on. | Medium | Parent Dash | Partial — Note is static hardcoded text, not tied to the child's actual current topic/progress. |
| FR-39 | An optional weekly summary email shall be sent to the registered parent email. | Low | Parent Dash | Not Implemented — `weeklyEmailEnabled` exists on the data model but there is no settings toggle or email-sending mechanism. |

### 3.9 Settings

| ID | Requirement | Priority | Screen | Status |
|---|---|---|---|---|
| FR-40 | Settings shall allow editing of child name, age, and avatar. | High | Settings | Partial — Name and age are editable; avatar is not editable from Settings. |
| FR-41 | A daily time limit (5–60 minutes) shall be configurable; the app shall display a gentle end-of-session screen when reached. | High | Settings | **Not Implemented** — The control was previously visible and persisted a value, but nothing enforced it and no end-of-session screen existed. Removed from the Settings UI on 31 Oct 2026 to avoid shipping a non-functional control (App Store review risk); the underlying `dailyTimeLimitMinutes` setting still persists but is no longer exposed. Re-add to UI once enforcement is implemented. |
| FR-42a | Sound effects shall be toggleable, and the toggle shall control real audio playback. | High | Settings | Implemented — Toggle was already wired up, but the five referenced sound-effect files (correct, incorrect, level complete, hint, sticker pop) did not exist in the repo, so the toggle had nothing to play. Fixed 31 Oct 2026: real CC0-licensed sound effects added at `assets/audio/sfx/`. |
| FR-42b | Background music shall be toggleable, and the toggle shall control real audio playback. | Medium | Settings | Not Implemented — Toggle persisted a preference but no code path ever called `AudioService.startBackgroundMusic()`; toggling it had no effect. Removed from the Settings UI on 31 Oct 2026 pending an actual background-music implementation. |
| FR-43 | A 'hints always on' toggle shall force mascot hints to appear after every question rather than on a delay. | Medium | Settings | Implemented |
| FR-44 | A progress reset option shall be available behind a confirmation dialog. | Medium | Settings | Implemented |
| FR-45 | The parent's email address shall be editable with re-verification. | Low | Settings | Not Implemented — UI entry exists but its tap handler is an empty stub; no re-verification flow. |

---

## 4. Non-Functional Requirements

Each item below is annotated with its implementation status, verified against the current codebase.

### 4.1 Performance

- App cold start to splash screen: ≤ 2 seconds on mid-range devices — **[Not Verified]** Requires on-device profiling; not assessable from source.
- Question screen render time: ≤ 300 ms after answer submission — **[Not Verified]** Requires on-device profiling; not assessable from source.
- Animation frame rate: ≥ 60 fps on devices with ≥ 2 GB RAM — **[Not Verified]** Requires on-device profiling; not assessable from source.
- All gameplay assets (audio, images) cached at install; no network required during a session — **[Implemented]** No network calls found in the gameplay path; assets are bundled via `pubspec.yaml`. *(31 Oct 2026: this was previously overstated — `pubspec.yaml` declared 6 asset directories, but 5 of them were empty/untracked and had no code reading them at all, and the one directory actually used, `assets/audio/sfx/`, had no real files in it, which broke the build on a fresh clone. Corrected: `pubspec.yaml` now declares only the directory actually used, and it contains real files.)*

### 4.2 Usability

- All interactive elements shall have a minimum tap target of 60 × 60 dp — **[Implemented]** 60×60 dp minimum enforced in `AnswerChoiceButton`.
- Font sizes shall be no smaller than 14 sp in gameplay; 11 sp in parent-facing screens — **[Not Verified]** Text uses theme styles; not measured against sp minimums.
- Colour contrast shall meet WCAG 2.1 AA for all text on backgrounds — **[Not Verified]** No contrast audit performed against WCAG 2.1 AA.
- All on-screen text shall have a corresponding audio narration (no reading required for child screens) — **[Partial]** Gameplay prompts/feedback are narrated; Settings, Progress, and Parent Dashboard have no narration.

### 4.3 Reliability & availability

- The app shall function fully offline; cloud features degrade gracefully with appropriate messaging — **[Implemented]** No network calls exist anywhere in the codebase.
- Crash rate target: < 0.5% of sessions — **[Not Verified]** Requires production telemetry.
- Session state shall be auto-saved so an interrupted session can be resumed — **[Not Implemented]** Gameplay state lives only in in-memory Riverpod state; killing the app mid-level loses progress.
- Onboarding and auth-state-driven navigation shall never silently discard in-flight navigation — **[Implemented, fixed 31 Oct 2026]** `appRouterProvider` was rebuilding a brand-new `GoRouter` instance on every change to `authStateProvider` (register, login, logout, adding a child, updating email). Since `MaterialApp.router` treats a new router instance as a new navigator, it reset to the splash screen each time, discarding whatever navigation was in flight — confirmed via a provider-identity test and a full widget-driven run through registration, which landed back on the splash screen instead of child setup. Fixed by constructing the router once and bridging auth-state changes into its `redirect` logic via `refreshListenable` instead of rebuilding the router object. Re-verified end-to-end: registration → child setup → home → gameplay → reward → parent dashboard → settings all now complete correctly.

### 4.4 Security & privacy

- No personally identifiable information (PII) shall be collected from the child — **[Implemented]**
- Parent email and password shall be stored encrypted (AES-256 at rest) — **[Not Implemented]** Hive boxes are opened without an encryption cipher; only the password value is SHA-256 hashed, box contents are not encrypted at rest.
- No third-party analytics, advertising, or tracking SDKs shall be included — **[Implemented]**
- Parent PIN shall be required to access any parent-facing screen — **[Implemented]**
- App shall comply with COPPA (US), GDPR-K (EU), and UK GDPR (UK) at launch — **[Not Verified]** Legal/compliance audit item, not code-verifiable.
- App Store age rating: 4+ (Apple) / Everyone (Google Play) — **[Not Verified]** App store listing configuration, outside app code.

### 4.5 Localisation

- v1.0 launches in English (UK and US variants) — **[Partial]** App is English-only; no explicit UK/US variant switching found.
- Architecture shall support additional languages without code changes (all strings externalised) — **[Not Implemented]** All UI strings are inline literals in widgets, not externalised to `.arb`/localization files.
- Date and number formats shall respect device locale — **[Partial]** `intl` is used for date formatting in the activity feed only; not applied elsewhere.

### 4.6 Maintainability

- Content (questions, worlds, stickers) shall be managed via a CMS; adding a new world shall require no app update — **[Not Implemented]** Worlds/levels/questions/stickers are hardcoded in `ContentRepository`.
- Adaptive difficulty thresholds shall be configurable via remote config — **[Not Implemented]** Thresholds are hardcoded constants in `AppConstants`.
- Analytics events shall be defined in a separate instrumentation plan (not in scope here) — **[N/A]** Explicitly out of scope per this SRS.

---

## 5. System Interfaces

### 5.1 Hardware interfaces

- Touch screen input (tap and drag gestures)
- Speaker / headphone audio output
- Camera: not required
- Microphone: not required in v1.0

### 5.2 Software interfaces

- iOS SDK 15+ / Android SDK 28+
- Optional: REST API for parent account sync and email reports
- Optional: Remote config SDK (e.g. Firebase Remote Config) for difficulty thresholds
- No third-party social or advertising SDKs

### 5.3 Communication interfaces

- HTTPS (TLS 1.3) for all network communication
- Offline-first: no gameplay network calls; network used only for account sync and email delivery

---

## 6. Appendix — Screen inventory

The following table summarises every screen defined in this SRS.

| Screen ID | Screen name | Primary purpose |
|---|---|---|
| SCR-01 | Splash | First-launch entry point; CTA to play or parent setup |
| SCR-02 | Onboarding | Child profile creation (name, age, avatar) |
| SCR-03 | Home | World selection, streak, star count |
| SCR-04 | Level Select | Level list within a chosen World |
| SCR-05 | Gameplay | Question presentation and answer interaction |
| SCR-06 | Reward | Level completion celebration, stars and stickers |
| SCR-07 | Sticker Book | Sticker collection browser |
| SCR-08 | Progress | Per-topic progress bars and activity history |
| SCR-09 | Parent Dashboard | Weekly summary metrics and child profile management |
| SCR-10 | Settings | Time limits, sound, avatar, account, reset |

---

*End of document. Next steps: stakeholder sign-off, UX prototyping handoff, and sprint planning against Section 3 requirements.*
