# Implementation Plan: Establish until_since_coherent

- **Task**: 84 - Establish Until/Since Coherence for Bundle Completeness
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None (task 83 closed the truth lemma sorries that added h_uc as hypothesis)
- **Research Inputs**: reports/01_research-synthesis.md, reports/02_team-research.md
- **Artifacts**: plans/02_until-since-coherent.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Three sorry sites in `FrameConditions/Completeness.lean` (lines 322, 356, 450) require proving that BFMCS families satisfy `until_since_coherent` -- that Until/Since membership in MCS families corresponds exactly to the existence of witnesses with correct guard intervals. The definition has four conjuncts: forward Until, backward Until, forward Since, backward Since. Research identified the enriched-seed approach (Approach D) as most viable: include active Until formulas directly in the Lindenbaum seed, exploiting the fact that `g_content(w) ∪ {active Untils in w}` is consistent because all elements are in `w` (an MCS). Forward directions have 85% confidence; backward directions have 55% confidence and represent the critical risk.

### Research Integration

- **01_research-synthesis.md**: Identified X-vs-G mismatch as the root cause of prior failures. Recommended Approach D (hybrid enriched seed) with g_content + active Untils.
- **02_team-research.md**: Confirmed forward direction viability. Identified backward Until as the single hardest sub-problem. Discovered `g_content(u) ⊆ u` under BX1 (simplifies consistency). Found DeterministicFMCS backward proof blocked only on `until_intro`/`since_intro` derivability.

## Goals & Non-Goals

**Goals**:
- Prove `g_content_subset_mcs` under BX1 (de-risk and close stale sorries)
- Establish forward Until and forward Since for enriched chains
- Establish backward Until and backward Since (via `until_intro`/`since_intro` derivation or contradiction argument)
- Close the three sorry sites at lines 322, 356, 450 of Completeness.lean

**Non-Goals**:
- `dense_completeness_fc` (task 68 -- Int is not dense)
- FMP TruthPreservation (task 82)
- BXCanonical Frame.lean sorries (proven impossible)
- `bfmcs_from_mcs_temporally_coherent` sorry at line 239 (may benefit but not primary target)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `until_intro` not derivable from BX axioms | H | M | Fallback to BX4+BX8 contradiction argument with Int linearity; last resort: split definition into forward-only |
| Enriched seed with dovetailed target inconsistent | H | L | `g_content(w) ∪ {active Untils}` all in w, so consistency follows from MCS. If joint with dovetailed target fails, restrict dovetailing to Until targets only |
| Backward Until requires `temporally_coherent` (circular for line 322) | M | M | Focus on lines 356/450 which have sorry-free TC; line 322 may need separate treatment or unified enriched chain |
| Until persistence through intermediate chain steps fails | M | M | Self-accumulation BX5 ensures `(phi U psi) -> ((phi /\ (phi U psi)) U psi)`, keeping Until active. Enriched seed explicitly includes active Untils |
| Since direction is not symmetric to Until | L | L | Since uses h_content instead of g_content with symmetric axioms BX8'/BX9'; architecture mirrors Until |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Foundation -- g_content_subset_mcs and Enriched Seed Consistency [NOT STARTED]

**Goal**: Prove `g_content(u) ⊆ u` for any MCS u under BX1, and verify that the enriched seed `g_content(w) ∪ {active Until formulas in w}` is consistent.

**Tasks**:
- [ ] Prove `g_content_subset_mcs`: for MCS u, `alpha ∈ g_content(u)` implies `G(alpha) ∈ u`, and by BX1 (`G(phi) -> phi`) + MCS derivation closure, `alpha ∈ u`
- [ ] Close stale `g_content_subset` sorries in SuccExistence.lean (~line 476) and SuccChainFMCS.lean (~line 1226), currently marked "KNOWN FALSE under strict semantics" but provable under BX1
- [ ] Prove enriched seed consistency: `g_content(w) ∪ S` is consistent whenever `S ⊆ w` and w is MCS (since `g_content(w) ⊆ w` by the above, the union is a subset of w, hence consistent)
- [ ] Prove symmetric `h_content_subset_mcs` for Since direction using BX1' (reflexive H)

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- close g_content_subset sorry
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- close g_content_subset sorry
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- new enriched seed lemmas (or new file)

**Verification**:
- `lake build` succeeds with g_content_subset sorry sites closed
- New lemmas type-check with no sorry

---

### Phase 2: Forward Until and Forward Since via Enriched Chain [NOT STARTED]

**Goal**: Prove the forward directions -- that `(phi U psi) ∈ fam.mcs t` implies existence of witness s >= t with psi at s and phi on guard interval [t,s), and symmetrically for Since.

