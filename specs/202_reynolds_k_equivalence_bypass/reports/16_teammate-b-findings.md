# Teammate B Findings: Existing Infrastructure Reuse for Reynolds Model Surgery

- **Task**: 202 - Reynolds k-equivalence bypass
- **Report**: 16 (teammate B)
- **Focus**: Existing infrastructure that can be directly reused in the model surgery
- **Date**: 2026-05-30

---

## Executive Summary

The codebase has substantial reusable infrastructure for the Reynolds model surgery. The
two sorry sites (`gap_prior_UZ_contradiction` and `gap_prior_SZ_contradiction` in
`GoodStructuresModelSurgery.lean`) require implementing Reynolds Lemmas 6-13. The
existing infrastructure covers: (1) gap structure and succ/pred-closure properties,
(2) contemp_equiv convexity and class closure, (3) US expressive completeness
(`US_expressively_complete_over_prior`), (4) the ordered sum + doets_lemma_1_4 chain,
(5) subinterval construction and k_equiv_of_iso. The critical gap is the actual model
surgery domain construction and temporal truth preservation proof (13 subcases for U/S),
which have no existing reusable code but are well-scaffolded.

---

## Key Findings

### Finding 1: The Two Sorry Sites Are Precisely Located

The two sorry sites in `GoodStructuresModelSurgery.lean` are:

- `gap_prior_UZ_contradiction` (line 688-702): upward case -- assumes class(a) succ-closed
  with some y > a not in class(a), must derive False via model surgery
- `gap_prior_SZ_contradiction` (line 714-728): downward case -- symmetric with y < a

Both have the same signature shape:
```lean
private theorem gap_prior_UZ_contradiction (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c))
    (y : M.carrier) (hay : a < y)
    (h_not_equiv : ¬ contemp_equiv sig k M a y) :
    False := by
  sorry
```

The downstream chain from these two theorems to the final `no_gaps_discrete_model_surgery`
is already sorry-free: `reynolds_model_surgery_core` wraps both, then
`gap_contradicts_prior` / `gap_contradicts_prior_below` call it, and
`no_gaps_discrete_model_surgery` at line 820 calls those.

### Finding 2: Right Gap Class Infrastructure Is Ready to Use

In `GoodStructuresModelSurgery.lean` (lines 589-659), three sorry-free lemmas exist that
are the foundation for Reynolds Lemma 6 (formula construction for gap detection):

- `right_gap_class_prop (sig k M t)`: Prop -- "t's contemp_equiv class is bounded above
  and succ-closed" (lines 592-597)
  ```lean
  private def right_gap_class_prop (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
      (t : M.carrier) : Prop :=
    (∃ b : M.carrier, t < b ∧ ¬ contemp_equiv sig k M t b) ∧
    (∀ c : M.carrier, contemp_equiv sig k M t c →
      contemp_equiv sig k M t (Order.succ c))
  ```
- `right_gap_class_invariant`: if t ~M s and right_gap_class(t), then right_gap_class(s)
- `right_gap_class_succ`: right_gap_class preserved under Order.succ
- `right_gap_class_pred`: right_gap_class preserved under Order.pred

These three preservation lemmas are crucial for proving that the predicate "has a right
gap class" is invariant within contemp_equiv classes -- needed for applying
`US_expressively_complete_over_prior`.

### Finding 3: US Expressive Completeness Is Ready to Use

`US_expressively_complete_over_prior` in `PriorExpressiveness.lean` (lines 371-393)
takes a `MonadicFormula sig 1` and produces a `Formula` that is truth-equivalent
on any Prior structure:

```lean
noncomputable def US_expressively_complete_over_prior
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_UZ : semantic_prior_UZ M atomMap)
        (_h_prior_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        temporal_truth M atomMap t A }
```

This is directly applicable for Reynolds Lemma 6: once `right_gap_class_prop` is
expressed as a `MonadicFormula sig 1` (the formula rho(x)), applying this function
gives the temporal formula R. The h_surj hypothesis is already in the sorry signature.

The key challenge (Lemma 6) is expressing `right_gap_class_prop` as a
`MonadicFormula sig 1`. This requires:
- Expressing `contemp_equiv` as a formula (it involves `very_good` which involves
  existential quantification over Z-intervals -- complex)
