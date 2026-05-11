# Implementation Plan: Post-Construction Collapse from LimitDomSubtype to Z

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 20-30 hours
- **Dependencies**: None (all prerequisite infrastructure exists)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_blocker-analysis.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_teammate-a-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_team-research-reynolds.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-a-burgess-paper.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-b-codebase-vs-paper.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-c-minimal-fix.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-d-limit-proof.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/03_alternative-architecture.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/handoffs/01_phase1-blocked.md
- **Artifacts**: plans/01_fix-c5-bot-witness.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4

### Research Integration

Reports integrated in this revision:
- `02_teammate-a-burgess-paper.md`: Confirmed Burgess's construction IS correct and produces infinite midpoint chains for U(T,bot) by design. Lemma 2.7 with eta=bot produces inconsistent B' (Set.univ) on the left side, closing the left gap, while B'' on the right remains consistent, leaving the right gap open for the next split.
- `02_teammate-b-codebase-vs-paper.md`: Confirmed the ProofChecker's omega chain FAITHFULLY implements Burgess 1982. The construction is NOT buggy. The architectural mismatch is in the downstream Z-isomorphism requirement (AddCommGroup D forces D = Z).
- `02_teammate-c-minimal-fix.md`: Ranked strategies. Previous plan's "weaken EliminationResult" approach (Strategy 4) FAILED because the right disjunct lacks g-value information. Recommended Strategy 6 (post-construction quotient) as most viable: 0 existing lines modified, ~300-500 new lines.
- `02_teammate-d-limit-proof.md`: Confirmed limit_satisfies_c5_strong ALREADY works correctly for xi=bot. The infinite chain does NOT break C5 satisfaction. Each point has a valid immediate successor via the left-side B' containing bot. The problem is solely that the chain is infinite, making Icc_finite and IsSuccArchimedean false.
- `03_alternative-architecture.md`: Confirmed AddCommGroup is genuinely structural (MF/TF soundness uses time_shift with group arithmetic). The countermodel MUST live on Z. No shortcut around the quotient/collapse exists.
- `01_phase1-blocked.md`: Documents the failed implementation attempt. The right disjunct approach cannot provide bot in limit_f(w) for points entering at stages > n+1.

## Overview

**Previous plan**: Modify `EliminationResult` to add a disjunct for the xi=bot case, preventing infinite midpoint insertion. This approach was implemented through Phase 1 (compiled successfully) but FAILED at Phase 3: the right disjunct lacks g-value information needed by `adj_g_mem_limit_f` to propagate the guard formula to future-stage points.

**Root cause**: Burgess's construction correctly produces infinite bounded intervals for U(T,bot). This is by design, not a bug. The limit model IS a valid discrete linear order -- it just is not isomorphic to Z because it has order type omega+omega* between structural points.

**New strategy**: Do NOT modify the construction. Instead, define a surjective collapse map `collapse : LimitDomSubtype -> Z` that identifies points in the same omega-chain, then build the countermodel (FMCS, BFMCS, TaskFrame) on Z by transporting through the collapse. The existing `limitDomSubtype_Icc_finite` sorry is BYPASSED entirely -- it is replaced by a direct collapse to Z that does not need finite bounded intervals.

**Definition of done**: Remove the sorry at `limitDomSubtype_Icc_finite` (line 1064) OR replace the entire Z-isomorphism pipeline (lines 1059-1188) with the collapse-based construction. The `dd_countermodel_chronicle_nondense_sorry` (line 836) is out of scope (separate task 122) but the new `discrete_fmcs` should be usable by task 122.

## Goals & Non-Goals

**Goals:**
- Define `collapse : LimitDomSubtype -> Z` that collapses omega-chains to integers
- Prove collapse is order-preserving and surjective
- Build `discrete_fmcs : FMCS Z` via the collapse (replacing or supplementing the existing definition)
- Ensure `discrete_fmcs` provides the same interface as the current one (same type signature, same properties) so that task 122 (BFMCS construction) can proceed
- Remove or resolve the `limitDomSubtype_Icc_finite` sorry

**Non-Goals:**
- Modifying the omega chain construction (sorry-free, faithful to Burgess)
- Modifying `CounterexampleElimination.lean` or `ChronicleConstruction.lean`
- Proving `dd_countermodel_chronicle_nondense_sorry` (task 122)
- Modifying the dense case (already sorry-free)

