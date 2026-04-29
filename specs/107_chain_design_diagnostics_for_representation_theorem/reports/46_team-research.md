# Research Report: Task #107 — Resolving the Inconsistent Case Blocker

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-29
**Session**: sess_1777484344_568000
**Mode**: Team Research (4 teammates)
**Type**: lean4

## Summary

The g_content(A) ⊆ B inconsistent case blocker is confirmed as a REAL gap in all known syntactic proof approaches — g_content⊆B, Xu 2.3, and Burgess's original D₀ all hit the same wall at the 2.0(iii) maximality extraction when {φ}∪B is inconsistent. The formula `untl(⊥, γ)` is satisfiable on non-dense frames (confirmed by Xu Theorem 4.6) and irrefutable in the minimal US tense logic.

Two viable paths remain:
1. **Option D (semantic shortcut via soundness)**: Prove the seed satisfiable model-theoretically, then use soundness (sorry-free, non-circular) to get consistency. No density assumption needed.
2. **Option A (density axiom)**: Add Burgess's F'(⊤) = ¬untl(⊥, ⊤) as an axiom. One-line fix for the blocker, but changes the axiom system's target frame class.

The codebase already has a `density_derivable` sorry stub at TemporalDerived.lean:143, confirming this gap was anticipated.

## Key Findings

### 1. All Syntactic Approaches Hit the Same Wall (Unanimous)

| Approach | Where it breaks | Root cause |
|----------|----------------|------------|
| g_content(A) ⊆ B via extension | ¬φ ∈ B → DC({φ}∪B) = Set.univ | 2.0(iii) needs consistent extension |
| Xu Lemma 2.3 (P(α) ∈ B) | H(¬α) ∈ B → same issue | 2.0(iii) needs consistent extension |
| Burgess D₀ seed | Step 1 uses 2.0(iii) | Same, masked by density in Burgess's setting |
| Xu 2.4 bypass | Requires Xu 2.3 for r(A,⊤,D) | P(α) ∈ B is a prerequisite |

The formula `untl(⊥, γ)` (guard=⊥, event=γ) is satisfiable when t has an immediate successor s: γ(s) holds and ⊥ on (t,s)=∅ is vacuous. This is irrefutable in TL_US(∅) — confirmed by Xu's Theorem 4.6 which explicitly constructs frames with U(⊤,⊥) true.

### 2. The Inconsistent Case Cannot Be Ruled Out Syntactically (Teammate B)

Seven derivation strategies were exhaustively attempted:
1. BX7 linearity → produces untl(⊥, γ₁∧γ₂), no contradiction
2. BX13 enrichment → enriches event but guard stays ⊥
3. BX14 separation → useful structure but doesn't resolve ⊥ guard
4. Since direction + enrichment → produces snce(¬φ, α∧untl(¬φ,φ)), irrefutable
5. temp_4 (G→GG) → propagates G-structure but doesn't help with untl(⊥,γ)
6. g_content(A) ⊆ C duality → gives φ ∈ C, P(α) ∈ C, but B ⊄ C
7. Combined BX4 + left_mono + BX13 → all reduce to untl(⊥,γ) ∈ A

**The key asymmetry** (Teammate B): g_content(A) ⊆ C IS provable because G(φ) at t gives φ at endpoint t' on ALL frames (endpoints are always reachable). But g_content(A) ⊆ B fails on non-dense frames because B represents the OPEN interval, which can be empty.

### 3. Option D: Semantic Shortcut via Soundness (Teammate A)

**Soundness is sorry-free**: Confirmed by grep — zero sorry in Soundness.lean. The main theorem at line 1042 has the right form: `DerivationTree Γ φ → truth_at M Ω τ t φ`.

**Non-circular**: Soundness.lean imports only ProofSystem.Derivation, Semantics.Validity, SoundnessLemmas. Zero imports from BXCanonical/Chronicle. Using soundness within completeness is standard and safe. (Teammate D verified.)

**The approach**:
1. Bridge lemma: `satisfiable_set_implies_SetConsistent` (~15-20 lines, straightforward from soundness contrapositive)
2. Prove seed `{β.neg} ∪ g_content(A) ∪ h_content(C)` is satisfiable: construct a model on a dense linear order (e.g., ℚ) with A true at t, C true at s>t, and show all seed elements are true at any u ∈ (t,s)
3. Apply bridge lemma to get SetConsistent

