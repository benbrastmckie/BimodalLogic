# Implementation Plan: g_content Blocker Resolution for Task #83

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours
- **Dependencies**: Phases 1-4 of plan v8 (11_strict-semantics-refactor.md) COMPLETED
- **Research Inputs**: reports/12_team-research.md (g_content blocker root cause and 3-tier resolution)
- **Artifacts**: plans/12_g-content-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Resolve the g_content blocker that emerged after removing the T-axiom under strict semantics. The blocker manifests as ~26 sorry sites across 6 files where proofs previously relied on `G(phi) in M -> phi in M` (the T-axiom pattern). Research report 12 identified three independent tiers of sorry sites requiring different fix strategies: (1) seed-based fixes needing no new theorems, (2) coherence theorem fixes needing the derived theorem `G(a) -> X(a)` plus strict inequality, and (3) algebraic/ultrafilter restructuring since R_G is not reflexive under strict semantics. Additionally, ~30 cascade errors in CanonicalConstruction.lean need resolution. This plan covers all remaining work from the blocked Phase 5 through final integration.

### Research Integration

- **Report 12 (team research)**: Established that `G(a) -> X(a)` IS derivable from the current 33-axiom system via `prop_s + until_induction`. Identified 3-tier decomposition of sorry sites. Confirmed `g_content(M)` elements are G-liftable, enabling seed enrichment. Identified that R_G reflexivity is FALSE under strict semantics, requiring algebraic restructuring. Audit needed for SuccChainFMCS self-g_content vs parent-g_content.

## Goals & Non-Goals

**Goals**:
- Prove `G(a) -> X(a)` and `H(a) -> Y(a)` as derived theorems in the proof system
- Enrich `temporal_box_seed` to include `g_content(M)` with consistency proof
- Fix all ~11 Tier 1 sorry sites via direct seed membership
- Fix all ~8 Tier 2 sorry sites via `G(a)->X(a)` derivation + strict inequality in coherence theorems
- Restructure ~7 Tier 3 sorry sites where R_G reflexivity was assumed
- Fix ~30 cascade errors in CanonicalConstruction.lean
- Fix WitnessSeed.lean axiom shape mismatches
- Achieve sorry-free canonical completeness over Int

**Non-Goals**:
- FMP TruthPreservation (task 82)
- dense_completeness_fc (task 68)
- Changes to modal logic (S5 axioms unchanged)
- Changes to propositional logic layer
- Sorries outside the canonical completeness path

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G(a)->X(a) derivation tree construction harder than sketch suggests | H | L | The proof sketch from research is complete; implementation is mechanical DerivationTree construction |
| Seed enrichment consistency proof has subtle gap in G-lift argument | H | L | Fall back to routing through temporal_theory_witness_exists directly |
| SuccChainFMCS needs self-g_content (not just parent-g_content) | H | M | Audit first; if self-g_content needed, restructure via successor chain propagation |
| R_G algebraic restructuring cascades into more files than expected | M | M | Accept temporary sorries on algebraic path; primary MCS-chain path takes priority |
| CanonicalConstruction cascade larger than estimated | M | L | Fix incrementally; each <= to < change is mechanical |
| until_induction G-quantified premises break WitnessSeed proofs | M | M | Reconstruct WitnessSeed proofs using temporal necessitation + K-distribution pattern |

## Implementation Phases

### Phase 1: Derived Theorems G(a)->X(a) and H(a)->Y(a) [COMPLETED]

**Goal**: Prove the foundational derived theorems that `G(a) -> X(a)` (where `X(a) = bot U a`) and the dual `H(a) -> Y(a)` (where `Y(a) = bot S a`) from the existing 33-axiom system. These are prerequisites for Tier 2 fixes.

