# Research Report: Task #83 — The X-Content Propagation Blocker and Deterministic Chain Resolution

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Mode**: Team Research (2 teammates)
**Session**: sess_1775258950_94a566

## Summary

Two-agent investigation of the last blocker for `completeness_over_Int`: X-content propagation through the dovetailed chain. The root cause is that under strict semantics, `until_unfold` produces X-formulas (next-step), but the successor seed (`temporal_box_g_seed`) only propagates g_content (all-future). This blocks Until persistence, which blocks F-resolution, which blocks the truth lemma.

**Key finding**: The TM axiom system is **missing two standard axioms** that were implicitly available under reflexive semantics:
1. **X-K** (X-distribution): `X(p → q) → (X(p) → X(q))`
2. **X-Det** (X-determinism): `¬X(p) → X(¬p)`

Both are valid on all discrete linear frames and universally included in standard temporal logic axiomatizations (Burgess 1984, Gabbay-Hodkinson-Reynolds 1994, Goldblatt 1992). Their absence was exposed by the strict-semantics transition.

**Resolution**: With X-K + X-Det, `x_content(M) = {a | X(a) ∈ M}` is itself an MCS. This enables a **deterministic chain construction** where `chain(n+1) = x_content(chain(n))` — no Lindenbaum extension or fair scheduling needed. The truth lemma then follows by structural induction on Until-depth.

## Key Findings

### 1. Root Cause: All 8 Critical Sorries Trace to X-Content Propagation

Teammate B mapped the complete dependency graph:

```
completeness_over_Int
  ├── restricted_shifted_truth_lemma (Until/Since cases: 2 sorries)
  │     └── needs forward_F + Until persistence
  └── dovetailed_bfmcs_restricted_temporally_coherent
        ├── DovetailedFMCS_forward_F (1 sorry)
        │     └── forward_dovetailed_until_persists (1 sorry) → X-content
        └── DovetailedFMCS_backward_P (1 sorry)
              └── backward_dovetailed_since_persists (1 sorry) → Y-content
```

Plus 2 Until/Since persistence sorries in the chain = **8 total**, all traceable to a single root: the successor seed lacks x_content.

### 2. X-K Is NOT Derivable from Current TM Axioms (HIGH confidence: 95%)

Teammate A exhaustively analyzed all 35 axioms:

- **`until_induction`** gives only G-level distribution: `G(a → b) → (X(a) → X(b))`. The premise must be under G, not X.
- **`until_linearity`** with φ=φ'=⊥ gives `X(a) ∧ X(b) → X(a ∧ X(b)) ∨ X(b ∧ X(a)) ∨ F(a ∧ b)`, which doesn't reduce to X-conjunction.
- **`temp_k_dist`** is for G, not X. No analogous axiom exists for X.
- No combination of axioms decomposes `X(p → q)` into parts.

The gap: X is treated as a derived notion (`X(a) = ⊥ U a`) with no distribution principle. Under reflexive semantics, X-K was trivially available (X(a) degenerates to a). The strict transition broke this.

### 3. X-K + X-Det Are Standard and Sound (VERY HIGH confidence: 99%)

**Literature**: X-K is universally included when X is primitive:
- Gabbay, Hodkinson, Reynolds (1994): axiom schema N2
- Goldblatt (1992): explicit axiom for functional successor
- Burgess (1984): fundamental axiom for Next

**Three equivalent formulations** (interderivable given X-Necessitation):
- X-K: `X(p → q) → (X(p) → X(q))`
- X-Conj: `X(p) ∧ X(q) → X(p ∧ q)`
- X-Det + X-K: `¬X(p) ↔ X(¬p)` together with K

**Soundness**: On discrete linear frames (ℤ with SuccOrder), X(a) at t means a at t+1 (deterministic successor). Modus ponens at t+1 validates X-K. Excluded middle at t+1 validates X-Det.

### 4. The Seed Consistency Problem: X-Lift ≠ G-Lift (CRITICAL finding)

Teammate A discovered that simply adding x_content to the seed does NOT work with the existing consistency proof:

