# Implementation Plan: Task #305 -- NF-to-VecEA Depth-1 Bridge (v18)

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None (all VecEA infrastructure sorry-free; ExistPart(0-1), CharPart(0-2) sorry-free)
- **Research Inputs**: specs/305_rabinovich_ea_formula_implementation/reports/17_faithful-bridge-design.md
- **Artifacts**: plans/18_nf-vecEA-bridge-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate the K=0 sorry sites (PriorComposition.lean lines 869, 964) by building a depth-1 NF-to-VecEA bridge. After 17 research rounds, the zone-3 between-endpoint transfer problem is confirmed irreducible within the NF composition framework. The resolution bypasses the NF-level zone-3 argument entirely by converting depth-0 3-var existentials into VecEA2 formulas (using the sorry-free VecEA infrastructure), translating to temporal formulas, using CharPart(1) temporal agreement to transfer between structures, then converting back. The bridge is additive (no existing sorry-free code is modified) and targets the SOLE remaining blocker for sorry-free `completeness_discrete`.

### Research Integration

Report 17 (faithful-bridge-design) provides:
- **Finding 1**: All 7 sorry sites are in PriorComposition.lean. Only lines 869 and 964 (K=0 cases of `prior_nonconstenv_2var_agree_until` and `_since`) are on the critical path. The other 5 (507, 555, 642, 647, 658) are in `nf_eval_from_lower_agree` and `zone_compatible_witness` on dead code paths.
- **Finding 2**: The VecEA infrastructure is entirely sorry-free: VecEAFormula (769 lines), VecEAClosure (386 lines), EANegationClosure (567 lines), VecEATranslation (297 lines), NfToVecEA (766 lines).
- **Finding 3**: ExistPart(0), ExistPart(1), CharPart(0), CharPart(1), CharPart(2) are all sorry-free. The sorry first manifests at ExistPart(2), n=1, via `existPart_succ_n1_bypass` with k=1 calling `prior_2var_transfer_until/since` with K=0.
- **Finding 4**: The zone-3 between-endpoint transfer is confirmed irreducible within the NF composition framework after exhaustive analysis.
- **Finding 5**: The correct resolution is an NF-to-VecEA bridge at depth 1 (sufficient for K=0). NfToVecEA currently handles depth 0 only. Estimated 500-900 lines across 2-4 files.
- **Finding 6 (H4 adversarial)**: VecEA bridge feasibility at depth 1 has 65% confidence. Depth-0 bridge exists and is clean; depth-1 requires encoding NF quantifier conditions as VecEA witness types.

### Prior Plan Reference

Plan v13 (charfn-prior-proof-plan) attempted the char_fn + Prior-UZ/SZ approach for filling `prior_exist_transfer_one_dir` (line 524 sorry). Phase 1 was blocked because the zone-3 interval bounding fails: witnesses transferred from individual endpoints cannot be guaranteed to land between both endpoints. Key lessons:
- The depth gap K -> K+1 cannot be bridged algebraically (confirmed across plans v9-v13).
- Every NF-level approach converges to the same zone-3 circularity.
- The existing `zone_compatible_witness` and `nf_eval_from_lower_agree` contain dead-code sorrys (d=0, d=1, r=0 cases) that do not affect the critical path. These should NOT be targeted -- the fix is at a higher level.
- Effort calibration: prior plans estimated 5 hours; this plan adds 1 hour for increased scope (new file + integration test). The depth-1 bridge is inherently harder than depth-0 (existing NfToVecEA.lean is 766 lines for depth-0 alone).

### Roadmap Alignment

ROADMAP.md identifies the critical path: Task 303/305 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free `completeness_discrete`. This plan directly advances the SOLE remaining blocker identified in the roadmap: the sorry chain through `existPart_succ_n1_bypass` k>0 -> `prior_2var_transfer_until/since` -> `prior_nonconstenv_2var_agree_until/since` K=0 -> sorry.

## Goals & Non-Goals

