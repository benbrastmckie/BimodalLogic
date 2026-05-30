# Research Report 16: reynolds_model_surgery_core Implementation Strategy

## Date: 2026-05-30
## Task: 202 (Reynolds K-Equivalence Bypass)
## Focus: Concrete proof strategy for the sole remaining mathematical sorry

---

## 1. Problem Statement

The single mathematical sorry blocking sorry-free `completeness_discrete`:

```lean
-- GoodStructuresModelSurgery.lean:500-512
theorem reynolds_model_surgery_core (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c)) :
    ∀ y : M.carrier, contemp_equiv sig k M a y := by
  sorry
```

**What it says**: If the contemp_equiv class of `a` is closed under successor,
then it contains ALL points (i.e., the class is the whole carrier).

**Why it matters**: Used by `gap_contradicts_prior` and `gap_contradicts_prior_below`
(both sorry-free once this is proved), which feed `no_gaps_discrete_model_surgery`,
which closes `no_gaps_discrete` in GoodStructures.lean, which gives `one_class`,
which ultimately reaches `completeness_discrete`.

---

## 2. What Has Been Tried and Why It Failed

### 2.1 Direct IsSuccArchimedean Argument (Plans v1-v5)
**Idea**: Prove the order is IsSuccArchimedean, then `one_class_archimedean` finishes.
**Failure**: `prior_implies_archimedean_of_accessible` was FALSE. Z+Z with constant
predicates satisfies Prior-UZ/SZ + h_accessible but is NOT archimedean.

### 2.2 Direct Predicate Transition Argument (Report 15, Section A.4-A.6)
**Idea**: Case split: (A) all predicates constant => all contemp_equiv; (B) some
predicate varies => Prior-UZ gives first-transition at successor pair => contradiction.
**Failure**: Case B fails. The first-transition point can legitimately be at a
successor pair WITHIN the complement (past the gap). Predicate transitions at
successor pairs in the complement do not create contradictions.

### 2.3 Enriched Signature Approach (Implementation cycle 4)
**Idea**: Add class membership as a new predicate, then use Prior-UZ on it.
**Failure**: Prior-UZ does NOT hold for the enriched structure because class
membership transitions at the gap (no first occurrence), violating the
first-occurrence property that Prior-UZ requires.

### 2.4 Z+Z Counterexample Discovery
Z+Z with constant predicates proves that ANY approach relying solely on
predicates/atoms is insufficient. The full Reynolds model surgery
(constructing a new structure and proving truth preservation) IS required.

---

## 3. Recommended Approach: Full Reynolds Model Surgery

### 3.1 Overview

Reynolds 1994, Section 7, Lemmas 6-13, Theorem 14. The proof proceeds by
contradiction: assume the class of `a` is proper (bounded) and succ-closed.
A gap exists. Construct a temporal formula R detecting "my class ends at a
gap on the right". Analyze R-intervals. Perform model surgery (replace a
"bad interval" by a single class). Prove temporal truth is preserved under
surgery. Derive contradiction (R holds in the surgery model but the class
no longer ends at a gap).

### 3.2 Why This Approach Is Correct

The model surgery approach is the ONLY approach that works because:

1. It does not rely on predicate constancy arguments (which fail for Case B).
2. It does not try to prove IsSuccArchimedean (which is false for Z+Z).
3. It works at the level of temporal truth preservation, which is exactly
   what contemp_equiv measures (via very_good / k_equiv).
4. It follows Reynolds' original proof, which is mathematically sound.

### 3.3 Proof Structure (Step-by-Step)

**Setup**: We have `a : M.carrier` with `h_succ_closed` (class succ-closed)
and we want to prove `∀ y, contemp_equiv sig k M a y`. By contradiction,
assume `∃ b, ¬ contemp_equiv sig k M a b`. Then:

#### Step 1: Gap Existence
From `h_succ_closed` and `¬ contemp_equiv sig k M a b`, by `class_gap_exists`
(already sorry-free), a `Gap M.carrier` exists. The gap's cut is
`C = {x | ∃ n, x ≤ succ^[n](a)}` -- the successor orbit of `a`.

**Existing infrastructure**: `class_gap_exists` (GoodStructuresModelSurgery.lean:311, sorry-free).

#### Step 2: Gap Formula R via Expressive Completeness (Lemma 6)

**Key insight**: We need a temporal formula R such that `temporal_truth M atomMap t R`
iff `right_gap_class sig k M t` (= "t's class ends at a gap on the right").

`right_gap_class` is a monadic first-order property (quantifying over carrier
elements), so by `US_expressively_complete_over_prior` (PriorExpressiveness.lean,
sorry-free), there exists a temporal formula R equivalent to it on Prior structures.

