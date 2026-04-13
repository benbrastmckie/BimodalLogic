# Handoff: Forward_F Obstacle Analysis

## Status

All 4 sorry sites in CanonicalModel.lean depend on proving `bx_fmcs_forward_F` (or its restricted variant). After extensive analysis, this theorem is **unprovable for the current scheduling chain construction**.

## Root Cause

The scheduling chain `fwd_chain` uses `fwd_succ(M, hM, schedule(n))` at each step:
- **Resolving step** (F(schedule(n)) in chain(n)): seed = `{schedule(n)} union g_content(chain(n))`
- **Non-resolving step**: seed = `g_content(chain(n)) union f_carry(chain(n))`

F-formulas persist through non-resolving steps (via f_carry). But at resolving steps for OTHER formulas chi != psi, F(psi) is NOT in the seed `{chi} union g_content(M)`. The Lindenbaum extension (Classical.choice) may or may not include F(psi).

Once F(psi) is lost (G(not psi) appears), it is lost PERMANENTLY: G(not psi) propagates forward via g_content (BX4: G -> GG), so F(psi) = not G(not psi) is excluded from all future chain positions.

## Why Enriching the Resolving Seed Fails

Adding f_carry(M) to the resolving seed (`{chi} union g_content(M) union f_carry(M)`) can create INCONSISTENCY.

**Concrete counterexample**: If G(F(alpha) -> not psi) in M and F(alpha) in M and F(psi) in M, then:
- (F(alpha) -> not psi) in g_content(M)
- F(alpha) in f_carry(M)
- Together with psi in the seed: derives bot

This scenario IS realizable in BX temporal logic.

## Why Choosing a Different Extension Fails

Even trying to pick a Lindenbaum extension that contains F(psi): `{chi} union g_content(M) union {F(psi)}` can be inconsistent when G(chi -> G(not psi)) in M, because:
- (chi -> G(not psi)) in g_content(M)
- chi in seed
- Therefore G(not psi) derivable from seed
- F(psi) = not G(not psi) contradicts this

## Viable Solutions (for future work)

### Option A: Quasimodel-Based FMCS (Recommended)

Replace the entire chain construction with a quasimodel-based one (Reynolds/Burgess approach):
1. Build finite Hintikka chains within deferralClosure(root)
2. Each chain step discharges one defect while preserving all others (within the finite closure)
3. Concatenate the finite chains with identity tails to form the Int-indexed FMCS
4. Forward_F holds BY CONSTRUCTION (defects are discharged in finite steps)

This requires ~300-500 lines of new code and replacing `bx_bfmcs` with a new construction.

### Option B: Non-Constructive Existence

Prove the existence of an Int-indexed chain with ALL required properties (forward_G, backward_H, forward_F, backward_P, forward_until, backward_until) using Zorn's lemma or compactness. This avoids the constructive scheduling chain entirely but requires a complex consistency/compactness argument.

### Option C: Modified Schedule

Use a schedule that ONLY does non-resolving steps (preserving f_carry) and relies on the Lindenbaum extension to non-deterministically resolve F-formulas. Then prove by compactness that for SOME choice function (among the non-deterministic Lindenbaum choices), all F-formulas get resolved. This requires a meta-argument about the space of choice functions.

## Impact on 4 Sorry Sites

| Sorry Site | Dependency |
|-----------|-----------|
| bx_fmcs_forward_F (497) | Direct: unprovable for current chain |
| bx_fmcs_backward_P (503) | Symmetric: same obstacle for backward direction |
| bx_bfmcs_restricted_fuc (627) | Depends on forward_F (for F(psi) witness in Until case) |
| bx_bfmcs_restricted_buc (621) | Depends on step transfer, which depends on chain properties |
| bx_bfmcs_restricted_tc (603-615) | Delegates to forward_F / backward_P |

## Files Analyzed

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (660 lines)
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (forward_temporal_witness_seed_consistent)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (restricted coherence defs)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (backward_until_from_step)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (bx_forward_witness)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/*.lean` (existing quasimodel infrastructure)
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/*.lean` (defect chain infrastructure)
