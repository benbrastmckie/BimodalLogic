# Implementation Summary: Delete the orphaned `FormalSystem/FrameConditions/` layer

- **Task**: 510 - Resolve orphaned FrameConditions layer
- **Plan**: `specs/510_resolve_orphaned_frameconditions_layer/plans/01_delete-frameconditions-layer.md`
- **Baseline capture**: `specs/510_resolve_orphaned_frameconditions_layer/baselines.txt`
- **Phases**: 7 of 7 completed
- **Type**: lean4

## What Was Done

The typeclass-based frame-condition layer is gone. Six paths were deleted — 853 `.lean` lines
across `FormalSystem/FrameConditions.lean` (74) and `FrameConditions/{FrameClass (292), Validity
(81), Soundness (207), Compatibility (199)}.lean`, plus the directory's 98-line README. The single
live import at `FormalSystem/FormalSystem.lean:13` was dropped along with its two docstring
references, and the resulting dangling archived import was permanently waived.

The layer was a carrier-typeclass re-encoding of the frame classes with no paper counterpart and
no consumer outside its own directory. Its replacements were already in the tree:
`FrameClass.Sat` (`Semantics/FrameClassValidity.lean`), `ValidIn` (`Semantics/Validity.lean`), and
`TaskFrame.IsDense` / `TaskFrame.IsSuccArchDiscrete` / `TaskFrame.IsDedekind`
(`Semantics/FrameProperty.lean`).

Everything that pointed at the layer was repaired in the same task: the book's frame-class chapter
prose, 11 `#leansrc` citation pointers, four README inventories, two `docs/` trees, three typst
files, and one `.lean` docstring.

## Phase-by-Phase

| Phase | Outcome | Commit |
|-------|---------|--------|
| 1 Capture green baselines | `lake build` GREEN (2509 jobs) — measured for the first time | `032a4f1da` |
| 2 Rewrite typst frame-class section | `typst-sync-check.sh` 2 violations → **0**, at pre-deletion HEAD | `54b101541` |
| 3 Repoint `#leansrc` pointers | 9 `FrameConditions` pointers + 2 adjacent broken siblings = 11 rewrites | `ed9d2de45` |
| 4 Delete the layer | 6 paths removed, C11 waived count 6 → **7**, manifest untouched | `8ccb469e4` |
| 5 Repair documentation references | `readme-lint.sh` check 3 back to **0** broken references | `0185336f4` |
| 6 Record the corrected finding | Boneyard README states archived-not-removed | `bb2b6e93e` |
| 7 Full gate sweep | see the comparison table below | this commit |

## Baseline vs. Final

| Measurement | Phase 1 baseline | Phase 7 final | Explanation |
|---|---|---|---|
| `lake build` | GREEN (2509 jobs) | GREEN | see the build note below |
| C4 import lines resolve | PASS, 1477 | PASS, 1474 | -8 from the deleted layer's own import lines, +5 from concurrent sessions' new files |
| C5 markdown module paths | PASS (1323 files) | PASS (1322 files) | the deleted directory README is gone |
| C6 unreachable, manifested | **17** | **17** | unchanged, and `module-invariants-manifest.txt` is byte-identical across the whole task |
| C6 check verdict | FAIL (3 foreign unmanifested) | FAIL (4 foreign unmanifested) | inherited and out of scope — see Reasoned Exclusions |
| C7 live `.lean` | 482 (427 FS / 54 Tests) | 479 (424 FS / 54 Tests) | -5 from this task, +2 net from concurrent sessions |
| C7 `(loose)` | 10 | 9 | `FrameConditions.lean`, the loose aggregator |
| C7 `FrameConditions` row | 4 | *(row removed)* | the directory no longer exists |
| C8 sibling aggregators | PASS | PASS | directory and aggregator deleted together |
| C11 archived imports | PASS, 6 waived | PASS, **7 waived** | exactly the predicted rise |
| `typst-sync-check.sh` | **FAIL**, `TOTAL_VIOLATIONS=2` | **PASS**, `TOTAL_VIOLATIONS=0` | a repair, not a hold |
| `readme-lint.sh` check 3 | 0 broken | 0 broken | 3 links broke on deletion and all 3 were repaired |
| `readme-lint.sh` check 1 | FAIL, 1 missing README | FAIL, 1 missing README | unchanged, inherited, out of scope |

