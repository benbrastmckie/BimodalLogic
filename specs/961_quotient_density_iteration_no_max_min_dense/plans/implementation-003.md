# Implementation Plan: Task #961 (v003)

- **Task**: 961 - quotient_density_iteration_no_max_min_dense
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: Task 956 (D Construction strategy), Task 957 (density_frame_condition)
- **Research Inputs**: research-003.md (blocker resolution investigation)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v003 supersedes v002; replaces unbounded case-tree iteration with Classical.choose existence proof

## Overview

**What Changed**: research-003.md analyzed three approaches to the termination problem:
1. Finite equivalence classes: NOT VIABLE (GContent-based equivalence can have infinite classes)
2. Visited set measure: NOT VIABLE (no natural finite candidate set exists)
3. Classical.choose existence proof: RECOMMENDED (prove existence non-constructively)

**New Approach**: Prove existence of strict intermediates via contradiction using Classical.choose. The key insight is that iteration termination is a proof engineering issue, not a mathematical one. Strict intermediates EXIST by the density property; we need not construct them iteratively.

### Research Integration

- **research-003.md**: Recommends Classical.choose existence proof with `intermediate_not_both_equiv` as core lemma

## Goals & Non-Goals

**Goals**:
- Prove `strict_intermediate_exists` via Classical.choose existence proof
- Resolve 6 sorries in CantorApplication.lean (lines 326, 372, 420, 462, 593, 652)
- Zero sorries remaining after implementation
- `lake build` passes

**Non-Goals**:
- Preserving the current case-tree structure
- Direct construction of strict intermediate
- Using fuel/measure-based termination (proven non-viable)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Quotient collapse argument has gaps | MEDIUM | MEDIUM | Careful use of intermediate_not_both_equiv |
| Existence proof complexity | MEDIUM | LOW | Use existing density infrastructure |
| NoMaxOrder depends on strict_intermediate_exists | HIGH | LOW | Fix strict_intermediate_exists first |

## Sorry Characterization

### Pre-existing Sorries (6)
- `CantorApplication.lean`:
  - Line 326: Deep case h not equivalent to p, h ~ q branch in strict_intermediate_exists
  - Line 372: Case f not equivalent to p, f ~ q branch in strict_intermediate_exists
  - Line 420: Case e not equivalent to p, e ~ q branch in strict_intermediate_exists
  - Line 462: Case d ~ c (c ~ q) branch in strict_intermediate_exists
  - Line 593: NoMaxOrder reflexive case
  - Line 652: NoMinOrder reflexive case

### Expected Resolution
- Phase 1-2: Prove `strict_intermediate_exists_core` via Classical.choose -> replaces sorries at 326, 372, 420, 462
- Phase 3: Fix NoMaxOrder reflexive case using the existence proof -> replaces sorry at 593
- Phase 4: Fix NoMinOrder reflexive case symmetrically -> replaces sorry at 652

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in `CantorApplication.lean`
- `cantor_iso` theorem fully proved
- Task 956 Phase 7 unblocked

## Implementation Phases

### Phase 1: Core Existence Lemma [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prove existence of strict intermediate via contradiction using Classical.choose

**Mathematical Strategy**:
The proof proceeds by contradiction. Assume no strict intermediate exists between [p] < [q]. Then every intermediate c from density_frame_condition satisfies c ~ p or c ~ q. But by `intermediate_not_both_equiv`, c cannot be ~ both. The quotient having [p] < [q] as distinct equivalence classes means there must be some element strictly between them.

**Tasks:**
- [ ] Add helper lemma `strict_intermediate_exists_core`:
  ```lean
  /-- Core existence lemma: Given [p] < [q], there exists c with [p] < [c] < [q]. -/
  theorem strict_intermediate_exists_core
      (p q : DenseTimelineElem root_mcs root_mcs_proof)
      (hp_q : CanonicalR p.1.mcs q.1.mcs)
      (hq_not_p : CanonicalR q.1.mcs p.1.mcs) :
      c : DenseTimelineElem root_mcs root_mcs_proof,
        CanonicalR p.1.mcs c.1.mcs CanonicalR c.1.mcs p.1.mcs
        CanonicalR c.1.mcs q.1.mcs CanonicalR q.1.mcs c.1.mcs := by
    by_contra h_no_strict
    push_neg at h_no_strict
    -- Every intermediate from density is ~ p or ~ q (but not both)
    -- Show this leads to contradiction via quotient collapse
    ...
  ```
- [ ] Prove by contradiction using `intermediate_not_both_equiv`
- [ ] Use `dense_timeline_has_intermediate` to obtain witness c
- [ ] Apply Classical.choose on the existence proof
- [ ] Verify helper lemma compiles with `lean_goal`

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes for the new helper lemma
- `lean_goal` shows "no goals" at lemma end

---

### Phase 2: Refactor strict_intermediate_exists [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Replace the 4-sorry case tree with the existence-based proof