**Tasks**:
- [ ] Create or extend a file (e.g., `Theories/Bimodal/Theorems/Combinators/TemporalDerived.lean` or add to existing Combinators file) for the derived theorems
- [ ] Implement `G_implies_X : DerivationTree ctx (Formula.g a --> Formula.next a)` using the 12-step derivation: prop_s instance, temporal necessitation, temp_k_dist, identity tautology, until_induction instantiation, seriality_future, F_until_equiv chain
- [ ] Implement `H_implies_Y : DerivationTree ctx (Formula.h a --> Formula.prev a)` as the symmetric dual using since_induction, seriality_past, P_since_equiv
- [ ] Verify both compile with `lake build`
- [ ] Run `lean_verify` on both theorems

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Theorems/Combinators/` -- new or extended file for G->X, H->Y derived theorems

**Verification**:
- Both theorems compile without sorry
- `lean_verify` confirms no axiom leakage
- DerivationTree uses only: prop_s, temp_k_dist, seriality_future, F_until_equiv, until_induction (and mirrors)

---

### Phase 2: Seed Enrichment with g_content [NOT STARTED]

**Goal**: Enrich `temporal_box_seed` to include `g_content(M)` and prove the enriched seed is consistent. This resolves Tier 1 sorry sites by providing direct seed membership for g_content elements.

**Tasks**:
- [ ] In the seed definition file (likely SuccExistence.lean or a seed-related file), add `g_content(M)` to `temporal_box_seed`
- [ ] Prove G-liftability of all enriched seed elements: G_theory elements via temp_4, box_theory via existing G_of_box_theory, g_content elements by definition
- [ ] Prove consistency of enriched seed via G-lift argument: if inconsistent, G-lift gives G(bot) in M, contradicting G(top) in M (seriality)
- [ ] Similarly enrich predecessor seed with `h_content(M)` and prove consistency
- [ ] Update `constrained_successor_seed_consistent` and `successor_deferral_seed_consistent_axiom` for enriched seeds
- [ ] Update `predecessor_deferral_seed_consistent_axiom` for enriched predecessor seed
- [ ] Run `lake build` on modified seed files

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- seed enrichment and consistency proofs
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- axiom shape updates for G-quantified until_induction premises

**Verification**:
- Enriched seed definitions compile
- Consistency proofs compile without sorry
- `lake build` passes for seed files

---

### Phase 3: Tier 1 Sorry Sites -- Direct Seed Membership [NOT STARTED]

**Goal**: Close the ~11 Tier 1 sorry sites by using direct membership in the enriched seed instead of the T-axiom detour pattern `G(a) in W -> a in W`.

**Tasks**:
- [ ] Fix `forward_step_g_content` in DovetailedChain.lean (line ~142): use seed membership directly
- [ ] Fix `temporal_witness_g_persistence` in UltrafilterChain.lean (line ~2591): use seed membership
- [ ] Fix `build_targeted_successor_g_persistence` in MCSWitnessSuccessor.lean (line ~259): use seed membership
- [ ] Fix mirror H-direction sites: `backward_step_h_content`, `temporal_witness_h_persistence`, `build_targeted_predecessor_h_persistence`
- [ ] Fix remaining Tier 1 sites in SuccChainFMCS.lean where seed already contains g_content
- [ ] Audit SuccChainFMCS for self-g_content vs parent-g_content: verify downstream proofs only need `g_content(parent) subset u` (which seed construction guarantees)
- [ ] Fix `neg_neg_bot` case in SuccChainFMCS.lean (line ~4449): derive from propositional axioms (not_not_bot is a propositional tautology)
- [ ] Run `lake build` on all modified files

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- forward/backward step g/h_content
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- witness g/h persistence
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean` -- targeted successor/predecessor g/h content
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- seed-based sites and neg_neg_bot

**Verification**:
- All Tier 1 sorry sites closed
- `lake build` passes for all modified files
- No T-axiom pattern `G(a) in M -> a in M` remains in these files

---

### Phase 4: Tier 2 Sorry Sites -- Coherence Theorems with Strict Inequality [NOT STARTED]

**Goal**: Fix the ~8 Tier 2 sorry sites by changing coherence theorem statements from `m >= n` to `m > n` and using `G(a) -> X(a)` for the base case.

**Tasks**:
- [ ] Rewrite `forward_dovetailed_forward_G` in DovetailedChain.lean: change statement to `m > n` (strictly greater), base case `m = n+1` uses G(a)->X(a) + successor resolution, inductive step uses temp_4
- [ ] Rewrite `forward_dovetailed_backward_H`: mirror change to strict inequality
- [ ] Rewrite `backward_dovetailed_forward_G` and `backward_dovetailed_backward_H`: same pattern
- [ ] Rewrite `g_content_forward_propagation` in UltrafilterChain.lean (line ~520): use G->X instead of T-axiom
- [ ] Rewrite `h_content_backward_propagation` in UltrafilterChain.lean (line ~565): use H->Y instead of T-axiom
- [ ] Update all call sites that referenced the old `>=` versions to pass strict `>` proofs
- [ ] Update TargetedChain.lean coherence theorems: remove `n=m` base cases, use strict `<`
- [ ] Run `lake build` on all modified files

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- forward/backward coherence with strict inequality
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- propagation proofs
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- base case removal

**Verification**:
- All Tier 2 sorry sites closed
- Coherence theorems state `m > n` (not `m >= n`)
- `lake build` passes for all modified files

---

### Phase 5: Tier 3 Sorry Sites -- Algebraic R_G/R_H Restructuring [NOT STARTED]

**Goal**: Handle the ~7 Tier 3 sorry sites where R_G reflexivity was assumed. Delete invalid reflexivity lemmas, fix the `G(bot)->bot` special case via seriality, and restructure or defer the algebraic path.

