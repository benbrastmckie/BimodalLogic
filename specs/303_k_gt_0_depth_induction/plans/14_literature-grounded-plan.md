# Implementation Plan: Close PriorComposition Sorry via Literature-Grounded Zone Transfer

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [IN PROGRESS] (Phases 1-4 complete, Phase 5 partial — between-zone blocked, Phases 6-7 not started)
- **Effort**: 20 hours (6-8 dispatch sessions)
- **Dependencies**: None (k=0 infrastructure is sorry-free, KampBypass.lean is sorry-free)
- **Research Inputs**: reports/09_interval-splitting-mapping.md, reports/11_vea-negation-closure-design.md, reports/12_fraisse-game-analysis.md, reports/13_literature-grounded-proof-strategy.md
- **Artifacts**: plans/14_literature-grounded-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v14 replaces the blocked Phase 4d from plan v9 with a literature-grounded 3-phase strategy (Phases 5-7) to close all 4 sorry in PriorComposition.lean. Report 13 established that the sorry share a single root cause: transferring n-var existentials between Prior structures on non-constant environments requires a zone-based argument where the "between-zone" (t < w < x) needs Prior-UZ/SZ with CharPart-level temporal formulas.

The key architectural insight from report 13: `exist_transfer_3var_nonconstenv` is stated WITHOUT Prior hypotheses, but the between-zone proof REQUIRES them. The fix is to either add Prior+CharPart parameters to the theorem, or inline the zone argument into `prior_nonconstenv_2var_agree_until/since` where Prior is already available. The recommended approach uses option (a) -- refactoring `exist_transfer_3var_nonconstenv` to accept Prior, CharPart, atomMap, and h_surj parameters -- because the theorem is called from both the base case and the inductive step, and inlining would duplicate substantial code.

Current state: KampBypass.lean is sorry-free (0 sorry). PriorComposition.lean has 4 sorry at lines 300, 320 (S1/S2 in `exist_transfer_3var_nonconstenv`) and 413, 491 (S3/S4 in base cases of `prior_nonconstenv_2var_agree_until/since`). All 4 sorry trace to the same root cause.

### Research Integration

Report 13 (literature-grounded-proof-strategy.md) established:
1. The 4 sorry decompose into two pairs: S1/S2 at general depth K+1, S3/S4 at depth 0
2. `exist_transfer_3var_nonconstenv` lacks Prior hypotheses -- architectural mismatch with the between-zone proof requirement
3. Zone decomposition: 5 zones for witness w relative to anchors x and t. Zones 1,2,4,5 use `cross_extend_bwd_1var` (already proved). Zone 3 (between) requires Prior-UZ/SZ + CharPart
4. The CharPart threading is well-founded: CharPart(K+1) depends on ExistPart(K), which depends on `prior_nonconstenv_2var_agree` at depth < K+2
5. Case C (both cross_extend witnesses land outside target interval) is the genuine hard case, requiring simultaneous Prior-UZ and Prior-SZ
6. At depth 0, the between-zone is purely atomic (predicate matching in intervals), solvable by Prior-UZ/SZ directly
7. Lean type signatures for all new lemmas verified via lean_hover_info against the existing codebase

Reports 09, 11, 12 (prior research) established:
- GeneralExistPartOrdered and BetweenZoneExistPart are both FALSE (Z counterexample) -- do not re-attempt
- The between-zone problem has a recursive structure: depth-(K+1) 3-var needs depth-K 4-var, which needs depth-(K-1) 5-var, terminating at depth 0
- The correct approach is Rabinovich's Lemma 5.1 argument (Prior-UZ/SZ + CharPart), not direct temporal formula encoding

### Prior Plan Reference

Plan v9 Phases 1-3 and 4a-4c are all COMPLETED. Phase 4d is BLOCKED due to the fundamental circularity in the depth-boost argument without Prior+CharPart. This revision replaces Phase 4d with three new phases (5-7) that follow the literature-grounded strategy from report 13.

### Roadmap Alignment

Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete" -- the SOLE remaining blocker on the critical path.

## Goals & Non-Goals

