# Implementation Plan: Task #448 - Build canonical_history

- **Task**: 448 - Build canonical_history
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Priority**: Low
- **Dependencies**: Task 447 (Canonical frame and model construction - COMPLETED)
- **Research Inputs**: .claude/specs/448_build_canonical_history/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Phase 5 of completeness proofs: Implement the `canonical_history` function that constructs a `WorldHistory canonical_frame` from a `CanonicalWorldState` (maximal consistent set). The research recommends a singleton domain MVP approach, which uses only time 0 in the domain and relies solely on `canonical_nullity` for the `respects_task` proof. This minimizes complexity while providing a working foundation for the truth lemma (Task 449).

### Research Integration

The research report (research-001.md) identified three approaches:
1. **Singleton domain at time 0** (recommended) - Simplest, sufficient for base cases
2. Full domain over all Duration values - Most general, requires existence lemmas
3. Generated domain from temporal formulas - Medium complexity

This plan implements approach 1 (singleton domain MVP) per the research recommendation. The singleton approach avoids the incomplete temporal compositionality from Task 447 and can be extended later if the truth lemma requires non-trivial temporal witnesses.

## Goals & Non-Goals

**Goals**:
- Replace `axiom canonical_history` stub with a concrete definition
- Implement WorldHistory structure with singleton domain at time 0
- Prove convexity and respects_task properties
- Ensure `lake build` succeeds without new errors
- Document singleton domain limitation for Task 449 (truth lemma)

**Non-Goals**:
- Implement full domain over all Duration values (Phase 5C if needed)
- Implement forward/backward existence lemmas (deferred)
- Fix temporal compositionality in canonical_task_rel (Task 447 follow-up)
- Prove truth lemma temporal cases (Task 449)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Singleton domain causes truth lemma failures | High | Medium-High | Document limitation clearly; extension plan ready |
| Duration type proofs interfere | Medium | Low | Singleton uses only `0` and basic equality |
| Type universe issues | Medium | Low | Match existing canonical_frame universe levels |
| Dependent type complications in states function | Medium | Medium | Use explicit type casts as shown in research template |

## Implementation Phases

### Phase 1: Implement singleton canonical_history [NOT STARTED]

**Goal**: Replace the axiom stub with a working definition using singleton domain

**Tasks**:
- [ ] Read current `canonical_history` axiom at line 2212 of Completeness.lean
- [ ] Define `canonical_history` with singleton domain `fun t => t = 0`
- [ ] Prove `convex` property (singleton is trivially convex)
- [ ] Prove `states` function returns S at time 0
- [ ] Prove `respects_task` using `canonical_nullity` for t - s = 0 case
- [ ] Add docstring documenting MVP approach and limitations

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines 2197-2212 (replace axiom with definition)

**Verification**:
- Definition compiles without `sorry` or `axiom`
- Type signature matches: `CanonicalWorldState -> WorldHistory canonical_frame`
- No errors from `lean_diagnostic_messages` for Completeness.lean

---

### Phase 2: Build verification and integration [NOT STARTED]

**Goal**: Verify the implementation compiles and integrates with existing code

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.Completeness`
- [ ] Check for any new errors or warnings
- [ ] Verify no regressions in existing proofs
- [ ] Confirm `canonical_model` still compiles with the new history
- [ ] Test that downstream code using `canonical_history` compiles

**Timing**: 30-45 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` succeeds
- No new errors in diagnostics
- Existing canonical_frame, canonical_model, canonical_valuation unaffected

---

### Phase 3: Documentation and downstream preparation [NOT STARTED]

**Goal**: Document the singleton domain limitation and prepare for Task 449

**Tasks**:
- [ ] Update docstring with detailed explanation of singleton domain trade-offs
- [ ] Add comments explaining why singleton domain is sufficient for MVP
- [ ] Document how temporal operators will behave (vacuously true)
- [ ] Add note about extension path (Phase 5B/5C from research)
- [ ] Create brief note for Task 449 about known limitation

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Docstring expansion

**Verification**:
- Docstring clearly explains singleton domain choice
- Limitation for temporal operators documented
- Extension path noted for future work

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] No `sorry` placeholders in `canonical_history` definition
- [ ] No `axiom` keyword in `canonical_history` definition
- [ ] `lean_diagnostic_messages` shows no errors for Completeness.lean
- [ ] `lean_goal` at respects_task proof shows "no goals" (complete)
- [ ] Type of `canonical_history` is exactly `CanonicalWorldState -> WorldHistory canonical_frame`

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Completeness.lean` with `canonical_history` definition
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If implementation encounters issues:

1. **Type errors**: Check WorldHistory structure requirements in WorldHistory.lean
2. **Universe issues**: Ensure Duration and CanonicalWorldState universes align with canonical_frame
3. **Proof difficulties**: Consult research report template code (lines 390-426)
4. **Build failures**: Revert to axiom stub, document blockers for escalation

If singleton domain proves insufficient during Task 449:
- Create follow-up task for Phase 5B/5C (full domain extension)
- Implement forward/backward existence lemmas per research recommendations
- May require fixing temporal compositionality first (Task 447 follow-up)

## Implementation Template Reference

From research report, the recommended implementation:

```lean
def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun t => t = 0
  convex := by
    intros x z hx hz y hxy hyz
    simp only at hx hz ⊢
    have hxz : x = z := by rw [hx, hz]
    have hxy' : x = y := le_antisymm hxy (hxz ▸ hyz)
    exact hxy' ▸ hx
  states := fun t ht => by
    simp only at ht
    exact ht ▸ S
  respects_task := by
    intros s t hs ht hst
    simp only at hs ht
    have h_diff : t - s = 0 := by rw [hs, ht]; ring
    rw [h_diff]
    exact canonical_nullity S
```

Note: This template may need adjustment for Lean 4 syntax and project-specific conventions.
