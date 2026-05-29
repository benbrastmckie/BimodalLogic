# Literature Extraction: succ_cofinal (Archimedean Property of the Limit Domain)

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Trace exactly how Burgess, Reynolds, GHR93/94, and Doets handle the Archimedean/gap-elimination property for the discrete chronicle construction.

---

## Literature Proof Structure

**Source**: Reynolds 1994 ("Axiomatizing U and S over Integer Time"), Sections 5-9
**Strategy**: Indirect -- Burgess construction gives a countable discrete Prior structure, then Reynolds proves it is order-isomorphic to Z via gap elimination + lexicographic sums

### Step Map

1. **Burgess-Xu Theorem 2 + Corollary 3** (Reynolds Section 5)
   - Given a US/Z-consistent formula A0, use Burgess-Xu strong completeness for linear time to get a model M with:
     (a) Countable, discrete, no endpoints flow of time
     (b) M satisfies A0 at point t
     (c) All instances of Prior-UZ and Prior-SZ valid in M
   - This is the omega-chain chronicle construction (Burgess 1982/1984)

2. **Expressive completeness of U,S over Prior structures** (Reynolds Section 6, Theorem 5)
   - In any Prior structure (where U' and S' are trivial), {U,S} is expressively complete for monadic first-order formulas
   - Proof: U'(A,B) is equivalent to false in Prior structures (by Prior-UZ, any F(A) gives U(A,~A), so U'(A,B) = ~U(T,~A) is vacuous). Similarly S'. Then by GHR93 Theorem 4, {U,S,U',S'} is expressively complete for all linear structures. Dropping U',S' (trivially false) gives {U,S} expressively complete

3. **Contemporaneous equivalence (~M)** (Reynolds Section 8, Lemma 17)
   - Define "good" = k-equivalent to a Z-interval structure
   - Define "very good" = every subinterval is good
   - Define a ~M b iff [a,b] (or [b,a]) is very good
   - ~M is a contemporaneous equivalence relation (Lemma 17): defined by a monadic formula epsilon(x,y), partitions M into convex classes, depends only on the substructure between the two points

4. **No gaps theorem** (Reynolds Section 7, Theorem 14, via Lemmas 6-13)
   - The ~M-classes cannot end at gaps in any Prior structure
   - This is the CENTRAL gap elimination result

5. **One-class theorem** (Reynolds Section 8, proof of Theorem 15)
   - If M is not good, M is not very good, so there exist a,b with different ~M-classes
   - By Theorem 14: a's class cannot end at a gap, so it includes some point c but not succ(c)
   - But [c, succ(c)] is always very good (finite interval), so c ~M succ(c)
   - By transitivity of ~M: a ~M succ(c), contradicting the assumption
   - Therefore M is good (all in one ~M-class)

6. **Good implies Z-isomorphic** (Reynolds Lemma 16)
   - Countable + very good implies good
   - Good means k-equivalent to a Z-interval structure
   - Countable discrete structure k-equivalent to Z-interval means there exists a Z-structure satisfying the same monadic sentences

7. **Truth transfer** (Reynolds Theorem 18)
   - The Z-structure satisfies the same monadic sentences of depth <= k as M
   - Choose k larger than the table depth of A0
   - Transfer: Z satisfies the table formula of A0, hence A0 itself

### Dependencies
- Step 4 depends on Step 2 (expressive completeness needed to define R = temporal formula for "gap on the right")
- Step 5 depends on Steps 3 and 4
- Step 6 depends on Step 5
- Step 7 depends on Steps 1 and 6

---

## How the Literature Proves the Archimedean Property

### Key finding: The literature does NOT prove IsSuccArchimedean directly

Neither Burgess nor Reynolds proves that the limit domain of the chronicle construction is successor-Archimedean (i.e., that iterating succ from any point a eventually reaches or passes any point b > a). Instead:

**Burgess 1984 (Section 2.6)**: Burgess proves the chronicle construction for discrete orders produces a countable discrete linear order without endpoints. He does NOT claim it is order-isomorphic to Z. He does NOT prove the succ-orbit is cofinal. His construction gives S-relations (immediate successor pairs) and proves that once xSy is set, no point is ever inserted between x and y (by parts (c),(d) of the Lemma). But this says nothing about whether the entire structure is one Z-component or multiple Z-components separated by gaps.

**Reynolds 1994**: Reynolds explicitly uses a DIFFERENT strategy. He takes the Burgess construction output (Corollary 3) and then proves it is Z-isomorphic via a multi-step pipeline:
1. Define an appropriate contemporaneous equivalence ~M
2. Prove ~M classes cannot end at gaps (Theorem 14)
3. Conclude all of M is one ~M class (Theorem 15)
4. Transfer to Z via Lemma 16

