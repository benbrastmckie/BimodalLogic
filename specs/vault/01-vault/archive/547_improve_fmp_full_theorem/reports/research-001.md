# Research Report: Task #547

**Task**: 547 - Improve FMP Full Theorem
**Started**: 2026-01-17T17:27:10Z
**Completed**: 2026-01-17T17:55:00Z
**Effort**: 2-3 hours estimated
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: FiniteCanonicalModel.lean, FiniteModelProperty.lean, Completeness.lean, Validity.lean, Mathlib
**Artifacts**: specs/547_improve_fmp_full_theorem/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The current FMP implementation has a proven core (`semantic_weak_completeness`) but gaps in the full theorem statement
- The key gap is bridging `formula_satisfiable` (existential over ALL models) to the finite canonical model
- Two main approaches: (1) direct contrapositive via semantic completeness, (2) classical filtration
- FiniteCanonicalModel.lean has build errors that must be resolved before proving FMP
- Recommended approach: use contrapositive of `semantic_weak_completeness` to establish FMP

## Context & Scope

### Research Focus

Task 547 addresses proving the **full Finite Model Property (FMP)** theorem for TM bimodal logic:

> **Full FMP**: If a formula phi is satisfiable in ANY model, then it is satisfiable in a FINITE model.

The current implementation has:
1. **Proven**: `semantic_weak_completeness` - core completeness via contrapositive
2. **Placeholder**: `finite_model_property_v2` - FMP theorem with sorry
3. **Broken**: Several bridge lemmas have compilation errors

### Current State Analysis

#### 1. Semantic Completeness (PROVEN)

Location: `FiniteCanonicalModel.lean`, lines 3317-3386

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (origin) phi) ->
    deriv phi
```

**Proof Strategy**:
1. Contrapositive: assume phi not derivable
2. Then {neg phi} is consistent
3. By Lindenbaum, extend to maximal consistent set M
4. Project M to closure MCS S
5. Build FiniteWorldState from S where phi is false
6. Build FiniteHistory from that state
7. Construct SemanticWorldState that falsifies phi
8. Contradiction with hypothesis

**Status**: PROVEN (no sorry gaps in the core proof)

#### 2. FMP Statement (PLACEHOLDER)

Location: `FiniteCanonicalModel.lean`, lines 4128-4143

```lean
theorem finite_model_property_v2 (phi : Formula) :
    formula_satisfiable phi ->
    exists (F : FiniteTaskFrame Int) (M : TaskModel F.toTaskFrame)
      (tau : WorldHistory F.toTaskFrame) (t : Int),
      truth_at M tau t phi := by
  sorry  -- Proof uses contrapositive of semantic_weak_completeness
```

**The Gap**: The theorem statement uses `formula_satisfiable` which quantifies over ALL temporal types D, but the proof needs to produce a witness in a specific finite model.

#### 3. Build Errors in FiniteCanonicalModel.lean

Current errors (22+ issues):
- Line 1821: Fields missing: `backward_rel`
- Line 3025: Unknown constant `SetConsistent.exists_false_derivation`
- Line 3467: Unsolved goals in `finiteHistoryToWorldHistory.respects_task`
- Line 3568: Type mismatch in `semantic_world_state_has_world_history`
- Multiple omega and simp failures in time arithmetic proofs

These errors prevent the file from compiling, blocking FMP implementation.

## Findings

### Relevant Theorems from Mathlib

#### Decidability from Finite Types
```lean
-- Fintype.decidableForallFintype
instance {alpha} {p : alpha -> Prop} [DecidablePred p] [Fintype alpha] : Decidable (forall a, p a)

-- Fintype.decidableExistsFintype
instance {alpha} {p : alpha -> Prop} [DecidablePred p] [Fintype alpha] : Decidable (exists a, p a)
```

These enable: If `SemanticWorldState phi` is Fintype and truth is decidable, satisfiability is decidable.

#### Quotient Finiteness
```lean
-- Quotient.finite
instance {alpha : Sort} [Finite alpha] (s : Setoid alpha) : Finite (Quotient s)