**Critical subtlety**: `US_expressively_complete_over_prior` takes a
`MonadicFormula sig 1` and produces a temporal `Formula`. We need to encode
`right_gap_class` as a `MonadicFormula sig 1`.

`right_gap_class sig k M t` is defined as:
```
(∃ y > t, ¬ contemp_equiv sig k M t y) ∧
(¬ ∃ c, contemp_equiv sig k M t c ∧ ¬ contemp_equiv sig k M t (Order.succ c))
```

Since `contemp_equiv` is defined via `very_good` which is defined via `good`
which is defined via `k_equiv` to `ZIntervalStructure`, this is a complex
semantic predicate. However, for a FIXED k and FIXED finite signature, the
set of possible k-types is finite. So `contemp_equiv` is equivalent to a
finite conjunction/disjunction of monadic FO sentences about predicate
patterns and order relations within bounded intervals. Specifically:

- For fixed k and sig, `good sig k M'` is expressible as a finite disjunction
  of k-type patterns (there are finitely many `NormalForm sig k 0` values).
- `very_good` is `∀ subintervals, good`, which is monadic FO.
- `contemp_equiv` is `very_good` on `subinterval(min a b, max a b)`, hence FO.

So `right_gap_class` IS a monadic FO formula with one free variable.

**New code needed**: ~80-100 lines to construct the monadic FO formula
encoding `right_gap_class` and prove its correctness.

**Alternative (simpler)**: Instead of constructing the explicit FO formula,
use an enriched signature approach: add `right_gap_class` as a NEW predicate
to the signature, then show Prior-UZ/SZ extends to the enriched signature.

Wait -- this is the approach that failed for class membership (Section 2.3).
The issue is that `right_gap_class` transitions at a gap, so Prior-UZ for the
enriched structure may fail.

However, there is a key difference: `right_gap_class` is defined via
`contemp_equiv`, which depends on the TEMPORAL TRUTH of all formulas in the
ORIGINAL structure. Unlike a raw class-membership predicate, `right_gap_class`
IS expressible as a temporal formula (via US expressive completeness). So we
do not need to add it as a new predicate -- we can express it directly.

**Recommended implementation**: Construct the monadic FO formula explicitly.
The `NormalForm sig k 0` type is finite (`Fintype`), and the construction
iterates over all possible k-types to build `epsilon(x,y)` (the FO formula
defining `contemp_equiv`) and then `rho(x)` (the FO formula defining
`right_gap_class`).

#### Step 3: R-Interval Properties (Lemma 7)

R is succ-closed within each R-interval: if `temporal_truth t R` (t's class ends
at a gap on the right), and t is not at a successor boundary of its class, then
`temporal_truth (succ t) R` (succ(t) is in the same class, which ends at the
same gap). This follows from `no_boundary_at_successor` (sorry-free).

**New code needed**: ~40 lines.

#### Step 4: No First/Last Class in R-Intervals (Lemma 8)

The last class in an R-interval cannot exist (it would end at the R-interval
boundary, a point, not a gap -- contradicting R). The first class cannot exist
by Prior-UZ/SZ applied to its detecting formula.

**New code needed**: ~60 lines.

#### Step 5: Class Homogeneity (Lemma 9)

All classes within a maximal R-interval are elementarily equivalent. The proof
uses US expressive completeness to encode "formula B holds somewhere in my class"
as a temporal formula, then Prior-UZ/SZ to show it cannot change across the gap.

**New code needed**: ~80 lines.

#### Step 6: Bad Intervals + Formula Propagation (Lemmas 10-11)

Define "bad point" (R or L holds). In bad intervals, both R and L hold.
If a formula holds at the start of a class in a bad interval, it holds throughout.

**New code needed**: ~80 lines.

#### Step 7: Model Surgery (Lemma 12)

Construct surgery model N by replacing a bad interval Q0 with a single class I.
N has domain Q- ∪ I ∪ Q+, inheriting order and predicates from M.

Prove temporal truth preservation: for all formulas A and all t in N,
`temporal_truth M atomMap t A ↔ temporal_truth N atomMap t A`.

The proof is by structural induction on A. The cases for atom, bot, imp, box
are immediate. The cases for Until and Since each have 7 forward and 6 backward
subcases (13 total), depending on where t and the witness s lie relative to
Q-, I, Q+.

**New code needed**: ~200 lines (the largest component).

#### Step 8: Contradiction (Lemma 13 + Theorem 14)

R holds at points of I in N (by Lemma 12). But in N, I's class is bounded
above by the first point q of Q+ (a successor boundary, not a gap). So R
should NOT hold at I in N. Contradiction.

