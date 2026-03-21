# Research Report: Task #977 - Teammate D Findings

**Task**: 977 - Organize TM base logic with extensions
**Focus**: Refactoring Strategy for Base Logic + Extensions Architecture
**Started**: 2026-03-16T14:00:00Z
**Completed**: 2026-03-16T15:30:00Z
**Effort**: 1.5 hours
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, existing documentation, Axioms.lean patterns
**Artifacts**: This research report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The current codebase already has a **solid foundation** for extension modularity through `Axiom.isBase`, `Axiom.isDenseCompatible`, and `Axiom.isDiscreteCompatible` predicates
- The architecture uses **validity variants** (`valid`, `valid_dense`, `valid_discrete`) to parameterize soundness/completeness by frame conditions
- A **typeclass-based approach** for frame conditions would improve modularity but requires careful migration
- The recommended refactoring strategy uses a **layered migration** preserving all existing proofs

## Logic Organization Best Practices

### 1. Mathlib-Style Layered Architecture

Mathlib organizes algebraic structures via:
1. **Typeclasses for properties**: `Group`, `Ring`, `TopologicalSpace`, etc.
2. **Instances for combinations**: `CommGroup` extends `Group`
3. **Conditional theorems**: Theorems state their required instances

For modal/temporal logic, the analogous pattern would be:
- **Base logic** (minimal axioms valid on all frames)
- **Frame condition typeclasses**: `DenseFrame`, `DiscreteFrame`, `SerialFrame`, etc.
- **Extension axioms** as conditionally available based on typeclasses

### 2. Current Codebase Pattern

The codebase already uses a principled organization:

```lean
-- In Axioms.lean: Predicates filter axioms by frame compatibility
def Axiom.isBase {φ : Formula} : Axiom φ → Prop
  | Axiom.density _ => False           -- Requires DenselyOrdered
  | Axiom.discreteness_forward _ => False  -- Requires SuccOrder
  | Axiom.seriality_future => False    -- Requires Nontrivial
  | Axiom.seriality_past => False      -- Requires Nontrivial
  | _ => True                          -- Valid on all frames
```

```lean
-- In Validity.lean: Separate validity notions
def valid (φ : Formula) : Prop := ...      -- All frames
def valid_dense (φ : Formula) : Prop := ... -- [DenselyOrdered D]
def valid_discrete (φ : Formula) : Prop := ... -- [SuccOrder D] [PredOrder D]
```

```lean
-- In Soundness.lean: Validators per frame class
theorem axiom_base_valid {φ} (h : Axiom φ) (h_base : h.isBase) : ⊨ φ
theorem axiom_valid_dense {φ} (h : Axiom φ) (h_dc : h.isDenseCompatible) : valid_dense φ
theorem axiom_valid_discrete {φ} (h : Axiom φ) (h_dc : h.isDiscreteCompatible) : valid_discrete φ
```

### 3. Recommended Best Practice Pattern

The ideal organization for base + extensions:

```
Theories/
  Logic/
    Base/           -- Minimal axioms (K, 4, T, B, etc.)
      Axioms.lean
      Derivation.lean
      Soundness.lean
      Completeness.lean
    Extensions/
      Dense/        -- Density extension
        Axiom.lean
        Soundness.lean
      Discrete/     -- Discreteness extension
        Axiom.lean
        Soundness.lean
      Serial/       -- Seriality extension
        Axiom.lean
        Soundness.lean
    Combinations/   -- Common combinations
      DenseSerial.lean   -- Q-like timeline
      DiscreteSerial.lean -- Z-like timeline
```

## Existing Patterns in Codebase

### Current Directory Structure

```
Theories/Bimodal/
  Syntax/           -- Formulas, contexts
  ProofSystem/      -- Axioms, derivations (monolithic)
  Semantics/        -- Task frames, validity
  Metalogic/        -- Soundness, completeness
    Soundness.lean
    DenseSoundness.lean
    DiscreteSoundness.lean
```