- **G-lift argument** (current): from L ⊆ g_content, L ⊢ ¬phi, derive G(¬phi) ∈ M. F(phi) = ¬G(¬phi) ∈ M. **Contradiction.** ✓
- **X-lift argument** (proposed): from L ⊆ x_content, L ⊢ ¬phi, derive X(¬phi) ∈ M. F(phi) ∈ M. **No contradiction** — X(¬phi) means ¬phi at t+1, F(phi) means phi at some s > t, possibly s > t+1.

This means `{phi} ∪ x_content(M)` can be **genuinely inconsistent** when X(¬phi) ∈ M (phi not at next step, but at some future step).

### 5. The Deterministic Chain Resolution (KEY insight)

With X-K + X-Det, a fundamentally better construction becomes available:

**Theorem**: If M is MCS on a discrete frame and X-K + X-Det are axioms, then `x_content(M) = {a | X(a) ∈ M}` is itself an MCS.

*Proof sketch*:
- **Consistent**: If L ⊆ x_content(M) with L ⊢ ⊥, then by X-Nec + X-K, X(⊥) ∈ M. By X_bot_absurd, ⊥ ∈ M. Contradiction.
- **Deductively closed**: If a, a→b ∈ x_content(M), then X(a), X(a→b) ∈ M. By X-K: X(b) ∈ M. So b ∈ x_content(M).
- **Maximal**: For any p: X(p) ∈ M or X(¬p) ∈ M (from X-Det + MCS maximality of M). So p ∈ x_content(M) or ¬p ∈ x_content(M).

**Consequence**: Define `chain(n+1) = x_content(chain(n))`. The chain is **deterministic** — no Lindenbaum extension, no fair scheduling, no arbitrary choices. Every element of chain(n+1) is completely determined by chain(n).

**Properties of the deterministic chain**:
1. **G-coherence**: G(a) ∈ chain(n) → G(G(a)) ∈ chain(n) [temp_4] → X(G(a)) ∈ chain(n) [G→X] → G(a) ∈ chain(n+1). By induction: a ∈ chain(m) for all m > n.
2. **Box-class agreement**: □(a) ∈ chain(n) → G(□(a)) ∈ chain(n) [temp_a] → X(□(a)) ∈ chain(n) → □(a) ∈ chain(n+1). Propagates.
3. **Until persistence**: (φ U ψ) ∈ chain(n), ψ ∉ chain(n) → X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(n) [until_unfold] → ψ ∨ (φ ∧ (φ U ψ)) ∈ chain(n+1) [x_content]. Since ψ ∉ chain(n+1) (if not resolved): φ ∧ (φ U ψ) ∈ chain(n+1). **Both φ and (φ U ψ) persist.** ✓
4. **F-resolution is NOT needed per-step**: The truth lemma handles F-witness existence non-constructively.

### 6. The Complete Truth Lemma Strategy

**Induction measure**: Until-depth of formulas.
- Atoms: 0. Negation/implication: max of subformulas. Box/G/H: same as argument. Until/Since: max + 1.

**Until case — Forward** (`(φ U ψ) ∈ chain(t) → truth(φ U ψ, t)`):

1. `(φ U ψ) ∈ chain(t)` → `F(ψ) ∈ chain(t)` [until_implies_some_future]
2. By truth lemma for F(ψ) (lower Until-depth): truth(F(ψ), t), i.e., ∃ s > t with truth(ψ, s)
3. Take minimal s > t with truth(ψ, s). By IH on ψ (backward): ψ ∈ chain(s).
4. For intermediate r ∈ (t, s): ψ ∉ chain(r) (minimality). By Until persistence (property 3 above): (φ U ψ) ∈ chain(r) and φ ∈ chain(r). By IH on φ: truth(φ, r).
5. Combining: truth(φ U ψ, t) with witness s. ✓

Step 2 is non-constructive (existence from ¬∀ via classical logic). The minimal s in step 3 exists by well-ordering of ℕ.

**Until case — Backward** (`truth(φ U ψ, t) → (φ U ψ) ∈ chain(t)`):

By contrapositive: ¬(φ U ψ) ∈ chain(t) → truth(¬(φ U ψ), t) [by truth lemma for negation, IH] → ¬truth(φ U ψ, t). ✓

