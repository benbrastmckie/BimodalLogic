# Handoff Analysis: Phase 1 Completion and Phases 2-6 Assessment

**Task**: 155 - Reynolds Pipeline Activation
**Date**: 2026-05-16
**Focus**: Post Phase 1 redesign impact analysis

## Executive Summary

The Phase 1 redesign of `ZIntervalStructure.toOrdered` (carrier = actual interval subtype instead of all of Z) is mathematically correct and simplifies subsequent phases. However, the plan for phases 2-6 requires significant corrections: the transitivity proof (Phase 2) is substantially harder than described, `no_gaps_discrete` (Phase 3) needs a fundamentally different proof strategy, and the Phase 4 cofinal decomposition needs careful rethinking around the ordered sum / Z-interval concatenation step.

## 1. Is the Redesigned `ZIntervalStructure.toOrdered` Correct?

**Verdict: YES, mathematically sound and faithful to Reynolds.**

The new definition (IntegerModel.lean lines 42-73):
- `intervalCarrier` = `{z : Z // Z.lo.elim True (. <= z) /\ Z.hi.elim True (z <= .)}` 
- `toOrdered` builds an `OrderedMonadicStructure` with this subtype as carrier
- `good sig k M` = exists Z such that `k_equiv sig k M (Z.toOrdered sig)`

Reynolds 1994 defines "good" as: M is k-equivalent to a structure whose "flow of time is an interval of the integers." The new carrier IS that interval directly (as a subtype of Z), so this matches Reynolds exactly.

**Key advantage**: `finite_structures_good` becomes a simple order-isomorphism argument via `monoEquivOfFin` + `k_equiv_of_iso`, which is already proved sorry-free.

## 2. Exact Goal States at Each Remaining Sorry

### Sorry 1: `contemp_equiv_is_equiv.trans` (line 280)

```lean
sig : MonadicSignature
k : N
M : OrderedMonadicStructure sig
a b c : M.carrier
hab :
  forall (a_1 b_1 : (OrderedMonadicStructure.subinterval sig M (min a b) (max a b)).carrier),
    a_1 <= b_1 ->
      good sig k
        (OrderedMonadicStructure.subinterval sig (OrderedMonadicStructure.subinterval sig M (min a b) (max a b)) a_1 b_1)
hbc :
  forall (a b_1 : (OrderedMonadicStructure.subinterval sig M (min b c) (max b c)).carrier),
    a <= b_1 ->
      good sig k
        (OrderedMonadicStructure.subinterval sig (OrderedMonadicStructure.subinterval sig M (min b c) (max b c)) a b_1)
x y : (OrderedMonadicStructure.subinterval sig M (min a c) (max a c)).carrier
hxy : x <= y
-- GOAL:
good sig k (OrderedMonadicStructure.subinterval sig (OrderedMonadicStructure.subinterval sig M (min a c) (max a c)) x y)
```

### Sorry 2: `no_gaps_discrete` (line 297)

```lean
sig : MonadicSignature
k : N
M : OrderedMonadicStructure sig
inst_3 : SuccOrder M.carrier
inst_2 : PredOrder M.carrier
inst_1 : NoMaxOrder M.carrier
inst : NoMinOrder M.carrier
a b : M.carrier
h_diff_class : not (contemp_equiv sig k M a b)
-- GOAL:
exists c, contemp_equiv sig k M a c /\ not (contemp_equiv sig k M a (Order.succ c))
```

### Sorry 3: `very_good_implies_good` (line 354)

```lean
sig : MonadicSignature
k : N
M : OrderedMonadicStructure sig
_h_countable : Countable M.carrier
_h_very_good : very_good sig k M
-- GOAL:
good sig k M
```

### Sorry 4: `chronicle_is_good` (line 366)

```lean
M : ChronicleAsPriorModel
sig : MonadicSignature
atomMap : sig.preds -> Formula
k : N
-- GOAL:
good sig k (chronicleAsMonadicStructure M sig atomMap)
```

## 3. Phase 2 Analysis: contemp_equiv_is_equiv.trans

