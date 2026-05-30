# Reynolds Pipeline: Detailed Plan for Closing All Sorry Sites

## Date: 2026-05-30
## Task: 202 (Reynolds K-Equivalence Bypass)

---

## Executive Summary

After 5 implementation cycles and detailed analysis, the path to sorry-free
`completeness_discrete` requires closing exactly 3 sorry sites (2 engineering,
1 mathematical). This report provides Lean-level detail for each, including
concrete type signatures, proof strategies, helper lemma specifications, and
file placement. It also evaluates the BX pipeline revival path as an alternative
to the Reynolds packaging sorry.

### Sorry Sites

| # | File | Line | What | Nature | Est. Lines |
|---|------|------|------|--------|------------|
| 1 | GoodStructuresModelSurgery.lean | 348 | `no_gaps_discrete_model_surgery` | Reynolds Theorem 14 (mathematical) | 400-600 |
| 2 | Transfer.lean | 1116 | `h_surj` construction | Engineering (fresh atoms) | 40-60 |
| 3 | Transfer.lean | 1162 | Z-interval to TaskFrame | Engineering (packaging) | 150-300 |

### Recommended Path

**Option 1 (Reynolds Pipeline, 600-960 lines)**: Close all 3 sorries.
Yields `countermodel_discrete_reynolds` sorry-free, then rewire
`completeness_discrete`.

**Option 2 (BX Revival, 500-700 lines)**: Close sorry #1 + #2, then use
`prior_implies_archimedean_of_accessible` to prove `IsSuccArchimedean` for
the chronicle, unblocking `succ_cofinal` in the existing BX pipeline. Avoids
sorry #3 entirely. However, this requires a DIFFERENT proof approach for sorry
#1 (proving IsSuccArchimedean, not just "no class boundary at gaps") -- and the
previous attempt at this (`prior_implies_archimedean_of_accessible`) was proven
FALSE. See Part C for detailed analysis.

