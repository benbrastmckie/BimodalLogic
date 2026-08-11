# Phase 14 Summary — Retarget `TruthAt`'s box clause to totality

## Outcome

`implemented (skeleton)`. The semantic heart of the refactor has landed: `TruthAt`'s box clause
now quantifies over the **total** histories, per `def:BL-semantics`'s box clause verbatim —
"M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ for all σ ∈ H_F" — with no `Ω` and no shift-closure side condition.

The tree is **red by design** at this phase boundary, with a fully enumerated break set (below).
Phases 15-17 are the scheduled repairs.

## What changed

`FormalSystem/Semantics/Truth.lean`:

- **Box clause**: `∀ σ, σ ∈ Omega → …` became `∀ (σ : WorldHistory F), σ.IsTotal → …`. The target
  predicate is `WorldHistory.IsTotal` (`∀ t, τ.domain t`), **not** Mathlib's `IsMax`.
- **`Omega` renamed `_Omega`** in `TruthAt`'s binder, with a docstring recording that it is a
  transient carrier scheduled for deletion in the terminal reverse-topological sweep — never a
  shipped shim, and that no new declaration may acquire a meaning depending on it.
- **`untl`/`snce` untouched in shape**, with a docstring note recording the **event-first /
  guard-second** convention and the fact that `def:BLplus-semantics`'s footnote describes it
  backwards. Cross-references `specs/decisions/untl-snce-argument-order.md`. The Lean convention
  was deliberately preserved.
- **Atom clause's `∃ (ht : τ.domain t)` retained**, with the Decision A rationale documented:
  under totality the conjunct is vacuously satisfiable at every `t`, so the two readings agree on
  `H_F`, and the conjunct is what keeps `TruthAt` meaningful at the partial histories the
  extension machinery still traffics in.
- **`Truth.box_iff`** restated against totality.
- **`truth_double_shift_cancel`** (plan called it `truth'_double_shift_cancel`; no prime exists):
  box case is now `simp only [TruthAt]` alone with **no residual goal**, exactly as the plan
  predicted, because both sides quantify over the same `IsTotal` predicate.
- **`TimeShift.time_shift_preserves_truth`** restated with **no `ShiftClosed` hypothesis**. The
  box case's `h_sc ρ h_rho_mem (y - x)` became `WorldHistory.isTotal_timeShift h_rho_tot (y - x)`,
  definitionally `fun t => hρ (t + Δ)`. The resulting statement is strictly stronger than the one
  it replaces.
- **`TimeShift.exists_shifted_history`** likewise loses `h_sc` (forced; not in the plan's list).
- **`ShiftClosed`'s docstring** marked no-longer-load-bearing and scheduled for deletion.

Call-site `h_sc` drops (8 sites, **Scope Hypothesis of 8 confirmed exactly**):
`Soundness.lean:265`; `DenseValidity.lean:206`, `:858`; `Decidable.lean:655`, `:666`, `:1509`;
and — omitted from the plan's enumeration but genuinely live — `Bridge/Omega.lean:348`, `:388`.

## The one strategic sorry

`FormalSystem/Semantics/Validity.lean:458`, `valid_of_valid_box`.

This is a seam, not a gap. `TruthAt`'s box clause now binds `σ.IsTotal`; `valid` still binds
`τ ∈ Omega`. Instantiating the box hypothesis at `σ := τ` requires `τ.IsTotal`, and `τ ∈ Omega`
does not yield it under any hypothesis in scope. The theorem is **not provable as stated** until
the validity-layer binder delta (Phase 18) replaces `(τ : WorldHistory F) (_ : τ ∈ Omega)` with
`(τ : WorldHistory F) (hτ : τ.IsTotal)` throughout `valid`/`satisfiable`/consequence. The
docstring records the seam, names the owner, and gives the exact one-line proof that becomes
valid once the delta lands.

Landing this skeleton rather than reverting the retarget is what made the downstream census
possible at all: `Validity.lean` is a hub, and all 12 break sites sit behind it.

## Downstream breakage — the headline finding

**12 error sites in exactly 4 files.** Nothing else in the tree breaks.

| File | Sites | Error family | Repair shape | Owner |
|------|-------|--------------|--------------|-------|
| `Metalogic/SoundnessLemmas/DenseValidity.lean` | `:55`, `:90`, `:735`, `:752` | A: `τ ∈ Omega` supplied where `τ.IsTotal` needed | Supply totality for the history the box hypothesis is instantiated at; ultimately subsumed by the Phase 18 validity binder delta | Phase 15 |
| `Metalogic/SoundnessLemmas/DenseValidity.lean` | `:205`, `:247`, `:857`, `:1278` | B: `σ.IsTotal` supplied where `σ ∈ Omega` needed | The bound variable is now total; drop the `ShiftClosed` detour (`h_sc σ …`) entirely — `time_shift_preserves_truth` no longer needs it | Phase 15 |
| `Automation/PrefilterSoundness.lean` | `:96` | A | Same as family A above | Phase 15 |
| `Metalogic/Algebraic/FlowFrame.lean` | `:662` | `rcases` on `h_σ_mem : ∀ t, σ.domain t` — the destructuring assumed Ω-membership's structure | Rewrite along `bundleFlowOmega_eq_total` (Phase 11's bridge equation) before destructuring | Phase 16 |
| `Metalogic/Algebraic/FlowFrame.lean` | `:672` | A (`bundleFlowHistory_mem_omega` returns membership, totality wanted) | Route through `bundleFlowOmega_eq_total` to convert the membership witness into a totality witness | Phase 16 |
| `Metalogic/Decidability/Verified/Bridge/Interpolate.lean` | `:504` | B | Convert the totality witness to Ω-membership via the relevant `*_eq_total` bridge, or drop the Ω detour | Phase 17 |

