# Implementation Plan: Task #996 - IRR Wiring Restructure

- **Task**: 996 - Wire the remaining sorry in soundness_dense (IRR case) via restructured proof
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 1000 (temporal_duality fixed), Task 1001 (IRRSoundness.lean fixed)
- **Research Inputs**: specs/996_soundness_theorem_assembly/reports/02_irr-wiring-analysis.md
- **Artifacts**: plans/02_irr-wiring-restructure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a **revision** of plan 01_soundness-wiring.md. Tasks 1000 and 1001 have resolved the temporal_duality mutual recursion and IRRSoundness.lean type errors. One sorry remains at line 696 (IRR case in soundness_dense).

The research (02_irr-wiring-analysis.md) identified that the induction hypothesis `ih` provides model-specific validity, but `irr_sound_dense_at_domain` requires universal `valid_dense`. The recommended approach restructures the proof to prove `valid_dense` directly, following the pattern in `derivable_valid_and_swap_valid` from SoundnessLemmas.lean.

### Research Integration

- Report: `reports/02_irr-wiring-analysis.md`
- Key finding: ih-to-valid_dense scope mismatch prevents direct wiring
- Recommendation: Create `soundness_dense_valid` theorem proving `valid_dense` directly
- Domain restriction (h_dom) semantically necessary but trivially satisfied for canonical models

## Goals and Non-Goals

**Goals**:
- Resolve the final sorry at line 696 in Soundness.lean (IRR case)
- Create `soundness_dense_valid` theorem with signature `valid_dense phi`
- Wire IRR case using `irr_sound_dense_at_domain` where ih provides `valid_dense (premise.imp phi')`
- Handle domain restriction via case analysis
- Derive `soundness_dense` as corollary from `soundness_dense_valid`

**Non-Goals**:
- Modifying the `irr_sound_dense_at_domain` theorem signature
- Proving IRR soundness for non-domain times (separate semantic question)
- Creating `soundness_discrete_valid` (can be done in future task if needed)
- Removing the existing `soundness_dense` theorem (will be refactored, not removed)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Domain case analysis complexity | M | M | Non-domain case may be vacuously true (atoms require domain membership) |
| Termination proofs for new theorem | M | L | Follow exact pattern from derivable_valid_and_swap_valid |
| Type universe issues | L | L | Copy instance structure from irr_sound_dense_at_domain |
| Regression in existing cases | M | L | Verify all non-IRR cases still compile after restructure |

## Implementation Phases

### Phase 1: Create soundness_dense_valid theorem scaffold [COMPLETED]

**Goal**: Create the new `soundness_dense_valid` theorem structure that proves `valid_dense` directly

**Tasks**:
- [ ] Study `derivable_valid_and_swap_valid` pattern in SoundnessLemmas.lean (lines 935-999)
- [ ] Create `soundness_dense_valid` theorem with signature:
  ```lean
  theorem soundness_dense_valid {phi : Formula} (d : DerivationTree [] phi)
      (h_dc : d.isDenseCompatible) : valid_dense phi
  ```
- [ ] Copy case structure from existing `soundness_dense` induction
- [ ] Wire all non-IRR cases by introducing model parameters and applying existing proofs
- [ ] Leave IRR case as sorry for Phase 2
- [ ] Add termination_by clause matching `derivable_valid_and_swap_valid`
- [ ] Build to verify scaffold compiles

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Add soundness_dense_valid theorem

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` succeeds
- All cases except IRR have no sorry
- termination_by accepted by Lean

---

### Phase 2: Wire IRR case with domain case analysis [IN PROGRESS]

**Goal**: Complete the IRR case using `irr_sound_dense_at_domain` with domain case analysis

**Tasks**:
- [ ] In IRR case, introduce model parameters: `intro D' _ _ _ _ _ F M Omega h_sc tau h_mem t`
- [ ] Apply `ih` to get `h_premise : valid_dense (premise.imp phi')`
- [ ] Case split on `h_dom_dec : Decidable (tau.domain t)`:
  - If `tau.domain t`: Apply `irr_sound_dense_at_domain h_fresh h_premise h_sc h_mem h_dom`
  - If `¬tau.domain t`: Prove by cases on `phi'` structure (atoms require domain, so goal may be vacuously achievable or require additional reasoning)
- [ ] If non-domain case is complex, add `h_dom` as explicit hypothesis to `soundness_dense_valid`
- [ ] Build to verify IRR case compiles

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Complete IRR case in soundness_dense_valid

**Verification**:
- IRR case has no sorry
- `lake build Bimodal.Metalogic.Soundness` succeeds

---

### Phase 3: Refactor soundness_dense as corollary [NOT STARTED]

**Goal**: Update `soundness_dense` to use `soundness_dense_valid` and verify full build

**Tasks**:
- [ ] Refactor existing `soundness_dense` to be a corollary of `soundness_dense_valid`:
  ```lean
  theorem soundness_dense (Gamma : Context) (phi : Formula)
      (d : DerivationTree Gamma phi) (h_dc : d.isDenseCompatible)
      ... (h_ctx : forall psi in Gamma, truth_at M Omega tau t psi) :
      truth_at M Omega tau t phi := by
    -- For non-empty context, use existing induction
    -- For empty context, apply soundness_dense_valid and instantiate
    ...
  ```
- [ ] Alternative: If context-dependent version is complex, keep separate theorems for `[] ⊢ phi` (via soundness_dense_valid) and `Gamma ⊢ phi` (existing soundness_dense without IRR)
- [ ] Remove the sorry from line 696 (now handled by soundness_dense_valid)
- [ ] Update module docstring to describe the new theorem structure
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify all existing theorem signatures are preserved for API compatibility

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Refactor soundness_dense

**Verification**:
- Zero sorries in Soundness.lean (or documented sorries for non-IRR cases if any remain)
- `lake build` (full project) succeeds
- `soundness_dense` theorem signature unchanged for external callers

---

## Testing and Validation

- [ ] `lake build Bimodal.Metalogic.Soundness` succeeds with no errors
- [ ] `lake build` (full project) succeeds
- [ ] `soundness_dense_valid` has zero sorries
- [ ] IRR case in soundness_dense wired via soundness_dense_valid
- [ ] `derivable_valid_and_swap_valid` IRR case still has sorry (separate scope)

## Artifacts and Outputs

- `Theories/Bimodal/Metalogic/Soundness.lean` - Updated with soundness_dense_valid
- `specs/996_soundness_theorem_assembly/summaries/02_irr-wiring-restructure-summary.md` - Implementation summary

## Rollback/Contingency

If the domain case analysis proves intractable:
1. Add explicit `h_dom : tau.domain t` hypothesis to `soundness_dense_valid`
2. Document that soundness is proven for domain times only
3. Note in comments that canonical models (domain = Set.univ) satisfy this trivially
4. This matches the restriction already present in `irr_sound_dense_at_domain`
