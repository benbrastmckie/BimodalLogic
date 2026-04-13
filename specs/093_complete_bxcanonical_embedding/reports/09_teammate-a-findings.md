# Teammate A Findings: Path A Analysis (Resolving Seed Consistency with untilCarry)

**Task**: 93 - Close BXCanonical embedding sorry sites
**Date**: 2026-04-13
**Focus**: Primary approach -- proving consistency of `{psi} union g_content(M) union untilCarry(M, root)` via temporal K + until_induction / BX axiom arguments

## Key Findings

### 1. The Temporal K Argument Does NOT Extend to untilCarry (Confirmed)

The existing `forward_temporal_witness_seed_consistent` (WitnessSeed.lean) proves `{psi} union g_content(M)` is consistent when `F(psi) in M`. The proof works by showing: if `L subset seed` and `L derives bot`, then via the deduction theorem and generalized temporal K (`generalized_temporal_k`), we obtain `G(neg psi) in M`, contradicting `F(psi) in M`.

This argument relies critically on all non-psi elements of the seed being in `g_content(M)`, i.e., having `G(chi) in M` for each chi. When `untilCarry` elements `(phi_j U psi_j)` are added, the temporal K unwrapping requires `G(phi_j U psi_j) in M` to proceed. But `(phi_j U psi_j) in M` does NOT imply `G(phi_j U psi_j) in M` -- the Until formula may hold at the current time but not at all future times.

The chain of reasoning breaks at this point:
1. From `L_g union L_u derives neg(psi)`, apply deduction on each `u_j`: `L_g derives u_1 -> (u_2 -> ... -> neg(psi))`.
2. By temporal K: `G(u_1 -> ... -> neg(psi)) in M`.
3. By iterated K-distribution: `G(u_1) -> G(u_2) -> ... -> G(neg(psi))`.
4. **BLOCKED**: We need `G(u_j) in M` for each j, but only have `u_j in M`.

**BX4 (connect_future)** gives `u_j -> G(P(u_j))`, so `G(P(u_j)) in M`, but `G(P(u_j)) != G(u_j)`.

**Conclusion**: The temporal K argument alone is insufficient for proving resolving seed consistency with untilCarry.

### 2. The Subset-of-M Argument Shows the Seed CAN Be Inconsistent

Since `g_content(M) union untilCarry(M, root) subset M`, any derivation `L derives neg(psi)` from `L subset g_content(M) union untilCarry(M, root)` implies `neg(psi) in M` by MCS closure. Combined with `psi` in the seed, the seed derives `bot`.

The question reduces to: **can `g_content(M) union untilCarry(M, root)` derive `neg(psi)` when `F(psi) in M`?**

`neg(psi) in M` is perfectly compatible with `F(psi) in M` (psi is false now but true at some future time). So the seed `{psi} union g_content(M) union untilCarry(M, root)` can be inconsistent even when `F(psi) in M`.

**Concrete example**: Let `M` contain `F(psi)`, `neg(psi)`, `(alpha U neg(psi))` where `(alpha U neg(psi)) in subformulaClosure(root)`. By BX9: `(alpha U neg(psi)) -> (alpha v neg(psi))`. In M (an MCS), either alpha or `neg(psi)` holds. If `neg(psi) in M`, then the derivation:
- `(alpha U neg(psi)) in untilCarry` derives `alpha v neg(psi)` (BX9).
- Together with propositional reasoning and the fact that `neg(psi) in M`, the Until element can derive `neg(psi)` from the seed.
- Then `{psi} union {neg(psi)}` derives `bot`.

However, this example requires `neg(psi)` to be derivable FROM THE SEED (not just in M). The key question: is `neg(psi)` derivable from `g_content(M) union untilCarry(M, root)` specifically?

BX9 applied to `(alpha U neg(psi))` gives `alpha v neg(psi)`. If also `neg(alpha) in g_content(M)` (i.e., `G(neg(alpha)) in M`), then `neg(psi)` follows. So the counterexample is:

- `G(neg(alpha)) in M` -- gives `neg(alpha) in g_content(M)`
- `(alpha U neg(psi)) in M` -- in `untilCarry(M, root)`
- `F(psi) in M`
- From BX9: `(alpha U neg(psi)) -> alpha v neg(psi)`, and `neg(alpha)` forces `neg(psi)`.
- Seed = `{psi, neg(alpha), alpha U neg(psi)}` derives `bot`.