### Handoff Strategy Assessment

The handoff proposes decomposing M|[x,y] as an ordered sum on Bool for the spanning case. This strategy is **conceptually correct but has significant technical obstacles**.

### Key Observations

1. **Nested subinterval problem**: The goal involves `subinterval (subinterval M (min a c) (max a c)) x y`. The hypotheses `hab` and `hbc` give information about `subinterval (subinterval M (min a b) (max a b)) ...` and `subinterval (subinterval M (min b c) (max b c)) ...`. These are nested subtypes with DIFFERENT outer intervals.

2. **Missing infrastructure**: There is no lemma showing that `subinterval (subinterval M a b) x y` is order-isomorphic to `subinterval M x.val y.val` (a "flatten" lemma). This would simplify the problem dramatically because then everything reduces to subintervals of M directly.

3. **The ordered sum decomposition**: To apply `doets_lemma_1_4` on `Bool`, we need to show `M|[x.val, y.val]` is isomorphic (as an ordered monadic structure) to `orderedSum sig Bool (fun b => if b then M|[b_val+1, y.val] else M|[x.val, b_val])`. The carrier of the ordered sum is `Sigma (fun (i : Bool) => ...)` with Sigma.Lex order. Constructing this isomorphism requires showing the sigma lex carrier bijects with the subinterval carrier and preserves both order and predicates.

4. **The final step**: After showing the ordered sum of two good structures is good via `doets_lemma_1_4`, we need that "ordered sum of two Z-intervals is a Z-interval." This requires constructing a `ZIntervalStructure` whose `intervalCarrier` is isomorphic to `Sigma (fun (b : Bool) => Z_b.intervalCarrier)` under lex order. This IS true (concatenation of two Z-intervals [lo1, hi1] and [lo2, hi2] is the Z-interval [lo1, hi1 + hi2 - lo2 + 1] after shifting), but the proof requires:
   - Building the explicit bijection between `Sigma Bool Z_b.intervalCarrier` (lex) and a single `ZIntervalStructure.intervalCarrier`
   - Showing it is an order isomorphism
   - Showing predicates transfer

### Recommended Approach

**Step A**: Prove a "flatten" lemma:
```lean
theorem subinterval_subinterval_iso (sig) (M) (a b : M.carrier) 
    (x y : (M.subinterval sig a b).carrier) (hxy : x <= y) :
    (M.subinterval sig a b).subinterval sig x y ≃o M.subinterval sig x.val y.val
```
This is straightforward: both carriers are `{z : M.carrier // x.val <= z /\ z <= y.val}` (possibly with extra outer bounds that are always satisfied).

**Step B**: Use the flatten lemma + `k_equiv_of_iso` to reduce the goal to showing `good sig k (M.subinterval sig x.val y.val)`.

**Step C**: Case split on whether `x.val` and `y.val` are both <= b, both >= b, or spanning:
- Same-side: reduce to `hab` or `hbc` hypotheses (after flatten + suitable casting)
- Spanning: decompose via ordered sum on Bool, apply `doets_lemma_1_4`, then show ordered sum of two Z-intervals is a Z-interval

**Difficulty**: HIGH. The spanning case alone requires 3-4 non-trivial helper lemmas.

### Viability of Handoff Strategy

**Partially viable.** The overall structure (case split + ordered sum on Bool) is correct. But the handoff underestimates the difficulty by not mentioning the nested-subinterval type mismatch problem or the need for the "flatten" isomorphism.

## 4. Phase 3 Analysis: no_gaps_discrete

### Handoff Strategy Assessment

The handoff and plan propose "well-founded induction on the distance between a and b" with a maximum principle argument. This approach has problems:

1. **No well-founded metric available**: The structure M has type `OrderedMonadicStructure sig` with carrier having `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder` but NOT necessarily `Countable` at this point. Without countability, there's no natural well-founded "distance" function (the carrier might be uncountable).

