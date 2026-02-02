# Research Report: Task #801

**Task**: Document Soundness temp_t axiom validity issue
**Date**: 2026-02-02
**Focus**: Analyze the nature of the temp_t sorries and research whether to use weak vs strict inequalities for temporal semantics

## Executive Summary

The 2 sorries in SoundnessLemmas.lean (lines 833, 844) and 2 in Soundness.lean (lines 663, 682) exist because **the proofs were written for strict inequality semantics (`<`) but the semantics were changed to reflexive (`<=`) in Task 658**. With the current reflexive semantics, these sorries are now **trivially provable** - they just need to be updated to use the correct inequality constraints.

**Key Finding**: The sorries are a **code synchronization issue**, not a fundamental semantic problem. The reflexive semantics change was well-motivated and should be retained.

## Analysis

### Current State of the Code

1. **Truth.lean** (lines 113-114) uses **reflexive semantics**:
   ```lean
   | Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M τ s φ
   | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M τ s φ
   ```

2. **SoundnessLemmas.lean** contains proofs written for **strict semantics** (using `<`):
   - Comments reference strict inequalities (e.g., "s < t" at line 260)
   - Proofs like `swap_axiom_t4_valid` use `lt_trans` (line 263) which expects strict `<`
   - The temp_t validity proofs at lines 774-833 and 836-844 have sorry placeholders

3. **Soundness.lean** (lines 663, 682) has the same issue with temp_t axiom validity proofs.

### Build Error Analysis

When rebuilding SoundnessLemmas.lean, 9 type mismatch errors occur because:
- Proofs pass `h_r_lt_t` (type `r ≤ t`) to `lt_trans` which expects strict `<`
- Goals expect `s ≤ t` but proofs provide `s < t`

Example errors:
```
error: Theories/Bimodal/Metalogic/SoundnessLemmas.lean:263:45: Application type mismatch
  h_r_lt_t has type r ≤ t but is expected to have type ?m.31 < t
```

### Historical Context

**Task 658** (2026-01-28) changed the semantics from strict to reflexive for well-motivated reasons:

1. **Primary Motivation**: Solving the indexed family coherence proofs needed for completeness
   - Without T axioms (`Gφ → φ`, `Hφ → φ`), independent Lindenbaum extensions cannot be proven coherent
   - T axioms provide a local constraint connecting `Gφ ∈ mcs(t)` to `φ ∈ mcs(t)`

2. **Secondary Benefits**:
   - Algebraic elegance: Reflexive G/H form closure/interior operators
   - Mathlib alignment: Works with `ClosureOperator` and `Nucleus` structures

3. **The switch was NOT motivated by backwards TruthLemma** (which is not needed for completeness)

### The Nature of the Problem

With **reflexive semantics**, the temp_t axioms become trivially valid:

- `Gφ → φ` (temp_t_future): "If φ holds at all s ≥ t, then φ holds at t"
  - Proof: Given `h : ∀ s, t ≤ s → truth_at M τ s φ`, apply with `s = t` and `le_refl t`

- `Hφ → φ` (temp_t_past): "If φ holds at all s ≤ t, then φ holds at t"
  - Proof: Given `h : ∀ s, s ≤ t → truth_at M τ s φ`, apply with `s = t` and `le_refl t`

With **strict semantics**, these axioms are NOT valid because:
- `Gφ` only says φ holds for s > t (strictly future)
- `Hφ` only says φ holds for s < t (strictly past)
- Neither provides information about time t itself

### Two Design Options

#### Option 1: Keep Reflexive Semantics (RECOMMENDED)

**Advantages**:
- T axioms are valid (temp_t_future, temp_t_past)
- Coherence proofs for indexed family construction are trivial
- Algebraic benefits (closure/interior operators)
- Already implemented in Truth.lean

