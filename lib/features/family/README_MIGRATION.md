# Family Feature — Migration Notice

Family management (member listing, invites, visibility controls) has been
consolidated into the **Settings** module (`lib/features/settings/`).

The `providers/`, `screens/`, and `widgets/` directories under
`lib/features/family/` are intentionally empty. They remain as namespace
placeholders in case family-specific UI is reintroduced in a future phase.

See `lib/features/settings/screens/` for the current family management screens.
