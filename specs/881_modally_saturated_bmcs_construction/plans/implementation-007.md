# Implementation Plan: Task #881 (Version 7)

- **Task**: 881 - Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
- **Status**: [NOT STARTED]
- **Effort**: 2-4 hours (after task 887 completes)
- **Dependencies**: Task 887 (primary implementation)
- **Research Inputs**:
  - research-010.md: Options A and D analysis
  - research-011.md: Temporal coherence gap analysis
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL**: No technical debt is tolerable. This plan must result in a sorry-free and axiom-free proof.

**Key insight**: Task 887 is implementing the same goal with the same no-technical-debt policy. This plan coordinates task 881's completion with task 887's outcome.

### Task Relationship: 881 vs 887

| Aspect | Task 881 | Task 887 |
|--------|----------|----------|
| Goal | Eliminate `fully_saturated_bmcs_exists` axiom | Prove `fully_saturated_bmcs_exists_int` sorry-free |
| Status | planned | implementing |
| Key file | TemporalCoherentConstruction.lean | FinalConstruction.lean |
| Relationship | Consumer of result | Primary implementer |

Task 887 creates FinalConstruction.lean with the sorry-free construction. Task 881 verifies the axiom can be deprecated and the codebase is clean.

### Research Integration: Options A, C, D

From research-010.md and research-011.md, the sorry-free options are:

**Option A (from research-010.md): Modify createNewFamily to propagate BoxContent**
- Extends to GContent/HContent for temporal saturation
- Requires updating 15+ theorems (8-12 hours)
- Confidence: HIGH
- Used when: Lindenbaum preservation (Option B) fails but structural fix is viable

**Option C (from research-011.md): Restructure truth lemma**
- Only require eval_family to be temporally coherent
- Witness families used for modal reasoning only (not temporal)
- Requires analyzing TruthLemma.lean to verify this is mathematically valid
- Confidence: MEDIUM-HIGH
- Used when: Simpler than Option A, requires verifying math validity

**Option D (from research-010.md): FamilyCollection architecture**
- `exists_fullySaturated_extension` is ALREADY SORRY-FREE for modal saturation
- Handles box_coherence as collection invariant
- This is the BASE architecture, not a fallback - all other options build on it
- Confidence: HIGH (already proven)

### Decision Tree for Sorry-Free Path

```
fully_saturated_bmcs_exists_int
  |
  +-- Base Architecture: Option D (FamilyCollection + exists_fullySaturated_extension)
  |   Already sorry-free for modal saturation
  |
  +-- Challenge: Temporal coherence of witness families
      |
      +-- Primary (Task 887 Phase 1): Option B
      |   Prove lindenbaum_preserves_temporal_saturation
      |   |
      |   +-- SUCCESS → Task 887 completes, task 881 verifies
      |   +-- FAIL → Try fallback
      |
      +-- Fallback 1: Option A Extended
      |   Modify witness seed to include {ψ} ∪ BoxContent(M) ∪ GContent(M) ∪ HContent(M)
      |   Proves temporal saturation from content preservation
      |   |
      |   +-- SUCCESS → Task 887 completes, task 881 verifies
      |   +-- FAIL → Try fallback
      |
      +-- Fallback 2: Option C
      |   Analyze truth lemma: does it only need eval_family temporal coherence?
      |   If yes: weaken BMCS.temporally_coherent requirement
      |   |
      |   +-- VALID and SUCCESS → Task 887 completes, task 881 verifies
      |   +-- INVALID → Mathematical blocker (document and create research task)
      |
      +-- All approaches fail:
          DO NOT accept technical debt
          Document mathematical blocker
          Create new research task
          Task 881 remains blocked
```

### Why Option C is the Strongest Fallback

If Option B (Lindenbaum preservation) fails, **Option C** (restructure truth lemma) is preferable to **Option A** (modify createNewFamily) because:

1. **Scope**: Option C only requires analyzing existing code, Option A modifies 15+ theorems
2. **Mathematical validity**: If the truth lemma truly only queries eval_family for temporal properties, Option C is correct by design
3. **Risk**: Option A could introduce new bugs during refactoring; Option C is more surgical

However, if Option C is mathematically invalid (truth lemma genuinely requires all families to be temporally coherent), then Option A becomes the path forward.

### Why Option D is the Foundation, Not a Fallback

Research-010.md's Option D is NOT a fallback - it's the base architecture that all approaches use:

```lean
-- Option D Architecture (already implemented)
let C := initialFamilyCollection phi eval_fam
let C' := exists_fullySaturated_extension C ...  -- SORRY-FREE
let B := C'.toBMCS ...  -- Modal saturation proven
```

The challenge is proving `B.temporally_coherent`, which Options B, A, and C address.

## Goals & Non-Goals

**Goals**:
- Task 887 completes with sorry-free `fully_saturated_bmcs_exists_int`
- Verify the axiom `fully_saturated_bmcs_exists` can be deprecated
- Ensure no new sorries or axioms in the codebase
- If task 887 fails, escalate to research task (do NOT accept debt)

