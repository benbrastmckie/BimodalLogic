# Teammate B Findings: How Does Burgess Actually Populate g-Values?

## Executive Summary

Burgess's construction populates g-values **at every point insertion step** (Lemmas 2.4, 2.6, 2.7, 2.8, 2.9, 2.10). The g function is a first-class citizen: adjacent pairs get R-maximal DCS values from the insertion lemmas, and non-adjacent pairs are **defined** by C3. The codebase's `g := fun _ _ => empty` is a fundamental deviation. However, the codebase has a compensating structural advantage that may make the empty-g approach viable for the truth lemma -- though not without work.

---

## 1. How Burgess Creates and Maintains g-Values

### 1.1 Lemma 2.4 (C5 elimination -- creating new endpoint y)

Given MCS A with U(gamma, beta) in A, Lemma 2.4 produces:
- An MCS C with gamma in C (the witness)
- A DCS B with beta in B satisfying R(A, B, C) -- that is, B is **R-maximal** w.r.t. the Burgess r-relation r(A, -, C)

The g-value assignment is: `g'(x, y) = B` where x is the existing point with f(x) = A and y is the new point with f'(y) = C. Then C3 **defines** all other g-values involving y:
- For any existing w < x: `g'(w, y) = g(w, x) intersect f(x) intersect g'(x, y)`
- For any existing w > y: not applicable (y is placed beyond all existing points in case n=0)

So Lemma 2.4 creates **one new adjacent g-value** (the R-maximal B), and C3 determines all non-adjacent values.

### 1.2 Lemma 2.6 (C4 elimination -- inserting z between x and y, case n=0)

Given R(f(x), g(x,y), f(y)) and delta not in g(x,y), Lemma 2.6 produces:
- MCS D with neg(delta) in D
- DCS B' with R(f(x), B', D) and g(x,y) subset B'
- DCS B'' with R(D, B'', f(y)) and g(x,y) subset B''
- The identity `g(x,y) = B' intersect D intersect B''` (Lemma 2.5)

The g-value assignments are:
- `g'(x, z) = B'` (R-maximal, newly created)
- `g'(z, y) = B''` (R-maximal, newly created)
- C3 determines all g'(w, z) and g'(z, w) for other domain points w

### 1.3 Lemma 2.7/2.8 (C5 elimination -- inserting z between x and x', inductive step)

Same pattern as 2.6: given R(f(x), g(x,x'), f(x')), the lemma produces D (the new MCS), B' (the left interval DCS), B'' (the right interval DCS), with C3 defining the rest.

### 1.4 The Omega Chain (Section 2.8)

At each step n+1, the construction processes one counterexample. If it requires inserting a point z, the f and g functions are **both** extended:
- `f_{n+1}` extends `f_n` with the new MCS at z
- `g_{n+1}` extends `g_n` with the new adjacent-pair DCS values, plus C3 definitions for all non-adjacent pairs involving z

The limit is:
- `f = union of f_n` (well-defined because f agrees on old points)
- `g = union of g_n` (well-defined because g agrees on old pairs)

The limit (f, g) satisfies C0-C5 with g playing its full role.

---

## 2. What the Codebase Does Wrong (and a Key Saving Grace)

### 2.1 The Problem

The codebase's `singleton_chronicle` sets `g := fun _ _ => empty`, and every elimination function passes `chi.g` unchanged. The g field is structurally dead.

Looking at `eliminate_C5_counterexample` (CounterexampleElimination.lean:167):
```
refine <...fun q => if q = y then C else chi.f q, chi.g, insert y chi.dom...>
```

It passes `chi.g` unchanged. The same pattern holds for `eliminate_C4_counterexample`, `eliminate_density_counterexample`, etc. None update g.

### 2.2 The Saving Grace: R3Maximal Forces MCS

The codebase has a critical structural discovery (PointInsertion.lean:763, `R3Maximal_is_mcs`): Under the codebase's definition of `r3Relation` (which is obligation-propagation-based and **monotone** in B), `R3Maximal(A, B, C)` forces B to be an MCS.

This is a departure from Burgess. Burgess's r-relation is content-based (`forall beta in B, forall gamma in C, (beta U gamma) in A`), which is NOT monotone in B. So Burgess's R-maximal DCS are genuinely non-MCS proper subsets of MCS. The codebase's R3Maximal cannot produce non-MCS DCS because any proper extension would still satisfy r3Relation.

**Consequence for Lemma 2.6**: In the codebase, `lemma_2_6_full` (PointInsertion.lean:840) sets D = B' = B'' = B (all equal to the forced MCS). This trivializes the three-way decomposition: no new DCS need to be constructed.