-- Quot.finite
instance {alpha : Sort} [Finite alpha] (r : alpha -> alpha -> Prop) : Finite (Quot r)
```

Key insight: `SemanticWorldState phi` is defined as a `Quotient` of `HistoryTimePair phi`, so if the underlying type is finite, the quotient is finite.

#### First-Order Compactness Pattern
```lean
-- FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable
theorem {T : L.Theory} : T.IsSatisfiable <-> T.IsFinitelySatisfiable
```

Pattern for FMP: reduce infinite satisfiability to finite model checking.

### Key Local Declarations

| Name | Location | Status |
|------|----------|--------|
| `formula_satisfiable` | Validity.lean:126 | Defined (exists over all D) |
| `SemanticWorldState` | FiniteCanonicalModel.lean | Defined (quotient type) |
| `SemanticCanonicalFrame` | FiniteCanonicalModel.lean:2837 | Defined |
| `SemanticCanonicalModel` | FiniteCanonicalModel.lean:2873 | Defined |
| `semantic_weak_completeness` | FiniteCanonicalModel.lean:3317 | PROVEN |
| `finite_model_property_v2` | FiniteCanonicalModel.lean:4128 | PLACEHOLDER |
| `finiteHistoryToWorldHistory` | FiniteCanonicalModel.lean:3451 | HAS ERRORS |

### Proof Strategies

#### Strategy 1: Direct Contrapositive (Recommended)

Use the contrapositive of `semantic_weak_completeness`:

1. **Negation of FMP antecedent**: If phi is satisfiable in some model, then phi is not valid's negation
2. **Contrapositive chain**:
   - `formula_satisfiable phi` implies `neg phi` not valid
   - By contrapositive of soundness, `neg phi` not derivable
   - So `phi` is not refutable (consistent)
   - By `semantic_weak_completeness` contrapositive, there exists a `SemanticWorldState` where `phi` is true
   - This `SemanticWorldState` lives in the finite `SemanticCanonicalModel`

**Key lemma needed**:
```lean
theorem satisfiable_implies_not_refutable (phi : Formula) :
    formula_satisfiable phi -> not (Nonempty (deriv (neg phi)))
```

This follows from soundness: if we could derive `neg phi`, then `neg phi` would be valid, but `formula_satisfiable phi` means `neg phi` is not valid.

#### Strategy 2: Explicit Filtration

The classical modal logic approach:
1. Start with arbitrary satisfying model M, world w
2. Define equivalence relation on worlds: `w ~ v` iff same truth values on subformulas
3. Quotient M by ~ to get finite model M'
4. Prove filtration preserves truth (truth lemma for filtration)

**Challenges**:
- Requires proving `filtration_preserves_truth` (currently has sorry in FiniteModelProperty.lean)
- More complex than contrapositive approach
- Already sketched but not completed in codebase

#### Strategy 3: Direct Model Construction

Build the finite model directly from the satisfying assignment:
1. Extract truth values for all subformulas at the satisfying point
2. Construct `FiniteWorldState` from these values
3. Build `FiniteHistory` containing this state
4. Show original satisfaction implies satisfaction in finite model

**Challenges**:
- Need to handle temporal operators (require extending to full history)
- More complex case analysis

### Type Architecture Analysis

The current type hierarchy:

```
formula_satisfiable phi
  = exists D [instances] F M tau t, truth_at M tau t phi

SemanticWorldState phi
  = Quotient (HistoryTimePair phi) (same equivalence)

HistoryTimePair phi
  = { h : FiniteHistory phi } x FiniteTime (temporalBound phi)

FiniteHistory phi
  = { states : FiniteTime k -> FiniteWorldState phi
    , forward_rel : ...
    , backward_rel : ... }

FiniteWorldState phi
  = { assignment : closure phi -> Bool
    , locally_consistent : ... }
```

The gap: `formula_satisfiable` uses arbitrary type D, but `SemanticWorldState` uses `Int` (via `SemanticCanonicalFrame phi`).

### Bridge Requirements

To prove FMP, we need to connect:

1. **Arbitrary D to Int**: Show that if phi is satisfiable in some D-model, it's satisfiable in the Int-model (SemanticCanonicalModel)
2. **truth_at to semantic_truth_at_v2**: Bridge the general truth definition to the semantic approach

The contrapositive bypasses this: we prove that if phi is NOT satisfiable in SemanticCanonicalModel, then neg phi is derivable, hence valid, hence phi is unsatisfiable everywhere.

## Decisions

1. **Fix build errors first**: The FiniteCanonicalModel.lean file has critical errors preventing any further work

2. **Use contrapositive approach**: The `semantic_weak_completeness` is proven; leverage it rather than starting fresh

3. **Keep Int as temporal type**: The SemanticCanonicalFrame uses Int, which is the natural choice for finite canonical models

4. **Defer Fintype instance**: Use `Classical.dec` for decidability initially; prove Fintype later

## Recommendations

### Phase 1: Fix Build Errors

1. **Fix FiniteHistory.time_shift** (line ~1821): Add missing `backward_rel` field
2. **Fix SetConsistent reference** (lines 3025, 3081): Add `exists_false_derivation` lemma or use alternative
3. **Fix finiteHistoryToWorldHistory** (line 3467-3548): Repair time arithmetic proofs
4. **Fix semantic_world_state_has_world_history** (line 3556-3577): Repair type mismatches

### Phase 2: Prove Key Bridge Lemmas

```lean
-- Bridge: satisfiability implies non-refutability
theorem satisfiable_implies_not_refutable (phi : Formula) :
    formula_satisfiable phi -> not (Nonempty (deriv (neg phi)))

