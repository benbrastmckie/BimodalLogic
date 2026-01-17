# Implementation Plan: Task #464

- **Task**: 464 - Strategy A: Strengthen canonical_task_rel for compositionality
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: Task 458 (Extend canonical_history), Task 257 (Completeness Proofs)
- **Research Inputs**: specs/464_research_coherence_alternatives_strategy_a/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement Strategy A from research-001.md: strengthen the `canonical_task_rel` definition to include persistence conditions for G-formulas (forward) and H-formulas (backward). This addresses the root cause of compositionality failure by ensuring temporal formulas persist through the canonical relation.

The key insight from research is that `future_formula_persistence` and `past_formula_persistence` are already proven (lines 2110-2149), showing these properties can be derived from existing axioms. By incorporating persistence directly into the relation definition, we make these properties structural rather than derived, enabling compositionality proofs.

**User Constraints (CRITICAL)**:
- Follow Strategy A only - NO discrete chain construction for canonical history
- NO relativized completeness statement
- NO Duration discreteness assumptions
- Duration must remain structurally agnostic (neither discrete, dense, nor continuous)

### Research Integration

From research-001.md:
- G-persistence uses G-4 axiom (`G phi -> G G phi`) + future_transfer
- H-persistence uses H-4 axiom (`H phi -> H H phi`) + past_transfer
- Compositionality for x > 0, y > 0 case becomes provable with persistence
- The x > 0, y <= 0, x + y > 0 case remains a known limitation (documented gap)

## Goals & Non-Goals

**Goals**:
- Strengthen `canonical_task_rel` definition with persistence conditions
- Update `forward_extension` proof to satisfy new persistence conditions
- Update `backward_extension` proof to satisfy new persistence conditions
- Update `canonical_nullity` to show persistence is vacuously true at t=0
- Remove sorries from `canonical_compositionality` for the x > 0, y > 0 case
- Document remaining gaps (x > 0, y <= 0 case) clearly in code comments

**Non-Goals**:
- Proving Duration discreteness
- Constructing chain-based canonical histories
- Achieving complete compositionality (some cases remain open by design)
- Changing Duration/PositiveDuration structure
- Adding new axioms to the logic

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New definition breaks other proofs | High | Low | Carefully audit all uses of canonical_task_rel |
| forward_extension cannot satisfy persistence | High | Low | Research confirms it's achievable via G-4 |
| backward_extension requires complex seed | Medium | Medium | May need to restructure backward_seed |
| Compositionality gaps larger than expected | Medium | Low | Document gaps clearly, accept partial result |

## Implementation Phases

### Phase 1: Strengthen canonical_task_rel Definition [COMPLETED]

**Goal**: Modify `canonical_task_rel` to include G-persistence and H-persistence conditions

**Tasks**:
- [ ] Update `canonical_task_rel` definition at lines 2048-2051 to add:
  - `(t > 0 -> forall phi, Formula.all_future phi in S.val -> Formula.all_future phi in T.val)`
  - `(t < 0 -> forall phi, Formula.all_past phi in S.val -> Formula.all_past phi in T.val)`
- [ ] Update docstring to document the new conditions
- [ ] Verify the file still compiles (with expected errors in downstream proofs)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - lines 2040-2051

**Verification**:
- Definition compiles without errors
- Expected downstream errors appear (canonical_nullity, forward_extension, backward_extension)

---

### Phase 2: Update canonical_nullity [COMPLETED]

**Goal**: Prove the persistence conditions are vacuously true at t=0

**Tasks**:
- [ ] Extend `canonical_nullity` proof at lines 2069-2090
- [ ] Add proof that G-persistence is vacuously true (since 0 is not > 0)
- [ ] Add proof that H-persistence is vacuously true (since 0 is not < 0)
- [ ] Use same exfalso pattern already in the proof for future/past transfer

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - lines 2069-2090

**Verification**:
- `canonical_nullity` compiles without errors
- No sorries introduced

---

### Phase 3: Update forward_extension with Persistence [COMPLETED]

**Goal**: Prove that forward_extension produces states satisfying G-persistence