### 2.3 Why This Matters for g

If every g(x,y) in the codebase's chronicle is forced to be an MCS (by R3Maximal), then g(x,y) has the same structure as f(z) for some point z. In fact, the C3 identity `g(x,z) = g(x,y) intersect f(y) intersect g(y,z)` with MCS g-values becomes an intersection of three MCS, which is generally NOT an MCS (it is a DCS, but not maximal). This creates a tension: C3 would force g(x,z) to be a proper DCS (not MCS) for non-adjacent pairs, while C2' forces adjacent g-values to be MCS.

The codebase avoids this tension entirely by not tracking g. But it then lacks the mechanism for the truth lemma's Until case.

---

## 3. Comparison: What g Provides That f Alone Doesn't

### 3.1 The Truth Lemma's Until Case (Claim 2.11)

From U(beta, gamma) in f(x), C5 gives y with gamma in f(y) and **beta in g(x,y)**. For intermediate z with x < z < y, C3 gives `g(x,y) subset f(z)`, hence beta in f(z). This is the guard.

Without g, the codebase has:
- C5_weak: exists y > x with gamma in f(y) (the witness)
- limit_forward_G: G(phi) in f(x) and x < y implies phi in f(y)
- limit_satisfies_c4: the C4 condition at the limit

But it LACKS: "beta holds at all intermediate points between x and y."

### 3.2 Can limit_forward_G Replace g for the Guard?

**No, not directly.** G(beta) in f(x) would give beta at all y > x. But U(beta, gamma) in f(x) does NOT imply G(beta) in f(x). The Until formula only guarantees beta on the interval [x, witness), not globally.

The codebase's `limit_forward_G` is proved via C4 + contradiction. It handles the G/H cases of the truth lemma (which are now sorry-free). But it cannot handle the Until guard.

### 3.3 What About the BX5 Self-Accumulation Path?

BX5 gives: U(gamma, beta) in f(x) implies U(gamma AND U(gamma, beta), beta) in f(x). This means the accumulated formula `gamma AND U(gamma, beta)` holds on the guard interval. At each intermediate point z:
- gamma in f(z) (the guard)
- U(gamma, beta) in f(z) (the Until persists)

This is exactly what C5 (the full version, not C5_weak) guarantees: at intermediate domain points z, both gamma in f(z) AND U(gamma, beta) in f(z).

The codebase's `EliminationResult` has a `c5_forward_witness` field that only records `exists y, x < y AND eta in f(y)`. It discards the guard information. The handoff (Finding in item 3) notes this: "Strengthen EliminationResult.c5_forward_witness to include guard info."

---

## 4. Is the Empty-g Approach Viable?

### 4.1 Approach A: Reconstruct g at the Limit (Zorn's Lemma)

Define `limit_g(x,y)` as the R3-maximal DCS satisfying r3Relation(limit_f(x), -, limit_f(y)). By Zorn's lemma, such exists. Would this satisfy C3?

**Problem**: There is no reason that independently chosen R3-maximal DCS for different pairs would satisfy C3. C3 requires `g(x,z) = g(x,y) intersect f(y) intersect g(y,z)` -- a global coherence condition. Choosing g-values independently for each pair gives no such guarantee.

**Verdict**: Not viable without additional argument.

### 4.2 Approach B: Define g by C3 from a Base Case

Choose g(x,y) for adjacent pairs (where adjacency is defined in the LIMIT domain -- but the limit domain is dense, so there ARE no adjacent pairs).

**Verdict**: Not applicable. The limit domain is dense by construction (`limit_dom_dense`).

### 4.3 Approach C: Track g During Elimination (Fix the Omega Chain)

Update the elimination functions to actually produce g-values. Each `eliminate_*` function would return not just the new f-values but also the new g-values for adjacent pairs involving the inserted point, with C3 defining the rest.

**Assessment**: This is the correct approach and matches Burgess. However, the codebase's `R3Maximal_is_mcs` discovery simplifies things enormously: since g(x,y) at adjacent pairs is forced to be an MCS (identical to some f(z)), the g-values are trivially determined by the f-values. Specifically, for adjacent x < y, g(x,y) must be an MCS satisfying r3Relation(f(x), g(x,y), f(y)). Then for non-adjacent x < z with intermediate y, `g(x,z) = g(x,y) intersect f(y) intersect g(y,z)`.

But this still requires non-trivial infrastructure to maintain at every step.

### 4.4 Approach D: Bypass g Entirely via Strengthened C5 + Density

