# Implementation Plan: Task #141 (Revised)

- **Task**: 141 - canonical_truth_lemma_until_since
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/141_canonical_truth_lemma_until_since/reports/01_team-research.md, specs/141_canonical_truth_lemma_until_since/reports/03_teammate-a-necessity.md, specs/141_canonical_truth_lemma_until_since/reports/03_teammate-b-solutions.md, specs/141_canonical_truth_lemma_until_since/reports/03_teammate-c-cleanup.md, specs/141_canonical_truth_lemma_until_since/reports/03_teammate-d-critical-path.md
- **Artifacts**: plans/02_revised-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is a revised plan for Task 141, reduced from 6 phases (10 hours) to 3 phases (4 hours) based on definitive findings from round 2 research (8 agents). The key finding is that ALL 7 remaining WeakCanonical sorries (1 in ReflexiveCanonical.lean, 6 in TruthLemma.lean) are confirmed dead code relative to `bx_completeness`. The `truth_lemma` is defined but never called by the completeness theorem, which routes through the parametric truth lemma via the Burgess chronicle pipeline. The 6 TruthLemma Until/Since sorries are structurally impossible to close in the current ReflCanDomain model -- the model lacks chronicle gap-content infrastructure needed for the intermediate guard condition. The revised plan focuses on: (1) closing `reflCanR_linear` as mathematically correct infrastructure, (2) fixing stale documentation and ghost references, and (3) updating sorry counts to reflect the actual critical path.

### Research Integration

Round 2 research confirmed with high confidence:
- **Teammate A (Necessity)**: WeakCanonical `truth_lemma` has zero consumers outside TruthLemma.lean. `reflCanR_linear` has zero consumers. Neither blocks `bx_completeness`. The TODO.md sorry count claiming 8 critical-path sorries from task 141 is incorrect.
- **Teammate B (Solutions)**: The guard condition is structurally impossible in ReflCanDomain because `tempR_fwd` (g_content inclusion) lacks the interval structure (Burgess gap-content g(x,y)) needed for Until/Since intermediate guard propagation. This is not a missing lemma but a structural mismatch. Burgess uses the same open-guard semantics; his proof succeeds only because the chronicle has a two-function structure (f, g) with property C3.
- **Teammate C (Cleanup)**: TruthLemma.lean header (lines 27-28) falsely claims box backward and H forward/backward are sorry'd -- they are proved. `DovetailingChain.lean` is referenced 3 times but does not exist. The `truth_lemma` docstring at line 503 is stale.
- **Teammate D (Critical Path)**: The actual critical-path sorries for `bx_completeness` are `succ_cofinal` (hard, discrete branch), `existsTask_transitive` (trivial, 1-line fix), and `dd_countermodel_chronicle_mixed_sorry` (task 142). None are in WeakCanonical.

### Prior Plan Reference

Plan v1 (01_truth-lemma-plan.md) had 6 phases targeting all 8 sorries. Phase 1 (canS5R_symm) completed successfully. Phases 2-5 were blocked because the Until/Since guard condition is structurally impossible in the current model. Lesson learned: the 6 TruthLemma sorries cannot be closed without redesigning the ReflCanDomain to include chronicle-like gap-content, which would provide no benefit over the existing chronicle pipeline. The revised plan drops these impossible phases and focuses on what is achievable and valuable.

### Roadmap Alignment

- ROADMAP.md lists "Canonical truth lemma: 8 sorries in Until/Since and ReflexiveCanonical infrastructure (task 141)" under the critical path
- Research conclusively shows these 7 remaining sorries are NOT on the `bx_completeness` critical path -- the parametric truth lemma (Algebraic module) handles all cases via BFMCS coherence
- The ROADMAP sorry summary should be corrected to reflect this architectural reality
- `reflCanR_linear` is needed for Reynolds Theorem 15 but has no current downstream consumer

## Goals & Non-Goals