**Goals**:
- Build a depth-1 NF-to-VecEA bridge: convert depth-0 3-var existentials (with non-constant 2-var environment) into VecEA2 form
- Eliminate the K=0 sorry at PriorComposition.lean line 869 (Until) and line 964 (Since)
- Verify sorry elimination propagates through KampBypass -> KampMutualInduction -> KampPrior -> `completeness_discrete`
- All work is additive (new file + minimal edits to PriorComposition.lean sorry sites)

**Non-Goals**:
- Fixing the dead-code sorrys in `nf_eval_from_lower_agree` (lines 507, 555) or `zone_compatible_witness` (lines 642, 647, 658) -- these are not on the critical path
- Generalizing the bridge beyond depth 1 -- depth 1 is sufficient for K=0
- Modifying any existing sorry-free infrastructure (VecEAFormula, VecEAClosure, NfToVecEA, etc.)
- Creating a general-purpose NF-to-VecEA converter for arbitrary depth

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth-1 3-var existential decomposition into VecEA2 is more complex than expected (quantifier conditions at depth 0 involve 4-var atoms) | H | M | The depth-0 3-var case decomposes into zone analysis (order atoms) + predicate matching. At depth 0, everything is purely atomic -- no recursive quantifier structure. The existing depth-0 2-var decomposition in NfToVecEA.lean is the template. |
| The VecEA temporal formula for depth-0 3-var existentials may not transfer correctly between structures via CharPart(1) alone | H | L | CharPart(1) gives temporal formulas characterizing depth-1 1-var NFs. The VecEA2.translateLeft/Right convert VecEA2 to TL(U,S) formulas. The temporal truth transfer follows from h_x, h_t at depth 2 (which subsume depth-1 truth agreement). |
| Connecting the VecEA-mediated transfer back to the `h_agree_env` goal type (depth-1 2-var NF agreement) requires complex type-matching | M | M | The goal decomposes into atoms (already proved by `h_atom`) + quantifier conditions. Each quantifier condition is a depth-0 3-var existential. The bridge handles each existential individually, returning the biconditional required by the quantifier part. |
| Lean performance issues with the new file (large VecEA term manipulations may cause slow elaboration) | M | L | Follow the pattern in NfToVecEA.lean: use `set` bindings, avoid deep unfolding. If slow, split into helper lemmas. |
| Integration requires exact parameter threading from PriorComposition through VecEA machinery | M | M | Phase 3 (integration) handles this. The parameter signatures are known: h_x, h_t at depth K+2, char_fn, char_correct at depth <= K+1, Prior axioms. The bridge uses char_fn at d=0 and d=1 (both within bound since K+1 >= 1 when K >= 0). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Depth-0 3-var Existential to VecEA2 Conversion [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The plan identifies only 2 sorry sites (lines 869, 964) as critical path. Implementation analysis discovered 3 ADDITIONAL sorries on the critical path at K=0: `zone_compatible_witness` d=1 (line 647), `nf_eval_from_lower_agree` d=0 (line 507), and `zone_compatible_witness` d=0 (line 642).
- **What was tried**: 
  1. Direct zone decomposition with Prior-UZ/SZ squeeze for zone 3
  2. VecEA bracket approach with temporal transfer
  3. Depth-1 2-var NF transfer approach
  4. Combined two-endpoint squeeze argument
  All approaches fail because the zone-3 "between" constraint (t < w < x) is a 3-variable condition that cannot be decomposed into a conjunction of 2-variable conditions with the SAME existential witness.
- **Why stuck**: The K=0 case requires depth-2 2-var agreement at [x,t]/[x',t']. The current proof structure constructs this via h_agree_env (depth-1 2-var agreement) + prior_exist_transfer_bidir (depth-1 3-var existential transfer). But prior_exist_transfer_bidir at d=1 calls zone_compatible_witness at d=1 which has an independent sorry. Even if h_agree_env is proved, zone_compatible_witness d=1 requires nf_eval_from_lower_agree d=0 which has its own sorry. All three sorries reduce to the SAME fundamental problem: proving that "exists w in (t,x) with preds P_w" transfers between Prior structures when h_x and h_t only provide endpoint agreements.
- **What is needed**: The K=0 proof must be RESTRUCTURED to bypass zone_compatible_witness entirely. Two approaches:
  (A) Prove the depth-0 zone-3 transfer directly (hard math), then fix all 3 sorries
  (B) Restructure the K=0 case to prove depth-2 2-var agreement WITHOUT the h_agree_env intermediate -- i.e., prove the quantifier transfer at depth 1 directly using a different mechanism
  Either approach requires new research: the direct squeeze via Prior-UZ/SZ does NOT straightforwardly work (see detailed analysis in handoff).
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Create a new file `NfToVecEA1.lean` that converts depth-0 3-var NF existentials (with 2-var environment [x,t]) into VecEA2 formulas and proves correctness. This is the depth-1 analog of the existing depth-0 2-var conversion in NfToVecEA.lean.

**Context**: At K=0, `h_agree_env` requires depth-1 2-var agreement, which decomposes into atoms (already proved) + quantifier conditions. Each quantifier condition is:
```
(exists w, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi) <->
(exists w', nf_eval_nf N 0 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) chi)
```
At depth 0, `nf_eval_nf` is purely atomic: predicates at w, x, t and all order relations among {w, x, t}. The order relations partition w into zones relative to x and t:
- Zone 1 (w < t < x): w below both endpoints
- Zone 2 (w = t): w at lower endpoint
- Zone 3 (t < w < x): w between endpoints -- THE HARD ZONE
- Zone 4 (w = x): w at upper endpoint
- Zone 5 (t < x < w): w above both endpoints

For zones 1, 2, 4, 5: the existential transfers via the per-endpoint 1-var agreements (exist_transfer_from_full_agree applied to h_x or h_t). Zone 3 is the one that requires the VecEA bridge.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` with import of NfToVecEA, EANegationClosure, PriorINF
- [ ] Define `nf_3var_x_proj`, `nf_3var_t_proj`, `nf_3var_w_proj`: extract 1-var NF projections from a depth-0 3-var NF
- [ ] Define `nf_3var_wt_proj`, `nf_3var_wx_proj`: extract 2-var NF projections from a depth-0 3-var NF ([w,t] and [w,x] sub-NFs)
- [ ] Prove `nf_depth0_3var_zone_decomp`: case-split a depth-0 3-var existential by the order atoms of the w variable relative to x and t (6 cases: w<t<x, w=t, t<w<x, w=x, t<x<w, and impossible/degenerate)
- [ ] For each non-zone-3 case, prove the transfer using existing `exist_transfer_from_full_agree` or direct endpoint matching (these are analogs of the depth-0 2-var cases in NfToVecEA.lean)
- [ ] For zone 3 (t < w < x): construct a VecEA2 formula capturing `exists w, t < w < x, preds(w) = P, depth-0 4-var quantifier conditions on [v,w,x,t]`. At depth 0 with 3-var chi, the quantifier part is empty (depth-0 means no quantifier conditions -- it IS purely atomic). So zone 3 reduces to: `exists w, t < w < x, preds(w) = P_w` where P_w is determined by chi's predicate atoms for variable 0
- [ ] Prove `zone3_vecEA2_future_correct`: the zone-3 VecEA2 formula (with bracket encoding "w between t and x with predicates P_w") is equivalent to the zone-3 existential
- [ ] Prove `zone3_vecEA2_past_correct`: the mirror for the Since direction (x < t)
- [ ] Verify with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1`

**Key insight for zone 3**: At depth 0, the 3-var NF chi with variables [w, x, t] (where Fin 0 = w, Fin 1 = x, Fin 2 = t) and zone-3 order atoms (t < w < x) reduces to: "exists w with preds(w) = P_w and t < w < x". This is exactly a VecEA2 with n=0 (no interior witnesses beyond w): endpointLeft = nfPred(nf_t_proj), endpointRight = nfPred(nf_x_proj), bracket = trivial with constraint that w has preds P_w. Actually, w IS the existential witness, so the VecEA2 structure is: endpointLeft = nfPred(t's predicates), endpointRight = nfPred(x's predicates), and the point w is the VecEA2's existential variable with pointType = nfPred(w's predicates). This gives a VecEA2 with n=1 (one interior witness) and trivial bracket segments.