### On the C7 prediction

The report predicted 479 → 474 live `.lean`, 424 → 419 `FormalSystem`, `(loose)` 10 → 9. Only the
`(loose)` prediction landed exactly. The others are off because the report's *baseline* was wrong,
not its arithmetic: the tree measured 482/427 at Phase 1, not 479/424, because concurrent sessions
had added files. The delta this task is responsible for is exactly -5 `.lean` files. C7 is
informational and is never asserted as a gate, so this is recorded, not treated as a failure.

## The corrected archived-completeness finding

The original brief recorded that a historical claim ("wiring is DONE:
`completeness_over_Int`, `discrete_completeness_fc`, `dovetailed_bundle`") had gone silently
stale, and asserted that **all three identifiers are ABSENT from the live tree**. That assertion is
wrong in two of its three parts. Measured:

- `completeness_over_Int` (`FormalSystem/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean:530`)
  and `discrete_completeness_fc` (`:549`) **both still exist**. They were archived, not deleted.
- They are nonetheless unreachable from every Lake target root, so no build elaborates them and
  neither is compile-checked. A live claim that the wiring "is done" is therefore false *of the
  live tree* even though the source text is on disk. The claim is stale for a different reason
  than the brief supposed.
- `dovetailed_bundle` has no declaration of that **exact** name anywhere in the repository — that
  part of the brief holds. But the same archived file declares `dovetailed_bundle_to_bfmcs`
  (`:433`) and `dovetailed_bundle_validity_implies_provability` (`:474`), so a flat "absent
  tree-wide" would be falsified by the first grep a reader runs.

This correction is recorded durably in
`FormalSystem/Boneyard/StrictSemanticsLegacy/README.md`, not only here. The archived file is
deliberately retained as the evidence for it, and its now-unsatisfiable
`FormalSystem.FrameConditions.Compatibility` import is permanently waived in
`scripts/boneyard-import-waivers.txt`.

## Acceptance Criteria

| | Criterion | Verdict |
|---|---|---|
| A1 | No orphaned validity vocabulary tree-wide | **PASS** — zero `ValidOver`/`ValidLinear`/`ValidDenseFc`/`ValidDiscreteFc`/`ValidOverInt` outside `specs/` and `Boneyard/` |
| A2 | `lake build` green via a detached guarded build at Phase 1 and Phase 7 | **PASS** — see the build note |
| A3 | `check-module-invariants.sh` with C6 still at 17 and no manifest edit | **PARTIAL** — the 17 and the untouched manifest both hold, and C5/C8/C11 pass; the C6 *check* fails on foreign modules. See Reasoned Exclusions |
| A4 | `typst-sync-check.sh` PASS at `TOTAL_VIOLATIONS=0` | **PASS** — repaired from a RED baseline |
| A5 | `readme-lint.sh` exits 0 with every broken relative link repaired | **PARTIAL** — all three broken links repaired, check 3 at 0; check 1 still fails on an inherited missing README. See Reasoned Exclusions |
| A6 | The silent regression recorded in corrected form | **PASS** |
| A7 | No `#leansrc` pointer names a `FrameConditions` module or symbol, every repoint verified | **PASS** — 0 occurrences; all 11 targets verified by line number against live `.lean` |

### Build note

Phase 4's post-deletion build returned exit 1 with 9 errors, **none of them attributable to this
task**. All 9 were in `FormalSystem/Metalogic/BaseLanguageSoundness.lean`, a file with zero
`FrameConditions` references, and they all lay inside a then-uncommitted +132-line block added by
a concurrent session (referencing `swapBL_involution`, an identifier that did not exist at HEAD).
Every other module in the tree built. That session subsequently committed a compiling state, and
Phase 7's build was re-run against it.

## Reasoned Exclusions

Two gate failures are present at the end of this task. Both were present at the Phase 1 baseline,
both are foreign territory, and neither has any `FrameConditions` involvement.

| Item | Reason | Evidence |
|---|---|---|
| `check-module-invariants.sh` C6: 4 unreachable live modules absent from the manifest | Every one is a file created by another in-flight task, not by this one. The set churned across the three runs (`BLSchemaValidity` appeared then vanished; `SpWitness` and `Z1Countermodel` appeared) — the signature of concurrent sessions, not of a stable defect. Manifesting another task's module would claim its work | Baseline set: `TMCompletenessReduction`, `BLSchemaValidity`, `LexCarrier`. Final set: `SpWitness`, `TMCompletenessReduction`, `Z1Countermodel`, `LexCarrier`. `git diff 032a4f1da..HEAD -- scripts/module-invariants-manifest.txt` is empty, and the manifested-unreachable count is 17 at both ends |
| `readme-lint.sh` check 1: missing `FormalSystem/Semantics/Ultraproduct/README.md` | That directory was created by *committed* foreign work that shipped without a README. Writing one would author another task's deliverable for a directory under active concurrent edit | `git log -- FormalSystem/Semantics/Ultraproduct/` shows `0f1e50fd4`, `9eb879519`, `dbad125e6`. The failure is recorded verbatim in `baselines.txt` before this task modified anything |

Adding a `FrameConditions` entry to `scripts/module-invariants-manifest.txt` would **not** have
fixed C6 — it would have failed it. C6 counts *unreachable* modules and `FrameConditions` was
reachable from `FormalSystem/FormalSystem.lean:13`, so deleting it cannot move that count. The
manifest was correctly left untouched.

## Plan Deviations

- **Phase 1** — `check-module-invariants.sh` and `readme-lint.sh` were both already RED at
  baseline, contrary to the plan's Scope Hypothesis. Recorded in `baselines.txt`, not repaired.
- **Phase 2** — the *Monotonicity* paragraph's deleted bridge clause was replaced by `ValidIn.mono`
  rather than simply dropped, so the claim keeps a live semantic witness. Two stale names outside
  the plan's enumerated ranges (`SerialFrame` at `:109`, the file's own ground-truth header
  comment) were repaired in the same pass; both would otherwise have become violations.