- The standard approach is to use an enriched signature that adds `right_gap_class`
  as an abstract predicate, bypassing explicit formula construction

### Finding 4: Contemp Equiv Infrastructure Is Rich

In `GoodStructuresModelSurgery.lean` (lines 247-515), several sorry-free lemmas about
`contemp_equiv` are available:

- `contemp_equiv_convex` (line 247): if a ~M c and a <= b <= c, then a ~M b
  ```lean
  theorem contemp_equiv_convex (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig)
      (a b c : M.carrier) (hab : a ≤ b) (hbc : b ≤ c)
      (hac : contemp_equiv sig k M a c) :
      contemp_equiv sig k M a b
  ```
- `contemp_equiv_succ_closed_of_no_boundary` (line 273)
- `contemp_equiv_pred_closed` (line 288): if a ~M c then a ~M pred(c)
- `contemp_equiv_succ_iterate` (line 312): class closed under succ^[n]
- `class_gap_exists` (line 328): if class(a) is succ-closed and -(a ~M b), a Gap exists
- `cut_succ_closed` (line 383): gap's cut is closed under successor (used internally)
- `complement_pred_closed` (line 405): complement pred-closed

The convexity lemma is especially valuable: it shows the model surgery domain (cutting
out a bad interval and replacing by a single class) preserves the class structure within
the cut boundaries.

### Finding 5: Prior-UZ/SZ Transition Lemmas Are Ready

In `GoodStructuresModelSurgery.lean`:

- `prior_UZ_first_transition` (line 116): If ψ holds at t and ¬ψ holds at some s > t,
  then there exists c >= t with temporal_truth c ψ and ¬temporal_truth (succ c) ψ.
  ```lean
  theorem prior_UZ_first_transition ... :
    ∃ c : M.carrier, t ≤ c ∧
      temporal_truth M atomMap c ψ ∧
      ¬ temporal_truth M atomMap (Order.succ c) ψ
  ```
- `prior_SZ_last_transition` (line 180): Symmetric for past direction.

These are used in Reynolds Lemmas 7-8 to establish that R-intervals have no
"first class" (no element where R first becomes true). They encapsulate the
first-occurrence property from Prior-UZ/SZ axioms.

### Finding 6: doets_lemma_1_4 + orderedSum Are Directly Applicable

`doets_lemma_1_4` in `OrderedSum.lean` (lines 34-38):
```lean
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type) [LinearOrder I]
    (m m' : I → OrderedMonadicStructure sig)
    (h_equiv : ∀ i, k_equiv sig k (m i) (m' i)) :
    k_equiv sig k (orderedSum sig I m) (orderedSum sig I m')
```

This is the key preservation lemma for ordered sums. In the model surgery proof, when
replacing a bad interval Q0 by a single class I in the surgery domain, the surgery model
is expressible as an ordered sum (Q- + I + Q+). If Q0 is k-equivalent to I (class
homogeneity, Lemma 9), then the surgery is k-equivalent to the original by doets_lemma_1_4.

`orderedSum` in `NEquivalence.lean` (lines 122-129):
```lean
noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms : I → OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Sigma fun i => (ms i).carrier
  interp := fun p x => (ms x.1).interp p x.2
  carrier_order := Sigma.Lex.linearOrder
```

The surgery domain M' = orderedSum over {Left, Middle, Right} where Left = Q-, Middle
= single class I, Right = Q+.

### Finding 7: k_equiv_of_iso Is Ready for Order Isomorphisms

In `GoodStructures.lean` (lines 84-148):
```lean
theorem k_equiv_of_iso (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) (f : M.carrier ≃o N.carrier)
    (h_pred : ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ N.interp p (f x)) :
    k_equiv sig k M N
```

This is used whenever the surgery model is order-isomorphic to the original (or to
a Z-interval). The ShiftAndGlue.lean file uses it extensively and provides patterns
for constructing such isomorphisms.

### Finding 8: doets_lemma_1_1 Is the Bridge for Formula Transfer

