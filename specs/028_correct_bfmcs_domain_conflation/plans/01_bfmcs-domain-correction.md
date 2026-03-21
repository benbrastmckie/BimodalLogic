# Implementation Plan: Task #28

- **Task**: 28 - Correct W=D conflation in BFMCS domain architecture
- **Status**: [IN PROGRESS]
- **Effort**: 12 hours (8-16 hour range from task description)
- **Dependencies**: Task 27 (unify dense/dovetailed timelines) - provides TimelineQuot infrastructure
- **Research Inputs**: specs/028_correct_bfmcs_domain_conflation/reports/01_team-research.md
- **Artifacts**: plans/01_bfmcs-domain-correction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

The BFMCS domain architecture conflates world states (W = CanonicalMCS) with time indices (D) in 4 sites. The root cause: CanonicalMCS has neither DenselyOrdered nor SuccOrder instances, making it unsuitable as D for completeness theorems. This plan implements the architecturally correct fix from specs/006 reports 17-20: use D = Int for discrete completeness (via Succ-chain induction) and D = TimelineQuot for dense completeness (via Cantor isomorphism). The implementation bypasses the problematic covering lemma entirely through the Succ-based approach.

### Research Integration

Key findings from team research:
- 4 conflation sites identified with specific files and sorry counts
- Mathematical root cause confirmed: DenselyOrdered and SuccOrder are mutually exclusive (Mathlib proof via `denselyOrdered_iff_forall_not_covBy`)
- Cross-family modal coherence fails when D =/= CanonicalMCS unless Succ-chain structure is used
- Discrete path via Succ-chains bypasses `discrete_Icc_finite_axiom` entirely
- Dense path has two viable approaches: TimelineQuotBFMCS unification or CanonicalEmbedding completion

## Goals & Non-Goals

**Goals**:
- Implement f_content/p_content extractors in TemporalContent.lean
- Define Succ relation and CanonicalTask three-place relation for discrete completeness
- Fix DirectMultiFamilyBFMCS.lean to use Succ-chain families (eliminating t=/=0 modal coherence sorries)
- Complete one viable path for dense completeness (TimelineQuotBFMCS or CanonicalEmbedding)
- Correct task 22 report with W vs D clarification
- Remove or deprecate dead-end code (MultiFamilyBFMCS.lean)

**Non-Goals**:
- Proving seed consistency for successor existence (may remain sorry if complex)
- Full S5 modal logic support (only T4 required for TM logic)
- Removing all sorries (focus on domain conflation sorries, not dovetailing gaps)
- Implementing both dense paths (one is sufficient)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Successor seed consistency proof intractable | High | Medium | Axiomatize successor existence (weaker than Icc finiteness, more transparent) |
| Dense path F/P witnesses harder than expected | Medium | Medium | Use TimelineQuot path (architecturally cleaner) over CanonicalEmbedding |
| Cross-family modal coherence still fails at t=/=0 with Succ-chains | High | Low | Succ-chain determinism should resolve via F-step constraint |
| Task 27 dependency not ready | Medium | Low | Dense path can proceed independently; verify TimelineQuot exists |

## Implementation Phases

### Phase 1: Foundation - Temporal Content Extractors [COMPLETED]

**Goal**: Add f_content and p_content extractors as foundation for Succ relation

**Tasks**:
- [ ] Add `f_content` definition to `TemporalContent.lean`: `{phi | F phi in M}`
- [ ] Add `p_content` definition: `{phi | P phi in M}`
- [ ] Prove basic properties: `f_content` = `neg_g_content_neg`, `p_content` = `neg_h_content_neg`
- [ ] Prove duality with existing g_content/h_content
- [ ] Run `lake build Bimodal.Metalogic.Core.TemporalContent`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/TemporalContent.lean` - add f_content, p_content definitions and lemmas

**Verification**:
- `lake build` passes with no new sorries
- All 4 extractors documented in module docstring

---

### Phase 2: Succ Relation Definition [COMPLETED]

**Goal**: Define the immediate successor relation that enforces F-step progression

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- [ ] Define `Succ (u v : Set Formula) : Prop := g_content u subseteq v AND f_content u subseteq v union f_content v`
- [ ] Prove `Succ_implies_CanonicalR`: every Succ pair satisfies CanonicalR
- [ ] Prove g/h duality for Succ pairs (from existing duality theorems)
- [ ] Add module documentation explaining relationship to covering lemma bypass

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccRelation` passes
- `Succ_implies_CanonicalR` proven (not sorry)

---

### Phase 3: CanonicalTask Three-Place Relation [COMPLETED]

**Goal**: Define the three-place task relation that directly instantiates TaskFrame Int

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/CanonicalTask.lean`
- [ ] Define `CanonicalTask : Set Formula -> Int -> Set Formula -> Prop` inductively from Succ
- [ ] Prove nullity identity: `CanonicalTask u 0 v <-> u = v`
- [ ] Prove forward compositionality: chain concatenation for x, y >= 0
- [ ] Prove converse property: `CanonicalTask u d v <-> CanonicalTask v (-d) u`
- [ ] Prove single-step forcing theorem: `F phi in u AND FF phi notin u AND Succ u v -> phi in v`
- [ ] Prove bounded witness corollary
- [ ] Prove CanonicalR recovery: `CanonicalR u v <-> exists n >= 1, CanonicalTask u n v`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTask.lean` - new file

