# Implementation Plan: Task #157 -- Self-Contained Oracle Elimination (v26)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [BLOCKED]
- **Effort**: 8 hours
- **Dependencies**: Phase A completed (plan v22)
- **Research Inputs**: reports/24_blocker-research.md, handoffs/phase-1-handoff-20260519.md, handoffs/phase-2-blocked-20260519.md
- **Artifacts**: plans/25_revised-oracle-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## STRICT COMPLIANCE CONTRACT

### Absolute Prohibitions

1. **NO `all_separable` / `snce_separable` / `untl_separable` / `all_past_separable` / `all_future_separable`**: Axiom-backed. Never reference in new code.
2. **NO `sorry`**.
3. **NO vacuous definitions** (`def X := True`).
4. **NO modifying `snce_depth_of_U`, `junction_depth`, or `count_U_subformulas` definitions**.

### Escalation Protocol

If stuck >20 minutes: write handoff to `specs/157_.../handoffs/`, mark phase `[BLOCKED]`.

---

## Overview

Plan v25 failed because Case 2 introduces U-types `(neg A, top)` via `all_future`, breaking `has_single_U_type` preservation. Plan v26 abandons single-U-type preservation entirely.

The existing `all_formulas_separable_aux` works for JD >= 2. The only problem is the n=1 fallback (lines 2783-2784, 2820), which calls `no_S_nested_in_U_separable_direct` backed by the `all_separable` axiom. The fix: create a self-contained `no_S_nested_sep`.

### Induction Structure

`no_S_nested_sep` uses double strong induction on `(UND, count_U_total)`:

```
UND = 0:  U-free → trivially separated

UND >= 2: extract innermost U(X,Y) with U-free X,Y
          abstract → count_U_total strictly decreases
          inner IH (same UND, smaller count) → separated
          substitute back → callbacks have UND <= 1
          outer IH (UND decreased from >= 2 to <= 1)

UND <= 1: extract surface U(A,B) with U-free + S-free A,B
          abstract → count_U_total strictly decreases
          inner IH (same UND, smaller count) → separated
          substitute back via subst_in_separated_separable_typed
          callbacks have has_single_U_type _ A B
          apply single_U_formula_separable_noax_param with oracle
          oracle receives: no_S_nested_in_U chi, JD chi <= 1
          *** BLOCKED: oracle formula measures are uncontrolled ***
```

### Phase 2 Blocker (UND <= 1 oracle chain)

The oracle from `single_U_formula_separable_noax_param` at `snce_depth >= 2` produces formulas with `no_S_nested_in_U` + `JD <= 1` but **uncontrolled** `UND` and `count_U_total`. The root cause: `is_separable` is existential — the separated witness has unconstrained atom counts, so callback formulas from substitution have uncontrollable measures.

Five approaches were tried and failed (see `handoffs/phase-2-blocked-20260519.md`). Possible solutions not yet attempted:
- **(A) Constructive separation**: Replace existential `is_separable` with computable `separate : Formula → Formula` that preserves atom counts
- **(B) Fuel-based**: Bound oracle chain depth as function of input formula
- **(C) Custom WF relation**: On the proof-tree sequence, not the formula measure
- **(D) Inline n=1 in all_formulas_separable_aux**: Use JD IH at n >= 2 as oracle; handle n=1 with count_U induction + n=0 as leaf
- **(E) Prove atom preservation**: Show separated form preserves `formula_atoms`

## Goals & Non-Goals

**Goals**: `count_U_total`, `extract_innermost_U_type`, oracle-free `no_S_nested_sep`, replace 9 axioms in SeparationThm.lean

**Non-Goals**: Modifying `snce_depth_of_U`/`junction_depth`/`count_U_subformulas`, modifying Eliminations.lean/DedekindZ.lean, preserving `has_single_U_type`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Nested WF inductions cause Lean elaboration issues | H | M | Flatten to single WF induction on product type |
| Oracle formulas have `snce_depth_of_U > 1` | H | L | Follows from `separated_boxnorm_snce_depth_zero` (line 1632) |
| Import reversal creates cycle | H | L | Remove SeparationThm import BEFORE adding Hierarchy import |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