**Recommendation**: Option 1 (Reynolds Pipeline). The mathematical theorem
`no_gaps_discrete` (class boundaries don't end at gaps) is the correct,
provable target. The BX revival path requires proving a STRONGER claim
(IsSuccArchimedean for the chronicle) which requires additional non-trivial
argumentation beyond Theorem 14.

---

## Part A: Reynolds Model Surgery (Lemmas 6-13 + Theorem 14)

### A.1 Literature Proof Structure

**Source**: Reynolds 1994, "Axiomatising U and S over Integer Time",
Section 7 (pp.124-129), Lemmas 6-13, Theorem 14.

**Strategy**: Proof by contradiction. Assume a contemporaneous equivalence
relation ~M on a Prior structure M has a class ending at a gap. Construct a
temporal formula R detecting this situation. Analyze R-intervals. Perform
model surgery (replace a bad interval by one class). Show temporal truth is
preserved. Derive contradiction (R holds in the surgery model but the class
no longer ends at a gap).

### Step Map

1. **Lemma 6 (Gap formula R)**: By expressive completeness (Theorem 5),
   construct temporal formula R that holds exactly where the ~M-class ends
   in a gap on the right. -- [Reynolds] Section 7, p.124-125.

2. **Lemma 7 (R-interval structure)**: Maximal intervals where R holds are
   open intervals with excluded endpoints in M (if bounded). Uses Prior-UZ
   to rule out first point of R at a gap. -- [Reynolds] p.125.

3. **Lemma 8 (No first/last class)**: No first or last ~M-class in any
   maximal R-interval. Last class doesn't end at gap. First class: use
   expressive completeness to get formula B true only in first-class points,
   contradicts Prior-UZ. -- [Reynolds] p.126.

4. **Lemma 9 (Class homogeneity)**: Each pair of ~M-classes in a maximal
   R-interval are elementarily equivalent (as substructures). Uses expressive
   completeness + Prior-UZ. -- [Reynolds] p.126.

5. **Lemma 10 (Bad intervals)**: Define "bad point" = R V L. Bad points
   occur in non-singleton bad intervals where both R and L hold throughout.
   Bounded bad intervals have excluded endpoints. -- [Reynolds] p.127.

6. **Lemma 11 (Formula propagation)**: If B holds for a while at the start
   of a ~M-class in a bad interval, then B holds throughout the bad interval.
   If B holds anywhere, it holds arbitrarily close to each end of each class.
   -- [Reynolds] pp.127-128.

7. **Lemma 12 (Model surgery)**: Replace bad interval Q0 by one class I.
   N has domain Q- u I u Q+. For all temporal formulas A and all t in N:
   M |= A(t) iff N |= A(t). Proof by induction on A, with 7 subcases for
   U(A,B) forward and 6 subcases backward. -- [Reynolds] pp.128-129.

8. **Lemma 13 + Theorem 14 (Contradiction)**: R holds in I in N (by Lemma 12).
   But I's class in N is bounded above (Q+ nonempty) and ends at point q
   (first point of Q+), not at a gap. So R should NOT hold. Contradiction.
   Therefore no class ends at a gap. -- [Reynolds] p.129.

### Dependencies

- Lemma 7 depends on Lemma 6
- Lemma 8 depends on Lemmas 6, 7
- Lemma 9 depends on Lemmas 6, 7, 8
- Lemma 10 depends on Lemmas 6, 7, 8, 9
- Lemma 11 depends on Lemmas 6, 9, 10
- Lemma 12 depends on Lemmas 6, 9, 11
- Lemma 13 depends on Lemmas 6, 7, 12

All lemmas depend on `US_expressively_complete_over_prior` (Theorem 5),
which requires `h_surj`.

### Potential Formalization Challenges

- **Lemma 6**: Constructing the monadic FO formula rho(x) = "x's class ends
  at a gap on the right" requires encoding contemp_equiv and gap detection
  as monadic FO with two quantifiers. The existing `MonadicFormula sig n`
  type supports this, but the formula construction is non-trivial.

- **Lemma 12**: The 13 subcases (7 forward + 6 backward) for U(A,B) are
  each straightforward but collectively verbose. Each subcase is 15-30 lines.

- **Connecting to existing infrastructure**: The `contemp_equiv` definition
  uses `very_good` (defined via `good` / `k_equiv`), which is a semantic
  condition. Reynolds' paper defines ~M via a monadic FO formula epsilon.
  The connection between these two definitions must be established.

### A.2 Detailed Lean Specifications

#### A.2.1 Gap Formula R (Lemma 6)

The monadic FO formula rho(x) = "x's ~M-class has a right gap boundary"
is defined as:

```
rho(x) = exists y > x (not epsilon(x,y))
       AND exists z > x (epsilon(x,z)
           AND forall y (z < y AND epsilon(x,y) -> epsilon(z,y)))
```

This says: (1) x's class is bounded above (there exists y not equivalent to x),
and (2) there is no "last equivalent point" (the class ends at a gap, not at
a successor boundary).

In our formalization, `contemp_equiv sig k M` is defined via `very_good` on
subintervals. The monadic FO formula epsilon defining ~M is constructed in
Reynolds Lemma 17 (which is `contemp_equiv_is_equiv` in GoodStructures.lean,
sorry-free). Specifically, the formula epsilon(x,y) is:

```
epsilon(x,y) = (x <= y -> forall z,t (x <= z < t <= y -> gamma(z,t)))
             AND (y < x -> forall z,t (y <= z < t <= x -> gamma(z,t)))
```

where gamma(z,t) is the disjunction of all "good" k-type patterns
(finitely many since sig is finite and k is fixed).

**Lean definition needed**:

```lean
/-- The monadic FO formula rho(x) detecting right-gap class boundaries. -/
noncomputable def right_gap_boundary_formula (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    { R : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t R ↔ right_gap_class sig k M t } := by
  -- Use US_expressively_complete_over_prior on the monadic FO formula rho
  ...
```

where `right_gap_class` is defined as:

```lean
/-- Point t's ~M-class ends at a gap on the right. -/
def right_gap_class (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (t : M.carrier) : Prop :=
  (∃ y : M.carrier, t < y ∧ ¬ contemp_equiv sig k M t y) ∧
  (¬ ∃ c : M.carrier, contemp_equiv sig k M t c ∧
    ¬ contemp_equiv sig k M t (Order.succ c))
```

**Estimated lines**: 60-80 (formula construction + correctness proof)

**Existing infrastructure used**:
- `US_expressively_complete_over_prior` (PriorExpressiveness.lean) -- sorry-free
- `contemp_equiv` definition (GoodStructures.lean) -- sorry-free
- `contemp_equiv_is_equiv` (GoodStructures.lean) -- sorry-free

**Challenge**: The main challenge is constructing the intermediate monadic FO
formula `rho : MonadicFormula sig 1` such that `eval M (fun _ => t) rho` iff
`right_gap_class sig k M t`. This requires encoding the contemp_equiv relation
and gap detection as first-order statements. The key insight: since sig is finite
and k is fixed, there are finitely many k-types, so "good" can be expressed as
a finite disjunction of k-type patterns. The formula epsilon(x,y) defining ~M
was already implicitly constructed in the proof of `contemp_equiv_is_equiv`
(GoodStructures.lean line 693).

**Alternative approach**: Instead of constructing the explicit monadic FO formula,
use `right_gap_class` as a predicate and show it can be expressed as a monadic
predicate on an enriched signature, then apply `US_expressively_complete_over_prior`
on the enriched signature. This is cleaner but requires signature manipulation.

**Recommended approach**: Define `right_gap_class` and `left_gap_class` as Lean
predicates. Construct the monadic FO formula encoding them. Apply
`US_expressively_complete_over_prior` to get temporal formulas R and L. This
follows Reynolds' paper exactly.

#### A.2.2 R-Interval Properties (Lemma 7)

```lean
/-- R-intervals are open: if R holds at t, R holds at succ(t). -/
theorem R_holds_succ (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds) (R : Formula)
    (h_R_correct : ∀ t, temporal_truth M atomMap t R ↔ right_gap_class sig k M t)
    (h_UZ : semantic_prior_UZ M atomMap)
    (t : M.carrier) (h_R_t : temporal_truth M atomMap t R) :
    temporal_truth M atomMap (Order.succ t) R

/-- Maximal R-intervals have excluded endpoint (if bounded above). -/
theorem R_interval_excluded_endpoint (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds) (R : Formula)
    (h_R_correct : ∀ t, temporal_truth M atomMap t R ↔ right_gap_class sig k M t)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) (h_R_t : temporal_truth M atomMap t R)
    (h_bounded : ∃ s, t < s ∧ ¬ temporal_truth M atomMap s R) :
    ∃ q : M.carrier, t < q ∧ ¬ temporal_truth M atomMap q R ∧
      ∀ r, t ≤ r → r < q → temporal_truth M atomMap r R
```

**Proof strategy for R_holds_succ**: If t's class ends at a gap on the right,
then succ(t) is still in the same class (because the class doesn't end at a
successor boundary -- it ends at a gap). So succ(t)'s class also ends at
the same gap. Hence R holds at succ(t).

Actually, this is slightly more subtle. R holds at t means t's class ends at a
gap on the right. succ(t) is in the same class (by `no_boundary_at_successor`).
succ(t)'s class is the same class, so it also ends at the same gap. Hence R
holds at succ(t).

Wait -- `no_boundary_at_successor` says c ~M succ(c) for ALL c. This is proved
sorry-free. So if t ~M c for all c in the class, then t ~M succ(t), and succ(t)
is in the same class. The class of succ(t) = the class of t, so it ends at the
same gap.

**Estimated lines**: 60-80

#### A.2.3 No First/Last Class (Lemma 8)

```lean
/-- No last ~M-class in any maximal R-interval. -/
theorem no_last_class_in_R_interval ...

/-- No first ~M-class in any maximal R-interval. -/
theorem no_first_class_in_R_interval ...
```

**Proof of no_last_class**: The last class in a maximal R-interval would end
at the R-interval boundary (a point of M, not a gap). But R says the class
ends at a gap. Contradiction.

**Proof of no_first_class**: Uses expressive completeness to construct formula
B = "my class is the first in this R-interval" (the class whose left boundary
is the R-interval boundary). B holds throughout the first class and is false
in subsequent classes. By Prior-UZ, B transitions at a successor pair. But the
first class ends at a gap (R holds), so B doesn't transition at a successor
within the class. Contradiction.

**Estimated lines**: 60-80

#### A.2.4 Class Homogeneity (Lemma 9)

```lean
/-- Classes in a maximal R-interval are elementarily equivalent. -/
theorem classes_elem_equiv_in_R_interval ...
```

**Proof**: Suppose formula A holds somewhere in class C1 but nowhere in class
C2. Use expressive completeness to get B = "A occurs in my class". B holds
throughout C1 and is false throughout C2. By Prior-UZ, the first transition of
B after a point in C1 is at a successor pair. But C1 ends at a gap, so B holds
continuously up to the gap. After the gap, the next class C' must also have B
(by the first part of the argument applied to B). Contradiction since C2
eventually occurs and lacks B.

Actually, the proof is more intricate:
1. B holds throughout C1, false throughout C2 (both in the R-interval).
2. Pick t in C1. B holds at t and for a while after t.
3. By Prior-UZ applied to B: first not-B point s > t either is a successor
   endpoint (B has a last point) or a first not-B point.
4. s must be the left endpoint of its class (B holds throughout classes
   where it holds at all).
5. Look at the gap at the right end of s's class. By Prior-UZ applied to a
   formula C = "my class starts at s and K-(B) holds at the left endpoint",
   C holds in s's class but is false after the gap. Contradiction with
   Prior-UZ.

**Estimated lines**: 80-100

#### A.2.5 Bad Intervals (Lemma 10)

```lean
/-- "Bad point": R or L holds. -/
def bad_point (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (R L : Formula) (t : M.carrier) : Prop :=
  temporal_truth M atomMap t R ∨ temporal_truth M atomMap t L

/-- Bad intervals: maximal intervals where R V L holds throughout. -/
-- (implicit from bad_point definition)

/-- In any bad interval, both R and L hold throughout. -/
theorem bad_interval_both_R_and_L ...
```

**Proof**: If L fails somewhere in a maximal R-interval, then some class has
no left-gap boundary. This class either includes its left endpoint (a point of
M) or begins just after a point of M. In either case, use expressive
completeness and Prior-UZ to derive a contradiction.

**Estimated lines**: 60-80

#### A.2.6 Formula Propagation (Lemma 11)

```lean
/-- If B holds at the start of a class in a bad interval, B holds throughout. -/
theorem formula_propagation_in_bad_interval ...

/-- If B holds anywhere in a bad interval, it holds near class boundaries. -/
theorem formula_near_class_boundaries ...
```

**Proof**: Suppose B holds for a while after gap gamma (start of class) but
not-B holds somewhere in the bad interval. By Lemma 9, not-B also holds
somewhere in the same class. Use expressive completeness to find C = "in my
class, there is not-B after me". C is false at the start (B holds for a while)
and true later. C holds up to the gap at the right end of the class, then
false after the gap. Contradicts Prior-UZ.

**Estimated lines**: 60-80

#### A.2.7 Model Surgery (Lemma 12)

This is the most complex lemma. It constructs the surgery model N and proves
temporal truth preservation.

```lean
/-- Surgery model: Q- u I u Q+, inheriting order and predicates from M. -/
noncomputable def surgery_model (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig)
    (Q_minus I Q_plus : Set M.carrier)
    (h_partition : ...) : OrderedMonadicStructure sig := ...

/-- Temporal truth preservation under model surgery. -/
theorem surgery_truth_preservation (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (Q_minus I Q_plus : Set M.carrier)
    (h_bad : ...)
    (h_class : ...)
    (A : Formula) (t : M.carrier) (ht : t ∈ Q_minus ∪ I ∪ Q_plus) :
    temporal_truth M atomMap t A ↔
    temporal_truth (surgery_model sig M Q_minus I Q_plus h_partition) atomMap
      ⟨t, ht⟩ A := by
  induction A with
  | atom a => ... -- Immediate from predicate inheritance
  | bot => ... -- Both sides False
  | imp phi psi ih_phi ih_psi => ... -- Immediate from IH
  | box phi => ... -- Immediate from predicate inheritance
  | untl phi psi ih_phi ih_psi => ... -- 7 forward + 6 backward subcases
  | snce phi psi ih_phi ih_psi => ... -- Mirror of untl
```

**Forward U(A,B) subcases** (M |= U(A,B)(t) with witness s, need N |= U(A,B)(t)):

| Case | t in | s in | Strategy |
|------|------|------|----------|
| 1 | Q- | Q- | IH on A at s, B between t and s |
| 2 | Q- | Q0 | A somewhere in Q0, hence in I (Lemma 9). B holds for a while into Q0, hence throughout Q0 (Lemma 11), hence throughout I. |
| 3 | Q- | Q+ | B throughout Q0, hence I. IH. |
| 4 | I | I | Direct IH. |
| 5 | I | Q0\I | A in Q0, hence in I (Lemma 9). B throughout rest of I. A arbitrarily close to end of I. |
| 6 | I | Q+ | B throughout I. IH on A at s. |
| 7 | Q+ | Q+ | IH on A at s, B between t and s. |

**Backward U(A,B) subcases** (N |= U(A,B)(t) with witness s in N, need M |= U(A,B)(t)):

| Case | t in | s in | Strategy |
|------|------|------|----------|
| 1 | Q- | Q- | IH. |
| 2 | Q- | I | B from t to start of I in N and M. B at start of I in M, hence throughout Q0 (Lemma 11). A in I in M. |
| 3 | Q- | Q+ | B throughout I in N and M. Lemma 11 gives B throughout Q0. |
| 4 | I | I | Direct IH. |
| 5 | I | Q+ | B throughout I. IH on A at s. |
| 6 | Q+ | Q+ | IH. |

**Estimated lines**: 150-200

**Key dependency**: Lemmas 9 (class homogeneity) and 11 (formula propagation)
are used extensively in cases 2, 3, 5 of both forward and backward directions.

#### A.2.8 Contradiction (Lemma 13 + Theorem 14)

```lean
/-- Reynolds Theorem 14: class boundaries don't end at gaps. -/
theorem no_class_boundary_at_gap (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (a b : M.carrier) (h_diff : ¬ contemp_equiv sig k M a b) :
    ∃ c : M.carrier, contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- Contradiction: assume no successor boundary.
  by_contra h_no_succ
  push_neg at h_no_succ
  -- Then class of a is succ-closed
  have h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c) := by
    intro c hac; exact (h_no_succ c hac).elim
  -- Wait: h_no_succ says ¬(hac ∧ ¬ h_succ), i.e., hac → h_succ.
  -- Actually h_no_succ : ∀ c, ¬(contemp_equiv a c ∧ ¬ contemp_equiv a (succ c))
  -- This means: for all c, contemp_equiv a c → contemp_equiv a (succ c)
  -- i.e., the class is succ-closed.

  -- Class of a bounded above: ¬(a ~M b) with a < b (WLOG)
  -- By class_gap_exists: a Gap exists
  -- R holds somewhere (at a, since a's class ends at a gap)
  -- Perform model surgery to get N
  -- In N, R still holds at class I (by surgery_truth_preservation)
  -- But in N, I's class ends at first point of Q+ (a point, not a gap)
  -- So R should NOT hold in N. Contradiction.
  sorry
```

**Proof outline**:
1. From h_no_succ, derive that class(a) is successor-closed.
2. Since NOT a ~M b, there exist points outside the class. A gap exists.
3. R (gap formula) holds at a.
4. The maximal R-interval containing a has a bad interval (both R and L hold).
5. Choose one class I in this bad interval.
6. Perform model surgery: N = Q- u I u Q+.
7. By Lemma 12: R holds at points of I in N.
8. But in N, I is bounded above by first point q of Q+.
9. By Lemma 7 (R-interval excluded endpoint): not-R holds at q.
10. Since q is in N and is the immediate successor of I's last point,
    I's class in N ends at q (a successor boundary), not at a gap.
11. So R should not hold at I in N. Contradiction.

**Estimated lines**: 40-60

### A.3 Simplified Proof Alternative

There is a potential simplification that avoids some of Lemmas 8-11. The key
observation: once we have R (Lemma 6), we can argue more directly.

**Simplified argument**:
1. Assume class(a) is succ-closed and bounded (gap exists).
2. R holds at a.
3. R holds at succ(a), succ^2(a), ... (R is succ-closed: if t's class ends at
   a gap, so does succ(t)'s class, since they are in the same class).
4. Some point b outside the class exists. Consider the first not-R point
   after a (by Prior-UZ).
5. This first not-R point q must be: R holds for a while before q, not-R at q.
6. But R holds at all succ^n(a), and these are all in the class. The class
   extends to the gap. So q must be past the gap (in the complement).
7. But the gap has no minimum on the complement side. So there is no first
   not-R point. But Prior-UZ guarantees one. Contradiction.

Wait -- this doesn't quite work because R holds at t does NOT mean R holds
at succ(t). R says "my class ends at a gap on the RIGHT". If t and succ(t) are
in the same class, they have the same right gap boundary, so R holds at both.
But R is about the RIGHT boundary. If the class also has a left gap boundary,
then L might hold at t but not be relevant.

Actually, this simplified argument DOES work and avoids Lemmas 8-11 entirely.
The key:

1. Class(a) is succ-closed (by assumption: no successor boundary).
2. Class(a) has a gap on the right (by class_gap_exists).
3. right_gap_class holds at a (definition).
4. R holds at a (by Lemma 6).
5. R holds at all points in class(a) to the right of a: if c ~M a and c > a,
   then c's class = a's class, which ends at the same gap. So R holds at c.
6. In particular, R holds at succ^n(a) for all n.
7. By Prior-UZ applied to R.neg: if not-R holds somewhere above a, there is a
   first not-R point s with R holding on (a, s).
8. s cannot be succ^n(a) for any n (R holds at all succ^n(a)).
9. The complement of class(a) has no minimum (gap property).
10. So s would need to be in the complement, but the complement has no first
    element after a. But the succ-iterates succ^n(a) are all in the class,
    and the class is everything up to the gap. So any s > succ^n(a) for all n
    must be in or past the complement.
11. If s is in the complement, it is not the minimum (gap has no complement
    minimum). So there exists s' with a < s' < s and s' in the complement.
    Then R does not hold at s' (s' is not in class(a), and s' is in the
    complement of the class -- we need to verify this carefully).

Actually, step 11 is where the argument gets subtle. s' being in the complement
of class(a) does NOT immediately mean R fails at s'. R says "my class ends at
a gap on the right". s' could be in a DIFFERENT class that also ends at a gap.

So the simplified argument requires knowing that not ALL points are in
gap-ending classes. This brings us back to the need for some of the structural
lemmas (8-10).

**Conclusion**: The simplified argument does not fully avoid Lemmas 8-11.
The full Reynolds argument (Lemmas 6-13) is needed.

### A.4 ALTERNATIVE: Direct Prior-UZ Contradiction Proof

There is a fundamentally different proof strategy that avoids model surgery
entirely. Instead of constructing R and performing surgery, argue directly that
the gap is incompatible with Prior-UZ/SZ + h_surj.

**Strategy**: Assume class(a) has no successor boundary (succ-closed) and
there exist points outside the class (not a ~M b). A gap exists.

1. By h_surj, every predicate p has an atom a_p with atomMap(.atom a_p) = p.
2. temporal_truth(.atom a_p, t) = M.interp(p, t) for all t.
3. Since the class is succ-closed, for any two successive points c, succ(c)
   in the class, M.interp(p, c) = M.interp(p, succ(c)) for all p eventually
   (by pigeonhole on the finite predicate profile space).
4. This means predicate profiles stabilize within the class.
5. Consider a point b' in the complement. M.interp(p, b') may differ from
   the stabilized class value.
