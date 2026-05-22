# Phase 7 Handoff: IntegerModel.lean Helper Sorries

## Summary

Both sorry sites in IntegerModel.lean present significant challenges. No sorry sites closed this round.

## Sorry 1: cofinal_decomposition_k_equiv (line 1135)

### BLOCKER: Theorem as stated appears INCORRECT for k ≥ 2

**Root cause**: The ordered sum uses closed subintervals `[a(i), a(i+1)]` which share boundary points. The Sigma-type ordered sum creates DISJOINT copies, giving the ordered sum MORE elements than M (each boundary point `a(i+1)` appears as both `⟨i, a(i+1)⟩` and `⟨i+1, a(i+1)⟩`).

**Counterexample sketch (k=2)**: In the ordered sum, `y = ⟨i+1, a(i+1)⟩` and `z = ⟨i, a(i+1)⟩` are distinct elements with `z < y` (lex) and identical predicates. The depth-0 NF with 2 vars recording "same predicates, z < y" is realizable in the ordered sum but may NOT be realizable in M (since both project to the same element `a(i+1)`, and M may have no element with the same predicates strictly below `a(i+1)`).

**Reynolds's original proof** (Reynolds 1994, p.888) uses `N | a_i, a_{i+1} - 1` (discrete closed intervals that are DISJOINT, since piece i ends at `pred(a(i+1))` and piece i+1 starts at `a(i+1)`). The codebase uses general closed intervals that OVERLAP.

### Proposed fix options

1. **Half-open intervals**: Define `M.leftClosedRightOpen sig (a i) (a (i+1))` with carrier `{x | a(i) ≤ x ∧ x < a(i+1)}`. Then ordered sum is isomorphic to M. Requires new infrastructure + showing each half-open piece is k-equiv to the closed piece (for downstream goodness transfer). ~200 lines.

2. **Discrete predecessor**: Add `SuccOrder`/`PredOrder` hypotheses and use `[a(i), pred(a(i+1))]` matching Reynolds. Downstream `very_good_implies_good` already operates on discrete structures. ~100 lines but changes the theorem signature.

3. **Boundary identification**: Prove a "duplicate insertion preserves k-equiv" lemma showing that adding adjacent predicate-identical elements doesn't change k-type. Then: M ≃o canonical_subtype ≡_k orderedSum. ~250 lines.

4. **Direct k_equiv via modified back-and-forth**: Build the nf transfer proof with a canonicalization strategy that avoids boundary duplicates in the backward direction. ~300 lines.

**Recommendation**: Option 2 (discrete predecessor) is simplest and matches Reynolds. The downstream uses all involve discrete orders.

## Sorry 2: ordered_sum_of_good_bounded_is_good (line 1194)

### Status: COMPLEX but PROVABLE

**Goal**: `good sig (k'' + 2) (orderedSum sig ℤ wit_structs)` where each `wit_structs i` is a `ZIntervalStructure` that is (k''+2)-equivalent to `ms i` (which has max and min).

**Approach** (shift-and-glue):

1. **Transfer boundedness**: Each `ms(i)` has max/min. Via `doets_lemma_1_1` at depth k''+2 ≥ 2, transfer "has max" and "has min" sentences to `witnesses(i)`. Pattern exists at lines 562-612 of the same file.

2. **Show Z_i bounded**: From "has max/min" in the Z-interval structure, extract `Z_i.lo = some _` and `Z_i.hi = some _`. Pattern exists at lines 602-640.

3. **Each Z_i is Fintype**: Bounded Z-interval has finitely many integer elements.

4. **Construct OrderIso to ℤ**: The ordered sum `Σ i : ℤ, Z_i.intervalCarrier` with bounded Z_i needs `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`, `Nonempty` instances to apply `orderIsoIntOfLinearSuccPredArch`.

5. **Use k_equiv_of_iso**: The order iso to ℤ + predicate transfer gives goodness.

**Main difficulty**: Step 4 requires building `SuccOrder` and `PredOrder` instances on the Sigma lex type of bounded integer intervals. This is the core "shift-and-glue" construction: the successor of `⟨i, max_i⟩` is `⟨i+1, min_{i+1}⟩`. Building this as a Lean `SuccOrder` instance with correct properties is ~150-200 lines of technical work.

**Alternative for step 4**: Instead of `orderIsoIntOfLinearSuccPredArch`, directly construct the order iso by cumulative offset: map `⟨i, z⟩` to `z + offset(i)` where `offset(i) = Σ_{j<i} size(Z_j)`. This requires showing the offset is well-defined (each Z_j is finite, so the partial sums are finite) and the map is an OrderIso. ~100-150 lines.

**Estimate**: 300-500 lines total for the complete proof.

## Recommendation

1. Research option 2 for `cofinal_decomposition_k_equiv` (add SuccOrder/PredOrder hypotheses)
2. Implement `ordered_sum_of_good_bounded_is_good` using the cumulative-offset OrderIso approach
