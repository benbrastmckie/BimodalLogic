# Implementation Plan: Task #738 (v002)

- **Task**: 738 - Port FMP to parametric architecture with explicit cardinality bounds
- **Version**: 002 (Revised for Option A - Full Parametric Port)
- **Status**: [PARTIAL]
- **Effort**: 10-14 hours
- **Priority**: medium
- **Dependencies**: Task 660 (parent task - Phase 3)
- **Research Inputs**:
  - `specs/738_port_fmp_to_parametric_architecture/reports/research-001.md`
  - `specs/738_port_fmp_to_parametric_architecture/reports/research-002.md`
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

- **v001**: Minimal port (Option C) - state parametric, prove for Int only
- **v002**: Full parametric port (Option A) - prove for generic D with typeclass constraints

## Overview

Port the Finite Model Property (FMP) infrastructure from the deprecated `Boneyard/Metalogic_v2/` architecture (hardcoded to Int) to the active parametric `Metalogic/` architecture with **full parametric generalization**. Following **Option A (Full Parametric Port)** from research:

1. Define `BoundedTime D (k : Nat)` as a subtype of D for arbitrary ordered groups
2. Generalize all constructions to work with parametric duration type D
3. Prove FMP for any D satisfying `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`
4. Maintain maximum generality to match the parametric architecture design

This provides the highest-quality result that fully integrates with the existing parametric completeness proofs.

### Research Integration

From Research 001:
- Closure infrastructure has no duration type dependency and ports directly
- `FiniteWorldState` uses `FiniteTime` with Int mapping - **needs full generalization for Option A**
- Known sorries: compositionality (frame validity), truth bridge (line 481) - acceptable to preserve
- **Option A challenge**: Define `BoundedTime D (k : Nat)` as subtype of D with bounds ±k

From Research 002:
- FMP provides bounded search space (2^closureSize) for tableau decidability
- **Option A (Full Parametric)**: Port FMP with parametric D type, requiring bounded time subsets
- Maximally general result that matches parametric architecture

### Why Option A?

1. **Architectural consistency**: The parametric Metalogic/ uses generic D throughout - FMP should match
2. **Maximum generality**: Proves FMP for any ordered group, not just Int
3. **Future-proofing**: Any duration type satisfying constraints works automatically
4. **Mathematical elegance**: The FMP bound (2^closureSize) is independent of D - the proof should reflect this

## Goals & Non-Goals

**Goals**:
- Port Closure infrastructure to parametric architecture location
- Define `BoundedTime D (k : Nat)` for arbitrary ordered group D
- Provide fully parametric FMP statement and proof
- Explicit cardinality bounds: `|worlds| <= 2^closureSize(phi)`
- Seamless integration with existing IndexedMCSFamily and CoherentConstruction

