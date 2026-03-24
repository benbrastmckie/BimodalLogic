# Teammate B Findings: FMP Approach and Equivalence

**Task**: 49 - fmp_based_boundedness_proof_fallback
**Date**: 2026-03-24
**Role**: Teammate B - FMP Approach and Equivalence Analysis
**Session**: sess_1774335050_c8fe9d

---

## Key Findings

### 1. The FMP Infrastructure is Nearly Complete (with One Critical Blocker)

The FMP path through `Theories/Bimodal/Metalogic/Decidability/FMP/` has nearly all structural
components built:

| File | Status | Notes |
|------|--------|-------|
| `ClosureMCS.lean` | **Sorry-free** | Closure-restricted MCS, Lindenbaum extension, cardinality bounds |
| `Filtration.lean` | **Sorry-free** | MCS-based filtration equivalence, quotient type, refined task frame |
| `FiniteModel.lean` | **Sorry-free** | FilteredWorld.finite proof via injection into Set (subformulaClosure phi) |
| `TruthPreservation.lean` | **2 sorries** | `mcs_all_future_closure` and `mcs_all_past_closure` are blocked |
| `FMP.lean` | **Sorry-free** | Main FMP theorem, `mcs_finite_model_property`, `fmp_contrapositive` |
| `DenseFMP.lean` | **Sorry-free** | Delegates to base FMP (frame-independent) |
| `DiscreteFMP.lean` | **Sorry-free** | Delegates to base FMP (frame-independent) |

The 2 sorries in `TruthPreservation.lean` are **explicitly documented** as arising from a
semantic mismatch:

```lean
-- DEPRECATED: Under strict temporal semantics, the T-axiom (Gφ → φ) is
-- NOT valid, so this theorem does not hold. The FMP proof strategy needs redesign
-- to avoid relying on reflexive semantics.
theorem mcs_all_future_closure ... sorry
theorem mcs_all_past_closure ... sorry
```

### 2. The Core Conflict: Reflexive vs. Strict Temporal Semantics

The FMP sorries are NOT arbitrary proof gaps - they represent a genuine semantic mismatch:

**The semantics IS reflexive** (confirmed in `Soundness.lean` lines 244-266):
```lean
-- The temporal T axiom (Gφ → φ) IS VALID under the project's semantics.
-- "G" quantifies over s ≥ t (with ≤), so t ≥ t gives Gφ → φ.
theorem temp_t_future_valid (φ : Formula) : ⊨ (φ.all_future.imp φ)
```

**The filtration lemmas claim T-axiom can't be used**:
The `mcs_all_future_closure` theorem is marked DEPRECATED with the note that
"Gψ only says ψ at times > t, not at t itself." This is INCORRECT relative to the
actual semantics - the comment in TruthPreservation.lean is *wrong* about the semantics.

The project's truth evaluation for `all_future` (G) quantifies over `s ≥ t` (reflexive),
not `s > t` (strict). Therefore `Gψ → ψ` IS a theorem, and `temp_t_future ψ` IS in the
axiom system (confirmed by `Axiom.temp_t_future` handling in `Soundness.lean` line 399).

**Consequence**: The 2 sorries in `TruthPreservation.lean` can be removed by simply applying
the `temp_t_future` and `temp_t_past` axioms - the same technique used for `mcs_box_closure`
(which uses `Axiom.modal_t` and is already proven). The commented deprecation notes contain
a factual error about the semantics.

### 3. FMP-Based Completeness Path

The `FMP.lean` file already proves the key theorem:

```lean
-- If φ not provable → ∃ closure MCS where φ fails (proven, sorry-free)
theorem mcs_finite_model_property (phi : Formula)
    (h_not_provable : ¬Nonempty (DerivationTree [] phi)) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier ∧ Finite (FilteredWorld phi)

-- Contrapositive (proven, sorry-free)
theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : ∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) :
    Nonempty (DerivationTree [] phi)
```

These theorems operate at the **proof-theoretic** level (MCS membership, not semantic truth).
The connection to semantic validity requires the filtration lemma (truth preservation), which
is where the 2 sorries appear.

### 4. The Equivalence Connection: Same Core MCS Structure

The algebraic path and the FMP path are formally equivalent through a chain:

```
Proof-theoretic: ⊢ φ
   ↕ (soundness/completeness)
Semantic: ⊨ φ
   ↕ (canonical model / BFMCS)
MCS-theoretic: φ ∈ S for all MCS S
   ↕ (filtration / ultrafilter bijection)
Algebraic: [φ] is top in every ultrafilter of LindenbaumAlg
   ↕ (FMP injection)
Finite model: φ holds in every closure MCS world
```

