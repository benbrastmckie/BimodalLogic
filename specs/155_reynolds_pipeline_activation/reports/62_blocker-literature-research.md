# Blocker Literature Research: Task 155

**Task**: reynolds_pipeline_activation
**Date**: 2026-06-02
**Focus**: Deep literature alignment for the two blockers preventing sorry-free `completeness_discrete`

---

## 1. Current State (from handoffs)

### Sorry Chain (confirmed)

```
completeness_discrete  (Completeness.lean:309)
  -> countermodel_discrete_reynolds  (Transfer.lean:1203)
    -> cantor_bfmcs_discrete_restricted_tc  (ChronicleToCountermodel.lean:1992)
    -> cantor_bfmcs_discrete_restricted_fuc  (ChronicleToCountermodel.lean:2048)
      -> succ_embed_surjective  (ChronicleToCountermodel.lean:1666)
        -> limitDomSubtype_isSuccArchimedean  (ChronicleToCountermodel.lean:789)
          -> succ_cofinal  (ChronicleToCountermodel.lean:773)
            -> chronicle_gap_contradiction  (ChronicleToCountermodel.lean:486) [SORRY]
```

**Critical finding**: There is only ONE sorry chain, not two. The Stavi/EF game sorry chain (nf_2var_existential_transfer in StaviCompleteness.lean:2347,2429) does NOT flow into `completeness_discrete`. The Stavi sorries affect `stavi_expressive_completeness` which flows through PriorExpressiveness -> GoodStructuresModelSurgery -> ReynoldsModelSurgery, but `countermodel_discrete_reynolds` does NOT depend on any of those. It uses the parametric canonical model construction directly.

This contradicts the Phase 1 handoff claim that "both sorry chains trace to the same root." The Phase 1 handoff incorrectly identified Chain 1 as blocking completeness_discrete. In reality:

- **Chain 1 (Stavi EF game)**: Blocks `stavi_expressive_completeness` and the general model surgery pipeline. Does NOT block `completeness_discrete`.
- **Chain 2 (chronicle gap)**: The ONLY chain blocking `completeness_discrete`, flowing through `chronicle_gap_contradiction`.

### What Previous Work Established

- **Phase 1** (completed): Import cycle resolved. `gap_contradicts_prior`, `no_boundary_at_successor`, `contemp_equiv_is_equiv` are accessible from ChronicleToCountermodel.
- **Phase 3** status: BLOCKED on `nf_2var_existential_transfer` (interval splitting problem). Five failed sessions documented. This is real but NOT on the critical path for `completeness_discrete`.
- **Phase 4** status: IN PROGRESS. The old proof of `chronicle_gap_contradiction` (lines 488-762, commented out) is nearly complete for Case A. Case B (constant MCS) identified as genuinely hard.

### GoodStructuresModelSurgery.lean Sorry Status

Despite earlier claims that GoodStructuresModelSurgery carries sorryAx, grep reveals **zero sorry proof terms** in the file. The file is source-sorry-free. The comments mentioning "sorry sites" refer to `gap_prior_UZ_contradiction` and `gap_prior_SZ_contradiction` which are defined there as requiring semantic_prior_UZ/SZ as hypotheses (satisfied by the caller), not sorry.

---

## 2. Literature Analysis

### 2.1 Reynolds 1994 — Theorem 15 (pp.129-131)

**Statement**: If M is a temporal structure in a finite language with countable, discrete, endpoint-free flow of time, and all instances of Prior-UZ and Prior-SZ are valid in M, then for all k there exists a Z-structure satisfying the same monadic FO sentences of quantifier depth at most k.

**Proof structure** (Section 8, pp.129-131):

1. **Define "good"**: M is good iff there exists N with Z-interval flow such that N equiv_k M. M is "very good" iff every subinterval M|[t,u] is good.

2. **Lemma 16** (very good => good): If N is countable and very good, it is good. Proof by decomposing into subintervals, finding Z-intervals for each, and composing via lexicographic sums preserving equiv_k.

3. **Define contemporaneous equivalence ~_M**: a ~_M b iff M|[a,b] (or M|[b,a]) is very good. This is definable by a temporal formula.

4. **Lemma 17**: ~_M is a contemporaneous equivalence relation.

5. **Theorem 14** (Section 7, p.129): In a Prior structure, the ~-classes do not end at gaps. This is the model surgery core result.

6. **The contradiction** (p.131, lines 964-973 of the extract): If M is not good, it's not very good, so there exist disjoint ~-classes. The first class can't end at a gap (by Theorem 14). So it must end at a successor boundary c/c+1. But M|[c,c+1] is finite, hence trivially very good, so the class extends across c+1. Contradiction.

