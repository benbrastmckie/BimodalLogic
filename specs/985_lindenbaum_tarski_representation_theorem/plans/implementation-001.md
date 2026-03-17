# Implementation Plan: Task #985

- **Task**: 985 - Lindenbaum-Tarski algebraic representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (algebraic infrastructure exists)
- **Research Inputs**: specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true

## Overview

Develop the D-parametric Lindenbaum-Tarski algebraic representation theorem for TaskFrame semantics. The key insight from research-002 is that the duration type D should be a parameter, not constructed from syntax. This avoids the "domain mismatch" problems from tasks 977/978/982.

The existing infrastructure (LindenbaumAlg, BooleanStructure, InteriorOperators, UltrafilterMCS, CanonicalConstruction) is largely complete and sorry-free. This task generalizes from hardcoded `D = Int` to parametric `D : Type*` with appropriate typeclass constraints.

### Research Integration

From research-002.md:
- D-parametric construction avoids domain mismatch by accepting D as a parameter
- WorldState = Ultrafilter LindenbaumAlg (algebraically derived)
- task_rel from G interior operator's Stone relation
- Histories from temporally coherent FMCS families
- Truth lemma proof structure transfers directly (mechanical type polymorphism)

## Goals & Non-Goals

**Goals**:
- Define D-parametric canonical TaskFrame construction
- Generalize FMCS/BFMCS to arbitrary ordered abelian groups D
- Prove D-parametric truth lemma
- State and prove algebraic representation theorem for any D
- Instantiate for dense (D = Rat) and discrete (D = Int) cases

