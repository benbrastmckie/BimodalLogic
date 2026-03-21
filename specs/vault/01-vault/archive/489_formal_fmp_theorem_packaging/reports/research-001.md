# Research Report: Task 489 - Formal FMP Theorem Packaging

- **Task**: 489 - formal_fmp_theorem_packaging
- **Started**: 2026-01-14T01:43:04Z
- **Completed**: 2026-01-14T01:50:00Z
- **Effort**: 2-3 hours (estimated for implementation)
- **Priority**: Medium
- **Dependencies**: Task 488 (fill remaining bridge lemmas) should be completed first for cleaner architecture
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Core completeness infrastructure
  - `Theories/Bimodal/Metalogic/Completeness.lean` - Canonical model construction
  - `Theories/Bimodal/Semantics/Validity.lean` - Satisfiability definitions
  - `Theories/Bimodal/Semantics/TaskFrame.lean` - Frame structure
  - `Theories/Bimodal/Semantics/TaskModel.lean` - Model structure
  - lean_leansearch (Mathlib FMP patterns)
- **Artifacts**: This report
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- The existing `semantic_weak_completeness` theorem in FiniteCanonicalModel.lean proves the core completeness result but is not packaged in standard FMP format
- The standard FMP statement is: `satisfiable phi -> exists (M : FiniteModel), M models phi` (contrapositive of completeness)
- Current infrastructure provides:
  - `SemanticCanonicalFrame phi : TaskFrame Int` with `Finite (SemanticWorldState phi)` instance
  - `SemanticCanonicalModel phi : TaskModel (SemanticCanonicalFrame phi)` with `semantic_valuation`
  - `FiniteTime k` with `Fintype` instance
- Key bounds are documented: temporal depth and modal depth determine model size
- Implementation requires defining `FiniteTaskModel` structure and proving equivalence with existing theorems

## Context & Scope

### Task Objective

Create formal Finite Model Property theorem statement matching the standard formulation:
```
forall phi, satisfiable phi -> exists (M : FiniteModel), M models phi
```

Package existing `semantic_weak_completeness` proof into this standard FMP format. Add documentation explaining bounds (temporal depth, modal depth).

### What We Have

1. **Core Completeness** (PROVEN in FiniteCanonicalModel.lean):
   - `semantic_weak_completeness`: If phi is true in all SemanticWorldStates, then phi is derivable
   - `main_provable_iff_valid`: `Nonempty (DerivationTree [] phi) <-> valid phi`

2. **Finite Model Infrastructure**:
   - `SemanticWorldState phi` - Quotient of (FiniteHistory, FiniteTime) pairs
   - `semanticWorldState_finite : Finite (SemanticWorldState phi)` - Finiteness instance
   - `SemanticCanonicalFrame phi : TaskFrame Int` - Frame with finite world states
   - `SemanticCanonicalModel phi : TaskModel (SemanticCanonicalFrame phi)` - Full model

3. **Finiteness Bounds**:
   - `FiniteTime k = Fin (2 * k + 1)` represents times from -k to +k
   - `temporalBound phi = temporalDepth phi` - sufficient time domain
   - World states bounded by `2^|closure phi|` where `closure phi` is the subformula closure

4. **Satisfiability Definition** (in Validity.lean):
   ```lean
   def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (Γ : Context) : Prop :=
     exists (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
       forall phi in Gamma, truth_at M tau t phi
   ```

### What We Need

The standard FMP format requires:
1. A `FiniteTaskModel` or `FiniteTaskFrame` structure with `Finite` constraint on WorldState
2. A theorem connecting satisfiability to existence of finite model
3. Explicit bound documentation

## Findings

### Finding 1: Existing Finite Model Property Theorem

There exists a `finite_model_property` theorem at line 3834, but it is trivial (identity):
```lean
theorem finite_model_property (phi : Formula) :
  (exists (_M : TaskModel (FiniteCanonicalFrame phi))
     (h : FiniteHistory phi)
     (t : FiniteTime (temporalBound phi)),
     finite_truth_at phi h t phi) ->
  (exists (_M : TaskModel (FiniteCanonicalFrame phi))
     (h : FiniteHistory phi)
     (t : FiniteTime (temporalBound phi)),
     finite_truth_at phi h t phi) := by
  intro h
  exact h
```

This needs to be replaced with the proper FMP statement.

### Finding 2: Contrapositive Structure

The semantic completeness result is stated via contrapositive:
- `semantic_weak_completeness`: `(all w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi) -> derives phi`
- Contrapositive: `not (derives phi) -> exists w, not (semantic_truth_at_v2 phi w origin phi)`

This IS the finite model property - if phi is not valid (i.e., not derivable), then there exists a finite countermodel (SemanticWorldState where phi is false).

### Finding 3: FiniteTaskFrame Structure

`FiniteCanonicalFrame phi` already exists with:
- `WorldState = FiniteWorldState phi`
- `task_rel = finite_task_rel phi`
- Finiteness: `finiteWorldState_finite : Finite (FiniteWorldState phi)`

Similarly for `SemanticCanonicalFrame phi`:
- `WorldState = SemanticWorldState phi`
- Finiteness: `semanticWorldState_finite : Finite (SemanticWorldState phi)`

