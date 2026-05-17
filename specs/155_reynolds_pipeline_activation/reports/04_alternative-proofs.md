# Alternative Proof Strategies for `good_of_split_at_succ`

**Task**: 155 (Reynolds Pipeline Activation)
**Focus**: Investigate whether a completely different proof strategy can avoid the stuck sorry
**Date**: 2026-05-16

---

## Executive Summary

The sorry in `good_of_split_at_succ` (IntegerModel.lean:470) is **NOT on the critical path** for discrete completeness. The theorem is used only inside `contemp_equiv_is_equiv`, which is itself unused by any downstream theorem. The working pipeline (chronicle_is_good -> doets_countermodel_discrete) bypasses it entirely via `IsSuccArchimedean`. Nevertheless, filling this sorry has independent mathematical value and strengthens the formalization.

**Recommended approach**: Strategy F (Finite Witness Replacement) combined with Strategy G (case split on k). This constructs a bounded Z-interval witness from an unbounded one, making the ordered sum finite and allowing `finite_structures_good` to close the goal.

---

## 0. Critical Path Analysis

Before evaluating strategies, an important structural finding:

### `good_of_split_at_succ` Is Dead Code

| Theorem | Used By | On Critical Path? |
|---------|---------|-------------------|
| `good_of_split_at_succ` | `contemp_equiv_is_equiv` (line 573) | No |
| `contemp_equiv_is_equiv` | (nothing outside IntegerModel.lean) | No |
| `no_gaps_discrete` | (nothing outside IntegerModel.lean) | No |
| `one_class` | `chronicle_is_good` (indirectly, same file) | **Already proved (direct)** |
| `chronicle_is_good` | Transfer.lean (commented out, fallback used) | Partially |

The discrete completeness pipeline uses:
1. `chronicle_is_good` -- proved directly via `k_equiv_of_iso` using `orderIsoIntOfLinearSuccPredArch` (chronicle domain is isomorphic to Z)
2. Does NOT need `contemp_equiv_is_equiv` because `one_class` is proved using `IsSuccArchimedean` + `finite_structures_good` (all bounded intervals are finite in succ-Archimedean orders)

### When Would It Be Needed?

Reynolds Lemma 17 (`contemp_equiv_is_equiv`) is essential for the **dense case** (future work) or any case where the underlying linear order does NOT have `IsSuccArchimedean`. In such cases, you cannot derive finiteness of intervals from first principles and must use the ~M equivalence machinery.

---

## 1. Strategy Assessment

### Strategy A: Direct Z-interval Construction (Bypass orderedSum Goodness)

**Idea**: Skip proving `orderedSum witnesses` is good. Instead, directly construct Z3 from M|[t,u] via composition of the chain M|[t,u] ~k orderedSum pieces ~k orderedSum witnesses ~k Z3.

**Assessment**: INFEASIBLE (circular). The chain `M|[t,u] ~k orderedSum witnesses` is proved, but concluding `good sig k (M.subinterval sig t u)` requires a Z3 such that `orderedSum witnesses ~k Z3.toOrdered`. This IS the same problem: show the ordered sum is good.

### Strategy B: Direct Z3 Without orderedSum

**Idea**: Directly construct Z3 : ZIntervalStructure such that `k_equiv sig k (M.subinterval sig t u) (Z3.toOrdered sig)` without going through the ordered sum at all.

**Assessment**: INFEASIBLE (no construction principle available). The only way to get k-equiv to a Z-interval is:
- Order-isomorphism (requires the carrier to literally be an interval of Z -- fails for general M)
- Compose known k-equivalences (brings us back to the ordered sum approach)
- Use `doets_lemma_1_5` (type-matching sums) -- currently SORRIED and even harder to prove

### Strategy C: Reformulate Using `good` Definition Differently

**Idea**: Find an alternative characterization of `good` that makes split easier.

**Assessment**: INFEASIBLE. The definition `good sig k M := exists Z, k_equiv sig k M (Z.toOrdered sig)` is exactly Reynolds's definition. Any alternative characterization would require proving equivalence with this definition, which would be at least as hard.

### Strategy D: Weaken the Theorem (Dead Code Removal)

**Idea**: Since `good_of_split_at_succ` is dead code, simply remove the sorry and mark the theorem as a standalone mathematical result not needed for completeness.

**Assessment**: FEASIBLE but unsatisfying. The sorry doesn't block anything. Options:
- Leave the sorry in place (current state -- does not break any builds)
- Add an `axiom` declaration explicitly (more honest than sorry)
- Remove `contemp_equiv_is_equiv` transitivity case entirely

**Verdict**: Not a "proof strategy" but a pragmatic option. The sorry is technically harmless.

### Strategy E: Use Existing Infrastructure

