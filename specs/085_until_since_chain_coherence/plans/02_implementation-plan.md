# Implementation Plan: Task #85 — Until/Since Chain Coherence

- **Task**: 85 - Until/Since chain coherence approaches
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md, reports/02_xy-archival-scope.md
- **Artifacts**: plans/02_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan addresses the dominant completeness blocker in the bimodal TM system through four workstreams: (1) surgical archival of X/Y discrete-time artifacts to Boneyard, eliminating 5 sorry sites from dead code; (2) fixing the trivial FMP sorry in TruthPreservation.lean; (3) investigating the BXCanonical path by attempting to prove bx_le linearity from BX7; and (4) refactoring the truth lemma to use restricted coherence. Research confirmed that chain-based approaches are degenerate under reflexive semantics (x_content(M) = M), that Burgess-Xu axiom 4 is semantically invalid, and that BXCanonical (5 sorries) is the most viable path forward.

### Research Integration

- **Report 01** (team research): Established x_content triviality, Burgess-Xu 4 invalidity, identified BXCanonical as 5-sorry path vs 40+ Bundle path, found trivially fixable FMP sorry.
- **Report 02** (X/Y archival scope): Mapped X/Y footprint to 3 material files + 8 comment files, designed 6-phase surgical cleanup with net -5 sorry reduction.

## Goals & Non-Goals

**Goals**:
- Remove X/Y operator artifacts from active codebase (net -5 sorry sites)
- Fix the trivial FMP sorry in TruthPreservation.lean (-1 sorry)
- Investigate BX7 linearity as a path to closing 4 BXCanonical Frame.lean sorries
- Refactor truth lemma to properly scope Until/Since coherence obligations

**Non-Goals**:
- Closing all completeness sorries (this task is investigation + cleanup)
- Implementing full quasimodel replacement
- Deriving Burgess-Xu axiom 4 (proven semantically invalid)
- Modifying the reflexive semantics design choice

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| X/Y rename breaks downstream imports | H | L | `lake build` after each sub-step; all breakage is from renamed symbols only |
| BX7 linearity does not yield bx_le totality | H | M | Phase 4 is investigative; document findings even if proof fails |
| FMP temp_4 fix has hidden complications | L | L | The fix is a one-liner using existing Axiom.temp_4; verify with lake build |
| Truth lemma refactoring introduces regressions | M | L | Restricted coherence is a weakening; existing proofs remain valid |
| Lean build times slow iteration on BXCanonical | M | M | Use lean-lsp MCP for targeted goal inspection instead of full rebuilds |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4 | 1 |
| 3 | 5 | 2, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Rename X/Y Theorems and Remove Pure X/Y Code [NOT STARTED]

**Goal**: Rename kept theorems from X/Y notation to bot-Until/bot-Since notation, then remove purely X/Y definitions and theorems from TemporalDerived.lean.

**Tasks**:
- [ ] Rename in `Theorems/TemporalDerived.lean`:
  - `X_bot_absurd` -> `bot_until_bot_absurd`
  - `Y_bot_absurd` -> `bot_since_bot_absurd`
  - `X_elim` -> `bot_until_elim`
  - `Y_elim` -> `bot_since_elim`
  - `x_implies_id` -> `bot_until_id`
  - `y_implies_id` -> `bot_since_id`
  - `until_unfold_X` -> `until_unfold_wrapped`
  - `since_unfold_Y` -> `since_unfold_wrapped`
