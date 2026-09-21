# StaviDiscretePath

Archived from `FormalSystem/Metalogic/WeakCanonical/EFGames/`.
Three files archived 2026-06-16 in commit `e94c38ca7`; `StaviExpressiveCompletenessTail.lean`
was excised later, under the never-built conventions described below.

## Contents

<!-- BEGIN GENERATED: inventory dir=Boneyard/StaviDiscretePath rows=loose sort=lines-desc -->
| File | Lines | Description |
|------|------:|-------------|
| `StaviExpressiveCompletenessTail.lean` | 1,754 | The dead 24-declaration tail of the live `EFGames/StaviCompleteness.lean`, carrying that file's 3 statement-position sorries |
| `DiscreteGameTransfer.lean` | 1,476 | GHR93 Theorem 6 restricted to discrete (succ-archimedean) orders, where `IsEmpty (Gap T)` makes Cases III and IV vacuous |
| `NFGameBridge.lean` | 1,247 | Bridge lemmas joining the NormalForm world (`nf_characteristic`, `nf_eval_nf`, `interval_nf_types`) to the EF-game world (`rank_type`, `stavi_temporal_truth_mu`, `decomposition_agreement`) |
| `DiscreteStaviCompleteness.lean` | 504 | Sorry-free `discrete_nf_characterizable_by_stavi` and `discrete_stavi_expressive_completeness` via the game pipeline |
<!-- END GENERATED -->

## Why archived

Two different reasons live in this one directory, and they should not be conflated.

**The three game-pipeline files are a superseded approach.** They are a complete discrete Stavi
completeness route that bypasses the sorry in `nf_exist_sf_guarded_backward` by going through the
EF game pipeline instead of the direct NF induction (which fails at the sub-interval splitting
problem). The route works; it simply has no live consumers, because
`PriorExpressiveness.lean` reaches expressive completeness through
`kamp_prior_expressive_completeness` (Kamp / Rabinovich 2014) instead.

**`StaviExpressiveCompletenessTail.lean` is a dead-sorry excision**, placed here thematically
rather than in [`../SorriedDeclExcisions/`](../SorriedDeclExcisions/README.md) because it belongs
with the rest of the discrete Stavi material. It is the verified-dead closure of 24 declarations
lifted out of the live `EFGames/StaviCompleteness.lean` — the audited 16-declaration tail
(including the two pre-tail orphan guards `nf_base_sf_correct` and `nf_exist_sf_forward`)
enlarged to its consumer fixpoint with 8 exclusively-consumed helpers: `sf_disj_iff`,
`sf_top_iff`, `sf_atom_literal_iff`, `sf_disjList_iff`, `sf_conjList_iff`,
`atomKind_to_sf_literal_correct`, `nf_base_sf` and `zone_match_witness`. The chain top,
`stavi_expressive_completeness` (GHR93 Theorem 9.3.1), had zero code consumers at excision.

It follows the never-built excision conventions: the source file's import block verbatim, an
`ARCHIVED (Boneyard)` docstring naming the moved declarations, `#exit` before the first
declaration, then the excised code verbatim. Its stale imports are never repaired.

## Relationship to active code

`EFGames/Decomposition.lean`, `EFGames/Composition.lean`, `EFGames/CharacteristicFormula.lean`,
`EFGames/GapDetection.lean`, `Expressiveness/Theorem6.lean` and `EFGames/StaviCompleteness.lean`
are all still live; this directory's files import them. `StaviCompleteness.lean` survives with its
tail removed. The live expressive-completeness result comes from the Kamp/Rabinovich route in
`PriorExpressiveness.lean`.

## Convention note

These files predate the guard-first migration. Check `untl`/`snce` occurrences and swap the
arguments before resurrecting anything, per the archive root README.
