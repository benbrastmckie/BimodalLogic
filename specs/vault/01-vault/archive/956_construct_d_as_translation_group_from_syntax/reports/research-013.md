# Research Report: Layered Representation Theorem Architecture

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-013
**Date**: 2026-03-09
**Session**: sess_1773188000_c4e5f3
**Status**: Findings ready for planning
**Effort**: Medium (mathematical analysis + Mathlib verification)
**Dependencies**: research-011, research-012
**Sources/Inputs**: Codebase (Axioms.lean, Validity.lean, TranslationGroup.lean, TaskFrame.lean), Mathlib lookup (lean_leansearch, lean_leanfinder, lean_loogle, lean_local_search), Web research (SEP Temporal Logic, Archimedean group Wikipedia, arxiv papers)
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

---

## 1. Executive Summary

- The dense/discrete dichotomy for totally ordered abelian groups holds ONLY for **Archimedean** groups. Non-Archimedean groups (e.g., Z^2 lexicographic) can be discrete (have immediate successors) yet not isomorphic to Z. The Archimedean property is therefore a critical prerequisite for the layered architecture.
- The representation theorem should be stated at three layers: (1) base layer parametric over abstract D, (2) dense extension with DN, (3) discrete extension with DP/DF. The base layer does NOT need to prove D is any specific group -- it works with the existing polymorphic validity definition.
- The existing codebase already implements the correct architecture: `valid` in Validity.lean quantifies over ALL `D : Type` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. This IS the parametric base layer.
- Mathlib provides the exact theorem needed: `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` proves that for Archimedean ordered abelian groups, either G is isomorphic to Z (as ordered group) or G is densely ordered. The converse direction `discrete_iff_not_denselyOrdered` gives a true dichotomy.
- The layered architecture is achievable: TM alone gives completeness for all linear frames (parametric over D). TM + DN gives completeness for dense D-frames (D densely ordered). TM + DP/DF (+ Archimedeanness) gives completeness for discrete D-frames (D isomorphic to Z).

---

## 2. The Dense/Discrete Dichotomy: Precise Mathematical Statement

### 2.1 The Archimedean Dichotomy (Mathlib Theorem)

The key Mathlib theorem is:

```
LinearOrderedAddCommGroup.discrete_or_denselyOrdered :
  (G : Type*) [LinearOrderedAddCommGroup G] [Archimedean G] →
  Nonempty (G ≃+o Z) ∨ DenselyOrdered G
```

**Module**: `Mathlib.GroupTheory.ArchimedeanDensely`

This says: For any Archimedean linearly ordered additive commutative group G, EITHER G is isomorphic to Z (as both an ordered set and an additive group, via `OrderAddMonoidIso`), OR G is densely ordered.

The stronger form gives a true dichotomy (exclusive or):

```
LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered :
  (G : Type*) [LinearOrderedAddCommGroup G] [Archimedean G] →
  Nonempty (G ≃+o Z) ↔ ¬ DenselyOrdered G
```

### 2.2 The Proof Structure

The proof of `discrete_or_denselyOrdered` is elegant and directly relevant:

1. **Case 1**: If there exists a least positive element x (i.e., `IsLeast {y : G | 0 < y} x`), then G is isomorphic to Z via `int_orderAddMonoidIso_of_isLeast_pos`.
2. **Case 2**: If there is no least positive element, then for any a < b, there exists c with a < c < b (constructed as a + z where z is a positive element smaller than b - a).

This tells us exactly what "discrete" means for an ordered group: having a minimal positive element.

### 2.3 The Non-Archimedean Counterexample

**Critical point**: The dichotomy does NOT hold for non-Archimedean groups.

Consider Z^2 with lexicographic ordering (the ordered pair (a,b) with (a1,b1) < (a2,b2) iff a1 < a2 or (a1 = a2 and b1 < b2)):

