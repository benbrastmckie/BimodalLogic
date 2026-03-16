# Research Report: Namespace Migration Opportunities in Metalogic

**Task**: 972 - Review Metalogic Naming Conventions
**Session**: sess_1773677328_11daf7
**Date**: 2026-03-16
**Status**: Complete

## Executive Summary

This report identifies potential namespace migrations in `Theories/Bimodal/Metalogic/` that could improve code clarity by leveraging Lean's dot notation. The analysis found **four primary prefix patterns** as migration candidates, with varying levels of recommendation based on impact and Mathlib alignment.

## Analysis Methodology

1. Searched for function/theorem declarations with type-based prefixes
2. Counted call sites to assess migration impact
3. Reviewed existing namespace conventions in the codebase
4. Compared against Mathlib patterns (particularly `Ultrafilter`, `Filter`, `IsChain`)

## Findings Summary

| Prefix Pattern | Count | Files | Recommendation |
|----------------|-------|-------|----------------|
| `set_mcs_*` | ~16 defs, 242 usages | 19 | **High Priority** |
| `mcs_*` | ~16 defs, 639 usages | 34 | **Medium Priority** |
| `canonical_*` | ~18 defs, 135 usages | 16 | **Low Priority** |
| `staged_*` | 6 defs, 18 usages | 4 | **Not Recommended** |

---

## High Priority Candidates

### 1. `set_mcs_*` Functions -> `SetMaximalConsistent.*`

**Current Pattern:**
```lean
-- In Bimodal.Metalogic.Core
lemma set_mcs_closed_under_derivation {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) ...

theorem set_mcs_implication_property {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) ...
```

**Proposed Pattern:**
```lean
namespace SetMaximalConsistent

lemma closed_under_derivation {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) ...

theorem implication_property {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) ...

end SetMaximalConsistent
```

**Rationale:**
- `SetMaximalConsistent` is a predicate on `Set Formula`
- All `set_mcs_*` functions take `(h_mcs : SetMaximalConsistent S)` as first explicit argument
- Enables dot notation: `h_mcs.closed_under_derivation` instead of `set_mcs_closed_under_derivation h_mcs`
- Follows Mathlib convention (cf. `Ultrafilter.mem_or_compl_mem`)

**Candidates:**
| Current Name | Proposed Name | Location |
|--------------|---------------|----------|
| `set_mcs_closed_under_derivation` | `SetMaximalConsistent.closed_under_derivation` | MCSProperties.lean |
| `set_mcs_implication_property` | `SetMaximalConsistent.implication_property` | MCSProperties.lean |
| `set_mcs_negation_complete` | `SetMaximalConsistent.negation_complete` | MCSProperties.lean |
| `set_mcs_all_future_all_future` | `SetMaximalConsistent.all_future_all_future` | MCSProperties.lean |
| `set_mcs_all_past_all_past` | `SetMaximalConsistent.all_past_all_past` | MCSProperties.lean |
| `set_mcs_neg_excludes` | `SetMaximalConsistent.neg_excludes` | MCSProperties.lean |
| `set_mcs_finite_subset_consistent` | `SetMaximalConsistent.finite_subset_consistent` | MaximalConsistent.lean |
| `set_mcs_disjunction_intro` | `SetMaximalConsistent.disjunction_intro` | Completeness.lean |
| `set_mcs_disjunction_elim` | `SetMaximalConsistent.disjunction_elim` | Completeness.lean |
| `set_mcs_disjunction_iff` | `SetMaximalConsistent.disjunction_iff` | Completeness.lean |
| `set_mcs_conjunction_intro` | `SetMaximalConsistent.conjunction_intro` | Completeness.lean |
| `set_mcs_conjunction_elim` | `SetMaximalConsistent.conjunction_elim` | Completeness.lean |
| `set_mcs_conjunction_iff` | `SetMaximalConsistent.conjunction_iff` | Completeness.lean |
| `set_mcs_box_closure` | `SetMaximalConsistent.box_closure` | Completeness.lean |
| `set_mcs_box_box` | `SetMaximalConsistent.box_box` | Completeness.lean |
| `set_mcs_diamond_box_duality` | `SetMaximalConsistent.diamond_box_duality` | Completeness.lean |

**Migration Impact:** 242 call site changes across 19 files

