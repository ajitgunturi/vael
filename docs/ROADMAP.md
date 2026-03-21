# Vael — Implementation Roadmap

5 phases, ~14 weeks for a solo developer.

## Phase 1: Foundation (Weeks 1-2)

| Task | Details |
|------|---------|
| Flutter project init | `flutter create --platforms ios,android,macos --org com.vael vael` |
| drift + SQLCipher setup | Core schema: families, users, accounts, categories, transactions |
| Financial math library | Port `FinancialMath.java` + `AmortizationCalculator.java` to Dart with test parity |
| Account balance rules | Port `AccountBalanceService.java` — INCOME adds, EXPENSE subtracts, TRANSFER two-step |
| Google Sign-In | `google_sign_in` package for Drive access |
| Navigation shell | AdaptiveScaffold with breakpoints: BottomNav (phone), NavigationRail (tablet), NavigationDrawer (desktop) |

**Exit criteria**: App launches on all 3 platforms, can create accounts and transactions, balances update correctly.

## Phase 2: Core Features (Weeks 3-5)

| Task | Details |
|------|---------|
| Dashboard | Net worth, monthly income/expense/savings, charts (fl_chart), net worth history |
| Account CRUD | List, create, edit, soft delete. Balance display. Visibility toggle. |
| Transactions | List with date/category filters. Create/edit. Category assignment. |
| Budgets | Create monthly budgets by category group. Track actuals vs limits. Overspend alerts. |
| Goals | Create with target amount/date. SIP calculator. Status tracking (ON_TRACK, AT_RISK). |
| Loans | Loan details view. Amortization schedule table. Prepayment simulation. |

**Exit criteria**: All core screens functional with adaptive layouts. Phone portrait and iPad landscape both working.

## Phase 3: Encryption + Sync (Weeks 6-8)

| Task | Details |
|------|---------|
| Crypto engine | PBKDF2 key derivation, AES-256-GCM encrypt/decrypt, FEK generation and wrapping |
| Family passphrase flow | Setup screen, passphrase entry, KEK derivation, FEK storage in platform secure storage |
| SQLCipher activation | Encrypt local database with FEK-derived passphrase |
| Drive sync — push | sync_changelog table, changeset batching, encryption, upload to Drive |
| Drive sync — pull | Poll for new changesets, download, decrypt, apply to local DB |
| Conflict resolution | Last-writer-wins by timestamp, additive merge for transactions |
| Full snapshot | Weekly encrypted DB backup to Drive. Bootstrap new devices from snapshot. |
| Family onboarding | Invite flow: share passphrase out-of-band, new member joins via Google Sign-In + passphrase |
| Recovery key | Generate printable recovery key during setup |

**Exit criteria**: Two devices (e.g., iPhone + Mac) can sync data. Data on Drive is verified encrypted. New device can bootstrap from snapshot.

## Phase 4: Advanced Features (Weeks 9-11)

| Task | Details |
|------|---------|
| Projection engine | Port `ProjectionEngine.java` — 60-month forecast with 3 scenarios |
| Investment tracking | Holdings, bucket types, baseline returns, portfolio value |
| Statement import | HDFC, SBI, ICICI, generic CSV parsers. Preview → review → commit flow. |
| Recurring automation | Local scheduler replaces Temporal. Monthly/annual frequency with escalation. |
| Planning insights | Budget drift detection (3-month window), at-risk goal flags |
| Balance reconciliation | Run on app foreground. Validate balances vs transaction sums. |
| Data migration | Import from Storely Google Drive backup (pg_dump parser in Dart) |

**Exit criteria**: All features from the current web app are available in Vael. Migration from old app verified.

## Phase 5: Polish + Distribution (Weeks 12-14)

| Task | Details |
|------|---------|
| App Store prep | Metadata, screenshots (iPhone, iPad, Mac), privacy policy, App Store description |
| Play Store prep | Same for Google Play. Content rating. |
| Mac App Store prep | Sandboxing, entitlements, notarization. |
| Fastlane setup | Automated build, signing, and submission for all 3 stores |
| GitHub Actions CI | Lint, test, build on every PR. Release workflow triggers Fastlane. |
| Onboarding flow | First-run experience: sign in → create/join family → set passphrase → optional import |
| Accessibility | VoiceOver/TalkBack labels, dynamic type support, color contrast |
| Edge case testing | Offline scenarios, sync conflicts, large datasets (10k+ transactions) |

**Exit criteria**: App submitted to all 3 stores. CI/CD pipeline green. Onboarding tested with non-technical family member.

## Verification Criteria

| Check | Method |
|-------|--------|
| Financial math | Port Java test cases to Dart. Verify against Excel. |
| Encryption | Round-trip tests. Verify non-deterministic ciphertext (random IV). |
| Sync | Two emulators, both edit offline, reconnect, verify consistency. |
| Cross-platform | Integration tests on iOS simulator, Android emulator, macOS. |
| Adaptive layout | iPhone SE, iPhone 15 Pro Max, iPad Pro 12.9" landscape, macOS 800x600 → fullscreen. |
| iPad multitasking | Split View (50/50, 33/66) and Slide Over without overflow. |
| App Store readiness | Fastlane build succeeds, screenshots generated, metadata validated. |
| Data migration | Import from old app, verify row counts + net worth + spot-check transactions. |
| Offline | Airplane mode → create transactions → reconnect → verify sync. |
| Security | SQLCipher DB unreadable without passphrase. Drive files are opaque. |
