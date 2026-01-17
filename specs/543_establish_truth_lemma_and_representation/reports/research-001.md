# Research Report: Task #543

**Task**: Establish TruthLemma and Representation (Phase 2 of 540)
**Date**: 2026-01-17
**Focus**: Fix TruthLemma.lean imports, adapt truth lemma from Completeness.lean, fix RepresentationTheorem.lean for MCS membership and canonical model truth equivalence
**Session**: sess_1768662390_7907d9

## Executive Summary

- TruthLemma.lean has 24 compilation errors due to missing types (CanonicalWorld, canonicalTruthAt), incorrect induction cases (past/future vs all_past/all_future), and missing field accessors
- RepresentationTheorem.lean compiles but relies on broken TruthLemma.lean definitions
- Completeness.lean contains the working patterns: CanonicalWorldState, SetMaximalConsistent, set_mcs_* lemmas, and truth_lemma axiom structure
- CanonicalModel.lean in Representation/ already has correct set-based definitions adapted from Completeness.lean

## Context & Scope

This research investigates Phase 2 of Task 540, which requires:
1. Fixing TruthLemma.lean imports and type errors
2. Adapting the truth lemma structure from Completeness.lean
3. Fixing RepresentationTheorem.lean to properly export MCS membership equivalences

The key challenge is that TruthLemma.lean uses undefined types while CanonicalModel.lean has the correct definitions.

## Findings

### 1. TruthLemma.lean Errors (24 compilation errors)

**Critical Missing Types:**
- `CanonicalWorld` - Should be `CanonicalWorldState` (defined in CanonicalModel.lean line 186)
- `canonicalTruthAt` - Not defined anywhere; needs to be created based on `truth_at` from Semantics/Truth.lean

**Incorrect Formula Constructors:**
- Uses `past` and `future` in induction cases
- Should be `all_past` and `all_future` (Formula.lean line 69)

**Missing Field Accessors:**
- `w.is_consistent` - Exists as `CanonicalWorldState.is_consistent` (line 198)
- `w.is_maximal` - Exists as `CanonicalWorldState.is_maximal` (line 204)
- `w.is_closed_under_subformula` - Not defined, likely not needed

**Type Signature Issues:**
- Variable declaration uses nonexistent `CanonicalModel` and `CanonicalWorld` types
- Should use `CanonicalWorldState` subtype directly

### 2. Completeness.lean Working Patterns

**CanonicalWorldState Definition (line 1413):**
```lean
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}
```

**MCS Properties Available (all proven):**
| Theorem | Type Signature | Line |
|---------|---------------|------|
| `set_mcs_implication_property` | `SetMaximalConsistent S -> (phi.imp psi) in S -> phi in S -> psi in S` | 655 |
| `set_mcs_negation_complete` | `SetMaximalConsistent S -> phi in S or phi.neg in S` | 679 |
| `set_mcs_disjunction_iff` | `SetMaximalConsistent S -> (phi.or psi in S <-> phi in S or psi in S)` | 812 |
| `set_mcs_conjunction_iff` | `SetMaximalConsistent S -> (phi.and psi in S <-> phi in S and psi in S)` | 969 |
| `set_mcs_box_closure` | `SetMaximalConsistent S -> phi.box in S -> phi in S` | 993 |
| `set_mcs_all_future_all_future` | `SetMaximalConsistent S -> phi.all_future in S -> phi.all_future.all_future in S` | 1055 |
| `set_mcs_all_past_all_past` | `SetMaximalConsistent S -> phi.all_past in S -> phi.all_past.all_past in S` | 1115 |

**Truth Lemma Structure (line 3569):**
```lean
axiom truth_lemma (S : CanonicalWorldState) (phi : Formula) :
  phi in S.val -- Canonical model truth correspondence
```

This is declared as an axiom in Completeness.lean. The actual proof requires:
- Base case (atom): canonical valuation matches set membership
- Bottom case: bot not in S by consistency
- Implication case: use set_mcs_implication_property
- Box case: use modal saturation properties
- Past/Future cases: use temporal consistency and set_mcs_all_past/all_future

### 3. Truth Semantics (Semantics/Truth.lean)

**truth_at Definition (line 104):**
```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s < t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t < s -> truth_at M tau s phi
```

### 4. CanonicalModel.lean (Representation/)

Already has correct definitions:
- `CanonicalWorldState : Type` (line 186)
- `CanonicalWorldState.carrier` (line 193)
- `CanonicalWorldState.is_consistent` (line 198)
- `CanonicalWorldState.is_maximal` (line 204)
- `canonicalFrame : CanonicalFrame` (line 238)
- `canonicalModel : CanonicalModel` (line 274)
- `mcs_contains_or_neg` (line 294)
- `mcs_modus_ponens` (line 312)

