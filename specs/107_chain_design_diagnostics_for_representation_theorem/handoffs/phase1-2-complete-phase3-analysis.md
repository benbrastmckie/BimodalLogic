# Handoff: Phases 1-2 Complete, Phase 3 Analysis

## Session ID
sess_1777999912_7fcbe9

## What Was Done

### Phase 1: Fix Build Error [COMPLETED]
- Restructured the `by_cases h_cons : SetConsistent ({xi} ∪ B)` block in `lemma_2_7` (PointInsertion.lean)
- Moved the `by_cases` OUTSIDE the `have h_xi_consistent` block (previously nested inside `intro L hL ⟨d⟩` where the goal was `False`)
- In the consistent case: `h_xi_consistent` is derived trivially via `SetConsistent_of_subset Set.subset_union_left h_cons`
- In the inconsistent case: `sorry` (sorry #3, Phase 5)
- Steps 7-10 are now inside the consistent branch of the `by_cases`
- **Build passes with 0 errors, sorry count unchanged at 12**

### Phase 2: Add `linear_until_mcs` Infrastructure [COMPLETED]
- Added `or_elim_mcs` (local MCS disjunction elimination, needed because `SetMaximalConsistent.disjunction_elim` is in Completeness.lean which isn't imported and would create circular deps)
- Added `linear_until_mcs` (BX7 MCS wrapper) after `conj_mcs` (the new theorems use `conj_mcs`, so must be placed after it)
- Added `linear_since_mcs` (BX7' MCS wrapper, dual for Since)
- Both compile without sorry, build passes
- **Location**: Lines 219-262 of PointInsertion.lean (after `conj_mcs` at line 210)

### Phase 3: Lemma 2.6 Pos Sub-case Analysis [PARTIAL - analysis only]
- Sorry #1 is at line 1945 in `burgess_D0_finite_subset_consistent_incons`
- This function proves seed consistency when {beta}∪B is INconsistent (so beta.neg ∈ B)
- The pos sub-case has `untl(b∧β, γ_hat) ∈ A` where `b` includes β.neg as a conjunct
- Since `⊢ (b∧β) → ⊥` (b contains β.neg), left_mono gives `untl(⊥, γ_hat) ∈ A`
- From left_mono + EFQ: `untl(r, γ_hat) ∈ A` for ANY formula r

## Phase 3 Analysis: Why the Pos Sub-case Is Hard

### Core Difficulty
The neg sub-case uses `burgess_zeta_consistent` which requires `(untl(b∧β, γ_hat)).neg ∈ A` to apply BX14 (separation). In the pos sub-case, we have the POSITIVE formula, so BX14 doesn't apply directly.

Moreover, `untl(r, γ_hat) ∈ A` for ALL r means NO neg-until formula `(untl(r, γ_hat)).neg ∈ A` exists for any r with event γ_hat. So BX14 with event γ_hat is impossible.

### The Plan's Strategy (Case A / Case B)
The plan proposes case-splitting on whether B is MCS:

**Case A (B not MCS):**
1. Find delta' ∉ B with {delta'}∪B consistent (exists since B is DCS but not MCS — there exists phi with phi ∉ B and phi.neg ∉ B, and by contrapositive of `neg_mem_of_inconsistent_union`, {phi}∪B is consistent)
2. Apply `BurgessR3Maximal_extension_fails` with delta' to get neg-until witness: ∃ beta0 ∈ B, gamma0 ∈ C, `(untl(beta0∧delta', gamma0)).neg ∈ A`
3. Add gamma0 to c_list, forming γ_hat' with `⊢ γ_hat' → gamma0`
4. From `untl(⊥, γ_hat') ∈ A` + left_mono: `untl(beta0∧delta', γ_hat') ∈ A`
5. From right_mono with `⊢ γ_hat' → gamma0`: `untl(beta0∧delta', gamma0) ∈ A`
6. Contradiction with step 2

**Case B (B is MCS):**
B itself serves as MCS D directly. Return the splitting triple bypassing seed construction.

### Critical Implementation Issue
The c_list is constructed BEFORE the pos/neg case split (line 1934). Adding gamma0 to c_list changes γ_hat, which changes the formula in the case split. The entire proof structure needs to be restructured:

**Option 1 (recommended):** Move the Case A/B case-split BEFORE the c_list construction. In Case A, get the witness first, then construct c_list including gamma0. Then do the pos/neg case split with the modified γ_hat.

**Option 2:** Keep the existing structure but in the pos sub-case, construct a SEPARATE c_list' with gamma0 added, form γ_hat', and derive `untl(⊥, γ_hat') ∈ A` from `untl(⊥, γ_hat) ∈ A` using right_mono with `⊢ γ_hat → γ_hat'`... but wait, this direction is wrong. We need `⊢ γ_hat → γ_hat'` where γ_hat' has MORE conjuncts than γ_hat. But more conjuncts means STRONGER, so `⊢ γ_hat' → γ_hat`, not the reverse. We'd need `⊢ γ_hat → γ_hat'` which doesn't hold.

