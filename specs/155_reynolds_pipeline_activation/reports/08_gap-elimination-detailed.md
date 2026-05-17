# Reynolds Theorem 14 (Gap Elimination) — Detailed Formalization Plan

## Executive Summary

Reynolds's Theorem 14 states: "If ~ is a contemporaneous equivalence relation on a Prior structure M, then the ~-classes do not end at gaps." This theorem is essential for proving `no_gaps_discrete` and `one_class` WITHOUT the `IsSuccArchimedean` hypothesis. The current proofs use `IsSuccArchimedean` to show bounded intervals are finite; the correct approach uses Prior-UZ semantically (via Theorem 14) to rule out gaps between equivalence classes, leaving successor boundaries as the only possibility, which are immediately dispatched by the existing `no_boundary_at_successor`.

**Key Insight**: In a discrete linear order without endpoints that is NOT necessarily succ-Archimedean (e.g., Z + Z, or the chronicle domain before proving succ_cofinal), there CAN be "gaps" between equivalence classes. These gaps occur at non-successor boundaries -- places where no finite iteration of succ reaches across. Reynolds's Theorem 14, using expressive completeness + Prior-UZ, proves such gaps cannot exist for contemporaneous equivalence relations on Prior structures.

---

## 1. Full Analysis of Reynolds's Proof (Lemmas 6-13, Theorem 14)

### 1.1 Lemma 6: Construction of R

**Statement**: There exists a US-formula R which holds in any Prior structure N exactly at those points whose ~N-class ends in a gap on the right. Dually L for the left.

**Key Ideas**:
- Define the monadic FO formula rho(x):
  ```
  rho(x) := exists y > x [not-epsilon(x,y)
             AND exists z > y [epsilon(x,z)
             AND forall y'(x < y' < z -> epsilon(x,y'))]]
  ```
  This says: "There is a point y after x that leaves x's class, AND there's a point z beyond y still in x's class (witnessed by epsilon), AND everything between x and z that is before z is in x's class." The gap is between the end of x's class (before y) and z.

  Actually, more precisely: rho(x) says "x's equivalence class is bounded above but does not have a last element nor a first non-equivalent element immediately following -- instead, the transition happens at a gap."

- By Theorem 5 (expressive completeness of {U,S} for Prior structures), there exists a temporal formula R equivalent to rho(x) on all Prior structures.

**Dependencies**: Theorem 5 (expressive completeness).

**Quantifier depth of rho(x)**: The formula epsilon(x,y) defining ~ is itself a monadic FO formula (built from quantifiers over the carrier relativized to the interval). Its quantifier depth depends on k (the depth parameter of contemp_equiv). rho(x) adds 2-3 more quantifiers on top, giving total depth ~k+3.

**Formalization Difficulty**: HIGH. Requires either (a) formalizing Theorem 5, or (b) working entirely at the monadic FO/k-type level without constructing R as a temporal formula.

---

### 1.2 Lemma 7: R-interval Structure

**Statement**: The maximal intervals in which R holds are open intervals which, if bounded, have elements of M as their (excluded) end points.

**Key Ideas**:
1. If R holds at t, then rho(t) holds, which means the class containing t stretches up to a gap. So R holds for a while after t (at least up until the gap).
2. If R stops holding after t, by Prior-U applied to R, there is either a last point of R (impossible -- rho implies R continues) or a first point of not-R. The first point of not-R is the excluded endpoint.
3. Looking left from t: by Prior-S, either R holds always before t, there's a last point of not-R just before (an excluded endpoint -- acceptable), or there's a first point of R. The third case is ruled out by contradiction using Prior-U applied to a formula B defined by expressive completeness.

**Dependencies**: Lemma 6, Prior-U semantics, expressive completeness (for formula B in case 3).

**Formalization Difficulty**: MEDIUM. The structure of the proof is standard if Prior-U is available as a semantic hypothesis.

---

### 1.3 Lemma 8: No First/Last Class in R-intervals

**Statement**: There is no last class and no first class in any maximal interval of R.

**Key Ideas**:
- Last class: A last class in a maximal interval of R wouldn't end in a gap (because after it comes the boundary of the R-interval, not a gap within the class structure).
- First class: By expressive completeness, construct a formula true only in the first classes of maximal intervals of R. If a first class exists, this formula holds up to a gap and is false arbitrarily soon afterwards, contradicting Prior-U.

**Dependencies**: Lemma 7, expressive completeness, Prior-U.

**Formalization Difficulty**: MEDIUM.

---

### 1.4 Lemma 9: Elementary Equivalence of Classes

**Statement**: (a) If a temporal formula holds somewhere in one ~-class in a maximal interval of R, then it holds somewhere in each ~-class in the interval. (b) All ~-classes in a maximal R-interval are elementarily equivalent as substructures of M.

**Key Ideas**:
- (a) Contradiction proof: Suppose formula A holds in one class but not another. Using expressive completeness and ~, construct temporal B true at points whose class contains A. B holds throughout one class and is false throughout a later class. By Prior-U, find the transition point. The transition forces a pattern that contradicts Prior-U again.
- (b) Given a monadic sentence sigma, relativize its quantifiers to where epsilon(x,-) holds (restricting to a single class). By expressive completeness, the relativized formula has a temporal equivalent. By part (a), this temporal formula is either true everywhere in the R-interval or false everywhere. So all classes satisfy the same sentences.

**Dependencies**: Lemma 8, expressive completeness, Prior-U.

**Formalization Difficulty**: HIGH. Part (b) is the most conceptually deep -- it requires relativization of monadic FO formulas to subintervals.

