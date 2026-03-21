# Task 1009: FMCS Indexing Architecture Analysis

**Date**: 2026-03-20
**Focus**: Why is FMCS indexed by CanonicalMCS when world states should not index world states?

## Executive Summary

The construction `FMCS CanonicalMCS` is **architecturally legitimate but semantically degenerate**. It represents a clever proof-theoretic trick for establishing the TruthLemma, not a standard Kripke model construction. The key insight is that `FMCS D` uses `D` as an **indexing parameter**, not a temporal domain. When `D = CanonicalMCS`, the "family" is trivial: each index *is* its own world state.

## The User's Question Analyzed

> "When is FMCS indexed by CanonicalMCS, and why does this happen? The FMCS construction is for world histories which should be indexed by elements of D, not CanonicalMCS which are the world states."

This question reveals a fundamental conceptual issue in the codebase's naming and documentation. Let me address each part.

### 1. What FMCS D Actually Means

From `FMCSDef.lean` (lines 59-100):

```lean
structure FMCS where
  mcs : D -> Set Formula           -- Function assigning an MCS to each index
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : ...                   -- G-coherence between indices
  backward_H : ...                   -- H-coherence between indices
```

**Key observation**: The type parameter `D` in `FMCS D` is an **indexing type**, not a temporal domain. The structure requires only `[Preorder D]` - no group structure, no arithmetic, no linear order.

### 2. What FMCS CanonicalMCS Actually Does

From `CanonicalFMCS.lean` (lines 137-145):

```lean
def canonicalMCS_mcs (w : CanonicalMCS) : Set Formula :=
  w.world   -- IDENTITY MAPPING!

theorem canonicalMCS_is_mcs (w : CanonicalMCS) :
    SetMaximalConsistent (canonicalMCS_mcs w) :=
  w.is_mcs  -- Each index carries its own proof
```

The mapping is **identity**: `mcs(w) = w.world`. Each `CanonicalMCS` element contains both:
- The MCS itself (`.world : Set Formula`)
- The proof it's maximal consistent (`.is_mcs`)

### 3. Why This Construction Exists

**Purpose**: To make `forward_F` and `backward_P` witnesses trivial.

The standard approach would be:
- `D = TimelineQuot` (or `Int`, `Rat`, etc.) as actual time points
- `mcs : D -> Set Formula` mapping time points to world states
- Need to construct witnesses when `F phi` or `P phi` is in some MCS

The all-MCS approach (from `CanonicalFMCS.lean` lines 26-39):
- `D = CanonicalMCS` (all maximal consistent sets)
- `mcs(w) = w.world` (identity)
- Witnesses are **automatic**: every MCS is already in the domain

```lean
theorem canonicalMCS_forward_F
    (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  -- W is an MCS, so it's automatically a CanonicalMCS element!
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  exact ⟨s, CanonicalMCS.le_of_canonicalR w s h_R, h_phi_W⟩
```

## Is This Legitimate?

**Yes, but it's a degenerate case.** Here's the analysis:

### Legitimate Aspects

1. **Mathematically sound**: The construction satisfies all `FMCS` requirements
2. **Sorry-free**: All proofs complete without axioms
3. **Serves its purpose**: Establishes the TruthLemma for base completeness

### Degenerate Aspects

1. **No temporal structure**: CanonicalMCS has only Preorder, not the LinearOrder needed for actual time
2. **Identity mapping**: The "family" doesn't actually assign MCSes to times - each index *is* its MCS
3. **Not connectable to TaskFrame**: Cannot be used directly in `TaskFrame D` semantics (wrong typeclasses)

## The Architectural Gap

The completeness pipeline has a fundamental mismatch documented in `StagedConstruction/Completeness.lean` (lines 112-130):

| Component | Index/Domain | Purpose |
|-----------|--------------|---------|
| `BFMCS`/`FMCS` | `CanonicalMCS` | Proof-theoretic (TruthLemma) |
| `TaskFrame` | `TimelineQuot`/`Rat` | Semantic (model theory) |

**The gap**: We can prove the TruthLemma for `FMCS CanonicalMCS`, but the actual completeness theorem needs a `TaskFrame D` where `D` has dense linear order. These are **different D's**.

## Original Motivation