| Property | Z^2_lex |
|----------|---------|
| Totally ordered? | Yes |
| Abelian group? | Yes (componentwise addition) |
| Has successor? | Yes: succ(a,b) = (a, b+1) |
| Isomorphic to Z? | **No** (not Archimedean: no n with n*(0,1) >= (1,0)) |
| Densely ordered? | **No** (no element between (0,0) and (0,1)) |
| Archimedean? | **No** |

So Z^2_lex is a totally ordered abelian group that is **neither isomorphic to Z nor densely ordered**. It has immediate successors everywhere (like Z) but is not Archimedean.

### 2.4 Answer to the User's Question

> "Is it true that the representation theorem only holds for TM + DN or for TM + DF since any concrete totally ordered abelian group must be either dense or discrete?"

**No, it is not true that EVERY totally ordered abelian group is either dense or discrete (in the sense of being isomorphic to Z).** The dichotomy holds only for **Archimedean** groups. Non-Archimedean groups like Z^2 are discrete (have successors) but not isomorphic to Z.

However, this does not block the layered architecture. The key insight is that the representation theorem does not need to handle ALL ordered abelian groups simultaneously. It works at three separate levels (see Section 3).

---

## 3. The Layered Architecture

### 3.1 Layer 0: Existing Parametric Validity (No New Axioms)

The codebase ALREADY implements the correct parametric base layer:

```lean
-- From Validity.lean (lines 71-75)
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

This quantifies over ALL D with the required structure. Soundness is proven against this definition. This is the **representation theorem at maximum generality**: a formula is valid iff it is true in all task frames with any totally ordered abelian group D.

**What TM alone proves**: Exactly the formulas valid on ALL task frames, regardless of whether D is Z, Q, R, Z^2, or any other ordered abelian group. This is the correct level of generality for the base system.

### 3.2 Layer 1: Dense Extension (TM + DN)

Adding the density axiom DN: `Fp -> FFp` (equivalently: `some_future phi -> some_future (some_future phi)`)

**Frame condition**: DN is valid on a frame iff the temporal order is densely ordered (for all s < t, exists u with s < u < t).

**What this gives**:
- Soundness: DN is sound for all frames where D is densely ordered (Q, R, etc.)
- Completeness: TM + DN is complete for the class of all task frames where D is densely ordered

**To prove**: Define a restricted validity notion:

```lean
def valid_dense (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] -- NEW: D must be dense
    (F : TaskFrame D) (M : TaskModel F) ...,
    truth_at M Omega τ t φ
```

Then prove: `TM + DN ⊢ φ ↔ valid_dense φ`

**Concrete instantiation** (optional): When D is additionally Archimedean and countable, D is isomorphic to Q (a subgroup of Q, to be precise). In the canonical model construction with DN, the timeline T is countable, dense, and without endpoints, so T is isomorphic to Q by Cantor's theorem (`Order.iso_of_countable_dense`), and D can be taken as Q.

### 3.3 Layer 2: Discrete Extension (TM + DF)

Adding a single discreteness axiom:
- DF: `(F top ∧ φ ∧ Hφ) → FHφ` (forward discreteness)

**DP is derivable from DF via temporal_duality**: The TM proof system includes the `temporal_duality` inference rule (Derivation.lean): if `⊢ φ` then `⊢ swap_past_future(φ)`, where `swap_past_future` swaps `all_future ↔ all_past` (i.e., G ↔ H, F ↔ P) throughout. Applying this to DF instantiated at `swap χ`:

1. DF at `swap χ`: `⊢ (F top ∧ swap χ ∧ H(swap χ)) → FH(swap χ)`
2. Apply `temporal_duality`: `⊢ (P top ∧ χ ∧ Gχ) → PGχ` = **DP** ✓

So only DF needs to be stated as an axiom; DP is then a theorem of TM + DF.

**Frame condition**: DF is valid on a frame iff the temporal order has immediate successors (SuccOrder); once DP is derived, predecessors (PredOrder) follow.

**What this gives**:
- Soundness: DF is sound for all frames where D has SuccOrder
- Completeness: TM + DF is complete for the class of task frames with discrete D

**Concrete instantiation**: When D is additionally Archimedean, D is isomorphic to Z by `discrete_iff_not_denselyOrdered` (DF rules out density, so the Archimedean dichotomy forces Z). In the canonical model, Archimedeanness follows from the bidirectional reachability construction (every MCS is reached in finitely many canonical-R steps from the origin).

### 3.4 Architecture Summary

```
Layer 0 (TM):        valid φ ↔ ⊢_TM φ
                      Quantifies over ALL D : LinearOrderedAddCommGroup

