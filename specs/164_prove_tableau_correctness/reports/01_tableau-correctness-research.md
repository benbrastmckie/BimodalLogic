# Research Report: Tableau Correctness Theorems for Decision Procedure

**Task**: 164 -- Prove tableau correctness theorem for decision procedure
**Session**: sess_1780355308_a08e2f_164
**Date**: 2026-06-01

## Executive Summary

The decision procedure in `DecisionProcedure.lean` implements a real tableau (proof search + branch expansion + countermodel extraction) but the correctness theorem in `Correctness.lean` is trivially `Classical.em`. Three theorems are needed to connect the tableau output to semantic validity: `decide_sound`, `decide_complete`, and `decide_terminates`. This report catalogs the current state, identifies all sorry sites, and recommends an implementation approach.

## 1. Current Codebase State

### 1.1 Decision Procedure (`DecisionProcedure.lean`)

The `decide` function has type:

```lean
def decide (phi : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    (fc : FrameClass := .Base) : DecisionResult phi
```

where `DecisionResult` is:

```lean
inductive DecisionResult (phi : Formula) : Type where
  | valid (proof : DerivationTree FrameClass.Base [] phi)
  | invalid (counter : SimpleCountermodel)
  | timeout
```

Key observation: when `decide` returns `.valid proof`, the `proof` is already a `DerivationTree FrameClass.Base [] phi` -- a syntactic proof object. This is the critical enabler for `decide_sound`.

The procedure:
1. Fast path: tries `tryAxiomProof phi` (direct axiom pattern match)
2. Proof search: `bounded_search_with_proof [] phi searchDepth`
3. Tableau: `buildTableau phi tableauFuel fc`, then either extract proof (closed) or countermodel (open)

### 1.2 Correctness (`Correctness.lean`)

Current state:
- `validity_decidable`: `(valid phi) or (not (valid phi))` -- proved by `Classical.em`, says nothing about the tableau
- `validity_has_decision_procedure`: exists a Boolean decision, also via `by_cases`
- `decide_result_exclusive`: the three result constructors are mutually exclusive (sorry-free)
- `fmp_completeness`: if phi is in all closure MCS, then phi is provable (via `FMP.fmp_contrapositive`, sorry-free)
- `fmp_incompleteness_witness`: if phi is not provable, there exists a finite countermodel (sorry-free)
- `countermodel_size_bound`: the filtered model is finite (sorry-free)

Missing: No theorem connects `decide`'s output to semantic validity.

### 1.3 Soundness (`Soundness.lean`)

The soundness module is **sorry-free** with three theorems:
- `soundness`: `DerivationTree .Base Gamma phi -> truth_at M Omega tau t phi` (for all models)
- `soundness_dense`: Same for `.Dense` derivations on dense frames
- `soundness_discrete`: Same for `.Discrete` derivations on discrete frames

These are the key building blocks for `decide_sound`.

### 1.4 Countermodel Extraction (`CountermodelExtraction.lean`)

This module defines:
- `SimpleCountermodel`: just tracks true/false atoms
- `SemanticCountermodel`: full model with worlds, times, temporal ordering, and `branchTruth` evaluation
- `branchTruthLemma`: the key theorem that every signed formula in a saturated open branch is satisfied by the extracted countermodel

**Sorry sites (13 actual sorries in proof obligations)**:

