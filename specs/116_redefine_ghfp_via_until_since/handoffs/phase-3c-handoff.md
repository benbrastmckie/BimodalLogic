# Phase 3c Handoff — Fix Final Downstream Files

**Session**: sess_1779159757_8a4784
**Date**: 2026-05-18
**Phase**: 3 (continued)
**Status**: Phase 3 still IN PROGRESS — 54 errors remain across 5 files

## What Was Done

### Files Fixed (8 files, all compile cleanly)

1. **ParametricTruthLemma.lean** — Removed `| all_future`/`| all_past` induction arms from both truth lemma proofs (parametric and shifted). 4 errors fixed.

2. **RestrictedParametricTruthLemma.lean** — Same fix: removed `| all_future`/`| all_past` induction arms from both truth lemma proofs. 4 errors fixed.

3. **SuccRelation.lean** — 4 errors fixed:
   - `G_neg_implies_not_F`: replaced `rfl` duality with `some_future_all_future_neg_absurd`
   - `neg_FF_implies_GG_neg_in_mcs`: completely rewritten using MCS negation completeness + BX3/DNE chain (old proof relied on structural equality `¬FF = GG¬`)
   - `H_neg_implies_not_P`: replaced `rfl` duality with `some_past_all_past_neg_absurd`
   - `neg_PP_implies_HH_neg_in_mcs`: completely rewritten (mirror of future case)

4. **Frame.lean (BXCanonical)** — 2 errors fixed:
   - `g_content_set_consistent`: replaced `set_consistent_not_both` with `some_future_all_future_neg_absurd`
   - `h_content_set_consistent`: replaced with `some_past_all_past_neg_absurd`

5. **OrderedSeedConsistency.lean** — 1 error fixed: replaced `set_consistent_not_both` with `some_future_all_future_neg_absurd`

6. **CanonicalTaskRelation.lean** — 2 errors fixed: updated `some_future_complexity` and `some_past_complexity` from `5 + phi.complexity` to `4 + phi.complexity` (new def: `untl phi top` has complexity 4+phi, not 5+phi). Updated iter_F/P complexity formulas to match.

7. **TruthLemma.lean (BXCanonical)** — 2 errors fixed: rewrote `F_from_witness` and `P_from_witness` using `neg_some_future_to_all_future_neg` / `neg_some_past_to_all_past_neg`.

8. **RRelation.lean (partially)** — 2 of 9 errors fixed: rewrote `c4_hard_case_G_neg_delta` and `c4'_hard_case_H_neg_delta` using duality conversion helpers.

### New Helper Lemmas Added

In **WitnessSeed.lean**:
- Made `some_future_all_future_neg_absurd` and `some_past_all_past_neg_absurd` public (were `private`)
- Added `neg_some_future_to_all_future_neg`: `¬F(φ) ∈ M → G(¬φ) ∈ M`
- Added `neg_some_past_to_all_past_neg`: `¬P(φ) ∈ M → H(¬φ) ∈ M`

## What Remains

### 54 errors across 5 files

| File | Errors | Category |
|------|--------|----------|
| Realization.lean | 29 | induction arms + rfl duality + injection |
| ReflexiveCanonical.lean | 11 | rfl duality (set_consistent_not_both) |
| RRelation.lean | 7 | rfl duality (neg_excludes, neg-neg patterns) |
| RootScopedChain.lean | 4 | cascade from Realization/RRelation |
| SuccExistence.lean | 3 | structural SubformulaClosure issue |

### Error Categories

**Category 1: Induction arms (easy)** — Remove `| all_future`/`| all_past` arms. Found in Realization.lean (~6 errors).

**Category 2: rfl duality (medium)** — Replace `set_consistent_not_both`/`neg_excludes`/`double_neg_elim` with the new helpers from WitnessSeed. Found in ReflexiveCanonical (~11), RRelation (~7), Realization (~8). Each requires identifying which helper to use.

**Category 3: Structural SubformulaClosure (hard, design change)** — SuccExistence.lean `p_step_blocking_restricted_subset_deferralClosure` (3 errors). The proof assumes `H(¬χ)` is a structural subformula of `P(χ)` (true when `P(χ) = ¬H(¬χ)`, false now that `P(χ) = snce χ top`). Fix requires extending `baseDeferralClosure` in SubformulaClosure.lean to include a `pastBlockingSet` (H(¬χ) for each P(χ)) and `futureBlockingSet` (G(¬χ) for each F(χ)), then fixing ~10 downstream membership proofs that unfold baseDeferralClosure.

**Category 4: Deep structural (hard)** — RRelation.lean lines 1270-1359: proofs that `F(H(¬α))` contradicts `G(P(α))` in an MCS. These relied on `F(X) = ¬G(¬X)` and `P(α) = ¬H(¬α)` being definitional. Now requires proving `⊢ P(α) → ¬H(¬α)` (via BX3'+DNI+DNI) and lifting through G/F.

### Recommended Approach for Next Session

1. **Start with Category 1** (induction arms in Realization.lean) — mechanical, removes ~6 errors.

2. **Then Category 2** (duality fixes) — systematic, removes ~26 errors. Pattern:
   - `set_consistent_not_both X h_X h_F` where `h_F : some_future _ ∈ M` → use `some_future_all_future_neg_absurd`
   - `set_consistent_not_both X h_X h_P` where `h_P : some_past _ ∈ M` → use `some_past_all_past_neg_absurd`
   - `neg_excludes ... h_F` where `h_F : some_future _ ∈ M` → derive contradiction differently
   - `double_neg_elim ... h_neg_F` → use `neg_some_future_to_all_future_neg` / `neg_some_past_to_all_past_neg`

3. **Then Category 3** (SubformulaClosure extension) — requires:
   - Add `futureBlockingSet` and `pastBlockingSet` to `baseDeferralClosure`
   - Fix all downstream membership proofs (~10 in SubformulaClosure.lean)
   - Fix SuccExistence.lean `p_step_blocking_restricted_subset_deferralClosure`

4. **Finally Category 4** (deep structural in RRelation.lean) — requires deriving `⊢ P(α) → ¬H(¬α)` at the proof system level, then using K-distribution to lift through G/F.

### Key Design Insight

The fundamental issue is that under the new definitions:
- `F(φ) = untl φ top` (an `untl` term)
- `G(φ) = (some_future φ.neg).neg` (an `imp` term wrapping `untl`)
- `¬F(φ) ≠ G(¬φ)` structurally (but semantically equivalent)
- `P(φ) ≠ ¬H(¬φ)` structurally (but semantically equivalent)

All proof system conversions between these forms must go through BX3/BX3' (right_mono_until/since) combined with DNE/DNI. The helpers `neg_some_future_to_all_future_neg` and `neg_some_past_to_all_past_neg` handle the MCS-level conversion.

## Build State

- Total errors: 54 across 5 files
- Sorry count: 471 (below 506 baseline)
- No new sorries introduced
- No new axioms introduced
- All previously-fixed files (from phases 3a, 3b, 3c) compile cleanly