---

### Phase 1: Measure Infrastructure [COMPLETED]

**Goal**: Define `count_U_total`, `extract_innermost_U_type`, and companion lemmas.

**Completed items**:
- `count_U_total` in Defs.lean (counts all `.untl` nodes at all depths)
- `count_U_total_zero_iff_U_free` in Defs.lean
- `contains_untl_deep`, `contains_untl_surface_implies_deep` in Hierarchy.lean
- `abstract_untl_count_total_le`, `abstract_untl_count_total_lt_of_contains_deep` in Hierarchy.lean
- `s_free_implies_no_S_nested` in Hierarchy.lean
- `extract_innermost_U_type` with `_S_free`, `_U_free`, `_contains_deep` companions in Hierarchy.lean

**Timing**: 2 hours | **Depends on**: none
**Files modified**: Defs.lean, Hierarchy.lean

---

### Phase 2: Oracle-Free `no_S_nested_sep` [BLOCKED]

**Goal**: Prove `no_S_nested_sep (phi : Formula) (hns : no_S_nested_in_U phi) : is_separable phi` without oracle parameters or axiom-backed functions.

**Current state**: UND >= 2 case is COMPLETE and self-contained. UND <= 1 case falls back to `no_S_nested_in_U_separable_direct` (axiom-backed).

**Blocker**: No well-founded measure decreases across the `single_U_formula_separable_noax_param` oracle chain at UND <= 1. Callback formulas from substitution into existential separated forms have uncontrollable `(UND, count_U_total)`.

**Attempted**: 5 approaches (double induction, `_depth` variant, nesting, leaf oracle, triple induction). All fail at the same point. See `handoffs/phase-2-blocked-20260519.md`.

**Timing**: 3.5 hours | **Depends on**: Phase 1
**Files to modify**: Hierarchy.lean

---

### Phase 3: Fix 10.2.8, Import Reversal, Axiom Replacement [NOT STARTED]

**Goal**: Replace n=1 fallback with `no_S_nested_sep`, reverse import, replace axioms with theorems.

**Tasks**:
- [ ] Replace n=1 `.snce` fallback (line 2783-2784): `no_S_nested_sep` for `no_S_nested_in_U_separable_direct`
- [ ] Replace n=1 `.untl` fallback (line 2820): same
- [ ] Remove all `all_separable` references from Hierarchy.lean
- [ ] Remove `import SeparationThm` from Hierarchy.lean
- [ ] Add `import Hierarchy` to SeparationThm.lean
- [ ] Replace 4 temporal closure axioms with theorems
- [ ] Replace 4 proper separation axioms with theorems
- [ ] Verify only `proper_separation_preserves_atoms` remains as axiom
- [ ] Final: `lake build` clean, no `sorry`, no axiom-backed references

**Timing**: 2.5 hours | **Depends on**: Phase 2
**Files to modify**: Hierarchy.lean, SeparationThm.lean

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn "^axiom" SeparationThm.lean` returns at most 1 line
- [ ] `no_S_nested_sep` has NO oracle parameter
- [ ] No `all_separable` references in Hierarchy.lean
- [ ] No `sorry` in Hierarchy.lean, SeparationThm.lean, Defs.lean

## Artifacts & Outputs

- `plans/25_revised-oracle-plan.md` (this file)
- Modified `Defs.lean`, `Hierarchy.lean`, `SeparationThm.lean`

## Rollback/Contingency

- Phase 1 is additive, safe to keep
- If Phase 2 blocks: try approaches A-E from blocker analysis, or write handoff
- If Phase 3 blocks on import cycle: remove SeparationThm import BEFORE adding Hierarchy import