**Verification**:
- All three TaskFrame axioms proven (not sorry)
- Single-step forcing theorem proven
- `lake build` passes

---

### Phase 4: Successor Existence Theorem [COMPLETED]

**Goal**: Prove that Succ-successors exist under discrete axioms (the key construction)

**Tasks**:
- [ ] In `CanonicalTask.lean`, add successor existence theorem
- [ ] Define successor seed: `S = g_content u union { phi or F phi | F phi in u }`
- [ ] Prove seed consistency under DF + seriality axioms (or axiomatize if intractable)
- [ ] Prove `Succ_successor_exists`: `F T in u -> exists v, Succ u v`
- [ ] Prove predecessor existence symmetrically via DB axiom
- [ ] Document the covering lemma bypass in module docstring

**Timing**: 2.5 hours (highest risk phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTask.lean` - add existence theorems

**Verification**:
- If seed consistency proven: no new sorries
- If axiomatized: exactly one clearly documented axiom (weaker than discrete_Icc_finite_axiom)
- Covering lemma bypass documented

---

### Phase 5: Fix DirectMultiFamilyBFMCS with Succ-Chains [IN PROGRESS]

**Goal**: Replace arbitrary Lindenbaum chains with Succ-chains for cross-family modal coherence

**Tasks**:
- [ ] Import SuccRelation.lean and CanonicalTask.lean
- [ ] Replace `intFMCS_basic` with Succ-chain FMCS construction
- [ ] Define `succChainFMCS : CanonicalMCS -> FMCS Int` using CanonicalTask
- [ ] Fix `directFamilies_modal_forward` at t=/=0 using Succ determinism
- [ ] Fix `directFamilies_modal_backward` at t=/=0 using F-step constraint
- [ ] Update module documentation explaining the fix

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - refactor to use Succ-chains

**Verification**:
- 4 sorries in this file eliminated or reduced to seed consistency axiom
- `modal_forward` and `modal_backward` work for all t, not just t=0
- `lake build` passes

---

### Phase 6: Dense Completeness Path Assessment [NOT STARTED]

**Goal**: Choose and complete one viable path for dense completeness

**Tasks**:
- [ ] Audit `TimelineQuotBFMCS.lean` for integration with task 27 TimelineQuot
- [ ] Audit `CanonicalEmbedding.lean` for F/P witness sorries
- [ ] Choose path based on: fewer sorries, cleaner architecture, task 27 readiness
- [ ] If TimelineQuotBFMCS path: unify to use D = TimelineQuot throughout
- [ ] If CanonicalEmbedding path: complete F/P witness proofs via Cantor transfer
- [ ] Document chosen path rationale in module

**Timing**: 1.5 hours (assessment) + implementation deferred to follow-up if complex

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean` - OR
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`

**Verification**:
- Clear decision documented
- If implementation included: reduced sorries on chosen path
- Unchosen path documented as alternative

---

### Phase 7: Clean Up Dead-End Code [NOT STARTED]

**Goal**: Remove or deprecate MultiFamilyBFMCS.lean and update task 22 report

**Tasks**:
- [ ] Add deprecation notice to `MultiFamilyBFMCS.lean` header explaining W=D impossibility
- [ ] Comment out or remove the `modal_backward` sorry (provably impossible)
- [ ] Update `specs/022_direct_multi_family_bundle/reports/03_*.md` with W vs D clarification
- [ ] Add note: "CanonicalMCS as BFMCS modal domain W is correct; as temporal D is incorrect"
- [ ] Cross-reference task 28 completion in task 22 report

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - add deprecation
- `specs/022_direct_multi_family_bundle/reports/` - update relevant report

**Verification**:
- MultiFamilyBFMCS.lean marked as dead-end with explanation
- Task 22 report includes clarifying note
- No functional code removed (only documentation changes)

---

### Phase 8: Verification and Integration [NOT STARTED]

**Goal**: Full build, sorry audit, and documentation completion

**Tasks**:
- [ ] Run `lake build` on full codebase
- [ ] Grep for remaining sorries in modified files
- [ ] Compare sorry count before/after (target: net reduction of 4+)
- [ ] Update module docstrings with W/D distinction documentation
- [ ] Verify no regressions in dependent modules
- [ ] Create implementation summary

**Timing**: 0.5 hours

**Files to modify**:
- Multiple files (documentation updates only)

**Verification**:
- `lake build` passes with no new errors
- Sorry count reduced or held constant (no new sorries)
- All modified modules have accurate docstrings

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new sorries introduced (existing may be restructured)
- [ ] Succ relation correctly implies CanonicalR
- [ ] CanonicalTask satisfies all three TaskFrame axioms
- [ ] DirectMultiFamilyBFMCS sorries reduced from 4 to 0-1
- [ ] Task 22 report accurately distinguishes W from D

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/TemporalContent.lean` - extended with f_content, p_content
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - new file
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTask.lean` - new file
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - refactored
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - deprecated
- Task 22 report - updated with W/D clarification
- `specs/028_correct_bfmcs_domain_conflation/summaries/01_bfmcs-domain-correction-summary.md` - execution summary

## Rollback/Contingency

If Succ-based approach proves intractable:
1. Revert to `discrete_Icc_finite_axiom` as documented blocking axiom
2. Keep DirectMultiFamilyBFMCS with t=/=0 sorries documented
3. Focus on dense path completion as alternative progress
4. Document blocking issues for future research

All changes are additive (new files) or documentation (deprecation notices), so rollback is straightforward via git revert.
