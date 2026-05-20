# Full Reynolds Approach: Implementation Plan for Phase 4 (Gap Elimination)

## Executive Summary

This report provides a complete, step-by-step implementation plan for the full Reynolds approach to eliminating the `no_gaps_discrete` sorry in `IntegerModel.lean`. The plan follows Reynolds 1994 exactly: Stavi connectives (Section 4) -> Theorem 4 (expressive completeness of {U,S,U',S'} over all linear structures, via GHR93 Section 8) -> Theorem 5 (expressive completeness of {U,S} over Prior structures) -> Lemmas 6-13 -> Theorem 14 (gap elimination).

**Current blocker**: `no_gaps_discrete` at line 859 of `IntegerModel.lean` is sorry'd. It needs Reynolds Theorem 5, which needs Theorem 4, which needs the Stavi connectives and the GHR93 game-theoretic proof.

**Key insight for implementation**: We do NOT need to formalize the full GHR93 game-theoretic proof (Section 8). Reynolds Theorem 5 has a SHORT direct proof: in any Prior structure, U'(A,B) is equivalent to False (because Prior-U forbids the gap pattern that U' asserts). So the chain collapses: we only need the DEFINITION of Stavi semantics, state Theorem 4 as an axiom (or prove it separately), prove Theorem 5 directly, then proceed with Lemmas 6-13.

**Recommended approach**: State Theorem 4 as an axiom initially (to unblock the pipeline), prove Theorem 5 from it, complete Lemmas 6-13 and Theorem 14, then return to prove Theorem 4 as a separate task.

---

## 1. Literature Proof Structure

### Source: Reynolds 1994, Sections 4, 6, 7

### Strategy
Indirect contradiction via model surgery. Assumes a contemporaneous equivalence relation has a class ending at a gap in a Prior structure, constructs a temporal formula R detecting the gap, analyzes R-interval structure, performs model surgery (replacing the bad interval by one equivalence class), then derives contradiction.

### Step Map

| Step | Source | Description | Dependencies |
|------|--------|-------------|--------------|
| 0 | R94 S4 | Define Stavi connective semantics U'(A,B), S'(A,B) | None |
| 1 | R94 Thm 4 / GHR93 Thm 3 | {U,S,U',S'} expressively complete over all linear time | Step 0 |
| 2 | R94 Thm 5 | {U,S} expressively complete over Prior structures | Steps 0, 1 |
| 3 | R94 Lem 6 | Temporal formula R detecting gap-on-right | Step 2 |
| 4 | R94 Lem 7 | R-intervals are open with excluded endpoints | Step 3, Prior-U |
| 5 | R94 Lem 8 | No first/last class in R-intervals | Steps 3, 4 |
| 6 | R94 Lem 9 | Elementary equivalence of classes in R-intervals | Steps 3, 5 |
| 7 | R94 Lem 10 | Bad interval structure (R and L hold together) | Step 6 |
| 8 | R94 Lem 11 | Formula propagation in bad intervals | Step 6 |
| 9 | R94 Lem 12 | Model surgery preserves temporal truth | Steps 6, 8 |
| 10 | R94 Lem 13 | Contradiction: no bad points | Steps 4, 9 |
| 11 | R94 Thm 14 | ~M classes do not end at gaps | Step 10 |

---

## 2. Detailed Analysis of Each Step

### Step 0: Stavi Connective Semantics

**What**: Define the semantic evaluation of U'(A,B) and S'(A,B) on ordered monadic structures.

**Reynolds Definition** (Section 4, p.123): U'(A,B) holds at t iff B is true from t until a gap, after which not-B is true arbitrarily soon, but after which A is true for a while.

**First-order table** (p.123):
```
U'(p,q)(t) = exists s > t such that:
  forall u (t < u < s ->
    (exists v (u < v and forall w (t < w < v -> q(w)))
     or forall v (u < v < s -> p(v)))
    and not-forall v (t < v < u -> q(v)))
  and exists u (t < u < s and not-q(u))
  and exists u (t < u < s and forall v (t < v < u -> q(v)))
```

