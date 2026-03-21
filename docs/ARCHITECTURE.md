# Vael — Architecture

## System Overview

```
┌─────────────────────────────────────────────┐
│              Flutter App (per device)         │
│  ┌─────────┐  ┌──────────┐  ┌────────────┐  │
│  │ UI Layer│  │ Business  │  │ Crypto     │  │
│  │ (Screens│  │ Logic     │  │ Engine     │  │
│  │  Widgets│  │ (Dart)    │  │ (AES-256   │  │
│  │  State) │  │           │  │  + PBKDF2) │  │
│  └────┬────┘  └─────┬────┘  └─────┬──────┘  │
│       │             │              │          │
│  ┌────┴─────────────┴──────────────┴───────┐ │
│  │        Local SQLite (drift)             │ │
│  │   Encrypted at rest (SQLCipher)         │ │
│  └─────────────────┬───────────────────────┘ │
│                    │                          │
│  ┌─────────────────┴───────────────────────┐ │
│  │     Sync Engine (Google Drive API)      │ │
│  │  Encrypted JSON changesets ↔ Drive      │ │
│  └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Principles
- Zero server infrastructure — Google Drive is the only external dependency
- All financial data encrypted before leaving the device (AES-256-GCM)
- Family encryption key (FEK) derived from a shared family passphrase
- Each device is fully functional offline
- Sync is eventual consistency via encrypted changesets on Drive

## Technology Stack

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Flutter 3.x + Dart | Single codebase for iOS, Android, macOS. Rich widget library. |
| Local DB | drift + SQLCipher | Type-safe SQLite in Dart. SQLCipher adds transparent AES-256 encryption at rest. |
| State Mgmt | Riverpod | Compile-safe, testable, scales well. Preferred over BLoC for new projects. |
| Encryption | pointycastle + platform Keychain/KeyStore | AES-256-GCM for data, PBKDF2 for key derivation, platform secure storage for key material. |
| Sync | googleapis (Google Drive API v3) | Direct Drive API calls. No intermediary server. |
| Auth | google_sign_in | OAuth for Drive access. No custom auth server needed. |
| Charts | fl_chart | Flutter-native charting (replaces Recharts from the web app). |
| Testing | flutter_test + integration_test + mockito | Unit, widget, and integration tests. |
| CI/CD | GitHub Actions + Fastlane | Automated builds, signing, and app store submission. |

### Platform Targets
- iOS 16+ (iPhone + iPad)
- Android 8+ (API 26, phone + tablet)
- macOS 13+

## Project Structure

```
vael/
├── lib/
│   ├── main.dart
│   ├── app.dart                        # MaterialApp, routing, theme
│   ├── core/
│   │   ├── database/                   # drift tables, DAOs, migrations
│   │   ├── crypto/                     # Encryption, key derivation, key management
│   │   ├── sync/                       # Google Drive sync engine
│   │   ├── auth/                       # Google Sign-In wrapper
│   │   └── financial/                  # Ported math: PMT, FV, amortization, projections
│   ├── features/
│   │   ├── dashboard/                  # Net worth, monthly summary, charts
│   │   ├── accounts/                   # Account CRUD, balance tracking
│   │   ├── transactions/               # Transaction list, filters, categorization
│   │   ├── budgets/                    # Budget management, actuals vs limits
│   │   ├── goals/                      # Goal tracking, SIP calculator
│   │   ├── loans/                      # Loan details, amortization schedule
│   │   ├── investments/                # Portfolio, holdings, returns
│   │   ├── imports/                    # Statement import (HDFC, SBI, ICICI, CSV)
│   │   ├── projections/               # 60-month forecast, scenarios
│   │   ├── family/                     # Family management, invites
│   │   └── settings/                   # App preferences, sync status, encryption
│   └── shared/
│       ├── layout/                     # AdaptiveScaffold, breakpoint system
│       ├── widgets/                    # Reusable UI components
│       ├── theme/                      # App theme, colors, typography
│       └── utils/                      # Formatters, validators, extensions
├── test/
│   ├── core/                           # Unit tests for financial math, crypto, sync
│   ├── features/                       # Widget tests per feature
│   └── integration/                    # End-to-end test flows
├── integration_test/                   # On-device integration tests
├── macos/                              # macOS runner
├── ios/                                # iOS runner
├── android/                            # Android runner
├── pubspec.yaml
├── analysis_options.yaml
├── Makefile                            # Developer workflow automation
└── .github/
    └── workflows/
        ├── ci.yml                      # Lint, test, build on PR
        └── release.yml                 # Fastlane build + store submission
```

## Adaptive Layout Strategy

### Breakpoints

| Form Factor | Width | Orientation | Layout Strategy |
|-------------|-------|-------------|-----------------|
| iPhone / Android phone | < 600dp | Portrait | Single-column stack. Bottom navigation bar. Full-screen drill-down. |
| iPad (portrait) | 600-900dp | Portrait | Optional side rail + content area. Can show list+detail split. |
| iPad Pro / Mac / Android tablet | > 900dp | Landscape | Persistent side navigation + master-detail. Dashboard uses multi-column grid. |

### Layout Patterns by Screen

| Screen | Phone (Portrait) | iPad Pro / Mac (Landscape) |
|--------|-----------------|---------------------------|
| Dashboard | Vertical scroll: net worth card -> monthly summary -> chart -> goals | 2-3 column grid: net worth + chart side-by-side, goals + budget in second row |
| Accounts | Full-width list -> tap opens detail | Master list (left 35%) + detail panel (right 65%) |
| Transactions | Full-width list with filter chips -> tap opens detail | Filterable table with inline editing, wider columns for description/category |
| Projections | Stacked: scenario selector -> single chart -> data table below | Chart fills 60% width, scenario comparison table on the right |
| Loans | Amortization as vertical timeline -> scroll | Split: loan summary (left) + amortization table (right, scrollable) |
| Goals | Card list -> tap for detail | Card grid (2-3 across) with inline progress bars |
| Settings | Standard list -> drill-down | List (left) + settings panel (right), no navigation away |
| Import | Step wizard (full screen per step) | All steps visible: file picker + preview table + category mapping side-by-side |

### AdaptiveScaffold

```dart
// lib/shared/layout/adaptive_scaffold.dart
class AdaptiveScaffold extends StatelessWidget {
  // Wraps every screen. Switches between:
  // - BottomNavigationBar (phone portrait)
  // - NavigationRail (tablet portrait)
  // - Persistent NavigationDrawer (landscape iPad/Mac)
  //
  // Uses LayoutBuilder to detect width and apply breakpoints.
  // Each feature screen provides both a "compact" and "expanded" builder.
}
```

Key Flutter widgets:
- `LayoutBuilder` — reactive to parent constraints (not just screen size)
- `NavigationRail` — vertical nav for medium screens
- `NavigationDrawer` — persistent side nav for wide screens
- `SliverGrid` + `SliverList` — adaptive grid/list layouts
- Platform-aware: `defaultTargetPlatform` for Cupertino vs Material touches

### iPad-Specific
- Multitasking: Support Split View and Slide Over
- Keyboard shortcuts: Cmd+N (new transaction), Cmd+F (search), Cmd+, (settings)
- Pointer/hover: hover states on interactive elements with trackpad/mouse
- Stage Manager (iPadOS 16+): Resizable windows handled by breakpoint system

### macOS-Specific
- Native menu bar with File, Edit, View, Window menus
- Window resizing: functional from 800x600 to full screen
- macOS-style toolbar with search field and action buttons
- Persistent sidebar (NavigationDrawer maps to NavigationSplitView pattern)
