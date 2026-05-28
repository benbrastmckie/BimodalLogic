# Case II GHR93 U(B,sf_top) Implementation Handoff

## Status
Analysis complete. No code changes committed (reverted sub-interval approach per user directive). Infrastructure gap identified.

## The Problem
`CaseAnalysis.lean:1243` — the sorry inside `ghr93_case_II`. This is the core Case II proof body.

## Approach Required: GHR93 U(B,sf_top) Formula Transfer

Per user directive, use the GHR93 characteristic formula approach, NOT sub-interval composition.

### The Formula Transfer Strategy

Given: Spoiler picks a_init(0) < ... < a_init(n-1) ≤ p_n in [d, y']. p_n = a_bwd(n) is a carrier point.

1. **Build B_pn**: characteristic formula for p_n's rank-r type
   - Use `nf_characterizable_by_stavi atomMap h_surj r nf_pn` where `nf_pn` is p_n's depth-r NormalForm
   - `stavi_depth B_pn ≤ r` (from the construction in StaviCompleteness.lean)
   - B_pn characterizes p_n: for any carrier point q, `stavi_temporal_truth M atomMap q B_pn ↔ nf_eval_nf M r 1 (fun _ => q) nf_pn`

2. **Build phi**: `phi = .std_untl B_pn sf_top` ("there exists a point above me satisfying B_pn")
   - `stavi_depth phi = max(stavi_depth B_pn, 0) + 2 ≤ r + 2`

3. **Establish phi at a_init(k) in N**: When `a_init(k) < p_n`, phi holds at a_init(k) witnessed by p_n (p_n > a_init(k) and B_pn holds at p_n by construction)

4. **Transfer phi through tau at rank r+delta**: 
   - `props.tau` operates at rank r+delta on rank-embedded positions
   - Formula agreement at depth ≤ r+delta includes phi (since r+2 ≤ r+delta, from hd : 2 ≤ delta)
   - Play props.tau with rank-embedded a_init; extract formula agreement at rank-embedded positions
   - phi at rank-embedded a_init(k) ↔ phi at rank-embedded resp_tau_rdelta(k)

5. **Extract witness z**: phi at resp_tau_rdelta(k) in M means there exists carrier point z > resp_tau_rdelta(k) with B_pn(z). Project z back to rank r.

6. **Establish sel_pn_ord**: z has the same rank-r type as p_n. Since e_n also has rank-r formula agreement with p_n (from the forward game), z and e_n have the same rank-r type. The ordering `resp(k) < z` and `resp(k) ∈ [c, y]`, combined with e_n's properties, gives `resp(k) < e_n`.

### Wait — Step 6 has a gap

Having z > resp(k) with the same rank-r type as e_n does NOT directly give resp(k) < e_n. z could be a DIFFERENT point with the same type as e_n but at a different position. Two points with the same rank-r formula type can be at different positions in the linear order.

This gap needs careful handling. Options:
- Show z ≤ e_n (since z satisfies B_pn and is in [c, y], and e_n is the "corresponding" point from the forward game)
- Use the full NormalForm 2-variable type to establish ordering (but this requires more infrastructure)
- Use a different argument structure

Actually, the correct argument for sel_pn_ord from GHR93:
- For the FORWARD direction (a_init(k) < p_n → resp(k) < e_n): phi at resp(k) gives z > resp(k) with B_pn(z). Since z ∈ [c, y] and z > resp(k) ≥ c, we have z ∈ (resp(k), y]. Now e_n ∈ [c, y]. We need to show resp(k) < e_n.

The issue: z > resp(k) but z could be > e_n too. We don't know z ≤ e_n.

This suggests the pure formula transfer approach gives the EXISTENCE of a witness above resp(k) with the same type as p_n, but not necessarily the specific ordering with e_n. Additional argument needed.

### Alternative: Sub-interval composition IS the correct approach

The sub-interval approach (tau_left on [d,p_n]/[c,e_n], tau_right on [p_n,y']/[e_n,y]) gives sel_pn_ord DIRECTLY from the game's y-endpoint ordering. This is mathematically clean and avoids the characteristic formula gap.

The original blocker (Case B sorry sites for tau_sel_b/tau_b_sel) is resolved by splitting Case B into:
- **B1** (b_sp ≤ e_n): use tau_left's round-2, all orderings from tau_left
- **B2** (b_sp > e_n): use tau_right's round-2, orderings from monotonicity

This was fully analyzed and shown to work (see analysis in agent conversation). The sub-interval approach was partially implemented and then reverted per user directive.

## Infrastructure Gap: h_surj

The GHR93 formula transfer approach requires `h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p` (atomMap surjectivity) for `nf_characterizable_by_stavi`. This parameter is NOT currently in scope for `ghr93_case_II`.

### Required changes to add h_surj:

1. **ghr93_case_II** (CaseAnalysis.lean:1196): Add `(h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)` parameter
2. **ghr93_inductive_step** (CaseAnalysis.lean): Add h_surj parameter, pass through to case theorems
3. **ghr93_case_II_III_IV_dispatcher** (CaseAnalysis.lean): Pass h_surj
4. **ghr93_inductive_step callers** in Theorem6.lean: Provide h_surj
5. The top-level theorem likely has h_surj available (it's a standard assumption in GHR93)

## Recommendation

Two viable paths:

### Path A: Sub-interval composition (B1/B2 split)
- No infrastructure changes needed
- ~1400 lines of proof (old code + B1/B2 fix)
- Mathematically correct, tested in analysis
- Avoids characteristic formula entirely
- Ready to implement

### Path B: GHR93 U(B,sf_top) formula transfer
- Requires h_surj threading (~30 lines of signature changes)
- Requires showing the Step 6 gap (sel_pn_ord from witness z)
- ~200 lines of new formula infrastructure
- More faithful to GHR93 text
- Has an unresolved mathematical gap in Step 6

## Key Files
- `CaseAnalysis.lean:1243` — the sorry site
- `SplitPoint.lean` — SplitPointProps with tau at rank r+delta
- `StaviCompleteness.lean:2425` — nf_characterizable_by_stavi (requires h_surj)
- `DConsistencyTransport.lean:258` — ghr93_duplicator_wins_rank_down
- `Composition.lean:40` — ghr93_strategy_compose

## Next Action
1. Decide between Path A and Path B
2. If Path B: thread h_surj through the theorem chain first
3. If Path A: implement the B1/B2 Case B split using the analysis from this session
