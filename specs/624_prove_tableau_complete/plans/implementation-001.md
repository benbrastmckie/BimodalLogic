# Implementation Plan: Task #624

- **Task**: 624 - Prove tableau_complete
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: Low
- **Dependencies**: Task 623 (expanded - infrastructure partially built)
- **Research Inputs**: specs/624_prove_tableau_complete/reports/research-001.md, specs/738_port_fmp_to_parametric_architecture/reports/research-001.md, specs/738_port_fmp_to_parametric_architecture/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove the `tableau_complete` theorem in `Correctness.lean` connecting FMP to tableau termination. The theorem states that valid formulas have closing tableaux within FMP fuel bounds. The key insight from research is that Metalogic_v2 has more complete infrastructure than Metalogic - specifically `expansion_decreases_measure` (147 lines) and `branchTruthLemma` (140 lines) are fully proven in v2. The implementation strategy is to port/adapt essential lemmas from Metalogic_v2 and use the contrapositive approach: valid implies no satisfiable countermodel implies no open saturated branch.

### Research Integration

- **Research 624-001**: Identified that Metalogic has `sorry` for `expansion_decreases_measure` (line 217-221) while Metalogic_v2 has it proven (lines 969-1101). The `branchTruthLemma` in Metalogic is trivial (returns True) while v2 has substantive implementation.
- **Research 738-001**: Documented the FMP infrastructure relationship - closure definitions port directly, the 2^closureSize bound is combinatorial (no duration type involved).
- **Research 738-002**: Detailed the FMP-Tableau connection: fuel = 2^closureSize * 2 guarantees termination.

## Goals & Non-Goals

**Goals**:
- Prove `tableau_complete` theorem showing valid formulas have closing tableaux
- Port `expansion_decreases_measure` from Metalogic_v2 to Metalogic
- Port/adapt `branchTruthLemma` with its helper lemmas from Metalogic_v2
- Define `fmpBasedFuel` if not already present
- All proofs compile without `sorry`