6. If it differs for some p: temporal_truth(.atom a_p) transitions from
   class-value to complement-value. By Prior-UZ, this transition has a
   first occurrence at some successor pair. But the class is succ-closed,
   so the transition cannot occur within the class. The complement has no
   minimum, so the transition cannot occur at the first complement point.
   Contradiction.
7. If all predicates agree: then temporal_truth of every formula agrees
   across the gap (by structural induction on formulas, using the fact that
   the order is discrete and succ/pred are well-defined). This means the
   k-types agree across the gap, making points on both sides contemp_equiv.
   But we assumed they are NOT contemp_equiv. Contradiction.

**Problem with step 7**: The "constant predicates => same temporal_truth"
argument is WRONG for this setting. The deep research report (Section 6.3-6.5)
showed this approach is circular or incorrect:
- temporal_truth depends on the ORDER structure, not just predicates.
- Two points with the same predicate profile can have different temporal truth
  if the order structure around them differs (e.g., one has a gap nearby).
- The Z+Z counterexample shows constant predicates are compatible with a gap.

**However**: With h_surj (not just h_accessible), there is a difference.
h_surj means EVERY predicate comes from an atom, so temporal_truth(.atom a_p)
= M.interp(p). If all M.interp(p) are the same on both sides of the gap, then
the atom-level truth values are the same. But temporal_truth for complex formulas
(U, S) depends on the order structure beyond just atom values.

