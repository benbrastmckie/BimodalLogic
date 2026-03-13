# Implementation Plan: Task #961 (v002)

- **Task**: 961 - quotient_density_iteration_no_max_min_dense
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: Task 956 (D Construction strategy), Task 957 (density_frame_condition)
- **Research Inputs**: research-001.md, research-002.md (blocker investigation)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v002 supersedes v001; replaces flawed fuel-based recursion with direct case-based proof

## Overview

**What Changed**: research-002.md found that the fuel-based termination measure (`subformulaClosure(delta).card`) is fundamentally flawed. Consecutive distinguishing formulas are NOT subformula-related - when iterating from (p, q) to (c, q), the new delta' can be ANY formula in `GContent(q) \ c.mcs`, not necessarily a sub-formula of delta.

**New Approach**: Direct case-based proof using at most 2 applications of `dense_timeline_has_intermediate`. No recursion needed.

### Research Integration

- **research-001.md**: Original analysis (now superseded for termination approach)
- **research-002.md**: Blocker investigation - identified fuel measure is incorrect, recommends direct case-based proof

## Goals & Non-Goals

**Goals**:
- Replace current `strict_intermediate_exists` with non-recursive version
- Resolve 4 sorries in CantorApplication.lean (now at lines 190, 211, 366, 425)
- Zero sorries remaining after implementation
- `lake build` passes

**Non-Goals**:
- Preserving the current recursive structure
- Using fuel-based termination (proven flawed)
- Modifying `density_frame_condition` infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case explosion in direct proof | LOW | LOW | Only 4 cases, Case 4 is unreachable |
| Edge cases in equivalence checking | MEDIUM | LOW | Use existing `intermediate_not_both_equiv` lemma |
| NoMaxOrder proof complexity | MEDIUM | MEDIUM | Use density twice at most, leverage existing helpers |

## Sorry Characterization

### Current Sorries (4)
- `CantorApplication.lean`:
  - Line 190: Fuel decrease check for c ~ p case (in `strict_intermediate_exists`)
  - Line 211: Fuel decrease check for c ~ q case (in `strict_intermediate_exists`)
  - Line 366: NoMaxOrder reflexive case
  - Line 425: NoMinOrder reflexive case

### Expected Resolution
- Phase 1: Rewrite `strict_intermediate_exists` with direct proof → removes lines 190, 211
- Phase 2: Fix NoMaxOrder/NoMinOrder using the corrected theorem → removes lines 366, 425

### New Sorries
- None. NEVER introduce new sorries.

### Remaining Debt
After this implementation:
- 0 sorries in `CantorApplication.lean`
- `cantor_iso` theorem fully proved
- Task 956 Phase 7 unblocked

## Implementation Phases

### Phase 1: Rewrite strict_intermediate_exists [NOT STARTED]

- **Dependencies:** None
- **Goal:** Replace recursive fuel-based version with direct case-based proof

**Key Insight**: When `dense_timeline_has_intermediate` gives c between p and q:
- c CANNOT be ~ both p and q (would make [p] = [q], contradicting [p] < [q])
- So at least one of: c ≁ p OR c ≁ q
- Apply density at most ONCE MORE to the remaining interval

**Tasks:**
- [ ] Remove current fuel-based `strict_intermediate_exists` implementation
- [ ] Implement new `strict_intermediate_exists_v2`:
  ```lean
  theorem strict_intermediate_exists
      (p q : DenseTimelineElem root_mcs root_mcs_proof)
      (hp_q : CanonicalR p.1.mcs q.1.mcs)
      (hq_not_p : ¬CanonicalR q.1.mcs p.1.mcs) :
      ∃ c, [p] < [c] ∧ [c] < [q] := by
    -- Step 1: Get first intermediate c
    obtain ⟨c, hc_mem, hc_R_p, hc_R_q⟩ := dense_timeline_has_intermediate p q hp_q hq_not_p
    -- Step 2: c cannot be ~ both p and q (proved by intermediate_not_both_equiv)
    -- Step 3: Case split on c's equivalences
    by_cases hc_p : CanonicalR c.mcs p.1.mcs
    · -- c ~ p case: apply density to (c, q)
      by_cases hq_c : CanonicalR q.1.mcs c.mcs
      · -- c ~ p AND c ~ q: contradiction via intermediate_not_both_equiv
        exact False.elim (intermediate_not_both_equiv ...)
      · -- c ~ p AND c ≁ q: get second intermediate d between c and q
        obtain ⟨d, ...⟩ := dense_timeline_has_intermediate c q ...
        -- d cannot be ~ both c and q
        -- At least one of d ≁ c or d ≁ q gives strict intermediate
        ...
    · -- c ≁ p case: check q side
      by_cases hq_c : CanonicalR q.1.mcs c.mcs
      · -- c ≁ p AND c ~ q: get second intermediate d between p and c
        obtain ⟨d, ...⟩ := dense_timeline_has_intermediate p c ...
        ...
      · -- c ≁ p AND c ≁ q: c is the strict intermediate!
        exact ⟨c, ...⟩
  ```
- [ ] Verify with `lake build`
- [ ] Verify sorries at lines 190, 211 are gone

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` shows only lines 366, 425

---

### Phase 2: NoMaxOrder and NoMinOrder Resolution [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Resolve the 2 remaining sorries using corrected strict_intermediate_exists

**Key Insight**: For reflexive MCSs:
- If p.mcs is reflexive and all seriality witnesses are ~ p
- Apply density to (p, seriality_witness) → get intermediate c
- c cannot be ~ both p and the witness
- Use c or apply one more density step

**Tasks:**
- [ ] Replace sorry at line 366 (NoMaxOrder reflexive case):
  - Get seriality witness q with CanonicalR p.1.mcs q.mcs
  - If q ≁ p: Done (q is strictly greater)
  - If q ~ p: Apply density to (p, q')
    where q' is seriality witness of q
  - The density intermediate escapes p's equivalence class
- [ ] Replace sorry at line 425 (NoMinOrder reflexive case):
  - Symmetric to NoMaxOrder using past direction
- [ ] Verify `lake build` passes with zero sorries
- [ ] Verify `grep -n "\bsorry\b" CantorApplication.lean` returns empty

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns empty
- `cantor_iso` theorem has no sorry dependencies

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" CantorApplication.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " CantorApplication.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] NoMaxOrder instance has no sorries
- [ ] NoMinOrder instance has no sorries
- [ ] DenselyOrdered instance has no sorries
- [ ] `cantor_iso` theorem fully proved
- [ ] All 4 current sorries resolved

## Artifacts & Outputs

- `plans/implementation-002.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

## Rollback/Contingency

If implementation fails:
1. The fuel-based version in git history is NOT a fallback (proven flawed)
2. Consider axiomatizing strict density as a temporary measure
3. Escalate to user review for alternative mathematical approach
4. Key invariant: at most 2 density applications guarantees termination

## Comparison: v001 vs v002

| Aspect | v001 | v002 |
|--------|------|------|
| **Approach** | Recursive with fuel | Direct case-based |
| **Termination** | subformulaClosure.card | Finite case split (max 2 iterations) |
| **Recursion** | Yes (Nat.strong_induction_on) | No |
| **Correctness** | Flawed - delta' not subformula of delta | Sound - explicit exhaustive cases |
| **Complexity** | Higher (recursion, fuel tracking) | Lower (simple case split) |