**Tasks:**
- [ ] Remove the current deep case-tree structure (lines ~150-470)
- [ ] Replace with invocation of `strict_intermediate_exists_core`
- [ ] Use Classical.choose to obtain witness:
  ```lean
  theorem strict_intermediate_exists
      (p q : DenseTimelineElem root_mcs root_mcs_proof)
      (hp_q : CanonicalR p.1.mcs q.1.mcs)
      (hq_not_p : CanonicalR q.1.mcs p.1.mcs) :
      c : DenseTimelineElem root_mcs root_mcs_proof,
        CanonicalR p.1.mcs c.1.mcs CanonicalR c.1.mcs p.1.mcs
        CanonicalR c.1.mcs q.1.mcs CanonicalR q.1.mcs c.1.mcs :=
    strict_intermediate_exists_core root_mcs root_mcs_proof p q hp_q hq_not_p
  ```
- [ ] Verify sorries at lines 326, 372, 420, 462 are removed
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` shows only lines 593, 652

---

### Phase 3: NoMaxOrder Reflexive Case [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Resolve the sorry at line 593 for the NoMaxOrder reflexive case

**Mathematical Strategy**:
When p.mcs is reflexive and all seriality witnesses q are equivalent to p (p ~ q), we use the density construction to escape the equivalence class:
1. Apply `dense_timeline_has_intermediate` to get intermediate c between p and any q'
2. c cannot be ~ both p and q' (by intermediate_not_both_equiv)
3. If c not equivalent to p: c is strictly above p (done)
4. If c ~ p and c not equivalent to q': use strict_intermediate_exists to find element strictly above p and strictly below q'

**Tasks:**
- [ ] Replace sorry at line 593 with proof:
  ```lean
  -- p.mcs is reflexive, p ~ q ~ q' ... all equivalent
  -- Use density to escape: get intermediate strictly different from [p]
  obtain c, hc_p, hc_not_p, hc_q, hq_not_c :=
    strict_intermediate_exists root_mcs root_mcs_proof p q' hp_q' hq'_not_p
  -- c is strictly above p
  let c' : DenseTimelineElem root_mcs root_mcs_proof := c
  use toAntisymmetrization ( ·) c'
  rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
  ...
  ```
- [ ] Handle edge case where seriality witness is reflexive
- [ ] Verify with `lean_goal` showing "no goals"
- [ ] Verify with `lake build`

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` shows only line 652

---

### Phase 4: NoMinOrder Reflexive Case [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Resolve the sorry at line 652 for the NoMinOrder reflexive case (symmetric to Phase 3)

**Mathematical Strategy**:
Symmetric to NoMaxOrder using the past direction. When p.mcs is reflexive and all past witnesses are equivalent to p, use density to escape via strict_intermediate_exists.

**Tasks:**
- [ ] Replace sorry at line 652 with symmetric proof:
  - Get past predecessor q via `dense_timeline_has_past`
  - If q not equivalent to p: done
  - If q ~ p: get q' via seriality of q
  - Apply `strict_intermediate_exists` to (q', p) to find element strictly below p
- [ ] Verify with `lean_goal` showing "no goals"
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` shows only line 652 removed

---

### Phase 5: Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Ensure all sorries resolved and full verification passes

**Tasks:**
- [ ] Run `lake build` - must pass with no errors
- [ ] Run `grep -rn "\bsorry\b" CantorApplication.lean` - must return empty
- [ ] Run `grep -n "^axiom " CantorApplication.lean` - verify no new axioms
- [ ] Verify `cantor_iso` theorem has no sorry dependencies
- [ ] Verify DenselyOrdered, NoMaxOrder, NoMinOrder instances are complete
- [ ] Document any remaining technical debt (should be none)

**Timing:** 0.25 hours

**Files to modify:**
- None (verification only)

**Verification:**
- All checks pass
- Zero sorries in `CantorApplication.lean`
- Zero new axioms
- `cantor_iso` fully proved

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" CantorApplication.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " CantorApplication.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] `strict_intermediate_exists` theorem compiles without sorry
- [ ] NoMaxOrder instance has no sorries
- [ ] NoMinOrder instance has no sorries
- [ ] DenselyOrdered instance has no sorries
- [ ] `cantor_iso` theorem fully proved
- [ ] All 6 current sorries resolved

## Artifacts & Outputs

- `plans/implementation-003.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

## Rollback/Contingency

If implementation fails:
1. The v002 case-tree approach is preserved in git history as reference
2. If Phase 1 (core existence lemma) fails:
   - Mark [BLOCKED] with requires_user_review: true
   - Consider axiomatizing strict density as temporary measure
   - Escalate for alternative mathematical approach
3. If Phase 3-4 fail:
   - Core existence lemma may need adjustment
   - Review if NoMaxOrder/NoMinOrder need different strategy
4. Key invariant: Classical.choose approach should terminate trivially (no iteration)

## Comparison: v002 vs v003

| Aspect | v002 | v003 |
|--------|------|------|
| **Approach** | Direct case-based iteration | Classical.choose existence proof |
| **Termination** | 2-step bound (failed) | No iteration (existence by contradiction) |
| **Core Issue** | Unbounded case tree | Solved via non-constructive proof |
| **Mathematical Basis** | Case analysis | Quotient distinctness + density |
| **Complexity** | Higher (deep case splits) | Lower (existence lemma + application) |
