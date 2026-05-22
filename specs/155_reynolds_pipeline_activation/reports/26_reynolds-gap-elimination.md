# Reynolds Gap Elimination Research Report (Lemmas 6-13, Theorem 14)

**Source**: Reynolds 1994, "Axiomatising U and S over Integer Time", Section 7 ("No gaps between equivalence classes")

**Strategy**: Proof by contradiction. Assume a contemporaneous equivalence relation ~M on a Prior structure M has a class that "ends at a gap." Derive a contradiction by:
1. Using US expressive completeness (Theorem 5) to define temporal R that detects "gap on right"
2. Showing R-intervals have structural regularity (Lemmas 7-10)  
3. Performing "model surgery" (Lemma 12) -- replacing a bad interval by one class
4. Deriving contradiction: R holds in the surgery model but cannot (Lemma 13)

---

## Literature Proof Structure

### Definitions (from Reynolds 1994, p. 124-125)

**Contemporaneous equivalence relation**: A binary relation ~ on a structure M is defined by a monadic formula epsilon(x,y) satisfying:
- ~M is an equivalence relation partitioning M into intervals
- ~M depends only on "contemporary properties": a ~_M b iff M|[a,b] |= epsilon(a,b)

**rho(x)**: The FO formula saying "x's ~-class ends in a gap on the right":
```
rho(x) = exists s > x: not-epsilon(x,s) AND
         forall z (x < z AND epsilon(x,z) implies exists y (z < y AND epsilon(x,y)))
```

**R**: The temporal formula (guaranteed by Theorem 5) true exactly where rho is true.

**L**: The dual formula for "class ends in a gap on the left."

**Bad point**: Where R or L holds.

**Bad interval**: A maximal non-empty interval in which R or L holds throughout.

---

### Step Map (Lemmas 6-13 -> Theorem 14)

| # | Lemma | Statement | Proof Type | Dependencies |
|---|-------|-----------|-----------|--------------|
| 1 | Lemma 6 | There is a US-formula R that holds in any Prior structure exactly at points whose ~-class ends in a gap on the right. Dually L. | Application of Theorem 5 | Theorem 5 (US expressive completeness over Prior structures) |
| 2 | Lemma 7 | The maximal intervals in which R holds are open intervals which, if bounded, have elements of M as their (excluded) end points. | Prior-U/S application | Lemma 6 |
| 3 | Lemma 8 | There is no last class and no first class in any maximal interval of R. | Prior-U application | Lemma 6, Theorem 5 |
| 4 | Lemma 9 | If a temporal formula holds somewhere in one ~-class in a maximal interval of R, then it holds somewhere in each ~-class in the interval. Furthermore, all ~-classes in a maximal interval of R are elementarily equivalent (as substructures of M). | Prior-U/S + expressive completeness | Lemma 6, Theorem 5 |
| 5 | Lemma 10 | Bad points only occur in non-singleton bad intervals. In any bad interval both R and L hold throughout. Any bad interval, if bounded, has excluded end points in M (neither R nor L holds at these). | Prior-U/S + Lemma 9 | Lemmas 7, 8, 9 |
| 6 | Lemma 11 | If a formula B is true for a while at the start of a ~-class in a bad interval then it holds throughout the bad interval. Similarly at the end. If a formula is true anywhere in a bad interval it is true arbitrarily close to each end of each class. | Prior-U + Lemma 9 | Lemmas 6, 9 |
| 7 | Lemma 12 | Model surgery: Let Q- precede the bad interval, Q+ follow it, Q0 be the bad interval, I be any one of its ~-classes. Then for all temporal formulas A, for all t in N = M|Q- union I union Q+: M |= A(t) iff N |= A(t). | Induction on formula + 14 sub-cases | Lemmas 9, 11 |
| 8 | Lemma 13 | In fact there can't have been any bad points. | Contradiction via surgery | Lemma 12, Lemma 7 |
| 9 | Theorem 14 | ~-classes of a contemporaneous equivalence relation on a Prior structure do not end at gaps. | Direct from Lemma 13 | Lemma 13 |

