# Research Report: Alternative Approaches for the Discrete Case

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: Research complete
- **Type**: lean4
- **Artifacts**: reports/08_discrete-alternative-research.md

## Executive Summary

Five approaches were analyzed for resolving the `sorry` at `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:554). The fundamental problem: proving that the succ chain from `a` reaches `b` in finitely many steps when both are in `LimitDomSubtype`, which is needed for the Z-isomorphism `LimitDomSubtype ≃o Int` via Mathlib's `orderIsoIntOfLinearSuccPredArch`.

**Key finding**: Burgess's construction does NOT require `IsSuccArchimedean` or a Z-isomorphism. The truth lemma (Claim 2.11) works for ANY linear order X satisfying C0-C5. The Z-isomorphism is an artifact of the codebase's `AddCommGroup D` requirement in `valid`, not a mathematical necessity.

**Recommended approach**: Approach 4 (prove `IsSuccArchimedean` via the two-phase well-founded induction from report 07, with the dom_N measure properly corrected). This has the smallest delta to the existing plan and avoids architectural changes. The mathematical argument IS correct -- the formalization challenge is manageable with the corrected measure strategy.

---

## 0. Problem Context

### 0.1 The AddCommGroup Constraint

The semantic framework requires `D` to satisfy `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. This constraint propagates through:

- `TaskFrame D` (Semantics/TaskFrame.lean:93)
- `truth_at` (Semantics/Truth.lean:89)
- `valid` (Semantics/Validity.lean:73)
- `ShiftClosed` (via WorldHistory time shifts requiring `t + delta` arithmetic)
- `ParametricCanonicalTaskModel D` (entire parametric infrastructure)

The `valid` definition quantifies: `forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] ...`. The completeness proof is contrapositive: given non-derivable phi, find D and a countermodel over D. The countermodel MUST produce a concrete D with all four instances.

### 0.2 Why LimitDomSubtype Cannot Be D

`LimitDomSubtype = {q : Rat // q in limit_dom A h_mcs}` inherits `LinearOrder` from Rat but is NOT closed under addition. If `a, b in limit_dom`, `a + b` is typically NOT in `limit_dom` (the domain is an irregular countable subset of Q). Therefore `AddCommGroup (LimitDomSubtype A h_mcs)` is impossible. This was confirmed by 4 independent teammates in Round 1 research (reports 01_teammate-a through 01_teammate-d).

### 0.3 The Current Architecture

