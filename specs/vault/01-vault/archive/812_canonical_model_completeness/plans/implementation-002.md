# Implementation Plan: Task #812

- **Task**: 812 - Canonical Model Completeness
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 809 (archival complete), Task 810 (research complete)
- **Research Inputs**: research-001.md, research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Previous Version**: plans/implementation-001.md (superseded - FMP-compactness approach was flawed)

## Overview

This revised plan focuses on establishing sorry-free weak and strong completeness without changing the semantics or pursuing compactness (which research-002.md identified as requiring the Representation approach with architectural sorries).

**Key Insight from Research**: The existing `semantic_weak_completeness` in SemanticCanonicalModel.lean IS completely sorry-free for FMP-internal validity. The only sorry is in the validity bridge from general validity to FMP-internal validity in FiniteStrongCompleteness.lean:130.

**Strategy**: Instead of trying to bridge general validity → FMP-internal validity (which is architecturally blocked for modal operators due to S5-style universal quantification), we will:

1. **Expose FMP-internal validity as the primary semantic notion** for completeness results
2. **Rename/reorganize theorems** to make the semantic scope clear
3. **Provide sorry-free strong completeness** using FMP-internal validity
4. **Document the general validity gap** as a known limitation (not implementation debt)

### What Changed from v001

| v001 Approach | v002 Approach | Reason |
|---------------|---------------|--------|
| FMP-based compactness (Phase 1) | REMOVED | research-002 showed compactness requires Representation sorries |
| Bridge general validity to FMP | Expose FMP-internal validity as primary | Bridge is architecturally blocked |
| 5 phases, 6 hours | 4 phases, 4 hours | Focused scope, no compactness |

### Constraints (from task description)

1. **Only restore elements that can be implemented sorry-free** - No architectural workarounds
2. **Ensure definitions align with semantics** - Box quantifies over world histories
3. **No semantics changes** - Preserve existing semantic definitions

## Goals & Non-Goals

**Goals**:
- Provide sorry-free weak completeness theorem (FMP-internal validity)
- Provide sorry-free strong completeness theorem (FMP-internal validity)
- Clear documentation distinguishing FMP-internal from general validity
- Clean module structure with exported theorems

**Non-Goals**:
- Compactness (requires Representation approach with sorries)
- General validity completeness (architecturally blocked without semantics changes)
- Changing box semantics
- Reviving Boneyard approaches

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FMP-internal validity naming confusion | Medium | Medium | Clear documentation and theorem names |
| Scope creep into general validity | Medium | Low | Strict adherence to sorry-free constraint |

## Implementation Phases

### Phase 1: Define FMP-Internal Semantic Consequence [NOT STARTED]

**Goal**: Create explicit semantic consequence relation for FMP-internal validity, separate from general validity

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/FMPSemantics.lean`
- [ ] Define `FMPSemanticConsequence`: `(Gamma : Context) → (phi : Formula) → Prop` using SemanticWorldStates
- [ ] Define `FMPValid`: `(phi : Formula) → Prop` for FMP-internal validity
- [ ] Prove basic properties (reflexivity, monotonicity)
- [ ] Add clear documentation distinguishing from general validity

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/FMP/FMPSemantics.lean`

**Key definitions**:
```lean
/-- FMP-internal validity: truth at all SemanticWorldStates for the formula's closure -/
def FMPValid (phi : Formula) : Prop :=
  ∀ (w : SemanticWorldState phi),
    semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi

/-- FMP-internal semantic consequence: if all premises hold at a world, conclusion holds -/
def FMPSemanticConsequence (Gamma : Context) (phi : Formula) : Prop :=
  -- For the closure of (Gamma ++ [phi]), at all SemanticWorldStates:
  -- if all gamma in Gamma hold, then phi holds
  ∀ (psi : Formula) (h : psi = impChain Gamma phi),
    FMPValid psi
```

**Verification**:
- `lake build Bimodal.Metalogic.FMP.FMPSemantics` succeeds
- No `sorry` in the file
- Clean separation from general validity

---

### Phase 2: FMP-Internal Strong Completeness [NOT STARTED]

**Goal**: Prove strong completeness theorem using FMP-internal semantic consequence (sorry-free)

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/FMPCompleteness.lean`
- [ ] Import `FMPSemantics.lean` and `SemanticCanonicalModel.lean`
- [ ] Define `fmp_weak_completeness`: `FMPValid phi → ContextDerivable [] phi` (wrapper around `semantic_weak_completeness`)
- [ ] Build `impChain` semantics for FMP (adapt from FiniteStrongCompleteness)
- [ ] Prove `fmp_strong_completeness`: `FMPSemanticConsequence Gamma phi → ContextDerivable Gamma phi`
- [ ] Verify all proofs are sorry-free

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/FMP/FMPCompleteness.lean`

**Key theorem**:
```lean
/-- FMP-internal strong completeness (sorry-free) -/
theorem fmp_strong_completeness (Gamma : Context) (phi : Formula) :
    FMPSemanticConsequence Gamma phi → ContextDerivable Gamma phi := by
  -- Uses fmp_weak_completeness + impChain unfolding
  ...
```

**Verification**:
- `lake build Bimodal.Metalogic.FMP.FMPCompleteness` succeeds
- No `sorry` in the file
- Theorem compiles with clear type signature

