# Teammate B Findings: Porting Chain Construction INTO BXCanonical

- **Task**: 83 - Close Restricted Coherence Sorries
- **Angle**: Viability of modifying BXCanonical to incorporate chain construction
- **Date**: 2026-04-07
- **Sources**: Frame.lean, TruthLemma.lean, Completeness.lean, Axioms.lean, Bundle/FMCSDef.lean, Bundle/SuccChainFMCS.lean, Bundle/WitnessSeed.lean, Bundle/TemporalContent.lean, Reports 35-38

## Key Findings

### 1. Can We Change the Quantification? No -- Signature Is Load-Bearing

The 4 sorry stubs in Frame.lean quantify over ALL BXPoints:

```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

This signature is consumed directly by `until_iff_mcs` and `since_iff_mcs` in TruthLemma.lean (lines 281-307 and 315-357). These in turn provide the biconditional needed by any truth lemma that maps MCS membership to semantic truth.

**Changing the quantification to "only chain members" would break the truth lemma.** The semantic definition of Until in Truth.lean quantifies over ALL time points in the model, not just chain members. The truth lemma must establish an equivalence between formula membership and semantic truth. If the canonical model contains all BXPoints as potential evaluation points, the guard must hold at all of them.

The only way to restrict the quantification is to restrict the MODEL -- build a canonical model whose points ARE chain members. This is exactly what a ChainCanonical module does: it replaces BXPoint (all MCS) with chain members (a specific linear sequence of MCS).

### 2. Can We Prove Universal Guard from Chain Membership? No

Report 37 conclusively establishes that `phi U psi` does not propagate through `g_content`. The self-accumulation BX5 gives `(phi AND (phi U psi)) U psi in w`, but this enriched formula also fails to propagate because:

- `G(alpha U beta)` does not follow from `alpha U beta` (semantically invalid: Until is consumed at the witness)
- `P(phi U psi) in u` (from BX4 + g_content propagation) only gives an existential backward witness, not `phi U psi in u` itself
- BX7 linearity operates on Until formulas within a single MCS, not across the MCS ordering

The fundamental obstacle: an arbitrary BXPoint u with `bx_le w u` and `bx_le u v` need not lie on any chain from w to v. The g_content preorder is a preorder (reflexive + transitive) but provably NOT total. Two BXPoints above w can be incomparable under bx_le.

### 3. BX7 and Interval Linearity: Cannot Establish Totality

BX7 (Axioms.lean line 174-184):
```
(phi U psi) AND (chi U theta) ->
  ((phi AND chi) U (psi AND theta)) OR
  ((phi AND chi) U (psi AND chi)) OR
  ((phi AND chi) U (phi AND theta))