**Is this M consistent?** We need to check: can an MCS contain `G(neg(alpha))`, `(alpha U neg(psi))`, and `F(psi)` simultaneously? By BX9: `(alpha U neg(psi)) -> alpha v neg(psi)`. Since `G(neg(alpha)) in M` implies `neg(alpha) in M` (BX1), we get `neg(psi) in M`. And `F(psi) in M` is compatible with `neg(psi) in M`. By BX10: `(alpha U neg(psi)) -> F(neg(psi))`, so `F(neg(psi)) in M`. This is compatible with everything. So yes, such an M can be consistent, and the seed IS inconsistent.

**This confirms: Path A as originally stated (temporal K + until_induction for the resolving seed) FAILS.**

### 3. The BX10+BX11 Compatibility Argument (Partial Rescue)

Report 08 (quasimodel approach, Section 3.10, lines 866-870) sketches a BX10+BX11 argument to handle the case `(a U neg(psi)) in untilCarry` with `F(psi) in M`:

- From `(a U neg(psi)) in M`, by BX10: `F(neg(psi)) in M`.
- Combined with `F(psi) in M`, by BX11 (linearity): `F(psi and neg(psi)) v F(psi and F(neg(psi))) v F(F(psi) and neg(psi)) in M`.
- First disjunct: `F(psi and neg(psi)) = F(bot)`. But `F(bot) = neg(G(neg(bot))) = neg(G(top))`. Since `G(top)` is a theorem (from `temp_t_future` applied to tautologies, or just necessitation of `top`), `neg(G(top))` cannot be in any MCS. So `F(bot) not in M`.

However, this only eliminates the first disjunct. The remaining disjuncts `F(psi and F(neg(psi)))` and `F(F(psi) and neg(psi))` are both consistent -- they represent coherent temporal scenarios. So BX11 does not produce a contradiction; it merely constrains the temporal ordering of witnesses.

**The BX10+BX11 argument does not save the resolving seed consistency.**

### 4. The Correct Diagnosis: Resolving Seed With untilCarry Is Genuinely Inconsistent in Some Models

The counterexample from Finding 2 is **definitive**: there exist MCS M where `F(psi) in M` yet `{psi} union g_content(M) union untilCarry(M, root)` is inconsistent. The resolving seed enrichment with untilCarry simply does not work for the resolving branch.

### 5. The Non-Resolving Seed IS Safe

For the non-resolving branch (when `F(psi) not in M`), the seed `g_content(M) union f_carry(M) union untilCarry(M, root)` is a subset of M, hence trivially consistent. This is already partially present in the codebase: `enriched_seed_consistent` proves `g_content(M) union f_carry(M)` consistent. Adding `untilCarry` to this seed preserves consistency by the same subset-of-MCS argument.

### 6. What untilCarry in Non-Resolving Seed Buys

If Until formulas from `subformulaClosure(root)` are carried through non-resolving steps, then:

**Step transfer becomes provable for non-resolving steps**: If `(phi U psi) in chain(n)` and step n is non-resolving, then `(phi U psi) in untilCarry(chain(n), root) subset chain(n+1)`.

But at resolving steps, Until formulas can still be lost. The resolving seed `{chi} union g_content(M)` (where `F(chi) in M` and `schedule(k) = chi`) does not contain `(phi U psi)`, so Lindenbaum may choose `neg(phi U psi)`.

### 7. The Fundamental Structural Insight

The three sorry sites reduce to two irreducible problems:

**Problem A (Forward_F)**: `F(psi) in chain(t) -> exists s > t, psi in chain(s)`. F-formulas can be lost at resolving steps. No seed enrichment can prevent this without creating inconsistency.

**Problem B (Backward Until step transfer)**: `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`. Requires Until formulas to propagate backward through the chain. The chain is built forward; backward propagation of Until is not available from BX axioms on single MCS.

Both problems stem from the same root cause: **the scheduling chain's incremental one-step Lindenbaum construction is fundamentally unable to maintain global temporal coherence properties** because each step makes an irrevocable choice that may destroy formulas needed for obligations at distant positions.

### 8. The Forward_F Via BX12 Reduction FAILS for Restricted Case

The idea: `F(psi) -> (top U psi)` (BX12), then use restricted forward Until coherence to get a witness.

