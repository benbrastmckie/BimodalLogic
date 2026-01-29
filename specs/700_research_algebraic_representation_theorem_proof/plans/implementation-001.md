# Implementation Plan: Task #700

- **Task**: 700 - Algebraic Representation Theorem Proof
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours
- **Priority**: Medium
- **Dependencies**: None (reflexive semantics already implemented)
- **Research Inputs**: reports/research-001.md, reports/research-002.md, reports/research-003.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan establishes a purely algebraic approach to the representation theorem as an **alternative path** to the current seed-extension approach in CoherentConstruction.lean. The algebraic approach leverages reflexive G/H semantics (already implemented) to show that temporal operators form interior operators on the Lindenbaum-Tarski algebra, enabling a cleaner proof via Boolean algebra with operators and Stone duality.

**Key constraint**: All algebraic infrastructure MUST be isolated in `Theories/Bimodal/Metalogic/Algebraic/` so it can be cleanly removed if the approach fails. The algebraic approach provides an ALTERNATIVE proof path; it should not modify existing files.

### Research Integration

From research-001.md:
- Mathlib has strong Boolean algebra infrastructure but lacks BAO support
- Revised estimate: 800-1200 lines with reflexive semantics

From research-002.md:
- Reflexive G/H form interior/closure operators on the Lindenbaum algebra
- Mathlib's `ClosureOperator` can be leveraged directly
- S4 conditions (K, T, 4) are precisely interior operator conditions

From research-003.md:
- Reflexive semantics already implemented (Truth.lean uses `<=`, Axioms.lean has T-axioms)
- Algebraic approach: quotient by provability, show Boolean structure, prove G/H are interior operators, use Stone duality

## Goals & Non-Goals

**Goals**:
- Establish Lindenbaum-Tarski algebra as Boolean algebra with operators G and H
- Prove G and H are interior operators using T-axioms
- Show ultrafilters of Lindenbaum algebra correspond to MCS
- Prove representation theorem algebraically
- Keep all infrastructure isolated for clean removal if approach fails

**Non-Goals**:
- Replacing the current CoherentConstruction.lean approach (this is an alternative)
- Contributing to Mathlib (out of scope for this task)
- Proving equivalence of algebraic and current approaches (future work)
- Modifying existing metalogic files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Interior operator structure hard to formalize | High | Medium | Use existing `ClosureOperator` as template, define dual manually |
| Quotient Boolean algebra proof tedious | Medium | High | Break into small lemmas, leverage LatticeCon machinery |
| Stone duality complexity | High | Medium | Use minimal algebraic correspondence (ultrafilter <-> MCS), skip topological machinery |
| Proofs depend on task-specific axioms | Medium | Low | Document axiom dependencies clearly for each lemma |
| Cannot cleanly integrate with existing proof | Low | Low | Treat as standalone alternative; success criteria is independent proof |

## Implementation Phases

### Phase 1: Directory Structure and Module Scaffold [NOT STARTED]

**Goal**: Establish isolated algebraic module hierarchy with proper imports

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/` directory
- [ ] Create `Algebraic.lean` root module file with imports
- [ ] Create placeholder files for each component module
- [ ] Add `Algebraic` to `Metalogic.lean` imports
- [ ] Verify `lake build` passes with empty modules

**Timing**: 30 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - Root module
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - Quotient construction
- `Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` - Boolean algebra proof
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` - G/H as interior operators
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - Ultrafilter-MCS correspondence
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` - Final theorem

**Verification**:
- `lake build` succeeds
- All new files have proper module headers and imports

---

### Phase 2: Provable Equivalence and Lindenbaum Quotient [NOT STARTED]

**Goal**: Define provable equivalence relation and quotient type, show it's a congruence

**Tasks**:
- [ ] Define `ProvEquiv : Formula -> Formula -> Prop := fun phi psi => Derives phi psi /\ Derives psi phi`
- [ ] Prove `ProvEquiv` is an equivalence relation (refl, symm, trans)
- [ ] Prove `ProvEquiv` respects conjunction: `phi ~ phi' -> psi ~ psi' -> (phi.and psi) ~ (phi'.and psi')`
- [ ] Prove `ProvEquiv` respects disjunction: `phi ~ phi' -> psi ~ psi' -> (phi.or psi) ~ (phi'.or psi')`
- [ ] Prove `ProvEquiv` respects negation: `phi ~ psi -> phi.neg ~ psi.neg`
- [ ] Prove `ProvEquiv` respects implication: `phi ~ phi' -> psi ~ psi' -> (phi.imp psi) ~ (phi'.imp psi')`
- [ ] Define `LindenbaumAlg := Quotient (ProvEquiv.setoid)`
- [ ] Lift lattice operations to quotient

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - All definitions and lemmas

**Verification**:
- `ProvEquiv` is a `Setoid` on `Formula`
- `LindenbaumAlg` type compiles
- Quotient lifts for `and`, `or`, `neg`, `imp` compile without sorry

---

### Phase 3: Boolean Algebra Structure [NOT STARTED]

**Goal**: Prove `LindenbaumAlg` is a `BooleanAlgebra`

**Tasks**:
- [ ] Define lattice order on `LindenbaumAlg`: `[phi] <= [psi] := Derives phi psi`
- [ ] Prove order is well-defined on quotient
- [ ] Prove `LindenbaumAlg` is a `Lattice` (sup = or, inf = and)
- [ ] Define top element `[Truth]` and bottom element `[Falsum]`
- [ ] Prove bounded lattice axioms
- [ ] Define complement operation via negation
- [ ] Prove complement axioms: `a /\ ~a = bot`, `a \/ ~a = top`
- [ ] Prove distributivity: `a /\ (b \/ c) = (a /\ b) \/ (a /\ c)`
- [ ] Assemble `BooleanAlgebra LindenbaumAlg` instance

**Timing**: 2.5-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` - Boolean algebra instance