| Theorem | Location | Nature | Difficulty |
|---------|----------|--------|------------|
| `sat_imp_neg` | L440 | Saturation invariant: F(A->B) implies T(A), F(B) in branch | Medium -- requires rule engine unfolding |
| `sat_box_pos` | L461 | Saturation invariant: T(box A) propagates to all worlds | Medium -- persistent rule analysis |
| `sat_box_neg` | L478 | Saturation invariant: F(box A) introduces witness world | Medium -- similar to sat_imp_neg |
| `sat_untl_pos` | L501 | Until positive saturation: T(U(e,g)) branching witness | Hard -- branching provenance tracking |
| `sat_snce_pos` | L514 | Mirror of sat_untl_pos for Since | Hard -- same difficulty |
| `sat_untl_neg` | L536 | Until negative saturation: Reynolds co-decomposition | Hard -- persistent rule + filterMap |
| `sat_snce_neg` | L550 | Mirror of sat_untl_neg for Since | Hard -- same difficulty |
| `truthLemma_pos` (imp) | L594 | T(A->B) case of truth lemma | Medium -- depends on sat_imp_neg variant |
| `truthLemma_pos` (untl) | L610 | T(U(e,g)) case of truth lemma | Hard -- depends on sat_untl_pos |
| `truthLemma_pos` (snce) | L614 | T(S(e,g)) case of truth lemma | Hard -- mirror of untl |
| `truthLemma_neg` (untl) | L660 | F(U(e,g)) case of truth lemma | Hard -- depends on sat_untl_neg |
| `truthLemma_neg` (snce) | L664 | F(S(e,g)) case of truth lemma | Hard -- mirror of untl |

Note: The atom, bot, box cases of the truth lemma are **complete** (lines 577-604 for pos, 629-655 for neg). Only imp and temporal cases carry sorries.

### 1.5 Saturation/Blocking (`Saturation.lean`)

Three blocking-related theorems carry sorries:

| Theorem | Location | Nature |
|---------|----------|--------|
| `subformula_property` | L639 | All expanded formulas are subformulas of initial formula |
| `blocking_terminates` | L653 | Subset blocking ensures termination |
| `blocking_sound` | L670 | Blocking doesn't prematurely close satisfiable branches |

### 1.6 FMP (`FMP/FMP.lean`)

The FMP module is **sorry-free**. Key results:
- `exists_mcs_with_negation`: not-provable implies exists MCS with negation
- `filtered_model_falsifies`: not-provable implies exists MCS falsifying phi
- `mcs_finite_model_property`: combined with finiteness
- `fmp_contrapositive`: all-MCS-membership implies provable

### 1.7 Proof Extraction (`ProofExtraction.lean`)

The proof extraction module is **sorry-free**. It uses a multi-strategy pipeline:
1. Direct axiom match (tryAxiomProof)
2. Derived theorem match (matchDerived)
3. Closure-based extraction
4. Compositional proof builder
5. Enhanced proof search

Returns `ProofExtractionResult` which is either `.success proof` or `.incomplete reason`.

## 2. The Three Target Theorems

### 2.1 decide_sound

**Statement**: If `decide phi = .valid proof` then `valid phi`.

**Approach**: This is essentially immediate from existing infrastructure.

When `decide` returns `.valid proof`, the `proof` has type `DerivationTree FrameClass.Base [] phi`. The existing `soundness` theorem gives:

```lean
theorem soundness (Gamma : Context) (phi : Formula)
    (d : DerivationTree FrameClass.Base Gamma phi) ... : truth_at M Omega tau t phi
```

So `decide_sound` is:

```lean
theorem decide_sound (phi : Formula) (searchDepth tableauFuel : Nat) (fc : FrameClass)
    (proof : DerivationTree FrameClass.Base [] phi)
    (h : decide phi searchDepth tableauFuel fc = .valid proof) :
    valid phi := by
  intro D _ _ _ _ F M Omega h_sc tau h_mem t
  exact soundness [] phi proof D F M Omega h_sc tau h_mem t (by simp)
```

Note: The proof object is embedded in the `DecisionResult.valid` constructor. We just need to extract it and apply `soundness`. The key insight is that `decide` already constructs a genuine `DerivationTree`, not a placeholder.

**Difficulty**: Easy. No new sorry sites needed. Depends only on the existing sorry-free `soundness` theorem.

**Estimated effort**: 1 phase, approximately 20 lines.

### 2.2 decide_complete (countermodel correctness)

**Statement**: If `decide phi = .invalid counter` then `not (valid phi)`.

**Approach**: This requires showing the countermodel genuinely refutes phi. The current countermodel extraction produces a `SimpleCountermodel` (just atom lists), not a full semantic model. There are two paths:

**Path A (via SemanticCountermodel)**: The `SemanticCountermodel` + `branchTruthLemma` would establish that every signed formula in the saturated open branch is satisfied. Since the initial branch contains `F(phi)` at the initial label, the truth lemma would give `not (branchTruth cm w0 t0 phi)`, showing phi fails in the branch model. However, the branchTruthLemma has **12 sorry sites** (temporal cases).

**Path B (via FMP contrapositive)**: We could use a different argument. If `decide phi = .invalid counter`, that means `buildTableau phi fuel = some (.hasOpen ...)`. We need to show that the existence of an open branch implies phi is not valid. This requires:
1. Showing that if the tableau has an open branch, then phi is not provable (completeness of tableau)
2. Using `fmp_contrapositive` to link provability to MCS membership
3. Bridging from MCS membership to semantic validity

But this is essentially proving full tableau completeness, which is a substantial undertaking.

**Path C (Classical shortcut)**: Use the fact that `decide` never returns `.invalid` for a provable formula (correctness of the tableau closure detection). If all branches closed but proof extraction failed, `decide` returns `.timeout`, not `.invalid`. So `.invalid` means the tableau genuinely found an open branch. If the formula were valid, it would be provable (by completeness -- which we have via FMP), and if provable, the tableau would close all branches (by completeness of the tableau w.r.t. the proof system). But this circular argument requires exactly the "tableau completeness" we're trying to prove.

**Recommended approach**: Path A is most direct but requires resolving the 12 sorry sites in `CountermodelExtraction.lean`. The sorry sites break into two categories:

1. **Saturation invariants** (7 sorries in sat_imp_neg, sat_box_pos, sat_box_neg, sat_untl_pos, sat_snce_pos, sat_untl_neg, sat_snce_neg): These require unfolding through `findApplicableRule`, `isApplicable`, `applyRule` to show that certain formulas cannot exist in saturated branches or that their consequents must be present. The proofs are "feasible but tedious" per the inline comments.

2. **Truth lemma cases** (5 sorries in truthLemma_pos/neg for imp, untl, snce): These depend on the saturation invariants above.