**How Expressive Completeness Is Used**: The formula constructed in (a) is: "B(x) = there exists y in x's class such that A(y)." This is a monadic FO formula with one free variable (quantification over the class, which is defined by epsilon). Its temporal equivalent exists by Theorem 5.

For part (b): Given a sentence sigma (no free variables), "sigma restricted to x's class" becomes a formula with one free variable x (quantifiers restricted to {y : epsilon(x,y)}). This has a temporal equivalent by Theorem 5.

---

### 1.5 Lemma 10: Bad Interval Structure

**Statement**: Define "bad point" = where R or L holds. Bad points occur only in non-singleton bad intervals. In any bad interval, both R AND L hold throughout. Any bad interval, if bounded, has excluded endpoints in M (neither R nor L holds there).

**Key Ideas**:
- Show L holds wherever R does: Suppose a maximal interval of R has some class where L fails. That class includes its left-hand end point (or begins just after a point of M). But a class beginning just after a point of M contradicts the gap structure. A class including its left endpoint implies ALL classes include their left endpoints (by Lemma 9). Then construct a temporal formula true at non-left-endpoint points of classes, which holds up to a gap and is false after -- contradicting Prior-U.
- Mirror argument gives R wherever L holds.
- Excluded endpoints follow from Lemma 7 applied to both R and L.

**Dependencies**: Lemma 9, Prior-U.

**Formalization Difficulty**: MEDIUM.

---

### 1.6 Lemma 11: Formula Propagation in Bad Intervals

**Statement**: If a formula B is true for a while at the start of a ~-class in a bad interval, then it holds throughout the bad interval. If a formula is true anywhere in a bad interval, it is true arbitrarily close to each end of each class in the interval.

**Key Ideas**:
- Suppose B holds for a while after a gap gamma but not-B holds somewhere in the bad interval. By Lemma 9 ("Lemma 4" in the original -- elementary equivalence), not-B also holds somewhere in the same class (gamma, delta).
- Using epsilon and expressive completeness, construct temporal C true only at points within a class after some not-B in that class. C is false at the beginning of each class and true at the end. C holds up to the gap at the end and is false arbitrarily soon after -- contradicting Prior-U.

**Dependencies**: Lemma 9, expressive completeness, Prior-U.

**Formalization Difficulty**: MEDIUM.

---

### 1.7 Lemma 12: Model Surgery Preserves Temporal Truth

**Statement**: Let Q- precede the bad interval, Q0 be the bad interval, I be one ~-class from Q0, Q+ follow the bad interval. Define N as the substructure of M with domain Q- union I union Q+. Then for all temporal formulas A and all t in N: M models A(t) iff N models A(t).

**Key Ideas**: Structural induction on A. The atomic and boolean cases are trivial.

For U(A,B) -- forward direction (M models U(A,B)(t) implies N models U(A,B)(t)):
- 7 cases based on position of t and witness s relative to Q-, I, Q+:
  1. t < s both in Q-: direct induction
  2. t in Q-, s in Q0: A holds somewhere in Q0, hence in I (Lemma 9). B holds for a while into Q0, hence throughout Q0 (Lemma 11), hence throughout I.
  3. t in Q-, s in Q+: B holds throughout I in both M and N.
  4. t < s both in I: direct induction
  5. t in I, s later in Q0: B true throughout I (Lemma 11). A true somewhere in Q0 hence arbitrarily close to end of I (Lemma 9).
  6. t in I, s in Q+: B true throughout I.
  7. t < s both in Q+: direct induction

For U(A,B) -- backward direction (N models U(A,B)(t) implies M models U(A,B)(t)):
- 6 cases (similar structure, slightly fewer because I is the only representative of Q0 in N):
  1. t < s both in Q-: direct induction
  2. t in Q-, s in I: B holds at beginning of I in N hence in M, hence throughout Q0 (Lemma 11).
  3. t in Q-, s in Q+: B holds throughout I in N hence in M hence throughout Q0.
  4. t < s both in I: direct induction
  5. t in I, s in Q+: B true throughout I.
  6. t < s both in Q+: direct induction

**Dependencies**: Lemma 9 (truth transfer across classes), Lemma 11 (propagation from class start to whole bad interval).

**Formalization Difficulty**: VERY HIGH. This is the largest technical sub-proof (~200-300 lines). The 14 total cases each require careful environment manipulation for the inductive hypothesis.

---

### 1.8 Lemma 13: Contradiction (No Bad Points)

**Statement**: There can't have been any bad points anyway.

**Key Ideas**:
1. By Lemma 7, R holds in the bad interval, hence R holds at all points of I in M.
2. By Lemma 12, temporal truth is preserved: R holds at all points of I in N.
3. N is a Prior structure (any counterexample to Prior-U/S in N is also one in M, since N is a substructure of M).
4. R holds at a point iff that point's ~N-class ends in a gap (Lemma 6 applied to N).
5. By the contemporaneity of epsilon, I (as a subset of N) is still all in one ~N-class.
6. R says this class is bounded above. So Q+ is non-empty and begins with a point q.
7. By Lemma 7 (applied to N), not-R holds at q. So q is not in I's class in N.
8. Therefore I's class ends just before q (at the excluded endpoint), NOT at a gap.
9. But R was supposed to hold at points in I (meaning the class ends at a gap). Contradiction.

**Dependencies**: Lemmas 6, 7, 12.

**Formalization Difficulty**: MEDIUM. The logic is clear; the main work is assembling the pieces.

---

### 1.9 Theorem 14: Assembly

**Statement**: ~-classes do not end at gaps in any Prior structure.

**Proof**: Immediate from Lemma 13 (there are no bad points, hence no R points, hence no gaps).

