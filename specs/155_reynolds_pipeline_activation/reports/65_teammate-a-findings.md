# Teammate A: Blocker Analysis and Resolution Paths

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-06-04
**Role**: Primary -- Blocker analysis and resolution path evaluation

## Key Findings

### The Core Problem (Confirmed)

The 3 sorry sites in StaviCompleteness.lean (lines 2353, 2435, 2805) trace to a single root: `nf_2var_existential_transfer` cannot prove 4-variable existential transfer at the 3-point base (u,x,t)/(u',x',t') because:

1. **Zone matching is pointwise**: `zone_match_witness` finds u' with correct NF and orderings relative to (x',t'), but when a 4th point w is zone-matched on (x,t), its orderings relative to u are NOT controlled.

2. **Sub-interval splitting is false**: Counterexample confirmed -- types {A, B, tau, C} arranged differently in M vs M' can make identical interval splitting impossible.

3. **The circularity**: The EF game's `formula_agreement` requires agreement on ALL StaviFormulas of depth <= k, which requires `stavi_expressive_completeness` (the theorem being proved).

### Path Analysis

#### Path A: NF Type Game -- DOES NOT RESOLVE

Defining a simplified game with NF-type matching instead of formula_agreement avoids the circularity of the existing game. However:

- **Composition still hits sub-interval splitting**: After round 1 matches u to u', round 2 needs interval data for (x, u)/(x', u'). This data is NOT derivable from interval data for (x, t)/(x', t').
- **Multi-round game helps but insufficiently**: A k-round Fraisse game on M.carrier could bypass gaps but the sub-interval invariant still fails at the composition step.
- **Estimated effort if attempted**: 300+ lines for game definition + 400+ lines for composition + bridge -- significant for an approach that may not close.

**Verdict**: Not viable without solving the sub-interval invariant problem, which is equivalent to the original problem.

#### Path B: Mutual Induction Restructuring -- PARTIALLY VIABLE

Restructuring to prove formula_agreement at rank k from depth-k NFs:

- **Depth gap problem**: stavi_depth k StaviFormulas have FO depth up to 2k (by `stavi_fo_depth_le_twice_depth`). Depth-k NFs only capture FO-depth-k. So depth-k NF agreement gives formula_agreement at rank floor(k/2), not rank k.
- **Doubling approach**: If hypotheses are strengthened to depth-2k, formula_agreement at rank k is achievable. But this changes the theorem statement and requires threading 2k through the induction.
- **Cross-model chain**: doets_lemma_1_1 (cross-model) + stavi_table_mu_correct (per-model) chain CAN produce cross-model stavi_temporal_truth agreement from NF agreement on the extended structure.

**Verdict**: Mathematically sound but requires significant theorem-level refactoring. Not the simplest path.

#### Path C: Direct Sub-Interval Composition -- IMPOSSIBLE

Proved false by counterexample (confirmed in both handoffs). Types arranged differently in M vs M' while maintaining identical type sets makes splitting impossible.

**Verdict**: Impossible. Do not pursue.

#### Path D: Discrete Specialization -- MOST PROMISING

For discrete orders (IsSuccArchimedean), a critical simplification eliminates the blocker:

**Key Insight**: In discrete models, `ExtendedCarrier M atomMap r` has NO gaps (`discrete_no_gaps`). This means:
1. Every extended carrier element is `Sum.inl p` for some actual point p
2. `mu_holds` is true at every extended carrier element
3. `stavi_temporal_truth_mu M atomMap r (extendPoint p) A = stavi_temporal_truth M atomMap p A` (by `stavi_truth_mu_at_point`)
4. The NFs on `extendedStructureWithMu M atomMap r` at depth d are essentially the NFs on M at depth d (with one extra trivially-true mu atom)

**Consequence**: For discrete models, depth-k 1-var NF agreement on the plain structure implies depth-k NF agreement on the extended structure, which implies formula_agreement at rank floor(k/2).

**Resolution chain**:
1. From depth-k NF agreement at endpoints (hypothesis), derive formula_agreement at rank floor(k/2) via the cross-model chain: doets_lemma_1_1 + stavi_table_mu_correct + stavi_truth_mu_at_point
2. Set up the existing EF game at rank floor(k/2) using the formula_agreement and gap-free extended carrier
3. The game (with composition from `ghr93_strategy_compose`) handles sub-interval splitting
4. Extract NF agreement from the game result
5. Fraisse compression gives depth-k 2-var NF equality

**Why this avoids the circularity**: The circularity was: formula_agreement needs stavi_expressive_completeness. In the discrete case, formula_agreement at rank floor(k/2) comes from depth-k NF agreement via Doets' lemma (a general model theory result), NOT from stavi_expressive_completeness. The game at rank floor(k/2) is sufficient to prove the bridge lemma at depth k, because the Fraisse compression only needs existential transfer at depths j < k, and the game at rank floor(k/2) with enough rounds handles this.

**Critical caveat**: This approach only works for discrete models. The general `nf_characterizable_by_stavi` would still have sorries for non-discrete models. But since the end goal is `completeness_discrete`, this is acceptable.

## Recommended Approach

**Path D (Discrete Specialization)** with the following implementation plan:

### Phase 1: Cross-Model Formula Agreement for Discrete Models (~100 lines)
Prove:
```lean
theorem cross_model_stavi_agree_discrete
    {M M' : OrderedMonadicStructure sig}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier]
    [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier] [NoMinOrder M'.carrier]
    [IsSuccArchimedean M'.carrier]
    {atomMap : Formula -> sig.preds} {k : Nat}
    {p : M.carrier} {q : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => p) = 
            nf_characteristic M' k 1 (fun _ => q))
    (A : StaviFormula) (hA : stavi_depth A <= k / 2) :
    stavi_temporal_truth M atomMap p A <-> stavi_temporal_truth M' atomMap q A
```

Proof structure:
1. Show that for discrete M, extendedStructureWithMu M has carrier = M.carrier (via Sum.inl)
2. Show NF agreement on plain M at depth k implies NF agreement on extended structure at depth k (since gaps are empty and mu is trivially true)
3. Apply doets_lemma_1_1 to get FO agreement at depth k on the extended structure
4. In particular, eval of stavi_table_mu A agrees (since stavi_fo_depth A <= 2 * stavi_depth A <= k)
5. Apply stavi_table_mu_correct for each model to convert to stavi_temporal_truth_mu
6. Apply stavi_truth_mu_at_point to convert to stavi_temporal_truth

### Phase 2: Build EF Game from NF Hypotheses (~150 lines)
Prove that the NF hypotheses (endpoint NFs, orderings, interval types) give the EF game at rank floor(k/2) on the gap-free extended carrier.

### Phase 3: Extract Existential Transfer from Game (~100 lines)
From the game result, extract the existential transfer at all depths j < k needed by nf_fraisse_compression.

### Phase 4: Wire into nf_2var_existential_transfer (~50 lines)
Replace the sorry sites with the game-based proof, adding discrete hypotheses.

### Phase 5: Thread Discrete Hypotheses (~200 lines)
Create `nf_characterizable_by_stavi_discrete` (or add discrete hypotheses to existing theorem chain) and wire through to `completeness_discrete`.

### Estimated Total Effort
~600 lines, 8-12 hours implementation time.

### Risks
1. **Depth arithmetic**: The floor(k/2) bound may be too loose for the Fraisse compression. Need to verify the exact depth relationship: do we need existential transfer at depths j < k, or just at depths j < floor(k/2)?
2. **Extended structure equivalence**: Need to formally prove that discrete models' extended structures are isomorphic to the plain structure (with mu). This may require lemmas about Sum.inl embedding.
3. **Thread-through effort**: Adding discrete hypotheses through the `nf_characterizable_by_stavi` -> `stavi_expressive_completeness` -> `PriorExpressiveness` -> `GoodStructuresModelSurgery` chain may require touching many files.

## Evidence/Examples

### The depth arithmetic (floor(k/2) sufficiency)
- `nf_fraisse_compression` requires existential transfer at depths 0, 1, ..., k-1 for depth-k NF equality
- The game at rank r provides formula_agreement at rank r, giving stavi_depth-r agreement
- stavi_depth r => FO depth 2r => captures all NFs at depth 2r
- With r = floor(k/2), we get NF agreement at depth 2*floor(k/2) >= k-1 (for k >= 1)
- So the game at rank floor(k/2) suffices for depth-k Fraisse compression

### The gap-free carrier equivalence (discrete case)
- `discrete_no_gaps` (Defs.lean:532): IsSuccArchimedean => IsEmpty (Gap T)
- Therefore: RDefinableGap M atomMap r is empty for all r
- ExtendedCarrier M atomMap r = M.carrier + Empty = M.carrier (up to Sum.inl/inr)
- mu_holds (Sum.inl p) = true for all p (actual points are always mu-points)

### Sorry count reduction
- Current: 3 sorry sites (lines 2353, 2435, 2805) affecting `completeness_discrete`
- After Path D: 0 sorries on the `completeness_discrete` critical path
- The general `nf_characterizable_by_stavi` would retain sorries for non-discrete models (acceptable: it's not on the critical path for the current goal)

## Confidence Level

**Medium-High** for Path D. The mathematical argument is sound and the infrastructure (game composition, Doets' lemma, discrete_no_gaps) exists. The main risk is implementation complexity of threading discrete hypotheses through the chain, and the possibility that the depth arithmetic (floor(k/2)) has an off-by-one issue requiring depth-k NFs at endpoints to be replaced with depth-(2k) NFs (which would change the hypotheses of the bridge lemma).

**If the depth arithmetic is off**: Fall back to strengthening the hypotheses. Instead of depth-k NF agreement, require depth-(2k) NF agreement in the bridge lemma. This is a bigger refactoring but is mathematically guaranteed to work.
