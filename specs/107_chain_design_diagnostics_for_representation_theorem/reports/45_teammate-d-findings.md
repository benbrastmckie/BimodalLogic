# Teammate D (Horizons) Findings: Strategic Assessment

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-29
**Focus**: Long-term strategic direction, sorry inventory reconciliation, task sequencing

## Key Findings

### 1. Actual Sorry Count: 10 (Not 13, Not 4)

The ROADMAP claims 12-13 chronicle sorries. The actual count from `grep sorry` on executable code lines (excluding comments) is **10 sorry sites across 3 files**:

| File | Count | Locations |
|------|-------|-----------|
| `PointInsertion.lean` | 1 | line 306: `splitting_seed_consistent` |
| `CounterexampleElimination.lean` | 7 | lines 830, 868, 908, 946, 982, 1014 (c2' fields), line 1130 (self-pair case) |
| `ChronicleToCountermodel.lean` | 2 | lines 615, 619: `cantor_bfmcs_restricted_fuc` (forward Until/Since) |

`ChronicleConstruction.lean` and `RRelation.lean` are **sorry-free**. The ROADMAP's claim of "2 sorries in ChronicleConstruction.lean (forward_G/backward_H)" is outdated -- these were proved after the C4 fix (report 25/26).

### 2. Dependency Structure of the 10 Sorries

The sorries form a clear dependency chain:

```
PointInsertion.lean (1 sorry: splitting_seed_consistent)
  |
  v  (used by eliminate_C5_counterexample and eliminate_C4 paths)
CounterexampleElimination.lean (7 sorries: c2' invariant maintenance)
  |
  v  (C5 witnesses feed limit_satisfies_c5_full)
ChronicleToCountermodel.lean (2 sorries: forward Until/Since coherence)
  |
  v  (restricted_fuc feeds dd_countermodel_chronicle)
dd_countermodel_chronicle  -->  bx_completeness
```

**Critically**: The 2 FUC/FSC sorries at the bottom are NOT directly about splitting_seed_consistent. They require `limit_satisfies_c5_full` (C5 with guard), which depends on the c2' sorries being closed (to get correct g-function values after point insertion), which in turn depends on splitting_seed_consistent (to prove that Lemma 2.6 produces valid chronicles with correct c2' invariants).

However, the 7 c2' sorries have a different character than splitting_seed_consistent. They concern the **g-function maintenance** after point insertion -- showing that when a new point z is inserted between x and y, the inherited g(x,z) and g(z,y) values (set to g(x,y)) satisfy the c2' invariant (DCS + burgessR3). The self-pair sorry at line 1130 is a distinct problem: it needs `burgessR3(f(x), g(x,y), f(x))` when the existing proof gives `burgessR3(f(x), g(x,y), f(y))`.

### 3. The Two Approaches Address Different Sorry Tiers

**A4a (separation_until)** addresses: Only `splitting_seed_consistent` (1 sorry in PointInsertion.lean). It does NOT address the 7 c2' sorries or the 2 FUC sorries.

**left_mono_until_G (Xu path)** addresses: Also only `splitting_seed_consistent` (via Xu Lemma 2.3/2.4 instead of Burgess Lemma 2.6). Same downstream scope.

Both approaches are equivalent in their sorry-site impact. The choice between them is about proof difficulty, axiom cleanliness, and long-term maintenance -- not about closing more sorries.

### 4. The 7 c2' Sorries Are a Separate Engineering Problem

The c2' sorries in CounterexampleElimination.lean are about maintaining the chronicle invariant during point insertion. They have three sub-categories:

- **Lines 830, 868** (C5 forward/backward): Need g-construction for the new chronicle after C5 elimination. Plan says "Phase 9: n=0 via burgessR3Maximal_from_g_content_sub, n>0 via Lemma 2.7". These depend on Lemma 2.6 splitting (hence on splitting_seed_consistent) but are otherwise independent engineering.

- **Lines 908, 946, 982, 1014** (C4 forward/backward): Need g-construction via "burgessR3_absorption for new adjacent pairs". These are about splitting the existing g(x,y) into g(x,z) and g(z,y) when z is inserted. This is the absorption/refinement of the R3-maximal set, a separate proof from splitting_seed_consistent.

- **Line 1130** (self-pair case): Needs `burgessR3(f(x), g(x,y), f(z))` where `f(z) = f(x)` (the duplicate assignment). Currently the proof has `burgessR3(f(x), g(x,y), f(y))` from the existing c2'. This is a straightforward but non-trivial modification.