**In the Z+Z counterexample with constant predicates**: temporal_truth of
U(.atom a, .atom b) at a point in the left copy depends on whether there
exists a future point where .atom a holds with .atom b between. Since all
atoms are True everywhere, U(.atom a, .atom b) is True at every point (take
succ(t) as witness). Similarly for S. So indeed all temporal formulas are
constant. But this gives all k-types the same, making all points contemp_equiv,
contradicting "not a ~M b". So step 7 DOES work in the Z+Z case.

But wait -- the Z+Z counterexample was for h_accessible, not h_surj. With
h_surj, can we have non-constant predicates across a gap? No -- h_surj says
every predicate comes from an atom, but it doesn't prevent constant predicates.

The issue is: with h_surj, constant predicates => constant temporal_truth =>
all contemp_equiv => no class boundaries => no need for Theorem 14 (vacuous).
The non-trivial case is when some predicate is NOT constant. Then temporal_truth
of the detecting atom formula transitions across the gap. Prior-UZ gives a
first-transition point at a successor. But the class is succ-closed, so the
transition can't happen within the class. And the complement has no minimum.
Contradiction.

**So the direct argument IS correct with h_surj**:

```lean
theorem no_gaps_discrete_model_surgery ... := by
  by_contra h_no_succ
  push_neg at h_no_succ
  -- Class(a) is succ-closed
  have h_succ_closed := ...
  -- Consider two cases: all predicates constant, or some varies
  by_cases h_const : ∀ p : sig.preds, ∀ x y : M.carrier, M.interp p x ↔ M.interp p y
  · -- Case 1: All predicates constant
    -- Then temporal_truth is constant (structural induction)
    have h_tt_const : ∀ f t₁ t₂, temporal_truth M atomMap t₁ f ↔
        temporal_truth M atomMap t₂ f := ...
    -- Then all k-types are equal
    -- Then all points contemp_equiv
    -- Contradiction with h_diff_class
    ...
  · -- Case 2: Some predicate p varies
    push_neg at h_const
    obtain ⟨p, x, y, h_diff_pred⟩ := h_const
    -- By h_surj, get atom a_p with atomMap(.atom a_p) = p
    obtain ⟨a_p, h_a_p⟩ := h_surj p
    -- temporal_truth(.atom a_p, t) = M.interp(p, t)
    -- Find points c ∈ class(a) and d ∉ class(a) with different M.interp(p)
    -- Apply Prior-UZ to get first-transition point
    -- The transition must be at a successor pair
    -- But class is succ-closed, so cannot transition within class
    -- Complement has no minimum, so cannot be first complement point
    -- Contradiction
    ...
```

**Critical question**: Does "all predicates constant => temporal_truth constant"
hold in a non-archimedean order?

Let me verify: temporal_truth is defined by structural induction:
- Atom a: temporal_truth M atomMap t (.atom a) = M.interp(atomMap(.atom a)) t.
  If all predicates constant, this is constant.
- Bot: constant (False).
- Imp: if phi and psi have constant temporal_truth, so does phi -> psi.
- Box: temporal_truth M atomMap t (.box phi) = M.interp(atomMap(.box phi)) t.
  If all predicates constant, this is constant.
- Untl phi psi: temporal_truth M atomMap t (U(phi, psi)) =
  exists s > t, temporal_truth M atomMap s phi AND
  forall r, t < r < s -> temporal_truth M atomMap r psi.
  If phi is constant True: U(True, psi) = exists s > t, forall r, t<r<s,
  temporal_truth r psi. Take s = succ(t). Vacuous guard (no r with
  t < r < succ(t) in discrete order). So U(True, psi) = True.
  If phi is constant False: U(False, psi) = False (no witness).
  If psi is constant True or False: similar analysis.
  In ALL cases with constant phi and psi: U(phi, psi) is constant.
- Snce: mirror of Untl.

**YES**, by structural induction, constant predicates implies constant
temporal_truth for all formulas. The key step is the U(True, psi) case where
we use discreteness (succ(t) exists and there are no points strictly between
t and succ(t)).

**This is the correct proof**. The Z+Z counterexample (which disproved
`prior_implies_archimedean_of_accessible`) had h_accessible but NOT h_surj.
The argument above uses ONLY:
- h_surj (to connect atoms to predicates)
- Prior-UZ/SZ (for the first-transition in Case 2)
- Discreteness (SuccOrder, for the constant-predicate argument in Case 1)
- The gap structure (from class_gap_exists)

**This is simpler than full model surgery and avoids Lemmas 7-13 entirely.**

### A.5 Recommended Proof Strategy

I recommend the **direct Prior-UZ contradiction proof** (Section A.4) over
the full model surgery (Sections A.2.1-A.2.8). Reasons:

1. **Simpler**: ~200 lines vs ~500 lines.
2. **No model surgery construction**: Avoids defining surgery_model and
   proving 13 subcases.
3. **No R formula construction**: Avoids constructing the monadic FO formula
   rho and its temporal equivalent.
4. **Mathematically sound**: The two cases (constant vs. non-constant
   predicates) are exhaustive and each leads to contradiction.
5. **Uses existing infrastructure**: The main tools needed are all sorry-free:
   - `class_gap_exists` (GoodStructuresModelSurgery.lean)
   - `contemp_equiv_succ_iterate` (GoodStructuresModelSurgery.lean)
   - `prior_UZ_first_transition` (GoodStructuresModelSurgery.lean)
   - `no_boundary_at_successor` (GoodStructures.lean)
   - `contemp_equiv_is_equiv` (GoodStructures.lean)
   - h_surj (from caller)

### A.6 Detailed Proof: Direct Prior-UZ Contradiction