**Goals**:
- Refactor `exist_transfer_3var_nonconstenv` to accept Prior, CharPart, atomMap, and h_surj parameters
- Prove depth-0 between-zone transfer (S3/S4) via Prior-UZ/SZ + atomic predicate matching
- Prove depth-(K+1) between-zone transfer (S1/S2) via CharPart(K+1) + Prior-UZ/SZ
- Thread CharPart through `prior_nonconstenv_2var_agree_until/since` and upstream callers
- Close all 4 sorry in PriorComposition.lean
- Verify the completeness chain through completeness_discrete

**Non-Goals**:
- Modifying KampBypass.lean (already sorry-free)
- Modifying the k=0 case (existPart_succ_n1_bypass_k0 is sorry-free)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since, ~4400 lines)
- Proving GeneralExistPartOrdered or BetweenZoneExistPart (both are FALSE)
- Implementing the full arity-climbing recursion (report 13 showed this is unnecessary if CharPart is threaded correctly)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case C (both witnesses outside interval) not resolvable by Prior-UZ/SZ | H | M | Report 13 shows the argument uses Prior-UZ and Prior-SZ simultaneously. If the first occurrence (from Prior-UZ) is above x' AND the last occurrence (from Prior-SZ) is below t', the interval is genuinely empty for that predicate pattern. Must show this contradicts the existing witness in M via the depth-1 2-var quantifier transfer. Fallback: add the case analysis as a sorry and escalate. |
| CharPart threading through mutual induction creates unexpected typing issues | M | L | The well-foundedness is verified (report 13, Challenge 2, HIGH confidence). CharPart(K+1) = charPart_succ(CharPart(K), ExistPart(K)), available before step K. If typing issues arise, use explicit universe annotations. |
| Depth-0 between-zone requires more infrastructure than estimated | M | M | Zone 3 at depth 0 is purely atomic. The existing `depth0_3var_witness_check` helper handles witness verification. The new code needs: (a) build a temporal formula for the predicate pattern, (b) apply Prior-UZ/SZ, (c) verify the witness. Each step has known Lean encodings. If complexity exceeds estimate, split into sub-phases. |
| Refactoring `exist_transfer_3var_nonconstenv` signature breaks downstream callers | L | L | Only two call sites: base case and inductive step of `prior_nonconstenv_2var_agree_until/since`. Both already have Prior hypotheses in scope. The refactoring adds parameters that are immediately available. |
| Heartbeat limits exceeded by zone decomposition case analysis | M | M | Factor zone analysis into private helpers (one per zone). Use `set_option maxHeartbeats` as needed. The existing zone infrastructure (lines 130-186) demonstrates the pattern. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- (all completed) |
| 2 | 4 | 1, 2, 3 (completed) |
| 3 | 5 | 4 (completed sub-phases 4a-4c) |
| 4 | 6 | 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove GeneralExistPartOrdered and Simplify Mutual Induction [COMPLETED]

**Goal**: Delete the false GeneralExistPartOrdered definition, its sorry proofs, and revert kamp_mutual_induction to a 2-conjunct form (CharPart + ExistPart).

**Tasks**:
- [x] Delete `GeneralExistPartOrdered` abbrev and its sorry theorems from GeneralExistPart.lean
- [x] Simplify KampMutualInduction.lean to 2-conjunct (CharPart + ExistPart)
- [x] Remove ih_general_exist from existPart_succ parameter
- [x] Fix nf_2var_exist_formula_prior_filled extractor from `.2.1` to `.2` for 2-conjunct form
- [x] Verify: `lake build GeneralExistPart` succeeds with no sorry

**Timing**: 1.5 hours

**Depends on**: none

**Completed**: 2026-06-17

---

### Phase 2: Remove ih_general_exist from existPart_succ_n1_bypass [COMPLETED]

**Goal**: Remove the ih_general_exist parameter and restructure k>0 Until/Since zones to encode quantifier conditions without it.

**Tasks**:
- [x] Remove ih_general_exist parameter from existPart_succ_n1_bypass signature
- [x] Restructure Until zone (true/false) using direct sub_nf.2 ssn truth values
- [x] Restructure Since zone (false/true) with mirror approach
- [x] Update existPart_succ call site in KampMutualInduction.lean
- [x] Verify: `lake build KampBypass` succeeds -- 2 sorry remain (backward directions only)

**Timing**: 2.5 hours

**Depends on**: 1

**Completed**: 2026-06-17

---

### Phase 3: Research and Design V-EA Negation Closure [COMPLETED]

**Goal**: Research Rabinovich's V-EA negation closure (Lemma 5.1) and design the Lean formalization needed to close the between-zone sorry from Phase 2.