### 5. The 2 FUC Sorries Have a Clean Proof Path Once c2' Is Closed

The `cantor_bfmcs_restricted_fuc` sorries at lines 615/619 require `limit_satisfies_c5_full` -- C5 with full guard information. The docstring at line 597 identifies two paths:

(a) Build the real interval function g with C3 three-way property and transfer guard membership through it.
(b) Strengthen `EliminationResult.c5_forward_witness` to include guard information (currently "checked but discarded").

Path (b) is clearly simpler: the guard IS checked in `eliminate_potential_counterexample` but the result type drops it. Widening the result type to carry guard info would close these 2 sorries without any new mathematical content.

## Strategic Assessment

### Which Axiom System Is Cleaner?

**left_mono_until_G is strictly cleaner** for the following reasons:

1. **Axiom count**: Adding left_mono_until_G makes BX2 (left_mono_until) derivable, so the net axiom count does not increase (replace BX2 with left_mono_until_G, or keep BX2 as a derived theorem). Adding A4a increases the axiom count by 2 (separation_until + separation_since).

2. **Semantic transparency**: left_mono_until_G has a 3-step semantic proof (G-info covers the open guard). A4a has a 6-step semantic proof involving negated Until reasoning. Under open-guard semantics, left_mono_until_G directly captures the fundamental semantic fact: G-information is the natural tool for reasoning about strictly-future intervals.

3. **Axiom independence**: With left_mono_until_G, the axiom system has a cleaner independence structure. A4a is independent of all existing axioms (confirmed: 5 derivation attempts failed), meaning it adds genuinely new deductive power. left_mono_until_G subsumes BX2, so its addition replaces rather than supplements.

### Which Approach Better Aligns With Formal Verification Goals?

**The Xu path (left_mono_until_G)** better aligns with formal verification for several reasons:

1. **Proof simplicity**: The Xu Lemma 2.4 splitting avoids the bidirectional seed consistency problem entirely. The seed is B UNION {neg beta}, where B is already a DCS (so consistency is trivial: beta not in B implies the extension is consistent). The Burgess Lemma 2.6 proof requires proving consistency of `{neg beta} UNION g_content(A) UNION h_content(C)` -- a three-way union from three different MCSes whose interaction under irreflexive semantics has an identified open question (the h_content gap in the Phase 5b handoff).

2. **Proof trust**: A formalization that avoids hard-to-verify intermediate steps is more trustworthy. The `splitting_seed_consistent` sorry has been open for multiple research rounds. The Xu alternative sidesteps the hard step entirely, not by being clever, but by using a mathematically simpler argument.

3. **Maintenance burden**: Fewer axioms = fewer soundness proofs = fewer match arms = less maintenance when the proof system evolves.

### Which Approach Is More "Honest" Mathematically?

**Both approaches are mathematically honest**, but they follow different mathematicians:

- A4a follows **Burgess 1982** directly. This is the "original source" approach. The separation axiom is a natural temporal property and Burgess uses it in his completeness proof.

- left_mono_until_G follows **Xu 1988**. Xu's paper explicitly simplifies Burgess's axiomatization. Xu's contribution is recognized in the naming of the "Burgess-Xu" axiom system. Using Xu's simpler proof is not a workaround -- it is the acknowledged improvement to Burgess's original approach.

The project already uses the name "BX" (Burgess-Xu), so following Xu's approach for the splitting lemma is entirely consistent with the project's mathematical heritage.

## Recommended Long-Term Direction

### Task 107 and Task 115: Merge, Don't Sequence

**Recommendation**: Pivot task 107 directly to the Xu path. Do NOT implement task 115 separately.

Rationale:
1. Task 107 is [RESEARCHING] and blocked on `splitting_seed_consistent`. The Phase 5b handoff identifies an open question in the A4a approach. Rather than continuing to push on a path with an identified gap, pivot to the path without the gap.

2. Task 115 was created as a contingency ("if task 107 gets stuck on A4a"). Task 107 IS stuck on A4a. The contingency has triggered.

3. The infrastructure built in task 107 (BX13, burgessR3Maximal_from_g_content_sub, the entire chronicle construction, Cantor FMCS, etc.) is fully compatible with the Xu approach. Only the `splitting_seed_consistent` proof changes.