- **Phase 3** — `:1252`/`:1255` were repointed at `Metalogic.BaseLanguageSoundness`
  (`bl_soundness`, `bl_soundness_dedekind`) rather than the plan's `Metalogic.Soundness`, because
  the citation block belongs to a proposition about TM⁺-algebras — the base language — and its two
  sibling pointers already name that module. Those two siblings were themselves broken
  (`soundness_dense`/`soundness_discrete` are `bl_soundness_dense`/`bl_soundness_discrete` there)
  and were repaired so the quad is coherent.
- **Phase 3 scope** — the before-count was 9 pointers on 9 lines, not the report's 11 on 9. The
  line-level enumeration was correct; only the pointer tally was overstated.
- **Phase 4** — the waiver block names the deletion by description rather than by SHA, because the
  waiver must be committed in the same atomic batch as the deletion and that commit's SHA does not
  exist while the file is being written.
- **Phase 4** — the post-deletion build was not green, for fully foreign reasons. See the build
  note above.
- **Phase 5** — `FormalSystem/Semantics/FrameProperty.lean:105` was added to the phase. It was the
  only `.lean` file outside the deleted directory that referenced the layer, in the present tense.
- **Phase 5** — `SoundnessLemmas/README.md`'s Dependencies block was rewritten to the actual,
  independently re-verified import list rather than having the single false clause deleted.
- **Phase 5 scope** — check 3 named **three** broken links, confirming the plan's suspicion about
  `FormalSystem/README.md:280` over the report's two.
- **Phase 6** — the `dovetailed_bundle` clause was sharpened; see the corrected finding above.
