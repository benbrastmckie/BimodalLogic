# SoundnessVariants

Archived from the top level of `FormalSystem/Metalogic/`.
Archived 2026-07-24 in commit `56e9f62ff`.

## Contents

<!-- BEGIN GENERATED: inventory dir=Boneyard/SoundnessVariants rows=loose -->
| File | Lines | Description |
|------|------:|-------------|
| `DenseSoundness.lean` | 54 | `density_sound_dense`, `axiom_dense_valid` — soundness of every axiom with `minFrameClass ≤ FrameClass.Dense` against `valid_dense` |
| `DiscreteSoundness.lean` | 56 | `discreteness_forward_sound_discrete`, `axiom_discrete_valid` — soundness of every axiom with `minFrameClass ≤ FrameClass.Discrete` against `valid_discrete` |
<!-- END GENERATED -->

## Why archived

**Superseded approach: thin wrappers with no importers.** Both files re-package results that
`FormalSystem/Metalogic/Soundness.lean` proves directly as `soundness_dense` and
`soundness_discrete`. No live module imported either, so they were pure orphans — two extra
surfaces stating the same theorems.

Nothing here is refuted. The content is a duplicate of live material, not a dead end.

## Relationship to active code

Both files import `FormalSystem.Metalogic.Soundness` and `FormalSystem.Semantics.Validity`, both
live. The substantive observations in their docstrings survive in the live proofs: under
irreflexive temporal semantics (`<` rather than `≤`) the density axiom `GGφ → Gφ` genuinely
requires `DenselyOrdered`, and the discreteness axiom `DF = (F⊤ ∧ φ ∧ Hφ) → F(Hφ)` genuinely
requires `SuccOrder`. The discrete-specific axioms (`prior_UZ`, `prior_SZ`, `z1`) carry
`minFrameClass = .Discrete`, which is incomparable with `.Dense`, so the dense wrapper excluded
them by construction.

## Convention note

Neither file contains `untl` or `snce` occurrences; the root README's argument-swap warning does
not apply to anything here.
