# Research Report 002: Detailed Codebase Audit for the Translation Group Construction

**Task**: 956 -- Construct D as translation group from syntax
**Date**: 2026-03-06
**Session**: sess_1772899200_a5b3c7
**Status**: Complete
**Supplements**: research-001.md (theoretical pipeline overview)

## 1. Executive Summary

This report audits every file in the existing Lean codebase against the 11-step construction pipeline from research-001.md, starting from an arbitrary consistent set Gamma_0. For each step, we identify what is already proven (with file paths and theorem names), what remains to be completed, and what blockers exist.

**Key finding**: Steps 1-3 of the forward direction (Lindenbaum, existence lemma, CanonicalR-based ordering) are essentially complete and sorry-free. The current completeness proof already works end-to-end via `CanonicalMCS` (all-MCS approach) with a **trivial** `task_rel`. The translation group construction (Steps 4-8) is entirely new and represents the core work of this task. Steps 9-11 (canonical model, truth lemma, completeness) are already proven but with `task_rel := fun _ _ _ => True`, and must be adapted to use the proper group action.

**Critical insight**: The existing codebase has TWO parallel completeness approaches:
1. **CanonicalMCS approach** (`CanonicalFMCS.lean`, `Representation.lean`): Works with `D = Int`, `task_rel = trivial`. Sorry-free at the FMCS level; sorry in `fully_saturated_bfmcs_exists_int` for combining temporal coherence with modal saturation.
2. **BidirectionalFragment approach** (`BidirectionalReachable.lean`, `CanonicalCompleteness.lean`, `FragmentCompleteness.lean`): Works at fragment level with sorry-free forward_F/backward_P, but has 2 sorries converting fragment chain to `FMCS Int` (F-persistence obstacle).

The translation group construction offers a third approach that could eliminate ALL remaining sorries by making D = Aut+(T) emerge from the structure itself.

---

## 2. Step-by-Step Audit

### Step 1: Lindenbaum Extension -- Gamma_0 to MCS w_0

**Goal**: Given a consistent set of formulas Gamma_0, extend it to a maximal consistent set w_0.

**Status**: FULLY PROVEN (sorry-free)

**Existing Infrastructure**:

| Item | File | Status |
|------|------|--------|
| `SetConsistent` | `Core/MaximalConsistent.lean:88` | Defined |
| `SetMaximalConsistent` | `Core/MaximalConsistent.lean:95` | Defined |
| `consistent_chain_union` | `Core/MaximalConsistent.lean:253` | Proven |
| `set_lindenbaum` | `Core/MaximalConsistent.lean:291` | Proven (via Zorn) |
| `lindenbaumMCS` | `Core/MCSProperties.lean` | Defined (wrapper) |
| `lindenbaumMCS_is_mcs` | `Core/MCSProperties.lean` | Proven |
| `lindenbaumMCS_extends` | `Core/MCSProperties.lean` | Proven |
| `lindenbaumMCS_set` | `Core/MCSProperties.lean` | Defined (set-based) |
| `lindenbaumMCS_set_extends` | `Core/MCSProperties.lean` | Proven |

**MCS Closure Properties** (all proven, sorry-free):
- `maximal_consistent_closed` (deductive closure)
- `maximal_negation_complete` (negation completeness)
- `theorem_in_mcs` (theorems belong to every MCS)
- `set_mcs_implication_property` (modus ponens closure)
- `set_mcs_negation_complete` (either phi or neg phi)
- `set_mcs_all_future_all_future` (temporal 4: G(phi) -> G(G(phi)))
- `set_mcs_all_past_all_past` (temporal 4: H(phi) -> H(H(phi)))

**Remaining work**: None for this step. The infrastructure is complete.

**Usage in task 956**: Call `set_lindenbaum` on `Gamma_0` to get `w_0`. This is the designated origin.

---

### Step 2: Building the Timeline T via the Existence Lemma

**Goal**: From w_0, build the universe T of MCSes reachable by iterated forward and backward temporal witness steps.

**Status**: FULLY PROVEN (sorry-free)

