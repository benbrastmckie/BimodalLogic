# Implementation Plan: Task #29 (v6 - Per-Construction Strictness)

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [PARTIAL] (Phases 4, 5A complete; 5B-8 remaining)
- **Effort**: 6-10 hours remaining (5B/5C ~4h, Phase 6 ~0.5h, Phase 7-8 ~3h)
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/12_team-research.md (order-theoretic foundations)
  - specs/029_switch_to_reflexive_gh_semantics/reports/13_unbounded-axiom-analysis.md (seriality axiom analysis)
- **Supersedes**: plans/05_irr-removal-approach.md (v5)
- **Artifacts**: plans/06_per-construction-strictness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

**Plan v6 incorporates the critical findings from team research (report 12):**

1. **Fresh atom existence is NOT provable in general** — The cardinality argument fails; a pathological MCS (all atoms always false) covers all atoms
2. **Per-construction strictness is mathematically correct** — Prove ¬CanonicalR W M at each call site using construction-specific arguments
3. **Bypass fresh atom theorems entirely** — Don't attempt universal existence proofs; use site-specific witness distinctness
4. **Antisymmetry fails** — CanonicalR is a preorder, not a partial order; mutual accessibility is possible

### Key Insight: Witness Distinctness from Formula Content

The team research proved that **strictness comes from the specific construction**, not from universal properties:

> When `F(φ) ∈ M` and we construct witness `W ⊇ g_content(M) ∪ {φ}`:
> - `φ ∈ W` (by construction)
> - `CanonicalR M W` (since g_content(M) ⊆ W)
> - If `φ ∉ M`, then `W ≠ M`, so we get strictness
> - If `φ ∈ M`, the obligation is reflexively satisfied — no strict successor needed

**Critical**: The strict successor is needed for **frame conditions (NoMaxOrder)**, not for the Truth Lemma. When `F(φ) ∈ M` and `φ ∈ M`, the semantic obligation IS satisfied reflexively.

### What Changed from Plan v5

| v5 Approach | v6 Approach |
|-------------|-------------|
| Prove `exists_fresh_for_g_content` via cardinality | **DELETE** — cardinality argument is flawed |
| Prove `fresh_Gp_seed_consistent` universally | Keep proven theorem; use selectively |
| Prove `canonicalR_strict_successor` universally | **REPLACE** with per-site strictness |
| Blocked on "order structure decision" | **RESOLVED** — use per-construction strictness |

### Completed Work (Preserved)

Phases 1-3 from plan v5 are COMPLETED:
- Phase 1: Remove IRR from Proof System ✓
- Phase 2: Remove IRR from Conservative Extension ✓
- Phase 3: Delete Obsolete Files ✓

Phase 4 key theorem `fresh_Gp_seed_consistent` is PROVEN. The infrastructure is ready.

## Goals & Non-Goals

**Goals**:
- Delete flawed cardinality-based theorems (`exists_fresh_for_g_content`, `fresh_for_g_content_some_decided_false`)
- Replace ~30 `canonicalR_irreflexive` call sites with construction-specific strictness
- Introduce `lt_of_canonicalR_and_not_reverse` requiring explicit backward non-accessibility
- Prove strictness at each call site from the specific witness construction
- Delete `canonicalR_irreflexive_axiom` to restore consistency
- Update documentation for reflexive semantics