## Risks & Mitigations

- **Risk: Defining the collapse is conceptually unclear.** The omega-chains between structural points converge to accumulation points in Q. Defining which points map to the same integer requires characterizing the chain boundaries. Mitigation: Use the `limitDomSubtype_succ` function itself -- the collapse maps each point to the count of succ-iterations from a fixed origin. Two points get the same integer iff they are equal. Actually, this gives an injection, not a collapse. The real approach: use `limitDomSubtype_succ` on the QUOTIENT type, or define collapse via the discrete structure directly.

- **Risk: The collapse may need to identify points across omega-chains, which requires understanding the chain structure.** Mitigation: Use a simpler definition. Since every point has an immediate successor (via `limit_dom_has_succ`) and immediate predecessor (via `limit_dom_has_pred`), the succ/pred functions are already defined. The problem is only that `succ^[n](a)` never reaches b for finite n when there is an omega-chain between them. The collapse should map all points in an omega-chain to the SAME integer. Define: x ~ y iff the set {w in limit_dom | min(x,y) < w < max(x,y)} is infinite. Then collapse maps equivalence classes to Z.

- **Risk: Transporting FMCS properties (forward_G, backward_H) through the collapse.** If collapse is a surjection but not an injection, we need to choose a representative for each integer and show that the FMCS properties hold for the representatives. Mitigation: Since all points in the same omega-chain have the same MCS values (by BurgessR3Maximal and the chain structure), the representative choice should not matter for forward_G/backward_H. However, this needs verification.

- **Risk: The FMCS also needs Until/Since coherence for task 122 (BFMCS).** The current `discrete_fmcs` only provides forward_G and backward_H. Until/Since coherence is proved at the limit level (`limit_satisfies_c5_strong`) and needs to be transported through the collapse. Mitigation: Phase 4 explicitly handles this.

- **Risk: Alternative approach may be simpler.** Instead of the collapse, we could simply PROVE `limitDomSubtype_Icc_finite` directly by showing that the omega-chains DO terminate (i.e., that the construction does NOT produce infinite chains in practice). However, 4 independent research reports confirm that infinite chains genuinely arise. Mitigation: Commit to the collapse approach.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Characterize Succ-Chains and Define the Collapse Map [NOT STARTED]

**Goal:** Define `collapse : LimitDomSubtype A h_mcs -> Z` and its representative inverse. The key insight: since `limitDomSubtype_succ` is well-defined and every point has an immediate successor/predecessor, we can define the collapse by counting succ-steps from a reference point.

**Tasks:**
- [ ] Read the existing succ/pred infrastructure in `ChronicleToCountermodel.lean` (lines 898-1048) to understand the exact types and interfaces.
- [ ] Define `succ_chain_equiv : LimitDomSubtype -> LimitDomSubtype -> Prop` where `succ_chain_equiv a b` holds iff `exists n : Nat, succ^[n] a = b` OR `exists n : Nat, succ^[n] b = a`. This is the equivalence relation identifying points in the same succ-chain.
- [ ] Alternative simpler approach: since the omega-chain issue means `succ^[n]` does not connect all points, define `collapse` directly as `fun x => discrete_iso_attempt x` where `discrete_iso_attempt` uses a DIFFERENT order isomorphism construction. Specifically:
  - Define `structural_succ : LimitDomSubtype -> LimitDomSubtype` as the function that skips omega-chains: `structural_succ(x) = y` where y is the first limit_dom point after x such that the interval (x, y) in limit_dom is FINITE. If the interval (x, z) for z = succ(x) is infinite (omega-chain), then `structural_succ(x) = structural_succ(succ(x))`. But this is circular.
  - Better: define `is_structural (x : LimitDomSubtype) : Prop` as `Set.Finite {w : LimitDomSubtype | succ_pred_reachable w x}` where `succ_pred_reachable` means reachable by finite succ/pred iteration. Wait, all points are trivially self-reachable. The issue is more subtle.
  - **SIMPLEST APPROACH**: Observe that `limitDomSubtype_succ` gives an immediate successor for every point. The issue is that succ^[n](a) converges to a limit point in Q but never reaches it. However, the limit point IS in limit_dom (it was added at some stage). So `succ^[omega](a)` = lim_{n->inf} succ^[n](a) exists in limit_dom. Define `structural_succ(a) = inf {b in limit_dom | b > a AND (a, b) is finite in limit_dom}`. Since the omega-chain from a converges to some c, and (a, c) is infinite (the omega-chain), structural_succ must skip past c. But then what IS structural_succ(a)?
  - **RECONSIDER**: The research says the order type between structural points is omega+omega*. This means there are points approaching from BOTH sides (omega from the left, omega* from the right). Every point in the omega-chain has a UNIQUE immediate successor (the next midpoint), and the chain converges to an accumulation point. That accumulation point also has an immediate successor (from the omega* chain from the right of the next structural gap).
  - **PRAGMATIC APPROACH**: Don't try to characterize structural points. Instead, build the Z-isomorphism by a different route:
    1. `LimitDomSubtype` has `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder` (all proved).
    2. The only missing piece is `IsSuccArchimedean`.
    3. REPLACE the `limitDomSubtype_Icc_finite -> IsSuccArchimedean` path with a DIRECT construction of `FMCS Z`.
    4. Define `collapse_f : Z -> Set Formula` by: pick any x0 in limit_dom. Set `collapse_f(0) = limit_f(x0)`. Set `collapse_f(n+1) = limit_f(succ^[n+1](x0))` for n >= 0. Set `collapse_f(n) = limit_f(pred^[|n|](x0))` for n < 0. But succ^[n](x0) only reaches points within the same omega-chain, not across chains. So this gives an FMCS on Z where all integers map to points in ONE omega-chain + its omega* continuation. The other structural points are missed.
    5. This WORKS for the countermodel! We only need ONE FMCS that contains A at some position and satisfies forward_G/backward_H. The succ/pred chain from x0 gives a bi-infinite sequence of MCS values that IS an FMCS on Z.
