# Team Research Report: Task #93

**Task**: Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-12
**Mode**: Team Research (4 teammates)
**Session**: sess_1776064099_fe9c19

## Summary

Four researchers independently analyzed the TaskModel embedding sorry at `BXCanonical/Completeness.lean:154`, evaluating strategies for elegance, generality, and extensibility to both discrete and dense time domains. All four converge on **Strategy B (Bridge to Parametric Infrastructure)** as the correct approach, with important corrections, risk assessments, and strategic insights that refine the original research.

## Key Findings

### 1. Strategy B is unanimously confirmed — with corrections

All teammates agree: bridge BXCanonical witnesses to the existing parametric infrastructure via BFMCS construction. The alternatives collapse to Strategy B:
- **Strategy A** (direct construction) requires a truth lemma, which requires modal saturation for the Box case, which IS the BFMCS machinery (Teammate B)
- **Strategy C** (minimal proof) doesn't simplify because the truth lemma is by structural induction over all connectives (Teammate B)
- **Hybrid approaches** all collapse to Strategy B for the Box backward case (Teammate B)

### 2. Guard interval correction (Critic finding)

The original report claimed the Int guard interval `[t, t+1)` is "vacuously satisfied." This is **wrong**. The guard `∀ r, t ≤ r → r < t+1 → φ ∈ fam.mcs r` requires `φ ∈ fam.mcs t` (since r = t satisfies both bounds in Int). This is NOT vacuous — but it IS trivially satisfied because `bx_until_eventuality_resolution` provides exactly `φ ∈ w.formulas` at the starting point (via BX9 `until_elim`). The trick works, but the reasoning must be corrected.

### 3. Multi-obligation Until interleaving is the hidden difficulty

The t+1 trick works for ONE Until obligation per time step. Multiple simultaneous Until obligations `φ₁ U ψ₁` and `φ₂ U ψ₂` at the same time `t` require careful handling:
- Only one gets the t+1 slot; the other must wait
- The waiting Until must be PRESERVED as the chain advances
- BX8 (Until induction: `(φ U ψ) ∧ φ → φ U ψ` at next step) should propagate unresolved Until formulas forward
- BUT `φ₂ U ψ₂` is an Until formula, not a G-formula — `bx_le` only preserves G-formulas
- **Resolution**: The chain step must explicitly seed unresolved Until formulas into the Lindenbaum extension at each step. This is constructible but adds complexity.

### 4. The parametric infrastructure is already fully D-generic

Confirmed by Teammates A and D: `ParametricCanonicalTaskFrame D`, `ParametricCanonicalTaskModel D`, `parametric_canonical_truth_lemma`, and `parametric_algebraic_representation_conditional` are all parameterized over arbitrary `D : Type*` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. No changes needed to this layer for either Int or Rat.

### 5. Dense completeness is architecturally independent but technically harder

