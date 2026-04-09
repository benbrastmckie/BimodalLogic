# Implementation Plan: Close Remaining BXCanonical Sorries (v3)

- **Task**: 88 - Close remaining BXCanonical sorries
- **Status**: [NOT STARTED]
- **Effort**: 24-38 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md, reports/02_team-research.md, reports/03_team-research.md
- **Artifacts**: plans/03_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the 6 remaining BXCanonical sorries across 3 distinct problems: (A) forward eventuality resolution (Frame.lean:653, 690), (B) backward eventuality construction (Frame.lean:675, 704), and (C) CanonicalEmbedding imp Case B (CanonicalEmbedding.lean:418), plus the downstream Completeness.lean:160. Round 3 research (4 teammates) demolished the v2 plan's core assumptions: interval linearity is NOT derivable from BX7+BX12 (BX7 constrains Until-witness ordering, not arbitrary bx_le-successors), backward Until is NOT simpler (same linearity gap), and CanonicalEmbedding:418 is NOT on the critical path for `bx_completeness` (it serves `usf_completeness` independently). The fundamental blocker is the X-vs-G mismatch: `phi U psi in w` does not give `G(phi U psi) in w`, so Until formulas do not propagate through the g_content-based `bx_le` ordering. This plan addresses the mismatch through an architecture spike (redefine `bx_le` via Until-witness chains) with go/no-go gates at Phases 2 and 3. Definition of done: `lake build` succeeds with zero `sorry` in `Theories/Bimodal/Metalogic/BXCanonical/`.

### Research Integration

**Round 3 findings integrated** (4 teammates, all high confidence):

1. **Interval linearity claim invalidated** (Teammate C, 80%): BX7 constrains Until-witness ordering, not arbitrary bx_le-successor ordering. Two BXPoints that are not Until-witnesses for any formula need not be comparable. The v2 Phase 1 approach is not viable.

2. **Backward Until "simpler" claim invalidated** (Teammate C, 90%): The backward witness u from `bx_backward_witness` satisfies u <= v, not w <= u. The guard hypothesis requires w <= u to be applicable. Same linearity gap as forward direction.

3. **CanonicalEmbedding independence confirmed** (Teammate C, 95%): Completeness.lean imports TruthLemma, not CanonicalEmbedding. CanonicalEmbedding:418 is for `usf_completeness` (fragment), not `bx_completeness` (main theorem). These are independent paths.

4. **FMP bridge not viable** (Teammates B, C, D consensus): TruthPreservation.lean temporal cases are archived to Boneyard. Both BXCanonical and FMP fail at the same truth lemma step.

5. **BX11/BX12 unused in BXCanonical** (grep confirmed): They helped DovetailedChain/LinearityDerivedFacts but not the 6 sorry sites.

6. **3 distinct problems, not 6**: Forward eventuality (HARD), backward eventuality (HARD, same gap), CanonicalEmbedding (INDEPENDENT, 4-6h), Completeness (DOWNSTREAM).

7. **Architecture alternatives identified**: (A) Redefine bx_le via Until-witness chains, (B) Quasimodel approach, (C) Two-indexed canonical model.

**Reports integrated across plan versions**:
- `reports/01_team-research.md` — integrated in plan v1 (initial findings)
- `reports/02_team-research.md` — integrated in plan v2 (interval linearity hypothesis)
- `reports/03_team-research.md` — integrated in plan v3 (this plan; interval linearity demolished, architecture alternatives)

### Prior Plan Reference

Plan v1 completed Phase 1 (axiom restoration) and partially completed Phase 6 (downstream fixes). Plan v2 was entirely [NOT STARTED] and assumed interval linearity from BX7+BX12, which round 3 research invalidated. Key accumulated lessons across 5 rounds (tasks 83-88): (a) X-vs-G mismatch is fundamental and confirmed by every investigation; (b) no existing BX axiom bridges Until-membership to G-membership; (c) the problem is architectural (bx_le definition), not proof-engineering.

### Roadmap Alignment

Closing all 6 sorries yields `bx_completeness`: the first verified formalization of Until/Since temporal logic completeness in Lean 4. Closing CanonicalEmbedding:418 alone yields `usf_completeness`: first S5+G/H completeness in Lean 4.

