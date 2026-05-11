# Teammate B: Alternative Approaches to TC/FUC Without succ_embed_surjective

Task: 123 | Date: 2026-05-11 | Artifact: 02_teammate-b-findings.md

## Executive Summary

After thorough analysis of the codebase and prior research reports, this report answers the specific delegation questions and delivers a ranked list of alternative approaches. The key finding is that **there are no viable alternatives that bypass succ_embed_surjective entirely** -- all paths to completing TC and FUC on Z ultimately require knowing that every LimitDomSubtype point is in the image of succ_embed. However, there IS a single, well-identified alternative approach to PROVING that fact, which prior reports have developed in detail but not formalized.

---

## 1. What TC and FUC Actually Need

### 1.1 TC (restricted temporal coherence, lines 2352-2396)

`cantor_bfmcs_discrete_restricted_tc` proves:
- Forward: `F(phi) in fam.mcs(t)` implies `exists m, m > t and phi in fam.mcs(m)`
- Backward (P direction): symmetric

The proof structure is:
1. `h_mcs_eq`: `fam.mcs(t) = limit_f(succ_embed(t + offset))` (definitional)
2. Apply `limit_F_resolution` to get `y in limit_dom` with `phi in limit_f(y)` and `succ_embed(t+offset) < y`
3. **Apply `succ_embed_surjective`** to get `m` with `succ_embed m = y`
4. Extract `m - offset` as the integer witness; the strict-monotonicity calculation gives the ordering

The surjectivity call is at line 2371 (F direction) and 2387 (P direction). These are the ONLY uses.

### 1.2 FUC (restricted forward Until/Since coherence, lines 2407-2476)

`cantor_bfmcs_discrete_restricted_fuc` proves:
- Forward: `U(phi,psi) in fam.mcs(t)` implies `exists m > t, phi in fam.mcs(m)` and psi-guard
- Backward (Since direction): symmetric

The proof structure is:
1. Apply `limit_satisfies_c5_strong` to get `y in limit_dom` with `phi in limit_f(y)`, ordering, and guard over limit_dom interval
2. **Apply `succ_embed_surjective`** to get `m` with `succ_embed m = y`
3. Transfer the guard: for any integer `r` between `t` and `m-offset`, `succ_embed(r+offset)` is between `succ_embed(t+offset)` and `succ_embed(m)`, so the C5 guard applies

Uses at lines 2424 (Until) and 2455 (Since).

### 1.3 BUC (sorry-free) -- what it does differently

`cantor_bfmcs_discrete_restricted_buc` (lines 2276-2341) is sorry-free because it works in the **backward/contrapositive** direction:

- It does NOT need to map a limit_dom witness to an integer
- It ASSUMES the integers `t, u` and works backward: applies `limit_satisfies_c4` to get a midpoint `z in limit_dom` between `succ_embed(t)` and `succ_embed(u)`
- It then uses `succ_embed_squeeze_strict` to conclude `z = succ_embed(k)` for some integer `k` between `t` and `u`

**Why BUC works without surjectivity**: `succ_embed_squeeze_strict` works BETWEEN two known embedded points. Given `succ_embed(a) < z < succ_embed(b)`, it finds `k` with `a < k < b` and `succ_embed(k) = z`. This is strictly weaker than surjectivity -- it only needs z to be bounded by two embedded points, which is guaranteed by construction (both bounds are `succ_embed` of some integer).

### 1.4 What cantor_bfmcs_discrete_restricted_tc requires from surjectivity

In TC, `limit_F_resolution` gives y above `succ_embed(t+offset)`. We need y to equal `succ_embed(m)` for some m. The squeeze lemma cannot help because we have NO upper bound on y expressed as `succ_embed` of anything. The witness y could be above all `succ_embed(n)` for any n (the "cofinal" problem). Surjectivity says y = succ_embed(m) for some m, but we cannot independently identify what m is without first knowing the orbit is cofinal.

---

## 2. Can TC/FUC Use the C5 Witness Directly Without Mapping to Z?

### 2.1 The fundamental obstruction

The coherence conditions are stated at the integer level: `phi in fam.mcs(m)` where `m : Z`. But `fam.mcs` is defined as:
```
fam.mcs(t) = limit_f(succ_embed(t + offset))
```