- [ ] **IMPLEMENT THIS**: Define `collapse_f : Z -> Set Formula` by iterating `limitDomSubtype_succ` and `limitDomSubtype_pred` from a fixed origin point `x0 = (0, zero_mem_limit_dom)`.
  - `collapse_f 0 = limit_f 0`
  - `collapse_f (n+1) = limit_f (succ^[n+1] x0).val`  for n >= 0
  - `collapse_f (-(n+1)) = limit_f (pred^[n+1] x0).val` for n >= 1
- [ ] Define `collapse_point : Z -> LimitDomSubtype` as the representative:
  - `collapse_point 0 = x0`
  - `collapse_point (n+1) = succ (collapse_point n)` for n >= 0
  - `collapse_point (-(n+1)) = pred (collapse_point (-n))` for n < 0
  - Or more cleanly: `collapse_point n = succ^[n] x0` for n >= 0, `collapse_point n = pred^[|n|] x0` for n < 0, using `Int.toNat` and `Int.natAbs`.
- [ ] Prove `collapse_point` is strictly monotone: for m < n, `(collapse_point m).val < (collapse_point n).val`. This follows from succ being strictly increasing and pred being strictly decreasing.
- [ ] Place all definitions in a new section of `ChronicleToCountermodel.lean`, AFTER the existing succ/pred infrastructure and BEFORE (or replacing) `limitDomSubtype_Icc_finite`.

**Timing:** 4-6 hours

**Depends on:** none

### Phase 2: Build FMCS on Z via Collapse [NOT STARTED]

**Goal:** Define `discrete_fmcs_via_collapse : FMCS Z` using `collapse_point` and prove forward_G and backward_H.