The critical structural insight is that **both paths share the same MCS layer**. The
`UltrafilterMCS.lean` file establishes the bijection between ultrafilters and MCS. The
filtration construction quotients the same MCS space. The equivalence is not a coincidence
- it reflects that MCS are the canonical "worlds" for propositionally complete systems.

---

## Equivalence Strategy

### Formal Statement of Equivalence

For TM bimodal logic, the following are provably equivalent:

1. **Proof-theoretic**: `Nonempty (DerivationTree [] φ)`
2. **FMP-completeness**: `∀ (S : ClosureMCSBundle φ), φ ∈ S.carrier`
3. **Algebraic satisfiability**: `∀ U : Ultrafilter LindenbaumAlg, toQuot φ ∈ U.carrier`

The equivalence `(1) ↔ (2)` is `fmp_contrapositive` (already proven).

The equivalence `(2) ↔ (3)` follows from the ultrafilter-MCS bijection in `UltrafilterMCS.lean`:
- Every closure MCS projects to an ultrafilter via `mcsToUltrafilter`
- Every ultrafilter corresponds to an MCS via `ultrafilterToSet`
- The bijection preserves formula membership

### Concrete Isomorphism Between Finite Model and Algebraic Witness

The `FilteredWorld phi` quotient type is isomorphic to a subset of ultrafilters of
`LindenbaumAlg` restricted to the subformula closure. Specifically:

```lean
-- FilteredWorld φ ≅ Finset (Ultrafilter (LindenbaumAlg restricted to closure φ))
-- The characteristic set map:
def filteredCharacteristicSet (phi : Formula) (w : FilteredWorld phi) :
    Set (subformulaClosure phi)
-- Is injective (proven in FiniteModel.lean, sorry-free)
theorem filteredCharacteristicSet_injective (phi : Formula) :
    Function.Injective (filteredCharacteristicSet phi)
```

The algebraic witness is an ultrafilter `U` on the full `LindenbaumAlg`. The finite model
witness is a closure MCS bundle (a "local" ultrafilter restricted to the closure). The
restriction map from ultrafilters to closure-ultrafilters shows these are the "same" objects
at different levels of granularity.

### Proof Architecture for Equivalence

To formally state the equivalence in the codebase, one would:

1. **Show filtration quotient factors through ultrafilters**: The characteristic set of a
   filtered world is the same data as the ultrafilter restricted to the closure.

2. **Use `characteristicSet_eq_iff_equiv`** (already proven in `FiniteModel.lean`):
   `characteristicSet φ S = characteristicSet φ T ↔ ClosureMCSEquiv φ S T`
   This shows the characteristic set IS the ultrafilter structure for the closure.

3. **The restriction functor**: The map `fullUltrafilter → closureUltrafilter` via
   intersection with `closureWithNeg φ` produces exactly the filtration equivalence classes.

This equivalence does NOT require new proofs - it is implicit in the existing infrastructure
and can be made explicit with a bridging theorem in a new `FMPAlgebraicEquivalence.lean` file.

---

## Computability Implications

### FMP → Decidability

The FMP approach gives decidability **constructively**: given φ, enumerate all consistent
subsets of `closureWithNeg φ` (finitely many, bounded by `2^|closure φ|`), check each as
a potential closure MCS, and determine if any fails to contain φ.

The existing `Decidability/` module (tableau-based) provides an independent decision procedure.
The FMP provides an **explicit bound on the search space**: models of size ≤ 2^|closure φ|.

```
|subformulaClosure φ| ≤ 2 * |φ|  (linear in formula size)
Model size ≤ 2^(2*|φ|)           (exponential bound)
```

This gives: **TM bimodal logic is EXPTIME-decidable** (or better - filtration is actually
in NP if we guess the finite model nondeterministically, suggesting coNP for validity).

### Algebraic → Structural Completeness

The algebraic path provides **structural completeness**: the logic is characterized
by the variety of Boolean algebras with three interior operators satisfying the TM axiom
equations. This is a universal-algebraic characterization.

The interior operator characterization (`InteriorOperators.lean`, sorry-free) establishes:
- Box, G (all_future), H (all_past) are deflationary (T axiom)
- Box, G, H are monotone (K distribution)
- Box, G, H are idempotent (4 axiom)

### Dual Path Clarifies Computability

The equivalence between FMP and algebraic paths clarifies the computability landscape:

**FMP → Decidability chain**:
```
FMP (finite model) → model checking is decidable (Finite.decidable)
                  → validity is decidable (enumerate finite models)
                  → satisfiability is NP (guess a finite model)
```

**Algebraic → Complexity from variety theory**:
```
TM is a finitely generated variety → equational theory is decidable (Birkhoff)
Interior operator equations → locally finite variety
Locally finite variety → decidable equational theory
```

