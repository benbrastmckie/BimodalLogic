# Implementation Summary: Task #951

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-02-27
**Session**: sess_1740672300_i951
**Status**: Partial (Phases 1-2 of 7 completed)

## Phase 1: Infrastructure - Z-Indexed Chain Type and Basic Properties [COMPLETED]

### What Was Built

Created `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` (new module, ~450 lines) containing:

**Core Data Structure:**
- `CanonicalChain`: Structure holding a function `Int -> CanonicalMCS` with a proof that consecutive elements are CanonicalR-related (`GContent(chain(n).world) ⊆ chain(n+1).world` for all n)

**Construction Functions:**
- `forwardChainStep root n`: Recursively builds chain element at position n >= 0 by Lindenbaum extension of GContent seeds
- `backwardChainStep root n`: Recursively builds chain element at position -n by Lindenbaum extension of HContent seeds
- `buildChainFn root n`: Combines forward/backward into a single `Int -> CanonicalMCS` function
- `buildCanonicalChain root`: Packages the combined function with the ordering proof into a `CanonicalChain`

**Key Theorems (all sorry-free):**
- `CanonicalChain.monotone`: For s <= t, `CanonicalR chain(s).world chain(t).world` (by induction on distance, using transitivity)
- `CanonicalChain.GContent_inclusion`: For s <= t, `GContent(chain(s).world) ⊆ chain(t).world`
- `CanonicalChain.HContent_inclusion`: For s <= t, `HContent(chain(t).world) ⊆ chain(s).world` (via GContent/HContent duality)
- `CanonicalChain.toFMCS`: Converts chain to `FMCS Int` with forward_G and backward_H coherence
- `chain_ordered_forward` / `chain_ordered_backward`: Explicit forward/backward ordering lemmas
- `buildChainFn_ordered`: The combined chain function has consecutive CanonicalR ordering
- `toFMCS_preserves_context`: Root context is preserved at position 0

### Design Decisions

1. **No separate ChainElement type**: The plan called for a `ChainElement` structure wrapping MCS with position metadata. Instead, we use `CanonicalMCS` directly (which already wraps the MCS with is_mcs proof). The position is the integer index. This is cleaner and avoids redundant wrapping.

2. **Conservative chain construction**: The Phase 1 chain extends at each step using only GContent/HContent seeds (no additional witness formulas). This establishes the basic ordering infrastructure. Witness formula injection will be added in Phase 2 via the dovetailing enumeration.

3. **Single ordering invariant**: The `ordered` field states `CanonicalR chain(n) chain(n+1)` for ALL n (not separate positive/negative cases). The `buildChainFn_ordered` proof handles all three cases (positive, transition at -1, negative) in a single theorem.

### Verification

- `lake build Bimodal.Metalogic.Bundle.CanonicalChain` passes (Build completed successfully, 700 jobs)
- `grep -n "\bsorry\b"` returns only comment occurrences (no proof sorries)
- `grep -n "^axiom "` returns empty (no new axioms)
- `lean_goal` shows "no goals" for all theorems
- No warnings in the new file

## Phase 2: Dovetailing Enumeration and Obligation Processing [COMPLETED]

### What Was Built

Extended `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` (now ~860 lines) with:

**Obligation Type:**
- `Obligation`: Inductive type with `ForwardF (t : Int) (phi : Formula)` and `BackwardP (t : Int) (phi : Formula)` constructors
- `Obligation.time`, `Obligation.formula`: Accessors

**Diagonal Enumeration (omega-squared):**
- `decodePosFormula`: Maps `Nat` to `Option (Nat x Formula)` via `Nat.unpair` and `decodeFormula`
- `encodePosFormula`: Inverse direction via `Nat.pair` and `encodeFormula`
- `decodePosFormula_encodePosFormula`: Round-trip surjectivity proof
- `diagonalForwardObligation` / `diagonalBackwardObligation`: Map `Nat` to forward/backward obligations
- `diagonalForwardObligation_surjective` / `diagonalBackwardObligation_surjective`: Every obligation eventually enumerated

**Enriched Chain Construction:**
- `enrichedForwardStep root n`: Forward chain where at step n+1, if `decodeFormula(n) = some phi` and `F(phi) in chain(n)`, phi is included in the Lindenbaum seed via `ForwardTemporalWitnessSeed`
- `enrichedBackwardStep root n`: Symmetric backward chain using `PastTemporalWitnessSeed`
- `buildEnrichedChainFn` / `buildEnrichedCanonicalChain`: Full Z-indexed enriched chain

**Key Theorems (all sorry-free):**
- `enrichedForwardStep_ordered`: CanonicalR ordering preserved at each enriched forward step
- `enrichedForwardStep_witness_placed`: If F(phi) alive at step k and phi decoded at k, then phi in chain(k+1)
- `enrichedBackwardStep_ordered`: CanonicalR ordering for backward enriched steps (via HContent/GContent duality)
- `enrichedBackwardStep_witness_placed`: Symmetric backward witness placement
- `enrichedBackwardStep_HContent_inclusion`: HContent inclusion for backward enriched steps
- `buildEnrichedChainFn_ordered`: Consecutive ordering for the full enriched chain

### Design Decisions

1. **Per-step enumeration (not omega-squared at chain level)**: The enriched chain processes obligations at the CURRENT position (`F(phi) in chain(k)`) rather than from earlier positions. This is consistent with the DovetailingChain approach and avoids the GContent-corruption problem (where an F-obligation from an earlier position may not survive to a later one). The omega-squared enumeration infrastructure is provided for Phases 3-4 to argue about coverage.

2. **Enriched chain as separate construction**: Rather than modifying the Phase 1 conservative chain, the enriched chain is a separate construction (`enrichedForwardStep` vs `forwardChainStep`). Both are available. The enriched chain is what will be used for forward_F/backward_P proofs.

3. **`processObligation` adapted**: The plan specified `processObligation : CanonicalChain -> Obligation -> CanonicalChain`. Since a CanonicalChain is total (defined on all of Int), "extending" it doesn't apply directly. Instead, obligations are processed inline at each enriched chain step.

### Verification

- `lake build` passes (full project, 739 jobs)
- No sorries in CanonicalChain.lean
- No new axioms
- No warnings in CanonicalChain.lean
- `lean_goal` shows "no goals" for all new theorems

### What Comes Next (Phase 3)

Phase 3 will prove forward_F for the enriched chain:
- Prove that for any `F(phi) in chain(t)`, either phi is already witnessed or the obligation persists until it is processed
- This is the critical proof step that was sorry'd in DovetailingChain
- The enriched chain with current-position witness placement provides the infrastructure
