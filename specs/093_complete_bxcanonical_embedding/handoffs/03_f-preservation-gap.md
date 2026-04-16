# Handoff: F-Preservation Gap in BXPoint Chain Approach

**Task**: 93 - Complete BXCanonical Embedding
**Session**: sess_1776379144_14819a
**Phase**: 5 (Quasimodel Bridge) IN PROGRESS
**Prior handoffs**: `01_drm-chain-obstacle.md`, `02_quasimodel-bridge-design.md`

## Summary

Extensive analysis of the BXPoint chain approach (designed in handoff 02) reveals a fundamental gap: the `bx_forward_witness` seed `{target} U g_content(w)` does NOT preserve F-formulas across chain steps. This means `F(psi) in chain(t)` does not imply `F(psi) in chain(n)` for later steps `n > t`, making forward_F unprovable with this approach alone.

## The Gap

### BXPoint Chain Seed
```
chain(n+1) = Lindenbaum({target(n)} U g_content(chain(n)))
```

**Guarantees**:
- `target(n) in chain(n+1)` (target resolution -- the BXPoint advantage)
- `bx_le chain(n) chain(n+1)` (g_content propagation)
- `G(alpha) in chain(n) -> alpha in chain(n+1)` (forward_G)

**Does NOT guarantee**:
- `F(psi) in chain(n) -> F(psi) in chain(n+1)` (F-preservation)
- `(phi U psi) in chain(n) -> (phi U psi) in chain(n+1)` (Until persistence)

### Why F-Preservation Fails

`F(psi) = neg(G(neg psi))`. For F(psi) to propagate via g_content, we'd need `G(F(psi)) in chain(n)`, i.e., `G(neg(G(neg psi))) in chain(n)`. This is NOT derivable from `F(psi) in chain(n)`.

The only temporal propagation mechanism in g_content is: `G(alpha) in chain(n) -> alpha in chain(n+1)`. F-formulas are NOT G-formulas.

### Why This Blocks Forward_F

For forward_F: `F(psi) in chain(t) -> exists s > t, psi in chain(s)`.

The round-robin visits psi at step m > t. At step m, `bx_forward_witness` resolves psi IF `F(psi) in chain(m)`. But F(psi) may have been lost at steps t+1, ..., m-1 because the BXPoint chain doesn't include f_carry in its seed.

### Why Adding f_carry Doesn't Work

The combined seed `{target} U g_content(w) U f_carry(w)` may be INCONSISTENT.

Example: if `neg(target) in w` and `F(target) in w` (both possible in an MCS), then:
- `g_content(w) U f_carry(w) subset w`, so `g_content(w) U f_carry(w)` might derive `neg(target)`
- `{target} U g_content(w) U f_carry(w)` derives both `target` and `neg(target)` -> inconsistent

The `bx_forward_witness` consistency proof specifically relies on g_content alone (from which `neg(target)` is NOT derivable when `F(target) in w`).

## Existing Infrastructure Comparison

### enriched_fwd_step (current chain)
- Seed: `{target} U g_content(M) U f_carry(M) U modal_fix(M0)`
- F-preservation: YES (via f_carry and BX11 fold)
- Target resolution: NO (BX11 may defer target, resolving another formula)
- This is the source of the perpetual deferral problem (sorry site 1)

### bx_forward_witness (proposed BXPoint chain)
- Seed: `{target} U g_content(w)`
- F-preservation: NO (only g_content)
- Target resolution: YES (target is directly in the seed)
- This has an F-preservation gap

## Until/Since Coherence Analysis

### Forward Until Coherence
Requires: `(phi U psi) in chain(t) -> exists s >= t, psi in chain(s) and guard`

If `psi in chain(t)`: take s = t (reflexive Until). Guard vacuous.

If `psi not in chain(t)`: by BX9 `phi in chain(t)`, by BX10 `F(psi) in chain(t)`. Need F(psi) to persist to visit step for psi. Same F-preservation gap.

If chain resolves psi IMMEDIATELY at step t+1 (not round-robin): guard is trivially `phi in chain(t)` from BX9. But this requires F(psi) at step t, which we have.

**Insight**: If the chain construction resolves each Until formula's psi in ONE step (instead of waiting for the round-robin), Until coherence is trivially satisfied for the guard. But this conflicts with the round-robin needed for forward_F.

### Backward Until Step Transfer
Requires: `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`

This goes BACKWARD in the chain. Cannot be proved from the BXPoint seed (which only determines forward construction). Would require `phi AND F(phi U psi) -> (phi U psi)` in the MCS at time r, which is NOT derivable from the BX axiom system.

The existing `backward_until_from_step` (UntilSinceCoherence.lean) parameterizes this as a hypothesis. The step transfer must be built into the chain construction.

