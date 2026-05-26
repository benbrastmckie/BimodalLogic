# Phase 4 Handoff: Soundness Refactor (Partial)

**Task**: 168 - Parameterize DerivationTree over FrameClass
**Phase**: 4 of 7
**Status**: IN PROGRESS (SoundnessLemmas done, Soundness/DenseSoundness/DiscreteSoundness remaining)
**Session**: sess_1779757476_869869
**Date**: 2026-05-25

## Summary

SoundnessLemmas.lean is fully refactored and compiles. Soundness.lean, DenseSoundness.lean, and DiscreteSoundness.lean need the same treatment.

## Completed: SoundnessLemmas.lean

### Changes Made

1. **Opened FrameClass**: `open Bimodal.ProofSystem (Axiom DerivationTree FrameClass)`

2. **`axiom_swap_valid`**: Changed `h_dc : h.isDenseCompatible` to `h_fc : h.minFrameClass ≤ FrameClass.Dense`. Added `density` case (swap proof: HHφ → Hφ via `exists_between`). Dismissals: `prior_UZ/SZ/z1 => absurd h_fc (by simp [Axiom.minFrameClass, LE.le])`.

3. **`axiom_locally_valid`**: Same pattern. Added density case (GGφ → Gφ via `exists_between`).

4. **`derivable_valid_and_swap_valid`**: Changed to take `DerivationTree FrameClass.Dense [] φ` (no more `h_dc`). Pattern matches now include `h_fc` from axiom constructor. Weakening case simplified (no `isDenseCompatible` propagation needed).

5. **General versions** (`axiom_swap_valid_general`, `axiom_locally_valid_general`): Changed to take `h_fc : h.minFrameClass ≤ FrameClass.Base` (was `≤ .Dense`). Added `density` dismissal. `derivable_valid_and_swap_valid_general`: takes `DerivationTree FrameClass.Base [] φ`.

6. **Discrete versions** (`axiom_swap_valid_discrete`, `axiom_locally_valid_discrete`): Added `h_fc : h.minFrameClass ≤ FrameClass.Discrete` parameter. Added `density` dismissal (`Dense ≤ Discrete` is False). `derivable_valid_and_swap_valid_discrete`: takes `DerivationTree FrameClass.Discrete [] φ`.

### Key Patterns

- Dismissing density in base/discrete contexts: `exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])`
- Dismissing prior_UZ/SZ/z1 in dense contexts: same pattern
- Dismissing base axioms in non-base branches: `exact absurd trivial hbase` (where `hbase : ¬(h.minFrameClass ≤ .Base)`)

## Remaining: Soundness.lean

### What needs to change

1. **`axiom_valid`**: Change `h_base : h.isBase` to `h_fc : h.minFrameClass ≤ FrameClass.Base`. Add `density` dismissal. Dismiss `prior_UZ/SZ/z1`.

2. **`axiom_dense_valid`**: Change `h_dc : h.isDenseCompatible` to `h_fc : h.minFrameClass ≤ FrameClass.Dense`. Add `density` case. Dismiss `prior_UZ/SZ/z1`.

3. **`axiom_discrete_valid`**: Change `h_dc : h.isDiscreteCompatible` to `h_fc : h.minFrameClass ≤ FrameClass.Discrete`. Add `density` dismissal.

4. **`soundness`**: Change `(d : DerivationTree Γ φ) (h_dc : d.isDenseCompatible)` to `(d : DerivationTree FrameClass.Base Γ φ)`. Remove all `h_dc` threading. Pattern match axiom case gets `h_fc` from constructor. Remove `prior_UZ/SZ/z1` absurd cases (they can't appear in `.Base` tree). Add `density` dismissal.

5. **`soundness_dense_valid`**: Change `(d : DerivationTree [] phi) (h_dc : d.isDenseCompatible)` to `(d : DerivationTree FrameClass.Dense [] phi)`. Remove `h_dc` threading.

6. **`soundness_dense`**: Same pattern as `soundness` but for `.Dense`.

7. **`soundness_discrete_valid`** and **`soundness_discrete`**: Change to `DerivationTree FrameClass.Discrete`. Remove `h_dc`/`isDiscreteCompatible`.

### Mechanical pattern for each soundness theorem
- Remove `h_dc` parameter
- In `induction d` / `match d`, axiom case gets `h_fc` from constructor
- Use `h_fc` to dispatch to appropriate `axiom_*_valid`
- In `modus_ponens` case, remove `obtain ⟨h_dc1, h_dc2⟩ := h_dc` (structural now)
- In `necessitation/temporal_necessitation/temporal_duality/weakening`, remove `h_dc` passing

## Remaining: DenseSoundness.lean, DiscreteSoundness.lean

Thin wrappers -- update type signatures to use `DerivationTree fc`, remove `h_dc`.

## Next Action

Continue Phase 4: apply the mechanical pattern to Soundness.lean. The changes follow the exact same structure as SoundnessLemmas.lean.
