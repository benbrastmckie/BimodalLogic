# Research Report: Task #83 — Strict vs Weak Temporal Semantics Analysis

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Mode**: Team Research (3 teammates)
**Session**: sess_1775227205_726938

## Summary

Three research agents investigated whether switching from weak (reflexive, `≤`) to strict (`<`) temporal semantics for G and H would improve the bimodal logic TM, and what the full scope of such a change would entail. The investigation covered: (A) complete codebase impact analysis, (B) logic-theoretic design of the ideal operator coordination, and (C) critical risk assessment.

**Central finding**: The ideal logic — fully strict G/H with fully strict Since/Until — is theoretically superior (Kamp-complete expressiveness, definable next-step operator X = `⊥ U φ`, cleaner backward truth lemma via discrete induction). However, the engineering cost is massive (67+ direct breakage sites, 18 files, 80-120 hours estimated), and the current blocker (Until/Since truth lemma sorries) is not caused by reflexive G/H semantics.

## Key Findings

### 1. Current Semantics (from Teammate A)

From `Truth.lean:118-129`:
- **G φ at t**: `∀ s, t ≤ s → φ(s)` — reflexive (includes present)
- **H φ at t**: `∀ s, s ≤ t → φ(s)` — reflexive (includes present)
- **φ U ψ at t**: `∃ s, t ≤ s ∧ ψ(s) ∧ ∀ r, t ≤ r → r < s → φ(r)` — half-open `[t, s)`
- **φ S ψ at t**: `∃ s, s ≤ t ∧ ψ(s) ∧ ∀ r, s < r → r ≤ t → φ(r)` — half-open `(s, t]`

The Until/Since definitions were recently changed from closed to half-open intervals as part of plan v7 Phase 1 (already completed). G and H remain reflexive.

### 2. Three Consistent Designs (from Teammate B)

| Design | G/H | U/S witness | U/S guard | F = ⊤ U? | T-axiom? | X definable? | Backward truth lemma |
|--------|-----|-------------|-----------|----------|----------|-------------|---------------------|
| **Reflexive + Closed** (previous) | `≤` | `≥` | `[t, s]` | Yes (refl F) | Yes | No | Blocked (until_intro unsound) |
| **Reflexive + Half-open** (plan v7) | `≤` | `≥` | `[t, s)` | F = φ ∨ F_strict | Yes | No | Hard (G too strong in until_intro) |
| **Fully strict** (ideal) | `<` | `>` | `(t, s)` | Yes (strict F) | No | **Yes** (`⊥ U φ`) | **Easy** (X gives discrete induction) |

### 3. The Ideal Logic (from Teammate B)

**Fully strict semantics** is standard in the mathematical/philosophical tradition (Kamp 1968, Burgess 1982, Xu 1988, Venema 1993). Key benefits:

- **Kamp completeness**: Strict S + U express everything first-order monadic logic of order can express over (ℤ, <)
- **Clean definability chain**: `F φ ≡ ⊤ U φ`, `P φ ≡ ⊤ S φ`, `X φ ≡ ⊥ U φ`, `Y φ ≡ ⊥ S φ`
- **Discrete unfold axiom**: `φ U ψ ↔ ψ ∨ (φ ∧ X(φ U ψ))` — uses next-step X instead of all-future G
- **Backward truth lemma becomes straightforward**: From `φ U ψ` at `t+1` and `φ` at `t`, derive `φ U ψ` at `t` by discrete induction. This eliminates the "G too strong" problem that plagues plan v7's Phase 4.

**Ideal axiom system** (Layer 2 only — S5 modal unchanged):
- TK_G/TK_H: Distribution axioms (unchanged)
- T4_G/T4_H: `G φ → G G φ`, `H φ → H H φ` (transitivity, still valid)
- TA: `φ → G P φ` (present recoverable from past-of-future; valid on ℤ since ℤ has no endpoints)
- TA_dual: `φ → H F φ` (symmetric)
- U-Induction, U-Linearity, U-S-Connectedness (Burgess-Xu core)
- Disc-F: `F ⊤ → ⊥ U ⊤` (discrete: if future exists, immediate successor exists)
- Disc-P: `P ⊤ → ⊥ S ⊤` (symmetric)
- Ser-F/Ser-P: `F ⊤`, `P ⊤` (seriality: ℤ has no endpoints)
- **T-axioms DROPPED**: `G φ → φ` and `H φ → φ` are invalid under strict semantics

### 4. Why the Backward Truth Lemma Difficulty Resolves (from Teammate B)

The current blocker in plan v7 Phase 4 is the backward truth lemma for Until. The root cause:

