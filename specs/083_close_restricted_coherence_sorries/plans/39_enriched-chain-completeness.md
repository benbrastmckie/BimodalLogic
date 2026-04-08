# Implementation Plan: Enriched Chain Construction for Bundle Completeness

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None
- **Research Inputs**: reports/39_team-research.md (3-teammate synthesis on Bundle vs BXCanonical path analysis)
- **Artifacts**: plans/39_enriched-chain-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build an enriched-Succ chain construction with dovetailed scheduling to resolve Until/Since eventuality obligations within the existing Bundle architecture. The team research (report 39) conclusively showed that Path A (fix Bundle) is the only viable approach -- Path B (BXCanonical port) is mathematically impossible due to the universal BXPoint quantifier. The enriched chain places Until/F-formula targets directly into the Lindenbaum seed at each step using round-robin scheduling over the finite deferral closure, resolving `forward_F` and enabling the Until/Since truth lemma cases in `CanonicalConstruction.lean`. This supersedes plan v34, which targeted BXCanonical (now proven unfillable).

### Research Integration

Key findings from reports/39_team-research.md:

1. **FMCS families already ARE Burgess's chain construction** -- no type changes needed to FMCSDef.lean or BFMCS.lean
2. **Enriched seed consistency already proven** -- `targeted_g_content_seed_consistent` (SuccChainFMCS.lean:2040) provides the core ingredient
3. **Backward Until via BX6 contradiction** -- derive `neg(phi U psi) -> neg(psi) /\ (neg(phi) \/ G(neg(phi U psi)))`, then propagate negation forward to contradict the witness (70% confidence, must verify first)
4. **All 6 prior chain attempts failed because they used DRM-based chains** -- this enriched full-MCS approach is structurally novel
5. **Path B (BXCanonical) is mathematically impossible** -- 95% confidence, leave those 5 sorries as-is

## Goals & Non-Goals

**Goals**:
- Verify the backward Until derivation from BX axioms (de-risk before committing)
- Create EnrichedChain.lean with dovetailed scheduling over deferral closure
- Fill Until/Since sorry cases in `canonical_truth_lemma` (line 628-629) and `shifted_truth_lemma` (line 776-777)
- Fill Until/Since sorry cases in `restricted_shifted_truth_lemma` (line 935, 938)
- Produce a sorry-free path from enriched chain through truth lemma to completeness wiring
- Clean `lake build` with reduced sorry count in Bundle/

**Non-Goals**:
- Fixing BXCanonical Frame.lean sorries (proven impossible by research)
- FMP TruthPreservation (task 82)
- dense_completeness_fc (task 68)
- Modifying FMCSDef.lean or BFMCS.lean type definitions
- Archiving SuccChainFMCS.lean (still contains reusable infrastructure)
- Fixing TemporalCoherence.lean G_dne_theorem sorry (line 68) -- separate concern

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Backward Until derivation fails in Lean | H | 30% | Phase 1 verifies this FIRST; fallback: induction on Until-depth via BX10 |
| DeferralRestrictedMCS vs SetMaximalConsistent typing mismatch | M | 40% | Enriched chain builds full MCS via Lindenbaum; targeted_successor already returns DRM, lift to MCS |
| Dovetailed scheduling complicates termination argument | M | 30% | Finite deferral closure guarantees every formula is scheduled within k steps; use Nat.mod for scheduling |
| CanonicalConstruction.lean wiring complexity for Until cases | M | 50% | Start with canonical_truth_lemma (simpler); extend to shifted/restricted versions via same pattern |
| Enriched chain coherence (forward_G) harder than expected | L | 20% | g_content is always in the seed by construction; Lindenbaum extension preserves superset |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Verify Backward Until Derivation [NOT STARTED]

**Goal**: De-risk the backward direction by formally deriving the key lemma `neg(phi U psi) -> neg(psi) /\ (neg(phi) \/ G(neg(phi U psi)))` from BX axioms in Lean. This is the highest-risk component (70% confidence from research).