---

### Phase 3: Documentation and Module Organization [NOT STARTED]

**Goal**: Update documentation to clearly explain the completeness landscape

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` docstrings
- [ ] Update `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` with architectural notes
- [ ] Create/update `Theories/Bimodal/Metalogic/Completeness/README.md`
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` exports

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Add docstrings
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Add architectural notes
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Export new modules

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/README.md`

**Documentation content**:

```markdown
# Completeness Theorems

## Sorry-Free Results (FMP-Internal Validity)

| Theorem | Location | Status |
|---------|----------|--------|
| `semantic_weak_completeness` | FMP/SemanticCanonicalModel.lean | ✓ Sorry-free |
| `fmp_weak_completeness` | FMP/FMPCompleteness.lean | ✓ Sorry-free |
| `fmp_strong_completeness` | FMP/FMPCompleteness.lean | ✓ Sorry-free |

## General Validity Results (Has Sorries)

| Theorem | Location | Status | Note |
|---------|----------|--------|------|
| `weak_completeness` | Completeness/FiniteStrongCompleteness.lean | 1 sorry | Validity bridge blocked |
| `finite_strong_completeness` | Completeness/FiniteStrongCompleteness.lean | (inherits) | Uses weak_completeness |

## Why the Gap Exists

The validity bridge from general validity to FMP-internal validity is blocked for modal operators
because:
- General validity quantifies over ALL TaskModels
- Box semantics: `truth_at M tau t (box phi) = forall sigma, truth_at M sigma t phi`
- This universal quantification over histories includes non-MCS-derived histories
- FMP's SemanticWorldStates are MCS-derived, so they can't represent arbitrary histories

This is an architectural limitation, not an implementation gap. Closing it would require
changing the semantic definition of box (e.g., to Kripke-style accessibility relations).
```

**Verification**:
- All docstrings compile
- README accurately reflects code state
- Module exports work correctly

---

### Phase 4: Final Verification and Summary [NOT STARTED]

**Goal**: Verify all changes compile and create implementation summary

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic` to verify full module
- [ ] Verify sorry count: expect 0 new sorries, 1 existing (validity bridge)
- [ ] Check that new theorems are accessible via module exports
- [ ] Create implementation summary documenting:
  - What IS sorry-free: `semantic_weak_completeness`, `fmp_weak_completeness`, `fmp_strong_completeness`
  - What has documented sorries: `weak_completeness` (validity bridge)
  - What is NOT in scope: compactness, general validity completeness
- [ ] Update specs/state.json with completion status

**Timing**: 0.5 hours

**Files to create**:
- `specs/812_canonical_model_completeness/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- `lake build Bimodal.Metalogic` succeeds
- No new sorries introduced
- Summary accurately reflects codebase state

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic` compiles successfully
- [ ] `semantic_weak_completeness` remains sorry-free
- [ ] New `fmp_weak_completeness` is sorry-free
- [ ] New `fmp_strong_completeness` is sorry-free
- [ ] Existing `weak_completeness` has documented architectural sorry
- [ ] All new code has proper documentation

## Artifacts & Outputs

**New Files**:
- `Theories/Bimodal/Metalogic/FMP/FMPSemantics.lean` - FMP semantic relations
- `Theories/Bimodal/Metalogic/FMP/FMPCompleteness.lean` - Sorry-free completeness
- `Theories/Bimodal/Metalogic/Completeness/README.md` - Completeness documentation
- `specs/812_canonical_model_completeness/summaries/implementation-summary-YYYYMMDD.md`

**Modified Files**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Enhanced docstrings
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Architectural notes
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Updated exports

## Rollback/Contingency

If FMP-internal semantics prove problematic:
1. Preserve existing `semantic_weak_completeness` (already sorry-free)
2. Keep FiniteStrongCompleteness.lean as-is with its documented sorry
3. Skip new files and just update documentation

The existing sorry-free results (`semantic_weak_completeness`) are the primary deliverable.
New wrapper theorems (`fmp_weak_completeness`, `fmp_strong_completeness`) provide cleaner API
but are not strictly necessary.

## Notes on Compactness

Compactness is explicitly OUT OF SCOPE for this task. From research-002.md:

> The actual compactness proof uses `infinitary_strong_completeness`, which depends on the
> Representation approach's truth lemma (with its 4 sorries). Therefore, the compactness
> theorem ALSO depends on these sorries.

To achieve sorry-free compactness would require either:
1. Changing box semantics (out of scope)
2. Using a completely different proof technique (e.g., FOL translation - future research)

This is documented as a known limitation, not a gap in this implementation.

## Summary of Completeness Landscape After Implementation

| Property | Semantic Notion | Status | Location |
|----------|-----------------|--------|----------|
| Weak Completeness | FMP-internal | ✓ Sorry-free | FMP/SemanticCanonicalModel.lean |
| Strong Completeness | FMP-internal | ✓ Sorry-free | FMP/FMPCompleteness.lean |
| Weak Completeness | General validity | 1 sorry | Completeness/FiniteStrongCompleteness.lean |
| Strong Completeness | General validity | inherits sorry | Completeness/FiniteStrongCompleteness.lean |
| Compactness | Any | OUT OF SCOPE | Requires Representation sorries |