---

### Detailed Lemma Statements and Proof Sketches

#### Lemma 6 (Foundation)

**Statement**: Suppose ~ defines the contemporaneous equivalence relation ~_N on any structure N. Then there is a US-formula R which holds in any Prior structure N exactly at those points whose ~_N-class ends in a gap on the right. Dually L.

**Proof**: By expressive completeness of U and S over Prior structures (Reynolds Theorem 5), since rho(x) is a monadic formula, there exists a temporal formula R equivalent to rho(x) in all Prior structures.

**Lean infrastructure needed**: 
- `US_expressively_complete_over_prior` (Phase 5')
- The formula `rho` expressed as a `MonadicFormula sig 1`

**Effort estimate**: ~100-150 lines. Most of the effort is encoding rho(x) as a MonadicFormula and applying Theorem 5. The result is an existential: there exists R such that ...

---

#### Lemma 7 (R-interval openness)

**Statement**: The maximal intervals in which R holds are open intervals which, if bounded, have elements of M as their (excluded) end points.

**Proof sketch** (Reynolds):
1. R holding at t implies rho(t), i.e., t's ~-class ends at a gap. This means R holds for a while after t (up until that gap). So t is in a non-singleton interval of R.
2. If R doesn't hold forever after t, apply Prior-U to R: either M has a last point where R holds (impossible given rho) or a first point of ~R. The first-point-of-~R IS the excluded endpoint.
3. For the left boundary: apply Prior-S. Either R holds always before t, or there's a last-point-of-~R (excluded endpoint), or a first-point-of-R. The third case is ruled out by contradiction with Prior-U.

**Lean infrastructure needed**:
- `h_prior_UZ` hypothesis (already in the theorem signature)
- Encoding "maximal interval" as a predicate on sets

**Effort estimate**: ~80-100 lines.

---

#### Lemma 8 (No first/last class)

**Statement**: There is no last class and no first class in any maximal interval of R.

**Proof sketch**: 
- Last class: A last class wouldn't end in a gap (contradiction with R holding there).
- First class: By expressive completeness, the property "being in a first class of a maximal R-interval" is temporal. If there IS a first class, then no immediately subsequent class satisfies this property. So this formula holds up to a gap and is false arbitrarily soon afterwards -- contradicting Prior-U.

**Effort estimate**: ~60 lines. Short but uses Theorem 5 again.

---

#### Lemma 9 (Elementary equivalence of classes in R-interval)

**Statement**: If a temporal formula holds somewhere in one ~-class in a maximal R-interval, then it holds somewhere in each ~-class in that interval. Furthermore, each pair of ~-classes are elementarily equivalent (as substructures of M).

**Proof sketch**:
1. First part: Suppose A holds in one class but not in another. By expressive completeness, find B true in ~-classes containing A and false in others. B holds throughout one class up to gap, false after -- contradicts Prior-U.
2. Second part: For any monadic sentence phi, relativize it to get phi_restricted (quantifiers restricted to where epsilon(x,.) holds). This gives a temporal formula via expressive completeness. If it holds in one class, must hold in all (by first part).

**Effort estimate**: ~130 lines. Requires relativization infrastructure.

---

#### Lemma 10 (Bad interval structure)

**Statement**: Bad points only occur in non-singleton bad intervals. In any bad interval both R and L hold throughout. If bounded, has excluded end points.

**Proof sketch** (Reynolds):
1. Show L holds wherever R does: Suppose a maximal R-interval has ~L somewhere. By Lemma 9, ~L holds throughout one class. A class beginning at a point (not a gap on left) means the preceding class ends at a non-gap -- contradicting R. A class not beginning at a gap and having a predecessor means the predecessor doesn't end at a gap -- contradicting R.
2. Show the interval is non-singleton: from Lemma 7.
3. Excluded endpoints: from Lemma 7.

**Effort estimate**: ~80 lines. Builds directly on Lemmas 7-9.

---

#### Lemma 11 (Formula propagation in bad intervals)

**Statement**: If a formula B is true for a while at the start of a ~-class in a bad interval then it holds throughout the bad interval. Similarly at the end. If a formula is true anywhere in a bad interval it is true arbitrarily close to each end of each class.

**Proof sketch**: 
1. Suppose B holds for a while after a gap gamma (start of a class) but ~B holds somewhere in the bad interval. By Lemma 9 (here called "lemma 4" in original), ~B also holds in the same class (gamma, delta). Find C = "in-class-after-some-~B". C is true at end of class up to gap, false after -- contradicts Prior-U.
2. Negation gives second part.

**Effort estimate**: ~60 lines.

---

#### Lemma 12 (Model Surgery) -- THE CRITICAL LEMMA

**Statement**: Let Q- be all points preceding a bad interval, Q+ all after, Q0 the bad interval itself, I any one of its ~-classes. Let N = M|_{Q- union I union Q+}. Then for all temporal formulas A, for all t in N: M |= A(t) iff N |= A(t).

**Proof sketch**: Induction on formula construction. Cases: atomic/boolean are immediate. For U(A,B) (and S(A,B) similarly):

**(=>)**: Given M |= U(A,B)(t) with witness s. Cases by position of t and s:
1. t < s in Q-: Apply induction hypothesis to A,B at s and all between.
2. t in Q-, s in Q0: A holds somewhere in Q0 so in I (Lemma 9). B holds into Q0, so everywhere in Q0 (Lemma 11 extended). By IH, B holds everywhere in I in N.
3. t in Q-, s in Q+: B throughout I in both M and N.
4. t < s in I: Direct IH.
5. t in I, s later in Q0: By Lemma 9, A is true arb. close to end of I in M/N. B true throughout I in M.
6. t in I, s in Q+: B true throughout I.
7. t < s in Q+: Direct IH.

**(<=)**: Given N |= U(A,B)(t). Cases:
1. t < s in Q-: IH.
2. t in Q-, s in I: B from t to end of Q-. B at start of I in N, so in M. By Lemma 9, B throughout Q0. A holds in I in N so in M.
3. t in Q-, s in Q+: B throughout I in N so in M. Lemma 9 gives B throughout Q0.
4. t < s in I: IH.
5. t in I, s in Q+: B throughout I.
6. t < s in Q+: IH.

**Total cases**: 7 forward + 6 backward = 13 sub-cases (plus S gives another 13 = 26, but S is dual).

**Effort estimate**: ~250-300 lines. This is the largest single lemma. Each case is 10-30 lines. The induction structure is straightforward but tedious.

---

#### Lemma 13 (No bad points -- the contradiction)

**Statement**: In fact there can't have been any bad points anyway.

**Proof sketch**:
1. By Lemma 12, R holds in I in N (temporal truth preserved).
2. But R holds at a point in any Prior structure iff the ~-class of that point ends in a gap (by the DEFINITION of R via rho).
3. N IS a Prior structure: any counterexample to Prior-U in N would also be one in M.
4. By contemporaneity of epsilon, I as subset of N is still one ~_N-class. Is the class bigger in N? No: R holds, so the class is bounded above. Q+ is non-empty (by Lemma 7) and begins with a point q. ~R holds at q in M and so in N. So q is not in I's class in N. The class ends just before q.
5. R cannot have been true in this class after all -- contradiction.

**Effort estimate**: ~60 lines.

---

#### Theorem 14 (Gap Elimination)

**Statement**: Suppose ~ is a contemporaneous equivalence relation on a Prior structure M. Then the ~-classes do not end at gaps.

**Proof**: Direct consequence of Lemma 13 (there are no bad points means no class ends at a gap).

**Effort estimate**: ~10-30 lines. Just assembly of Lemmas.

---

## Dependency Graph

```
                     Theorem 5 (Phase 5')
                         |
                    Lemma 6 (R exists)
                    /    |    \
              Lemma 7  Lemma 8  Lemma 9
                |       /   |     |
              Lemma 10 ----+     |
                |               |
              Lemma 11 ---------+
                |
              Lemma 12 (model surgery)
                |
              Lemma 13 (contradiction)
                |
              Theorem 14
```

Linear dependency chain with main branch:
```
Thm 5 -> L6 -> L7 -> L10 -> L11 -> L12 -> L13 -> Thm 14
                L6 -> L8 -> L10
                L6 -> L9 -> L10
                      L9 -> L11
                      L9 -> L12
```

---

## Current Lean Infrastructure Assessment

### Available (can be used directly)

| Component | Location | Status |
|-----------|----------|--------|
| `OrderedMonadicStructure` | MonadicFO.lean:103 | sorry-free |
| `subinterval` | MonadicFO.lean:129 | sorry-free |
| `contemp_equiv` | IntegerModel.lean:694 | sorry-free |
| `contemp_equiv_is_equiv` | IntegerModel.lean:710 | sorry-free |
| `temporal_truth` | Table.lean:182 | sorry-free |
| `stavi_temporal_truth` | StaviConnectives.lean:157 | sorry-free |
| `StaviFormula` | StaviConnectives.lean:135 | sorry-free |
| `orderedSum` | NEquivalence.lean:122 | sorry-free |
| `no_gaps_discrete` (signature) | IntegerModel.lean:837 | **sorry'd** (Phase 6 will fill) |
| `h_prior_UZ` / `h_prior_SZ` | (hypothesis pattern in one_class) | Available |

### Needed but not yet available (blocked on earlier phases)

| Component | Phase | Status |
|-----------|-------|--------|
| `US_expressively_complete_over_prior` | Phase 5' | NOT STARTED |
| `stavi_expressive_completeness` | Phase 4C | sorry'd (EFGames.lean:5500) |

### What Phase 6 needs to BUILD (new infrastructure)

1. **A "Prior structure" predicate**: Currently only hypotheses `h_prior_UZ`/`h_prior_SZ` are passed. Need a bundled predicate or class `IsPriorStructure M atomMap`.

2. **The rho formula**: Need to encode "x's ~-class ends in a gap on the right" as a `MonadicFormula sig 1`.

3. **Model surgery construction**: Construct N = M restricted to Q- union I union Q+ as an `OrderedMonadicStructure`. This is NOT simply a subinterval -- it's a lexicographic sum of three pieces with a "hole" (removing the bad interval except one class). May use `orderedSum` with index `Fin 3` or `Bool × Bool`.

4. **Maximal interval characterization**: Formalize what a "maximal interval in which R holds" means.

5. **Prior-structure preservation under restriction**: Show that restricting M to a convex subset preserves Prior-U/S validity.

---

## Feasibility Assessment

### Realistic effort estimate

| Task | Plan estimate | Revised estimate | Rationale |
|------|---------------|-----------------|-----------|
| 6.1 (Lemma 6) | 100-150 | 120-180 | Encoding rho as MonadicFormula is non-trivial |
| 6.2 (Lemma 7) | 80-100 | 80-120 | Standard Prior-U argument |
| 6.3 (Lemma 8) | 60 | 60-80 | Uses Theorem 5 again (existential) |
| 6.4 (Lemma 9) | 130 | 150-200 | Relativization + two-part proof |
| 6.5 (Lemma 10) | 80 | 80-100 | Builds on 7-9 |
| 6.6 (Lemma 11) | 60 | 60-80 | Standard |
| 6.7 (Lemma 12) | 250-300 | 350-450 | 14 cases x ~25 lines; surgery construction itself ~80 lines |
| 6.8 (Lemma 13) | 60 | 60-80 | Contradiction assembly |
| 6.9 (Theorem 14) | 10-30 | 10-30 | Wrapper |
| Infrastructure | (not counted) | 100-150 | IsPriorStructure, rho encoding, surgery type, convex restriction |
| **TOTAL** | 830-960 | **1070-1470** | |

### Key risk factors

1. **Blocking dependency on Phase 5'**: Phase 6 CANNOT proceed without `US_expressively_complete_over_prior`. Lemmas 6, 8, 9 ALL use expressive completeness as a subroutine. Without it, these lemmas would need sorry.

2. **Model surgery type construction**: The surgery model N = M|_{Q- union I union Q+} is NOT a standard subinterval. It requires:
   - Defining a subtype of M.carrier (elements in Q- union I union Q+)
   - Proving this subtype inherits LinearOrder
   - Showing predicate interpretations transfer correctly
   - This is closer to an ordered sum than a restriction

3. **Prior-structure preservation**: The surgery model N must be proven to be a Prior structure. Reynolds says "any counterexample point in N is also one in M" -- this works because N is a convex-ish restriction. But formalizing this requires showing that the U-witness structure is preserved.

4. **Line count overshoot**: The plan estimates 800-1000 lines. The realistic estimate is 1070-1470 lines. The main culprit is Lemma 12 (model surgery) which has 14 forward + backward cases for U, and 14 more for S (but S is truly dual, so perhaps ~10 lines to invoke a symmetry lemma).

### Mitigations

1. **For the blocking dependency**: Phase 6 can be structured to ACCEPT `US_expressively_complete_over_prior` as a hypothesis. This means the file can be written with a parameter rather than importing the result. Wire-up happens in Phase 8.

2. **For model surgery type**: Use `OrderedMonadicStructure.restrict` (to be defined) taking a convex predicate P on M.carrier and producing a substructure on {x | P x}. This avoids the complexity of ordered sums.

3. **For line count**: Lemma 12's cases can be organized with helper tactics or modular case lemmas. The S cases are perfectly dual to U cases.

---

## Recommendation

**Phase 6 is feasible but oversized**. Recommend splitting into two sub-phases:

- **Phase 6A** (Lemmas 6-11, infrastructure): ~600-800 lines. Can be marked [COMPLETED] independently.
- **Phase 6B** (Lemma 12 model surgery, Lemma 13, Theorem 14): ~500-700 lines.

The critical blocker is Phase 5'. Without it, Phase 6 must accept expressive completeness as a hypothesis parameter (which is fine for modular development but means `no_gaps_discrete` won't be sorry-free until 5' is also done).

---

## How Theorem 14 wires into IntegerModel.lean

The sorry at line 859 (`no_gaps_discrete`) has this signature:
```lean
theorem no_gaps_discrete (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : ...)
    (h_prior_SZ : ...)
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c)
```

Theorem 14 says: "~-classes do not end at gaps." In the discrete context (`SuccOrder + PredOrder`), a "class ending at a gap" IS exactly having a boundary between c and succ(c). So Theorem 14 proves: there is no point where a ~-class ends at a gap. This means if a and b are in different classes, there must be a boundary at some successor pair -- which is exactly what `no_gaps_discrete` produces (the existential witness c).

Actually, looking more carefully: `no_gaps_discrete` asserts the EXISTENCE of a boundary at a successor pair. Theorem 14 says boundaries DON'T end at gaps. These are complementary:

- Theorem 14 tells us: all class boundaries are at points (not gaps).
- In a discrete order, "at a point" = "at a successor pair" (since between any two elements there's a successor pair).
- So if a and b are in different classes, walking from a toward b, we must cross a class boundary. That boundary is at some (c, succ(c)). Hence c ~M a but succ(c) is NOT ~M a.

The wiring in Phase 8 will:
1. Apply Theorem 14 to get "no gap boundaries"
2. Use discreteness to turn "boundary exists" into "boundary at successor"
3. Return the existential witness

This confirms the plan's Phase 8 estimate of ~20-40 lines is reasonable.
