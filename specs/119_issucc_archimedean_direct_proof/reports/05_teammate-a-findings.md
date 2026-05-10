# Reynolds 1992 Deep Dive: Complete Mathematical Architecture

- **Task**: 119 - Prove IsSuccArchimedean via direct connectivity extraction
- **Status**: Research findings complete
- **Type**: lean4
- **Round**: 5 (Teammate A - Reynolds 1992 deep dive)
- **Date**: 2026-05-10
- **Session**: sess_1778454477_cdc6ef

## Executive Summary

Reynolds 1992 provides a complete axiom hierarchy for Until/Since temporal logic over four frame classes: arbitrary linear orders, dense orders (Q), the reals (R), and the integers (Z). This report extracts the full mathematical architecture, maps every axiom and proof step onto our BX codebase, and answers the five specific questions from the delegation brief. The central finding is that Reynolds's approach for Z uses **k-equivalence transfer via the Doets theorem**, not isomorphism to Z, and this fundamentally changes the relationship between our IsSuccArchimedean problem and the mathematical completeness result.

## 1. Reynolds's Axiom System Hierarchy

### 1.1 US/LO (Base System — Linear Orders)

**Axioms**: The six Burgess-Xu axioms (plus duals) + propositional tautologies + four rules (MP, G-necessitation, H-necessitation, substitution).

The six Burgess-Xu axioms, as listed in Reynolds Section 2, are (with our Burgess convention untl(event, guard)):

| Reynolds | Formula | Our BX Axiom |
|----------|---------|--------------|
| A1 | `G(p -> q) -> (U(p,r) -> U(q,r))` | `right_mono_until` (BX3) |
| A2 | `G(p -> q) -> (U(r,p) -> U(r,q))` | `left_mono_until_G` (BX2G) |
| A3 | `p ^ U(q,r) -> U(q ^ S(p,r), r)` | `enrichment_until` (BX13) |
| A4 | `U(p,q) -> U(p, q ^ U(p,q))` | `self_accum_until` (BX5) |
| A5 | `U(q ^ U(p,q), q) -> U(p,q)` | `absorb_until` (BX6) |
| A6 | `U(p,q) ^ U(r,s) -> U(p^r, q^s) v U(p^s, q^s) v U(q^r, q^s)` | `linear_until` (BX7) |

Plus their duals (S-versions). Reynolds references Burgess [2] and Xu [18] for the original six.

**Reynolds Theorem 1** (Section 4): This system is sound and **strongly** complete for all linear frames. This corresponds precisely to our existing chronicle construction producing a linear model via the Burgess omega-chain.

**Mapping to our codebase**: Our BX axiom system (Axioms.lean) contains all six Burgess-Xu axioms plus duals, plus additional axioms (BX4 connectedness, BX10 until-F, BX11 temporal linearity, BX12 F-until bridge, temp_k_dist, temp_4). The additional axioms are derivable from BX1-BX6 plus the rules in the presence of the base system, or are independently valid on all linear orders. Our BX system is thus a **superset** of Reynolds's US/LO.

### 1.2 US/Q (Dense System — Rationals)

**Axioms**: US/LO + density and no-endpoint axioms:
- `K+ T` (density from the right): equivalent to `neg(U(T,bot))`
- `K- T` (density from the left): equivalent to `neg(S(T,bot))`
- `F T` (no right endpoint)
- `P T` (no left endpoint)

Where `K+ A = neg(U(T, neg A))` means "A holds arbitrarily soon in the future."

**Reynolds's approach** (Section 4, Corollary 1): Start with a US/LO-consistent set, get a linear model by Theorem 1. Since K+T, K-T, FT, PT are all in the consistent set, the model has no endpoints and is dense. By Cantor's theorem, a countable dense linear order without endpoints is isomorphic to Q.