---

## 2. Exact Uses of Expressive Completeness

### 2.1 Catalog of Uses

| Location | FO Formula Being Converted | Properties Needed | Quantifier Depth |
|----------|---------------------------|-------------------|-----------------|
| Lemma 6 | rho(x) = "x's class ends at gap on right" | Equivalent to some temporal R in all Prior structures | k + 3 (where k is depth of epsilon) |
| Lemma 7 (case 3) | "We are in a class beginning with R AND K-(not-R)" | Defines a contemporaneous property of the current class | k + 4 |
| Lemma 8 (first class) | "rho(x) AND not-exists z with ... between us and the first class" | Defines "being in the first class of an R-interval" | k + 5 |
| Lemma 9(a) | "There exists y in x's class such that A(y)" | Defines "A occurs somewhere in this class" | depth(A) + k + 1 |
| Lemma 9(b) | sigma relativized to x's class | Converts global sentence to class-relative formula | depth(sigma) + k |
| Lemma 11 | "We are at a point after some not-B in this class" | Defines a contemporaneous property | depth(B) + k + 1 |

### 2.2 Could FO Be Used Directly (via doets_lemma_1_1)?

**Observation**: Every use of expressive completeness converts a monadic FO formula phi(x) (with one free variable) to a temporal formula A such that phi(x) <-> A holds in all Prior structures. The temporal formula A is then fed to Prior-U to derive a contradiction.

**Key question**: Can we bypass the temporal formula entirely and work with monadic FO + Prior-U directly?

**Answer: No, not straightforwardly.** The Prior-U axiom is a statement about TEMPORAL formulas:
```
Prior-UZ: F(psi) -> U(psi, not-psi)
```
It says: if psi will hold in the future, there's a NEAREST future point where psi holds, with not-psi between now and then. This is inherently temporal -- it talks about the relationship between truth now and truth at future points.

To use Prior-U on a property phi(x) (monadic FO), we NEED the temporal equivalent A, because Prior-U only applies to temporal formulas.

**However**: What Prior-U actually ensures is a DEFINABILITY property of the structure. In any Prior structure, there are no "definable gaps" -- for any temporal formula psi, if psi holds somewhere in the future, there exists a nearest such point. This translates to: for any temporal formula psi defining a subset S of the domain, if S is non-empty above t, then S has a minimum element above t (in the closure-from-the-right sense: there's a boundary point).

At the k-type level, this means: for any normal form (which determines a definable set), the set has no gaps.

### 2.3 Could a Restricted Expressive Completeness Suffice?

**Yes.** Reynolds does NOT need the full general theorem (for arbitrary monadic FO formulas). He needs it only for formulas built from:
- The specific epsilon(x,y) defining contemporaneous equivalence
- Order comparisons
- Boolean combinations
- Bounded quantification over the carrier

All these formulas have bounded quantifier depth (determined by k, the equivalence depth parameter). A restricted theorem of the form:

> "For any monadic formula phi(x) of quantifier depth <= D (for specific D depending on k), there exists a temporal formula equivalent to phi on Prior structures"

would suffice. But even this restricted version requires the core separation machinery.

### 2.4 The Real Question: What Does "Expressive Completeness for Prior Structures" Mean?

Reynolds's Theorem 5 states: {U,S} is expressively complete over the class of Prior structures. The proof is elegant and short:

1. {U, S, U', S'} is expressively complete over ALL linear flows (Theorem 4 = GHR94 Chapter 11)
2. U'(A,B) is equivalent to False in all Prior structures (because U'(A,B) requires a definable gap, and Prior-U prevents definable gaps)
3. Therefore {U,S} alone is expressively complete over Prior structures

This means: for ANY monadic FO formula phi(x), there exists a {U,S}-formula A such that phi(x) <-> A is valid in all Prior structures.

For formalization, the challenge is that step (1) is a major external result.

---

## 3. The Separation Proof for Integer Time (Chapter 10.2)

### 3.1 Overview

The separation theorem (Theorem 10.2.9) proves that every {U,S}-formula over integer time is equivalent to a "separated" formula -- a boolean combination of pure-future formulas (built from U only), pure-past formulas (built from S only), and atoms.

### 3.2 The 8 Elimination Cases

Each case handles one pattern of nesting U under S:

| # | Pattern | Strategy | Complexity |
|---|---------|----------|------------|
| 1 | S(a AND U(A,B), q) | Split on U-witness position: future/present/past | Medium |
| 2 | S(a AND not-U(A,B), q) | Use negation equivalence (Lemma 10.2.2), reduce to case 1 | Medium |
| 3 | S(a, q OR U(A,B)) | Negate and use case 2 | Low |
| 4 | S(a, q OR not-U(A,B)) | Direct semantic argument | Medium |
| 5 | S(a AND U(A,B), q OR U(A,B)) | Split on A-witness position | High |
| 6 | S(a AND not-U(A,B), q OR U(A,B)) | Reduce to cases 3 and 5 | Medium |
| 7 | S(a AND U(A,B), q OR not-U(A,B)) | Reduce to cases 4 and 8 | Medium |
| 8 | S(a AND not-U(A,B), q OR not-U(A,B)) | Negate and reduce to case 5 | Medium |

### 3.3 The Induction Structure