```

BX7 orders witnesses of Until formulas WITHIN a single MCS. It says: if two Until formulas both hold at a point, their witnesses are linearly arranged. But it does NOT imply that two arbitrary BXPoints above w are bx_le-comparable.

**Why BX7 fails to give interval linearity:**
- bx_le(w, u1) and bx_le(w, u2) means g_content(w) is in both u1 and u2
- To show bx_le(u1, u2) or bx_le(u2, u1), we need g_content(u1) subset of u2 OR g_content(u2) subset of u1
- This is a statement about infinitely many formulas (all G-formulas in u1 or u2)
- BX7 only constrains formulas that appear as Until-pairs within a single MCS
- Formulas in g_content(u1) need not be expressible as Until witnesses in any common MCS

Report 37 Section 5.3 confirms: "bx_le can be non-linear in the abstract canonical model."

### 4. Effort Comparison: Path A (Fix Bundle) vs Path B (Fix BXCanonical)

#### Path A: New ChainCanonical Module (Bypass BXCanonical)

| Item | Estimate |
|------|----------|
| New files | 3-4 files (Chain.lean, ChainWorldHistory.lean, TruthLemma.lean, Completeness.lean) |
| New LOC | 800-1200 |
| Bundle reuse | ~60% (WitnessSeed, TemporalContent, g_content infrastructure) |
| BXCanonical changes | None (left as-is with sorries, becomes unused) |
| Risk | LOW -- follows standard Burgess construction, chain is linear by design |
| Bundle sorry count | 57 sorries across 11 files -- NOT required to fix, can build independently |

#### Path B: Fix BXCanonical Directly

| Item | Estimate |
|------|----------|
| Feasibility | **MATHEMATICALLY IMPOSSIBLE** in current architecture |
| Root cause | bx_le preorder is not total; Until doesn't propagate through g_content |
| BX7 linearity | Operates within MCS, not across MCS ordering |
| No valid axiom addition helps | Report 37 proves no sound interaction axiom suffices |

**Path B is definitively ruled out.** Reports 35-37 provide conclusive evidence:
- Burgess-Xu axiom 4 is semantically invalid under half-open guards (3-point countermodel)
- No valid variant is strong enough (all are existential P-based, too weak)
- BX5 self-accumulation doesn't propagate through g_content
- Interval linearity of bx_le is unprovable from BX1-BX10

### 5. Hybrid Possibility: BXCanonical Using Bundle's FMCS Internally

A hybrid approach would keep the BXCanonical truth lemma for Box/G/H (which is fully proved) and route Until/Since through a chain construction. Concretely:

**What works in BXCanonical:**
- `bot_not_in_mcs`, `imp_iff_mcs` -- fully proved
- `G_iff_mcs`, `H_iff_mcs` -- fully proved (using bx_G_forward/backward, bx_H_forward/backward)
- `box_iff_mcs` -- fully proved (using bx_modal_witness)
- `until_iff_mcs`, `since_iff_mcs` -- structurally complete, delegates to 4 sorry stubs

**The hybrid problem:** The truth lemma uses structural induction on formulas. The Box/G/H cases use the abstract BXPoint model (all MCS). The Until/Since cases would need a chain-based model. But a single model cannot be both "all MCS" (for Box) and "chain members only" (for Until). The evaluation points must be the same for all formula cases.

**Resolution:** The chain-based model IS a subset of all MCS. Box/G/H truth at chain members is provable from the same MCS properties (it's the same proof, restricted to chain MCS). So a ChainCanonical module replaces BXCanonical entirely -- it doesn't need BXCanonical's infrastructure.

**Verdict:** A true hybrid is architecturally incoherent. The correct approach is a clean ChainCanonical module that reproves Box/G/H on chain members (trivial, since these proofs only use MCS properties available at chain points) and adds the chain-based Until/Since proof.

## Recommended Approach

**Build a new ChainCanonical module (Path A).** This is the ONLY viable path.

1. The 4 BXCanonical sorries are **unfillable** in the current architecture (conclusive per reports 35-37)
2. The chain construction resolves ALL 4 sorries by making linearity structural rather than derived
3. The Box/G/H truth lemma reproofs on chain members are straightforward (reuse MCS property lemmas from BXCanonical/Frame.lean)
4. The 1 sorry in Completeness.lean (TaskModel embedding) is also resolved by the chain-to-WorldHistory mapping (report 38 Section 2.1)
5. Bundle infrastructure (g_content, WitnessSeed, TemporalContent) provides ~60% reuse

**Architecture:**
```
Metalogic/ChainCanonical/
  Chain.lean          -- ℤ-indexed chain with enriched-Succ seeds
  WorldHistory.lean   -- Chain → WorldHistory + Omega bundle
  TruthLemma.lean     -- Full truth lemma (all formula cases on chain)
  Completeness.lean   -- Wire to validity theorem
```

## Evidence/Examples

**Evidence that chain resolves the guard:**

In the chain construction, points are w_0, w_1, ..., w_n with explicit ordering. Given `phi U psi in w_0` and witness w_n (with `psi in w_n`):

- At each w_i (0 <= i < n): seed includes `phi U psi`, so `phi U psi in w_i`
- Since `psi not in w_i` (chosen by construction for i < n): BX9 gives `phi in w_i`
- Guard verified at ALL points in the model (which are exactly the chain members)

The quantifier `for all u between w and v` becomes `for all w_i with 0 <= i < n`, which is trivially satisfied by the seed construction.

**Evidence from existing infrastructure:**

- `forward_temporal_witness_seed_consistent` (WitnessSeed.lean) already proves consistency of `{psi} UNION g_content(M)` seeds
- `g_content_closed_derivation` (Frame.lean) already proves G-formula derivation from seed membership
- `FMCS` structure (FMCSDef.lean) already encodes the forward_G/backward_H coherence
- `succ_chain_fam` (SuccChainFMCS.lean) already builds ℤ-indexed chains from enriched Succ seeds

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Chain seed consistency for enriched seeds (including Until formulas) | MEDIUM | Partially covered by WitnessSeed; extend with Until-specific consistency argument using BX10 |
| Backward direction (bx_until_backward) | MEDIUM | Report 38 identifies contradiction approach via negation unfolding as cleanest path |
| Box truth lemma reproof on chain | LOW | Same MCS properties; trivial adaptation |
| Bundle's 57 sorries contaminating ChainCanonical | LOW | ChainCanonical can be built independently, reusing only sorry-free lemmas from Bundle |
| LOC estimate undercount | MEDIUM | 800-1200 LOC assumes heavy reuse; if seed consistency is harder than expected, could reach 1500 |

## Confidence Level

**HIGH** (9/10) on the core conclusion: the BXCanonical sorries are unfillable and a ChainCanonical module is the correct path. This is supported by:
- 3 independent research reports (35, 36, 37) reaching the same conclusion
- Team synthesis (38) with 3 teammates converging
- Explicit countermodels proving semantic invalidity of needed axioms
- Standard literature (Burgess 1984, Goldblatt 1992) using chain construction

**MEDIUM-HIGH** (7/10) on effort estimates. The 800-1200 LOC range assumes the enriched seed consistency proof goes smoothly, which is the main technical uncertainty.
