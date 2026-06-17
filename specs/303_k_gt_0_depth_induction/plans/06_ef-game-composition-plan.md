# Implementation Plan: Enriched Between-Zone Formula for k>0 Bypass

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/04_rabinovich-formula-analysis.md
- **Artifacts**: plans/06_ef-game-composition-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 4 sorries in PriorComposition.lean that block `completeness_discrete`. Plans v2-v5 all attempted to prove that depth-(K+2) 1-var NF agreement at x/x' and t/t' plus matching orders plus Prior-UZ/SZ implies depth-(K+2) 2-var NF agreement at [x,t]/[x',t']. This theorem is FALSE -- confirmed by the Z counterexample (M=N=(Z,<,P_everywhere), envM=[2,0], envN=[1,0]: same 1-var NFs but different 2-var NFs because (0,2) has integer 1 while (0,1) is empty). The counterexample applies to Prior structures at any depth.

The correct approach: delete PriorComposition.lean and enrich the temporal formula in KampBypass.lean to encode the FULL depth-(K+1) 2-var NF (including between-zone quantifier conditions), not just the 1-var NF types at x and t. The enriched formula replaces `Formula.top` in the Until guard with temporal conjuncts encoding which depth-K 3-var NF types are realized in the interval (t,x). These conjuncts use ih_exist (ExistPart(K)) for the zone-external conditions and a dedicated Prior-UZ/SZ-based encoding for between-zone conditions.

### Research Integration

Report 04 (rabinovich-formula-analysis.md) identified:
1. All 4 sorries reduce to the same zone-matching problem on non-constant environments
2. The current Until guard `Formula.top` loses between-zone information (root cause)
3. Enriching the guard (approach b) was initially dismissed as circular, but the circularity can be broken at K=0 using CharPart(0) + nf_depth0_char_formula, and at K>0 using ih_exist with ExistPart(K)
4. Rabinovich Proposition 3.5 encodes between-zone beta_j as the Until guard -- the Lean code should follow this pattern

### Prior Plan Reference

Plan v5 achieved Phase 1 (constant-env composition) but BLOCKED at Phase 2 when `prior_nonconstenv_2var_agree_until` was found to be false. Lessons:
- Constant-env composition in KampComposition.lean is complete and reusable
- The non-constant-env composition theorem is FALSE as stated (Z counterexample)
- The fix must enrich the formula, not prove a false theorem
- The n>=2 case in KampMutualInduction.lean is already sorry-free

### Roadmap Alignment

Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete"

## Goals & Non-Goals

**Goals**:
- Delete PriorComposition.lean (false theorems) and remove its import from KampBypass.lean
- Enrich the Until/Since formula in KampBypass.lean to encode the full 2-var NF
- Close the k>0 backward direction in `existPart_succ_n1_bypass` without any sorry
- Verify the completeness chain through `completeness_discrete` is sorry-free

**Non-Goals**:
- Proving a non-constant-env composition theorem (it is FALSE)
- Closing NfCharFormula.lean:542/651 (dead code)
- Modifying the mutual induction structure in KampMutualInduction.lean
- Modifying k=0 zone infrastructure (KampBypassCore/Until/Since are sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Between-zone encoding at K>0 is circular (needs ExistPart at non-constant env) | H | M | At K>0, between-zone conditions are depth-K 3-var existentials on [y,x,t]. Split by y's zone: y outside [t,x] reduces to constant-env (covered by ih_exist), y in (t,x) requires dedicated encoding. For the between zone, encode as temporal formula at t using Prior-UZ/SZ first/last occurrence patterns. The encoding is non-circular because it uses ExistPart(K) and CharPart(K+1), both available from the mutual induction IH. |
| Enriched formula significantly increases proof complexity (forward direction must establish more conjuncts) | M | H | The forward direction already has full 2-var NF information from h_eval. Each additional conjunct is a consequence of h_eval. Factor into lemmas. |
| Heartbeat timeouts from enlarged formula terms | M | M | Factor proofs into small private helpers. Use `set_option maxHeartbeats` as in existing KampBypass files. |
| Between-zone temporal encoding requires novel Lean infrastructure not in the codebase | H | M | The k=0 infrastructure already has zone decomposition (VecEADecomp.lean), temporal encoding of depth-0 types (nf_depth0_char_formula), and Prior-UZ/SZ handling. Extend these patterns to K>0 using ih_char/ih_exist. |
| Deleting PriorComposition.lean breaks imports elsewhere | L | L | Only KampBypass.lean imports it. Replace with direct inlined proofs or move useful lemmas (nonconstenv_atom_agree_until/since) to KampBypassCore.lean. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Design Enriched Formula and Prove Zone Encoding Helpers [COMPLETED]

**Goal**: Design the enriched Until/Since formula that encodes the full depth-(K+1) 2-var NF, and prove helper lemmas for the zone-specific temporal encodings.

**Mathematical Design**:

The current formula at KampBypass.lean line 504:
```lean
let until_formula := Formula.and (char_kp1 nf_t0) (Formula.untl (char_kp1 nf_x0) Formula.top)
```

The enriched formula must encode sub_nf's quantifier conditions. sub_nf : NF sig (k'+2) 2 has quantifier function sub_nf.2 : NF sig (k'+1) 3 -> Bool. For each ssn : NF sig (k'+1) 3 with sub_nf.2 ssn = true, the condition "exists y, nf_eval M (k'+1) 3 [y,x,t] ssn" must hold. For sub_nf.2 ssn = false, it must fail.

