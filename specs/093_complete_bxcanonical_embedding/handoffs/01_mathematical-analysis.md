# Handoff: Mathematical Analysis of BXCanonical Embedding Sorries

**Task**: 93 - Complete BXCanonical embedding
**Session**: sess_1776533662_a1d4fd
**Phase**: 1 (restricted_tc) - BLOCKED
**Written**: 2026-04-18

## Summary

Extensive mathematical analysis of the three sorry sites (lines 1517, 1522, 1527 in
RootScopedChain.lean) reveals that **the plan v38 approach cannot work as described**.
The fundamental obstacle is the BX11 perpetual deferral problem in the depth-0 case
of `rr_fwd_chain_forward_F`, which the plan's `self_resolving_fwd_step` strategy
cannot circumvent.

## The Three Sorry Sites

All three sorries prove coherence properties of `dd_bfmcs M0 h0 sigma_list`:

1. **dd_bfmcs_restricted_tc** (line 1517): For each family `fam`, if `F(phi) in fam.mcs(t)`,
   then `exists s > t, phi in fam.mcs(s)` (and symmetrically for P).

2. **dd_bfmcs_restricted_buc** (line 1522): Backward Until/Since coherence.

3. **dd_bfmcs_restricted_fuc** (line 1527): Forward Until/Since coherence.

All three require the witness in the SAME family. A family is
`shifted_dd_fmcs N h_N sigma_list s`, so `fam.mcs(t) = dd_chain N h_N sigma_list (t-s)`.
The forward chain `dd_chain` for `t-s >= 0` uses `rr_fwd_chain` which is built from
`enriched_fwd_step` (BX11 fold).

## Why Plan v38 Cannot Work

### The self_resolving_fwd_step approach

Plan v38 proposes using `self_resolving_fwd_step` to construct witnesses. This function
(lines 1961-1996, sorry-free) provides:
- `psi in M'` (target resolved directly)
- `F(psi) in M'` (self-resolving)
- `g_content(M) subset M'`

**Problem**: The result `M'` is a NEW MCS, not a state of `dd_chain`. Temporal coherence
requires the witness in `dd_chain N h_N sigma_list (s'-s)` for some `s' > t`, which is
the SAME chain. We cannot substitute `M'` for a chain state.

### The dd_chain forward_F problem

For `dd_chain` (which uses `rr_fwd_chain` with `enriched_fwd_step`):

1. **F-obligations persist**: `rr_fwd_chain_F_obligation_persists` (sorry-free) shows
   `F(psi) in chain(n)` implies `F(psi) in chain(n+1)` for `psi in sigma_list`. This
   uses the BX11 fold property: `psi in M' OR F(psi) in M'`, and either way
   `F(psi) in M'` (via `phi_in_mcs_imp_F_phi`).

2. **Resolution is disjunctive**: `enriched_fwd_step_preserves` gives
   `psi in M' OR F(psi) in M'`. We cannot force `psi in M'`.

3. **Perpetual deferral**: At each visit of psi, the BX11 fold may resolve a DIFFERENT
   formula `w != psi`, giving `F(psi) in M'` but not `psi in M'`. This can repeat
   indefinitely because the resolved formula `w` remains an active defect
   (`w in M'` implies `F(w) in M'` by `phi_in_mcs_imp_F_phi`).

4. **Depth-0 case is irreducible**: For formulas with `f_nesting_depth = 0` (atoms,
   non-F-formulas), there is no way to reduce to a simpler case. The depth >= 1 case
   is handled by `rr_fwd_chain_forward_F_depth_pos` (sorry-free), but depth-0 is the
   sorry at line 1413.

### Why alternative chain constructions fail

Every alternative chain construction hits the same fundamental obstacle:

| Construction | Resolves directly? | Preserves other F-obligations? | Works? |
|---|---|---|---|
| `enriched_fwd_step` (BX11 fold) | Disjunctive only | YES | No (perpetual deferral) |
| `fwd_succ` (direct resolution) | YES | NO | No (kills other F-obligations) |
| `self_resolving_fwd_step` | YES + self-resolving | NO | No (kills other F-obligations) |
| `{psi1,...,psik} union g_content(M)` | All at once | N/A | Not always consistent |

The fundamental tension: protecting F-obligations (via BX11) prevents direct resolution,
while direct resolution (via fwd_succ) destroys other F-obligations.

### Why F-obligation loss is fatal