Correction: The VecEA2 `holdsLeft` semantics is `endpointLeft(t) AND exists z1 > t, endpointRight(z1) AND bracket(t, z1)`. For zone 3, we need `exists w, t < w < x AND preds(w)`. This means w is BETWEEN two fixed endpoints t and x. The VecEA2 structure should encode: the bracket between t and x has one interior witness w with pointType = nfPred(w's predicates). Specifically:
- A `BracketFormula 1` with `pointTypes(0) = nfPred(nf_3var_w_proj chi)` and `segmentTypes = top` (no segment constraints)
- The bracket holds on (t, x) iff exists w in (t,x) with preds(w) matching chi

**Timing**: 2.5 hours

**Depends on**: none

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` (NEW, ~300-400 lines) -- depth-0 3-var existential decomposition and VecEA2 conversion with zone analysis

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1` succeeds
- `grep -n sorry NfToVecEA1.lean` returns no proof sorry lines

---

### Phase 2: Temporal Transfer of Depth-0 3-var Existentials on Prior Structures [NOT STARTED]

**Goal**: Prove that each depth-0 3-var existential (with 2-var environment) is TL-definable on Prior structures and that the temporal formula transfers between structures with matching depth-2 1-var NFs at the endpoints. This is the key theorem that bridges the NF framework to the VecEA framework.

**Context**: From Phase 1, each depth-0 3-var existential in zone 3 is equivalent to a VecEA2/BracketFormula `holds` statement. The VecEA translation machinery (VecEATranslation.lean) converts `BracketFormula.holds` into a temporal formula. On Prior structures, temporal truth at a point is determined by the depth-k 1-var NF at that point (via CharPart). Given depth-2 1-var agreement at x/x' and t/t', the temporal formula evaluates the same way.

**Tasks**:
- [ ] Prove `depth0_3var_exist_temporal`: for each depth-0 3-var NF chi and direction (Until/Since), there exists a temporal formula A such that on Prior structures, `temporal_truth M atomMap t A <-> exists w, nf_eval M 0 3 [w,x,t] chi` conditioned on the atoms of the parent environment [x,t]. The proof assembles:
  - Non-zone-3 cases: use `nf_2var_exist_depth0_tl` (from NfToVecEA.lean) applied to the 2-var sub-NF projected from chi's relationship with the relevant endpoint
  - Zone 3: use `VecEA2.translateLeft/Right` on the zone-3 VecEA2 from Phase 1, yielding a temporal formula. Correctness follows from `zone3_vecEA2_future/past_correct` composed with `VecEA2.translateLeft/Right_correct`
- [ ] Prove `depth0_3var_exist_transfer`: given depth-2 1-var agreement at x/x' and t/t' on two Prior structures M and N, and matching orders (t<x iff t'<x'), for all depth-0 3-var NF chi: `(exists w, nf_eval M 0 3 [w,x,t] chi) <-> (exists w', nf_eval N 0 3 [w',x',t'] chi)`. Proof: obtain A from `depth0_3var_exist_temporal`. Show temporal_truth M atomMap t A <-> temporal_truth N atomMap t' A via char_correct(1) + h_t agreement. Compose with correctness on both structures.
  - Subtlety: The temporal formula A depends on chi and the DIRECTION (zone). For zones that involve x rather than t, the formula may be evaluated at x rather than t. Specifically: zone-3 Until involves a bracket between t and x, which translates to a formula containing `Until` quantifiers evaluated at t. The temporal truth at t transfers via h_t at depth 2 (CharPart(1) correctness at depth <= K+1 = 1 when K=0, with char_fn d=1). But actually we need char_correct at d=0 for the predicate formulas, and the `bracketBuildRight/Left` generates formulas using `Until/Since` combinators. The temporal truth of the COMPOSITE formula at t transfers because temporal truth of all TL(U,S) formulas at t is determined by the depth-k 1-var NF at t for sufficiently large k. With depth-2 1-var agreement (k=2), all TL(U,S) formulas with quantifier depth <= 2 agree. The VecEA2 translation generates formulas with quantifier depth <= 2 (one `Until/Since` nesting for the bracket + one for the endpoint predicates).
  - Alternative approach: Rather than proving temporal transfer generically, use the fact that the temporal formula A is known (from the VecEA translation) and show it evaluates correctly on BOTH structures via the VecEA correctness theorems composed with the NF-to-VecEA correctness from Phase 1. The biconditional then follows from: (exists w in M) <-> holdsLeft/Right M <-> temporal M t A, and separately (exists w' in N) <-> holdsLeft/Right N <-> temporal N t' A. The temporal equivalence at t/t' follows from the structural formula definition and h_t/h_x agreements.
  - Simplest approach: Use the classical satisfiability argument (already used by KampBypass for k>0). For the specific zone-3 case: fix a witnessing structure M0. Build formula encoding t0's NF type + w0's NF type as `(char_fn 0 nf_w0) U top` (exists point above t with w0's predicates) AND `(char_fn 0 nf_w0) S top` (exists point below x with w0's predicates) AND `char_fn 0 nf_t0` (t has t0's predicates). Backward: given formula at t in M, extract w with matching predicates in (t, x). Forward: given w in (t, x) in M, construct formula. This avoids the full VecEA machinery for zone 3 at depth 0, since depth-0 is purely about PREDICATES and ORDER.

**Revised approach after reflection**: At depth 0, the zone-3 3-var existential `exists w, t < w < x, preds(w) = P_w` can be proved to transfer MORE DIRECTLY using the bracket formula infrastructure on Prior structures:
1. From h_t at depth 2: the depth-1 quantifier conditions at t encode "exists y > t with depth-0 2-var NF matching [w,t]". This gives y > t' with w's predicates and y > t'.
2. From h_x at depth 2: similarly gives y' < x' with w's predicates.
3. One of y or y' must be in (t', x') on a dense-enough structure. On Prior structures (which include all discrete models embedded via the Reynolds construction), this follows from `HasAttainedINF.first_occ_tp`: if there's a point with w's predicates above t', the FIRST such point r0 satisfies t' < r0. If r0 < x', we're done. If r0 >= x', then from the h_x direction we get a point below x' with w's predicates, and its LAST occurrence r1 < x' gives r1 > t' (otherwise contradicting r0 being the first above t').

This is the "Prior-UZ/SZ squeeze" that prior plans attempted at the NF level but which works CLEANLY at depth 0 because depth-0 predicates are simple (conjunction of atom literals = a TemporalPred). The key is that `HasAttainedINF` provides first/last occurrence localization that bounds the witness to the interval.

- [ ] Prove `zone3_depth0_prior_transfer`: on Prior structures with HasAttainedINF, if `exists w, t < w < x, preds(w) = P_w` in M, and h_x, h_t provide depth-2 1-var agreement, then `exists w', t' < w' < x', preds(w') = P_w` in N. Proof sketch:
  - Define phi_w = nfPred(nf_3var_w_proj chi) -- the TemporalPred for w's predicates
  - From h_t at depth 2: `exist_transfer_from_full_agree` applied to the constant-env [t] with k=1 gives depth-1 2-var existential transfer. The depth-1 2-var NF at [w,t] includes "w > t, preds(w) = P_w" plus depth-0 3-var quantifier conditions. Transfer gives y1 > t' with matching depth-1 2-var NF -- in particular, phi_w(y1) holds.
  - From h_x at depth 2: similarly, get y2 < x' with phi_w(y2).
  - Case: if y1 < x': y1 is in (t', x') with correct predicates. Done.
  - Case: if y2 > t': y2 is in (t', x') with correct predicates. Done.
  - Case: y1 >= x' AND y2 <= t': Use HasAttainedINF. Since y1 > t' and phi_w(y1), there exists a first phi_w point r0 above t' (by HasAttainedINF). If r0 < x': done. If r0 >= x': since y2 < x' and phi_w(y2), and r0 is the FIRST above t', we need y2 <= t' < r0 <= y1 >= x' > y2. But phi_w(y2) holds and y2 < x' <= r0. If y2 > t', we already handled that. If y2 <= t', then we look from above: use HasAttainedINF on N from x' downward (the Since analog -- "last occurrence below x'"). The last phi_w point below x' is r1 with r1 < x'. If r1 > t': done. If r1 <= t': then no phi_w point exists in (t', x'). But we need to show this contradicts our hypotheses. Since t < w < x in M with phi_w(w), we need to show this forces a phi_w point in (t', x') in N. This may require the full depth-1 information from the 2-var transfers (not just depth-0 predicates).
  - If the direct squeeze argument fails, fall back to the VecEA bracket approach: encode the zone-3 existential as a BracketFormula, translate to temporal, show temporal transfer.
- [ ] Verify with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` -- add temporal transfer theorems (~150-250 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1` succeeds
- `grep -n sorry NfToVecEA1.lean` returns no proof sorry lines
- Key theorem: `depth0_3var_exist_transfer` compiles sorry-free

---

### Phase 3: Replace K=0 Sorry Sites in PriorComposition.lean [NOT STARTED]

**Goal**: Wire the depth-0 3-var existential transfer from Phase 2 into PriorComposition.lean to eliminate the K=0 sorry at lines 869 and 964.

**Context**: The sorry sites occur in the `| 0 =>` branch of `match K with` inside `prior_nonconstenv_2var_agree_until` (line 866-869) and `_since` (line 963-964). The goal at K=0 is:
```
h_agree_env : forall nf : NormalForm sig 1 2,
    nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) nf <->
    nf_eval_nf N 1 2 (Fin.cons x' (fun _ => t')) nf
```
This decomposes into atoms (already proved as `h_atom`) + quantifier conditions:
```
forall chi : NormalForm sig 0 3,
  (exists w, nf_eval M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi) <->
  (exists w', nf_eval N 0 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) chi)
```
Phase 2's `depth0_3var_exist_transfer` provides exactly this biconditional.

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1` to PriorComposition.lean
- [ ] Replace the sorry at line 869 (Until, K=0) with:
  1. Prove the atom part: already available as `h_atom`
  2. Prove the quantifier part: for each `chi : NormalForm sig 0 3`, apply `depth0_3var_exist_transfer` with M, x, t, N, x', t', h_UZ_M, h_SZ_M, h_UZ_N, h_SZ_N, h_x (at depth 2), h_t (at depth 2), h_order_M, h_order_N, char_fn, char_correct (at d <= 1)
  3. Combine atoms + quantifiers to construct the full depth-1 2-var NF agreement using `nf_characteristic_satisfies` + `nf_agreement_from_shared_nf` (the same pattern used by the K'>=1 branch)
- [ ] Replace the sorry at line 964 (Since, K=0) with the mirror construction
- [ ] Verify PriorComposition.lean compiles: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition`
- [ ] Verify K=0 sorry sites are eliminated: `grep -n 'sorry' PriorComposition.lean` should show only the dead-code sorrys at lines 507, 555, 642, 647, 658

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- add import, replace 2 sorry sites (~40-80 lines of new proof code)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds
- `grep -n 'sorry' PriorComposition.lean` returns only lines 507, 555, 642, 647, 658 (dead-code sorrys)
- `lean_verify` on `prior_nonconstenv_2var_agree_until` and `_since` confirms no sorryAx

---

### Phase 4: Integration Verification (KampBypass to completeness_discrete) [NOT STARTED]

**Goal**: Verify that eliminating the K=0 sorry in PriorComposition.lean propagates through the entire call chain to `completeness_discrete`, making the full Kamp theorem pipeline sorry-free.

**Context**: The sorry chain is:
```
completeness_discrete
  -> countermodel_discrete_reynolds_v2
    -> limitdom_is_good
      -> no_gaps_discrete_model_surgery
        -> US_expressively_complete_over_prior
          -> kamp_prior_expressive_completeness
            -> existPart_succ_n1_bypass (k>0)
              -> prior_2var_transfer_until/since (K=k-1)
                -> prior_nonconstenv_2var_agree_until/since (K=k-1)
```
With K=0 eliminated, the recursion works: k=1 calls K=0 (now sorry-free), k=2 calls K=1 (uses K=0 recursively), etc. All k>0 cases resolve.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify compiles
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify compiles
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify compiles
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no sorryAx
- [ ] Run full `lake build` to verify clean project build with zero errors
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` to catalog remaining sorrys
- [ ] Document which remaining sorrys are dead-code vs. live

**Timing**: 1 hour

**Depends on**: 3

**Files to verify** (no modifications expected):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
- Full project via `lake build`

**Verification**:
- `lake build` succeeds with no errors
- `lean_verify` on `completeness_discrete` reports no sorryAx
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only dead-code sorrys in PriorComposition.lean (lines 507, 555, 642, 647, 658) and any NfCharFormula.lean dead-code sorrys

## Testing & Validation

- [ ] Phase 1: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1` succeeds sorry-free
- [ ] Phase 1: `lean_goal` at zone-3 VecEA2 construction confirms correct types
- [ ] Phase 2: `depth0_3var_exist_transfer` compiles sorry-free
- [ ] Phase 2: `lean_verify` on `depth0_3var_exist_transfer` confirms no sorryAx
- [ ] Phase 3: Both K=0 sorry sites eliminated
- [ ] Phase 3: `prior_nonconstenv_2var_agree_until` and `_since` compile sorry-free for all K
- [ ] Phase 3: `lean_verify` on both theorems confirms no sorryAx
- [ ] Phase 4: `completeness_discrete` compiles sorry-free (no sorryAx)
- [ ] Phase 4: Full `lake build` succeeds
- [ ] Phase 4: Final sorry audit confirms only dead-code sorrys remain in Kamp directory

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/18_nf-vecEA-bridge-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` (NEW) -- depth-1 NF-to-VecEA bridge (~450-650 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- K=0 sorry eliminated (Phases 3)

## Postmortem Constraints (from v9-v13 and 17 research rounds)

Previous plans failed for specific reasons that this plan MUST avoid:

1. **Do NOT attempt zone-3 witness placement within the NF framework** -- 17 research rounds confirm this is irreducible. Every NF-level approach (cross_extend, exist_transfer_from_full_agree, nvar_transfer_from_1var_agree, char_fn + Prior-UZ/SZ) fails at zone 3.
2. **Do NOT modify existing sorry-free infrastructure** -- the VecEA files, NfToVecEA.lean, KampBypass.lean, etc. are all sorry-free and must remain untouched.
3. **Do NOT target the dead-code sorrys** (lines 507, 555, 642, 647, 658 in PriorComposition.lean) -- they are in `nf_eval_from_lower_agree` and `zone_compatible_witness`, which are NOT called from the main theorem pipeline at K=0.
4. **The depth-0 3-var existential at zone 3 IS the kernel** -- the plan must handle this case specifically, not try to prove a more general theorem.
5. **Use the Prior-UZ/SZ + HasAttainedINF infrastructure for zone-3 witness bounding** -- this is the mechanism that Rabinovich uses (Lemma 5.3 witness placement via first/last occurrence analysis). The bracket formula approach is the fallback.
6. **Work at depth 0 only** -- the bridge needs to handle depth-0 3-var existentials, which are purely atomic. Do NOT attempt to generalize to depth > 0.

## Rollback/Contingency

- **Phase 1** creates a new file. Rollback = delete `NfToVecEA1.lean`.
- **Phase 2** extends the same new file. Rollback = delete `NfToVecEA1.lean`.
- **Phase 3** modifies PriorComposition.lean (2 sorry sites + 1 import). Rollback = `git checkout -- PriorComposition.lean`.
- **Phase 4** is verification only -- no rollback needed.
- Git per-phase commits enable rollback to any intermediate state.
- **If the Prior-UZ/SZ squeeze argument fails at zone 3**: Fall back to the full VecEA bracket approach: encode zone-3 as a BracketFormula with 1 witness, translate via bracketBuildRight/Left to temporal formula, prove temporal truth transfer via char_correct compositionality. This is more complex (~100 extra lines) but follows the same pattern as the existing sorry-free VecEA translation infrastructure.
- **If the depth-0 3-var decomposition is too complex**: Split NfToVecEA1.lean into two files: one for projections and zone decomposition, one for the transfer theorem. This keeps each file manageable (<400 lines).
