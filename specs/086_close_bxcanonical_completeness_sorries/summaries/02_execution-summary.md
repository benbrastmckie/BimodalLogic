# Execution Summary: Close BXCanonical Completeness Sorry #5

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [PARTIAL]
- **Plan**: plans/02_implementation-plan.md
- **Type**: lean4

## What Was Accomplished

### Fragment Completeness for Temporal-Free Formulas

Proved completeness for the **temporal-free fragment** {atom, bot, imp, box}:

```lean
theorem fragment_completeness (φ : Formula) (h_tf : temporalFree φ)
    (h_valid : valid φ) : Nonempty (DerivationTree [] φ)
```

This theorem is **sorry-free** and verified with only standard Lean axioms
(propext, Classical.choice, Quot.sound).

### New File: CanonicalEmbedding.lean (~260 lines)

Created `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` containing:

1. **`temporalFree`**: Predicate for the {atom, bot, imp, box} fragment
2. **`canonical_task_frame`**: TaskFrame with BXPoint states and permissive task_rel `d != 0 || w = u`
3. **`constant_history`**: Full-domain history mapping all times to one BXPoint
4. **`time_shift_constant_eq`**: Proof that time-shifting a constant history gives the same history (key for shift-closure)
5. **`canonical_valuation`**: Atom p true at w iff `atom p in w.formulas`
6. **`modal_omega`**: Set of constant histories through modally-equivalent BXPoints
7. **`modal_omega_shift_closed`**: Shift-closure of modal_omega
8. **`modal_omega_eq_of_equiv`**: modal_omega invariant under S5 modal equivalence
9. **`fragment_truth_iff`**: Bidirectional truth lemma: `phi in w <-> truth_at ... phi` for all temporal-free phi
10. **`fragment_completeness`**: The completeness theorem

### Integration

- Added import to `BXCanonical.lean` (module index)
- Added documentation comment at sorry #5 in `Completeness.lean` explaining scope

## What Was NOT Accomplished

### G/H (Temporal Operators) Not Covered

The plan targeted the {atom, bot, imp, box, G, H} fragment but G/H could not be
handled with the constant-history approach. The fundamental issue:

- **Constant histories collapse temporal structure**: `truth_at G(psi)` on a constant
  history through w reduces to `truth_at psi` (since all times map to the same state w).
  But `G(psi) in w` requires `psi in v` for ALL v >= w, which is strictly stronger
  than just `psi in w`.

- **The iff fails for G backward**: `truth_at G(psi) -> G(psi) in w` is not provable
  because `truth_at G(psi)` only gives `psi in w` (one BXPoint), not `psi in v` for
  all bx_le-successors.

- **Countermodel also fails**: `G(psi) not_in w` does not imply `psi not_in w`, so
  `not truth_at G(psi)` at `constant_history w` is not provable from `G(psi) not_in w`.

This is the "surjectivity problem" identified in the research: constant histories
cannot represent the temporal ordering between BXPoints. Non-constant histories
(e.g., two-point histories) are needed, requiring a significantly more complex
truth lemma.

### Sorry #5 Remains

The original sorry at `Completeness.lean:144` (`bx_completeness`) remains. The
`fragment_completeness` theorem covers a proper subset of formulas.

## Verification Results

- **Build**: Full `lake build` passes with zero errors
- **Sorry count in new file**: 0
- **New axioms**: 0
- **Axiom check**: `fragment_completeness` uses only standard Lean axioms

## Files Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` | New file (~260 lines) |
| `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` | Documentation comment at sorry #5 |
| `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` | Added import + updated architecture doc |

## What Remains

1. **G/H fragment**: Requires non-constant histories (two-point or multi-point) and a truth lemma that handles temporal structure. Estimated additional effort: 6-8 hours.
2. **Until/Since**: Requires eventuality resolution (blocked by Frame.lean sorries #1-4). Out of scope.
3. **Full bx_completeness**: Sorry #5 remains for the complete formula language.