When `F(psi) in chain(n)` and a resolving step for `chi != psi` occurs at step `k`:
- The seed is `{chi} union g_content(chain(k))`
- `F(psi)` is NOT in the seed (unless `G(F(psi)) in chain(k)`)
- `F(psi) -> G(F(psi))` is NOT derivable in BX
- If `F(psi) not in chain(k+1)`, then `G(neg psi) in chain(k+1)` (MCS maximality)
- By `all_future_all_future` (temp_4), `G(neg psi)` persists forever
- `psi not in chain(m)` for all `m > k`

So once `F(psi)` is lost, `psi` can never appear in the chain. Temporal coherence fails.

## Existing Infrastructure Analysis

### FiniteDeferral (Boneyard) - Almost works but stuck

File: `Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean`

Uses F -> Until conversion (BX12) + pigeonhole + Until persistence to show the chain
restricted theory must cycle. The gap: deriving `G(neg psi) in chain(t)` from
"neg psi in chain(s) for all s > t" requires backward G reasoning, which requires
forward_F (circular). And the Until Induction axiom is NOT in BX.

### defect_fwd_chain - F-obligations persist but resolution uncontrolled

`defect_fwd_chain M0 h0 defects` preserves F-obligations for all defects AND resolves
SOME formula at each step. But the resolved formula is not controllable, and the same
formula can be resolved repeatedly while others are perpetually deferred.

For singleton `defects = [psi]`: trivially resolves psi at step 1 (sorry-free by
`defect_fwd_step_choice_singleton`). But temporal coherence for OTHER formulas in the
family fails.

## Root Cause

The BX axiom system (BX1-BX12) does NOT include an Until Induction axiom or any
axiom that prevents perpetual F-deferral. In standard temporal logic completeness
proofs (e.g., GHR 1994), either:

1. An Until Induction axiom is included (prevents perpetual deferral directly), or
2. A quasimodel construction is used (builds explicit witness sets globally)

The BX system uses approach (2) implicitly, but the formalization attempted approach (1)
via incremental chain construction. This is the source of the difficulty.

## Recommended Approaches (in order of feasibility)

### Approach A: Redefine dd_bfmcs using per-formula resolution chains

For each formula psi in sigma_list, define `sr_dd_chain_psi N h_N sigma_list` that uses
`self_resolving_fwd_step` targeting psi at every step. Then define `dd_bfmcs` with families
from ALL (N, psi, shift) triples. Each family resolves exactly one formula.

**Problem**: Temporal coherence for OTHER formulas in the same family still fails.
**Mitigation**: Might be solvable if we show that the `self_resolving_fwd_step` chain
preserves F-obligations for formulas in `deferralClosure(root)` specifically (not all
formulas). Requires checking if `G(F(chi)) in chain(n)` for chi in deferralClosure.

### Approach B: Quasimodel construction (recommended)

Build a global canonical model using the quasimodel approach from GHR 1994:
1. Define quasimodels as pairs (run, defect-set) where the run is a function from Int to MCS
2. Build the canonical quasimodel using Lindenbaum lemma
3. Unwind the quasimodel into a proper model
4. Prove temporal coherence by construction (each F-obligation has an explicit witness)

This is ~800-1200 LOC of new infrastructure. Plan v37 attempted this but was blocked by
"extended seed consistency" -- the specific failure mode should be re-examined.

### Approach C: Add Until Induction to BX (changes axiom system)

Add BX13: Until Induction axiom `G(psi -> chi) AND G((phi AND (chi U chi)) -> chi) -> ((phi U psi) -> chi)`.
This directly enables the FiniteDeferral argument. But it changes the axiom system,
which may affect soundness proofs and other parts of the codebase.

### Approach D: Prove restricted_tc without forward_F (if possible)

Check whether the truth lemma actually requires forward_F for formulas in
deferralClosure(root). If the truth lemma only uses forward_F for formulas of depth >= 1,
then `rr_fwd_chain_forward_F_depth_pos` (sorry-free) suffices.

**Quick check**: The truth lemma's G-case requires forward_F for `neg(psi)` where
`F(neg(psi)) in fam.mcs(t)`. The formula `neg(psi)` has f_nesting_depth 0 when psi
is not of the form F(...). So depth-0 IS needed.

## Files Read

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (lines 1-2290)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (definitions)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (fwd_succ, bwd_pred)
- `Theories/Bimodal/ProofSystem/Axioms.lean` (BX1-BX12)
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (seed consistency)
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` (full file)
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` (sorry analysis)

## Current State

- Phase 1: BLOCKED (mathematical obstacle, not implementation difficulty)
- No code changes made
- All original sorries remain at lines 1517, 1522, 1527
- Dead-code sorries at lines 1413, 1457, 1464, 2196, 2289 also remain