## Goals & Non-Goals

**Goals**:
- Close CanonicalEmbedding.lean:418 sorry for `usf_completeness` (independent, immediate value)
- Research and prototype an alternative `bx_le` definition using Until-witness chains
- If architecture spike succeeds: close all 4 Frame.lean sorries and Completeness.lean:160
- Achieve zero `sorry` in the BXCanonical module

**Non-Goals**:
- Closing ConservativeExtension sorries (separate module, distinct task)
- Proving global bx_le totality (known impossible, confirmed 5 times)
- Modifying the axiom system (BX1-BX12 are fixed)
- Closing TruthPreservation.lean temporal cases (archived to Boneyard, separate path)
- Pursuing FMP bridge (fails at the same truth lemma step)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Until-witness chain bx_le definition breaks G/H truth lemma | H | M | Phase 2 spike explicitly prototypes G/H truth lemma before committing; go/no-go gate |
| Until-witness chain ordering is not well-founded or antisymmetric | H | M | Phase 2 checks order-theoretic properties first; fall back to quasimodel if partial order fails |
| CanonicalEmbedding WorldHistory infrastructure is more complex than 4-6h estimate | M | L | Bound Phase 1 at 6 hours; use two-point histories only if needed |
| New bx_le definition requires rewriting large portions of Frame.lean | H | M | Phase 3 assesses blast radius before committing; preserve old definitions behind option |
| Architecture change proves mathematically impossible | H | L | Phase 2 go/no-go gate; if NO-GO, document as open problem requiring novel mathematical technique |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel. Phases 1 and 2 are fully independent.

---

### Phase 1: Close CanonicalEmbedding:418 (usf_completeness) [NOT STARTED]

**Goal**: Close the `usf_completeness` imp Case B sorry independently, yielding the first S5+G/H completeness in Lean 4.

**Tasks**:
- [ ] Analyze the exact proof obligation at CanonicalEmbedding.lean:418: need to derive `chi in w.formulas` from `psi in w.formulas` where `phi = imp chi psi` and `chi` is not valid, for Until/Since-free `chi` that may contain G or H
- [ ] Build a non-constant WorldHistory construction: given BXPoint `w`, use `bx_forward_witness` to get `v >= w` (or `bx_backward_witness` for `u <= w`), construct a 2-point WorldHistory visiting both `w` and `v`
- [ ] Prove the truth bridge for USF formulas: `chi in w.formulas iff truth_at chi` on the 2-point history, using `G_iff_mcs`/`H_iff_mcs` from TruthLemma.lean for G/H cases
- [ ] Handle nested G/H inside imp: the truth bridge must work for all USF subformulas (atom, bot, imp, box, all_future, all_past)
- [ ] Close the sorry at line 418 using the non-constant history to derive a contradiction
- [ ] Verify `usf_completeness` type-checks sorry-free

