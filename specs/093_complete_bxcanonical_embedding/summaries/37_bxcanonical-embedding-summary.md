# Implementation Summary: Task #93 (Plan v37)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [BLOCKED]
- **Started**: 2026-04-17T00:00:00Z
- **Completed**: 2026-04-17T02:00:00Z
- **Effort**: 2 hours (analysis and attempted implementation)
- **Dependencies**: None
- **Artifacts**: plans/37_bxcanonical-embedding.md
- **Standards**: summary-format.md, status-markers.md

## Overview

Attempted to implement Plan v37 (Extended Seed Oracle + Hybrid BFMCS) to close the 3 sorry sites reachable from `bx_completeness` (`dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`). Deep mathematical analysis revealed two fundamental blockers that were not identified in the research reports.

## What Changed

No code changes were committed. The entire session was spent on mathematical analysis to validate the plan's approach before implementation.

## Decisions

- **Plan v37's approach is architecturally correct**: a new BFMCS construction IS needed (the existing `dd_bfmcs` cannot be patched for coherence)
- **Backward Until coherence is NOT provable from FMCS structure alone**: a concrete counterexample exists (constant-then-shift FMCS where `neg(phi U psi) in mcs(0)` and `phi U psi in mcs(1)`)
- **The extended seed consistency proof requires a new technique**: the standard G-lift approach (used in `forward_temporal_witness_seed_consistent`) fails for seeds containing Until formulas, because Until formulas in an MCS do NOT have their G-versions in the MCS

## Impacts

### Blocker 1: Extended Seed Consistency

The plan proposes seed `{psi_target} U g_content(w) U {active Until defects from w}`. The consistency proof in `forward_temporal_witness_seed_consistent` uses a G-lift:
1. L' (seed minus psi) |- neg(psi)
2. G(L') |- G(neg(psi)) by generalized temporal K
3. G(chi) in w for each chi in L' (because chi in g_content)
4. So G(neg(psi)) in w, contradicting F(psi) in w

Step 3 fails for Until formulas: `alpha U beta in w` does NOT imply `G(alpha U beta) in w`. The G-version of an Until formula is much stronger (Until holds at ALL future times) and is NOT derivable from the Until formula alone.

This means the extended seed's consistency is NOT "trivially" proved by the same argument as the standard seed. A fundamentally different consistency proof is needed.

### Blocker 2: Until Propagation Through bx_le

The `hintikka_step` relation requires: if `phi U psi in h1` and `psi not in h1`, then `phi U psi in h2`. For sigma-signatures of bx_le-related BXPoints, the G-propagation and H-backward clauses are straightforward (proved in analysis). But Until propagation fails: `bx_le w v` (i.e., `g_content(w) subset v`) does NOT imply `phi U psi in v` even when `phi U psi in w`.

This is because `phi U psi` is NOT of the form `G(chi)`, so it does not propagate through g_content/bx_le.

### Partial Results (Not Committed)

The following were proved in analysis but not committed (they are straightforward and can be re-derived):
- `sigma_signature_G_H_step`: G-propagation and H-backward for sigma-signatures of bx_le-related BXPoints (first two clauses of hintikka_step)
- `sigma_signature_until_guard`: If `phi U psi in sig(w)` and `psi not in sig(w)`, then `phi in sig(w)` (first half of Until clause, using BX9)
- `bx_forward_sigma_oracle` (partial): Oracle that resolves one Until defect using `bx_forward_witness`, but missing Until propagation for OTHER defects

## Follow-ups

### Recommended Approach for Closing the Sorries

1. **Prove extended seed consistency** via a different technique. Possible approaches:
   - Show that `{psi} U g_content(w) U {Until formulas from w}` is a subset of the Lindenbaum extension of `{psi} U g_content(w)`. This requires proving that the Lindenbaum extension contains the Until formulas.
   - Use a two-phase construction: first extend `{psi} U g_content(w)` to MCS M', then check if Until formulas landed in M'. If yes, use M'. If no, construct a different witness.
   - Use compactness: any finite inconsistent subset of the seed has all non-psi elements in w, so it reduces to `w U {psi}` being inconsistent for some finite projection, which contradicts F(psi) in w via G-lift on the g_content PORTION only.

2. **Alternative: avoid hintikka_step Until propagation entirely** by modifying the chain construction to not require Until propagation at intermediate points. Use a construction where each step directly resolves to the witness (no intermediate chain points with active defects).

3. **Spawn focused sub-task** for the extended seed consistency proof, which is the minimal mathematical blocker.

## References

- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/plans/37_bxcanonical-embedding.md`
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/reports/37_team-research.md`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (lines 1512-1527: sorry sites)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (HintikkaStepOracle, hintikka_chain_exists)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (forward_temporal_witness_seed_consistent)
