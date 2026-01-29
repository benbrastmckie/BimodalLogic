# Implementation Plan: Task #738

- **Task**: 738 - Port FMP to parametric architecture with explicit cardinality bounds
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: medium
- **Dependencies**: Task 660 (parent task - Phase 3)
- **Research Inputs**:
  - `specs/738_port_fmp_to_parametric_architecture/reports/research-001.md`
  - `specs/738_port_fmp_to_parametric_architecture/reports/research-002.md`
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Port the Finite Model Property (FMP) infrastructure from the deprecated `Boneyard/Metalogic_v2/` architecture (hardcoded to Int) to the active parametric `Metalogic/` architecture. Following the **minimal port strategy (Option C)** from research, the approach will:
1. Move Closure infrastructure (no duration type, direct port)
2. State FMP parametrically but prove for `D = Int`
3. Provide explicit cardinality bounds: `|worlds| <= 2^closureSize(phi)`

This enables the decidability foundation orthogonal to the completeness chain.

### Research Integration

From Research 001:
- Closure infrastructure has no duration type dependency and ports directly
- `FiniteWorldState` uses `FiniteTime` with Int mapping - keep Int for finite construction
- Known sorries: compositionality (frame validity), truth bridge (line 481) - acceptable to preserve
- Recommended 4-phase approach matches implementation strategy

From Research 002:
- FMP provides bounded search space (2^closureSize) for tableau decidability
- Option C (minimal port) recommended: Move Closure, state FMP parametrically, prove for D=Int
- This matches the approach in `UniversalCanonicalModel.lean` which uses Z despite parametric definitions

## Goals & Non-Goals

**Goals**:
- Port Closure infrastructure to parametric architecture location
- Provide parametric FMP statement with explicit cardinality bounds
- Enable decidability procedure integration
- Preserve existing proofs (keeping known sorries)

