# Implementation Plan: Close Remaining BXCanonical Sorries (v2)

- **Task**: 88 - Close remaining BXCanonical sorries
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None (all prerequisite axioms BX11/BX11'/BX12/BX12' already added)
- **Research Inputs**: reports/01_team-research.md, reports/02_team-research.md
- **Artifacts**: plans/02_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the 6 remaining BXCanonical sorries by replacing the blocked global-linearity approach (v1 Phase 2) with an interval-linearity strategy derived from BX7 + BX4 + BX12. The 4 Frame.lean eventuality resolution sorries require proving that BXPoints reachable from a common Until-bearing ancestor are comparable -- a weaker property than global totality that IS derivable from BX axioms. The CanonicalEmbedding.lean sorry (imp Case B) requires building non-constant WorldHistory to avoid the G/H collapse on constant histories. The Completeness.lean sorry requires constructing a concrete TaskModel from BXPoint chains. Definition of done: `lake build` succeeds with zero `sorry` in `Theories/Bimodal/Metalogic/BXCanonical/`.

### Research Integration

Round 2 research (4 teammates, unanimous) confirmed:
1. Global `bx_le_total` is FALSE -- two arbitrary MCSs can have incomparable g_content. This validates v1 finding.
2. Interval linearity IS the correct reformulation -- Frame.lean sorries need comparability only for BXPoints reachable from a common Until-bearing w, which follows from BX7 + BX12 + BX4.
3. Backward Until (Frame.lean:675) may be closable by direct contradiction + BX8 without needing interval linearity at all.
4. CanonicalEmbedding sorry requires new WorldHistory infrastructure (4-8 hours, not 2 as v1 estimated).
5. Completeness sorry requires concrete TaskModel construction (4-8 hours, not 1.5 as v1 estimated).
6. Guard propagation at intermediate points remains the single hardest proof obligation.

### Prior Plan Reference

Plan v1 completed Phase 1 (axiom restoration) and partially completed Phase 6 (downstream fixes). Phases 2-5 were blocked because Phase 2 assumed global bx_le totality, which is impossible. Key lessons: (a) effort estimates for CanonicalEmbedding and Completeness were 2-4x too low; (b) the X-vs-G mismatch (Until formulas not propagating through g_content) is the fundamental blocker; (c) BX axiom soundness proofs were straightforward when semantics align.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Close all 4 Frame.lean eventuality resolution sorries (lines 653, 675, 690, 704)
- Close the CanonicalEmbedding.lean imp Case B sorry (line 418)
- Close the Completeness.lean bx_completeness sorry (line 160)
- Achieve zero `sorry` in the BXCanonical module