**Tasks**:
- [x] Study Rabinovich Lemma 5.1 and map to existing codebase
- [x] Design Lean type signatures for negation-closure lemma
- [x] Estimate effort for between-zone implementation
- [x] Write research report (11_vea-negation-closure-design.md)

**Result**: Between-zone case requires 500-800 lines. Phase 4 re-scoped as multi-session implementation.

**Timing**: 2 hours

**Depends on**: 2

**Completed**: 2026-06-17

---

### Phase 4: Implement Enriched Bracket-Formula Encoding (Sub-Phases 4a-4c Complete, 4d Blocked -> Superseded) [COMPLETED]

**Goal**: Replace top/bot quant_conj encoding with Prior composition transfer. Make KampBypass.lean sorry-free. Prove supporting lemmas in PriorComposition.lean.

**Sub-phases completed**:
- Phase 4a [COMPLETED]: Enriched backward direction with partial proof structure in KampBypass.lean
- Phase 4b [COMPLETED]: Prior composition transfer -- KampBypass.lean now 0 sorry. Sorry moved to PriorComposition.lean (6 sorry -> reduced in 4c)
- Phase 4c [COMPLETED]: Proved `prior_second_1var_from_2var` via `nf_skipIdx_cross` projection. PriorComposition.lean reduced from 6 to 4 sorry

**Phase 4d** [BLOCKED -> SUPERSEDED by Phases 5-7]: The `exist_transfer_3var_nonconstenv` theorem requires Fraisse game simultaneous (depth, arity) induction. Report 13 found the correct alternative: refactor to accept Prior+CharPart parameters and use zone-based argument with Prior-UZ/SZ for the between-zone.

**Timing**: 6 hours (4a-4c completed)

**Depends on**: 3

**Completed**: 2026-06-17 (sub-phases 4a-4c)

---

### Phase 5: Depth-0 Between-Zone Transfer (Closes S3/S4) [BLOCKED]

**Goal**: Prove the depth-0 3-var existential transfer for the between-zone case in the base cases of `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since`. At depth 0, `nf_eval_nf` is purely atomic, so the between-zone reduces to finding a point with matching monadic predicates in the interval (t', x').

**Started**: 2026-06-17

**Progress**:
- [x] Created standalone helper lemmas `depth0_3var_exist_transfer_until` (line ~200) and `depth0_3var_exist_transfer_since` (line ~277) in PriorComposition.lean
- [x] Proved all pairwise order inconsistency cases sorry-free (3 pairs x 2 lemmas = 6 checks)
- [x] Proved anchor order consistency checks (ssn3 x-t order vs h_order) sorry-free
- [x] Replaced original S3/S4 sorry (deeply nested in lambdas) with clean calls to new helper lemmas
- [x] Build passes (988 jobs)
- [ ] **BLOCKED**: Between-zone case (Zone 3: t < w < x) in both helper lemmas

**Remaining sorry** (2 in this phase, at lines 274 and 345):
- `depth0_3var_exist_transfer_until` between-zone: `(∃ w, t < w < x ∧ preds τ at w) ↔ (∃ w', t' < w' < x' ∧ preds τ at w')`
- `depth0_3var_exist_transfer_since` between-zone: symmetric mirror

**Blocker analysis**: The between-zone existential is a 2-variable property of (t,x) that cannot be expressed as a depth-2 temporal formula at a single endpoint. Prior-UZ/SZ produce separate witnesses (one above t', one below x') but do not guarantee a single witness in the intersection (t', x'). Possible resolutions:
1. Derive `interval_nf_types` from Prior axioms (the Stavi pipeline has this explicitly)
2. Use KampBypass `existPart_succ_n1_bypass_k0` infrastructure to bridge
3. Restructure base case to avoid needing the between-zone transfer directly

**BLOCKER** (Phase 5):
- **What failed**: `depth0_3var_exist_transfer_until/since` are FALSE as stated. The between-zone
  condition "exists w in (t, x) with predicates sigma" does NOT transfer from depth-2 1-var
  agreement at endpoints x/x' and t/t' plus Prior-UZ/SZ alone.
