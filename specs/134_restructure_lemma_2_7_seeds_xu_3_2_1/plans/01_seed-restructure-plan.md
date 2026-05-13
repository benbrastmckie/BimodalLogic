# Implementation Plan: Restructure lemma_2_7/lemma_2_7_since Seeds Using Xu 3.2.1

- **Task**: 134 - Restructure lemma_2_7/lemma_2_7_since seeds using Xu 3.2.1
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: Task 115 (Xu 3.2.1 implementation, completed)
- **Research Inputs**: reports/01_seed-restructure-research.md
- **Artifacts**: plans/01_seed-restructure-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The current `lemma_2_7_seed` and `lemma_2_7_since_seed` in PointInsertion.lean each contain 5 set-union components. Components 3 (`{untl(gamma,beta)}`) and 4 (`{snce(alpha,beta)}`) are redundant because Xu 3.2.1 (proved in task 115) guarantees these formulas are already in B, which is a subset of any Lindenbaum extension D. This plan reduces each seed from 5 to 3 components, simplifies the associated consistency proofs from 5-way to 3-way case analysis, and updates the lemma_2_7/lemma_2_7_since proof bodies to derive the formerly-seeded memberships via Xu 3.2.1 (following the pattern established in `lemma_2_6_splitting` at lines 1835-1841). The 5th component must be retained: it is essential for establishing `xi in B'` in the output. Definition of done: `lake build` passes with zero sorries and PointInsertion.lean shrinks by approximately 700-900 lines.

### Research Integration

Research report `reports/01_seed-restructure-research.md` confirmed:
- Seed reduces from 5 to 3 components (NOT to 2 as the task description originally claimed)
- Component 5 (`snce(alpha, beta and xi)` / `untl(gamma, beta and xi)`) cannot be dropped because `xi not in B` prevents Xu 3.2.1 from applying
- The consistency proof chain (BX5+BX7+BX13) for component 5 remains necessary but with fewer cases
- `lemma_2_8` / `lemma_2_8_since` share the same seeds and benefit from identical simplification
- Zero changes needed in CounterexampleElimination.lean -- output types are unchanged
- Lines 1835-1841 of `lemma_2_6_splitting` provide the exact pattern for deriving untl/snce memberships from Xu 3.2.1

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the Chronicle pipeline simplification. The roadmap notes PointInsertion.lean at approximately 3690 lines (sorry-free). After this task, it should be approximately 3500-3600 lines. This is preparatory cleanup that does not directly advance the critical path (task 129 -> task 122) but improves maintainability for future work in the Phase 2 axiom cleanup phase.

## Goals & Non-Goals

**Goals**:
- Reduce `lemma_2_7_seed` and `lemma_2_7_since_seed` from 5 to 3 components each
- Simplify all four consistency proofs (lemma_2_7_seed_consistent, lemma_2_8_seed_consistent, lemma_2_7_since_seed_consistent, lemma_2_8_since_seed_consistent) from 5-way to 3-way case analysis
- Remove dead helper functions that extracted guards/events for components 3-4
- Update `lemma_2_7` and `lemma_2_7_since` proof bodies to derive components 3-4 memberships from Xu 3.2.1 + B subset D
- Maintain zero sorries throughout
- Reduce PointInsertion.lean by approximately 700-900 lines