Reynolds DOES NOT assume or prove that the chronicle limit domain is Archimedean. Instead, he BYPASSES the question by:
- Working at the level of monadic first-order k-equivalence (not exact isomorphism)
- Using gap elimination at the equivalence-class level (not the point level)
- Constructing a NEW Z-model k-equivalent to M (not showing M itself is Z-isomorphic)

### The gap question is real

Report 32_burgess-omega-chain.md (from earlier task 155 research) correctly identified that:
- The Burgess construction CAN produce gaps (Z+Z models)
- In the constant-MCS case, all temporal axioms are trivially satisfied, and no formula distinguishes orbit points from gap points
- Reynolds confirms this implicitly: he needs a separate gap-elimination pipeline precisely because the construction alone does not guarantee it

The "frozen guard" property (`adj_g_mem_limit_f`, ChronicleConstruction.lean:1357) says: if phi is in the guard g(a,b) for adjacent pair (a,b) at stage k, then phi is in limit_f(w) for any limit-domain point w between a and b. When the guard is bot (from U(T, bot) resolution), this means bot is in limit_f(w) for any w between the pair -- which is impossible since no MCS contains bot. So NO limit_dom point can be inserted between a and b. This gives the SuccOrder/PredOrder properties (discrete adjacency is preserved). But it does NOT prevent the limit domain from having multiple Z-components (each component is a complete succ-orbit, but there could be multiple orbits separated by gaps in the rational line).

---

## Detailed Analysis of Reynolds' Theorem 14 (No Gaps)

### What Theorem 14 says

"Suppose that ~ is a contemporaneous equivalence relation on a Prior structure M. Then the ~-classes do not end at gaps."

### What Theorem 14 requires

1. **Expressive completeness of {U,S} over Prior structures** (Reynolds Theorem 5)
   - This is the CRITICAL prerequisite
   - Allows defining temporal formulas R, L, B, C that characterize gap-ending, first/last classes, and other structural properties
   - Without this, the Lemmas 6-13 cannot be stated or proved

2. **Prior-UZ and Prior-SZ semantic validity** in M
   - Fp -> U(p, ~p) semantically valid at all points
   - Pp -> S(p, ~p) semantically valid at all points
   - These are the key axioms that prevent definable gaps

### Proof structure (Lemmas 6-13 -> Theorem 14)

**Lemma 6**: By expressive completeness, there exists a temporal formula R true exactly where rho(x) = "x's ~M-class ends in a gap on the right." Dually L for left gaps.

**Lemma 7**: Maximal intervals of R are open intervals. If bounded, their excluded endpoints are elements of M.
- Proof uses Prior-UZ: if R holds at t, it continues for a while (up to a gap). The interval cannot begin at a "first point of R" because that would create a class whose left end is a non-gap point, contradicting the construction.

**Lemma 8**: No first or last class in any maximal R-interval.
- Last class wouldn't end in a gap (it reaches the end of the R-interval)
- First class: use expressive completeness to define "in a first class," show it holds up to a gap and is false after, contradicting Prior-UZ

**Lemma 9**: All ~-classes within a maximal R-interval are elementarily equivalent (as substructures of M).
- If formula A holds in one class but not another, use expressive completeness + Prior-UZ to derive contradiction
- The argument: define B = "A occurs somewhere in my ~-class," find where B transitions from true to false, this transition happens at a gap boundary, contradicting Prior-UZ

**Lemma 10**: Bad points (where R or L hold) only occur in non-singleton "bad intervals" where BOTH R and L hold throughout.
- Uses Lemmas 7, 8, 9 to show L holds wherever R does (if L failed somewhere in an R-interval, the classes would have non-gap left endpoints, contradicting the definition)

**Lemma 11**: In a bad interval, if a formula B holds for a while at the start of a ~-class, it holds throughout the entire bad interval.
- Proof uses expressive completeness + Prior-UZ: if B fails somewhere, construct C = "there is ~B before in my class," C is true at the end and false at the start of the gap, contradicting Prior-UZ

**Lemma 12 (Model Surgery)**: Replace a bad interval Q0 by one of its ~-classes I. The resulting structure N (domain Q- union I union Q+) preserves temporal truth at all points.
- Proof by induction on formula structure
- Key cases for U(A,B): when t is in Q- and s in Q0, use Lemma 9/11 to show A holds somewhere in I and B holds throughout I