-- Bridge: SemanticCanonicalModel witness implies formula_satisfiable
theorem semantic_satisfiable_implies_formula_satisfiable (phi : Formula) :
    (exists w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi) ->
    formula_satisfiable phi
```

### Phase 3: Prove FMP

```lean
theorem finite_model_property (phi : Formula) :
    formula_satisfiable phi ->
    exists (F : FiniteTaskFrame Int) (M : TaskModel F.toTaskFrame)
      (tau : WorldHistory F.toTaskFrame) (t : Int),
      truth_at M tau t phi := by
  intro h_sat
  -- By soundness, if phi satisfiable then neg phi not valid
  have h_not_valid_neg : not (valid (neg phi)) := by
    intro h_val_neg
    obtain (D, _, _, _, F, M, tau, t, h_true) := h_sat
    have h_neg_true := h_val_neg D F M tau t
    -- h_true : truth_at M tau t phi
    -- h_neg_true : truth_at M tau t (neg phi)
    -- Contradiction since neg phi = phi.imp bot
    sorry -- truth_at_neg contradiction
  -- By contrapositive of completeness, neg phi not derivable
  have h_not_deriv_neg : not (Nonempty (deriv (neg phi))) := by
    intro (d)
    have := Soundness.soundness [] (neg phi) d
    exact h_not_valid_neg (by intro D _ _ _ F M tau t; exact this D F M tau t (fun _ h => absurd h List.not_mem_nil))
  -- So phi is consistent (neg neg phi |- phi)
  -- By semantic_weak_completeness, there exists SemanticWorldState where phi is true
  sorry -- Connect to finite model
```

### Phase 4: Prove Decidability

```lean
theorem satisfiability_decidable (phi : Formula) : Decidable (formula_satisfiable phi) := by
  -- SemanticWorldState phi is finite
  haveI : Fintype (SemanticWorldState phi) := sorry
  -- Truth at each world state is decidable
  haveI : DecidablePred (fun w => semantic_truth_at_v2 phi w origin phi) := sorry
  -- Use Fintype.decidableExistsFintype
  exact Fintype.decidableExistsFintype
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Build errors block all progress | High | Fix errors as Phase 1 priority |
| Time arithmetic proofs are fragile | Medium | Use omega/decide tactics systematically |
| Fintype instance is complex | Medium | Start with Classical.dec, prove Fintype later |
| Bridge lemmas require deep induction | Medium | Leverage existing truth lemma proofs as templates |

## Appendix

### Search Queries Used
- `lean_leansearch`: "finite model property for modal logic", "any model can be reduced to finite model with quotient"
- `lean_loogle`: "Set.Finite", "Decidable Fintype"
- `lean_leanfinder`: "filtration modal logic finite model"
- `lean_local_search`: SemanticWorldState, formula_satisfiable, finite_model_property

### Key Files Examined
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`
- `/home/benjamin/Projects/ProofChecker/specs/archive/544_connect_fmp_bridge/reports/research-001.md`
- `/home/benjamin/Projects/ProofChecker/specs/468_remove_or_refactor_the_existing_infinite_canonical_model_code_in_completeness.lean/reports/research-001.md`

### References
- Modal Logic, Blackburn et al., Chapter 4 (Finite Model Property)
- Mathlib FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable
- Mathlib Fintype.decidableForallFintype, Fintype.decidableExistsFintype
- Task 544 research report (FMP bridge analysis)
- Task 468 research report (canonical model refactoring)

## Next Steps

Run `/plan 547` to create implementation plan for:
1. Fix build errors in FiniteCanonicalModel.lean
2. Prove bridge lemmas connecting formula_satisfiable to semantic model
3. Prove finite_model_property via contrapositive
4. Prove satisfiability_decidable using Fintype instance
