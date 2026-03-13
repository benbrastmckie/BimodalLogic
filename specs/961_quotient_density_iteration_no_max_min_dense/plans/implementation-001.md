# Implementation Plan: Task #961

- **Task**: 961 - quotient_density_iteration_no_max_min_dense
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: Task 956 (D Construction strategy), Task 957 (density_frame_condition)
- **Research Inputs**: specs/961_quotient_density_iteration_no_max_min_dense/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement well-founded iteration using `Nat.strongRecOn` to resolve 6 sorries in CantorApplication.lean where `density_frame_condition` returns intermediates that may fall into endpoint equivalence classes. The termination measure uses `subformulaClosure(anchor).card` as fuel, strictly decreasing with each iteration that consumes a distinguishing formula. When iteration finds an intermediate c with c not equivalent to p and c not equivalent to q, success; otherwise recurse with a sub-formula.

### Research Integration

- research-001.md: Identified `Nat.strongRecOn` pattern with fuel = `subformulaClosure(anchor).card`
- Case analysis: 4 cases for equivalence checking, Case 4 (c ~ p ~ q) is unreachable
- Termination: Each failed iteration consumes a formula from finite set, guaranteeing termination

## Goals & Non-Goals

**Goals**:
- Resolve all 6 sorries in CantorApplication.lean (lines 210, 269, 332, 345, 380, 385)
- Implement well-founded iteration infrastructure using `Nat.strongRecOn`
- Zero sorries remaining after implementation
- `lake build` passes

**Non-Goals**:
- Modifying the existing `density_frame_condition` infrastructure
- Optimizing performance of the iteration
- Refactoring unrelated code in CantorApplication.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination proof complexity | HIGH | MEDIUM | Use `Nat.strongRecOn` which handles well-foundedness automatically |
| Type mismatch in recursive helper | MEDIUM | MEDIUM | Design helper signature carefully, test with lean_goal |
| Edge cases in equivalence checking | MEDIUM | LOW | Explicit case split on all 4 equivalence combinations |
| Formula tracking errors | MEDIUM | LOW | Leverage existing `distinguishing_formula_exists` and `subformulaClosure` |

## Sorry Characterization

### Pre-existing Sorries
- 6 sorries in `CantorApplication.lean`:
  - Line 210: NoMaxOrder reflexive case
  - Line 269: NoMinOrder reflexive case
  - Lines 332, 345, 380, 385: DenselyOrdered iteration cases

### Expected Resolution
- Phase 1: Define iteration infrastructure (helper lemmas and main iterator)
- Phase 2: Resolve DenselyOrdered sorries (4 sorries at lines 332, 345, 380, 385)
- Phase 3: Resolve NoMaxOrder and NoMinOrder sorries (2 sorries at lines 210, 269)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in `CantorApplication.lean`
- `cantor_iso` theorem will be fully proved
- D Construction Phase 6 prerequisites complete

## Implementation Phases

### Phase 1: Well-Founded Iteration Infrastructure [PARTIAL]

- **Dependencies:** None
- **Goal:** Create the well-founded iteration machinery using `Nat.strongRecOn`

**Tasks:**
- [ ] Define `findStrictIntermediate` helper using `Nat.strongRecOn`
  - Input: p, q, anchor formula, fuel (= subformulaClosure(anchor).card)
  - Output: c with [p] < [c] < [q]
  - Termination: fuel decreases on each iteration
- [ ] Implement the 4-way case split in iteration body:
  - Case 1: c not ~ p AND c not ~ q -> SUCCESS (return c)
  - Case 2: c ~ p -> recurse with sub-formula (c, q)
  - Case 3: c ~ q -> recurse with sub-formula (p, c)
  - Case 4: c ~ p ~ q -> contradiction (unreachable)
- [ ] Add helper lemmas for sub-formula fuel decrease:
  - Lemma: when c ~ p, the new anchor is a sub-formula of old anchor
  - Lemma: sub-formula has strictly smaller closure cardinality
- [ ] Verify with `lake build` that infrastructure compiles

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - add iteration infrastructure

**Verification:**
- `lake build` passes
- New definitions type-check
- `lean_goal` shows correct types for helper functions

---

### Phase 2: DenselyOrdered Resolution [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Resolve the 4 DenselyOrdered sorries using the iteration infrastructure

**Tasks:**
- [ ] Replace sorry at line 332 (d ~ c ~ p case):
  - Apply `findStrictIntermediate` with (p, q) and anchor from h_R
  - Extract witness d' from result
- [ ] Replace sorry at line 345 (d ~ q case):
  - Apply `findStrictIntermediate` with (p, q) and anchor from h_R
  - Extract witness d' from result
- [ ] Replace sorry at line 380 (d ~ p case in q branch):
  - Apply `findStrictIntermediate` with (p, q) and anchor from h_R
  - Extract witness d' from result
- [ ] Replace sorry at line 385 (d ~ c ~ q case):
  - Apply `findStrictIntermediate` with (p, q) and anchor from h_R
  - Extract witness d' from result
- [ ] Verify `lake build` passes with no sorries in DenselyOrdered instance
- [ ] Verify `grep -n "\bsorry\b" CantorApplication.lean` shows only 2 remaining (lines 210, 269)

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - resolve 4 DenselyOrdered sorries

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns only lines 210, 269
- DenselyOrdered instance is sorry-free

---

### Phase 3: NoMaxOrder and NoMinOrder Resolution [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Resolve the 2 remaining sorries for NoMaxOrder and NoMinOrder

**Tasks:**
- [ ] Replace sorry at line 210 (NoMaxOrder reflexive case):
  - When p.mcs is reflexive, use iteration to escape equivalence class
  - Apply seriality repeatedly via `findStrictIntermediate` variant for "no max" case
  - Key insight: find anchor formula from GContent(p) witnessing non-triviality
- [ ] Replace sorry at line 269 (NoMinOrder reflexive case):
  - Symmetric to NoMaxOrder using past direction
  - Apply `findStrictIntermediate` variant for "no min" case
- [ ] Verify `lake build` passes with zero sorries
- [ ] Verify `grep -n "\bsorry\b" CantorApplication.lean` returns empty
- [ ] Verify `cantor_iso` theorem is fully proved

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - resolve 2 NoMax/NoMin sorries

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns empty
- `cantor_iso` theorem has no sorry dependencies

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] NoMaxOrder instance has no sorries
- [ ] NoMinOrder instance has no sorries
- [ ] DenselyOrdered instance has no sorries
- [ ] `cantor_iso` theorem fully proved
- [ ] All 6 original sorries resolved

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation state
2. Preserve iteration infrastructure if partially working
3. Mark phase [BLOCKED] with specific blocker identified
4. Consider alternative: direct proof without iteration for simpler cases
5. If proof complexity exceeds expectations, escalate to user review for approach decision