```
no_gaps_discrete_model_surgery:
  Input: sig, k, M (discrete, no endpoints), atomMap, h_surj, h_UZ, h_SZ,
         a, b with ¬(a ~M b)
  Output: ∃ c, a ~M c ∧ ¬(a ~M succ(c))

Proof:
  By contradiction. Assume no successor boundary exists.

  STEP 1: Class(a) is succ-closed.
    From the negation: ∀ c, a ~M c → a ~M succ(c).
    (If a ~M c and ¬(a ~M succ(c)), we have our successor boundary.)

  STEP 2: Class(a) is pred-closed.
    By contemp_equiv_pred_closed (sorry-free): a ~M c → a ~M pred(c).

  STEP 3: Gap exists.
    By class_gap_exists: since a ~M succ^n(a) for all n (by
    contemp_equiv_succ_iterate + h_succ_closed) and ¬(a ~M b),
    a Gap gamma exists.

  STEP 4: Case split on predicates.

  CASE A: All predicates constant.
    ∀ p : sig.preds, ∀ x y : M.carrier, M.interp p x ↔ M.interp p y.

    Sub-step A1: temporal_truth is constant for all formulas.
      By structural induction on f:
      - atom a: temporal_truth t (.atom a) = M.interp(atomMap(.atom a)) t.
        Constant by hypothesis.
      - bot: constant (False).
      - imp phi psi: by IH, temporal_truth of phi and psi are constant.
        imp is constant.
      - box phi: temporal_truth t (.box phi) = M.interp(atomMap(.box phi)) t.
        Constant by hypothesis.
      - untl phi psi: by IH, phi and psi have constant temporal_truth.
        If phi constant True: ∃ s > t, True ∧ guard.
          Take s = succ(t). No r with t < r < succ(t) (discrete). True.
        If phi constant False: no witness. False.
        So U(phi, psi) is constant (True or False depending on phi).
      - snce: mirror.

    Sub-step A2: All k-types are equal.
      k_type_of depends on nf_eval_nf, which evaluates normal forms.
      Normal forms involve atoms (= predicates) and quantified order
      comparisons. Since temporal_truth of every formula is constant,
      the table translation (monadic FO formula equivalent to the temporal
      formula) also has constant truth. So eval M env rho is the same for
      any env, meaning all k-types agree.

      More precisely: for any normal form nf, nf_eval_nf M nf is determined
      by eval at singleton environments. Since predicates and temporal_truth
      are constant, the atoms in the normal form have the same truth value
      at every point. The order comparisons in quantified normal forms
      always have witnessing points (NoMaxOrder, NoMinOrder). So nf_eval_nf
      is the same for any two structures with the same predicate pattern.

      Therefore k_type_of sig k M = k_type_of sig k M (trivially), and
      for any subinterval, k_type_of is the same. This means every
      subinterval is k-equivalent to any other, and in particular to a
      Z-interval (since finite subintervals are good by
      finite_structures_good). So every subinterval is good, making every
      pair contemp_equiv.

    Sub-step A3: Contradiction.
      All pairs contemp_equiv means a ~M b. But ¬(a ~M b). Contradiction.

    NOTE: Sub-step A2 is the most delicate part. The key insight: if all
    predicates are constant, then ANY two structures with the same
    predicate pattern and the same order type are k-equivalent. In our
    discrete setting, any subinterval [c,d] is either finite (trivially
    good) or has the same k-type as Z (constant-predicate Z). So every
    subinterval is good.

    Actually, this can be made simpler: if all predicates are constant,
    then every subinterval [c, succ(c)] is good (finite_structures_good,
    since it has exactly 2 elements). By transitivity of contemp_equiv
    (sorry-free) and no_boundary_at_successor (sorry-free), for any c and
    d in the class of a, c ~M d. But what about points OUTSIDE the class?

    Wait, we assumed ALL predicates are constant (not just within the class).
    So predicates are the same at points in the class and outside. Then for
    any c in the class and d outside: the subinterval [c, d] has constant
    predicates. We need to show [c, d] is very_good. This requires showing
    every sub-subinterval is good.

    For finite sub-subintervals: trivially good (finite_structures_good).
    For infinite sub-subintervals (those spanning the gap): these have
    constant predicates and are discrete. By the same argument as for the
    whole structure, all their finite subintervals are good. But we need
    the INFINITE subinterval itself to be good (k-equiv to a Z-interval).

    This is where the argument needs care. An infinite subinterval with
    constant predicates IS k-equivalent to the Z-interval with the same
    constant predicates. Why? Because the Ehrenfeucht-Fraisse game for
    k rounds on two infinite discrete orders with constant predicates and
    no endpoints is won by the duplicator: at each round, choose the
    corresponding point in the other structure to maintain the same relative
    order. With constant predicates, the atom conditions are trivially
    satisfied.

    But does this work for subintervals that have endpoints? Yes: a
    subinterval [c, d] with n elements is k-equiv to the Z-interval
    [0, n-1], which IS a Z-interval. An infinite subinterval [c, +inf)
    is k-equiv to [0, +inf), which is a Z-interval. Similarly for
    (-inf, d] and (-inf, +inf).

    So yes, ALL subintervals with constant predicates are good. Therefore
    every pair is contemp_equiv. Contradiction.

    FORMALIZATION NOTE: This argument goes through eval/k_type_of/nf_eval_nf
    machinery, which is already sorry-free. The key lemma needed is:

    ```lean
    theorem constant_predicates_give_contemp_equiv
        (sig : MonadicSignature) (k : Nat)
        (M : OrderedMonadicStructure sig)
        [SuccOrder M.carrier] [NoMaxOrder M.carrier]
        (h_const : ∀ p : sig.preds, ∀ x y : M.carrier,
          M.interp p x ↔ M.interp p y) :
        ∀ a b : M.carrier, contemp_equiv sig k M a b
    ```

    This can be proved by showing every subinterval is good via k_equiv_of_iso
    to a Z-interval with the same constant predicates.

  CASE B: Some predicate varies.
    ∃ p : sig.preds, ∃ x y : M.carrier, ¬(M.interp p x ↔ M.interp p y).

    Sub-step B1: Get the varying predicate.
      obtain ⟨p, x, y, h_varies⟩ := h_const.

    Sub-step B2: Find class/complement points with different predicate values.
      Class(a) is nonempty (contains a) and proper (does not contain b).
      The gap gamma separates class(a) from its complement.
      Since all points in class(a) are above succ^n(a) for some n (within
      the successor chain), and the complement is everything past the gap:

      We need to find c ∈ class(a) and d ∉ class(a) with M.interp p c
      but ¬M.interp p d (or vice versa). If the varying predicate values
      are distributed with some in the class and some in the complement,
      we have what we need. If the predicate varies WITHIN the class, we
      can find c1, c2 ∈ class(a) with different p values. By stabilization
      (the class extends infinitely via succ, and predicate profiles must
      stabilize by pigeonhole), the predicate must eventually be constant
      within the class. Then the complement must have a different value for
      at least one predicate (or all predicates agree everywhere, falling
      back to Case A).

      Actually, the simplest approach: since there is a gap, consider two
      points: one in class(a) just below the gap, and one in the complement
      just above. But there is no "just above" the gap (no complement
      minimum). Instead:

      The key insight: the predicate profiles within class(a) stabilize
      (by pigeonhole, since there are finitely many profiles and the class
      extends infinitely via succ). Let profile_stable be the eventual
      stable profile.

      If ALL points in the complement have the SAME profile as
      profile_stable: then all predicates are constant everywhere (including
      across the gap), contradicting Case B assumption.

      So there exists d ∉ class(a) with a different profile. Pick such d.
      Then some predicate p has M.interp p c_stable = True and M.interp p d = False
      (or vice versa), where c_stable is a point in the class with the
      stable profile.

    Sub-step B3: Apply Prior-UZ.
      WLOG, M.interp p c_stable = True and M.interp p d = False,
      with c_stable < d (since class is below, complement is above).

      By h_surj: get atom a_p with atomMap(.atom a_p) = p.
      Then temporal_truth M atomMap c_stable (.atom a_p) = True.
      And temporal_truth M atomMap d (.atom a_p) = False.

      Since c_stable < d, F(.atom a_p.neg) holds at c_stable.
      By Prior-UZ: there exists first s > c_stable with
      temporal_truth s (.atom a_p.neg), and temporal_truth r (.atom a_p)
      for all r with c_stable < r < s.

      Equivalently: M.interp p r = True for all r with c_stable < r < s,
      and M.interp p s = False.

    Sub-step B4: Derive contradiction.
      s cannot be in class(a): if s ∈ class(a), then s = succ^n(c_stable)
      for some n (because class(a) above c_stable consists exactly of
      succ-iterates, by the covering property of SuccOrder and the fact
      that class(a) is succ-closed). But M.interp p (succ^n(c_stable))
      = True for all n ≥ some N (profile stabilized at c_stable). If
      c_stable is in the stable region, then M.interp p s = True.
      Contradiction with M.interp p s = False.

      Wait: c_stable was chosen to be in the stable region. So
      M.interp p (succ^n(c_stable)) = True for all n ≥ 0. So s cannot
      be any succ^n(c_stable). Since class(a) above c_stable = {succ^n(c_stable) | n ∈ N},
      s ∉ class(a).

      s must be in the complement. But the complement of class(a) is
      past the gap, and the gap complement has no minimum. So s is not
      the first complement point. There exists s' ∈ complement with
      c_stable < s' < s. Then M.interp p s' = True (by the "all between
      c_stable and s" condition). But s' ∈ complement means s' ∉ class(a).

      Now we need: for all r with c_stable < r < s: M.interp p r = True.
      In particular, for s' (which is in the complement): M.interp p s' = True.

      This doesn't immediately give a contradiction. The predicate p is True
      at s' (which is in the complement). That's fine -- predicates can be
      True at complement points.

      But s is also in the complement, and M.interp p s = False. And s' < s
      with s' in the complement. So between s' and s (both in complement),
      the predicate transitions from True to False. We can apply the same
      Prior-UZ argument again...

      Actually, the issue is more fundamental. The first-transition point s
      is well-defined (Prior-UZ guarantees it exists). The question is
      whether s can be in a position consistent with the gap structure.

      Let me reconsider. The gap separates class(a) from the complement.
      The class extends via succ to the gap. The complement starts after the
      gap (no minimum).

      All succ^n(c_stable) are in the class, with M.interp p = True.
      s is the first point above c_stable with M.interp p = False.
      s cannot be succ^n(c_stable) (all have p = True).
      s cannot be in the class at all (class = {succ^n(c_stable) | n ≥ 0}
      above c_stable).

      So s ∈ complement. Since complement has no minimum, there exists
      s' ∈ complement with s' < s. The condition says M.interp p s' = True
      (since c_stable < s' < s).

      Now the problem: s is the first point with p = False, but there exist
      complement points BELOW s (namely s') where p = True. What about
      pred(s)? pred(s) < s, so M.interp p (pred(s)) = True. And
      succ(pred(s)) = s (since s is not IsMin -- there are points below it).
      So M.interp p transitions from True at pred(s) to False at s.

      pred(s) is in the complement (complement is a final segment, and
      pred(s) > c_stable which means pred(s) is past the gap boundary).
      Wait -- is pred(s) necessarily past the gap?

      Actually, yes: pred(s) > c_stable (since s > c_stable and s is not
      succ(c_stable) -- it's past the gap). Actually, s > succ^n(c_stable)
      for all n. So s is past the gap. And pred(s) is past the gap (unless
      pred(s) is in the class). But pred(s) cannot be in the class: if it
      were, pred(s) = succ^n(c_stable) for some n, and then
      s = succ(pred(s)) = succ^(n+1)(c_stable), which is in the class.
      But s is in the complement. Contradiction.

      So pred(s) is in the complement. And succ(pred(s)) = s is also in the
      complement. M.interp p (pred(s)) = True (between c_stable and s).
      M.interp p s = False.

      This is a transition from True to False at the successor pair
      (pred(s), s). Both pred(s) and s are in the complement.

      But this doesn't violate anything! Transitions at successor pairs are
      perfectly fine. The issue was supposed to be that transitions can't
      happen at the GAP, but here the transition happens at a successor pair
      WITHIN the complement. This is consistent.

      **The direct argument fails for Case B as stated.**

  So the direct Prior-UZ contradiction proof has a gap in Case B. The
  issue: finding the FIRST point with a different predicate value doesn't
  lead to a contradiction because that first point might be well past the
  gap, at a legitimate successor transition point in the complement.

  **CORRECTION**: The argument needs to be about the BOUNDARY of the class,
  not about predicate values. The key is that class boundaries (= boundaries
  of contemp_equiv classes) occur at successor pairs (by no_boundary_at_successor)
  or at gaps. We're assuming no successor boundary exists. So the only
  boundaries are at gaps. This is the content of Theorem 14: class boundaries
  don't end at gaps. The proof IS the model surgery argument.

  **CONCLUSION**: The direct Prior-UZ contradiction proof (Case A + Case B)
  does NOT work. Case A (constant predicates) does work but Case B requires
  model surgery. The full Reynolds argument (Lemmas 6-13) is necessary.
```