2. **The correct proof** (Reynolds 1994): This is actually a **straightforward proof by contradiction**. The argument is:
   - Suppose a and b are NOT in the same class
   - WLOG assume a < b (since ~M is symmetric, both cases lead to the same conclusion)
   - Consider the set S = {c in [a,b] | contemp_equiv sig k M a c}
   - S is nonempty (a is in S since the reflexivity case holds)
   - b is NOT in S (by h_diff_class + symmetry + one direction of WLOG)
   - Since M is discrete: there exists c in S such that Order.succ c is NOT in S
   - This c is the witness

3. **The crucial gap**: Why does such a c exist? In a discrete linear order, for any nonempty downward-closed (in [a,b]) set S with a in S and b not in S, there is a "last" element c in S (meaning succ(c) is not in S). This follows because if every element c in S had succ(c) also in S, then by induction (S is closed under succ in [a,b]), b would be in S -- contradiction.

### But there's a subtlety

The set S need not be "closed under successor" in general -- contemp_equiv is NOT necessarily preserved under successor (that's what we're TRYING to prove fails to exist). The correct argument:

- Since a and b are in different classes, NOT every point between them is equivalent to a
- Let c be any point with c ~M a but succ(c) NOT ~M a (if no such c exists, then by the successor-closed argument, b ~M a, contradiction)

The discrete induction works as follows: define the "reach" function r(n) = succ^n(a). Either:
- There exists n with r(n) ~M a but r(n+1) NOT ~M a (done, take c = r(n))
- For all n, r(n) ~M a implies r(n+1) ~M a. Then by induction, all r(n) ~M a. Since M has NoMaxOrder and SuccOrder, the successor iterates r(n) are cofinal above a. So for any b > a, there exists n with r(n) >= b, hence b ~M r(n) ~M a by transitivity, contradiction.

**Wait**: But this uses TRANSITIVITY which we haven't proved yet! Phase 3 depends on Phase 2.

### Critical Dependency Issue

The plan says Phase 3 depends only on Phase 1, but the proof of `no_gaps_discrete` uses transitivity of ~M (via the successor chain argument). However, looking more carefully at the goal and the proof in `one_class`:

```lean
theorem one_class ... :
    forall (a b : M.carrier), contemp_equiv sig k M a b := by
  by_contra h_not_all
  push_neg at h_not_all
  obtain <a, b, h_diff> := h_not_all
  obtain <c, hc_equiv, hc_succ_not> := no_gaps_discrete sig k M a b h_diff
  have h_succ : contemp_equiv sig k M c (Order.succ c) :=
    no_boundary_at_successor sig k M c
  ...
```

The `one_class` proof gets `c` from `no_gaps_discrete`, then uses `no_boundary_at_successor` to show c ~M succ(c), then uses transitivity to derive a contradiction. So `no_gaps_discrete` is used BEFORE transitivity gives us the contradiction -- but `no_gaps_discrete` itself might need transitivity internally!

**Actually**: Re-reading Reynolds more carefully, the proof of `no_gaps_discrete` does NOT need transitivity. It needs only:
- Discreteness (SuccOrder)
- The negation hypothesis: NOT (a ~M b)
- It produces c with a ~M c but NOT (a ~M succ(c))

The proof: since ~M classes are convex (a consequence of the definition: contemp_equiv a b means very_good on [min a b, max a b], which is a property of the INTERVAL between them), and contemp_equiv is reflexive, there must be a boundary between the class of a and outside it. In a discrete order, boundaries happen at successor pairs.

**But convexity of classes requires transitivity!** This is a circular dependency.

### Resolution

The actual proof structure in Reynolds 1994 is:
1. First prove transitivity (our Phase 2) 
2. Then prove no_gaps (our Phase 3)
3. Then get one_class

The plan's dependency analysis is WRONG: Phase 3 actually depends on Phase 2 (transitivity), not just Phase 1. The plan says they can execute in parallel (Wave 2), but they cannot.

**Alternative approach for `no_gaps_discrete` that avoids transitivity**:

Actually, looking at the goal more carefully:
```
exists c, contemp_equiv sig k M a c /\ not (contemp_equiv sig k M a (Order.succ c))
```

