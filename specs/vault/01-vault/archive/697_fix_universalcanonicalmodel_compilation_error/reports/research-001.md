# Research Report: Task #697

**Task**: 697 - Fix UniversalCanonicalModel.lean compilation error
**Date**: 2026-01-28
**Focus**: Fix compilation error where representation_theorem calls construct_indexed_family without required h_no_G_bot and h_no_H_bot proofs
**Session**: sess_1769641604_bd7ab8

## Executive Summary

The original task description mentions a compilation error at `UniversalCanonicalModel.lean:77` where `construct_indexed_family` is called without `h_no_G_bot` and `h_no_H_bot` proofs. However, investigation reveals that **the actual blocking errors are in TruthLemma.lean**, caused by a **reflexive vs. irreflexive semantics mismatch**:

- **Semantics** (Truth.lean): Use `s ≤ t` for `all_past` and `t ≤ s` for `all_future` (reflexive)
- **Coherence conditions** (IndexedMCSFamily.lean): Use `t' < t` and `t < t'` (strict/irreflexive)
- **TruthLemma** (lines 396, 417): Tries to pass `s ≤ t` where `s < t` is expected

### Key Findings

1. **The errors are in TruthLemma.lean**, not UniversalCanonicalModel.lean
   - Line 396: `family.backward_H t s psi h_s_lt h_mem` expects `s < t` but `h_s_lt : s ≤ t`
   - Line 417: `family.forward_G t s psi h_t_lt h_mem` expects `t < s` but `h_t_lt : t ≤ s`

2. **Root cause**: Semantic definition mismatch between semantics and coherence conditions
   - Truth.lean uses reflexive semantics: `∀ s, s ≤ t → truth_at s φ`
   - IndexedMCSFamily uses strict inequalities: `t' < t → ...`

3. **Two approaches to fix**:
   - **Option A**: Change coherence conditions to use `≤` (reflexive) - requires T-axiom infrastructure
   - **Option B**: Split the proof cases to handle `s = t` separately using T-axioms

4. **The `construct_indexed_family` signature issue** mentioned in the task description is a **separate issue** that will surface once TruthLemma compiles, but it requires proving `G⊥ ∉ Gamma` and `H⊥ ∉ Gamma` from `SetConsistent {phi}`.

## Context: Architecture Overview

```
Completeness Theorem
         ↓
Representation Theorem (UniversalCanonicalModel.lean:70-89)
         ↓
Truth Lemma (TruthLemma.lean:233-450) ← BLOCKING ERRORS HERE
         ↓
IndexedMCSFamily coherence (IndexedMCSFamily.lean)
         ↓
CoherentConstruction (CoherentConstruction.lean)
```

## Detailed Findings

### Finding 1: TruthLemma Compilation Errors

```
error: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:396:72:
Application type mismatch: The argument h_s_lt has type s ≤ t
but is expected to have type s < t

error: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:417:71:
Application type mismatch: The argument h_t_lt has type t ≤ s
but is expected to have type t < s
```

**Location analysis**:
- Line 396 in `all_past` case: `family.backward_H t s psi h_s_lt h_mem`
- Line 417 in `all_future` case: `family.forward_G t s psi h_t_lt h_mem`

**Why the mismatch occurs**:
- The `ih` (induction hypothesis) is called with `s` from the semantic quantifier `∀ s, s ≤ t → ...`
- But coherence conditions use `s < t` (strict inequality)

### Finding 2: Semantic Definitions

From Truth.lean:196-210:
```lean
theorem past_iff (φ : Formula) :
    (truth_at M τ t φ.all_past) ↔
      ∀ (s : D), s ≤ t → (truth_at M τ s φ)  -- REFLEXIVE: s ≤ t

theorem future_iff (φ : Formula) :
    (truth_at M τ t φ.all_future) ↔
      ∀ (s : D), t ≤ s → (truth_at M τ s φ)  -- REFLEXIVE: t ≤ s
```

### Finding 3: Coherence Condition Definitions

From IndexedMCSFamily.lean:95-116:
```lean
forward_G : ∀ t t' phi, t < t' → Formula.all_future phi ∈ mcs t → phi ∈ mcs t'  -- STRICT: t < t'
backward_H : ∀ t t' phi, t' < t → Formula.all_past phi ∈ mcs t → phi ∈ mcs t'   -- STRICT: t' < t
forward_H : ∀ t t' phi, t < t' → Formula.all_past phi ∈ mcs t' → phi ∈ mcs t    -- STRICT: t < t'
backward_G : ∀ t t' phi, t' < t → Formula.all_future phi ∈ mcs t' → phi ∈ mcs t  -- STRICT: t' < t
```

### Finding 4: T-Axiom Infrastructure Exists

The T-axioms are already defined in the system:
- `temp_t_future`: `G φ → φ` (if φ at all future times including now, then φ now)
- `temp_t_past`: `H φ → φ` (if φ at all past times including now, then φ now)

And corresponding MCS closure lemmas exist in IndexedMCSFamily.lean:257-296:
- `mcs_closed_temp_t_future`: `Gφ ∈ mcs → φ ∈ mcs`
- `mcs_closed_temp_t_past`: `Hφ ∈ mcs → φ ∈ mcs`

## Recommended Approach

### Option A: Modify TruthLemma to Handle Reflexive Case (Recommended)

