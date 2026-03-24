# Research Report: Task #1006 — Order-Preserving Embedding Analysis

**Task**: Replace FlagBFMCS satisfies_at with canonical TaskFrame using truth_at
**Date**: 2026-03-19
**Mode**: Team Research (2 teammates)
**Focus**: Resolving Phase 2 blocker — order-preserving embedding of Flag chains

## Summary

The Phase 2 blocker (global `enum_mcs` not order-preserving) has been fully analyzed. The problem has **TWO independent sub-problems**: (1) order-preservation within a Flag, and (2) forward_F/backward_P witnesses across Flags. Both are solvable. The existing `FMCSTransfer` infrastructure (`FMCSTransfer.lean`) already provides sorry-free transfer of `forward_G`/`backward_H` given an order-preserving bijection. The critical architectural insight is that an `FMCS D` is a **schedule** (a time-indexed sequence of MCSes), not an embedding of all CanonicalMCS into D.

## Key Findings

### 1. The Blocker Is Confirmed and Fundamental

Both teammates independently confirmed: `enum_mcs : CanonicalMCS -> Int` (via `Encodable.encode`) assigns integers based on encoding order, which is completely unrelated to `CanonicalR`. The `parametric_to_history` function (ParametricHistory.lean:81) requires `fam.forward_G s t phi h_lt` where `h_lt : s < t` uses **D-ordering**, so `s < t` in Int must imply CanonicalR-ordering on the corresponding MCSes.

### 2. FMCSTransfer Infrastructure Already Exists (Teammate A)

`FMCSTransfer.lean` (lines 80-93) defines:
```lean
structure FMCSTransfer (D : Type*) [Preorder D] where
  embed : CanonicalMCS →o D      -- order-preserving injection
  retract : D → CanonicalMCS     -- left inverse
  embed_retract_eq : ∀ d, embed (retract d) = d  -- surjectivity
  retract_lt : ∀ d₁ d₂, d₁ < d₂ → retract d₁ < retract d₂
  embed_lt : ∀ w₁ w₂, w₁ < w₂ → embed w₁ < embed w₂
```

The `transferred_forward_G` and `transferred_backward_H` are **already proven sorry-free** (lines 162-173). This infrastructure is the right tool — but it requires an **order-preserving bijection** (surjective), not just injection.

### 3. Flags Are Totally Ordered but Density Is Unknown (Teammate A)

- `CanonicalR` is a **preorder** (not total): `CanonicalFMCS.lean:94` explicitly documents this
- Within a Flag, elements ARE totally ordered: `chainFMCS_pairwise_comparable` (ChainFMCS.lean:550)
- `ChainFMCSDomain F` is a **countable total order** without endpoints (from seriality)
- **Density question**: If Flags are dense, they embed into `Rat` (Cantor); if discrete, into `Int`
- For base TM (no density/discreteness axiom), Flag density is **unknown**

### 4. An FMCS Is a Schedule, Not an Embedding (Teammate B)

Critical architectural insight: `FMCS D` maps `D -> Set Formula` — it's a function from times to MCSes. It does NOT inject CanonicalMCS into D. The global `enum_mcs` approach was wrong because it tried to embed all CanonicalMCS, but only ONE Flag's elements need to be scheduled at a time.

### 5. The REAL Second Blocker: forward_F/backward_P (Teammate B)

Even with order-preserving scheduling, the `forward_F`/`backward_P` conditions are needed by `parametric_shifted_truth_lemma` (via `temporal_backward_G`):
```lean
forward_F : ∀ t φ, some_future φ ∈ mcs t → ∃ s, t < s ∧ φ ∈ mcs s
```

A single Flag may not contain all F/P witnesses. `IntBFMCS.lean:16-33` documents this as a **fundamental limitation** of linear chain constructions.

**Resolution**: Use `families = all Flags` in the BFMCS, with `temporally_complete` ensuring cross-Flag witnesses exist. The witness from `canonical_forward_F` lands in SOME CanonicalMCS, which is in some Flag (via `canonicalMCS_in_some_flag`), hence in some family of the BFMCS.

### 6. FlagBFMCS Truth Lemma Sidesteps Both Problems (Teammate B)

The existing `satisfies_at` truth lemma (`FlagBFMCSTruthLemma.lean:558-580`) works sorry-free because it uses **cross-Flag quantification** with `temporally_complete`, bypassing both the order-embedding problem and the forward_F problem. The remaining gap is purely the bridge from `satisfies_at` to `valid`.

## Synthesis

### Conflict: Int vs Rat as Target Domain

**Teammate A**: If Flags are dense (possible under base TM), embedding into Int is mathematically impossible. Use Rat.

**Teammate B**: Enumerate Flag chain in order at integer positions. Int works for the schedule.