This just needs: given a and b with NOT (a ~M b), find c with a ~M c but NOT (a ~M succ c).

Without transitivity, we can still argue: WLOG a < b. Consider the sequence a, succ(a), succ(succ(a)), ... This is a discrete ascending sequence. Either:
- There exists n where a ~M succ^n(a) but NOT (a ~M succ^{n+1}(a)). Done.
- For all n, a ~M succ^n(a). Then specifically, does there exist n with succ^n(a) >= b?

In a discrete order with NoMaxOrder, succ^n(a) is strictly increasing. But without well-foundedness or Archimedean property, we can't guarantee succ^n(a) ever reaches b.

**Actually the issue is deeper**: In an arbitrary discrete linear order without endpoints, it's possible that `a < b` but no iterate of succ applied to a ever reaches or exceeds b (think of Z + Z where a is in the first copy and b in the second). So the "iterate succ from a" approach doesn't work without additional assumptions.

**The correct approach**: The proof of `no_gaps_discrete` DOES require transitivity as a prerequisite. The plan must be corrected: Phase 3 depends on Phase 2.

**Revised proof sketch for Phase 3** (assuming Phase 2 complete):
- Given NOT (a ~M b), the equivalence class [a] = {c | a ~M c} is a proper subset of M.carrier (b is not in it)
- By transitivity + reflexivity: [a] is nonempty (contains a) and a ~M c implies a ~M succ(c) or not
- Since [a] is not all of M.carrier, and [a] is closed under the equivalence relation, there must be a "boundary" of [a]
- In discrete order: take any d not in [a]. WLOG d > a (or d < a, symmetric). Consider the set S = {c in [a,d] | a ~M c}. This set contains a but not d. By discreteness + well-ordering of the interval below d: let c_max = sup S in [a,d). Then a ~M c_max but succ(c_max) not in S.
- The sup exists because [a,d] in a discrete order is order-isomorphic to a finite set or to N (if d is unreachable by succ iterates -- but in that case by the convexity argument using transitivity, every point between a and d would need to be in [a] or not, and the boundary must exist).

**Key insight for Lean implementation**: The simplest approach uses `WellFounded.min` on the well-ordering of `{c | a <= c /\ not (a ~M c)}` which is nonempty (contains b or a point derived from b). Then pred of the min gives the desired c.

### Recommended Approach for Phase 3

```lean
-- Given h_diff_class : not (contemp_equiv sig k M a b)
-- Use well-foundedness approach with nat-indexed intervals
-- This requires Phase 2 (transitivity) to establish convexity
```

**After Phase 2**:
1. WLOG a <= b (or handle both orderings)
2. Let S = {c : M.carrier | a <= c /\ not (contemp_equiv sig k M a c)}
3. S is nonempty (contains b or a suitable point)
4. Use Zorn's lemma or well-founded descent on the discrete order below any element of S
5. The minimum of S minus 1 (i.e., pred of the min) is the desired boundary point

## 5. Phase 4 Analysis: very_good_implies_good

### Goal State

```lean
_h_countable : Countable M.carrier
_h_very_good : very_good sig k M
-- GOAL: good sig k M
```

### Strategy Assessment

The plan proposes a cofinal decomposition: partition M into Z-indexed finite intervals, show each is good, apply `doets_lemma_1_4` to get k-equiv to ordered sum of Z-intervals, then show the ordered sum of Z-intervals is a Z-interval.

**Problem 1: Missing hypotheses.** The goal state shows ONLY `Countable M.carrier` and `very_good sig k M`. But Reynolds Lemma 16 applies to structures that are also discrete and without endpoints. These hypotheses are NOT in the theorem statement.

Looking at the theorem statement:
```lean
theorem very_good_implies_good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    (_h_countable : Countable M.carrier) (_h_very_good : very_good sig k M) :
    good sig k M
```

This is too general! Without discreteness (SuccOrder) and no-endpoints (NoMaxOrder, NoMinOrder), we cannot construct the cofinal sequence required by Reynolds Lemma 16.