**Required Work**:
1. Update SoundnessLemmas.lean proofs to use `≤` instead of `<`
2. Fix the 9 type mismatches (replace `lt_trans` with `le_trans`, etc.)
3. Complete the temp_t validity proofs (now trivial with `le_refl`)
4. Update Soundness.lean temp_t validity proofs similarly

**Estimated Effort**: 2-4 hours

#### Option 2: Revert to Strict Semantics

**Advantages**:
- Matches traditional tense logic semantics (F = "strictly future")
- No need to maintain T axioms in proof system

**Disadvantages**:
- T axioms must be removed from the Axiom type
- Coherence proofs become blocked by mathematical impossibility
- Completeness proof strategy requires architectural redesign
- Approximately 40+ hours of work (per Task 658 research-002.md)

**Not Recommended**: The reflexive semantics change was well-researched and addresses genuine mathematical blockers.

### Detailed Fix for SoundnessLemmas.lean

The following changes are needed:

1. **swap_axiom_t4_valid** (lines 253-264):
   - Change comments from "s < t" to "s ≤ t"
   - Replace `lt_trans h_u_lt_r h_r_lt_t` with `le_trans h_u_le_r h_r_le_t`

2. **swap_axiom_ta_valid** (lines 278-288):
   - Update type annotations and proof logic for weak inequality

3. **swap_axiom_tl_valid** (lines 310-363):
   - Update case analysis from `<` to `≤`
   - Replace `lt_of_le_of_ne` with appropriate `le` lemmas

4. **axiom_temp_4_valid** (lines 700-706):
   - Replace `lt_trans hts hsr` with `le_trans hts hsr`

5. **axiom_temp_t_future_valid** (lines 774-833):
   - Replace sorry with: `exact h_future t (le_refl t)`

6. **axiom_temp_t_past_valid** (lines 836-844):
   - Replace sorry with: `exact h_past t (le_refl t)`

7. **axiom_temp_l_valid** (lines 724-745):
   - Update the extraction logic for reflexive inequalities

8. **axiom_swap_valid** (line 503):
   - Add missing cases for `temp_t_future` and `temp_t_past`

### Impact Assessment

| Component | Current Status | After Fix |
|-----------|----------------|-----------|
| SoundnessLemmas.lean | 2 sorries, 9 type errors | 0 sorries, compiles |
| Soundness.lean | 2 sorries | 0 sorries |
| Completeness | Unaffected | Unaffected |
| Truth.lean | Already reflexive | No change |

## Recommendations

### Primary Recommendation: Fix the Code to Match Reflexive Semantics

1. **Update SoundnessLemmas.lean** to use `≤` throughout
2. **Complete temp_t validity proofs** using `le_refl`
3. **Update Soundness.lean** similarly
4. **Verify build succeeds** with `lake build`

### Do NOT Revert to Strict Semantics

The reflexive semantics were adopted after thorough research (Tasks 658, 700, 730) and are essential for:
- Coherence proofs in indexed family construction
- Completeness theorem proof strategy
- Algebraic elegance with Mathlib infrastructure

### Documentation Update

After fixing the code, update the module documentation to explain:
- Why reflexive semantics are used (T axiom validity, coherence proofs)
- The historical context (Tasks 658, 730)

## File Locations

| File | Lines | Issue |
|------|-------|-------|
| `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` | 774-833, 836-844 | 2 temp_t sorries |
| `Theories/Bimodal/Metalogic/Soundness.lean` | 663, 682 | 2 temp_t sorries |
| `Theories/Bimodal/Semantics/Truth.lean` | 113-114 | Already reflexive |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | 252-275 | T axiom definitions |

## References

- Task 658: Changed semantics to reflexive, added T axioms
- Task 730: Investigated motivation for reflexive semantics (confirmed well-motivated)
- Task 794: Created SoundnessLemmas.lean (with sorries)
- Task 796: Categorized remaining sorries

## Next Steps

1. Create implementation plan for fixing the proofs
2. Update SoundnessLemmas.lean and Soundness.lean
3. Verify build succeeds
4. Add documentation explaining the design choice