**Non-Goals**:
- Closing ConservativeExtension/Lifting.lean sorries (12 sorry sites in a separate module; these require proving old axioms derivable from BX, which is a distinct task)
- Closing ConservativeExtension/Substitution.lean or ExtDerivation.lean Extsorry markers (these use the extended axiom system's sorry mechanism, not Lean sorry)
- Proving global bx_le totality (known impossible)
- Modifying the axiom system further

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard propagation at intermediate points fails (BX4 gives `P(phi U psi) in u` but backward witness may not be on interval) | H | M | Fall back to well-founded induction on interval structure; if blocked, try chain extraction approach (Teammate A) |
| Interval linearity from BX7 does not formalize cleanly (70% confidence per research) | H | M | 2-hour spike in Phase 1; if blocked after spike, pivot to backward-Until-first approach (BX8 contradiction) which avoids interval linearity |
| WorldHistory infrastructure is more complex than estimated | M | M | Bound Phase 4 at 6 hours; if exceeded, simplify by using two-point histories only |
| TaskModel construction requires Until/Since chain infrastructure not yet built | H | L | Phase 5 depends on Phase 3 completion; reuse eventuality resolution witnesses directly |
| `bx_until_backward` contradiction argument has a gap (BX4 variant not matching) | M | L | Verify exact BX4 statement (`connect_future`) before starting Phase 2; adjust proof strategy if needed |

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

### Phase 1: Prove Interval Linearity Lemma [NOT STARTED]

**Goal**: Establish the key intermediate lemma that BXPoints reachable from a common Until-bearing ancestor are bx_le-comparable. This replaces the impossible global totality with a usable local property.

**Tasks**:
- [ ] State and prove `bx_interval_linearity`: given `phi U psi in w`, for any `u, v` with `bx_le w u` and `bx_le w v`, either `bx_le u v` or `bx_le v u`
- [ ] The proof path: from `phi U psi in w` derive `F(psi) in w` (BX10), then `top U psi in w` (BX12/F_until_equiv). Apply BX5 (self_accum_until) to get `(phi /\ (phi U psi)) U psi in w`. Use BX7 (linear_until) on these two Until formulas at w to get witness ordering. Bridge witness ordering to bx_le ordering via BX4 (connect_future) propagation.
- [ ] If the BX7-to-bx_le bridge is blocked (the g_content vs Until-witness mismatch), document the gap and assess whether backward Until (Phase 2) can proceed independently

**Timing**: 4 hours (includes 2-hour spike to assess feasibility)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - Add `bx_interval_linearity` lemma in the section before eventuality resolution

**Verification**:
- `lake build` succeeds
- New lemma type-checks without sorry
- If blocked: documented gap with clear description of what is missing

---

### Phase 2: Close Backward Until/Since Sorries (Frame.lean:675, 704) [NOT STARTED]

**Goal**: Close the two backward direction sorries using direct contradiction + BX8, which may not require interval linearity.

**Tasks**:
- [ ] Close `bx_until_backward` (line 675): Assume `neg(phi U psi) in w`. By BX4 (`connect_future`): `G(P(neg(phi U psi))) in w`. Since `bx_le w v`: `P(neg(phi U psi)) in v`. From `psi in v` and BX8 (`refl_intro_until`): `phi U psi in v`. From `P(neg(phi U psi)) in v`: exists `u le v` with `neg(phi U psi) in u`. Need `bx_le w u` to use the guard hypothesis -- this is where interval linearity (Phase 1) may be needed, OR the contradiction can be completed if we can show `phi U psi in u` via the guard.
- [ ] Close `bx_since_backward` (line 704): Mirror of backward Until using BX4' (`connect_past`), BX8' (`refl_intro_since`), and past-direction arguments
- [ ] If interval linearity (Phase 1) is blocked: attempt alternative proof using BX4 + BX9 directly without comparability, or mark these as dependent on Phase 1

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - Replace sorry at lines 675 and 704

**Verification**:
- `lake build` succeeds
- `bx_until_backward` and `bx_since_backward` type-check without sorry

---

### Phase 3: Close Forward Until/Since Sorries (Frame.lean:653, 690) [NOT STARTED]

**Goal**: Close the two forward eventuality resolution sorries using interval linearity + guard propagation.

**Tasks**:
- [ ] Close `bx_until_eventuality_resolution` (line 653): From `phi U psi in w` and `psi notin w`, use BX9 to get `phi in w`. Use BX10 to get `F(psi) in w`, then `bx_forward_witness` for `v ge w` with `psi in v`. For intermediate `u in [w, v)`: use interval linearity (Phase 1) to establish `bx_le w u` and `bx_le u v`. Then use BX4 to get `P(phi U psi) in u`, yielding a backward witness `u'` with `phi U psi in u'`. The critical step is showing `phi in u` -- either from `phi U psi in u` via BX9, or from the guard propagation chain.
- [ ] If guard propagation is blocked: try well-founded induction on the interval, using BX5 (self-accumulation) to push `phi U psi` forward one step at a time
- [ ] Close `bx_since_eventuality_resolution` (line 690): Mirror using h_content, BX5', BX9', BX10', and past-direction interval linearity
- [ ] Update Frame.lean module docstring (lines 585-622) to reflect the resolved proof strategy

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - Replace sorry at lines 653 and 690; update module docstring

**Verification**:
- `lake build` succeeds
- All 4 Frame.lean sorry sites closed
- `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` type-check without sorry

---

### Phase 4: Close CanonicalEmbedding Sorry (line 418) [NOT STARTED]

**Goal**: Close the `usf_completeness` imp Case B sorry by building non-constant WorldHistory that correctly evaluates G/H formulas.

**Tasks**:
- [ ] Build a two-point WorldHistory construction: given BXPoint `w`, use `bx_forward_witness` to get `v ge w`, and construct a WorldHistory that visits both `w` and `v` (avoiding the constant-history collapse where `G(alpha)` reduces to `alpha`)
- [ ] Prove the truth bridge: `chi in w.formulas iff truth_at chi` on the two-point history, using `G_iff_mcs`/`H_iff_mcs` from TruthLemma.lean for G/H cases
- [ ] Handle the inductive structure: chi may contain nested G/H inside imp, requiring the truth bridge to work for arbitrary until/since-free subformulas
- [ ] Close the sorry at line 418 using the non-constant history + truth bridge to derive a contradiction between `psi in w` and `chi notin w`

**Timing**: 4 hours

**Depends on**: 2, 3 (needs eventuality resolution for chain structure, though the until/since-free fragment may be self-contained)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` - Replace sorry at line 418; add WorldHistory construction helpers

**Verification**:
- `lake build` succeeds
- `usf_completeness` type-checks without sorry
- The truth bridge handles all until/since-free formula constructors (atom, bot, imp, box, all_future, all_past)

---

### Phase 5: Close Completeness Sorry (line 160) [NOT STARTED]

**Goal**: Close the `bx_completeness` sorry by constructing a concrete TaskModel from BXPoint chains and proving formula falsification.

**Tasks**:
- [ ] Construct a TaskModel value from the MCS `w0` (with `neg phi in w0`): build TaskFrame using BXPoint chains from eventuality resolution, assign WorldHistory objects using Phase 4 infrastructure
- [ ] Prove the truth lemma: `phi in w0.formulas iff truth_at phi` at the corresponding point in the TaskModel, handling all formula cases including Until/Since via Phase 3 results
- [ ] Close the sorry at line 160: from `valid phi` and the canonical model, derive `phi` true at `w0`, contradicting `neg phi in w0`
- [ ] Verify that the proof handles the temporal cases (G, H, Until, Since) by delegating to the eventuality resolution and truth lemma infrastructure

**Timing**: 2 hours (reduced from v1 estimate because Phase 3-4 build the hard infrastructure)

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Replace sorry at line 160; add TaskModel construction

**Verification**:
- `lake build` succeeds
- `bx_completeness` and `bx_completeness'` type-check without sorry
- Zero `sorry` in the entire BXCanonical module (verify with `grep -r sorry Theories/Bimodal/Metalogic/BXCanonical/`)

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` returns zero Lean sorry instances (documentation mentions of "sorry" in comments are acceptable)
- [ ] All 6 previously sorry'd definitions type-check: `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`, `usf_completeness`, `bx_completeness`
- [ ] No new axioms added beyond BX1-BX12 and their primed variants
- [ ] Existing tests pass (`lake build` covers this)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - 4 sorries closed, interval linearity lemma added
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` - 1 sorry closed, WorldHistory infrastructure added
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - 1 sorry closed, TaskModel construction added
- `specs/088_close_remaining_bxcanonical_sorries/plans/02_implementation-plan.md` - This plan

## Rollback/Contingency

**Phase-level rollback**: Each phase modifies a single file. If a phase introduces errors, revert that file with `git checkout -- <file>`.

**Strategy-level fallback**: If interval linearity (Phase 1) proves impossible to formalize after the 4-hour spike:
1. Try backward-Until-first approach (Phase 2 may work independently via direct contradiction)
2. If all Frame.lean approaches fail, consider chain extraction architecture (Teammate A's proposal, estimated 21-39 additional hours) as a separate task
3. The CanonicalEmbedding sorry (Phase 4) is independent of Frame.lean and can proceed regardless

**Partial completion is acceptable**: Closing even 1-2 of the 6 sorries represents meaningful progress. Mark remaining sorries with updated status in docstrings.