```
Lemma 10.2.8 (Junction Depth induction):
  For junction depth >= 2, reduce by 1
  |
  v
Lemma 10.2.7 (No S within U, induction on U-nesting depth n):
  For n > 1, reduce nesting depth
  |
  v
Lemma 10.2.6 (Multiple U-formulas, induction on count n):
  For n > 1, focus on one U(A_n, B_n) at a time
  |
  v
Lemma 10.2.5 (Single U, induction on S-nesting depth k):
  For k > 0, apply Lemma 10.2.4 to innermost
  |
  v
Lemma 10.2.4 (Single S with U at top level):
  DNF/CNF normalization + Lemma 10.2.1 distributivity
  |
  v
Lemma 10.2.3 (8 elimination cases):
  Case-by-case semantic equivalence proofs
```

### 3.4 Estimated Formalization Complexity

The separation proof for integer time is a PURELY SYNTACTIC rewriting procedure. Each step produces an equivalent formula. The main challenges are:

1. **Formula representation**: Need a notion of "separated formula" and rewriting infrastructure
2. **8 elimination lemmas**: Each is a semantic equivalence proof over integer time (~100-150 lines each)
3. **Induction structure**: The nested inductions are well-founded but need careful bookkeeping
4. **Negation equivalences (Lemma 10.2.2)**: These use discreteness (integer-specific)

**Total estimate**: 2200-2600 lines, 3-4 weeks of dedicated work.

---

## 4. Existing Codebase Infrastructure

### 4.1 What We Have

| Component | Location | Status | Notes |
|-----------|----------|--------|-------|
| `table : Formula -> MonadicFormula sig 1` | Table.lean:89 | COMPLETE | Temporal -> FO translation |
| `table_correctness` | Table.lean:268 | PROVED (sorry-free) | eval(table(phi)) <-> temporal_truth(phi) |
| `temporal_truth` | Table.lean:204 | DEFINED | Semantic truth for temporal formulas |
| `eval` (Tarski satisfaction) | MonadicFO.lean:216 | DEFINED | For MonadicFormula evaluation |
| `MonadicFormula sig n` | MonadicFO.lean:62 | DEFINED | FO formulas with De Bruijn indices |
| `MonadicSentence sig` | MonadicFO.lean:72 | DEFINED | Closed formulas (n=0) |
| `contemp_equiv` | IntegerModel.lean:691 | DEFINED | a ~M b via very_good of subinterval |
| `contemp_equiv_is_equiv` | IntegerModel.lean:707 | PROVED | Equivalence relation (NO IsSuccArchimedean) |
| `no_boundary_at_successor` | IntegerModel.lean:828 | PROVED | c ~M succ(c) always holds |
| `finite_structures_good` | IntegerModel.lean:173 | PROVED | Finite -> good |
| `doets_lemma_1_1` | NormalForm.lean:433 | PROVED | k-type determines depth-k sentence truth |
| `doets_lemma_1_4` | NEquivalence (sum_preservation) | PROVED | Ordered sum preserves k-equiv |
| `k_equiv_of_iso` | IntegerModel.lean:98 | PROVED | Order-iso -> k-equiv |
| Prior-UZ syntactic | ChronicleExtraction.lean:117 | AVAILABLE | Formula in MCS at every point |
| Prior-UZ semantic | SoundnessLemmas.lean:2175 | PROVED | Requires IsSuccArchimedean on D |
| `good_of_split_at_succ` | IntegerModel.lean:413 | PROVED | Split interval at succ boundary |

### 4.2 What We Lack

| Component | Needed For | Difficulty |
|-----------|-----------|------------|
| Expressive completeness inverse (FO -> temporal for Prior structures) | Lemma 6 | HIGH |
| Semantic Prior-U for general structures | Lemmas 7-11 | MEDIUM |
| Model surgery construction | Lemma 12 | VERY HIGH |
| "No definable gaps" semantic property | All of Theorem 14 | MEDIUM |
| Separation procedure | Expressive completeness | VERY HIGH |
| "Maximal interval" / interval topology | Lemmas 7-11 | MEDIUM |

### 4.3 Current `no_gaps_discrete` and `one_class`

**Current `no_gaps_discrete`** (IntegerModel.lean:804): Takes `IsSuccArchimedean` as hypothesis. The "proof" is actually trivial -- it shows exfalso from h_diff_class by constructing a finite subinterval (using IsSuccArchimedean to bound it) and applying finite_structures_good. The theorem says "if a and b are in different classes, contradiction" which is effectively `one_class` stated differently.

**Current `one_class`** (IntegerModel.lean:851): Also takes `IsSuccArchimedean`. Same proof pattern -- every subinterval is finite hence good.

**Both are mathematically WRONG as stated.** They use IsSuccArchimedean to make every bounded interval finite, but the REAL proof should use Prior-UZ to eliminate gaps and no_boundary_at_successor to eliminate successor boundaries, without assuming finite reachability.

### 4.4 The `succ_cofinal` Sorry

The `ChronicleAsPriorModel` structure (ChronicleExtraction.lean:103) declares `domain_succ_archimedean : IsSuccArchimedean domain`. This is the `succ_cofinal` sorry -- it asserts that the chronicle domain is succ-Archimedean without proof. The chronicle domain is a subtype of the rationals (LimitDomSubtype), and proving it is succ-Archimedean requires showing that the succ-iteration from any point eventually reaches any larger point.

---

## 5. Formalization Plan

### 5.1 Strategy Selection

There are three viable approaches:

**Approach A: Full Reynolds (Theorem 5 + Lemmas 6-13)**
- Faithful formalization of the proof
- Requires expressive completeness (Theorem 5), which requires Theorem 4 (separation)
- Estimated: 3000+ lines, 4-6 weeks
- NOT recommended