The most promising approach for the codebase's current architecture:

1. Strengthen `EliminationResult.c5_forward_witness` to record the FULL guard: not just "exists y > x with eta in f(y)" but "exists y > x with eta in f(y) AND for all z in dom with x < z < y, xi in f(z) AND U(xi, eta) in f(z)."

2. This full guard transfers to the limit: at the limit, for any x in limit_dom with U(xi, eta) in limit_f(x), there exists y in limit_dom with eta in limit_f(y) and for all z in limit_dom with x < z < y, xi in limit_f(z).

3. By density of limit_dom, "for all z in limit_dom with x < z < y" covers all points in the dense order, which is equivalent to "for all z with x < z < y" since limit_dom IS the full model domain.

**Key insight**: The guard at intermediate DOMAIN points is exactly what the truth lemma needs, because the model IS the limit domain. We don't need a separate g function -- the guard is witnessed by the f-values at domain points.

**What needs to change**:
- `C5Counterexample.no_witness` already checks the full guard (line 54-55)
- `eliminate_C5_counterexample` uses `lemma_2_4` which produces g_content(A) subset C. The guard gamma at intermediate points comes from the r-relation propagation.
- The `EliminationResult.c5_forward_witness` type needs to carry the guard info through
- `limit_satisfies_c5_weak` upgrades to `limit_satisfies_c5_full`

**Potential obstacle**: The base case of Lemma 2.10 (n=0, no points after x) places y beyond all domain points. The guard is vacuously true (no intermediate domain points). This is correct.

The inductive case (n=m+1, x' immediately succeeds x) either:
- Reduces to n=m by replacing x with x' (if U(xi,eta) persists AND eta in g(x,x'))
- Inserts z between x and x' using Lemma 2.7/2.8

In the codebase's version (no g tracked), the reduction test "eta in g(x,x')" is not available. Instead, the test should be reformulated purely in terms of f-values and the Until formula:
- If xi in f(x') AND U(xi, eta) in f(x'): reduce (xi propagates by BX5 self-accumulation)
- If eta in f(x'): x' is the witness (with vacuous guard if x and x' are adjacent)
- Otherwise: insert via 2.7/2.8 pattern

This is essentially what the current `eliminate_potential_counterexample` does for the c5_forward case (lines 726-758). It just doesn't record the guard.

---

## 5. Conclusions and Recommendations

### Finding 1: Burgess's g is Integral to His Proof
Burgess creates g-values at every insertion step. The g function provides the "interval content" that connects the endpoints. Without it, the truth lemma's Until case has no mechanism to establish the guard at intermediate points.

### Finding 2: The Codebase's r3Relation Monotonicity Changes the Game
Because the codebase's r3Relation is monotone in B (unlike Burgess's), R3Maximal forces g-values to be MCS. This substantially simplifies the g-value construction but does not eliminate the need for tracking g.

### Finding 3: The Empty-g Approach IS Viable via Approach D
The codebase can bypass g entirely by:
1. Strengthening `c5_forward_witness` to carry the guard information
2. Using density to transfer the guard from domain points to all points
3. The truth lemma's Until case then uses "for all z in limit_dom between x and y, xi in limit_f(z)" rather than "xi in g(x,y) subset f(z)"

### Finding 4: The Key Missing Piece is Guard Propagation in C5
The two sorry sites at ChronicleToCountermodel.lean:964-968 (`restricted_fuc` Until and Since) need exactly this: the guard at intermediate points. The fix is to thread guard information through the elimination result type, not to rebuild the g infrastructure.

### Finding 5: The Base-Point Guard (r = t) Remains an Independent Issue
Even with full guard propagation at intermediate points, the guard at the base point r = t (where U(phi,psi) holds) requires `phi in f(t)` or `psi in f(t)`. BX9 gives `phi OR psi`, so if `psi in f(t)`, the guard might not hold for phi at t. This is the issue identified in the handoff's Finding 5 and is independent of the g-value question.

### Recommended Path Forward
1. **Do NOT rebuild the omega chain to track g.** The R3Maximal-forces-MCS discovery means g-values would just be MCS anyway, and the C3 intersection would need non-trivial coherence proofs.
2. **Strengthen the C5 elimination result** to include guard info at intermediate domain points.
3. **Prove `limit_satisfies_c5_full`** from the strengthened elimination result.
4. **Use density** to transfer the domain-point guard to all points for the truth lemma.
5. **Handle the base-point guard** as a separate issue (possibly via changing the guard interval from [t,s) to (t,s), or adding BX9s as discussed in the handoff).