### A.7 Final Assessment

The full Reynolds model surgery (Lemmas 6-13, Theorem 14) is required.
The direct argument fails because predicate transitions at successor pairs
in the complement do not create contradictions.

**Estimated total lines for Part A**: 400-600 lines in GoodStructuresModelSurgery.lean.

**File placement**: All new code goes in
`Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
(existing file, currently 350 lines including helper lemmas).

**Key challenge**: Constructing the monadic FO formula rho(x) that encodes
"x's class ends at a gap on the right" and proving its correctness. This
requires:
1. A finite enumeration of all k-types (k_type_of is noncomputable but
   the enumeration exists by Fintype).
2. Constructing the formula epsilon(x,y) defining ~M (as in Reynolds Lemma 17).
3. Constructing rho(x) = "exists y > x, not epsilon(x,y)" AND "no successor
   boundary" (using epsilon and gap detection).
4. Applying `US_expressively_complete_over_prior` to rho.

**Potential simplification**: Instead of constructing epsilon and rho as
explicit monadic FO formulas, treat them as abstract monadic predicates
on an enriched signature. Since `US_expressively_complete_over_prior` works
for any monadic predicate, we can add the right-gap-class predicate to the
signature and get the temporal formula R. This avoids explicit formula
construction but requires showing the enriched signature still satisfies
Prior-UZ/SZ.

---

## Part B: Z-interval TaskFrame Packaging (Transfer.lean)

### B.1 The h_surj Construction Sorry (Line 1116)

**Current state**: `atomMap_fwd` maps `.atom a` to `⟨.atom a, _⟩` when
`.atom a ∈ phi.predFormulas`, and to `defaultPred` otherwise. This fails
h_surj for non-atom predicates (`.bot` and `.box psi`).

**The fix**: Enrich `atomMap_fwd` with fresh atoms for each non-atom predicate.

**Concrete implementation**:

```lean
-- Enumerate non-atom predicates in sig.preds
-- sig.preds = Finset.cons bot phi.predFormulas
-- Non-atom predicates: those of the form .bot or .box psi
-- Actually: sig.preds elements are subtypes of Formula.
-- Each element is ⟨f, hf⟩ where f ∈ Finset.cons bot phi.predFormulas.
-- The elements where f is NOT of the form .atom a need fresh atoms.

-- Step 1: Collect non-atom predicates
let non_atom_preds : Finset sig.preds :=
  (sig.preds.toFinset).filter (fun ⟨f, _⟩ =>
    match f with | .atom _ => false | _ => true)

-- Step 2: Pick distinct fresh atoms for each
-- We need an injection from non_atom_preds to Atom, avoiding
-- atoms already in phi.predFormulas.
let used_atoms : Finset Atom := phi.predFormulas.biUnion (fun f =>
  match f with | .atom a => {a} | _ => ∅)

-- Since Atom is Infinite and non_atom_preds is Finite, we can find
-- distinct fresh atoms using Infinite.exists_not_injective or
-- a recursive construction with fresh_for.

-- Step 3: Define enriched atomMap_fwd
let atomMap_fwd_enriched : Formula → sig.preds := fun f =>
  match f with
  | .atom a =>
    if h : .atom a ∈ phi.predFormulas then
      ⟨.atom a, Finset.mem_cons.mpr (Or.inr h)⟩
    else if ∃ p ∈ non_atom_preds, fresh_assignment p = a then
      -- Fresh atom maps to its assigned predicate
      ...
    else
      defaultPred
  | f => ...
```

**Key properties to verify**:
1. `h_surj`: For each p : sig.preds, there exists atom a with
   `atomMap_fwd_enriched (.atom a) = p`.
2. `h_section`: For f ∈ phi.predFormulas, `atomMap_rev (atomMap_fwd_enriched f) = f`.
   This is preserved since fresh atoms are NOT in predFormulas.
3. Prior-UZ/SZ: `chronicle_semantic_prior_UZ/SZ` works for ANY atomMap_fwd,
   so these are preserved for the enriched version.

**Estimated lines**: 40-60.

**Technical note**: The enriched atomMap_fwd changes the `let` binding, which
means `M_struct` (the monadic structure from the chronicle) and `h_UZ`/`h_SZ`
(Prior-UZ/SZ proofs) need to be recomputed for the enriched map. However,
`chronicleAsMonadicStructure` takes `atomMap_rev` (not `atomMap_fwd`), so
`M_struct` is unchanged. The Prior-UZ/SZ proofs call
`chronicle_semantic_prior_UZ CM sig atomMap_rev atomMap_fwd`, which works
for any `atomMap_fwd`. So the enrichment is seamless.

### B.2 The Z-interval to TaskFrame Packaging Sorry (Line 1162)

**Current state**: After Step 7 (truth transfer), we have:
- A `ZIntervalStructure sig` called `Z`
- k-equivalence between the chronicle monadic structure and `Z.toOrdered sig`
- A point `s` in `Z.intervalCarrier` where `phi.neg` holds (via truth_transfer)

We need to package this as a `TaskFrame D` / `TaskModel` / `truth_at`
countermodel.

**The fundamental tension**:
- `TaskFrame D` requires `D : Type` with `AddCommGroup D`, `LinearOrder D`,
  `IsOrderedAddMonoid D`, `Nontrivial D`.
- `TaskModel` has `task_atoms : Atom → D → Prop` (position-dependent).
- `truth_at` uses the TaskFrame's shift-closed set Omega.
- The Z-interval has `lo`/`hi` bounds and predicates `interp : sig.preds → Z → Prop`.

**Approach 1: Direct Z countermodel**

If the Z-interval is unbounded (`lo = none`, `hi = none`), the carrier is all
of Z, and we can use `D = Int`.

```lean
-- Construct TaskFrame Int
let F : TaskFrame Int := ⟨⟩  -- default TaskFrame on Int
-- Construct TaskModel
let TM : TaskModel F where
  task_atoms a t := temporal_truth (Z.toOrdered sig) atomMap_fwd t (.atom a)