**Feasibility**: Bridge lemma is easy. Model construction is the bottleneck (~100-200 lines). Sub-approach D3 (per-finite-subset satisfiability) is most promising: for each finite L ⊆ seed, show L is satisfiable by a simple model, then Consistent(L) by soundness, then SetConsistent(seed) since L was arbitrary.

### 4. Option A: Density Axiom (Teammates B, D)

Burgess's density axiom F'(⊤) = ¬untl(⊥, ⊤): on dense orders, the guard interval (t,s) is always nonempty, so ⊥ on (t,s) always fails, making untl(⊥,γ) unsatisfiable.

**The codebase anticipated this**: `density_derivable` at TemporalDerived.lean:143 has `sorry` with comment "Under irreflexive semantics, GGφ → Gφ requires density, not just BX1."

**How it resolves the blocker**: From untl(⊥, γ) ∈ A, by BX3 (right_mono_until with G(γ→⊤) derivable): untl(⊥, ⊤) ∈ A. Density axiom ¬untl(⊥, ⊤) gives ¬untl(⊥, ⊤) ∈ A. Contradiction.

**Trade-off**: Changes the axiom system from "all linear orders" to "dense linear orders." The chronicle construction is over ℚ (dense), so soundness is maintained. But completeness would be for dense ordered groups only, not all ordered groups (excluding ℤ).

### 5. Burgess 2.2 Clarification (Teammate D)

Burgess 2.2 is about EVENT consistency, NOT guard consistency. untl(guard, event) ∈ MCS A implies event is consistent — NOT guard. So untl(⊥, γ) with inconsistent guard ⊥ and consistent event γ does NOT violate 2.2. This was a source of confusion in earlier analyses.

## Synthesis

### Conflicts Resolved

**"g_content(A) ⊆ B is provable" (Report 45)**: DEBUNKED. The consistent case is proved, but the inconsistent case is a genuine gap. All four teammates confirm.

**"Xu 2.4 avoids the problem" (Report 45)**: DEBUNKED. Xu 2.4 depends on Xu 2.3 which has the same gap. Teammate C traced the full dependency chain.

**"Burgess 2.2 resolves untl(⊥,γ)" (Report 46 density analysis)**: DEBUNKED. 2.2 constrains the EVENT, not the guard. Teammate D clarified.

### Gaps Identified

1. **No bridge lemma exists** from semantic satisfiability to SetConsistent (needed for Option D)
2. **Model construction formalization** is the main technical challenge for Option D
3. **The `density_derivable` sorry** at TemporalDerived.lean:143 is a known gap — it needs either a density axiom or semantic argument

## Recommendations

### If density is acceptable:

Add Burgess's F'(⊤) density axiom to BXAxiom. This is a one-line fix:
```lean
| density_future : BXAxiom [] (Formula.untl Formula.bot Formula.top).neg
```
Prove soundness (~10 lines). Then `density_derivable` and `past_density_derivable` close immediately. The inconsistent case of g_content⊆B dissolves. Total: ~2 hours.

### If density is NOT acceptable (preserve "all linear orders"):

Implement Option D (semantic shortcut):
1. Build `satisfiable_set_implies_SetConsistent` bridge lemma (~15-20 lines)
2. Build model construction showing seed is satisfiable (~100-200 lines)
3. Close `splitting_seed_consistent` via satisfiability + bridge (~10 lines)
Total: ~8-12 hours.

The model construction is the bottleneck. The D3 approach (per-finite-subset) may reduce complexity.

### Recommended: Hybrid approach

Since the chronicle IS constructed over ℚ (dense), and completeness over dense ordered groups is the actual goal, adding the density axiom is mathematically correct and dramatically simpler. However, the Option D approach would give the stronger result (completeness for ALL linear orders, using only the base BX axioms + soundness). The choice is a design decision for the user.

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | Option D (soundness) | completed | Soundness sorry-free, bridge lemma straightforward, model construction is bottleneck |
| B | Option B (impossible) | completed | 7 strategies exhausted, all fail; density_derivable sorry found; asymmetry identified |
| C | Option C (Xu bypass) | completed | Xu 2.3 has same gap; all approaches confirmed equivalent; dependency chain traced |
| D | Critic | completed | Burgess 2.2 = event consistency (not guard); temp_4 exists; soundness non-circular |

## References

- Burgess 1982, Section 1.6: density axiom F'(⊤)
- Xu 1988, Theorem 4.6: untl(⊥,⊤) satisfiable in TL_US({(6),(16),(17)})
- specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/45_phase5b-inconsistent-case-blocker.md
- specs/107_chain_design_diagnostics_for_representation_theorem/reports/46_density-analysis.md