**Non-Goals**:
- Proving universal `canonicalR_strict_successor` (per-site is sufficient)
- Proving `canonicalR_antisymmetric` (FALSE under reflexive semantics)
- Modifying seriality axioms (they're trivially valid and needed)
- Task 25 work (deferred)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Call site variety | M | M | Team research categorized all ~30 sites; patterns are clear |
| Strictness proof complexity | M | L | Most sites have obvious witness distinctness from formula content |
| Frame condition proofs | M | M | NoMaxOrder/NoMinOrder need fresh-atom construction; use `fresh_Gp_seed_consistent` |

## Implementation Phases

### Phase 4: Clean Up Flawed Theorems [COMPLETED]

**Goal**: Remove cardinality-based theorems that are provably false.

**Effort**: 1 hour

**Tasks**:
- [ ] Delete `exists_fresh_for_g_content` (line ~312) — cardinality argument is flawed
- [ ] Delete `fresh_for_g_content_some_decided_false` (line ~668) — depends on above
- [ ] Delete `naming_set_consistent` (line ~512) — unused legacy from IRR approach
- [ ] Keep `fresh_Gp_seed_consistent` — this IS proven and works for specific seeds
- [ ] Add documentation explaining why universal fresh atom existence fails
- [ ] Run `lake build` — verify no regressions

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- No references to deleted theorems remain

---

### Phase 5A: Introduce Per-Construction Strictness Infrastructure [COMPLETED]

**Goal**: Create the lemma that enables per-site strictness proofs.

**Effort**: 1 hour

**Tasks**:
- [ ] Create theorem `lt_of_canonicalR_and_not_reverse`:
  ```lean
  theorem lt_of_canonicalR_and_not_reverse {M N : CanonicalMCS}
      (h_fwd : CanonicalR M.world N.world)
      (h_not_bwd : ¬CanonicalR N.world M.world) :
      M < N := by
    constructor
    · exact h_fwd
    · intro h_eq
      rw [h_eq] at h_not_bwd
      exact h_not_bwd (canonicalR_reflexive N.world)
  ```
- [ ] Create theorem `strict_of_formula_not_in_source`:
  ```lean
  /-- When witness W contains a formula φ that is NOT in source M,
      and φ ∈ g_content(W), then ¬CanonicalR W M. -/
  theorem strict_of_formula_not_in_source {M W : MCS} {φ : Formula}
      (h_φ_in_W : φ ∈ W.formulas)
      (h_φ_g_content : φ ∈ g_content W)  -- i.e., G(φ) ∈ W
      (h_φ_not_M : φ ∉ M.formulas) :
      ¬CanonicalR W.world M.world := by
    intro h_contra
    -- h_contra : g_content(W) ⊆ M
    have : φ ∈ M.formulas := h_contra h_φ_g_content
    exact h_φ_not_M this
  ```
- [ ] Add documentation explaining per-construction strictness pattern
- [ ] Run `lake build`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` (or new file)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- New theorems are available for Phase 5B

---

### Phase 5B: Refactor Frame Condition Sites [NOT STARTED]

**Goal**: Fix NoMaxOrder and NoMinOrder instances using per-construction strictness.

**Effort**: 2-3 hours

These are the critical sites that NEED strict successors for the frame conditions.

**Pattern for NoMaxOrder**:
```lean
instance : NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_gt a := by
    -- Step 1: Get F(¬⊥) ∈ M via seriality axiom
    have h_serial : F (¬⊥) ∈ a.world.formulas := seriality_membership a.world
    -- Step 2: Build successor seed: g_content(M) ∪ {¬⊥}
    -- Step 3: Extend to MCS via Lindenbaum
    -- Step 4: Prove strictness from ¬⊥ ∉ M (bottom is not in consistent sets)
    -- Use strict_of_formula_not_in_source
```

**Tasks by file**:

**CanonicalSerialFrameInstance.lean (~2 sites)**:
- [ ] Refactor `NoMaxOrder` instance — use seriality + bottom non-membership
- [ ] Refactor `NoMinOrder` instance — symmetric using H and P

**CantorApplication.lean (~4 sites)**:
- [ ] `cantor_noMaxOrder` — use fresh-atom seed construction
- [ ] `cantor_noMinOrder` — symmetric
- [ ] `cantor_denselyOrdered_between` — strictness from interpolated formula
- [ ] `cantor_denselyOrdered` — combines above

**DovetailedTimelineQuot.lean (~12 sites)**:
This file has the most call sites. Pattern:
- [ ] `dovetailed_noMaxOrder` — use witness formula distinctness
- [ ] `dovetailed_noMinOrder` — symmetric
- [ ] `dovetailed_denselyOrdered` — interpolation gives strict witnesses
- [ ] Additional `canonicalR_strict` uses (~9) — audit each

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Verification**:
- `lake build` passes
- Frame condition instances proven without `canonicalR_irreflexive`

---

### Phase 5C: Refactor Remaining Call Sites [NOT STARTED]

**Goal**: Fix non-frame-condition uses of `canonicalR_irreflexive`.

**Effort**: 2-3 hours

**Tasks by file**:

**SaturatedChain.lean (~8 sites)**:
- [ ] Chain construction strictness — use formula witness at each step
- [ ] Pattern: each chain step adds a formula not in previous MCS

**FMCSTransfer.lean (~2 sites)**:
- [ ] Transfer lemma strictness — witness comes from transfer formula
- [ ] Use `strict_of_formula_not_in_source`

**ClosureSaturation.lean (~2 sites)**:
- [ ] Saturation step strictness — added formula gives distinctness

**IncrementalTimeline.lean (~1 site)**:
- [ ] Timeline point equality — use MCS distinctness directly

**TimelineQuotCanonical.lean (~1 site)**:
- [ ] Quotient canonical — likely uses formula witness

**DiscreteTimeline.lean (~2 sites)**:
- [ ] Discrete successor strictness — DF/SF axiom witnesses

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
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from `CanonicalIrreflexivity.lean`
- [ ] Remove any re-exports or wrappers
- [ ] Run `lake build`
- [ ] Verify no references remain

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no matches
- System is CONSISTENT (only `canonicalR_reflexive` exists)

---

### Phase 7: Update Documentation [NOT STARTED]

**Goal**: Align documentation with reflexive semantics.

**Effort**: 1-2 hours

**Tasks**:
- [ ] Update comments explaining per-construction strictness pattern
- [ ] Update comments in ~20 files with outdated irreflexive references
- [ ] Add documentation explaining why universal fresh atom existence fails
- [ ] Document the preorder structure (antisymmetry fails)
- [ ] Update typst/latex documentation

**Files to modify**: See report 20_teammate-b-findings.md for complete list

**Verification**:
- Documentation accurately describes reflexive semantics
- No misleading "irreflexive" comments remain (except historical notes)

---

### Phase 8: T-Axiom Proofs for Remaining Axioms [NOT STARTED]

**Goal**: Prove consistency axioms using T-axiom where possible.

**Effort**: 2-3 hours

Carried forward from plan v5.

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
- [ ] Phase 4: Flawed cardinality theorems deleted
- [ ] Phase 5A: `lt_of_canonicalR_and_not_reverse` available
- [ ] Phase 5B: Frame condition instances use per-construction strictness
- [ ] Phase 5C: All non-frame call sites refactored
- [ ] Phase 6: `canonicalR_irreflexive_axiom` deleted
- [ ] Final: `grep -r "canonicalR_irreflexive" Theories/` returns no code matches
- [ ] Final: Sorry count reduced; system is consistent

## Artifacts & Outputs

- Updated `CanonicalIrreflexivity.lean` (flawed theorems removed, infrastructure added)
- Refactored ~30 call sites using per-construction strictness
- Deleted `canonicalR_irreflexive_axiom`
- Updated documentation for reflexive semantics
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/08_per-construction-summary.md`

## Key Mathematical Insight (From Team Research)

The team research proved:

> The mathematically elegant and correct solution, making no compromises:
> 1. **Accept preorder structure** — CanonicalR is a preorder, antisymmetry fails
> 2. **Per-construction strictness** — prove witness ≠ source at each construction site
> 3. **Bypass fresh atom existence** — don't try to prove it universally
> 4. **Replace `lt_of_canonicalR` with `lt_of_canonicalR_and_not_reverse`**
> 5. **At each call site**, prove ¬CanonicalR W M from the specific construction

This approach:
- Has no axioms
- Has no cardinality arguments
- Has no antisymmetry assumption
- Is mathematically rigorous
- Works even for pathological MCS

## Rollback/Contingency

If per-construction strictness proves difficult at specific sites:

1. **Phase 4-5A are safe**: Infrastructure changes don't break existing code
2. **Per-site fallback**: Leave sorries at difficult sites; document for future
3. **Fresh atom for frame conditions**: `fresh_Gp_seed_consistent` IS proven for specific seeds
4. **Git revert**: All changes are incremental