**Idea**: Check if `ordered_sum_preserves_good` or similar exists.

**Assessment**: No such theorem exists in the codebase. The only relevant theorems are:
- `doets_lemma_1_4` (preserves k-equiv under pointwise equiv -- PROVED)
- `doets_lemma_1_5` (type-matching sums -- SORRIED)
- `finite_structures_good` (finite implies good -- PROVED)
- `k_equiv_of_iso` (iso implies k-equiv -- PROVED)

### Strategy F: Finite Witness Replacement (RECOMMENDED)

**Idea**: Replace unbounded Z-interval witnesses with bounded ones, making the ordered sum finite, then apply `finite_structures_good`.

**Core Insight**: If `k_equiv sig k M (Z.toOrdered sig)` and M has both a max and a min element, then for k >= 2 we can find Z' with both `lo = some _` and `hi = some _` (i.e., finite carrier) that is also k-equivalent to M.

**Why it works**:
- M|[t,b] has max element `<b, htb, le_refl b>` and min element `<t, le_refl t, htb>`
- M|[succ b, u] has max element `<u, ...>` and min element `<succ b, ...>`
- "Has a maximum" is expressible as a depth-2 sentence: `exists x, forall y, not (x < y)`
- "Has a minimum" is expressible as a depth-2 sentence: `exists x, forall y, not (y < x)`
- At k >= 2: k-equiv preserves these properties, so Z1 must be bounded, hence finite
- At k = 0: trivial (already handled in code)
- At k = 1: special argument needed (see below)

**The k = 1 case**:
At depth 1 with 0 free variables, `NormalForm sig 1 0 = (AtomKind sig 0 -> Bool) x (NormalForm sig 0 1 -> Bool)`. Since `AtomKind sig 0` is empty (no variables), the atom part is trivially `fun a => a.elim`. The quantifier part records which `NormalForm sig 0 1` (= depth-0 1-types = `AtomKind sig 1 -> Bool` = predicate assignments on a single variable) are existentially realized. So at depth 1, k-equivalence records exactly which predicate-patterns are realized by some element.

For k = 1: construct a finite Z-interval [0, m-1] where m = number of distinct predicate-patterns realized by the ordered sum, with each integer assigned a different realized pattern. This finite Z-interval is 1-equivalent to the ordered sum (same set of realized 1-types). Since it's bounded, it witnesses `good sig 1 (orderedSum Bool witnesses)`.

**Proof outline for k >= 2**:

```
lemma good_bounded_witness (sig : MonadicSignature) (k : Nat) (hk : k >= 2)
    (M : OrderedMonadicStructure sig) [OrderBot M.carrier] [OrderTop M.carrier]
    (h_good : good sig k M) :
    exists Z : ZIntervalStructure sig, Z.lo = some _ /\ Z.hi = some _ /\
      k_equiv sig k M (Z.toOrdered sig) := by
  -- "has max" and "has min" are depth-2 sentences
  -- k-equiv at k >= 2 preserves depth-2 truth
  -- So the Z-interval witness also has max and min
  -- A Z-interval with both max and min is bounded (lo = some, hi = some)
  sorry -- requires: depth-2 expressibility of has_max/has_min
```

**Lemmas needed**:
1. `has_max_expressible_depth_2`: "has a maximum" is a depth-2 sentence in monadic FO
2. `has_min_expressible_depth_2`: "has a minimum" is a depth-2 sentence in monadic FO
3. `bounded_Z_interval_fintype`: Z-interval with both bounds is Fintype
4. `good_of_k1`: for k=1, direct construction of finite witness from predicate-pattern enumeration

### Strategy G: Case Split on k (Combined with F)

**Idea**: Split the proof into k = 0, k = 1, and k >= 2, using different arguments for each.

**Assessment**: This is the natural structural approach that makes Strategy F work. The k=0 case is already proved in the code. The k=1 and k>=2 cases need the arguments from Strategy F.

### Strategy H: Prove via `doets_lemma_1_5`

**Idea**: Prove `doets_lemma_1_5` (currently sorried) and use it to show ordered sum of Z-intervals is k-equiv to a single Z-interval.

**Assessment**: HARDER THAN THE ORIGINAL PROBLEM. `doets_lemma_1_5` requires showing that two ordered sums with matching k-type distributions are k-equivalent, which is a generalization of what we need. It's marked as "not on discrete critical path" for good reason.

---

## 2. Recommended Approach

### Primary: Strategy F + G (Finite Witness Replacement with Case Split)

