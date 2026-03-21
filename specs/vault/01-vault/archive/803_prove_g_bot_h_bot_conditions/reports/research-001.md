# Research Report: G_bot/H_bot Conditions in UniversalCanonicalModel

**Task**: 803 - prove_g_bot_h_bot_conditions
**Session**: sess_1769992810_e5aa89
**Date**: 2026-02-02

## Summary

The G_bot and H_bot conditions in `UniversalCanonicalModel.lean` (lines 83-86) can be proven using the T-axiom pattern demonstrated in `InfinitaryStrongCompleteness.lean` (lines 368-421). The proof uses the temporal T-axioms (`temp_t_future` and `temp_t_past`) combined with MCS consistency properties.

## Problem Statement

### Location of Sorries

File: `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`

Lines 83-86:
```lean
have h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma := by
  sorry
have h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma := by
  sorry
```

### Context

In `representation_theorem`, `Gamma` is a `SetMaximalConsistent` set obtained by extending `{phi}` using `set_lindenbaum`:

```lean
obtain ⟨Gamma, h_extends, h_mcs⟩ := set_lindenbaum {phi} h_cons
```

Where:
- `h_extends : {phi} ⊆ Gamma`
- `h_mcs : SetMaximalConsistent Gamma`

## Proof Strategy

### Key Insight

The T-axioms provide:
- `temp_t_future`: `⊢ G phi → phi` (future includes present)
- `temp_t_past`: `⊢ H phi → phi` (past includes present)

When instantiated with `phi = Formula.bot`:
- `⊢ G⊥ → ⊥`
- `⊢ H⊥ → ⊥`

### Proof Outline for h_no_G_bot

1. Assume `G⊥ ∈ Gamma` for contradiction
2. By `mcs_closed_temp_t_future h_mcs Formula.bot h_G_bot_in`, we get `⊥ ∈ Gamma`
3. If `⊥ ∈ Gamma`, then `[⊥] ⊢ ⊥` (by assumption axiom)
4. But this means `Gamma` is inconsistent (derives `⊥` from a finite subset `[⊥]`)
5. This contradicts `h_mcs.1` (the consistency part of SetMaximalConsistent)

### Two Implementation Options

#### Option 1: Use mcs_closed_temp_t_future (Recommended - Shorter)

```lean
have h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma := by
  intro h_G_bot_in
  -- If G⊥ ∈ Gamma, then ⊥ ∈ Gamma by T-axiom closure
  have h_bot_in : Formula.bot ∈ Gamma :=
    mcs_closed_temp_t_future h_mcs Formula.bot h_G_bot_in
  -- But ⊥ ∈ Gamma contradicts MCS consistency
  apply h_mcs.1 [Formula.bot]
  · intro ψ hψ; simp at hψ; rw [hψ]; exact h_bot_in
  · constructor
    exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
```

#### Option 2: Direct T-axiom application (As in InfinitaryStrongCompleteness)

```lean
have h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma := by
  intro h_G_bot_in
  have h_axiom : ⊢ (Formula.all_future Formula.bot).imp Formula.bot :=
    DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future Formula.bot)
  have h_bot_in : Formula.bot ∈ Gamma := by
    by_contra h_not
    have h_incons : ¬SetConsistent (insert Formula.bot Gamma) := h_mcs.2 Formula.bot h_not
    apply h_mcs.1 [Formula.all_future Formula.bot]
    · intro ψ hψ; simp at hψ; rw [hψ]; exact h_G_bot_in
    · constructor
      have h_ax' : DerivationTree [Formula.all_future Formula.bot]
          ((Formula.all_future Formula.bot).imp Formula.bot) :=
        DerivationTree.weakening [] _ _ h_axiom (by simp)
      have h_assm : DerivationTree [Formula.all_future Formula.bot]
          (Formula.all_future Formula.bot) :=
        DerivationTree.assumption _ _ (by simp)
      exact DerivationTree.modus_ponens _ _ _ h_ax' h_assm
  apply h_mcs.1 [Formula.bot]
  · intro ψ hψ; simp at hψ; rw [hψ]; exact h_bot_in
  · constructor
    exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
```

### Proof for h_no_H_bot

Symmetric to h_no_G_bot, using:
- `mcs_closed_temp_t_past` instead of `mcs_closed_temp_t_future`
- `temp_t_past` instead of `temp_t_future`
- `Formula.all_past` instead of `Formula.all_future`

## Required Imports

The following are already imported via `TruthLemma.lean`:
- `Bimodal.ProofSystem.Axioms` - for `Axiom.temp_t_future`, `Axiom.temp_t_past`
- `Bimodal.Metalogic.Representation.IndexedMCSFamily` - for `mcs_closed_temp_t_future`, `mcs_closed_temp_t_past`

## Reference Files

| File | Purpose |
|------|---------|
| `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` | Contains the sorries (lines 83-86) |
| `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` | Working proof pattern (lines 368-421) |
| `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` | `mcs_closed_temp_t_future`, `mcs_closed_temp_t_past` (lines 257-296) |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | T-axiom definitions (lines 258-275) |

## Key Lemmas to Use

### mcs_closed_temp_t_future (IndexedMCSFamily.lean:257-273)

```lean
lemma mcs_closed_temp_t_future {Gamma : Set Formula} (h_mcs : SetMaximalConsistent Gamma)
    (φ : Formula) (h_G : Formula.all_future φ ∈ Gamma) : φ ∈ Gamma
```

### mcs_closed_temp_t_past (IndexedMCSFamily.lean:280-296)

```lean
lemma mcs_closed_temp_t_past {Gamma : Set Formula} (h_mcs : SetMaximalConsistent Gamma)
    (φ : Formula) (h_H : Formula.all_past φ ∈ Gamma) : φ ∈ Gamma
```

### SetMaximalConsistent Structure

From `MaximalConsistent.lean`, `SetMaximalConsistent Gamma` is a conjunction:
- `h_mcs.1 : SetConsistent Gamma` - No finite subset derives ⊥
- `h_mcs.2 : ∀ φ ∉ Gamma, ¬SetConsistent (insert φ Gamma)` - Maximality

## Implementation Recommendation

Use **Option 1** (mcs_closed_temp_t_future approach) as it is:
1. Shorter (5 lines vs 15 lines per proof)
2. Reuses existing infrastructure
3. Matches the style in TruthLemma.lean (lines 416, 445)

## Estimated Complexity

- **Difficulty**: Low
- **Lines of code**: ~10-15 lines total
- **Dependencies**: All required lemmas already exist
- **Risk**: None - this is a direct application of proven lemmas

## Verification Steps

1. Replace the sorries with the proof code
2. Run `lake build` to verify compilation
3. Confirm no new sorries are introduced
4. The `representation_theorem` should now compile fully

## Impact

Completing these proofs will:
- Make `representation_theorem` sorry-free
- Enable the `weak_completeness` path to become sorry-free
- Reduce the project's sorry count by 2
