# Research Report: Task #93 — F/P Obligation Resolution Strategies

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1776096116_9c4d6a
**Focus**: Investigate (1) finite tree + linear embedding and (2) consistent tuple (V,F) strategies for closing forward_F sorry

## Summary

Four researchers investigated two user-proposed strategies for closing the `bx_fmcs_forward_F` sorry at `CanonicalModel.lean:491-495`. The **unanimous conclusion** is that neither strategy is viable as a standalone approach, but both contribute insights that reinforce the **restricted temporal coherence + deferral disjunction** path identified in prior research (Report 03). The concrete mechanism is the `successor_deferral_seed` from `SuccExistence.lean`, which uses "resolve-or-defer" semantics to prevent F-obligation loss at resolving steps.

## Key Findings

### 1. Strategy 1 (Finite Tree + Linear Embedding): NOT VIABLE Standalone

**Teammate A** showed that BX11 (temp_linearity) forces all F-witnesses to be linearly ordered, so the "tree" degenerates to a path — the tree-to-linear embedding step is trivial. However, the tree/path construction is essentially the existing DRM chain with deferral disjunctions, not a new approach.

**Teammate C** identified the critical flaw: BX11 iteration causes infinite regress. Applying BX11 to F(phi) ^ F(psi) produces three disjuncts; the 2nd and 3rd contain strictly larger F-formulas (F(phi ^ F(psi)) and F(F(phi) ^ psi)), generating unbounded nesting depth. This was already identified in Report 03 and remains unresolved.

**Teammate D** confirmed low literature alignment: no standard reference uses a two-phase tree+embed approach for tense logic over Int.

**Useful insight preserved**: The tree approach IS viable within the restricted scope of `deferralClosure(root)`, where F-nesting depth is bounded by `closure_F_bound(root)`. The `bounded_witness` argument in `CanonicalTaskRelation.lean` already formalizes this bound. This is not "Strategy 1" per se, but the restricted temporal coherence approach (Approach 3 from Report 03).

### 2. Strategy 2 (Consistent Tuples (V,F)): NOT VIABLE

**Teammate B** showed the tuple approach collapses: if phi in F <-> neg(phi) in V holds fully, then (V,F) IS an MCS, recreating the Lindenbaum problem. If F is genuinely partial (negation incomplete), the truth lemma's backward direction for `imp` breaks because `negation_complete` is required by the parametric infrastructure.

**Teammate C** confirmed: the FMCS infrastructure requires `SetMaximalConsistent` at every time point. A prime consistent theory satisfying negation completeness IS an MCS by definition. The tuple approach either collapses to MCS or requires a 1000+ line infrastructure rewrite.

**Teammate D** found low-medium literature alignment: non-maximized approaches exist (Scott-style, Henkin-style) but are rare in tense logic and require fundamentally different truth lemma architecture.

**Useful insight preserved**: The deferral disjunction seed from `SuccExistence.lean` (`g_content(u) U {psi v F(psi) | F(psi) in u}`) achieves the SPIRIT of avoiding Lindenbaum's uncontrollable extension. The seed forces "resolve or defer" — any MCS extending this seed must either contain psi (resolving the obligation) or contain F(psi) (deferring it). This is not "avoiding Lindenbaum" but CONTROLLING it.

### 3. The Actual Blocker (Teammate C's Critical Analysis)

The forward_F sorry cannot be closed because:
1. `bx_fmcs_forward_F` has signature `(t : Int) (psi : Formula) -> ... -> exists s, t < s ^ psi in chain(s)` — it quantifies over ALL formulas psi, not just those in a finite set.
2. The deferral approach only works for finitely many formulas (those in `deferralClosure(root)`).
3. The fix is to use `BFMCS.restricted_temporally_coherent root` which only requires forward_F for formulas in `deferralClosure(root)`.

**Critical question raised by Teammate C**: Does `parametric_representation_from_neg_membership` accept restricted temporal coherence? If it currently requires full `temporally_coherent`, a bridge lemma or API change is needed.

### 4. Recommended Path: Restricted Coherence + Deferral Seeds

All four teammates converge on this approach:

1. **Use `successor_deferral_seed`** (from `SuccExistence.lean`, already proven consistent) as the seed for `fwd_succ` at resolving steps. This replaces the current `forward_temporal_witness_seed` with a seed that explicitly preserves F-obligations via resolve-or-defer disjunctions.

2. **Scope to `deferralClosure(root)`**: Only track F-obligations for formulas in the finite set `deferralClosure(root)`. F-nesting depth is bounded by `closure_F_bound(root)`, guaranteeing termination of the deferral chain.

3. **Prove restricted forward_F**: For each F(psi) where psi in deferralClosure(root), show that within `closure_F_bound(root)` steps, the deferral chain must resolve (psi enters the chain) because each deferral step produces F(psi) with strictly smaller nesting within the closure.

4. **Bridge to parametric infrastructure**: Either:
   - (a) Modify `parametric_representation_from_neg_membership` to accept `restricted_temporally_coherent root` instead of `temporally_coherent`, OR
   - (b) Write a bridge lemma showing that for evaluating `root`, restricted coherence suffices

5. **Handle backward_P symmetrically**: Same deferral approach using `p_step_blocking_formulas_restricted` from `SuccExistence.lean`.

**Estimated effort**: 300-400 lines of new code
- Modified chain step with deferral seed: ~100-150 lines
- Restricted forward_F/backward_P proofs: ~100-150 lines
- Bridge lemma for parametric infrastructure: ~50-100 lines

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Is the tree approach new? | No — it's the existing DRM chain. BX11 forces linearity, making the tree a path. The "finite tree" insight only adds value within deferralClosure scope. |
| Does the tuple approach avoid Lindenbaum? | No — if tuples have negation completeness, they ARE MCS. If they don't, the truth lemma breaks. The deferral seed achieves the spirit of "controlling" Lindenbaum instead. |
| Is BX11 the proof engine? | No (Teammate A). BX11 is needed for semantic correctness (linear models) but the formal sorry closure uses deferral disjunctions + bounded nesting, not BX11 iteration. |
| Is restricted coherence sufficient? | Likely yes, but needs verification that `parametric_representation_from_neg_membership` can accept it (Teammate C's critical gap). |

### Gaps Remaining

1. **Parametric infrastructure compatibility**: Does the representation theorem accept restricted temporal coherence? This is the single most important question to answer before implementation.
2. **Until/Since coherence** (`bx_bfmcs_buc`, `bx_bfmcs_fuc` sorries): Neither strategy directly addresses these. They remain independent blockers.
3. **Boneyard porting**: Much of the needed infrastructure exists in the Boneyard (`ResolvingChain.lean`, `CanonicalTaskRelation.lean`) but uses deprecated strict semantics. Porting cost uncertain.
4. **Finite resolution bound formalization**: The well-founded induction on F-nesting depth within `deferralClosure(root)` needs careful construction to work in Lean 4.

### Recommendations

**Primary path**: Restricted temporal coherence with deferral disjunction seeds.

**Immediate next step**: Check whether `parametric_representation_from_neg_membership` (in `ParametricRepresentation.lean`) requires full `temporally_coherent` or can accept `restricted_temporally_coherent root`. This determines whether we need a 50-line bridge or a 200-line truth lemma rewrite.

**Implementation sequence**:
1. Verify parametric infrastructure compatibility (research, 1 hour)
2. Modify `fwd_succ`/`bwd_pred` to use deferral seeds (implementation, 2-3 hours)
3. Prove restricted forward_F/backward_P (implementation, 2-3 hours)
4. Wire into `bx_countermodel` (implementation, 1 hour)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Finite tree + embedding (Primary) | completed | High (85%) |
| B | Consistent tuples (V,F) (Alternative) | completed | Very Low standalone (5%), Medium for deferral insight (70%) |
| C | Critic | completed | High |
| D | Strategic Horizons + Literature | completed | High (85%) |

## References

- Goldblatt 1992, *Logics of Time and Computation* — full canonical frame approach
- Burgess 1984, *Basic Tense Logic* — step-by-step growing linear orders
- Venema 1993 — temporal logic completeness
- Gabbay, Hodkinson, Reynolds 1994 — comprehensive temporal logic foundations
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — successor_deferral_seed (sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean:295` — restricted_temporally_coherent
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — bounded_witness, closure_F_bound
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean:491` — forward_F sorry