**Existing Infrastructure**:

| Item | File | Status |
|------|------|--------|
| `GContent` / `HContent` | `Bundle/TemporalContent.lean` | Defined |
| `ForwardTemporalWitnessSeed` | `Bundle/DovetailingChain.lean` | Defined |
| `PastTemporalWitnessSeed` | `Bundle/DovetailingChain.lean` | Defined |
| `forward_temporal_witness_seed_consistent` | `Bundle/DovetailingChain.lean` | Proven |
| `past_temporal_witness_seed_consistent` | `Bundle/DovetailingChain.lean` | Proven |
| `CanonicalR` | `Bundle/CanonicalFrame.lean:63` | Defined: `GContent M ⊆ M'` |
| `CanonicalR_past` | `Bundle/CanonicalFrame.lean:71` | Defined: `HContent M ⊆ M'` |
| `canonical_forward_F` | `Bundle/CanonicalFrame.lean` | Proven (sorry-free) |
| `canonical_backward_P` | `Bundle/CanonicalFrame.lean` | Proven (sorry-free) |
| `canonical_forward_G` | `Bundle/CanonicalFrame.lean` | Proven (trivial) |
| `canonical_backward_H` | `Bundle/CanonicalFrame.lean` | Proven (trivial) |
| `canonicalR_reflexive` | `Bundle/CanonicalFrame.lean` | Proven (via T-axiom) |
| `canonicalR_transitive` | `Bundle/CanonicalFrame.lean` | Proven (via Temp4) |
| `BidirectionalEdge` | `Bundle/BidirectionalReachable.lean:58` | Defined |
| `BidirectionalReachable` | `Bundle/BidirectionalReachable.lean:84` | Defined |
| `BidirectionalFragment` | `Bundle/BidirectionalReachable.lean` | Defined (subtype) |
| `forward_F_stays_in_fragment` | `Bundle/BidirectionalReachable.lean` | Proven |
| `backward_P_stays_in_fragment` | `Bundle/BidirectionalReachable.lean` | Proven |

**Key insight**: `BidirectionalFragment M_0 h_mcs_0` IS the timeline T from research-001.md. It is exactly the set of MCSes reachable from w_0 by iterated forward/backward temporal witness steps.

**Remaining work**: None structurally. The BidirectionalFragment already captures the reachable MCS universe. However, for the translation group construction, we need to work with this type as a linearly ordered set (see Step 3).

---

### Step 3: Linear Order Properties of T

**Goal**: Show T is a connected, linearly ordered set without endpoints.

**Status**: PARTIALLY PROVEN

**Existing Infrastructure**:

| Item | File | Status |
|------|------|--------|
| `Preorder CanonicalMCS` | `Bundle/CanonicalFMCS.lean:93` | Defined via CanonicalR |
| `fragment_total` | `Bundle/BidirectionalReachable.lean` | Proven (totality on fragment) |
| `CanonicalR` transitivity | `Bundle/CanonicalFrame.lean` | Proven |
| `CanonicalR` reflexivity | `Bundle/CanonicalFrame.lean` | Proven |
| `GContent_subset_implies_HContent_reverse` | `Bundle/CanonicalFrame.lean` | Proven (duality) |

**Fragment Totality**: The BidirectionalFragment has a TOTAL preorder:
- For any `w, v` in the fragment, either `w <= v` or `v <= w`
- This is proven in `BidirectionalReachable.lean` (by induction on reachability paths)

**What is proven**:
- Reflexivity of the preorder (via T-axiom: G(phi) -> phi)
- Transitivity (via Temp4: G(phi) -> G(G(phi)))
- Totality within the bidirectional fragment
- Forward/backward duality (GContent/HContent reversal)