**Non-Goals**:
- Resolving existing sorries (compositionality, truth bridge) - preserve as-is
- Porting tableau decidability infrastructure (separate follow-up task)
- Optimizing for proof performance (clarity over speed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BoundedTime construction complex for arbitrary D | High | Medium | Use Finset-based approach; fall back to Int coercion if needed |
| Ordered group arithmetic proofs tedious | Medium | High | Use automation (omega, simp, linarith) where possible |
| Import conflicts between architectures | Medium | Medium | Careful namespace management, explicit imports |
| Compositionality sorry affects generalization | Low | Low | Sorry is independent of D type |
| Fintype instance construction for generic D | High | Medium | Leverage that bound is combinatorial, not D-dependent |

## Implementation Phases

### Phase 1: Closure Infrastructure Port [COMPLETED]

**Goal**: Move closure definitions to parametric architecture with no functional changes. (Same as v001 - closure has no D dependency)

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/Closure.lean`
- [ ] Copy closure definitions from `Boneyard/Metalogic_v2/Representation/Closure.lean`
- [ ] Update namespace to `Bimodal.Metalogic.FMP`
- [ ] Update imports to use `Bimodal.Metalogic.Core`
- [ ] Verify all closure lemmas compile without changes

**Timing**: 1-1.5 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/FMP/Closure.lean`
- Update: `Theories/Bimodal/Metalogic.lean` (hub import)

**Key definitions to port**:
- `closure : Formula -> Finset Formula`
- `closureSize : Formula -> Nat`
- `closureWithNeg : Formula -> Finset Formula`
- `ClosureConsistent`, `ClosureMaximalConsistent`
- `mcs_projection`, `mcs_projection_is_closure_mcs`

**Verification**:
- `lake build Bimodal.Metalogic.FMP.Closure` succeeds
- All existing lemmas type-check without modification

---

### Phase 2: BoundedTime Abstraction [COMPLETED]

**Goal**: Define parametric bounded time domain for arbitrary ordered group D.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean`
- [ ] Define `BoundedTime (D : Type) [AddCommGroup D] [LinearOrder D] (k : Nat)` structure
- [ ] Define canonical injection from `Fin (2*k+1)` to `BoundedTime D k`
- [ ] Define projection `BoundedTime.toD : BoundedTime D k -> D`
- [ ] Prove `Fintype (BoundedTime D k)` with cardinality `2*k+1`
- [ ] Define `BoundedTime.origin : BoundedTime D k` (maps to 0 in D)
- [ ] Prove ordering properties: `BoundedTime` inherits linear order from D
- [ ] Define arithmetic operations within bounds (where defined)

**Timing**: 2-2.5 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean`

**Key definitions**:
```lean
/-- Bounded time domain for FMP construction.
    For any ordered group D, BoundedTime D k represents the finite set of
    "time offsets" within bounds [-k, k] as elements of D. -/
structure BoundedTime (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (k : Nat) where
  val : D
  bounds : ∃ (n : Fin (2*k+1)), val = (n.val : Int) • (1 : D) -- using int scalar mult
  -- Alternative: use Finset-based representation

/-- Canonical embedding from Fin to BoundedTime -/
def BoundedTime.ofFin (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (k : Nat) : Fin (2*k+1) -> BoundedTime D k

/-- Fintype instance - crucial for FMP bounds -/
instance : Fintype (BoundedTime D k) where
  elems := ...  -- Image of Fin embedding
  complete := ...

theorem boundedTime_card (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (k : Nat) : Fintype.card (BoundedTime D k) = 2*k+1
```

**Design Decision**: Use Fin-indexed representation
- `BoundedTime D k` is **defined** as the image of `Fin (2*k+1)` under scalar multiplication
- This guarantees Fintype automatically
- The bound comes from the combinatorial structure, not from D

**Verification**:
- `Fintype (BoundedTime D k)` instance compiles
- `boundedTime_card` proves correct cardinality
- Ordering operations work correctly

---

### Phase 3: Parametric FiniteWorldState [COMPLETED]

**Goal**: Port finite world state construction with parametric duration type D.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean`
- [ ] Replace `FiniteTime k` with `BoundedTime D k`
- [ ] Define `FiniteTruthAssignment D` using `BoundedTime D`
- [ ] Port `IsLocallyConsistent` with parametric time
- [ ] Define `FiniteWorldState D phi` structure
- [ ] Prove `Fintype (FiniteWorldState D phi)`
- [ ] Port `FiniteHistory D` using `BoundedTime D`
- [ ] Port `worldStateFromClosureMCS D` construction

**Timing**: 2-2.5 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean`

**Key definitions**:
```lean
/-- Truth assignment over bounded time domain -/
def FiniteTruthAssignment (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) (k : Nat) :=
  BoundedTime D k -> closure phi -> Bool

/-- Locally consistent finite truth assignment -/
def IsLocallyConsistent (D : Type) ... (fta : FiniteTruthAssignment D phi k) : Prop

/-- Finite world state - parametric over D -/
structure FiniteWorldState (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) where
  k : Nat
  assignment : FiniteTruthAssignment D phi k
  consistent : IsLocallyConsistent D assignment

/-- Fintype instance for FiniteWorldState -/
instance : Fintype (FiniteWorldState D phi)
-- Proof: bounded by finite truth assignments over finite closure

/-- World state from closure MCS - parametric construction -/
def worldStateFromClosureMCS (D : Type) ... (mcs : ClosureMaximalConsistent phi) :
    FiniteWorldState D phi
```

**Verification**:
- All Fintype/Finite instances resolve with generic D
- `worldStateFromClosureMCS D` constructs valid world states

---

### Phase 4: Parametric SemanticCanonicalModel [COMPLETED]

**Goal**: Port semantic canonical model with full parametric D type.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- [ ] Define `HistoryTimePair D phi` using `FiniteHistory D`
- [ ] Port `htEquiv D` and `htSetoid D` with parametric time
- [ ] Define `SemanticWorldState D phi` quotient
- [ ] Define `semantic_task_rel D phi` - the task relation
- [ ] Define `SemanticCanonicalFrame D phi : TaskFrame D`
- [ ] Keep compositionality sorry with documenting comment
- [ ] Port `SemanticCanonicalModel D phi` valuation
- [ ] Port `finiteHistoryToWorldHistory D` conversion
- [ ] Port helper lemmas with generic D

**Timing**: 2-3 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

**Key definitions**:
```lean
/-- Semantic canonical frame - fully parametric -/
noncomputable def SemanticCanonicalFrame (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) : TaskFrame D where
  WorldState := SemanticWorldState D phi
  task_rel := semantic_task_rel D phi
  nullity := semantic_task_rel_nullity D phi
  compositionality := by
    -- KNOWN GAP: Compositionality for task relation in finite model
    -- This sorry exists in the original implementation and is preserved
    -- during the parametric port. The finite model is still valid for
    -- demonstrating satisfiability, just not for general frame reasoning.
    sorry

/-- Semantic canonical model - fully parametric -/
noncomputable def SemanticCanonicalModel (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) : TaskModel (SemanticCanonicalFrame D phi)
```

**Verification**:
- `SemanticCanonicalFrame D` and `SemanticCanonicalModel D` compile
- Frame uses generic D, not hardcoded Int
- `semantic_world_state_has_world_history D` provides history witness

---

### Phase 5: Parametric FMP Theorems [COMPLETED]

**Goal**: Port FMP theorems with full parametric proofs.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`
- [ ] Port `finite_model_property D` with parametric proof
- [ ] Port `semanticWorldState_card_bound D` with explicit bound
- [ ] Port `finite_model_property_constructive D` with Fintype witness
- [ ] Keep truth bridge sorry with documenting comment
- [ ] Port `consistent_implies_satisfiable D`
- [ ] Verify cardinality bound is D-independent (combinatorial)
- [ ] Connect to existing `representation_theorem` from parametric layer

**Timing**: 2-3 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`

**Key theorems**:
```lean
/-- Cardinality bound - combinatorial, independent of D -/
theorem semanticWorldState_card_bound (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) :
    Fintype.card (SemanticWorldState D phi) <= 2 ^ closureSize phi

/-- Constructive FMP with explicit bounds - fully parametric -/
theorem finite_model_property_constructive (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) (h_sat : formula_satisfiable phi) :
    ∃ (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D)
      (_h_finite : Finite F.WorldState)
      (_h_fintype : Fintype F.WorldState),
      truth_at M tau t phi ∧
      Fintype.card F.WorldState <= 2 ^ (closureSize phi) := by
  -- Construction uses SemanticCanonicalModel D phi
  -- Bound follows from semanticWorldState_card_bound
  ...
  -- KNOWN GAP: Truth bridge connecting finite model truth to general truth_at
  sorry

/-- FMP structural statement - fully parametric -/
theorem finite_model_property (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) :
    formula_satisfiable phi ->
    ∃ (F : TaskFrame D), Finite F.WorldState ∧
      ∃ (M : TaskModel F) (tau : WorldHistory F) (t : D), truth_at M tau t phi
```

**Key insight**: The cardinality bound `2^closureSize phi` is **purely combinatorial**:
- It counts subsets of the closure
- The closure is a Finset of Formulas
- This bound is the same for any D
- The parametric proof reflects this mathematical fact

**Verification**:
- `finite_model_property_constructive D` compiles with generic D
- `semanticWorldState_card_bound D` proves D-independent bound
- FMP module imports successfully

---

### Phase 6: Integration & Documentation [NOT STARTED]

**Goal**: Integrate FMP with existing architecture and document the parametric design.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP.lean` as hub module
- [ ] Update `Theories/Bimodal/Metalogic.lean` to export FMP
- [ ] Update `Theories/Bimodal/Metalogic/README.md` with FMP section
- [ ] Create `Theories/Bimodal/Metalogic/FMP/README.md` documenting:
  - Parametric design rationale
  - BoundedTime abstraction
  - Known sorries and their justification
  - Usage patterns for decidability integration
- [ ] Verify no import cycles
- [ ] Run full `lake build` for Bimodal
- [ ] Add integration examples showing FMP with different D types

**Timing**: 1-1.5 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/FMP.lean`
- Update: `Theories/Bimodal/Metalogic.lean`
- Update: `Theories/Bimodal/Metalogic/README.md`
- Create: `Theories/Bimodal/Metalogic/FMP/README.md`

**Verification**:
- `lake build Bimodal` completes successfully
- All FMP exports are accessible from hub module
- Documentation explains parametric design

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.FMP.Closure` succeeds
- [ ] `lake build Bimodal.Metalogic.FMP.BoundedTime` succeeds
- [ ] `lake build Bimodal.Metalogic.FMP.FiniteWorldState` succeeds
- [ ] `lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel` succeeds
- [ ] `lake build Bimodal.Metalogic.FMP.FiniteModelProperty` succeeds
- [ ] `lake build Bimodal.Metalogic.FMP` (hub) succeeds
- [ ] `lake build Bimodal` completes with no new errors
- [ ] All known sorries are explicitly documented with `-- KNOWN GAP:` comments
- [ ] Cardinality bound theorem provides explicit `2^closureSize` bound
- [ ] FMP works for `D = Int`, `D = Rat`, `D = Real` (example instantiations)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Closure infrastructure
- `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean` - **NEW** Parametric bounded time
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Parametric finite world states
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Parametric semantic model
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` - Parametric FMP theorems
- `Theories/Bimodal/Metalogic/FMP.lean` - Hub module
- `Theories/Bimodal/Metalogic/FMP/README.md` - Documentation

## Rollback/Contingency

If implementation fails:
1. New files are isolated in `Metalogic/FMP/` - can be deleted
2. Hub imports can be reverted
3. No modifications to existing working code
4. Boneyard source remains unchanged as reference

If specific phases fail:
- Phase 1 (Closure): Blocks all - resolve first (low risk, direct port)
- **Phase 2 (BoundedTime)**: Critical for Option A - if fails, can fall back to v001 (Option C)
- Phase 3 (FiniteWorldState): Depends on Phase 2 - may need design iteration
- Phase 4 (SemanticCanonicalModel): Depends on Phase 3
- Phase 5 (FMP): Can proceed with sorries if earlier phases work
- Phase 6 (Integration): Optional for MVP

**Fallback to Option C**: If Phase 2 (BoundedTime) proves too complex:
1. Revert to v001 plan (minimal port)
2. Keep Int-based construction
3. Document parametric limitation in README

## Notes

### Known Sorries to Preserve

| Source Location | New Location | Sorry Description |
|-----------------|--------------|-------------------|
| SemanticCanonicalModel.lean:224 | SemanticCanonicalModel.lean | `compositionality` - Frame axiom |
| FiniteModelProperty.lean:481 | FiniteModelProperty.lean | Truth bridge for constructive FMP |

### Architecture Decision: Full Parametric Port (Option A)

The full parametric strategy was chosen because:
1. **Architectural consistency**: Matches existing parametric Metalogic design
2. **Maximum generality**: Works for any ordered group D
3. **Mathematical elegance**: Cardinality bound is D-independent - proof should reflect this
4. **Future-proofing**: New duration types work automatically
5. **Quality**: Highest-quality result for the theorem proving foundation

### Key Design: BoundedTime Abstraction

The `BoundedTime D k` type is the key innovation for Option A:
- Defined as image of `Fin (2*k+1)` under scalar multiplication into D
- Inherits Fintype from Fin
- Works for any ordered group D
- Preserves the combinatorial nature of the cardinality bound

### Future Work

After this port, tableau decidability can be addressed as a separate task:
- Port `Decidability/` modules to use parametric FMP infrastructure
- Connect `fmpBasedFuel` to `closureSize` from ported Closure
- Enable `validity_decidable_via_fmp` with parametric implementation