**Non-Goals**:
- Dropping component 5 (not possible -- xi not in B)
- Changing output types of lemma_2_7 or lemma_2_7_since
- Modifying CounterexampleElimination.lean
- Investigating the alternative post-hoc derivation path for component 5 (theoretical, not practical for this task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Consistency proof refactoring introduces sorry or breaks downstream | H | L | Each phase verified with `lake build`; existing sorry-free baseline provides clear regression check |
| Helper functions used by both seed_consistent and since_seed_consistent | M | M | Phase 1 and Phase 3 handle Until-direction first; shared helpers updated before removal |
| Component 5 consistency argument (BX5+BX7+BX13 chain) is fragile | M | L | This chain is unchanged -- only the surrounding case analysis is simplified |
| lemma_2_8 seed shares definition with lemma_2_7 seed | M | L | Phase 2 handles lemma_2_8 after lemma_2_7 is stable; same seed definition means automatic benefit |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Simplify lemma_2_7_seed and lemma_2_7_seed_consistent [NOT STARTED]

**Goal**: Reduce the Until-direction seed from 5 to 3 components and simplify the consistency proof from 5-way to 3-way case analysis.

**Tasks**:
- [ ] Rewrite `lemma_2_7_seed` definition (line 1875) to remove components 3 and 4:
  ```
  B ∪ {eta} ∪ {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce α (Formula.and β xi)}
  ```
- [ ] Update `l27_guard` (line 1887) from 5-case to 3-case extraction: (1) phi in B: guard = phi, (2) phi = eta: guard = top, (3) phi = snce(alpha, beta and xi): guard = beta
- [ ] Update `l27_collect_guards` (line 1905) to handle 3 cases
- [ ] Remove `l27_c_event_list` (line 1922) and `l27_c_event_list_mem` (line 1932) -- these extracted gamma events from the untl component (component 3), now removed
- [ ] Simplify `l27_a_event_list` (line 1947) and `l27_a_event_list_mem` (line 1960) -- remove the snce(alpha,beta) case (component 4), keep snce(alpha, beta and xi) case only
- [ ] Update `l27_collect_guards_mem_of_B` (line 1981) from 5-case to 3-case
- [ ] Remove `l27_guard_untl_val` (line 1995) -- extracted untl guard values for component 3
- [ ] Remove `l27_collect_guards_mem_of_untl` (line 2012) -- untl guard membership for component 3
- [ ] Remove `l27_guard_snce_val` (line 2030) -- extracted snce guard values for component 4
- [ ] Keep and potentially simplify `l27_guard_snce_xi_val` (line 2055) -- snce(beta and xi) guard values for component 5
- [ ] Remove `l27_collect_guards_mem_of_snce` (line 2079) -- snce guard membership for component 4
- [ ] Keep and potentially simplify `l27_collect_guards_mem_of_snce_xi` (line 2099) -- component 5 guard membership
- [ ] Remove `l27_c_event_list_gamma_mem` (line 2121) -- gamma membership for component 3
- [ ] Remove `l27_a_event_list_alpha_mem` (line 2140) if it only handles component 4; keep if shared with component 5
- [ ] Keep `l27_a_event_list_alpha_mem_xi` (line 2161) -- alpha membership for component 5
- [ ] Rewrite `lemma_2_7_seed_consistent` (lines 2188-2603): reduce from 5-way to 3-way case split on seed membership; keep the BX5+BX7+BX13 chain logic for component 5
- [ ] Verify `lake build` passes with zero sorries

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- lines 1875-2603 (seed definition, helpers, consistency proof)

**Verification**:
- `lake build` succeeds with zero errors
- `lemma_2_7_seed_consistent` type signature unchanged (produces `SetConsistent (lemma_2_7_seed A B C xi eta)`)
- No new sorries introduced

---

### Phase 2: Update lemma_2_7 and lemma_2_8 proof bodies [NOT STARTED]

**Goal**: Update the Until-direction main lemma proofs to derive components 3-4 memberships from Xu 3.2.1 instead of seed extraction, and simplify `lemma_2_8_seed_consistent`.

**Tasks**:
- [ ] Update `lemma_2_7` (lines 2604-2712) proof body:
  - After obtaining D from Lindenbaum extension of simplified seed, derive `h_B_sub_D : B ⊆ D`
  - Add `h_untl_D` derivation: `∀ β' ∈ B, ∀ γ ∈ C, Formula.untl γ β' ∈ D` via `xu_lemma_3_2_1_until` + `h_B_sub_D` (following pattern at lines 1835-1837)
  - Add `h_snce_D` derivation: `∀ β' ∈ B, ∀ α ∈ A, Formula.snce α β' ∈ D` via `xu_lemma_3_2_1_since` + `h_B_sub_D` (following pattern at lines 1839-1841)
  - Replace any direct seed extraction of untl/snce memberships with these derived facts
  - Establish `burgessR3(D, B, C)` and `burgessR3(A, B, D)` from derived memberships
- [ ] Simplify `lemma_2_8_seed_consistent` (lines 2713-2988): this proof uses the same `lemma_2_7_seed` -- the simplified seed definition automatically propagates, but the internal case analysis needs the same 5-way to 3-way reduction as Phase 1
- [ ] Update `lemma_2_8` (lines 2989-3092) if it has any direct seed extraction for components 3-4
- [ ] Verify `lake build` passes with zero sorries

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- lines 2604-3092 (lemma_2_7 body, lemma_2_8_seed_consistent, lemma_2_8 body)

**Verification**:
- `lake build` succeeds with zero errors
- `lemma_2_7` output type unchanged: `∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧ SetMaximalConsistent D ∧ eta ∈ D ∧ B ⊆ B' ∧ B ⊆ D ∧ B ⊆ B'' ∧ xi ∈ B'`
- `lemma_2_8` output type unchanged
- No new sorries introduced

---

### Phase 3: Simplify lemma_2_7_since_seed and lemma_2_7_since_seed_consistent [NOT STARTED]

**Goal**: Reduce the Since-direction seed from 5 to 3 components and simplify the consistency proof, mirroring Phase 1 for the dual direction.

**Tasks**:
- [ ] Rewrite `lemma_2_7_since_seed` definition (line 3093) to remove components 3 and 4:
  ```
  B ∪ {eta} ∪ {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl γ (Formula.and β xi)}
  ```
  Note: component 5 here is `untl(gamma, beta and xi)` (dual of the Until-direction's `snce(alpha, beta and xi)`)
- [ ] Remove or simplify Since-direction helpers (lines 3099-3182):
  - Keep `l27s_c5_event_list` / `l27s_c5_event_list_mem` (line 3099-3118) -- component 5 event extraction
  - Keep `l27s_b5_guard_list` / `l27s_b5_guard_list_mem` (line 3119-3138) -- component 5 guard extraction
  - Keep `l27s_c5_gamma_mem` (line 3139) and `l27s_b5_beta_mem` (line 3160) -- component 5 membership
  - Remove any helpers specific to components 3-4 (if they exist among these)
- [ ] Rewrite `lemma_2_7_since_seed_consistent` (lines 3184-3531): reduce from 5-way to 3-way case split; keep BX5+BX7+BX13 chain for component 5
- [ ] Verify `lake build` passes with zero sorries

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- lines 3093-3531 (since seed definition, helpers, consistency proof)

**Verification**:
- `lake build` succeeds with zero errors
- `lemma_2_7_since_seed_consistent` type signature unchanged
- No new sorries introduced

---

### Phase 4: Update lemma_2_7_since and lemma_2_8_since proof bodies [NOT STARTED]

**Goal**: Update the Since-direction main lemma proofs to use Xu 3.2.1 for components 3-4, and simplify `lemma_2_8_since_seed_consistent`.

**Tasks**:
- [ ] Update `lemma_2_7_since` (lines 3532-3640) proof body:
  - Derive `h_untl_D` via `xu_lemma_3_2_1_until` + `h_B_sub_D` (same pattern as Phase 2)
  - Derive `h_snce_D` via `xu_lemma_3_2_1_since` + `h_B_sub_D`
  - Replace seed extraction of untl/snce memberships with derived facts
  - Establish `burgessR3(D, B'', C)` and `burgessR3(A, B', D)` from derived memberships
- [ ] Simplify `lemma_2_8_since_seed_consistent` (lines 3641-3951): 5-way to 3-way case reduction (mirrors Phase 2's work on lemma_2_8_seed_consistent)
- [ ] Update `lemma_2_8_since` (lines 3952-4055) if it has any direct seed extraction for components 3-4
- [ ] Verify `lake build` passes with zero sorries

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- lines 3532-4055 (lemma_2_7_since body, lemma_2_8_since_seed_consistent, lemma_2_8_since body)

**Verification**:
- `lake build` succeeds with zero errors
- `lemma_2_7_since` output type unchanged
- `lemma_2_8_since` output type unchanged
- No new sorries introduced

---

### Phase 5: Final cleanup and verification [NOT STARTED]

**Goal**: Remove any remaining dead code, update comments/docstrings, and verify the full build.

**Tasks**:
- [ ] Remove any dead helper functions that are no longer referenced after Phases 1-4
- [ ] Update the docstring on `lemma_2_7_seed` (lines 1864-1874) to reflect the 3-component structure
- [ ] Update the docstring on `lemma_2_7_since_seed` (lines 3091-3092) to reflect the 3-component structure
- [ ] Run `lake build` to confirm full project builds with zero sorries
- [ ] Verify line count reduction: PointInsertion.lean should be approximately 3500-3600 lines (down from 4347)
- [ ] Spot-check CounterexampleElimination.lean builds without changes (confirm zero modifications needed)

**Timing**: 30 minutes

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- dead code removal and comment updates

**Verification**:
- `lake build` succeeds with zero errors across entire project
- PointInsertion.lean line count between 3400 and 3700 (approximately 700-900 lines removed)
- `grep -c sorry PointInsertion.lean` returns 0
- CounterexampleElimination.lean unchanged (verify with `git diff`)

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental verification)
- [ ] Zero sorries in PointInsertion.lean after all phases
- [ ] Output types of `lemma_2_7`, `lemma_2_7_since`, `lemma_2_8`, `lemma_2_8_since` unchanged
- [ ] CounterexampleElimination.lean requires zero modifications
- [ ] PointInsertion.lean line count reduced by approximately 700-900 lines
- [ ] No regressions in any other file in the project

## Artifacts & Outputs

- `specs/134_restructure_lemma_2_7_seeds_xu_3_2_1/plans/01_seed-restructure-plan.md` (this file)
- `specs/134_restructure_lemma_2_7_seeds_xu_3_2_1/summaries/01_seed-restructure-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

## Rollback/Contingency

Git provides full rollback capability. If any phase introduces a sorry or breaks the build:
1. Revert to the last known-good commit with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
2. The existing 5-component seeds are sorry-free and working -- reverting loses only the simplification, not correctness
3. If the consistency proof simplification proves unexpectedly difficult, a partial approach is viable: simplify only the seed definition and lemma bodies (using Xu 3.2.1) while keeping the full 5-way consistency proof structure with the extra cases trivially discharged