**Note:** `SetMaximalConsistent` is a `def` (predicate), not a `structure`. In Lean 4/Mathlib, predicates often use namespaces for their lemmas (e.g., `Continuous.*`, `Injective.*`).

---

## Medium Priority Candidates

### 2. `mcs_*` Functions (Set-based MCS properties)

**Context:** These are similar to `set_mcs_*` but without the `set_` prefix. They appear throughout the codebase with the pattern `(h_mcs : SetMaximalConsistent M)`.

**Current Pattern:**
```lean
lemma mcs_contrapositive {S : Set Formula} (h_mcs : SetMaximalConsistent S) ...
lemma mcs_F_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M) ...
```

**Proposed Pattern:**
```lean
namespace SetMaximalConsistent

lemma contrapositive {S : Set Formula} (self : SetMaximalConsistent S) ...
lemma F_linearity (M : Set Formula) (self : SetMaximalConsistent M) ...

end SetMaximalConsistent
```

**Candidates:**
| Current Name | Proposed Name | Location |
|--------------|---------------|----------|
| `mcs_contrapositive` | `SetMaximalConsistent.contrapositive` | ModalSaturation.lean |
| `mcs_neg_box_implies_box_neg_box` | `SetMaximalConsistent.neg_box_implies_box_neg_box` | ModalSaturation.lean |
| `mcs_F_linearity` | `SetMaximalConsistent.F_linearity` | ConstructiveFragment.lean |
| `mcs_P_linearity` | `SetMaximalConsistent.P_linearity` | ConstructiveFragment.lean |
| `mcs_double_neg_elim` | `SetMaximalConsistent.double_neg_elim` | TemporalCoherence.lean |
| `mcs_contains_seriality_future` | `SetMaximalConsistent.contains_seriality_future` | CanonicalTimeline.lean |
| `mcs_contains_seriality_past` | `SetMaximalConsistent.contains_seriality_past` | CanonicalTimeline.lean |
| `mcs_has_canonical_successor` | `SetMaximalConsistent.has_canonical_successor` | CanonicalTimeline.lean |
| `mcs_has_canonical_predecessor` | `SetMaximalConsistent.has_canonical_predecessor` | CanonicalTimeline.lean |
| `mcs_ultrafilter_correspondence` | `SetMaximalConsistent.ultrafilter_correspondence` | UltrafilterMCS.lean |
| `mcs_has_strict_future` | `SetMaximalConsistent.has_strict_future` | SeparationLemma.lean |
| `mcs_has_strict_past` | `SetMaximalConsistent.has_strict_past` | SeparationLemma.lean |
| `mcs_density_F_to_FF` | `SetMaximalConsistent.density_F_to_FF` | CantorPrereqs.lean |
| `mcs_density_P_to_PP` | `SetMaximalConsistent.density_P_to_PP` | CantorPrereqs.lean |

**Migration Impact:** 639 occurrences across 34 files (but many are usages of the above 16 definitions)

**Note:** Some `mcs_*` names refer to FMCS operations (e.g., `fam.mcs t`), not `SetMaximalConsistent`. These should NOT be migrated. Careful filtering required.

---

## Low Priority Candidates

### 3. `canonical_*` Functions

**Context:** These functions relate to canonical model construction but do NOT have a consistent first argument type. They operate on various types (`Set Formula`, `CanonicalWorldState`, etc.).

**Current Pattern:**
```lean
theorem canonical_truth_lemma ...
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) ...
theorem canonical_forward_G (M M' : Set Formula) ...
```

**Analysis:** The `canonical_` prefix is descriptive (describes the domain) rather than type-redundant. These functions do not share a common first argument type that would enable dot notation.

**Recommendation:** **LOW PRIORITY** - Consider keeping as-is. The prefix describes the conceptual domain (canonical model construction) rather than duplicating a type name.

**Exception:** `canonical_task_rel` and related definitions that take `CanonicalWorldState` as first argument could move to a `CanonicalWorldState` namespace:
- `canonical_task_rel` -> `CanonicalWorldState.task_rel`
- `canonical_task_rel_nullity_identity` -> `CanonicalWorldState.task_rel_nullity_identity`

---

## Not Recommended

### 4. `staged_*` Functions

**Context:** These appear only in `StagedConstruction/CantorPrereqs.lean` and describe properties of staged timeline construction.

**Current Pattern:**
```lean
theorem staged_has_future ...
theorem staged_timeline_nonempty ...
theorem staged_timeline_countable ...
```

