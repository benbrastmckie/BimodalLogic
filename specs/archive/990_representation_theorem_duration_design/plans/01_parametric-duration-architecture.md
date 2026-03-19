# Implementation Plan: Task #990

- **Task**: 990 - Representation theorem design for parametric durations
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: None (architectural consolidation task)
- **Research Inputs**:
  - specs/990_representation_theorem_duration_design/reports/02_synthesis.md
  - specs/990_representation_theorem_duration_design/reports/01_teammate-a-findings.md
  - specs/990_representation_theorem_duration_design/reports/01_teammate-b-findings.md
- **Artifacts**: plans/01_parametric-duration-architecture.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: formal
- **Lean Intent**: true

## Overview

Consolidate on D-parametric architecture as the primary path for representation theorems across base, dense, and discrete TM logic extensions. The research conclusively shows D should be parametric with axioms constraining its structure, not constructed from pure syntax. This task implements this architectural decision by:

1. Updating ROAD_MAP.md to reflect the D-parametric primary / D-from-syntax auxiliary architecture
2. Adding documentation to key Lean files clarifying the architectural roles
3. Ensuring downstream tasks (987, 988, 989) can proceed with the correct architecture

### Research Integration

The synthesis report (02_synthesis.md) establishes:

| Question | Verdict |
|----------|---------|
| D-from-syntax feasible for base logic? | **Not feasible** (no characterization theorem) |
| D-parametric correct for base logic? | **Yes** (matches Montanari & de Rijke 1995) |
| Current `ParametricRepresentation.lean`? | **Keep as primary path** |
| D-from-syntax (`DFromCantor.lean`) role? | **Keep as auxiliary** |

**Key Insight**: The base TM axioms provide insufficient order-theoretic structure to identify the canonical timeline with a known group. Only with DN (density) or DF (discreteness) axioms can Cantor's theorem or Z-characterization be applied. Therefore:

- **Base completeness (task 987)**: Use D = Int parametrically; the `temporal_coherent_family_exists_CanonicalMCS` construction provides the BFMCS
- **Dense completeness (task 982)**: Use D = Rat parametrically with `[DenselyOrdered D]` constraint; `DFromCantor.lean` remains as an auxiliary result showing TimelineQuot satisfies the required axioms
- **Discrete completeness (task 989)**: Use D parametrically with `[SuccOrder D]` constraint

## Goals & Non-Goals

**Goals**:
- Update ROAD_MAP.md "D Construction from Canonical Timeline" strategy to reflect D-parametric as primary
- Add architectural documentation to `ParametricRepresentation.lean` clarifying its role as the main theorem
- Add architectural documentation to `DFromCantor.lean` clarifying its auxiliary role
- Document the domain selection for each completeness variant (base: Int, dense: Rat, discrete: Int/Z)
- Ensure the architectural decision is clear for downstream implementation tasks

**Non-Goals**:
- Implementing the actual completeness proofs (tasks 987, 988, 989)
- Removing or deprecating `DFromCantor.lean` (it has valid uses for dense completeness)
- Changing any theorem statements or proofs
- Wiring the domain connection gap in `FrameConditions/Completeness.lean` (task 982)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ROAD_MAP.md changes conflict with other tasks | L | L | This is an architectural clarification, not a strategy change |
| Downstream tasks misunderstand architecture | M | L | Clear documentation in both ROAD_MAP.md and Lean files |
| D-from-syntax path abandoned prematurely | M | L | Explicitly document auxiliary role; do not deprecate |

## Implementation Phases

### Phase 1: Update ROAD_MAP.md Strategy Section [COMPLETED]

**Goal**: Revise the "D Construction from Canonical Timeline" strategy to reflect the research findings.

**Tasks**:
- [ ] Update strategy status from ACTIVE to CONCLUDED
- [ ] Add research outcome explaining why D-parametric is primary
- [ ] Document that D-from-syntax remains valid as auxiliary for dense extension
- [ ] Add new architectural decision "D-Parametric as Primary Representation Path"
- [ ] Update "Remaining Work: Dense Completeness Wiring" to reference the D-parametric approach

**Key Changes to Document**:

1. **Strategy Conclusion**: The D-from-syntax approach (via Cantor isomorphism) successfully constructs D = TimelineQuot for dense logic, but cannot work for base logic (no characterization theorem). D-parametric is therefore the universal approach.

2. **Architectural Decision**: For all TM extensions, the representation theorem is parametric in D:
   ```
   forall (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
     not provable phi -> exists countermodel over D-parametric canonical frame
   ```

3. **Domain Instantiation**:
   - Base: D = Int (arbitrary choice; any linearly ordered abelian group works)
   - Dense: D = Rat (or any `[DenselyOrdered D]`)
   - Discrete: D = Int (or any `[SuccOrder D]`)