### Key Existing Patterns

1. **Axiom Filtering via Predicates**: `isBase`, `isDenseCompatible`, `isDiscreteCompatible` in `Axioms.lean`

2. **Validity Stratification**: Three separate validity definitions with typeclass constraints:
   - `valid`: No extra constraints beyond `LinearOrder D`, `AddCommGroup D`
   - `valid_dense`: Adds `[DenselyOrdered D] [Nontrivial D]`
   - `valid_discrete`: Adds `[SuccOrder D] [PredOrder D] [Nontrivial D]`

3. **Soundness Stratification**: Three soundness theorems:
   - `axiom_base_valid`: Base axioms universally valid
   - `axiom_valid_dense`: Dense-compatible axioms valid on dense frames
   - `axiom_valid_discrete`: Discrete-compatible axioms valid on discrete frames

4. **Temporal Duality Rule**: Derives backward axioms from forward axioms (e.g., DP from DF in `Discreteness.lean`)

5. **TaskFrame Parameterization**: Frames are polymorphic over `D : Type*` with ordered additive group structure

### What Works Well

- **Axiom classification is clean**: The `isBase`/`isDenseCompatible`/`isDiscreteCompatible` predicates clearly separate extension axioms
- **Validity stratification is correct**: Each frame class has its own validity notion
- **Soundness proofs are modular**: `DenseSoundness.lean` and `DiscreteSoundness.lean` wrap the main soundness theorem

### What Could Be Improved

1. **DerivationTree is monolithic**: All 20+ axiom constructors are in one inductive type
2. **No typeclass for frame conditions**: Frame conditions are checked at validity definition level, not at derivation level
3. **Extension composition is manual**: Combining density + seriality requires restating theorems

## Proposed Extension Architecture

### Architecture Option A: Typeclass-Based Frame Conditions (Recommended)

Define typeclasses for frame properties:

```lean
-- Frame condition typeclasses
class DenseFrame (D : Type*) extends LinearOrder D, AddCommGroup D where
  dense : DenselyOrdered D

class DiscreteFrame (D : Type*) extends LinearOrder D, AddCommGroup D where
  succ : SuccOrder D
  pred : PredOrder D

class SerialFrame (D : Type*) extends LinearOrder D, AddCommGroup D where
  nontrivial : Nontrivial D
```

Axioms become conditional:

```lean
-- Base axioms (always available)
inductive BaseAxiom : Formula → Type where
  | prop_k : BaseAxiom (...)
  | modal_t : BaseAxiom (...)
  -- ... base axioms only

-- Dense extension axiom
def DenseAxiom (φ : Formula) [DenseFrame D] : Prop :=
  ∃ ψ, φ = ψ.some_future.imp ψ.some_future.some_future

-- Discrete extension axiom
def DiscreteAxiom (φ : Formula) [DiscreteFrame D] : Prop :=
  -- discreteness_forward pattern
```

Derivation parameterized by extensions:

```lean
-- Generic derivation with extension axioms
structure ExtendedDerivation (Ext : Formula → Prop) : Context → Formula → Type where
  base : BaseDerivation Γ φ → ExtendedDerivation Ext Γ φ
  extension : Ext φ → ExtendedDerivation Ext Γ φ
  modus_ponens : ...
```

### Architecture Option B: Extension Mixins (Simpler Migration)

Keep current monolithic `Axiom` type but add mixin predicates:

```lean
-- Current approach extended
def Axiom.requiresDense {φ} : Axiom φ → Prop
  | density _ => True
  | _ => False

def Axiom.requiresDiscrete {φ} : Axiom φ → Prop
  | discreteness_forward _ => True
  | _ => False

def Axiom.requiresSerial {φ} : Axiom φ → Prop
  | seriality_future => True
  | seriality_past => True
  | _ => False

-- Derivation-level validation
def DerivationTree.isValidFor (frameClass : FrameClass) : DerivationTree Γ φ → Prop
  | axiom _ _ ax => ax.compatibleWith frameClass
  | modus_ponens d1 d2 => d1.isValidFor frameClass ∧ d2.isValidFor frameClass
  | ...
```

