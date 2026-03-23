# Implementation Plan: Task #29 (v7 - MCS-Decided Atom Approach)

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours remaining
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/29_team-research.md (blocker resolution synthesis)
  - specs/029_switch_to_reflexive_gh_semantics/reports/29_teammate-b-findings.md (MCS-decided atom pattern)
  - specs/029_switch_to_reflexive_gh_semantics/reports/29_teammate-c-findings.md (root cause: conceptual error)
- **Supersedes**: plans/06_per-construction-strictness.md (v6 - blocked on fresh atom existence)
- **Artifacts**: plans/07_mcs-decided-atom-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

**Plan v7 resolves the Phase 5B blocker** identified in v6 using the solution from team research (report 29):

**Root Cause (from Teammate C)**: The blocker was a conceptual error — attempting to prove universal fresh atom existence when only per-construction distinctness is needed.

**Solution (from Teammate B)**: Use MCS-decided atoms. Every atom p is decided by an MCS (either p ∈ M or ¬p ∈ M). The opposite literal provides the distinguishing formula.

### The MCS-Decided Atom Pattern

For any MCS M requiring a strict successor:

```
1. Pick any atom p (Atom is nonempty)
2. Case split on p ∈ M:
   - If p ∈ M: Use seed g_content(M) ∪ {G(¬p)}
     → Witness W has ¬p ∈ g_content(W) but p ∈ M → distinctness!
   - If p ∉ M: By maximality, ¬p ∈ M. Use seed g_content(M) ∪ {G(p)}
     → Witness W has p ∈ g_content(W) but ¬p ∈ M → distinctness!
```

### Why This Works (Even for Pathological MCS)

The pathological MCS (G(¬q) ∈ M for all atoms q) is real but NOT a blocker:
- Every atom q has ¬q ∈ M (from G(¬q) and T-axiom)
- So q ∉ M for any atom q
- Use seed g_content(M) ∪ {G(q)} for any atom q
- Witness W has q ∈ g_content(W) but q ∉ M → distinctness!

### What Changed from Plan v6

| v6 Approach | v7 Approach |
|-------------|-------------|
| Blocked on fresh atom existence | No fresh atoms needed |
| Per-construction strictness (incomplete) | MCS-decided atom pattern (complete) |
| 6-10h remaining (blocked) | 6-10h remaining (unblocked) |

### Completed Work (Preserved from v5/v6)

- **Phases 1-3**: IRR removed from proof system ✓
- **Phase 4**: Flawed cardinality theorems deleted ✓
- **Phase 5A**: Per-construction strictness infrastructure ✓
  - `lt_of_canonicalR_and_not_reverse` ✓
  - `strict_of_formula_in_g_content_not_in_source` ✓
  - `strict_of_formula_with_G_not_in_source` ✓

## Goals & Non-Goals

**Goals**:
- Add MCS-decided atom lemmas for strictness
- Refactor ~30 call sites using MCS-decided atom pattern
- Delete `canonicalR_irreflexive_axiom` to restore consistency
- Update documentation for reflexive semantics
- Complete T-axiom proofs for remaining axioms

**Non-Goals**:
- Proving universal fresh atom existence (FALSE, deleted in v6)
- Proving antisymmetry (FALSE under reflexive semantics)
- Seed tracking through MCS construction (unnecessary)
- Quotient via Antisymmetrization (optional enhancement, not required)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency for G(¬p) when p ∈ M | M | L | `fresh_Gp_seed_consistent` variant should apply |
| Call site variety | M | L | MCS-decided pattern is uniform |
| Edge cases in proof | M | L | Pattern works for ALL MCS including pathological |

## Implementation Phases

### Phase 5A-bis: Add MCS-Decided Atom Infrastructure [NOT STARTED]

**Goal**: Add the lemmas needed for the MCS-decided atom pattern.

**Effort**: 1-2 hours

**Tasks**:
- [ ] Prove `mcs_decides_atom`:
  ```lean
  theorem mcs_decides_atom (M : MCS) (p : Atom) :
      (atom p) ∈ M.formulas ∨ (¬atom p) ∈ M.formulas := by
    exact mcs_complete M (atom p)
  ```
