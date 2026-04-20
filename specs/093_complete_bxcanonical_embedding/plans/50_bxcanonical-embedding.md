# Implementation Plan: Task #93

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: reports/51_guard-choice-analysis.md
- **Artifacts**: plans/50_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the research-determined path to sound axiomatics for BXCanonical: switch Until/Since to half-open guard [t,s), drop the unsound BX8/BX8' axioms, reformulate BX2/BX2' to require the additional conjunct (phi->chi), and close the resulting soundness proofs. After the axiom system is corrected, the plan addresses BX2 call site auditing in the completeness infrastructure and assesses the chain construction sorry sites. Definition of done: Soundness.lean sorry-free for all retained axioms, BX8/BX8' removed from axiom system, BX2 reformulated, BX9 soundness proved, downstream compilation clean.

### Research Integration

- Report 51 (guard choice analysis): Definitively establishes half-open guard as the only viable convention that keeps BX9 sound while maintaining completeness proof structure. BX8 invalid under both guards on Z. BX2 needs (phi->chi) AND G(phi->chi) under half-open. BX9 becomes trivially provable (guard includes t). BX5/BX6/BX10/BX12 all remain sound under half-open (proved in appendices).
- Report 50 (team research): Confirmed phi_imp_F_phi removal (done in v49 Phase 2), identified constrained Lindenbaum limitations, validated irreflexive semantics choice.

### Prior Plan Reference

Plan v49 (4 phases, 12 hours): Phase 2 (phi_imp_F_phi removal) was completed. Phases 1 (guard fix), 3, and 4 (chain construction) were blocked. Key lessons: (1) Guard fix itself is mechanical but cascading effects need cataloging; (2) The research now CLARIFIES that BX8 must be dropped entirely (v49 incorrectly tried to prove it); (3) BX2 reformulation is newly identified by report 51 and was not in v49 at all; (4) Chain construction sorries remain the hard unsolved problem.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Switch Until/Since guard from open (t,s) to half-open [t,s) in Truth.lean
- Drop BX8/BX8' (until_step/since_step) from Axioms.lean and Soundness.lean
- Reformulate BX2/BX2' to (phi->chi) AND G(phi->chi) -> (phi U psi -> chi U psi)
- Prove BX9/BX9' soundness (now trivial under half-open guard)
- Prove BX1/BX1' soundness (specialize to Int or add NoMaxOrder/NoMinOrder)
- Close Soundness.lean line 448 sorry (temporal interaction)
- Audit and fix BX2 call sites in completeness proof (CanonicalChain.lean, Frame.lean)
- Achieve `lake build` clean with no new sorries introduced

**Non-Goals**:
- Closing chain construction sorries (fwd_chain_forward_F, restricted_tc, restricted_buc, restricted_fuc) -- these are orthogonal and remain the hard open problem
- SigmaOrdering.lean sorry sites (marked non-critical path, depend on BX1 which requires reflexive G)
- Quasimodel architecture redesign
- psi_imp_until_mcs closure (requires reflexive Until introduction which is invalid; will be deleted along with BX8)
- Dense completeness (task 68)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard change cascades through TimeShift lemmas | M | H (65%) | Changes are mechanical (≤ vs <). Audit systematically. Most lemmas use witness direction (t < s), not guard direction. |
| BX2 reformulation breaks left_mono_until_mcs callers | M | M (50%) | Only 2 call sites identified. BX9 (now sound) provides phi(t) from (phi U psi) in w, likely satisfying the extra hypothesis. |
| serial_future/past need NoMaxOrder/NoMinOrder not available generically | M | L (30%) | Canonical model uses Int which has both. Either add typeclass constraints to validity theorem or specialize. |
| Temporal interaction sorry (line 448) requires successor structure | M | M (40%) | Under half-open guard, the argument strengthens: phi on [t,s) directly gives phi(t). May simplify or may need discrete specialization. |
| Removing BX8 from DerivationTree breaks existing proof trees | L | M (35%) | BX8 was never used in proved code. Only sorry'd `psi_imp_until_mcs` references it conceptually (not as Axiom.until_step). Deletion is safe. |
| Half-open guard invalidates existing BX2 soundness proof | M | H (80%) | This is EXPECTED. The proof must be rewritten to match the new axiom statement. Research provides the proof sketch. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3 |

Phases 4 and 5 are independent of each other (both depend on Phase 3 for a compiling axiom system).

---

### Phase 1: Switch Guard Convention in Truth.lean [COMPLETED]

**Goal**: Change Until/Since guard from open (t,s) to half-open [t,s) / (s,t]. Fix downstream compilation in Truth.lean itself (TimeShift lemmas, truth_at helpers).