In `NormalForm.lean` (lines 433-438):
```lean
theorem doets_lemma_1_1 {sig : MonadicSignature} (k : Nat) :
    ∀ (n : Nat) (phi : MonadicFormula sig n) (_h_depth : phi.quantifier_depth ≤ k)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin n → M.carrier) (env_N : Fin n → N.carrier)
    (h_same_nf : ∀ nf : NormalForm sig k n,
      nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf),
    (eval M env_M phi ↔ eval N env_N phi)
```

This is used in the surgery proof (Lemma 9, class homogeneity) to transfer truth of
arbitrary monadic FO formulas between k-equivalent classes. The pattern used in
`ShiftAndGlue.lean` (lines 378-396) shows the standard usage:
```lean
have h_same_nf : ∀ nf : NormalForm sig (k'' + 2) 0,
    nf_eval_nf (ms i) (k'' + 2) 0 Fin.elim0 nf ↔
    nf_eval_nf ((witnesses i).toOrdered sig) (k'' + 2) 0 Fin.elim0 nf := by
  intro nf; have h := congr_fun (h_equiv i) nf
  simp [k_type_of] at h; exact_mod_cast h
```

### Finding 9: Gap Structure Is Fully Available

The `Gap` structure in `EFGames/Defs.lean` (lines 236-249):
```lean
structure Gap (T : Type) [LinearOrder T] where
  cut : Set T
  nonempty : cut.Nonempty
  proper : cut ≠ Set.univ
  downward_closed : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut
  no_sup : ¬∃ s, IsLUB cut s ∧ s ∈ cut
  complement_no_min : ¬∃ m, m ∉ cut ∧ ∀ y, y ∉ cut → m ≤ y
```

And `gap_of_not_succ_archimedean` in `ReynoldsNoGaps.lean` (line 158):
```lean
theorem gap_of_not_succ_archimedean {T : Type} [LinearOrder T]
    [SuccOrder T] [PredOrder T] [NoMaxOrder T] [NoMinOrder T]
    (h_not_arch : ¬ @IsSuccArchimedean T inferInstance inferInstance) :
    Nonempty (Gap T)
```

And `gap_cut_succ_closed` / `gap_complement_pred_closed` in `EFGames/Defs.lean` (lines 490-518).

These provide the structural properties of the gap that drive the model surgery:
- The cut is succ-closed (so formulas propagate across it)
- The complement is pred-closed (symmetric argument)

### Finding 10: ShiftAndGlue.lean Shows the K-Equiv via OrderIso Pattern

`ShiftAndGlue.lean` (lines 246-303) provides the pattern for proving k-equivalence via
ordered sum with half-open partition, including the `cofinal_decomposition_k_equiv`
lemma. The key pattern:

```lean
private theorem cofinal_decomposition_k_equiv (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (a : ℤ → M.carrier)
    (h_mono : StrictMono a)
    (h_cofinal : ∀ x : M.carrier, ∃ i : ℤ, a i ≤ x ∧ x < a (i + 1)) :
    k_equiv sig k M (orderedSum sig ℤ
      (fun i => M.hoSubinterval sig (a i) (a (i + 1))))
```