> The `until_intro` axiom uses `G(φ U ψ)`, which requires `φ U ψ` at ALL future times. But the semantic witness only provides information up to time `s`.

Under strict semantics with X-based axioms:
> `φ U ψ ↔ ψ ∨ (φ ∧ X(φ U ψ))` requires `φ U ψ` only at `t+1`, not all future times.

This converts the infinite quantifier problem into a single successor step, making backward induction trivial on discrete orders.

### 5. Complete Change Catalog (from Teammate A)

**87+ edit sites across 18+ Lean files**, organized in tiers:

| Tier | Scope | Key Files | Changes |
|------|-------|-----------|---------|
| 1 | Semantic definitions | `Truth.lean` | `≤` → `<` in G/H cases |
| 2 | Axiom system | `Axioms.lean`, `Substitution.lean` | Remove temp_t_future/past, reformulate until_intro/since_intro |
| 3 | Soundness proofs | `Soundness.lean`, `SoundnessLemmas.lean` | Rewrite 12+ validity proofs; density/seriality become non-trivial |
| 4 | Completeness (heavy) | `CanonicalIrreflexivity.lean`, `DovetailedChain.lean` (9 uses), `UltrafilterChain.lean` (14 uses), `SuccChainFMCS.lean` (8 uses) | Fundamental restructuring of canonical model |
| 5 | Derived theorems | `LinearityDerivedFacts.lean`, `Perpetuity/`, `Discreteness.lean` | Update proofs using T-axiom |
| 6 | FMP/Decidability | `TruthPreservation.lean`, `Tableau.lean` | Temporal truth preservation changes |
| 7 | Documentation | `typst/`, `latex/` | Update semantic descriptions |

**Positive**: `WitnessSeed.lean` was deliberately written to be strict-compatible (line 31: "These proofs work with irreflexive temporal semantics").

### 6. Critical Risks (from Teammate C)

| # | Risk | Severity |
|---|------|----------|
| 1 | T-axiom removal (87 sites, 18 files) | **CRITICAL** |
| 2 | FMCS structure redefinition (forward_G uses `≤`) | **CRITICAL** |
| 3 | Canonical frame becomes irreflexive (ExistsTask M M becomes false) | HIGH |
| 4 | Dovetailed chain reconstruction (9 T-axiom uses in only working approach) | HIGH |
| 5 | F/P ≡ ⊤ U/⊤ S equivalence breaks under mixed strict G + reflexive U | HIGH |
| 6 | Re-introduction of canonicalR irreflexivity problem (previously abandoned) | HIGH |
| 7 | Soundness proofs: density/seriality become genuine frame conditions | MEDIUM |
| 8 | Always operator: `H φ ∧ G φ` no longer implies `φ` | MEDIUM |

### 7. ROADMAP and Historical Context (from Teammates A and C)

`Truth.lean:16-18` documents: *"A previous version used strict semantics (<) which required an axiom for canonicalR irreflexivity. The current version uses reflexive semantics to eliminate this axiom and simplify the metalogic."*

`typst/chapters/06-notes.typ:187`: *"The fundamental obstacle is that irreflexivity is not modally definable."*

The project already tried strict semantics and abandoned it. None of the 7+ Boneyard failures were caused by reflexive semantics — they stem from deeper canonical model construction issues (MCS extension, bidirectional coherence, bundle semantics) that are independent of the strict/reflexive choice.

## Synthesis

### Conflicts Resolved

**Conflict 1: Effort estimates diverge.** Teammate A estimates 40-80 hours, Teammate C estimates 80-120 hours. Resolution: Teammate C's higher estimate is more realistic given the project's history of cascading failures in completeness proof refactoring. The 7+ Boneyard failures demonstrate that changes to the completeness infrastructure carry high risk of discovering new blockers. **Adopted estimate: 80-120 hours.**

**Conflict 2: Is the expressiveness gain worthwhile?** Teammate B argues fully strict semantics is the ideal (Kamp-complete, clean definability, easier backward truth lemma). Teammate C argues the gain is marginal and not relevant. Resolution: **Both are correct in their domains.** B is correct that the ideal logic uses strict semantics — this is the mathematical standard with genuine expressiveness gains (X definability, FOMLO completeness). C is correct that for the immediate task (closing 2 sorries), switching semantics is overkill and introduces enormous risk. The question is about the ideal state vs. the pragmatic path.

**Conflict 3: Does strict semantics help the current blocker?** B identifies that X-based until axioms would make the backward truth lemma trivial. C argues the blocker isn't caused by reflexive G/H. Resolution: **B's insight is the most important finding.** The backward truth lemma difficulty in plan v7 Phase 4 fundamentally stems from using G (all future) instead of X (next step) in `until_intro`. Under reflexive semantics, there is no way to define X from Until (`⊥ U φ` reduces to `φ` with reflexive witness). Under strict semantics, `X φ = ⊥ U φ` gives discrete induction for free. This is not just an expressiveness nicety — it directly resolves the structural proof difficulty.