**Tasks**:
- [ ] Truth.lean line 128: Change `t < r → r < s` to `t ≤ r → r < s` (Until includes current point)
- [ ] Truth.lean line 130: Change `s < r → r < t` to `s ≤ r → r < t` (Since: half-open from witness side)
- [ ] Audit TimeShift lemmas (lines 321-575) for guard direction references and fix
- [ ] Run `lake build` on Truth.lean module; catalog all downstream breakage
- [ ] Fix any truth_at helper lemmas that unpack the guard (e.g., truth_at_untl_iff)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- 2 guard changes + TimeShift repairs (~50 LOC)

**Verification**:
- Truth.lean compiles with `t ≤ r → r < s` for Until guard
- Since guard uses `s ≤ r → r < t` (half-open from witness side)
- All TimeShift lemmas compile

---

### Phase 2: Drop BX8/BX8' and Reformulate BX2/BX2' in Axioms [COMPLETED]

**Goal**: Remove BX8/BX8' from the axiom inductive type. Reformulate BX2/BX2' to include the extra (phi->chi) conjunct. Update all pattern-match sites in DerivationTree, Soundness, etc.

**Tasks**:
- [ ] Axioms.lean: Delete `until_step` and `since_step` constructors
- [ ] Axioms.lean: Change `left_mono_until` from `G(phi->chi) -> (phi U psi -> chi U psi)` to `(phi->chi) AND G(phi->chi) -> (phi U psi -> chi U psi)`
- [ ] Axioms.lean: Change `left_mono_since` similarly with H replacing G
- [ ] Axioms.lean: Update doc comments to reflect new semantics
- [ ] Soundness.lean: Remove `until_step_valid` and `since_step_valid` theorems (or convert to commented historical note)
- [ ] Soundness.lean: Remove the match cases for `until_step`/`since_step` in all three soundness theorems
- [ ] Soundness.lean: Update `left_mono_until_valid` proof to match new axiom statement
- [ ] Soundness.lean: Update `left_mono_since_valid` proof similarly
- [ ] DerivationTree pattern matches: Remove BX8/BX8' cases everywhere
- [ ] CanonicalChain.lean: Delete `psi_imp_until_mcs` and `psi_imp_since_mcs` (these used BX8 conceptually and are sorry'd; now invalid)
- [ ] CanonicalChain.lean: Update `left_mono_until_mcs` and `left_mono_since_mcs` to require extra hypothesis `(phi.imp chi) ∈ w.formulas`
- [ ] Run `lake build` and fix all compilation errors from removed/changed constructors

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Remove 2 constructors, modify 2 (~30 LOC)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Remove 2 theorems, update 2 proofs (~80 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Delete 2 theorems, update 2 signatures (~40 LOC)
- Any file matching on `Axiom.until_step`/`Axiom.since_step` -- pattern match removal

**Verification**:
- No occurrences of `until_step` or `since_step` in Axioms.lean
- `left_mono_until` now takes conjunction as hypothesis
- `lake build` passes (with existing sorries elsewhere)

---

### Phase 3: Close Soundness Proofs (BX9, BX1, temporal interaction) [COMPLETED]

**Goal**: Close all remaining sorry sites in Soundness.lean. BX9/BX9' are now trivially provable under half-open guard. BX1/BX1' need NoMaxOrder/NoMinOrder (specialize to Int or add typeclass). Line 448 temporal interaction needs review under new guard.

**Tasks**:
- [ ] Soundness.lean `until_elim_valid` (line 761): Prove BX9 under half-open guard. Proof: (phi U psi) at t gives witness s > t with psi(s) and phi on [t,s). Since t in [t,s), phi(t) holds. So phi OR psi via Left.
- [ ] Soundness.lean `since_elim_valid` (line 771): Mirror proof for Since
- [ ] Soundness.lean `serial_future_axiom_valid` (line 200): Add `[NoMaxOrder T]` typeclass constraint or prove for the general ordered additive group (use `exists_gt`)
- [ ] Soundness.lean `serial_past_axiom_valid` (line 213): Add `[NoMinOrder T]` or use `exists_lt`
- [ ] Soundness.lean line 448 (temporal interaction): Analyze under half-open guard. The half-open guard gives phi(t) directly from the Until hypothesis. Close or reformulate.
- [ ] Soundness.lean `left_mono_until_valid`: Write new proof for reformulated BX2 under half-open. Proof sketch: from (phi->chi)(t) and G(phi->chi), given phi U psi at t with phi on [t,s) and psi(s), derive chi(t) from phi(t) and (phi->chi)(t), chi(r) for r in (t,s) from phi(r) and G(phi->chi) at r.
- [ ] Soundness.lean `left_mono_since_valid`: Mirror proof
- [ ] Run `lake build` and verify Soundness.lean is sorry-free

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Close 5-7 sorry sites (~150 LOC of proofs)

**Verification**:
- Zero `sorry` keywords in Soundness.lean
- `lake build` passes
- `lean_verify` on soundness theorem shows no sorry dependency

---

### Phase 4: Audit and Fix BX2 Call Sites in Completeness [COMPLETED]

**Goal**: The reformulated BX2 requires `(phi->chi) ∈ w.formulas` in addition to `G(phi->chi) ∈ w.formulas`. Update all callers of `left_mono_until_mcs`/`left_mono_since_mcs` to provide this extra hypothesis.

**Tasks**:
- [ ] Grep all uses of `left_mono_until_mcs` and `left_mono_since_mcs` in the codebase
- [ ] For each call site, determine if `(phi.imp chi) ∈ w.formulas` is available:
  - If `phi U psi ∈ w.formulas`: by BX9 (now sound), phi ∈ w. If chi follows from phi, derive (phi->chi) via MCS properties.
  - If G(phi->chi) ∈ w.formulas and the MCS has modal reflexivity reasoning available, derive directly.
- [ ] Update each call site to provide the extra argument
- [ ] If any call site cannot provide the hypothesis, document as a new sorry with clear explanation
- [ ] Run `lake build` and verify no regressions

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Update callers (~20 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` -- If BX2 used there
- Any other files using `left_mono_until_mcs`/`left_mono_since_mcs`

**Verification**:
- All callers of `left_mono_until_mcs` provide both hypotheses
- `lake build` passes
- No new sorry sites introduced by this phase

---

### Phase 5: Assess Chain Construction Sorries [COMPLETED]

**Goal**: With the corrected axiom system (BX9 sound, BX8 removed, BX2 reformulated), reassess the 5 chain construction sorry sites in RootScopedChain.lean / OracleCoherence.lean. Determine which are now closeable and attempt closure where feasible.

**Tasks**:
- [ ] Catalog all active sorry sites in BXCanonical/ (excluding Boneyard/, SigmaOrdering non-critical)
- [ ] For `fwd_chain_forward_F`: With BX9 now providing phi(t) from phi U psi, and BX8 removed (no longer needed), reassess the proof strategy. The oracle step may now have a cleaner termination argument.
- [ ] For `psi_imp_until_mcs` (deleted in Phase 2): Verify its callers have been updated to use `F_imp_top_until_mcs` (BX12) instead
- [ ] For `restricted_tc` / `restricted_buc` / `restricted_fuc`: Document current status and what additional infrastructure is needed
- [ ] Attempt to close any sorry site that becomes tractable under the new axiom system
- [ ] If chain construction remains blocked, document precise blockers for future work

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Assessment and potential closures
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/OracleCoherence.lean` -- Assessment

**Verification**:
- Clear documentation of which sorries remain and why
- Any closed sorries verified by `lake build`
- No new sorry sites introduced

---

## Testing & Validation

- [ ] After Phase 1: Truth.lean compiles with half-open guard
- [ ] After Phase 2: Axioms.lean has no BX8/BX8', BX2 reformulated, `lake build` passes
- [ ] After Phase 3: Soundness.lean is sorry-free, `lean_verify` clean on soundness theorems
- [ ] After Phase 4: All BX2 callers updated, `lake build` clean
- [ ] After Phase 5: Chain construction status documented, any closeable sorries closed
- [ ] Full: `lake build` succeeds with no new sorry sites beyond pre-existing chain construction sorries

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/50_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Semantics/Truth.lean` -- half-open guard convention
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- BX8 removed, BX2 reformulated
- `Theories/Bimodal/Metalogic/Soundness.lean` -- sorry-free soundness proofs (for retained axioms)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- updated BX2 MCS lemmas

## Rollback/Contingency

1. **Phase 1 rollback**: `git checkout -- Theories/Bimodal/Semantics/Truth.lean` restores open guard. Low risk -- change is 2 characters per line.

2. **Phase 2 rollback**: Revert Axioms.lean and Soundness.lean. More involved due to constructor removal cascading through pattern matches. Keep a commit checkpoint before Phase 2.

3. **Phase 3 contingency**: If BX1 cannot be proved generically, restrict soundness theorem to orders with NoMaxOrder/NoMinOrder (which includes Int, the canonical model's domain). This is a narrowing of generality, not a failure.

4. **Phase 4 contingency**: If BX2 call sites cannot provide (phi->chi) ∈ w, consider alternative: derive (phi->chi) from BX9 applied to phi U psi (gives phi ∈ w) combined with context-specific reasoning. Worst case: leave as documented sorry with clear justification.

5. **Complete rollback**: The branch `irr_until` contains all changes. Can reset to pre-Phase-1 commit at any time.