**Non-Goals**:
- Full parametric proof for arbitrary D (can use Int-specific construction)
- Resolving existing sorries (compositionality, truth bridge)
- Porting tableau decidability infrastructure (separate follow-up task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import conflicts between Boneyard and Metalogic | Medium | Medium | Careful namespace management, use explicit imports |
| Compositionality sorry blocks usage | Low | Low | Frame is only used for FMP statement, not for general proofs |
| Truth bridge sorry prevents constructive FMP | Medium | Low | Already present in source; documented as known gap |
| Name collisions with existing definitions | Low | Medium | Use FMP-specific namespaces |

## Implementation Phases

### Phase 1: Closure Infrastructure Port [NOT STARTED]

**Goal**: Move closure definitions to parametric architecture with no functional changes.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/Closure.lean`
- [ ] Copy closure definitions from `Boneyard/Metalogic_v2/Representation/Closure.lean`
- [ ] Update namespace from `Bimodal.Metalogic_v2.Representation` to `Bimodal.Metalogic.FMP`
- [ ] Update imports to use `Bimodal.Metalogic.Core` instead of `Boneyard/Metalogic_v2/Core`
- [ ] Verify all closure lemmas compile without changes

**Timing**: 1-1.5 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/Representation/Closure.lean`
- Update: `Theories/Bimodal/Metalogic.lean` (hub import)

**Key definitions to port**:
- `closure : Formula -> Finset Formula`
- `closureSize : Formula -> Nat`
- `closureWithNeg : Formula -> Finset Formula`
- `ClosureConsistent`, `ClosureMaximalConsistent`
- `mcs_projection`, `mcs_projection_is_closure_mcs`

**Verification**:
- `lake build Bimodal.Metalogic.Representation.Closure` succeeds
- All existing lemmas type-check without modification

---

### Phase 2: FiniteWorldState Port [NOT STARTED]

**Goal**: Port finite world state construction keeping Int for time domain.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/FiniteWorldState.lean`
- [ ] Copy definitions from `Boneyard/Metalogic_v2/Representation/FiniteWorldState.lean`
- [ ] Update namespace to `Bimodal.Metalogic.FMP`
- [ ] Update imports to reference new Closure location
- [ ] Keep `FiniteTime (k : Nat) := Fin (2 * k + 1)` unchanged (Int via toInt)
- [ ] Port `FiniteTruthAssignment`, `IsLocallyConsistent`, `FiniteWorldState`
- [ ] Port `FiniteHistory` construction

**Timing**: 1.5-2 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/Representation/FiniteWorldState.lean`

**Key definitions to port**:
- `FiniteTime`, `FiniteTime.toInt`, `FiniteTime.origin`
- `FiniteTruthAssignment`, `IsLocallyConsistent`
- `FiniteWorldState` structure with `Fintype` instance
- `FiniteHistory`, `finite_history_from_state`
- `worldStateFromClosureMCS` construction

**Verification**:
- All Fintype/Finite instances resolve
- `worldStateFromClosureMCS_models_iff` compiles

---

### Phase 3: SemanticCanonicalModel Port [NOT STARTED]

**Goal**: Port semantic canonical model with frame compositionality sorry preserved.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/SemanticCanonicalModel.lean`
- [ ] Port `HistoryTimePair`, `htEquiv`, `htSetoid`
- [ ] Port `SemanticWorldState` quotient definition
- [ ] Port `semantic_task_rel` definition
- [ ] Port `SemanticCanonicalFrame (phi : Formula) : TaskFrame Int`
- [ ] Keep compositionality sorry with documenting comment
- [ ] Port `SemanticCanonicalModel` valuation
- [ ] Port `finiteHistoryToWorldHistory` conversion
- [ ] Port helper lemmas (`semantic_world_state_has_world_history`, etc.)

**Timing**: 1.5-2 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/Representation/SemanticCanonicalModel.lean`

**Key components**:
```lean
-- Port with Int hardcoded (as in source)
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel phi
  nullity := semantic_task_rel_nullity phi
  compositionality := sorry  -- KNOWN GAP: preserved from source
```

**Verification**:
- `SemanticCanonicalFrame` and `SemanticCanonicalModel` compile
- `semantic_world_state_has_world_history` provides history witness

---

### Phase 4: FMP Theorems Port [NOT STARTED]

**Goal**: Port FMP theorems with parametric statements where possible.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/FMP.lean` as hub module
- [ ] Create `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`
- [ ] Port `finite_model_property` structural statement
- [ ] Port `semanticWorldState_card_bound` with explicit bound
- [ ] Port `finite_model_property_constructive` with Fintype witness
- [ ] Keep truth bridge sorry (line 481 equivalent) with documenting comment
- [ ] Port `consistent_implies_satisfiable` via representation
- [ ] Port `validity_decidable_via_fmp` noncomputable instance
- [ ] Add parametric FMP statement (proven via Int specialization)

**Timing**: 2-2.5 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/FMP.lean`
- Create: `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`

**Key theorems to port**:
```lean
-- Cardinality bound (combinatorial, no duration type)
theorem semanticWorldState_card_bound (phi : Formula) :
    Fintype.card (SemanticWorldState phi) <= 2 ^ closureSize phi

-- Constructive FMP with explicit bounds
theorem finite_model_property_constructive (phi : Formula) (h_sat : formula_satisfiable phi) :
    exists (F : TaskFrame Int) (M : TaskModel F) (tau : WorldHistory F) (t : Int)
      (_h_finite : Finite F.WorldState)
      (_h_fintype : Fintype F.WorldState),
      truth_at M tau t phi /\
      Fintype.card F.WorldState <= 2 ^ (closureSize phi)

-- Parametric statement (using Int proof as witness)
theorem finite_model_property_parametric (D : Type)
    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (phi : Formula) (h_sat : formula_satisfiable phi) :
    exists (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
      truth_at M tau t phi  -- Existence follows from Int case
```

**Verification**:
- `finite_model_property_constructive` compiles with Fintype witness
- `semanticWorldState_card_bound` proves cardinality bound
- FMP module imports successfully

---

### Phase 5: Integration & Documentation [NOT STARTED]

**Goal**: Integrate FMP with existing architecture and document.

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic.lean` to export FMP modules
- [ ] Update `Theories/Bimodal/Metalogic/README.md` with FMP section
- [ ] Create `Theories/Bimodal/Metalogic/FMP/README.md` documenting:
  - Architecture relationship to decidability
  - Known sorries and their justification
  - Usage patterns for decidability integration
- [ ] Verify no import cycles
- [ ] Run full `lake build` for Bimodal

**Timing**: 0.5-1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean`
- `Theories/Bimodal/Metalogic/README.md`
- Create: `Theories/Bimodal/Metalogic/FMP/README.md`

**Verification**:
- `lake build Bimodal` completes successfully
- All FMP exports are accessible from hub module

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.Closure` succeeds
- [ ] `lake build Bimodal.Metalogic.Representation.FiniteWorldState` succeeds
- [ ] `lake build Bimodal.Metalogic.Representation.SemanticCanonicalModel` succeeds
- [ ] `lake build Bimodal.Metalogic.FMP` succeeds
- [ ] `lake build Bimodal` completes with no new errors
- [ ] All known sorries are explicitly documented with `-- KNOWN GAP:` comments
- [ ] Cardinality bound theorem provides explicit `2^closureSize` bound

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/Closure.lean` - Closure infrastructure
- `Theories/Bimodal/Metalogic/Representation/FiniteWorldState.lean` - Finite world states
- `Theories/Bimodal/Metalogic/Representation/SemanticCanonicalModel.lean` - Semantic canonical model
- `Theories/Bimodal/Metalogic/FMP.lean` - Hub module
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` - FMP theorems
- `Theories/Bimodal/Metalogic/FMP/README.md` - Documentation

## Rollback/Contingency

If implementation fails:
1. New files are isolated in `Metalogic/FMP/` and `Metalogic/Representation/` - can be deleted
2. Hub imports can be reverted
3. No modifications to existing working code
4. Boneyard source remains unchanged as reference

If specific phases fail:
- Phase 1 (Closure): Blocks all subsequent phases - resolve import issues first
- Phase 2 (FiniteWorldState): Can proceed to Phase 4 if closure works, using Boneyard types
- Phase 3 (SemanticCanonicalModel): Required for Phase 4 - focus on fixing imports
- Phase 4 (FMP): Can be stated even if model construction has issues
- Phase 5 (Integration): Optional for MVP - can defer documentation

## Notes

### Known Sorries to Preserve

| Source Location | New Location | Sorry Description |
|-----------------|--------------|-------------------|
| SemanticCanonicalModel.lean:224 | SemanticCanonicalModel.lean | `compositionality` - Frame axiom |
| FiniteModelProperty.lean:481 | FiniteModelProperty.lean | Truth bridge for constructive FMP |

### Architecture Decision: Minimal Port (Option C)

The minimal port strategy was chosen because:
1. Matches existing approach in `UniversalCanonicalModel.lean` (uses Z)
2. Avoids complexity of fully parametric time domains
3. Preserves working proofs from Boneyard
4. Provides explicit cardinality bounds for decidability

### Future Work

After this port, tableau decidability (Phase 4 from Research 002) can be addressed as a separate task:
- Port `Decidability/` modules to use new FMP infrastructure
- Connect `fmpBasedFuel` to `closureSize` from ported Closure
- Enable `validity_decidable_via_fmp` with concrete implementation