**Goals**:
- Close `reflCanR_linear` sorry in ReflexiveCanonical.lean (mathematically correct, ~50 lines via BX11)
- Fix stale TruthLemma.lean header comments (box backward and H forward/backward falsely listed as sorry'd)
- Replace 3 ghost `DovetailingChain.lean` references with actual extant files
- Fix `truth_lemma` docstring at line 503 (stale sorry list)
- Document all 6 TruthLemma sorries as non-critical-path dead code requiring ReflCanDomain restructuring
- Correct TODO.md sorry count to reflect actual critical path (remove 7 WeakCanonical sorries from count)
- Verify `lake build` passes

**Non-Goals**:
- Closing `until_forward_mcs` guard condition -- structurally impossible without model redesign
- Closing `until_backward_mcs`, `since_forward_mcs`, `since_backward_mcs` -- same root cause
- Closing truth_lemma Until/Since cases (lines 548, 563) -- depend on the above
- Redesigning ReflCanDomain with chronicle gap-content (30-50 hour effort with no benefit over existing chronicle)
- Fixing `existsTask_transitive` (different file, could be its own 1-line task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `reflCanR_linear` proof harder than estimated (~50 lines) | M | L | Proof sketch is well-established (BX11 argument), infrastructure exists. If blocked, mark phase PARTIAL and document progress. |
| `neg_G_imp_F_neg` helper (needed for reflCanR_linear) requires careful Formula encoding | M | M | Plan v1 Phase 2 worked through the encoding in detail. Use `G(neg_neg_psi) -> G(psi)` via double negation under temporal necessitation. |
| TODO.md sorry count correction may need coordination with other task updates | L | L | Only modify the sorry_count fields and the task 141 description. Do not touch other task entries. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: reflCanR_linear via BX11 [COMPLETED]

**Goal**: Close the `reflCanR_linear` sorry at ReflexiveCanonical.lean:144. This theorem states that the forward temporal cone from any MCS is linearly ordered. While it has no current downstream consumer, it is mathematically correct and completes the canonical frame properties.

**Tasks**:
- [x] **Task 1.1**: Create helper `tempR_fwd_mem_some_future` (Burgess Lemma 1.6(b)): if `tempR_fwd x y` and `β ∈ y.val`, then `F(β) ∈ x.val`. *(deviation: altered -- used Burgess 1.6(b) approach instead of the planned `neg_G_imp_F_neg` contrapositive, which is cleaner and avoids the ¬G→F encoding issue)*
- [x] **Task 1.2**: Create helper `not_tempR_fwd_witness_F`: contrapositive of 1.6(b) giving F-witnesses from ¬tempR_fwd. *(deviation: altered -- replaces `F_from_non_g_content` with a more general Lemma 1.6(b) contrapositive)*
- [x] **Task 1.3**: Create helper `some_future_mono`: F-monotonicity `⊢ A → B` gives `⊢ F(A) → F(B)`. *(not in plan -- needed for BX11 case analysis)*
- [x] **Task 1.4**: Prove `reflCanR_linear` using BX11 following Burgess 1984 Section 2.2. *(deviation: altered -- theorem statement changed from two-way `tempR_fwd y z ∨ tempR_fwd z y` to three-way `tempR_fwd y z ∨ y = z ∨ tempR_fwd z y` because `tempR_fwd y y` does not hold in irreflexive temporal semantics. Proof follows Burgess's construction of β₀∧¬Fγ₀∧δ and γ₀∧¬Fβ₀∧¬δ to make all BX11 disjuncts provably inconsistent.)*
- [x] **Task 1.5**: Verify `lake build` succeeds *(completed)*
- [x] **Task 1.6**: Confirm `grep -c 'sorry' ReflexiveCanonical.lean` shows 0 *(completed)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Add helper lemmas + prove reflCanR_linear

**Verification**:
- `lake build` succeeds
- `grep -c 'sorry' ReflexiveCanonical.lean` shows 0

---

### Phase 2: Documentation Cleanup [COMPLETED]

**Goal**: Fix all stale comments, ghost references, and incorrect sorry claims in TruthLemma.lean. Add non-critical-path documentation to the 6 Until/Since sorries.

**Tasks**:
- [x] **Task 2.1**: Fix TruthLemma.lean header (lines 22-33): Removed `box backward` and `H forward, H backward` from "Documented sorries" list. Added them to "Proved (sorry-free)" section with box forward/backward and H forward/backward. *(completed)*
- [x] **Task 2.2**: Fix `truth_lemma` docstring (line 503): Updated to list all sorry-free cases and note Until/Since sorries as non-critical-path. *(completed)*
- [x] **Task 2.3**: Replace 3 ghost `DovetailingChain.lean` references with `BXCanonical/CanonicalChain.lean` or `BXCanonical/Filtration/DefectChain.lean`. All three references replaced. *(completed -- lines 392, 424, 436 now reference actual files)*
- [x] **Task 2.4**: Add non-critical-path architectural note to all 6 sorry blocks. Updated `until_forward_mcs` docstring and inline sorry comment, `until_backward_mcs` docstring, `since_forward_mcs` docstring and inline sorry comment, `since_backward_mcs` docstring, and both truth_lemma Until/Since sorry comments. *(deviation: altered -- notes are condensed rather than using the full template from the plan, but convey the same information: non-critical-path, parametric truth lemma handles via BFMCS coherence)*
- [x] **Task 2.5**: Verify `lake build` succeeds. *(completed -- 781 jobs, 0 errors)*

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - Fix header, docstrings, ghost references, add architectural notes

**Verification**:
- `lake build` succeeds
- `grep -c 'DovetailingChain' TruthLemma.lean` shows 0
- Header accurately reflects sorry status (only Until/Since listed)

---

### Phase 3: Sorry Count Correction and Close-Out [COMPLETED]

**Goal**: Correct TODO.md and state.json sorry counts to reflect the actual critical path, removing the 7 WeakCanonical sorries from the critical-path count. Verify build. Mark task status.

**Tasks**:
- [x] **Task 3.1**: Run `lake build` to verify all changes from Phases 1-2 are clean. *(completed -- downstream modules build, NormalForm.lean pre-existing error unrelated)*
- [x] **Task 3.2**: Audit remaining sorries. ReflexiveCanonical: 0. TruthLemma: 6 (as expected). *(completed)*
- [x] **Task 3.3**: Update TODO.md sorry count from 14 to 6 critical-path sorries: 3 NEquivalence (139) + 2 Table (140) + 1 mixed case (142). *(completed)*
- [x] **Task 3.4**: Update TODO.md task 141 description: 2 closed (canS5R_symm, reflCanR_linear), 6 documented non-critical-path. *(completed)*
- [x] **Task 3.5**: Update ROADMAP.md critical-path sorry summary: task 141 resolved, not on critical path. *(completed)*
- [ ] **Task 3.6**: Decide on task 141 completion status. *(deferred to orchestrator -- implementation agent does not update task status)*

**Timing**: 1 hour

**Depends on**: 1, 2

**Files to modify**:
- `specs/TODO.md` - Correct sorry counts, update task 141 description
- `specs/state.json` - Correct sorry_count and sorry_count_note
- `specs/ROADMAP.md` - Update critical-path sorry summary

**Verification**:
- `lake build` succeeds
- TODO.md sorry counts match actual critical path
- state.json and TODO.md are synchronized
- ROADMAP.md accurately reflects architectural reality

## Testing & Validation

- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -c 'sorry' Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` returns 0 (after Phase 1)
- [ ] `grep -c 'sorry' Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` returns 6 (unchanged -- these are documented non-critical-path sorries)
- [ ] `grep -c 'DovetailingChain' Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` returns 0 (after Phase 2)
- [ ] No regressions in existing sorry-free proofs
- [ ] TODO.md and state.json sorry counts are consistent and accurate

## Artifacts & Outputs

- `specs/141_canonical_truth_lemma_until_since/plans/02_revised-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` (reflCanR_linear sorry closed)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` (documentation cleanup, no sorry changes)
- Modified: `specs/TODO.md` (sorry count correction)
- Modified: `specs/state.json` (sorry count correction)
- Modified: `specs/ROADMAP.md` (critical-path sorry summary correction)

## Rollback/Contingency

- If Phase 1 (reflCanR_linear) is blocked, proceed with Phases 2-3 anyway. The documentation cleanup and sorry count correction are independently valuable. reflCanR_linear can be left for a future task.
- All Lean code changes are in 2 files only (ReflexiveCanonical.lean, TruthLemma.lean). Git revert of those files restores the prior state.
- If sorry count correction is controversial (e.g., desire to keep the higher count for visibility), the correction can be deferred pending broader discussion about what "critical path" means.
