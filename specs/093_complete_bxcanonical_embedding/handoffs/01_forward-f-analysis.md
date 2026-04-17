# Handoff: Forward_F Analysis for BXCanonical Embedding

**Task**: 93
**Session**: sess_1776384495_603482
**Phase**: Pre-Phase 1 (analysis before implementation)
**Context Usage**: ~80% (extensive analysis of sorry sites and chain architecture)

## What Was Done

Thorough analysis of all 6 sorry sites in RootScopedChain.lean and the mathematical obstructions preventing their closure. No code changes were made.

## Key Findings

### 1. The Existing Chain Cannot Prove Forward_F

The `rr_fwd_chain` uses `enriched_fwd_step` which preserves F-obligations via BX11 fold (`enriched_fwd_step_preserves`). However:

- `enriched_fwd_step_resolves_one` guarantees SOME formula `w` is resolved at each step
- The resolved formula `w` is determined by the BX11 fold via `enriched_fwd_fold_with_witness`
- In Case 3 of BX11 (`F(F(beta) AND chi)`), the witness SWITCHES from the target to another formula
- This "BX11 hijacking" means the round-robin target `psi` might NEVER be the resolved formula
- The `rr_fwd_chain_forward_F` sorry at line 3644 is NOT closable with the current chain

### 2. Extended Seed Inconsistency Confirmed

The extended seed `{target, F(psi)} union g_content(M)` (which would allow resolving target while preserving F(psi)) is NOT always consistent:

- When `F(G(neg psi)) in M`, the seed can be inconsistent
- The proof (lines 2430-2505 in RootScopedChain.lean): if `g_content(M)` derives `chi -> G(neg psi)`, then by `g_content_closed_derivation` and F-monotonicity, `F(G(neg psi)) in M`, and `G(neg psi)` and `F(psi)` (= `neg G(neg psi)`) create inconsistency in the seed
- This blocks the "enriched resolving seed that preserves f_carry" approach

### 3. F(psi) -> G(F(psi)) Is NOT a Theorem

`F(psi) -> G(F(psi))` is semantically invalid (counterexample: finite time domain {0,1,2}, psi true only at time 1). Without this, `F(psi)` cannot be "promoted" to g_content for automatic propagation. This is the core obstruction identified in Reports 26/27.

### 4. The Depth-0 Base Case Is the Only Obstruction

- Depth >= 1 case is handled trivially: `F(F(psi')) in chain(n)` -> `F(psi') in chain(n)` by `FF_imp_F_mcs`, then by IH get `psi' in chain(s)`, then `F(psi') = psi in chain(s)` by `phi_in_mcs_imp_F_phi`. This is already implemented (lines 3645-3655).
- Depth 0 is the only sorry: line 3644.

### 5. Sorry Sites 2-6 All Depend on Sorry Site 1

- Sorry 2 (`dd_fmcs_forward_F` t >= 0 case): delegates to `rr_fwd_chain_forward_F`
- Sorry 3 (`dd_fmcs_backward_P`): symmetric backward direction, same obstruction
- Sorry 4 (`dd_bfmcs_restricted_tc`): needs forward_F and backward_P for each family
- Sorries 5-6 (`dd_bfmcs_restricted_buc/fuc`): Until/Since coherence, partly depends on forward_F plus an independent Until persistence obstacle

## The Correct Architecture (Not Yet Implemented)

Based on 29 rounds of research and this analysis, the viable approaches are:

### Approach A: Per-Formula FMCS (Recommended)

Replace `dd_bfmcs` with a construction where each forward_F query is answered by a DEDICATED one-step extension:

1. Keep `dd_chain` for g_content, h_content, and box stability (all sorry-free)
2. For `restricted_temporally_coherent`: when `F(psi) in fam.mcs(t)`, construct a one-step witness using `bx_forward_witness` (Frame.lean:164, sorry-free)
3. The witness BXPoint `v` has `psi in v` and `g_content(fam.mcs(t)) subset v`
4. Challenge: `v` is not on the chain; need to restructure the BFMCS to include `v` as `fam.mcs(s)` for some `s > t`

This requires changing the FMCS from a FIXED chain to a DEMAND-DRIVEN chain, or changing the BFMCS architecture entirely.

### Approach B: Quasimodel Bridge (Fallback)

Build Int-indexed FMCS families from the sorry-free Quasimodel infrastructure (1,816 lines). Estimated 600-1000 new LOC. Handles forward_F and Until coherence together. Higher implementation cost but more robust.

### Approach C: New Chain with Controlled Lindenbaum

Define a new `fwd_succ_controlled` that takes an EXPLICIT seed (including specific F-obligations to preserve) and extends it. At each chain step, include F(psi) in the seed when `{target, F(psi)} union g_content(M)` is consistent (provable via `forward_temporal_witness_seed_consistent` when `F(G(neg psi)) not in M`). Skip F(psi) when it's inconsistent with the seed.

The key lemma to prove: when `F(G(neg psi)) in M`, the BX11 argument gives `F(psi AND F(G(neg psi))) in M`, which semantically means "psi holds at some time before G(neg psi) takes over." This can be used for a termination argument: the set of formulas where `F(G(neg phi)) in chain(n)` is monotonically non-increasing (once G(neg phi) enters the chain, it stays forever via g_content).

## Files Read

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (3790 lines, extensive analysis in lines 1280-3616)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (bx_forward_witness, bx_backward_witness)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (fwd_succ, bwd_pred)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (restricted coherence definitions)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (FMCS structure)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (BFMCS structure)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (truth lemma using coherence)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (bx_completeness)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean`
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/reports/29_team-research.md`
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/plans/29_bxcanonical-embedding.md`

## Resumption Instructions

The next agent should:

1. **Choose an approach** (A, B, or C above) and implement it
2. **Do NOT attempt** to prove `rr_fwd_chain_forward_F` for the existing chain -- it is mathematically blocked
3. **Focus on** either replacing `dd_bfmcs` (Approach A/B) or replacing `rr_fwd_chain` with a new chain that controls Lindenbaum extensions (Approach C)
4. **Read the key files**: `RootScopedChain.lean` (3600-3790 for sorry sites), `Frame.lean` (164-186 for `bx_forward_witness`/`bx_backward_witness`), `RestrictedParametricTruthLemma.lean` (270-487 for what coherence properties are needed)
5. **The plan's phases 2-5 need revision** to reflect the new approach -- the plan assumed targeted seed + semantic forward_F would be straightforward, but wiring the semantic witness into the chain structure is the hard part

## Status

All phases remain [NOT STARTED] (Phase 1 marked [BLOCKED] pending architecture decision).
No code changes made. No sorry sites modified.