**Tasks**:
- [ ] Derive `until_neg_unfolding`: `neg(phi U psi) -> neg(psi) /\ (neg(phi) \/ G(neg(phi U psi)))` from BX6 (absorption axiom: `phi /\ F(phi U psi) -> phi U psi`)
  - Contrapositive of BX6: `neg(phi U psi) -> neg(phi) \/ neg(F(phi U psi))`
  - `neg(F(phi U psi)) = G(neg(phi U psi))` by temporal duality
  - Also derive `neg(phi U psi) -> neg(psi)` from contrapositive of `psi -> phi U psi` (BX8/reflexivity)
  - Combine into conjunction
- [ ] Derive `until_neg_G_propagation`: If `neg(phi U psi) in MCS w` and `phi in w`, then `G(neg(phi U psi)) in w`
  - From `until_neg_unfolding`: `neg(psi) /\ (neg(phi) \/ G(neg(phi U psi)))` in w
  - Since `phi in w` (guard hypothesis), `neg(phi) not in w` by MCS consistency
  - Therefore `G(neg(phi U psi)) in w` by MCS maximality (disjunction elimination)
- [ ] Derive mirror lemmas for Since: `neg(phi S psi) -> neg(psi) /\ (neg(phi) \/ H(neg(phi S psi)))` from BX6'
- [ ] Run `lake build` to verify all derivations compile sorry-free
- [ ] If derivation fails: document the failure point and fall back to BX10-based induction approach

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- Add Until/Since negation unfolding theorems (~100-150 LOC)

**Verification**:
- `until_neg_unfolding` and `since_neg_unfolding` compile with zero sorry
- `lake build Bimodal.Theorems.TemporalDerived` passes
- Derivation chain is traceable to specific BX axioms (BX6, BX8, temporal duality)

---

### Phase 2: Enriched Chain Construction [NOT STARTED]

**Goal**: Create `EnrichedChain.lean` implementing dovetailed scheduling over the finite deferral closure, producing an FMCS with forward_F and backward_P properties.

**Tasks**:
- [ ] Define `enriched_seed`: `fun (u : Set Formula) (i : Nat) (targets : List Formula) => g_content(u) ∪ {targets[i % targets.length]}`
  - `targets` = list of F/Until formulas in deferral closure (finite, computed once)
  - `i` = chain step index
  - Round-robin scheduling: step i serves target at index `i mod k`
- [ ] Define `enriched_forward_chain`: `Nat -> Set Formula` by recursion
  - Base: `enriched_forward_chain 0 = M0` (the starting MCS)
  - Step: `enriched_forward_chain (n+1) = lindenbaum_extension(enriched_seed(chain(n), n, targets))` within deferral closure
  - Reuse `targeted_g_content_seed_consistent` for seed consistency at each step
  - Reuse `deferral_restricted_lindenbaum` for Lindenbaum extension
- [ ] Define `enriched_backward_chain`: Mirror for past direction using `h_content` and Since/P formulas
- [ ] Define `enriched_fmcs`: Combined `Int -> Set Formula` family (backward for negative, forward for non-negative)
- [ ] Prove `enriched_fmcs_is_mcs`: Each position is a SetMaximalConsistent set
  - Follows from Lindenbaum extension producing DRM, which implies MCS within deferral closure
  - Need to verify: DRM within finite closure implies MCS of the full language? This may require lifting.
- [ ] Prove `enriched_fmcs_forward_G`: g_content propagation (G-persistence)
  - By construction: g_content(chain(n)) is subset of seed(chain(n), n), which is subset of chain(n+1)
- [ ] Prove `enriched_fmcs_backward_H`: h_content propagation (H-persistence)
  - Mirror of forward_G for the backward chain
- [ ] Prove `enriched_fmcs_forward_F`: If F(phi) in chain(n), then phi in chain(n+j) for some j
  - By dovetailing: phi appears in targets list. At step n + (k - (n mod k) + index(phi)) mod k, phi is scheduled
  - Seed includes phi, so Lindenbaum extension includes phi
  - Bound: within k steps (k = |targets|)
- [ ] Prove `enriched_fmcs_backward_P`: Mirror for P direction
- [ ] Package as `EnrichedFMCS`: `FMCS Int` with all coherence properties
- [ ] Run `lake build` to verify

**Timing**: 3-4 hours