- [ ] Prove `Gneg_seed_consistent`:
  ```lean
  /-- When p ∈ M, the seed g_content(M) ∪ {G(¬p)} is consistent -/
  theorem Gneg_seed_consistent (M : MCS) (p : Atom) (hp : (atom p) ∈ M.formulas) :
      SetConsistent (g_content M ∪ {G (¬atom p)}) := by
    -- Similar to fresh_Gp_seed_consistent but using ¬p instead of fresh q
    sorry
  ```
- [ ] Prove `Gpos_seed_consistent`:
  ```lean
  /-- When ¬p ∈ M, the seed g_content(M) ∪ {G(p)} is consistent -/
  theorem Gpos_seed_consistent (M : MCS) (p : Atom) (hp : (¬atom p) ∈ M.formulas) :
      SetConsistent (g_content M ∪ {G (atom p)}) := by
    -- Symmetric
    sorry
  ```
- [ ] Prove `exists_strict_successor_via_decided_atom`:
  ```lean
  theorem exists_strict_successor_via_decided_atom (M : MCS) :
      ∃ W : MCS, CanonicalR M W ∧ ¬CanonicalR W M := by
    obtain ⟨p⟩ : Nonempty Atom := inferInstance
    rcases mcs_decides_atom M p with hp | hnp
    · -- p ∈ M: use G(¬p) seed
      have h_cons := Gneg_seed_consistent M p hp
      let W := lindenbaum (g_content M ∪ {G (¬atom p)}) h_cons
      refine ⟨W, ?_, ?_⟩
      · -- CanonicalR M W: g_content M ⊆ W
        sorry
      · -- ¬CanonicalR W M: ¬p ∈ g_content(W) but p ∈ M
        apply strict_of_formula_with_G_not_in_source
        · -- G(¬p) ∈ W (from seed)
          sorry
        · -- ¬p ∉ M (since p ∈ M and MCS consistent)
          sorry
    · -- ¬p ∈ M: use G(p) seed (symmetric)
      sorry
  ```
- [ ] Run `lake build`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- `exists_strict_successor_via_decided_atom` proven without sorry

---

### Phase 5B: Refactor Frame Condition Sites [NOT STARTED]

**Goal**: Update NoMaxOrder/NoMinOrder instances using MCS-decided atom pattern.

**Effort**: 2-3 hours

**Pattern for NoMaxOrder**:
```lean
instance : NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_gt a := by
    -- Use exists_strict_successor_via_decided_atom
    obtain ⟨W, h_fwd, h_not_bwd⟩ := exists_strict_successor_via_decided_atom a.world
    exact ⟨⟨W, ...⟩, lt_of_canonicalR_and_not_reverse h_fwd h_not_bwd⟩
```

**Tasks by file**:

**CanonicalSerialFrameInstance.lean (~2 sites)**:
- [ ] Refactor `NoMaxOrder` instance using `exists_strict_successor_via_decided_atom`
- [ ] Refactor `NoMinOrder` instance (symmetric, using H)

**CantorApplication.lean (~4 sites)**:
- [ ] `cantor_noMaxOrder` — apply decided atom pattern
- [ ] `cantor_noMinOrder` — symmetric
- [ ] `cantor_denselyOrdered_between` — strictness from interpolated formula
- [ ] `cantor_denselyOrdered` — combines above

**DovetailedTimelineQuot.lean (~12 sites)**:
- [ ] Audit each site — most should use `exists_strict_successor_via_decided_atom`
- [ ] Or use specific witness formula from the dovetailed construction

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Verification**:
- `lake build` passes
- Frame condition instances use `exists_strict_successor_via_decided_atom` or equivalent

---

### Phase 5C: Refactor Remaining Call Sites [NOT STARTED]

**Goal**: Update non-frame-condition uses of `canonicalR_irreflexive`.

**Effort**: 2-3 hours

**Tasks by file**:

**SaturatedChain.lean (~8 sites)**:
- [ ] Chain construction — use witness formula from step

**FMCSTransfer.lean (~2 sites)**:
- [ ] Transfer lemma — use transfer formula as witness

**ClosureSaturation.lean (~2 sites)**:
- [ ] Saturation step — added formula gives distinctness