**Approach B: Semantic Prior-U + Direct FO Arguments (Bypass Temporal Formulas)**
- Reformulate Lemmas 6-13 at the monadic FO / k-type level
- Express "no definable gaps" as a property of the ordered monadic structure
- Use k-equiv transfer (doets_lemma_1_1) instead of expressive completeness
- Estimated: 600-900 lines, 1-2 weeks
- RECOMMENDED (medium difficulty, matches existing infrastructure)

**Approach C: Axiomatic Shortcut (Assume Expressive Completeness)**
- State expressive completeness as a sorry'd axiom
- Use it to prove Theorem 14 faithfully
- Replace the sorry later (or never, if the pipeline works)
- Estimated: 400-600 lines, 1 week
- ACCEPTABLE (fastest path to unblocking, with documented sorry)
- PROBLEM: Violates zero-debt policy

### 5.2 Recommended Approach: B (k-type Level Reformulation)

The key observation enabling Approach B:

**Reynolds's "expressive completeness" arguments are all used to feed monadic FO properties into Prior-U.** But Prior-U itself, when viewed semantically, is a statement about the STRUCTURE of definable sets. The core content of Theorem 14 is:

> "In a structure where all definable (by depth-k formulas) sets have no gaps, the equivalence classes of a contemporaneous relation have no gaps."

This can be reformulated entirely at the k-equivalence level:

1. **"Prior structure" reformulated**: Instead of "all instances of Prior-UZ are semantically valid," use "for any monadic formula phi(x) of depth <= k, if phi defines a non-empty upward-unbounded set, then it defines a set whose complement has no gap" (i.e., every definable set is a union of intervals whose endpoints are realized).

2. **"No gaps" reformulated**: Instead of "the class does not end at a gap," use "for every k'-type tau (where k' = k + constant), if the class boundary separates tau-points from non-tau-points, then the boundary is at a realized point."

3. **Model surgery reformulated**: Instead of "temporal truth is preserved under surgery," use "k-types are preserved under surgery" (which is essentially doets_lemma_1_4 applied to the appropriate ordered sum).

### 5.3 Concrete Implementation Plan

#### Phase 1: Semantic Prior-U Property (NEW DEFINITION)

Define a structure/typeclass capturing "Prior-U holds semantically":

```lean
/-- A structure satisfies Prior-U semantically at depth k if:
    for any temporal formula psi, if F(psi) holds at t, then there exists
    a nearest s > t where psi holds (with not-psi between t and s). -/
def prior_U_semantic (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds) : Prop :=
  forall (psi : Formula), forall (t : M.carrier),
    temporal_truth M atomMap t (Formula.some_future psi) ->
    temporal_truth M atomMap t (Formula.untl psi psi.neg)
```

**Estimated**: 30-40 lines including the dual Prior-S.

#### Phase 2: No Definable Gaps Property

Define "no k-definable gaps" directly on OrderedMonadicStructure:

```lean
/-- An ordered monadic structure has no k-definable gaps if:
    for any normal form nf of depth k, the set where nf holds is a
    union of intervals with realized endpoints. -/
def no_definable_gaps (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : Prop :=
  forall (nf : NormalForm sig k 1),
    forall (t : M.carrier),
    (exists s, t < s AND nf_eval_nf M k 1 (fun _ => s) nf) ->
    exists (boundary : M.carrier),
      t < boundary AND
      nf_eval_nf M k 1 (fun _ => boundary) nf AND
      forall r, t < r -> r < boundary -> NOT (nf_eval_nf M k 1 (fun _ => r) nf)
```

Wait -- that's not quite right either. "No definable gaps" means: if a definable set S is true up to some point and false after (with S true again eventually), then the boundary between S and its complement is realized. Let me think more carefully...

Actually, the cleanest reformulation at the k-type level is:

```lean
/-- Prior-U at the k-type level: if two adjacent k-types exist
    (one above the other with nothing between), then they are
    separated by a realized boundary point, not a gap. -/
def prior_U_ktype (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : Prop :=
  forall (t : M.carrier) (nf : NormalForm sig k 1),
    -- If nf holds at t but not always between t and some future point where nf holds...
    -- then there's a nearest such point
    sorry -- precise formulation needed
```

The precise formulation requires more thought. Let me state what's actually needed:

**The actual property used by Reynolds**: If a temporal formula psi holds continuously starting from t and eventually stops holding, then either:
- There is a last point where psi holds, OR
- There is a first point where not-psi holds

This is exactly what Prior-U ensures: `U(psi, chi) AND F(not-chi) -> U(not-chi OR K+(not-chi), chi)` says the transition from chi to not-chi cannot be a gap.

At the monadic FO level, this becomes: for any formula phi(x), the set {x : phi(x)} is "closed" in the order topology (no Dedekind gaps in its boundary).

**Estimated**: 40-60 lines.

#### Phase 3: Prove Prior-U Property Holds for Chronicle

Show that the chronicle's Prior-UZ validity (syntactic: formula in MCS) translates to the semantic Prior-U property on the chronicle-as-monadic-structure:

```lean
theorem chronicle_has_prior_U_semantic (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds -> Formula) (k : Nat) :
    prior_U_semantic sig k (chronicleAsMonadicStructure M sig atomMap) atomMap
```

This requires the truth lemma bridge (connecting MCS membership to temporal_truth). The U/S cases of the truth lemma are currently sorry'd in TruthLemma.lean. However, we can potentially use the PARAMETRIC truth lemma from the algebraic approach (which IS proved).

**Alternative**: Work with a more abstract "PriorStructure" typeclass that simply asserts the semantic property, and instantiate it for the chronicle separately.

**Estimated**: 80-120 lines (or 20 lines if we use the abstract approach).

#### Phase 4: Gap Elimination at k-type Level (Core Theorem)

