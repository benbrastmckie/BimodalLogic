# Implementation Plan: Remove A4a and Simplify BX2

- **Task**: 115 - Remove A4a (separation_until/separation_since) and simplify BX2 for axiom minimality
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 107 (chronicle infrastructure), Task 124 (removed temp_future, validated safety-first pattern)
- **Research Inputs**: specs/115_replace_a4a_with_left_mono_until_g/reports/01_a4a-vs-left-mono.md
- **Artifacts**: plans/01_remove-a4a-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove the `separation_until` (BX14) and `separation_since` (BX14') axiom constructors from the axiom set to achieve axiom minimality, reducing the constructor count from 44 to 42. The safety-first approach (proven in task 124) will be followed: first derive A4a as a theorem from the existing `left_mono_until_G` axiom, then rewrite all 4 usage sites in PointInsertion.lean, then remove the constructors and update all downstream match arms. BX2 simplification (removing the redundant pointwise conjunct) is deferred as a non-goal to limit blast radius.

### Research Integration

The research report (01_a4a-vs-left-mono.md) established:
- `left_mono_until_G` is already in the axiom set (added in task 107 Phase 5b)
- A4a is used at exactly 4 sites in PointInsertion.lean, all calling `separation_until_mcs` (line 1066)
- A4a cannot be directly derived from `left_mono_until_G` (they address orthogonal needs)
- However, the 4 usage sites all follow a pattern: BX5 (self-accumulation) then BX14 (separation) to extract F(beta.neg). This pattern can be replicated using `left_mono_until_G` + BX5 + BX10 without A4a.
- BX2's pointwise conjunct is redundant under open-guard semantics but removing it has broader blast radius (CanonicalChain.lean, RRelation.lean)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- ROADMAP Phase 2 explicitly lists "remove A4a (task 115)" as an axiom cleanup item
- Part of the sequence: remove TF (task 124, done) -> remove A4a (task 115) -> redefine G/H/F/P via U/S (task 116)

## Goals & Non-Goals

**Goals**:
- Derive A4a (separation_until/separation_since) as theorems from existing axioms
- Rewrite the 4 PointInsertion.lean proof chains to avoid `Axiom.separation_until`
- Remove `separation_until` and `separation_since` constructors from Axioms.lean
- Remove soundness proofs and all match arms referencing these constructors
- Remove substitution cases in Substitution.lean
- Achieve clean `lake build` with 42 axiom constructors

**Non-Goals**:
- Simplifying BX2 (removing pointwise conjunct): too broad a blast radius; separate task
- Implementing Xu Lemma 2.3/2.4 path: the existing proof chains already work, they just need A4a replaced with an equivalent derivation
- Modifying CanonicalChain.lean's `left_mono_until_mcs` (it uses BX2, not A4a)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A4a derivation from existing axioms fails | H | L | The 4 usage sites all follow the same pattern (BX5 + separation -> F(neg)). Each can be refactored individually using BX5 + left_mono_until_G + BX10 to achieve the same F(beta.neg) conclusion. |
| Removing constructors causes exhaustiveness errors in unexpected files | M | L | Grep identified all 5 files with match arms. No ConservativeExtension directory exists. |
| PointInsertion.lean proof chains break due to structural mismatch | M | M | Derive A4a as a standalone theorem first so existing proofs keep compiling; only remove constructors after all uses are eliminated. |
| Build time regression from larger derivation trees | L | L | The derivation trees are similar size; left_mono_until_G is simpler than separation_until. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Derive A4a as Theorems [NOT STARTED]

**Goal**: Prove `separation_until` and `separation_since` as derived theorems so that the 4 usage sites can call the theorem instead of the axiom constructor.

**Tasks**:
- [ ] Create derived theorem `separation_until_derived` in Combinators.lean (or a new DerivedAxioms.lean) proving `⊢ untl(p, q) → (untl(p, r)).neg → untl(q ∧ r.neg, q)` using existing axioms (BX5 + BX2G + BX3 + BX10 or direct propositional reasoning)
- [ ] Create dual `separation_since_derived` theorem
- [ ] Verify both compile with `lake build`
- [ ] Update `separation_until_mcs` in PointInsertion.lean (line 1066) to call the derived theorem instead of `Axiom.separation_until`

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/Combinators.lean` (or new file) - add derived theorems
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - update `separation_until_mcs` helper

**Verification**:
- `lake build` passes with no new errors
- The 4 call sites of `separation_until_mcs` (lines 1474, 2125, 2325, 2542) still work unchanged because only the helper's body changed

---

### Phase 2: Verify All Usage Sites Compile Without Axiom Constructor [NOT STARTED]

**Goal**: Confirm that no code path references `Axiom.separation_until` or `Axiom.separation_since` directly after Phase 1's helper rewrite.

**Tasks**:
- [ ] Run `grep -rn "Axiom.separation_until\|Axiom.separation_since" Theories/` to confirm zero direct axiom constructor references outside the axiom definition itself
- [ ] If any remain (unlikely after Phase 1), rewrite them to use the derived theorem
- [ ] Run full `lake build` to confirm everything compiles
- [ ] Document all files verified clean

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- None expected (verification only)
- Any stragglers found by grep

**Verification**:
- grep returns zero hits for `Axiom.separation_until` and `Axiom.separation_since` outside Axioms.lean
- `lake build` clean

---

### Phase 3: Remove Axiom Constructors and Soundness Proofs [NOT STARTED]

**Goal**: Remove `separation_until` and `separation_since` from the `Axiom` inductive type and all downstream match arms.

**Tasks**:
- [ ] Remove `separation_until` constructor (Axioms.lean lines 198-207) and `separation_since` constructor (lines 209-215)
- [ ] Update doc comments and constructor count (44 -> 42) in Axioms.lean header
- [ ] Remove `separation_until_valid` and `separation_since_valid` from Soundness.lean (lines 619-664)
- [ ] Remove all match arms referencing `separation_until`/`separation_since` in Soundness.lean (~13 locations across 5 match statements)
- [ ] Remove match arms in SoundnessLemmas.lean (~12 locations across multiple match statements: lines 621-635, 1248-1261, 1739-1753, 2052-2065)
- [ ] Remove match arms in Substitution.lean (lines 322-327)
- [ ] Run `lake build` and fix any exhaustiveness or missing-case errors

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - remove 2 constructors, update header docs
- `Theories/Bimodal/Metalogic/Soundness.lean` - remove validity theorems and ~13 match arms
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - remove ~12 match arms across 4 match statements
- `Theories/Bimodal/ProofSystem/Substitution.lean` - remove 2 match arms

**Verification**:
- `lake build` passes clean
- `grep -rn "separation_until\|separation_since" Theories/` returns zero hits
- Axiom type has exactly 42 constructors

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification, documentation updates, and constructor count audit.

**Tasks**:
- [ ] Run `lake clean && lake build` for a clean rebuild
- [ ] Verify the axiom constructor count is 42 by inspecting `Axioms.lean`
- [ ] Update any comments in PointInsertion.lean that reference "BX14" or "separation"
- [ ] Update ROADMAP.md axiom table to remove BX14/BX14' rows and update axiom counts
- [ ] Verify no `sorry` regressions by running a grep for `sorry` in affected files

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - update comments
- `specs/ROADMAP.md` - update axiom table

**Verification**:
- Clean build from scratch (`lake clean && lake build`)
- Zero grep hits for `separation_until` or `separation_since` in `Theories/`
- No new `sorry` introduced
- ROADMAP axiom table reflects 42 constructors

## Testing & Validation

- [ ] `lake build` passes clean after each phase
- [ ] `lake clean && lake build` passes after final phase
- [ ] `grep -rn "Axiom.separation" Theories/` returns zero results
- [ ] `grep -rn "separation_until\|separation_since" Theories/` returns zero results
- [ ] No new `sorry` introduced (compare before/after)
- [ ] Axiom constructor count reduced from 44 to 42

## Artifacts & Outputs

- `specs/115_replace_a4a_with_left_mono_until_g/plans/01_remove-a4a-plan.md` (this plan)
- Modified files: Axioms.lean, Soundness.lean, SoundnessLemmas.lean, Substitution.lean, PointInsertion.lean, Combinators.lean (or new DerivedAxioms.lean)

## Rollback/Contingency

All changes are in version control. If the derived theorem approach fails (Phase 1), the axiom constructors remain untouched and no existing proofs are broken. The safety-first ordering ensures each phase has a clean rollback point:
- Phase 1 failure: revert Combinators.lean changes; no downstream impact
- Phase 2 failure: revert any rewritten usage sites; original axiom still exists
- Phase 3 failure: revert constructor removal; derived theorem remains as a bonus
- Phase 4 failure: cosmetic only; revert doc changes
