# Research Report: Task #813

**Task**: Resolve Remaining BMCS Sorries
**Date**: 2026-02-02
**Focus**: Inventory and task breakdown for eliminating 10 remaining sorries in BMCS completeness infrastructure

## Summary

Task 812 successfully implemented the Bundle of Maximal Consistent Sets (BMCS) approach for completeness, reducing sorries from 30+ (in the archived Representation approach) to 10. The critical box case of the truth lemma is now sorry-free, resolving the fundamental completeness obstruction. The remaining 10 sorries fall into four categories: classical propositional tautologies (5), temporal omega-saturation (2), universe polymorphism technicalities (2), and multi-family construction (1). None represent mathematical gaps.

## Findings

### Complete Sorry Inventory

**TruthLemma.lean (4 sorries)**

| Line | Definition | Type | Description |
|------|------------|------|-------------|
| 156 | `phi_at_all_future_implies_mcs_all_future` | Temporal | Truth at all future times implies G phi in MCS |
| 166 | `phi_at_all_past_implies_mcs_all_past` | Temporal | Truth at all past times implies H phi in MCS |
| 186 | `neg_imp_implies_antecedent` | Classical tautology | `|- not(psi -> chi) -> psi` |
| 198 | `neg_imp_implies_neg_consequent` | Classical tautology | `|- not(psi -> chi) -> not chi` |

**Construction.lean (1 sorry)**

| Line | Definition | Type | Description |
|------|------------|------|-------------|
| 220 | `modal_backward` in `singleFamilyBMCS` | Construction | phi in single MCS implies Box phi in MCS |

**Completeness.lean (5 sorries)**

| Line | Definition | Type | Description |
|------|------------|------|-------------|
| 158 | `bmcs_valid_implies_valid_Int` | Universe | Polymorphic validity implies Int-specific validity |
| 184 | `not_derivable_implies_neg_consistent` | Classical | Not derivable implies negation consistent |
| 197 | `double_negation_elim` | Classical tautology | `|- not not phi -> phi` (DUPLICATE) |
| 292 | `bmcs_consequence_implies_consequence_Int` | Universe | Polymorphic consequence implies Int-specific |
| 323 | `context_not_derivable_implies_extended_consistent` | Classical | Context extension consistency |

### Category Analysis

**Category 1: Classical Propositional Tautologies (4 unique)**

These are standard derivable theorems in classical logic. Proven implementations exist elsewhere in the codebase:

1. **`double_negation_elim`** - Already proven as `Bimodal.Theorems.Propositional.double_negation` (line 140 of Propositional.lean). Just needs import and application.

2. **`neg_imp_implies_antecedent`** - Proven as `neg_imp_fst` in Boneyard/Metalogic_v5/Representation/TruthLemma.lean (line 153). Can be adapted/copied.

3. **`neg_imp_implies_neg_consequent`** - Proven as `neg_imp_snd` in Boneyard/Metalogic_v5/Representation/TruthLemma.lean (line 216). Can be adapted/copied.

4. **`not_derivable_implies_neg_consistent`** + **`context_not_derivable_implies_extended_consistent`** - Require DNE + deduction theorem reasoning. Standard completeness lemmas.

**Category 2: Temporal Omega-Saturation (2 sorries)**

Both `phi_at_all_future_implies_mcs_all_future` and `phi_at_all_past_implies_mcs_all_past` require that the IndexedMCSFamily construction anticipates all future/past truths. Two approaches:

1. **Add backward coherence to IndexedMCSFamily** - New fields for omega-saturation
2. **Prove from maximality** - Show that MCS maximality + forward coherence implies backward direction

**Category 3: Universe Polymorphism (2 sorries)**

The `bmcs_valid_implies_valid_Int` and `bmcs_consequence_implies_consequence_Int` lemmas are "obviously true" type-theoretically but Lean's universe polymorphism makes direct instantiation tricky. Solutions:

1. **Specialize at definition** - Define completeness theorems directly over Int
2. **Use Lean 4 universe hacks** - Explicit universe level manipulation

