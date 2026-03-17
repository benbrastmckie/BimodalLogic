# Research Report: Task #981 — Consistency Proof Blocker Resolution

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-16
**Mode**: Team Research (2 teammates, logic domain)
**Session**: sess_1773705775_169372
**Run**: 003

---

## Summary

The Phase 2 blocker—proving consistency of `discreteImmediateSuccSeed(M)`—is definitively diagnosed: the **arbitrary forward witness containment approach is mathematically impossible**. Both teammates independently reached this conclusion with high confidence. The correct approach is a **direct finite derivation argument** exploiting the derivability of blocking formulas from their M-triggers. Additionally, `SuccOrder.ofCore` from Mathlib offers a cleaner path for Phase 5 that bypasses `LocallyFiniteOrder` entirely.

---

## Key Findings

### Finding 1: The Containment Approach Is Mathematically Impossible (HIGH confidence)

The current proof at `DiscreteSuccSeed.lean:280–455` attempts to prove `discreteImmediateSuccSeed(M) ⊆ W` for some arbitrary forward witness W. This approach **cannot succeed**:

- Blocking formula `blockingFormula(ψ) = ¬ψ ∨ ¬G(ψ)` is added to the seed when `¬G(ψ) ∈ M`
- An arbitrary forward witness W is constructed from seed `{¬⊥} ∪ g_content(M)` — it can freely include `G(ψ) ∈ W` and `ψ ∈ W`
- When both hold, `¬(¬ψ ∨ ¬G(ψ)) ∈ W` by MCS completeness + De Morgan
- So `blockingFormula(ψ) ∉ W`, breaking the containment

**The semantic reason**: Blocking formulas are *designed* to be false in witnesses that go "too far ahead". This is a feature, not a bug — it is precisely what makes `discreteImmediateSucc` an *immediate* successor. But it means no arbitrary forward witness can witness consistency of the full seed.

The sorry at line 445 cannot be filled. This branch of proof must be replaced entirely.

---

### Finding 2: The Correct Approach — Direct Finite Derivation (MEDIUM-HIGH confidence)

Both teammates converge on the **standard literature approach** (Segerberg/Verbrugge): prove consistency of the seed *directly*, by contradiction through finite derivation analysis.

**Proof structure**:

Assume `discreteImmediateSuccSeed(M)` is inconsistent. By compactness, there is a finite `L ⊆ seed` with `L ⊢ ⊥`. Decompose:

```
L = L_g ∪ L_b
    L_g ⊆ g_content(M)
    L_b ⊆ blockingFormulas(M)
```

**Case 1** (`L_b = ∅`): `L_g ⊢ ⊥`, contradicting `g_content_consistent` ✓

**Case 2** (`L_b ≠ ∅`): Each `bf ∈ L_b` has the form `¬ψ ∨ ¬G(ψ)` with trigger `¬G(ψ) ∈ M`.

Key lemma (already proved): `blocking_formula_from_negG` at `DiscreteSuccSeed.lean:258–264`:
```
[¬G(ψ)] ⊢ ¬ψ ∨ ¬G(ψ)   -- right disjunction introduction
```

By **cut/weakening**: since `[¬G(ψ)] ⊢ bf` and `L ⊢ ⊥`, we can substitute each `bf` in the derivation with its trigger `¬G(ψ)`:

```
L_g ∪ {¬G(ψ) | bf ∈ L_b, ¬G(ψ) triggers bf} ⊢ ⊥
```

Let `triggers = {¬G(ψ) | bf ∈ L_b}`. Note `triggers ⊆ M`.

**Remaining gap**: We need `L_g ∪ triggers ⊢ ⊥` to derive a contradiction. Since `g_content(M) ⊄ M` (g_content contains successors' formulas, not M's formulas), this requires showing:

```
{φ | G(φ) ∈ M} ∪ {¬G(ψ) | ¬G(ψ) ∈ M}  is jointly consistent
```

**The closing argument** uses the modal structure: if `L_g ∪ triggers ⊢ ⊥`, then by the K4-axiom (G4: `G(G(ψ)) → G(ψ)`) and monotonicity of G:

- Applying G to the derivation (G-inference rule): `G(L_g) ∪ G(triggers) ⊢ G(⊥)`, hence `⊢ ⊥` (contradicting soundness)
- More precisely: from `φ_1, …, φ_m, ¬G(ψ_1), …, ¬G(ψ_k) ⊢ ⊥`, we can conclude `G(φ_1), …, G(φ_m), ¬G(ψ_1), …, ¬G(ψ_k) ⊢ ⊥` using K-axiom and G4
- All these G-formulas are in M: `G(φ_i) ∈ M` (def. of g_content) and `¬G(ψ_j) ∈ M` (trigger condition)
- This gives `M ⊢ ⊥`, contradicting M's consistency ✓

> **Implementation note**: The G-inference step ("if L ⊢ φ then G(L) ⊢ G(φ)") needs careful formalization in Lean. Look for `SetMaximalConsistent.closed_under_derivation` or modal monotonicity lemmas in `MCSProperties.lean`. The pattern from `g_content_consistent` (line 209) uses `forward_temporal_witness_seed_consistent` — study its proof structure for the derivation-lifting pattern.

---

### Finding 3: `SuccOrder.ofCore` — Cleaner Path for Phase 5 (MEDIUM-HIGH confidence)

