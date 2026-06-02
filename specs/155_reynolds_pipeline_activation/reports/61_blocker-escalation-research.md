# Blocker Escalation Research: Task 155

**Date**: 2026-06-02
**Session**: sess_1780442901_da3012
**Status**: Two independent sorry chains confirmed; root causes identified

## Root Cause Analysis

### Chain 1: Stavi Expressive Completeness (3 sorries)

**Root sorry**: `nf_2var_existential_transfer` (StaviCompleteness.lean:2347, 2429)

The two sorries at lines 2347 and 2429 are the forward/backward directions of 4-variable existential transfer at depth `j'+1`. The proof reduces to: given zone-matched witnesses `u/u'` with matching depth-k 1-var NFs and correct orderings, show the depth-j' quantifier part transfers. This requires sub-interval matching for the 3-point configuration `(u,x,t)/(u',x',t')` — essentially a recursive application of the bridge lemma at lower depth and higher variable count.

**Dependent sorry**: `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2787) depends on `nf_2var_from_interval_data` which calls `nf_2var_existential_transfer`.

**The "formula construction bug" is a misdiagnosis.** The backward direction `nf_exist_sf_guarded_backward` is NOT structurally unprovable — its sorry simply awaits `nf_2var_from_interval_data`, which itself awaits `nf_2var_existential_transfer`. The formula `nf_exist_sf_guarded` only needs to extract a witness `x` from the temporal formula and verify its NF matches `sub_nf` via the bridge lemma. The `atom_compat` filter in the formula is sufficient for the forward direction; the backward direction doesn't need the formula to encode quantifier structure because the bridge lemma (`nf_2var_from_interval_data`) handles the quantifier matching independently.

**Fix**: Prove the two sorries in `nf_2var_existential_transfer` by strong induction on `j`. The depth-0 case is done (atoms transfer). The depth `j'+1` case requires showing that 3-variable existential transfer at depth `j'` follows from 2-variable interval data matching at depth `k` — essentially the same bridge lemma applied recursively with one more variable. This is GHR93 Proposition 7's core inductive step.

**Estimated effort**: 200-400 lines of new proof code. The zone-matching infrastructure (`zone_match_witness`) and atom agreement machinery are already in place. The missing piece is the inductive quantifier transfer.

### Chain 2: IsSuccArchimedean (6 sorries in `chronicle_gap_contradiction`)

**Root sorry**: `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:486) with sub-sorries at lines 236, 392, 500, 741, 761.

The main sorry at line 486 replaces an old proof (lines 488-761, commented out) that was partially complete. The old proof's Case A (distinguishing formula exists) was close but had:
- Line 741: `good(0)` is trivially true for sentences (no free vars); needs `k ≥ 1`
- Line 761: Symmetric case sorry (ψ ∈ limit_f(b) but ψ ∉ limit_f(a))

The old proof's Case B (constant MCS: `limit_f(a) = limit_f(b)`) at line 500 is the hard case — the Z+Z counterexample shows abstract model surgery alone cannot resolve it.

**Critical path**: `chronicle_gap_contradiction` → `succ_cofinal` → `limitDomSubtype_isSuccArchimedean` → `succ_embed_surjective` → `cantor_bfmcs_discrete_restricted_tc/fuc` → `countermodel_discrete_reynolds` → `completeness_discrete`.

**Important finding**: The doc comment on `countermodel_discrete_reynolds` (Transfer.lean:1201) claiming "Does NOT use `IsSuccArchimedean`" is **incorrect**. It calls `cantor_bfmcs_discrete_restricted_tc` which calls `succ_embed_surjective` which uses `limitDomSubtype_isSuccArchimedean`.

### Proposed Fix Strategies

**Strategy A: Fix chronicle_gap_contradiction directly** (addresses Chain 2)
1. Fix Case A line 741: use `k = 1` instead of `k = 0` for the `good` instance
2. Fix Case A line 761: symmetric case (same proof pattern, swap a/b roles)
3. Fix Case B (constant MCS): requires chronicle-specific argument that constant MCS + omega-chain construction implies succ-orbit covers domain
- Estimated: 300-600 lines. Case B is the hard part.

**Strategy B: Decouple via direct IsSuccArchimedean** (bypasses chronicle_gap_contradiction)
Prove `limitDomSubtype_isSuccArchimedean` directly from the omega-chain construction without going through `succ_cofinal`/`chronicle_gap_contradiction`. The key insight: the omega-chain construction adds exactly one new point per stage, and each new point is reachable by successor from the previous stage's new point.
- Estimated: 150-300 lines. Requires understanding omega_chain internals.

**Strategy C: Fix nf_2var_existential_transfer** (addresses Chain 1)
The inductive step for GHR93 Proposition 7. All infrastructure (zone matching, atom agreement, NF characteristics) is in place.
- Estimated: 200-400 lines. Self-contained mathematical proof.

## Recommended Attack Order

1. **Strategy C first** (Chain 1): Most self-contained, all infrastructure exists
2. **Strategy B second** (Chain 2): Avoids the hard constant-MCS case
3. **Strategy A last** (Chain 2, full): Only if Strategy B fails

If Strategies B and C both succeed, `completeness_discrete` becomes sorry-free.