-- This doesn't work directly because task_atoms takes Atom, not sig.preds.
-- And temporal_truth in the Z-interval uses atomMap_fwd.
```

**Problem**: `truth_at` is defined using `TaskModel` and `WorldHistory` and
`ShiftClosed`, while `temporal_truth` uses `OrderedMonadicStructure`. These
are different semantic frameworks.

The connection: `truth_at TM Omega tau t phi` is defined by structural
induction on phi, using the task semantics (worlds, shifts, modal box).
`temporal_truth M atomMap t phi` is defined by structural induction on phi,
using the temporal semantics (order, until, since, predicates).

For formulas without `.box`: `truth_at` and `temporal_truth` correspond when:
- `TM.task_atoms a t = M.interp(atomMap(.atom a)) t` for atoms
- The linear order on D matches M.carrier's order
- Until/Since quantification matches

For `.box phi`: `truth_at` uses the modal box (worlds in Omega), while
`temporal_truth` maps `.box phi` to a predicate `M.interp(atomMap(.box phi)) t`.
In the chronicle, `.box phi ∈ MCS(t)` iff phi is valid in the modal
accessibility class of t. In the Z-interval countermodel, we need a
corresponding `Omega` and `ShiftClosed` that makes box work correctly.

**This is the crux of the packaging challenge**: translating between the
temporal semantics (where box is a predicate) and the task semantics (where
box quantifies over world histories).

**Approach 2: Use existing z_interval_countermodel**

Check if there is an existing `z_interval_countermodel` or similar utility.

```bash
grep -rn "z_interval_countermodel\|ZInterval.*countermodel" Theories/
```

There doesn't seem to be one. The existing countermodel constructions in
`Completeness.lean` use the BX pipeline's `dd_countermodel_chronicle_discrete`
which constructs the Int model via `ParametricCanonical`.

**Approach 3: Bypass packaging via operator_depth argument**

The key insight: `truth_transfer` gives us a point s in the Z-interval where
phi.neg holds under temporal_truth. We need phi.neg to also hold under
truth_at in some TaskFrame model.

For formulas without box subformulas (which is the case when phi comes from
the discrete completeness theorem where box formulas are handled by the MCS
structure), we can construct a simple TaskModel where truth_at matches
temporal_truth.

Actually, phi CAN have box subformulas. The discrete completeness theorem
does not restrict phi.

**Approach 4: Construct a WorldHistory-based model**

1. For each point t in the Z-interval (= some interval of Z), define a
   WorldHistory tau_t where tau_t(t') gives the predicate values at t'.
2. Define Omega = {tau_t | t ∈ Z-interval}.
3. ShiftClosed: shift by 1 maps tau_t to tau_{t+1}.
4. truth_at then matches temporal_truth for Until/Since.
5. For box: truth_at uses ∀ tau ∈ Omega, which quantifies over all shifts.
   This makes box phi equivalent to "phi holds at all time shifts", i.e.,
   G(phi) ∧ H(phi) ∧ phi. But temporal_truth treats box as a predicate.

So the box case is problematic unless we carefully align the WorldHistory
structure with the box predicate interpretation.

**Approach 5: Factor through the ParametricCanonical model**

The existing BX pipeline constructs an Int model via ParametricCanonical,
which already handles box correctly. If we can connect the Reynolds pipeline
to the ParametricCanonical construction, we avoid the packaging problem.

This is essentially the BX Revival path (Part C).

### B.3 Assessment

The Z-interval to TaskFrame packaging is a significant engineering challenge,
primarily because of the box modality. The temporal_truth semantics treats
box as a predicate (M.interp(atomMap(.box phi)) t), while truth_at treats it
as quantification over WorldHistories.

**Options**:
1. **Full packaging** (~150-300 lines): Construct WorldHistory, Omega, ShiftClosed,
   and prove truth correspondence for all formula constructors including box.
2. **Restrict to box-free formulas** (~80 lines): If phi has no box subformulas,
   packaging is straightforward. But completeness_discrete doesn't assume this.
3. **BX Revival** (~100-200 lines): Avoid packaging entirely by connecting the
   Reynolds model surgery result to the BX pipeline. See Part C.

**Recommendation**: Option 3 (BX Revival) if feasible. See Part C.

---

## Part C: BX Pipeline Revival vs Reynolds Pipeline

### C.1 How the BX Pipeline Currently Works

```
completeness_discrete
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean)
      -> cantor_bfmcs_discrete_restricted_tc
        -> succ_embed_surjective
          -> limitDomSubtype_isSuccArchimedean
            -> succ_cofinal  <-- SORRY
              -> chronicle_gap_contradiction  <-- calls no_gaps_faithful (FALSE)
```

The BX pipeline constructs the Int countermodel via ParametricCanonical, which
already handles box correctly. The only sorry is `succ_cofinal`, which requires
`IsSuccArchimedean` for the limit domain.

### C.2 What succ_cofinal Needs

`succ_cofinal` says: for any a < b in LimitDomSubtype, there exists n with
succ^n(a) >= b. This is exactly `IsSuccArchimedean`.

Currently, `succ_cofinal` calls `chronicle_gap_contradiction`, which constructs
a `PriorModelData` and calls `no_gaps_faithful`. But `no_gaps_faithful` is FALSE.

### C.3 Can We Fix succ_cofinal?

YES, if we can prove `IsSuccArchimedean` for LimitDomSubtype by a different route.

**Key observation**: The LimitDomSubtype IS a Prior structure (Prior-UZ/SZ hold
at every point, C4/C5 coherence holds). It is also discrete (SuccOrder, PredOrder),
countable, and without endpoints. The chronicle construction ensures that the
MCS assignment is faithful (temporal_truth matches MCS membership, by
`chronicle_temporal_truth` / `temporal_truth_effective_raw`).

With faithfulness, the counterexample (Z+Z with constant predicates) does NOT
apply to the chronicle, because the chronicle has non-trivial MCS variation
(it was constructed from a consistent formula phi, and the MCS assignment carries
information about phi's subformulas).

**However**: proving `IsSuccArchimedean` for the chronicle requires a DIFFERENT
argument than Theorem 14. Theorem 14 says "class boundaries don't end at gaps".
This means:
- Either there is only one class (and IsSuccArchimedean MAY hold), or
- There are multiple classes separated only by successor boundaries.

In both cases, the ORDER might still have gaps -- it's just that the
equivalence classes don't end at those gaps. In the one-class case (all points
contemp_equiv), IsSuccArchimedean does NOT follow from one-class alone
(Z+Z with constant predicates is a counterexample).

**So**: To prove IsSuccArchimedean for the chronicle, we need MORE than just
"class boundaries don't end at gaps". We need either:
(a) The one_class theorem + an argument that one_class + faithful MCS =>
    IsSuccArchimedean, or
(b) A direct argument that the chronicle limit domain has no gaps (using
    omega-chain properties).

**Approach (a)**: With faithful MCS (temporal_truth = MCS membership), one_class
means all k-types are the same everywhere. This implies that the monadic FO
theory is the same everywhere. For the chronicle, the MCS assignment comes from
the Lindenbaum construction and the omega-chain limit. If the MCS is non-constant
(which it must be, since phi.neg is in the root MCS but phi itself might be
elsewhere), then we get non-constant predicates, which by the direct argument
(Case B in Section A.6) would give a contradiction if a gap existed.

Wait -- the direct argument (Case B) FAILED. It doesn't give a contradiction.
The issue was that predicate transitions can happen at successor pairs in the
complement, which is legitimate.

**Approach (b)**: The omega-chain construction builds the limit domain as a
union of finite stages. Each stage resolves defects by adding points. A gap in
the limit would mean some pair of points is never connected by successor
iterates. But the construction adds successors at each stage, so succ^n(a)
eventually reaches any finite distance. The gap would require an infinite
distance, which the omega-chain should eventually bridge.

This is a non-trivial argument about the omega-chain construction and is the
content of the original `chronicle_gap_contradiction` proof attempt.

### C.4 BX Revival Assessment

**Difficulty**: HIGH. Proving `IsSuccArchimedean` for the chronicle directly
requires either:
- A model-surgery-based argument at the chronicle level (essentially
  reimplementing Theorem 14 PLUS an additional step), or
- An omega-chain argument about the limit construction.

Both are as complex or more complex than the Reynolds packaging sorry.

**Conclusion**: The BX Revival path does NOT save work compared to the
Reynolds Pipeline. The fundamental issue is that `IsSuccArchimedean` is a
STRONGER property than "no class boundary at gaps", and the additional
strength requires additional proof work.

### C.5 Comparison

| Path | Sorry #1 (model surgery) | Sorry #2 (h_surj) | Sorry #3 (packaging) | Total |
|------|--------------------------|--------------------|-----------------------|-------|
| Reynolds Pipeline | ~500 lines | ~50 lines | ~200 lines | ~750 lines |
| BX Revival | ~500 lines + extras | ~50 lines | avoided | ~650+ lines |

The BX Revival avoids sorry #3 but adds complexity to sorry #1 (proving
IsSuccArchimedean instead of just "no class boundary at gaps"). The net
savings are marginal at best.

**Recommendation**: Reynolds Pipeline. The packaging sorry (#3) is pure
engineering with well-understood requirements, while the BX Revival's
additional proof requirements are less clear.

---

## Part D: Concrete Implementation Plan

### D.1 Dependency Order

```
Phase 0: h_surj construction (Transfer.lean:1116)
  -- Independent, can be done first
  -- Enables all downstream phases