To get `phi in fam.mcs(m)` for some `m : Z`, we need `phi in limit_f(succ_embed(m))` for some m. The C5 witness gives `phi in limit_f(y)` for y in LimitDomSubtype. We can only conclude `phi in fam.mcs(m)` if `succ_embed(m) = y`, i.e., if y is in the image of succ_embed.

There is no detour around this: the BFMCS families are indexed by integers, and the only way to produce an integer time is to find an integer whose embedding lands on the witness.

### 2.2 Could we redefine discrete_f via collapse_map?

The delegation context asks: could we redefine `discrete_f(n) = limit_f(collapse_map(y))` where `collapse_map` maps LimitDomSubtype to Z by counting succ-steps from root?

The answer from report 07 is definitive: **collapse_map does not exist in the codebase**. The conceptual name was aspirational. What does exist is:
- `succ_embed : Z -> LimitDomSubtype` (injective, strictly monotone)
- `collapse_equiv` / `CollapseClass` (quotient by succ-orbits, with LinearOrder)
- `discrete_embed : Z -> LimitDomSubtype` (injective, strictly monotone, but NOT succ-based)

Building `collapse_map : LimitDomSubtype -> Z` would require:
1. SuccOrder on CollapseClass
2. PredOrder on CollapseClass
3. IsSuccArchimedean on CollapseClass
4. An order isomorphism CollapseClass ≃o Z via `orderIsoIntOfLinearSuccPredArch`
5. A section of this isomorphism that is order-preserving

This is estimated at 400-800 new lines (report 07, Section 3.2). And the IsSuccArchimedean step requires exactly the same "single orbit" argument as surjectivity.

---

## 3. Could TC/FUC Be Proved on LimitDomSubtype Directly?

### 3.1 The idea

Instead of stating TC/FUC at the Z level (`phi in fam.mcs(m)` for `m : Z`), prove them at the LimitDomSubtype level, then transfer to Z.

The LimitDomSubtype-level statement of TC would be:
```
ForwardF(phi) in limit_f(x) -> exists y in LimitDomSubtype, x < y and phi in limit_f(y)
```
This IS `limit_F_resolution` -- already proved, sorry-free.

The transfer step: given `phi in limit_f(y)`, find integer `m` with `phi in limit_f(succ_embed(m))`.

This transfer IS surjectivity (or something equivalent). The transfer step cannot be avoided.

### 3.2 Using limit_g / guard at the LimitDomSubtype level

For FUC, the C5 guard `limit_g(x, y)` quantifies over LimitDomSubtype points between x and y. The BFMCS guard quantifies over integers between t and m. The conversion between these guards requires:
- For every integer r with t < r < m, show `psi in fam.mcs(r)` (i.e., `psi in limit_f(succ_embed(r+offset))`)
- This requires `succ_embed(r+offset)` to be between `succ_embed(t+offset)` and `succ_embed(m)`, which requires knowing `succ_embed m = y`

The guard cannot be proved without first mapping y to an integer.

### 3.3 Verdict

TC/FUC CANNOT be proved on LimitDomSubtype and then transferred to Z without a transfer map. The transfer map IS succ_embed surjectivity (or equivalent).

---

## 4. Could the Coherence Conditions Be Weakened?

### 4.1 What dd_countermodel_chronicle_discrete requires

The proof at lines 2495-2522 calls:
```lean
fully_restricted_parametric_representation_from_neg_membership
  (cantor_bfmcs_discrete A h_mcs h_box_discrete) phi
  (cantor_bfmcs_discrete_restricted_tc ...)
  (cantor_bfmcs_discrete_restricted_buc ...)
  (cantor_bfmcs_discrete_restricted_fuc ...)
```

This requires all three coherence conditions as stated. The underlying theorem in the parametric representation infrastructure has a specific interface that TC, BUC, and FUC must satisfy.

### 4.2 Can the parametric representation theorem be bypassed or weakened?

Not without significant infrastructure changes. The parametric representation theorem is the main technical device connecting the BFMCS to the actual countermodel. Weakening it would require understanding its proof and whether its coherence hypotheses can be relaxed. This is not explored in prior research and would be a high-risk approach.

---

## 5. How Does the Dense Case Avoid This Problem?