**Tasks**:
- [ ] Extend `forward_extension` proof at lines 2455-2496
- [ ] Add proof of G-persistence: `t > 0 -> G phi in S -> G phi in T`
  - Use `set_mcs_all_future_all_future` to get `GG phi in S` from `G phi in S`
  - Show `G phi in forward_seed S` (since GG phi in S means G phi is extracted)
  - Conclude `G phi in T` via Lindenbaum extension
- [ ] Add proof of H-persistence is vacuously true (since t > 0, not < 0)
- [ ] Verify proof compiles without errors

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - lines 2455-2496

**Verification**:
- `forward_extension` compiles without errors
- No new sorries introduced

---

### Phase 4: Update backward_extension with Persistence [COMPLETED]

**Goal**: Prove that backward_extension produces states satisfying H-persistence (or document why it cannot)

**Tasks**:
- [ ] Analyze `backward_extension` structure at lines 2552-2577
- [ ] Note: backward_extension currently has sorry at line 2577
- [ ] If provable: Add proof of H-persistence for t < 0 case
  - Would need `HH phi in T -> H phi in S` via backward_seed construction
- [ ] If not provable with current seed: Document the limitation
  - backward_seed may need restructuring for persistence
  - Mark as known gap with detailed comment explaining the issue
- [ ] Add proof of G-persistence is vacuously true (since t < 0, not > 0) if base proof works

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - lines 2552-2577

**Verification**:
- backward_extension either compiles or has documented limitation
- If sorry remains, it includes detailed comment explaining why

---

### Phase 5: Update canonical_compositionality [COMPLETED]

**Goal**: Remove sorries for the x > 0, y > 0 compositionality case

**Tasks**:
- [ ] Locate the x > 0, y > 0 case at lines 2219-2224
- [ ] Verify this case already works (uses persistence which is now structural)
- [ ] Update the x > 0, y <= 0 case (lines 2225-2298) with clearer documentation:
  - Explain why this case cannot be proven without additional structure
  - Reference the research findings about semantic/syntactic gap
  - Keep sorry but with detailed justification
- [ ] Update the x <= 0 case (lines 2299-2321) with similar documentation
- [ ] Mirror updates for past transfer cases (lines 2322-2349)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - lines 2169-2349

**Verification**:
- x > 0, y > 0 case compiles without sorry
- x < 0, y < 0 case compiles without sorry (symmetric)
- Mixed cases have documented sorries with clear explanations
- `lake build` succeeds

---

### Phase 6: Verification and Cleanup [COMPLETED]

**Goal**: Ensure all changes work together and are properly documented

**Tasks**:
- [ ] Run `lake build` to verify full compilation
- [ ] Check `lean_diagnostic_messages` for any remaining errors
- [ ] Review all sorries in Completeness.lean - ensure each has clear documentation
- [ ] Update module docstring at top of file if needed
- [ ] Verify persistence lemmas (future_formula_persistence, past_formula_persistence) still work
- [ ] Add summary comment in canonical_compositionality explaining what's proven vs. gaps

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - top-level documentation

**Verification**:
- `lake build` succeeds with no errors
- All sorries are documented with clear explanations
- Module compiles and is ready for future work

---

## Testing & Validation

- [ ] `lake build` succeeds for full project
- [ ] No unexpected sorries introduced (only documented gaps)
- [ ] `canonical_task_rel` definition is strengthened with persistence
- [ ] `canonical_nullity` proves all conditions (including vacuous persistence)
- [ ] `forward_extension` satisfies new persistence conditions
- [ ] `canonical_compositionality` handles x > 0, y > 0 case without sorry
- [ ] All remaining sorries have detailed documentation explaining the gap

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness.lean` - Modified with strengthened canonical_task_rel
- `specs/464_research_coherence_alternatives_strategy_a/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the strengthened definition causes unforeseen issues:
1. Git revert the changes to Completeness.lean
2. Keep research-001.md findings for alternative approaches
3. Consider Strategy D (Duration discreteness) as fallback if Strategy A proves insufficient
4. Document lessons learned in errors.json