**Timing**: 4-6 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` — Replace sorry at line 418; add WorldHistory construction helpers

**Verification**:
- `lake build` succeeds
- `usf_completeness` type-checks without sorry
- Truth bridge handles all USF formula constructors

---

### Phase 2: Architecture Spike — Until-Witness Chain bx_le (GO/NO-GO GATE) [NOT STARTED]

**Goal**: Research and prototype an alternative `bx_le` definition using Until-witness chains instead of g_content inclusion. Produce a go/no-go decision for the architectural change.

**Tasks**:
- [ ] **Study the current bx_le definition**: `bx_le w v := g_content w.formulas ⊆ v.formulas` (Frame.lean:61). Catalog all lemmas that depend on this definition (transitivity, reflexivity, box preservation, modal equivalence, forward/backward witness construction)
- [ ] **Design alternative ordering**: Define `bx_le_new w v` via existence of an Until-witness chain from `w` to `v` — i.e., a sequence `w = w0, w1, ..., wn = v` where each `wi+1` is a forward witness for some `phi U psi in wi`. This makes linearity on Until-intervals hold by construction.
- [ ] **Check order-theoretic properties**: (a) reflexivity (empty chain), (b) transitivity (chain concatenation), (c) antisymmetry or at least partial order (critical: does `bx_le_new w v` and `bx_le_new v w` imply `w = v`?), (d) relationship to old bx_le (does `bx_le_new w v` imply `bx_le w v`?)
- [ ] **Prototype G/H truth lemma**: The most critical test. Under the new ordering, does `G(phi) in w ↔ forall v, bx_le_new w v -> phi in v.formulas` still hold? The forward direction (G(phi) in w -> phi in v for Until-chain successors) should follow from BX6 (G distributes over Until) or BX4 (connectedness). The backward direction needs: if phi in every Until-chain successor, then G(phi) in w.
- [ ] **Assess blast radius**: How many existing lemmas (box_preserved_along_bx_le, bx_modal_equiv_of_bx_le, bx_forward_witness, bx_backward_witness, etc.) need modification under the new definition?
- [ ] **GO/NO-GO decision**: If (i) order-theoretic properties hold, (ii) G/H truth lemma is provable under new ordering, and (iii) blast radius is manageable (< 20 lemma modifications): GO. Otherwise: NO-GO with documented reasons.

**Timing**: 4 hours (hard cap: do not exceed)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — Prototype new definitions (may be in a separate section or scratch file)

**Verification**:
- Written go/no-go assessment with clear criteria
- If GO: prototype definitions that type-check (sorries in proofs acceptable at this stage)
- If NO-GO: documented reasons with specific failure points

**GO/NO-GO Gate**: If NO-GO, skip Phases 3-5. Update plan status to [PARTIAL] with CanonicalEmbedding closed (Phase 1) and Frame.lean sorries documented as requiring novel mathematical technique. Consider alternative (B) quasimodel or (C) two-indexed model as future tasks.

---

### Phase 3: Implement New bx_le and Reprove Infrastructure (GO/NO-GO GATE) [NOT STARTED]

**Goal**: Replace the g_content-based `bx_le` with the Until-witness chain ordering and reprove all dependent lemmas, including the G/H truth lemma.

**Tasks**:
- [ ] Replace `bx_le` definition in Frame.lean with the Until-witness chain variant from Phase 2
- [ ] Reprove `bx_le_refl`, `bx_le_trans`, and any antisymmetry/partial-order lemmas
- [ ] Reprove `box_preserved_along_bx_le`: show that `Box(phi) in w` and `bx_le_new w v` implies `phi in v.formulas` — this should follow from modal equivalence along each chain step
- [ ] Reprove `bx_modal_equiv_of_bx_le`: show modal equivalence is preserved along Until-witness chains
- [ ] Reprove or adapt `bx_forward_witness` and `bx_backward_witness` to produce witnesses that are single Until-chain steps
- [ ] Prove `G_iff_mcs` and `H_iff_mcs` under the new ordering in TruthLemma.lean — this is the critical step
- [ ] Verify `lake build` succeeds (possibly with the 4 Frame.lean sorries still present)

**Timing**: 6-10 hours

**Depends on**: Phase 2 (GO decision)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — New bx_le definition and infrastructure
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` — Adapt G/H truth lemma

**Verification**:
- `lake build` succeeds
- All infrastructure lemmas type-check without sorry
- G/H truth lemma (`G_iff_mcs`, `H_iff_mcs`) type-checks without sorry

**GO/NO-GO Gate**: If G/H truth lemma cannot be proved under the new ordering after 10 hours, stop. The new ordering makes Until-propagation easy but may make G/H harder. Document which direction fails and why. If NO-GO here, Phases 4-5 are skipped.

---

### Phase 4: Close 4 Frame.lean Eventuality Resolution Sorries [NOT STARTED]

**Goal**: Close all 4 Frame.lean sorries using the new Until-witness chain ordering, which provides linearity on Until-intervals by construction.

