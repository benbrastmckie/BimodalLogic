// ============================================================================
// generated/machine-appendix.typ
//
// GENERATED FILE -- never edit by hand. Regenerate via:
//   bash scripts/typst-machine-appendix.sh
//
// Rendered strictly from generated/machine-appendix.jsonl (same script),
// which is produced by the Lean exporter (interpreted via `lake env lean
// --run`) with schema formulas extracted from the Axiom type index --
// never hand-copied.
// Stamped from live source at commit de8a7e472 (2026-10-14).
// ============================================================================

#let stamp-commit = "de8a7e472"
#let stamp-date = "2026-10-14"

#let machine-axiom-count = 20
#let machine-rule-count = 7
#let machine-derived-op-count = 21

#let axiom-table = (
  ("prop_k", "Propositional", "φ, ψ, χ", "Base", "((φ → (ψ → χ)) → ((φ → ψ) → (φ → χ)))"),
  ("prop_s", "Propositional", "φ, ψ", "Base", "(φ → (ψ → φ))"),
  ("ex_falso", "Propositional", "φ", "Base", "(⊥ → φ)"),
  ("peirce", "Propositional", "φ, ψ", "Base", "(((φ → ψ) → φ) → φ)"),
  ("modal_t", "S5 Modal", "φ", "Base", "(□φ → φ)"),
  ("modal_5_collapse", "S5 Modal", "φ", "Base", "((□(□φ → ⊥) → ⊥) → □φ)"),
  ("modal_k_dist", "S5 Modal", "φ, ψ", "Base", "(□(φ → ψ) → (□φ → □ψ))"),
  ("serial_future", "BX Temporal", "", "Base", "U((⊥ → ⊥), (⊥ → ⊥))"),
  ("left_mono_until_G", "BX Temporal", "φ, χ, ψ", "Base", "((U(((φ → χ) → ⊥), (⊥ → ⊥)) → ⊥) → (U(ψ, φ) → U(ψ, χ)))"),
  ("right_mono_until", "BX Temporal", "φ, ψ, χ", "Base", "((U(((φ → ψ) → ⊥), (⊥ → ⊥)) → ⊥) → (U(φ, χ) → U(ψ, χ)))"),
  ("enrichment_until", "BX Temporal", "φ, ψ, p", "Base", "(((p → (U(ψ, φ) → ⊥)) → ⊥) → U(((ψ → (S(p, φ) → ⊥)) → ⊥), φ))"),
  ("self_accum_until", "BX Temporal", "φ, ψ", "Base", "(U(ψ, φ) → U(ψ, ((φ → (U(ψ, φ) → ⊥)) → ⊥)))"),
  ("absorb_until", "BX Temporal", "φ, ψ", "Base", "(U(((φ → (U(ψ, φ) → ⊥)) → ⊥), φ) → U(ψ, φ))"),
  ("linear_until", "BX Temporal", "φ, ψ, χ, θ", "Base", "(((U(ψ, φ) → (U(θ, χ) → ⊥)) → ⊥) → ((U(((ψ → (θ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥)) → ⊥) → ((U(((ψ → (χ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥)) → ⊥) → U(((φ → (θ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥)))))"),
  ("modal_future", "Modal-Temporal Interaction", "φ", "Base", "(□φ → □(U((φ → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("discrete_box_necessity", "Uniformity", "", "Base", "(U((⊥ → ⊥), ⊥) → □U((⊥ → ⊥), ⊥))"),
  ("prior_UZ", "Prior", "φ", "ZTime", "(U(φ, (⊥ → ⊥)) → U(φ, (φ → ⊥)))"),
  ("dense_indicator", "Density", "", "Dense", "(U((⊥ → ⊥), ⊥) → ⊥)"),
  ("prior_U_gap", "Reynolds Dedekind", "φ", "RTime", "(((U((⊥ → ⊥), φ) → (U((φ → ⊥), (⊥ → ⊥)) → ⊥)) → ⊥) → U((((φ → ⊥) → ⊥) → (U((⊥ → ⊥), ((φ → ⊥) → ⊥)) → ⊥)), φ))"),
  ("sep", "Reynolds Dedekind", "φ", "RTime", "((((U((⊥ → ⊥), (φ → ⊥)) → ⊥) → (((U((⊥ → ⊥), (((φ → (U(φ, (φ → ⊥)) → ⊥)) → ⊥) → ⊥)) → ⊥) → ⊥) → ⊥)) → ⊥) → (U((⊥ → ⊥), ((((U((⊥ → ⊥), (φ → ⊥)) → ⊥) → ((S((⊥ → ⊥), (φ → ⊥)) → ⊥) → ⊥)) → ⊥) → ⊥)) → ⊥))"),
)