This shows how to prove k-equivalence of M with its orderedSum decomposition. The
surgery model (M' = Q- + I + Q+) has the same pattern: it is order-isomorphic to
the original M via the surgery map.

### Finding 11: The Half-Open Subinterval Construction

`OrderedMonadicStructure.hoSubinterval` in `ShiftAndGlue.lean` (lines 213-217):
```lean
def OrderedMonadicStructure.hoSubinterval (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x < b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance
```

And the standard `subinterval` (closed intervals) in `MonadicFO.lean` (lines 129-133):
```lean
def OrderedMonadicStructure.subinterval (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x ≤ b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance
```

Both are needed for the surgery domain: Q- = (-∞, gap_left) and Q+ = (gap_right, ∞)
can be expressed as half-open or open intervals.

### Finding 12: temporal_truth Semantics for U/S Are the Core Pattern

`temporal_truth` in `Table.lean` (lines 182-193):
```lean
def temporal_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) : Formula → Prop
  | .untl φ ψ => ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s φ ∧
      ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ
  | .snce φ ψ => ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s φ ∧
      ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ
```

For the model surgery temporal truth preservation proof (Reynolds Lemma 12), the 13
subcases for U(A,B) decompose based on whether the witness s is in Q-, I, or Q+, and
whether the guard range (t,s) crosses the surgery boundary. Each subcase needs to reason
about `temporal_truth` on the surgery domain vs. the original.

---

## Recommended Approach

### Step 1: Encode right_gap_class_prop as MonadicFormula sig 1

The critical step is expressing `right_gap_class_prop sig k M t` as a `MonadicFormula sig 1`
(with one free variable x_0 = t). Two options:

**Option A (enriched signature)**: Add `right_gap_class` as a new predicate in an
enriched signature `sig' = sig + {rgc}`. Define the structure with `rgc` true exactly
at right_gap_class points. Apply `US_expressively_complete_over_prior` on `sig'` with
`psi = atom rgc 0`. This avoids constructing the explicit MonadicFormula -- just use
the abstract predicate. The enriched structure and atomMap extension need to be defined
carefully.

**Option B (explicit formula)**: Construct the explicit `MonadicFormula sig 1` for
`right_gap_class_prop` by expressing `contemp_equiv` as a formula. `contemp_equiv a b`
= `very_good sig k (M.subinterval sig (min a b) (max a b))` which is equivalent to
"there exists a Z-interval Z of the right k-type" -- expressible as a Σ₂ sentence
quantifying over Z-interval k-types (finitely many of them, enumerated by `KType sig k`).
This is complex but ultimately a finite disjunction over `NormalForm sig k 0`.

Option A is more tractable and follows the Reynolds proof sketch more directly.

### Step 2: Prove R-interval Properties (Lemmas 7-8)

Using `right_gap_class_succ` and `right_gap_class_invariant` (already proven), show:
- R holds throughout a right_gap_class interval (by invariance)
- The interval is open on both sides (succ/pred of boundary points are not in R)
- Apply `prior_UZ_first_transition` to show no first R-point

These are 30-50 lines each, using the existing lemmas.

### Step 3: Prove Class Homogeneity (Lemma 9)

Using `doets_lemma_1_1`, show that in a maximal R-interval, all contemp_equiv classes
satisfy the same monadic FO formulas. The argument: if classes C1 and C2 differ on
formula A, construct formula B = "A occurs in my class". B transitions at a successor
pair (by Prior-UZ). But R-intervals have no first class, contradicting Prior-UZ
first-transition.

Key infrastructure: `doets_lemma_1_1`, `prior_UZ_first_transition`, `temporal_truth_neg_iff_not`.

### Step 4: Construct Surgery Domain

Define:
- `Q0` = maximal bad interval (where both R and its symmetric left version hold)
- `I` = a single contemp_equiv class inside Q0
- Surgery domain `M'` with carrier = M.carrier, but with surgery applied to Q0

The surgery domain can be constructed using `orderedSum` over `{Left, Middle, Right}`:
- Left = M.hoSubinterval sig (-∞, left boundary of Q0)
- Middle = I (single class in Q0)
- Right = M.hoSubinterval sig (right boundary of Q0, +∞)

Use `k_equiv_of_iso` to show M' ~k M (since Q0 ~k I by class homogeneity, Lemma 9, and
doets_lemma_1_4 preserves the sum).

### Step 5: Prove Temporal Truth Preservation (Lemma 12, 13 subcases for U/S)

For each subcase of `temporal_truth M atomMap t (φ.untl ψ)`, case-split on:
1. t ∈ Q-, s ∈ Q-: both outside surgery, truth preserved trivially
2. t ∈ Q-, s ∈ Q0 (surgery zone): must argue the guard range stays consistent
3. t ∈ Q-, s ∈ Q+: guard crosses surgery zone, use class homogeneity
4. t ∈ Q0, s ∈ Q0: both in surgery zone, class homogeneity
5. t ∈ Q0, s ∈ Q+: guard exits surgery zone
6. t ∈ Q+, s ∈ Q+: both outside, trivial
7. t ∈ Q-, no witness in M (¬U): need to show ¬U in M' too

Each of the 13 forward/backward subcases uses `prior_UZ_first_transition` or
`temporal_truth_neg_iff_not` as appropriate.

Key infrastructure to use: `temporal_truth_neg_neg_elim`, `contemp_equiv_convex`,
`class_gap_exists`.

