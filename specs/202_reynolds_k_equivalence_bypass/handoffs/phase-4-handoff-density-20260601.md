# Phase 4 Handoff: Task 202 (Density Argument)

## Session
sess_1780336977_e5mt

## Current State
Phase 4 BLOCKED on "ordered spread" (Reynolds Lemma 11 density).

### The Two Sorry Sites (lines ~1530, ~1556 in GoodStructuresModelSurgery.lean)

Both are in `truth_pres` (structural induction on Formula), in the Until/Since forward direction (M -> N) when the witness `s` is NOT in class(a).

The goal: find φ at some class(a) point ABOVE t (for Until) or BELOW t (for Since).

`class_spread` gives φ at some class(a) point but possibly on the wrong side of t.

### Critical Analysis: Why This Is Hard

**Spread_below is invariant; spread_above is NOT.** 

The formula `spread_below(x) = ∃ y ~M x, y < x, φ(y)` ("φ held at a past class member") IS contemp_equiv-invariant: if x ~M x', then any y < x with y ~M x also satisfies y < x' (when x < x') because y < x < x'. Wait, actually: if x < x' and y < x, we get y < x' (since y < x < x'). If x > x' and y < x, y might be > x' (between x' and x). So spread_below(x) → spread_below(x') when x' > x but NOT when x' < x.

Hmm, re-checking: spread_below(x) = ∃ y ~M x, y < x, φ(y). If x ~M x':
- If x < x': spread_below(x) has y < x. Since y < x < x': y < x'. And y ~M x ~M x'. So spread_below(x') holds. ✓
- If x > x': spread_below(x') has y < x'. Since x' < x and y < x': y < x. And y ~M x' ~M x. So spread_below(x) holds. ✓ (the OTHER direction)

So: spread_below(x) ↔ spread_below(x') whenever x ~M x'. It IS invariant!

And `spread_above(x) = ∃ y ~M x, y > x, φ(y)`:
- If x < x': spread_above(x) has y > x with y ~M x, φ(y). Is y > x'? Maybe not (x < y could be ≤ x'). NOT guaranteed. ✗

So spread_above is NOT invariant.

**Consequence**: invariant_formula_constant applies to spread_below (giving it constant = True), but NOT to spread_above. So we can show φ is "cofinal from below" in every class (spread_below = True everywhere), but we CANNOT show φ is "cofinal from above" directly.

### The Correct Approach: Reynolds Lemma 11 Density

Reynolds 1994 pp.127-128 (Lemma 11) proves density via a TRANSITION argument using Prior-U/S:

**Lemma 11 (First Part)**: If B holds "for a while at the start" of a ~-class in a bad interval, then B holds throughout the bad interval.

**Proof**: Suppose not. ¬B holds somewhere. By class_spread, ¬B in our class. Construct C = "∃ ¬B before me in my class" (temporal formula via expressive completeness). C is false at start, true at end. C transitions True→False at the gap. Prior-U contradiction.

**Lemma 11 (Second Part)**: If A holds anywhere in the bad interval, then A holds "arbitrarily close to each end of each class."

**Proof**: Apply first part to ¬A. If ¬A holds "for a while at the end" of a class, then ¬A everywhere, contradicting A somewhere.

### Why the Transition Argument Works

The key: C = "∃ y ~M x, y < x, ¬B(y)" is a temporal formula (via US_expressively_complete_over_prior). By Lemma 9 part 2 (elementary equivalence of classes), B holds "for a while at the start" of EVERY class (not just the one we chose). So C is false near the start and true near the end of EVERY class. At each gap: C transitions True (near end of class) → False (near start of next class). Prior-U fails because the set {s > t | ¬C(s)} has no minimum (next class has no first element near the gap).

### Elementary Equivalence of Classes (Lemma 9 Part 2)

This is the piece that makes the argument work. For any monadic sentence τ about a class: relativize quantifiers to "y ~M x" to get τ*(x). This is a 1-ary monadic formula. By standard model theory, τ* IS contemp_equiv-invariant (if x ~M x', the class {y | y ~M x} = {y | y ~M x'}). By invariant_formula_constant, τ* is constant. So τ has the same truth value on all classes.

In particular: "B holds for a while at the start" (= ∃ threshold, B true below threshold in class) is a monadic sentence about the class. Its relativization is invariant and constant. If true on one class, true on all.

### Implementation Plan

1. **Prove elementary equivalence of classes** (~20 lines): For any MonadicSentence sig 0 about a class (relativized), the relativized formula is invariant. By invariant_formula_constant, it's constant. Therefore all classes satisfy the same sentences.

2. **Prove Lemma 11 first part (end version)** (~30 lines): If B holds "for a while at the end" (i.e., at all succ^n(t₀) for n ≥ 1) of a class, then B holds throughout M. Use the C-formula argument with Prior-SZ.

3. **Apply to the sorry cases** (~10 lines each): In the Until sorry: use exfalso. Assume ¬φ at all class(a) above t. Then ¬φ holds "for a while at the end" of class(a). By Lemma 11: ¬φ throughout. But φ(s') gives contradiction. Hence φ at some class(a) above t. Use that as witness.

### Technical Challenges

1. **Constructing the C formula**: Need `spread_below_neg_B = .ex (.and (.and (contemp_eq_body sig k) (.lt var0 var1)) ((table sig atomMap B.neg).lift 1))` as a MonadicFormula sig 1. Then convert to temporal via US_expressively_complete_over_prior.

2. **Proving C is false for a while at start of each class**: Requires elementary equivalence + "B for a while at start" transfers across classes.

3. **The Prior-SZ contradiction**: C is true near the gap (right end of class), false just beyond (near start of next class). Prior-SZ at a point in the next class gives a "last C" with C.neg between. But C is true at infinitely many class(a) points approaching the gap (no maximum). Any "last C" r₀ in class(a) has succ(r₀) also in class(a) with C(succ(r₀)) = True. Contradicts C.neg between r₀ and c₂.

### Estimated Effort
60-100 lines for the full density argument + application to sorry sites.

## Files Modified
None yet in this cycle (analysis only).

## Next Action
Implement Reynolds Lemma 11 density argument inline in gap_prior_UZ_contradiction to close the two sorry sites.