### Architecture Option C: Separate Inductive Types per Extension (Most Modular)

Completely separate axiom/derivation types per extension:

```lean
-- Base logic
inductive BaseAxiom : Formula → Type where ...
inductive BaseDerivation : Context → Formula → Type where ...

-- Dense extension (imports Base)
inductive DenseAxiom : Formula → Type where
  | density : DenseAxiom (...)

inductive DenseDerivation : Context → Formula → Type where
  | base : BaseDerivation Γ φ → DenseDerivation Γ φ
  | dense_axiom : DenseAxiom φ → DenseDerivation Γ φ
  | modus_ponens : DenseDerivation Γ (φ.imp ψ) → DenseDerivation Γ φ → DenseDerivation Γ ψ
```

### Recommendation: Hybrid Approach

Use **Option B** for immediate pragmatic improvements:
1. Add explicit `requiresDense`, `requiresDiscrete`, `requiresSerial` predicates
2. Add `FrameClass` enumeration (`Base | Dense | Discrete | DenseSerial | DiscreteSerial`)
3. Add derivation validation functions

Then migrate to **Option A** for future extensions:
1. Define frame condition typeclasses
2. Parameterize completeness proofs over frame classes
3. Composition becomes automatic via typeclass resolution

## Refactoring Migration Strategy

### Phase 1: Documentation and Analysis (0.5 hours)
- Document current extension patterns
- Identify all axioms by frame class requirements
- Create mapping table (axiom -> required frame conditions)

### Phase 2: Explicit Predicates (1 hour)
Add explicit requirement predicates without changing existing proofs:

```lean
-- Add to Axioms.lean (non-breaking)
def Axiom.requiresDense {φ : Formula} : Axiom φ → Bool
def Axiom.requiresDiscrete {φ : Formula} : Axiom φ → Bool
def Axiom.requiresSerial {φ : Formula} : Axiom φ → Bool
def Axiom.frameRequirements {φ : Formula} : Axiom φ → FrameClass
```

### Phase 3: FrameClass Enumeration (0.5 hours)
Define frame class combinations:

```lean
inductive FrameClass
  | base        -- All linear ordered additive groups
  | dense       -- + DenselyOrdered
  | discrete    -- + SuccOrder, PredOrder
  | serial      -- + Nontrivial (NoMaxOrder, NoMinOrder)
  | denseSerial -- dense + serial (like Q)
  | discreteSerial -- discrete + serial (like Z)
```

### Phase 4: Derivation Validation (1 hour)
Add validation without changing derivation type:

```lean
def DerivationTree.usedAxioms : DerivationTree Γ φ → List (Σ ψ, Axiom ψ)

def DerivationTree.minimalFrameClass : DerivationTree Γ φ → FrameClass :=
  d.usedAxioms.foldl (fun acc ⟨_, ax⟩ => max acc ax.frameRequirements) .base

def DerivationTree.validForFrameClass (fc : FrameClass) : DerivationTree Γ φ → Prop :=
  d.minimalFrameClass ≤ fc
```

### Phase 5: Soundness Refactoring (2 hours)
Generalize soundness theorems:

```lean
-- Generic soundness parameterized by frame class
theorem soundness_for_frame_class (fc : FrameClass) :
    (Γ ⊢ φ) → (d : Γ ⊢ φ).validForFrameClass fc → Γ ⊨[fc] φ
```

### Phase 6: Directory Reorganization (Optional, 3 hours)
If full restructure desired:
1. Create `Extensions/` directory
2. Move `DenseSoundness.lean` -> `Extensions/Dense/Soundness.lean`
3. Move `DiscreteSoundness.lean` -> `Extensions/Discrete/Soundness.lean`
4. Extract extension axiom definitions to extension subdirectories