**Lemma 13**: There cannot have been any bad points.
- R holds in I subset N (by Lemma 7, R is true of points whose ~-class ends in a gap)
- But N is still a Prior structure (Prior-UZ instances in N follow from M)
- In N, the ~N-class of I is bounded above by q (start of Q+), and ~R holds at q
- So the ~N-class of I ends just before q -- NOT at a gap
- Contradiction: R should not hold at points whose class doesn't end at a gap

---

## Formalization Status in the Lean Codebase

### What is formalized

| Component | Location | Status |
|-----------|----------|--------|
| Burgess chronicle construction | ChronicleConstruction.lean | Sorry-free |
| limit_dom, limit_f, limit_g | ChronicleConstruction.lean | Sorry-free |
| C0, C5, C5' at limit | ChronicleConstruction.lean | Sorry-free |
| adj_g_mem_limit_f (frozen guard) | ChronicleConstruction.lean:1357 | Sorry-free |
| SuccOrder / PredOrder on LimitDomSubtype | ChronicleToCountermodel.lean:920-960 | Sorry-free |
| succ_orbit_convex | ChronicleToCountermodel.lean:1093 | Sorry-free |
| backward_G / backward_F / backward_P | ChronicleToCountermodel.lean:1703-1839 | Sorry-free |
| succ_cofinal Steps 1-8 | ChronicleToCountermodel.lean:1557-1695 | Sorry-free |
| succ_cofinal Step 9 | ChronicleToCountermodel.lean:1885 | **ROOT SORRY** |
| limitDomSubtype_isSuccArchimedean | ChronicleToCountermodel.lean:1893 | Depends on sorry |
| succ_embed_surjective | ChronicleToCountermodel.lean:2817 | Depends on sorry |
| cantor_bfmcs_discrete_restricted_tc | ChronicleToCountermodel.lean:3142 | Depends on sorry |
| cantor_bfmcs_discrete_restricted_fuc | ChronicleToCountermodel.lean:3197 | Depends on sorry |
| cantor_bfmcs_discrete_restricted_buc | ChronicleToCountermodel.lean:3066 | Sorry-free |
| OrderedMonadicStructure | GoodStructures.lean | Sorry-free |
| contemp_equiv (~M) | GoodStructures.lean | Sorry-free |
| contemp_equiv_is_equiv | GoodStructures.lean | Sorry-free |
| no_boundary_at_successor | GoodStructures.lean:849 | Sorry-free |
| no_gaps_discrete (Theorem 14) | GoodStructures.lean:820 | **SORRY** |
| one_class (Theorem 15) | GoodStructures.lean:883 | Depends on sorry |
| very_good_to_good (Lemma 16) | ShiftAndGlue.lean:817 | Has sorries |
| US expressive completeness over Prior | Not formalized | **MISSING** |
| countermodel_discrete | Transfer.lean:782 | Delegates to chronicle path |

### What is NOT formalized (and blocks Theorem 14)

1. **Reynolds Theorem 5**: US expressive completeness over Prior structures. The codebase has `US_expressively_complete_over_Z` (over Z only), not over general Prior structures. The general case requires showing U'(A,B) equiv bot and S'(A,B) equiv bot in Prior structures, then invoking GHR93/94 Theorem 9.3.1.

2. **Lemmas 6-13**: The detailed model surgery argument. These require defining temporal formulas R, L, B, C via expressive completeness, and then performing inductive truth preservation through the surgery model N.

3. **The "gap elimination" pipeline**: Lemmas 6-13 culminating in Theorem 14 are approximately 1500-2500 lines of formal proof.

---

## Potential Formalization Challenges

### Step 2 (Expressive completeness over Prior structures)
- **Challenge**: The EFGames infrastructure (EFGames/StaviCompleteness.lean) has sorries in the GHR93 decomposition theorem. US expressive completeness over Prior structures would need to go through the Stavi connective machinery or find a direct route.
- **Lean-specific**: The current `US_expressively_complete_over_Z` theorem applies only when the carrier IS Z. Generalizing requires either: (a) proving U'(A,B) equiv bot in Prior structures directly, then applying GHR94 9.3.1, or (b) constructing the EF game argument for Prior structures from scratch.

### Step 4 (Gap elimination / Theorem 14)
- **Challenge**: Lemmas 6-13 require repeated use of expressive completeness to construct formulas R, L, B, C with specific properties. Each application needs a monadic FO formula to be expressed as a temporal formula. This is highly non-constructive.
- **Lean-specific**: The model surgery (Lemma 12) requires defining a new temporal structure by domain restriction and proving truth preservation by induction on formula depth. This is a large induction (6-7 cases for each direction).