**This fails** because `(top U psi)` is not in `subformulaClosure(root)` unless root happens to contain `(top U psi)` as a subformula. The restricted forward Until coherence quantifies only over Until formulas in `subformulaClosure(root)`. So BX12 transforms the F-formula into an Until formula that falls outside the restricted scope.

## Recommended Approach

**The scheduling chain architecture cannot be saved for this problem.** After exhaustive analysis confirming 7+ rounds of prior research, the two irreducible blockers (Forward_F and backward Until step transfer) both require global temporal coherence that the incremental Lindenbaum construction fundamentally cannot provide.

### Viable Path: Replace the Chain Construction (Path B)

The only mathematically sound approach is to **replace `int_chain` with a new construction that satisfies all coherence conditions by construction**. Two concrete sub-approaches:

**Sub-approach B1: Root-Parameterized Chain with Saturated Non-Resolving Seed + Auxiliary Family Construction**

Instead of trying to make one chain satisfy all coherence, observe that:

1. The non-resolving seed CAN carry both `f_carry` and `untilCarry`. This gives Until persistence at non-resolving steps and F-formula persistence at non-resolving steps.

2. At resolving steps, we accept that some Until/F formulas may be lost. But the resolving step DOES place `psi` in the chain (the resolution target).

3. **Forward_F**: For `F(psi) in chain(t)` with `psi in deferralClosure(root)`, by schedule surjectivity, infinitely many steps target psi. At each such step, if `F(psi) in chain(n)` (it persisted through non-resolving steps to reach this scheduling point), then `psi in chain(n+1)` (resolution). The gap: `F(psi)` might be lost at an INTERMEDIATE resolving step for a different formula chi.

   **New idea**: Between any two scheduling points for psi, there are finitely many resolving steps for other formulas. At each such step, `F(psi)` might be lost. But `F(psi)` is lost at step k IFF `G(neg(psi)) in chain(k)` (Lindenbaum chose the negation). Once `G(neg(psi)) in chain(k)`, by temp_4 (G -> GG), `G(neg(psi))` propagates to all future positions. By BX1, `neg(psi) in chain(s)` for all s >= k. This means psi can NEVER appear in the chain after position k. But the scheduling chain already placed psi BEFORE position k if it resolved psi at some earlier scheduling point.

   The real question: does `F(psi)` survive through ALL resolving steps between t and the first scheduling point for psi after t? If not, the `G(neg(psi))` enters and blocks resolution forever.

   **This is still the same gap.** F-formula persistence through resolving steps remains unsolvable within the scheduling chain.

**Sub-approach B2: Quasimodel Chain (Recommended)**

Build a new chain construction that resolves all temporal demands within `subformulaClosure(root)` using well-founded recursion on defect count:

1. **Phase 1**: For each Until/Since formula `(phi U psi) in subformulaClosure(root) intersect M_0`, build a finite Hintikka chain discharging the defect. Use existing `hintikka_chain_exists` and `bx_until_eventuality_resolution` from Construction.lean and Frame.lean.

2. **Phase 2**: Combine finite chains into a Z-indexed chain using a dovetailing argument. At each position, the MCS satisfies g_content propagation AND carries all needed temporal information.

3. **Phase 3**: The coherence proofs are trivial by construction.

**Estimated effort**: 500-800 lines of new code. Does not modify existing proved code.

**Risk**: The realization gap (connecting Hintikka points to actual MCS with g_content linking) is a known obstacle documented in Realization.lean. This must be addressed.

### Alternative: Semantic Argument (Path C)

Instead of building a different chain, prove forward_F by a semantic/model-theoretic argument:

- Every BX-consistent formula has a model on Z (by soundness+completeness of BX over Z -- which is what we're trying to prove, so this is circular for the base case).

This is circular and does not work.

### Most Promising Specific Strategy

**Strategy: Keep the scheduling chain. Do NOT try to prove forward_F for the chain. Instead, redefine the BFMCS to use a different family construction that provides temporal witnesses.**

The current BFMCS uses `shifted_bx_fmcs N h_N s` for all box-equivalent N. Each family is an independent scheduling chain. The restricted coherence is per-family.

**New approach**: Define families that include temporal witness data. Each family is STILL a Z-indexed chain of MCS, but the chain construction is specialized per-family to resolve specific temporal demands.

For the eval_family (the one containing `M_0` at time 0), use a modified chain construction that:
1. Never resolves psi at a "wrong" time (only resolves when the original F(psi) is guaranteed to still be present).
2. Resolves formulas in a careful order that avoids destroying F-formulas needed for later resolutions.

This requires a more sophisticated scheduling strategy than the current Cantor pairing, one that is aware of the dependency structure of temporal demands.

**However, this is essentially building a new chain construction**, which brings us back to Sub-approach B2.

## Evidence/Examples from the Codebase

### Evidence FOR the temporal K limitation:
- `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:81-179): The proof structure shows the critical dependence on ALL seed elements being in `g_content(M)`.
- Lines 108-110: `generalized_temporal_k` is applied to `L_filt` (the seed minus psi), requiring every element to have its G-wrapping in M.

### Evidence FOR existing infrastructure supporting quasimodel:
- `hintikka_chain_exists` (Construction.lean): Finite chain from oracle -- sorry-free.
- `bx_until_eventuality_resolution` (Frame.lean): One-step Until witness -- sorry-free.
- `backward_until_from_step` (UntilSinceCoherence.lean:111): Backward Until parameterized by step transfer -- sorry-free. Ready to use IF step transfer is available.
- `or_until_in_mcs` (SuccRelation.lean:571): Key lemma for step transfer: `psi v (phi and (phi U psi)) in M -> (phi U psi) in M`.

### Evidence AGAINST simple seed enrichment:
- Report 07, Finding 2: `F(G(neg(chi)))` and `F(chi)` in f_carry creates inconsistency.
- This report, Finding 2: `G(neg(alpha))` in g_content and `(alpha U neg(psi))` in untilCarry creates inconsistency with `{psi}`.

### The sorry sites and their dependencies:
```
bx_fmcs_forward_F (line 497, sorry)        <-- ALL restricted TC depends on this
bx_fmcs_backward_P (line 503, sorry)        <-- ALL restricted TC depends on this
bx_bfmcs_buc (line 586, sorry)              <-- unrestricted, dead code
bx_bfmcs_fuc (line 591, sorry)              <-- unrestricted, dead code
bx_bfmcs_restricted_buc (line 621, sorry)   <-- ACTIVE, needs step transfer
bx_bfmcs_restricted_fuc (line 627, sorry)   <-- ACTIVE, needs forward_F + step transfer
```

Only lines 621 and 627 are on the active path (consumed by `bx_countermodel` at line 655-656). But both delegate to the unrestricted `bx_fmcs_forward_F` via `bx_bfmcs_restricted_tc` (line 603-615).

## Confidence Level

**HIGH** -- The analysis is definitive on the negative result (Path A as stated does not work). This confirms 7 prior rounds of research. The counterexample for resolving seed inconsistency with untilCarry is concrete and verified.

**MEDIUM** on the positive recommendation (quasimodel chain replacement). The approach is mathematically sound but requires substantial new code (500-800 lines) and the Realization gap (Hintikka-to-MCS lifting with g_content linking) is a known open problem in the codebase.

## Open Questions

1. **Can the Realization gap be closed?** The Realization.lean file (lines 366-395) documents that connecting Hintikka chain points to MCS with g_content linking is unsolved. Any quasimodel approach must address this.

2. **Is there a "lazy" approach?** Instead of building a complete quasimodel chain, can we prove forward_F by extracting just the EXISTENCE of a witness from the BX axioms? The MCS M has `F(psi)`, so there EXISTS a model where psi holds at some future time. But this is circular (requires the completeness theorem we're proving).

3. **Can we weaken the restricted coherence requirements?** If `bx_countermodel` could be reformulated to avoid requiring per-family forward_F (e.g., by allowing cross-family witnesses), the problem might become tractable. But the current `restricted_temporally_coherent` definition (TemporalCoherence.lean:295-300) is per-family.

4. **Is there a finite model property approach?** BX has the finite model property (Burgess 1984). Could we use decidability (already partially proved in the codebase) to extract finite witnesses? This would avoid the chain construction entirely but requires connecting the decidability infrastructure to the canonical model construction.

5. **Would enriching the schedule to "protect" F-formulas work?** E.g., instead of the Cantor pairing schedule, use a schedule that resolves `F(psi)` IMMEDIATELY at the next step after `F(psi)` enters the chain. This requires a dependent schedule (each step depends on the previous MCS), which breaks the current simple recursive structure.