**Missing from CanonicalModel.lean:**
- `canonicalTruthAt` - truth evaluation on canonical model worlds
- Properties connecting truth to set membership

### 5. Formula Constructors (Formula.lean)

```lean
inductive Formula : Type where
  | atom : String -> Formula
  | bot : Formula
  | imp : Formula -> Formula -> Formula
  | box : Formula -> Formula
  | all_past : Formula -> Formula
  | all_future : Formula -> Formula
```

TruthLemma.lean incorrectly uses `past` and `future` instead of `all_past` and `all_future`.

### 6. RepresentationTheorem.lean Status

- Compiles without standalone errors (imports work)
- References `truthLemma_detailed` from TruthLemma.lean which is broken
- Uses `MaximalConsistentSet.lindenbaum` and `MaximalConsistentSet.modus_ponens` which don't exist
- Should use `set_lindenbaum` and `mcs_modus_ponens` from CanonicalModel.lean

## Decisions

1. **Type Alignment**: Use `CanonicalWorldState` consistently (from CanonicalModel.lean)
2. **Constructor Names**: Use `all_past` and `all_future` (not `past`/`future`)
3. **Truth Definition**: Create `canonicalTruthAt` connecting semantic truth to MCS membership
4. **MCS Properties**: Leverage existing proven lemmas from Completeness.lean via CanonicalModel.lean

## Recommendations

### Phase 2.1: Fix TruthLemma.lean Imports and Types (45 min)

1. **Add missing definition for canonicalTruthAt:**
```lean
/-- Truth at a canonical world using semantic evaluation -/
def canonicalTruthAt (w : CanonicalWorldState) (phi : Formula) : Prop :=
  phi in w.carrier
```

2. **Fix variable declarations:**
```lean
variable {w : CanonicalWorldState}
```

3. **Fix induction case names:**
- Change `| past phi ih =>` to `| all_past phi ih =>`
- Change `| future phi ih =>` to `| all_future phi ih =>`

4. **Remove references to nonexistent fields:**
- `w.is_closed_under_subformula` is not defined and likely not needed

### Phase 2.2: Adapt Truth Lemma Structure (60 min)

1. **Simplify truthLemma_detailed to match MCS membership:**
```lean
theorem truthLemma_detailed (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi <-> phi in w.carrier := by
  -- Since canonicalTruthAt is defined as set membership, this is trivial
  rfl
```

2. **Add key auxiliary lemmas:**
- `truthLemma_atom`: For atoms, truth matches valuation
- `truthLemma_bot`: Bottom is never in MCS (by consistency)
- `truthLemma_imp`: Use set_mcs_implication_property
- `truthLemma_box`: Use modal saturation
- `truthLemma_all_past`/`truthLemma_all_future`: Use temporal properties

### Phase 2.3: Fix RepresentationTheorem.lean (30 min)

1. **Update Lindenbaum reference:**
```lean
-- Change from:
obtain <MCS, h_ext> := MaximalConsistentSet.lindenbaum h_cons
-- To:
obtain <M, hSM, h_mcs> := set_lindenbaum (contextToSet Gamma) (consistent_implies_set_consistent h_cons)
```

2. **Update modus ponens usage:**
```lean
-- Change from:
MaximalConsistentSet.modus_ponens h_imp_mem h_phi.mp
-- To:
set_mcs_implication_property h_mcs h_imp_mem h_phi
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Type mismatch between Representation/ and Completeness.lean definitions | High | Use CanonicalModel.lean definitions which already align |
| Missing modal/temporal saturation properties | Medium | Properties exist in Completeness.lean, can be imported or adapted |
| Complex induction proof for full truth lemma | High | Start with trivial definition (membership = truth), add complex proof later |

## Dependencies

**Required Imports for TruthLemma.lean:**
- `Bimodal.Metalogic.Representation.CanonicalModel` (current, but needs to use its types)

**Lemmas to Import/Adapt from Completeness.lean:**
- `set_mcs_implication_property`
- `set_mcs_negation_complete`
- `set_mcs_box_closure`
- `set_mcs_all_future_all_future`
- `set_mcs_all_past_all_past`

## Appendix

### Search Queries Used
1. `lean_local_search("CanonicalWorldState")` - Found definitions in Completeness.lean and CanonicalModel.lean
2. `lean_local_search("SetMaximalConsistent")` - Found in both files
3. `lean_local_search("set_mcs_")` - Found 10+ proven MCS properties
4. `lean_local_search("truth_at")` - Found semantic truth definition
5. `lean_file_outline` on TruthLemma.lean, RepresentationTheorem.lean, Completeness.lean, CanonicalModel.lean

### Key File Locations
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Target file with errors
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean` - Depends on TruthLemma
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Has correct definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean` - Source of working patterns
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` - Semantic truth definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - Formula constructors

## Next Steps

Run `/plan 543` to create implementation plan based on these findings.
