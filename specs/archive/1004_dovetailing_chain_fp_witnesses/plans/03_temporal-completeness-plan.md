# Implementation Plan: Task #1004

- **Task**: 1004 - Complete FlagBFMCS Temporal Completeness
- **Version**: 03 (replaces 02_semantic-bridge-plan.md)
- **Status**: [COMPLETED]
- **Effort**: 4-6 hours
- **Dependencies**: Task #1003 (FlagBFMCS implementation) [COMPLETED]
- **Research Inputs**:
  - specs/1004_dovetailing_chain_fp_witnesses/reports/07_post-completion-evaluation.md (CRITICAL gap discovery)
- **Previous Plans (OBSOLETE)**:
  - plans/01_dovetailing-chain-plan.md (dovetailing approach - mathematically impossible)
  - plans/02_semantic-bridge-plan.md (semantic bridge - premature, FlagBFMCS broken)
- **Artifacts**: plans/03_temporal-completeness-plan.md (this file)
- **Type**: lean4
- **Lean Intent**: true

## Overview

**CRITICAL DISCOVERY (Research Round 7)**: FlagBFMCS completeness is BROKEN.

The file `FlagBFMCSCompleteness.lean` has an unsolved goal at line 52:
```
case h_complete
⊢ B.temporally_complete
```

**Root Cause**:
- `satisfies_at_iff_mem` (truth lemma) requires `h_complete : B.temporally_complete`
- `canonicalFlagBFMCS` uses `closedFlags M0` which provides **modal saturation** (Diamond witnesses)
- But `closedFlags` is NOT proven to be **temporally complete** (every CanonicalMCS in some Flag)
- The file isn't imported anywhere, so `lake build` passes silently

**Revised Objective**: Fix the temporal completeness gap so FlagBFMCS completeness works.

### Why Previous Plans Are Now Obsolete

| Plan | Objective | Why Obsolete |
|------|-----------|--------------|
| v01 (dovetailing) | Fix IntBFMCS F/P sorries | Mathematically impossible |
| v02 (semantic bridge) | Connect FlagBFMCS to WorldHistory | Premature - FlagBFMCS completeness is broken |
| **v03 (this)** | Fix temporal completeness gap | Required before any further work |

## Goals & Non-Goals

**Goals**:
- Prove `temporally_complete` for `canonicalFlagBFMCS` (or alternative construction)
- Make `FlagBFMCSCompleteness.lean` compile without unsolved goals
- Wire the file into the build so `lake build` catches regressions
- Verify end-to-end completeness theorem