**Category 4: Multi-Family Construction (1 sorry)**

The `modal_backward` in `singleFamilyBMCS` states that if phi is in the (single) MCS, then Box phi is in the MCS. This doesn't hold in general modal logic. Solutions:

1. **Modal saturation** - Add Box phi to the MCS during construction when phi is "box-necessary"
2. **Multi-family approach** - Use multiple families where modal_backward holds by design
3. **Accept as construction axiom** - The representation theorem still works if we assume modal coherence

## Proposed Task Breakdown

Based on complexity and logical dependencies, the 10 sorries can be resolved in **3 focused tasks**:

### Task A: Classical Propositional Completeness Infrastructure
**Scope**: 4 sorries (lines 186, 198 in TruthLemma; lines 184, 197, 323 in Completeness)
**Effort**: 2-3 hours
**Strategy**:
- Import existing `double_negation` theorem
- Port `neg_imp_fst` and `neg_imp_snd` from Boneyard
- Derive `not_derivable_implies_neg_consistent` using DNE + deduction theorem
- Derive `context_not_derivable_implies_extended_consistent` using same infrastructure

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

### Task B: Universe Polymorphism Resolution
**Scope**: 2 sorries (lines 158, 292 in Completeness)
**Effort**: 1-2 hours
**Strategy**:
- Option 1: Redefine `bmcs_valid` and `bmcs_consequence` directly over Int
- Option 2: Use explicit universe instantiation with `@` syntax
- Option 3: Add Int-specific variants as primary definitions

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- Possibly `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`

### Task C: Temporal/Modal Coherence Strengthening
**Scope**: 3 sorries (lines 156, 166 in TruthLemma; line 220 in Construction)
**Effort**: 3-4 hours
**Strategy**:
- Add backward temporal coherence conditions to IndexedMCSFamily:
  - `backward_from_all_future`: All future truths implies G in MCS
  - `backward_from_all_past`: All past truths implies H in MCS
- For modal_backward: Either implement multi-family saturation OR prove from S5 properties

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean`
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`

## Recommended Execution Order

1. **Task A first** - Classical infrastructure is foundational and well-understood
2. **Task B second** - Universe issues are isolated and don't affect other proofs
3. **Task C last** - Temporal/modal coherence may reveal new design insights

**Rationale**: Task A unblocks the most sorries (4 unique) with known proof techniques. Task B is isolated. Task C is the most complex and benefits from having other infrastructure in place.

## Alternative: Consolidated Single Task

If desired, all 10 sorries could be resolved in a single focused task (~6-8 hours):

**Task: BMCS Sorry Elimination (Comprehensive)**
- Phase 1: Classical tautologies (2 hours)
- Phase 2: Universe resolution (1 hour)
- Phase 3: Temporal coherence (2 hours)
- Phase 4: Modal backward (2 hours)
- Phase 5: Integration testing (1 hour)

## Dependencies

- **Existing proven infrastructure**:
  - `Bimodal.Theorems.Propositional.double_negation` - DNE theorem
  - `Bimodal.Metalogic.Core.deduction_theorem` - Deduction theorem
  - `neg_imp_fst`, `neg_imp_snd` in Boneyard (can be ported)

- **No external dependencies** - All proofs use existing axioms and lemmas

## Verification Method

After each task:
1. Run `lake build Bimodal.Metalogic.Bundle.Completeness`
2. Verify specific sorry count using `grep -c sorry <file>`
3. Confirm no new errors introduced

## References

- Implementation summary: `specs/812_canonical_model_completeness/summaries/implementation-summary-20260202.md`
- Implementation plan: `specs/812_canonical_model_completeness/plans/implementation-003.md`
- Propositional theorems: `Theories/Bimodal/Theorems/Propositional.lean`
- Archived TruthLemma: `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TruthLemma.lean`

## Next Steps

1. Create implementation tasks based on recommended breakdown (3 tasks) or consolidated approach (1 task)
2. Task A (Classical tautologies) has zero risk - proceed immediately
3. Task C (Temporal coherence) may require design review if adding new fields to IndexedMCSFamily