### Phase 7: Typeclass Migration (Future, 4+ hours)
For true modular composition:
1. Define `DenseFrame`, `DiscreteFrame`, `SerialFrame` typeclasses
2. Parameterize validity over frame typeclass
3. Generic completeness theorem with frame typeclass parameter

## Risk Assessment

### Low Risk
- **Adding predicates** (Phase 2-3): Pure additions, no changes to existing proofs
- **Adding validation functions** (Phase 4): Pure additions, optional use

### Medium Risk
- **Soundness refactoring** (Phase 5): May require re-proving some lemmas
- **Directory reorganization** (Phase 6): Requires import path updates, potential merge conflicts

### High Risk
- **Typeclass migration** (Phase 7): Major structural change affecting:
  - All soundness proofs must be re-parameterized
  - Completeness proofs need frame class parameters
  - Potential universe level issues with typeclass parameters

### Mitigation Strategies

1. **Incremental migration**: Complete Phases 1-4 before Phase 5+
2. **Backward compatibility**: Keep existing validity definitions as aliases
3. **Test coverage**: Run `lake build Bimodal` after each phase
4. **Boneyard backup**: Archive old implementations before major changes

### Dependencies on Current Work

**Phase 6 Blocker** (CantorApplication.lean):
The current "D Construction from Canonical Timeline" strategy (Task 956) requires:
- `DenselyOrdered` instances on the canonical timeline quotient
- Seriality (NoMaxOrder, NoMinOrder) on the timeline

This work should wait until Phase 6 of Task 956 is resolved, as the frame class architecture should align with the canonical timeline's discovered properties.

## What Existing Code Can Be Preserved

### Fully Preservable (No Changes Needed)
- `Syntax/Formula.lean` - Formula definitions unchanged
- `Syntax/Context.lean` - Context operations unchanged
- `ProofSystem/Derivation.lean` - DerivationTree type unchanged (add validation)
- `Semantics/TaskFrame.lean` - Frame structure unchanged
- `Semantics/Validity.lean` - Validity definitions unchanged (add aliases)

### Minor Modifications
- `ProofSystem/Axioms.lean` - Add requirement predicates (non-breaking)
- `Metalogic/Soundness.lean` - Add parameterized theorem (keep existing)

### Potential Rewrite (If Option A Chosen)
- Completeness proofs - Would need frame typeclass parameters
- But can be deferred to Phase 7 (future work)

## Summary Table: Axiom Frame Requirements

| Axiom | Base | Dense | Discrete | Serial |
|-------|------|-------|----------|--------|
| prop_k, prop_s, ex_falso, peirce | Y | Y | Y | Y |
| modal_t, modal_4, modal_b, modal_5_collapse | Y | Y | Y | Y |
| modal_k_dist, temp_k_dist | Y | Y | Y | Y |
| temp_4, temp_t_future, temp_t_past | Y | Y | Y | Y |
| temp_a, temp_l, temp_linearity | Y | Y | Y | Y |
| modal_future, temp_future | Y | Y | Y | Y |
| density | N | Y | N | N |
| discreteness_forward | N | N | Y | N |
| seriality_future, seriality_past | N | Y* | Y* | Y |

*Seriality axioms require Nontrivial D, which is implied by DenselyOrdered + NoMaxOrder in practice

## Conclusion

The codebase already has a well-designed foundation for extension modularity. The recommended path is:

1. **Short term** (Phases 1-4): Add explicit frame requirement predicates and validation functions - low risk, immediate benefit
2. **Medium term** (Phase 5): Generalize soundness theorem with frame class parameter
3. **Long term** (Phase 7): Migrate to typeclass-based frame conditions for automatic extension composition

The key insight is that **adding modularity is an additive change** - we can layer new abstractions on top of the existing working system without breaking existing proofs.