From `CanonicalFMCS.lean` (lines 26-39), the all-MCS approach was adopted because:

1. **CanonicalReachable failed**: The reachable fragment approach doesn't include backward witnesses
2. **backward_P requirement**: Past witnesses need `CanonicalR_past` which doesn't imply future-reachability
3. **Simplification**: Using all MCSes makes F/P witnesses trivial

The construction is not confused about what it's doing - it's a deliberate proof-theoretic trick.

## What SHOULD FMCS Be Indexed By?

For a proper temporal model construction:

| Scenario | Index Type | Example |
|----------|-----------|---------|
| Discrete completeness | `Int` or `Nat` | Time as integers |
| Dense completeness | `TimelineQuot ≃o Rat` | Cantor's theorem domain |
| World-history representation | `D` with `AddCommGroup + LinearOrder` | Duration arithmetic |

For the current proof-theoretic purpose (establishing that MCS membership is consistent):

| Scenario | Index Type | Purpose |
|----------|-----------|---------|
| Base completeness | `CanonicalMCS` | Trivialize F/P witnesses |

## Should FMCS CanonicalMCS Be Eliminated?

**No** - it serves a legitimate purpose in the proof pipeline. However:

### Should Be Done

1. **Rename or clarify**: The construction should be documented as "degenerate" or "proof-theoretic"
2. **Avoid "D = CanonicalMCS"**: This notation suggests CanonicalMCS is a temporal domain (it's not)
3. **Explicit role separation**: When discussing completeness, distinguish:
   - `I = CanonicalMCS` (FMCS indexing type, for TruthLemma)
   - `D = TimelineQuot` (TaskFrame temporal domain, for semantics)

### Recommended Documentation Update

In `CanonicalFMCS.lean`, add a module-level note:

```lean
/-!
## Architectural Note

This construction uses CanonicalMCS as the FMCS indexing type, creating a
"degenerate" or "identity" family where mcs(w) = w.world. This is NOT the
same as TaskFrame's temporal domain D:

- `FMCS CanonicalMCS`: Indexing type with Preorder only (proof-theoretic)
- `TaskFrame D`: Temporal domain with AddCommGroup + LinearOrder (semantic)

The construction's purpose is to trivialize forward_F and backward_P
witnesses for the TruthLemma. It cannot be directly connected to TaskFrame
semantics because CanonicalMCS lacks the required algebraic structure.
-/
```

## Correct Semantic Interpretation

If we must give `FMCS CanonicalMCS` a semantic interpretation:

> "A family of worlds indexed by themselves, where each index IS its own world state."

This is like asking "what is the temperature at temperature 25°C?" - the question conflates the domain and codomain. But as a proof technique for establishing consistency properties, it's perfectly valid.

## The Path Forward

The completeness architecture should:

1. **Keep `FMCS CanonicalMCS`** for the TruthLemma proof
2. **Build a transfer theorem** from `FMCS CanonicalMCS` truth to `TaskFrame TimelineQuot` semantics
3. **Document the distinction** clearly in ROAD_MAP.md and source files

From `StagedConstruction/Completeness.lean` (lines 124-130):

```
The gap is connecting CanonicalMCS (used in BFMCS/TruthLemma) to TimelineQuot
(used in TaskFrame). This requires either:
1. Building FMCS directly over TimelineQuot
2. A quotient transfer theorem for BFMCS
```

Option 2 (transfer theorem) appears more tractable given the existing sorry-free infrastructure.

## Summary

| Question | Answer |
|----------|--------|
| Is `FMCS CanonicalMCS` legitimate? | Yes - architecturally sound, mathematically valid |
| Is it semantically meaningful? | Degenerate - identity mapping, no actual time structure |
| Why does it exist? | Proof trick to trivialize F/P witness obligations |
| Should it be eliminated? | No - serves its purpose in TruthLemma proof |
| What should change? | Documentation to clarify "indexing type" vs "temporal domain" |
| Is "D = CanonicalMCS" notation correct? | No - creates confusion with TaskFrame's D |

## References

- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`: FMCS structure definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`: All-MCS construction
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`: Gap documentation
- Task 922 plan v5: Original motivation for Preorder generalization
- Previous research: `specs/1009_clarify_canonicalmcs_role/reports/03_d-equals-canonicalmcs-audit.md`