**Non-Goals**:
- Full parametric port of FMP (that's Task 738)
- Countermodel extraction completeness (only need contrapositive)
- Full semantic bridge to `truth_at` (not needed for validity direction)
- Proving `decide_complete` (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Port complexity for `expansion_decreases_measure` | High | Medium | Follow v2 proof structure closely; port helper lemmas first |
| Namespace/import conflicts between Metalogic and Metalogic_v2 | Medium | Medium | Use qualified imports; test compilation incrementally |
| Helper lemmas missing in Metalogic | Medium | High | Port necessary helpers: `saturation_contradiction`, `isExpanded_*_false`, `open_branch_consistent` |
| Proof details differ due to different type definitions | Medium | Low | Carefully compare SignedFormula/Branch definitions; adapt as needed |

## Implementation Phases

### Phase 1: Port Helper Lemmas for Saturation [NOT STARTED]

**Goal**: Port the helper lemmas from Metalogic_v2 that support `expansion_decreases_measure`.

**Tasks**:
- [ ] Review and compare `Saturation.lean` helper lemmas between Metalogic and Metalogic_v2
- [ ] Port `expansionMeasure_filter_unexpanded` lemma
- [ ] Port `expansionMeasure_new_le_totalComplexity` lemma
- [ ] Port `applyRule_decreases_complexity` lemma
- [ ] Port `unexpanded_contributes` lemma
- [ ] Port `findApplicableRule_spec` lemma
- [ ] Verify helpers compile and integrate with existing Metalogic definitions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Saturation.lean` - add helper lemmas

**Verification**:
- Run `lake build Bimodal.Boneyard.Metalogic.Decidability.Saturation`
- All helper lemmas compile without `sorry`

---

### Phase 2: Prove expansion_decreases_measure [NOT STARTED]

**Goal**: Complete the proof of `expansion_decreases_measure` using the ported helper lemmas.

**Tasks**:
- [ ] Review v2 proof structure (lines 969-1101 in v2/Saturation.lean)
- [ ] Adapt proof for Metalogic's type definitions
- [ ] Handle linear expansion case (formulas ++ remaining)
- [ ] Handle branching expansion case (each branch in branches.map)
- [ ] Handle notApplicable case (should be contradictory)
- [ ] Verify omega tactic succeeds for arithmetic conclusions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Saturation.lean` - replace `sorry` at line 221

**Verification**:
- Run `lake build Bimodal.Boneyard.Metalogic.Decidability.Saturation`
- `expansion_decreases_measure` compiles without `sorry`

---

### Phase 3: Port branchTruthLemma Infrastructure [NOT STARTED]

**Goal**: Port the helper lemmas from Metalogic_v2 that support `branchTruthLemma`.

**Tasks**:
- [ ] Port `isExpanded_pos_imp_false` and similar `isExpanded_*_false` lemmas
- [ ] Port `saturation_contradiction` helper lemma
- [ ] Port `open_branch_consistent` lemma from BranchClosure.lean (or verify it exists)
- [ ] Review `evalFormula` and `extractValuation` compatibility
- [ ] Verify all helpers compile

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/CountermodelExtraction.lean` or create new helper file
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/BranchClosure.lean` - add consistency lemma if needed

**Verification**:
- Run `lake build` for affected modules
- All helper lemmas compile without `sorry`

---

### Phase 4: Implement branchTruthLemma [NOT STARTED]

**Goal**: Replace the trivial `branchTruthLemma` with a substantive implementation.

**Tasks**:
- [ ] Locate current `branchTruthLemma` definition in Metalogic (may be in Saturation.lean or separate)
- [ ] Implement positive case: T(phi) in branch implies evalFormula = true
- [ ] Implement negative case: F(phi) in branch implies evalFormula = false
- [ ] Handle all formula cases: atom, bot, imp, box, all_future, all_past
- [ ] Use saturation_contradiction for compound formulas
- [ ] Use open_branch_consistent for atom consistency

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/CountermodelExtraction.lean` or equivalent location

**Verification**:
- Run `lake build` for affected modules
- `branchTruthLemma` compiles without `sorry`
- Theorem provides meaningful semantic content (not trivially True)

---

### Phase 5: Define fmpBasedFuel and Prove tableau_complete [NOT STARTED]

**Goal**: Complete the main `tableau_complete` theorem.

**Tasks**:
- [ ] Define `fmpBasedFuel (phi : Formula) : Nat := 2 ^ closureSizeOf phi * 2`
- [ ] Define `closureSizeOf` if not present (use subformula list length)
- [ ] Implement `tableau_complete` proof:
  - [ ] Introduce validity hypothesis
  - [ ] Use `fmpBasedFuel phi` as witness fuel
  - [ ] Prove `buildTableau` terminates with sufficient fuel (uses expansion_decreases_measure)
  - [ ] Prove result is valid via case analysis on ExpandedTableau
  - [ ] For `hasOpen` case: derive contradiction via branchTruthLemma and validity
- [ ] Verify theorem compiles without `sorry`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/SignedFormula.lean` - add fmpBasedFuel if needed
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean` - replace sorry at line 82

**Verification**:
- Run `lake build Bimodal.Boneyard.Metalogic.Decidability.Correctness`
- `tableau_complete` compiles without `sorry`
- Comment reflects proof complete (not "Requires FMP-based termination proof")

---

## Testing & Validation

- [ ] `lake build` succeeds for entire Metalogic/Decidability module
- [ ] No `sorry` in `expansion_decreases_measure`
- [ ] No `sorry` in `branchTruthLemma` (or equivalent)
- [ ] No `sorry` in `tableau_complete`
- [ ] Check `#check tableau_complete` shows correct type signature
- [ ] Verify theorem can be used: create simple test case if time permits

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Saturation.lean` - updated with helper lemmas and proven `expansion_decreases_measure`
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/CountermodelExtraction.lean` - substantive `branchTruthLemma` (or location varies)
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean` - proven `tableau_complete`
- `specs/624_prove_tableau_complete/summaries/implementation-summary-YYYYMMDD.md` - implementation summary

## Rollback/Contingency

If porting proves too complex:
1. Preserve partial progress by committing helper lemmas separately
2. Document remaining gaps in file comments
3. Consider alternative: import from Metalogic_v2 directly via qualified namespace
4. If structural mismatches prevent direct port, document differences and recommend architectural decision (keep Metalogic vs deprecate in favor of v2)

All changes are additive (new lemmas) or filling existing sorries - no destructive changes to existing proven code.