This is the reformulation of Theorem 14:

```lean
theorem no_gaps_from_prior_U (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (h_prior : prior_U_semantic sig k M atomMap)
    (a b : M.carrier) (h_diff_class : NOT contemp_equiv sig k M a b) :
    -- The class boundary is at a successor pair, not a gap
    exists c : M.carrier, contemp_equiv sig k M a c AND
      NOT contemp_equiv sig k M a (Order.succ c) := by
```

The proof would follow Reynolds's structure but reformulated:
1. Assume a's class ends (there's a boundary)
2. Show the boundary can't be at a gap (using prior_U_semantic)
3. Therefore the boundary is between c and succ(c) for some c

**KEY INSIGHT for the reformulation**: In Reynolds's proof, "expressive completeness" converts FO formulas to temporal ones so Prior-U can be applied. In our reformulation, we need Prior-U to apply to monadic FO formulas directly. This is possible if we reformulate Prior-U as a property of the STRUCTURE (no definable gaps) rather than as a schema about temporal formulas.

The reformulated Prior-U property should be:

```lean
/-- No definable gaps: for any temporal formula psi, the set where psi holds
    does not have a gap in its right boundary. That is, if psi holds at t and
    there's a first point beyond t where psi fails, that point is realized. -/
def no_definable_gaps_temporal (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds) : Prop :=
  forall (psi : Formula) (t : M.carrier),
    temporal_truth M atomMap t psi ->
    (exists s, t < s AND NOT temporal_truth M atomMap s psi) ->
    exists boundary, t <= boundary AND
      temporal_truth M atomMap boundary psi AND
      (NOT temporal_truth M atomMap (Order.succ boundary) psi
       OR -- boundary is the last point where psi holds (succ exists)
       -- actually this needs more careful statement for the general discrete case
      )
```

Actually, Prior-U's precise semantic content in a discrete order is:
- If F(psi) holds at t (psi holds somewhere in the future), then U(psi, not-psi) holds at t
- U(psi, not-psi) means: there exists s > t where psi holds, and not-psi holds at all points between t and s

In a discrete order, "between t and s" means succ(t), succ(succ(t)), ..., pred(s). So Prior-U says: the nearest point where psi holds in the future can be reached by successor iteration (with not-psi holding at every intermediate point).

BUT WAIT -- this IS `IsSuccArchimedean` in disguise! If psi = True holds everywhere, then Prior-U(True) trivially holds. But if we pick psi carefully (e.g., "being in a particular k-type class"), Prior-U says that class boundary is reachable by successor iteration.

**This is the fundamental insight**: Prior-U on SPECIFIC formulas implies that certain definable boundaries are at successor-reachable distances. You don't need IsSuccArchimedean for ALL pairs -- you only need it for definable boundaries.

**Estimated for Phase 4**: 200-300 lines (the core theorem with case analysis).

#### Phase 5: Connect to one_class

```lean
theorem one_class_from_prior_U (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (h_prior : prior_U_semantic sig k M atomMap) :
    forall (a b : M.carrier), contemp_equiv sig k M a b := by
  -- Proof: Suppose not. Then by no_gaps_from_prior_U, boundary is at c/succ(c).
  -- But no_boundary_at_successor gives contemp_equiv c (succ c). Contradiction.
  intro a b
  by_contra h
  obtain ⟨c, hc_equiv, hc_succ_not⟩ := no_gaps_from_prior_U sig k M h_prior a b h
  exact hc_succ_not (no_boundary_at_successor sig k M c)
```

**Estimated**: 20-30 lines.

#### Phase 6: Remove IsSuccArchimedean from downstream theorems

Update `no_gaps_discrete`, `one_class`, `very_good_implies_good`, `chronicle_is_good` to use `prior_U_semantic` instead of `IsSuccArchimedean`.

**Estimated**: 50-100 lines of refactoring.

---

## 6. Assessment: Restricted Expressive Completeness

### 6.1 What Reynolds Actually Needs

Reynolds uses expressive completeness for the following specific formulas:
1. rho(x) = "x's class ends at a gap on the right" -- quantifier depth: 2-3 above epsilon
2. "x is in a class beginning with R AND K-(not-R)" -- quantifier depth: similar
3. "x is in the first class of an R-interval" -- quantifier depth: 1-2 above rho
4. "A holds somewhere in x's class" -- quantifier depth: depth(A) + 1 (quantification over class)
5. "sigma relativized to x's class" -- quantifier depth: depth(sigma)
6. "x is after some not-B in this class" -- quantifier depth: depth(B) + 1

### 6.2 Could a Restricted Version Suffice?

**Yes.** All formulas used have quantifier depth bounded by a function of k (the equivalence depth parameter). A version of expressive completeness restricted to "formulas of quantifier depth <= D over a fixed finite signature" would suffice.

**But**: Even the restricted version requires the 8 elimination lemmas (Lemma 10.2.3) which are the bulk of the work. The induction structure (Lemmas 10.2.4-10.2.8) handles arbitrary nesting depth, but the base cases (the 8 eliminations) are fixed.

### 6.3 The Simplest Possible Restricted Version

For the discrete case specifically, an even simpler approach exists:

**Observation**: In a discrete order, Prior-U applied to a formula psi says "if F(psi) at t, then there's a nearest point s > t where psi holds, reachable by successor iteration from t." The key content is "reachable by successor iteration."

If we could show that Prior-U on a specific set of formulas (those defining class boundaries) implies successor-reachability of those boundaries, we would have the one_class theorem without general expressive completeness.

