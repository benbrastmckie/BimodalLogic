# Implementation Summary: Spherical → Saturation axiom rename

- **Task**: 517 — Rename the fourth task-frame axiom from `Spherical` to `Saturation`
- **Status**: [COMPLETED]
- **Plan**: `specs/517_rename_spherical_axiom_to_saturation/plans/01_spherical-to-saturation-rename.md`
- **Report**: `specs/517_rename_spherical_axiom_to_saturation/reports/01_spherical-to-saturation-occurrence-inventory.md`
- **Type**: lean4
- **Commits**: `85bde0916` (phase 1), `d4e288472` (phase 2, atomic batch), phase 3 (this summary)

## What was done

The paper (`possible_worlds.tex`) renamed its fourth task-frame axiom from *Spherical* to
*Saturation*. All 441 rename-class occurrences across 40 non-`specs/` files now follow it, the 3
keep-class occurrences survive verbatim, and both paper anchors resolve again.

| Phase | Outcome |
|---|---|
| 1 — baseline | Closed. All eight pre-edit figures measured and matched. |
| 2 — the rename | Closed. One atomic batch, one full build, four gates. |
| 3 — prose coherence | Closed. No Lean surface, no rebuild. |

### Phase 2, the substance

A sentinel-guarded global substitution over the frozen 40-file list, preceded by a dedicated
`sphericality` → `saturation` pass on `TaskFrame.lean:513` so the global pass could not produce
`saturationity`. It covered the 26 Lean identifiers, the 21 `spherical := …` field assignments,
the 5 compile-checked `#guard_msgs` expected-output strings, the typst `leanSpherical` macro and
its `raw("spherical")` body, the sync-check whitelist, and both paper anchors. Alongside it:

- `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` → `SaturationFiniteAxiomTest.lean`
  via `git mv` (`roots := #[`BimodalTest]` means no lakefile edit).
- `specs/paper-definitions-of-record.md`: the two MANIFEST rows, and nothing else.
- `README.md:80`: the interim note saying the Lean sources still used the old name, deleted.
- A homonym-disambiguation paragraph in the `TaskFrame.Saturation` docstring pointing at the
  unrelated tableau saturation of `FormalSystem/Metalogic/Decidability/Saturation.lean`.

### The semantic distinction, preserved

*Saturation* is ball-space condition `S₁ᵈ`, **strictly stronger** than *spherically complete*
(`S₁`). The keep set is exactly the three occurrences of that literal phrase —
`TaskFrame.lean:393`, `:394`, `README.md:80` — and line 394 carries both partitions on one line,
now reading that `"Saturation"` is not a synonym for `"spherically complete"`. A blind replace
would have converted a true mathematical claim into a false one. The sentinel pass resolved the
mixed line with no hand edit; `git grep -io "spherical"` outside `specs/` returns exactly 3, all
inside that phrase.

## Verification

| Gate | Baseline (pre-edit) | Final | Verdict |
|---|---|---|---|
| `lake build` (guarded, detached) | exit 0 | exit 0, 2521 jobs, **345 s** | green |
| `check-module-invariants.sh` | exit 0, ALL CHECKS PASSED | exit 0, ALL CHECKS PASSED | green |
| `check-paper-definitions.sh` | exit 1, 10 drifted, 2 unresolvable | exit 1, 10 drifted, **0 unresolvable** | improved, no new drift |
| `typst-sync-check.sh` | exit 1, `TOTAL_VIOLATIONS=2` | exit 1, `TOTAL_VIOLATIONS=2` | unchanged, no new violations |

The drifted-anchor *set* was captured at baseline and diffed after the edit: byte-identical. Exit
1 on the last two is the expected, accepted outcome — acceptance was stated as "no NEW violations"
because those gates are red at HEAD for causes this task did not create.

Post-condition assertions, all holding: `spherical` outside `specs/` = 3 (all in "spherically
complete"); `SPHLYSENTINEL` = 0; `saturationity` = 0; `spherical` in `Tests/` = 0; stale anchor
citations = 0.

**No sorries, no new axioms, no vacuous definitions were introduced** — this was a rename, and the
proof content is unchanged.

## Measured, against the plan's hypotheses

The plan predicted the edit would force a full ~646-module re-elaboration and raised the guard's
lock-wait budget from 1800 to 7200 s to cover it. **The rebuild took 345 s** (2521 jobs). The
7200 figure is disconfirmed on the low side; 1800 would have been ample. Detachment was still
required and is not in question — 345 s is well past the 120 s default foreground cap, and the
guard's budget is a lock-wait bound rather than a build-duration limit either way.

## Plan Deviations

1. **Baseline HEAD moved.** The plan was written against `92b154ab2`; the actual pre-edit HEAD was
   `34d512e8d` (task 518's implementation `9cd17f308` plus task 517's own research and plan
   commits landed between). All eight baseline figures still matched, so no post-condition
   re-derivation was needed.
2. **Two post-condition greps need the `specs/` exclusion** the plan applies to the others. As
   written, `git grep -io "saturationity"` and `git grep -l "SPHLYSENTINEL"` match the plan's own
   prose naming those tokens — 8 and 2 hits respectively, all self-references. Outside `specs/`,
   both are 0 as intended. The assertions are self-defeating only in form, not in substance.
3. **`git-snapshot.sh 517` reverted the working tree**, including uncommitted `specs/`
   bookkeeping. Restored via `git stash apply stash@{0}`; the snapshot itself is intact as
   `git-snapshot-1788327852`.
4. **`git mv` staged the pre-substitution blob.** It moves the *index* entry rather than re-adding
   from the worktree, so the rename staged at R100 with the old content until the new path was
   explicitly `git add`-ed. Worth knowing for any future substitute-then-rename batch: the naive
   staging silently commits the unsubstituted file.
5. **The `⊇`-directed fix landed at 3 sites, not the 2 the plan named.** The prose gloss at
   `02-Semantics.tex:96` makes the same unqualified claim as the transcription. The comment at
   ~77 also matters more than a gloss: it is labelled verbatim paper text, so leaving it
   unqualified would have been a false quotation.
6. **Both missing test-README rows were added**, not just one — `DependentUltraproductProbe.lean`
   alongside `SaturationFiniteAxiomTest.lean`. The plan left this to implementer discretion and
   asked that the choice be recorded.

## Out-of-scope follow-ups (recorded so they are not lost)

1. **The 10 drifted paper anchors** in `specs/paper-definitions-of-record.md`
   (`def:task-relation`, `def:directed`, `def:frame`, `def:frame#Compositionality`,
   `def:frame#Seriality`, `def:frame#Limit`, `def:world-history`, `thm:extension`,
   `def:BLplus-defined`, `def:time-shift-histories`). Most are `\bf` → `\it` cosmetics, but at
   least two are substantive: `def:time-shift-histories` dropped its explicit translation
   function, and `def:BLplus-defined` changed item emphasis. This warrants a paper-reconciliation
   task of its own; `check-paper-definitions.sh` stays exit 1 until it is done.
2. **`typst-sync-check.sh`'s 2 Check-1 violations** — `@[aesop norm unfold]` and
   `@[aesop safe forward]` in `typst/chapters/p4-proof-automation.typ`, introduced by task 518's
   aesop work and belonging to that territory.
3. **One judgment call left open**: the record file's own entry heading ``def:directed`` —
   directed family (used by Spherical)`` still says *Spherical*. It is this file's navigation
   rather than quoted paper text, so it is not protected by the historical-record rule, but it
   fell outside this task's declared scope. Flagged in the dated absorption entry so a later pass
   can decide it deliberately rather than by omission.

## Artifacts

- Plan: `specs/517_rename_spherical_axiom_to_saturation/plans/01_spherical-to-saturation-rename.md`
- Handoffs: `handoffs/phase-1-handoff-20260901.md`, `handoffs/phase-2-handoff-20260901.md`
- This summary