**However**: In the ACTUAL usage path (`chronicle_is_good`), M is always the chronicle which IS discrete and without endpoints. Two options:
1. Add `[SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier]` to the theorem statement
2. Use a weaker argument that works for general countable structures

For option 2: In a general countable linear order, we can enumerate the carrier as {a_0, a_1, a_2, ...} and build a sequence of expanding intervals. But for the ordered sum decomposition to work, we need the intervals to be CONSECUTIVE (no gaps). This requires discreteness.

**Recommendation**: Add discreteness and no-endpoints hypotheses to `very_good_implies_good`. This matches Reynolds exactly and the only caller (`chronicle_is_good`) has these properties.

### Ordered Sum of Z-Intervals is a Z-Interval

The plan claims that "an ordered sum of Z-intervals indexed by Z IS a single Z-interval." This is the key step. With the new carrier definition:

- Each component `Z_i.intervalCarrier` = `{z : Z // lo_i <= z /\ z <= hi_i}` 
- The ordered sum carrier = `Sigma (fun (i : Z) => Z_i.intervalCarrier)` with Sigma.Lex order
- We need this to be order-isomorphic to SOME `ZIntervalStructure.intervalCarrier`

For the unbounded case (lo=none, hi=none), the target carrier is `{z : Z // True /\ True}` which is isomorphic to Z.

**The construction**: Given a Z-indexed family of finite Z-intervals (each [lo_i, hi_i] has `hi_i - lo_i + 1` elements), the ordered sum is order-isomorphic to Z via:
- Shift each interval: position of element z in interval i = (cumulative size of intervals < i) + (z - lo_i)

But this only works if the intervals are non-empty and have finite, computable sizes. Since each interval is finite (from the very_good + subinterval decomposition), this holds.

**The Lean proof** requires:
1. Construct an explicit `OrderIso` from `Sigma (fun i : Z => Z_i.intervalCarrier)` (with Lex) to `{z : Z // True}`
2. Show predicates transfer through this iso
3. Apply `k_equiv_of_iso` (already proved)

**Difficulty**: MEDIUM-HIGH. The explicit construction of the OrderIso involves cumulative sums over Z-indexed finite intervals.

### Impact of Carrier Redesign on Phase 4

The carrier redesign makes Phase 4 slightly MORE complex because:
- `orderedSum` produces `Sigma (fun i => (ms i).carrier)` with Lex
- Each `(ms i).carrier` is now a SUBTYPE (the Z-interval carrier), not a simple type
- The order-isomorphism to a single Z-interval carrier (also a subtype) requires careful subtype manipulation

But it also makes it MORE natural because the mathematical claim IS that concatenating intervals gives an interval.

## 6. Phase 5-6 Analysis: Truth Transfer and TaskFrame

### intervalCarrier When Both Bounds Are None

When `lo = none` and `hi = none`:
```
intervalCarrier = {z : Z // none.elim True (. <= z) /\ none.elim True (z <= .)}
               = {z : Z // True /\ True}
```

This is `{z : Z // True}` which is isomorphic to Z via:
- `forward : Z -> {z : Z // True}` = `fun z => <z, trivial>`
- `backward : {z : Z // True} -> Z` = `Subtype.val`

**Impact on Phase 6**: The TaskFrame Int construction needs the carrier to BE Int (or isomorphic to Int). Since `{z : Z // True}` is trivially isomorphic to Z (= Int in Lean 4), this works. The isomorphism `Equiv.subtypeUnivEquiv (fun _ => trivial)` or similar provides the bridge.

### How Truth Transfer Works (Phase 5)

The bridge from `k_equiv` to formula agreement:

1. `k_equiv sig k M N` means `k_type_of sig k M = k_type_of sig k N`
2. Unfolding: for all `nf : NormalForm sig k 0`, `nf_eval_nf M k 0 Fin.elim0 nf <-> nf_eval_nf N k 0 Fin.elim0 nf`
3. By `doets_lemma_1_1`: for any `phi : MonadicFormula sig 0` with `phi.quantifier_depth <= k`, `eval M Fin.elim0 phi <-> eval N Fin.elim0 phi`