**Depends on**: 1 (backward derivation must be verified to confirm the approach)

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/EnrichedChain.lean` -- Enriched chain construction (~400-600 LOC)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` -- Add import for EnrichedChain if needed

**Verification**:
- `EnrichedFMCS` produces a valid `FMCS Int` with forward_F and backward_P
- All proofs sorry-free
- `lake build` passes

---

### Phase 3: Fill Until/Since Truth Lemma Cases [NOT STARTED]

**Goal**: Close the 6 sorry cases for Until/Since in `canonical_truth_lemma`, `shifted_truth_lemma`, and `restricted_shifted_truth_lemma` in CanonicalConstruction.lean.

**Tasks**:
- [ ] Fill `canonical_truth_lemma` Until case (line 628):
  - **Forward (MCS -> truth_at)**: `phi U psi in fam.mcs t` implies exists `s > t` with `psi in fam.mcs s` and `phi in fam.mcs r` for all `r in (t,s)`
    - From `phi U psi in fam.mcs t`: get `F(psi) in fam.mcs t` via `until_imp_F` (derived theorem)
    - Use `forward_F` from TemporalCoherentFamily to get witness `s >= t` with `psi in fam.mcs s`
    - Guard verification: for `r` between `t` and `s`, show `phi in fam.mcs r`
      - Use `until_neg_unfolding` + `G(neg(phi U psi))` propagation through g_content
      - At each intermediate `r`: `neg(phi U psi) in fam.mcs r` (from G-propagation) contradicts the witness unless `phi U psi in fam.mcs r`, which gives `phi in fam.mcs r` via `until_imp_or`
  - **Backward (truth_at -> MCS)**: Exists witness `s` with `psi at s` and `phi` on interval implies `phi U psi in fam.mcs t`
    - By contradiction: assume `neg(phi U psi) in fam.mcs t`
    - From Phase 1 derivation: `G(neg(phi U psi)) in fam.mcs t` (since `phi in fam.mcs t` from guard)
    - Propagates to witness `s`: `neg(phi U psi) in fam.mcs s`
    - But `psi in fam.mcs s` implies `phi U psi in fam.mcs s` (from `psi_imp_until`). Contradiction.
- [ ] Fill `canonical_truth_lemma` Since case (line 629): Mirror of Until using h_content, backward_P, BX6'
- [ ] Fill `shifted_truth_lemma` Until/Since cases (lines 776-777): Same proof structure as canonical, using shifted model
- [ ] Fill `restricted_shifted_truth_lemma` Until/Since cases (lines 935, 938):
  - Same proof structure but using restricted forward_F/backward_P
  - Must verify that target formulas are in deferral closure (should hold since Until/Since subformulas of root are in closure)
- [ ] Run `lake build` to verify all truth lemma cases compile

**Timing**: 3-4 hours

**Depends on**: 2 (enriched chain provides the forward_F/backward_P that truth lemma hypotheses require)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- Fill 6 sorry cases (~300-400 LOC)

**Verification**:
- Lines 628-629, 776-777, 935, 938 all sorry-free
- `lake build Bimodal.Metalogic.Bundle.CanonicalConstruction` passes
- Truth lemma now handles all formula cases

---

### Phase 4: Wire Completeness [NOT STARTED]

**Goal**: Connect the enriched chain construction to the completeness theorem. Given an unprovable formula, build an enriched FMCS where the formula fails, producing a countermodel.

**Tasks**:
- [ ] Create `enriched_completeness_family`: Given MCS M0 with `neg(phi) in M0`, construct an `EnrichedFMCS` rooted at M0
  - M0 exists from `neg_consistent_of_not_derivable` + `set_lindenbaum`
  - EnrichedFMCS provides forward_F and backward_P
  - Package as single-family BFMCS with `temporally_coherent` property
- [ ] Wire to `shifted_truth_lemma`:
  - Build `ShiftClosedCanonicalOmega` from the single-family BFMCS
  - Apply `shifted_truth_lemma` at time 0: `phi in fam.mcs 0 <-> truth_at CanonicalTaskModel Omega (to_history fam) 0 phi`
  - Since `neg(phi) in fam.mcs 0`, get `phi not in fam.mcs 0` (MCS consistency)
  - Therefore `neg(truth_at ... phi)` -- countermodel found