Split the proof into cases:
1. **When `s = t`**: Use T-axiom closure (`mcs_closed_temp_t_future`/`mcs_closed_temp_t_past`)
2. **When `s ≠ t`**: Use coherence conditions (`forward_G`/`backward_H`)

**Proof sketch for `all_past` forward direction** (line 393-398):
```lean
| all_past psi ih =>
  constructor
  · -- Forward: H psi ∈ mcs t → ∀ s ≤ t, truth_at s psi
    intro h_mem s h_s_le
    -- Case split on s = t vs s < t
    rcases eq_or_lt_of_le h_s_le with rfl | h_s_lt
    · -- Case s = t: Use T-axiom
      have h_psi_at_t : psi ∈ family.mcs t := mcs_closed_temp_t_past (family.is_mcs t) psi h_mem
      exact (ih t).mp h_psi_at_t
    · -- Case s < t: Use backward_H coherence
      have h_psi_in_s : psi ∈ family.mcs s := family.backward_H t s psi h_s_lt h_mem
      exact (ih s).mp h_psi_in_s
```

**Proof sketch for `all_future` forward direction** (line 414-419):
```lean
| all_future psi ih =>
  constructor
  · -- Forward: G psi ∈ mcs t → ∀ s ≥ t, truth_at s psi
    intro h_mem s h_t_le
    -- Case split on t = s vs t < s
    rcases eq_or_lt_of_le h_t_le with rfl | h_t_lt
    · -- Case t = s: Use T-axiom
      have h_psi_at_t : psi ∈ family.mcs t := mcs_closed_temp_t_future (family.is_mcs t) psi h_mem
      exact (ih t).mp h_psi_at_t
    · -- Case t < s: Use forward_G coherence
      have h_psi_in_s : psi ∈ family.mcs s := family.forward_G t s psi h_t_lt h_mem
      exact (ih s).mp h_psi_in_s
```

### Option B: Change Coherence Conditions to Reflexive (Not Recommended)

This would require:
1. Changing all four coherence conditions to use `≤` instead of `<`
2. Re-proving all coherence cases in CoherentConstruction.lean
3. Much more extensive refactoring

## Secondary Issue: construct_indexed_family Signature

Once TruthLemma compiles, the call at UniversalCanonicalModel.lean:77 will fail:
```lean
let family := construct_indexed_family D Gamma h_mcs
```

The function signature (IndexedMCSFamily.lean:600-604) requires:
```lean
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    IndexedMCSFamily D
```

**To fix**, need to prove from `SetConsistent {phi}`:
1. After Lindenbaum extension: `G⊥ ∉ Gamma`
2. After Lindenbaum extension: `H⊥ ∉ Gamma`

**Approach**: These follow from consistency of `{phi}`:
- If `G⊥ ∈ Gamma`, then by T-axiom `⊥ ∈ Gamma`, contradicting MCS consistency
- Same reasoning for `H⊥`

However, research-003.md for Task 681 notes this is a known gap that matches the Boneyard. The current workaround is to assume these conditions or prove them separately.

## Dependencies

**Required imports for fix**:
- `mcs_closed_temp_t_future` from IndexedMCSFamily.lean
- `mcs_closed_temp_t_past` from IndexedMCSFamily.lean
- `eq_or_lt_of_le` from Mathlib.Order.Basic

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| T-axiom lemmas may not type-check with family.is_mcs | High | Verify type signatures match |
| Additional proof obligations in case split | Medium | Both cases are straightforward |
| May expose new errors downstream | Medium | Test incrementally |

## Implementation Steps

1. **Fix TruthLemma.lean lines 393-398** (all_past forward direction)
   - Add case split on `eq_or_lt_of_le`
   - Use `mcs_closed_temp_t_past` for reflexive case
   - Keep existing `backward_H` for strict case

2. **Fix TruthLemma.lean lines 414-419** (all_future forward direction)
   - Add case split on `eq_or_lt_of_le`
   - Use `mcs_closed_temp_t_future` for reflexive case
   - Keep existing `forward_G` for strict case

3. **Verify build passes**: `lake build Bimodal.Metalogic.Representation.TruthLemma`

4. **Address secondary issue** (construct_indexed_family arguments) if it surfaces

## Conclusion

The task description's focus on `construct_indexed_family` arguments is accurate for the ultimate fix needed, but the **immediate blocking issue** is a reflexive/irreflexive semantics mismatch in TruthLemma.lean. The fix is straightforward: split the proof cases and use T-axiom closure lemmas for the reflexive case (`s = t`).

**Estimated effort**: 2-3 hours for TruthLemma fix, plus additional time if `construct_indexed_family` signature issue surfaces.

## References

- TruthLemma.lean lines 391-424 (all_past and all_future cases)
- IndexedMCSFamily.lean lines 257-296 (T-axiom closure lemmas)
- IndexedMCSFamily.lean lines 95-116 (coherence condition definitions)
- Truth.lean lines 191-210 (semantic definitions)
- Task 681 research-003.md (coherence infrastructure analysis)

## Appendix: Search Queries Used

- `lean_leansearch`: "maximal consistent set temporal logic all past all future coherence"
- File searches: `construct_indexed_family`, `temp_t_future`, `backward_H`, `forward_G`
- Grep patterns: `Task.*658|reflexive.*temporal|temp_t_future|temp_t_past`

## Next Steps

1. Create implementation plan with detailed code changes
2. Implement TruthLemma fixes
3. Verify build and test
4. Address `construct_indexed_family` signature if needed