### Gaps Identified

1. **Venema discrete extension specifics**: Teammate B references Venema (1993) for the complete axiom system for strict discrete orders, but the exact axiom list and completeness proof strategy for the bimodal S5+temporal combination needs deeper study.

2. **Irreflexivity workaround**: The canonicalR irreflexivity problem (the original reason for abandoning strict semantics) has no proposed solution. The literature on IRR-rules and irreflexivity-handling in canonical model theory needs investigation.

3. **Incremental migration path**: No teammate proposed a staged migration strategy that could reduce risk. A possible approach: introduce X as a defined operator first (within reflexive semantics as syntactic sugar), then migrate axioms to use X, then switch the semantics.

4. **Impact on Since/Until axioms under fully strict**: If Until becomes fully strict (`s > t`), the witness range excludes the present, and the Burgess-Xu unfold axiom changes form significantly. Teammate B's analysis shows this requires X-based rather than G-based unfold, but the complete set of necessary axiom modifications is not fully specified.

### Recommendations

#### The Ideal End State (Long-Term Vision)

The ideal TM logic over ℤ uses:
- **Fully strict G/H**: `G φ at t := ∀ s > t, φ(s)`, `H φ at t := ∀ s < t, φ(s)`
- **Fully strict U/S**: `φ U ψ at t := ∃ s > t, ψ(s) ∧ ∀ u ∈ (t,s), φ(u)`
- **Definable operators**: `X φ = ⊥ U φ`, `Y φ = ⊥ S φ`, `F φ = ⊤ U φ`, `P φ = ⊤ S φ`
- **X-based axioms**: `φ U ψ ↔ ψ ∨ (φ ∧ X(φ U ψ))` (discrete unfold)
- **No T-axioms**: Replace with `φ → G P φ` and `φ → H F φ`

This gives Kamp-complete expressiveness, clean operator coordination, and straightforward backward truth lemma proofs.

#### Pragmatic Path (Immediate Action)

1. **Complete plan v7** (half-open interval semantics with reflexive G/H) to close the immediate sorries. This is ~15 hours and addresses the direct blocker.

2. **Create a dedicated task** (e.g., task 84) for the strict semantics migration as a separate, planned effort. This should be:
   - Scoped as a major architectural change (80-120 hours)
   - Broken into phases: (a) X operator introduction, (b) axiom reformulation, (c) semantic switch, (d) completeness reconstruction
   - Executed only after plan v7 achieves sorry-free completeness, providing a working baseline to refactor from

3. **Key insight for plan v7**: Teammate B's analysis suggests the backward truth lemma could benefit from the U-Induction axiom with the right `χ` instantiation, even under reflexive semantics. This may be the missing piece for Phase 4 without requiring a semantics switch.

#### Staged Migration Strategy (If Pursuing Strict Semantics)

Phase 0: Complete plan v7 (sorry-free completeness baseline)
Phase 1: Introduce X/Y as syntactic definitions within current reflexive system
Phase 2: Prove X-based lemmas alongside G-based ones (parallel infrastructure)
Phase 3: Switch axiom formulations to X-based where beneficial
Phase 4: Switch semantic definitions to strict (the "big bang" moment)
Phase 5: Reconstruct soundness proofs
Phase 6: Reconstruct completeness proofs (hardest phase — canonicalR irreflexivity)
Phase 7: Clean up and verify

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Codebase impact | completed | high | Complete 87-site change catalog across 18 files; identified WitnessSeed strict-compatibility |
| B | Logic theory | completed | high | Three consistent designs; X-based axioms resolve backward truth lemma; Kamp completeness analysis |
| C | Critic/risks | completed | high | 8 concrete blockers cataloged; strongest counter-argument; historical context from ROADMAP and Boneyard |

## References

- Kamp, H. (1968). "Tense Logic and the Theory of Linear Order"
- Burgess, J. (1982). "Axioms for tense logic I: Since and Until"
- Xu, M. (1988). "On some U,S-tense logics"
- Venema, Y. (1993). "Completeness via Completeness" (strict discrete orders)
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations"
- Blackburn, de Rijke, Venema (2001). "Modal Logic" (irreflexivity not modally definable)
- Stanford Encyclopedia of Philosophy, "Temporal Logic" (Burgess-Xu supplement)
- Truth.lean:10-18 (historical note on strict→reflexive switch)
- WitnessSeed.lean:31 (strict-compatible infrastructure note)