- [ ] Update call sites in `WitnessSeed.lean`, `SuccRelation.lean`, `TemporalContent.lean`
- [ ] `lake build` to verify renames compile
- [ ] Remove `private abbrev X` and `private abbrev Y` (lines 54-55)
- [ ] Remove purely X/Y theorems: `G_implies_G_step`, `G_implies_X`, `H_implies_Y`, `YX_identity`, `XY_identity`, `y_nec'`, `x_nec'`, `YG_implies_self`, `XH_implies_self`
- [ ] Update module docstring in TemporalDerived.lean
- [ ] `lake build` to verify removals compile

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — rename + remove X/Y-only definitions
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — update `X_bot_absurd`/`Y_bot_absurd` references
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — update `until_unfold_X`/`since_unfold_Y` references
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` — update `X_bot_absurd`/`Y_bot_absurd` references

**Verification**:
- `lake build` succeeds with zero new errors
- All renamed symbols resolve at their call sites
- Sorry count unchanged (no sorry sites added or removed in this phase)

---

### Phase 2: Remove x_content/y_content Section and Archive Discreteness [NOT STARTED]

**Goal**: Remove the x_content/y_content infrastructure from TemporalContent.lean (4 sorry sites) and archive Discreteness.lean to Boneyard (1 sorry site).

**Tasks**:
- [ ] Remove x_content/y_content definitions and all dependent theorems from `TemporalContent.lean` (lines ~112-441): `x_content`, `y_content`, `mem_x_content_iff`, `mem_y_content_iff`, `x_nec`, `y_nec`, `x_lift_derivation`, `y_lift_derivation`, `x_content_set_consistent`, `x_content_maximal`, `x_content_mcs`, `y_content_set_consistent`, `y_content_maximal`, `y_content_mcs`
- [ ] Update module docstring in TemporalContent.lean to remove x/y references
- [ ] `lake build` to verify (-4 sorry sites)
- [ ] Create `Theories/Bimodal/Boneyard/DiscreteXY/` directory
- [ ] Move `Theories/Bimodal/Theorems/Discreteness.lean` to `Theories/Bimodal/Boneyard/DiscreteXY/Discreteness.lean`
- [ ] Remove `import Bimodal.Theorems.Discreteness` from `Theories/Bimodal/Theorems.lean`
- [ ] `lake build` to verify (-1 sorry site, total -5 from baseline)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` — remove x/y_content section (lines 112-441)
- `Theories/Bimodal/Theorems/Discreteness.lean` — move to Boneyard
- `Theories/Bimodal/Theorems.lean` — remove Discreteness import

**Verification**:
- `lake build` succeeds
- Sorry count reduced by 5 (from ~261 to ~256 active)
- No active code references x_content, y_content, or Discreteness

---

### Phase 3: Fix FMP TruthPreservation Sorry [NOT STARTED]

**Goal**: Fix the trivial `temp_4` sorry in FMP/TruthPreservation.lean by providing the correct axiom derivation.

**Tasks**:
- [ ] Read `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean` around line 263
- [ ] Inspect the goal state at the sorry site using lean-lsp
- [ ] Replace `sorry /- temp_4 removed in BX -/` with `DerivationTree.axiom [] _ (Axiom.temp_4 psi)` (or equivalent based on goal inspection)
- [ ] `lake build` to verify the sorry is resolved

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean` — line 263, replace sorry with axiom invocation

**Verification**:
- `lake build` succeeds
- Sorry count reduced by 1 at TruthPreservation.lean:263
- No new sorry sites introduced

---

### Phase 4: Investigate BX7 Linearity for bx_le Totality [NOT STARTED]

**Goal**: Attempt to prove that bx_le is sufficiently linear (total preorder on intervals) using BX7 axiom, which would close 4 Frame.lean sorry sites.

**Tasks**:
- [ ] Read `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` in detail (lines 440-605) to understand the 4 sorry sites and what bx_le totality would provide
- [ ] Inspect the goal state at each sorry site using lean-lsp
- [ ] Read BX7 axiom definition in `Theories/Bimodal/ProofSystem/Axioms.lean` and understand its proof-theoretic content
- [ ] Attempt to prove: for BXPoints w, u, v with `bx_le w u` and `bx_le w v`, either `bx_le u v` or `bx_le v u`
- [ ] If linearity proof succeeds: wire into `bx_until_eventuality_resolution` (line 553) and propagate to remaining 3 sorries
- [ ] If linearity proof is blocked: document the specific obstacle (what subgoal remains), what additional infrastructure would be needed, and whether the approach remains viable
- [ ] Document findings in phase completion notes regardless of outcome

**Timing**: 4 hours

**Depends on**: none (but Wave 2 for scheduling efficiency)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — attempt proof at sorry sites (lines 553, 575, 590, 604)
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — line 144 if Frame sorries are resolved

**Verification**:
- If successful: `lake build` succeeds with 4 fewer sorry sites in Frame.lean and 1 fewer in Completeness.lean
- If partially successful: document which sorries were closed and which remain
- If blocked: written analysis of the obstacle with concrete Lean goal states

---

### Phase 5: Clean Up X/Y Comments Across Codebase [NOT STARTED]

**Goal**: Remove or update X/Y references in comments across 8 files to prevent confusion.

**Tasks**:
- [ ] Update comments in `Metalogic/Algebraic/Algebraic.lean` (lines 13-14, 40, 99-100)
- [ ] Update comments in `Metalogic/Algebraic/DovetailedChain.lean` (line 39, lines 627-648)
- [ ] Update comments in `Metalogic/Bundle/UntilSinceCoherence.lean` (lines 30-31)
- [ ] Update comments in `Metalogic/Bundle/TemporalCoherence.lean` (lines 442, 450-451)
- [ ] Update comments in `Metalogic/Bundle/SuccRelation.lean` (lines 533, 557)
- [ ] Update comments in `FrameConditions/Completeness.lean` (lines 6, 328, 599, 621)
- [ ] Update removed axiom list in `Metalogic/Soundness.lean` (lines 715-728)
- [ ] Update `Metalogic/Algebraic/README.md` (lines 47-48, 52, 85-87)
- [ ] `lake build` to verify no regressions

**Timing**: 1 hour

**Depends on**: 2, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` — comment cleanup
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` — comment cleanup
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — comment cleanup
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — comment cleanup
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — comment cleanup
- `Theories/Bimodal/FrameConditions/Completeness.lean` — comment cleanup
- `Theories/Bimodal/Metalogic/Soundness.lean` — comment cleanup
- `Theories/Bimodal/Metalogic/Algebraic/README.md` — remove DeterministicChain/FMCS references

**Verification**:
- `lake build` succeeds
- `grep -r "x_content\|y_content\|DeterministicChain\|DeterministicFMCS" Theories/ --include="*.lean" | grep -v Boneyard/` returns no results (excluding legitimate `bot U` discussions)

---

### Phase 6: Truth Lemma Refactoring and Sorry Summary Update [NOT STARTED]

**Goal**: Refactor truth lemma to use `restricted_forward_until_since_coherent` scoped to `subformulaClosure(root)`, and produce final sorry accounting.

**Tasks**:
- [ ] Read `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` to understand current coherence definition
- [ ] Define `restricted_forward_until_since_coherent root` quantifying only over `subformulaClosure(root)`
- [ ] Wire restricted coherence into truth lemma usage sites
- [ ] `lake build` to verify refactoring compiles
- [ ] Count remaining sorry sites: `grep -rn "sorry" Theories/ --include="*.lean" | grep -v Boneyard/ | grep -v "^.*:.*--" | wc -l`
- [ ] Update sorry summary with final delta from baseline

**Timing**: 1.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — add restricted coherence definition
- Possibly `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — wire restricted coherence