**Truth lemma for F(ψ)**: Since F(ψ) = ¬G(¬ψ):
- Forward: F(ψ) ∈ chain(t) means ¬G(¬ψ) ∈ chain(t). If truth(G(¬ψ), t), then by backward truth lemma for G(¬ψ) (IH): G(¬ψ) ∈ chain(t). Contradiction with MCS. So ¬truth(G(¬ψ), t) = truth(F(ψ), t). ✓

### 7. Impact Assessment: What Needs to Change

| Component | Change | Scope |
|-----------|--------|-------|
| `Axioms.lean` | Add 4 constructors: x_k_dist, x_det, y_k_dist, y_det | ~30 lines |
| `Substitution.lean` | 4 new pattern match cases | ~15 lines |
| `Soundness.lean` | 4 soundness proofs + ~8 pattern match cases | ~100 lines |
| `SoundnessLemmas.lean` | ~4 pattern match cases | ~10 lines |
| `FrameConditions/` | Compatibility cases | ~10 lines |
| `UltrafilterChain.lean` | New `x_content_mcs` theorem, deterministic chain | ~200 lines |
| `DovetailedChain.lean` | Replace dovetailed chain with deterministic chain | ~300 lines (rewrite) |
| `CanonicalConstruction.lean` | Truth lemma Until/Since cases | ~200 lines |
| `TemporalDerived.lean` | X-conjunction, X-determinism derived theorems | ~50 lines |
| **Total** | | **~900 lines changed** |

**Risk**: The deterministic chain is a SIMPLER construction than the dovetailed chain, so this is actually a simplification. The fair scheduling infrastructure (`schedule_formula`, `forward_dovetailed_until_propagate`, etc.) becomes unnecessary.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate B | Resolution |
|----------|-----------|-----------|------------|
| Does X-K alone resolve the blocker? | "Partially — seed consistency fails" | "The real fix is enriching the seed" | Neither: the DETERMINISTIC CHAIN avoids the seed consistency problem entirely. x_content IS the successor, no Lindenbaum needed. |
| Is F-resolution the bottleneck? | Not directly analyzed | "F-resolution is sound, Until persistence is the bottleneck" | F-resolution becomes moot with the deterministic chain — the truth lemma handles witnesses non-constructively. |

### Gaps Not Covered

1. **Lean implementation details**: The exact form of x_det as a Lean constructor needs careful encoding (Formula.neg (Formula.untl ...) vs implication form).
2. **Backward chain**: The y_content construction for the backward chain (negative integers) is symmetric but needs explicit work.
3. **Whether temporal_duality can derive Y-K/Y-Det from X-K/X-Det** — if so, only 2 axioms are needed instead of 4.
4. **Interaction with existing FMP completeness**: The FMP path doesn't use Until persistence and remains sorry-free. The deterministic chain approach only affects the Int-completeness path.

## Recommendations

### Priority 1: Add X-K + X-Det Axioms (2-4 hours)
Add the axioms, prove soundness, update all pattern matches. This is mechanical and well-defined. Start here.

### Priority 2: Prove x_content is MCS (2-3 hours)
Using X-K + X-Det + X_bot_absurd + disc_next, prove x_content(M) has consistency, deductive closure, and maximality. This is the mathematical core.

### Priority 3: Build Deterministic Chain (3-4 hours)
Replace the dovetailed chain with chain(n+1) = x_content(chain(n)). Prove G-coherence, box_class_agree, and Until persistence as chain properties. Delete or archive the fair scheduling infrastructure.

### Priority 4: Complete Truth Lemma (3-4 hours)
Close the Until/Since cases using the strategy from §6. The forward direction uses F-witness (non-constructive, classical) + minimality + Until persistence. The backward direction uses contrapositive.

### Priority 5: Wire to completeness_over_Int (1-2 hours)
Connect the deterministic chain's truth lemma to the existing completeness theorem structure.

**Total estimated effort**: 11-17 hours (comparable to current plan, but with a PROVABLY CORRECT mathematical foundation instead of the stuck approach).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | X-K derivability, literature, seed analysis | completed | HIGH (90-99%) |
| B | F-resolution, alternatives, dependency graph | completed | HIGH (90-95%) |

## References

- Burgess, J. (1984). "Basic Tense Logic." *Handbook of Philosophical Logic*, Vol. II.
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1.
- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed.
- Reynolds, M. (2003). "An Axiomatization of Full Computation Tree Logic." *Journal of Symbolic Logic*.