**What remains to be proven**:
1. **Antisymmetry**: The preorder on BidirectionalFragment is NOT antisymmetric a priori. Two distinct MCSes M, M' might have `GContent(M) ⊆ M'` AND `GContent(M') ⊆ M` without being equal. This is the **antisymmetrization** problem. The current code does NOT have a proof that the fragment preorder is antisymmetric.

2. **No endpoints**: Need to show that for every `w` in the fragment, there exists `v > w` and `u < w`. This follows from seriality axioms (G(phi) -> F(phi), H(phi) -> P(phi)) combined with the existence lemma, but is not explicitly stated as a lemma.

3. **Strict linear order**: Need the quotient by the equivalence relation `w ~ v iff w <= v and v <= w`, giving an antisymmetric total order. Alternatively, prove that the preorder IS antisymmetric for the fragment (which might be achievable from linearity axioms).

**Blockers**: The antisymmetry question is non-trivial. If the preorder is NOT antisymmetric, we need `Antisymmetrization` from Mathlib (already imported in `BidirectionalReachable.lean`). The construction becomes: T = Antisymmetrization of (BidirectionalFragment, <=).

---

### Step 4: Translation Group D = Aut+(T)

**Goal**: Define D as the group of order-preserving automorphisms of (T, <).

**Status**: NOT STARTED

**Existing Infrastructure**: None directly. However:
- Mathlib has `OrderIso` (order isomorphisms) and `OrderAutomorphism`
- `Mathlib.Order.Hom.Group` has `OrderIso.group` giving group structure on automorphisms

**What needs to be built**:
1. `TranslationGroup T` -- the type `OrderIso T T` (order-preserving bijections of T)
2. Group instance on `TranslationGroup T` -- from Mathlib's `OrderIso` infrastructure
3. Proof that the group acts on T by order-preserving maps (built into the definition)

**Dependencies**: Step 3 must be completed first (T must be a LinearOrder, not just a Preorder).

**Mathlib resources to investigate**:
- `Mathlib.Order.Hom.Group` -- group structure on automorphisms
- `Mathlib.GroupTheory.GroupAction.Defs` -- group action infrastructure
- `Mathlib.Dynamics.PeriodicPts` -- possible tools for rigidity arguments

---

### Step 5: Origin Bijection eval_0

**Goal**: Define `eval_0 : D -> T` by `eval_0(d) = d(w_0)` and prove it is a bijection.

**Status**: NOT STARTED

**What needs to be proven**:
1. **Surjectivity (transitivity of action)**: For every `w` in T, there exists `d` in D with `d(w_0) = w`. This requires showing that T is homogeneous -- for any two points, there is an order-preserving automorphism mapping one to the other.

2. **Injectivity (freeness of action)**: If `d(w_0) = w_0`, then `d = id`. This requires showing that an order-preserving automorphism fixing a point of a connected linear order is the identity (rigidity).

**Mathematical challenge**: The homogeneity and rigidity proofs are the HARDEST parts of the entire construction. They require substantial order-theoretic arguments that may not have direct Mathlib support.

**Homogeneity approach**: For a linear order arising from temporal logic MCSes:
- The order structure is determined by the axioms, which are uniform
- Every point has the same local structure (seriality, no endpoints)
- Homogeneity follows from the uniformity of the axioms

**Rigidity approach**: For a connected linear order:
- An order automorphism fixing a point fixes every point in the connected component
- Since T is connected (every point reachable from w_0), fixing w_0 forces identity

**Blockers**: These are genuine mathematical results that need formal proofs. Neither homogeneity nor rigidity is trivial to formalize.

---

### Step 6: Pullback Order on D

**Goal**: Define `d_1 < d_2 iff d_1(w_0) < d_2(w_0)` and show this makes D a linearly ordered set.

**Status**: NOT STARTED

**Dependencies**: Steps 4 and 5.

**What needs to be proven**: Once eval_0 is a bijection between D and T, and T is linearly ordered, the pullback order is automatically a linear order. This is straightforward given the prerequisites.

**Mathlib resources**: `OrderIso.linearOrder` or manual transfer of order instances.

---

### Step 7: Abelian Group Structure

**Goal**: Show D is an abelian group.

**Status**: NOT STARTED

**Mathematical argument**: A group acting freely and transitively on a linearly ordered set by order-preserving maps is abelian. This is because:
- The induced order on D is bi-invariant
- A bi-invariantly ordered group is abelian

**Mathlib resources to investigate**:
- `Mathlib.Algebra.Order.Group.Defs` -- ordered group definitions
- May need to prove the abelianness theorem from scratch

**Blocker**: This is a standard result in ordered group theory, but it may not be directly available in Mathlib. The proof would need to be formalized.

---

### Step 8: task_rel as Group Action

**Goal**: Define `task_rel(d)(w) = d(w)` (the group action of D on T).

**Status**: PARTIALLY ADDRESSED (trivially)

**Current state**: The existing codebase uses `task_rel := fun _ _ _ => True` in `Representation.lean:100`:
```lean
def canonicalFrame (B : BFMCS Int) : TaskFrame Int where
  WorldState := CanonicalWorldState B
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
```

This trivial task_rel makes `respects_task` for WorldHistory trivially satisfiable, but it does NOT match the JPL paper's intended semantics.

**What the paper requires** (`WorldHistory.lean:96`):
```lean
respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

So `task_rel w d u` means "starting from world state w, executing a task of duration d can reach state u." The translation group construction would define:
```
task_rel w d u  :=  d(w) = u
```
where `d` acts as an order-preserving automorphism of T.

**What needs to change**:
1. Define `canonicalFrame` with `task_rel w d u := eval_0(d)(eval_0^{-1}(w)) = u` (i.e., apply the translation corresponding to d to the world w).
2. Prove nullity: `task_rel w 0 w` (identity translation fixes w).
3. Prove compositionality: `task_rel w x u -> task_rel u y v -> task_rel w (x+y) v` (composition of translations).
4. Prove `respects_task` for canonical histories.

**TaskFrame requirements** (`TaskFrame.lean:84`):
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

The requirements `[AddCommGroup D]`, `[LinearOrder D]`, `[IsOrderedAddMonoid D]` must be satisfied by the translation group D. This means Steps 4-7 must produce these instances.

---

### Step 9: Canonical Model Assembly

**Goal**: Assemble M = (T, <, D, task_rel, V).

**Status**: PROVEN (with trivial task_rel)

**Existing Infrastructure**:

| Item | File | Status |
|------|------|--------|
| `TaskFrame D` | `Semantics/TaskFrame.lean:84` | Defined |
| `TaskModel` | `Semantics/TaskModel.lean` | Defined |
| `WorldHistory` | `Semantics/WorldHistory.lean:69` | Defined |
| `canonicalFrame` | `Representation.lean:98` | Defined (trivial task_rel) |
| `canonicalModel` | `Representation.lean:105` | Defined |
| `canonicalHistory` | `Representation.lean:114` | Defined |
| `canonicalOmega` | `Representation.lean:137` | Defined |
| `shiftClosedCanonicalOmega` | `Representation.lean:156` | Defined |
| `shiftClosedCanonicalOmega_is_shift_closed` | `Representation.lean:181` | Proven |

**What needs to change**: Replace `canonicalFrame`'s trivial `task_rel` with the group action. Everything downstream (model, histories, omega) will need corresponding adjustments.

---

### Step 10: Truth Lemma

**Goal**: For all formulas phi and worlds w in T: M, w |= phi iff phi in w.

**Status**: FULLY PROVEN (sorry-free)

**Existing Infrastructure**:

| Item | File | Status |
|------|------|--------|
| `bmcs_truth_lemma` | `Bundle/TruthLemma.lean` | Proven (BFMCS level, sorry-free) |
| `canonical_truth_lemma_all` | `Representation.lean:266` | Proven (standard semantics) |
| `shifted_truth_lemma` | `Representation.lean:411` | Proven (shift-closed Omega) |

**Key observation**: The truth lemma proof in `Representation.lean` does NOT depend on the specific `task_rel`. The atom, bot, imp, box, all_future, and all_past cases use:
- Atom: valuation = MCS membership (independent of task_rel)
- Bot: inconsistency (independent of task_rel)
- Imp: MCS implication property (independent of task_rel)
- Box: modal_forward/modal_backward from BFMCS (independent of task_rel)
- G/H: forward_G/backward_H from FMCS (independent of task_rel)

The truth lemma's backward direction for G and H uses `forward_F`/`backward_P` from temporal coherence, which IS where the sorry currently lives (in `fully_saturated_bfmcs_exists_int`).

**What changes with translation group**: If D = Aut+(T) instead of Int, the truth lemma structure is identical but instantiated at a different type. The critical question is whether the BFMCS construction can be done sorry-free at D = Aut+(T).

---

### Step 11: Completeness Theorem

**Goal**: If |= phi then |- phi.

**Status**: PROVEN (sorry-dependent on upstream `fully_saturated_bfmcs_exists_int`)

**Existing Infrastructure**:

| Item | File | Status |
|------|------|--------|
| `standard_representation` | `Representation.lean:551` | Proven (1 upstream sorry) |
| `standard_weak_completeness` | `Representation.lean:608` | Proven (1 upstream sorry) |
| `standard_strong_completeness` | `Representation.lean:650` | Proven (1 upstream sorry) |

**Sorry dependency chain**:
```
standard_weak_completeness
  -> construct_saturated_bfmcs_int
    -> fully_saturated_bfmcs_exists_int  [1 SORRY]
```

**The single sorry** is in `TemporalCoherentConstruction.lean:600`:
```lean
theorem fully_saturated_bfmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B := by
  sorry
```

This sorry exists because combining temporal coherence AND modal saturation for D = Int requires resolving the F-persistence obstacle (see FragmentCompleteness.lean analysis).

---

## 3. Sorry Inventory

### Active Sorry Count (excluding Examples, Automation, Boneyard)

| File | Sorry Count | Description |
|------|------------|-------------|
| `TemporalCoherentConstruction.lean:600` | 1 | `fully_saturated_bfmcs_exists_int` |
| `DovetailingChain.lean:1869` | 1 | `buildDovetailingChainFamily_forward_F` |
| `DovetailingChain.lean:1881` | 1 | `buildDovetailingChainFamily_backward_P` |
| `FragmentCompleteness.lean:460` | 1 | `fragmentChainFMCS_forward_F` |
| `FragmentCompleteness.lean:471` | 1 | `fragmentChainFMCS_backward_P` |
| **Total** | **5** | All related to F/P witness placement in Int chains |

All 5 sorries are manifestations of the SAME underlying problem: the F-persistence obstacle. When building an Int-indexed chain of MCSes, F-formulas can be "jumped past" by Lindenbaum extensions that non-deterministically add incompatible G-formulas.

**The translation group approach potentially eliminates all 5 sorries** by avoiding Int-indexed chains entirely. D emerges as Aut+(T), and temporal witnesses exist by the existence lemma at the fragment level (which IS sorry-free).

---

## 4. Architecture Assessment: What the Translation Group Changes

### What Stays the Same
- Steps 1-2: Lindenbaum + existence lemma (foundation, untouched)
- BFMCS/FMCS infrastructure (definitions only, reusable at any D)
- Truth lemma structure (formula-inductive proof, independent of task_rel specifics)
- Completeness proof structure (contrapositive argument)

### What Must Change
1. **D type**: Currently `Int`. Must become `TranslationGroup T` (= Aut+(BidirectionalFragment M_0)).
2. **task_rel**: Currently `fun _ _ _ => True`. Must become the group action.
3. **TaskFrame D requirements**: D must have `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`. These must be DERIVED from the translation group structure, not assumed.
4. **BFMCS construction**: Currently `fully_saturated_bfmcs_exists_int` (sorry-backed for Int). Must be redone for D = Aut+(T), potentially sorry-free.
5. **WorldHistory.respects_task**: Currently trivially satisfied. Must be proven for the actual group action.

### Critical Path Analysis

The **minimal viable path** to sorry-free completeness via the translation group:

```
Phase 1: Fragment Infrastructure (DONE)
  - BidirectionalFragment, totality, F/P closure

Phase 2: Antisymmetrization / Linear Order on T
  - Either prove preorder is antisymmetric, or quotient
  - Prove no endpoints (from seriality)

Phase 3: Translation Group D = Aut+(T)
  - Define as OrderIso T T
  - Derive group structure (from Mathlib)

Phase 4: Homogeneity + Rigidity (HARDEST)
  - eval_0 bijection: D ≅ T
  - Requires substantial order-theoretic arguments

Phase 5: Ordered Abelian Group on D
  - Pullback order from T
  - Abelianness proof
  - Derive AddCommGroup + LinearOrder + IsOrderedAddMonoid

Phase 6: Canonical Model with Group Action task_rel
  - New canonicalFrame with task_rel = group action
  - Prove nullity, compositionality
  - Prove respects_task for canonical histories

Phase 7: BFMCS at D = Aut+(T)
  - Adapt modal saturation
  - Temporal coherence (from fragment-level F/P, sorry-free)
  - Combine (the step that is sorry-backed for Int)

Phase 8: Truth Lemma + Completeness
  - Instantiate existing proof at new D type
```

---

## 5. Alternative Approach: CanonicalMCS as Time Domain

There is a SIMPLER alternative that avoids much of the translation group complexity:

**Observation**: The existing `temporal_coherent_family_exists_CanonicalMCS` theorem (`CanonicalFMCS.lean:265`) is SORRY-FREE. It constructs a fully temporally coherent family at `D = CanonicalMCS` (all MCSes). The modal saturation construction (`ModalSaturation.lean`) is also sorry-free.

**The obstacle** is that `TaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, and `CanonicalMCS` does not have these instances.

**If we could give CanonicalMCS (or BidirectionalFragment) an AddCommGroup + LinearOrder + IsOrderedAddMonoid structure**, the entire completeness chain would be sorry-free without needing the full translation group construction.

**This is exactly what the translation group provides**: D = Aut+(T) inherits the required algebraic structure, and T (as a principal homogeneous space for D) inherits it by transfer.

So the translation group construction is not an alternative to the existing fragment infrastructure -- it is the KEY to giving T the algebraic structure that `TaskFrame` demands.

---

## 6. Risk Assessment

### High Risk Items
1. **Homogeneity of T** (Step 5): This is the mathematical core. Must prove that for any two points in T, there is an order automorphism mapping one to the other. This may require significant new infrastructure around the order structure of MCS timelines.

2. **Abelianness** (Step 7): Standard result but may not be in Mathlib. Need to check `Mathlib.Order.Group.OrderIsoPermGroup` or similar.

3. **TaskFrame compatibility** (Step 8): The `respects_task` constraint is non-trivial when task_rel is a genuine group action (not trivially True).

### Medium Risk Items
4. **Antisymmetry** (Step 3): May need Antisymmetrization quotient, adding complexity.
5. **BFMCS construction at new D** (Step 9): Adapting modal saturation for a non-Int domain.

### Low Risk Items
6. **Lindenbaum, existence lemma** (Steps 1-2): Completely proven.
7. **Truth lemma structure** (Step 10): Independent of task_rel specifics.
8. **Completeness argument** (Step 11): Structural, depends only on BFMCS + truth lemma.

---

## 7. Recommended Implementation Strategy

### Option A: Full Translation Group (as described in research-001.md)
- Build Aut+(T) from scratch
- Prove homogeneity + rigidity
- Derive all algebraic structure
- **Pro**: Mathematically clean, matches theoretical pipeline exactly
- **Con**: Homogeneity proof is substantial; estimated 8-12 phases

### Option B: BidirectionalFragment as Ordered Group (shortcut)
- Use BidirectionalFragment (which is already a total preorder) as the time domain
- Define D directly as the Antisymmetrization of BidirectionalFragment
- Show this quotient inherits group structure from the temporal axioms
- **Pro**: Reuses existing sorry-free infrastructure
- **Con**: The group structure on the quotient is not obvious; may still need homogeneity

### Option C: Factored Approach (recommended)
1. First prove completeness for BidirectionalFragment as time domain with trivial task_rel (already nearly done, just needs BFMCS construction adapted)
2. Then prove that BidirectionalFragment admits a translation group D
3. Then upgrade task_rel from trivial to the group action
4. **Pro**: Incremental progress, each step independently valuable
- **Con**: More phases but each is smaller and more tractable

### Recommended: Option C (Factored Approach)

The factored approach yields:
- Phase 1: Sorry-free completeness at BidirectionalFragment (fixes the F-persistence obstacle)
- Phase 2: Translation group construction (proper task_rel, matches paper semantics)
- Phase 3: Isomorphism to Int for discrete time (optional, theoretical interest)

---

## 8. Concrete Next Steps

1. **Investigate antisymmetry**: Does the BidirectionalFragment preorder happen to be antisymmetric? If so, it IS a linear order directly. Check using `lean_local_search` or proof attempts.

2. **Check Mathlib for OrderIso group structure**: Search for `OrderIso.instGroup` or `Equiv.Perm.instGroup` restricted to order-preserving maps.

3. **Prototype the fragment-level BFMCS**: Adapt `FragmentCompleteness.lean` to produce a `BFMCS (BidirectionalFragment M_0 h_mcs_0)` that is fully sorry-free (this may be possible since forward_F and backward_P are already sorry-free at fragment level).

4. **Investigate the AddCommGroup obstacle**: What is the minimal additional structure needed on BidirectionalFragment (or its antisymmetrization) to satisfy TaskFrame's requirements?

---

## 9. File Reference Map

```
Construction Pipeline -> Codebase Location

Step 1 (Lindenbaum)    -> Core/MaximalConsistent.lean (set_lindenbaum)
Step 2 (Existence)      -> Bundle/CanonicalFrame.lean (canonical_forward_F, canonical_backward_P)
                        -> Bundle/BidirectionalReachable.lean (BidirectionalFragment)
Step 3 (Linear Order)   -> Bundle/BidirectionalReachable.lean (fragment_total)
                        -> [GAP: antisymmetry not proven]
Step 4 (Aut+(T))        -> [NOT STARTED]
Step 5 (eval_0)         -> [NOT STARTED]
Step 6 (Pullback Order) -> [NOT STARTED]
Step 7 (Abelian)        -> [NOT STARTED]
Step 8 (task_rel)       -> Representation.lean:100 (trivial, needs replacement)
Step 9 (Canonical Model)-> Representation.lean:98-138 (needs task_rel update)
Step 10 (Truth Lemma)   -> Representation.lean:266 (proven, mostly task_rel-independent)
                        -> Bundle/TruthLemma.lean (BFMCS-level, sorry-free)
Step 11 (Completeness)  -> Representation.lean:608 (proven, 1 upstream sorry)
```

---

## 10. Summary of Findings

| Step | Status | Sorry Count | Key File |
|------|--------|-------------|----------|
| 1. Lindenbaum | COMPLETE | 0 | `Core/MaximalConsistent.lean` |
| 2. Existence Lemma | COMPLETE | 0 | `Bundle/CanonicalFrame.lean` |
| 3. Linear Order | PARTIAL | 0 | `Bundle/BidirectionalReachable.lean` |
| 4. Aut+(T) | NOT STARTED | - | (new file needed) |
| 5. eval_0 | NOT STARTED | - | (new file needed) |
| 6. Pullback Order | NOT STARTED | - | (new file needed) |
| 7. Abelian | NOT STARTED | - | (new file needed) |
| 8. task_rel | TRIVIALLY DONE | 0 | `Representation.lean` (needs upgrade) |
| 9. Canonical Model | DONE (trivial) | 0 | `Representation.lean` (needs upgrade) |
| 10. Truth Lemma | COMPLETE | 0 | `Representation.lean`, `Bundle/TruthLemma.lean` |
| 11. Completeness | COMPLETE | 1* | `Representation.lean` |

*The 1 sorry in Step 11 is inherited from `fully_saturated_bfmcs_exists_int`, which is the F-persistence obstacle. The translation group approach aims to eliminate this sorry by making D = Aut+(T) and using the sorry-free fragment-level F/P proofs.