**Tasks**:
- [ ] Close `bx_until_eventuality_resolution` (line 653): With the new ordering, `bx_le w u` means there is an Until-witness chain from w to u. For phi U psi in w with psi not in w: use BX9 to get phi in w, use BX10 + bx_forward_witness for v >= w with psi in v. For intermediate u on [w,v): the Until-witness chain structure gives linearity, so the guard phi can be propagated via Until-persistence along chain steps
- [ ] Close `bx_until_backward` (line 675): Backward direction. With linearity available from the new ordering, the contradiction approach works: assume neg(phi U psi) in w, propagate forward via BX4, derive contradiction with guard at intermediate points
- [ ] Close `bx_since_eventuality_resolution` (line 690): Mirror of forward Until using h_content, BX5', BX9', BX10', and past-direction chain ordering
- [ ] Close `bx_since_backward` (line 704): Mirror of backward Until using BX8', BX4', and past-direction argument
- [ ] Update Frame.lean module docstring (lines 585-622) to reflect the resolved proof strategy

**Timing**: 4-8 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — Replace sorry at lines 653, 675, 690, 704; update module docstring

**Verification**:
- `lake build` succeeds
- All 4 Frame.lean sorry sites closed
- `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward` all type-check without sorry

---

### Phase 5: Close Completeness.lean:160 (Downstream) [NOT STARTED]

**Goal**: Close the `bx_completeness` sorry, which becomes closable once the Frame.lean sorries and TruthLemma infrastructure are sorry-free.

**Tasks**:
- [ ] Construct a TaskModel from MCS w0 (with neg phi in w0): build TaskFrame using BXPoint chains from eventuality resolution (Phase 4), assign WorldHistory objects
- [ ] Connect the truth lemma: `phi in w0.formulas iff truth_at phi` at the corresponding point in the TaskModel, handling all formula cases including Until/Since via the eventuality resolution infrastructure
- [ ] Close the sorry at line 160: from `valid phi` and the canonical model, derive `phi` true at w0, contradicting `neg phi in w0`
- [ ] Verify that `bx_completeness'` (alternate form, line 165) also type-checks

**Timing**: 2-4 hours

**Depends on**: Phase 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — Replace sorry at line 160; add TaskModel construction

**Verification**:
- `lake build` succeeds
- `bx_completeness` and `bx_completeness'` type-check without sorry
- Zero `sorry` in the entire BXCanonical module: `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` returns only documentation mentions

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` returns zero Lean sorry instances (documentation mentions in comments acceptable)
- [ ] All 6 previously sorry'd definitions type-check: `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`, `usf_completeness`, `bx_completeness`
- [ ] No new axioms added beyond BX1-BX12 and their primed variants
- [ ] New bx_le definition preserves all existing sorry-free results (soundness, fragment_completeness, etc.)
- [ ] Existing tests pass (`lake build` covers this)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` — 1 sorry closed, WorldHistory infrastructure added
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — New bx_le definition, 4 sorries closed, module docstring updated
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` — G/H truth lemma adapted to new ordering
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — 1 sorry closed, TaskModel construction added
- `specs/088_close_remaining_bxcanonical_sorries/plans/03_implementation-plan.md` — This plan

## Rollback/Contingency

**Phase-level rollback**: Each phase modifies specific files. If a phase introduces errors, revert with `git checkout -- <file>`.

**Go/no-go gates**:
- **Phase 2 NO-GO**: Architecture spike fails. Accept Phase 1 result (usf_completeness closed). Document Frame.lean sorries as open problems. Consider spawning new tasks for alternative approaches (quasimodel, two-indexed model).
- **Phase 3 NO-GO**: G/H truth lemma fails under new ordering. Revert Frame.lean changes. Same outcome as Phase 2 NO-GO but with more specific failure documentation.

**Partial completion is acceptable and valuable**:
| Phases Completed | Result |
|-----------------|--------|
| Phase 1 only | `usf_completeness` sorry-free (first S5+G/H completeness in Lean 4) |
| Phases 1-3 | Infrastructure rebuilt, G/H truth lemma reproved |
| Phases 1-4 | All Frame.lean sorries closed, TruthLemma fully sorry-free |
| Phases 1-5 | Full `bx_completeness` sorry-free (first TM bimodal completeness in Lean 4) |

**Alternative approaches for future tasks** (if Phases 2-5 are NO-GO):
- (B) Quasimodel approach: bypass canonical model entirely, build finite quasimodel
- (C) Two-indexed canonical model: separate orderings for temporal and modal dimensions
- (D) Accept as open problem: document X-vs-G mismatch as fundamental limitation of g_content-based canonical models