### Finding 4: Missing Standard Definition

There is no explicit `FiniteTaskFrame` or `FiniteTaskModel` type that bundles the `Finite` constraint. The finiteness is established via separate instance declarations.

For standard FMP packaging, we should define:
```lean
structure FiniteTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    extends TaskFrame D where
  finite_world : Finite WorldState

structure FiniteTaskModel (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : FiniteTaskFrame D) extends TaskModel F.toTaskFrame
```

### Finding 5: Satisfiability Gap

The current `satisfiable` definition quantifies over arbitrary `WorldHistory F` and time `t : D`. The FMP needs to show:
- If `[phi]` is satisfiable (there exists some model, history, time making phi true)
- Then there exists a FINITE model making phi true

The contrapositive (completeness) is proven, but the direct statement needs bridging.

### Finding 6: Model Bounds Documentation

From code analysis:
- **Temporal bound**: `temporalDepth phi` gives sufficient time range
- **State bound**: `|SemanticWorldState phi| <= 2^|closure phi|` (injective map to FiniteWorldState)
- **Closure bound**: `|closure phi| = O(|phi|)` (subformulas bounded by formula size)

These bounds should be documented as theorems.

## Decisions

1. **Use SemanticCanonicalFrame** as the canonical finite model (not FiniteCanonicalFrame) since it has proven completeness
2. **Define explicit FiniteTaskFrame/FiniteTaskModel structures** for clarity
3. **State FMP as contrapositive of completeness** to align with existing proofs
4. **Document bounds as separate theorems** for usability
5. **Add formula-specific satisfiability** for single formulas (current definition is for contexts)

## Recommendations

### Phase 1: Define FiniteTaskFrame/FiniteTaskModel (30 min)

Create explicit structures bundling finiteness:
```lean
/-- A task frame with finitely many world states -/
structure FiniteTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    extends TaskFrame D where
  finite_world : Finite WorldState

/-- A task model over a finite frame -/
abbrev FiniteTaskModel (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : FiniteTaskFrame D) := TaskModel F.toTaskFrame
```

### Phase 2: Define Formula Satisfiability (15 min)

Add single-formula satisfiability:
```lean
/-- A formula is satisfiable if there exists a model where it is true at some point -/
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

### Phase 3: State Formal FMP Theorem (45 min)

```lean
/-- Finite Model Property for TM logic.

If a formula phi is satisfiable, then it is satisfiable in a finite model
with bounded size (temporal depth and 2^|closure| world states). -/
theorem finite_model_property_v2 (phi : Formula) :
    formula_satisfiable phi ->
    exists (F : FiniteTaskFrame Int) (M : TaskModel F.toTaskFrame)
      (tau : WorldHistory F.toTaskFrame) (t : Int),
      truth_at M tau t phi := by
  -- Contrapositive of semantic_weak_completeness
  ...
```

### Phase 4: Prove Model Bounds (30 min)

```lean
/-- World state count bound -/
theorem finite_model_state_bound (phi : Formula) :
    Nat.card (SemanticWorldState phi) <= 2 ^ (closure phi).card := by
  ...

/-- Temporal domain bound -/
theorem finite_model_time_bound (phi : Formula) :
    -- Model needs only times in [-temporalDepth phi, temporalDepth phi]
    ...
```

### Phase 5: Add Documentation (30 min)

Add comprehensive docstrings explaining:
- What FMP means for TM logic
- How bounds are computed
- Connection to decidability
- Relationship between semantic and syntactic approaches

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Bridge lemmas (Task 488) not complete | Medium | FMP can still be stated; internal sorries localized |
| FiniteTaskFrame definition incompatible with existing code | Low | Use abbrev/coercion for seamless integration |
| Int time type complicates bounds | Low | Document that finite subrange suffices |

## Appendix

### Key File Locations

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Core implementation (3955 lines)
- `Theories/Bimodal/Semantics/Validity.lean` - Satisfiability definitions
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Frame structure
- `Theories/Bimodal/Semantics/TaskModel.lean` - Model structure

### Existing Theorem Signatures

```lean
-- Core completeness (PROVEN)
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (FiniteTime.origin (temporalBound phi)) phi) ->
    derives phi

-- Finiteness instances (PROVEN)
instance semanticWorldState_finite : Finite (SemanticWorldState phi)
instance (k : Nat) : Fintype (FiniteTime k)
instance finiteWorldState_finite (phi : Formula) : Finite (FiniteWorldState phi)

-- Satisfiability (in Validity.lean)
def satisfiable (D : Type*) [...] (Gamma : Context) : Prop
def satisfiable_abs (Gamma : Context) : Prop
```

### Mathlib FMP Reference

Mathlib's first-order logic has:
```lean
-- In Mathlib.ModelTheory.Satisfiability
def FirstOrder.Language.Theory.IsFinitelySatisfiable : Theory -> Prop
theorem isSatisfiable_iff_isFinitelySatisfiable : T.IsSatisfiable <-> T.IsFinitelySatisfiable
```

This pattern (relating general satisfiability to finite satisfiability) is the standard FMP formulation we should follow.
