# Handoff: Sorry Closure (Phases 3-4)

## Context
Task 93, plan v48 (irreflexive semantics switch). Phases 1, 2, 5 completed.
Phase 3 partially completed (defect_step weakened to disjunctive output).
Phase 4 (close 5 sorry sites) not achieved due to fundamental mathematical difficulty.

## The 5 Sorry Sites

All in `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`:

1. **`fwd_chain_forward_F`** (line ~1093): F(phi) in chain(n) -> exists m > n, phi in chain(m)
2. **`dd_bfmcs_restricted_tc`** forward F-case (line ~1120): temporal coherence for backward chain position
3. **`dd_bfmcs_restricted_tc`** backward P-case (line ~1127): P(phi) resolution
4. **`dd_bfmcs_restricted_buc`** (line ~1135): backward Until/Since coherence
5. **`dd_bfmcs_restricted_fuc`** (line ~1142): forward Until/Since coherence

## What Was Tried

### Finite Descent on active_defects
The plan's strategy: under irreflexive semantics, active_defects strictly decreases
because resolved defects don't re-enter (phi -> F(phi) invalid).

**Why it fails**: The Lindenbaum extension (`.choose` in `set_lindenbaum`) is
non-constructive. When the seed is `{beta} union g_content(M)`, the Lindenbaum
extension can freely add `F(phi)` to M' even when `F(phi)` was not in the seed.
This means a resolved defect w with `w in M'` might also have `F(w) in M'`,
so the active defect count does NOT necessarily decrease.

The irreflexive semantics change removes DERIVATION-LEVEL re-entry (phi -> F(phi)
is not derivable), but does NOT prevent SET-LEVEL re-entry (the Lindenbaum
extension is unconstrained).

### Direct pigeonhole
Tried: after |sigma_list| steps, each defect is resolved at least once.
Fails because: the BX11 fold picks w non-deterministically; the same defect
might be picked repeatedly.

## Current Infrastructure

What IS in place (sorry-free):
- `defect_step_early`: ∀ chi in defects, chi in M' OR F(chi) in M'
- `fwd_chain_defect_one_step`: single-step preservation
- `preserving_fwd_step_defect_preserved`: disjunctive output
- `g_content_set_consistent`: via seriality (G(bot) contradicts F(top))
- `h_content_set_consistent`: mirror via serial_past

## Recommended Approaches

### Approach A: Constrained Lindenbaum Extension
Instead of unconstrained `set_lindenbaum`, use a CONSTRAINED version that
EXCLUDES `F(phi)` for resolved defects from the extension. This requires:
1. Define `constrained_lindenbaum` that extends a consistent set to MCS while
   excluding a given finite set of formulas
2. Prove this is possible when the excluded formulas are not forced by the seed
3. Under irreflexive semantics, F(phi) is NOT forced by g_content(M) union {phi}
   because phi -> F(phi) is not derivable

This is the most direct approach. Estimated effort: 200-300 LOC.

### Approach B: Oracle Chain
Replace the Lindenbaum-based chain with a more constructive approach:
1. Use sigma-specific Hintikka sets (available in OrderedSeedConsistency.lean)
2. Build the chain deterministically using BX11 fold
3. The deterministic chain gives precise control over F-obligations

This approach avoids the Lindenbaum non-determinism entirely.
Estimated effort: 400-600 LOC.

### Approach C: Semantic Argument
Instead of proof-theoretic argument, use the completeness proof's semantic side:
1. Build the canonical model semantically (truth at each integer time)
2. Use the model's satisfaction to derive the coherence properties
3. This requires showing the canonical model validates all formulas in each MCS

This is the most elegant but requires significant new infrastructure.
Estimated effort: 500-800 LOC.

### Approach D: Weakened Coherence
Weaken the coherence requirements to something provable with unconstrained
Lindenbaum. Instead of requiring EXACT Until coherence, require an approximate
version that is still sufficient for the truth lemma.

## Key Files
- `RootScopedChain.lean`: Chain construction and sorry sites
- `Frame.lean`: Canonical frame (sorry-free except bx_le_refl)
- `CanonicalModel.lean`: Forward/backward step infrastructure
- `OrderedSeedConsistency.lean`: BX11 fold and enriched seed consistency
- `TemporalCoherence.lean`: Coherence definitions (updated to strict inequalities)

## Build Status
`lake build` passes with 950 jobs and 0 errors.