**New code needed**: ~40 lines.

### 3.4 Total Estimate

| Component | Lines |
|-----------|-------|
| Right_gap_class definition + FO encoding | 80-100 |
| R formula construction (Lemma 6) | 30-40 |
| R-interval properties (Lemma 7) | 40-50 |
| No first/last class (Lemma 8) | 50-60 |
| Class homogeneity (Lemma 9) | 70-80 |
| Bad intervals + propagation (Lemmas 10-11) | 70-80 |
| Model surgery construction (Lemma 12) | 180-220 |
| Contradiction (Lemma 13 + Theorem 14) | 30-40 |
| **Total** | **550-670** |

### 3.5 Existing Infrastructure Reused

All of the following are sorry-free and directly applicable:

| Lemma | File | Purpose |
|-------|------|---------|
| `US_expressively_complete_over_prior` | PriorExpressiveness.lean | Converts monadic FO formula to temporal formula |
| `class_gap_exists` | GoodStructuresModelSurgery.lean | Gap from succ-closed bounded class |
| `prior_UZ_first_transition` | GoodStructuresModelSurgery.lean | First-transition lemma for Prior-UZ |
| `prior_SZ_last_transition` | GoodStructuresModelSurgery.lean | Last-transition lemma for Prior-SZ |
| `contemp_equiv_convex` | GoodStructuresModelSurgery.lean | Class convexity |
| `contemp_equiv_succ_iterate` | GoodStructuresModelSurgery.lean | Succ-iterate closure |
| `contemp_equiv_is_equiv` | GoodStructures.lean | Equivalence relation |
| `no_boundary_at_successor` | GoodStructures.lean | c ~M succ(c) always |
| `one_class_archimedean` | ReynoldsNoGaps.lean | All contemp_equiv in archimedean order |
| `gap_of_not_succ_archimedean` | ReynoldsNoGaps.lean | Non-archimedean => gap |
| `temporal_truth_neg_iff_not` | GoodStructuresModelSurgery.lean | Negation helper |
| `table_correctness` | Table.lean | FO translation correctness |
| `doets_lemma_1_4` | OrderedSum.lean | Sum preserves k-equiv |
| `k_equiv_of_iso` | GoodStructures.lean | Iso gives k-equiv |
| `finite_structures_good` | GoodStructures.lean | Finite => good |
| `good_of_split_at_succ` | GoodStructures.lean | Split decomposition |

---

## 4. Risk Assessment

### 4.1 Primary Risk: FO Formula Construction Complexity

**Risk**: Encoding `right_gap_class` as a `MonadicFormula sig 1` requires
encoding `contemp_equiv` (defined via `very_good` / `good` / `k_equiv`) as a
finite FO formula. This involves iterating over all `NormalForm sig k 0` values.

**Mitigation**: The `NormalForm sig k 0` type has a `Fintype` instance. The
construction is schematic: for each k-type tau, construct the FO formula
"there exists a Z-interval with k-type tau that is k-equiv to subinterval(x,y)".
The k-type can be checked by evaluating each normal form sentence.

**Residual risk**: MEDIUM. The construction is conceptually clear but may require
~100 lines of careful Lean code with Fintype enumeration.

### 4.2 Secondary Risk: Model Surgery Domain Construction

**Risk**: The surgery model's carrier is Q- ∪ I ∪ Q+ (subsets of M.carrier).
Proving `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder` for the surgery
carrier requires careful case analysis at the boundaries.

**Mitigation**: The boundary between Q- and I is a gap (no points removed between
them -- Q0 is replaced by I which is a subinterval of Q0). The boundary between I
and Q+ is the first point of Q+. Since we keep all of Q- and Q+, and I is a
contiguous subinterval, the order properties inherit naturally.

**Residual risk**: MEDIUM. Standard Lean subtype/order instance plumbing.

### 4.3 Tertiary Risk: Until/Since 13 Subcases

**Risk**: Each subcase is 15-30 lines, and there are 13 in total. Errors in
any single subcase block the whole proof.

**Mitigation**: Each subcase is independent and follows the same pattern:
identify where t and the witness s are (Q-, I, or Q+), then use the
inductive hypothesis + Lemmas 9-11 to transfer truth between M and N.

**Residual risk**: LOW. Tedious but mechanical.

---

## 5. Alternative Approaches Considered and Rejected

### 5.1 EF Game Approach
**Idea**: Show Duplicator wins the k-round EF game on intervals spanning the gap.
**Rejection**: The EF game infrastructure exists in `EFGames/Defs.lean` but is
not connected to `contemp_equiv` (which uses `very_good` / `good` / `k_equiv`
via normal forms, not EF games). Connecting them would require additional sorry-free
infrastructure.