**Non-Goals**:
- Build D from syntax (that's the approach that caused domain mismatch)
- Prove SuccOrder for discrete domain (task 974 concern)
- Full soundness/completeness wiring (task 982 concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type constraint mismatch between existing Int code and parametric D | High | Medium | Carefully audit existing lemmas, introduce typeclass aliases |
| truth_at definition uses domain convexity differently for different D | Medium | Low | WorldHistory domain = True sidesteps this |
| Dense CanonicalR requires DenselyOrdered typeclass | Medium | Low | Add typeclass constraint, verify density axiom integration |
| Lean4 typeclass resolution difficulties with complex constraints | Medium | Medium | Use explicit instance arguments, structure inheritance |

## Sorry Characterization

### Pre-existing Sorries
- `AlgebraicRepresentation.lean`: Uses proven components (no sorries in that module)
- `CanonicalConstruction.lean`: Full truth lemma proven for D=Int (no sorries)

### Expected Resolution
- No pre-existing sorries in scope; all base infrastructure is proven

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach

### Remaining Debt
After this implementation:
- 0 sorries expected in parametric algebraic modules
- Dense/discrete instantiations will be sorry-free given base infrastructure

## Implementation Phases

### Phase 1: D-Parametric Canonical TaskFrame [NOT STARTED]

- **Dependencies:** None
- **Goal:** Generalize canonical TaskFrame from Int to arbitrary D

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`
- [ ] Define typeclass constraint bundle for D: `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- [ ] Define `ParametricCanonicalWorldState` = Subtype of MCS (D-independent)
- [ ] Define `parametric_canonical_task_rel (D : Type*) [constraints]`
- [ ] Prove `parametric_task_rel_nullity_identity`: d = 0 iff M = N
- [ ] Prove `parametric_task_rel_forward_comp`: compositionality for 0 <= x, 0 <= y
- [ ] Prove `parametric_task_rel_converse`: task_rel M d N iff task_rel N (-d) M
- [ ] Define `ParametricCanonicalTaskFrame D`: TaskFrame D with parametric world states

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.ParametricCanonical` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` returns empty

---

### Phase 2: D-Parametric FMCS and BFMCS [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Verify FMCS/BFMCS are already D-parametric and add conversion to WorldHistory

**Tasks:**
- [ ] Audit `FMCSDef.lean` - confirm FMCS is already parametric over `D : Type*`
- [ ] Audit `BFMCS.lean` - confirm BFMCS is already parametric over `D : Type*`
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean`
- [ ] Define `parametric_to_history (D) (fam : FMCS D) : WorldHistory (ParametricCanonicalTaskFrame D)`
- [ ] Prove `respects_task` for parametric_to_history (uses forward_G from FMCS)
- [ ] Define `ParametricCanonicalOmega (D) (B : BFMCS D) : Set (WorldHistory (ParametricCanonicalTaskFrame D))`
- [ ] Define `ParametricShiftClosedCanonicalOmega` - shift-closed enlargement
- [ ] Prove `parametric_shiftClosedCanonicalOmega_is_shift_closed`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.ParametricHistory` passes
- FMCS/BFMCS modules compile without modification (already parametric)

---

### Phase 3: D-Parametric Truth Lemma [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove the truth lemma for arbitrary D

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- [ ] Define `ParametricCanonicalTaskModel D : TaskModel (ParametricCanonicalTaskFrame D)`
- [ ] Prove `parametric_canonical_truth_lemma`: phi in fam.mcs t iff truth_at ... for any D
- [ ] Prove `parametric_box_persistent`: Box phi persists to all times (TF axiom)
- [ ] Prove `parametric_shifted_truth_lemma`: truth lemma for shift-closed Omega
- [ ] Verify proof structure matches Int case (should be nearly identical)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.ParametricTruthLemma` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` returns empty
- Proof cases: atom, bot, imp, box, all_future, all_past all handled

---

### Phase 4: Algebraic Representation Theorem [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** State and prove the D-parametric representation theorem

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`
- [ ] State `parametric_algebraic_representation`: For any D, if not (derivable phi), then exists countermodel over ParametricCanonicalTaskFrame D
- [ ] Prove using: Lindenbaum extension -> FMCS construction -> BFMCS bundle -> truth lemma
- [ ] Export theorem in standard completeness form: valid phi implies derivable phi (contrapositive)
- [ ] Add module documentation explaining D-parametric approach

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.ParametricRepresentation` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` returns empty
- Representation theorem statement matches research-002.md specification

---

### Phase 5: Dense and Discrete Instantiation [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Instantiate parametric theorem for dense (Rat) and discrete (Int) cases

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
- [ ] Instantiate `ParametricCanonicalTaskFrame Rat`
- [ ] Verify Rat satisfies required typeclasses (AddCommGroup, LinearOrder, IsOrderedAddMonoid, DenselyOrdered)
- [ ] State `dense_representation_theorem`: For Rat domain, not derivable implies countermodel
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean`
- [ ] Instantiate `ParametricCanonicalTaskFrame Int`
- [ ] Verify Int satisfies required typeclasses
- [ ] State `discrete_representation_theorem`: For Int domain, not derivable implies countermodel
- [ ] Document relationship to existing DenseCompleteness.lean and DiscreteCompleteness.lean

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - new file
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.DenseInstantiation` passes
- `lake build Bimodal.Metalogic.Algebraic.DiscreteInstantiation` passes
- Both modules are sorry-free

---

### Phase 6: Integration and Documentation [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Integrate with existing infrastructure, update Algebraic.lean re-export

**Tasks:**
- [ ] Update `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` to import new modules
- [ ] Add re-exports for key theorems: parametric_representation, dense_representation, discrete_representation
- [ ] Add module documentation explaining the D-parametric algebraic approach
- [ ] Update DenseCompleteness.lean to reference new algebraic infrastructure
- [ ] Update DiscreteCompleteness.lean to reference new algebraic infrastructure
- [ ] Verify full `lake build` passes

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - add imports and re-exports
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - add reference comments
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` - add reference comments

**Verification**:
- `lake build` passes (full project)
- All new modules accessible via Algebraic.lean re-exports
- No sorries in any modified files

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/Parametric*.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Algebraic/Parametric*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Task-Specific Validation
- [ ] `ParametricCanonicalTaskFrame D` satisfies TaskFrame axioms for any valid D
- [ ] Truth lemma covers all formula constructors: atom, bot, imp, box, all_future, all_past
- [ ] Dense instantiation works with D = Rat (DenselyOrdered)
- [ ] Discrete instantiation works with D = Int

## Artifacts & Outputs

- `specs/985_lindenbaum_tarski_representation_theorem/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` - D-parametric TaskFrame
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` - D-parametric histories
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - D-parametric truth lemma
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - representation theorem
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - Rat instantiation
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - Int instantiation
- `specs/985_lindenbaum_tarski_representation_theorem/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the D-parametric generalization encounters unexpected obstacles:

1. **Type Constraint Issues**: If typeclass constraints conflict, fall back to defining separate theorems for Rat and Int rather than a single parametric theorem

2. **Proof Complexity**: If the parametric truth lemma proof becomes unwieldy, consider:
   - Using `variable` section with explicit constraints
   - Breaking into smaller helper lemmas
   - Using `haveI` for local instances

3. **Integration Issues**: New files are additive (no modifications to core infrastructure), so rollback is straightforward: delete new files

4. **Performance**: If compilation becomes slow due to typeclass resolution, add explicit instance hints or `@` annotations
