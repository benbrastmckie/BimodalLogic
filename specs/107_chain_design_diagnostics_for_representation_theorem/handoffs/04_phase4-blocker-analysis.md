# Handoff: Task 107 -- Phase 4 Blocker Analysis

## Session
- **Session ID**: sess_1777424311_a956d8
- **Phases Completed**: 1, 2, 3 (prior sessions)
- **Phase 4**: BLOCKED (9 sorry sites analyzed, 0 closed)
- **Phase 5**: NOT STARTED (blocked by similar issues)
- **Build Status**: `lake build` passes (unchanged)
- **Sorry Count**: 11 (9 in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean)

## Analysis Summary

All 9 sorry sites in CounterexampleElimination.lean fall into three structural categories, each requiring architectural changes rather than proof tactics. The plan assumed Xu's Lemma 3.2.1 would be available (Phase 3 "B closure gives the needed Until/Since formulas"), but Xu 3.2.1 was archived to Boneyard as unprovable, leaving these sorries without their planned proof strategy.

## Category 1: C4/C4' Nested Case (Lines 425, 543)

### Goal
Show `gamma not in g(w, w_next)` where:
- `neg(untl gamma delta) in f(w)` (leftmost/rightmost with neg-Until/neg-Since)
- `untl(gamma, delta) in f(w_next)` (the Until formula, NOT the event delta)
- `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))`

### Why Blocked
The existing sorry-free case (w_next = y) uses `burgessR3_gamma_not_in_B` which requires `delta in f(w_next)`. In the nested case, w_next < y and only `untl(gamma, delta) in f(w_next)` is available (not delta directly).

**Proof attempt**: Suppose gamma in g. By backward burgessR3: `snce(gamma, neg(untl gamma delta)) in f(w_next)`. Then by A3a enrichment: `untl(gamma, delta AND snce(...)) in f(w_next)`. By forward burgessR3: `untl(gamma, untl(gamma, delta AND snce(...))) in f(w)`. Need this to contradict `neg(untl gamma delta) in f(w)`.

The reduction requires `untl(gamma, untl(gamma, X)) -> untl(gamma, X)`, which is exactly `untl_absorb_nested` -- **INVALID under open guard semantics** (Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean:91-101, junction point not covered).

**Seven alternative approaches exhausted**:
1. BX3 right-monotonicity: gives `untl(gamma, untl(gamma, delta))`, not `untl(gamma, delta)`
2. BX5 self-accumulation: enriches guard, doesn't help with event nesting
3. A3a enrichment: creates more complex formulas, doesn't collapse nesting
4. A3b (Since enrichment): similarly creates more complex formulas
5. Backward induction from y: loses the delta at non-endpoint pairs
6. Forward induction from x: need neg(untl gamma delta) to propagate, which may not hold
7. Using BurgessR3Maximal maximality directly: gamma in B is consistent, no contradiction from maximality

### Root Cause
Burgess 1982 proves C4 elimination under closed guard (reflexive) semantics where `untl_absorb_nested` is valid. Under open guard (strict) semantics, the junction point between two Until witnesses is not covered by either guard interval, making nesting absorption invalid.

### Possible Fixes (require plan revision)
1. **Restructure C4 elimination to avoid nested case**: Eliminate ALL C4/C4' counterexamples simultaneously rather than one at a time. With all C4 counterexamples processed, every pair (a, b) with neg(untl gamma delta) in f(a) will have delta in f(b) for some b (not just untl(gamma, delta)).
2. **Use different bridging lemma**: Prove gamma not in g by a different route that doesn't require `untl_absorb_nested`.
3. **Strengthen the C5 elimination to provide delta at intermediate points**: After C5 processing, delta is at the witness y. Use this to close C4 at (y_prev, y).
4. **Weaken c2' requirement during C4 elimination**: Only maintain c2' for pairs NOT involved in the C4 argument, then rebuild g-values in a separate pass.

## Category 2: c2' for New Adjacent Pairs (Lines 792, 830, 870, 908, 944, 976)

### Goal
Show `BurgessR3Maximal(f'(a), g'(a, b), f'(b))` for new adjacent pairs (a, b) created by point insertion, where `g' a b = chi.g a b` (g unchanged).