**Specifically**: Let tau(x) be a temporal formula that is True throughout x's equivalence class and False outside it (such a formula exists IF we have expressive completeness). Then F(not-tau) at t means the class boundary is in the future. Prior-U on not-tau gives: there's a nearest point where not-tau holds, reachable by successor. This point is the boundary.

But constructing tau requires expressive completeness. The chicken-and-egg problem.

### 6.4 Breaking the Circularity

The circularity is:
- Theorem 14 needs expressive completeness to convert FO properties to temporal ones for Prior-U
- Expressive completeness is a big theorem (2000+ lines)
- We want to avoid formalizing all of it

**Resolution via Prior-U on FO formulas**: If we can show that Prior-U's semantic content extends to monadic FO formulas (not just temporal ones), we bypass expressive completeness entirely.

**Claim**: In a discrete Prior structure, for any monadic FO formula phi(x) of depth <= k, if phi defines a non-empty set in the future of t, then there's a NEAREST point where phi holds (reachable by successor from t).

**Proof sketch**: 
- phi(x) has a temporal equivalent A(x) in Prior structures (by expressive completeness)
- Prior-U applied to A gives the nearest point
- The nearest point for A = the nearest point for phi (they're equivalent)

We can break this circularity by proving the claim DIRECTLY for monadic FO formulas over discrete structures with Prior-UZ, without going through temporal formulas:

**Direct proof that Prior-UZ implies no FO-definable gaps in discrete orders**:
- Use table_correctness: every temporal formula has an FO equivalent
- Prior-UZ says: for every psi, F(psi) -> U(psi, not-psi)
- table(F(psi)) = exists s > t, table(psi)(s) -- an FO formula
- table(U(psi, not-psi)) = exists s > t, table(psi)(s) AND forall r (t < r < s -> not table(psi)(r))
- So for every FO formula of the form table(psi), the "nearest point" property holds
- BUT: Not every MonadicFormula is of the form table(psi)!

This brings us back to needing expressive completeness (the converse of table).

---

## 7. Final Recommended Plan

### 7.1 Two-Phase Strategy

**Phase A (Immediate, unblocks pipeline): Abstract Prior-U approach**

1. Define `PriorStructure` typeclass with semantic Prior-U/S
2. State `no_gaps_discrete` and `one_class` with `PriorStructure` hypothesis instead of `IsSuccArchimedean`
3. Prove `one_class` using: Prior-U implies no gaps (stated as axiom/sorry for now) + no_boundary_at_successor
4. Instantiate `PriorStructure` for the chronicle using `prior_UZ_valid`
5. This unblocks the full pipeline while leaving one well-scoped sorry

**Phase B (Follow-up: eliminate sorry)**

The sorry from Phase A is: "Prior-U semantic implies no gaps between contemporaneous equivalence classes." This is exactly Reynolds Theorem 14. To prove it:

Option B1: Prove Prior-U implies successor-reachability of k-definable boundaries directly (100-200 lines, avoiding expressive completeness entirely by using the DISCRETE structure + induction on distance)

Option B2: Formalize expressive completeness for Prior structures (Theorem 5) using the separation approach (2000+ lines)

### 7.2 Why Option B1 Might Work

In a DISCRETE order, Prior-UZ has a special strengthening:

**Prior-UZ**: F(psi) -> U(psi, not-psi)

In a discrete order, U(psi, not-psi) at t means: there exists s > t with psi(s) AND for all r with t < r < s, not-psi(r). Since the order is discrete, "t < r < s" means r is between t and s in the successor chain. So psi(s) and the nearest such s is succ^n(t) for some n.

Now the key lemma: **if two points a, b are NOT contemporaneously equivalent, then there exists a boundary point reachable by successor from a**.

Proof (using Prior-UZ semantically on the chronicle):
1. a and b are in different ~M classes
2. WLOG a < b (use symmetry)
3. The class of a has a supremum (it's bounded above by b)
4. We need to show: the class of a ends at a REALIZED boundary (successor pair c, c+1)
5. For contradiction, suppose the class of a has no last element (or the next class has no first element) -- this would be a "gap"
6. Consider the temporal formula R defined (via table_correctness backwards) as equivalent to "x is in the class of a" -- THIS IS WHERE WE NEED EXPRESSIVE COMPLETENESS
7. Wait -- we CAN'T construct R in general without expressive completeness

**Alternative for step 6**: Instead of constructing R, observe that IN A DISCRETE ORDER, "the class of a has a supremum that is not realized" is IMPOSSIBLE if the supremum is in the domain. The supremum must be some point c, and succ(c) exists (NoMaxOrder). So either c ~M succ(c) (handled by no_boundary_at_successor) or c is not-~M succ(c) (a boundary at c/succ(c), which is what we want).

WAIT -- this argument works! The key insight:

In a discrete order without endpoints (SuccOrder + NoMaxOrder + NoMinOrder), the equivalence class of a is a CONVEX subset. A convex subset of a discrete linear order is either:
- The whole domain, OR
- Has a boundary at some successor pair c / succ(c)

There are NO other options in a discrete linear order with NoMaxOrder/NoMinOrder! The "gap" situation (class bounded above but no last element and no first non-element) CANNOT happen because:
- Class is convex (subset of a linear order)
- Every element has a successor
- If c is in the class, either succ(c) is in the class too, or succ(c) is the first element not in the class

The class boundary MUST be at a successor pair. There's no room for a "gap" in a discrete order.

BUT WAIT -- this assumes the class is an INTERVAL of the order. In a non-Archimedean discrete order like Z + Z, a "gap" between the two copies means: the class of a point in the first Z can be bounded above WITHOUT having a "last element followed by first non-element" because the supremum is in the GAP between the two copies (not a point in the domain at all).

So the question reduces to: In the chronicle domain (which has SuccOrder and NoMaxOrder), can there be a point whose class is bounded above but with no "last point in class / first point out of class"?

In a SuccOrder, every point c has succ(c). If c is in the class, succ(c) is either in the class or not. If not, we have a boundary. If yes, we continue. The question is: can this process "run off to infinity" without finding a boundary?

YES -- in Z + Z, starting from any point in the first copy, iterating succ never reaches the second copy. The class (first copy) IS bounded above (by any point in the second copy) but iterating succ from any point stays in the first copy forever.

So the argument DOES fail without something like Prior-U / expressive completeness to rule this out.

### 7.3 The Essential Nature of the Problem

The core issue is:
- In Z + Z (discrete, no endpoints, NOT Archimedean), ~M classes CAN be proper subintervals that don't end at successor boundaries
- Prior-UZ prevents this, but its semantic content is inherently about TEMPORAL formulas
- Translating "the class boundary" into a temporal formula requires expressive completeness

**Therefore**: There is no cheap way around expressive completeness for the general Theorem 14. Any proof of one_class without IsSuccArchimedean MUST either:
1. Use expressive completeness (Theorem 5) to apply Prior-U
2. Use some restricted version of expressive completeness sufficient for the specific formulas needed
3. Prove IsSuccArchimedean directly for the chronicle (Option D from report 06)

### 7.4 Reassessing Option D (Prove succ_cofinal for Chronicle)

Given the analysis above, **Option D (prove IsSuccArchimedean for the chronicle domain directly) is far more practical** than formalizing Theorem 14 from scratch. The arguments:

1. The chronicle domain IS succ-Archimedean (it's order-isomorphic to Z by construction)
2. Proving this requires understanding the chronicle's construction (LimitDomSubtype)
3. Estimated effort: 150-250 lines
4. Does not require expressive completeness, separation, model surgery, or any new theory
5. Once proved, the existing `one_class` and `chronicle_is_good` work immediately

**The plan directive "NEVER add IsSuccArchimedean as a hypothesis"** should be reinterpreted: the theorems `no_gaps_discrete` and `one_class` can KEEP IsSuccArchimedean as a hypothesis, as long as we can PROVE it for the chronicle. This is mathematically correct: the chronicle IS succ-Archimedean.

### 7.5 Hybrid Strategy (FINAL RECOMMENDATION)

**Immediate path (unblocks pipeline in 1-2 days)**:
1. Prove `IsSuccArchimedean` for the chronicle domain (150-250 lines)
2. Existing `one_class` + `chronicle_is_good` work immediately
3. This eliminates the succ_cofinal sorry

**Future enhancement (if generality is desired)**:
1. Formalize Theorem 14 using Approach B (k-type reformulation)
2. Replace IsSuccArchimedean hypothesis with PriorStructure typeclass
3. This gives the full generality of Reynolds's result

**Estimated total effort**:
- Immediate path: 150-250 lines, 3-5 hours
- Full Theorem 14 (Option B): 600-900 additional lines, 1-2 weeks
- Full expressive completeness (Option A): 2000-2600 additional lines, 3-4 weeks

---

## 8. Dependency Summary

```
IMMEDIATE PATH:
  prove_succ_cofinal_for_chronicle (150-250 lines)
    -> existing one_class works (0 changes)
    -> existing chronicle_is_good works (0 changes)
    -> existing very_good_implies_good works (0 changes)
    -> Transfer.lean pipeline completes

FULL THEOREM 14 PATH:
  define PriorStructure typeclass (40 lines)
    -> prove no_definable_gaps_from_prior_U (200-300 lines)
      [REQUIRES: expressive completeness OR restricted version OR direct argument]
    -> prove one_class_from_prior_U (30 lines)
    -> prove chronicle_is_prior_structure (80-120 lines)
    -> Transfer.lean pipeline completes

  [Where "expressive completeness" requires either:]
    - Full separation proof: 2200-2600 lines
    - OR: sorry'd axiom (violates zero-debt)
    - OR: direct argument for discrete case only (unclear if possible)
```

---

## 9. Open Questions

1. **Can succ_cofinal be proved for the chronicle?** The chronicle domain is LimitDomSubtype -- a subtype of Q constructed by the Burgess construction. Is there a straightforward proof that it is succ-Archimedean? (This is the key question for the immediate path.)

2. **Is there a direct proof that Prior-UZ implies no FO-definable gaps in discrete orders?** Without expressive completeness, can we show directly (by induction on formula structure or depth) that the "nearest point" property extends from temporal formulas to all monadic FO formulas?

3. **What is the exact quantifier depth bound needed?** Reynolds uses expressive completeness for specific formulas. Their depth depends on k (the equivalence parameter). Is k bounded by the formula we're trying to prove complete for?

4. **Could omega-saturation or model completeness help?** The chronicle is constructed as a countable omega-saturated-like structure. Could this give us the Archimedean property directly?

---

## 10. Conclusion

Reynolds's Theorem 14 is a sophisticated 6-page argument using model surgery and expressive completeness. Formalizing it fully requires either the separation theorem (2000+ lines) or a novel restricted version. The most practical path to eliminating the succ_cofinal sorry is to prove IsSuccArchimedean directly for the chronicle domain, which requires understanding the chronicle construction's specific properties rather than the general theory of gap elimination.

If the full generality of Theorem 14 is desired (as a mathematical contribution beyond what's needed for bx_completeness), then the k-type reformulation approach (Approach B, ~600-900 lines) is recommended, but this requires first resolving the expressive completeness dependency at least for a restricted class of formulas.