**Two facts that should resize Phases 15-17 downward:**

1. **`Metalogic/Soundness.lean` contributes ZERO errors of its own.** `lake build
   FormalSystem.Metalogic.Soundness` fails solely on upstream `DenseValidity.lean`. The plan sized
   Phase 15 against "70 declarations in `Soundness.lean`'s Omega/validity blast radius"; the
   actual repair set in that file is empty. The charter's prediction that soundness consumes
   shift-preservation (not Zorn extension), and that the totality version is strictly easier, is
   borne out — the `ShiftClosed` hypothesis simply evaporated without leaving work behind.
2. **`Bridge/Omega.lean`, `Bridge/TruthLemma.lean` and `Verified/Decidable.lean` likewise
   contribute ZERO errors of their own** — all three fail only on upstream `Interpolate.lean:504`.
   Phase 17's decidability-side repair may be a single site plus the `truthAt_box_iff` restatement.

`FrameConditions/Validity.lean` builds **green** unedited; `FrameConditions/Soundness.lean` is
blocked only upstream. Phase 15's group (C) inventory is correspondingly thinner than estimated.

## Verification

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Semantics.Truth` | green (754 jobs) |
| `lake build FormalSystem.Semantics.Validity` | green (757 jobs) |
| `lake build FormalSystem.FrameConditions.Validity` | green (866 jobs), unedited |
| `lake build` (tree) | RED — 12 sites, 4 files, enumerated above |
| Sorries in `FormalSystem/` | 2: the new tracked strategic one, plus pre-existing `WeakCanonical/Transfer.lean:1085` (untouched) |
| Vacuous definitions | 0 (the one grep hit, `Examples/TemporalStructures.lean:284 int_domain_universal … := trivial`, is a genuine proof that `intTimeHistory`'s domain is universal — pre-existing and untouched) |
| `axiom` count | 6 — unchanged from the Phase 13 baseline |

The pre-existing `lake build BimodalTest` `#guard_msgs` mismatches were **not** re-baselined and
were not investigated, per the dispatch caveat; nothing in this phase changes a tableau-engine
`#eval` expectation.

## Deviations from the plan

- **`FormalSystem/Semantics/TimeShift.lean` does not exist.** The `TimeShift` namespace lives
  inside `Truth.lean`. All work assigned to it was done there; nothing was dropped.
- **`truthAt_box_iff`** was read as `Truth.box_iff` in `Truth.lean` (in scope). The identically
  named `Bridge/Omega.lean:342` was left to Phase 17, which owns the decidability-side box repair
  and the `regionOmega_eq_total` rewrite. That file currently has zero errors of its own.
- **The Scope Hypothesis's count of 8 is right; its enumeration was not** — it omitted
  `Bridge/Omega.lean:348` and `:388`.
- **Downstream doc references** describing proofs that Phases 15-17 will rewrite were left alone
  rather than made to describe a state those proofs are not yet in.