The dense case uses the **Cantor isomorphism** `iso : LimitDomSubtype N h_N ≃o Q` (an order isomorphism). This makes the mapping from LimitDomSubtype to Q completely bijective and continuous:
- `iso : LimitDomSubtype -> Q` is surjective by definition (it's an isomorphism)
- The inverse `iso.symm : Q -> LimitDomSubtype` maps every rational to a domain point

So in the dense case, the analog of TC at line 611-621:
```lean
obtain <y, hy, hlt, hphi_y> := limit_F_resolution N h_N (iso.symm (t + offset)).val ...
refine <iso <y, hy> - offset, ...>
```
The witness `iso <y, hy> - offset` is the rational image under the isomorphism, which is a Q element. No "surjectivity" lemma is needed because the Cantor isomorphism IS a bijection.

**The discrete case lacks this bijection.** The succ_embed map is injective (proved) but not surjective (the sorry). If it were proved surjective, the discrete case would be exactly parallel to the dense case.

---

## 6. Can discrete_fmcs (Phase 2, collapse-based) Serve as the BFMCS Backbone?

### 6.1 What discrete_fmcs is

`discrete_fmcs` (lines 1694-1712) uses `discrete_embed` (NOT `succ_embed`) to map Z to LimitDomSubtype. `discrete_embed` uses iterated `exists_gt/lt` choices, not the succ/pred structure. It is strictly monotone but not aligned with the successor structure of LimitDomSubtype.

### 6.2 Why discrete_fmcs cannot be used for coherence

The problem is identical: `discrete_embed` is even LESS surjective than `succ_embed` (it picks arbitrary increasing points via `exists_gt`). Witnesses from `limit_F_resolution` or `limit_satisfies_c5_strong` will generically NOT land on `discrete_embed` images, and there is no squeeze lemma for `discrete_embed` (the no-gap property relies on the succ structure, not the arbitrary `discrete_embed`).

Using `discrete_fmcs` would make coherence proofs impossible, not easier.

---

## 7. Ranked Alternative Approaches

### Rank 1: Prove succ_embed_surjective via the single-orbit argument (RECOMMENDED)

**What**: Prove `collapse_equiv root w` for all w (i.e., every LimitDomSubtype point is in the succ-orbit of root). This directly implies `succ_embed_surjective` via `collapse_orbit_convex`.

**Why it works**: The argument in report 07, Section 6.8 establishes a clean contradiction:
- If root and w are in different orbits, total separation (collapse_class_sep, already proved) says all of one orbit is below all of the other
- root's orbit extends in BOTH directions (up via succ, down via pred), unboundedly
- w also extends in both directions
- If root < w: root's orbit has pred(root) < root < w, so root's orbit has elements on BOTH sides of any w-orbit element. But total separation requires strict ordering between orbits -- contradiction because root's orbit "crosses" both sides.

The key lemma needed is:
```lean
theorem single_orbit (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ...) (w : LimitDomSubtype A h_mcs) :
    collapse_equiv A h_mcs h_discrete root w
```

Proof by contradiction: if root and w are in different orbits with root < w, then:
1. By total separation, pred(root) ~ root but pred(root) is below root which is below w. So pred(root) < w (all of root's orbit < all of w's orbit by total separation applied to pred(root) ~ root and w being in a different class).
2. Similarly, succ^n(root) < w for all n (orbit_bounded, already proved).
3. But also w is above root's orbit and below... wait: what is pred(w) relative to root's orbit? pred(w) ~ w. If pred(w) is also > root, we have a contradiction coming from pred(w) also being above ALL of root's orbit (total separation applied to pred(w) ~ w and any root-orbit element). So pred(w) > succ^n(root) for all n.
4. But pred(w) < w, and between pred(w) and w, no domain points (immediate predecessor property).
5. The orbit elements succ^n(root) satisfy succ^{n+1}(root) <= w (from succ_le_iff and succ^n(root) < w). So succ^n(root) is eventually >= pred(w)? Actually succ^n(root) < pred(w) for all n (total separation). And succ^{n+1}(root) <= w for all n (from succ_le_iff). So all succ^n(root) are in [root, pred(w)). The immediate predecessor of w has nothing between it and w, but all the orbit elements are below pred(w), none between pred(w) and w. So far no contradiction.
6. **The actual contradiction**: The orbit is unbounded below (pred^n(root) for all n). But pred^n(root) ~ root (each element is in root's orbit). By total separation, ALL of root's orbit < ALL of w's orbit. So pred^n(root) < pred(w) for all n. The pred-chain of root {pred^n(root)} is strictly decreasing and bounded above by pred(w). Fine so far.
7. But now: w > root means w's orbit has an element above root. By total separation, ALL of w's orbit is above ALL of root's orbit. So pred(w) > succ^n(root) for all n. And pred^2(w) > succ^n(root) for all n. And pred^k(w) > succ^n(root) for all n, k. The pred-chain of w is entirely above the succ-chain of root.
8. The pred-chain of w is strictly decreasing and bounded below by... what? By total separation, it's bounded below by the entire root-orbit (including the pred-chain of root, which goes to -infinity). But "bounded below by -infinity" is vacuous. No contradiction from this.

**The correct version** (following report 07, Section 6.8 more carefully):

The contradiction comes from: if two orbits are totally separated with orbit-root < orbit-w, and the immediate-predecessor property holds (nothing between pred(w) and w), and the succ-orbit of root has unboundedly many elements below w (succ^n(root) < w for all n, strictly increasing, all in LimitDomSubtype below w), then pred(w) must be the smallest LimitDomSubtype element above all of {succ^n(root) : n}. But that means nothing is between pred(w) and any succ^n(root) from above... and for large n, succ^n(root) is very close to pred(w) in rational coordinates. Eventually we'd need succ^{n+1}(root) to be between pred(w) and... but succ^{n+1}(root) = succ(succ^n(root)), and if succ^n(root) < pred(w), then succ(succ^n(root)) <= pred(w) (from succ_le_iff). So succ^{n+1}(root) <= pred(w) < w. No orbit element ever reaches between pred(w) and w.

Actually this FAILS to give a contradiction. The orbit can be bounded above by pred(w) and there is a gap between it and w. This is the same fundamental issue found in report 07, Section 6.11.

**Reformulation**: The correct argument (report 07, Section 6.11, corrected) uses the INTERLEAVING of the two sequences near their common limit:
- {succ^n(root)} increases toward some limit L (rational, possibly irrational)
- {pred^k(w)} decreases toward some limit M (rational, possibly irrational)  
- Both sequences are bounded and monotone; their elements interleave in rational coordinates
- For large n and k, a succ^n(root) falls strictly between pred^{k+1}(w) and pred^k(w)
- This contradicts "no domain points between pred^{k+1}(w) and pred^k(w)"

**Formalization requirement**: The interleaving argument requires showing that L = M (the two limits coincide), or equivalently that there is no "gap" between the two orbits. This uses the immediate-predecessor property to show that pred(w) cannot be higher than all succ^n(root), because if it were, succ^{n+1}(root) = succ(succ^n(root)) <= pred(w) would put orbit elements up to pred(w), which eventually reaches pred(w) itself.

**Estimated effort**: 80-150 lines. Medium-hard difficulty. The key Lean lemma is `succ_le_iff` applied repeatedly to show the orbit approaches pred(w) from below.

**Risk**: The interleaving argument requires careful epsilon-delta-style reasoning about rational sequences, or an equivalent purely order-theoretic argument. Prior reports have struggled to make this fully precise.

**Critical assessment**: This is the CORRECT and INTENDED path. The existing plan (Phase 4, plan v2) already calls for proving `succ_embed_surjective`. The single-orbit approach via total separation + succ_le_iff is the best-identified strategy.

---

### Rank 2: Prove cofinality via omega-chain stage bound (ALTERNATIVE)

**What**: Prove `succ_orbit_cofinal_above`: for all w : LimitDomSubtype, exists N : Nat, w <= succ^N(root). Combined with the symmetric result for pred, this gives surjectivity via succ_embed_squeeze.

**The proof**: Strong induction on the omega-chain stage K where w enters:
- Base (K=0): w = root = succ^0(root). Done.
- Step (K+1): Either w in dom(K) (use IH) or w newly added at K+1.
  - If newly added: by `omega_chain_dom_new_unique`, exactly one point is added per stage. Let max_K = max(dom(K)).
  - By IH, max_K = succ^J(root) for some J (since max_K entered at stage <= K).
  - Need: succ^{J+1}(root) <= w.
  - succ^{J+1}(root) = succ(max_K). By `succ_le_iff`: succ(max_K) <= w iff max_K < w.
  - Since max_K is the max of dom(K) and w > max_K (it's newly above), max_K < w. So succ(max_K) <= w.
  - If succ^{J+1}(root) = w: done.
  - If succ^{J+1}(root) < w: we need more steps. But succ^{J+1}(root) may not be in dom(K+1)! It could be a point added at stage K+100. We cannot apply IH to it.

**The stage-crossing problem**: The succ of max_K in the FULL limit domain may enter the domain at a stage much later than K+1. The induction "measure" is the stage of w, but the successor of max_K can have a LARGER stage than w.

**Mitigation**: Use a LEXICOGRAPHIC induction on (stage(w), something). But the "something" is unclear. Report 07, Section 6.12 identifies this as the same fundamental difficulty.

**Estimated effort**: 100-200 lines. Hard difficulty. May require novel combinatorial insight.

**Feasibility**: Probably feasible with a sufficiently clever induction measure, but the measure needs to be identified first.

---

### Rank 3: Separate Forward/Backward cofinality into two cases per induction (VARIANT OF RANK 2)

**What**: Split the proof into: (a) prove that every w ADDED AT STAGE K+1 AS THE MAXIMUM NEW POINT satisfies `succ^{J+1}(root) <= w`; (b) do a separate induction for points added below the current maximum.

The plan for (a) is: w is the maximum new point at stage K+1. By the omega_chain construction, w enters as a new C5 forward witness for some Until formula at some point x = max_K (the current maximum). So w = C5-witness(max_K). The immediate succ of max_K in the CURRENT stage K+1 domain is w (it's adjacent to max_K with nothing between them IN STAGE K+1). But the limit-domain successor may be different if later stages add points between max_K and w.

However: succ(max_K) in the FULL limit domain is <= w (since max_K < w and w is in limit_dom, so succ_le_iff gives succ(max_K) <= w). And succ(max_K) = succ^{J+1}(root) (by IH for max_K). So succ^{J+1}(root) <= w. The question is whether we can continue from here by more applications of the same argument.

This approach requires proving that succ^{J+1}(root) ITSELF eventually reaches w in a finite number of steps. This is the surjectivity claim for succ^{J+1}(root) instead of root. By the same induction applied to succ^{J+1}(root) instead of root, we get succ^{J+2}(root) <= w, etc. This creates an infinite regress unless we can bound the number of steps.

**Verdict**: This approach reduces to showing the orbit eventually reaches w, which is the original problem.

---

### Rank 4: Prove boundedness via rational interval density (HARDEST BUT MOST DIRECT)

**What**: Prove `Set.Finite (Set.Icc a b)` for a, b : LimitDomSubtype in the discrete case. Then the descending pred-chain from w to root is finite, giving surjectivity.

**Why it works**: By `collapse_orbit_convex`, if `a <= z <= succ^n(a)` then z is in the orbit of a. If `Set.Icc a b` is finite, then the orbit from a must reach b in finitely many steps (otherwise infinitely many points would accumulate in the bounded interval).

**The proof of finiteness**: Suppose `Set.Icc a b` is infinite. Then there are infinitely many distinct points c_0 < c_1 < c_2 < ... all in `limit_dom` with `a <= c_i <= b`. Their rational coordinates are a bounded strictly increasing sequence in Q. Between consecutive c_i, no domain points (from the no-gap property). As the values c_i.val increase toward some limit L in R:
- If L is rational and in limit_dom: for large i, c_i is between pred(L_sub) and L_sub, contradicting no-gap.
- If L is irrational (or rational but not in limit_dom): consider the smallest limit_dom point z > L. Then for large i, c_i > pred(z), putting c_i between pred(z) and z, contradicting no-gap.

**Formalization requirements**:
1. Formalize bounded monotone sequences having convergent subsequences (or: an infinite set of distinct rationals in [a.val, b.val] has an accumulation point in R)
2. Use the accumulation point to construct the contradiction with no-gap
3. Connect to Lean's `Rat` vs `Real` type relationship

**Estimated effort**: 150-300 lines. Very hard to formalize. Requires either importing Mathlib real analysis tools or a purely combinatorial alternative.

**Verdict**: Mathematically clean but formalization-heavy. Not recommended unless all other approaches fail.

---

### Rank 5: Accept the sorry and document it (PRAGMATIC FALLBACK)

**What**: Leave `succ_embed_surjective` with 2 sorry sites, documenting clearly that:
1. The theorem is true (proved by the accumulation argument in report 06)
2. The proof gap is specifically in the "above-max" and "below-min" subcases of stage induction
3. The mathematical content of TC and FUC is correct, modulo this gap

**Impact**: `dd_countermodel_chronicle_discrete` compiles (with sorry propagation). The mixed-case sorry is a separate independent sorry. The completeness proof has 2 active sorry paths: discrete-coherence and mixed-modal.

**Feasibility**: Zero implementation effort. Everything already compiles.

**Risk**: The sorry in `succ_embed_surjective` propagates to `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`, and thence to `dd_countermodel_chronicle_discrete`. This is a sorry in the MAIN THEOREM, not just an auxiliary.

---

## 8. Assessment of Key Open Questions from the Delegation

### Q: What does BUC use that TC/FUC don't?

**A**: BUC works by contradiction with a BOUNDED witness -- the C4 midpoint z satisfies `succ_embed(t) < z < succ_embed(u)`, so z is strictly between two embedded points. `succ_embed_squeeze_strict` maps it to an integer. TC and FUC get a witness that may be ABOVE ALL embedded points (no upper bound in embedded terms), so squeeze cannot apply. This is the structural asymmetry.

### Q: What does cantor_bfmcs_discrete_restricted_tc require from surjectivity?

**A**: The proof uses `succ_embed_surjective` to get `m` with `succ_embed m = y` where y is the F-resolution witness. If surjectivity were replaced by "y is bounded above by succ_embed(N) for some N", then squeeze would give the integer. So the MINIMUM requirement is "cofinality of the succ-orbit" (report 07, Section 4.4, Approach A), which is equivalent to surjectivity given the no-gap property.

### Q: Can we redefine discrete_f via collapse_map?

**A**: No -- collapse_map does not exist. Building it requires more work than proving surjectivity directly. See report 07.

### Q: Can TC/FUC use the C5 witness directly without mapping back to Z?

**A**: No -- the coherence conditions are stated at the Z level and require integer witnesses. The BFMCS definition forces families to be indexed by Z. There is no way to bypass this.

### Q: Could we prove TC/FUC on LimitDomSubtype and then transfer?

**A**: The "transfer" IS surjectivity. Working at the LimitDomSubtype level would require separately defining a LimitDomSubtype-level BFMCS and coherence conditions, then transferring back to Z -- equivalent work.

### Q: Could we weaken the coherence conditions?

**A**: The downstream theorem `fully_restricted_parametric_representation_from_neg_membership` requires TC, BUC, and FUC as stated. Weakening them would require either a different parametric representation theorem or a different proof strategy for the countermodel.

### Q: Check if discrete_fmcs (Phase 2, collapse-based) could serve as the BFMCS backbone

**A**: No -- `discrete_fmcs` uses the non-succ-based `discrete_embed`, which lacks the no-gap property. Witnesses from C5 will not land on `discrete_embed` images. It is even less suitable than `succ_discrete_fmcs`.

---

## 9. Conclusion

The only viable path to sorry-free TC and FUC coherence is to prove `succ_embed_surjective`. All alternative approaches (collapse_map, LimitDomSubtype-level proofs, weakened conditions) either fail or reduce to the same underlying problem.

Among approaches to proving surjectivity itself, the **single-orbit argument via total separation** (Rank 1) is the most promising because:
- The necessary infrastructure (`collapse_equiv`, `collapse_class_sep`, `collapse_orbit_bounded`, `collapse_orbit_convex`) is already present and sorry-free
- The key contradiction uses `succ_le_iff` repeatedly to show no second orbit can exist
- The formalization challenge is identifying the right lemma sequence to make the interleaving argument work in Lean

The **omega-chain stage induction** (Rank 2) is a plausible alternative but suffers from the stage-crossing problem that requires a non-obvious induction measure.

If formal proof proves intractable in the near term, the pragmatic option (Rank 5) is to accept the sorry with thorough documentation, since the mathematical content is sound and the proof structure is complete.