**Non-Goals**:
- Semantic bridge to WorldHistory (deferred to future task)
- Fixing IntBFMCS F/P sorries (proven impossible, documented)
- Int/Rat domain transfer (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| closedFlags NOT temporally complete | High | Medium | Use Option B (Set.univ) as fallback |
| allFlags modal saturation proof complex | Medium | Low | allFlags_closed likely already proven |
| Build regression after wiring | Low | Low | Test incrementally |

## Implementation Phases

### Phase 1: Analyze Temporal Completeness Options [COMPLETED]

**Goal**: Determine which approach to use for temporal completeness.

**Tasks**:
- [ ] Check if `closedFlags_temporally_complete` can be proven
  - Does `closedFlags` equal `Set.univ`? (would make temporal completeness trivial)
  - Can we prove every CanonicalMCS is in some Flag in `closedFlags`?
- [ ] Check if `allFlags_closed` (modal saturation for `Set.univ`) is already proven
- [ ] Decide: Option A (closedFlags) or Option B (Set.univ)

**Timing**: 1 hour

**Investigation Commands**:
```bash
# Check if closedFlags equals Set.univ
grep -n "closedFlags.*univ\|univ.*closedFlags" Theories/Bimodal/Metalogic/Bundle/*.lean

# Check for allFlags_closed or similar
grep -n "allFlags\|Set.univ.*modally\|modally.*Set.univ" Theories/Bimodal/Metalogic/Bundle/*.lean
```

**Verification**:
- Decision documented: Option A or Option B

---

### Phase 2: Implement Temporal Completeness [COMPLETED]

**Goal**: Prove `temporally_complete` for the FlagBFMCS construction used in completeness.

#### Option A: Prove closedFlags_temporally_complete

**If chosen**: Prove that `closedFlags M0` contains a Flag for every CanonicalMCS.

```lean
theorem closedFlags_temporally_complete (M0 : CanonicalMCS) :
    (canonicalFlagBFMCS M0).temporally_complete := by
  intro M
  -- Need: ∃ F ∈ closedFlags M0, M ∈ F
  -- Strategy: Show all Flags are in closedFlags (closedFlags = Set.univ)
  -- OR: Show M is reachable from M0 via witness chain
  sorry
```

#### Option B: Define allFlagsBFMCS using Set.univ

**If chosen**: Define a variant that uses all Flags.

```lean
/-- FlagBFMCS using all Flags (Set.univ).
    Temporal completeness is trivial since every CanonicalMCS is in some Flag. -/
noncomputable def allFlagsBFMCS (M0 : CanonicalMCS) : FlagBFMCS where
  root := M0
  flags := Set.univ
  flags_nonempty := ⟨_, Set.mem_univ _⟩
  modally_saturated := allFlags_modally_saturated  -- Need to prove or find
  eval_flag := (root_in_some_flag M0).choose
  eval_flag_mem := Set.mem_univ _
  root_in_eval_flag := (root_in_some_flag M0).choose_spec

theorem allFlagsBFMCS_temporally_complete (M0 : CanonicalMCS) :
    (allFlagsBFMCS M0).temporally_complete := by
  intro M
  exact canonicalMCS_in_some_flag M
```

**Timing**: 2-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` - Add temporal completeness proof
- OR `Theories/Bimodal/Metalogic/Bundle/ClosedFlagBundle.lean` - Add closedFlags_temporally_complete

**Verification**:
- [ ] `temporally_complete` proof compiles without sorry
- [ ] `lake build` still passes

---

### Phase 3: Fix FlagBFMCSCompleteness.lean [COMPLETED]

**Goal**: Make the completeness theorem compile.

**Tasks**:
- [ ] Update `FlagBFMCS_satisfies_root` to provide `h_complete` argument:
  ```lean
  theorem FlagBFMCS_satisfies_root (B : FlagBFMCS) (h_complete : B.temporally_complete)
      (φ : Formula) (h_mem : φ ∈ B.root.world) :
      satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ := by
    rw [satisfies_at_iff_mem h_complete]
    ...
  ```
- [ ] Update `canonicalFlagBFMCS_satisfies_root` to use the temporal completeness proof
- [ ] Update `FlagBFMCS_completeness_set` and `FlagBFMCS_completeness` accordingly
- [ ] Verify all theorems compile without sorry

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean`

**Verification**:
- [ ] `FlagBFMCS_satisfies_root` compiles without sorry
- [ ] `FlagBFMCS_completeness` compiles without sorry
- [ ] No unsolved goals in the file

---

### Phase 4: Wire into Build and Verify [COMPLETED]

**Goal**: Ensure FlagBFMCSCompleteness is built and tested.

**Tasks**:
- [ ] Import FlagBFMCSCompleteness from a file that's in the build
  - Option: Add to `Theories/Bimodal/Metalogic/Metalogic.lean`
  - Option: Create new umbrella file
- [ ] Run `lake build` and verify no errors
- [ ] Run `grep -c sorry` on all FlagBFMCS files

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Add import

**Verification**:
- [ ] `lake build` passes
- [ ] `grep -c sorry Theories/Bimodal/Metalogic/Bundle/FlagBFMCS*.lean` returns 0

---

## Testing & Validation

- [ ] `lake build` passes with FlagBFMCSCompleteness included
- [ ] All FlagBFMCS files have 0 sorries
- [ ] `lean_goal` at line 52 of FlagBFMCSCompleteness.lean shows no unsolved goals
- [ ] Completeness theorem is end-to-end sorry-free

## Success Criteria

1. **Gap Fixed**: `temporally_complete` has a sorry-free proof
2. **Completeness Works**: `FlagBFMCS_completeness` compiles without errors
3. **Build Integrated**: File is imported and built by `lake build`
4. **No Regression**: Overall sorry count stable or decreased

## Artifacts & Outputs

- `specs/1004_dovetailing_chain_fp_witnesses/plans/03_temporal-completeness-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` or `ClosedFlagBundle.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean`
- `specs/1004_dovetailing_chain_fp_witnesses/summaries/02_temporal-completeness-summary.md` (on completion)

## Future Work (Deferred)

**Semantic Bridge**: After this task completes, a future task can:
1. Define `CanonicalTaskFrame` with `WorldState = CanonicalMCS`
2. Construct `FlagBFMCS_to_WorldHistory` conversion
3. Prove truth preservation

This is low priority since FlagBFMCS completeness is the primary goal.

## Rollback/Contingency

If neither Option A nor Option B works:
1. **Document the gap**: Add a well-documented sorry with explanation
2. **Track as technical debt**: Note that temporal completeness is a known gap
3. **Investigate alternatives**: Consider if FlagBFMCS architecture needs rethinking

However, Option B (Set.univ) should work since:
- `canonicalMCS_in_some_flag` proves every MCS is in some Flag
- Modal saturation for all Flags likely follows from existing infrastructure