**IncrementalTimeline.lean (~1 site)**:
- [ ] Timeline point — use MCS distinctness

**TimelineQuotCanonical.lean (~1 site)**:
- [ ] Quotient canonical — formula witness

**DiscreteTimeline.lean (~2 sites)**:
- [ ] Discrete successor — DF/SF axiom witnesses

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean`
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification**:
- `lake build` passes
- `grep -r "canonicalR_irreflexive[^_]" Theories/` returns only axiom declaration

---

### Phase 6: Delete Axiom and Restore Consistency [NOT STARTED]

**Goal**: Remove the deprecated axiom.

**Effort**: 30 minutes

**Tasks**:
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from `CanonicalIrreflexivityAxiom.lean`
- [ ] Remove any re-exports or wrappers
- [ ] Run `lake build`
- [ ] Verify `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no matches

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (remove wrapper if any)

**Verification**:
- `lake build` passes
- System is CONSISTENT (only `canonicalR_reflexive` exists)
- Axiom count reduced by 1

---

### Phase 7: Update Documentation [NOT STARTED]

**Goal**: Align documentation with reflexive semantics.

**Effort**: 1-2 hours

**Tasks**:
- [ ] Update comments explaining MCS-decided atom pattern
- [ ] Update comments in ~20 files with outdated irreflexive references
- [ ] Document why universal fresh atom existence is false
- [ ] Document the preorder structure (antisymmetry fails)
- [ ] Update typst/latex documentation

**Files to modify**: See report 20_teammate-b-findings.md for complete list

**Verification**:
- Documentation accurately describes reflexive semantics
- No misleading "irreflexive" comments remain

---

### Phase 8: T-Axiom Proofs for Remaining Axioms [NOT STARTED]

**Goal**: Prove consistency axioms using T-axiom where possible.

**Effort**: 2-3 hours

**Tasks**:
- [ ] Complete `discreteImmediateSuccSeed_consistent` using T-axiom
- [ ] Remove `discreteImmediateSuccSeed_consistent_axiom` if proof succeeds
- [ ] Assess `discreteImmediateSucc_covers_axiom`
- [ ] Assess `successor_deferral_seed_consistent_axiom`
- [ ] Assess `predecessor_deferral_seed_consistent_axiom`
- [ ] Document remaining axioms

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `lake build` passes
- Axiom count reduced where proofs succeed

---

## Testing & Validation

- [ ] Full `lake build` passes after each phase
- [ ] Phase 5A-bis: `exists_strict_successor_via_decided_atom` proven
- [ ] Phase 5B: Frame condition instances refactored
- [ ] Phase 5C: All non-frame call sites refactored
- [ ] Phase 6: `canonicalR_irreflexive_axiom` deleted
- [ ] Final: `grep -r "canonicalR_irreflexive" Theories/` returns no code matches
- [ ] Final: System is consistent, build passes

## Artifacts & Outputs

- Updated `CanonicalIrreflexivity.lean` (MCS-decided atom infrastructure)
- Refactored ~30 call sites using MCS-decided atom pattern
- Deleted `canonicalR_irreflexive_axiom`
- Updated documentation for reflexive semantics
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/10_mcs-decided-summary.md`

## Key Mathematical Insight (From Team Research Report 29)

The team research proved:

> **Root Cause**: The conceptual error was trying to prove universal fresh atom existence when only per-construction distinctness is needed.
>
> **Solution**: Use MCS-decided atoms. Every atom p is decided by an MCS. The opposite literal provides distinctness.
>
> **This works for ALL MCS** including the pathological one where G(¬q) ∈ M for all atoms.

This approach:
- Has NO new axioms
- Requires NO seed tracking
- Is mathematically rigorous
- Works uniformly for all call sites

## Rollback/Contingency

If seed consistency proofs (Gneg_seed_consistent, Gpos_seed_consistent) prove difficult:

1. **Phase 5A-bis is the critical path** — focus there first
2. **Leverage fresh_Gp_seed_consistent** — the proof technique should transfer
3. **If stuck**: Consider adding a minimal semantic axiom (Option D from report 29)
4. **Git revert**: All changes are incremental

The MCS-decided pattern is mathematically sound. Only proof mechanics remain.
