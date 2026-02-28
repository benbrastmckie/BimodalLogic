# Implementation Summary: Task #951

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-02-27
**Sessions**: sess_1740672300_i951 (plan v001), sess_1772246447_439fa1e5 (plan v002)
**Status**: Partial - Plan v002 Phases A, C completed; Phase B in progress

---

## Plan v002: Bidirectional Reachable Fragment Approach

Following the root cause analysis (research-003.md), plan v002 supersedes the chain approach
with the Bidirectional Reachable Fragment approach.

### Phase A: Bidirectional Reachable Fragment Infrastructure [COMPLETED]

Created `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` (450+ lines):

**Types Defined**:
- `BidirectionalEdge M₁ M₂` - one-step edge in either CanonicalR direction
- `BidirectionalReachable M₀ M` - reflexive-transitive-symmetric closure from M₀
- `BidirectionalFragment M₀ h_mcs₀` - subtype of reachable MCSes

**Key Theorems (all sorry-free)**:
- `BidirectionalReachable.refl` - root is reachable
- `BidirectionalFragment.forward_closed` - CanonicalR forward closure
- `BidirectionalFragment.backward_closed` - CanonicalR backward closure
- `forward_F_stays_in_fragment` - F-witnesses remain in fragment
- `backward_P_stays_in_fragment` - P-witnesses remain in fragment
- `toCanonicalMCS` - conversion to CanonicalMCS element
- `Preorder` instance on fragment

### Phase B: Linearity Proof [IN PROGRESS]

Added linearity infrastructure to BidirectionalReachable.lean:

**Completed (sorry-free)**:
- `mcs_F_linearity` - temp_linearity axiom application within MCS context
- `canonical_F_of_mem_successor` - F-introduction from CanonicalR successor
- `canonical_forward_reachable_linear` - totality for forward-reachable elements

**Remaining**:
- Extend linearity to full bidirectional reachability
- Prove `bidirectional_totally_ordered`

### Phase C: F/P Fragment Closure [COMPLETED]

Completed during Phase A work:
- `forward_F_stays_in_fragment`
- `backward_P_stays_in_fragment`

### Phases D-H [NOT STARTED]

- Phase D: Antisymmetrization and countability
- Phase E: Embedding into Int
- Phase F: FMCS Int via pullback
- Phase G: BFMCS and modal saturation
- Phase H: Truth lemma and completeness

### Verification (Plan v002)

- `lake build` passes (703 jobs, no new errors)
- All new proofs in BidirectionalReachable.lean are sorry-free
- No new axioms introduced

### Commits (Plan v002)

1. `b02e38ac` - task 951 phase A: bidirectional reachable fragment infrastructure
2. `647e6e53` - task 951 phase B: linearity infrastructure (partial)

---

## Plan v001: Z-Indexed Chain Approach (BLOCKED)

The original chain approach is documented below. Phases 1-2 completed, Phase 3 BLOCKED
due to F-formula non-persistence through GContent seeds.

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

## Phase 3: Forward F via Dovetailed Chain [BLOCKED]

### Blocker Analysis

Phase 3 attempted to prove forward_F for the enriched chain construction. After detailed analysis, this phase is BLOCKED by a fundamental mathematical obstacle: **F-formula non-persistence through GContent seeds**.

**The problem**: `F(phi) in chain(t)` does NOT imply `F(phi) in chain(k)` for `k > t`. The GContent propagation between chain elements only preserves G-formulas (universal: `G(psi)`), not F-formulas (existential: `F(phi) = neg(G(neg(phi)))`). At any step, the Lindenbaum extension can introduce `G(neg(phi))`, which kills `F(phi)`.

**Why this blocks forward_F**: The enriched chain's witness placement (`enrichedForwardStep_witness_placed`) only works when `F(phi)` is alive at the step where `phi` is decoded (step `encodeFormula phi`). For `F(phi)` at position `t`, there is no guarantee that `F(phi)` survives from position `t` to position `encodeFormula phi`. Since `decodeFormula` maps each natural number to at most one formula, phi has exactly ONE chance to be witnessed (at step `encodeFormula phi`). If `F(phi)` is dead at that step, forward_F fails.

**Why this is fundamental (not fixable by tactics/lemmas)**:
1. GContent(M) = {phi | G(phi) in M}. F(phi) = neg(G(neg(phi))) is NOT a G-formula.
2. The linearity axiom constrains F-witness ORDERING but does NOT prevent Lindenbaum from making choices that kill F-obligations (confirmed in Boneyard/CanonicalEmbedding.lean lines 67-78).
3. This is the SAME blocker that defeated 12+ prior attempts in DovetailingChain.lean (documented in DovetailingChain.lean lines 1778-1784).
4. The enriched chain has the SAME structural limitation as DovetailingChain: it IS a linear chain with GContent propagation.

**Confirmed non-starters**:
- Using the diagonal enumeration `decodePosFormula(k) = (pos, phi)` to check F(phi) at the origin position: requires `F(phi) in chain(k)` for seed consistency, which is the same problem.
- Using seed `{phi} ∪ GContent(chain(pos))` instead of `{phi} ∪ GContent(chain(k))`: consistent but does NOT give `CanonicalR chain(k) chain(k+1)`.
- GContent monotonicity helps propagate GContent forward but does NOT propagate F-formulas.

### Resolution Path

The correct approach (confirmed by Boneyard/CanonicalEmbedding.lean analysis) is the **canonical quotient / embedding approach**:

1. `canonicalMCS_forward_F` already provides sorry-free forward_F over CanonicalMCS (trivially, since the witness MCS is in the domain by construction).
2. `canonical_reachable_linear` (in Boneyard) proves that the reachable fragment of CanonicalMCS from any root is linearly ordered.
3. Embed the linearly-ordered reachable fragment into Int via Mathlib's `orderIsoIntOfLinearSuccPredArch` or `Order.embedding_from_countable_to_dense`.
4. Pull back the FMCS to get `FMCS Int` with forward_F.

This avoids the F-persistence problem entirely by NOT using a chain construction for forward_F.

### What Was Preserved

Phases 1-2 infrastructure is still valid and useful:
- `CanonicalChain` structure and `toFMCS` conversion provide forward_G and backward_H
- The enriched chain construction with witness placement may still serve as a building block
- The diagonal enumeration infrastructure is reusable
- All 856 lines of CanonicalChain.lean are sorry-free and build cleanly

### Recommendation

The plan (Phases 3-7) should be **revised** to use the canonical quotient / embedding approach rather than the linear chain construction. Key steps:
1. Resurrect `CanonicalEmbedding.lean` infrastructure from Boneyard (proven: `canonical_reachable_linear`, `mcs_F_linearity`, `canonical_F_of_mem_successor`)
2. Define the reachable fragment type with `Countable`, `LinearOrder`, `SuccOrder`, `PredOrder`
3. Use Mathlib embedding to map into Int
4. Construct `TemporalCoherentFamily Int` from the embedding
5. Combine with modal saturation for `fully_saturated_bfmcs_exists_int`
