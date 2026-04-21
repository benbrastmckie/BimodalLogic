# Handoff: Phase 1 Analysis - fwd_chain_forward_F

## Status: BLOCKED

Phase 1 (`fwd_chain_forward_F`, sorry #1 at line ~1130) requires proving that the preserving forward chain eventually resolves each F-defect. After extensive analysis, the proof is blocked by a gap in the chain construction.

## Key Results Achieved

### 1. F-obligation Monotonicity (PROVED, sorry-free)

**Theorem `fwd_chain_F_obligation_monotone`**: Once F(chi) leaves the forward chain, it never returns.

```
F(chi) not-in chain(n) => F(chi) not-in chain(m) for all m >= n
```

**Proof**: F(chi) not-in chain(n) => G(neg chi) in chain(n) (MCS). By temp_4: G(G(neg chi)) in chain(n). So G(neg chi) in g_content(chain(n)) subset chain(n+1). By induction, G(neg chi) in chain(m) for all m >= n. So F(chi) = neg G(neg chi) not-in chain(m).

**Consequence**: The set S_k = {chi in sigma_list | F(chi) in chain(k)} is non-increasing. It eventually stabilizes at some S_inf.

### 2. Singleton Defect Resolution (PROVED, sorry-free)

**Theorem `singleton_defect_resolved`**: When the active defect list is exactly [phi], the defect_step_choice_early guarantees phi in M'.

This is because `resolving_enriched_fwd_exists` with others = [] produces the target as the resolving witness.

### 3. F-set Non-increasing (PROVED, sorry-free)

**Theorem `fwd_chain_F_set_nonincreasing`**: If F(chi) in chain(m) and n <= m, then F(chi) in chain(n). Contrapositive of monotonicity.

## The Gap

The gap is between "S_k eventually stabilizes" and "S_inf = {phi}".

### What Would Close the Gap

If |S_inf| = 1 (only phi has persistent F-obligation), then:
- active_defects = [phi] at all steps after stabilization
- singleton_defect_resolved gives phi in chain(k+1)
- Contradiction with "phi never resolved"

### Why |S_inf| >= 2 is Problematic

If |S_inf| >= 2, there exist formulas chi != phi with F(chi) in chain(k) for ALL k. At each step, the `defect_step_choice_early` resolves some w from active_defects:

- w in chain(k+1) (resolved)
- For all chi in active_defects: chi in chain(k+1) OR F(chi) in chain(k+1)

Since S stabilized, F(w) must be in chain(k+1) (otherwise w exits S, contradicting stabilization). So w in chain(k+1) AND F(w) in chain(k+1). This is consistent under irreflexive semantics.

The issue: at each step, the resolved w gets F(w) back in the next MCS (through the Lindenbaum extension). The S set never shrinks below S_inf.

### Analysis of BX11 Case Structure

With exactly 2 defects {phi, chi} in S_inf, the BX11 fold gives 3 cases at each step:

- **Case 1**: F(phi AND chi) in chain(k) => both phi and chi in chain(k+1). PHI RESOLVED.
- **Case 2**: F(phi AND F(chi)) in chain(k) => phi in chain(k+1), F(chi) preserved. PHI RESOLVED.
- **Case 3** (with phi as target): F(F(phi) AND chi) in chain(k) => chi in chain(k+1), F(phi) preserved. Phi NOT resolved.

But `bx11_earlier_total` + the fold: if chi beats phi, the fold gives case 2 or 3 (using the `bx11_earlier` definition). The `target_stays_direct_in_fold` theorem requires phi to beat ALL others.

When chi beats phi (case 3-like), the fold resolves chi as the witness and phi gets only F(phi) in M'. At the next step, the same situation can repeat.

**The open question**: Can BX11 case 3 (or equivalently, `bx11_earlier M chi phi`) fire at EVERY step for a fixed pair (phi, chi)? If case 1 or the reverse case 3 fires at some step, phi is resolved. But I could not prove this must eventually happen.

## Recommended Approaches

### Approach A: Chain Redesign with G(neg w) Seed Enrichment

Modify `preserving_fwd_step` to include G(neg w) in the seed for the resolved witness w. This forces F(w) not-in chain(k+1), ensuring w permanently exits S. Then S strictly decreases at each step.

**Challenge**: Need to prove the enriched seed `{beta', G(neg w)} union g_content(M)` is consistent. Under irreflexive semantics, w and G(neg w) are consistent (w now, neg w at all future times). But consistency with g_content(M) needs verification.

### Approach B: Round-Robin + target_stays_direct_in_fold

Redefine the chain to use round-robin targeting. At phi's visit step, use `target_stays_direct_in_fold` if phi beats all other defects. If phi doesn't beat all, accept F(phi) preservation and wait.

**Challenge**: Need to show phi eventually beats all others, or that the non-beating case can't persist.

### Approach C: BX11 Transitivity

Prove that `bx11_earlier` is transitive (making it a total preorder). Then a global minimum always exists, and `target_stays_direct_in_fold` can always be applied with the minimum as target. At each step, the minimum exits S (using Approach A), and the next minimum is resolved.

**Challenge**: Proving transitivity of `bx11_earlier` from the BX axioms.

### Approach D: Quasimodel Run-Composition (Path B from research)

Use the sorry-free `hintikka_chain_exists` infrastructure to build finite chains resolving individual defects, then compose them. This avoids the BX11 termination issue entirely.

**Challenge**: The oracle defect-monotonicity gap needs closing, and a run-composition layer needs building.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`:
  - Added `fwd_chain_F_obligation_monotone` (sorry-free)
  - Added `fwd_chain_F_set_nonincreasing` (sorry-free)
  - Added `singleton_defect_resolved` (sorry-free)
  - `fwd_chain_forward_F` remains sorry (with updated documentation)

## Context for Next Session

- The 5 sorry sites at lines ~1130, ~1161, ~1168, ~1176, ~1183 all depend on sorry #1
- Sorry #1 is the keystone: all others are downstream
- The key mathematical insight (F-obligations don't return) is formalized and sorry-free
- The remaining gap is purely about the BX11 fold termination in the stabilized phase