For `D = Rat`, the guard `{r : Rat | t ≤ r ∧ r < s}` is always infinite for `s > t`. The Int guard-interval trick fundamentally fails. Dense time requires genuinely different chain construction. However:
- The parametric infrastructure is reusable unchanged
- Only `construct_bfmcs` is D-specific
- BX5 (self-accumulation: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) propagates the Until formula itself through the guard interval, making dense guard population tractable (Teammate D's key insight)

### 6. All BXCanonical lemmas and parametric infrastructure are sorry-free

Verified by Critic (Teammate C): grep confirms zero sorry in Frame.lean, ParametricCanonical.lean, ParametricTruthLemma.lean, ParametricHistory.lean, ParametricRepresentation.lean. The 6 sorries in TenseS5Algebra/LindenbaumQuotient/InteriorOperators are NOT in the parametric import chain. No axiom contamination risk.

### 7. BXPoint ↔ ParametricCanonicalWorldState bridge is trivial

Both wrap `SetMaximalConsistent`. The coercion `⟨w.formulas, w.is_mcs⟩` is definitional. The task relations are definitionally equal: `bx_le w v = ExistsTask w.formulas v.formulas`. No transport lemma needed.

## Synthesis

### Conflicts Resolved

| Issue | Teammate A | Teammate C | Resolution |
|-------|-----------|-----------|------------|
| Guard vacuity | "Guard reduces to `φ ∈ fam.mcs t`" | "Report wrong: not vacuous" | **C is right**: guard is non-vacuous but trivially satisfied. A's analysis is correct in substance; the original report's "vacuous" claim is wrong. |
| Line estimate | 400-600 | 500-900 | **Realistic: 500-750**. C's higher estimate accounts for modal saturation complexity. A's lower estimate assumes smoother construction. |
| forward_F strictness | Uses `t < s` (strict) | Report conflates ≤ and < | **C is right**: forward_F uses strict `<`, forward_G uses non-strict `≤`. The chain must satisfy both. |
| Restricted coherence | Worth considering | Doesn't help (temporal F/P is unrestricted) | **B is right**: restricted Until/Since coherence narrows the Until burden but forward_F/backward_P remain unrestricted. Not a significant win for Int. |

### Gaps Identified

1. **Multi-obligation Until interleaving** (Critic): The chain construction must handle multiple simultaneous Until obligations. Need explicit Until-formula seeding in Lindenbaum extensions. Not addressed in the original report.

2. **≤ vs < inconsistency in FMCS docs** (Critic): `FMCSDef.lean` docstring says strict `<` but code uses non-strict `≤` for `forward_G`. Could cause confusion during implementation.

3. **Modal saturation complexity** (Critic): Each Diamond witness family needs its own dovetailed chain with all coherence properties. The original "100-150 lines" estimate for this step is significantly low.

4. **Backward Until/Since coherence**: Less analyzed than forward coherence. BX8 (`ψ → φ U ψ`) handles the reflexive base case. The step transfer (`(φ U ψ) ∈ fam.mcs (t+1) ∧ φ ∈ fam.mcs t → (φ U ψ) ∈ fam.mcs t`) needs the BX Until induction axiom.

### Recommendations

**Immediate (Task 93)**:
1. **Focus on D = Int only.** Dense time is a separate task (68). The `valid` quantifier makes this sufficient.
2. **Use BXCanonical witnesses directly**, not Boneyard code. All Boneyard approaches are deprecated and use strict semantics.
3. **Create `BXCanonical/CanonicalModel.lean`** as a separate module containing the Int-specific BFMCS construction.
4. **Priority-based chain construction**: Resolve Until obligations at t+1 (highest priority), then F/P obligations via dovetailing (normal priority). This ensures the guard trick works.
5. **Seed unresolved Until formulas explicitly** into Lindenbaum extensions at each chain step to handle multi-obligation interleaving.

**Architecture (for extensibility)**:
6. **Do NOT introduce a TemporalDomain typeclass.** Existing typeclasses (`AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`) are precisely right. Int vs Rat constructions genuinely differ in technique.
7. **Factor `construct_bfmcs` as a standalone callback.** This is the only D-specific component. The parametric infrastructure, truth lemma, and representation theorem are all D-generic and reusable.
8. **For the paper**: Emphasize the D-parametric truth lemma proved once, with only BFMCS construction being domain-specific. This is a genuine formalization methodology contribution.

**Dense extension (future Task 68)**:
9. **BX5 self-accumulation** (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population. It propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`.
10. **Cantor-domain chain construction** over a countable dense order, with interval-filling for Until guards.

### Revised Complexity Estimate

| Component | Lines | Confidence |
|-----------|-------|------------|
| Dovetailed chain (`Int → BXPoint`) | 200-300 | High |
| FMCS wrapping (forward_G, backward_H, forward_F, backward_P) | 100-150 | High |
| BFMCS packaging (modal saturation + coherences) | 150-200 | Medium |
| Until/Since coherence proofs | 50-100 | Medium-High |
| Bridge proof (instantiate `valid`, derive contradiction) | 50-100 | High |
| **Total** | **550-850** | **Medium-High** |

The higher estimate vs the original report (400-650) reflects the Critic's observation about modal saturation complexity and multi-obligation Until interleaving.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary strategy | completed | 8/10 | Detailed Int vs Rat analysis; priority-based chain design |
| B | Alternatives | completed | 7/10 | Boneyard archaeology (4 generations of failures); hybrid collapse proof |
| C | Critic | completed | high | Guard interval correction; multi-Until interleaving risk; sorry audit |
| D | Horizons | completed | high | D-generic architecture confirmed; BX5 insight for dense; publication alignment |

## References

### Core files (sorry-free, verified)
- `BXCanonical/Frame.lean` — All BXPoint witnesses proved
- `BXCanonical/Completeness.lean:154` — The sorry to close
- `Algebraic/ParametricCanonical.lean` — D-parametric frame
- `Algebraic/ParametricTruthLemma.lean` — D-parametric truth lemma
- `Algebraic/ParametricRepresentation.lean:254` — Conditional representation theorem
- `Bundle/FMCSDef.lean` — FMCS structure (forward_G uses ≤)
- `Bundle/TemporalCoherence.lean` — Coherence conditions (forward_F uses <)
- `Semantics/Validity.lean:73` — `valid` quantifies over all D

### Boneyard (analyzed for patterns, not for reuse)
- 4 generations of failed completeness approaches documented by Teammate B
- All blocked by Until propagation through chain steps — resolved by BXCanonical

### Sorries in broader Algebraic module (NOT in parametric path)
- TenseS5Algebra.lean: 3 sorry (annotated "derivable from BX")
- LindenbaumQuotient.lean: 2 sorry (annotated "derivable from BX")
- InteriorOperators.lean: 1 sorry (annotated "derivable from BX")
