/// Deterministic Indian capital gains tax constants (FY 2024-25).
///
/// Rates are in basis points (1250 bp = 12.5%).
/// Amounts are in paise (integer minor units).
/// No DB imports, no mutable state.
///
/// Review after each Union Budget for rate changes.
class IndianTaxConstants {
  IndianTaxConstants._();

  // ── Equity (MF equity, stocks) ────────────────────────────────────
  /// Holding period threshold for long-term classification.
  static const equityLtcgThresholdMonths = 12;

  /// Long-term capital gains tax rate: 12.5%.
  static const equityLtcgRateBp = 1250;

  /// Annual LTCG exemption: Rs 1.25 lakh in paise.
  static const equityLtcgExemptionPaise = 125000 * 100;

  /// Short-term capital gains tax rate: 20%.
  static const equityStcgRateBp = 2000;

  // ── Debt (MF debt, bonds) — post-2023 rules ──────────────────────
  /// Holding period threshold for long-term classification.
  static const debtLtcgThresholdMonths = 36;

  /// Debt MF gains are taxed as income (slab rate), no indexation.
  static const debtTaxedAsIncome = true;
}