- **Counterexample**: M = N = (Z, <, P = even integers), t = t' = -1, x = 4, x' = 0.
  - depth-2 1-var at x=4 / x'=0: both even, same NF by 2-periodicity of P = evens.
  - depth-2 1-var at t=-1 / t'=-1: same point, same NF.
  - M: exists w=0 in (-1, 4) with P(0)=true. N: interval (-1, 0) is empty, no P-point.
  - Prior-UZ/SZ hold on Z (discrete order). All conditions met, but transfer fails.
- **Root cause**: The depth-2 1-var NF at t captures depth-1 2-var quantifier conditions
  relative to t, including "exists s > t with sigma AND exists z in (t, s) with tau".
  But the transferred witness s' may not equal x' (s' could be at a different position).
  The between-zone of (t', s') need not coincide with (t', x'). Similarly from h_x.
  Two 1-variable conditions (at t and x separately) cannot express a 2-variable
  interval containment property.
- **Confirmed FALSE depth-2 1-var NF check**: depth-2 1-var NF of 4 and 0 in
  (Z, P=evens) are the same because: (a) same predicates (both even, P=true),
  (b) same depth-1 neighbor patterns by 2-periodicity (nearest P-neighbor above at +2,
  nearest non-P at +1, etc.), (c) depth-0 3-var between-zone conditions at [s, 4] and
  [s, 0] with matching s values have the same NF due to translation invariance of P=evens.
- **What is needed**: Restructure to either:
  (a) Add CharPart(K+1) parameter and use temporal formula transfer (Phase 6 approach,
      needed even at K=0 base case), or
  (b) Add depth-(K+1) 2-var agreement h_xt as an explicit parameter to
      `exist_transfer_3var_nonconstenv`, with the base case h_xt at depth 0 = atom agreement
      from `nonconstenv_atom_agree_until`, and higher depths from induction, or
  (c) Restructure the induction in `prior_nonconstenv_2var_agree_until` to simultaneously
      prove depth-d 2-var agreement for all d <= K+2 by strong induction, with the depth-1
      2-var case using temporal formula transfer via CharPart(1).

**Recommended fix (option c)**: Merge Phases 5 and 6. Add `char_1 : CharPart atomMap 1` as a
parameter to `prior_nonconstenv_2var_agree_until/since` (propagated from the mutual induction
call site which has CharPart at all depths). Use `existPart_succ_n1_bypass_k0` with char_1 to
build a temporal formula A for each depth-1 2-var NF chi. A works in all Prior structures.
Transfer A's truth via depth-2 1-var agreement (since A has operator depth 2). This gives
depth-1 2-var agreement at [x,t]/[x',t'] without needing depth-0 3-var transfer first. Then
the depth-0 3-var transfer follows from the depth-1 2-var quantifier part.

**Tasks remaining**:
- [ ] *(deviation: blocked — `depth0_3var_exist_transfer_until/since` are FALSE as stated)*
  Resolve between-zone blocker via architectural restructuring (merge with Phase 6)
- [ ] Verify: `lake build PriorComposition` succeeds with sorry count reduced from 4 to 2 (S1/S2 only)

**Key technical detail for Zone 3 (Case C)**: At depth 0, we have depth-2 1-var agreement at x/x' and t/t'. `cross_extend_bwd_1var(h_t, w)` uses the FULL depth-2 hypothesis to produce w_t with depth-1 2-var agreement at [w,t]/[w_t,t']. The depth-1 2-var includes quantifier conditions: for each depth-0 3-var chi, `(exists z, nf_eval M 0 3 [z,w,t] chi) <-> (exists z', nf_eval N 0 3 [z',w_t,t'] chi)`. Similarly for w_x from h_x. In Case C (w_t >= x', w_x <= t'), the point x in M satisfies x > w, x > t with specific predicates. The depth-1 2-var transfer from [w,t]/[w_t,t'] gives z' > w_t >= x' with x's predicates. The point t in M satisfies t < w, t < x. The transfer from [w,x]/[w_x,x'] gives z'' < w_x <= t' with t's predicates. These witnesses are OUTSIDE (t', x'), but their existence establishes that the predicate patterns ARE realized in N. The Prior-UZ/SZ argument then constrains the first/last occurrence to be INSIDE the interval. If this fails, the contradiction may come from the depth-1 2-var quantifier transfer encoding the between-zone census.

**Sorry budget**: 0 new sorry. Target: reduce from 4 to 2.

**Timing**: 6 hours (2-3 dispatch sessions)

**Depends on**: 4 (specifically, the existing zone infrastructure and `depth0_3var_witness_check` from Phase 4)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- refactor signature, implement zone decomposition for depth-0 base cases

**Verification**:
- `lake build PriorComposition` succeeds
- Sorry count in PriorComposition.lean: 2 (S1/S2 only)
- `lean_verify prior_nonconstenv_2var_agree_until` at K=0 base case shows no sorryAx contribution from S3/S4

---

### Phase 6: General-K Between-Zone Transfer via CharPart Threading (Closes S1/S2) [NOT STARTED]

**Goal**: Close the remaining 2 sorry at lines 300 and 320 in `exist_transfer_3var_nonconstenv` by adding CharPart(K+1) as a parameter and using it for the between-zone at depth K+1.

**Tasks**:
- [ ] Add `char_kp1` parameter to `exist_transfer_3var_nonconstenv`: a function that for each depth-(K+1) 1-var NF produces a temporal formula whose truth at a point is equivalent to having that NF type. Type signature:
  ```
  (char_kp1 : ∀ (nf1 : NormalForm sig (K + 1) 1), ∃ (A : Formula),
    ∀ (S : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ S atomMap) (h_SZ : semantic_prior_SZ S atomMap)
      (s : S.carrier), temporal_truth S atomMap s A ↔ nf_eval_nf S (K + 1) 1 (fun _ => s) nf1)
  ```
- [ ] Implement the between-zone argument for S1 (forward, line 300):
  - Have c_K from hex_K with depth-K 3-var agreement at [y,x,t]/[c_K,x',t']. c_K is in the correct zone (same orders as y relative to x' and t'). If y is in zone 3 (t < y < x), then c_K is in zone 3 (t' < c_K < x') -- orders transfer at depth K.
  - c_K has depth-K 1-var agreement with y (from `cross_1var_from_2var` applied to h_3var_K ... wait, h_3var_K is 3-var not 2-var). Extract depth-K 1-var from the depth-K 3-var via `nf_skipIdx_cross`.
  - The goal is depth-(K+1) 3-var eval of sub_nf at [c_K, x', t']. This requires:
    - Atoms: match from h_3var_K (depth-independent). Already proved at Phase 4d dispatch 2.
    - Quantifiers: for each chi : NF sig K 4, `(exists v, nf_eval M K 4 [v,y,x,t] chi) <-> (exists v', nf_eval N K 4 [v',c_K,x',t'] chi)`. From h_3var_K quantifier: depth-(K-1) 4-var transfer. Need depth-K.
  - The depth gap (K vs K-1 for 4-var) is resolved by the SAME zone argument at one lower depth, recursing down to depth 0. This is the arity-climbing recursion. Implement as a private helper with strong induction on depth d (descending from K to 0).
  - Alternative (simpler if feasible): instead of arity climbing, show that c_K already has the correct depth-(K+1) 1-var type (from CharPart + the depth-K 1-var matching). Then use `nf_agreement_from_shared_nf` to transfer the full 3-var eval.
- [ ] Implement S2 (backward, line 320) as the symmetric mirror.
- [ ] Thread `char_kp1` through the call sites in `prior_nonconstenv_2var_agree_until/since`:
  - Base case (K=0): CharPart(1) is available from `charPart_succ` applied to CharPart(0) and ExistPart(0), both of which are sorry-free.
  - Inductive step (K = succ K'): The IH provides depth-(K'+2) 2-var, and CharPart(K'+2) is available from the mutual induction.
  - Update `prior_2var_transfer_until/since` in KampBypass.lean to pass CharPart.
  - Update `existPart_succ_n1_bypass` to obtain CharPart from the mutual induction and thread it through.
  - Update `kamp_mutual_induction` to provide CharPart at each depth.
- [ ] Verify: `lake build PriorComposition` succeeds with 0 sorry. `lake build KampBypass` still succeeds with 0 sorry.

**Key architectural decision**: The arity-climbing recursion vs. the simpler CharPart-based shortcut. Report 13 recommends the arity-climbing approach (depth d descending from K to 0) but acknowledges this may require manipulating (K+3)-dimensional environments. The simpler alternative: if c_K has depth-(K+1) 1-var type tau (obtainable from CharPart(K+1) since c_K has temporal_truth A at the right point), and the depth-(K+1) 2-var agreement at [x,t]/[x',t'] (from h_xt) gives depth-K 3-var transfer, and depth-(K+1) 1-var + depth-K 3-var together determine depth-(K+1) 3-var via a "depth boost from 1-var" argument... this needs investigation. If the simpler approach works, the arity-climbing lemma is unnecessary.

**Sorry budget**: 0 new sorry. Target: reduce from 2 to 0.

**Timing**: 8 hours (3-4 dispatch sessions)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- add CharPart parameter, implement between-zone at general K
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- thread CharPart through `prior_2var_transfer_until/since` calls
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- provide CharPart at each depth of mutual induction

**Verification**:
- `lake build PriorComposition` succeeds with 0 sorry
- `lake build KampBypass` succeeds with 0 sorry
- `lean_verify exist_transfer_3var_nonconstenv` shows no sorryAx
- `lean_verify prior_nonconstenv_2var_agree_until` shows no sorryAx

---

### Phase 7: End-to-End Verification and Cleanup [NOT STARTED]

**Goal**: Verify the full completeness chain from `kamp_mutual_induction` through `completeness_discrete`, clean up any dead code, and confirm zero sorry in the entire Kamp pipeline.

**Tasks**:
- [ ] Run `lean_verify kamp_mutual_induction` -- confirm no sorryAx
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Remove any dead imports or unused helper lemmas introduced during Phases 4-6
- [ ] Remove the "Fraisse game" comment block in PriorComposition.lean (lines 207-209) that references a now-superseded approach
- [ ] Update the module docstring in PriorComposition.lean to reflect the final proof strategy
- [ ] Verify sorry count across the entire Kamp directory: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`