**Tasks**:
- [ ] Define `enriched_until_seed(w, t)` = `g_content(w) ∪ {phi U psi : (phi U psi) ∈ w ∧ psi ∉ w}` with consistency proof (from Phase 1)
- [ ] Prove Until persistence: if `(phi U psi) ∈ chain(n)` and `psi ∉ chain(n)`, then `(phi U psi) ∈ chain(n+1)` when using enriched seed (by seed inclusion + Lindenbaum preservation)
- [ ] Prove guard extraction: for intermediate r in [t,s) where `(phi U psi) ∈ chain(r)` and `psi ∉ chain(r)`, BX9 gives `phi ∨ psi`, so `phi ∈ chain(r)`
- [ ] Prove witness resolution via dovetailed scheduling: since the subformula closure is finite, round-robin over Until targets ensures eventual resolution (each psi is eventually placed in seed, Lindenbaum preserves it)
- [ ] Mirror all results for forward Since using h_content and BX8'/BX9'
- [ ] Prove `forward_until` and `forward_since` for the dovetailed chain construction

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- enriched chain construction (or new UntilCoherence module)
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- enriched seed definitions
- New file `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (if separating concerns)

**Verification**:
- Forward Until and forward Since lemmas compile sorry-free
- Type signatures match the first and third conjuncts of `until_since_coherent`

---

### Phase 3: Backward Until and Backward Since [NOT STARTED]

**Goal**: Prove the backward directions -- that existence of a witness implies `(phi U psi) ∈ fam.mcs t` (and symmetrically for Since). This is the critical risk phase.

**Tasks**:
- [ ] **Primary approach**: Derive `until_intro` from BX axioms. The required form is `X(psi ∨ (phi ∧ (phi U psi))) → (phi U psi)`. Investigate whether BX8 (`psi -> phi U psi`) + BX5 (self-accumulation) + BX9 (elimination) + BX10 (eventuality) combine to derive this. Check Soundness.lean for `until_intro_valid` to confirm semantic validity.
- [ ] If `until_intro` is derivable: adapt the DeterministicFMCS backward_until_chain proof pattern (lines 340-395) which already works modulo until_intro, using induction on `(s - t).toNat`
- [ ] **Fallback approach**: Prove backward Until by contradiction using BX4 + BX8 + Int linearity. From `¬(phi U psi) ∈ fam.mcs t` derive contradiction with the guard/witness hypothesis using connectedness axioms.
- [ ] **Last resort**: If backward direction cannot be closed, split `until_since_coherent` into forward-only (`until_since_forward_coherent`) and backward (`until_since_backward_coherent`), restructure truth lemma to accept them separately, and close forward-only for now.
- [ ] Mirror backward Until proof for backward Since using `since_intro` / symmetric axioms
- [ ] Prove `backward_until` and `backward_since` for the chain construction

**Timing**: 6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- derive until_intro/since_intro from BX if possible
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` or DovetailedChain.lean -- backward proofs
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` -- close until_intro/since_intro sorries if derivable

**Verification**:
- Backward Until and backward Since lemmas compile sorry-free (or with isolated fallback sorry if last resort taken)
- If until_intro derivable: DeterministicFMCS sorries at lines 371, 395, 427, 451 also close

---

### Phase 4: Assemble until_since_coherent for All Three Chain Types [NOT STARTED]

**Goal**: Wire forward and backward results into complete `until_since_coherent` proofs for the three bundle constructions used at the sorry sites.

**Tasks**:
- [ ] Prove `dovetailed_bfmcs_until_since_coherent`: for `construct_dovetailed_bfmcs_bundle`, combine forward Until, backward Until, forward Since, backward Since into the 4-conjunct property for all families
- [ ] Prove `bfmcs_restricted_until_since_coherent`: for `construct_bfmcs_bundle` with restricted coherence (line 356 uses same bundle as 322 but with restricted TC)
- [ ] Prove `bfmcs_until_since_coherent`: for `construct_bfmcs_bundle` unrestricted (line 322, also needs TC sorry at line 239 -- may leave this one if TC is still sorry)
- [ ] Handle family iteration: `until_since_coherent` quantifies over all families in the BFMCS. Show that each family (shifted SuccChainFMCS or dovetailed chain) satisfies the property via the per-family proofs
- [ ] Verify that the proof terms have correct types matching the sorry sites

**Timing**: 3 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- replace sorry at lines 322, 356, 450 with proof terms
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- add until_since_coherent theorems near the definition
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- dovetailed-specific coherence proof

**Verification**:
- All three sorry sites replaced with proof terms
- `lake build` succeeds for Completeness.lean

---

### Phase 5: Integration Testing and Cleanup [NOT STARTED]

**Goal**: Verify the full completeness pipeline builds sorry-free (modulo known-open sorries), clean up temporary artifacts, and document the approach.

**Tasks**:
- [ ] Run `lake build` on the full project to verify no regressions
- [ ] Count remaining sorries in Completeness.lean -- should be reduced from 5 to 2 (TC at line 239 + dense_completeness)
- [ ] If backward directions used "last resort" split, document the forward-only status and what remains
- [ ] Update module-level documentation in Completeness.lean to reflect closed sorries
- [ ] Remove any deprecated helper lemmas or unused intermediate constructions

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- update documentation
- Any files with temporary scaffolding

**Verification**:
- `lake build` succeeds with no new sorries introduced
- Sorry count in Completeness.lean decreased by 3 (lines 322, 356, 450 closed)

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `g_content_subset_mcs` compiles sorry-free (Phase 1)
- [ ] Forward Until/Since close without sorry (Phase 2)
- [ ] Backward Until/Since close without sorry OR documented with fallback plan (Phase 3)
- [ ] All three sorry sites (lines 322, 356, 450) replaced with proof terms (Phase 4)
- [ ] No new sorries introduced anywhere in the codebase (Phase 5)
- [ ] Grep for `sorry` in Completeness.lean shows only pre-existing sorries (line 136, 239)

## Artifacts & Outputs

- `plans/02_until-since-coherent.md` (this file)
- Modified Lean source files (listed per phase)
- `summaries/02_until-since-coherent-summary.md` (after implementation)

## Rollback/Contingency

- All changes are additive (new lemmas and proof terms replacing sorry). If a phase fails, prior sorry can be restored.
- If backward Until/Since cannot be derived, the fallback is to split the definition and close forward-only, leaving backward as a new isolated sorry with clear documentation.
- Git commits per phase enable per-phase rollback via `git revert`.
- If the enriched seed approach fails entirely, the sorry sites remain isolated and do not block other development.