### Backward Until/Since via existing infrastructure
`backward_until_from_step` and `backward_since_from_step` in UntilSinceCoherence.lean provide the full backward coherence given a step-transfer hypothesis:
```
h_step : forall r, (phi U psi) in fam.mcs (r + 1) -> phi in fam.mcs r -> (phi U psi) in fam.mcs r
```

## Possible Approaches Forward

### 1. Combined Seed with Consistency Proof
Build a chain with seed `{target} U g_content(w) U T` where T is a carefully chosen subset of f_carry that remains consistent with the target. This requires a new consistency proof showing that the combined seed is consistent.

**Feasibility**: Hard. The BX11 fold is the only known mechanism for creating consistent multi-formula seeds, and it doesn't guarantee specific target resolution.

### 2. Two-Pass Chain
1. First pass: build BXPoint chain (with target resolution, no F-preservation)
2. For each F-obligation `F(psi) in chain(t)`: check if psi appears at any chain position s > t
3. If not: modify the chain at the visit step for psi

**Feasibility**: Very hard to formalize. Modifying the chain at one step might break properties at other steps.

### 3. Iterated BXPoint Resolution
At each step, instead of round-robin, resolve the formula with the SMALLEST index in sigma_list that has a pending F-obligation. Within |sigma_list| steps, each formula gets exactly one visit. This avoids the need for F-preservation between visits.

**Key**: At step t with `F(psi) in chain(t)`, the round-robin visits psi at step m > t. Between t and m, other formulas are resolved. F(psi) might not persist. BUT: if we can show that F(psi) persists through the specific sequence of `bx_forward_witness` steps...

Actually, `bx_le chain(k) chain(k+1)` for all k. By transitivity: `bx_le chain(t) chain(m)`. This means `g_content(chain(t)) subset chain(m)`. So `G(alpha) in chain(t) -> alpha in chain(m)`. But F(psi) is NOT a G-formula.

**However**: from `F(psi) in chain(t)`, we can derive `G(P(F(psi))) in chain(t)` by BX4. So `P(F(psi)) in chain(m)` for all m >= t. And `P(F(psi)) in chain(m)` means `F(psi)` held at some past time. This doesn't directly give `F(psi) in chain(m)`.

### 4. Direct Proof of Depth-0 Forward_F for Existing Chain
Instead of building a new chain, prove sorry site 1 for the EXISTING `rr_fwd_chain`. The depth-0 case requires showing that the BX11 fold eventually resolves the target. This would close ALL sorry sites (since 2-6 depend on 1).

**Key mathematical argument**: The BX11 ordering `bx11_earlier` is total on F-defects. At each step, the "earliest" defect is resolved. After resolving it, the remaining defects may re-enter. But the set of F-defects is bounded by |sigma_list|. By a pigeonhole/ordering argument, each defect must eventually be earliest and get resolved.

**Feasibility**: This is the ORIGINAL approach that led to sorry site 1. The codebase already has extensive infrastructure for this (bx11_earlier_total, enriched_fwd_fold_with_witness, etc.). The difficulty is that after resolving one defect, it re-enters immediately (F(psi) in chain(n+1) whenever psi in chain(n+1), by F_of_mem). So the defect set never shrinks.

### 5. Quasimodel-Based Approach (from existing Quasimodel/ directory)
Use the existing HintikkaChain/HintikkaPoint infrastructure to build chains with the right properties. The quasimodel handles Until/Since eventuality resolution correctly.

**Feasibility**: The quasimodel is designed for finite sigma-closure, not for FMCS temporal coherence. Adapting it would require significant bridging work.

## Recommendation

Approach 4 (proving depth-0 forward_F for the existing chain) is likely the most productive. The infrastructure is already in place. The mathematical argument needs:
1. Show that after sufficiently many steps, the BX11 fold MUST resolve the target (not just defer it)
2. Key: the BX11 ordering might cycle, but the enriched seed's resolving property guarantees SOME formula is resolved at each step. Over |sigma_list| steps, EACH formula is targeted. If the fold always defers the target, it must resolve ALL other formulas first, eventually making the target the only remaining defect.

But: ALL other formulas re-enter as defects immediately after resolution (F_of_mem). So the "other formulas resolved" argument doesn't work as stated.

A deeper mathematical insight is needed. Perhaps:
- Use the FINITE BX11 ordering to show that after a bounded number of deferrals, the ordering shifts and the target becomes earliest
- Use the fact that f_nesting_depth is 0 to show that the target can't be indefinitely dominated by other formulas
- Use absorption (BX6) or linearity (BX7) to show that perpetual deferral of a depth-0 formula leads to a contradiction

## Files

Key source files:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (sorry sites, chain construction)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (BXPoint, bx_le, bx_forward_witness)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` (eventuality resolution)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (backward Until from step transfer)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (restricted coherence definitions)