### Step 6: Derive Contradiction (Lemma 13 + Theorem 14)

In the surgery model M':
- The class containing I has a right boundary (by construction of surgery)
- That boundary is at a successor pair (not a gap), since I is a single class
- Therefore right_gap_class_prop is FALSE at any point of I in M'
- But temporal truth of R is the same in M' as in M (by Lemma 12 preservation)
- And right_gap_class_prop is TRUE at points of I in M (I is in a right gap class)
- Contradiction: R should be true at I in M', but it's false

---

## Evidence / Type Signatures

### Core Chain (all sorry-free)
- `reynolds_model_surgery_core` delegates to `gap_prior_UZ_contradiction` (sorry)
- `gap_contradicts_prior` -> `reynolds_model_surgery_core`
- `no_gaps_discrete_model_surgery` -> `gap_contradicts_prior` / `gap_contradicts_prior_below`
- `no_gaps_discrete` -> `no_gaps_discrete_model_surgery` (separate, also sorry)
- `one_class` -> `no_gaps_discrete`
- `chronicle_is_good_direct` -> `one_class`

### Available Infrastructure Summary

| Infrastructure | Location | Type | Reuse Point |
|---|---|---|---|
| `right_gap_class_prop` | GoodStructuresModelSurgery:592 | `Prop` | Lemma 6 predicate |
| `right_gap_class_invariant` | GoodStructuresModelSurgery:603 | theorem | Lemma 6 invariance |
| `right_gap_class_succ` | GoodStructuresModelSurgery:639 | theorem | Lemma 6/7 propagation |
| `right_gap_class_pred` | GoodStructuresModelSurgery:650 | theorem | Lemma 6/7 |
| `US_expressively_complete_over_prior` | PriorExpressiveness:371 | noncomputable def | Lemma 6 formula R |
| `contemp_equiv_convex` | GoodStructuresModelSurgery:247 | theorem | Lemma 9 homogeneity |
| `contemp_equiv_pred_closed` | GoodStructuresModelSurgery:288 | theorem | Gap structure |
| `prior_UZ_first_transition` | GoodStructuresModelSurgery:116 | theorem | Lemmas 7-8 |
| `prior_SZ_last_transition` | GoodStructuresModelSurgery:180 | theorem | Lemmas 7-8 |
| `class_gap_exists` | GoodStructuresModelSurgery:328 | theorem | Entry point |
| `cut_succ_closed` | GoodStructuresModelSurgery:383 | theorem | Gap cut properties |
| `complement_pred_closed` | GoodStructuresModelSurgery:405 | theorem | Gap complement |
| `doets_lemma_1_1` | NormalForm:433 | theorem | Lemma 9 formula transfer |
| `doets_lemma_1_4` | OrderedSum:34 | theorem | Sum preservation |
| `orderedSum` | NEquivalence:122 | noncomputable def | Surgery domain |
| `k_equiv_of_iso` | GoodStructures:84 | theorem | Iso-based k_equiv |
| `temporal_truth_neg_iff_not` | GoodStructuresModelSurgery:90 | theorem | Subcase negations |
| `temporal_truth_neg_neg_elim` | GoodStructuresModelSurgery:97 | theorem | Double neg elim |
| `Gap` structure | EFGames/Defs:236 | structure | Gap formalization |
| `gap_of_not_succ_archimedean` | ReynoldsNoGaps:158 | theorem | Gap existence |
| `gap_cut_succ_closed` | EFGames/Defs:490 | theorem | Cut propagation |
| `hoSubinterval` | ShiftAndGlue:213 | def | Surgery domain pieces |
| `subinterval` | MonadicFO:129 | def | Standard interval |
| `semantic_prior_UZ/SZ` | PriorExpressiveness:59-75 | abbrev | Hypothesis types |
| `temporal_truth` | Table:182 | def | Core truth definition |

---

## Gaps Between Existing Infrastructure and What Is Needed

### Gap 1: MonadicFormula Construction for right_gap_class_prop (Lemma 6)

`right_gap_class_prop` is defined as a Lean `Prop`, not a `MonadicFormula sig 1`.
To apply `US_expressively_complete_over_prior`, we need a `MonadicFormula sig 1`
whose evaluation at (M, t) is equivalent to `right_gap_class_prop sig k M t`.