**Implementation decision**: We do NOT need U' and S' as new `Formula` constructors. We only need their SEMANTICS defined on `OrderedMonadicStructure` (as a `Prop`-valued function), or more precisely, their first-order tables as `MonadicFormula sig 1` expressions. The purpose is solely to support Theorem 4 (which gives a temporal equivalent for any FO formula) and Theorem 5 (which shows U' is trivially False on Prior structures).

**Recommended approach**: Define `stavi_U_truth` and `stavi_S_truth` as semantic predicates on `OrderedMonadicStructure`:

```lean
def stavi_U_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula -> sig.preds)
    (t : M.carrier) (A B : Formula) : Prop :=
  -- B true from t up until a gap after which not-B is arbitrarily soon,
  -- and after which A is true for a while
  exists s : M.carrier, t < s /\
    -- not-B somewhere between t and s
    (exists u : M.carrier, t < u /\ u < s /\ not temporal_truth M atomMap u B) /\
    -- B true for a while after t (up to the gap)
    (exists u : M.carrier, t < u /\ u < s /\
      forall v : M.carrier, t < v -> v < u -> temporal_truth M atomMap v B) /\
    -- For each u between t and s: either there's a B-streak from t to
    -- beyond u, or A is true from u to s
    (forall u : M.carrier, t < u -> u < s ->
      (exists v : M.carrier, u < v /\
        forall w : M.carrier, t < w -> w < v -> temporal_truth M atomMap w B)
      \/ (forall v : M.carrier, u < v -> v < s -> temporal_truth M atomMap v A))
```

This semantic definition suffices for Theorem 5's proof (showing it is contradictory in Prior structures).

**Lines**: ~30 for `stavi_U_truth`, ~30 for `stavi_S_truth`.
**File**: New file `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean`

---

### Step 1: Theorem 4 ({U,S,U',S'} expressively complete over all linear time)

**What**: For every monadic FO formula phi(x) with one free variable, there exists a temporal formula A (using U, S, U', S') such that phi(x) <-> A holds uniformly on all linear temporal structures.

**Source**: GHR93 Section 8 (Theorem 3 = our Theorem 4). The proof uses an elaborate game-theoretic argument (Ehrenfeucht-Fraisse games, Theorem 6 of GHR93) spanning pages 108-119 of that paper (about 12 pages of dense mathematics).

**Why this is hard to formalize**: The proof involves:
- Custom EF games (`G_{n;r}`) with a non-standard structure (two rounds: first n elements, then one more)
- Induction on n with a complex bounds relationship (f(n+1) > (1 + 3f(n)) * (2k_n) + 1)
- Four separate cases (I-IV) for the main theorem, each spanning a page
- Construction of formulas `left(A,D)` and `right(A,D)` for talking about gaps

**Recommendation**: STATE Theorem 4 as an axiom for now. The game-theoretic proof is a separate, self-contained mathematical result that can be formalized independently. The key observation is that Theorem 4 is ONLY used to derive Theorem 5, and Theorem 5 has a short proof from Theorem 4.

```lean
/-- Theorem 4 (GHR93 Theorem 3, GPSS 1980):
    {U, S, U', S'} is expressively complete for the class of all linear
    temporal structures. For any monadic FO formula, there exists an
    equivalent temporal formula (using U, S and Stavi connectives).

    This is stated as an axiom pending formalization of the GHR93
    game-theoretic proof (Section 8, approximately 1000 lines). -/
axiom stavi_expressive_completeness :
    forall (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      exists (A : Formula) (atomMap : sig.preds -> Atom),
        forall (M : OrderedMonadicStructure sig) [LinearOrder M.carrier]
          (t : M.carrier),
          eval M (fun _ => t) psi <->
          stavi_temporal_truth M atomMap t A
```

where `stavi_temporal_truth` extends `temporal_truth` with Stavi connectives.

**Alternative**: If the axiom approach is undesirable, Theorem 4 can be proved as a separate multi-thousand-line formalization effort. This is a well-known result (GPSS 1980) and its proof, while long, is purely combinatorial. Estimated effort: 2000-3000 lines of Lean.

**Lines**: ~10 (axiom) or ~2500 (full proof)
**File**: `StaviConnectives.lean`

---

### Step 2: Theorem 5 ({U,S} expressively complete over Prior structures)

**What**: For the class of Prior structures (those satisfying all substitution instances of Prior-U and Prior-S), the language {U,S} alone is expressively complete.

**Reynolds's proof** (p.123-124): By Theorem 4, it suffices to show that for every {U,S,U',S'}-formula B', there is a {U,S}-formula B equivalent to B' on all Prior structures. This is by structural induction on B':
- Atoms, negation, conjunction, U, S: trivial (already {U,S}).
- U'(A,B): Claim U'(A,B) <-> False on all Prior structures. Proof: Suppose U'(A,B) holds at t. Then B holds from t until a gap, after which not-B is true arbitrarily soon. Apply Prior-U to B: this gives U(not-B or K+(not-B), B) at t, contradicting the gap structure.
- S'(A,B): Dual argument.

**Implementation**:

```lean
/-- In any Prior structure, U'(A,B) is equivalent to False.

    Proof: If U'(A,B) holds at t, then B is true from t up to a gap
    and not-B is true arbitrarily soon after the gap. But Prior-U
    applied to B gives U(neg-B or K+(neg-B), B) at t, which means
    after B stops being true, there is either a first point of neg-B
    or neg-B is true "arbitrarily soon" (K+). Both contradict the gap
    structure: the gap means there is no first point of neg-B (it's
    a gap, not a point), and K+(neg-B) is contradicted by B continuing
    up to the gap. -/
theorem stavi_U_false_in_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula -> sig.preds)
    (h_prior_U : forall (t : M.carrier) (psi : Formula),
      (exists s, t < s /\ temporal_truth M atomMap s psi) ->
      exists s, t < s /\ temporal_truth M atomMap s psi /\
        forall r, t < r -> r < s -> temporal_truth M atomMap r psi.neg)
    (t : M.carrier) (A B : Formula) :
    not (stavi_U_truth M atomMap t A B) := by
  intro h_stavi
  -- Extract the gap structure from h_stavi
  obtain <s, hts, h_notB_exists, h_B_initial, h_gap_structure> := h_stavi
  -- B is true for a while after t
  obtain <u0, htu0, hu0s, h_B_streak> := h_B_initial
  -- not-B exists between t and s
  obtain <u1, htu1, hu1s, h_notB> := h_notB_exists
  -- Apply Prior-U to B at t: since F(B) holds...
  have h_FB : exists s, t < s /\ temporal_truth M atomMap s B :=
    <u0, htu0, ... -- need a point in the streak where B holds>
  obtain <w, htw, hBw, h_negB_between> := h_prior_U t B h_FB
  -- w is the FIRST point after t where B holds (with neg-B between t and w)
  -- But B holds for a while after t (h_B_streak)
  -- Contradiction: h_negB_between says neg-B between t and w,
  -- but h_B_streak says B between t and u0 < s.
  -- If w <= u0: neg-B between t and w, but B between t and u0 -- pick any
  --   v with t < v < min(w, u0), contradiction.
  -- If w > u0: B holds at u0, and u0 < w means neg-B at u0. Contradiction.
  sorry -- Detailed case analysis (straightforward, ~30 lines)
```

**The actual proof** is more subtle because Prior-U gives us the FIRST occurrence of psi (not B), but the key insight is the same: Prior-U prevents the gap pattern. The exact Lean proof requires carefully destructing the existentials and using the discrete/linear order properties.

**Lines**: ~80-120 for `stavi_U_false_in_prior` and `stavi_S_false_in_prior`
**File**: `StaviConnectives.lean`

**Then Theorem 5 follows**:

```lean
/-- Theorem 5 (Reynolds 1994): {U,S} is expressively complete for Prior structures.

    By Theorem 4 and the fact that U'(A,B) <-> False and S'(A,B) <-> False
    on all Prior structures, every {U,S,U',S'}-formula has an equivalent
    {U,S}-formula on Prior structures. Combined with Theorem 4, this gives
    expressive completeness of {U,S} over Prior structures. -/
theorem US_expressively_complete_over_prior :
    forall (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      exists (A : Formula) (atomMap : sig.preds -> Atom),
        forall (M : OrderedMonadicStructure sig) [LinearOrder M.carrier]
          (h_prior_U : ...) (h_prior_S : ...)
          (t : M.carrier),
          eval M (fun _ => t) psi <->
          temporal_truth (... to_int_struct ...) t A
```

**Lines**: ~40 on top of the Stavi-false lemmas
**File**: `StaviConnectives.lean`

---

### Steps 3-11: Lemmas 6-13 and Theorem 14

With Theorem 5 established, the remaining steps follow Reynolds Section 7 exactly. These are formalized in `IntegerModel.lean` (replacing the current sorry).

### Step 3: Lemma 6 (R construction)

**What**: There exists a {U,S}-formula R that holds in any Prior structure exactly at those points whose ~M-class ends in a gap on the right. Dually L for the left.

**Strategy**: 
1. Define the monadic FO formula rho(x) expressing "x's equivalence class ends in a gap on the right." The formula is:
   ```
   rho(x) := exists y > x [not-epsilon(x,y)
              AND exists z (y < z AND epsilon(x,z)
              AND forall w (x < w < z -> epsilon(x,w)))]
   ```
   where epsilon(x,y) is the FO formula defining the contemporaneous equivalence (~M).

2. Apply Theorem 5 to rho(x) to obtain a temporal formula R.

**Key observation**: epsilon(x,y) is definable in monadic FO because ~M is defined by "the subinterval [min(x,y), max(x,y)] is very good", and "very good" is expressible as a conjunction of k-type conditions on all sub-subintervals. The formula epsilon has quantifier depth depending on k.

**Implementation**: Since epsilon involves quantification over subintervals (relativized quantifiers), and rho adds 2-3 more quantifier levels, the resulting FO formula has quantifier depth ~k+3. Theorem 5 gives us a temporal formula R equivalent to rho on Prior structures.

In Lean, we need:
- `mk_epsilon_formula` : constructs the `MonadicFormula sig 2` for epsilon
- `mk_rho_formula` : constructs the `MonadicFormula sig 1` for rho
- `R_formula` : the temporal formula from Theorem 5 applied to rho
- `R_correct` : R holds at t iff t's class ends in a gap on the right

**Lines**: ~100-150
**File**: `GapElimination.lean` (new file)

---

### Step 4: Lemma 7 (R-interval structure)

**What**: Maximal intervals of R are open intervals with excluded endpoints in M.

**Proof sketch** (Reynolds p.125):
1. If R holds at t, rho(t) implies R holds for a while after t (up to the gap). So t is in a non-singleton interval of R.
2. If R stops holding, Prior-U applied to R gives: either (a) a last point of R (impossible since rho implies continuation), or (b) a first point of not-R (the excluded right endpoint).
3. Looking left: Prior-S gives either (a) R always before, (b) a last point of not-R (excluded left endpoint), or (c) a first point of R. Case (c) is ruled out: at the first point s of R with K-(not-R)(s), the ~-class containing s can't stretch forever (or the gap wouldn't exist). Subsequent classes after the gap also have R true. But B = "we're in a class whose left endpoint has R and K-(not-R)" holds in s's class but is false after the gap, contradicting Prior-U.