**Verification**:
- `instance : BooleanAlgebra LindenbaumAlg` compiles without sorry
- Key properties (commutativity, associativity, absorption, distributivity) provable

---

### Phase 4: Temporal Operators as Interior Operators [NOT STARTED]

**Goal**: Define G and H as operators on `LindenbaumAlg` and prove they are interior operators

**Tasks**:
- [ ] Define `InteriorOperator` structure (dual of `ClosureOperator`):
  - Deflationary: `c(a) <= a`
  - Monotone: `a <= b -> c(a) <= c(b)`
  - Idempotent: `c(c(a)) = c(a)`
- [ ] Define `G_quot : LindenbaumAlg -> LindenbaumAlg` via `Quotient.lift`
- [ ] Prove G respects equivalence: `phi ~ psi -> G phi ~ G psi` (from K-axiom)
- [ ] Prove G is deflationary: `[G phi] <= [phi]` (from T-axiom `temp_t_future`)
- [ ] Prove G is monotone: uses K-distribution axiom
- [ ] Prove G is idempotent: `G(G phi) = G phi` (from T4-axiom `temp_4`)
- [ ] Assemble `InteriorOperator` instance for G
- [ ] Symmetric treatment for H (define `H_quot`, prove InteriorOperator)
- [ ] Prove G and H interact correctly (from temporal duality axioms)

**Timing**: 2-2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` - Interior operator definition and instances

**Verification**:
- `InteriorOperator` structure defined
- `instance : InteriorOperator LindenbaumAlg G_quot` compiles
- `instance : InteriorOperator LindenbaumAlg H_quot` compiles
- Key lemmas (deflationary, monotone, idempotent) provable

---

### Phase 5: Ultrafilter-MCS Correspondence [NOT STARTED]

**Goal**: Establish bijection between ultrafilters of `LindenbaumAlg` and maximal consistent sets

**Tasks**:
- [ ] Define `mcs_to_ultrafilter : SetMaximalConsistent Gamma -> Ultrafilter LindenbaumAlg`
  - Map: `Gamma |-> {[phi] | phi in Gamma}`
- [ ] Prove image is a filter (closed under sup, downward closed)
- [ ] Prove image is an ultrafilter (for all a, either a or ~a in filter)
- [ ] Define `ultrafilter_to_mcs : Ultrafilter LindenbaumAlg -> Set Formula`
  - Map: `U |-> {phi | [phi] in U}`
- [ ] Prove image is consistent (does not derive Falsum)
- [ ] Prove image is maximal (deductively closed + complete)
- [ ] Prove `mcs_to_ultrafilter` and `ultrafilter_to_mcs` are inverses
- [ ] Establish `Equiv` between `{Gamma // SetMaximalConsistent Gamma}` and `Ultrafilter LindenbaumAlg`

**Timing**: 2.5-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - Correspondence proof

**Verification**:
- Both directions of correspondence compile
- Bijection is established as `Equiv`
- Interior operator properties transfer to MCS properties

---

### Phase 6: Algebraic Representation Theorem [NOT STARTED]

**Goal**: Prove the representation theorem using algebraic machinery

**Tasks**:
- [ ] Define algebraic canonical frame:
  - Worlds: ultrafilters of `LindenbaumAlg` (equivalently, MCS via correspondence)
  - Task relation: derived from interior operator structure
- [ ] Define algebraic canonical model using the frame
- [ ] State algebraic truth lemma: `[phi] in U <-> truth_at (algebraic_model U) phi`
- [ ] Prove algebraic truth lemma by structural induction on formulas
  - Atomic case: by definition
  - Boolean cases: from Boolean algebra structure
  - Temporal cases: from interior operator properties
- [ ] State algebraic representation theorem:
  - `forall phi, satisfiable phi <-> not (Derives phi.neg)`
- [ ] Prove representation theorem from truth lemma
- [ ] Add documentation explaining relationship to current approach

**Timing**: 2.5-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` - Main theorem

**Verification**:
- `theorem algebraic_representation_theorem` compiles without sorry
- Truth lemma covers all formula constructors
- Documentation explains algebraic vs seed-extension approach

---

## Testing & Validation

- [ ] `lake build` passes with no errors after each phase
- [ ] No sorries remain in Algebraic/ directory
- [ ] Each module has proper imports without circular dependencies
- [ ] Algebraic representation theorem has same statement form as existing theorem
- [ ] Removing `Algebraic/` directory and import does not break existing code

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - Root module
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - Quotient construction
- `Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` - Boolean algebra proof
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` - G/H as interior operators
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - Ultrafilter-MCS correspondence
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` - Final theorem
- `specs/700_research_algebraic_representation_theorem_proof/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the algebraic approach proves infeasible:

1. **Clean removal**: Delete entire `Theories/Bimodal/Metalogic/Algebraic/` directory
2. **Update imports**: Remove `Algebraic` from `Metalogic.lean` imports
3. **Document learnings**: Create summary documenting why approach failed and lessons learned
4. **Preserve for future**: Keep research reports for potential future revisit with better tooling

The existing CoherentConstruction.lean approach remains unchanged and continues to work regardless of algebraic approach outcome.

## Success Criteria

The algebraic approach succeeds if:
1. All 6 phases complete with no sorries
2. `theorem algebraic_representation_theorem` proves the same logical statement as existing approach
3. The proof is self-contained within `Algebraic/` directory
4. Code structure is elegant and well-documented
5. Removal does not break any existing code
