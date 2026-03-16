# Implementation Plan: Task #969 - Refactor TaskFrame Restrict Compositionality

- **Task**: 969 - Refactor TaskFrame to use forward_compositionality with `0 <= x` and `0 <= y` restriction
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: Task 966 (COMPLETED - axiomatization decision)
- **Research Inputs**: Task 966 decision, research_sign_elimination findings
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace universal compositionality in `TaskFrame` with a three-axiom system: `nullity_identity` (d=0 => w=u), `forward_comp` (restricted to non-negative durations), and `converse` (w -d- u iff u -(-d)- w). This axiomatization is algebraically equivalent to the current formulation but eliminates the impossible mixed-sign compositionality requirement.

The change propagates through the semantic layer (TaskFrame, WorldHistory) and metalogic constructions (CanonicalConstruction, DurationTransfer, IRRSoundness, example frames).

### Research Integration

From task 966 decision and research findings:
- Full mixed-sign compositionality requires functionality of positive-duration action (impossible for relational canonical model)
- The `respects_task` property only evaluates at `d = t - s >= 0` where `s <= t`, so negative durations are never tested in practice
- Converse axiom + non-negative compositionality is algebraically equivalent to current formulation
- Duration independence holds in canonical model (task_rel depends only on sign, not magnitude)

## Goals & Non-Goals

**Goals**:
- Replace `compositionality` with `nullity_identity`, `forward_comp`, `converse` in TaskFrame
- Derive `nullity` as theorem from `nullity_identity`
- Derive `backward_comp` as theorem from `forward_comp` + `converse`
- Update CanonicalConstruction to use converse for negative durations instead of `False`
- Update all example frames with trivial `converse` proofs
- Maintain build integrity at each phase

**Non-Goals**:
- Removing `s <= t` guard from WorldHistory (optional, keep for now)
- Adding new semantic capabilities beyond the axiom refactor
- Changing the logical meaning of task frames

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `forward_comp` proof complexity in CanonicalConstruction | H | M | The x=0 and y=0 cases use substitution; x>0,y>0 uses existing `canonicalR_transitive` |
| `converse` proof for canonical_task_rel requires CanonicalR symmetry | H | L | Research shows converse is trivial for group-based relations; canonical model uses sign-based definition |
| Downstream breakage in IRRSoundness | M | L | `prod_frame` compositionality uses same pattern as source frame |
| Example frames need non-trivial converse | L | L | Trivial frames have `task_rel = True` so converse is `trivial` |

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in scope files (TaskFrame.lean, WorldHistory.lean, CanonicalConstruction.lean, DurationTransfer.lean, IRRSoundness.lean, TemporalStructures.lean)

### Expected Resolution
- No existing sorries to resolve

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in modified files
- No new axioms introduced

## Implementation Phases

### Phase 1: TaskFrame.lean Core Refactor [COMPLETED]

- **Dependencies:** None
- **Goal:** Replace `compositionality` with `nullity_identity`, `forward_comp`, `converse` in TaskFrame structure

**Tasks:**
- [ ] Update `TaskFrame` structure: remove `nullity` and `compositionality` fields
- [ ] Add `nullity_identity : forall w u, task_rel w 0 u <-> w = u` field
- [ ] Add `forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v` field
- [ ] Add `converse : forall w d u, task_rel w d u <-> task_rel u (-d) w` field
- [ ] Derive `nullity : forall w, task_rel w 0 w` theorem from `nullity_identity`
- [ ] Derive `backward_comp` theorem from `forward_comp` + `converse` (optional, for convenience)
- [ ] Update `trivial_frame` with new axiom proofs (all trivial since task_rel = True)
- [ ] Update `identity_frame` with new axiom proofs
- [ ] Update `nat_frame` with new axiom proofs
- [ ] Update `FiniteTaskFrame` if needed

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Semantics/TaskFrame.lean` - core structure change

**Verification:**
- `lake build Bimodal.Semantics.TaskFrame` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Semantics/TaskFrame.lean` returns empty

---

### Phase 2: WorldHistory.lean Updates [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Ensure WorldHistory works with new TaskFrame axioms

**Tasks:**
- [ ] Verify `respects_task` field still works (it uses `s <= t` so only non-negative durations)
- [ ] Update any lemmas that referenced old `compositionality` directly
- [ ] Verify `time_shift` construction proofs still work
- [ ] Update docstrings to reference new axiom names

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Semantics/WorldHistory.lean` - minimal changes expected

**Verification:**
- `lake build Bimodal.Semantics.WorldHistory` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Semantics/WorldHistory.lean` returns empty

---

### Phase 3: DurationTransfer.lean Updates [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update canonicalTaskFrame to use new axiom structure

**Tasks:**
- [ ] Update `canonicalTaskFrame` definition with new fields
- [ ] Prove `nullity_identity`: `w + 0 = u <-> w = u` (trivial by `add_zero`)
- [ ] Prove `forward_comp`: `w + x = u -> u + y = v -> w + (x + y) = v` (uses `add_assoc`, no sign restriction needed since relation is deterministic)
- [ ] Prove `converse`: `w + d = u <-> u + (-d) = w` (trivial by group theory: `w + d = u <-> u - d = w`)
- [ ] Update `discreteTaskFrame` and `denseTaskFrame` wrappers

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` - update canonicalTaskFrame

**Verification:**
- `lake build Bimodal.Metalogic.Domain.DurationTransfer` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` returns empty

---