Actually, for left_mono: `untl(⊥, γ_hat) ∈ A` doesn't directly give `untl(⊥, γ_hat') ∈ A`. We'd need right_mono with `⊢ γ_hat → γ_hat'`, but γ_hat' = γ_hat ∧ gamma0 and `⊢ γ_hat → γ_hat ∧ gamma0` requires `⊢ γ_hat → gamma0` which we don't have.

Wait -- we can use left_mono on `untl(⊥, γ_hat)` to get `untl(⊥, γ_hat) ∈ A`, and SEPARATELY get `untl(⊥, gamma0) ∈ A` via left_mono on `untl(⊥, γ_hat)` + ... no, left_mono changes the GUARD, not the event.

We can use `right_mono_until_mcs` on `untl(⊥, γ_hat)` with `⊢ γ_hat → gamma0` ONLY IF `⊢ γ_hat → gamma0`. Since gamma0 is NOT a conjunct of γ_hat, this doesn't hold.

So Option 2 doesn't work directly. **Option 1 is the correct approach.**

**Option 3 (alternative):** Instead of restructuring, observe that from `untl(⊥, γ_hat) ∈ A`, by left_mono EFQ: `untl(beta0∧delta', γ_hat) ∈ A`. Then apply BX14 with a DIFFERENT event pair:
- Positive: `untl(beta0∧delta', γ_hat) ∈ A` -- guard=beta0∧delta', event=γ_hat
- Negative: `(untl(beta0∧delta', gamma0)).neg ∈ A` -- guard=beta0∧delta', event=gamma0
BX14 requires MATCHING EVENTS. Events are γ_hat vs gamma0 — mismatch. So BX14 doesn't apply.

### Recommendation for Next Agent
**Implement Option 1:** Restructure `burgess_D0_finite_subset_consistent_incons` to case-split on `SetMaximalConsistent B` FIRST, before constructing c_list.

In Case A: get the neg-until witness (beta0, gamma0), add gamma0 to c_list, form b/γ_hat with gamma0 included, then proceed with the existing neg sub-case logic (which now works for BOTH sub-cases since in the pos sub-case, the contradiction follows from right_mono + left_mono on `untl(⊥, γ_hat')`).

In Case B: B is MCS. The seed D0 ⊆ B ∪ A ∪ C (since β.neg ∈ B already). Show consistency directly by noting all B-elements are in B (consistent), all untl-formulas are in A (consistent), and all snce-formulas are in C (consistent). Use the omega_chain or Lindenbaum machinery to get the result.

## Current File State

### Modified Files
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Phase 1: lines 2561-2667 (by_cases restructuring in lemma_2_7)
  - Phase 2: lines 219-262 (or_elim_mcs, linear_until_mcs, linear_since_mcs)

### Sorry Locations (12 total, unchanged)
- PointInsertion.lean:1945 -- sorry #1 (burgess_D0_finite_subset_consistent_incons pos sub-case)
- PointInsertion.lean:2537 -- sorry #2 (lemma_2_7_seed_consistent)
- PointInsertion.lean:2667 -- sorry #3 (lemma_2_7 inconsistent case)
- CounterexampleElimination.lean:412 -- sorry #4 (C4 forward hard case)
- CounterexampleElimination.lean:510 -- sorry #5 (C4' backward hard case)
- CounterexampleElimination.lean:756 -- sorry #6 (c2' for C5 forward)
- CounterexampleElimination.lean:794 -- sorry #7 (c2' for C5' backward)
- CounterexampleElimination.lean:834 -- sorry #8 (c2' for C4 forward)
- CounterexampleElimination.lean:872 -- sorry #9 (c2' for C4' backward)
- CounterexampleElimination.lean:918 -- sorry #10 (c2' for density)
- ChronicleToCountermodel.lean:615 -- sorry #11 (FUC coherence)
- ChronicleToCountermodel.lean:619 -- sorry #12 (FSC coherence)

### Build Status
`lake build` passes with 0 errors.

### Key Infrastructure (all sorry-free)
- `or_elim_mcs` (line 219): Local MCS disjunction elimination
- `linear_until_mcs` (line 228): BX7 MCS wrapper, three-way disjunction for Until
- `linear_since_mcs` (line 249): BX7' MCS wrapper, three-way disjunction for Since
- `right_mono_until_mcs` (line 986): BX3 right-mono for Until at MCS level
- `separation_until_mcs` (line 1044): BX14 separation at MCS level
- `burgess_zeta_consistent` (line 1319): Event construction for neg sub-case
- `BurgessR3Maximal_extension_fails` (line 621): Maximality prevents consistent extensions
- `BurgessR3Maximal_neg_or_ext_fails` (line 762): Combined neg/extension failure

## Convention Reminder
Our `untl(guard, event)` = Burgess `U(event, guard)`. Arguments are SWAPPED.
BX14 in our code: `untl(q, p) ∧ ¬untl(r, p) → untl(q, q∧¬r)` where q,r are guards and p is the event (must match).
