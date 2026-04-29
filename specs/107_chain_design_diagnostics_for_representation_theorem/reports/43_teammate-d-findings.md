# Teammate D Findings: Strategic Assessment and Path Forward

**Task 107**: Burgess chronicle construction -- g_content ordering blocker
**Date**: 2026-04-28
**Focus**: Full dependency chain mapping, divergence analysis, unified fix architecture

---

## 1. Key Findings

### 1.1 Sorry Site Inventory (Actual Count)

The current sorry count is **9 total** across 2 files, not the estimated ~10:

**CounterexampleElimination.lean** (7 sorries):
- Lines 830, 868, 908, 946, 982, 1014: `c2'` field in `EliminationResult` -- all identical pattern: after inserting a new point, the c2' invariant (BurgessR3Maximal for new adjacent pairs) is not proved
- Line 1130: density case, `(pc.x, z)` adjacent pair where `f(z) = f(pc.x)` -- needs `burgessR3(f(pc.x), g(pc.x, pc.y), f(pc.x))` (self-pair case)

**ChronicleToCountermodel.lean** (2 sorries):
- Lines 615, 619: `cantor_bfmcs_restricted_fuc` -- forward Until/Since coherence (guard at intermediate points)

### 1.2 Dependency Chain: Sorry Sites to Sorry-Free Completeness

```
dd_countermodel_chronicle (ChronicleToCountermodel.lean)
  |-- cantor_bfmcs_restricted_tc     [SORRY-FREE]
  |-- cantor_bfmcs_restricted_buc    [SORRY-FREE]
  |-- cantor_bfmcs_restricted_fuc    [2 SORRIES]
      |-- needs: limit_satisfies_c5_full (C5 with guard)
          |-- needs: guard phi at intermediate points between x and witness y
          |-- current: limit_satisfies_c5_weak gives endpoint only
          |-- required: limit_g(x,y) subset limit_f(z) for x < z < y
          |-- available: limit_c3_interval_subset_point [SORRY-FREE]
          |-- GAP: need Until-witness y with xi in limit_g(x,y)
              |-- omega_chain carries c2' invariant
              |-- c2' requires BurgessR3Maximal at new adjacent pairs
              |-- ALL 7 CE sorry sites feed into this
```

**Critical insight**: The 7 `c2'` sorries in CounterexampleElimination.lean are NOT directly blocking `cantor_bfmcs_restricted_fuc`. The `c2'` invariant is only needed for the finite-stage chronicle, which produces the limit. The limit itself has no adjacent pairs (it is dense). The actual blocker for `restricted_fuc` is that `limit_satisfies_c5_weak` only produces an endpoint witness y with `eta in limit_f(y)`, but does NOT show that `xi in limit_g(x, y)` -- i.e., the guard formula holds at all intermediate points.

### 1.3 Burgess 1982 vs Codebase: Full Divergence Analysis

**Burgess's construction** (Section 2):

1. **Pairs (f, g) in F**: f maps finite dom subset Q to MCS; g maps ordered pairs in dom to DCS. Conditions C0-C3 define chronicle membership. C2 requires `r(f(x), g(x,y), f(y))` for all x < y. C2' requires `R(f(x), g(x,y), f(y))` (R = maximal r) for ADJACENT pairs only. C3 is the composition identity: `g(x,z) = g(x,y) inter f(y) inter g(y,z)`.

2. **Lemma 2.4**: Given `U(gamma, beta) in A`, produces B, C with `beta in B`, `gamma in C`, `R(A, B, C)`. This produces BOTH the endpoint MCS C AND the interval DCS B simultaneously.

3. **Lemma 2.6**: Given `R(A, B, C)` with `delta not in B`, splits into B', D, B'' with `neg delta in D`, `R(A, B', D)`, `R(D, B'', C)`, `B = B' inter D inter B''`. Again, produces ALL THREE components together.

