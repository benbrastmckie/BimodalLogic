# Handoff: IsSuccArchimedean Proof Analysis

## Current State

The sorry remains at `limitDomSubtype_isSuccArchimedean` in
`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (line 1068).
The file builds correctly with `lake build`.

## What Was Attempted

Extensive analysis of multiple proof strategies for proving `IsSuccArchimedean`
for `LimitDomSubtype` in the discrete case. The goal is:

```
a b : LimitDomSubtype A h_mcs
hab : a <= b
-- Goal: exists n, Order.succ^[n] a = b
```

where `SuccOrder` is defined via `limitDomSubtype_succOrder` using C5 witnesses.

### Available Infrastructure

All of the following are proven sorry-free:
- `limitDomSubtype_succ_le_iff`: `succ(a) <= b <-> a < b`
- `limitDomSubtype_le_pred_iff`: `a <= pred(b) <-> a < b`
- `limitDomSubtype_succ_pred`: `succ(pred(b)) = b`
- `limitDomSubtype_pred_lt`: `pred(b) < b`
- `limitDomSubtype_le_pred_of_lt`: `a < b -> a <= pred(b)`
- `omega_chain_dom_mono_le`: `dom_m subset dom_n` for `m <= n`
- `omega_chain_dom_new_unique`: at most one new point per stage
- `limit_dom_has_succ`: immediate successor exists (no limit_dom between)
- `limit_dom_has_pred`: immediate predecessor exists (no limit_dom between)

### Strategies Analyzed and Why They Fail

#### 1. Fixed dom_N count induction
Induct on `|dom_N cap (a.val, b.val]|` with pred(b) descent.
**Problem**: When `pred(b) not in dom_N`, need to use a larger `M > N`.
But `|dom_M cap (a.val, pred(b).val]|` can exceed `|dom_N cap (a.val, b.val]|`
because `dom_M` has more elements than `dom_N`.

#### 2. Parameterized M induction
Induct on count with M as a universal parameter in the IH.
**Problem**: Same issue -- applying IH with a larger M' increases the count.

#### 3. Minimum-count mu(a,b) = min_M |dom_M cap (a.val, b.val]|
The minimum is achieved at `M = max(birth(a), birth(b))`.
**Problem**: `mu(a, pred(b))` is NOT always < `mu(a, b)`. When
`birth(pred(b)) > birth(b)`, the optimal stage for `(a, pred(b))` is larger,
and the count can equal `mu(a, b)`.

#### 4. Birth-stage monotonicity
The original plan assumed `birth(succ(z)) > birth(z)`.
**Reality**: Birth can go EITHER direction:
- If `succ(z) in dom_{birth(z)}`: `birth(succ(z)) < birth(z)` (succ is older)
- If `succ(z) not in dom_{birth(z)}`: `birth(succ(z)) > birth(z)` (succ is newer)

So `birth(succ(z)) > birth(z)` is NOT universally true. The plan's Phase 2
(`succ_birth_gt`) is **incorrect as stated**.

#### 5. Gap lemma with dom_M-based WF measure
For consecutive dom_N elements p < q, try `|dom_M cap (current, q]|` as measure.
**Problem**: dom_M changes at each step (different stages for different succ
computations), so the count is not comparable across steps.

#### 6. Contradiction via pigeonhole on dom_N
Map `n -> floor(succ^[n] a)` into finite `dom_N cap [a.val, b.val]`.
Gets the succ chain into a single gap, but can't close the gap.

#### 7. Contradiction via real analysis
If succ chain is infinite, both `succ^[n] a` and `pred^[m] b` converge.
The limits L+, L- satisfy L+ <= L-. If L+ in limit_dom, contradiction
with pred property. But L+ might not be rational or in limit_dom.

#### 8. WellFoundedGT approach
`WellFoundedGT.toIsSuccArchimedean` gives the result if `>` is well-founded.
But LimitDomSubtype ~ Z, which is NOT WellFoundedGT.

#### 9. LocallyFiniteOrder approach
`LinearLocallyFiniteOrder` gives IsSuccArchimedean.
But proving `LocallyFiniteOrder` requires showing `Set.Icc a b` is finite,
which is equivalent to the original problem.

### Key Insight: C5 Resolution in Discrete Case

The C5 counterexample for `U(top, bot)` at point `x` is RESOLVED at any stage
where `x in dom_n` and `x` is not the maximum of `dom_n`. In the gap between
consecutive dom_N elements `p < q`, since `q in dom_n` and every gap element
`z < q`, the C5 for `z` is always resolved. Therefore:

- `succ(z)` is the `dom_{m_z}`-successor of `z` (where `m_z` is the C5 stage)
- `succ(z) in dom_{m_z}` (from the resolved case)
- No new point is added (dom_{m_z+1} = dom_{m_z})

This means the succ chain stays within existing dom elements. But the dom
elements at different stages can be different sets, preventing a uniform
finite bound.

### Recommended Approach for Next Attempt

**Approach A: Prove finiteness of limit_dom cap [a.val, b.val] directly.**

Key argument: In the discrete case, every limit_dom point has an immediate
predecessor (pred). If limit_dom cap [a.val, b.val] were infinite, it would
contain an infinite strictly increasing sequence bounded above. The infimum
L of the complementary decreasing sequence satisfies: all nearby limit_dom
points below L must satisfy `succ(z) <= L` (otherwise a limit_dom point
between z and succ(z) contradicts the successor property). But this means
succ(z) = L for points z approaching L, which either puts L in limit_dom
(contradiction with pred) or gives an accumulation of succ values at a
non-limit_dom point.

This approach requires formalizing the Bolzano-Weierstrass / monotone
convergence theorem for sequences in [a.val, b.val] subset Q subset R.
Mathlib has this infrastructure via `Real.tendsto_of_bddAbove_monotone`
or `Monotone.tendsto_atTop_atTop`.

**Approach B: Direct well-founded recursion on a custom pair.**

Define the measure as the pair `(|dom_M cap [a.val, b.val]|, M)` where
`M = max(birth(a), birth(b))`. Use well-founded recursion on the
lexicographic product Nat x Nat^op (first component decreasing,
second component decreasing when first is equal).

The key lemma needed: for consecutive dom_M elements p < q in the gap,
`succ(p)` either equals q (done) or has `birth(succ(p)) < birth(p)` when
`succ(p) in dom_{birth(p)}`, which makes the M component decrease for the
pair (a, succ(p)). When the M component decreases, the first component
might increase, so this needs the lex order with M as PRIMARY:
`(M, count)` with M decreasing first.

But this doesn't directly work because the M component can also INCREASE
(when `succ(z) not in dom_{birth(z)}`).

**Approach C: Use omega_chain structure to bound the gap.**

Prove that between consecutive dom_N elements p < q, the number of
limit_dom points is bounded by some function of N and the counterexample
enumeration. This requires tracking which counterexample_enum indices
correspond to points in (p, q) and showing they form a finite set.

The key property: each limit_dom point in (p, q) was added by resolving
a SPECIFIC counterexample_enum entry. Different entries correspond to
different points. The entries are indexed by natural numbers, but only
finitely many have their start point in (p, q) and produce a witness
in (p, q). Proving this finiteness requires analyzing the enumeration
structure.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`:
  Cleaned up comments in `limitDomSubtype_isSuccArchimedean`. Sorry remains.

## Dependencies

- The sorry blocks `discrete_iso` (line 1079) and downstream definitions.
- `dd_countermodel_chronicle_nondense_sorry` (line 825) has its own independent sorry.