**For temporal truth**: `temporal_truth M atomMap t phi <-> eval M (fun _ => t) (table sig atomMap phi)` (by `table_correctness`)

But there's a subtlety: `table sig atomMap phi` is a `MonadicFormula sig 1` (ONE free variable, the time point). To use `doets_lemma_1_1` which works at the 0-variable sentence level, we need to close over the time variable.

The correct approach:
- For each point t in M, there is a corresponding point t' in N (via some map from the k-equivalence)
- Actually: k-equivalence at 0 variables does NOT directly give pointwise correspondence

**This is the key difficulty of Phase 5**: `k_equiv` is about SENTENCE-level agreement (0 free variables). But temporal truth at a point t is about a formula with 1 free variable evaluated at t. The connection requires:
- Either: showing that k-equiv implies agreement on ALL existentially-closed 1-variable formulas (which it does, since `exists x, phi(x)` is a sentence), or
- Using the fact that for the SPECIFIC formula of interest (`neg phi` evaluated at some point), we can find the corresponding sentence

**The correct argument** (Reynolds): Since `chronicle_is_good` gives us `k_equiv sig k (chronicle) (Z.toOrdered sig)` where k >= operator_depth(phi) + 1, and the chronicle contains a point t where `neg phi` holds (temporal truth on the chronicle at the root point), we need:
- `neg phi` holds temporally at root t in the chronicle
- Transfer this to "neg phi holds at SOME point in Z.toOrdered"

This works via: `temporal_truth chronicle atomMap t (neg phi)` <-> `eval chronicle (fun _ => t) (table (neg phi))` (by table_correctness) <-> EXISTS in the k-type of chronicle -> EXISTS in the k-type of Z (by k-equiv at the sentence level containing the existential closure).

Actually simpler: the sentence `exists x, table(neg phi)(x)` has depth <= operator_depth(phi) + 1 <= k. By k-equiv, this sentence has the same truth value in chronicle and Z.toOrdered. Since it's true in chronicle (witnessed by root t), it's true in Z.toOrdered. Extract the witness.

**Phase 5 is VIABLE** with this approach. `doets_lemma_1_1` + `table_correctness` + `table_depth_bound` provide exactly what's needed.

### Phase 6: TaskFrame Int Construction

Once we have:
- `Z : ZIntervalStructure sig` with `lo = none, hi = none`
- A point `t0 : Z.intervalCarrier` where `neg phi` holds temporally on `Z.toOrdered sig`