**Timing**: 1 hour

**Files to modify**:
- `specs/ROAD_MAP.md` - Strategy and architectural decisions sections

**Verification**:
- Strategy section reflects research conclusions
- No conflict with existing conclusions
- Downstream tasks (987, 988, 989) have clear guidance

---

### Phase 2: Document Parametric Architecture in Lean Files [COMPLETED]

**Goal**: Add architectural documentation to the key Lean files clarifying their roles.

**Tasks**:
- [ ] Add module-level documentation to `ParametricRepresentation.lean` establishing it as the primary representation theorem
- [ ] Add documentation explaining the conditional form (`parametric_algebraic_representation_conditional`) is correct
- [ ] Add module-level documentation to `DFromCantor.lean` clarifying its auxiliary role
- [ ] Document that `DFromCantor.lean` provides a concrete witness that the dense canonical timeline satisfies D-parametric constraints
- [ ] Add cross-references between the two modules

**Documentation to Add**:

In `ParametricRepresentation.lean`:
```lean
/-!
## Architectural Role

This module provides the PRIMARY representation theorem for TM logic. The duration type
D is parametric: completeness holds for ALL totally ordered abelian groups D, not just
a specific one constructed from syntax.

**Why Parametric?**
The base TM axiom system (without density DN or discreteness DF) provides insufficient
order-theoretic structure to characterize the canonical timeline. Without a characterization
theorem (Cantor for dense, Z-characterization for discrete), we cannot identify the
canonical timeline with a specific group like Q or Z.

The parametric approach resolves this: we prove completeness for ALL D satisfying
the group+order constraints. For specific extensions:
- **Base**: Instantiate with D = Int (or any suitable D)
- **Dense**: Instantiate with D = Rat, add [DenselyOrdered D]
- **Discrete**: Instantiate with D = Int, add [SuccOrder D]

**Relationship to DFromCantor.lean**:
The `DFromCantor.lean` module provides an auxiliary result: for dense TM logic,
the canonical timeline (constructed from syntax) IS order-isomorphic to Q via
Cantor's theorem. This is a CONSEQUENCE of the density axiom DN, not a requirement
for the representation theorem.
-/
```

In `DFromCantor.lean`:
```lean
/-!
## Architectural Role

This module provides an AUXILIARY result for dense TM completeness. It shows that
when the density axiom DN is present, the canonical timeline (TimelineQuot) is
order-isomorphic to Q via Cantor's uniqueness theorem.

**Why Auxiliary?**
The PRIMARY representation theorem in `ParametricRepresentation.lean` is parametric
in D. This module provides a specific witness: given DN, the canonical timeline
satisfies the D-parametric constraints with D = TimelineQuot (isomorphic to Q).

**When to Use This Module**:
1. To instantiate the parametric representation theorem with the "natural" D from syntax
2. To show that dense TM completeness follows from the axioms alone (without importing Q)
3. As evidence that the D-parametric architecture is flexible enough to accommodate
   syntax-derived domains

**Relationship to Base Completeness**:
For base TM logic (no DN/DF), this module is NOT applicable. The base logic must
use D = Int or another externally-provided group, as there is no characterization
theorem to identify the canonical timeline with a known structure.
-/
```

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - Add architectural docs
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromCantor.lean` - Add architectural docs

**Verification**:
- `lake build` succeeds (docs are comments only)
- Module documentation accurately reflects research findings
- Cross-references are correct

---

### Phase 3: Update BaseCompleteness.lean Documentation [COMPLETED]

**Goal**: Align BaseCompleteness.lean documentation with the D-parametric architecture.

**Tasks**:
- [ ] Update module documentation to reference the D-parametric representation theorem
- [ ] Clarify that D = Int is the chosen instantiation for base completeness
- [ ] Add reference to `ParametricRepresentation.lean` as the abstract result
- [ ] Document the relationship between `base_truth_lemma` and `parametric_shifted_truth_lemma`

**Key Documentation Updates**:

```lean
/-!
## Relationship to D-Parametric Architecture

This module instantiates the D-parametric representation theorem (from
`ParametricRepresentation.lean`) with D = Int for base TM completeness.

**Why D = Int?**
The base TM axioms provide no characterization theorem for the canonical timeline.
Any linearly ordered abelian group D works; we choose Int because:
1. It has the required algebraic structure (AddCommGroup, LinearOrder, IsOrderedAddMonoid)
2. The Int-based canonical construction is well-tested
3. Int is concrete and avoids universe issues

**What This Module Provides**:
- `base_truth_lemma`: The Int-specialized truth lemma
- `base_shifted_truth_lemma`: For shift-closed Omega
- `base_omega_shift_closed`: The shift-closed property

