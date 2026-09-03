# Implementation Summary: Task #525 — Galois over Mathlib + correspondence tidy

- **Task**: 525 (WAVE 3, theorem layer)
- **Plan**: `specs/525_galois_over_mathlib_correspondence_tidy/plans/01_galois-over-mathlib-tidy.md`
- **Report**: `specs/525_galois_over_mathlib_correspondence_tidy/reports/01_galois-over-mathlib-correspondence-tidy.md`
- **Session**: sess_1788407456_70233f
- **Phases**: 6 of 6 [COMPLETED]
- **Type**: lean4

## What landed

**Phase 1 — the Galois layer over `Mathlib.Order.Concept`.** `Th`, `Mod` and `GaloisClosed` are
now the `upperPolar`, `lowerPolar` and `Order.IsExtent` of a new relation
`validOnRel F φ := F.ValidOn φ`, declared as `abbrev`s. All seven connection theorems keep their
names and docstrings and have one-line Mathlib projections as bodies. Added: `mod_th_gc` (the
adjunction as an explicit `GaloisConnection`, for discoverability — nothing is derived from it),
`galoisClosed_iff` (the bridge back to the fixed-point equation, since `GaloisClosed` shifted from
an equation to a range membership), `galoisClosed_of_indicator_iff`, and the free
`galoisClosed_iInter` / `_inter` / `_univ` and `mod_union` / `mod_iUnion` / `mod_empty` /
`th_empty`. `Th K = {φ | ∀ F ∈ K, F.ValidOn φ}` and the `Mod` analogue both close by `rfl`, so the
re-based definitions are defeq to what they replaced.

**Phase 2 — `Indicator.lean`.** `galoisClosed_sat_dense` and `galoisClosed_isDiscrete` are each a
single line, `galoisClosed_of_indicator_iff _ <the correspondence biconditional>`. The header now
tabulates the full four-part closed/not-closed picture in one place, naming both non-closure
witnesses in `Metalogic/Independence/`.

**Phase 3 — the atom-realisation layer.** Six additive declarations in `DurationFrames.lean`:
`translationHF`, `translation_realizes`, `translation_realizes_allPast`,
`translation_realizes_allFuture`, and the permissive twin `permissiveHF` / `permissive_realizes`
that the review missed and without which one of the three proofs would have been left untouched.

**Phase 4 — the three (T1) proofs.** All three (⇒) branches rewritten over those lemmas, 207 -> 165
lines. `private def corrAtom` deleted; the atom idiom is `Atom.mkBase "p"` throughout, including
`FwdRec.lean`'s two former `Atom.mk "p" none` inlines.

**Phase 5 — zero private Archimedean copies.** `Separability.lean`'s `private theorem arch_of_lub`
deleted in favour of `Semantics.archimedean_of_lub`, with the new import edge measured rather than
asserted. Four falsified docstrings repaired (the plan predicted three).

**Phase 6 — READMEs and baselines.** Both module tables regenerated; opening paragraph of
`Independence/README.md` rewritten to the three result families over six modules, mirroring
`Independence.lean:20-31`; reciprocal "See also" added to `Correspondence/README.md`'s Key Results.

## Parallelism of the three (T1) proofs

The acceptance criterion for Phase 4 was a side-by-side read, not a line count. All three (⇒)
branches now run the same five marked steps, in the same order, with identical marker comments:

1. `-- The realising data: …` — `set` the set `A ⊆ ↑D` or the assignment `f : ↑D → Bool`
2. `-- Realisation: …` — `have` the realisation lemma (`translation_realizes_allPast` /
   `permissive_realizes`)
3. build the schema's antecedent through it, with `.mpr`
4. `-- Instantiate the schema at the witness frame, then read the consequent back.` — apply `h` at
   `(witnessFrame …) (Formula.atom (Atom.mkBase "p")) (witnessModel …) (witnessHF …)`
5. read the consequent back with `.mp`

## Verification

| Check | Result |
|---|---|
| `lake build` (full tree) | green, 2521 jobs |
| `lake build BimodalTest` | green (via invariants C1) |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED |
| C2 flagship axiom baseline | **PASS — unchanged**; all four are `[propext, Classical.choice, Quot.sound]` |
| C3 structural sorry inventory | PASS — ZERO across `FormalSystem/` (Boneyard excluded) |
| `scripts/check-metalogic-cycles.sh` | PASS — exactly 1 pre-existing directory cycle, none added |
| `scripts/readme-lint.sh` | PASS |
| `grep -rn corrAtom FormalSystem/` | 0 |
| `grep -rn arch_of_lub FormalSystem/` | 0 |
| `grep -c '^axiom ' FormalSystem/` | 9, unchanged against pre-task baseline `b7da18269` |
| README Lines cells vs `wc -l` | all 12 match |

