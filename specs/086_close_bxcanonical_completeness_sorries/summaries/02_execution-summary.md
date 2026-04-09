# Execution Summary: Close BXCanonical Completeness Sorry #5

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [PARTIAL]
- **Plan**: plans/02_implementation-plan.md
- **Type**: lean4

## What Was Accomplished

### Round 1: Fragment Completeness for Temporal-Free Formulas

Proved completeness for the **temporal-free fragment** {atom, bot, imp, box}:

```lean
theorem fragment_completeness (phi : Formula) (h_tf : temporalFree phi)
    (h_valid : valid phi) : Nonempty (DerivationTree [] phi)
```

This theorem is **sorry-free** and verified with only standard Lean axioms.

### Round 2: Extension to G, H, and Box via Proof-Theoretic Reduction

Extended completeness to handle G, H, and box at the top level using a novel
proof-theoretic reduction approach:

```lean
noncomputable def usf_completeness (phi : Formula) (h_usf : untilSinceFree phi)
    (h_valid : valid phi) : Nonempty (DerivationTree [] phi)
```

#### New Definitions and Theorems

1. **`untilSinceFree`**: Predicate for the {atom, bot, imp, box, G, H} fragment
2. **`temporalFree_imp_untilSinceFree`**: Every temporal-free formula is Until/Since-free
3. **`valid_of_valid_all_future`**: G(phi) valid implies phi valid (reflexive semantics)
4. **`valid_of_valid_all_past`**: H(phi) valid implies phi valid (reflexive semantics)
5. **`valid_of_valid_box`**: box(phi) valid implies phi valid (tau in Omega)
6. **`usf_completeness`**: Completeness for Until/Since-free fragment

#### Proof Strategy

The key insight is that under reflexive temporal semantics:
- `valid G(phi)` implies `valid phi` (since G(phi) at t gives phi at t by t <= t)
- `valid H(phi)` implies `valid phi` (by t <= t)
- `valid box(phi)` implies `valid phi` (since tau in Omega)

Combined with the existing necessitation rules:
- `derivable phi` implies `derivable G(phi)` (temporal_necessitation)
- `derivable phi` implies `derivable H(phi)` (past_necessitation)
- `derivable phi` implies `derivable box(phi)` (necessitation)

This gives a complete proof for 6 of 8 formula cases.

#### Cases Covered (sorry-free)

| Case | Proof Method |
|------|-------------|
| atom | Delegate to `fragment_completeness` |
| bot | Delegate to `fragment_completeness` |
| box(psi) | Reduction: valid box(psi) -> valid psi -> derivable psi -> derivable box(psi) |
| G(psi) | Reduction: valid G(psi) -> valid psi -> derivable psi -> derivable G(psi) |
| H(psi) | Reduction: valid H(psi) -> valid psi -> derivable psi -> derivable H(psi) |
| untl/snce | Excluded by `untilSinceFree` predicate |

#### Remaining Sorry: imp Case B

The imp case splits on whether the antecedent psi is valid:

- **Case A (psi valid)**: valid psi and valid(psi -> chi) give valid chi. By IH,
  derivable chi. By prop_s, derivable(psi -> chi). **Complete.**

- **Case B (psi not valid)**: Uses contrapositive argument. Gets MCS w with
  (psi -> chi) not in w, hence psi in w and chi not in w. The gap: proving
  chi in w from the canonical model requires a backward truth bridge for chi,
  which fails on constant histories when chi contains G or H. **Sorry.**

The backward truth bridge failure on constant histories for G/H inside imp is
a fundamental limitation: constant histories collapse G(alpha) to alpha
semantically, so truth_at G(alpha) <-> alpha in w, but G(alpha) in w requires
alpha in v for ALL v >= w. The forward bridge (membership -> truth) works via
BX1, but the backward bridge (truth -> membership) requires non-constant
histories that visit all bx_le-successors.

### Integration

- Updated `BXCanonical.lean` module index with import
- Updated `Completeness.lean` with documentation at sorry #5

## Verification Results

- **Build**: Full `lake build` passes with zero errors
- **Sorry count in CanonicalEmbedding.lean**: 1 (imp Case B in usf_completeness)
- **New axioms**: 0

## Files Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` | Extended with validity reduction lemmas, untilSinceFree predicate, usf_completeness |

## What Remains

1. **imp Case B**: Requires either (a) non-constant histories with full truth bridge, or (b) a proof-theoretic argument connecting flatten(chi) derivability to chi derivability. Estimated: 4-6 hours.
2. **Until/Since**: Requires eventuality resolution (blocked by Frame.lean sorries #1-4). Out of scope.
3. **Full bx_completeness**: Sorry #5 remains for the complete formula language.