Layer 1 (TM + DN):   valid_dense φ ↔ ⊢_{TM+DN} φ
                      Quantifies over dense D only
                      Concrete: D = Q (when Archimedean + countable)

Layer 2 (TM + DF):    valid_discrete φ ↔ ⊢_{TM+DF} φ
                       Quantifies over discrete D only
                       Concrete: D = Z (when Archimedean)
                       Note: DP is derived from DF via temporal_duality rule
```

Each layer is a proper extension of the previous one:
- `valid φ → valid_dense φ` (dense frames are a subclass of all frames)
- `valid φ → valid_discrete φ` (discrete frames are a subclass of all frames)
- But NOT `valid_dense φ → valid φ` (some dense-valid formulas are not universally valid)

---

## 4. What "Representation Theorem" Means at Each Layer

### 4.1 The JPL Paper's Representation Theorem

The JPL paper's task semantics uses D as a totally ordered abelian group. The "representation theorem" in this context is:

> Every consistent formula has a task frame model (with some D).

This is just **completeness** phrased model-theoretically. At each layer:

| Layer | Representation Theorem |
|-------|----------------------|
| TM | Every TM-consistent formula has a model with SOME ordered abelian group D |
| TM + DN | Every (TM+DN)-consistent formula has a model with a DENSE D |
| TM + DP/DF | Every (TM+DP+DF)-consistent formula has a model with a DISCRETE D |

### 4.2 The D-Construction Is NOT Part of the Representation Theorem

A critical clarification from research-012: the construction of D as a specific group (Z or Q) is **not** part of the representation theorem per se. The representation theorem says a model EXISTS. The D-construction is about BUILDING that model concretely.

For the parametric layer (TM alone), the representation theorem holds without constructing D at all -- D is universally quantified in the validity definition. The canonical model construction produces SOME frame, and completeness follows regardless of what D turns out to be.

The D-construction becomes relevant only when we want to:
1. Instantiate the parametric result with a specific D (for examples, computation)
2. Prove properties specific to dense or discrete time
3. Connect to the JPL paper's specific use of Z or Q

### 4.3 When Concrete D IS Needed

The concrete identification D = Q or D = Z is needed for:
- **AddTorsor D T**: proving the canonical timeline is a torsor requires knowing what D acts on it
- **Transfer of structure**: getting Mathlib instances (Archimedean, Countable, etc.) on the canonical timeline
- **Connecting to existing Lean instances**: Z and Q have extensive Mathlib support

But these are properties of the CANONICAL MODEL CONSTRUCTION, not of the representation theorem statement. The theorem can be stated parametrically; the proof instantiates D concretely.

---

## 5. Implementation Strategy

### 5.1 Phase 1: Base Layer (Already Done)

The existing codebase already has:
- `valid` quantifying over all D (Validity.lean)
- Soundness proven against this definition
- TM axioms stated without density or discreteness

**Status**: Complete. No work needed.

### 5.2 Phase 2: Define Restricted Validity Notions

Define `valid_dense` and `valid_discrete` as restricted quantifications:

```lean
-- Dense validity: true in all models with dense D
def valid_dense (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ

-- Discrete validity: true in all models with discrete D
def valid_discrete (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [PredOrder D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

**Effort**: 20-30 lines. Straightforward definitions.

### 5.3 Phase 3: Add DN Axiom and Prove Soundness

Add the density axiom to Axioms.lean:

```lean
| density (φ : Formula) :
    Axiom (Formula.some_future φ |>.imp (Formula.some_future (Formula.some_future φ)))
```

Prove soundness of DN for `valid_dense`:

```lean
theorem density_sound_dense :
    ∀ φ, Axiom.density φ → valid_dense (Formula.some_future φ |>.imp ...) := by ...
```

**Effort**: 30-50 lines.

### 5.4 Phase 4: Dense Completeness (Canonical Model with DN)

Prove that the canonical model with DN produces a dense timeline, then apply Cantor's theorem.

1. Prove `DenselyOrdered (CanonicalTimeline M0 h_mcs0)` from DN
2. Apply `Order.iso_of_countable_dense` to get T isomorphic to Q
3. Set D = Q, transfer AddTorsor
4. Prove completeness: `valid_dense φ → TM+DN ⊢ φ`

**Effort**: 115-185 lines (from research-012 estimate).

### 5.5 Phase 5: Discrete Completeness (Canonical Model with DF)

Using DF alone (DP is derived via temporal_duality) and the Z isomorphism.

1. Add DF axiom; derive DP via `temporal_duality` (one-line derivation)
2. Prove `SuccOrder` on the canonical timeline from DF; `PredOrder` from DP
3. Prove `IsSuccArchimedean` from the bidirectional reachability construction
4. Apply `orderIsoIntOfLinearSuccPredArch` to get T isomorphic to Z
5. Set D = Z, transfer AddTorsor
6. Prove completeness: `valid_discrete φ → TM+DF ⊢ φ`

**Effort**: 150-300 lines (DP derivation is trivial; the Archimedeanness proof remains the key risk).

### 5.6 Phase 6: The Archimedean Dichotomy Bridge

Prove the meta-theorem connecting the layers:

```lean
-- For Archimedean D, either D is Z-like or densely ordered
-- This is just an application of the Mathlib theorem
theorem archimedean_dichotomy (D : Type) [LinearOrderedAddCommGroup D] [Archimedean D] :
    Nonempty (D ≃+o Z) ∨ DenselyOrdered D :=
  LinearOrderedAddCommGroup.discrete_or_denselyOrdered D
```

This connects the two extension layers: for Archimedean D, every task frame falls into exactly one of the two categories.

**Effort**: 5 lines (direct application of Mathlib).

---

## 6. Addressing the User's Specific Questions

### 6.1 "Can D be constructed as a totally ordered abelian group from TM alone?"

**Yes, but not as a specific one.** From TM alone, the canonical model produces a timeline T. The translation group D = Additive(T ≃o T) is an AddGroup (already proven in TranslationGroup.lean). However:

- D may not be abelian (if T has order type Z^2, Aut+(T) is non-abelian)
- D may not have a linear order compatible with addition

So from TM alone, D is an AddGroup acting on T, but not necessarily an ordered abelian group. The correct approach is NOT to construct D from TM alone, but to use the parametric validity definition which quantifies over all possible D.

### 6.2 "When DN is added, is D dense?"

**Yes, conditionally.** When DN is added:
1. The canonical timeline T becomes densely ordered (provable from DN)
2. If D acts freely and transitively on T (torsor property), and D is an ordered abelian group, then D inherits density from T
3. Concretely, with DN the canonical T is isomorphic to Q, so D = Q is densely ordered

The statement is: "If DN is an axiom and D is the duration group of the canonical model, then `DenselyOrdered D`."

### 6.3 "When DP/DF is added, is D discrete?"

**Yes, conditionally + Archimedean.** When DP/DF are added:
1. The canonical timeline T has SuccOrder and PredOrder (provable from DP/DF)
2. If Archimedeanness holds (provable from the construction), then T is isomorphic to Z
3. D = Z has `SuccOrder` and `PredOrder` and `IsSuccArchimedean`

The Archimedean step is essential: DP/DF alone give T a successor/predecessor structure, but without Archimedeanness, T could be Z^2 (which has successors but is not isomorphic to Z).

### 6.4 "Is the Archimedean property always present?"

For the density path: **Archimedeanness is not needed.** Cantor's theorem requires only countability + density + no endpoints, not Archimedeanness. (Though Q happens to be Archimedean, we do not need this fact.)

For the discreteness path: **Archimedeanness IS needed.** The Mathlib theorem `orderIsoIntOfLinearSuccPredArch` requires IsSuccArchimedean. Without it, T could be Z^2 with SuccOrder but not isomorphic to Z.

This is a significant advantage of the density path.

---

## 7. The Non-Archimedean Gap

### 7.1 What Happens for Non-Archimedean D?

The existing validity definition quantifies over ALL ordered abelian groups D, including non-Archimedean ones like Z^2. The soundness theorem is proven for this full generality. But:

- TM completeness for non-Archimedean frames: TM IS complete for the class of ALL reflexive transitive linear frames, regardless of Archimedeanness. This is because TM axioms do not distinguish between Archimedean and non-Archimedean orderings.
- The issue arises only when trying to CONSTRUCT D concretely.

### 7.2 Should the Validity Definition Require Archimedean?

**No.** The current definition is correct. Soundness holds for all D. Completeness (TM proves exactly the universally valid formulas) holds because TM is frame-complete for all linear orders.

Adding `[Archimedean D]` to the validity definition would:
- Make soundness trivially easier (fewer models to check)
- But would change the set of valid formulas (some formulas valid on all Archimedean frames are NOT valid on Z^2 frames)
- Break the alignment with the existing soundness proofs

### 7.3 The Role of Archimedeanness in the Representation Theorem

Archimedeanness is needed ONLY at the concrete instantiation step:
- To prove D = Z (discrete case): need Archimedean + SuccOrder + PredOrder
- To prove D = Q (dense case): NOT needed (Cantor's theorem suffices)

At the parametric level, the representation theorem works without Archimedeanness.

---

## 8. Detailed Mathlib Theorem Analysis

### 8.1 The Core Dichotomy

| Theorem | Hypothesis | Conclusion |
|---------|-----------|------------|
| `discrete_or_denselyOrdered` | `LinearOrderedAddCommGroup G`, `Archimedean G` | `Nonempty (G ≃+o Z) ∨ DenselyOrdered G` |
| `discrete_iff_not_denselyOrdered` | same | `Nonempty (G ≃+o Z) ↔ ¬ DenselyOrdered G` |
| `int_orderAddMonoidIso_of_isLeast_pos` | same + `IsLeast {y : G \| 0 < y} x` | `G ≃+o Z` |

### 8.2 The Proof Mechanism

The proof of `discrete_or_denselyOrdered` works as follows:
- **Case: exists least positive element x**: Apply `int_orderAddMonoidIso_of_isLeast_pos` which constructs an order-and-group isomorphism G isomorphic to Z by matching x to 1.
- **Case: no least positive element**: For any a < b, the element b - a is positive but not least, so there exists z with 0 < z < b - a. Then a < a + z < b, establishing density.

### 8.3 Related Theorems

| Theorem | Type | Relevance |
|---------|------|-----------|
| `Order.iso_of_countable_dense` | `Nonempty (OrderIso alpha beta)` | Cantor's theorem for dense countable linear orders |
| `orderIsoIntOfLinearSuccPredArch` | `iota ≃o Z` | Z isomorphism for discrete Archimedean linear orders |
| `addGroupIsAddTorsor` | `AddTorsor G G` | Every additive group is a torsor over itself |
| `countable_of_linear_succ_pred_arch` | `Countable iota` | Discrete Archimedean linear orders are countable |

---

## 9. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| CanonicalReachable/CanonicalQuotient | Medium | Bidirectional fragment is correct but its order type is underdetermined without DN or DP/DF |
| Non-Standard Validity | Low | Parametric validity is standard validity; no non-standard issues |
| Single-Family BFMCS modal_backward | Low | Not relevant to D-construction layers |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | Compatible with parametric D: `fmcs : D -> Set Formula` works for any D |
| Representation-First | CONCLUDED | Layered representation extends this: base + dense + discrete layers |
| Algebraic Verification | PAUSED | Orthogonal: algebraic completeness is independent of D-choice (see research-012) |

### Key Insight

The "Indexed MCS Family Approach" strategy uses `fmcs : D -> Set Formula`. In the layered architecture:
- Base layer: D is abstract, fmcs is parametric
- Dense layer: D = Q, fmcs : Q -> Set Formula (densely indexed)
- Discrete layer: D = Z, fmcs : Z -> Set Formula (Z-indexed, = DovetailingChain)

This shows the existing DovetailingChain infrastructure is the discrete specialization of the parametric approach.

---

## 10. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Archimedean dichotomy theorem | Section 2 | No | new_file |
| Layered validity definitions (valid, valid_dense, valid_discrete) | Section 3 | No | extension |
| Non-Archimedean counterexample (Z^2 lexicographic) | Section 2.3 | No | extension |
| `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` | Section 8 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `duration-group-construction.md` | `domain/` | D-construction paths (parametric, Z, Q), Archimedean dichotomy, layered architecture | High | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Temporal Frame Classes | DN and DF axioms (DP derived), dense vs discrete frame conditions, Archimedean requirement, temporal_duality rule | Medium | No |
| `metalogic-concepts.md` | Completeness | Layered completeness (base, dense, discrete), parametric vs concrete | Medium | No |

### Summary

- **New files needed**: 1
- **Extensions needed**: 2
- **Tasks to create**: 0
- **High priority gaps**: 1

---

## 11. Decisions

1. **The dense/discrete dichotomy requires Archimedeanness.** Non-Archimedean groups (Z^2, etc.) are counterexamples. The Mathlib theorem `discrete_or_denselyOrdered` explicitly requires `[Archimedean G]`.

2. **The representation theorem should be layered, not monolithic.** Base layer (TM, all D) is already implemented. Dense layer (TM+DN) and discrete layer (TM+DF) extend it.

3. **The existing parametric validity IS the base layer.** No new "abstract D construction" is needed for the base. The validity definition already quantifies over all D.

4. **The density path does NOT require Archimedeanness for the T-to-Q isomorphism.** Cantor's theorem needs only countability + density + no endpoints. This is a significant advantage over the discrete path.

5. **The discrete path DOES require Archimedeanness.** DF gives SuccOrder (and DP is derived via temporal_duality to give PredOrder), but Archimedeanness is needed to apply `orderIsoIntOfLinearSuccPredArch`. Archimedeanness must be proven from the canonical model construction.

6b. **DP is derivable from DF via temporal_duality.** The TM proof system has a `temporal_duality` inference rule (Derivation.lean): from `⊢ φ`, derive `⊢ swap_past_future(φ)`. Applying this to DF instantiated at `swap χ` immediately gives DP for all χ. Only DF needs to be added as an axiom.

6. **D should NOT be constructed from TM alone as a specific group.** At the base layer, D is universally quantified. Concrete D is only needed at the extension layers.

---

## 12. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| DN soundness proof difficulty | Low | Medium | DN frame condition (density) is standard; proof follows from exists_between |
| DenselyOrdered proof on canonical timeline from DN | Low-Medium | Medium | Proof sketch is straightforward (research-012 Section 3.3) |
| Archimedeanness proof for discrete path | Medium | High | Can be proven from bidirectional reachability; fallback is density path first |
| `OrderAddMonoidIso` vs `OrderIso`: confusing the two | Medium | Low | `≃+o` preserves both order AND group structure; `≃o` only order |
| Restricted validity definitions may need refactoring of soundness | Low | Medium | Soundness is proven for unrestricted valid; restricted follows by specialization |

---

## 13. Appendix

### Search Queries Used

1. "totally ordered abelian group must be dense or discrete dichotomy theorem"
2. "temporal logic completeness representation theorem parametric ordered group dense discrete"
3. "non-archimedean totally ordered abelian group neither dense nor discrete example Z lexicographic product"
4. "Z times Z lexicographic order neither dense abelian group discrete successor predecessor"
5. Venema temporal logic completeness "Kt.3" "Kt.Li" dense discrete axiom system frame class linear order

### Mathlib Lookup Results

1. `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` -- **KEY**: Archimedean ordered abelian group is either isomorphic to Z or densely ordered
2. `LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered` -- True dichotomy (iff form)
3. `int_orderAddMonoidIso_of_isLeast_pos` -- Construct G ≃+o Z from least positive element
4. `Order.iso_of_countable_dense` -- Cantor's theorem: countable dense unbounded linear orders are isomorphic
5. `orderIsoIntOfLinearSuccPredArch` -- T ≃o Z from SuccOrder + PredOrder + IsSuccArchimedean
6. `addGroupIsAddTorsor` -- Every AddGroup is a torsor over itself
7. `Prod.Lex.linearOrder` -- Lexicographic product has LinearOrder
8. `countable_of_linear_succ_pred_arch` -- Discrete Archimedean implies Countable

### Codebase Files Examined

- `Theories/Bimodal/Semantics/Validity.lean` -- Current parametric validity definition (quantifies over all D)
- `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame D structure
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Current axiom system (no DN or DP/DF)
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` -- Current D = Aut+(T) construction
- `Theories/Bimodal/Examples/TemporalStructures.lean` -- Example frames (Int, polymorphic)
- `specs/956_construct_d_as_translation_group_from_syntax/reports/research-011.md` -- Prior: Morel classification
- `specs/956_construct_d_as_translation_group_from_syntax/reports/research-012.md` -- Prior: Density path rehabilitation

### References

- Mathlib: `Mathlib.GroupTheory.ArchimedeanDensely` -- The Archimedean dichotomy theorems
- Mathlib: `Mathlib.Order.CountableDenseLinearOrder` -- Cantor's theorem
- Mathlib: `Mathlib.Order.SuccPred.LinearLocallyFinite` -- Discrete order isomorphism to Z
- Mathlib: `Mathlib.Algebra.AddTorsor` -- Torsor definitions
- Stanford Encyclopedia of Philosophy, "Temporal Logic" -- Axiom systems for specific frame classes
- Venema, Y. "Temporal Logic." Chapter 10 in Handbook of Philosophical Logic
- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Publications
- Burgess, J.P. (1982). "Axioms for tense logic I." Notre Dame J. Formal Logic

### Web Sources

- [Archimedean group - Wikipedia](https://en.wikipedia.org/wiki/Archimedean_group)
- [Temporal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
- [Strong theories of ordered Abelian groups (arxiv)](https://arxiv.org/pdf/1511.08274)
- [Quantifier Elimination for Lexicographic Products of Ordered Abelian Groups](https://projecteuclid.org/journals/tsukuba-journal-of-mathematics/volume-33/issue-1/Quantifier-Elimination-for-Lexicographic-Products-of-Ordered-Abelian-Groups/10.21099/tkbjm/1251833209.full)

---

## 14. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-013.md`
- **Key referenced files**:
  - `Theories/Bimodal/Semantics/Validity.lean` -- Parametric validity (base layer)
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- Current axiom system
  - `Theories/Bimodal/ProofSystem/Derivation.lean` -- temporal_duality rule (line 136)
  - `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` -- past_k_dist, past_necessitation derived via temporal_duality
  - `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` -- Current D construction
  - `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame structure

---

## 15. Next Steps

1. **Decision**: Accept layered architecture (base parametric + dense DN + discrete DF, where DP is derived)
2. **Phase 1**: Define `valid_dense` and `valid_discrete` in Validity.lean
3. **Phase 2**: Add DN axiom to Axioms.lean, prove soundness for `valid_dense`
4. **Phase 3**: Prove DenselyOrdered on canonical timeline from DN
5. **Phase 4**: Apply Cantor's theorem, set D = Q, prove completeness for `valid_dense`
6. **Phase 5** (optional/deferred): Add DP/DF, prove discrete completeness
7. **Phase 6** (optional): Prove Archimedean dichotomy bridge connecting layers
