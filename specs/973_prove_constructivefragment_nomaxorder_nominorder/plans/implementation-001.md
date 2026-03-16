# Implementation Plan: Task 973

- **Task**: 973 - Prove NoMaxOrder/NoMinOrder on ConstructiveQuotient
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/973_prove_constructivefragment_nomaxorder_nominorder/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete two sorry placeholders in `ConstructiveFragment.lean` at lines 580 and 585 proving that `ConstructiveQuotient` has no maximum or minimum elements. The proofs follow the established pattern from `DiscreteTimeline.lean`: use seriality axioms to get forward/backward witnesses, establish strictness via `canonicalR_strict`, and lift to the quotient using `toAntisymmetrization_lt_toAntisymmetrization_iff`.

### Research Integration

The research report (research-001.md) provides:
- Complete goal states for both sorries
- Working proof pattern from DiscreteTimeline.lean (lines 247-285)
- Specific tactic proof sketches for both instances
- Key lemmas: `mcs_contains_seriality_future/past`, `executeForwardStep/BackwardStep`, `canonicalR_strict/irreflexive`

## Goals & Non-Goals

**Goals**:
- Prove `NoMaxOrder.exists_gt` for `ConstructiveQuotient` (line 580)
- Prove `NoMinOrder.exists_lt` for `ConstructiveQuotient` (line 585)
- Zero sorries remaining in these instances after completion

**Non-Goals**:
- Modifying the preorder definition on ConstructiveFragment
- Adding new lemmas to other files
- Refactoring the existing proof structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implicit argument issues with execute* functions | M | M | Use explicit type annotations; check with lean_hover_info |
| Quotient induction syntax differs from DiscreteTimeline | L | L | Use `Quotient.ind` as shown in research; adjust if needed |
| canonicalR_irreflexive import missing | L | L | Verify import from CanonicalIrreflexivityAxiom.lean |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `ConstructiveFragment.lean` at lines 580 and 585 (NoMaxOrder/NoMinOrder instances)

### Expected Resolution
- Phase 1 resolves line 580 sorry via forward seriality witness and canonicalR_strict
- Phase 2 resolves line 585 sorry via backward seriality witness and canonicalR_strict

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in NoMaxOrder/NoMinOrder instances
- These instances become publication-ready

## Implementation Phases

### Phase 1: Prove NoMaxOrder.exists_gt [NOT STARTED]

- **Dependencies:** None
- **Goal:** Complete the sorry at line 580 proving every quotient element has a strictly greater element

**Tasks:**
- [ ] Navigate to `ConstructiveFragment.lean` line 580
- [ ] Use `Quotient.ind` to reduce to underlying ConstructiveFragment element
- [ ] Get forward seriality witness via `mcs_contains_seriality_future w.val w.is_mcs`
- [ ] Execute forward step: `executeForwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_F`
- [ ] Establish MCS property via `executeForwardStep_mcs`
- [ ] Get canonical relation via `executeForwardStep_canonicalR`
- [ ] Prove strictness via `canonicalR_strict`
- [ ] Construct reachability witness via `ConstructiveReachable.forward_witness`
- [ ] Build ConstructiveFragment element for successor MCS
- [ ] Lift to quotient via `toAntisymmetrization`
- [ ] Prove strict inequality using `toAntisymmetrization_lt_toAntisymmetrization_iff`
- [ ] Handle equality case via `canonicalR_irreflexive`
- [ ] Verify no goals remain with `lean_goal`

**Timing:** 45 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` - line 580

**Verification:**
- `lean_goal` at line 580 shows "no goals"
- `lake build` compiles without errors for this file

---

### Phase 2: Prove NoMinOrder.exists_lt [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Complete the sorry at line 585 proving every quotient element has a strictly lesser element

**Tasks:**
- [ ] Navigate to `ConstructiveFragment.lean` line 585
- [ ] Use `Quotient.ind` to reduce to underlying ConstructiveFragment element
- [ ] Get backward seriality witness via `mcs_contains_seriality_past w.val w.is_mcs`
- [ ] Execute backward step: `executeBackwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_P`
- [ ] Establish MCS property via `executeBackwardStep_mcs`
- [ ] Get canonical relation via `executeBackwardStep_canonicalR` (note: direction is `CanonicalR N w.val`)
- [ ] Prove strictness via `canonicalR_strict` (with swapped order)
- [ ] Construct reachability witness via `ConstructiveReachable.backward_witness`
- [ ] Build ConstructiveFragment element for predecessor MCS
- [ ] Lift to quotient via `toAntisymmetrization`
- [ ] Prove strict inequality using `toAntisymmetrization_lt_toAntisymmetrization_iff`
- [ ] Handle equality case via `canonicalR_irreflexive`
- [ ] Verify no goals remain with `lean_goal`

**Timing:** 45 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` - line 585

**Verification:**
- `lean_goal` at line 585 shows "no goals"
- `lake build` compiles without errors for this file

---

### Phase 3: Final Verification [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Verify zero-debt completion and full build success

**Tasks:**
- [ ] Run `lake build` on full project
- [ ] Verify no sorries in modified file: `grep -n "\bsorry\b" ConstructiveFragment.lean`
- [ ] Verify no new axioms introduced: `grep -n "^axiom " ConstructiveFragment.lean`
- [ ] Create implementation summary

**Timing:** 15 minutes

**Files to modify:**
- None (verification only)

**Verification:**
- `lake build` passes with zero errors
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` returns empty
- No new axioms in modified file

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Verifications
- [ ] NoMaxOrder instance compiles without errors
- [ ] NoMinOrder instance compiles without errors
- [ ] Both instances properly provide the required witnesses

## Artifacts & Outputs

- `specs/973_prove_constructivefragment_nomaxorder_nominorder/plans/implementation-001.md` (this file)
- `specs/973_prove_constructivefragment_nomaxorder_nominorder/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

## Rollback/Contingency

If implementation fails:
1. Revert changes to `ConstructiveFragment.lean` via `git checkout`
2. Mark task [BLOCKED] with specific error encountered
3. If proof strategy is fundamentally flawed, request revised research

Both proofs follow a well-established pattern from DiscreteTimeline.lean, so rollback should not be necessary. The main risk is syntax/implicit argument issues which can be resolved with minor adjustments.
