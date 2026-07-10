# Task 333 Phase 3 Implementation Summary — Per-σ Kit Application

- **Task**: 333, Phase 3 only (single-phase hard-mode dispatch)
- **Plan**: `plans/06_route-a-grouped-extraction.md` (v4), Phase 3
- **Session**: sess_1783679696_817168
- **Date**: 2026-07-10
- **Outcome**: Phase 3 [COMPLETED] — green, axiom-clean, 0 sorries

## What Landed (all at the tail of `SharedWitness.lean`)

| Theorem | Role | Axioms |
|---|---|---|
| `kvE2_sepBundleL_sound` | Left-class kit application: `kvE2_sepBundleL_parts` → `kvE_subBracket2V_sound_of_parts`, `hgate` threaded verbatim (the `sound_of_outer` composition pattern) | `[propext, Classical.choice, Quot.sound]` |
| `kvE2_sepBundleR_sound` | Right-class kit-application lemma (the plan's anticipated mitigation for the MEDIUM-risk residual): geometry-correct mirror of the closer, gate-backward exempting `kvE2_sep_zWX1` | same |
| `kvE2_sepBody_kit_sound` | Aggregate: hypothesis-free `kvE2_sepBody_extract` + both appliers → per-σ `nf_eval` at the extracted shared pivot (the Phase 4 input shape) | same |

## The Right-Interior Residual — Resolution Record

The plan flagged one genuine question: does the right-class bundle discharge into the landed
closer? **No — refuted by three signature reads** (each machine-grounded on HEAD source):

1. `kvE_subBracket2V_sound_of_parts`'s `hgate` conclusion opens with `a < w`
   (SubBracket2V:1305); `kvE2_sepBundleR` supplies its anchor with `w < x1`. Feeding the
   right anchor makes the gate's conclusion contain `x1 < w` against known `w < x1` — a
   truthful gate can never be supplied, so the closer applies only vacuously to this class.
2. `kvE2_sepBundleR_parts` (SW:5376) deliberately drops the below-clause — there is no
   `hbelow` in the closer's `kvE_sub2_zXU` shape for this class.
3. The right bundle's witnesses live in `kvE2_sep_zWX1` (`w < v < x1`); for right-interior
   geometry, `kvE_sub2_zXU` reads `x < v < w` (SW zone-constant header, SW:100-105) — a
   disjoint region.

**Resolution** (exactly the plan's mitigation): `kvE2_sepBundleR_sound` proved from scratch
in `SharedWitness.lean` (333 territory) against the same engine `nf_eval_depth1_fold_iff`
(CarrierKv:466), mirroring the closer's body with the `kvE2_sep_zWX1` case discharged by the
bundle's own witnesses under `x < w < u < x1 < t`. The left closer's `a < w ∧ w < t` head
conjuncts are intentionally not mirrored (right geometry carries `w < a`, `a < t` as gate
antecedents; `x < w` is the lemma hypothesis) — Phase 4's gate provider supplies a leaner
4-conjunct right gate. NO filter weakened; `hgate` never assumed (explicit Amendment-F3
hypothesis in all three lemmas); SubBracket2V untouched.

## Bit Self-Ownership Confirmation

Every `σ.2 (nf0_assemble … χ σ.1) = true` occurrence in the new code is the *antecedent* of
that same σ's `bit ⟹ witness` implication (bundle `hbelow` clauses, gate forward/backward
clauses). No cross-σ bit goal exists anywhere; the task-321 R3 trap (treating a forward-zone
conjunct as a proof obligation) was not re-entered.

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`:
  green (1013 jobs; pre-existing warnings only).
- Sorry census (territory file): **0** live sorries.
- `lean_verify` on all three new symbols: `[propext, Classical.choice, Quot.sound]`, no
  `sorryAx`.
- LITMUS grep: 0 live hits; **zero-delta vs pre-session baseline including prose**.
- Vacuous definitions: 0. New axioms: 0. New `md:NN` citations: 0.
- Diff scope: Lean diff touches only `SharedWitness.lean`; carrier structure and all
  do-not-edit assets byte-identical.

## Plan Deviations

- Phase 3 task 3 *(altered)*: right class landed via the mirrored kit-application lemma
  rather than the direct closer feed — the exact contingency the plan authorized, with the
  refutation record inline in the plan checklist.
- Phase 3 task 1 materialized as the aggregate `kvE2_sepBody_kit_sound` (per-σ realizations
  at the shared pivot), giving Phase 4 its input in one lemma.

## Commits

- `0e156a7a8` — task 333 phase 3.1: left-class kit application `kvE2_sepBundleL_sound`
- `163d6b700` — task 333 phase 3.2: right-class mirrored kit application + per-σ aggregate
- (wrap-up commit follows: plan annotations + handoff + this summary)

## Next

Phase 4 (`kvE2_outer_fold`, THE make-or-break) — see
`handoffs/phase-3-handoff-20260710-kit-application.md` for the immediate next action and the
gate-family shapes Phase 4's provider must supply.