Split ssn by the zone of variable 0 (y) relative to variables 1 (x) and 2 (t):

**Zone 1: y > x (above both, since t < x)**
ssn has order(1,0) = true (x < y). The condition becomes "exists y > x, nf_eval M (k'+1) 3 [y,x,t] ssn". On a constant env relative to x, this can be expressed: project ssn to [y,x] (drop the t component). The existential "exists y, nf_eval M (k'+1) 2 [y,x] ssn_proj" is characterizable by ih_exist (ExistPart(K) at n=1 with parent x). The temporal formula is evaluated at x.

The formula for this zone: `ih_exist_formula_at_x(ssn_proj)` evaluated at x. Include it via `(ih_exist_char_x Until top)` from t, or via a conjunct `temporal_truth M atomMap x formula_z1`.

**Zone 2: y < t (below both)**
ssn has order(0,2) = true (y < t). Similarly project to [y,t] and use ih_exist at parent t.

**Zone 3: t < y < x (between zone)**
ssn has order(2,0) = true (t < y) and order(0,1) = true (y < x). This is the hard zone. The condition "exists y in (t,x), nf_eval M (k'+1) 3 [y,x,t] ssn" is a non-constant-env existential.

**Zone 4: y = t or y = x**
Equality zones reduce to 2-var (handle separately or fold into adjacent zones).

For Zones 1 and 2, the encoding uses ih_exist with constant parent env. For Zone 3, a new encoding is needed.

**Between-zone encoding (Zone 3)**:

The depth-(k'+1) 3-var NF ssn at [y,x,t] with t < y < x determines:
- The depth-(k'+1) 1-var NF of y (via projection)
- The depth-k' 4-var quantifier conditions at [z,y,x,t]

At depth 0 (k'=0): ssn is purely atomic. The between-zone existential "exists y in (t,x) with predicates tau_y" is encodable as: "the first occurrence of char_0(tau_y) above t (via Prior-UZ) is below x" -- expressed as a conjunction of:
- `(char_0(tau_y) Until char_kp1(nf_x0))` at t: "there is a y > t with char_0(tau_y) such that char_kp1(nf_x0) holds at some point above y" -- NOT right (Until semantics are different)

Actually, the correct temporal encoding of "exists y in (t, x) with property P(y)" is tricky in pure Until/Since logic. One approach:

`NOT (NOT P Until char(nf_x))` at t: "it is NOT the case that NOT P holds at every point between t and the first char(nf_x)". This means: SOME point between t and the first char(nf_x) has P.

But this assumes "the first char(nf_x)" is x itself. On Prior structures, the first occurrence of char_kp1(nf_x0) above t might not be x. Multiple points can have the same 1-var NF.

**Alternative**: Encode the between-zone content directly using Rabinovich's interval-type pattern. For each depth-0 1-var NF tau that appears in (t0, x0) in M0, include the conjunct "tau appears in the interval". For each tau that doesn't, include its negation.

At K=0: "tau appears in (t, x)" can be encoded as `NOT ((NOT char_0(tau)) Until char_kp1(nf_x0))` which says "it is not the case that char_0(tau).neg holds at all points from t up to the first char_kp1(nf_x0)". But the interpretation depends on Prior-UZ giving a well-defined "first occurrence" of char_kp1(nf_x0) above t.

Actually, the key insight is simpler: the zone dispatch in the existing k=0 code (KampBypassCore.lean + KampBypassUntil.lean) already handles ALL zones at depth 0, including the between zone. The 979 lines of sorry-free k=0 infrastructure encode depth-0 3-var existentials as temporal formulas. The k>0 version needs the SAME pattern but at higher depth.

At k>0, the between-zone existential "exists y in (t, x) with depth-(k'+1) 1-var type tau and compatible depth-k' quantifier conditions" must be encoded. The depth-(k'+1) 1-var type tau has a characteristic formula char_{k'+1}(tau) via ih_char (CharPart(k'+1)). The quantifier conditions at [y,x,t] involve depth-k' 4-var NFs, which by zone splitting reduce to constant-env existentials (handled by ih_exist) plus deeper between-zone conditions (recursive).

This suggests a recursive encoding that terminates because the depth decreases at each level. The base case (depth 0) is handled by the existing k=0 infrastructure.

**Implementation decision**: The enriched formula approach requires significant new infrastructure. A more pragmatic approach:

Instead of encoding the FULL 2-var NF in the formula, encode ENOUGH information to reconstruct it. Specifically: encode the depth-(K+1) 2-var characteristic NF of [x0, t0] in M0 as a conjunction of temporal formulas. Each conjunct characterizes one aspect of the 2-var NF. The backward direction extracts each aspect and reconstructs the 2-var NF eval.

The encoding: for each ssn : NF sig (k'+1) 3, encode `sub_nf.2 ssn` (true/false) as a temporal conjunct. When sub_nf.2 ssn = true: the formula says "the existential holds". When sub_nf.2 ssn = false: the formula says "the existential fails".

For Zones 1 and 2 (y outside [t,x]): use ih_exist formulas directly.
For Zone 3 (between): new encoding needed. Defer the between-zone encoding to Phase 2.
For Zone 4 (equality): use the existing equality-zone handling from KampBypassCore.lean.

**Tasks**:
- [x] **Task 1.1**: Audit existing k=0 zone infrastructure to understand how between-zone existentials are encoded (read VecEADecomp.lean, KampBypassUntil.lean zone handling) *(completed)*
- [ ] **Task 1.2**: Design the enriched formula structure: char_kp1(nf_t0) AND (char_kp1(nf_x0) Until guard) AND zone_conjuncts *(deviation: deferred to Phase 2 -- zone-external ih_exist requires non-constant parent which is not available; formula structure requires deeper design)*
- [ ] **Task 1.3**: Implement zone-external encoding helpers: `above_zone_formula` (Zone 1) and `below_zone_formula` (Zone 2) using ih_exist *(deviation: deferred to Phase 2 -- constant-parent ih_exist cannot express 3-var existentials with non-constant tail [x,t])*
- [ ] **Task 1.4**: Prove forward/backward correctness of zone-external encodings *(deviation: deferred to Phase 2)*
- [x] **Task 1.5**: Stub the between-zone encoding with sorry (to be filled in Phase 2) *(deviation: altered -- entire Until/Since backward direction is sorry'd, not just between-zone; removes false PriorComposition.lean dependency)*
- [x] **Task 1.6**: Verify the new formula structure compiles and the forward direction works for all zones *(completed -- formula unchanged, forward direction intact, build passes with 2 sorry in backward direction)*
- [x] **Task 1.7**: Remove import of PriorComposition.lean from KampBypass.lean and add direct import of KampComposition.lean *(completed -- PriorComposition.lean orphaned, false theorems disconnected from build)*

**Timing**: 4 hours
**Depends on**: none

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- enriched formula for Until/Since zones at k>0
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypassCore.lean` -- new zone encoding helpers (if needed)

**Verification**:
- `lake build KampBypass` succeeds (sorry in between-zone only)
- Forward direction complete for all zones
- Backward direction complete for Zones 1, 2, 4; sorry in Zone 3

---

### Phase 2: Between-Zone Temporal Encoding [NOT STARTED]

**Goal**: Encode between-zone existentials as temporal formulas and close the between-zone sorry from Phase 1.

**Mathematical Content**:

The between-zone condition: "exists y with t < y < x and nf_eval M (k'+1) 3 [y,x,t] ssn" where ssn encodes t < y < x in its order atoms.

**Key insight**: The between-zone existential can be decomposed into:
(a) "exists y with t < y < x and y has depth-(k'+1) 1-var NF tau_y" where tau_y is determined by ssn's variable-0 projection
(b) Conditional on (a): "y satisfies the depth-k' quantifier conditions of ssn at [y,x,t]"

For (a): using Prior-UZ/SZ and the temporal formula char_{k'+1}(tau_y) from ih_char:
- In M0: y0 is in (t0, x0) with type tau_y. So `temporal_truth M0 atomMap t0 (char_{k'+1}(tau_y) Until char_{k'+1}(nf_x0))` would say "there is a point between t0 and the first char_{k'+1}(nf_x0) occurrence with type tau_y"... but Until semantics don't directly express this.

**Better encoding**: Use the temporal formula directly:
`temporal_truth M atomMap t (Formula.untl (char_{k'+1}(nf_x0)) (Formula.neg (char_{k'+1}(tau_y))))`

This says: "there exists x > t with char_{k'+1}(nf_x0) at x, and for all r in (t, x), NOT char_{k'+1}(tau_y) at r". The NEGATION of this says: "for every x > t with char_{k'+1}(nf_x0), SOME r in (t, x) has char_{k'+1}(tau_y)". But this involves a universal over all x, not the specific x we want.

**Correct encoding using first occurrence**: On Prior structures (semantic_prior_UZ), if char_{k'+1}(nf_x0) holds somewhere above t, there is a FIRST such x. The interval (t, x) is well-defined. Then:
- "tau_y appears in (t, x)" iff "NOT (neg(tau_y) holds at all points between t and x)"
- As temporal formula at t: NOT (neg(char_{k'+1}(tau_y)) Until char_{k'+1}(nf_x0))

But this uses `NOT (B Until A)` where A = char_{k'+1}(nf_x0) and B = neg(char_{k'+1}(tau_y)). The Until is `B Until A` = "exists s > t with A(s) and B holds at all r in (t,s)". Its negation is: "for all s > t with A(s), there exists r in (t,s) with NOT B(r)" = "for all s > t with nf_x0 at s, there exists r in (t,s) with tau_y at r".

This says: at EVERY occurrence of nf_x0 above t, there is a tau_y point before it. This is STRONGER than what we want (we want tau_y before ONE specific occurrence of nf_x0). But on Prior structures, the first occurrence of nf_x0 above t is well-defined, so this condition at the first occurrence implies it at all later occurrences (because the interval [t, later_x] contains [t, first_x]).

Wait, that's backwards. If tau_y appears before the first nf_x0, it certainly appears before all later nf_x0 occurrences. So the negation `NOT (neg(tau_y) Until nf_x0)` correctly encodes "tau_y appears before the first nf_x0" which is "tau_y is in (t, first_x)".

This is precisely what we need IF the first occurrence of nf_x0 above t corresponds to the witness x we're looking for.

**For the forward direction**: From sub_nf at [x, t] in M, x has type nf_x0, t has type nf_t0, t < x. From Prior-UZ, the first occurrence of char_{k'+1}(nf_x0) above t is some x1 with x1 <= x. If a between-zone witness y is in (t, x), then y is in (t, x1) (since x1 <= x). So the formula holds.

Actually if x1 < x, we have a problem: the formula characterizes (t, x1), not (t, x). But sub_nf was satisfied at [x, t], and x1 might be different from x (x1 has the same 1-var NF but is closer to t).

**This means the between-zone encoding using "first occurrence" doesn't directly correspond to the specific x from the existential.** The formula `NOT (neg(tau_y) Until nf_x0)` at t says "before ANY nf_x0 occurrence above t, tau_y appears". In the backward direction, given this formula, we know that before x (which has type nf_x0 and is above t), tau_y appears. So there is y in (t, x) with tau_y. Good.

In the forward direction: given y in (t, x) with tau_y in M. The formula `NOT (neg(tau_y) Until nf_x0)` at t means "it is not the case that neg(tau_y) holds at all points between t and the first nf_x0". Since y is between t and x (which has type nf_x0), and tau_y holds at y, neg(tau_y) does NOT hold at all points in (t, x). If the first nf_x0 is at x or before x, then neg(tau_y) doesn't hold at all points in (t, first_nf_x0) either (since y < x and y has tau_y, and if first_nf_x0 <= x then (t, first_nf_x0) contains (t, y) or is shorter). Actually, y < x but y might be >= first_nf_x0 (if first_nf_x0 < y). In that case, the interval (t, first_nf_x0) does not contain y. Then neg(tau_y) MIGHT hold at all points in (t, first_nf_x0).

**Problem**: If the first occurrence of nf_x0 above t is at x1 < y (where y is between t and x), then the formula could fail to capture y.

This suggests the encoding needs to use the SPECIFIC x from the Until formula, not the first occurrence. The Until formula `char_kp1(nf_x0) Until top` already specifies a specific x. Can we refine the guard?

**Better approach**: Replace `Formula.top` in the Until guard with a formula that characterizes the between-zone content. Instead of encoding "tau_y appears before any nf_x0 occurrence", encode "tau_y appears somewhere between t and the x from the Until".

The Until semantics: `temporal_truth M atomMap t (A Until B)` = exists s > t with A(s) and for all r in (t, s), B(r). Here A = char_kp1(nf_x0) (holds at x), B = the guard. B holds at EVERY point between t and x.

If we set B to encode which types appear in (t, x): B cannot directly do this because B is evaluated at each individual point r in (t, x), not at the interval as a whole. B(r) at each r can say "r has type in {tau_1, ..., tau_m}" (a disjunction), but this doesn't encode which specific types ARE realized.

**The Rabinovich encoding**: B_j in Rabinovich's Proposition 3.5 is a QUANTIFIER-FREE formula that holds at every point in the interval. It specifies the common properties. For NF types, this would mean: B says "the type at this point is one of {tau_1, ..., tau_m}". The conjunction over all m types is: `disjunction(char_0(tau_1), ..., char_0(tau_m))`. This says "every between-point has one of these types".

But we also need to ensure each tau_i IS realized (not just that no other types appear). For realization, separate conjuncts outside the Until encode "exists y > t with tau_i at y". Combined with "x is the first nf_x0 above t", these give "y is in (t, x)".

**This approach works at K=0** where types are purely atomic (predicate assignments). At K>0, the "type" of y is a depth-(k'+1) 1-var NF, and its characteristic formula is char_{k'+1}(tau_y) which is available from ih_char.

**Encoding scheme for the enriched formula**:
```
enriched_formula =
  char_kp1(nf_t0)  -- t has the right 1-var type
  AND (char_kp1(nf_x0) Until between_guard)  -- x above t with right type, guard in between
  AND conjunction over realized between-types tau_i:
    NOT (NOT char_{k'+1}(tau_i) Until char_kp1(nf_x0))  -- tau_i appears before x
  AND conjunction over non-realized types tau_j:
    (NOT char_{k'+1}(tau_j) Until char_kp1(nf_x0))  -- tau_j doesn't appear before x
```

where `between_guard` = disjunction over all realized between-types: `char_{k'+1}(tau_1) OR ... OR char_{k'+1}(tau_m)`.

**Forward direction**: Given sub_nf at [x, t] in M:
1. char_kp1(nf_t0) at t: from h_t_eval (t has type nf_t0)
2. char_kp1(nf_x0) Until between_guard: x > t with nf_x0 at x, and every point in (t, x) has type in {tau_1, ..., tau_m}. This follows from M0's between-zone structure (M0 and M agree on 2-var NFs at [x, t] via h_eval and h_eval0).
3. Each realized tau_i: from h_eval, there exists y_i in (t, x) with type tau_i. So NOT(NOT char(tau_i) Until char(nf_x0)) holds.
4. Each non-realized tau_j: no y in (t, x) has type tau_j. So NOT char(tau_j) Until char(nf_x0) holds (all between-points have NOT tau_j).

**Backward direction**: Given the enriched formula at t in M:
1. Extract t has type nf_t0, x above t has type nf_x0, t < x.
2. Cross-structure 1-var agreement at x/x0 and t/t0 (same as current code).
3. From the between_guard: every point in (t, x) has type in {tau_1, ..., tau_m}.
4. From the realization conjuncts: each tau_i has a witness in (t, x).
5. From the non-realization conjuncts: each tau_j has no witness in (t, x).
6. Reconstruct the full depth-(K+1) 2-var NF: atoms determined by 1-var types + order. Quantifier conditions: for each ssn : NF (k'+1) 3:
   - If ssn's zone is "y > x" or "y < t": use ih_exist constant-env transfer.
   - If ssn's zone is "t < y < x": the existence of a witness with the right 1-var type (from step 4) plus the quantifier conditions at [y,x,t] need further analysis.

**The gap at the backward direction**: Having a witness y with the right 1-var type tau_y in (t, x) is necessary but not sufficient. The depth-(k'+1) 3-var NF at [y, x, t] requires not just tau_y but also depth-k' 4-var quantifier conditions. These are determined by y's full depth-(k'+1) 1-var NF (which we have) PLUS the depth-k' 3-var NFs at [y,x] and [y,t] (which require the 2-var NF at non-constant envs again).

**THIS IS THE FUNDAMENTAL RECURSION**: Encoding the full 2-var NF requires encoding the full 3-var NF for the quantifier conditions, which requires the full 4-var NF, etc.

**HOWEVER**: The recursion terminates because the DEPTH decreases. The depth-(k'+1) 3-var quantifier condition involves depth-k' 4-var existentials. At depth k', by the IH (ExistPart(K)), the 4-var existentials on CONSTANT envs are already characterized. For non-constant envs at depth k', the same enrichment pattern applies recursively, but at a LOWER depth. Eventually, depth 0 is reached, where everything is purely atomic and the k=0 infrastructure handles it.

**Implementation**: The enriched formula is RECURSIVE in the depth. At each depth level, the between-zone existentials are encoded using the ih_exist formulas from the lower depth. This recursion is EXACTLY the mutual induction on K that already exists.

**Concrete implementation**: In `existPart_succ_n1_bypass`, the between-zone encoding at depth k'+1 uses ExistPart(k') (= ih_exist) to characterize each zone's existentials. The between-zone requires a NEW helper:

```lean
private theorem between_zone_exist_formula
    (ih_char_succ : CharPart atomMap (k' + 1))
    (ih_exist : ExistPart atomMap h_surj k')
    (nf_x nf_t : NormalForm sig (k' + 1 + 1) 1)
    (ssn : NormalForm sig (k' + 1) 3)
    (h_between : ssn encodes t < y < x) :
    ∃ A : Formula,
    ∀ M h_UZ h_SZ (t : M.carrier),
      (atom agreement at t with nf_t) →
      temporal_truth M atomMap t A ↔
      (∃ y x : M.carrier, t < y ∧ y < x ∧
        nf_eval_nf M (k' + 1 + 1) 1 (fun _ => x) nf_x ∧
        nf_eval_nf M (k' + 1 + 1) 1 (fun _ => t) nf_t ∧
        nf_eval_nf M (k' + 1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn)
```

This reduces to: "exists y in (t, first_x_with_nf_x0) with ssn at [y, x, t]". The ssn conditions involve:
- 1-var type of y: char_{k'+1}(tau_y) -- expressible via ih_char_succ
- y's relationship to x: depth-k' 2-var conditions at [y, x] -- expressible via ExistPart(k') at constant env x
- y's relationship to t: depth-k' 2-var conditions at [y, t] -- expressible via ExistPart(k') at constant env t
- y's depth-k' 3-var conditions at [y, x, t]: the BETWEEN ZONE at depth k' -- recursive

The recursion: between-zone encoding at depth (k'+1) uses between-zone encoding at depth k'. This terminates at depth 0 (handled by the k=0 infrastructure).

**But**: the between-zone at depth k' involves `exists z in (y, x) with nf_eval M k' 4 [z,y,x,t] chi`, which is a 4-var existential. This has zones relative to y, x, and t. The "between y and x" sub-zone is again a non-constant-env existential at depth k'-1. The arity INCREASES at each level. Since NormalForm sig K N is finite for each K and N, and K decreases, the recursion does terminate (at depth 0, all arities are purely atomic).

This is a deeply recursive construction. The full encoding would be a new definition by recursion on K, producing temporal formulas that characterize multi-var existentials on non-constant envs.

**THIS IS A MAJOR REWRITE.** Estimated 500-1000 lines of new code.

**Tasks**:
- [ ] Define `between_zone_exist_formula` by recursion on K
- [ ] Prove forward/backward correctness at K=0 using existing k=0 infrastructure
- [ ] Prove forward/backward correctness at K+1 using ih_char_succ and ih_exist
- [ ] Integrate into the enriched formula in KampBypass.lean
- [ ] Close the between-zone sorry from Phase 1

**Timing**: 5 hours
**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- between-zone encoding
- Possibly new helper file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/BetweenZone.lean`

**Verification**:
- Between-zone encoding is sorry-free
- Full enriched formula is sorry-free
- `lake build KampBypass` succeeds with 0 sorries in the k>0 bypass

---

### Phase 3: Delete PriorComposition and Wire Completeness Chain [NOT STARTED]

**Goal**: Remove PriorComposition.lean (false theorems), verify the full completeness chain is sorry-free.

**Tasks**:
- [ ] Delete `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean`
- [ ] Remove the import from KampBypass.lean
- [ ] Move `nonconstenv_atom_agree_until` and `nonconstenv_atom_agree_since` to KampBypassCore.lean if needed by the enriched formula (or inline them)
- [ ] Run `lean_verify existPart_succ_n1_bypass` -- confirm no sorryAx
- [ ] Run `lean_verify kamp_mutual_induction` -- confirm no sorryAx
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx from Kamp path
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Verify NfCharFormula.lean:542/651 remain dead code (not on critical path)

**Timing**: 1.5 hours
**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- delete
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- remove import
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypassCore.lean` -- absorb atom agree lemmas

**Verification**:
- `lean_verify completeness_discrete` shows no sorryAx from Kamp path
- `lake build` succeeds with no regressions

---

### Phase 4: Implementation Summary and Cleanup [NOT STARTED]

**Goal**: Write implementation summary. Clean up any temporary helpers or dead code.

**Tasks**:
- [ ] Write implementation summary to specs/303_k_gt_0_depth_induction/summaries/
- [ ] Clean up any sorry markers or TODO comments in modified files
- [ ] Verify k=0 infrastructure remains untouched and sorry-free
- [ ] Final `lake build` verification

**Timing**: 1 hour
**Depends on**: 3

**Files to modify**:
- Various cleanup edits

**Verification**:
- Final `lake build` passes
- Summary written

## Testing & Validation

- [ ] After Phase 1: `lake build KampBypass` succeeds; sorry only in between-zone
- [ ] After Phase 2: `lake build KampBypass` succeeds; 0 sorries in k>0 bypass
- [ ] After Phase 3: `lean_verify completeness_discrete` shows no sorryAx from Kamp path; full `lake build` passes
- [ ] After Phase 4: Clean build, summary written

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- enriched formula with between-zone encoding
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/BetweenZone.lean` -- between-zone temporal encoding (new, if needed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- DELETED (false theorems)
- `specs/303_k_gt_0_depth_induction/plans/06_ef-game-composition-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/summaries/06_ef-game-summary.md` -- implementation summary

## Rollback/Contingency

1. **Phase 1 fails**: The zone-external encoding (Zones 1, 2) is straightforward and should succeed. If Zone 3 stubbing is problematic, simplify the enriched formula to just add zone-external conjuncts and leave Zone 3 for Phase 2.

2. **Phase 2 fails (between-zone recursion is too complex)**: The recursive encoding terminates by depth decrease, but may be too complex to formalize in a single phase. Fallback options:
   - **Flatten the recursion**: At depth k'+1, encode the between-zone as a conjunction of ih_exist formulas at CONSTANT parent envs (one for each reference point), accepting a weaker characterization that may not capture all 3-var quantifier conditions. If some conditions are lost, the backward direction may need Prior-UZ/SZ to fill gaps.
   - **Use the EF-game argument**: Prove a partial composition theorem that works for the specific case needed (3-var at non-constant [x,t] with t < x), rather than the general r-var case. This narrows the problem to a manageable scope.
   - **Increase effort estimate**: If the approach is correct but needs more code, request additional implementation cycles.

3. **PriorComposition.lean deletion breaks something**: The only import is in KampBypass.lean. Move any useful lemmas before deletion.

4. `git revert` any phase commits to restore the pre-attempt state.
