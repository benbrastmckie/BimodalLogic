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
// Stamped from live source at commit b811bc100 (2026-08-17).
// ============================================================================

#let stamp-commit = "b811bc100"
#let stamp-date = "2026-08-17"

#let machine-axiom-count = 45
#let machine-rule-count = 7
#let machine-derived-op-count = 21

#let axiom-table = (
  ("prop_k", "Propositional", "φ, ψ, χ", "Base", "((φ → (ψ → χ)) → ((φ → ψ) → (φ → χ)))"),
  ("prop_s", "Propositional", "φ, ψ", "Base", "(φ → (ψ → φ))"),
  ("ex_falso", "Propositional", "φ", "Base", "(⊥ → φ)"),
  ("peirce", "Propositional", "φ, ψ", "Base", "(((φ → ψ) → φ) → φ)"),
  ("modal_t", "S5 Modal", "φ", "Base", "(□φ → φ)"),
  ("modal_4", "S5 Modal", "φ", "Base", "(□φ → □□φ)"),
  ("modal_b", "S5 Modal", "φ", "Base", "(φ → □(□(φ → ⊥) → ⊥))"),
  ("modal_5_collapse", "S5 Modal", "φ", "Base", "((□(□φ → ⊥) → ⊥) → □φ)"),
  ("modal_k_dist", "S5 Modal", "φ, ψ", "Base", "(□(φ → ψ) → (□φ → □ψ))"),
  ("serial_future", "BX Temporal", "", "Base", "((⊥ → ⊥) → U((⊥ → ⊥), (⊥ → ⊥)))"),
  ("serial_past", "BX Temporal", "", "Base", "((⊥ → ⊥) → S((⊥ → ⊥), (⊥ → ⊥)))"),
  ("left_mono_until_G", "BX Temporal", "φ, χ, ψ", "Base", "((U(((φ → χ) → ⊥), (⊥ → ⊥)) → ⊥) → (U(ψ, φ) → U(ψ, χ)))"),
  ("left_mono_since_H", "BX Temporal", "φ, χ, ψ", "Base", "((S(((φ → χ) → ⊥), (⊥ → ⊥)) → ⊥) → (S(ψ, φ) → S(ψ, χ)))"),
  ("right_mono_until", "BX Temporal", "φ, ψ, χ", "Base", "((U(((φ → ψ) → ⊥), (⊥ → ⊥)) → ⊥) → (U(φ, χ) → U(ψ, χ)))"),
  ("right_mono_since", "BX Temporal", "φ, ψ, χ", "Base", "((S(((φ → ψ) → ⊥), (⊥ → ⊥)) → ⊥) → (S(φ, χ) → S(ψ, χ)))"),
  ("connect_future", "BX Temporal", "φ", "Base", "(φ → (U((S(φ, (⊥ → ⊥)) → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("connect_past", "BX Temporal", "φ", "Base", "(φ → (S((U(φ, (⊥ → ⊥)) → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("enrichment_until", "BX Temporal", "φ, ψ, p", "Base", "(((p → (U(ψ, φ) → ⊥)) → ⊥) → U(((ψ → (S(p, φ) → ⊥)) → ⊥), φ))"),
  ("enrichment_since", "BX Temporal", "φ, ψ, p", "Base", "(((p → (S(ψ, φ) → ⊥)) → ⊥) → S(((ψ → (U(p, φ) → ⊥)) → ⊥), φ))"),
  ("self_accum_until", "BX Temporal", "φ, ψ", "Base", "(U(ψ, φ) → U(ψ, ((φ → (U(ψ, φ) → ⊥)) → ⊥)))"),
  ("self_accum_since", "BX Temporal", "φ, ψ", "Base", "(S(ψ, φ) → S(ψ, ((φ → (S(ψ, φ) → ⊥)) → ⊥)))"),
  ("absorb_until", "BX Temporal", "φ, ψ", "Base", "(U(((φ → (U(ψ, φ) → ⊥)) → ⊥), φ) → U(ψ, φ))"),
  ("absorb_since", "BX Temporal", "φ, ψ", "Base", "(S(((φ → (S(ψ, φ) → ⊥)) → ⊥), φ) → S(ψ, φ))"),
  ("linear_until", "BX Temporal", "φ, ψ, χ, θ", "Base", "(((U(ψ, φ) → (U(θ, χ) → ⊥)) → ⊥) → ((((U(((ψ → (θ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥)) → ⊥) → U(((ψ → (χ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥))) → ⊥) → U(((φ → (θ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥))))"),
  ("linear_since", "BX Temporal", "φ, ψ, χ, θ", "Base", "(((S(ψ, φ) → (S(θ, χ) → ⊥)) → ⊥) → ((((S(((ψ → (θ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥)) → ⊥) → S(((ψ → (χ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥))) → ⊥) → S(((φ → (θ → ⊥)) → ⊥), ((φ → (χ → ⊥)) → ⊥))))"),
  ("until_F", "BX Temporal", "φ, ψ", "Base", "(U(ψ, φ) → U(ψ, (⊥ → ⊥)))"),
  ("since_P", "BX Temporal", "φ, ψ", "Base", "(S(ψ, φ) → S(ψ, (⊥ → ⊥)))"),
  ("temp_linearity", "Additional BX Temporal", "φ, ψ", "Base", "(((U(φ, (⊥ → ⊥)) → (U(ψ, (⊥ → ⊥)) → ⊥)) → ⊥) → ((U(((φ → (ψ → ⊥)) → ⊥), (⊥ → ⊥)) → ⊥) → ((U(((φ → (U(ψ, (⊥ → ⊥)) → ⊥)) → ⊥), (⊥ → ⊥)) → ⊥) → U(((U(φ, (⊥ → ⊥)) → (ψ → ⊥)) → ⊥), (⊥ → ⊥)))))"),
  ("temp_linearity_past", "Additional BX Temporal", "φ, ψ", "Base", "(((S(φ, (⊥ → ⊥)) → (S(ψ, (⊥ → ⊥)) → ⊥)) → ⊥) → ((S(((φ → (ψ → ⊥)) → ⊥), (⊥ → ⊥)) → ⊥) → ((S(((φ → (S(ψ, (⊥ → ⊥)) → ⊥)) → ⊥), (⊥ → ⊥)) → ⊥) → S(((S(φ, (⊥ → ⊥)) → (ψ → ⊥)) → ⊥), (⊥ → ⊥)))))"),
  ("F_until_equiv", "Additional BX Temporal", "φ", "Base", "(U(φ, (⊥ → ⊥)) → U(φ, (⊥ → ⊥)))"),
  ("P_since_equiv", "Additional BX Temporal", "φ", "Base", "(S(φ, (⊥ → ⊥)) → S(φ, (⊥ → ⊥)))"),
  ("modal_future", "Modal-Temporal Interaction", "φ", "Base", "(□φ → □(U((φ → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("discrete_symm_fwd", "Uniformity", "", "Base", "(U((⊥ → ⊥), ⊥) → S((⊥ → ⊥), ⊥))"),
  ("discrete_symm_bwd", "Uniformity", "", "Base", "(S((⊥ → ⊥), ⊥) → U((⊥ → ⊥), ⊥))"),
  ("discrete_propagate_fwd", "Uniformity", "", "Base", "(U((⊥ → ⊥), ⊥) → (U((U((⊥ → ⊥), ⊥) → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("discrete_propagate_bwd", "Uniformity", "", "Base", "(U((⊥ → ⊥), ⊥) → (S((U((⊥ → ⊥), ⊥) → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("discrete_box_necessity", "Uniformity", "", "Base", "(U((⊥ → ⊥), ⊥) → □U((⊥ → ⊥), ⊥))"),
  ("prior_UZ", "Prior", "φ", "Discrete", "(U(φ, (⊥ → ⊥)) → U(φ, (φ → ⊥)))"),
  ("prior_SZ", "Prior", "φ", "Discrete", "(S(φ, (⊥ → ⊥)) → S(φ, (φ → ⊥)))"),
  ("z1", "Z1", "φ", "Discrete", "((U((((U((φ → ⊥), (⊥ → ⊥)) → ⊥) → φ) → ⊥), (⊥ → ⊥)) → ⊥) → (U((U((φ → ⊥), (⊥ → ⊥)) → ⊥), (⊥ → ⊥)) → (U((φ → ⊥), (⊥ → ⊥)) → ⊥)))"),
  ("density", "Density", "φ", "Dense", "((U(((U((φ → ⊥), (⊥ → ⊥)) → ⊥) → ⊥), (⊥ → ⊥)) → ⊥) → (U((φ → ⊥), (⊥ → ⊥)) → ⊥))"),
  ("dense_indicator", "Density", "", "Dense", "(U((⊥ → ⊥), ⊥) → ⊥)"),
  ("prior_U_gap", "Reynolds Dedekind", "φ", "Dedekind", "(((U((⊥ → ⊥), φ) → (U((φ → ⊥), (⊥ → ⊥)) → ⊥)) → ⊥) → U((((φ → ⊥) → ⊥) → (U((⊥ → ⊥), ((φ → ⊥) → ⊥)) → ⊥)), φ))"),
  ("prior_S_gap", "Reynolds Dedekind", "φ", "Dedekind", "(((S((⊥ → ⊥), φ) → (S((φ → ⊥), (⊥ → ⊥)) → ⊥)) → ⊥) → S((((φ → ⊥) → ⊥) → (S((⊥ → ⊥), ((φ → ⊥) → ⊥)) → ⊥)), φ))"),
  ("sep", "Reynolds Dedekind", "φ", "Dedekind", "((((U((⊥ → ⊥), (φ → ⊥)) → ⊥) → (((U((⊥ → ⊥), (((φ → (U(φ, (φ → ⊥)) → ⊥)) → ⊥) → ⊥)) → ⊥) → ⊥) → ⊥)) → ⊥) → (U((⊥ → ⊥), ((((U((⊥ → ⊥), (φ → ⊥)) → ⊥) → ((S((⊥ → ⊥), (φ → ⊥)) → ⊥) → ⊥)) → ⊥) → ⊥)) → ⊥))"),
)

#let rule-table = (
  ("axiom", "—", "Γ ⊢[fc] φ", "φ is an instance of an axiom schema with minFrameClass ≤ fc"),
  ("assumption", "—", "Γ ⊢[fc] φ", "φ ∈ Γ"),
  ("modus_ponens", "Γ ⊢[fc] φ → ψ; Γ ⊢[fc] φ", "Γ ⊢[fc] ψ", "—"),
  ("necessitation", "⊢[fc] φ", "⊢[fc] □φ", "empty context only (theorems)"),
  ("temporal_necessitation", "⊢[fc] φ", "⊢[fc] Gφ", "empty context only (theorems)"),
  ("temporal_duality", "⊢[fc] φ", "⊢[fc] swapTemporal φ", "empty context only (theorems)"),
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