**Non-Goals**:
- Accepting any sorries as "tolerable technical debt"
- Implementing if task 887 already implements successfully
- Fixing unrelated sorries in other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| All approaches in task 887 fail | H | L | Document blocker, create research task |
| Option C mathematically invalid | M | M | Fall back to Option A |
| Option A requires extensive refactoring | M | M | Systematic approach documented in task 887 |

## Sorry Characterization

### Pre-existing Sorries (Target)
- `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:842) - eliminated by task 887
- `fully_saturated_bmcs_exists_constructive` (SaturatedConstruction.lean:1367) - related

### Expected Resolution
- Task 887 eliminates the target sorry using the B → A → C decision tree
- If task 887 succeeds, task 881 verifies and closes

### New Sorries
- **NONE PERMITTED**. No technical debt is tolerable.

## Axiom Characterization

### Pre-existing Axioms
- `fully_saturated_bmcs_exists` (TemporalCoherentConstruction.lean) - deprecated after success

### Expected Resolution
- Task 887's proof makes the axiom unnecessary for D = Int
- Task 881 verifies the axiom can be marked deprecated

### New Axioms
- **NONE PERMITTED**. No new axioms allowed.

## Implementation Phases

### Phase 0: Monitor Task 887 [NOT STARTED]

- **Dependencies**: None
- **Goal**: Wait for task 887 to complete

**Tasks**:
- [ ] Task 887 completes one of the approaches (B, A, or C)
- [ ] FinalConstruction.lean has sorry-free `fully_saturated_bmcs_exists_int`
- [ ] `lake build` succeeds

**Decision Point**:
- If task 887 SUCCEEDS → Proceed to Phase 1
- If task 887 FAILS (all approaches) → Proceed to Phase 3

**Timing**: Dependent on task 887

---

### Phase 1: Verification [NOT STARTED]

- **Dependencies**: Phase 0 (task 887 succeeded)
- **Goal**: Verify the codebase is sorry-free for the target

**Tasks**:
- [ ] Verify `fully_saturated_bmcs_exists_int` compiles without sorry
- [ ] Verify no new sorries introduced in FinalConstruction.lean
- [ ] Verify no new axioms introduced
- [ ] `lake build` succeeds

**Timing**: 1 hour

**Verification**:
- `grep "sorry" Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns nothing
- `grep "axiom " Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns nothing

---

### Phase 2: Axiom Deprecation [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Mark the axiom as deprecated

**Tasks**:
- [ ] Add deprecation comment to `fully_saturated_bmcs_exists` axiom
- [ ] Document that `fully_saturated_bmcs_exists_int` is the proven version
- [ ] Update any code using the axiom to use the theorem instead
- [ ] Create implementation summary

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - deprecation comment
- Any files using the axiom

**Verification**:
- `lake build` succeeds
- Axiom usage documented/migrated

---

### Phase 3: Escalate to Research Task (only if task 887 fails) [NOT STARTED]

- **Dependencies**: Phase 0 (task 887 failed all approaches)
- **Goal**: Create research task documenting the mathematical blocker

**Tasks**:
- [ ] Review task 887's blocker documentation
- [ ] Create new research task describing the mathematical gap
- [ ] Identify what theorem/property would unblock the proof
- [ ] DO NOT introduce any sorries or axioms
- [ ] Task 881 remains in BLOCKED state

**Timing**: 1-2 hours

**This phase should NOT be reached** - task 887's decision tree (B → A → C) should find a sorry-free path.

---

## Testing & Validation

- [ ] Task 887 completes successfully
- [ ] `fully_saturated_bmcs_exists_int` is sorry-free
- [ ] No new sorries in any file
- [ ] No new axioms in any file
- [ ] `lake build` succeeds
- [ ] Completeness.lean theorems still work

## Artifacts & Outputs

- `plans/implementation-007.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)

## Rollback/Contingency

**NO TECHNICAL DEBT FALLBACK**.

If task 887 fails:
1. Do NOT accept any sorry as "tolerable debt"
2. Review task 887's blocker documentation
3. Create research task describing mathematical gap
4. Task 881 remains BLOCKED pending research

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 001 | 2026-02-13 | Initial two-tier plan |
| 002 | 2026-02-13 | Unified Zorn approach |
| 003 | 2026-02-14 | Focus on existing 3 sorries via S5 BoxContent invariance |
| 004 | 2026-02-14 | RecursiveSeed extension for multi-formula seed building |
| 005 | 2026-02-16 | Option D: FamilyCollection architecture (abandons buildSeedForList) |
| 006 | 2026-02-16 | Dependency on task 887; Option C (truth lemma restructure) with fallback |
| 007 | 2026-02-17 | No technical debt; integrated Options A/C/D decision tree; coordinate with task 887 |