Both paths confirm decidability. The FMP gives explicit size bounds. The algebraic
approach reveals that decidability stems from the variety being **locally finite** -
every finitely generated subalgebra is finite, which is precisely what filtration proves.

**The deep insight**: Filtration is the constructive witness that the TM variety is
locally finite. Every finitely generated sub-BAO is quotient-isomorphic to a finite
Boolean algebra. This is the computational core of the finite model property.

---

## Evidence/Examples

### Evidence 1: FMP Sorries are Easily Fixable

The 2 sorries in `TruthPreservation.lean` are at lines 263 and 281. The fix mirrors
the `mcs_box_closure` proof at lines 188-203, which is sorry-free:

```lean
-- Already proven for Box (lines 188-203, sorry-free):
theorem mcs_box_closure ... (h_psi_clos : ψ ∈ closureWithNeg phi) : ψ ∈ S.carrier := by
  have h_modal_t_thm : [] ⊢ (ψ.box).imp ψ :=
    DerivationTree.axiom [] _ (Axiom.modal_t ψ)
  ...

-- The SAME pattern works for G (all_future) - the deprecation comment is wrong:
theorem mcs_all_future_closure ... : ψ ∈ S.carrier := by
  -- Axiom.temp_t_future ψ gives: [] ⊢ (ψ.all_future).imp ψ  (VALID in the semantics)
  have h_temp_t_thm : [] ⊢ (ψ.all_future).imp ψ :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future ψ)
  -- Then proceed identically to mcs_box_closure
  ...
```

The axiomatic structure confirms this: `Soundness.lean` proves `temp_t_future_valid`
(lines 244-254) using `le_rfl` (reflexivity), and the axiom system includes
`Axiom.temp_t_future` and `Axiom.temp_t_past` as axiom constructors handled by soundness
at lines 399-400.

### Evidence 2: The Semantic Semantics IS Reflexive

From `Soundness.lean` lines 247-254:
```lean
theorem temp_t_future_valid (φ : Formula) : ⊨ (φ.all_future.imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_G
  -- h_G : ∀ s ≥ t, φ(s)   -- "≥" means REFLEXIVE (includes t itself)
  exact h_G t le_rfl      -- This uses t ≥ t (reflexivity)
```

The semantics uses `≤` (reflexive), not `<` (strict). The deprecation comment in
TruthPreservation.lean claiming "strict temporal semantics" contradicts the actual
semantics definition.

### Evidence 3: FMP fmp_contrapositive is Sorry-Free

The key FMP completeness theorem `fmp_contrapositive` (lines 206-211 of `FMP.lean`)
is completely sorry-free:

```lean
theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : ∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_provable
  obtain ⟨S, h_not_in, _⟩ := mcs_finite_model_property phi h_not_provable
  exact h_not_in (h_all_mcs S)
```

This proves: "if φ is in every closure MCS, then φ is provable." Combined with soundness,
this gives completeness relative to MCS-truth. The only gap to full semantic completeness
is the filtration lemma (truth preservation), and specifically the 2 temporal sorry cases.

### Evidence 4: The Algebraic Path Has the Same Underlying MCS Core

From `ParametricRepresentation.lean` lines 44-55:
```
The representation theorem is CONDITIONAL on having a `construct_bfmcs` function that:
  - Takes any MCS M₀
  - Returns a temporally coherent BFMCS containing M₀
```

From `FMP.lean` `exists_mcs_with_negation` (lines 57-134):
```
The FMP proof constructs a closure MCS containing ¬φ
  - No temporal coherence required (closure MCS is purely local)
  - The temporal content comes from the filtration lemma
```

Both approaches face the **same underlying problem**: establishing that temporal
operators (G, H) are truth-preserving in the model construction. The algebraic path
requires temporal coherence in BFMCS. The FMP path requires temporal truth preservation
in filtration. These are the same mathematical content at different abstraction levels.

---

## Recommended Integration Path

### Phase 1: Fix the 2 FMP Sorries (Estimated: 1-2 hours)

**Action**: Repair `mcs_all_future_closure` and `mcs_all_past_closure` in
`TruthPreservation.lean`.

**Approach**: Apply the same pattern as `mcs_box_closure` using `Axiom.temp_t_future`
and `Axiom.temp_t_past`. The deprecation comments are factually incorrect about the
semantics being strict - the semantics is reflexive, so the T axiom applies.

**Expected result**: 0 sorries in the entire FMP infrastructure.

**File**: `/Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean`
**Lines**: 256-263 and 268-281 (the two sorry blocks)

### Phase 2: Prove Semantic Truth Preservation (Estimated: 2-4 hours)

The current `fmp_contrapositive` connects provability to MCS membership. To connect
to semantic validity, we need:

```lean
-- Missing bridge theorem:
theorem fmp_semantic_completeness (phi : Formula)
    (h_valid : valid phi) : Nonempty (DerivationTree [] phi)
```

This requires showing that `valid phi` implies `∀ S : ClosureMCSBundle phi, phi ∈ S.carrier`.
The proof would use:
1. Soundness: provable formulas are valid
2. Contrapositive: if not provable, FMP gives closure MCS countermodel
3. The filtration lemma (Phase 1 fix) connects MCS truth to semantic truth

**Key theorem needed**:
```lean
theorem mcs_truth_implies_semantic_truth : (phi ∈ S.carrier) → truth_at ...
-- This is filtration_lemma_membership (already proven, lines 375-379)
-- Connects: phi ∈ S.carrier ↔ filteredMcsTruth phi ... (toFilteredWorld phi S)
```

The full bridge requires constructing a semantic model from the filtered frame and
showing that truth in the filtered model (using filteredMcsTruth as valuation) aligns
with the standard truth evaluation. This is the filtration theorem from modal logic.

### Phase 3: Explicit Equivalence Theorem (Estimated: 2-3 hours)

Add a bridging file `FMPAlgebraicEquivalence.lean` that formally states and proves
the equivalence between FMP and algebraic completeness:

```lean
-- In a new file: Metalogic/Decidability/FMP/FMPAlgebraicEquivalence.lean
theorem fmp_algebraic_equivalence (phi : Formula) :
    (∀ S : ClosureMCSBundle phi, phi ∈ S.carrier) ↔
    (∀ U : Ultrafilter LindenbaumAlg, toQuot phi ∈ U.carrier) := by
  -- Forward: ClosureMCS world → ultrafilter via mcsToUltrafilter
  -- Backward: ultrafilter → closure MCS via restriction to closureWithNeg
  ...
```

This equivalence is mathematically straightforward given the ultrafilter-MCS bijection
in `UltrafilterMCS.lean`. It makes explicit that the FMP finite model and the algebraic
ultrafilter witness are two presentations of the same mathematical object.

### Phase 4: Computability Theorem (Estimated: 1-2 hours)

Once the FMP is fully proven, add the decidability consequence:

```lean
-- The FMP gives a decision procedure:
theorem tm_decidable (phi : Formula) : Decidable (Nonempty (DerivationTree [] phi)) := by
  -- Check whether all closure MCS contain phi
  -- This is decidable because:
  -- 1. closureWithNeg phi is finite
  -- 2. The set of closure-restricted MCS is finite (subsets of closureWithNeg)
  -- 3. Checking consistency is decidable (tableau)
  ...
```

This would complement the existing tableau-based decidability in `Decidability/`.

---

## Confidence Level

**High** for the following claims:
- The 2 FMP sorries are fixable by applying `Axiom.temp_t_future`/`Axiom.temp_t_past`
  (verified by matching the axiom system structure and semantics definition)
- The FMP and algebraic paths are equivalent at the MCS level
  (confirmed by the ultrafilter-MCS bijection in `UltrafilterMCS.lean`)
- The underlying blocker for both paths is the same temporal coherence problem
  (confirmed by comparing the `construct_bfmcs` gap and the filtration sorry pattern)

**Medium** for:
- Whether Phase 2 (semantic completeness) can proceed without temporal coherence work
  (depends on whether filtration lemma is sufficient for the semantic bridge)
- The precise cost estimate for Phase 3 equivalence theorem
  (depends on how much type coercion work is needed between MCS and ultrafilter types)

**Lower** for:
- Whether the computability theorem (Phase 4) can avoid axiom introduction
  (decidability of consistency checking may need separate verification)

---

## Summary

The FMP infrastructure is in excellent shape. The critical finding is that the 2 sorries
in `TruthPreservation.lean` are **not fundamental blockers** - they are the result of
an incorrect deprecation comment claiming the semantics is strict when it is actually
reflexive. The fix is a 2-10 line proof following the exact same pattern as the already-proven
`mcs_box_closure`.

The FMP and algebraic approaches are equivalent through the ultrafilter-MCS bijection.
Rather than competing approaches, they are complementary: the FMP gives computational
decidability bounds, the algebraic approach gives structural variety-theoretic characterization.
The `fmp_contrapositive` theorem in `FMP.lean` is already the key completeness result
(sorry-free), and repairing the filtration lemma would complete the entire FMP proof chain.

For the computability story: the FMP proves TM is decidable by showing the model checking
problem for any formula is finite (bounded by `2^|closure φ|`). The algebraic approach
proves it is decidable by showing the equational theory of the TM variety is decidable
(the variety is locally finite, witnessed by filtration). Both paths confirm decidability;
their equivalence shows these are two aspects of the same mathematical fact.