**Tasks**:
- [ ] Delete `R_G_refl` from UltrafilterChain.lean (line ~97)
- [ ] Delete `R_H_refl` from UltrafilterChain.lean (line ~267)
- [ ] Fix `G(bot)->bot` sites (UltrafilterChain.lean lines ~1009, ~1318): derive via seriality argument (G(bot) -> F(bot), F(bot) = neg G(top), contradicts G(top) theorem)
- [ ] Restructure `forward_G` lattice ordering (line ~520): replace `G(a) <= a` with appropriate strict-semantics ordering
- [ ] Restructure `backward_H` lattice ordering (line ~565): mirror
- [ ] Audit all downstream uses of R_G_refl/R_H_refl and fix or mark with sorry if on non-critical path
- [ ] If restructuring is intractable for specific algebraic sites, accept sorry with documentation noting these are on the algebraic path (not the primary MCS-chain path)
- [ ] Run `lake build` on modified files

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- R_G/R_H deletion, G(bot)->bot fix, lattice restructuring

**Verification**:
- R_G_refl and R_H_refl deleted
- G(bot)->bot derived via seriality
- Critical-path sorry sites closed; any remaining sorries are on algebraic non-critical path with documentation
- `lake build` passes

---

### Phase 6: Cascade Fixes and Integration Build [NOT STARTED]

**Goal**: Fix the ~30 cascade errors in CanonicalConstruction.lean, WitnessSeed.lean axiom shape mismatches, SuccRelation.lean, and any remaining compilation errors across all files. Achieve a full clean build.

**Tasks**:
- [ ] Fix CanonicalConstruction.lean cascade: each `<=` to `<` type mismatch needs trichotomy split or strict inequality proof; close the 2 original task-83 sorries (restricted_tc_family_to_fmcs forward_G/backward_H)
- [ ] Fix WitnessSeed.lean axiom shape mismatches: until_induction/since_induction now have G/H-quantified premises, reconstruct proofs using temporal necessitation + K-distribution
- [ ] Fix SuccRelation.lean sorry (1 site)
- [ ] Fix ParametricTruthLemma.lean partially updated sites
- [ ] Fix RestrictedTruthLemma.lean auxiliary sorries (restricted_chain_G_step, restricted_chain_H_step)
- [ ] Run full `lake build` and fix any remaining errors iteratively
- [ ] Verify no references to `temp_t_future`, `temp_t_past`, `R_G_refl`, `R_H_refl` remain
- [ ] Grep for remaining `sorry` on the canonical completeness path
- [ ] Run `lean_verify` on key theorems: axiom_valid, restricted_tc_family_to_fmcs, canonical completeness
- [ ] Update module docstrings to reference strict semantics where needed

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- cascade fixes and original sorries
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- axiom shape reconstruction
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- remaining sorry
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- partially updated sites
- `Theories/Bimodal/Metalogic/Bundle/RestrictedTruthLemma.lean` -- auxiliary sorries
- Various files across `Theories/Bimodal/` -- cleanup and documentation

**Verification**:
- Full `lake build` succeeds with zero errors
- Zero `sorry` on the canonical completeness path
- No stale references to removed axioms or theorems
- `lean_verify` passes on key theorems
- The 2 original task-83 sorries (restricted_tc_family_to_fmcs) are closed

## Testing & Validation

- [ ] `lake build` succeeds with zero errors on all Theories/Bimodal/ files
- [ ] `lean_verify` passes on `G_implies_X` and `H_implies_Y` derived theorems
- [ ] `lean_verify` passes on axiom_valid (all 33 axioms dispatched)
- [ ] `lean_verify` passes on restricted_tc_family_to_fmcs (the original task-83 target)
- [ ] Grep for `sorry` in canonical completeness path returns empty
- [ ] Grep for `temp_t_future|temp_t_past` in Theories/ returns empty
- [ ] Grep for `R_G_refl|R_H_refl` in Theories/ returns empty (except Boneyard)
- [ ] Coherence theorems use strict `>` (not `>=`)

## Artifacts & Outputs

- plans/12_g-content-resolution.md (this file)
- Modified files across ~15 Lean source files in Theories/Bimodal/
- New file: TemporalDerived.lean (or extension of existing Combinators) with G->X, H->Y
- summaries/12_g-content-resolution-summary.md (post-implementation)

## Rollback/Contingency

- All changes are on the `until` branch; main branch is unaffected
- Git history preserves all prior plan versions (v1-v8, v9/11) and phases 1-4 implementation
- If seed enrichment consistency proof (Phase 2) proves intractable, fall back to routing through `temporal_theory_witness_exists` directly
- If R_G algebraic restructuring (Phase 5) is too complex, accept sorries on the algebraic path while keeping the primary MCS-chain path sorry-free
- If CanonicalConstruction cascade (Phase 6) reveals deeper structural issues, split into additional phases
- Partial progress can be committed and phases resumed independently