```lean
-- The sorry lives inside: good sig (k' + 1) (orderedSum sig Bool witnesses)
-- where witnesses = [Z1.toOrdered, Z2.toOrdered]

-- Case 1: k' + 1 = 1 (i.e., k' = 0)
-- Argument: enumerate realized predicate-patterns, construct finite Z-interval
-- Key lemma:
theorem good_of_orderedSum_k1 (sig : MonadicSignature)
    (I : Type) [LinearOrder I] [Fintype I]
    (ms : I -> OrderedMonadicStructure sig)
    (h_good : forall i, good sig 1 (ms i)) :
    good sig 1 (orderedSum sig I ms)

-- Case 2: k' + 1 >= 2
-- Argument: bounded Z-intervals -> finite ordered sum -> finite_structures_good
-- Key lemma:
theorem Z_interval_bounded_of_has_max_min (sig : MonadicSignature) (k : Nat) (hk : 2 <= k)
    (Z : ZIntervalStructure sig) [Nonempty Z.intervalCarrier]
    (h_max : exists (x : Z.intervalCarrier), forall (y : Z.intervalCarrier), y <= x)
    (h_min : exists (x : Z.intervalCarrier), forall (y : Z.intervalCarrier), x <= y) :
    exists (a b : Z), Z.lo = some a /\ Z.hi = some b

theorem k_equiv_preserves_has_max (sig : MonadicSignature) (k : Nat) (hk : 2 <= k)
    (M N : OrderedMonadicStructure sig)
    (h_eq : k_equiv sig k M N)
    (h_max : exists (x : M.carrier), forall (y : M.carrier), y <= x) :
    exists (x : N.carrier), forall (y : N.carrier), y <= x
```

### Estimated Complexity

| Lemma | Difficulty | Lines (est.) |
|-------|-----------|------|
| `good_of_orderedSum_k1` | Medium | 40-60 |
| `k_equiv_preserves_has_max` | Hard (core) | 60-100 |
| `k_equiv_preserves_has_min` | Same as above | 60-100 |
| `bounded_Z_interval_fintype` | Easy | 15-20 |
| Integration in `good_of_split_at_succ` | Medium | 30-40 |
| **Total** | | **~250 lines** |

The hardest part is `k_equiv_preserves_has_max`: showing that "has a maximum" is preserved by k-equivalence at k >= 2. This requires:
1. Encoding "has max" as a NormalForm sentence at depth 2
2. Showing that if this NormalForm evaluates to true in M, it evaluates to true in N (follows from k_equiv definition at k >= 2)

This encoding requires careful work with `NormalForm sig 2 0` and `nf_eval_nf`, but is fundamentally straightforward since the framework already supports arbitrary monadic FO sentences up to any depth.

---

## 3. Alternative Pragmatic Options

### Option 1: Accept Dead Code (Lowest Effort)

Since `good_of_split_at_succ` is not on the critical path, leave the sorry in place. It doesn't propagate to any theorem used in the actual completeness proof.

**Pros**: Zero effort, no risk
**Cons**: Incomplete formalization of Reynolds Lemma 17

### Option 2: Add IsSuccArchimedean Hypothesis

Add `[IsSuccArchimedean M.carrier]` to `good_of_split_at_succ`. Then M|[t,b] would be finite (via `subinterval_finite_of_succ_archimedean`), hence good via `finite_structures_good`, making the ordered sum finite.

But wait -- this would make the theorem trivially provable (if IsSuccArchimedean, any bounded subinterval is finite, hence good). The theorem becomes pointless with that hypothesis.

Actually, this IS what `one_class` does! With IsSuccArchimedean, you don't need `good_of_split_at_succ` at all -- you just prove every subinterval is finite directly.

**Verdict**: This confirms the dead-code analysis. With IsSuccArchimedean, `good_of_split_at_succ` is never needed.

### Option 3: Axiomatize

Replace the sorry with an explicit axiom:
```lean
axiom ordered_sum_Z_intervals_good (sig : MonadicSignature) (k : Nat)
    (Z1 Z2 : ZIntervalStructure sig) :
    good sig k (orderedSum sig Bool (fun i => if i = false then Z1.toOrdered sig else Z2.toOrdered sig))
```

**Pros**: Honest, clearly documented mathematical assumption
**Cons**: Axioms are bad practice in Lean formalizations

---

## 4. Detailed Proof Sketch for Strategy F+G (k >= 2 case)

### Step 1: Express "has max" in the NormalForm framework

At depth 2 with 0 free variables, `NormalForm sig 2 0` has the structure:
```
(AtomKind sig 0 -> Bool)      -- trivial (empty domain)
x
(NormalForm sig 1 1 -> Bool)  -- which depth-1 1-types are realized
```

A `NormalForm sig 1 1` has the structure:
```
(AtomKind sig 1 -> Bool)      -- which preds hold at x
x
(NormalForm sig 0 2 -> Bool)  -- which depth-0 2-types are realized with x
```

