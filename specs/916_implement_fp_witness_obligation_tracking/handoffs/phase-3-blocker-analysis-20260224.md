# Phase 3 Blocker Analysis: Omega-Squared F-Persistence Gap

**Date**: 2026-02-24
**Session**: sess_1771951923_ee9d53
**Phase**: 3 (Omega-Squared Construction)

## Blocker Summary

The omega-squared construction (plan v012) has a mathematical gap at the same
location as all previous approaches: **F-formula persistence through Lindenbaum
extensions is not provable, even within the inner chain of an omega-squared
construction.**

## Detailed Analysis

### The Core Problem (Unchanged Across All Approaches)

For ANY chain where `chain(n+1) = Lindenbaum(seed(chain(n)))`:

1. F(psi) = neg(G(neg(psi))) is in chain(n)
2. seed(chain(n)) contains GContent(chain(n)) (for forward_G)
3. The Lindenbaum extension is NONCONSTRUCTIVE (uses Zorn's lemma)
4. The resulting chain(n+1) MAY contain G(neg(psi)), which kills F(psi)
5. Once G(neg(psi)) enters the chain, it persists via the 4-axiom

### Why "Process Immediately" Doesn't Fully Resolve It

The plan says: "Process F(psi) as the VERY FIRST operation BEFORE any
Lindenbaum extension can introduce G(neg(psi))."

This works for ONE F-formula:
- F(psi) in outer(n)
- Immediately create Lindenbaum({psi} union GContent(outer(n)))
- Seed is consistent (by forward_temporal_witness_seed_consistent)
- psi is in the result

But for MULTIPLE F-formulas:
- F(psi_0), F(psi_1), F(psi_2), ... all in outer(n)
- Process F(psi_0) first: inner(n,1) = Lindenbaum({psi_0} union GContent(outer(n)))
- Now process F(psi_1): need F(psi_1) in inner(n,1) for seed consistency
- F(psi_1) was in outer(n) = inner(n,0), but NOT guaranteed in inner(n,1)
- The Lindenbaum extension at step 1 may have introduced G(neg(psi_1))

### Why {psi} union GContent(inner(n,k)) May Be Inconsistent

When F(psi_k) is in outer(n) but we use GContent(inner(n,k)) as seed:

- GContent(inner(n,k)) may be LARGER than GContent(outer(n))
- Larger GContent can conflict with psi_k
- Specifically: Lindenbaum at earlier inner steps may introduce
  G(neg(psi_k)), putting neg(psi_k) in GContent of later inner steps
- Then {psi_k} union GContent(inner(n,k)) contains both psi_k and
  neg(psi_k) (via derivation), making it inconsistent

### Why Using GContent(outer(n)) Breaks forward_G

If we always use GContent(outer(n)) instead of GContent(inner(n,k)):
- Seed is consistent (no new G-formulas from inner steps)
- But GContent(inner(n,k)) is NOT subset of inner(n,k+1)
- forward_G fails between adjacent inner indices

### The FPreservingSeed Alternative

Including {F(chi) | F(chi) in M} in the seed preserves F-formulas but:
1. FPreservingSeed chain never witnesses psi (only preserves F(psi))
2. Combining psi with FPreservingSeed is inconsistent when
   neg(psi) equals some F(chi) in M
3. Concrete counterexample: psi = G(neg(p)), F(p) in M, then
   neg(psi) = neg(G(neg(p))) = F(p) in FPreservingSeed

### Approaches Exhaustively Analyzed

| Approach | Why It Fails |
|----------|-------------|
| Linear chain + GContent seed | F-persistence not guaranteed |
| FPreservingSeed chain | Never witnesses psi (F persists but psi never appears) |
| Combined {psi} + FPreservingSeed | Inconsistent when neg(psi) = F(chi) |
| Omega-squared inner chain | Same F-persistence problem at inner level |
| Dynamic priority scheduling | Still uses Lindenbaum which can kill F-formulas |
| Separate chains for each F-formula | Can't combine into single BFMCS with forward_G |

## What Actually Works (Literature)

Standard completeness proofs for temporal logic use ONE of:

1. **Canonical model approach**: The model has ALL MCSes as worlds with
   GContent-inclusion as the temporal relation. forward_F follows from the
   step lemma directly (each F(psi) in an MCS has a GContent-successor
   containing psi). The LINEAR ORDER on worlds comes from the connectedness
   axioms, not from the chain construction.

2. **Bulldozing** (Blackburn et al.): Operates on the full canonical model
   to produce a linear model. Requires rebuilding from scratch.

3. **Mosaic method** (Marx-Mikulas-Reynolds): Builds from local tiles.
   80-120h effort, no existing infrastructure.

## Recommendation

The bottom-up chain construction approach (building a chain step by step and
trying to prove it satisfies forward_F) is fundamentally blocked. All 12 plan
versions and 16 research reports have converged on the same issue.

The viable path is approach #1: **canonical model with step lemma**. This
requires:

1. Define the canonical temporal model: worlds = all MCSes, relation R where
   M R M' iff GContent(M) subset M'
2. Show R is connected/linear (using temp_a axiom)
3. forward_F follows directly: F(psi) in M means {psi} union GContent(M) is
   consistent, so there exists MCS M' with GContent(M) subset M' and psi in M'.
   Since M R M', this gives the witness.
4. Embed the canonical model into Int (countability + linearity)

This requires a FUNDAMENTALLY different architecture from DovetailingChain.lean.

## Completed Work (Phases 1-2)

Despite the Phase 3 blocker:
- Phase 1: Documentation cleanup completed (TemporalContent.lean GContent
  warning, WitnessGraph.lean misleading comments fixed, TemporalCoherentConstruction.lean
  updated, DO NOT TRY list added to DovetailingChain.lean)
- Phase 2: GContent infrastructure completed (GContent_mono, GContent_path_propagates,
  HContent_mono, HContent_path_propagates - all proven, 0 sorries)
- Build verification: `lake build` succeeds, no new sorries

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - GContent/HContent warnings
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` - Misleading comment fixed
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Status clarified
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - DO NOT TRY list + 4 new lemmas