**Resolution**: Both are partially right. For an **order-isomorphism** (bijection), Teammate A is correct — if the Flag is dense, it cannot be isomorphic to Int. However, for a **schedule** (Teammate B's perspective), we don't need a bijection — we need an order-preserving injection with the right properties.

The resolution depends on which infrastructure we use:
- **FMCSTransfer** (Teammate A's tool): Requires **bijection** (surjective). Target D must match Flag density.
- **Direct FMCS construction** (Teammate B's approach): Only needs forward_G/backward_H. Can use partial scheduling with fallback.

### Two Viable Paths Forward

**Path A: Per-Flag FMCSTransfer (cleaner, but requires density resolution)**

1. For each Flag F, build `FMCSTransfer D` where D matches Flag structure
2. Use `transferredFMCS` (sorry-free) to get `FMCS D` with forward_G/backward_H
3. Bundle into `BFMCS D` with `families = all transferred FMCSes`
4. Prove `temporally_coherent` via `allFlagsBFMCS.temporally_complete`
5. Apply parametric pipeline

**Challenge**: Need to determine D (Int or Rat) based on Flag density. For base TM, this is undetermined.

**Workaround**: Since `valid` quantifies over ALL D, for the contrapositive we only need ONE specific D. We can pick D to match whatever density the Flag has. If we don't know the density, we can use Rat (which embeds any countable linear order without endpoints — dense or discrete — as a suborder).

**Path B: Direct satisfies_at bridge (bypasses embedding entirely)**

1. Keep `FlagBFMCS_completeness` (already sorry-free) as the core theorem
2. Prove `satisfies_at` corresponds to `truth_at` for a specifically constructed TaskFrame
3. The TaskFrame uses `D = Rat` (or any suitable D) with the Flag chain embedded
4. Bridge: `satisfies_at -> truth_at -> not valid`

**Challenge**: Still need SOME embedding to create the `TaskFrame D`. But the bridge is simpler because `satisfies_at_iff_mem` is already proven.

### Recommended Approach: Path A with D = Rat

**Rationale**:
1. **Any countable linear order without endpoints embeds order-preservingly into Rat** (even if not dense — you just don't use all of Rat)
2. The `FMCSTransfer` infrastructure is sorry-free and handles forward_G/backward_H
3. Multi-family BFMCS with all Flags handles forward_F/backward_P
4. The parametric pipeline is D-polymorphic — works for Rat just as well as Int
5. For future dense completeness, D=Rat is the right choice anyway

**Key insight**: We don't need Flag ≃o Rat (isomorphism). We need Flag ↪o Rat (order-preserving injection). For `FMCSTransfer`, we need surjectivity — but we can define `retract` for positions outside the Flag's image by mapping to the nearest Flag element (exists by density of Rat or by totality of the Flag order).

## Gaps Identified

1. **Countable linear order ↪o Rat**: Need to construct or cite this in Lean/Mathlib. The math is standard but the Lean proof may not exist.

2. **retract function for FMCSTransfer**: For positions outside the Flag's image, what does `retract` map to? Needs careful definition to maintain `retract_lt`.

3. **forward_F at BFMCS level**: The cross-Flag witness mechanism (via `canonicalMCS_in_some_flag`) works conceptually but needs to be formalized as `BFMCS.temporally_coherent`.

4. **Existing dovetailing work (Task 1004)**: DovetailedBuild/DovetailedCoverage may already solve part of this — needs verification.

## Recommendations

### For Plan v3

1. **Switch from D=Int to D=Rat** for the base completeness proof
2. **Use `FMCSTransfer Rat`** with per-Flag order-preserving embedding
3. **Use multi-family BFMCS Rat** with `families = all Flags` for temporal coherence
4. **Apply existing parametric pipeline** (`DenseCanonicalTaskFrame = ParametricCanonicalTaskFrame Rat`)
5. **Replace Phase 1**: Instead of global `enum_mcs`, build per-Flag `embed_flag : ChainFMCSDomain F ↪o Rat`

### Alternative: If Rat embedding proves difficult

Fall back to Path B — bridge `satisfies_at` directly to `valid` without going through BFMCS.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Order-preserving embedding (math analysis) | completed | high (structure), medium (density) |
| B | Alternative approaches (architectural) | completed | high |

## Key File References

| File | Relevance |
|------|-----------|
| `FMCSTransfer.lean:80-93` | FMCSTransfer structure (order-preserving bijection) |
| `FMCSTransfer.lean:162-173` | transferred_forward_G (sorry-free) |
| `ChainFMCS.lean:550` | chainFMCS_pairwise_comparable (Flag total order) |
| `CanonicalFMCS.lean:94` | Documents CanonicalR is NOT total |
| `IntBFMCS.lean:16-33` | Documents forward_F/backward_P fundamental limitation |
| `FlagBFMCSTruthLemma.lean:300-367` | Cross-Flag temporal witness mechanism |
| `ParametricHistory.lean:81` | Where forward_G is actually used (D-ordering) |
| `TemporalCoherence.lean:149-153` | forward_F/backward_P requirements |

## Next Steps

1. Revise plan v3 using D=Rat and FMCSTransfer approach
2. Verify Lean/Mathlib has countable linear order ↪o Rat
3. Design retract function for FMCSTransfer Rat
4. Formalize multi-family BFMCS temporal coherence proof
