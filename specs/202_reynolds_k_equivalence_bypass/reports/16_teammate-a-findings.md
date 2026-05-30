# Research Report 16 -- Teammate A Findings: Reynolds Model Surgery Decomposition

**Date**: 2026-05-30
**Task**: 202 (Reynolds k-equivalence bypass)
**Artifact number**: 16, Teammate A
**Focus**: Primary decomposition -- 3-4 sub-tasks for closing `gap_prior_UZ_contradiction`
and `gap_prior_SZ_contradiction`

---

## Key Findings

### 1. Exact Sorry Sites

There are exactly **two sorry sites** in
`Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`:

- **Line 702**: `gap_prior_UZ_contradiction` (upward case: a < y, class of a bounded above)
- **Line 728**: `gap_prior_SZ_contradiction` (downward case: y < a, class of a bounded below)

Both are `private` theorems that feed into the sorry-free `reynolds_model_surgery_core`
(line 745), which in turn closes `gap_contradicts_prior` and `gap_contradicts_prior_below`
(both sorry-free), and `no_gaps_discrete_model_surgery` (sorry-free), and ultimately
`no_gaps_discrete` in GoodStructures.lean (the primary sorry on the critical path).

### 2. Common Type Signature Pattern

Both sorry sites share the same argument structure:

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
    False
