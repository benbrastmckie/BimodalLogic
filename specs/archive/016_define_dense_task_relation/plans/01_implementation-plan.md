# Implementation Plan: Define DenseTask Relation

- **Task**: 16 - define_dense_task_relation
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None (all prerequisites exist)
- **Research Inputs**: specs/016_define_dense_task_relation/reports/01_dense-task-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Define `DenseTask(u, q, v)` as the deterministic three-place task relation where `u + q = v` under the transferred group structure on `TimelineQuot`. This leverages the existing `canonicalTaskRel` pattern from `DurationTransfer.lean` and the Cantor isomorphism `TimelineQuot ≃o Q` from `CantorApplication.lean`. The TaskFrame axioms are trivially satisfied by group properties already proven in `DurationTransfer.lean`. The density interpolation theorem follows from standard group arithmetic.

### Research Integration

Key findings from research report:
- `canonicalTaskRel` from `DurationTransfer.lean` provides the exact definition pattern needed
- `timelineQuotAddCommGroup` from `TimelineQuotAlgebra.lean` provides the group structure
- All three TaskFrame axioms (nullity identity, forward compositionality, converse) already proven generically
- Density interpolation is straightforward group arithmetic

## Goals & Non-Goals

**Goals**:
- Define `DenseTask` relation on `TimelineQuot` elements
- Instantiate `TaskFrame` structure for the dense case
- Prove density interpolation theorem
- Integrate into module hierarchy

**Non-Goals**:
- Defining `DenseTask_MCS` (MCS-based variant requiring `mcsAtTime` mapping)
- Modifying existing `parametric_canonical_task_rel` (kept for coarse duration comparisons)
- Adding new type class instances beyond what's needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Group instance inference issues | M | L | Use explicit `letI` for group instance |
| Import cycle | M | L | Keep imports minimal, follow existing patterns |
| `add_sub_cancel` simp lemma issues | L | L | Use `ring` or explicit rewriting if needed |

## Implementation Phases

### Phase 1: Create DenseTaskRelation.lean with Core Definition [COMPLETED]

**Goal**: Define `DenseTask` and prove basic equivalences

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean`
- [ ] Add required imports (TimelineQuotAlgebra, DurationTransfer, TaskFrame)
- [ ] Define `DenseTask` as `u + q = v` using `timelineQuotAddCommGroup`
- [ ] Prove `DenseTask_zero`: `DenseTask u 0 v ↔ u = v`
- [ ] Prove `DenseTask_add`: composition lemma for consecutive tasks
- [ ] Prove `DenseTask_neg`: `DenseTask u q v ↔ DenseTask v (-q) u`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean` - create new file

**Verification**:
- `lake build` compiles the new file without errors
- All three basic lemmas type-check

---

### Phase 2: TaskFrame Instance [COMPLETED]

**Goal**: Create `TaskFrame` structure instance for dense timeline

**Tasks**:
- [ ] Define `DenseTaskFrame` as `TaskFrame (TimelineQuot root_mcs root_mcs_proof)`
- [ ] Verify `nullity_identity` axiom (reuse proof pattern from `DurationTransfer.lean`)
- [ ] Verify `forward_comp` axiom (associativity of addition)
- [ ] Verify `converse` axiom (group inverse properties)
- [ ] Add docstrings explaining relationship to `canonicalTaskRel`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean` - add TaskFrame instance

**Verification**:
- `DenseTaskFrame` compiles
- All three axiom proofs complete without `sorry`

---

### Phase 3: Density Interpolation Theorem [COMPLETED]

**Goal**: Prove the density interpolation theorem and subdivision corollary

**Tasks**:
- [ ] State `density_interpolation`: for `DenseTask u q v` with `q > 0` and `0 < r < q`, exists `w` with `DenseTask u r w` and `DenseTask w (q-r) v`
- [ ] Prove via `use u + r` and group arithmetic
- [ ] State `arbitrary_subdivision` corollary: any positive-duration task subdivides into n equal parts
- [ ] Prove via induction on n using interpolation
- [ ] Add docstrings explaining semantic significance for F-obligation resolution

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean` - add theorems

**Verification**:
- `density_interpolation` compiles without `sorry`
- `arbitrary_subdivision` compiles without `sorry`

---

### Phase 4: Module Integration and Build Verification [COMPLETED]

**Goal**: Integrate into module structure and verify clean build

**Tasks**:
- [ ] Add import to `Theories/Bimodal/Metalogic/StagedConstruction.lean` (if exists)
- [ ] Alternatively, add import to `Theories/Bimodal/Metalogic.lean`
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify `DenseTaskRelation.lean` exports expected symbols

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction.lean` or `Theories/Bimodal/Metalogic.lean` - add import

**Verification**:
- `lake build` succeeds with no errors
- `#check DenseTask` works from dependent files

## Testing & Validation

- [ ] `lake build` compiles entire project without errors
- [ ] `DenseTask` definition accessible from other modules
- [ ] `DenseTaskFrame` instance usable in TaskFrame contexts
- [ ] `density_interpolation` theorem callable with concrete examples
- [ ] No `sorry` or `axiom` introduced

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean` - main implementation file
- `specs/016_define_dense_task_relation/summaries/01_implementation-summary.md` - completion summary

## Rollback/Contingency

If implementation fails:
1. Remove `DenseTaskRelation.lean` from imports
2. Delete `DenseTaskRelation.lean`
3. Run `lake build` to verify project still builds
4. Task remains in [PLANNED] status for retry with revised approach