**Implementation**: Requires `temporal_truth`-level reasoning with the Prior-U hypothesis. The contradiction arguments use `stavi_U_false_in_prior`-style reasoning.

**Lines**: ~80-100
**File**: `GapElimination.lean`

---

### Step 5: Lemma 8 (No first/last class in R-intervals)

**What**: No last class (it wouldn't end at a gap). No first class (formula "in first class" would hold up to gap and be false after, contradicting Prior-U).

**Lines**: ~60
**File**: `GapElimination.lean`

---

### Step 6: Lemma 9 (Elementary equivalence)

**What**: (a) If temporal A holds somewhere in one ~-class in an R-interval, it holds somewhere in every class. (b) All classes in an R-interval are elementarily equivalent as substructures.

**Proof of (a)**: Contradiction. If A holds in class C1 but not in later class C2, construct temporal B = "A occurs somewhere in my class" (exists by Theorem 5). B holds throughout C1 and is false throughout C2. By Prior-U, there's a transition: a first point s where not-B and K-(B). The class of s's left endpoint also has R and K-(not-R) and B, but after the gap not-B. Formula C = "my class's left point has K-(B)" holds in s's class but is false in subsequent classes, contradicting Prior-U.

**Proof of (b)**: Given monadic sentence sigma, relativize quantifiers to epsilon-class. By Theorem 5, get temporal equivalent. By (a), either true everywhere or false everywhere in the R-interval.

**Lines**: ~130
**File**: `GapElimination.lean`

---

### Step 7: Lemma 10 (Bad intervals)

**What**: Bad = R or L. Bad points only in non-singleton bad intervals. Both R and L hold throughout. Excluded endpoints.

**Lines**: ~80
**File**: `GapElimination.lean`

---

### Step 8: Lemma 11 (Propagation)

**What**: If B true for a while at start of a class in a bad interval, then B holds throughout the interval.

**Lines**: ~60
**File**: `GapElimination.lean`

---

### Step 9: Lemma 12 (Model surgery)

**What**: Let Q- precede the bad interval, Q0 = bad interval, I = one class from Q0, Q+ follow. N = M restricted to Q- union I union Q+. For all temporal A and t in N: M |= A(t) iff N |= A(t).

**This is the hardest sub-proof**. It requires:

1. **Surgery carrier definition**:
```lean
def surgery_carrier (M : OrderedMonadicStructure sig) 
    (bad_lo bad_hi : M.carrier) (class_lo class_hi : M.carrier) :=
  {x : M.carrier // x < bad_lo \/ (class_lo < x /\ x < class_hi) \/ bad_hi < x}
```

2. **14 cases for Until** (7 forward, 7 backward) based on position of t and witness s.

3. **Key non-trivial cases use Lemmas 9 and 11**:
   - Case 2 (forward): t in Q-, s in Q0. A holds somewhere in Q0, hence in I (Lemma 9). B holds for a while into Q0, hence throughout (Lemma 11), hence throughout I. So we find a U-witness in I.
   - Case 5 (forward): t in I, s later in Q0. B throughout I (Lemma 11). A somewhere in Q0 hence arbitrarily close to end of I (Lemma 9 + density argument). Gives U-witness near end of I.

**Lines**: ~250-300 (the single largest sub-proof)
**File**: `GapElimination.lean`

---

### Step 10: Lemma 13 (No bad points)

**What**: Contradiction. R holds in I within N (Lemma 7). But N is Prior (counterexamples in N are also counterexamples in M). By contemporaneity, I is one ~N-class. R implies bounded above. So Q+ nonempty, starts with point q where not-R. The ~N-class of I ends just before q (not at gap). But R was supposed to hold, indicating a gap. Contradiction.

**Lines**: ~60
**File**: `GapElimination.lean`

---

### Step 11: Theorem 14

**What**: ~M classes don't end at gaps. Immediate from Lemma 13.

**Lines**: ~10
**File**: `GapElimination.lean`, with bridge to `IntegerModel.lean`'s `no_gaps_discrete`.

---

## 3. File-by-File Breakdown

### New Files

| File | Purpose | Est. Lines |
|------|---------|-----------|
| `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` | Stavi semantics, Theorem 4 (axiom), Theorem 5 | ~200 |
| `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` | Lemmas 6-13, Theorem 14 | ~900-1100 |

### Modified Files

| File | Change | Est. Lines Changed |
|------|--------|-------------------|
| `IntegerModel.lean` | Replace `no_gaps_discrete` sorry with call to `gap_elimination_theorem_14` | ~20 |
| `WeakCanonical.lean` | Add imports for new files | ~3 |

### Total New Lines: ~1100-1300

---

## 4. Dependency Graph

```
StaviConnectives.lean
  |
  +-- stavi_U_truth (definition)
  +-- stavi_S_truth (definition)
  +-- stavi_expressive_completeness (AXIOM = Theorem 4)
  +-- stavi_U_false_in_prior (Theorem 5, U' case)
  +-- stavi_S_false_in_prior (Theorem 5, S' case)
  +-- US_expressively_complete_over_prior (Theorem 5, full)
  |
  v
GapElimination.lean
  |
  +-- mk_epsilon_formula (FO formula for ~M)
  +-- mk_rho_formula (FO formula for "class ends at gap")
  +-- R_formula, R_correct (Lemma 6)
  +-- R_interval_open (Lemma 7)
  +-- no_first_last_class (Lemma 8)
  +-- elementary_equiv_classes (Lemma 9)
  +-- bad_interval_structure (Lemma 10)
  +-- formula_propagation (Lemma 11)
  +-- model_surgery (Lemma 12)
  +-- no_bad_points (Lemma 13)
  +-- gap_elimination_theorem_14 (Theorem 14)
  |
  v
IntegerModel.lean
  |
  +-- no_gaps_discrete (sorry replaced)
  +-- one_class (now sorry-free via no_gaps_discrete)
  +-- chronicle_is_good (downstream)
```

---

## 5. Critical Design Decisions

### Decision 1: Theorem 4 as Axiom vs Full Proof

**Recommended**: Axiom. Theorem 4 is a well-known result (GPSS 1980, GHR93). Its formalization is a self-contained 2000-3000 line effort that does not interact with the rest of the completeness proof except through Theorem 5. Using an axiom unblocks the entire pipeline immediately.

**Risk**: One axiom in the proof. Mitigated by the fact that Theorem 4 is a published, verified result with multiple independent proofs.

**Alternative**: Prove Theorem 4 fully. This requires formalizing the GHR93 Section 8 game-theoretic argument, which involves custom Ehrenfeucht-Fraisse games, complex inductions with parameter bounds, and four major case splits. This is feasible but represents a separate project.

### Decision 2: Where to Define Stavi Semantics

**Recommended**: In a new `StaviConnectives.lean` file. Do NOT add new `Formula` constructors. The Stavi connectives are only used semantically in Theorem 5's proof; they never appear as syntactic objects in the completeness proof itself.

### Decision 3: How to Handle the FO Formula for epsilon

**Recommended**: Define epsilon as a `MonadicFormula sig 2` directly, constructing it from the normal-form characterization of k-equivalence. The formula epsilon(x,y) says "for all z1 z2 between min(x,y) and max(x,y), the subinterval [z1,z2] is good." This involves:
- Relativized quantifiers to the interval [x,y]
- A conjunction over all k-types stating "there exists a Z-interval structure with this k-type"

The `NormalFormIdx` and `nf_eval_nf` infrastructure from `NormalForm.lean` supports this construction.

### Decision 4: Temporal Truth for General Ordered Structures vs Just Z

The current `temporal_truth` in `Table.lean` is defined for `OrderedMonadicStructure sig`, which covers any carrier with a `LinearOrder`. The Prior-U hypothesis is parameterized by an `atomMap`. This is exactly what we need -- no changes to `temporal_truth` are required.

### Decision 5: Model Surgery Implementation

**Recommended**: Define the surgery structure as a subtype of M.carrier. The order and predicate interpretations are inherited. The key difficulty is that the surgery removes the "middle part" (bad interval minus I) and the resulting structure has a different carrier. In Lean, this is naturally a subtype `{x : M.carrier // x < bad_lo \/ (class_lo < x /\ x < class_hi) \/ bad_hi < x}`.

---

## 6. Proof Sketches for Key Lemmas

### Theorem 5 (stavi_U_false_in_prior) -- Detailed Sketch

```
Assume for contradiction: stavi_U_truth M atomMap t A B holds.

By definition, there exists s > t such that:
  (a) B is true on some initial stretch (t, u0) with u0 < s
  (b) not-B holds at some u1 with t < u1 < s
  (c) For each u in (t,s), either a B-streak continues beyond u,
      or A holds from u to s

Since B holds at some point after t (any point in (t, u0)),
apply Prior-U to B at t:
  There exists w > t such that B(w) and for all r with t < r < w, neg-B(r).
  
This means: w is the FIRST point after t where B is true.
But from (a), B is true throughout (t, u0).
For any r with t < r < min(w, u0): both B(r) (from (a)) and neg-B(r) (from Prior-U).
This is a contradiction IF w > t and u0 > t and the interval (t, min(w,u0)) is nonempty.

In a discrete order: the successor of t is the first point after t. If B holds at succ(t)
(from the streak), then w must be <= succ(t). If w = succ(t), there are no points between
t and w, so no contradiction from "neg-B between t and w." But then B(w) = B(succ(t)) holds,
and for the gap to exist, there must be points between the B-streak and the not-B region.

The argument is more subtle in non-discrete orders. For GENERAL linear orders (which is
what we need for Prior structures from Corollary 3), the Prior-U axiom is:

  Prior-U: U(neg-psi, psi) \/ F(neg-psi) -> U(neg-psi \/ K+(neg-psi), psi)

Reynolds uses the WEAKER Prior-U (not Prior-UZ). The key: if B holds up to a gap
and not-B is true arbitrarily soon after, then F(B) holds at t. By Prior-U applied
to B: U(neg-B \/ K+(neg-B), B) holds at t. This means: there is a first occurrence
of (neg-B or K+(neg-B)), with B holding between t and that occurrence. But:
- K+(neg-B) means neg-B is true "arbitrarily soon" (in every neighborhood).
- At the gap, B is true up to the gap and not-B arbitrarily soon after.
- The point where "neg-B or K+(neg-B)" first holds must be at or beyond the gap.
- But at the gap, K+(neg-B) IS true (not-B arbitrarily soon after the gap).
- This means U(neg-B \/ K+(neg-B), B)(t) holds, with the witness at the gap.
- But the gap is not a point! U requires the witness to be an element of the carrier.

THIS is the crux: the gap is NOT a point of M. U quantifies over points. The "witness"
for U(neg-B \/ K+(neg-B), B) must be a POINT s > t where (neg-B \/ K+(neg-B))(s) holds,
with B true for all POINTS between t and s. But at the gap, there is no such point --
the gap is a Dedekind cut, not an element. So U can only witness at a point AFTER the gap.
But after the gap, there are points where neg-B holds (by assumption). Take the first
such point s. Then B holds from t to s, and neg-B(s). But wait -- B might not hold on
the OTHER SIDE of the gap (i.e., between the gap and s). This depends on whether there
are points between the gap and s where not-B holds.

Actually, the contradiction is simpler: U'(A,B) asserts that not-B is true "arbitrarily
soon" after the gap. This means K+(neg-B) holds at points just before the gap. So
neg-B or K+(neg-B) holds at points just before the gap. But B is also supposed to hold
at those same points (B holds up to the gap). So we need B(r) AND (neg-B(r) or K+(neg-B)(r))
simultaneously. B(r) rules out neg-B(r). So K+(neg-B)(r) must hold. But K+(neg-B)(r) means
neg-B is true arbitrarily soon after r. Since r is before the gap and B holds up to the gap,
there must be points between r and the gap where neg-B holds. But B holds between t and the
gap (by the U' definition). Contradiction.

Wait, I need to be more careful. The U' definition says B holds "from t up until a gap."
Not necessarily at ALL points between t and the gap -- just up to the gap. The exact
definition from p.122-123 is the first-order table. Let me re-examine.

Actually, Reynolds's proof on p.123-124 is cleaner and shorter:

"Suppose for contradiction that M |= U'(A,B)(t). Thus B holds for a while up until
a gap after which neg-B is true arbitrarily soon. By Prior-U applied to B we have
M |= U(neg-B \/ K+(neg-B), B)(t) which is the contradiction."

The "contradiction" is: U(neg-B \/ K+(neg-B), B)(t) says there exists s > t with
(neg-B \/ K+(neg-B))(s) and B between t and s. But this "contradicts" the U' structure
because:
- U'(A,B) says B holds up to a gap.
- U(neg-B \/ K+(neg-B), B) says the first "bad" point for B is a REAL POINT s.
- At s, either neg-B(s) or K+(neg-B)(s). 
- If neg-B(s): then s is beyond the gap (B holds to the gap), and B holds between t and s 
  (by the U statement). But B should fail at or right after the gap. So s is at or beyond 
  the gap, but there are NO points between the gap and s where B fails -- contradiction
  with "neg-B arbitrarily soon after the gap."
- If K+(neg-B)(s): neg-B is true in every neighborhood of s (from above). Since B holds
  between t and s, s is at least at the gap boundary. K+(neg-B)(s) means neg-B arbitrarily
  soon after s. And B holds from t to s. So the gap (if any) is at s. But s is a POINT,
  not a gap. The gap in U' is a REAL gap (Dedekind cut). Since s is a point and B holds
  up to s, and K+(neg-B) holds at s, this means s is at the right end of the B-stretch.
  After s, neg-B arbitrarily soon. But U' says the gap is NOT at a point -- it's a gap
  in the order. The existence of the point s where the transition happens (with K+(neg-B))
  means there IS a point at the transition, ruling out a gap. Contradiction.

So the formal proof needs:
1. From U'(A,B)(t), extract the gap structure.
2. B holds at some point after t, so F(B)(t).
3. Apply Prior-U to B: get U(neg-B \/ K+(neg-B), B)(t).
4. The U-witness s is a point (not a gap).
5. Show that the existence of s contradicts the gap structure of U'.

In Lean, this requires careful manipulation of the semantics but is straightforward
once the definitions are in place. Estimated ~80-100 lines.
```

---

## 7. Effort Estimate

| Component | Lines | Difficulty | Blocking? |
|-----------|-------|-----------|-----------|
| Stavi semantic definitions | 60 | LOW | No |
| Theorem 4 (axiom) | 10 | LOW | No (axiom) |
| Theorem 5 (U' false, S' false) | 120 | MEDIUM | No |
| Theorem 5 (full expressiveness) | 40 | MEDIUM | No |
| Lemma 6 (epsilon + rho + R) | 150 | HIGH | No |
| Lemma 7 (R-interval structure) | 80 | MEDIUM | No |
| Lemma 8 (no first/last class) | 60 | MEDIUM | No |
| Lemma 9 (elementary equiv) | 130 | HIGH | No |
| Lemma 10 (bad intervals) | 80 | MEDIUM | No |
| Lemma 11 (propagation) | 60 | MEDIUM | No |
| Lemma 12 (model surgery) | 300 | VERY HIGH | No |
| Lemma 13 (contradiction) | 60 | MEDIUM | No |
| Theorem 14 + bridge | 30 | LOW | No |
| Helper infrastructure | 100 | MEDIUM | No |
| **Total** | **~1280** | -- | -- |

### Estimated Wall-Clock Time
- StaviConnectives.lean: 1-2 implementation sessions
- GapElimination.lean: 4-6 implementation sessions (Lemma 12 alone is 2-3)
- Integration + testing: 1 session
- **Total: 6-9 implementation sessions**

---

## 8. Remaining Sorries After This Work

After completing the full Reynolds approach for Phase 4, the sorry status would be:

| Sorry | Location | Status |
|-------|----------|--------|
| `no_gaps_discrete` | IntegerModel.lean:859 | ELIMINATED (by Theorem 14) |
| `stavi_expressive_completeness` | StaviConnectives.lean | NEW AXIOM (Theorem 4) |
| `cofinal_decomposition_k_equiv` | IntegerModel.lean:1135 | Unchanged (Phase 2 task) |
| `ordered_sum_of_good_bounded_is_good` | IntegerModel.lean:1194 | Unchanged (Phase 2 task) |
| Various in TruthLemma.lean | TruthLemma.lean | Unchanged (non-critical path) |
| `doets_lemma_1_5` | OrderedSum.lean:56 | Unchanged (Phase 2 task) |
| Bridge in Transfer.lean | Transfer.lean:420 | Unchanged |

The `stavi_expressive_completeness` axiom replaces the `no_gaps_discrete` sorry. It is a cleaner, more principled axiom -- a well-known published theorem (GPSS 1980) rather than a sorry in the middle of a proof.

---

## 9. Alternative: Avoiding Theorem 4 Entirely

There is a potential shortcut that avoids needing Theorem 4 at all. The idea:

**Observation**: In our codebase, we don't need expressive completeness of {U,S} over ARBITRARY Prior structures. We only need it for the SPECIFIC Prior structure that arises from Corollary 3 (the Burgess-Xu model). This structure has a specific form: it is countable, discrete, and without endpoints.

**For discrete structures without endpoints**: The Stavi connectives U' and S' are trivially equivalent to False, because discrete orders have no gaps at all! In a discrete order (every element has an immediate successor and predecessor), there are no Dedekind cuts that correspond to gaps.

**Wait -- this is wrong**. The chronicle from Corollary 3 is discrete (has immediate successors/predecessors) but may NOT be isomorphic to Z. It could be Z + Z or more exotic. In Z + Z, there IS a gap between the two copies of Z. The "gap" is a Dedekind cut that is not filled by any element. So gaps CAN exist in discrete orders without endpoints, just not "definable" gaps in Prior structures (that's what Theorem 14 proves).

**So the shortcut doesn't work.** We genuinely need Theorem 5, and Theorem 5 requires Theorem 4 (or some equivalent).

**Another alternative**: Instead of Theorem 4, use the separation-based proof of expressive completeness. Our codebase already has `US_expressively_complete_over_Z` (separation -> expressiveness over Z). Could we generalize this to "separation over Prior structures -> expressiveness over Prior structures"?

The problem is: separation is proved specifically for integer time (Section 10.2 of GHR94). The separation proof uses discreteness of Z. For general Prior structures (which are discrete but not necessarily Z), we would need to re-prove separation. This is possible -- the GHR94 Chapter 10 separation proof works for any discrete linear order -- but it requires re-examining the elimination lemmas. Currently our separation proof is tied to `int_truth` (integer-valued structures). Generalizing it to arbitrary discrete carriers is feasible but would require refactoring ~1000 lines of `Separation/` code.

**Verdict**: The axiom approach (Theorem 4 as axiom) is the cleanest path forward. The alternatives all require significant additional work without clear advantages.

---

## 10. Implementation Phases (Recommended Order)

### Phase A: Foundations (~200 lines, 1-2 sessions)
1. Create `StaviConnectives.lean`
2. Define `stavi_U_truth`, `stavi_S_truth` 
3. State `stavi_expressive_completeness` as axiom
4. Prove `stavi_U_false_in_prior`, `stavi_S_false_in_prior`
5. Prove `US_expressively_complete_over_prior` (Theorem 5)

### Phase B: Gap Detection (~250 lines, 2 sessions)
1. Create `GapElimination.lean`
2. Define `mk_epsilon_formula` (FO formula for ~M)
3. Define `mk_rho_formula` (FO formula for gap-on-right)
4. Prove `R_formula` and `R_correct` (Lemma 6)
5. Prove `R_interval_open` (Lemma 7)
6. Prove `no_first_last_class` (Lemma 8)

### Phase C: Class Properties (~270 lines, 2 sessions)
1. Prove `elementary_equiv_classes` (Lemma 9)
2. Prove `bad_interval_structure` (Lemma 10)
3. Prove `formula_propagation` (Lemma 11)

### Phase D: Surgery (~360 lines, 2-3 sessions)
1. Define surgery carrier and structure
2. Prove `model_surgery` (Lemma 12) -- all 14 cases for Until, plus Since cases
3. Prove `no_bad_points` (Lemma 13)

### Phase E: Assembly (~50 lines, 1 session)
1. Prove `gap_elimination_theorem_14` (Theorem 14)
2. Replace `no_gaps_discrete` sorry in `IntegerModel.lean`
3. Verify `one_class` and `chronicle_is_good` are now sorry-free (modulo axiom)
4. Run `lake build` to confirm compilation

---

## 11. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Theorem 4 axiom accepted but hard to prove later | LOW | MEDIUM | Well-known result, multiple published proofs |
| Model surgery Lemma 12 exceeds estimate | MEDIUM | LOW | Modularize into sub-lemmas per case |
| epsilon formula construction too complex | MEDIUM | MEDIUM | Use abstract k-type characterization instead of explicit formula |
| Prior-U semantic hypothesis mismatch | LOW | HIGH | Carefully align with existing `h_prior_UZ` in `one_class` |
| Performance issues with large proof terms | LOW | LOW | Use `abstract` and section variables |

---

## 12. Summary

The full Reynolds approach to Phase 4 is feasible and well-understood. The critical path is:

1. **State Theorem 4 as an axiom** (10 lines, immediate)
2. **Prove Theorem 5** from Theorem 4 (~160 lines, the U'/S' triviality argument)
3. **Formalize Lemmas 6-13** (Reynolds Section 7, ~900 lines, the bulk of the work)
4. **Assemble Theorem 14** and replace the sorry (~30 lines)

Total: ~1100-1300 new lines, 6-9 implementation sessions. The single largest sub-proof is Lemma 12 (model surgery, ~300 lines, 14 cases for Until alone). The single most conceptually important step is Theorem 5, which has a short and elegant proof.

The axiom (`stavi_expressive_completeness`) is a principled choice: it is a well-known, published theorem (GPSS 1980) that is cleanly separated from the rest of the proof. It can be proved as a separate task later without affecting any other part of the formalization.