Mathlib provides `SuccOrder.ofCore` which constructs `SuccOrder` directly from a covering-style condition, **without requiring `LocallyFiniteOrder` first**:

```lean
SuccOrder.ofCore :
  (succ : α → α) →
  (∀ {a}, ¬IsMax a → ∀ b, a < b ↔ succ a ≤ b) →
  (∀ a, IsMax a → succ a = a) →
  SuccOrder α
```

The condition `∀ {a}, ¬IsMax a → ∀ b, a < b ↔ succ a ≤ b` is precisely the covering property in the `succ a ≤ b` form:
- `a < b → succ a ≤ b` (nothing strictly between a and succ a)
- `succ a ≤ b → a < b` (succ a is strictly above a)

**Revised Phase 5 plan**: Use `SuccOrder.ofCore` directly with `discreteImmediateSucc` as the successor function. Then `LocallyFiniteOrder` follows as a *consequence* from `LinearLocallyFiniteOrder.succOrder` (if the linear order is locally finite by `SuccOrder` + `PredOrder`).

This inverts the dependency order and is cleaner:
```
discreteImmediateSucc → covering property → SuccOrder.ofCore → LocallyFiniteOrder
```

---

### Finding 4: Existing Lemmas Ready to Use

The codebase already has key components:

| Lemma | File | Lines | Purpose |
|-------|------|-------|---------|
| `g_content_consistent` | DiscreteSuccSeed.lean | 209–253 | g_content is consistent |
| `blocking_formula_from_negG` | DiscreteSuccSeed.lean | 258–264 | `[¬G(ψ)] ⊢ bf` |
| `g_content_subset_implies_h_content_reverse` | WitnessSeed.lean | 324 | Key duality |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean | 79–178 | Pattern for G-inference lifting |
| `SetMaximalConsistent.disjunction_elim` | Completeness.lean | 117 | MCS disjunction property |

The sorry at line 445 must be **removed** and the entire section 280–455 replaced with the direct argument.

---

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Teammate A worried g_content(M) ⊄ M breaks the cut argument | Resolved: the final step uses G-inference to lift `L_g ∪ triggers ⊢ ⊥` to `G(L_g) ∪ triggers ⊢ ⊥`, where `G(L_g) ⊆ M` by definition |
| Whether blocking formula is "semantically correct" | Confirmed: the formula is correct; only the proof *strategy* was wrong |
| Whether SuccOrder requires LocallyFiniteOrder first | Resolved: `SuccOrder.ofCore` bypasses this; LocallyFiniteOrder follows afterward |

### Gaps Identified

1. **G-inference formalization**: The step "if `L ⊢ φ` then `G(L) ⊢ G(φ)`" needs a Lean lemma. Search for existing versions in `MCSProperties.lean` or `DerivationTree.lean` before writing new code.
2. **Cut admissibility**: The substitution of `bf` by its trigger in the derivation requires cut (or its equivalent). Verify that the proof system supports this.
3. **`SuccOrder.ofCore` availability**: Run `lean_local_search "SuccOrder.ofCore"` to verify it's in Mathlib and accessible.

---

## Recommendations

### Primary Recommendation: Replace Lines 280–455 with Direct Consistency Proof

**Proof template for Phase 2**:

```lean
theorem discreteImmediateSuccSeed_consistent
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (discreteImmediateSuccSeed M) := by
  -- Proof by contradiction: assume inconsistent
  intro L hL_sub ⟨d⟩
  -- Decompose L = L_g ∪ L_b
  -- Case 1: L_b = ∅ → contradicts g_content_consistent
  -- Case 2: L_b ≠ ∅ → substitute each bf with its trigger using blocking_formula_from_negG
  --         Then lift with G-inference to get G(L_g) ∪ triggers ⊆ M ⊢ ⊥
  --         Contradicts h_mcs.consistent
  sorry  -- NEW sorry with clear structure to fill
```

**Key lemma to find/prove first**:
```lean
-- Search: "if L ⊢ φ then G(L) ⊢ G(φ)" (G-monotonicity for sets of hypotheses)
-- Try: lean_local_search "g_inference" or "G_monotone"
```

### Secondary Recommendation: Update Phase 5 to Use `SuccOrder.ofCore`

Replace the `LocallyFiniteOrder → SuccOrder` derivation in Phase 5 with `SuccOrder.ofCore`, then derive `LocallyFiniteOrder` as a consequence.

### Fallback: Accept Axiom with Typeclass Constraint

If the G-inference step cannot be formalized (low probability), document the axiom formally and refactor `DiscreteTemporalFrame` typeclass to make `LocallyFiniteOrder` an explicit constraint. This is Approach D from Teammate B — not recommended, but available.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary consistency proof approaches | Completed | Medium-High |
| B | Alternative approaches and codebase analysis | Completed | High |

---

## References

- Verbrugge et al., "Completeness by construction for tense logics of linear time" — uses constructive method with blocking formulas; consistency is proven directly
- Segerberg (1970) — original blocking formula approach for discrete tense logic
- Goldblatt (1992), "Logics of Time and Computation" — canonical model constructions
- `DiscreteSuccSeed.lean` — current Phase 1 implementation (lines 258–264 critical)
- `WitnessSeed.lean:79–178` — `forward_temporal_witness_seed_consistent` proof pattern
- Mathlib `SuccOrder.ofCore` — cleaner Phase 5 path