### Step 5 (One-class theorem)
- **Challenge**: Relatively straightforward given Theorem 14 + no_boundary_at_successor + transitivity. The codebase already has the structure (GoodStructures.lean:883).
- **Lean-specific**: Depends directly on no_gaps_discrete being sorry-free.

### The fundamental difficulty
The gap elimination argument is SEMANTIC (working with truth in structures) rather than SYNTACTIC (working with derivability). This is inherent to Reynolds' approach: he cannot prove the chronicle IS Z-isomorphic, so he uses k-equivalence transfer instead. This semantic approach requires the full expressive completeness machinery, which is the most complex part of the formalization.

---

## Implications for succ_cofinal

### succ_cofinal is NOT provable from temporal axioms alone

This is confirmed by both the literature analysis and the codebase comments (ChronicleToCountermodel.lean:1809-1815). The gap scenario (orbit converging to L, pred-chain descending from above L) is consistent with all temporal axioms in the constant-MCS case. No temporal formula can distinguish orbit points from pred-chain points when all MCS labels are identical.

### Three resolution paths (ranked by literature alignment)

**Path A: Reynolds gap elimination (Theorem 14)**
- Literature support: STRONG (this is Reynolds' actual proof)
- Effort: 2000-3000 lines (Lemmas 6-13, expressive completeness)
- Blocked by: Expressive completeness over Prior structures (Theorem 5)
- Status: Infrastructure partially built (GoodStructures.lean has definitions, GHR93 EFGames has partial decomposition)

**Path B: Construction-level argument (show omega-chain cannot produce gaps)**
- Literature support: NONE (no published proof of this approach)
- Effort: 300-600 lines (uncertain)
- Blocked by: Deep interaction with construction internals; may not be true as stated (constant-MCS case appears valid)
- Status: No progress; previous analysis (report 32) concluded "unlikely to work"

**Path C: Direct Z-chain construction (bypass chronicle entirely)**
- Literature support: WEAK (Burgess 1984 Section 2.8 constructs Z-indexed models for well-orders, not general discrete orders)
- Effort: 500-800 lines
- Blocked by: Bundle sorries (g_content_subset_mcs, h_content_subset_mcs) + needs C5 proof equivalent to succ_cofinal
- Status: Demonstrated infeasible (report 48)

### Recommendation

The ONLY viable sorry-free path to `completeness_discrete` through `succ_cofinal` is **Path A** (Reynolds gap elimination). Paths B and C are either unviable or reduce to the same difficulty.

However, there is an alternative architecture: instead of proving `succ_cofinal` (which establishes IsSuccArchimedean for the chronicle limit domain), one could use the Reynolds pipeline to construct a Z-model DIRECTLY from the Prior structure output of Corollary 3, BYPASSING the IsSuccArchimedean requirement entirely. This is what `countermodel_discrete` in Transfer.lean is designed to do -- but it currently delegates to the chronicle path (line 790).

The key insight from the literature: Reynolds NEVER proves IsSuccArchimedean. He proves k-equivalence transfer, which gives a Z-model satisfying the same bounded-depth monadic sentences. This is weaker than isomorphism but sufficient for weak completeness.

---

## Summary

| Finding | Detail |
|---------|--------|
| Burgess construction | Does NOT guarantee Archimedean / Z-isomorphic |
| Burgess 1984 Section 2.6 | Proves discrete adjacency preserved (no insertion between S-pairs), but NOT that the order is one Z-component |
| Reynolds 1994 | BYPASSES IsSuccArchimedean entirely via k-equivalence transfer |
| Reynolds Theorem 14 | Proves no gaps in contemporaneous equivalence classes (NOT in the order itself) |
| Reynolds Theorem 5 | US expressive completeness over Prior structures -- CRITICAL prerequisite, NOT formalized |
| succ_cofinal | CANNOT be proved from temporal axioms alone (constant-MCS scenario consistent with all axioms) |
| Construction-level proof | No literature support; likely impossible (constant-MCS case appears valid) |
| Direct Z-chain | Reduces to same difficulty + has independent Bundle blockers |
| Recommended path | Reynolds pipeline (Theorem 5 -> Theorem 14 -> Theorem 15 -> Lemma 16 -> Theorem 18) |
| Alternative architecture | Bypass succ_cofinal by wiring Transfer.lean to use Reynolds k-equivalence instead of chronicle OrderIso |