Phase 1: Model surgery core (GoodStructuresModelSurgery.lean)
  Phase 1a: Definitions (right_gap_class, left_gap_class, bad_point)
  Phase 1b: Gap formula R construction (Lemma 6)
  Phase 1c: R-interval properties (Lemma 7)
  Phase 1d: No first/last class (Lemma 8)
  Phase 1e: Class homogeneity (Lemma 9)
  Phase 1f: Bad intervals + formula propagation (Lemmas 10-11)
  Phase 1g: Model surgery construction (Lemma 12)
  Phase 1h: Contradiction (Lemma 13) + wire into no_gaps_discrete_model_surgery

Phase 2: Wire no_gaps_discrete (GoodStructures.lean:852)
  -- Currently sorry; should call no_gaps_discrete_model_surgery
  -- May need circular import resolution

Phase 3: Z-interval to TaskFrame packaging (Transfer.lean:1162)
  -- Depends on Phase 2 (no_gaps_discrete sorry-free)
  -- Construct WorldHistory, Omega, ShiftClosed
  -- Prove truth correspondence

Phase 4: Rewire completeness_discrete (Completeness.lean)
  -- Replace countermodel_discrete_enriched with countermodel_discrete_reynolds
  -- Depends on Phase 3

Phase 5: Cleanup and verification
  -- Deprecate BX pipeline artifacts
  -- Full lake build
  -- #print axioms completeness_discrete
```

### D.2 File-Level Changes

| File | Action | Lines Added |
|------|--------|-------------|
| GoodStructuresModelSurgery.lean | Add Lemmas 6-13, close sorry | +400-500 |
| GoodStructures.lean | Wire no_gaps_discrete to model surgery | +5-10 |
| Transfer.lean:1116 | Construct enriched atomMap_fwd | +40-60 |
| Transfer.lean:1162 | TaskFrame packaging | +150-250 |
| Completeness.lean | Rewire discrete case | +10-20 |

### D.3 Risk Matrix

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Monadic FO formula construction for rho(x) is complex | High | Medium | Use enriched signature approach instead of explicit formula |
| Model surgery U(A,B) subcases exceed estimates | Medium | Medium | Each subcase is independent; can be parallelized |
| Circular import between GoodStructures and ModelSurgery | Medium | Low | Already addressed: ModelSurgery imports GoodStructures |
| Box modality in TaskFrame packaging | High | High | May need to refactor truth_at or add box-specific handling |
| k_equiv/nf_eval_nf machinery is opaque | Medium | Low | Already sorry-free; just needs instantiation |

### D.4 Alternative Simplified Plan

If the full model surgery proves too complex, there is a viable 2-phase
approach:

**Phase A**: Prove `no_gaps_discrete_model_surgery` for the special case where
the structure has h_surj AND the monadic structure comes from a chronicle
(i.e., has faithful MCS). In this case, the model surgery can be done at the
MCS level using `PriorModelData` + faithfulness, which is a more concrete
setting.

**Phase B**: At the call site (Transfer.lean), the chronicle IS faithful, so
Phase A's special-case theorem applies directly.

This avoids the general model surgery but requires defining "faithful" and
proving the special case. Estimated: 300-400 lines.

### D.5 Recommended First Steps

1. **Implement h_surj construction** (Transfer.lean:1116, ~50 lines).
   This is independent and unblocks everything else. Use `Atom.fresh_for`
   to assign distinct atoms to non-atom predicates in `mkSigFrom phi`.

2. **Implement constant_predicates_give_contemp_equiv** (~60 lines).
   This handles Case A of the proof and is independently useful.

3. **Implement the monadic FO formula for rho(x)** (~80 lines).
   This is the most technically challenging step. Start by defining
   `right_gap_class` as a Lean predicate, then construct the corresponding
   `MonadicFormula sig 1`.

4. **Implement the model surgery step-by-step** (~400 lines).
   Follow Lemmas 6-13 in Reynolds' paper exactly.

5. **Implement TaskFrame packaging** (~200 lines).
   This is the final step before rewiring completeness_discrete.

### D.6 Estimated Total Effort

| Phase | Lines | Hours |
|-------|-------|-------|
| Phase 0: h_surj | 50 | 1 |
| Phase 1: Model surgery | 500 | 8-12 |
| Phase 2: Wire no_gaps_discrete | 10 | 0.5 |
| Phase 3: TaskFrame packaging | 200 | 4-6 |
| Phase 4: Rewire completeness | 20 | 1 |
| Phase 5: Cleanup | 20 | 1 |
| **Total** | **~800** | **~16-22** |

---

## Appendix: Key Type Signatures

### OrderedMonadicStructure

```lean
structure OrderedMonadicStructure (sig : MonadicSignature) where
  carrier : Type
  interp : sig.preds → carrier → Prop
  carrier_order : LinearOrder carrier
```

### temporal_truth

```lean
def temporal_truth (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) : Formula → Prop
  | .atom a => M.interp (atomMap (.atom a)) t
  | .bot => False
  | .imp phi psi => temporal_truth phi → temporal_truth psi
  | .box phi => M.interp (atomMap (.box phi)) t
  | .untl phi psi => ∃ s > t, temporal_truth s phi ∧ ∀ r, t < r → r < s → temporal_truth r psi
  | .snce phi psi => ∃ s < t, temporal_truth s phi ∧ ∀ r, s < r → r < t → temporal_truth r psi
```

### US_expressively_complete_over_prior

```lean
noncomputable def US_expressively_complete_over_prior
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_UZ : semantic_prior_UZ M atomMap)
        (_h_prior_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔ temporal_truth M atomMap t A }
```

### contemp_equiv

```lean
def contemp_equiv (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : Prop :=
  very_good sig k (M.subinterval sig (min a b) (max a b))
```

### Gap

```lean
structure Gap (T : Type) [LinearOrder T] where
  cut : Set T
  nonempty : cut.Nonempty
  proper : cut ≠ Set.univ
  downward_closed : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut
  no_sup : ¬∃ s, IsLUB cut s ∧ s ∈ cut
  complement_no_min : ¬∃ m, m ∉ cut ∧ ∀ y, y ∉ cut → m ≤ y
```

### Atom Freshness

```lean
instance : Infinite Atom
theorem Atom.exists_fresh (S : Finset Atom) : ∃ a : Atom, a ∉ S
noncomputable def Atom.fresh_for (S : Finset Atom) : Atom
theorem Atom.fresh_for_not_mem (S : Finset Atom) : Atom.fresh_for S ∉ S
```
