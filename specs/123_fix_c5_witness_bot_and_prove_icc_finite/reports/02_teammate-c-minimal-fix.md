# Minimal Burgess-Faithful Fix Analysis

**Task**: Find the minimal fix for discrete completeness, staying true to Burgess's method.
**Date**: 2026-05-11

## Critical Finding: What Burgess's "Routine Exercise" Actually Means

After careful reading of Burgess 1982 Section 1.6 and the full completeness proof:

**Burgess's construction DOES produce infinite bounded intervals for U(⊤,⊥).** This is NOT a bug — it's how his general construction works. His Lemma 2.10 condition (i) always fails for η=⊥ (requires ⊥ ∧ U(ξ,⊥) = ⊥ ∈ f(x'), impossible for MCS), so the split case always fires, creating infinite midpoint chains.

**Burgess's "routine exercise" does NOT mean modifying the construction.** It means: the Claim 2.11 proof (+: x ∈ V(α) iff α ∈ f(x)) works identically. The limit model validates the discrete axiom G'⊥ because U(⊤,⊥) ∈ f(x) for all x, and C5 gives witness y with ⊥ ∈ g(x,y), so by (+) no z exists between x and y. The model IS discrete — it's just on a non-standard domain (a subset of ℚ with order type ω·ω\*, not ℤ).

**The issue is ProofChecker-specific**: the `valid` definition requires `AddCommGroup D` for the task frame's time-shift semantics (`ShiftClosed`, `time_shift σ Δ`). This forces D = ℤ for the discrete case (ℤ is the unique countable discrete group with no endpoints). Getting LimitDomSubtype ≃o ℤ requires IsSuccArchimedean, which requires Icc_finite, which is false.

## Strategy Evaluations

### Strategy 1: Prove IsSuccArchimedean directly (without Icc_finite) — NOT VIABLE

IsSuccArchimedean says `∀ a ≤ b, ∃ n, succ^[n] a = b`. With infinite bounded intervals (order type ω+ω\*), succ^[n](a) literally never reaches b for finite n when there's an ω-chain between them. IsSuccArchimedean is mathematically false for the current limit_dom. No construction-specific argument can save it.

**Verdict**: Dead end.

### Strategy 2: Use left-side closure property — PARTIALLY VIABLE (for a quotient)

Every C5 split for U(⊤,⊥) produces B' ∋ ⊥ on the LEFT side. Via adj_g_mem_limit_f, no limit_dom points exist between x and the midpoint z. The ω-chain x < z₁ < z₂ < ... → c has each (zₖ, zₖ₊₁) permanently closed on the left. The RIGHT side (zₖ, zₖ₊₁) is open, producing the next midpoint.

This pattern is useful for defining a quotient: the ω-chain is "one structural step" from x to c. The quotient that collapses each ω-chain to a single edge would have finite bounded intervals.

**Verdict**: Useful as infrastructure for the quotient approach (Strategy 6 below).

### Strategy 3: Discrete case doesn't need omega chain — NOT VIABLE (in current architecture)

Burgess's completeness DOES work without ℤ — his model is on a subset of ℚ. But the ProofChecker's validity requires AddCommGroup D, forcing D = ℤ. You can't build a countermodel on the limit_dom ⊂ ℚ because ℚ-subsets don't have AddCommGroup.

This approach would require redesigning the semantics (task 120), which is a much larger project.

**Verdict**: Correct for Burgess, but incompatible with current ProofChecker architecture.

### Strategy 4: Skip C5 for ξ=⊥ and handle separately — PARTIALLY VIABLE but tried and failed

The previous implementation attempt added a disjunct to EliminationResult. Phase 1 (EliminationResult changes) compiled, but Phase 3 (limit proof) failed because the right disjunct doesn't carry g-value information needed by adj_g_mem_limit_f.

A variant that might work: instead of a disjunct, carry ADDITIONAL DATA in the EliminationResult for the ξ=⊥ case. Specifically, carry the proof that g(x, y) at the CURRENT stage is the original g-value (unchanged), and that the ORIGINAL g-value was R(f(x), -, f(y))-maximal. Then at the limit level, use a separate argument: since no point was inserted at THIS step, and the g-value is inherited from the previous stage, the adj_g_mem_limit_f still applies with the original g-value.

But this doesn't solve the fundamental issue: the original g-value doesn't contain ⊥ either. The adj_g_mem_limit_f would give "φ ∈ limit_f(w) for all φ ∈ g(x,y)", but ⊥ ∉ g(x,y).

**Verdict**: Tried and failed. The fundamental issue is that no g-value information can prove ⊥ ∈ limit_f(w).

### Strategy 5: Prove Icc_finite by showing the ω+ω\* pattern doesn't arise — NOT VIABLE

The pattern DOES arise, confirmed by multiple independent analyses. The backward C5' for S(⊤,⊥) creates the ω\* part. Each forward/backward split permanently closes one side but leaves the other open. The interleaving creates the full ω+ω\* pattern between any original adjacent pair.

**Verdict**: The pattern genuinely exists. Icc_finite is false.

### Strategy 6 (NEW): Post-construction quotient — MOST VIABLE

**Key insight**: Don't modify the construction at all. Instead, add a QUOTIENT step between the limit chronicle and the ℤ-isomorphism.

Define an equivalence relation on limit_dom that collapses each ω+ω\* chain to a point. The resulting quotient has the same "structural" order as the original domain but with finite bounded intervals.

**How the quotient works**:
- The ω-chains from C5 for U(⊤,⊥) create convergent sequences between "structural" points
- A "structural" point is one that entered the domain through a non-U(⊤,⊥) counterexample (C4, or C5 with ξ ≠ ⊥), or the initial point
- Define: x ~ y iff all points between x and y entered via U(⊤,⊥) C5 processing
- Each equivalence class is a maximal run of U(⊤,⊥)-fill points
- The quotient has finite bounded intervals (finitely many structural points between any two)
- The quotient inherits SuccOrder, PredOrder from the discrete structure
- The quotient IS IsSuccArchimedean (succ on the quotient = "jump to next structural point")
- The quotient ≃o ℤ via Mathlib's orderIsoIntOfLinearSuccPredArch

**Effort**: ~300-500 new lines, 0 existing lines modified.
**Risk**: Medium — defining the equivalence relation and transporting FMCS properties through the quotient requires care.
**Burgess-faithful**: Yes — the construction is unchanged.

### Strategy 7 (NEW): Reprove limit C5 for ξ=⊥ WITHOUT going through omega_chain_c5_witness

Instead of modifying EliminationResult, provide a SEPARATE proof of limit_satisfies_c5 for the ξ=⊥ case that doesn't use omega_chain_c5_witness at all.

The argument: for any x ∈ limit_dom with U(⊤,⊥) ∈ limit_f(x), the C5 walk at some stage n produced a midpoint z with g_n(x,z) = B' ∋ ⊥. By adj_g_mem_limit_f, no limit_dom points exist between x and z. So z IS the C5 witness: ⊤ ∈ f(z) (MCS) and ⊥ ∈ limit_g(x,z) (vacuously, since no w between x and z).

Wait — this is EXACTLY what limit_satisfies_c5_strong already proves! The existing proof DOES work for ξ=⊥. The witness z (midpoint) has ⊥ ∈ g(x,z) = B', and adj_g_mem_limit_f gives ⊥ ∈ limit_f(w) for any w between x and z, which is impossible (MCS), so no w exists. The limit C5 IS satisfied.

**The infinite chain is irrelevant to the limit C5 satisfaction.** Each point x has its OWN C5 witness z (its midpoint), and (x,z) is permanently closed. The fact that z has its OWN C5 witness z₁ (z's midpoint), and so on, doesn't affect x's C5.

**So the limit IS a valid chronicle.** C5 is satisfied. The model works. The only issue is getting from this model to ℤ.

**Strategy 7 is therefore**: Accept that the limit model is correct but has ω+ω\* intervals. Don't try to prove Icc_finite. Instead, build the countermodel differently.

## Recommended Approach

**Strategy 6 (quotient)** is the most viable and Burgess-faithful approach:

1. Keep the construction exactly as is (0 lines modified)
2. Define an equivalence relation collapsing ω+ω\* chains
3. Show the quotient ≃o ℤ  
4. Transport the FMCS through the quotient
5. Build BFMCS on ℤ from the transported FMCS

**Alternative**: If the quotient is too complex, consider Strategy 7 variant: build the countermodel on limit_dom directly by extending the ProofChecker's semantics to handle non-group domains (this is essentially task 120).

## Summary

| Strategy | Viable? | Lines Changed | New Lines | Risk |
|----------|---------|---------------|-----------|------|
| 1. Direct IsSuccArch | No | — | — | — |
| 2. Left-closure | Partial | 0 | ~100 | Low (but insufficient alone) |
| 3. No omega chain | No (arch.) | — | — | — |
| 4. Skip ξ=⊥ | No (tried) | ~300 | ~100 | Failed |
| 5. Prove Icc_finite | No | — | — | — |
| **6. Quotient** | **Yes** | **0** | **~300-500** | **Medium** |
| 7. Direct on limit_dom | Yes (arch. change) | ~500+ | ~500+ | High |