```

And symmetrically for the downward case (with `hya : y < a`).

### 3. Existing Sorry-Free Infrastructure (Already Implemented)

The file already provides substantial ready-to-use scaffolding:

| Lemma | Location | Purpose |
|-------|----------|---------|
| `right_gap_class_prop` | line 592 | Defines "t's class ends at a gap on the right" |
| `right_gap_class_invariant` | line 603 | Prop invariant under contemp_equiv |
| `right_gap_class_succ` | line 639 | Prop preserved under succ (via `no_boundary_at_successor`) |
| `right_gap_class_pred` | line 650 | Prop preserved under pred |
| `prior_UZ_first_transition` | line 116 | First-transition lemma using Prior-UZ |
| `prior_SZ_last_transition` | line 180 | Last-transition lemma using Prior-SZ |
| `contemp_equiv_convex` | line 247 | Classes are convex intervals |
| `contemp_equiv_succ_closed_of_no_boundary` | line 273 | Succ-closure from no-boundary |
| `contemp_equiv_pred_closed` | line 288 | Classes are pred-closed |
| `contemp_equiv_succ_iterate` | line 311 | Class closed under succ^n |
| `class_gap_exists` | line 328 | Gap exists if class is proper and succ-closed |
| `cut_succ_closed` | line 383 | Gap's cut is succ-closed |
| `complement_upward_closed` | line 397 | Complement is upward-closed |
| `complement_pred_closed` | line 405 | Complement is pred-closed |

From other files (sorry-free):
| Lemma | File | Purpose |
|-------|------|---------|
| `US_expressively_complete_over_prior` | PriorExpressiveness.lean | Monadic FO -> temporal formula on Prior structures |
| `contemp_equiv_is_equiv` | GoodStructures.lean | ~M is equivalence relation |
| `no_boundary_at_successor` | GoodStructures.lean | c ~M succ(c) always |
| `one_class_archimedean` | ReynoldsNoGaps.lean | All points equiv when archimedean |
| `gap_of_not_succ_archimedean` | ReynoldsNoGaps.lean | NOT archimedean => Gap exists |

### 4. Critical Structural Observation

The `right_gap_class_prop` predicate is the key lever. It is already sorry-free and
its invariance under contemp_equiv and preservation under succ/pred are proved. This
prop encodes "my class is bounded above and succ-closed" -- exactly what is true of the
class of `a` under the hypotheses of `gap_prior_UZ_contradiction`. Because
`right_gap_class_prop` is a structural property (not class-membership), it CAN be
encoded as a `MonadicFormula sig 1` (single free variable), enabling
`US_expressively_complete_over_prior` to yield a temporal formula R.

The central insight in Reynolds' proof is that R transitions at successor pairs
(which exist by `prior_UZ_first_transition`), but the class of `a` ends at a gap
(not a successor pair), leading to contradiction via the surgery argument.

### 5. Architecture of the Full Proof

Reading Reynolds 1994, Section 7, Lemmas 6-13, combined with the existing
infrastructure, the proof naturally decomposes into four layers:

**Layer 1 (Gap formula)**: Construct monadic FO formula `rho(x)` for
`right_gap_class_prop`. Apply `US_expressively_complete_over_prior` to get temporal
formula `R`. This requires showing `right_gap_class_prop` is expressible as
`MonadicFormula sig 1`.

**Layer 2 (R-interval analysis)**: Show that R holds throughout the class of `a`
(since `right_gap_class_prop a` is true by hypothesis). Show that R is preserved
under succ/pred via `right_gap_class_succ` and `right_gap_class_pred`. Characterize
where R transitions.

**Layer 3 (Model surgery)**: Identify a "bad interval" (maximal interval where R
holds), excise it, keep one representative class `I`, construct surgery model
`N = Q- ∪ I ∪ Q+`. Prove temporal truth preservation M ↔ N for all Formula
constructors. This is the 26-subcase argument (13 for U, 13 for S) described in
the plan.

**Layer 4 (Contradiction)**: In the surgery model N, the class of `I` ends at
a point (not a gap), so `right_gap_class_prop I` is false. But temporal truth
preservation gives `temporal_truth N atomMap_N I R ↔ temporal_truth M atomMap I R`,
and R holds at `I` in M. Contradiction.

---

## Recommended Decomposition into Sub-Tasks

### Sub-Task A: Monadic FO Encoding of right_gap_class_prop (Reynolds Lemma 6)

**Mathematical content**: Show that `right_gap_class_prop sig k M t` can be expressed
as `eval M (fun _ => t) rho` for some `rho : MonadicFormula sig 1`. Then apply
`US_expressively_complete_over_prior` to obtain temporal formula `R`.

The predicate `right_gap_class_prop sig k M t` says:
1. There exists b > t not in t's class, AND
2. For all c, if t ~M c then t ~M succ(c)

Both conditions involve `contemp_equiv`, which expands to `very_good sig k (M.subinterval sig ...)`,
which expands to: "for all subintervals of [min a b, max a b], there exists a Z-interval
structure k-equivalent to it." This is a `MonadicFormula sig 1` because:
- The quantifiers "for all x, y in [t, ?]" and "there exists Z-structure" can be
  bounded and enumerated (the k-type of a Z-interval structure has finitely many
  options -- `NormalFormIdx sig k 0`)
- The "exists" over `ZIntervalStructure` reduces to "exists k-type tau such that
  all subintervals of [t, t+n] have k-type tau for some Z-interval of that type"
- Since `NormalForm sig k 0` is finite, the entire condition is equivalent to a
  disjunction over finitely many k-types -- which is a FO condition

**Key point**: `contemp_equiv sig k M x y` is equivalent to `very_good sig k (M.subinterval sig (min x y) (max x y))`, and `very_good` quantifies over subintervals
of a BOUNDED interval (the interval between x and y). This can be expressed in
monadic FO with quantifiers ranging over the interval [t, b] (for some specific b
outside the class). The finiteness of `NormalFormIdx sig k 0` (the set of k-types)
turns this into a finite disjunction, which IS a monadic FO formula.

**Lean theorem signature**:

```lean
-- Sub-Task A: right_gap_class as monadic FO formula
noncomputable def right_gap_class_formula (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    MonadicFormula sig 1 :=
  sorry -- Construct the FO encoding of right_gap_class_prop

noncomputable theorem right_gap_class_expressible (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (t : M.carrier) :
    eval M (fun _ => t) (right_gap_class_formula sig k atomMap h_surj) ↔
    right_gap_class_prop sig k M t :=
  sorry -- Prove the encoding is correct

-- Corollary: get temporal formula R
noncomputable def gap_formula_R (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    Formula :=
  (US_expressively_complete_over_prior atomMap h_surj
    (right_gap_class_formula sig k atomMap h_surj)).val
```

**Infrastructure used**: `MonadicFormula sig 1`, `eval`, `US_expressively_complete_over_prior`,
`right_gap_class_prop`, `NormalFormIdx sig k 0` (finiteness).

**Estimated lines**: 60-100 lines (the formula construction is the tricky part;
the expressibility proof follows from the construction).

**Difficulty note**: The formula construction for `right_gap_class_prop` is the
hardest part of the whole proof. It requires encoding `contemp_equiv` (via
`very_good` via `k_equiv` via `NormalForm`) as a monadic FO sentence. The key
insight is that `k_equiv sig k M N` can be expressed as a Herbrand-style sentence
over the finite set `NormalFormIdx sig k 0` -- each k-type is a function
`NormalForm sig k 0 → Bool`, so the condition "M and N have the same k-type" is
a finite conjunction over all `nf : NormalForm sig k 0` of
"M satisfies nf ↔ N satisfies nf", and each `nf_eval_nf M k 0 Fin.elim0 nf` is
itself a monadic FO sentence (by definition of `nf_eval_nf`).

**Alternative strategy**: Instead of constructing the monadic FO formula explicitly,
use an ABSTRACT approach: treat `right_gap_class_prop` as an opaque predicate,
postulate a `MonadicFormula sig 1` for it as a local axiom (using Classical.choice
on the Prop that such a formula exists), then prove the Prop is true. This avoids
the explicit formula construction but requires proving the Prop holds. The Prop
holds because `right_gap_class_prop t` is equivalent to a Boolean combination of
monadic FO sentences (the k-type conditions), and all monadic FO sentences are
expressible in monadic FO.

### Sub-Task B: R-Interval Analysis (Reynolds Lemmas 7-8)

**Mathematical content**: Given temporal formula R from Sub-Task A (where
`temporal_truth M atomMap t R ↔ right_gap_class_prop sig k M t`), establish:
1. R holds throughout the class of `a` (since `right_gap_class_prop a` holds)
2. R is preserved under succ (via `right_gap_class_succ` + expressibility)
3. R is preserved under pred (via `right_gap_class_pred` + expressibility)
4. R has a "transition point": since `¬ right_gap_class_prop y` (the class
   of `y` does not end at a gap -- `y` is not in the class of `a`), R is false
   at some points

**Lean theorem signatures**:

```lean
-- R holds at a (since right_gap_class_prop a is true by hypothesis)
theorem R_holds_at_a (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a y : M.carrier) (hay : a < y)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c → contemp_equiv sig k M a (Order.succ c))
    (h_not_equiv : ¬ contemp_equiv sig k M a y) :
    temporal_truth M atomMap a (gap_formula_R sig k atomMap h_surj) := ...

-- First-transition point for R using Prior-UZ
theorem R_first_transition (sig : MonadicSignature) (k : Nat) ... :
    ∃ c : M.carrier, a ≤ c ∧
      temporal_truth M atomMap c R ∧
      ¬ temporal_truth M atomMap (Order.succ c) R
```

**Infrastructure used**: `prior_UZ_first_transition`, `right_gap_class_succ`,
`right_gap_class_invariant`, `right_gap_class_expressible` (from Sub-Task A).

**Estimated lines**: 40-60 lines (mostly applications of existing lemmas).

**Dependencies**: Sub-Task A.

### Sub-Task C: Model Surgery Construction and Truth Preservation (Reynolds Lemmas 9-12)

**Mathematical content**: The core of the proof. Given the R-transition point `c`
from Sub-Task B, construct the surgery model N. Prove temporal truth preservation.

**Setup**:
- `c` is the last point where R holds (by `prior_UZ_first_transition`)
- `c` is in the class of `a` (since R holds at `c` iff `right_gap_class_prop c`)
- `succ(c)` is NOT in the class of `a` (since R is false at `succ(c)`)
- The class of `a` restricted to `[a, c]` = {x | a ≤ x ≤ c, x ~M a}
  (a finite initial segment of the class, bounded by the transition point)

**Surgery**: Let `I = {x | x ~M a, x ≤ c}` (one representative class, the
initial segment). The surgery domain is `Q- ∪ I ∪ Q+` where:
- `Q-` = {x : M | x < min(I)} (everything below I)
- `Q+` = {x : M | x > max(I), NOT in the gap region} (everything above the R-interval)
- The "bad interval" (the R-region between I and Q+) is excised

**Lean theorem signature for surgery construction**:

```lean
-- Surgery model: excise the bad interval [succ(c_class_max), last_R_point]
noncomputable def surgery_model (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (c : M.carrier)  -- transition point
    : OrderedMonadicStructure sig := ...

-- Core truth preservation lemma (26 subcases)
theorem surgery_truth_preservation (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (c : M.carrier)
    (atomMap_N : Formula → (surgery_model sig k M atomMap c).sig.preds)
    (i : (surgery_model sig k M atomMap c).carrier)  -- representative element
    (φ : Formula) :
    temporal_truth M atomMap i.val φ ↔
    temporal_truth (surgery_model sig k M atomMap c) atomMap_N i φ
```

**Infrastructure used**: `contemp_equiv_is_equiv`, `contemp_equiv_convex`,
`cut_succ_closed`, `complement_pred_closed`, `right_gap_class_invariant`,
`right_gap_class_succ`.

**Estimated lines**: 250-350 lines (surgery construction: ~50 lines, truth
preservation: ~200-300 lines for the 26 U/S subcases).

**This is the highest-effort sub-task.** The 26 subcases for temporal truth
preservation under model surgery are:
- Atom case: 1 case (trivial)
- Bot case: 1 case (trivial)
- Imp case: 1 case (structural)
- Box case: 1 case (structural)
- U(A,B) forward: 7 subcases (depending on where the U-witness `s` lies
  relative to the excised interval)
- U(A,B) backward: 6 subcases (symmetric)
- S(A,B) forward: 7 subcases (time-reverse of U)
- S(A,B) backward: 6 subcases (symmetric)

The U and S cases are related by `Order.dual` (time reversal). The upward case
(gap_prior_UZ) and downward case (gap_prior_SZ) can share Sub-Tasks A and B;
they differ mainly in which direction the surgery excises.

**Dependencies**: Sub-Tasks A, B.

### Sub-Task D: Contradiction Derivation (Reynolds Lemmas 13 + Theorem 14)

**Mathematical content**: Use the surgery model N from Sub-Task C to derive
contradiction. In N, the representative element `i` has its class ending at
a POINT (not a gap) -- because the bad interval was excised and `succ(c)` is
now the immediate successor of `c` in N with a different class. Therefore
`right_gap_class_prop N i` is FALSE. But temporal truth preservation gives:
`temporal_truth M atomMap i R ↔ temporal_truth N atomMap_N i R`. Since
`right_gap_class_prop M i` is TRUE (by construction, `i ~M a` and the class
ends at a gap), R holds at `i` in M. Contradiction.

**Lean theorem signature**:

```lean
-- In the surgery model, right_gap_class_prop is false at i
theorem surgery_no_rgcp (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    ...
    (i : carrier_of_surgery_model) :
    ¬ right_gap_class_prop sig k (surgery_model ...) i := ...

-- The contradiction: R holds in M but not in N
theorem gap_prior_UZ_contradiction (sig : ...) ... : False := by
  -- Construct R from Sub-Task A
  -- Get transition point c from Sub-Task B
  -- Build surgery model N from Sub-Task C
  -- Apply surgery_no_rgcp to get ¬R at i in N
  -- Apply surgery_truth_preservation to get R at i in N
  -- Contradiction
```

**Estimated lines**: 30-60 lines (mostly composition of Sub-Tasks A-C).

**Dependencies**: Sub-Tasks A, B, C.

---

## Dependency Graph

```
Sub-Task A: Monadic FO encoding of right_gap_class_prop
    |
    v
Sub-Task B: R-interval analysis (R holds at a, first-transition)
    |
    v
Sub-Task C: Model surgery construction + truth preservation (26 subcases)
    |
    v
Sub-Task D: Contradiction derivation
    |
    v
gap_prior_UZ_contradiction (CLOSED)
    |
gap_prior_SZ_contradiction (CLOSED -- symmetric to UZ)
    |
    v
reynolds_model_surgery_core (already sorry-free)
    |
    v
no_gaps_discrete_model_surgery (already sorry-free)
    |
    v
no_gaps_discrete (GoodStructures.lean -- CLOSED)
    |
    v
one_class -> completeness_discrete (critical path unblocked)
```

---

## Evidence and Examples

### Why gap_prior_SZ_contradiction is symmetric

`gap_prior_SZ_contradiction` uses `h_prior_SZ` instead of `h_prior_UZ`, and the
bound is `y < a` instead of `a < y`. The proof structure is identical with
time-reversed orientation. Concretely:
- Sub-Task A: Same gap formula R (class ending at gap on the RIGHT is preserved
  under pred as well as succ, by `right_gap_class_pred`)
- Sub-Task B: Use `prior_SZ_last_transition` instead of `prior_UZ_first_transition`
- Sub-Task C: Mirror the surgery (excise the bad interval below the class, not above)
- Sub-Task D: Identical contradiction

The cleanest implementation strategy: prove `gap_prior_UZ_contradiction` first,
then reduce `gap_prior_SZ_contradiction` to it via `Order.dual`. The dual of
a Prior-UZ/SZ structure is a Prior-SZ/UZ structure, and the dual of
`right_gap_class_prop` for the upward case is `left_gap_class_prop` for the
downward case. However, the dual reduction requires showing that `contemp_equiv`
is preserved under `Order.dual`, which is true (contemp_equiv is symmetric in
the order orientation since it uses `min/max`).

Alternatively, prove both cases independently by mirroring the argument, which
adds ~50% lines but is safer from a Lean-tactics perspective.

### Key Infrastructure Already in Place

The most important already-proved lemma for Sub-Task A is `right_gap_class_invariant`
(line 603), which shows the prop is constant within a contemp_equiv class. This is
crucial for the FO encoding because it means `rho(x)` can be expressed purely in
terms of the class-structure of x, without reference to a fixed base point `a`.

The proof that `right_gap_class_prop` is expressible as monadic FO rests on the
fact that `contemp_equiv sig k M x y` is equivalent to a BOUNDED quantification
(over elements of `M.subinterval sig (min x y) (max x y)`), and `very_good sig k` is
a finite check (since `NormalFormIdx sig k 0` is finite). The finiteness of the
k-type set is the essential ingredient provided by the Doets/Reynolds normal form
theory already formalized in `MonadicFO.lean`.

---

## Confidence Level

**High confidence** on the overall decomposition into 4 sub-tasks. Reynolds' proof is
mathematically sound and the infrastructure already in place (especially
`right_gap_class_prop` and its invariance/preservation lemmas) was deliberately
designed to support this proof structure.

**Medium confidence** on line-count estimates:
- Sub-Task A (FO encoding): 60-100 lines. The formula construction is the hardest part
  and may require more lines depending on how explicit the encoding needs to be.
- Sub-Task B (R-interval): 40-60 lines. Mostly mechanical applications of existing lemmas.
- Sub-Task C (Surgery + truth preservation): 250-350 lines. The 26 subcases are the
  dominant cost. Each subcase is independent (15-30 lines each).
- Sub-Task D (Contradiction): 30-60 lines. Composition only.
- **Total**: 380-570 lines for `gap_prior_UZ_contradiction` plus ~50-100 more for
  `gap_prior_SZ_contradiction` (if handled via dual reduction rather than mirroring).

**Key risk**: Sub-Task A (FO encoding of `right_gap_class_prop`) is the hardest part
and the one most likely to require plan adjustment. The encoding is conceptually clear
but mechanically complex in Lean 4's dependent type theory. An ABSTRACT approach
(using `Classical.choice` to postulate the formula's existence based on a Prop-level
argument that the encoding is possible) would bypass the explicit construction at the
cost of making the proof non-constructive (acceptable since the theorem is about
provability, not computability).

**Alternative encoding strategy**: Instead of encoding `right_gap_class_prop` directly,
observe that `right_gap_class_prop sig k M t` can be reformulated as:
"There exists a depth-k k-type `tau` such that `k_type_of sig k (M.subinterval sig t s) = tau`
for all s in the class of t, and there exists s > t with `k_type_of sig k (M.subinterval sig t s) ≠ tau`."
Since `KType sig k = NormalForm sig k 0 → Bool` is a finite type, the disjunction
over all k-types is a FINITE formula, which is expressible in monadic FO. This gives
a cleaner path to Sub-Task A.

---

## Recommended Implementation Order

1. **Sub-Task A first** (blocking dependency): Implement the monadic FO encoding
   for `right_gap_class_prop` using the finite k-type disjunction strategy. This
   is the hardest sub-task but everything else depends on it.

2. **Sub-Task C in parallel with B** (once A is done): Sub-Task B is short and
   can be developed alongside the early parts of Sub-Task C.

3. **Sub-Task D last**: Pure composition; can be written in outline and filled
   in once C is complete.

4. **gap_prior_SZ_contradiction**: After gap_prior_UZ_contradiction, implement
   via Order.dual reduction (if feasible in Lean) or mirror the argument (~150
   additional lines).

The total estimated effort is **380-670 lines** across all 4 sub-tasks plus
the SZ case, fitting within the existing plan estimate of 400-600 lines
(the higher end is more likely given Lean 4 verbosity for 26-subcase case analyses).