**Tasks:**
- [ ] Define `discrete_f_collapse (A : Set Formula) (h_mcs : SetMaximalConsistent A) (h_discrete : ...) : Z -> Set Formula` as `fun n => limit_f A h_mcs (collapse_point A h_mcs h_discrete n).val`.
- [ ] Prove `discrete_f_collapse_is_mcs : forall n, SetMaximalConsistent (discrete_f_collapse n)`. This follows from `limit_c0` since `collapse_point n` is in `limit_dom`.
- [ ] Prove `discrete_f_collapse_forward_G`: For t < t', if `G(phi) in discrete_f_collapse(t)`, then `phi in discrete_f_collapse(t')`. Argument: `collapse_point` is strictly monotone, so `collapse_point(t).val < collapse_point(t').val`. Both are in `limit_dom`. Apply `limit_forward_G`.
- [ ] Prove `discrete_f_collapse_backward_H`: Mirror of forward_G using `limit_backward_H`.
- [ ] Assemble `discrete_fmcs_via_collapse : FMCS Z` from the above.
- [ ] Prove `discrete_fmcs_via_collapse_at_zero : discrete_fmcs_via_collapse.mcs (collapse_zero) = A` where `collapse_zero = 0` (since `collapse_point 0 = x0 = (0, ...)` and `limit_f 0 = A` by `limit_f_zero`).
- [ ] Verify `lake build ChronicleToCountermodel` compiles (with sorry at `limitDomSubtype_Icc_finite` still present; we address that in Phase 5).

**Timing:** 3-4 hours

**Depends on:** 1

### Phase 3: Prove Until/Since Coherence on Z [NOT STARTED]

**Goal:** Prove the Until and Since coherence properties for `discrete_fmcs_via_collapse`, which task 122 will need for the BFMCS construction.

**Tasks:**
- [ ] Prove `discrete_fmcs_collapse_c5 : forall t xi eta, untl(eta, xi) in discrete_f_collapse(t) -> exists t' > t, eta in discrete_f_collapse(t') AND forall s, t < s < t' -> xi in discrete_f_collapse(s)`. Argument:
  - From `untl(eta, xi) in limit_f(collapse_point(t))`, apply `limit_satisfies_c5_strong` to get witness `y in limit_dom` with `y > collapse_point(t).val`, `eta in limit_f(y)`, and `xi in limit_g(collapse_point(t), y)`.
  - Need to show y = `collapse_point(t')` for some t' > t. This is where the collapse matters: y might NOT be on the succ-chain from x0. The witness y from C5 is a midpoint inserted in the omega chain, which IS reachable from collapse_point(t) by finitely many succ-steps (it is in the same omega-chain between collapse_point(t) and the next "structural" boundary).
  - Wait -- y IS the immediate successor of collapse_point(t) (since `limit_satisfies_c5_strong` with xi=bot gives the succ witness from `limit_dom_has_succ`). For general xi, y could be further out.
  - **Key insight**: We do NOT need y to be on the collapse chain. We need to find t' such that eta in discrete_f_collapse(t') and xi in discrete_f_collapse(s) for all t < s < t'.
  - For the xi=bot case (discrete axiom): limit_dom_has_succ gives y = succ(collapse_point(t)), and succ(collapse_point(t)) = collapse_point(t+1) by definition. So t' = t+1, and there are no integers s with t < s < t+1. Guard is vacuously satisfied. Done.
  - For general xi, eta: limit_satisfies_c5_strong gives y with xi in limit_g(collapse_point(t), y). Need to show xi in limit_f(collapse_point(s)) for all t < s < t'. Since collapse_point is strictly monotone, collapse_point(t) < collapse_point(s) < collapse_point(t'). If y >= collapse_point(t'), then limit_g(collapse_point(t), y) subset limit_f(collapse_point(s)) by the definition of limit_g.
  - So set t' = the integer such that collapse_point(t') >= y. Then for all s with t < s < t', collapse_point(s) is between collapse_point(t) and collapse_point(t') <= y, so xi in limit_f(collapse_point(s)) by limit_g membership.
  - **But we need to prove such t' exists**: Since collapse_point is unbounded above (limit_dom has no max), there exists t' with collapse_point(t').val >= y. The FIRST such t' has eta in limit_f(collapse_point(t'))? Not necessarily -- eta in limit_f(y) but y might not equal collapse_point(t'). If collapse_point(t').val > y, we need eta in limit_f(collapse_point(t')), which requires a propagation argument.
  - **ALTERNATIVE**: Use a STRONGER Until coherence from the limit. Define the Until property on Z differently: for `untl(eta, xi) in discrete_f_collapse(t)`, use the limit-level C5 witness y, then set t' to be the smallest integer such that `collapse_point(t').val >= y`. Prove `eta in limit_f(collapse_point(t'))` using the limit's Until propagation (either y = collapse_point(t') or y is between collapse_point(t'-1) and collapse_point(t'), and the Until formula propagates via the chain).
  - This requires lemma: if `untl(eta, xi) in limit_f(x)` and `xi in limit_g(x, y)` and `eta in limit_f(y)`, and z > y with z in limit_dom, then either `eta in limit_f(z)` or there exists y' with y < y' <= z with `eta in limit_f(y')` and `xi in limit_g(y, y')`. This is essentially the Until propagation.
  - **SIMPLER APPROACH**: Prove that `untl(eta, xi) in limit_f(collapse_point(t))` implies there exists a FINITE n such that `eta in limit_f(succ^[n](collapse_point(t)))` and `xi in limit_f(succ^[k](collapse_point(t)))` for all 0 < k < n. This follows from the C5 witness being within the succ-reachable chain, which it is (the C5 witness is the immediate succ or a few succ-steps away).
  - Actually, re-examine: the C5 witness y from `limit_satisfies_c5_strong` at collapse_point(t) satisfies: y in limit_dom, y > collapse_point(t).val, eta in limit_f(y), xi in limit_g(collapse_point(t), y). The point y was added at some stage n+1 of the omega chain. Since collapse_point(t) is reached by t succ-steps from x0, and succ-steps follow the omega chain, y is exactly `succ(collapse_point(t))` = `collapse_point(t+1)` when xi=bot. For general xi, y could be several succ-steps ahead. In either case, y IS reachable by finitely many succ-steps from collapse_point(t), because: y is in limit_dom, which means y was inserted at some finite stage. The omega chain from collapse_point(t) passes through y before reaching the next structural boundary. So y = succ^[k](collapse_point(t)) = collapse_point(t+k) for some finite k.
  - **PROVE THIS**: Show that for any y in limit_dom with y > collapse_point(t).val, there exists k : Nat such that collapse_point(t+k).val >= y. This is equivalent to showing the succ-chain from collapse_point(t) is cofinal in limit_dom above collapse_point(t). Since limit_dom is a subset of Q and every point has an immediate successor via `limitDomSubtype_succ`, the succ-chain x0 < succ(x0) < succ(succ(x0)) < ... is an infinite strictly increasing sequence. Is it cofinal? This is exactly what `IsSuccArchimedean` would give us, but we cannot prove that.
  - **CRUCIAL REALIZATION**: The succ-chain from x0 may NOT be cofinal. The omega-chain from x0 converges to an accumulation point c in Q, and c itself is in limit_dom (added at some stage). But succ^[n](x0) never reaches c for finite n. So collapse_point(n) for n in N stays below c. The collapse misses everything at or above c.
  - **THIS MEANS THE COLLAPSE APPROACH AS DEFINED DOES NOT WORK.** The succ-chain from x0 only covers one omega-chain, not the entire limit_dom.
- [ ] **REVISED APPROACH for collapse_point**: Instead of iterating succ from a single x0, define collapse_point using STRUCTURAL successors that jump across omega-chain boundaries:
  - Define `structural_succ(x) : LimitDomSubtype` as: the first point y in limit_dom such that y > x AND there are only FINITELY many limit_dom points in (x.val, y.val). This skips the omega-chain convergence.
  - But this is exactly what we cannot characterize without understanding the chain structure.
  - **BETTER**: Use the STAGE STRUCTURE. Each point in limit_dom enters at some finite stage n. Define `stage(x) = min {n | x.val in dom_n}`. A point is "structural" if it was NOT inserted by a C5 elimination for a U(eta, bot) counterexample. Define `is_structural(x) : Prop` by examining the counterexample that caused x's insertion.
  - This requires tracking provenance information through the omega chain, which is not currently available in the limit definitions.
  - **SIMPLEST VIABLE APPROACH**: Use `WellOrder` / `Ordinal` theory. Define: for x in LimitDomSubtype, `transfinite_succ_rank(x) : Ordinal` as the ordinal rank in the well-ordering induced by succ on LimitDomSubtype. Then use the fact that limit_dom is countable (subset of Q) to get countable ordinal ranks, which embed into Z somehow. But this is extremely complex.
  - **ACTUALLY SIMPLEST**: Don't define collapse_point at all. Instead, prove `limitDomSubtype_Icc_finite` DIRECTLY by showing the construction cannot produce infinitely many points in a bounded interval. BUT the research says it does. However, let me re-examine: the research assumes the C5 walk for U(T,bot) always inserts midpoints. Is this actually true in the ProofChecker's code?
- [ ] **RE-EXAMINE THE CODEBASE**: Read CounterexampleElimination.lean to check whether the "already resolved" condition (condition ii in the C5 walk) can ever succeed for xi=bot. Condition ii checks `eta in f(x')` AND `xi in g(pt, x')`. With eta = top_formula and xi = bot: `top_formula in f(x')` is always true (MCS), `bot in g(pt, x')` -- this requires bot in the g-value. If g(pt, x') was produced by a PREVIOUS C5 split for U(T,bot), and the LEFT side B' contains bot, then when we recurse to the next dom-successor x'', the g-value g(z, x'') = B'' which is consistent (bot NOT in B''). So condition ii fails for the NEXT step. But what about the g-value g(x, z) = B' which DOES contain bot? The C5 walk processes left-to-right: starting at x, finding x' = dom-successor. If g(x, x') already contains bot (from a previous split), then condition ii would succeed: `top in f(x')` AND `bot in g(x, x')`. So the counterexample IS resolved.
  - **KEY**: Does the g-value from a previous C5 split persist? At stage n, if the C5 for U(T,bot) at x was processed and inserted z between x and x', then at stage n+1, dom includes z. The g-values: g_{n+1}(x, z) = B' (contains bot). When processing ANOTHER C5 for U(T,bot) at x at a LATER stage m > n, the counterexample_enum may select x again (different counterexample instance). At stage m, the dom-successor of x is z (since z was inserted at n+1). The g-value g_m(x, z) is B' (unchanged from stage n+1, since no insertion happened between x and z after that). So condition ii checks: `top in f(z)` (true) AND `bot in g(x, z) = B'` (TRUE since B' is inconsistent). So condition ii SUCCEEDS, and the counterexample is already resolved. NO new midpoint is inserted.
  - **THIS MEANS THE INFINITE CHAIN DOES NOT ARISE!** After ONE C5 split for U(T,bot) at x, inserting z with B' containing bot on the left, any FUTURE C5 for U(T,bot) at x finds z as dom-successor with bot in g(x,z), satisfying condition ii. The walk terminates at z. Similarly, the C5 for U(T,bot) at z: z's dom-successor is x' (the original). g(z, x') = B'' (consistent, bot NOT in B''). Condition ii fails. Split again at (z, x'), inserting z'. g(z, z') = B'_2 containing bot. Next C5 at z finds z' with bot in g(z,z'), condition ii succeeds. No infinite chain.
  - **WAIT**: Each counterexample in the omega chain is processed ONCE (the enumeration is a bijection N -> Counterexamples). So the C5 for U(T,bot) at x is processed at exactly ONE stage n. At stage n, z is inserted between x and x'. At stage n+1, x's dom-successor is z, and g(x,z) = B' contains bot. No FURTHER C5 for U(T,bot) at x is processed (it was already processed at stage n). Instead, a NEW C5 for U(T,bot) at z is processed at some later stage m. At z, dom-successor is x'. g(z, x') = B''. Is bot in B''? If not, split again at (z, x'), inserting z'. Then at z', dom-successor is x'. g(z', x') = B''_2. And so on. This creates the omega-chain z < z' < z'' < ... converging to x'.
  - **SO THE INFINITE CHAIN DOES ARISE** between z and x'. The left side is always closed (bot in B'), the right side remains open (bot not in B''). New points are inserted between the latest midpoint and x'.
  - **FINAL APPROACH**: Accept that infinite chains exist. The collapse must jump across them. Define collapse using a WELL-FOUNDED approach.

**Timing:** 4-6 hours

**Depends on:** 2

### Phase 4: Build BFMCS on Z and Wire to Countermodel [NOT STARTED]

**Goal:** Build `cantor_bfmcs_discrete : BFMCS Z` mirroring the dense case's `cantor_bfmcs_dense`, using `discrete_fmcs_via_collapse`. Prove the restricted temporal coherence and Until/Since coherence conditions needed by `fully_restricted_parametric_representation_from_neg_membership`.

**Tasks:**
- [ ] Define `rooted_discrete_fmcs : Set Formula -> Z -> FMCS Z` that builds a chronicle for each box-equivalent MCS N, applies the collapse, and shifts to place N at time s. Mirror `rooted_cantor_fmcs_dense` using integer shifts (Z has AddCommGroup, so `mcs t := collapse_f (t + offset)` works).
- [ ] Prove `rooted_discrete_fmcs_at_s : (rooted_discrete_fmcs N s).mcs s = N`.
- [ ] Prove box stability: `Box phi in (rooted_discrete_fmcs N s).mcs t <-> Box phi in N`. This should follow from the limit-level box stability.
- [ ] Define `cantor_bfmcs_discrete : BFMCS Z` with `families = {rooted_discrete_fmcs N s | N box-equiv A, s : Z}`.
- [ ] Prove `modal_forward` and `modal_backward` for the BFMCS (mirror dense case proofs).
- [ ] Prove the three restricted coherence conditions:
  - `restricted_tc` (restricted temporal coherence)
  - `restricted_buc` (restricted backward Until/Since coherence)
  - `restricted_fuc` (restricted forward Until/Since coherence)
- [ ] Wire to `dd_countermodel_chronicle_nondense_sorry` (or provide infrastructure that task 122 can use directly).
- [ ] Verify `lake build ChronicleToCountermodel` compiles.

**Timing:** 6-8 hours

**Depends on:** 3

### Phase 5: Clean Up and Resolve Sorries [NOT STARTED]

**Goal:** Remove the `limitDomSubtype_Icc_finite` sorry (or mark it as unnecessary given the new approach), clean up, and verify the full build.

**Tasks:**
- [ ] If the collapse-based approach fully replaces the `discrete_iso` pipeline: mark `limitDomSubtype_Icc_finite`, `limitDomSubtype_isSuccArchimedean`, `discrete_iso`, `discrete_f`, `discrete_fmcs` as deprecated or remove them, since the collapse bypasses them entirely.
- [ ] Alternatively, if keeping the old pipeline: prove `limitDomSubtype_Icc_finite` using the collapse (since collapse gives an order-embedding into Z, and Z has finite bounded intervals, the preimage of a finite Z-interval under the collapse is finite). This requires the collapse to be "bounded" -- each omega-chain maps to a single point in Z, and finitely many Z-points map into any bounded Q-interval.
- [ ] Run full `lake build` and verify no new errors.
- [ ] Verify `dd_countermodel_chronicle_nondense_sorry` retains its single sorry (unaffected by these changes).
- [ ] Add docstrings to all new definitions and lemmas.
- [ ] Grep for sorry in the Chronicle files; confirm count is unchanged or reduced.

**Timing:** 2-3 hours

**Depends on:** 4

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after each phase
- [ ] `lean_verify` on `discrete_fmcs_via_collapse` confirms no sorry dependencies
- [ ] `lean_verify` on new BFMCS infrastructure confirms no sorry dependencies
- [ ] Full `lake build` passes after Phase 5
- [ ] Grep for sorry in Chronicle files shows same or fewer count

## Artifacts & Outputs

- **Plan**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/01_fix-c5-bot-witness.md (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (all phases)
- **Summary**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/01_fix-c5-bot-summary.md

## Rollback/Contingency

All changes are ADDITIVE (new definitions and lemmas in ChronicleToCountermodel.lean). The existing construction, limit definitions, and dense case are untouched. Reverting: delete the new collapse section.

If the collapse approach proves too complex:
1. **Fallback A**: Prove `limitDomSubtype_Icc_finite` by showing the omega-chains are actually finite. Re-examine whether the ProofChecker's counterexample enumeration processes each (x, xi=bot, eta=top, c5_forward) tuple exactly once, meaning only ONE midpoint per original adjacent pair per direction. If so, the interval [a,b] has at most 2*|original_dom_between(a,b)| points, which is finite.
2. **Fallback B**: Change the definition of `valid_discrete` to quantify over arbitrary countable discrete linear orders (not just Z). This is a significant architectural change (task 120 scope) but is mathematically cleaner.
3. **Fallback C**: If the infinite chain analysis is wrong and chains ARE finite, prove Icc_finite directly and keep the existing pipeline.

## IMPORTANT NOTE: Phase 1 and Phase 3 Are Exploratory

The Phase 1 and Phase 3 task lists above reflect the FULL complexity of the problem, including dead-end analysis that was performed during planning. The implementer should:

1. **Start by reading the codebase** to verify the omega-chain structure and whether condition (ii) can prevent infinite chains.
2. **If infinite chains genuinely exist**: Proceed with the collapse approach, using the stage-tracking approach to define structural vs fill points.
3. **If infinite chains do NOT exist** (condition ii prevents them): Prove `limitDomSubtype_Icc_finite` directly and keep the existing pipeline. This would be much simpler (~5-10 hours total).

The implementer should write a handoff if the codebase analysis reveals that the situation is fundamentally different from what the research reports describe.
