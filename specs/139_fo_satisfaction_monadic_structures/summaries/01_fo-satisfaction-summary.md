# Implementation Summary: Task #139

**Task**: Build FO satisfaction infrastructure for monadic structures
**Status**: Partial (3 of 5 plan goals fully closed; 2 remain sorry)
**Date**: 2026-05-14

## What Was Done

### Phase 1-2: MonadicFormula redesign + eval/k_type_of (COMPLETED)

Replaced the placeholder `MonadicSentence` inductive with a properly designed `MonadicFormula sig n` type using De Bruijn variable binding via `Fin n`:

- **6 constructors**: `atom`, `lt`, `not`, `and`, `all`, `ex` (named `all`/`ex` to avoid Lean keyword conflicts with `forall`/`exists`)
- **`eval`**: Tarski satisfaction defined by structural recursion, using `Fin.cons` for quantifier binding
- **`KType sig k`**: Redefined as `{s : MonadicFormula sig 0 // s.quantifier_depth <= k} -> Bool` (truth-assignment function)
- **`k_type_of`**: Genuine (sorry-free) definition via `eval` and `Classical.dec`
- **`k_equiv_monotone`**: Proved genuinely via `funext` and `congr_fun`
- **`KEquivalenceFramework`**: Updated to operate on `OrderedMonadicStructure sig` (required because `eval` needs `LinearOrder` for the `lt` constructor)

### Phase 3: ktype_finite (PARTIAL)

- `equiv_is_equiv` and `equiv_monotone` in the framework instance are now sorry-free
- `ktype_finite` and `finite_types` remain sorry: the domain `{s : MonadicFormula sig 0 // s.quantifier_depth <= k}` is **syntactically infinite** (unbounded `not`/`and` nesting), so `Fintype` requires Doets' semantic equivalence theorem (Lemma 1.1), which quotients formulas by logical equivalence
- `sum_preservation` remains sorry as planned (requires EF-game formalization)

### Phase 4: Table.lean update (COMPLETED)

- `table` signature changed from `MonadicSentence sig` to `MonadicFormula sig 1` (one free variable `t`, matching Reynolds' `C_phi(t)`)
- Both `table` and `table_depth_bound` remain sorry for Task 140

### Phase 5: Downstream repairs (COMPLETED)

- **OrderedSum.lean**: All signatures updated to `OrderedMonadicStructure`. Sorries preserved with TODO markers.
- **IntegerModel.lean**: `good` now compares `OrderedMonadicStructure` via `ZIntervalStructure.toOrdered`. `finite_structures_good` now sorry (previously worked via sorry-propagation). Key proofs (`no_boundary_at_successor`, `contemp_equiv_is_equiv.refl`) maintained with explicit `Fintype` instance construction.
- **Transfer.lean**: No changes needed -- compiled as-is.
- `lake build` succeeds (1644 jobs, no errors)

## Key Design Decision: OrderedMonadicStructure

The major architectural change not anticipated by the plan: `k_equiv` and `KEquivalenceFramework` now operate on `OrderedMonadicStructure sig` instead of `MonadicStructure sig`. This was forced by the `lt` constructor in `MonadicFormula` -- `eval` needs `LinearOrder` on the carrier to interpret order comparisons. Since all structures in the Reynolds/Doets framework are ordered, this is mathematically correct.

## Sorry Inventory (Modified Files)

| File | Sorry | Reason | Owner |
|------|-------|--------|-------|
| NEquivalence.lean | `ktype_finite` | Domain is syntactically infinite; needs Doets Lemma 1.1 | follow-up |
| NEquivalence.lean | `finite_types` | Depends on ktype_finite | follow-up |
| NEquivalence.lean | `sum_preservation` | Requires EF-game formalization | follow-up |
| NEquivalence.lean | `carrier_order` (x2) | Lex order on Sigma types in sum_preservation | follow-up |
| OrderedSum.lean | `doets_lemma_1_4` | Depends on sum_preservation | follow-up |
| OrderedSum.lean | `doets_lemma_1_5` | Bypassed in discrete case | not needed |
| Table.lean | `table` | Task 140 | Task 140 |
| Table.lean | `table_depth_bound` | Task 140 | Task 140 |
| IntegerModel.lean | `finite_structures_good` | Needs Doets Theorem 1.1 | follow-up |
| IntegerModel.lean | `contemp_equiv_is_equiv.trans` | Needs sum_preservation | follow-up |
| IntegerModel.lean | `no_gaps_discrete` | Needs genuine gap argument | follow-up |
| IntegerModel.lean | `very_good_implies_good` | Needs sum_preservation | follow-up |
| IntegerModel.lean | `chronicle_is_good` | Depends on above | follow-up |

## Sorries Closed

| Definition | Previous State | New State |
|------------|---------------|-----------|
| `k_type_of` | sorry | genuine (eval + Classical.dec) |
| `k_equiv_monotone` | sorry-propagation | genuine (funext + congr_fun) |
| `equiv_is_equiv` | sorry-propagation | genuine (rfl/symm/trans on equality) |
| `equiv_monotone` | sorry-propagation | genuine (delegates to k_equiv_monotone) |

## Plan Deviations

- **Phase 1**: Constructor names changed from `forall`/`exists` to `all`/`ex` to avoid Lean keyword conflicts
- **Phase 2**: `eval` operates on `OrderedMonadicStructure` not `MonadicStructure` (forced by `lt` requiring `LinearOrder`). Decidability uses `Classical.dec` rather than a standalone instance.
- **Phase 3**: `ktype_finite` and `finite_types` could not be closed -- the plan assumed depth-bounded formulas are syntactically finite, but they are infinite due to unbounded `not`/`and` nesting. Doets Lemma 1.1 proves finiteness of *semantically* distinct formulas (up to logical equivalence), which requires a quotient construction.
- **Phase 5**: `finite_structures_good` now requires sorry where it previously worked via sorry-propagation. Several downstream proofs that relied on `simp only [k_equiv, k_type_of]` reducing to `sorry = sorry` now carry explicit sorry.

## Artifacts

- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (primary)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (signature update)
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (downstream)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` (downstream)
