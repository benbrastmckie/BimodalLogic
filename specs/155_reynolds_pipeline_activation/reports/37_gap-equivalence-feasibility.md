# Gap Equivalence Lemma Feasibility

## Verdict: The lemma is FALSE in general

The proposed lemma -- that two ExtendedCarrier elements with no mu-points strictly between them agree on all mu-relativized StaviFormula truth -- fails at the base case when one element is a point and the other is a gap.

## Analysis of stavi_temporal_truth_mu by constructor

**base phi (temporal_truth_mu)**: At atoms, `(extendedStructure ...).interp (atomMap (.atom a)) t` evaluates to `M.interp ... x` at a point `Sum.inl x` and to `False` at a gap `Sum.inr g` (EFGames.lean line 730). Two adjacent elements where one is a point and one is a gap disagree on any atom that holds at the point. This is a genuine counterexample: take any atom `a` true at carrier point `x`, a gap `g` adjacent to `extendPoint x` with no mu-points between them. Then `temporal_truth_mu ... (extendPoint x) (.atom a) = True` but `temporal_truth_mu ... (Sum.inr g) (.atom a) = False`.

**neg, conj**: Immediate from inductive hypothesis. These cases are fine.

**std_untl, std_snce**: The witness `s` is mu-restricted (`mu_holds s` required). All quantified variables are mu-restricted. If no mu-points lie strictly between `a` and `b`, the set of mu-points above (resp. below) `a` equals that above (resp. below) `b`. These cases would go through by straightforward substitution of witnesses.

**stavi_untl, stavi_snce**: The witness `s` is NOT mu-restricted (EFGames.lean line 829: "The witness s is NOT mu-restricted"). However, condition (2) requires `exists u, a < u < s, mu_holds u, ...`, which forces any valid witness `s` to have mu-points between `a` and `s`. Since no mu-points lie between `a` and `b`, this forces `s > b`. All other quantified variables are mu-restricted. So the effective set of valid witnesses and quantified points is the same for `a` and `b`. These cases would also go through -- IF the base case worked.

## Why the lemma cannot close the sorries

The two sorries (lines 2577 and 2732) arise in proving `r2_resp = rank_embed(d)` where `r2_resp` is the game response at rank r+2 and `d` is the infimum of the continuation set S_C. The variable `d` can be either a carrier point (Sum.inl) or a gap (Sum.inr).

**When d is a carrier point**: `rank_embed(d)` is a point (mu_holds). The gap `r2_resp` adjacent to `rank_embed(d)` disagrees on atoms -- any atom true at `d` is true at `rank_embed(d)` but false at `r2_resp`. The gap equivalence lemma fails here, so it cannot bridge formula agreement from `c_inf <-> r2_resp` (via game) to `r2_resp <-> rank_embed(d)`.

**When d is a gap**: Both `r2_resp` and `rank_embed(d)` would be gaps, so atoms agree (both False). The lemma would be true in this special case. But restricting to the gap-gap case does not cover the general proof obligation.

## The real approach for these sorries

Both sorries use a **different strategy** than gap equivalence, as outlined in the comments:

**Sorry at line 2577** (proving `r2_resp <= rank_embed(d)`): Uses the K^-(not D) pipeline. Extract a formula D that fails cofinally below c_inf via pigeonhole, build `K^-(not D)` of depth r+2, transfer via game to r2_resp, then derive contradiction from D holding above d. This does not need gap equivalence -- it needs the cofinal failure extraction and formula materialization infrastructure.

**Sorry at line 2732** (proving `rank_embed(d) <= r2_resp`): The interior case where `rank_embed(x') < r2_resp < rank_embed(d)`. Needs to find a mu-point `u` with `r2_resp < rank_embed(u)` to apply `h_cont_transfer`, getting a contradiction via `h_cofinal_failure_below_d`. The difficulty is that r2_resp might sit above some carrier points near d. This needs order-theoretic reasoning about carrier point density, not gap equivalence.

## Restricted variant that IS true

A **gap-to-gap** equivalence lemma -- where BOTH elements are gaps with no mu-points between them -- is true, since atoms evaluate to False at all gaps. But this restricted variant is insufficient because d can be a carrier point.

## Estimated effort

The gap equivalence approach is a dead end. The existing sorry comments already describe the correct strategies (K^-(not D) pipeline and carrier point density arguments). Implementing those directly is estimated at 200-400 lines per sorry, primarily involving:
- Cofinal failure formula extraction (pigeonhole over finite formula set)
- K^-(not D) construction and truth transfer
- Carrier point ordering arguments near the infimum
