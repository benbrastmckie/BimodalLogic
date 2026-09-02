# BundleDeadHalf -- the retired half of `Metalogic/Bundle/`

Archived 2026-09-02.

Six modules retired together from `FormalSystem/Metalogic/Bundle/`. They did not die one at a
time: breaking the `Core -> Bundle` directory import cycle removed the first module's only live
importer, and the rest followed as a mechanical cascade down the import graph.

## CONVENTION: these files are GUARD-FIRST, unlike the rest of this archive

The archive-wide banner in [`../README.md`](../README.md) tells you to swap the two arguments of
every `Formula.untl` and `Formula.snce` before resurrecting an archived file. **That instruction
does not apply to anything in this directory.** These six modules were live-tree files at the
moment they were archived, so they already read guard-first, exactly as the live tree does. There
are 14 such occurrences here, across 12 lines in 2 files: `SuccRelation.lean` (12 occurrences on
10 lines) and `CanonicalFrame.lean` (2 on 2 lines). Applying the banner's swap to them would
silently invert their meaning while still compiling -- precisely the failure the banner exists to
prevent.

## What died, and why

| Module | Lines | Why it died |
|---|---:|---|
| `CanonicalTaskRelation.lean` | 759 | Its 29 pure-syntax `iterF`/`iterP` declarations moved to `Syntax/SubformulaClosure/IteratedTemporal.lean` so that `Core/RestrictedMCS/Basic.lean` could stop importing `Bundle/`. That import was the module's only live importer; the remainder had no consumer. |
| `SuccRelation.lean` | 553 | Imported only by `CanonicalTaskRelation.lean` and `UntilSinceCoherence.lean`, both retired here. |
| `CanonicalFrame.lean` | 312 | Imported only by `SuccRelation.lean` and `CanonicalTaskRelation.lean`, plus a `BXCanonical/Frame.lean` import that was unused (`Frame.lean:223,235` re-prove the same content as `bx_forward_witness`/`bx_backward_witness`). |
| `Construction.lean` | 253 | Already unreachable before this retirement -- it carried a standing entry in `scripts/module-invariants-manifest.txt`. |
| `UntilSinceCoherence.lean` | 46 | Declared nothing: a pure import-forwarding shell left behind when its six declarations were archived to `SorriedDeclExcisions/UntilSinceCoherence.lean`. Its one live importer, `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:9`, was deleted; the measured import-closure delta was one substantive module (`Bundle.SuccRelation`), which that file does not use. |
| `ModalSaturation.lean` | 337 | Seven live helpers migrated out (five derivation-tree theorems to `Theorems/ModalDerived.lean`, two `SetMaximalConsistent` lemmas to `Core/MCSProperties.lean`). The remaining eleven declarations -- the whole `IsModallySaturated` / `SaturatedBFMCS` saturation layer, plus `dniTheorem` -- had zero references anywhere in the live tree or `Tests/`. |

Total as archived: **2,260 lines**. Line counts are as archived. `CanonicalTaskRelation.lean` (1,050 -> 759) and `ModalSaturation.lean` (521 -> 337) are smaller
than they were in the live tree, because the relocations above happened before the move: the
six modules were 2,735 lines when the retirement began.

## Specific notes worth keeping

### (a) The `SuccRelation.lean` proof diary, and why `h_p_step` is a hypothesis

`SuccRelation.lean:434-541` -- 108 lines inside `Succ_implies_p_step_forcing` -- is a proof diary:
a running commentary on why the P-direction of the argument could not be discharged from `Succ`
alone. It is preserved as archived rather than trimmed.

Its content, stated once so the diary need not be read: **`h_p_step` is a hypothesis, not a
derived fact, because `Succ` supplies only the F-step.** `Succ u v` unfolds to
`GContent u ⊆ v` (`Succ.g_persistence`) and `FContent u ⊆ v ∪ FContent v` (`Succ.f_step`). There
is no P-dual: nothing in `Succ` gives `PContent v ⊆ u ∪ PContent u`. Callers that construct
predecessors know that fact by construction and discharge the hypothesis themselves.

Note that the diary's range is `:434-541`, not `:432-543`: lines `:432-433` are real step-6 code
(`h_phi_in_p_content_v`), and `:542-543` resume real code with the `h_p_step` application.

### (b) The F-21 docstring error in `SuccRelation.lean:135-148`

That docstring asserts `F(phi) = neg(G(neg(phi)))` as a definitional identity. **It is false, and
backwards.** `Formula.someFuture φ = Formula.untl Formula.top φ` (`Syntax/Formula.lean:147`) is
primitive, and `Formula.allFuture φ = (someFuture φ.neg).neg` (`:167`) is defined *from* it --
G is derived from F, not F from G. The claim is recorded here rather than corrected in place,
because the file left the live tree in the same change that would have carried the fix.

The correct statement survives in the live tree at
`Metalogic/Bundle/WitnessSeed.lean:53`: *"`someFuture`/`somePast` are no longer definitionally
`neg(allFuture/allPast(neg _))`"*, followed by the duality helpers that exist precisely because
they are not.

### (c) `Succ_implies_CanonicalR` was a duplicate, not a relocation candidate

`SuccRelation.lean:97`'s `Succ_implies_CanonicalR` was the only consumer of
`CanonicalFrame.ExistsTask` anywhere. Its body is `h.1` -- character-for-character the body of
`Succ.g_persistence` at `SuccRelation.lean:78`, differing only in how the result type is spelled
(`ExistsTask u v` versus `GContent u ⊆ v`, which `ExistsTask_def` says are the same by `rfl`). It
was therefore retired as a duplicate rather than relocated. `ExistsTaskPast` and
`ExistsTask_past_def` had zero uses of any kind.

### (d) `Construction.lean` advertised a declaration it never had

`Construction.lean:20` and `:246` both list `constantBFMCS` as something the module provides. It
does not: `:71` is a `## REMOVED: constantBFMCS` tombstone explaining that a constant family
`t ↦ M` stopped satisfying `forward_G` under irreflexive semantics. The module's `## History`
heading at `:23` is empty. Both are recorded here rather than fixed in a file being archived in
the same change.

### (e) One stale fully-qualified reference elsewhere in the archive

`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:2990` calls
`FormalSystem.Metalogic.Bundle.iter_F_f_nesting_depth` by fully-qualified name. That name moved to
`FormalSystem.Syntax.iter_F_f_nesting_depth` when the 29 pure-syntax declarations were relocated,
so the reference is stale. No gate fails on it -- C11 checks archived *imports*, not identifiers --
and this record is the fix.

## Import re-pointing

Every archived import naming one of these six modules was re-pointed to
`FormalSystem.Boneyard.BundleDeadHalf.<Module>` in the same change: 5 intra-set lines within this
directory, and 23 external lines across 18 archived files elsewhere under `Boneyard/`. Imports of
*surviving* `Bundle/` and `Core/` modules were left as they are. No waiver was added to
`scripts/boneyard-import-waivers.txt`: a waiver is for an import with no unique target, and every
one of these had one.

## The nine survivors

`Metalogic/Bundle/` retains `BFMCS`, `FMCSDef`, `LimitMCS`, `LimitMCSCoherence`, `RealExtension`,
`RealExtensionBundle`, `TemporalCoherence`, `TemporalContent` and `WitnessSeed`. Each has at least
one live importer outside the `Bundle.lean` aggregator.