**For the Closed Completeness Theorem**:
See `AlgebraicBaseCompleteness.lean` (task 987) which wires these components
to prove `valid phi -> Nonempty (DerivationTree [] phi)`.
-/
```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` - Update documentation

**Verification**:
- `lake build` succeeds
- Documentation accurately describes Int instantiation rationale
- References to other modules are correct

---

### Phase 4: Create Architecture Summary Document [COMPLETED]

**Goal**: Create a concise reference document for the D-parametric architecture decision.

**Tasks**:
- [ ] Create `specs/990_representation_theorem_duration_design/summaries/01_architecture-decision-summary.md`
- [ ] Document the key architectural decisions
- [ ] Provide quick reference for downstream tasks
- [ ] Include file paths and cross-references

**Document Structure**:

```markdown
# Architecture Decision Summary: Task #990

## Decision: D-Parametric as Primary Representation Path

### Summary
The duration type D in TM representation theorems is PARAMETRIC. D is not constructed
from syntax for the base logic; only with density (DN) or discreteness (DF) axioms
can a specific D be derived from the canonical timeline.

### Key Files
| File | Role |
|------|------|
| `ParametricRepresentation.lean` | Primary: D-parametric representation theorem |
| `DFromCantor.lean` | Auxiliary: D-from-syntax for dense extension |
| `BaseCompleteness.lean` | Instantiation: D = Int for base logic |

### Domain Selection by Extension
| Extension | D | Constraint | Characterization |
|-----------|---|------------|------------------|
| Base | Int (any LOAG) | AddCommGroup + LinearOrder | None (no theorem) |
| Dense | Rat (or TimelineQuot) | [DenselyOrdered D] | Cantor's theorem |
| Discrete | Int (or Z-like) | [SuccOrder D] | Z-characterization |

### Impact on Downstream Tasks
- **Task 987**: Use `parametric_algebraic_representation_conditional` with D = Int
- **Task 988**: Use D-parametric with [DenselyOrdered D]; optionally instantiate via DFromCantor
- **Task 989**: Use D-parametric with [SuccOrder D]
```

**Timing**: 1 hour

**Files to create**:
- `specs/990_representation_theorem_duration_design/summaries/01_architecture-decision-summary.md`

**Verification**:
- Summary accurately reflects research and plan
- Cross-references are correct
- Downstream task guidance is actionable

---

### Phase 5: Verify and Finalize [COMPLETED]

**Goal**: Ensure all changes are consistent and the build passes.

**Tasks**:
- [ ] Run `lake build` to verify no regressions
- [ ] Grep for inconsistent terminology (ensure "D-parametric" is used consistently)
- [ ] Verify cross-references in ROAD_MAP.md are correct
- [ ] Review all modified files for accuracy

**Timing**: 1 hour

**Verification**:
- `lake build` succeeds
- No new sorries introduced
- Terminology is consistent across all modified files
- ROAD_MAP.md links are valid

## Testing & Validation

- [ ] `lake build` compiles without errors after all phases
- [ ] ROAD_MAP.md strategy section accurately reflects research conclusions
- [ ] Lean module documentation is accurate and consistent
- [ ] Summary document provides actionable guidance for downstream tasks
- [ ] No new sorries introduced (documentation changes only)

## Artifacts & Outputs

**Modified Files**:
- `specs/ROAD_MAP.md` - Strategy updates and architectural decision
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - Architectural docs
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromCantor.lean` - Architectural docs
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` - Documentation updates

**New Files**:
- `specs/990_representation_theorem_duration_design/summaries/01_architecture-decision-summary.md`

## Rollback/Contingency

This task involves only documentation changes (ROAD_MAP.md and Lean comments). If any issues arise:

1. All changes are reversible via git
2. Lean changes are comments only; no theorem/proof modifications
3. ROAD_MAP.md changes are additive (new decision, strategy update)

If downstream tasks reveal architectural issues:
1. Revisit the D-parametric assumption
2. Consider whether D-from-syntax has unexplored paths
3. Document any revisions in new research reports

## Dependencies and Downstream Impact

### This Task Enables
- **Task 987**: Algebraic base completeness - clear guidance to use D = Int
- **Task 988**: Dense algebraic completeness - clear guidance on D-parametric + DenselyOrdered
- **Task 989**: Discrete algebraic completeness - clear guidance on D-parametric + SuccOrder
- **Task 982**: Dense completeness wiring - clarifies that domain mismatch is a wiring problem, not an architecture problem

### This Task Does NOT Block
- Any task can proceed before this completes; this provides clarity, not prerequisites
- The architectural decision was already de facto in use (`ParametricRepresentation.lean` exists)
- This task documents and formalizes the existing direction