#let rule-table = (
  ("axiom", "—", "Γ ⊢[fc] φ", "φ is an instance of an axiom schema with minFrameClass ≤ fc"),
  ("assumption", "—", "Γ ⊢[fc] φ", "φ ∈ Γ"),
  ("modus_ponens", "Γ ⊢[fc] φ → ψ; Γ ⊢[fc] φ", "Γ ⊢[fc] ψ", "—"),
  ("necessitation", "⊢[fc] φ", "⊢[fc] □φ", "empty context only (theorems)"),
  ("temporal_necessitation", "⊢[fc] φ", "⊢[fc] Gφ", "empty context only (theorems)"),
  ("time_reflection", "⊢[fc] φ", "⊢[fc] reflectTime φ", "empty context only (theorems)"),
  ("weakening", "Γ ⊢[fc] φ", "Δ ⊢[fc] φ", "Γ ⊆ Δ"),
)

#let derived-op-table = (
  ("top", "", "(⊥ → ⊥)"),
  ("neg", "φ", "(φ → ⊥)"),
  ("someFuture", "φ", "U(φ, (⊥ → ⊥))"),
  ("somePast", "φ", "S(φ, (⊥ → ⊥))"),
  ("allFuture", "φ", "(U((φ → ⊥), (⊥ → ⊥)) → ⊥)"),
  ("allPast", "φ", "(S((φ → ⊥), (⊥ → ⊥)) → ⊥)"),
  ("and", "φ, ψ", "((φ → (ψ → ⊥)) → ⊥)"),
  ("or", "φ, ψ", "((φ → ⊥) → ψ)"),
  ("diamond", "φ", "(□(φ → ⊥) → ⊥)"),
  ("always", "φ", "(((S((φ → ⊥), (⊥ → ⊥)) → ⊥) → (((φ → ((U((φ → ⊥), (⊥ → ⊥)) → ⊥) → ⊥)) → ⊥) → ⊥)) → ⊥)"),
  ("next", "φ", "U(φ, ⊥)"),
  ("prev", "φ", "S(φ, ⊥)"),
  ("weakFuture", "φ", "((φ → ((U((φ → ⊥), (⊥ → ⊥)) → ⊥) → ⊥)) → ⊥)"),
  ("weakPast", "φ", "((φ → ((S((φ → ⊥), (⊥ → ⊥)) → ⊥) → ⊥)) → ⊥)"),
  ("release", "φ, ψ", "(U((φ → ⊥), (ψ → ⊥)) → ⊥)"),
  ("weakUntil", "φ, ψ", "((U(φ, ψ) → ⊥) → (U((ψ → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("trigger", "φ, ψ", "(S((φ → ⊥), (ψ → ⊥)) → ⊥)"),
  ("weakSince", "φ, ψ", "((S(φ, ψ) → ⊥) → (S((ψ → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("strongRelease", "φ, ψ", "U(((ψ → (φ → ⊥)) → ⊥), ψ)"),
  ("strongTrigger", "φ, ψ", "S(((ψ → (φ → ⊥)) → ⊥), ψ)"),
  ("sometimes", "φ", "((((S(((φ → ⊥) → ⊥), (⊥ → ⊥)) → ⊥) → ((((φ → ⊥) → ((U(((φ → ⊥) → ⊥), (⊥ → ⊥)) → ⊥) → ⊥)) → ⊥) → ⊥)) → ⊥) → ⊥)"),
)
