# Implementation Summary: Task #951

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-02-27
**Session**: sess_1740672300_i951
**Status**: Partial (Phase 1 of 7 completed)

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

### What Comes Next (Phase 2)

Phase 2 will add the dovetailing enumeration of F/P obligations:
- Define `Obligation` type for F-witnesses and P-witnesses
- Define diagonal enumeration over (time, formula) pairs
- Modify the chain construction to inject witness formulas into seeds
- Prove that every obligation is eventually witnessed