**Mapping to our codebase**: Our dense case works exactly this way. The `cantor_iso_dense` function in ChronicleToCountermodel.lean uses Mathlib's `Order.iso_of_countable_dense` to establish `LimitDomSubtype ~=o Rat`. The `limit_dom_dense_from_F'T` theorem proves density from the hypothesis that `neg(U(T,bot))` (our `next_top.neg`) is in every domain MCS.

### 1.3 US/R (Real System)

**Axioms**: US/Q + three additional axioms:

**Prior-U**: `U(T, p) ^ F(neg p) -> U(neg p v K+(neg p), p)`

This says: if p holds from now until some time, and eventually not-p holds, then there is a "clean" boundary — either not-p begins, or not-p is arbitrarily close before the boundary. The key force: Prior-U eliminates "definable gaps" where a formula's truth changes at a gap in the order.

**Prior-S**: The dual (Since direction).

**Sep**: `K+(p) ^ neg K+(p ^ U(p, neg p)) -> K+(K+(p) ^ K-(p))`

This says: if p holds arbitrarily close in the future, but there is no point where p starts a finite "run" (p until not-p), then there is a point arbitrarily close where p is dense from both sides. Sep encodes the separability of R (having a countable dense suborder).

**Mapping to our codebase**: NONE of these three axioms appear in our current Axioms.lean. They are not among the BX axioms. This is a major structural observation.

### 1.4 US/Z (Integer System)

**Axioms**: US/LO + discreteness and no-endpoint axioms + Prior-UZ/SZ:

**Discreteness**: `U(T, bot)` and `S(T, bot)` — "next top" holds everywhere. Every point has an immediate successor (no points between t and its successor) and immediate predecessor.

**No endpoints**: These are consequences of the discreteness axioms combined with US/LO (seriality).

**Prior-UZ**: `Fp -> U(p, neg p)`

If p holds somewhere in the future, then p holds until not-p. This is MUCH stronger than Prior-U. It forces:
1. No definable gaps (same as Prior-U but in a simpler way)
2. Every non-empty definable future subset has a minimum (well-ordering of definable subsets above any point)
3. The Stavi connective U'(A,B) is equivalent to bot (no gap-crossing behavior possible)

**Prior-SZ**: `Pp -> S(p, neg p)` — the dual.

**Mapping to our codebase**: The discreteness axioms `U(T,bot)` and `S(T,bot)` correspond to our uniformity axioms (`discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`). Our axioms encode both the existence of immediate successors/predecessors AND their uniform propagation. However, **Prior-UZ and Prior-SZ are NOT in our axiom system**. This is the critical gap identified in Report 04.

## 2. The Prior Axioms: Precise Statements and Relationships

### 2.1 Prior-U (for reals)

Reynolds Section 2:
```
Prior-U:  U(T, p) ^ F(neg p) -> U(neg p v K+(neg p), p)
```

Unpacking: If p holds continuously from now for a while (`U(T,p)` means "true until p" i.e., p holds from now into the future) AND not-p holds at some future time, then from now until not-p arrives, one of two things is true at each point: either not-p holds there, OR not-p is arbitrarily close in the future from there. The "K+(neg p)" part handles the case where we approach a gap from below.

**Force**: In any model validating Prior-U, there cannot be a "definable gap" — a gap in the order where a temporal formula's truth value changes across the gap without a smooth transition. The proof (Reynolds Sections 5-6) shows this by contradiction: if a contemporaneous equivalence class ended at a gap, the Prior-U axiom applied to a formula expressing "in the first class" would force a first point of the complement or a last point of the class, but neither exists at a gap.

### 2.2 Prior-UZ (for integers)

Reynolds Section 10:
```
Prior-UZ:  Fp -> U(p, neg p)
```

This is dramatically simpler. It says: if p holds somewhere in the future, then not-p holds continuously from now until p first holds. In a discrete order, this forces the set {t' > t | p(t')} to have a minimum, because U(p, neg p) at t requires a witness s > t with p(s) and neg p between t and s, meaning s is the first occurrence of p after t.

**Why different from Prior-U**: Prior-U has the extra hypothesis `U(T,p)` (p holds from now for a while) and a weaker conclusion (neg p OR K+(neg p)). In a dense order, the "first point where p holds" may not exist (p could be true on a Cantor-like set approaching a limit). Prior-U handles this via the K+(neg p) disjunct. In a discrete order, every point has an immediate successor, so "first point where p holds" always exists when Fp holds, making the simpler Prior-UZ sufficient.

### 2.3 Relationship to our BX axioms

**None of the Prior axioms are BX axioms.** The BX system is complete for arbitrary linear orders (Burgess-Xu Theorem 1). The Prior axioms are ADDITIONAL axioms needed for specific frame classes:
- Prior-U/S are needed for R (eliminating definable gaps in dense models)
- Prior-UZ/SZ are needed for Z (forcing well-ordering of definable sets in discrete models)

**Can Prior-UZ be derived from BX + our uniformity axioms?** NO. The previous report (04) established this with the Z+Z countermodel: two copies of Z concatenated satisfy all BX axioms and all four uniformity axioms, but Prior-UZ fails because the set "true on the second copy" has no minimum reachable by iterated successor from the first copy.

**Is Prior-UZ semantically valid on our intended frame class?** On ordered abelian groups with SuccOrder + PredOrder + IsSuccArchimedean + Nontrivial, YES. The proof: Given Fp at t, the set S = {s > t | p(s)} is non-empty. Since the group is IsSuccArchimedean, for any s in S, there exists n with succ^n(t) = s. So the set {n in N | p(succ^n(t))} is non-empty. By well-ordering of N, this set has a minimum n0. Then s0 = succ^n0(t) is the first occurrence of p after t, and neg p holds at succ^k(t) for all k < n0. This gives U(p, neg p) at t.

**Circularity note**: Proving Prior-UZ sound on our frame class requires IsSuccArchimedean — the very property we are trying to prove for the limit domain.

## 3. Reynolds's Completeness Proof Structure

### 3.1 Section 4: Burgess Construction -> Rational Model

**Requires**: A US/R-consistent set Gamma (or US/Z-consistent for the integer case).

**Produces**: A linear temporal structure M with:
- Flow of time = rationals (Q)
- A point 0 where all formulas in Gamma hold
- All substitution instances of all axioms (including Prior-U/S, Sep, or Prior-UZ/SZ) are valid in M

**How**: Gamma is consistent with the Burgess-Xu system (US/LO), which gives a linear model by Theorem 1 (strong completeness). Since the full axiom system's axioms are in every MCS of the linear model (by Burgess-Xu strong completeness and the fact that Gamma includes these axioms), all instances are valid.

For the dense case: K+T, K-T, FT, PT in Gamma force the model to be dense without endpoints. By Cantor's theorem: flow of time = Q.

For the discrete case: U(T,bot) and S(T,bot) force the model to be discrete (every point has an immediate successor/predecessor). The flow of time is a countable discrete linear order without endpoints.

**Mapping**: This corresponds exactly to our chronicle construction. The `limit_dom` / `limit_f` construction builds the linear model. The `limit_c0`, `limit_forward_G`, `limit_backward_H`, `limit_satisfies_c4`, `limit_satisfies_c5_strong` theorems establish the coherence properties. In the dense case, `cantor_iso_dense` gives the Q isomorphism.

**Can this be done in Lean?** Already done (dense case). The discrete case needs either IsSuccArchimedean (for Z-isomorphism) or an alternative approach.

### 3.2 Section 5: Expressive Completeness (Kamp's Theorem)

**Requires**: A Prior structure (model where Prior-U/S instances are valid).

**Produces**: Every first-order monadic formula with one free variable is equivalent to a temporal U/S formula.

**How**: The Stavi connectives U'(A,B) and S'(A,B) make {U,S,U',S'} expressively complete over ALL linear orders (Theorem 2). In a Prior structure, U'(A,B) is equivalent to bot (Theorem 3), because: if U'(A,B) holds at t, then B holds from t up to a gap where neg B is arbitrarily close. But Prior-U applied to B gives U(neg B v K+(neg B), B) at t, which means negB or K+(negB) holds eventually while B holds continuously up to that point. This contradicts the gap behavior of U'. Similarly for S'. So in a Prior structure, {U,S} alone suffices.

**Mapping**: We do NOT currently formalize expressive completeness. This is a substantial formalization task. However, it is only needed for the Doets transfer approach, not for the direct isomorphism approach.

**For the integer case (Prior-UZ)**: The argument is even simpler. U'(A,B) says B holds until a gap, then negB arbitrarily soon after. From Fp (where p is defined from A,B appropriately), Prior-UZ gives U(p, neg p), which means a clean transition exists. This contradicts the gap behavior of U'. So U' = bot in any Prior-UZ structure.

### 3.3 Section 6: No Gaps Between Equivalence Classes (Theorem 4)

**Requires**: A Prior structure M, a contemporaneous equivalence relation ~ on M.

**Produces**: The ~-classes do not end at gaps.

**How** (this is the heart of the paper, ~4 pages of intricate reasoning):

1. Define "bad points" (R v L): points whose ~-class ends at a gap on the right (R) or left (L).
2. Show bad points only occur in "bad intervals" (maximal intervals where R v L holds) — Lemma 6.
3. Show bad intervals have excluded endpoints — Lemma 3 (uses Prior-U/S).
4. Show all ~-classes in a bad interval are elementarily equivalent — Lemma 5.
5. Show formulas holding near the start/end of a class hold throughout the bad interval — Lemma 7.
6. Show replacing a bad interval by one of its classes produces a structure preserving all temporal truths — Lemma 8.
7. But in the replacement structure, the class used to replace the interval still satisfies R (by the replacement lemma), yet its class in the new structure doesn't end at a gap (since the gap was in the original interval, now collapsed). Contradiction — Lemma 9.

**Key Theorem 4**: In any Prior structure, contemporaneous equivalence classes do not end at gaps.

**Mapping**: This entire section is NOT formalized in our codebase. It would require:
- Formalizing contemporaneous equivalence relations
- Formalizing "gaps" (supremum-less proper initial segments)
- Formalizing "bad points" and "bad intervals"
- Proving Lemmas 2-9

This is the most technically demanding part of Reynolds's proof. Estimated at 300-500 lines of Lean.

### 3.4 Section 7: Separability (Sep Axiom)

**Requires**: A Prior structure M satisfying all Sep instances, with M/~ densely ordered.

**Produces**: M/~ has a dense set of singleton ~-classes (Theorem 5).

**How**: From Theorem 4, classes are closed intervals (no gaps). If c < d in different classes, c is the right endpoint of its class. The formula C = "left endpoint of class" satisfies K+(C) at c. Using Sep: K+(C ^ U(C, negC)) does not hold, so K+(K+(C) ^ K-(C)) holds. This gives a singleton class between c and d.

**Also**: Lemma 10 proves Sep is valid over R using a cardinality argument (uncountably many gaps in a dense subset of R would require uncountably many disjoint non-singleton intervals, impossible in R).

**Mapping**: Not formalized. Only needed for the R case.

### 3.5 Section 8: Doets Transfer -> Real Model (Theorem 6)

**Requires**: A countable temporal structure M (finite language), dense, no endpoints, satisfying D1 (no gaps at class boundaries) and D2 (dense singletons in dense quotients).

**Produces**: For all k < omega, a temporal structure with flow = R satisfying the same monadic sentences of quantifier depth <= k as M.

**How**: Define "good" (k-equivalent to an interval of R), "very good" (all subintervals are good). Define ~ via "M|[a,b] is very good". Show ~ is contemporaneous. By D1, classes don't end at gaps, so they are closed intervals. By D2, singleton classes are dense. Build a real-flowed model via lexicographic sums and shuffles, using EF-game arguments to preserve k-equivalence.

**Mapping**: Not formalized. This is a major piece of model theory (Doets 1987, Burgess-Gurevich 1985).

### 3.6 Section 9: Completeness for R (Theorem 7)

**Puts together**: Corollary 1 (rational model) + Theorems 4, 5, 6 + Kamp's theorem.

Given consistent phi:
1. Get rational model M with Prior-U/S and Sep valid (Corollary 1)
2. Restrict to finite language of phi
3. D1 holds (Theorem 4), D2 holds (Theorem 5)
4. Apply Doets (Theorem 6): get R-flowed model agreeing on depth-k sentences
5. phi has a table alpha(t) of bounded quantifier depth
6. exists t, alpha(t) transfers to the R-model
7. Therefore phi holds in the R-model

### 3.7 Section 10: Completeness for Z (Theorem 8)

**The key section for our problem.** Reynolds proves:

**Theorem 9**: Suppose M is a temporal structure (finite language) with countable, discrete, no-endpoint flow of time. If for any contemporaneous equivalence relation ~ on M, the ~-classes do not end at gaps, then for all k, there is a structure with flow = Z satisfying the same monadic sentences of depth <= k as M.

**Proof of Theorem 9** (the discrete Doets transfer):
- Fix k >= 3.
- Define "good" = k-equivalent to an interval of Z.
- Define "very good" = for all t <= u in M, M|[t,u] is good.
- **Key difference from dense case**: use closed intervals [t,u] rather than open intervals (t,u), and "very good" requires all [t,u] to be good (not just nonempty and good).
- Lemma 14: countable + very good => good (via lexicographic sums of finite intervals of Z).
- Lemma 15: ~ is a contemporaneous equivalence relation.
- **Final argument**: If M is not good, then not very good, so there exist a < b with M|[a,b] not good. Then a's ~-class ends before b. Since the class doesn't end at a gap (hypothesis), it has a right endpoint c with c+1 not in the same class. But M|[c, c+1] is a two-point structure, which is trivially good (= very good). This contradicts c+1 being in a different class from c, since [c, c+1] being good means c ~ c+1. Contradiction: M must have been good all along.

**Theorem 8 proof**: Given US/Z-consistent phi:
1. Get linear model M via Burgess-Xu (Theorem 1, strong completeness)
2. M satisfies Prior-UZ, Prior-SZ (all instances, because they are axioms)
3. M is a Prior structure (Prior-UZ implies Prior-U style gap elimination in discrete case)
4. Apply Theorem 4: contemporaneous equivalence classes don't end at gaps
5. Apply Theorem 9: M is k-equivalent to Z for all k
6. Transfer phi to a Z-model

## 4. The Critical Question: Isomorphism vs. k-Equivalence

### 4.1 Does Reynolds prove limit_dom IS isomorphic to Z?

**NO.** Reynolds NEVER constructs an isomorphism from the Burgess model to Z. His proof establishes:
- The Burgess model M (countable, discrete, no endpoints) is k-equivalent to Z for every k.
- Since phi has bounded quantifier depth, the k-equivalence for sufficiently large k preserves phi.
- Therefore phi is satisfiable in SOME model with flow Z (obtained by the k-equivalence transfer).

The model over Z that satisfies phi is NOT the Burgess model M. It is a DIFFERENT model, obtained through the Doets transfer construction (which involves lexicographic sums, shuffles, and game arguments).

### 4.2 Does k-equivalence suffice for our completeness theorem?

**Our `bx_completeness`** (Completeness.lean, line 128) states:
```
theorem bx_completeness (phi : Formula) : valid phi -> Nonempty (DerivationTree [] phi)
```

The contrapositive: if phi is not derivable, there exists SOME model in SOME temporal type where phi fails. The current `dd_countermodel_chronicle_nondense_sorry` existentially quantifies:
```
exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F) ...
```

So the countermodel D can be ANY type with the right structure. If we could produce a countermodel over Int (Z), that would suffice. Reynolds's approach produces exactly this.

**However**: our `valid` quantifies over ALL temporal types D with `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial`. So the countermodel must live in one such D. Int satisfies all of these. But the Reynolds approach also works: the k-equivalent Z-model has flow Int, and we can build a TaskFrame and TaskModel over Int.

**Bottom line**: k-equivalence to Z IS sufficient for our completeness theorem. We do NOT need an isomorphism from limit_dom to Z.

### 4.3 The role of IsSuccArchimedean in the current approach vs. Reynolds

**Current approach** (our codebase):
1. Build limit_dom (Burgess chronicle) -- DONE
2. Prove limit_dom is isomorphic to Z via `orderIsoIntOfLinearSuccPredArch` -- REQUIRES IsSuccArchimedean
3. Transport FMCS to Int -- DONE (modulo sorry)
4. Build BFMCS, apply parametric representation -- DONE

**Reynolds approach**:
1. Build limit_dom (Burgess chronicle) -- DONE (same step)
2. Prove Prior-UZ valid in limit model -- REQUIRES Prior-UZ as axiom
3. Prove no gaps at equivalence classes (Theorem 4) -- NEW formalization
4. Apply discrete Doets transfer (Theorem 9) -- NEW formalization
5. Transfer phi to a Z-model -- NEW formalization

**Key difference**: The current approach needs IsSuccArchimedean to prove isomorphism. Reynolds's approach needs Prior-UZ as an axiom to prove no-gaps, then uses the Doets theorem to get k-equivalence.

## 5. Weak vs. Strong Completeness

### 5.1 Reynolds's completeness is WEAK

Reynolds proves (Theorem 7 for R, Theorem 8 for Z): every SINGLE consistent formula is satisfiable. He explicitly notes (Section 2) that:
- Strong completeness (every consistent SET of formulas is satisfiable) FAILS for U/S over R.
- This is because compactness fails for {U,S} over R (there is an unsatisfiable set, all finite subsets of which are satisfiable).
- For Z, Reynolds does not discuss whether strong completeness holds, but it likely does (Z has a decidable theory, and decidability usually implies strong completeness for finitely axiomatizable logics).

### 5.2 Our `bx_completeness` is weak completeness

Our theorem states: `valid phi -> Nonempty (DerivationTree [] phi)`, which is equivalent to: every single formula not derivable is falsifiable. This is exactly weak completeness (for individual formulas).

**Our theorem does NOT require strong completeness.** The Burgess-Xu theorem (Theorem 1 in Reynolds) gives strong completeness for US/LO, which we use as an intermediate step. But the final result (US/R or US/Z completeness) is only weak.

### 5.3 Does Reynolds give us what we need?

**YES, completely.** Our `bx_completeness` asks: given a valid formula, produce a derivation. The contrapositive asks: given a non-derivable formula, produce a countermodel in SOME temporal type. Reynolds's approach produces a countermodel over Z (for the discrete case), which is exactly what we need.

The only question is whether we can implement the intermediate steps (Theorem 4 + Theorem 9) in Lean without requiring more machinery than the direct IsSuccArchimedean proof.

## 6. Detailed Mapping: Reynolds -> Our Codebase

### 6.1 Axiom correspondence table

| Reynolds Axiom | Reynolds System | Our Axiom (Axioms.lean) | Status |
|----------------|----------------|------------------------|--------|
| A1 (right mono) | US/LO | `right_mono_until` (BX3) | Present |
| A2 (left mono G) | US/LO | `left_mono_until_G` (BX2G) | Present |
| A3 (enrichment) | US/LO | `enrichment_until` (BX13) | Present |
| A4 (self-accum) | US/LO | `self_accum_until` (BX5) | Present |
| A5 (absorption) | US/LO | `absorb_until` (BX6) | Present |
| A6 (linearity) | US/LO | `linear_until` (BX7) | Present |
| A1'-A6' (duals) | US/LO | `*_since` variants | Present |
| K+T (density) | US/Q | NOT in BX (dense case hypothesis) | Conditional |
| K-T (density) | US/Q | NOT in BX (dense case hypothesis) | Conditional |
| FT (no right end) | US/Q | `serial_future` | Present |
| PT (no left end) | US/Q | `serial_past` | Present |
| Prior-U | US/R | NOT in BX | **MISSING** |
| Prior-S | US/R | NOT in BX | **MISSING** |
| Sep | US/R | NOT in BX | **MISSING** |
| U(T,bot) (disc) | US/Z | Via uniformity axioms | Present |
| S(T,bot) (disc) | US/Z | Via uniformity axioms | Present |
| Prior-UZ | US/Z | NOT in BX | **MISSING** |
| Prior-SZ | US/Z | NOT in BX | **MISSING** |

### 6.2 Proof component mapping

| Reynolds Component | Section | Our Codebase | Status |
|-------------------|---------|-------------|--------|
| Burgess-Xu (linear model) | 4 | Chronicle construction | Done |
| Corollary 1 (rational model) | 4 | `cantor_iso_dense` | Done (dense) |
| Expressive completeness | 5 | NOT formalized | Missing |
| No gaps at eq. classes | 6 | NOT formalized | Missing |
| Sep validity over R | 7 | NOT applicable | N/A |
| Separability (Thm 5) | 7 | NOT formalized | Missing |
| Doets transfer (dense) | 8 | NOT formalized | Missing |
| Completeness for R | 9 | NOT implemented | Missing |
| Discrete Doets (Thm 9) | 10 | NOT formalized | Missing |
| Completeness for Z | 10 | `dd_countermodel_chronicle_nondense_sorry` | sorry |

### 6.3 What our codebase has that Reynolds doesn't need

Our codebase includes infrastructure that Reynolds's approach does NOT require:
- `IsSuccArchimedean` proof (the sorry site)
- `orderIsoIntOfLinearSuccPredArch` (Z-isomorphism from Mathlib)
- Parametric representation theorem (builds TaskModel from FMCS)
- BFMCS restricted coherence

In the Reynolds approach, you bypass all of this by going directly from the Burgess model to a Z-model via k-equivalence. The parametric representation is still useful (you need to build a TaskModel somehow), but you build it on Int directly using the transferred valuation, not via isomorphism from limit_dom.

## 7. Assessment of Formalization Approaches

### 7.1 Approach A: Add Prior-UZ, implement Theorem 4 only (simplified Reynolds)

**Idea**: Add Prior-UZ as an axiom. Use Theorem 4 (no gaps at equivalence classes) to prove that limit_dom is "gap-free" in the relevant sense. Then argue that a gap-free countable discrete linear order without endpoints MUST be isomorphic to Z (bypassing IsSuccArchimedean entirely).

**Analysis**: A gap-free countable discrete linear order without endpoints is NOT necessarily isomorphic to Z. The Z+Z countermodel from Report 04 shows this: Z+Z has no "definable" gaps (in the sense of Theorem 4, because every contemporaneous equivalence class is all of Z+Z — the whole structure is very good), yet Z+Z is not isomorphic to Z.

Wait — actually in Z+Z, does Theorem 4 apply? Theorem 4 requires the model to be a "Prior structure" (Prior-UZ valid). As shown in Section 1 of Report 04, Prior-UZ IS valid on Z+Z. And Z+Z does satisfy "no gaps at contemporaneous equivalence classes" — because the equivalence classes are closed intervals (in fact all of Z+Z is one class when k is large enough). Yet Z+Z is not isomorphic to Z.

So Theorem 4 alone does NOT give IsSuccArchimedean or isomorphism to Z. The gap-freeness is a necessary but not sufficient condition.

**Conclusion**: This approach does not work without Theorem 9 (the Doets transfer).

### 7.2 Approach B: Full Reynolds (Theorem 4 + Theorem 9)

**Idea**: Implement both Theorem 4 and Theorem 9. This gives k-equivalence to Z, which suffices for weak completeness.

**Analysis**: Theorem 9's proof (Section 10) is remarkably simple — it is only about 1 page in the paper. The key argument is:

1. Define good (k-equiv to interval of Z), very good (all sub-intervals good).
2. If M is not good, then not very good: exists a,b with M|[a,b] not good.
3. a's ~-class doesn't end at a gap (Theorem 4 hypothesis).
4. So a's class has a right endpoint c, and c+1 exists (discreteness).
5. M|[c, c+1] is a two-point structure, hence good.
6. So c ~ c+1 (by definition of ~: M|[c, c+1] is very good).
7. But a ~ c (same class), so a ~ c+1 (transitivity).
8. Continue: by induction, a ~ b. Contradiction.

This is a simple well-foundedness argument. The hard part is:
- Formalizing contemporaneous equivalence relations (Lemma 15)
- Formalizing the "gamma_i" sentences (finitely many k-types)
- Proving Lemma 14 (countable very good => good) using lexicographic sums

**Estimated effort**: 200-400 lines of Lean for Theorem 9 alone. But Theorem 4 adds 300-500 lines. Total: 500-900 lines.

### 7.3 Approach C: Direct IsSuccArchimedean (current approach)

**Idea**: Prove that for any a <= b in limit_dom, there exists n with succ^n(a) = b.

**Analysis**: The current sorry site (line 1068) has:
```
set N := max na nb
have ha_N : a.val in omega_chain_val(N).dom
have hb_N : b.val in omega_chain_val(N).dom
sorry
```

The approach is to use the omega-chain stage N where both a and b are present. At stage N, the finite domain `omega_chain_val(N).dom` is a finite set of rationals. In the discrete case, this finite set with the induced successor function forms a finite discrete linear order. In a finite discrete linear order, succ^n connects any two comparable elements.

**The gap**: The succ function on limit_dom is defined via `limit_dom_has_succ`, which extracts the immediate successor from the C5 property. But the succ in limit_dom may NOT match the succ in omega_chain_val(N).dom. The issue is that limit_dom = union of all omega_chain_val(n).dom for n in N. Between stages N and N+1, new points may be inserted. The successor of a in omega_chain_val(N).dom might be some point c, but in limit_dom, new points might have been inserted between a and c, making the limit_dom successor different.

Wait — in the DISCRETE case, no new points are inserted between a and its successor in omega_chain_val(N).dom. This is because the C4 property (counterexample elimination) only inserts points in the GUARD INTERVAL of a negative Until formula. If `neg U(eta, xi)` is in limit_f(a) and eta is in limit_f(c) where c = succ(a), then a point is inserted between a and c. But in the discrete case, `U(T, bot)` is in every MCS, meaning there are no points between a and its successor. So `neg U(eta, xi)` at a with eta at succ(a) would require a point z with a < z < succ(a) and neg xi in limit_f(z). But there ARE no such z (discreteness). So the C4 property is vacuously satisfied.

**This means**: in the discrete case, the omega-chain construction NEVER inserts points between consecutive elements of a discrete block. The successor structure of limit_dom is exactly the successor structure established by stage N for any N where the elements are present.

**If this argument is correct**: then succ^n(a) = b can be proved by induction on the number of elements between a and b in omega_chain_val(N).dom. Since omega_chain_val(N).dom is a Finset, this is finite, and the result follows.

**Estimated effort**: 50-150 lines of Lean. This is MUCH less than the Reynolds approach.

### 7.4 Approach D: Hybrid (Prove Prior-UZ derivable from BX + uniformity + finiteness-of-limit-dom-intervals)

**Idea**: Instead of adding Prior-UZ as a new axiom, prove that the limit model satisfies Prior-UZ as a consequence of the construction. Then use Theorem 4 + Theorem 9 to complete.

**Analysis**: This combines the worst of both worlds — the Doets formalization overhead PLUS proving Prior-UZ for the limit model. Not recommended.

## 8. Verdict and Recommendations

### Primary Recommendation: Approach C (direct IsSuccArchimedean)

The direct proof of IsSuccArchimedean is the shortest path. The key insight from this Reynolds analysis is:

**In the discrete case, the omega-chain construction preserves the successor structure.** No new points are inserted between discrete-consecutive elements because:
1. The C4 counterexample elimination only inserts points in guard intervals.
2. In the discrete case, `U(T,bot)` in every MCS means guard intervals between consecutive points are empty.
3. Therefore C4 is vacuously satisfied between consecutive points, and no insertions happen.

This means: if a and b are both in omega_chain_val(N).dom, and the elements between them in that finite set are {a = x0, x1, ..., xm = b}, then in limit_dom these are still consecutive: succ(xi) = x(i+1) for each i. Therefore succ^m(a) = b.

**The proof strategy**:
1. Show that in the discrete case, no points are inserted between consecutive elements of any omega_chain_val(N).dom.
2. For a <= b with both in omega_chain_val(N).dom, count the elements between them in the finset.
3. By induction on this count, prove succ^count(a) = b.

### Secondary Recommendation: If Approach C fails, use Approach B (full Reynolds)

If the "no insertion between discrete-consecutive elements" argument has a flaw (e.g., the C5 property DOES insert points in ways that break the argument), then the Reynolds approach (Theorem 4 + Theorem 9) is the next best option. But this requires adding Prior-UZ as an axiom and formalizing approximately 500-900 lines of new mathematical content.

### NOT Recommended: sorry deferral or sorry tolerance

Per the zero-debt policy, the sorry at `limitDomSubtype_isSuccArchimedean` must be resolved. The Reynolds analysis confirms that the mathematics IS correct (the completeness for Z is a well-established result) and provides two concrete proof strategies, either of which should succeed.