**Sorry budget**: 0. No sorry in Kamp pipeline.

**Timing**: 1 hour (1 dispatch session)

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- cleanup
- Possibly other files in the Kamp directory if dead code is found

**Verification**:
- `lake build` succeeds
- `lean_verify completeness_discrete` clean (no sorryAx, only standard axioms)
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` returns 0 results (excluding comments)

## Testing & Validation

- [x] After Phase 1: `lake build GeneralExistPart` succeeds; no sorry in remaining code
- [x] After Phase 2: `lake build KampBypass` succeeds; sorry count = 2 (at between-zone sites only)
- [x] After Phase 3: Research report written with actionable design
- [x] After Phase 4 (4a-4c): KampBypass.lean sorry-free; PriorComposition.lean reduced to 4 sorry
- [ ] After Phase 5: `lake build PriorComposition` succeeds; sorry count = 2 (S1/S2 only)
- [ ] After Phase 6: `lake build PriorComposition` succeeds; sorry count = 0
- [ ] After Phase 7: `lean_verify completeness_discrete` clean; `lake build` succeeds; no sorry in Kamp directory

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- simplified (false definitions deleted) [Phase 1]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- simplified to 2-conjunct, CharPart threading [Phases 1, 6]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- sorry-free, Prior composition transfer [Phases 2, 4b, 6]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- zone-based transfer with Prior+CharPart [Phases 5, 6, 7]
- `specs/303_k_gt_0_depth_induction/plans/14_literature-grounded-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/reports/13_literature-grounded-proof-strategy.md` -- key research input

## Rollback/Contingency

1. **Phase 5 Case C proves intractable at depth 0**: The outer zones (1,2,4,5) are straightforward and should reduce sorry from 4 to a smaller number even if zone 3 remains sorry. If Case C cannot be resolved, document the specific contradiction argument needed and escalate as a focused research task. The depth-0 between-zone is purely atomic, so the argument is finite and checkable.

2. **Phase 6 CharPart threading causes typing issues in mutual induction**: The well-foundedness is verified (report 13). If typing issues arise, try explicit universe annotations or break the mutual induction into separate lemmas with explicit recursion. Fallback: keep CharPart as a parameter only in PriorComposition.lean and provide it ad-hoc at each call site.

3. **Phase 6 arity climbing proves necessary and exceeds complexity budget**: If the simpler CharPart-based shortcut (avoiding full arity climbing) does not work, and the arity climbing requires manipulating high-dimensional environments, re-scope as a separate task. The partial result (S3/S4 closed, S1/S2 with enriched proof structure) is still progress.

4. **Any phase**: `git revert` to restore pre-attempt state. Do NOT re-attempt GeneralExistPartOrdered or BetweenZoneExistPart (both are FALSE, documented in reports 09 and plan v9).