The gap between `branchTruth` (the countermodel's truth definition) and the semantic `truth_at` (the real semantics) also needs bridging. The countermodel operates on finite `WorldIndex`/`TimeIndex` nat indices, not on the full `TaskFrame`/`WorldHistory` infrastructure. A bridging lemma is needed to embed the branch model as a semantic model.

**Difficulty**: Hard. Requires resolving 12 sorry sites plus building the semantic bridge.

**Estimated effort**: 3-4 phases.

### 2.3 decide_terminates

**Statement**: For sufficient fuel, the procedure terminates (does not return `.timeout`).

**Approach**: The `soundFuel` function already provides a bound based on the subformula closure:

```lean
def soundFuel (phi : Formula) : Nat :=
  let n := (subformulaClosure phi).card
  min (n * (2 ^ n)) 100000
```

And `decideAuto` uses this bound. The termination argument requires:
1. `subformula_property` (sorry in Saturation.lean): all expanded formulas are subformulas
2. `blocking_terminates` (sorry in Saturation.lean): subset blocking ensures termination
3. Pigeonhole principle: at most 2^(2n) distinct time types before blocking fires

**Difficulty**: Medium-Hard. The `subformula_property` is straightforward but requires tracking formulas through all rule applications. `blocking_terminates` requires the pigeonhole argument over time types.

**Estimated effort**: 2 phases.

## 3. Sorry Site Dependency Graph

```
decide_sound
  |-- soundness (DONE, sorry-free)
  \-- (no additional sorry sites needed)

decide_complete
  |-- branchTruthLemma
  |   |-- truthLemma_pos (imp case: sorry)
  |   |   \-- sat_imp_neg (sorry) -- or vacuity argument
  |   |-- truthLemma_pos (untl case: sorry)
  |   |   \-- sat_untl_pos (sorry)
  |   |-- truthLemma_pos (snce case: sorry)
  |   |   \-- sat_snce_pos (sorry)
  |   |-- truthLemma_neg (untl case: sorry)
  |   |   \-- sat_untl_neg (sorry)
  |   |-- truthLemma_neg (snce case: sorry)
  |   |   \-- sat_snce_neg (sorry)
  |   \-- truthLemma_neg (imp case: DONE via sat_imp_neg)
  |-- sat_box_pos (sorry) -- used in truthLemma_pos box case (DONE)
  |-- sat_box_neg (sorry) -- used in truthLemma_neg box case (DONE)
  \-- semantic bridge: branchTruth -> not (valid phi) [NEW, needed]

decide_terminates
  |-- subformula_property (sorry in Saturation.lean)
  |-- blocking_terminates (sorry in Saturation.lean)
  \-- blocking_sound (sorry in Saturation.lean)
```

## 4. Key Type Relationships

### 4.1 DecisionResult vs Semantic Validity

```
DecisionResult phi
  .valid proof : DerivationTree .Base [] phi  --(soundness)--> valid phi
  .invalid cm  : SimpleCountermodel          --(branchTruthLemma)--> not (valid phi)
  .timeout     : (no information)
```

### 4.2 Two Countermodel Layers

- **Layer 0** (`SimpleCountermodel`): Just atom true/false lists. Used in `decide` return value. No semantic guarantees.
- **Layer 1** (`SemanticCountermodel`): Full model with worlds, times, ordering, valuation. Has `branchTruth` and `branchTruthLemma`. Not directly used by `decide`.

For `decide_complete`, we need to bridge from the `SimpleCountermodel` (what `decide` returns) to the `SemanticCountermodel` (where the truth lemma operates), or alternatively, restructure `decide` to return the richer type.

### 4.3 Semantic Model Gap

The `branchTruth` function defines truth on `SemanticCountermodel` (with `WorldIndex = Nat`, `TimeIndex = Nat`). The real semantic `truth_at` operates on `TaskModel F` with `WorldHistory F` and time type `D`. To prove `not (valid phi)`, we need to instantiate the semantic validity quantifier with a specific `D`, `F`, `M`, `Omega`, `tau`, `t` -- concretely, with a model constructed from the branch model.

This instantiation requires:
1. Choosing `D = Int` (or another concrete ordered abelian group)
2. Building a `TaskFrame D` from the branch's world/time structure
3. Building a `TaskModel F` (valuation) from `buildAtomValuation`
4. Choosing `Omega` and showing `ShiftClosed Omega`
5. Mapping `WorldIndex`/`TimeIndex` to actual world histories and times

This is the most technically demanding part of `decide_complete`.

## 5. Recommended Implementation Approach

### Phase 1: decide_sound (Easy)

**Goal**: Prove `decide_sound`.
**Approach**: Extract proof from `DecisionResult.valid`, apply `soundness`.
**Dependencies**: None (all prerequisites sorry-free).
**Estimated lines**: ~30.

### Phase 2: Saturation Invariants -- Propositional and Modal (Medium)

**Goal**: Prove `sat_imp_neg`, `sat_box_pos`, `sat_box_neg` (resolve 3 of 7 saturation sorry sites).
**Approach**: Each requires unfolding `findApplicableRule`/`applyRule` to show specific rules always produce non-notApplicable results for their respective formula patterns. The inline comments provide detailed proof strategies.
**Key technique**: The proofs are "vacuity" proofs -- show that the formula pattern in question cannot exist in a saturated branch because the corresponding rule always applies.
**Estimated lines**: ~150-200.

### Phase 3: Saturation Invariants -- Temporal (Hard)

**Goal**: Prove `sat_untl_pos`, `sat_snce_pos`, `sat_untl_neg`, `sat_snce_neg` (resolve remaining 4 saturation sorry sites).
**Approach**: Temporal rules are more complex due to branching (untlPos/sncePos) and persistence (untlNeg/snceNeg). The branching cases require tracking which child branch was taken during expansion.
**Key challenge**: The branching provenance problem -- in a saturated branch that resulted from a split, how to determine which branch alternative was taken.
**Estimated lines**: ~200-300.

### Phase 4: Truth Lemma Completion (Medium)

**Goal**: Complete `truthLemma_pos` (imp, untl, snce cases) and `truthLemma_neg` (untl, snce cases).
**Approach**: These follow directly from the saturation invariants proved in Phases 2-3, combined with the induction hypothesis.
**Dependencies**: Phases 2-3 must be complete.
**Estimated lines**: ~100-150.

### Phase 5: Semantic Bridge and decide_complete (Hard)

**Goal**: Prove `decide_complete`.
**Approach**:
1. Define a concrete `TaskFrame Int` and `TaskModel` from `SemanticCountermodel`
2. Show `branchTruth` agrees with `truth_at` on this model
3. Use `branchTruthLemma` to show F(phi) in the initial branch is satisfied
4. Conclude `not (valid phi)` by exhibiting the countermodel

**Alternative**: Restructure to avoid the full semantic bridge. Instead:
1. Prove that if phi is valid, then phi is provable (from FMP, already done via `fmp_contrapositive`)
2. Prove that if phi is provable, the tableau closes all branches (tableau completeness w.r.t. proof system)
3. Contrapositive: open branch implies not provable implies not valid

This alternative avoids building the semantic model from scratch but requires proving tableau completeness w.r.t. the proof system (that derivable formulas always have closed tableaux), which is itself non-trivial.

**Dependencies**: Phase 4.
**Estimated lines**: ~200-400.

### Phase 6: decide_terminates (Medium-Hard, Can Be Deferred)

**Goal**: Prove `decide_terminates`.
**Approach**: Prove `subformula_property`, then `blocking_terminates` via pigeonhole.
**Note**: This can be done independently of Phases 2-5.
**Estimated lines**: ~200-300.

## 6. Feasibility Assessment

| Theorem | Feasibility | Blockers | Sorry Sites to Resolve |
|---------|-------------|----------|----------------------|
| `decide_sound` | **High** | None | 0 |
| `decide_complete` | **Medium** | Saturation invariants (12 sorries), semantic bridge | 12 + new code |
| `decide_terminates` | **Medium** | Subformula property, pigeonhole over time types | 3 |

### Recommended ordering:
1. `decide_sound` first (immediate win, no blockers)
2. Saturation invariants (Phases 2-3) -- enables both `decide_complete` and removes sorry debt
3. Truth lemma completion (Phase 4) -- depends on saturation invariants
4. `decide_complete` (Phase 5) -- depends on truth lemma
5. `decide_terminates` (Phase 6) -- independent, can be done in parallel with 2-5

### Risk factors:
- The "vacuity" proof strategy for saturation invariants (sat_imp_neg etc.) requires matching against the `applyRule` function's implementation details. If the rule engine structure changes, these proofs break.
- The semantic bridge for `decide_complete` is architecturally complex due to the type-level gap between `WorldIndex`/`TimeIndex` (Nat) and the polymorphic `D`/`WorldHistory F` in the semantics.
- The `min bound 100000` cap in `soundFuel` means `decide_terminates` would need to handle the case where the cap is reached.

## 7. Alternative Architecture (Recommendation)

Instead of the full semantic bridge approach for `decide_complete`, consider adding a theorem:

```lean
theorem decide_not_invalid_if_provable (phi : Formula) (d : DerivationTree .Base [] phi) :
    forall sd tf fc, decide phi sd tf fc != .invalid _ := sorry
```

This states that provable formulas never produce `.invalid` results. Combined with soundness:

```lean
theorem decide_complete' (phi : Formula) (sd tf : Nat) (fc : FrameClass) (cm : SimpleCountermodel)
    (h : decide phi sd tf fc = .invalid cm) : not (valid phi) := by
  intro h_valid
  -- valid -> provable (by completeness, via FMP)
  -- provable -> not invalid (by decide_not_invalid_if_provable)
  -- contradiction with h
  sorry
```

But this requires both completeness (valid -> provable) and "tableau refutation completeness" (provable -> not invalid), which is still non-trivial.

The most pragmatic path is to focus on `decide_sound` (Phase 1) and the saturation invariants (Phases 2-3), leaving `decide_complete` and `decide_terminates` as follow-up tasks.