**Key insight for Blocker 2**: The argument at step 6 is exactly what `chronicle_gap_contradiction` needs to prove. Reynolds' argument uses:
- Theorem 14 (classes don't end at gaps) = `gap_contradicts_prior` in the Lean code
- Finiteness of M|[c,c+1] => very good => class extends past c+1 = `no_boundary_at_successor`
- The **contradiction structure** is: if succ-iterates are bounded, the equivalence class of a has a supremum point; this supremum is either a gap (contradicts Theorem 14) or a successor boundary (contradicts no_boundary_at_successor).

**Crucially**: Reynolds' argument does NOT separately handle a "constant MCS" case. The argument works uniformly because `~_M` is defined by "very good" (EF-game equivalence), not by MCS membership. The current Lean formalization's attempt to use MCS equality as the equivalence relation is a deviation from the literature that creates the constant-MCS problem.

### 2.2 Reynolds 1994 — The Contemporaneous Equivalence (pp.130-131)

Reynolds defines ~_M as: a ~_M b iff M|[min(a,b), max(a,b)] is very good (k-equivalent to some Z-interval at every subinterval). This is fundamentally different from the Lean code's `contemp_equiv sig k M a b` which is based on `very_good sig k (M.subinterval sig (min a b) (max a b))`.

**The Lean definition matches Reynolds** at the structural level. The problem is that the old proof in ChronicleToCountermodel.lean (lines 488-762) tries to construct a single-predicate OrderedMonadicStructure and use MCS-based distinguishing, rather than using the full multi-predicate structure at the appropriate depth k. Let me trace this more carefully.

The old proof's approach (Case A):
1. Find psi distinguishing limit_f(a.val) from limit_f(b.val)
2. Build single-predicate structure M with interp = psi membership
3. Prove semantic_prior_UZ/SZ on M (successfully done, lines 570-703)
4. Prove a and b are NOT contemp_equiv at some depth k (STUCK at k=0; analysis in handoff shows k=0 trivially holds)
5. Apply gap_contradicts_prior

The problem: at k=0, contemp_equiv is trivially true. The handoff's analysis (lines 80-122 of phase-3-4-handoff) shows that even at higher k, contemp_equiv might hold because Z-intervals CAN have mixed predicate values.

**Resolution from Reynolds**: Reynolds does NOT use contemp_equiv at depth 0 or depth 1 with a single predicate. Reynolds uses the full signature with ALL relevant predicates (or equivalently, uses the contemporaneity at depth k large enough to encode all relevant formula distinctions). The key is:

- Use contemp_equiv at depth k >= depth(psi_distinguishing) with the full signature
- At sufficient depth, the depth-k NF of a includes psi membership, so if a and b have different psi values AND the depth is high enough, the subinterval [a,b] is NOT k-equivalent to any Z-interval where psi is constant... but wait, Z-intervals can also have mixed values.

Actually, re-reading Reynolds more carefully: the key is that the contemporaneous equivalence is defined in terms of the FULL language. With a single predicate, a ~_M b iff M|[a,b] is very good at depth k in the single-predicate language. At k >= 1, the depth-1 NF includes which predicate values exist in every subinterval. A Z-interval of the integers with a single predicate CAN have arbitrary predicate assignments. So even at depth 1, M|[a,b] might be good because SOME Z-interval matches its depth-1 NF.

**The real insight**: Reynolds' argument does NOT need to show a and b are in different equivalence classes based on predicate disagreement. The argument is:

1. Define ~_M using the full depth-k language
2. Show ~_M has finitely many classes (because there are finitely many k-types)
3. Show ~_M classes don't end at gaps (Theorem 14 / gap_contradicts_prior)
4. Show ~_M classes extend past successor boundaries (no_boundary_at_successor / very_good is transitive across successor)
5. Therefore if the domain is countable and endpoint-free, there is only ONE ~_M class
6. One class means very good, means good (Lemma 16), means done

**The argument at step 5-6 is what matters for chronicle_gap_contradiction**. The proof doesn't need "a and b are in different classes." It needs "if succ-iterates are bounded, we get a contradiction." The contradiction comes from:

- Succ-orbit of a is bounded above by b
- The succ-orbit generates a ~_M class C containing a
- C is succ-closed (by no_boundary_at_successor: if c in C, then c+1 in C)
- C is bounded above by b (because b not in C, OR by the orbit bound)
- If C doesn't contain b, then C ends somewhere between a and b
- C can't end at a gap (Theorem 14)
- C can't end at a successor boundary (transitivity of very_good across successor)
- Contradiction

BUT: can C contain b? If all points in [a,b] are in one ~_M class, then the succ-orbit covers a to b and we're done (succ_cofinal holds). So the bounded orbit + C containing b is actually the case we WANT (it means succ reaches b).

Wait, the issue is subtler. The orbit {a, succ(a), succ^2(a), ...} is bounded above by b. If all points are ~_M equivalent (one class), then succ_cofinal should hold because the succ-orbit covers the domain... but does it? The orbit might converge to a limit point L < b without reaching b.

This is the key: in a discrete order, the orbit {succ^n(a)} is strictly increasing, so if bounded above by b, it converges to sup{succ^n(a)}. Call this L. Then:
- L is in the limit domain (it's the sup of a sequence)
- L != b (because the orbit is strictly bounded below b)
- L < b
- succ(L) > L (because succ is strictly increasing)
- If succ(L) <= b, then the orbit continues past L, contradicting L being the supremum. Unless succ(L) > sup{succ^n(a)}, which would mean L is NOT in the orbit.

Actually, the supremum L might not be in the limit domain at all. In a linear order, the supremum of {succ^n(a)} might be a gap (not a point). But in the chronicle limit domain construction, the domain is a subset of Q, so every point is either in the domain or is a gap of the domain.

**Reynolds' argument handles this**: if L is a gap, then the ~_M class of a ends at a gap, contradicting Theorem 14. If L is a point in the domain, then L is not in the orbit (since L = sup and the orbit is strictly below L), but L must be in the same ~_M class as the orbit members (since [succ^n(a), succ^{n+1}(a)] is very good and the class extends by transitivity). Then succ(L) is also in the same class, and succ(L) > L contradicts L being the supremum.

This is precisely the model surgery argument. And it works REGARDLESS of whether a and b have the same MCS (constant or not).

### 2.3 GHR93 — Proposition 7 and Lemma 11 (pp.113-115)

**Proposition 7**: Strategy composition for the EF game on temporal structures. Given n+1 matched base points with winning strategies for all adjacent sub-interval pairs, compose to get a winning strategy for the n-round game on the whole structure.

**Key mechanism**: When Spoiler places a new point alpha in some interval (x_i, x_{i+1}), Duplicator:
1. Lists the decomposition formulas true at (x_i, alpha) and (alpha, x_{i+1})
2. Uses the forward strategy for (x_i, x_{i+1}) -> (y_i, y_{i+1}) to find a matching point e
3. Crucially applies **Theorem 6** to convert forward strategies to backward strategies
4. Applies IH with the augmented base point set

**Theorem 6** (pp.115-119): The "forward-to-backward" theorem. If Duplicator has a winning strategy for G_{1+3n;r+4n}(M,xy; N,x'y'), then she has one for G_{n;r}(N,x'y'; M,xy). Proved by induction on n with four cases based on gap structure.

**Case II** (pp.117-118): When alpha_n is not a gap. Key construction:
- B = X_{alpha_n} (full rank-r type formula)
- Duplicator response e_n = witness to U(B,A) transfer through the backward strategy tau
- NOT from the forward game

**Relevance to Blocker 1**: The EF game bridge for `nf_2var_existential_transfer` would formalize this composition. However, since Chain 1 is NOT on the critical path for `completeness_discrete`, this bridge is deferred.

### 2.4 Libkin 2004 — Composition Lemma (Ch.3, Lemma 3.7)

**Lemma 3.7**: If L_1^{<=a} equiv_k L_2^{<=b} and L_1^{>=a} equiv_k L_2^{>=b}, then (L_1,a) equiv_{k-1} (L_2,b).

**This is the core composition principle** that `ghr93_strategy_compose` (Composition.lean, sorry-free) formalizes for the temporal setting with extended carriers and gap handling.

**For Blocker 1**: Lemma 3.7 / Proposition 7 provide the theoretical foundation for the EF game bridge. The existing sorry-free infrastructure in Composition.lean and Decomposition.lean already formalizes this.

### 2.5 Thomas 1997 — Composition for Ordinal Words

Thomas provides the general framework: composition on linear temporal structures reduces game arguments on complex structures to game arguments on sub-intervals, with types as the composition interface. The finite number of rank-k types (Libkin Theorem 3.15) ensures the composition table is finite.

**For Blocker 2**: The key insight is that "very good" (every subinterval equivalent to a Z-interval) is the right definition for contemporaneous equivalence in the integer-time setting. This aligns with Reynolds' ~_M definition.

---

## 3. Blocker 2 Resolution: chronicle_gap_contradiction

### 3.1 The Correct Proof Strategy (from Reynolds 1994, Section 8)

The old proof attempt in ChronicleToCountermodel.lean (lines 488-762) goes wrong by trying to build a single-predicate structure and distinguish a and b via MCS membership. This creates the unsolvable constant-MCS case.

**Reynolds' actual argument** (Theorem 15 proof, p.131) does not need to distinguish a and b. It needs only:

1. **The succ-orbit is bounded** => there exists a supremum L of {succ^n(a) : n in N}
2. **L is not a gap** (if it were, the contemporaneity class of a ends at a gap, contradicting Theorem 14 / gap_contradicts_prior)
3. **L is in the contemporaneity class of a** (because each [succ^n(a), succ^{n+1}(a)] is very good, and very_good is transitive)
4. **succ(L) is also in the class** (by no_boundary_at_successor)
5. **succ(L) > L** (by strictness of succ)
6. **succ(L) > succ^n(a) for all n** (because L >= succ^n(a) for all n, and succ is strictly monotone)
7. **Contradiction**: succ(L) should be an upper bound that is larger than all orbit elements, but succ(L) is in the orbit's class, so the orbit extends past L, contradicting L being the supremum.

Wait, step 7 needs refinement. L = sup{succ^n(a)}. succ(L) > L. succ(L) is in the domain. But succ(L) > succ^n(a) for all n doesn't immediately give succ(L) >= b. We need: succ(L) > L and the orbit {succ^n(a)} converges to L, so succ(L) > L is a point ABOVE L, meaning succ(L) > succ^n(a) for all n, but the orbit is {a, succ(a), ...} and the bound is b. If succ(L) <= b, then we can continue the orbit past L, contradicting L being the supremum.

Actually, the contradiction is simpler:
- L = sup{succ^n(a)} means: for all n, succ^n(a) <= L, and L is the least such upper bound
- succ(L) > L (strict successor in discrete order)
- succ(L) is in the succ-orbit's class, so the orbit extends to succ(L)
- But succ(L) > L means succ(L) is NOT bounded by L
- The orbit contains succ(L), so L was not the supremum of the orbit. Contradiction.

No wait, succ(L) being in the CLASS doesn't mean it's in the ORBIT. The orbit is specifically {succ^n(a) : n in N}. The class is the set of points contemporaneously equivalent to a.

Let me re-read the Lean code's approach more carefully. The theorem `chronicle_gap_contradiction` states: if succ^n(a) < b for all n, derive False. The proof strategy should be:

1. The sequence {succ^n(a)} is strictly increasing and bounded above by b
2. Let L = sup{succ^n(a)} in the limit domain ordering
3. There are two sub-cases:
   a. L is not in the limit domain (L is a gap in the domain): contradicts the model surgery result (Theorem 14 / gap_contradicts_prior)
   b. L is in the limit domain: then succ(L) is also in the domain, succ(L) > L, so succ(L) > succ^n(a) for all n, but also succ(L) <= b (since all orbit elements are < b and succ(L) is the successor of the supremum). Then we have a NEW orbit element succ(L)... but succ(L) is NOT succ^n(a) for any n. The orbit is {succ^n(a)}, not the succ-closure of {a}.

**Ah, this is the key confusion**. The orbit {succ^n(a) : n in N} might not contain L or succ(L). The gap_contradicts_prior theorem works with the contemporaneity class, not the orbit. The class of a is defined as {c : contemp_equiv sig k M a c} and is closed under successor (by no_boundary_at_successor). If the class is bounded above, it ends at either a gap (contradicted by gap_contradicts_prior) or doesn't exist (the class is unbounded).

So the CORRECT proof is:

1. Define M as a suitable OrderedMonadicStructure on LimitDomSubtype
2. Prove semantic_prior_UZ/SZ on M (already done in old proof, lines 570-703)
3. The contemp_equiv class of a (at some appropriate depth k and signature sig) is:
   - Succ-closed (by no_boundary_at_successor)
   - Therefore it contains all succ^n(a)
4. If the class is bounded above (say by some point c > succ^n(a) for all n):
   - The class ends below c
   - gap_contradicts_prior says this ending can't be at a gap
   - But in a discrete linear order with no endpoints, the only way a succ-closed set can be bounded is if it ends at a gap (since every point has a successor, and no_boundary_at_successor ensures the class extends past every successor boundary)
5. Since the class is unbounded above, there exists some n with succ^n(a) >= b (or succ^n(a) is arbitrarily large). But we need succ^n(a) >= b specifically.

Actually, this still doesn't immediately give succ^n(a) >= b. The class of a might be unbounded but the ORBIT might be bounded. The class includes points reachable from a by successor, but it also includes points that are equiv to a without being succ-iterates.

**Wait, no.** `no_boundary_at_successor` says: if c is in a's class, then succ(c) is in a's class. Starting from a:
- a is in a's class (reflexivity)
- succ(a) is in a's class
- succ^2(a) is in a's class
- ...
- succ^n(a) is in a's class for all n

So the orbit IS contained in the class. If the orbit is bounded by b, and the class extends past b (because gap_contradicts_prior says it can't end before b at a gap, and no_boundary_at_successor says it can't end at a successor boundary), then b is also in the class, meaning... well, the class contains b, but that doesn't prove succ^n(a) >= b.

**The missing step**: We need that if the class of a contains b, then succ^n(a) >= b for some n. This is NOT immediate from the class containing b. The class is the set of ALL points contemporaneously equivalent to a, which could include points not reachable by successor from a.

**This is exactly the "IsSuccArchimedean" question**: does the succ-orbit cover the entire class?

### 3.2 The Real Argument from Reynolds

Re-reading Reynolds (p.131) more carefully:

> "Now a's class can not end at a gap on the right (by theorem 5 and the fact that Prior-UZ and dual imply Prior-U and dual) so it must include a point c but not the successor c + 1 of c. This can not be because M | c, c + 1, like all finite structures is very good and ~ is transitive."

Reynolds' argument is that if the class of a is bounded above and does NOT include all successors up to b, then:
- The class must end at some point c where c is in the class but c+1 is not
- But M|[c,c+1] is a finite structure, hence very good
- Since c is in a's class (a ~ c, so M|[a,c] very good), and M|[c,c+1] is very good, by transitivity of very_good, M|[a,c+1] is very good, so a ~ c+1
- Contradiction: c+1 is in a's class after all

**This is `no_boundary_at_successor`** in the Lean code. So the argument is:
1. The class of a is succ-closed (no boundary at successor)
2. Therefore it contains all succ^n(a)
3. If the class does NOT contain b, then the class is bounded above (by b)
4. gap_contradicts_prior says the class can't end at a gap
5. The class must therefore contain everything (if it's succ-closed and can't end at a gap in a discrete endpoint-free order, it's all of the domain)
6. Contradiction with not containing b

Step 5 is the crux: why does succ-closed + no gap endings => the class covers everything?

In a discrete endpoint-free linear order:
- The class is succ-closed (for every c in the class, c+1 is in the class)
- The class is pred-closed (by the symmetric argument with gap_contradicts_prior_below)
- So the class is a convex succ-and-pred-closed subset
- In a discrete linear order without endpoints, a convex pred-and-succ-closed subset is either empty or everything
- Therefore the class is the entire domain

**Ah, but that's exactly IsSuccArchimedean for the domain!** And proving that the domain is "one Z-chain" (pred-and-succ-closed convex subset = everything) is exactly what we need.

The key insight is: **we need both directions** (succ-closed AND pred-closed). `gap_contradicts_prior` gives succ-closure + no right-gap endings. `gap_contradicts_prior_below` gives pred-closure + no left-gap endings. Together with discreteness and no endpoints, the class is the entire domain.

### 3.3 Concrete Implementation Path

The proof of `chronicle_gap_contradiction` should proceed as follows:

**Step 1**: Build an OrderedMonadicStructure on LimitDomSubtype with enough predicates to distinguish all relevant formula types. This is already mostly done in the old proof (lines 514-534 for the single-predicate case). The key change: use the full signature or at least enough predicates. However, a single predicate suffices IF we use it at sufficient depth.

Actually, let me reconsider. The argument doesn't need a and b to be in different classes at all. The argument is:

1. Assume succ^n(a) < b for all n (the orbit is bounded by b)
2. Build M on LimitDomSubtype (any MonadicSignature works)
3. Prove semantic_prior_UZ/SZ on M
4. Show that the contemp_equiv class of a is succ-closed (via no_boundary_at_successor)
5. Show that b is NOT in a's class (this is what requires the distinguishing formula)
6. Apply gap_contradicts_prior: succ-closed class, bounded above by b which is not in the class => the class ends at a gap => contradiction

Wait, but step 5 fails in the constant-MCS case. If a and b have the same MCS (limit_f(a.val) = limit_f(b.val)), then with a single predicate based on ANY formula psi, either both a and b have psi or neither does. So the single-predicate structure assigns the same predicate to a and b, and contemp_equiv might hold.

**But Reynolds' argument doesn't use a single predicate!** Reynolds uses the full depth-k language. At sufficient depth k, the NF of [a,b] encodes the subinterval type of every sub-interval within [a,b]. If [a,b] is NOT very good (not k-equivalent to a Z-interval), then a and b are NOT contemporaneously equivalent.

So the question reduces to: is [a,b] very good?

If the succ-orbit is bounded and doesn't reach b, then there must be a "convergence point" L = sup{succ^n(a)} with L < b. The interval [L, b] contains no succ-iterates of a (since L is the supremum). In the chronicle construction, the limit domain is built from an omega-chain of finite models, and every point enters at some stage. The density of points in [L, b] is determined by the chronicle construction.

**The real question**: is the limit domain on LimitDomSubtype isomorphic to Z (a single succ-orbit), or can it have multiple Z-chains?

In the discrete case (every point has an immediate successor and predecessor), the domain decomposes into Z-chains. IsSuccArchimedean is equivalent to there being exactly one Z-chain.

**Reynolds' Theorem 15 proves this**: the very_good-based contemporaneous equivalence classes cover everything (no boundaries at gaps or successors), so there's one class, meaning the domain IS a single Z-chain. But the proof uses the model surgery result (Theorem 14 / gap_contradicts_prior) which requires semantic_prior_UZ/SZ.

### 3.4 Reformulated Proof Strategy

The correct proof of `chronicle_gap_contradiction` should follow Reynolds Theorem 15 more closely:

1. **Build multi-predicate M** on LimitDomSubtype with signature having enough predicates to encode all subformulas relevant at depth k. The existing `effectiveFormula` approach in the old proof (lines 543-548) is a start but uses only one predicate. Instead, use the full deferralClosure of the formulas appearing in the MCS.

2. **Prove semantic_prior_UZ/SZ** (already done in old proof, lines 636-703, can be adapted).

3. **Apply the one_class argument**: 
   - `gap_contradicts_prior` (sorry-free, GoodStructuresModelSurgery.lean) shows the contemp_equiv class of a is succ-closed and unbounded to the right
   - `gap_contradicts_prior_below` (sorry-free) shows the class is pred-closed and unbounded to the left
   - In a discrete domain, succ-and-pred-closed + unbounded both ways = everything
   - Therefore one class, therefore very good, therefore succ-iterates reach everything

4. **BUT**: step 3 requires showing that b is NOT in a's class (to get a bounded above class for gap_contradicts_prior). If b IS in a's class, that means [a,b] is very good, which means there's a Z-interval matching, which means succ-iterates do reach b. So either way, we're done.

**Wait, let me be more precise.** The actual proof should be:

Proof of chronicle_gap_contradiction:
- Assume h_orbit_bounded: forall n, succ^n(a) < b
- Build M, prove prior_UZ/SZ
- By gap_contradicts_prior + gap_contradicts_prior_below: the class of a is both succ-closed and pred-closed and has no gap boundaries
- In the discrete limit domain (countable, no endpoints), a succ-and-pred-closed convex subset with no gap boundaries is the entire domain
- Therefore b is in a's class
- Therefore [a,b] is very good (k-equivalent to some Z-interval)
- Therefore the subinterval [a,b] is k-equivalent to Z|[i,j] for some i,j
- In Z|[i,j], succ^{j-i}(i) = j, so the succ-orbit covers the interval
- By k-equivalence, the succ-orbit in the limit domain also covers [a,b]
- Therefore there exists n with succ^n(a) >= b, contradicting h_orbit_bounded

Actually, step "by k-equivalence, the succ-orbit covers" doesn't follow directly. k-equivalence is about formula truth, not about the successor function.

Let me simplify. The key is that gap_contradicts_prior gives: the contemp_equiv class of a has no upper bound (if it had one, there would be a gap, contradicting Prior-UZ). Since the class is a subset of the limit domain which contains b, and the class has no upper bound, it contains elements >= b. But the class contains succ^n(a) for all n (by succ-closure). 

Hmm, the class containing elements >= b does NOT mean succ^n(a) >= b. The class might contain elements > b that are NOT succ-iterates of a.

**I think the correct argument is fundamentally about one_class implying IsSuccArchimedean**, not about succ_cofinal directly. Let me look at what exists.

### 3.5 The one_class Approach

The ShiftAndGlue.lean infrastructure already has:
- `one_class_implies_very_good` (sorry-free)
- `chronicle_is_good_direct` (ShiftAndGlue.lean, sorry-free per team report 61)

If we can show `one_class` for the limit domain model, then very_good follows, and the Reynolds pipeline handles the rest.

**But the team research report (61_team-research.md) warns**: the restricted coherence conditions require concrete integer witnesses via `succ_embed_surjective`, not abstract k-equivalence from `chronicle_is_good_direct`. This is the "type mismatch" concern.

However, re-reading the code: `succ_embed_surjective` is what USES IsSuccArchimedean. If we can prove chronicle_gap_contradiction (and hence succ_cofinal and IsSuccArchimedean), then succ_embed_surjective becomes sorry-free, and the restricted coherence conditions follow.

**The circular dependency concern is a red herring**: chronicle_gap_contradiction does NOT depend on succ_embed_surjective. The dependency is:
```
chronicle_gap_contradiction [sorry] 
  -> succ_cofinal 
  -> limitDomSubtype_isSuccArchimedean
  -> succ_embed_surjective
  -> cantor_bfmcs_discrete_restricted_tc/fuc
  -> countermodel_discrete_reynolds
  -> completeness_discrete
```

So proving chronicle_gap_contradiction removes the sorry from the entire chain.

### 3.6 What the Proof Actually Needs

Reading the theorem signature again:

```lean
private theorem chronicle_gap_contradiction (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b)
    (h_orbit_bounded : ∀ n : ℕ, (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a < b) :
    False
```

We need: from bounded succ-orbit, derive False.

**Proof outline (following Reynolds Theorem 15)**:

1. Build M : OrderedMonadicStructure sig on LimitDomSubtype
   - sig has at least one predicate
   - interp maps the predicate to membership in some formula psi of limit_f

2. Prove semantic_prior_UZ and semantic_prior_SZ on M
   (Already done in old proof template, lines 636-703)

3. Apply `gap_contradicts_prior sig k M atomMap h_surj h_prior_UZ h_prior_SZ`:
   - Needs: a's class is succ-closed (given by no_boundary_at_successor)
   - Needs: a's class is bounded above by some c > a with c NOT in a's class

   For step 3, we need SOME c > a NOT in a's class. If ALL c > a are in a's class, then in particular b is in a's class, meaning contemp_equiv sig k M a b holds.

4. **Case split**:
   a. If there exists c > a with c NOT in a's contemp_equiv class:
      - Apply gap_contradicts_prior. Get contradiction.
   b. If ALL c > a are in a's class (one_class above a):
      - Similarly for below a (gap_contradicts_prior_below)
      - One class means the entire domain is one contemp_equiv class
      - one_class_implies_very_good gives: M is very good
      - very_good at depth k means: for ALL subintervals, the subinterval is k-equivalent to a Z-interval
      - In particular, [a, b] is k-equivalent to some Z-interval Z|[i,j]
      - In Z|[i,j], j - i = length of the interval, and succ^{j-i}(i) = j
      - k-equivalence at sufficient depth preserves the number of elements in the interval (for finite intervals) -- NO! k-equivalence does NOT preserve cardinality in general.

**Hmm.** Case 4b is problematic. k-equivalence doesn't give us succ-reachability. We need a different approach for case 4b.

Actually, in case 4b (one class, the whole domain), the domain itself is a single Z-chain (because it's discrete with no endpoints and a single equivalence class). A single Z-chain with the successor function IS IsSuccArchimedean. But proving this requires knowing that the domain is order-isomorphic to Z, which requires Lemma 16 (very_good countable => good) and the Z-structure.

**Alternative for case 4b**: If the entire domain is one contemp_equiv class, then the domain is very good. By the formalization of Lemma 16 (which should be in ShiftAndGlue.lean), the domain is good (k-equivalent to a Z-structure). But we need more: we need that succ on the domain corresponds to succ on Z (or at least that succ-iterates are cofinal).

Actually, the simple argument is: in case 4b, the contemp_equiv class of a contains b. The class is exactly the set {c : contemp_equiv sig k M a c}. This class is succ-closed. Since b is in the class, we need to show succ^n(a) >= b for some n.

But... the class being succ-closed and containing both a and b does NOT mean succ^n(a) >= b. The class could contain points between a and b that are not succ-iterates of a. For example, if the domain is Z + Z (two copies of Z), and a is in the first copy while b is in the second copy, then the succ-orbit of a stays in the first copy forever and never reaches b. But both a and b could be in the same contemp_equiv class if the two Z-copies are k-equivalent.

Wait, but this is the discrete case with `next_top` in every MCS. The successor function on LimitDomSubtype is the chronicle successor, not the Z-successor. If the domain decomposes into multiple Z-chains, the chronicle successor maps within each chain. So succ^n(a) stays in a's Z-chain.

**This IS the constant-MCS problem (Case B)**. In the constant-MCS case, the domain might genuinely decompose into multiple Z-chains, all with the same k-type, all in one contemp_equiv class. The succ-orbit stays in one chain but never reaches the other.

### 3.7 The Resolution: Reynolds' Argument IS About the Full Structure

Re-reading Reynolds one more time. Reynolds works with M being the GIVEN temporal structure (the limit domain model), not an artificially constructed single-predicate model. The contemporaneous equivalence ~_M is defined using the full language of M.

In the chronicle construction, the limit domain model has its full set of formulas from the MCS. The contemporaneous equivalence at depth k encodes all depth-k formula distinctions. In the constant-MCS case, all points satisfy the same formulas, so the contemporaneous equivalence at ANY depth puts all points in one class. And the argument that one class + very good + countable => isomorphic to Z still works because:

- One class => very good (Lemma 17 + one_class_implies_very_good)
- Very good + countable => good (Lemma 16)
- Good => k-equivalent to a Z-interval
- The Z-interval covers the entire domain

But k-equivalent to Z does NOT mean isomorphic to Z. It only means first-order sentences of depth <= k agree.

**The key insight I've been missing**: Reynolds' theorem doesn't prove IsSuccArchimedean for the limit domain. It proves that the limit domain is k-equivalent to a Z-structure FOR EACH k. The completeness proof then works at a FIXED k (large enough for the formula being disproved), and uses the k-equivalence to transfer the countermodel to Z.

So the correct architecture is: **bypass IsSuccArchimedean entirely**. Instead of proving that the limit domain is succ-Archimedean (which would mean proving it's isomorphic to Z), prove that the limit domain is k-equivalent to Z for a fixed k, and use this k-equivalence to build the countermodel directly.

**But this is exactly what `chronicle_is_good_direct` + the Reynolds pipeline already does!** The team research (report 61) says `chronicle_is_good_direct` (ShiftAndGlue.lean:950) is sorry-free. The issue is connecting it to the restricted coherence conditions.

### 3.8 Two Concrete Resolution Paths

**Path A: Fix chronicle_gap_contradiction directly**

The old proof's Case A (different MCS) approach CAN work if we use a higher depth k. The handoff's analysis (lines 80-122 of phase-3-4-handoff) concludes that k=0 and k=1 are insufficient for contemp_equiv to distinguish a from b. But at sufficient depth k (specifically k >= the quantifier depth where the distinguishing formula psi becomes expressible), the depth-k NF WILL distinguish a from b because the truth value of psi at a point IS encoded in the depth-k NF.

Specifically: if psi in limit_f(a.val) and psi not in limit_f(b.val), then the temporal formula psi is true at a and false at b. The effective formula construction maps psi to a formula whose temporal truth equals psi membership. At depth k = rank(eff(psi)), the truth of eff(psi) is encoded in the depth-k 1-var NF. If a has a different depth-k NF from b (because eff(psi) is true at a and false at b), then [a,b] is NOT k-equivalent to any Z-interval where all points have the same depth-k type... but Z-intervals can have mixed types.

Actually, the issue is that we need contemp_equiv to FAIL at a and b. contemp_equiv at depth k means every subinterval is k-equivalent to a Z-interval. The single subinterval [a,b] must be NOT k-equivalent to any Z-interval. But a Z-interval can have elements where psi is true and elements where psi is false. So [a,b] being k-equivalent to some Z-interval is possible even if a and b disagree on psi.

**However**, if the single-predicate structure M has interp = psi membership, then at depth k >= 1, the depth-k NF includes the quantifier transfer information. For a Z-interval, the depth-1 NF encodes which atomic types are realized. In a Z-interval with both psi-true and psi-false points, the depth-1 NF includes both types. In [a,b] with both types, the depth-1 NF is the same. So 1-equivalence holds.

At depth k >= 2, the depth-2 NF encodes which depth-1 1-var types are realized by extensions. In a Z-interval, every point has a successor and predecessor, so the depth-1 types include the successor's depth-0 type. For a Z-interval with mixed predicates, the depth-1 types at each point encode "I have value V and my successors/predecessors have all possible combinations." In [a,b] (a finite interval of the limit domain), the same types are realized. So 2-equivalence might still hold.

The fundamental issue: contemp_equiv at depth k compares [a,b] with ALL possible Z-intervals. If SOME Z-interval has the same depth-k NF as [a,b], then contemp_equiv holds. Since Z-intervals can have arbitrary predicate assignments, and the single-predicate structure only distinguishes by one bit, there will always be a Z-interval matching [a,b] at any depth.

**Conclusion**: Case A (different MCS) with a single predicate CANNOT work because contemp_equiv will always hold for the single-predicate structure at any depth. The old proof's approach is fundamentally flawed.

**Path B: Bypass IsSuccArchimedean via direct k-equivalence**

Following Reynolds more closely: instead of proving chronicle_gap_contradiction (which requires IsSuccArchimedean), restructure the proof to:

1. Use `chronicle_is_good_direct` to show the limit domain is very good at depth k
2. Use Lemma 16 (very_good + countable => good) to get k-equivalence to a Z-structure
3. Transfer the countermodel directly from the limit domain to Z using the k-equivalence

This bypasses `succ_embed_surjective` entirely. The restricted coherence conditions (tc, fuc) need witnesses on Z, and these come from the k-equivalence transfer, not from succ_embed.

**Path C: Multi-predicate structure with full formula encoding**

Build M with one predicate per subformula in the deferralClosure of the target formula. At depth k = the game depth, the depth-k NF encodes all relevant truth values. If a and b disagree on ANY formula in the closure, the depth-k NF at a and b differ. Then contemp_equiv at this depth with this signature WILL distinguish a and b, because the multi-predicate Z-interval would need to match all predicate assignments simultaneously, and the Stavi completeness result ensures depth-k NFs are fine enough to distinguish.

This resolves Case A. For Case B (constant MCS, where a and b agree on ALL formulas): all points in the limit domain satisfy the same formulas. The depth-k NF is the same everywhere. So the structure IS very good (every subinterval is k-equivalent to a Z-interval where all points have the same NF). The limit domain is good (k-equivalent to Z). Transfer the countermodel to Z.

In the constant-MCS case, the F-resolution witnesses are all in the same MCS, so F(phi) in fmcs(t) gives a witness s > t with phi in fmcs(s) and fmcs(s) = fmcs(t). On Z, the same pattern holds: the countermodel on Z has constant truth values, so F(phi) is witnessed by t+1.

**Path C seems most promising.** It aligns with Reynolds' proof structure and handles both cases uniformly.

---

## 4. Blocker 1 Resolution: nf_2var_existential_transfer

### 4.1 Status: NOT ON CRITICAL PATH

As established in Section 1, the Stavi sorry chain does NOT flow into `completeness_discrete`. The `nf_2var_existential_transfer` sorry affects `stavi_expressive_completeness` which is used by the general model surgery pipeline (PriorExpressiveness -> GoodStructuresModelSurgery -> ReynoldsModelSurgery), but `countermodel_discrete_reynolds` bypasses all of this.

### 4.2 What Would Be Needed (for future work)

If this blocker is addressed later (for the general completeness theorem or for standalone expressive completeness), the EF Game Bridge approach from team research is correct:

1. `nf_char_eq_implies_rank_type_eq`: depth-k NF equality => rank_type equality (uses sorry-free `nf_profile_determines_rank_type`)
2. `interval_nf_types_implies_interval_types`: translate interval type sets
3. `nf_hypotheses_imply_duplicator_wins`: bridge hypotheses => game wins via `ghr93_strategy_compose`
4. `duplicator_wins_implies_nf_agreement`: game win => 2-var NF equality via Lemma 11

This is ~300-430 lines and is well-understood from the literature (GHR93 Proposition 7 + Lemma 11, Libkin Lemma 3.7).

### 4.3 Literature Reference

- GHR93 Proposition 7 (pp.113-115): Strategy composition
- GHR93 Lemma 11 (p.113): Decomposition formulas characterize game wins
- GHR93 Theorem 6 (pp.115-119): Forward-to-backward conversion
- Libkin Lemma 3.7 (p.62): Composition for linear orders

---

## 5. Recommended Attack Order

### Priority 1: Prove chronicle_gap_contradiction (Path C)

**Effort**: ~200-400 lines
**Impact**: Removes the ONLY sorry from `completeness_discrete`
**Approach**: Multi-predicate structure following Reynolds Theorem 15

Detailed implementation plan:

1. **Build multi-predicate M** (~40 lines):
   - sig has one predicate per formula in deferralClosure of some root formula
   - interp maps each predicate to the corresponding formula's membership in limit_f
   - Use the existing deferralClosure infrastructure

2. **Prove semantic_prior_UZ/SZ** (~100 lines, adapt from old proof):
   - The effective formula construction maps each temporal formula to its corresponding MCS formula
   - Prior-UZ/SZ transfer from MCS axioms to temporal truth
   - Already done for single-predicate in old proof (lines 636-703); generalize to multi-predicate

3. **Case A (different MCS)** (~60 lines):
   - With multi-predicate structure at sufficient depth, contemp_equiv distinguishes a and b
   - Need: if psi in limit_f(a.val) and psi not in limit_f(b.val), and the signature includes psi as a predicate, then the NF at a differs from NF at b for the multi-predicate structure
   - At depth 0: the predicate values differ (a has psi=true, b has psi=false)
   - contemp_equiv at depth 0 means 0-equivalent to Z-interval. The depth-0 NF for multi-predicate includes ALL predicate values. With n predicates, the depth-0 NF is a function from AtomKind sig 0 to Bool. AtomKind sig 0 includes pred p 0 for each predicate p. Since a and b disagree on the psi-predicate, they have different depth-0 NFs. 
   - For [a,b] to be 0-equivalent to a Z-interval Z, we need Z to have points matching both a's NF and b's NF. Z-intervals CAN have mixed predicate values, so 0-equivalence might still hold.
   - BUT at depth 0, the equivalence is about quantifier-free formulas. The quantifier-free formulas include the predicate atoms. The depth-0 type of [a,b] includes which atoms hold at each point. A Z-interval with the same pattern of atoms is 0-equivalent. So 0-equivalence CAN hold even with different predicate values.
   - So we need depth >= 1? At depth 1, the quantifier transfer includes: for each depth-0 1-var NF (= predicate assignment pattern), whether a point with that pattern exists in the interval. For [a,b], both patterns exist. For a Z-interval, both patterns can also exist. So 1-equivalence can hold.
   
   **Actually, this analysis shows that contemp_equiv at finite depth ALWAYS holds for any two points in a discrete structure, because there always exists a Z-interval matching the finite-depth type.** This is because Z-intervals can realize arbitrary patterns of predicate values and orderings at bounded depth.

   If this is correct, then **Case A cannot work with contemp_equiv at any finite depth**. The only way to distinguish is to show the interval [a,b] is NOT very good -- but very_good at depth k always holds for intervals in discrete structures that are long enough compared to k.

   Wait, but this contradicts the Lean formalization. Let me check: `contemp_equiv sig k M a b` is defined as `very_good sig k (M.subinterval sig (min a b) (max a b))`. And very_good means every subinterval is good. Good means k-equivalent to some Z-interval. In a discrete structure with no gaps, every finite subinterval IS k-equivalent to some Z-interval (by the EF game argument: take a Z-interval of the same length; it's isomorphic). So in a discrete gapless structure, very_good at depth k holds for ALL pairs.

   **Therefore: in a discrete structure satisfying Prior-UZ/SZ (which ensures no definable gaps), contemp_equiv holds for ALL pairs at ALL depths.** The entire structure is one contemp_equiv class.

   This means Case A is VACUOUSLY TRUE: there are no pairs (a,b) where a and b are NOT contemp_equiv. The `h_not_equiv_ab` hypothesis in the old proof is never satisfiable.

4. **The correct proof** (both cases, ~80 lines):
   - In a discrete structure satisfying Prior-UZ/SZ, the entire domain is one contemp_equiv class
   - gap_contradicts_prior gives: the class is succ-closed and not bounded above (right)
   - gap_contradicts_prior_below gives: the class is pred-closed and not bounded above (left)
   - The class = entire domain
   - Therefore: for any a < b, a and b are in the same class
   - The class being succ-closed means: succ(a) is in the class, succ^2(a) is in the class, etc.
   - But this doesn't directly give succ^n(a) >= b.

   **The ACTUAL contradiction comes from gap_contradicts_prior directly**:
   - gap_contradicts_prior takes: succ-closed class of a, bounded above by b (NOT in class)
   - If the entire domain is one class, then b IS in the class, and gap_contradicts_prior's hypothesis is not satisfied.
   - So we can't directly apply gap_contradicts_prior.

   **Re-reading gap_contradicts_prior's actual signature**:

   ```lean
   theorem gap_contradicts_prior ... (h_succ_closed : ...) 
       (h_bounded : ∃ y, a < y ∧ ¬contemp_equiv sig k M a y) : False
   ```

   It requires existence of y > a NOT in a's class. If the entire domain is one class, this hypothesis fails.

   **So the proof CANNOT use gap_contradicts_prior at all in the one-class case.**

### Revised Understanding

The one-class case (which includes constant MCS and more generally any case where the entire domain has the same depth-k type pattern) genuinely cannot use the model surgery approach. The model surgery approach (gap_contradicts_prior) requires at least two equivalence classes.

**But in the one-class case, the domain IS isomorphic to Z** (by Reynolds' Lemma 16: very good + countable => good, meaning k-equivalent to a Z-interval). In a Z-interval, succ-iterates are cofinal. So the one-class case is exactly the easy case.

The hard case is the multi-class case, where the model surgery argument applies. But in a discrete Prior structure, Theorem 14 says classes don't end at gaps, and no_boundary_at_successor says classes extend past successor boundaries. In a discrete gapless structure, these together force one class. So the multi-class case CANNOT occur in a discrete Prior structure.

**Therefore: in a discrete Prior structure with no gaps (limit domain satisfying Prior-UZ/SZ), there is exactly one contemp_equiv class, and the domain is k-equivalent to Z. The proof of succ_cofinal follows from the Z-equivalence.**

But k-equivalence to Z does NOT prove succ_cofinal directly. It proves agreement on first-order sentences of depth k. Succ_cofinal is a statement about the actual structure (there exists n with succ^n(a) >= b), not about first-order sentences.

**Wait**: succ_cofinal IS expressible as a first-order sentence (over the structure with succ as a function symbol). "For all a, b with a < b, there exists n such that succ^n(a) >= b" is an omega-quantification, not first-order. But for FIXED a and b, "there exists n such that succ^n(a) >= b" can be encoded as a disjunction: succ(a) >= b OR succ^2(a) >= b OR ... This is an infinite disjunction, not first-order.

**So k-equivalence to Z does NOT give succ_cofinal.** This is a genuine gap. The one-class argument shows the domain is "abstractly similar" to Z but doesn't prove the concrete reachability.

### 3.9 The Actual Resolution: Chronicle-Specific Induction

After extensive literature analysis, the correct resolution for chronicle_gap_contradiction appears to be:

**The proof must use the chronicle construction specifically**, not just abstract model-theoretic properties. The omega-chain construction builds the limit domain incrementally, and at each stage, the domain is a finite set (hence trivially succ-Archimedean). The limit preserves this property because:

1. Every point in the limit domain enters at some finite stage N
2. At stage N, the finite domain is succ-Archimedean (trivially, finite discrete order)
3. The successor function on the limit domain agrees with the stage-N successor for points at stage N
4. For a < b both at stage N, succ^k(a) = b for some k at stage N, hence also in the limit

The issue is with points entering at DIFFERENT stages. If a enters at stage N and b enters at stage M > N, then at stage N, b doesn't exist yet. The handoff's analysis of `succ_reaches_dom_N` (lines 220-236, 387-392) identifies exactly this: the "boundary cases" where a is below min(dom(N)) or b is above max(dom(N)).

**Path D: Stage induction on the omega-chain**

This was the original approach (`succ_reaches_dom_N`, ChronicleToCountermodel.lean:98-398) but was marked as dead due to boundary cases. The boundary cases are:

1. **Case 3a** (b above max(dom(N))): `succ(max_N_sub)` is the next point above max_N, but it might not enter at stage N+1. Resolution: use `omega_chain_dom_new_unique` to show that at stage N+1, exactly ONE new point enters above max_N. This new point IS succ(max_N_sub). Then repeat.

2. **Case 3b** (a below min(dom(N))): Symmetric issue. Resolution: use `omega_chain_dom_new_unique` for points below min.

The `omega_chain_dom_new_unique` approach was attempted but encountered issues (lines 226-236). The specific issue: succ(max_N_sub) might not enter at stage N+1; it could enter at a later stage.

**Path E: Use cantor_bfmcs_discrete differently**

Instead of proving chronicle_gap_contradiction -> succ_cofinal -> IsSuccArchimedean -> succ_embed_surjective, restructure `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc` to NOT use succ_embed_surjective.

The tc/fuc conditions need: for any t : Z, if F(phi) in fam.mcs(t), then there exists s > t with phi in fam.mcs(s). Currently, the proof finds a witness y in the limit domain using `limit_F_resolution`, then maps y back to Z using `succ_embed_surjective`.

Alternative: instead of mapping back to Z, define the family directly on the limit domain indices rather than on Z. The restricted parametric truth lemma would then work over the limit domain as the index set, not Z. This requires restructuring the parametric canonical model to be parametric over the index set.

**Effort**: ~300-500 lines of restructuring, but high confidence.
**Risk**: The parametric canonical model infrastructure might be tightly coupled to Z.

### 5.1 Final Recommendation

**Immediate path**: Path D (stage induction) with careful handling of boundary cases. The omega-chain construction's properties at each stage give concrete witnesses. The two boundary cases (above-max and below-min) each need ~50-80 lines of stage analysis.

**Alternative path**: Path E (restructure restricted coherence) if Path D's boundary cases prove intractable.

**Do NOT pursue**: Path A (single-predicate contemp_equiv), Path B (bypass via abstract k-equivalence without concrete witnesses), or Path C (multi-predicate) -- all face the fundamental issue that k-equivalence doesn't give succ-reachability.

**Effort estimate**: 150-300 lines for Path D (fixing the boundary cases in succ_reaches_dom_N), or 300-500 lines for Path E (restructuring the parametric model).

### Priority 2: Chain 1 (EF Game Bridge) — DEFERRED

**Not on critical path for completeness_discrete.** Defer until the general completeness theorem is targeted.

---

## 6. Infrastructure Inventory

### Sorry-Free Infrastructure Available

| Component | Location | Status |
|-----------|----------|--------|
| `gap_contradicts_prior` | GoodStructuresModelSurgery.lean:2087 | Sorry-free |
| `gap_contradicts_prior_below` | GoodStructuresModelSurgery.lean:2106 | Sorry-free |
| `no_boundary_at_successor` | GoodStructures.lean | Sorry-free |
| `contemp_equiv_is_equiv` | GoodStructures.lean | Sorry-free |
| `one_class_implies_very_good` | ShiftAndGlue.lean | Sorry-free |
| `chronicle_is_good_direct` | ShiftAndGlue.lean:950 | Sorry-free |
| `ghr93_strategy_compose` | Composition.lean:40 | Sorry-free |
| `decomposition_agreement` | Decomposition.lean:62 | Sorry-free |
| `ghr93_game_iff_decomposition` | Decomposition.lean:302 | Sorry-free |
| `nf_agreement_from_nf_char_eq` | NFGameBridge.lean:58 | Sorry-free |
| `nf_char_depth_le` | NFGameBridge.lean:104 | Sorry-free |
| `nvar_nf_eq_depth_zero_from_pointwise` | NFGameBridge.lean:160 | Sorry-free |
| `limit_F_resolution` / `limit_P_resolution` | ChronicleToCountermodel.lean | Sorry-free |
| `limit_satisfies_c4` / `c5_strong` | ChronicleToCountermodel.lean | Sorry-free |
| `omega_chain_dom_new_unique` | ChronicleToCountermodel.lean | Sorry-free |
| Old proof template (Case A) | ChronicleToCountermodel.lean:488-762 | Commented, nearly complete |

### Sorry Sites (Blocking completeness_discrete)

| Site | Location | Blocks |
|------|----------|--------|
| `chronicle_gap_contradiction` | ChronicleToCountermodel.lean:486 | THE ONLY SORRY |

### Sorry Sites (NOT Blocking completeness_discrete)

| Site | Location | Blocks |
|------|----------|--------|
| `nf_2var_existential_transfer` (fwd) | StaviCompleteness.lean:2347 | stavi_expressive_completeness |
| `nf_2var_existential_transfer` (bwd) | StaviCompleteness.lean:2429 | stavi_expressive_completeness |
| `nf_exist_sf_guarded_backward` | StaviCompleteness.lean:2787 | stavi_expressive_completeness |
| `succ_reaches_dom_N` Case 3a | ChronicleToCountermodel.lean:236 | Dead code |
| `succ_reaches_dom_N` Case 3b | ChronicleToCountermodel.lean:392 | Dead code |
| Old proof Case B | ChronicleToCountermodel.lean:500 | Dead code (commented) |
| Old proof Case A (k=0 issue) | ChronicleToCountermodel.lean:741 | Dead code (commented) |
| Old proof symmetric case | ChronicleToCountermodel.lean:761 | Dead code (commented) |

### Missing Infrastructure

| What | Why Needed | Effort |
|------|-----------|--------|
| Stage induction for boundary cases | Fix succ_reaches_dom_N Cases 3a/3b | ~100-160 lines |
| OR: Limit-domain-indexed parametric model | Bypass succ_embed_surjective | ~300-500 lines |