- For Option A (enriched signature): define `sig'` with extra predicate, construct
  `priorModelAsMonadicStructure` variant with rgc predicate, extend `atomMap`.
  This creates a new MonadicSignature and requires showing the extension is compatible.
  
- The core difficulty: `right_gap_class_prop` quantifies over `contemp_equiv` which
  requires existential quantification over Z-intervals. This is a second-order concept.
  However, since `KType sig k` is finite, the k-type characterization makes it expressible
  in monadic FO at depth k+1: "∃ Z-interval with the same k-type as M|[t,b] for all b
  in my class" -- but this is still complex.

Estimated implementation: 50-100 lines to define the enriched structure and prove the
equivalence with right_gap_class_prop.

### Gap 2: Model Surgery Domain and Map Construction (Lemma 12)

There is no existing construction that takes a Gap, identifies a bad interval Q0,
selects a class I, and builds the surgery domain M'. This is the main new construction:

```lean
-- Surgery domain (sketch)
def surgeryDomain (M : ...) (Q0 : Set M.carrier) (I : Set M.carrier) :
    OrderedMonadicStructure sig where
  carrier := {x : M.carrier // x ∉ Q0 ∨ x ∈ I}
  ...
```

The `orderedSum` infrastructure in `NEquivalence.lean` provides the ordered sum
pattern, and `ShiftAndGlue.lean` shows how to build order isomorphisms between
such sums. But the specific surgery domain with three pieces (Q-, I, Q+) is new.

Estimated implementation: 100-150 lines for the surgery domain + order isomorphism proof.

### Gap 3: Temporal Truth Preservation Through Surgery (Lemma 12 continued)

The 13 subcases for U(A,B) forward/backward across the surgery boundary have no
existing analog in the codebase. The `temporal_truth` definition (Table.lean) provides
the structure, and `temporal_truth_neg_iff_not` + `prior_UZ_first_transition` provide
the key tools. But the case analysis itself is entirely new code.

Estimated implementation: 200-300 lines for U/S subcases (13 each direction).

### Gap 4: Wiring no_gaps_discrete to no_gaps_discrete_model_surgery

`no_gaps_discrete` in `GoodStructures.lean` (line 820) is a sorry with the same
proof sketch as `no_gaps_discrete_model_surgery`. Once `no_gaps_discrete_model_surgery`
is proven, `no_gaps_discrete` can be wired to it directly:

```lean
-- In GoodStructures.lean, no_gaps_discrete should delegate:
theorem no_gaps_discrete ... := no_gaps_discrete_model_surgery ...
```

This requires that the signatures match (they do -- same parameters).

---

## Confidence Level

**High confidence** (directly reusable):
- `US_expressively_complete_over_prior`: exactly the right type, ready to use
- `right_gap_class_invariant/succ/pred`: directly applicable for Lemma 6/7
- `prior_UZ_first_transition / prior_SZ_last_transition`: directly applicable for Lemma 8
- `doets_lemma_1_1`: directly applicable for Lemma 9 formula transfer
- `doets_lemma_1_4` + `orderedSum`: directly applicable for sum k-equivalence
- `contemp_equiv_convex`: directly applicable for class structure arguments
- `k_equiv_of_iso`: directly applicable for order isomorphism arguments
- `temporal_truth_neg_iff_not/neg_elim`: directly applicable for subcase negations

**Medium confidence** (requires some adaptation):
- Surgery domain construction via `orderedSum` with 3 pieces: the pattern from
  `ShiftAndGlue.lean` is directly analogous, needs adaptation for the 3-piece case
- `MonadicFormula sig 1` for `right_gap_class_prop`: Option A (enriched signature)
  is the most tractable but requires new infrastructure

**Low confidence** (requires entirely new code):
- The 13 subcases for temporal truth preservation through surgery (Lemma 12)
- The final contradiction derivation (Lemma 13 + Theorem 14)

**Overall estimate**: The sorry implementation requires 400-600 lines as stated in the
plan. Approximately 40% of the core lemmas can be discharged using existing infrastructure
directly. The remaining 60% (primarily the U/S subcase analysis and surgery domain
construction) requires new code but follows well-established patterns in the codebase.