4. Implementing task 115 separately would mean: (a) add left_mono_until_G, (b) rewrite splitting, (c) remove A4a, then come back to task 107 and note it as superseded. This is unnecessary overhead. Just revise task 107's plan to use the Xu approach.

**Concrete action**: Run `/revise 107` to create plan v30 that replaces the A4a-based splitting_seed_consistent with the Xu Lemma 2.3/2.4 approach, then mark task 115 as [ABANDONED] with "subsumed by task 107 plan v30".

### The 10-Sorry Roadmap

After pivoting to Xu:

1. **Phase A** (1 sorry -> 0): Add left_mono_until_G, remove A4a, implement Xu Lemma 2.3/2.4 splitting. Closes `splitting_seed_consistent`. Estimated: 6-8 hours.

2. **Phase B** (7 sorries -> 0): Close CounterexampleElimination c2' invariants. These are engineering problems about g-function maintenance during point insertion. The self-pair case at line 1130 needs separate attention. Estimated: 8-12 hours.

3. **Phase C** (2 sorries -> 0): Widen `EliminationResult` to carry guard information through C5 elimination (path (b) from the docstring). Then `cantor_bfmcs_restricted_fuc` closes by transferring guard info through the Cantor isomorphism. Estimated: 4-6 hours.

4. **Phase D**: Verify `dd_countermodel_chronicle` is sorry-free. Update `Completeness.lean` to use the chronicle path instead of the RootScopedChain path. Run `#print axioms bx_completeness`. Estimated: 2-4 hours.

Total estimated: 20-30 hours of focused implementation work.

### What Happens After

Once `dd_countermodel_chronicle` is sorry-free:
- **Task 95** (axiom audit) becomes actionable
- The 5 critical-path sorries in `RootScopedChain.lean` become dead code (task 109 can deprioritize them)
- The 18 irreflexive-consequence sorries remain as cleanup (task 109), but they are not on the completeness critical path
- Publication path: soundness (sorry-free) + completeness (sorry-free via chronicle) + decidability (sorry-free via FMP)

## Creative Alternatives

### Alternative 1: Restructure c2' to Avoid 7 Separate Sorries

The 7 c2' sorries are all about maintaining `χ'.c2'` (DCS + burgessR3 for adjacent pairs) after point insertion. Currently, each case branch in `eliminate_potential_counterexample` provides its own c2' proof (sorry). A refactoring opportunity: extract a general lemma `c2'_preserved_by_insertion` that proves c2' is preserved when a point z is inserted between adjacent x and y, given that the g-function inherits from g(x,y). This would replace 7 sorry sites with 1 general lemma.

### Alternative 2: Weaken c2' to c2'_weak

The c2' invariant currently requires both DCS(g(x,y)) AND burgessR3(f(x), g(x,y), f(y)) for all adjacent pairs. The burgessR3 condition is what makes point insertion hard (the R3-maximal set is fragile under endpoint changes). An alternative: replace c2' with a weaker invariant `c2'_weak` that only requires g_content(f(x)) subset f(y) (the forward direction), with burgessR3 recovered at the limit via Zorn's lemma. This would simplify the inductive step at the cost of a more complex limit argument.

### Alternative 3: BurgessR3Maximal Reformulation

The `BurgessR3Maximal` definition uses a DCS (deductively closed set) as the "B" component. Under open-guard semantics, the DCS might be replaceable with a simpler structure. Specifically: since the guard interval (t,s) excludes the current time t, the "closure under modus ponens" property of DCS may be unnecessary for the B set. If B only needs to be a consistent set (not deductively closed), the Zorn step `rMaximal_extension_exists` could be simplified.

### Alternative 4: Direct C3 Construction

Instead of maintaining c2' through each elimination step, construct the g-function ONLY at the limit (after all counterexamples are eliminated). The omega-chain limit gives a countable dense linear order with f satisfying C0, C4, C4', C5, C5'. Define g(x,y) at the limit as the DCS generated by {formula in f(z) : x < z < y, z in limit_dom}. Proving C3 (g(x,z) subset f(y) for x < y < z) directly from C4's contrapositive might be cleaner than maintaining g through every insertion step.

## Confidence Level

**High** on the strategic assessment (merge 107+115, pivot to Xu path).

**Medium** on the 20-30 hour estimate (the c2' sorries may have hidden complexity, especially the self-pair case at line 1130).

**Low** on the creative alternatives (all four need investigation before committing; they are ideas, not validated approaches).