We need a TaskFrame on Int. The construction:
- Carrier isomorphism: `Z.intervalCarrier` ({z : Z // True}) <-> Z (Int)
- Transfer truth from Z.toOrdered to a Z-structure on Int
- Build TaskFrame Int with single WorldState = Unit
- Build WorldHistory covering all of Int
- Show truth_at corresponds to temporal_truth

This is conceptually straightforward given the carrier isomorphism. The plan's description is essentially correct.

## 7. orderedSum and subinterval Compatibility

### orderedSum definition (NEquivalence.lean line 122):
```lean
noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms : I -> OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Sigma fun i => (ms i).carrier
  interp := fun p x => (ms x.1).interp p x.2
  carrier_order := Sigma.Lex.linearOrder
```

### subinterval definition (MonadicFO.lean line 129):
```lean
def OrderedMonadicStructure.subinterval (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a <= x /\ x <= b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance
```

### Compatibility Analysis

The key question for Phase 2 (spanning case): can we show that `M.subinterval sig x.val y.val` (carrier = `{z : M.carrier // x.val <= z /\ z <= y.val}`) is order-isomorphic to `orderedSum sig Bool (fun b => ...)` (carrier = `Sigma (fun (i : Bool) => ...)`)?

**Yes, but it requires**:
1. A decomposition point b_val with x.val <= b_val <= y.val
2. Component 1: `M.subinterval sig x.val b_val` (carrier = `{z | x.val <= z /\ z <= b_val}`)
3. Component 2: `M.subinterval sig (Order.succ b_val) y.val` (carrier = `{z | succ(b_val) <= z /\ z <= y.val}`)  
4. An OrderIso from `{z | x.val <= z /\ z <= y.val}` to `Sigma Bool (fun i => if i = false then component_1.carrier else component_2.carrier)` with Sigma.Lex

The isomorphism maps:
- `z` with `x.val <= z <= b_val` to `<false, <z, proof>>`
- `z` with `succ(b_val) <= z <= y.val` to `<true, <z, proof>>`

This IS an order isomorphism under Sigma.Lex because:
- Cross-component: false < true in Bool, so left component < right component
- Within component: inherited order matches

**This construction is feasible** but requires building the explicit OrderIso and showing it's well-defined (every z in [x.val, y.val] is either <= b_val or >= succ(b_val), which holds by discreteness: in a discrete order, there's no element strictly between b_val and succ(b_val)).

## 8. Overall Plan Revision Recommendations

### Critical Corrections Needed

1. **Phase 3 depends on Phase 2** (not parallel in Wave 2). The `no_gaps_discrete` proof requires transitivity of ~M to establish that equivalence classes are convex. Corrected dependency graph:
   ```
   Wave 1: Phase 1 (COMPLETED)
   Wave 2: Phase 2
   Wave 3: Phase 3 (depends on Phase 2)
   Wave 4: Phase 4 (depends on Phase 3)
   Wave 5: Phase 5 (depends on Phase 4)
   Wave 6: Phase 6 (depends on Phase 5)
   ```

2. **Phase 2 needs new helper lemmas** not mentioned in the plan:
   - `subinterval_subinterval_iso`: flattening nested subintervals
   - `subinterval_decompose_discrete`: decomposing a subinterval at a point into an ordered sum on Bool
   - `orderedSum_two_z_intervals_is_z_interval`: concatenation of two Z-intervals is a Z-interval
   - `good_of_iso`: if M is good and N is order-isomorphic to M (with matching predicates), then N is good

3. **Phase 3 approach must change**: Instead of "well-founded induction on distance" (which doesn't work in general discrete orders), use:
   - Transitivity of ~M (from Phase 2) to establish convexity of classes
   - Classical minimum argument: `{c | a <= c /\ not (a ~M c)}` is nonempty, take its infimum in the well-order
   - Or use `WellFounded` machinery from Lean's `Nat.lt_wfRel` applied through the discrete order

4. **Phase 4 needs the hypothesis correction**: Add `[SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier]` to `very_good_implies_good`.

5. **Phase 5 strategy correction**: The truth transfer does NOT require pointwise correspondence between M and N. Instead, use existential closure: `exists x, table(neg phi)(x)` is a sentence of depth <= k, and k-equiv preserves sentence truth.

### Effort Estimate Revision

| Phase | Original | Revised | Reason |
|-------|----------|---------|--------|
| 2 | 3 hours | 6 hours | 3-4 new helper lemmas, complex subtype manipulation |
| 3 | 3 hours | 3 hours | Simpler once Phase 2 done (but now sequential) |
| 4 | 4 hours | 5 hours | Hypothesis fix + explicit OrderIso construction for Z-indexed sum |
| 5 | 5 hours | 4 hours | Simpler than expected (existential closure argument) |
| 6 | 5 hours | 4 hours | Carrier isomorphism is trivial; TaskFrame construction straightforward |
| **Total** | **20 hours** | **22 hours** | Sequential phases add calendar time, not necessarily effort |

### Should the Plan Be Revised?

**YES.** The plan must be revised to:
1. Fix the dependency graph (Phase 3 depends on Phase 2)
2. Add the missing helper lemmas for Phase 2
3. Fix the `very_good_implies_good` statement (add typeclass hypotheses)
4. Correct the Phase 3 proof strategy
5. Clarify the Phase 5 existential-closure approach (simpler than what's described)
