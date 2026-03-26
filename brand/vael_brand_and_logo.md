# Vael — Repo Overview & App Store Logo Design

## What is Vael?

**Vael** is a **private, local-first family finance app** built with Flutter. It runs on iOS, Android, and macOS with zero servers, zero subscriptions, and zero data leaving the device unencrypted.

### Core Features
| Feature | Description |
|---|---|
| **Unified family finances** | Accounts, transactions, budgets, goals, investments, loans — all in one place |
| **End-to-end encryption** | AES-256-GCM with PBKDF2 key derivation; Google Drive is blind storage |
| **Zero cost** | No backend, no subscriptions, fully offline |
| **Selective visibility** | Each family member controls what they share |
| **India-native** | Built for Indian banking formats (HDFC, SBI, ICICI), EMI structures, tax planning |

### Feature Modules
The app has **16 feature modules**: accounts, auth, budgets, cashflow, dashboard, family, goals, imports, investments, loans, onboarding, planning, projections, recurring, settings, and transactions.

### Tech Stack
- **Framework**: Flutter (iOS, Android, macOS)
- **Database**: drift + SQLCipher (encrypted SQLite)
- **State**: Riverpod
- **Encryption**: pointycastle (AES-256-GCM, PBKDF2)
- **Sync**: Google Drive API v3 (encrypted transport)
- **Charts**: fl_chart
- **Test coverage**: 760+ tests

### Governing Principles (in priority order)
1. **Privacy is non-negotiable** — no telemetry, no analytics, no server-side processing
2. **Family is the unit** — but individuals control their visibility boundaries
3. **Deterministic over intelligent** — math and rules, not AI/ML
4. **India-native, globally coherent** — extensible architecture
5. **Self-contained and zero-cost** — no backend, no subscriptions

---

## App Store Logo Designs

### Design Rationale

The logo captures Vael's three core brand pillars:

| Pillar | Visual Symbol |
|---|---|
| **Growth & Finance** | Two leaf-like forms creating the "V" — organic growth, financial prosperity |
| **Privacy & Security** | Shield silhouette in negative space — encryption, data protection |
| **Trust & Stability** | Deep forest green palette — trustworthiness, nature, permanence |

The color palette is drawn directly from the app's design system:
- **Primary dark green**: `#2D5A27` (light theme primary)
- **Primary light green**: `#7BC470` (dark theme primary)
- **Background light**: `#FAFAF9` (light theme surface)
- **Background dark**: `#0F0F0F` (dark theme surface)

### Option A — Light Background (Recommended for Apple App Store)

![Vael logo light — angular green V with blue gradient shield](/Users/ajitg/.gemini/antigravity/brain/6fcb40d6-8082-4296-8772-2eaa1b51501a/vael_light_blue_shield_1774541265339.png)

Angular V in deep forest greens with a navy-to-sky blue gradient shield at center. Clean contrast on warm off-white.

### Option B — Dark Background (Recommended for Google Play Store)

![Vael logo dark — angular green V with blue gradient shield on dark background](/Users/ajitg/.gemini/antigravity/brain/6fcb40d6-8082-4296-8772-2eaa1b51501a/vael_dark_blue_shield_1774541281056.png)

Same silhouette in bright greens with a medium-to-bright blue gradient shield. High contrast on charcoal.

---

## App Store Submission Requirements

| Store | Icon Size | Format | Corner Radius |
|---|---|---|---|
| **Google Play** | 512 × 512 px | PNG (32-bit, alpha OK) | Applied automatically |
| **Apple App Store** | 1024 × 1024 px | PNG (no alpha/transparency) | Applied automatically by iOS |

> [!IMPORTANT]
> The generated images are raster PNGs. For final production submission, consider recreating the chosen design as a vector (SVG/AI) and exporting at exact required dimensions for pixel-perfect results.

> [!TIP]
> Both stores apply their own corner radius masking — submit square images without pre-applied rounded corners for best results.
