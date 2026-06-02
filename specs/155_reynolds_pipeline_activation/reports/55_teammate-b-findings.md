# Teammate B Findings: Alternative Approaches for Sorry-Free `completeness_discrete`

**Task**: 155 — Fix no_gaps_discrete import cycle for sorry-free discrete completeness
**Date**: 2026-06-02
**Angle**: Alternative mathematical strategies (approaches NOT tried in v50-v55)

## Key Findings

### Finding 1: The Root Problem Is Narrower Than It Appears

The sorry chain bottlenecks at exactly TWO restricted coherence proofs: `restricted_tc` and `restricted_fuc` in ChronicleToCountermodel.lean. Both use `succ_embed_surjective` in an identical pattern:

```
limit_F_resolution gives witness y ∈ limit_dom
succ_embed_surjective maps y → integer k  ← SORRY
return (k - offset) as the integer witness
```

The third coherence proof (`restricted_buc`) does NOT use surjectivity — it works by contrapositive using `succ_embed_squeeze_strict` (which only needs that between two embedded points, no "extra" point exists — a local property that's already proved).

The BFMCS construction itself (`cantor_bfmcs_discrete`) is already correct: `modal_forward`, `modal_backward`, and all family definitions are sorry-free.

**Implication**: Any solution needs to address only forward F/P resolution and forward Until/Since resolution on the Z-indexed model. Backward Until/Since is already done.

### Finding 2: The Dense Case Succeeds Because Cantor Provides a Free Isomorphism

In the dense case:
- The chronicle's `LimitDomSubtype` is countable + dense + no min + no max
- Mathlib's `Rat.orderIsoOfCountableDenseNoMinNoMax` gives `LimitDomSubtype ≃o ℚ` automatically
- Every `ℚ`-point maps to a `limit_dom` point via the inverse isomorphism
- No surjectivity lemma needed — the Cantor isomorphism IS the surjection

In the discrete case:
- Mathlib's `orderIsoIntOfLinearSuccPredArch` requires `IsSuccArchimedean` as a hypothesis
- `IsSuccArchimedean` means every point is reachable from any other by finitely many successor steps
- This is `succ_cofinal`, the root sorry

The asymmetry is fundamental: countable dense linear orders are all isomorphic (Cantor's theorem), but countable discrete linear orders with succ/pred are NOT (Z ≅ Z, but Z+Z ≇ Z).

### Finding 3: Venema's "Completeness via Completeness" Does Not Transfer to the Discrete Case

Venema 1993 proves completeness for well-ordered and ω flows of time using this scheme:
1. Get a linear model M (from Burgess' base completeness)
2. Show M is "definably well-ordered" (via the W axiom making Stavi connectives trivially ⊥)
3. Apply Doets' Theorem 3.8 to get a well-ordered n-equivalent M'

This does NOT work for Z because:
- **Doets' theorem (1989) handles well-orderings**, not Z-like structures. His Theorem 3.8 says: "if M is definably well-ordered, then M has well-ordered n-equivalents for all n." There is no analogous theorem saying "if M is definably Z-like, then M has Z-isomorphic n-equivalents."
- The discrete axiom U(⊤,⊥) does NOT make the model "definably isomorphic to Z." It ensures each point has an immediate successor, but multiple Z-orbits (like Z+Z) are consistent with all discrete axioms.
- Doets' scattered-ordering theorem (2.4) could potentially provide scattered n-equivalents, but Z is not scattered in general — the limit points of limit_dom could create dense sub-intervals in the condensation.

**Conclusion**: The Venema/Doets transfer approach is a dead end for Z-completeness.

### Finding 4: Verbrugge's Direct Z Construction Is the Most Promising Alternative

Verbrugge et al. (2004) prove Z-completeness directly via step-by-step construction, entirely bypassing any chronicle or limit domain. Their Theorem 6 shows:

**Construction sketch** (adapted from Verbrugge):
1. Take a finite adequate set Σ containing the target formula (closed under subformulas and certain temporal operations)
2. Start with a maximal Σ-consistent set Γ₀ at position 0
3. Build a finite "middle stretch" by creating "maximal" right successor Γ_r and "minimal" left predecessor Γ_l
4. Handle ¬G demands in the middle stretch using the Z1 axiom: G(Gφ→φ) → (FGφ→Gφ)
5. Extend infinitely in both directions: beyond Γ_r, G-formulas stabilize, and remaining ¬G demands are fulfilled cyclically

**Why this is promising for our case**:
- The construction builds directly on Z — no limit_dom subtype, no succ_embed, no surjectivity
- F-resolution is guaranteed BY CONSTRUCTION (demands are processed cyclically)
- Until/Since resolution in a discrete order decomposes into one-step propagation via BX5 self-accumulation
- The Z1 axiom (which our formalization HAS as `Axiom.prior_UZ`) is exactly what the Verbrugge proof uses

**Key challenge**: Verbrugge's proof is for G/H tense logic only (no S/U connectives). Extending to S/U requires:
- Handling Until/Since witness demands in the step-by-step construction
- In discrete time, U(φ,ψ) at position n decomposes: either ψ(n+1) [witness found], or φ(n+1) ∧ U(φ,ψ)(n+1) [demand propagates]
- This one-step decomposition means Until demands can be processed alongside G demands
- Termination: the finite adequate set has finitely many formula types, so cyclic processing must eventually fulfill all demands

**Estimated effort**: 500-1000 lines of new Lean code. Would create a `DirectDiscreteBFMCS` that replaces the chronicle-based `cantor_bfmcs_discrete` for the restricted coherence proofs.

### Finding 5: The Mosaic Approach Is Viable But Too Costly

Caleiro, Viganò & Volpe (2013) prove completeness for exactly our logic class (S5 + linear tense) using mosaics. Their approach:
- A mosaic is a small fragment (≤6 points) of a model satisfying local consistency conditions
- A "saturated set of mosaics" guarantees a global model exists
- Completeness: consistent formula → satisfying mosaic set → model

This would completely bypass the chronicle and all associated problems. However:
- The mosaic approach requires a fundamentally different proof architecture
- Estimated 2000-4000 lines of new infrastructure
- Would not reuse any existing parametric canonical model code
- The paper's proofs for the discrete case with Until/Since are only sketched

**Verdict**: Correct but impractical given existing code investment.

### Finding 6: Orbit Restriction Cannot Work Without Proving the Core Claim

I investigated restricting the model to the orbit of 0 (the single Z-orbit containing the root point):
- Orbit(0) = {succ^k(0) | k ∈ Z} ⊆ LimitDomSubtype
- This orbit IS IsSuccArchimedean by definition → Z-isomorphism is free
- The FMCS restricted to this orbit has correct G/H coherence

**Problem**: F-resolution fails. If F(φ) ∈ limit_f(succ_embed(t)), the chronicle's F-resolution witness y may lie OUTSIDE Orbit(0). The formula G(¬φ) quantifies over ALL limit_dom points (not just orbit points), so we cannot derive G(¬φ) from "¬φ at all orbit points." Non-orbit points could witness F(φ) without any orbit point witnessing it.

Proving that all F-resolution witnesses lie within Orbit(0) is EQUIVALENT to proving succ_cofinal — the very sorry we're trying to eliminate.

### Finding 7: The Existing Infrastructure Supports a Hybrid Approach

Reading the `ParametricCanonical.lean` and `ParametricCompleteness.lean` modules reveals that the parametric framework is deliberately D-agnostic. The `BFMCS D` type requires:
- Families of FMCS indexed by D
- Modal forward/backward coherence
- An evaluation family

The restricted truth lemma (`RestrictedParametricTruthLemma.lean`) needs:
- `restricted_temporally_coherent root` — F/P for subformulas of root
- `restricted_backward_until_since_coherent root` — contrapositive U/S
- `restricted_forward_until_since_coherent root` — forward U/S witness

A hybrid approach would:
1. **Keep** the existing `cantor_bfmcs_discrete` for BFMCS structure (modal coherence already works)
2. **Keep** the existing `restricted_buc` (backward U/S works via squeeze)
3. **Replace only** `restricted_tc` and `restricted_fuc` with proofs based on the Verbrugge-style direct argument

This minimizes new code while addressing the exact sorry sites.

## Recommended Approach

**Primary Recommendation: Direct Z Construction (Verbrugge-style, adapted for S/U)**

Build FMCS families on Z directly using a step-by-step construction that incorporates F/P and U/S witness fulfillment into the construction itself. This has the following advantages:

1. **Mathematically rigorous**: The Verbrugge construction for Z is a standard result (published 2004, building on techniques from the 1970s-80s). The extension to S/U uses standard decomposition in discrete time.

2. **Addresses the root cause**: The problem is that the chronicle construction doesn't guarantee single-orbit in the discrete case. A direct Z construction doesn't create orbits at all — it IS Z by definition.

3. **Minimizes disruption**: Using the hybrid approach (Finding 7), only `restricted_tc` and `restricted_fuc` need replacement. The BFMCS structure, modal coherence, backward U/S coherence, and the entire parametric truth lemma infrastructure remain unchanged.

4. **Avoids speculative claims**: Plans v50-v55 each rely on proving something about the chronicle construction that may or may not be true (frozen guards, model surgery, Henkin chains). The Verbrugge approach has no speculative step — it constructs the model correctly from the start.

**Secondary (if Verbrugge is too costly): Prove restricted_tc/restricted_fuc via stepwise induction on the Z-indexed model**

Instead of constructing new families, prove that the EXISTING `rooted_succ_discrete_fmcs` satisfies restricted_tc/restricted_fuc by showing that F(φ) ∈ fam.mcs(t) implies φ ∈ fam.mcs(t+k) for some finite k, using:
- The discrete decomposition: F(φ) ↔ φ (at next) ∨ F(φ) (at next)
- The Z1 axiom: G(Gφ→φ) → (FGφ→Gφ) prevents infinite deferral
- An adequate-set-style argument that only finitely many formula types can appear in the cyclic extension

This would prove restricted_tc without surjectivity, using only the step structure of succ_embed.

## Evidence/Examples

### Verbrugge Cyclic Extension (from Theorem 6)

After the finite middle stretch is built, the right extension proceeds:
```
Γ_r has ¬Gφ₁, ..., ¬Gφ_k  (finitely many demands)
Step 1: create successor with ¬φ₁ ∈ Γ_{r+1}  (and Γ_r ≺ Γ_{r+1})
Step 2: create successor with ¬φ₂ ∈ Γ_{r+2}
...
Step k: create successor with ¬φ_k ∈ Γ_{r+k}
Step k+1: back to ¬φ₁  (cyclic)
```

F-resolution: If F(φ) ∈ Γ_r, then ¬G(¬φ) ∈ Γ_r, so ¬(¬φ) is one of the demands. Within at most k steps, ¬(¬φ) = φ appears at some position. QED.

### Discrete Until Decomposition

U(φ,ψ) at position n in a discrete order:
- If ψ ∈ mcs(n+1): witness is n+1, guard is vacuous (no points between n and n+1)
- If φ ∈ mcs(n+1) and U(φ,ψ) ∈ mcs(n+1): guard holds at n+1, demand propagates
- Eventually: finite adequate set means only finitely many types → must terminate

This decomposition is derivable from the BX axiom system (BX5 self-accumulation + discreteness).

### Dense vs Discrete Architecture Comparison

| Aspect | Dense (sorry-free) | Discrete (sorry) | Proposed |
|--------|-------------------|-------------------|----------|
| Chronicle → Domain | ≃o Rat (Cantor) | ≃o Z (requires IsSuccArch) | Direct Z |
| Surjectivity | Free (Cantor iso) | succ_embed_surjective (SORRY) | Not needed |
| F-resolution | Cantor iso inverse | succ_embed_surjective | By construction |
| U/S forward | Cantor iso inverse | succ_embed_surjective | By construction |
| U/S backward | Squeeze lemma | Squeeze lemma (works!) | Same |

## Confidence Level

**High** for the Verbrugge-style direct construction — the mathematics is standard and well-understood. The main risk is implementation effort (500-1000 lines), not mathematical correctness.

**Medium** for the stepwise induction alternative — the argument is plausible but requires careful handling of the interaction between Z1, Until accumulation, and the adequate set.

**Low** for Doets transfer, mosaic completeness, or orbit restriction — each has fundamental obstacles that would require solving problems at least as hard as the original.