### Why Blocked
All elimination functions (eliminate_C5/C5'/C4/C4'/g_prop/h_prop_counterexample) return chronicles with `g' = chi.g` (the g-function is UNCHANGED). New adjacent pairs involve the inserted point z, so `g'(a, z) = chi.g(a, z)` which is an arbitrary value for the out-of-domain pair (a, z).

**BurgessR3Maximal requires**: the g-value is a maximal DCS satisfying burgessR3 with the adjacent f-values. An arbitrary function value has no reason to satisfy this.

### Fix Required
Each elimination function must be restructured to:
1. Construct new g-values for new adjacent pairs using `burgessR3Maximal_exists_from_seed`
2. Find appropriate seeds (formulas with burgessR and burgessRSince) from the construction context
3. Set g' to use new values at new pairs and chi.g at old pairs
4. Update the return type to expose g-agreement only at OLD domain pairs

**Seed construction** is the hardest part. For C5 (point y > all domain, f(y) = C from Lemma 2.4):
- Need eta in f(x_max) with burgessR(f(x_max), eta, C) and burgessRSince(C, eta, f(x_max))
- Lemma 2.4 gives g_content(f(x_max)) subset C, which means: for all phi with G(phi) in f(x_max), phi in C
- This gives burgessR(f(x_max), phi, C) for individual phi with G(phi) in f(x_max)
- But burgessR3Maximal_exists_from_seed needs a SINGLE seed element with BOTH forward and backward

### Estimated Effort
Major restructuring: ~15-20 hours per elimination function (6 functions), ~100 hours total. This is well beyond the original Phase 4 estimate of 12 hours.

## Category 3: Density Self-Pair (Line 1092)

### Goal
Show `BurgessR3Maximal(f(pc.x), chi.g(pc.x, pc.y), f(pc.x))` (self-pair: same MCS on both sides) when we only have `BurgessR3Maximal(f(pc.x), chi.g(pc.x, pc.y), f(pc.y))` (different right endpoint).

### Why Blocked
The density case sets f(z) = f(pc.x) (copy left endpoint). The pair (pc.x, z) then has A = C = f(pc.x). But chi.g(pc.x, pc.y) was maximal for (f(pc.x), -, f(pc.y)), not (f(pc.x), -, f(pc.x)). BurgessR3 is endpoint-dependent: burgessR3(A, B, C) != burgessR3(A, B, A) when A != C.

### Fix
Same as Category 2: construct fresh g-values using `burgessR3Maximal_exists_from_seed`.

## Phase 5 Assessment

Lines 615, 619 (ChronicleToCountermodel.lean) require the full C5/C5' with GUARD at intermediate points (`forall r between t and s, phi in mcs(r)`). This requires:
- The limit g-function with C3 (three-way decomposition)
- g(x,y) subset f(z) for x < z < y (derived from C3)
- C5 elimination providing guard information (currently discarded)

This is independent of Phase 4 but equally deep. The guard information IS checked in the omega-chain construction (via eliminate_potential_counterexample) but the EliminationResult type only exposes the endpoint witness, not the guard.

## Recommended Path Forward

1. Run `/revise 107` to create plan v41 addressing the structural issues:
   - Restructure all 6 elimination functions to construct proper g-values
   - Use `burgessR3Maximal_exists_from_seed` for new adjacent pairs
   - Add seed-finding lemmas for each elimination type
   - Address the C4 nested case (either avoid it or find alternative proof)

2. The C4 nested case (Category 1) is the deepest blocker. Options:
   a. Process C4/C5 counterexamples in dependency order (C5 first, then C4 using C5 witnesses)
   b. Prove a new lemma: gamma not in g via a different route than burgessR3_gamma_not_in_B
   c. Add an axiom or prove that the nested case doesn't arise at the limit

3. The c2' restructuring (Category 2) is substantial but mechanically straightforward once the seed lemmas exist.

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- 9 sorry sites
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- 2 sorry sites
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- sorry-free, contains burgessR3Maximal_exists_from_seed
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- Lemma 2.4, seed construction helpers
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean` -- documents invalid lemmas under open guard