4. **Lemma 2.9** (C4 elimination): Inserts z between x and y. Case n=0 uses Lemma 2.6 directly. Case n=m+1 reduces to n=0 or n=m.

5. **Lemma 2.10** (C5 elimination): Inserts y after x. Case n=0 uses Lemma 2.4 directly. Case n=m+1 either propagates forward or inserts between x and x' using 2.7/2.8.

**Codebase divergences**:

| Aspect | Burgess 1982 | Codebase | Impact |
|--------|-------------|----------|--------|
| **r-relation** | Uses r(A, beta, C) and R(A, B, C) | Uses `burgessR3` and `BurgessR3Maximal` | Functionally equivalent |
| **Lemma 2.4** | Produces (B, C) together with R(A,B,C) | Produces C only (endpoint MCS) | **Gap**: no interval DCS B is produced |
| **Lemma 2.6** | Produces (B', D, B'') with R(A,B',D) and R(D,B'',C) | Produces D only (negation MCS) | **Gap**: no interval splitting |
| **C3 composition** | Maintained at each step by construction | `limit_g` defined by intersection at limit | Correct at limit, but NOT at finite stages |
| **C2' maintenance** | Each insertion produces new g-values | `c2'` sorry'd at each insertion | **Root blocker** for finite-stage invariant |
| **C5 full (with guard)** | Guard follows from g(x,y) subset f(z) via C3 | Only endpoint produced (weak C5) | **Root blocker** for restricted_fuc |

### 1.4 The Single Architectural Root Cause

Every sorry site traces to the same root cause: **the codebase's point insertion functions (Lemma 2.4, 2.6) produce only the endpoint MCS, not the interval DCS**. Burgess's construction fundamentally produces (f, g) pairs together -- the MCS AND the interval DCS are co-constructed from the same seed. The codebase separates them, producing the MCS first and then trying to reconstruct the interval DCS afterward, which requires sorry.

---

## 2. Strategic Assessment

### 2.1 Can c2' Sorries Be Eliminated Without Architectural Change?

**No**. The c2' sorries ask for `BurgessR3Maximal(f(a), g(a,b), f(b))` at new adjacent pairs created by point insertion. The current insertion functions return only the new MCS D, with g unchanged. To fill g for the new pair, you need:

- The old g(x,y) for the adjacent pair that was split
- A new DCS B' satisfying `burgessR3(f(x), B', D)` and `burgessR3(D, B'', f(y))`
- The maximality of B' and B''

This is precisely what Burgess's Lemma 2.6 provides. Without it, the c2' obligation is unprovable.

### 2.2 Can restricted_fuc Be Proved Without c2'?

**Possibly, but with significant difficulty**. The limit_g is defined as the intersection of all limit_f(y) for y between x and z. The guard at intermediate points follows if we can show:

Given U(xi, eta) in limit_f(x), the witness y produced by limit_satisfies_c5_weak has xi in limit_f(z) for all z between x and y.

This requires showing that the omega-chain's elimination step for the C5 counterexample (x, xi, eta) produces a witness y such that at the finite stage, xi holds at all intermediate domain points. Under Burgess's construction with full g-values, this is immediate from C2 + C3. Without g-values at finite stages, you would need to prove it from C0 alone, which appears to require exactly the g-value infrastructure that is missing.

### 2.3 Does the Limit Construction Bypass c2'?

**Partially yes, partially no**. At the limit:
- C2' is vacuously true (no adjacent pairs in the dense limit domain) -- this is already proved
- C3 is satisfied by construction (limit_g is defined as the intersection)
- C4/C4' are proved sorry-free at the limit
- forward_G and backward_H are proved sorry-free at the limit

The only thing missing is the GUARD for C5/C5'. The weak C5 (endpoint only) is sorry-free. The full C5 (with guard) requires showing xi in limit_g(x,y), which requires showing xi in limit_f(z) for all z between x and y. This is the content of `cantor_bfmcs_restricted_fuc`.

**Key question**: Can forward_G give us the guard? If G(xi) in limit_f(x), then xi in limit_f(z) for all z > x by forward_G. But we don't have G(xi) -- we have U(xi, eta) in limit_f(x). By BX5, this gives U(xi AND U(xi,eta), eta) in limit_f(x). But this still doesn't give G(xi).

---

## 3. Recommended Approach

### Option A: Full Burgess Alignment (Recommended)

Restructure `lemma_2_4` and `lemma_2_6` to produce interval DCS values alongside the endpoint MCS, following Burgess exactly. Define an `EliminationResult` that carries the g-values for new adjacent pairs.

**Specifically**:

1. **Rewrite `lemma_2_4`** to return `(B, C)` where B is a DCS with `beta in B` and `R(f(x), B, C)` holds. The seed for C remains the same. B is obtained by taking the maximal DCS B with r(f(x), B, C) and beta in B (using Zorn's lemma, which is already available via `rMaximal_extension_exists`).

2. **Rewrite `lemma_2_6`** to return `(B', D, B'')` where `R(A, B', D)`, `R(D, B'', C)`, and `B = B' inter D inter B''`. The seed for D is Burgess's D_0 set. B' and B'' are obtained by maximality (Zorn).

3. **Update `EliminationResult`** to carry g-values: instead of `c2' : sorry`, the elimination functions directly produce the g-values for new adjacent pairs, derived from the (B, C) or (B', D, B'') produced by the insertion lemma.

4. **Update `eliminate_potential_counterexample`** to pass through the new g-values.

5. **Prove `restricted_fuc`** using the chain of g-values maintained by the omega-chain. At step n where the C5 counterexample is eliminated, the witness y has `eta in f(y)` AND `xi in g(x, y)`. By C3 at the limit, `limit_g(x, y) subset limit_f(z)` for z between x and y. Since xi in g(x,y) subset limit_g(x,y), we get xi at all intermediate z.

### Option B: Limit-Only Guard Proof (Alternative)

Avoid restructuring the finite-stage construction entirely. Instead, prove the guard at the limit directly using forward_G and C4:

- By BX5, U(xi, eta) in f(x) gives U(xi AND U(xi,eta), eta) in f(x).
- The C5_weak witness y has eta in f(y).
- For any z between x and y: either xi in f(z) or xi.neg in f(z) (MCS).
- If xi.neg in f(z), then since neg(U(xi,eta)) is NOT in f(x) (we have U(xi,eta)), and eta in f(y)... this doesn't directly give a contradiction from C4 because C4 involves neg(U(xi,eta)) which is NOT what we have.

**Problem**: Option B does not work straightforwardly. The guard is not derivable from C0 + C4 + forward_G alone. You genuinely need the interval function g with C2.

### Option C: Strengthen C5 Elimination (Hybrid)

Keep the current architecture but strengthen `eliminate_C5_counterexample` to additionally produce a proof that `xi in limit_f(z)` for all z between x and y. This would require the elimination to track the guard formula, which it currently discards.

**Assessment**: This is feasible but amounts to a partial version of Option A. The elimination function would need to carry g-like information without formally constructing the DCS.

### Recommendation: **Option A** (Full Burgess Alignment)

Option A is the cleanest, most maintainable, and most certain to work. It follows Burgess exactly, so there are no mathematical uncertainties. The main cost is rewriting `lemma_2_4` and `lemma_2_6`, but these are moderate-sized functions (~25 lines each) and the mathematical content is already understood.

---

## 4. Ideal EliminationResult

```lean
structure EliminationResult (chi : Chronicle) (pc : PotentialCounterexample) where
  val : Chronicle
  dom_sub : chi.dom subset val.dom
  c0 : val.c0
  c2' : val.c2'  -- NOW PROVED, not sorry
  f_agrees : forall x in chi.dom, val.f x = chi.f x
  g_agrees_old : forall a b, Adjacent chi.dom a b ->
    val.g a b = chi.g a b  -- old adjacent pairs keep old g
  c5_forward_witness : ...  -- endpoint AND guard
  c5_backward_witness : ... -- mirror
  c4_forward_witness : ...
  c4_backward_witness : ...
  density_witness : ...
```

The key change: `c2'` is proved (not sorry), and the g-values for new adjacent pairs are explicitly constructed within each elimination function using the (B, C) or (B', D, B'') from the restructured insertion lemmas.

---

## 5. Remaining Work Estimates

### Option A: Full Burgess Alignment

| Component | Lines Changed | New Lemmas | Effort |
|-----------|--------------|------------|--------|
| Rewrite `lemma_2_4` (produce B,C) | ~30-50 new, ~25 modified | 1-2 | Medium |
| Rewrite `lemma_2_6` (produce B',D,B'') | ~60-80 new | 2-3 | Medium-Hard |
| Update `EliminationResult` | ~20 modified | 0 | Easy |
| Update `eliminate_C5_counterexample` | ~40-60 modified | 1-2 | Medium |
| Update `eliminate_C5'_counterexample` | ~40-60 modified | 1-2 | Medium |
| Update `eliminate_C4_counterexample` | ~30-40 modified | 0-1 | Medium |
| Update `eliminate_C4'_counterexample` | ~30-40 modified | 0-1 | Medium |
| Update density case | ~20-30 modified | 0-1 | Easy-Medium |
| Update `eliminate_potential_counterexample` | ~30-40 modified | 0 | Easy |
| Prove `restricted_fuc` | ~60-100 new | 2-3 | Medium-Hard |
| **Total** | **~360-500 lines changed** | **~8-15 new lemmas** | **3-5 days** |

### Closes All 9 Sorry Sites

- 7 c2' sorries in CounterexampleElimination.lean: directly resolved
- 2 restricted_fuc sorries in ChronicleToCountermodel.lean: resolved via full C5 with guard

---

## 6. ROADMAP Alignment

From `specs/ROADMAP.md`, the representation theorem goal is:
> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

The proposed fix directly advances this goal:
- `dd_countermodel_chronicle` would become sorry-free
- This plugs directly into `bx_completeness` via the parametric representation theorem
- The Cantor isomorphism maps the limit domain to all of Rat, giving D=Rat completeness
- Task 109 (BXCanonical 23 sorries) becomes dead code for completeness, though useful for cleanup

The fix also advances general completeness (all strict linear orders) since the chronicle construction works for arbitrary sparse X subset Q, not just dense orders.

---

## 7. Confidence Level

**90% confidence** that Option A resolves all 9 sorry sites and produces a sorry-free `dd_countermodel_chronicle`. The mathematical content follows Burgess 1982 exactly with no novel arguments needed. The main risks are:

1. **Seed consistency for Burgess's D_0 in Lemma 2.6** (10% risk): The D_0 set `{S(alpha, beta) : alpha in A, beta in B} union B union {neg delta} union {U(gamma, beta) : gamma in C, beta in B}` is more complex than the current seeds. Proving its consistency requires combining elements from all four sources. Burgess proves this using A4a (invalid under strict semantics), so the BX replacement axioms (BX5, BX6, BX7) must suffice. This is the main uncertainty.

2. **BX axiom adequacy** (5% risk): Burgess uses A3a-A4a which are invalid under strict/open-guard semantics. The BX axiom set (BX4-BX7, BX10) must provide equivalent power. Prior work (PointInsertion.lean) has already adapted Lemma 2.4 successfully using BX4+BX10, suggesting this is feasible.

3. **Lean proof engineering** (5% risk): The Zorn's lemma application for maximality and the Finset manipulation for adjacent pair tracking may require nontrivial engineering, but no mathematical obstacles are expected.