**Analysis:**
- Only 6 definitions, 18 total usages
- No consistent first argument type
- The prefix describes the construction method, not a type

**Recommendation:** **NOT RECOMMENDED** - The prefix is conceptually meaningful and the low usage count does not justify the migration cost.

---

## Existing Namespace Usage (Reference)

The codebase already uses type namespaces correctly in several places:

| Type | Namespace Used | Example |
|------|----------------|---------|
| `ExtFormula` | Yes | `namespace ExtFormula` in ExtFormula.lean |
| `SignedFormula` | Yes | `namespace SignedFormula` in SignedFormula.lean |
| `Sign` | Yes | `namespace Sign` in SignedFormula.lean |
| `Branch` | Yes | `namespace Branch` in SignedFormula.lean |
| `ExpandedTableau` | Yes | `namespace ExpandedTableau` in Saturation.lean |
| `DecisionResult` | Yes | `namespace DecisionResult` in DecisionProcedure.lean |
| `ClosureReason` | Yes | `namespace ClosureReason` in Closure.lean |
| `BFMCS` | Partial | `BFMCS.consistent`, `BFMCS.reflexivity` |
| `FMCS` | No | Functions defined in Bundle namespace |

The Decidability module shows good namespace hygiene. The Core and Completeness modules show the prefix pattern.

---

## Mathlib Alignment Analysis

Mathlib uses type namespaces extensively for predicates and structures:

| Mathlib Pattern | Example |
|-----------------|---------|
| `Ultrafilter.mem_or_compl_mem` | Lemma about Ultrafilter membership |
| `Continuous.comp` | Lemma about Continuous composition |
| `Injective.comp` | Lemma about Injective composition |
| `Filter.mem_iff_ultrafilter` | Cross-type lemma |
| `IsChain.total` | Lemma on IsChain predicate |

The `SetMaximalConsistent` -> `SetMaximalConsistent.*` migration aligns with this pattern.

---

## Implementation Recommendations

### Phase 1: High Priority (Low Risk)
1. Create `namespace SetMaximalConsistent` sections in:
   - `Core/MCSProperties.lean`
   - `Core/MaximalConsistent.lean`
2. Move `set_mcs_*` definitions into namespace
3. Add aliases for backward compatibility (optional)
4. Update 19 files with call site changes

### Phase 2: Medium Priority (Medium Risk)
1. Move `mcs_*` definitions that have `SetMaximalConsistent` as first argument
2. Update 34 files with call site changes
3. **Carefully filter:** Do not migrate FMCS-related `mcs` uses (e.g., `fam.mcs t`)

### Phase 3: Optional Low Priority
1. Consider `CanonicalWorldState` namespace for related definitions
2. Evaluate based on Phase 1/2 experience

### Migration Strategy
For each phase:
1. Create namespace wrapper in source file
2. Move definitions inside namespace (remove prefix)
3. Add deprecated alias outside namespace for transition period
4. Run `lake build` to identify all call sites
5. Update call sites to use dot notation where applicable
6. Remove deprecated aliases after verification

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Breaking changes | Add deprecated aliases during transition |
| Large diff size | Split into phases by file |
| Name collisions | Check for existing namespace members |
| Dot notation ambiguity | Ensure hypothesis names are consistent (e.g., `h_mcs`) |

---

## Appendix: Files Affected by set_mcs_* Migration

```
Theories/Bimodal/Metalogic/Completeness.lean (45 occurrences)
Theories/Bimodal/Metalogic/Bundle/BFMCS.lean (1)
Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean (5)
Theories/Bimodal/Metalogic/Core/MCSProperties.lean (17)
Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean (12)
Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean (3)
Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean (14)
Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean (1)
Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean (2)
Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean (15)
Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean (4)
Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean (52)
Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean (4)
Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean (1)
Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean (52)
Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean (3)
Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean (2)
Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean (3)
```

---

## Conclusion

The highest-value migration is moving `set_mcs_*` functions into a `SetMaximalConsistent` namespace. This:
- Follows Mathlib conventions
- Enables cleaner dot notation
- Affects a well-defined set of 16 definitions
- Has clear first-argument type pattern

The `mcs_*` prefix migration requires more careful analysis to separate `SetMaximalConsistent` properties from FMCS-related operations.

The `canonical_*` and `staged_*` prefixes are conceptually meaningful rather than type-redundant and should likely remain as-is.