**Verification**:
- `lake build` succeeds
- Restricted coherence definition compiles and is used by truth lemma
- Final sorry count documented

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase (6 checkpoints)
- [ ] Sorry count decreases by at least 5 (X/Y archival) + 1 (FMP fix) = 6
- [ ] No active Lean file imports X/Y-specific definitions after Phase 2
- [ ] BXCanonical investigation produces documented findings (success or documented obstacle)
- [ ] Restricted coherence compiles and properly scopes obligations

## Artifacts & Outputs

- `specs/085_until_since_chain_coherence/plans/02_implementation-plan.md` (this file)
- `specs/085_until_since_chain_coherence/summaries/02_execution-summary.md` (post-implementation)
- `Theories/Bimodal/Boneyard/DiscreteXY/Discreteness.lean` (archived file)

## Rollback/Contingency

- **Phase 1-2 (X/Y archival)**: `git revert` the phase commit. All changes are symbol renames and deletions; no new logic is introduced.
- **Phase 3 (FMP fix)**: Revert single line change if it introduces unexpected issues.
- **Phase 4 (BX7 investigation)**: If proof attempt fails, no code changes are committed. Document findings for future reference. This phase is investigative and does not modify working code unless proof succeeds.
- **Phase 5 (comments)**: Comment-only changes; revert is trivial.
- **Phase 6 (refactoring)**: If restricted coherence introduces type errors downstream, revert to unrestricted form. The refactoring is a weakening, so existing proofs should remain valid.

## Sorry Impact Tracking

| Phase | Action | Sorry Delta | Running Total |
|-------|--------|-------------|---------------|
| Baseline | Current state | 0 | ~261 |
| Phase 1 | Rename X/Y theorems | 0 | ~261 |
| Phase 2 | Remove x/y_content + archive Discreteness | -5 | ~256 |
| Phase 3 | Fix FMP temp_4 sorry | -1 | ~255 |
| Phase 4 | BX7 linearity (if successful) | -4 to -5 | ~250-251 |
| Phase 5 | Comment cleanup | 0 | ~250-256 |
| Phase 6 | Truth lemma refactoring | 0 | ~250-256 |
| **Best case** | All phases succeed | **-10 to -11** | **~250-251** |
| **Guaranteed** | Phases 1-3, 5-6 | **-6** | **~255** |