### Phase 4: CanonicalConstruction.lean Major Update [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update canonical_task_rel and CanonicalTaskFrame with new axiom structure

**Tasks:**
- [ ] Update `canonical_task_rel` definition:
  - `d > 0`: `CanonicalR M.val N.val` (unchanged)
  - `d = 0`: `M = N` (unchanged)
  - `d < 0`: `CanonicalR N.val M.val` (NEW: converse of positive case)
- [ ] Prove `canonical_task_rel_nullity_identity`: `canonical_task_rel M 0 N <-> M = N`
- [ ] Prove `canonical_task_rel_forward_comp`: restricted to `0 <= x` and `0 <= y`
  - x = 0, y = 0: transitivity of equality (M = U, U = V => M = V)
  - x = 0, y > 0: substitute M = U => CanonicalR M.val V.val
  - x > 0, y = 0: substitute U = V => CanonicalR M.val V.val
  - x > 0, y > 0: use `canonicalR_transitive`
- [ ] Prove `canonical_task_rel_converse`: `canonical_task_rel M d N <-> canonical_task_rel N (-d) M`
  - Case d > 0: need CanonicalR M.val N.val <-> CanonicalR N.val M.val (this is NOT generally true!)

**CRITICAL OBSERVATION**: The converse axiom for canonical_task_rel requires `CanonicalR` to be symmetric, which it is NOT (it represents GContent subset). This needs careful analysis.

**Alternative approach**: Use the research finding that `d < 0` maps to `CanonicalR N.val M.val` (i.e., the backward direction). Then converse becomes:
- `d > 0`: task_rel M d N = CanonicalR M N; task_rel N (-d) M = CanonicalR N M (since -d < 0, we use backward case)
- Wait, this doesn't match either.

**Resolution**: The canonical_task_rel should be:
- `d > 0`: `CanonicalR M.val N.val` (forward accessibility)
- `d = 0`: `M = N`
- `d < 0`: `CanonicalR N.val M.val` (backward accessibility = forward from N to M)

Then converse says: `task_rel M d N <-> task_rel N (-d) M`
- If d > 0: LHS = CanonicalR M N, RHS (with -d < 0) = CanonicalR M N. Matches!
- If d = 0: LHS = M = N, RHS (with -0 = 0) = N = M. Matches!
- If d < 0: LHS = CanonicalR N M, RHS (with -d > 0) = CanonicalR N M. Matches!

This works! Update the plan to reflect this.

- [ ] Update `CanonicalTaskFrame` with new axiom proofs
- [ ] Verify `to_history` still works (only uses forward direction since `s <= t`)
- [ ] Verify `canonical_truth_lemma` still works

**Timing:** 2-3 hours (most complex phase)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - significant changes

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.CanonicalConstruction` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty
- `canonical_truth_lemma` type-checks

---

### Phase 5: IRRSoundness.lean Updates [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update prod_frame and lift_history for new TaskFrame axioms

**Tasks:**
- [ ] Update `prod_frame` definition with new axiom fields:
  - `nullity_identity`: project to underlying frame's nullity_identity
  - `forward_comp`: project to underlying frame's forward_comp
  - `converse`: project to underlying frame's converse
- [ ] Verify `lift_history` respects_task proof still works
- [ ] Verify `omega_prod_shift_closed` still works
- [ ] Verify `truth_prod_iff` and `irr_sound_dense_at_domain` still work

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - update prod_frame

**Verification:**
- `lake build Bimodal.Metalogic.IRRSoundness` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/IRRSoundness.lean` returns empty

---

### Phase 6: TemporalStructures.lean Example Updates [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update all example frames with new axiom proofs

**Tasks:**
- [ ] Update `intTimeFrame` with new axiom proofs (trivial: task_rel = True)
- [ ] Update `intNatFrame` with new axiom proofs (trivial)
- [ ] Update `genericTimeFrame` with new axiom proofs (trivial)
- [ ] Update `genericNatFrame` with new axiom proofs (trivial)
- [ ] Verify all example theorems still hold

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Examples/TemporalStructures.lean` - add converse proofs

**Verification:**
- `lake build Bimodal.Examples.TemporalStructures` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Examples/TemporalStructures.lean` returns empty

---

### Phase 7: Final Verification and Documentation [COMPLETED]

- **Dependencies:** Phase 1-6
- **Goal:** Verify complete build and update documentation

**Tasks:**
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify zero sorries in all modified files
- [ ] Verify zero new axioms introduced
- [ ] Update TaskFrame.lean docstrings with new axiom descriptions
- [ ] Update any references to old `compositionality` in comments
- [ ] Create implementation summary

**Timing:** 0.5 hours

**Files to modify:**
- Documentation updates in modified files

**Verification:**
- `lake build` passes (full project)
- `grep -rn "\bsorry\b" Theories/Bimodal/Semantics/ Theories/Bimodal/Metalogic/ Theories/Bimodal/Examples/` returns empty for modified files
- `grep -n "^axiom " <modified files>` shows no new axioms

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validation
- [ ] `canonical_truth_lemma` type-checks without modification to proof structure
- [ ] `irr_sound_dense_at_domain` type-checks without modification
- [ ] All example frames compile successfully
- [ ] No downstream file breakage in unmodified files

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation state
2. Document the specific blocker in summary
3. If `converse` axiom is mathematically problematic for CanonicalConstruction:
   - Consider alternative: keep `d < 0 -> False` and derive converse only for non-negative durations
   - Or: restructure canonical_task_rel to be symmetric (may require changing CanonicalR definition)
