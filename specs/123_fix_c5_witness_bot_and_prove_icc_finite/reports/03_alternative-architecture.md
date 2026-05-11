# Alternative Architecture Analysis: Unified Dense/Discrete Completeness

**Task**: Evaluate whether a more elegant alternative to the post-construction quotient exists.
**Date**: 2026-05-11

## How AddCommGroup Is Actually Used

After tracing the codebase, `AddCommGroup D` is used in exactly three places:

### 1. `time_shift` (WorldHistory.lean:238)
```lean
def time_shift (σ : WorldHistory F) (Δ : D) : WorldHistory F where
  domain := fun z => σ.domain (z + Δ)
  states := fun z hz => σ.states (z + Δ) hz
```
Uses `z + Δ` (addition) and `sub_add_cancel` (subtraction = addition of inverse). This is the core: shifting a world history by Δ requires a group operation.

### 2. `ShiftClosed` (Truth.lean:242)
```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  ∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.time_shift σ Δ ∈ Omega
```
Requires arbitrary shifts by any Δ : D. Uses the group structure transitively.

### 3. Soundness of MF/TF/uniformity axioms (SoundnessLemmas.lean)
- **MF** (□φ→□Gφ, line 1036): Uses `time_shift σ (s - t)` and `time_shift_preserves_truth`. The key operation is `s - t` (subtraction).
- **TF** (□φ→G□φ, line 1045): Same pattern.
- **Uniformity axioms** (discrete_symm/propagate, lines 1421-1468): Use `t - (s - t)`, `u + (s - t)`, `c + (s - t)`, `c - (u - t)`. Heavy use of group arithmetic: `add_sub_cancel`, `sub_add_cancel`, `add_sub_sub_cancel`.

### What's needed from AddCommGroup

The MF/TF soundness proofs need:
- `(z + Δ)` — addition (for time_shift)
- `(s - t)` — subtraction (for computing durations)
- `sub_add_cancel`, `add_sub_cancel` — group laws (for algebraic simplification)
- Ordered addition: `add_lt_add_left`, `add_le_add_right`

The uniformity axiom soundness proofs additionally need:
- `add_sub_sub_cancel` — cancellation laws
- `sub_lt_sub_right`, `sub_lt_self` — ordered subtraction

**Verdict**: AddCommGroup is GENUINELY required for MF/TF/uniformity soundness. It's not just used for the ℤ-isomorphism — it's structural to the semantics.

## Direction Analysis

### Direction A: Weaken the Semantics — NOT VIABLE for base logic

Removing `AddCommGroup` from `valid` would mean MF and TF can't be proved sound (their proofs use `time_shift` which needs `+` and `-`). MF and TF are BASE axioms (Layer 4), not discrete-only. So weakening the semantics breaks soundness for the base logic.

For a DISCRETE-ONLY validity (`valid_discrete`), we COULD use a weaker structure... but `valid_discrete` already requires `AddCommGroup D` (line 181) because it inherits from `valid`'s quantification pattern.

**Verdict**: Weakening semantics to avoid AddCommGroup would require redesigning MF/TF soundness — a massive architectural change affecting 1500+ lines of sorry-free soundness proofs.

### Direction B: Build countermodel on limit_dom directly — NOT VIABLE

limit_dom ⊂ ℚ is not closed under addition (e.g., if x, y ∈ limit_dom, x + y may not be). So limit_dom can't carry AddCommGroup. We'd need to extend to a group containing limit_dom, which is essentially ℚ or ℤ — bringing us back to the isomorphism problem.

### Direction C: Use ℚ as domain for both cases — PARTIALLY VIABLE but unsound for discrete

If D = ℚ for the discrete case, Prior-UZ soundness requires `SuccOrder ℚ` and `IsSuccArchimedean ℚ`, which ℚ doesn't have (ℚ is dense, not discrete). So Prior-UZ can't be proved sound on ℚ, and the countermodel on ℚ wouldn't validate the discrete axioms.

### Direction D: Factor out AddCommGroup — PROMISING but large scope

The completeness theorem is contrapositive: `¬derivable φ → ¬valid φ`. To prove `¬valid φ`, we need to exhibit ONE frame where φ fails. We DON'T need to prove φ fails on ALL frames — just find one countermodel.

For the discrete case, the countermodel needs to live on some D with:
- `AddCommGroup D` (for TaskFrame to make sense)
- `SuccOrder D`, `PredOrder D`, `IsSuccArchimedean D` (for discrete validity)

The only standard type satisfying all of these is `ℤ`. So we MUST get to ℤ somehow.

**Key insight**: We don't need limit_dom ≃o ℤ. We need to BUILD a countermodel on ℤ. The quotient IS the simplest bridge.

### Direction E: Reynolds-style simplified transfer — IS the quotient

As noted, a surjection limit_dom → ℤ collapsing ω-chains is exactly the quotient. No simplification possible here.

### NEW Direction F: Build BFMCS on ℤ directly without isomorphism

Instead of:
1. Build FMCS on limit_dom
2. Iso to ℤ (or quotient to ℤ)
3. Transport FMCS to ℤ
4. Build BFMCS on ℤ

Consider:
1. Build FMCS on limit_dom (already done, sorry-free)
2. Define a SURJECTION π: limit_dom → ℤ that collapses ω-chains
3. Define f_ℤ(n) = f_limit(π⁻¹(n)) for one representative per ω-chain
4. Build BFMCS on ℤ using f_ℤ
5. Verify coherence (G/H propagation, Until/Since) on ℤ

This is essentially the quotient but framed as a surjection, which might be simpler to formalize.

## Recommendation

**The quotient/surjection approach is the most viable.** There's no elegant shortcut that avoids it:

1. AddCommGroup IS genuinely needed (MF/TF soundness)
2. The countermodel MUST live on ℤ (the only standard discrete ordered abelian group)
3. Burgess's construction correctly produces a discrete model on a non-standard domain
4. The bridge from limit_dom to ℤ requires collapsing the ω-chains

**However**, the quotient can be framed more simply as:

> Define `collapse : LimitDomSubtype → ℤ` by: for each x ∈ limit_dom, count the number of "structural" predecessor steps to reach the origin. Two points get the same integer iff they're in the same ω-chain.

This avoids formal quotient types (Lean's `Quotient`) and instead uses a direct function `limit_dom → ℤ`.

**Estimated effort**: ~300-500 new lines, 0 existing sorry-free lines modified. The FMCS transport is the main work — verifying that G/H propagation and Until/Since coherence are preserved under the collapse.

## Confidence

**High** that AddCommGroup cannot be removed (it's structural to MF/TF soundness).
**High** that the countermodel must live on ℤ.
**Medium** that the quotient/surjection is ~300-500 lines (the FMCS transport might be trickier than expected).