## The one real surprise

The Phase 1 risk that materialised was **not** the one the plan's risk table ranked highest.
`Mathlib.Order.Concept`'s `@[simp]` lemmas entering the default simp set broke nothing. What broke
was **binder info**: Concept states `lowerPolar r t = {a | ∀ ⦃b⦄, b ∈ t → r a b}` with `b` *strict
implicit*, so `F ∈ Mod S` is now `∀ ⦃φ⦄, φ ∈ S → validOnRel F φ`. Any application that passed `φ`
positionally shifts every later argument by one and fails. Three sites broke
(`RationalWitness.lean:198`, `LexIntWitness.lean:162`, `FwdRecBridge.lean:149`); each was repaired
by dropping the positional `φ`, which is then inferred from the expected type. *Producing* a `Mod`
membership with `fun _ h => …` is unaffected — only applications are. This is worth knowing before
any future code applies `Th`/`Mod` memberships.

The research report's probe checked that the `abbrev`s are `rfl`-defeq to what they replaced, which
is true and which the tree confirms; defeq simply does not imply that existing *applications* still
elaborate. Phase 1's `full` verification tier is what caught it, and the plan's mitigation
("fixed forward in Phase 1 before the phase closes") is what it was fixed under.

## Plan Deviations

- **Phase 1 — file set widened, in-phase.** Three files outside the phase's declared "Files to
  modify" (`RationalWitness.lean`, `LexIntWitness.lean`, `FwdRecBridge.lean`) received one-token
  call-site repairs. Sanctioned by the phase's own Risks-table mitigation, which reserves
  fix-forward inside Phase 1 for exactly this; all three are inside this dispatch's declared
  territory. Annotated on the plan's task list.
- **Phase 3 — optional stretch not taken.** The `WorldHistory.ofTotal` replacement for the literal
  `domain := fun _ => True` records was dropped. The plan marks it "Optional stretch, droppable and
  not part of acceptance"; budget went to Phases 4-6. Annotated inline.
- **Phase 4 — line target missed, criterion met.** 165 lines against the plan's ~150-160
  *expectation*. The plan is explicit that the expectation is not the acceptance criterion
  ("if the rewrite lands parallel proofs at 180 lines, that passes"). The residual is the CO
  proof's `halways` block, which is mathematical content with no counterpart in the other two.
- **Phase 5 — scope hypothesis under-counted.** The plan asserted three falsified docstrings; a
  fourth was found at `Decidable.lean:2562-2563`, independently asserting that `Separability.lean`
  "imports only Mathlib". Repaired in-phase, as the phase's own text directs. A fifth consequence,
  `SoundnessLemmas/README.md`'s stale Lines cell (354 -> 334), was also repaired here rather than
  deferred, since Phase 6 covers only the Correspondence and Independence READMEs.
- **Phase 6 — scope hypothesis under-counted.** `Correspondence/README.md`'s module table was stale
  in **six** of six rows, not the predicted four. Two prose passages beyond the enumerated task
  list (the opening paragraph and the first Key Results bullet) still described the pre-Mathlib
  layer and were updated in the same phase.

## Non-Goals honoured

U8, the `ClosureOperator` step, `Walk`/`MinCyc`, `axiomSet_mono` and the `AxiomSet` union
decomposition, the `NOTE:` tags in `Metalogic/{Discrete,Dedekind}NonCompactness.lean`, and
relocating `RationalWitness.lean` / `LexIntWitness.lean` were all left alone. The
`Semantics → Metalogic.Soundness` edge remains refused, and the sentence in `Decidable.lean` that
refuses it is byte-identical to before.

## Concurrency

Task 524 was live in `FormalSystem/Metalogic/` throughout. Its working-tree edits to
`SetConsequence.lean` and `StrongCompleteness.lean` are in this dispatch's forbidden set; they were
never staged or committed here. Phase 5's pre-flight territory check confirmed neither of its two
`Metalogic/` targets was foreign-modified before editing.

## Files changed

- `FormalSystem/Semantics/Correspondence/Galois.lean`
- `FormalSystem/Semantics/Correspondence/Indicator.lean`
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean`
- `FormalSystem/Semantics/Correspondence/FwdRec.lean`
- `FormalSystem/Semantics/Correspondence/FwdRecBridge.lean`
- `FormalSystem/Semantics/Correspondence/README.md`
- `FormalSystem/Semantics/DurationClassification.lean`
- `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean`
- `FormalSystem/Metalogic/SoundnessLemmas/README.md`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`
- `FormalSystem/Metalogic/Independence/RationalWitness.lean`
- `FormalSystem/Metalogic/Independence/LexIntWitness.lean`
- `FormalSystem/Metalogic/Independence/README.md`