### 5.2 Doets Lemma 1.5 Approach
**Idea**: Decompose the interval as an ordered sum, show each component is
k-equiv to a Z-interval via `doets_lemma_1_5`.
**Rejection**: `doets_lemma_1_5` itself is sorry'd. Using it would shift the
sorry rather than eliminate it.

### 5.3 Direct k-Type Stabilization
**Idea**: Show k-types stabilize along successor chains (pigeonhole), then use
stabilization to show gap-crossing k-type agreement.
**Rejection**: k-type stabilization within the class is true but insufficient.
The k-types ACROSS the gap can differ because the order structure changes
(gap vs no-gap). This is exactly the Case B failure documented in report 15.

### 5.4 Constant Predicate Special Case
**Idea**: Handle the constant-predicate case directly (all contemp_equiv),
then use some other argument for the varying-predicate case.
**Rejection**: The varying-predicate case STILL requires model surgery
(report 15, Section A.7 conclusion). The constant-predicate case is a useful
subresult but does not eliminate the need for the full argument.

---

## 6. Recommendation

**ONE recommended approach**: Full Reynolds model surgery (Section 3).

This is the ONLY approach that has been validated as mathematically sound by
the literature (Reynolds 1994) and by our exhaustive analysis of alternatives.
All 5 alternative approaches fail for documented reasons.

The implementation requires ~550-670 lines of new Lean code in
GoodStructuresModelSurgery.lean, structured as 8 modular components (Steps 1-8).
Each component is independently testable via `lake build`.

### Exact Lemmas to Define

```lean
-- Step 2: Gap formula R
def right_gap_class (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (t : M.carrier) : Prop

def right_gap_class_formula (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    MonadicFormula sig 1  -- The FO formula encoding right_gap_class

noncomputable def gap_detecting_formula (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p, ∃ a, atomMap (.atom a) = p) :
    { R : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t R ↔ right_gap_class sig k M t }

-- Step 3: R succ-closed
theorem R_succ_closed ...

-- Step 4: No first/last class
theorem no_last_class_in_R_interval ...
theorem no_first_class_in_R_interval ...

-- Step 5: Class homogeneity
theorem classes_elem_equiv_in_R_interval ...

-- Steps 6: Bad intervals
def bad_point ...
theorem bad_interval_both_R_and_L ...
theorem formula_propagation_in_bad_interval ...

-- Step 7: Model surgery
noncomputable def surgery_model ...
theorem surgery_truth_preservation ...

-- Step 8: Final contradiction
-- (fills in the body of reynolds_model_surgery_core)
```

### Exact Proof Structure

```
reynolds_model_surgery_core:
  by_contra h_not_all
  obtain ⟨b, h_diff⟩ := h_not_all
  -- Step 1: Gap exists
  have ⟨gamma⟩ := class_gap_exists ...
  -- Step 2: Construct R (gap-detecting formula)
  obtain ⟨R, h_R_correct⟩ := gap_detecting_formula ...
  -- Step 3-6: Structural analysis of R-intervals
  -- Step 7: Construct surgery model N
  let N := surgery_model ...
  -- Step 7: Truth preservation
  have h_truth := surgery_truth_preservation ...
  -- Step 8: Contradiction
  -- R holds at I in N (by truth preservation from M)
  -- But I's class in N ends at a point (not a gap)
  -- So R should not hold. Contradiction.
```

### Estimated Lines of Code

550-670 lines total, all in GoodStructuresModelSurgery.lean.

---

## 7. Dependency on Other Sorry Sites

Closing `reynolds_model_surgery_core` automatically unblocks:
1. `gap_contradicts_prior` (already delegates to `reynolds_model_surgery_core`)
2. `gap_contradicts_prior_below` (already delegates to `reynolds_model_surgery_core`)
3. `no_gaps_discrete_model_surgery` (already uses the above two)
4. `no_gaps_discrete` in GoodStructures.lean:852 (needs trivial wiring to call
   `no_gaps_discrete_model_surgery`)
5. `one_class` (uses `no_gaps_discrete`)
6. `chronicle_is_good_direct` in ShiftAndGlue.lean (uses `one_class`)
7. `countermodel_discrete_reynolds` in Transfer.lean (uses chronicle_is_good_direct)
8. `completeness_discrete` (once rewired to use countermodel_discrete_reynolds)

Two engineering sorry sites in Transfer.lean also need separate work:
- `h_surj` construction (Transfer.lean:1117) -- Phase 1, already marked [COMPLETED]
- TaskFrame packaging (Transfer.lean:~1162) -- Phase 4, separate engineering task