A `NormalForm sig 0 2` = `AtomKind sig 2 -> Bool` specifies for pairs (x, y):
- Which predicates hold at each variable
- The order relation between x and y

"Has max" = "there exists x such that for all y, NOT (x < y)":
- This says: there's a 1-type t of an element x such that t's quantifier assignment says: no 2-type with x < y is realized.
- In NormalForm terms: there exists a `NormalForm sig 1 1` whose quant_assignment maps every `NormalForm sig 0 2` with `.order 0 1 ... = true` to `false`.

So "has max" is encoded as: the depth-2 k-type says `true` for some specific depth-1 1-type that has the "no element above" property.

### Step 2: M|[t,b] has a max -> Z1 must have the "has max" k-type property

Since M|[t,b] ~k Z1.toOrdered at k >= 2, they agree on all depth-2 sentences. "Has max" is a depth-2 sentence (existential over depth-1 types). So if M|[t,b] satisfies "has max", then Z1.toOrdered satisfies "has max".

### Step 3: Z1 has max -> Z1 is bounded above

If Z1.toOrdered has a maximum element, then Z1.intervalCarrier has a greatest element. The greatest element z satisfies:
- `Z1.lo.elim True (. <= z)` (in the interval)
- `Z1.hi.elim True (z <= .)` (in the interval)
- For all z' in the interval, z' <= z

If Z1.hi = none (unbounded above), then the interval is {z : Z // Z1.lo.elim True (. <= z)} which includes ALL integers >= lo (or all integers if lo = none too). This set has no maximum. Contradiction.

Therefore Z1.hi = some _.

### Step 4: Similarly Z2 is bounded below

M|[succ b, u] has a minimum (succ b). By same argument, Z2.lo = some _.

### Step 5: With both bounded on touching side, show ordered sum is finite

- Z1 bounded above (hi = some h1) implies Z1.intervalCarrier is finite (bounded by lo..h1)
- Z2 bounded below (lo = some l2) implies... wait, Z2 could still be unbounded above! We need Z2 to be finite.

Actually we need Z2 bounded ABOVE too. M|[succ b, u] has a max (u). So Z2 must ALSO be bounded above. Similarly M|[t,b] has a min (t), so Z1 must also be bounded below.

So both Z1 and Z2 are doubly bounded -> both have finite carriers -> Sigma is finite -> `finite_structures_good` applies.

### Step 6: Compose k-equivalences

```lean
M|[t,u] ~k orderedSum Bool pieces    -- h_iso (proved)
        ~k orderedSum Bool witnesses  -- h_sum via doets_lemma_1_4 (proved)
```
And `orderedSum Bool witnesses` is good (step 5 gives the Z3).

Compose: `M|[t,u] ~k orderedSum witnesses ~k Z3.toOrdered`.

---

## 5. Lemma Dependency Graph

```
good_of_split_at_succ
  |
  +-- [k = 0]: already proved (AtomKind sig 0 is empty)
  |
  +-- [k = 1]: good_of_orderedSum_k1
  |     |
  |     +-- enumerate realized predicate-patterns
  |     +-- construct [0, m-1] Z-interval
  |     +-- prove 1-equiv via same realized 1-types
  |
  +-- [k >= 2]: bounded_witness_argument
        |
        +-- subinterval_has_max (easy: b is the max of M|[t,b])
        +-- subinterval_has_min (easy: t is the min of M|[t,b])
        +-- k_equiv_preserves_has_max (core difficulty)
        |     |
        |     +-- encode "has max" as NormalForm sig 2 0 sentence
        |     +-- use k_equiv at k >= 2 to transfer
        |
        +-- k_equiv_preserves_has_min (symmetric)
        +-- bounded_Z_interval_fintype (straightforward)
        +-- Sigma.instFintype (from Mathlib)
        +-- finite_structures_good (already proved)
```

---

## 6. Conclusion and Priority Recommendation

| Priority | Action | Rationale |
|----------|--------|-----------|
| **None (for completeness)** | Leave sorry as-is | Not on critical path; `chronicle_is_good` bypasses it |
| **Low (for mathematical completeness)** | Implement Strategy F+G | Fills the sorry correctly, ~250 lines |
| **Alternative** | Strategy D (document as non-critical) | Add comment noting dead-code status |

The sorry does NOT block the Reynolds pipeline activation (Task 155's goal). The pipeline's critical path is:

```
extract_chronicle_as_prior -> chronicleAsMonadicStructure -> chronicle_is_good -> Transfer
```

All of which are proved WITHOUT needing `good_of_split_at_succ`. The remaining blockers for pipeline activation are:
1. ZIntervalStructure -> TaskFrame bridge (Step 6 in Transfer.lean)
2. Uncomment the pipeline steps in `doets_countermodel_discrete`

Neither involves `good_of_split_at_succ`.