- [ ] Close the completeness sorry (if one exists in the main completeness path)
  - Check `BaseCompleteness.lean` and `DenseCompleteness.lean` for the exact wiring point
  - May need to show the enriched FMCS model satisfies task frame conditions
- [ ] Run `lake build` on all completeness modules

**Timing**: 2-3 hours

**Depends on**: 3 (truth lemma must handle Until/Since)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- Add enriched completeness construction (~150-200 LOC)
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` -- Wire enriched path (if needed)
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` -- Wire enriched path (if needed)

**Files to create** (if needed):
- `Theories/Bimodal/Metalogic/Bundle/EnrichedCompleteness.lean` -- Separate file if CanonicalConstruction.lean is too large (~200 LOC)

**Verification**:
- Completeness theorem compiles with zero sorry (for the enriched path)
- `lake build` passes on all completeness modules
- The enriched chain provides a complete sorry-free path: MCS -> FMCS -> truth lemma -> completeness

---

### Phase 5: Audit and Cleanup [NOT STARTED]

**Goal**: Full sorry audit of Bundle/, verify target sorries are resolved, catalog remaining sorries, and create summary.

**Tasks**:
- [ ] Run `lake build` and verify full success
- [ ] Sorry audit: `grep -rn "sorry" Theories/Bimodal/Metalogic/Bundle/ --include="*.lean"`
- [ ] Verify the 6 target truth lemma sorries are closed (lines 628-629, 776-777, 935, 938 of CanonicalConstruction.lean)
- [ ] Classify remaining Bundle/ sorries:
  - SuccChainFMCS.lean sorries: infrastructure for restricted path, may be superseded by enriched chain
  - TemporalCoherence.lean G_dne_theorem sorry (line 68): separate concern (temp_k_dist derivation)
  - Other infrastructure sorries: catalog with paths
- [ ] Verify BXCanonical sorries are untouched (leave as documented non-target)
- [ ] Create implementation summary at `specs/083_close_restricted_coherence_sorries/summaries/39_enriched-chain-summary.md`

**Timing**: 1 hour

**Depends on**: 4

**Files to create**:
- `specs/083_close_restricted_coherence_sorries/summaries/39_enriched-chain-summary.md`

**Verification**:
- Full `lake build` passes
- Target sorries eliminated
- Remaining sorries classified and documented
- Summary artifact created

---

## Testing & Validation

- [ ] Phase 1 gate: `until_neg_unfolding` and `since_neg_unfolding` sorry-free, `lake build` passes
- [ ] Phase 2 gate: `EnrichedFMCS` produces valid FMCS with forward_F/backward_P, sorry-free
- [ ] Phase 3 gate: All 6 Until/Since truth lemma sorries closed, `lake build` passes
- [ ] Phase 4 gate: Completeness wiring sorry-free, `lake build` passes on all completeness modules
- [ ] Phase 5 gate: Full sorry audit shows target sorries eliminated, remaining sorries classified
- [ ] Incremental `lake build` after each phase (critical -- do not proceed if build fails)

## Artifacts & Outputs

- `plans/39_enriched-chain-completeness.md` (this file)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- Until/Since negation unfolding theorems
- `Theories/Bimodal/Metalogic/Bundle/EnrichedChain.lean` -- New enriched chain construction
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- Until/Since truth lemma cases filled
- `summaries/39_enriched-chain-summary.md` -- Implementation summary

## Rollback/Contingency

- **Phase 1 failure (backward derivation)**: Fall back to BX10-based induction approach for backward Until. If that also fails, the forward direction alone may still close some sorries. Document as partial progress.
- **Phase 2 failure (enriched chain)**: The existing SuccChainFMCS infrastructure remains intact. No existing code is modified until Phase 3.
- **Phase 3 failure (truth lemma wiring)**: Revert CanonicalConstruction.lean changes via git. The enriched chain in its own file is preserved for future attempts.
- **DRM vs MCS typing**: If lifting DeferralRestrictedMCS to full SetMaximalConsistent proves difficult, create an intermediate adapter that embeds DRM into MCS for the truth lemma.
- **General**: All new code is in new files (EnrichedChain.lean) or clearly delineated sorry replacements. Git revert of any phase is clean.