The plan (04_case-split-completeness.md) case-splits on the root MCS:
- **Dense case** (F'T in A0): Map `LimitDomSubtype ≃o Rat` via Cantor iso. D = Rat. **Phases 1-3 completed.**
- **Discrete case** (U(T,bot) in A0): Map `LimitDomSubtype ≃o Int` via Z-iso. D = Int. **Phase 4 blocked at IsSuccArchimedean.**

Both cases need an order isomorphism to a type with `AddCommGroup`.

### 0.4 Burgess Section 1.6 Analysis

Burgess says the discrete variant uses axioms `G'bot /\ H'bot` (= `U(T,bot) /\ S(T,bot)`). He states: "For the reader familiar with ordinary G,H-tense logic, the adaptation of our work below to prove these variants is a routine exercise." He does NOT mention Z-isomorphism. His completeness proof builds X = union of dom f_n and defines V directly on X. The truth lemma (Claim 2.11) works for ANY linear order satisfying C0-C5.

In Burgess's framework, the model IS (X, <) with V defined by `x in V(alpha) iff alpha in f(x)`. No group structure is needed. The `AddCommGroup` requirement is entirely an artifact of this codebase's `TaskFrame`/`ShiftClosed` infrastructure, not of the mathematics.

---

## 1. Approach 1: Direct Int Chain (Bypass Chronicle Entirely)

### 1.1 Description

Build the MCS chain directly on Int without the chronicle construction:
- chain(0) = A0
- chain(n+1) = next MCS derived from chain(n) via Lemma 2.4 (Until witness)
- chain(-(n+1)) = previous MCS derived similarly
- Use dovetailing to handle all C4/C5 counterexamples across all formulas

### 1.2 Mathematical Viability: NO

The fundamental problem is C4 (counterexample elimination). C4 requires inserting points BETWEEN existing domain points. On Int, there is no room between consecutive integers.

Concretely: C4 says if `neg(U(gamma, delta)) in f(n)` and `gamma in f(m)` with `n < m`, then there must exist `k` with `n < k < m` and `neg(delta) in f(k)`. When `n` and `m` are consecutive integers (m = n + 1), there IS no integer strictly between them. The C4 property cannot be satisfied by a direct Int chain unless the chain assignment is constructed so that C4 violations never arise -- but this requires careful control that the standard Lemma 2.4 approach does not provide.

The chronicle construction handles C4 by inserting rationals like `(x + y) / 2` between existing points. This is essential and cannot be replicated on Int.

### 1.3 Lean Implementation Feasibility: N/A

### 1.4 Estimated Effort: N/A

### 1.5 Risks: Mathematically unsound

### 1.6 Avoids IsSuccArchimedean: Yes, but replaces it with an even harder problem

---

## 2. Approach 2: Use D = Lex(Rat x Int)

### 2.1 Description

Use `D = Lex(Rat x Int)` (lexicographic product) as the carrier type. This has:
- `AddCommGroup` (from `Prod.Lex.orderedCommGroup` / additive analogue)
- `LinearOrder` (from `Prod.Lex.linearOrder`)
- Discreteness: the gap `(0, 1)` exists, so U(T,bot) is satisfiable
- `Nontrivial` (from (0,0) /= (0,1))

Embed `LimitDomSubtype` into `Lex(Rat x Int)` order-preservingly, then build the countermodel over `Lex(Rat x Int)`.

### 2.2 Mathematical Viability: CONDITIONAL (significant obstacles)

**Problem 1: IsOrderedAddMonoid**. The `valid` definition requires `[IsOrderedAddMonoid D]`. For `Lex(Rat x Int)`, the additive order compatibility needs `a <= b -> a + c <= b + c`. In lex order: if `(r1, n1) <= (r2, n2)` (meaning r1 < r2, or r1 = r2 and n1 <= n2), does `(r1 + r3, n1 + n3) <= (r2 + r3, n2 + n3)`? Yes: if r1 < r2, then r1 + r3 < r2 + r3; if r1 = r2 and n1 <= n2, then r1 + r3 = r2 + r3 and n1 + n3 <= n2 + n3. So this works.

**Problem 2: Embedding LimitDomSubtype**. Need an order-preserving injection `iota : LimitDomSubtype -> Lex(Rat x Int)`. Natural candidate: `iota(q) = (q.val, 0)`. But this embeds into `{r} x {0}` for varying r, and the lex order on `(r, 0)` is just the Rat order. The limit domain points land in `Lex(Rat x Int)` at `(q, 0)`, preserving the Rat ordering. This works for the order embedding.

**Problem 3: Extending limit_f to all of Lex(Rat x Int)**. The countermodel needs `f : Lex(Rat x Int) -> Set Formula` defined everywhere. We have `limit_f` defined on `limit_dom subset Rat`. For `(q, 0)` with `q in limit_dom`, use `limit_f(q)`. For other points in `Lex(Rat x Int)`, we need MCS assignments that satisfy forward_G and backward_H.

This is EXACTLY the natural inclusion extension problem that was proved impossible in report 04. The issue: for non-domain points, there is no way to define an MCS assignment that satisfies `forward_G` under strict G semantics. The strict inequality `t < t'` means G(phi) at `(q, 0)` must propagate to ALL `(q', n')` with `(q, 0) < (q', n')`, including points `(q, 1), (q, 2), ...` that are NOT in the image of `limit_dom`. These non-image points have no natural MCS assignment.

**Problem 4: Soundness of discreteness axioms**. The four uniformity axioms (discrete_symm_fwd, discrete_symm_bwd, discrete_propagate_fwd, discrete_propagate_bwd) are sound over `Lex(Rat x Int)` because translation invariance holds: if `(r, n) < (r, n+1)` with nothing between (in whatever ShiftClosed Omega is used), the same gap exists everywhere by translation.

### 2.3 Lean Implementation Feasibility: LOW

Even if the mathematical obstacles could be overcome, Mathlib may not have the additive lex product instances readily available. The multiplicative versions exist (`Prod.Lex.orderedCommGroup`, `Prod.Lex.linearOrderedCommGroup`) but the additive versions are not found via local search. They would need to be derived or constructed manually.

Furthermore, the extension problem (Problem 3) is a hard blocker -- the same fundamental issue that blocked the natural inclusion approach in report 04.

### 2.4 Estimated Effort: 30+ hours (if feasible at all)

### 2.5 Risks: Extension problem is likely mathematically impossible (same as report 04)

### 2.6 Avoids IsSuccArchimedean: Yes, but creates equally hard problems

---

## 3. Approach 3: Modify Chronicle Construction to Prevent Cascading

### 3.1 Description

Modify the chronicle omega chain construction to process ALL counterexamples at current domain points SIMULTANEOUSLY at each stage, rather than one at a time. This would prevent cascading insertions in bounded intervals.

### 3.2 Mathematical Viability: CONDITIONAL (extremely complex)

The current chronicle construction processes ONE counterexample per stage (via `counterexample_enum`). If we processed ALL counterexamples at each stage, the C5 resolution for different formulas could interfere with each other. Specifically:

- At stage n, domain points are `{q1, ..., qk}`.
- Multiple C5 counterexamples exist: `U(xi_1, eta_1) in f(q_i)`, `U(xi_2, eta_2) in f(q_j)`, etc.
- Resolving all simultaneously requires inserting multiple new points between existing pairs.
- Each insertion uses Lemmas 2.6/2.7/2.8, which produce new DCS values (B', D, B'') that depend on the existing g-values.
- Simultaneous insertions at different positions are independent (they affect different intervals).
- Simultaneous insertions in the SAME interval are NOT independent (the second insertion's B'/D/B'' depend on the g-values modified by the first insertion).

So a "process all" approach at each stage would need to handle ordering within each interval carefully. This is essentially redesigning the entire chronicle construction -- a massive undertaking that would invalidate all existing proofs in ChronicleConstruction.lean, CounterexampleElimination.lean, and PointInsertion.lean (collectively over 5000 lines of Lean).

### 3.3 Lean Implementation Feasibility: VERY LOW

Would require rewriting the entire chronicle construction (3000+ lines). The current construction is already one of the most complex parts of the codebase.

### 3.4 Estimated Effort: 80+ hours

### 3.5 Risks: Extremely high risk of introducing new bugs. No guarantee that simultaneous processing avoids cascading.

### 3.6 Avoids IsSuccArchimedean: Conditionally (if the modification provably gives finitely many points between any two fixed points)

---

## 4. Approach 4: Prove IsSuccArchimedean via Corrected Two-Phase Induction

### 4.1 Description

Prove `IsSuccArchimedean` using the strategy from report 07, Section 6.2 (Approach B), with corrections to handle the "pred(b) not in dom_N" issue. The key insight from report 07 is the two-phase strategy:

**Phase 1**: Prove `exists k, pred^[k](b) = a` when `a <= b` and both are in `dom_N`.

Use `Nat.strongRecOn` on `m = |dom_N.filter(fun x => a.val <= x /\ x <= b.val)|`:
- Base (m <= 1): Since both `a.val, b.val in dom_N`, m >= 2 unless a = b. So a = b, k = 0.
- Step (m >= 2): a < b. Let b' = pred(b). We have a <= b' < b and succ(b') = b.
  - `m' = |dom_N.filter(fun x => a.val <= x /\ x <= b'.val)| < m` because:
    - dom_N elements in [a.val, b'.val] are a subset of dom_N elements in [a.val, b.val]
    - b.val is in dom_N inter [a.val, b.val] but NOT in dom_N inter [a.val, b'.val] (since b'.val < b.val)
    - No dom_N elements in (pred(b).val, b.val) since no limit_dom elements there
    - Therefore m' <= m - 1 < m
  - **Critical**: We do NOT need b'.val in dom_N for the measure to decrease. The measure counts dom_N elements in [a.val, b'.val], which is always well-defined and strictly smaller than m.
  - **But**: We DO need b'.val in dom_N to apply the IH, since the IH statement requires both endpoints in dom_N.

**The correction**: Reformulate the IH to NOT require the upper endpoint to be in dom_N.

**Corrected statement**: Prove by `Nat.strongRecOn` on `m`:

```
forall (target : LimitDomSubtype A h_mcs),
  a <= target ->
  (dom_N.filter (fun x => a.val <= x /\ x <= target.val)).card <= m ->
  exists k, (limitDomSubtype_pred A h_mcs h_discrete)^[k] target = a
```

Now the analysis:
- m = 0: dom_N inter [a.val, target.val] = empty. But a.val in dom_N and a.val <= target.val, so a.val is in the filter, giving card >= 1. Contradiction. So m = 0 is vacuously true.
- m = 1: Only a.val in dom_N inter [a.val, target.val]. If a = target, done (k = 0). If a < target, then target.val > a.val and target.val NOT in dom_N (else card >= 2). We can still compute pred(target):
  - pred(target) < target
  - a <= pred(target) (from limitDomSubtype_le_pred_of_lt since a < target)
  - card(dom_N inter [a.val, pred(target).val]) <= card(dom_N inter [a.val, target.val]) = 1 (since pred(target).val < target.val, the filter can only get smaller or stay the same)
  - Actually, dom_N inter [a.val, pred(target).val] subset dom_N inter [a.val, target.val], so card <= 1 = m
  - We need card STRICTLY less than m for the IH. But card could equal m = 1.
  - **This is the remaining difficulty**: the measure may not strictly decrease when target is not in dom_N.

**The deeper correction**: Use `Nat.strongRecOn` on `m = card(dom_N.filter(fun x => a.val <= x /\ x <= b.val))` with b FIXED and both a,b in dom_N. Then:

Phase 1 proves: for all b in dom_N with a <= b, exists k, pred^[k](b) = a.

The induction replaces b with pred(b), but the MEASURE is computed relative to the ORIGINAL b's endpoints... no, the measure must be recomputed for pred(b).

**The ACTUALLY correct approach**: Use `Nat.strongRecOn` on `m = card(dom_N.filter(fun x => a.val < x /\ x <= b.val))` (open on the left) with BOTH a,b in dom_N:

- m = 0: No dom_N elements in (a.val, b.val]. Since b.val in dom_N: if a.val < b.val, then b.val in (a.val, b.val] inter dom_N, giving card >= 1. Contradiction. So a.val >= b.val. Combined with a <= b, we get a = b. Use k = 0.
- m >= 1: a < b. Let b' = pred(b). Then a <= b' < b, succ(b') = b.
  - **If b'.val in dom_N**: m' = card(dom_N inter (a.val, b'.val]) = m - 1 < m (by the argument that b.val is removed and no dom_N points in (b'.val, b.val)). Apply IH to get pred^[j](b') = a. Then pred^[j+1](b) = pred^[j](pred(b)) = pred^[j](b') = a.
  - **If b'.val NOT in dom_N**: Find the LARGEST dom_N element p with a.val <= p < b.val and no dom_N elements in (p, b.val) except b.val itself (i.e., p is the dom_N predecessor of b). Since a in dom_N and a < b, such p exists. We have p <= b'.val (since b' is the limit_dom predecessor of b, and p is a dom_N element with p < b, so p is in limit_dom, and no limit_dom elements in (b'.val, b.val), so p <= b'.val).
  - Apply IH to (a, p): m'' = card(dom_N inter (a.val, p]) < m (since p < b and b is removed from the count). IH gives pred^[j1](p_sub) = a.
  - Now need: pred^[j2](b') = p_sub for some j2 (connecting b' down to p). But p_sub and b' are both in limit_dom, and p_sub <= b'. And dom_N inter (p, b) = empty (just b). So between p and b in limit_dom, there may be finitely or infinitely many points (this is exactly the gap lemma question).

**This brings us back to the gap lemma**. The two-phase approach from report 07 Section 6.2 DOES work IF we can prove the gap lemma: for consecutive dom_N elements q < r, the succ chain from q reaches r.

### 4.2 The Gap Lemma: A Finiteness Argument

**Claim**: For consecutive dom_N elements q < r (no dom_N elements in (q, r)), limit_dom inter [q, r] is finite.

**Proof sketch** (by contradiction):

Suppose limit_dom inter [q, r] is infinite. Since every element has an immediate predecessor (discrete hypothesis), define the pred chain from r: r, pred(r), pred^2(r), .... Each element is in limit_dom inter [q, r] (by induction: pred^n(r) >= q since a <= pred(b) when a < b, and here q <= pred^n(r) because if pred^n(r) > q then pred^{n+1}(r) >= q).

If the chain never reaches q, we have infinitely many distinct elements pred^n(r), all in limit_dom inter [q, r], all > q, strictly decreasing.

Now consider succ(q): succ(q) is the least limit_dom element above q. We know succ(q) <= r (since r is in limit_dom and r > q). Every pred^n(r) > q satisfies pred^n(r) >= succ(q) (since succ(q) is the LEAST limit_dom element above q).

So the infinite strictly decreasing sequence pred^n(r) is bounded below by succ(q).val. Similarly, succ^2(q) <= pred^n(r) for all n such that pred^n(r) > succ(q). And so on.

The key insight: the intervals (pred^{n+1}(r), pred^n(r)) are disjoint and contain NO limit_dom points. Each such interval has positive rational length. The total length sum_n (pred^n(r).val - pred^{n+1}(r).val) <= r.val - q.val (finite). So the lengths decrease to 0. But each length is positive (pred^{n+1}(r) < pred^n(r)). This gives an infinite sequence of positive rationals summing to at most r - q, which is certainly possible (like 1/2 + 1/4 + ...).

So a direct convergence argument in Q does NOT give a contradiction. We need the omega chain structure.

**Omega chain argument**: Each pred^n(r) is in limit_dom, so pred^n(r) in dom_{k_n} for some stage k_n. Since dom_N is finite, only finitely many pred^n(r) can be in dom_N. In fact, NO pred^n(r) (for n >= 1) is in dom_N: they are all in (q, r), and q, r are consecutive in dom_N, so (q, r) inter dom_N = empty.

For n >= 1: pred^n(r) in dom_{k_n} with k_n > N (since pred^n(r) not in dom_N). At stage k_n, the point pred^n(r) was inserted between two adjacent elements of dom_{k_n - 1}. The adjacent pair (p_n, q_n) satisfies p_n < pred^n(r) < q_n.

Since no limit_dom elements in (pred^{n+1}(r), pred^n(r)), and pred^n(r) is inserted at stage k_n between p_n and q_n, we need p_n <= pred^{n+1}(r) and q_n >= pred^n(r)... actually q_n > pred^n(r) since pred^n(r) is the new point between p_n and q_n.

The stages k_1, k_2, k_3, ... are distinct natural numbers (each pred^n(r) is unique to its first appearance stage). Actually they need not be distinct -- different pred iterates could appear at the same stage. But each pred^n(r) first appears at SOME stage, and later stages contain it.

**The critical observation**: Consider pred^1(r). It appears at stage k_1 > N. At stage k_1, it was inserted as the unique new point. The C5 counterexample that triggered its insertion was at some point x in dom_{k_1} with some formula U(xi, eta). The insertion point z = pred^1(r) satisfies x < z < x' for some x' (the successor of x in dom_{k_1}).

But r is in dom_N subset dom_{k_1}. And pred(r) is between q and r. Since q, r are consecutive in dom_N and dom_N subset dom_{k_1}, there may be dom_{k_1} elements between q and r. The point pred(r) is one such element (at stage k_1 if k_1 is its first stage).

This analysis is getting very detailed. The key question is: can we actually prove finiteness of limit_dom inter [q, r] in Lean, or is this prohibitively complex?

### 4.3 A Simpler Measure: Two-Component

Use the lexicographic measure `(N_max, card)` where:
- `N_max` = max stage at which any element of dom_N inter [a.val, b.val] first appears
- `card` = card(dom_N inter (a.val, b.val])

At each pred step from b to pred(b):
- If pred(b) in dom_N: card decreases by 1, N_max stays. Lex decreases.
- If pred(b) NOT in dom_N: Find N' with pred(b) in dom_{N'}. Set new N = max(N, N'). Now pred(b) in dom_{new_N}. But card(dom_{new_N} inter (a.val, b.val]) >= card(dom_N inter (a.val, b.val]) + 1 since pred(b) is a new element. This could INCREASE the lex pair.

So the two-component measure also fails.

### 4.4 The LocallyFiniteOrder Path

If we can prove `LocallyFiniteOrder (LimitDomSubtype A h_mcs)` (i.e., every closed interval `[a, b]` is finite), then Mathlib gives us `IsSuccArchimedean` for free via `LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder`.

To prove `LocallyFiniteOrder`, we need to construct `Finset.Icc a b` for each `a, b : LimitDomSubtype`. This requires:
1. Proving that limit_dom inter [a.val, b.val] is finite (under the discrete hypothesis)
2. Constructing the Finset explicitly (or via Classical.choice + finite set extraction)

The finiteness proof is the gap lemma in disguise. If we can prove limit_dom inter [q, r] is finite for ANY q, r in limit_dom (not just consecutive dom_N elements), then LocallyFiniteOrder follows.

**Can we prove finiteness?** The argument from report 07 Section 5.3 shows that an infinite limit_dom inter [a, b] leads to an infinite strictly decreasing pred chain, which in turn requires accumulation -- but the discrete hypothesis prevents accumulation (each element has an immediate predecessor with an empty interval before it). The issue is that this argument requires showing the pred chain MUST reach a, which is exactly IsSuccArchimedean.

This is circular: IsSuccArchimedean => finiteness => LocallyFiniteOrder => IsSuccArchimedean.

**Breaking the circularity**: The finiteness argument does NOT actually require IsSuccArchimedean. It requires showing that an infinite strictly decreasing sequence in limit_dom inter [a, b] leads to a contradiction. The contradiction comes from the omega chain structure, not from IsSuccArchimedean.

Here is a NON-circular finiteness proof:

**Theorem**: Under the discrete hypothesis, for any a, b in limit_dom with a <= b, limit_dom inter [a.val, b.val] is finite.

**Proof**: Suppose for contradiction that S = limit_dom inter [a.val, b.val] is infinite. Let N be a stage with both a.val, b.val in dom_N. Then dom_N inter [a.val, b.val] is a finite set (dom_N is a Finset). Let k = card(dom_N inter [a.val, b.val]).

Since S is infinite, there exist elements of S not in dom_N. Let c be any such element: c in limit_dom inter [a.val, b.val] with c not in dom_N. Then c first appears at some stage M > N. At stage M, c is inserted as the unique new point between two adjacent elements p, q of dom_{M-1} with p < c < q.

Now, dom_N subset dom_{M-1}, so p and q bracket c within the dom_N structure. The key: c is the ONLY new point added at stage M in the interval [a.val, b.val]. So card(dom_{M} inter [a.val, b.val]) = card(dom_{M-1} inter [a.val, b.val]) + 1 (if c in [a.val, b.val]) or card(dom_{M-1} inter [a.val, b.val]) (if c not in [a.val, b.val], but we assumed c in [a.val, b.val]).

Wait, the new point at stage M might be OUTSIDE [a.val, b.val]. But we chose c in [a.val, b.val], and c is new at stage M, so the new point at stage M IS c (by `omega_chain_dom_new_unique` -- each stage adds at most one new point).

So each stage that adds a point to [a.val, b.val] increases the count by exactly 1. Starting from card k at stage N, after j such stages, card is k + j.

If S is infinite, infinitely many stages add points to [a.val, b.val]. At stage M_j (the j-th such stage), card(dom_{M_j} inter [a.val, b.val]) = k + j. This is unbounded.

But here's the key: at each stage, the counterexample enumeration processes a specific counterexample. The counterexample involves formulas from the FINITE set of all formulas appearing in the deferral closure... wait, no. The counterexample enumeration processes ALL formula counterexamples, not just those in a finite set. So there could be infinitely many counterexamples with witnesses landing in [a.val, b.val].

**This shows the finiteness argument is NOT trivial to formalize.** The omega chain adds points everywhere, not just in [a.val, b.val]. Points landing in [a.val, b.val] could come from counterexamples at points OUTSIDE [a.val, b.val]. We cannot directly bound the number of points added to [a.val, b.val].

### 4.5 Mathematical Viability Assessment

The mathematical argument for IsSuccArchimedean IS correct: finite intervals in a discrete linear order without endpoints must be IsSuccArchimedean. The challenge is entirely in formalization: finding a measure that Lean's termination checker accepts.

**Most promising formalization path**: The two-phase approach (report 07, Section 6.2) with the following refinement:

Instead of trying to prove pred^[k](b) = a directly with a dom_N measure, prove it by EMBEDDING into a finite interval:

1. Fix N such that a, b in dom_N.
2. Define the finite set `F = dom_N.filter(fun x => a.val <= x /\ x <= b.val)` with card m.
3. Prove by strong Nat induction on m that for all b' in F with a <= b', exists k, pred^[k](b') = a.
4. Base (m = 1): a = b' (since both in F and F = {a}). k = 0.
5. Step (m >= 2): a < b'. Let p = the dom_N predecessor of b' (the largest element of F strictly less than b'. This exists since a in F and a < b'). Then card(F restricted to [a, p]) = m - 1 (removed b' from F). By IH, exists j, pred^[j](p_sub) = a.
6. Now need: exists j2, pred^[j2](b'_sub) = p_sub. Since b' and p are consecutive in dom_N and both in limit_dom, this is the gap lemma.

The gap lemma for consecutive dom_N elements q < r: need pred^[k](r_sub) = q_sub for some k.

For consecutive dom_N elements, the interval (q, r) contains no dom_N points. But it may contain limit_dom points added at stages > N. The key insight: ALL such points were added between q and r during the omega chain construction. Since each stage adds at most one point, and the total number of stages adding points to (q, r) is countable, the limit_dom inter (q, r) is countable.

But we need it to be FINITE. And without the LocallyFiniteOrder result (which requires IsSuccArchimedean), we cannot directly prove finiteness.

**Is there a fundamentally different approach?** Yes -- the next approach.

### 4.6 Viability: CONDITIONAL

Mathematical viability: YES (the theorem is true).
Lean formalization: DIFFICULT. Requires either (a) the gap lemma, which needs omega chain analysis of insertion points in bounded intervals, or (b) the LocallyFiniteOrder approach, which is circular without an independent finiteness proof.

### 4.7 Estimated Effort: 40-60 hours (high uncertainty)

### 4.8 Risks: HIGH. Multiple researchers have attempted this and failed to find a working formalization. The mathematical argument is clear but the Lean termination argument resists formalization.

### 4.9 Avoids IsSuccArchimedean: No (proves it directly)

---

## 5. Approach 5: Prove Completeness Without IsSuccArchimedean by Changing D

### 5.1 Description

Instead of building on `LimitDomSubtype` and then isomorphing to Int, build the countermodel directly on Int by defining a SEPARATE FMCS on Int that mimics the chronicle's properties. The key idea: we already have a discrete limit domain (with SuccOrder and PredOrder). Define an FMCS on Int by picking an arbitrary bijection between `{..., pred^2(0), pred(0), 0, succ(0), succ^2(0), ...}` and Int.

Specifically:
- Define `f_int : Int -> Set Formula` by `f_int(n) = limit_f(succ^[n](origin))` for n >= 0 and `f_int(n) = limit_f(pred^[-n](origin))` for n < 0, where origin is the zero element of LimitDomSubtype.
- This defines an MCS assignment on a SUBSET of Int (the succ/pred-reachable part from origin).

**Wait**: this only works if succ/pred from origin cover ALL of LimitDomSubtype. That is exactly IsSuccArchimedean!

So this approach is equivalent to Approach 4.

### 5.2 Alternative: Use succ/pred reachability directly

Define `R = {succ^[n](origin) | n in Nat} union {pred^[n](origin) | n in Nat}`. This is a subset of LimitDomSubtype, and we can biject R with Int via n -> succ^[n](origin), (-n) -> pred^[n](origin). The bijection is well-defined because succ and pred are injective (from succ_pred and the corresponding pred_succ identity).

Build the FMCS on Int using this bijection. The question: does R = LimitDomSubtype? If yes, IsSuccArchimedean holds and we get the Z-isomorphism. If no, some LimitDomSubtype elements are unreachable, and the FMCS on Int only captures a "succ-reachable" fragment.

**Can we build a valid countermodel using only R?** The countermodel needs:
1. `forward_G`: G(phi) in f_int(n) -> phi in f_int(m) for all m > n. This holds because succ^[k](succ^[n](origin)) = succ^[n+k](origin) and limit_forward_G gives the propagation.
2. `backward_H`: similarly.
3. `F-resolution`: F(phi) in f_int(n) -> exists m > n with phi in f_int(m). This requires that the F-witness from limit_F_resolution lands in R. But limit_F_resolution gives a witness y in limit_dom with y > succ^[n](origin). Is y in R?

**Not necessarily!** The F-witness y comes from the chronicle construction and could be ANY point in limit_dom above succ^[n](origin). It might not be succ-reachable from origin.

However, in the discrete case, if y in limit_dom and y > succ^[n](origin), then y >= succ^[n+1](origin) (since succ(succ^[n](origin)) is the least limit_dom element above succ^[n](origin)). And then y >= succ^[n+1](origin), so IF R = {x in limit_dom : x >= origin or x <= origin} (which it is by construction), then y is in R IFF y is succ-reachable from origin.

But y could be strictly between succ^[n](origin) and succ^[n+1](origin) in limit_dom... WAIT. In the discrete case, there are NO limit_dom points between succ^[n](origin) and succ^[n+1](origin). That is the definition of "succ^[n+1](origin) is the immediate successor." So y >= succ^[n+1](origin).

Similarly, if y > succ^[n+1](origin), then y >= succ^[n+2](origin), etc. So y = succ^[m](origin) for some m > n? Only if the succ chain from origin reaches y. This is exactly IsSuccArchimedean applied to (succ^[n+1](origin), y).

So this approach reduces to IsSuccArchimedean again.

### 5.3 Viability: NO (reduces to Approach 4)

---

## 6. New Approach: Prove IsSuccArchimedean via IsPredArchimedean and Direct Descent

### 6.1 Description

After all the analysis, the cleanest formalization that avoids the gap lemma is a DIRECT DESCENT argument using well-founded recursion on the subtype ordering.

**Key insight that breaks the circularity**: We do NOT need to prove that limit_dom inter [a, b] is finite. We only need to prove that pred^[k](b) = a for some k. This can be done by well-founded recursion on the SUBTYPE ORDERING of LimitDomSubtype restricted to [a, b].

Define the set `I(a, b) = {x : LimitDomSubtype | a <= x /\ x <= b}`. This is a subtype. The ordering on I(a, b) inherited from LimitDomSubtype is a linear order (I(a, b) is a totally ordered subset).

**Claim**: The strict order on I(a, b) is well-founded.

**Proof**: We need to show there is no infinite strictly decreasing sequence in I(a, b). Suppose c_0 > c_1 > c_2 > ... is such a sequence. Then c_0.val > c_1.val > c_2.val > ... is a strictly decreasing sequence of rationals, all in [a.val, b.val].

In Q, such sequences exist (e.g., 1/2, 1/3, 1/4, ...). So we cannot derive a contradiction from the order structure alone.

**But**: each c_n has an immediate predecessor pred(c_n) in LimitDomSubtype with no limit_dom elements between them. And c_{n+1} <= pred(c_n) (since c_{n+1} < c_n implies c_{n+1} <= pred(c_n)). If c_{n+1} = pred(c_n), then succ(c_{n+1}) = c_n. If c_{n+1} < pred(c_n), then the gap (c_{n+1}, pred(c_n)) in limit_dom is non-empty... wait, no: c_{n+1} <= pred(c_n), and pred(c_n) < c_n. If c_{n+1} < pred(c_n), then c_{n+1} is a limit_dom element in [a, pred(c_n)), strictly below pred(c_n) and above a.

This doesn't immediately give a contradiction. The sequence c_n can decrease by more than one "succ step" at a time.

**Revised strategy**: Instead of well-founded recursion on [a, b], use recursion on `dom_N inter [a.val, b.val]` via a Finset-based descent.

Actually, let me reconsider the two-phase approach one more time with a cleaner measure.

### 6.2 The CORRECT Two-Phase Proof (Final Version)

**Phase 1**: Prove by `Nat.strongRecOn` on `m`:

```
forall m : Nat,
  forall b : LimitDomSubtype,
  a <= b ->
  b.val in dom_N ->
  card(dom_N.filter(fun x => a.val < x /\ x <= b.val)) = m ->
  exists k, (limitDomSubtype_pred)^[k] b = a
```

- **m = 0**: dom_N inter (a.val, b.val] = empty. Since b.val in dom_N, b.val not in (a.val, b.val] means a.val >= b.val. With a <= b: a = b. k = 0.

- **m >= 1**: a < b. Let b' = pred(b). a <= b' < b. succ(b') = b.
  
  **Sub-case A**: b'.val in dom_N.
  m' = card(dom_N inter (a.val, b'.val]) = m - 1 (b.val removed, no dom_N in (b'.val, b.val)).
  IH gives pred^[j](b') = a. Then pred^[j+1](b) = a.

  **Sub-case B**: b'.val NOT in dom_N.
  Find the largest dom_N element q in (a.val, b.val). This exists since m >= 1 means dom_N inter (a.val, b.val] is non-empty, and b.val is the largest such. Let q be the largest dom_N element in (a.val, b.val) -- i.e., the largest in dom_N inter (a.val, b.val) that is NOT b.val itself. Wait, b.val IS in dom_N inter (a.val, b.val] (since a < b and b in dom_N). Is there a second-largest?

  If m = 1: dom_N inter (a.val, b.val] = {b.val}. So a and b are consecutive in dom_N (no dom_N between them). pred(b) is in limit_dom inter (a.val, b.val). Need pred^[k](b) = a. With m = 1, this requires showing that the pred chain from b reaches a within the "gap" between consecutive dom_N elements a and b. This IS the gap lemma.

  If m >= 2: dom_N inter (a.val, b.val] has at least 2 elements, including b.val. Let q be the second-largest dom_N element in this set (the largest in dom_N inter (a.val, b.val) strictly less than b.val). Then q in dom_N, a.val < q < b.val, and dom_N inter (q, b.val) = empty (q is the largest below b in dom_N).

  Now pred(b).val <= q (since pred(b) is in limit_dom, pred(b) < b, and no dom_N elements in (q, b.val). Since pred(b) is in limit_dom and pred(b).val < b.val, and q is the last dom_N element before b... actually pred(b).val could be > q if pred(b) is in limit_dom but not in dom_N. We do NOT know pred(b).val <= q.

  OK so regardless of whether pred(b) is in dom_N, the IH applies to q (which IS in dom_N). m_q = card(dom_N inter (a.val, q]) < m (since dom_N inter (a.val, q] is a strict subset of dom_N inter (a.val, b.val] -- b.val is missing). IH gives pred^[j](q_sub) = a.

  Then we need: pred^[k](b) = q_sub for some k. And a = pred^[j](q_sub). So pred^[j+k](b) = a.

  But connecting b to q via pred requires the gap lemma for the interval (q, b].

**Conclusion**: Every formalization of IsSuccArchimedean eventually reduces to the gap lemma for consecutive dom_N elements. The gap lemma is the essential missing piece.

### 6.3 Gap Lemma: Can We Prove It?

The gap lemma says: for consecutive dom_N elements q < r, exists k, pred^[k](r_sub) = q_sub.

**Proposed proof**: Since q and r are consecutive in dom_N, and all limit_dom points in (q, r) were added at stages > N, we can prove by induction on the STAGE that each such point is succ-reachable from q.

At stage N: dom_N inter (q, r) = empty. No limit_dom points in (q, r) at stage N.

At stage N+1: Either the new point at stage N+1 is in (q, r) or not. If it is, call it z. Then z was inserted between two adjacent elements of dom_N, namely q and r. z is the C5 witness for some counterexample. z has the property that it's the only new point in (q, r) at stage N+1.

Now, succ(q) is the least limit_dom element above q. Either succ(q) = z (if z = q' in limit_dom closest to q among elements > q) or succ(q) < z (if there are limit_dom elements between q and z). But at stage N+1, the only limit_dom elements in (q, r) are those in dom_{N+1} inter (q, r) = {z}. No other limit_dom elements exist in (q, r) AT THIS STAGE.

BUT: later stages may add more points in (q, z) or (z, r). These are limit_dom elements that appear at stages > N+1.

So succ(q) might NOT be z -- it could be a point added at a later stage in (q, z).

This makes the stage-based induction non-trivial. We'd need to track the EVENTUAL succ(q) in the limit, not at any finite stage.

### 6.4 Assessment

**Mathematical viability of Approach 4**: YES. The theorem is true. Every countable discrete linear order without endpoints and with both immediate successors and predecessors everywhere is Z-isomorphic. This is a standard result in order theory.

**Formalization difficulty**: HIGH. The standard proof uses the fact that such an order is isomorphic to Z, which requires showing that succ-reachability covers the whole order. The cleanest proof in a formalization context would be via `LocallyFiniteOrder`, but constructing the Finset requires an explicit finiteness witness, which brings us back to the same difficulties.

**Estimated effort**: 40-60 hours, with high uncertainty. The gap lemma is the crux, and multiple sophisticated approaches (dom_N cardinality, omega chain stage analysis, convergence arguments) have been attempted without success.

---

## 7. Summary Table

| Approach | Math Viable | Lean Feasible | Effort | Risk | Avoids Sorry |
|----------|-------------|---------------|--------|------|-------------|
| 1. Direct Int chain | NO | N/A | N/A | Fatal | N/A |
| 2. D = Lex(Rat x Int) | NO (extension blocker) | LOW | 30+ hrs | Very High | Yes |
| 3. Modify chronicle | Conditional | VERY LOW | 80+ hrs | Extreme | Conditional |
| 4. Prove IsSuccArchimedean | YES | DIFFICULT | 40-60 hrs | High | Yes |
| 5. Bypass via succ-reachable fragment | NO (reduces to 4) | N/A | N/A | N/A | N/A |

---

## 8. Recommendation

### 8.1 Primary Recommendation: Approach 4 via the Gap Lemma

Despite the difficulty, Approach 4 is the ONLY viable path that stays within the current architecture. The gap lemma is provably true, and the challenge is purely formalization-mechanical.

**Suggested formalization strategy for the gap lemma**:

Rather than trying to prove finiteness of limit_dom inter [q, r] abstractly, prove the gap lemma DIRECTLY by structural induction on the omega chain construction:

1. At stage N, dom_N inter (q, r) = empty (q, r consecutive in dom_N).
2. Define `S_n = dom_n inter (q, r)` for n >= N. This is a monotonically growing finite set sequence.
3. `limit_dom inter (q, r) = union_n S_n`.
4. At each stage n >= N, at most one new point is added to (q, r): the C5/C4 witness (if it lands in (q, r)).
5. For EACH point z added to (q, r) at stage n+1: z was the resolution of a counterexample for some formula U(xi, eta) at some point x. The formula pair (xi, eta) determines the "type" of the insertion.
6. After z is added, the next C5 counterexample for the SAME formula at x is resolved (because the witness z now exists). So the same formula-point pair does NOT generate another insertion in (q, r).
7. The number of distinct formula-point pairs that can generate insertions in (q, r) is bounded by |{counterexamples at points in dom_n}|. Each such counterexample generates at most a FINITE number of cascade insertions.

**Key lemma needed**: Show that for a FIXED formula pair (xi, eta) and a FIXED source point x, the C5 resolution inserts at most O(1) points in any given interval. This follows from the cascade analysis in report 07 Section 0.2: after ONE insertion for U(T,bot), sub-case (ii) of Lemma 2.10 applies and no further insertion occurs.

**For general formulas U(xi, eta)**: The cascade may insert more than one point, but the number is bounded by the complexity of the formula (specifically, by the depth of nested U/S operators). This gives a finite bound per formula-point pair.

**Total points in (q, r)**: Bounded by (number of counterexample formula-point pairs) x (cascade depth per pair). Both are finite, so limit_dom inter (q, r) is finite.

This argument would give the gap lemma, from which IsSuccArchimedean follows via the two-phase proof.

### 8.2 Estimated Effort for Recommended Path

- Gap lemma proof (finite insertions per interval): 20-30 hours
- Two-phase IsSuccArchimedean from gap lemma: 10-15 hours
- Testing and integration: 5-10 hours
- **Total: 35-55 hours**

### 8.3 Alternative: Mark [BLOCKED] for User Review

If the gap lemma formalization proves too difficult, mark the task [BLOCKED] with a recommendation to:

1. **Restructure the semantics** to use a more permissive `valid` definition that quantifies over linear orders (not just AddCommGroups). This would allow building the countermodel directly on LimitDomSubtype, following Burgess exactly. This is a significant architectural change but eliminates the root cause.

2. **Use a weaker completeness theorem** that says "valid over AddCommGroups implies derivable" rather than "valid over all linear orders implies derivable". The AddCommGroup version is still meaningful and useful. The discrete case would be deferred to a future task that adds the necessary `valid` generalization.

### 8.4 Risk Mitigation

The gap lemma is the single point of failure. If it cannot be formalized within 30 hours, escalate to [BLOCKED] with the alternatives above. Do NOT introduce `sorry` as a workaround.
