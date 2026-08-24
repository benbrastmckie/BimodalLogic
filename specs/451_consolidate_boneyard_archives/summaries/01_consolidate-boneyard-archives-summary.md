# Implementation Summary: Consolidate the Two Boneyard Archives

- **Task**: 451 - Consolidate the two Boneyard archives into a single tree
- **Status**: [COMPLETED]
- **Plan**: `specs/451_consolidate_boneyard_archives/plans/01_consolidate-boneyard-archives.md`
- **Report**: `specs/451_consolidate_boneyard_archives/reports/01_consolidate-boneyard-archives.md`
- **Baselines**: `specs/451_consolidate_boneyard_archives/baselines/`
- **Phases**: 10 of 10 completed

## What Landed

One archive tree at `FormalSystem/Boneyard/`, with a coherent `Kamp/` region, produced entirely by
`git mv`; every archived import either resolves or is waived with a recorded reason; and a new
enforced check, C11, that keeps it that way.

| Deliverable | Result |
|---|---|
| One archive tree | `find FormalSystem -type d -name Boneyard` returns **1**. 90 files moved into `Boneyard/Kamp/` (63 `.lean` + 4 READMEs from the nested archive, 22 `.lean` + 1 README from four top-level dirs), all `R100`. |
| Kamp region shape | `Boneyard/Kamp/` holds `KampWeakCanonical/`, `KampBypassArchive/`, `KampNegationClosure/`, `RabinovichPath/`, `VecEADecomposition/`. The 35 flat files at the `KampWeakCanonical/` root were regrouped into `ProbeIterations/` (14), `VecEANormalForm/` (10), `TranslationEra/` (6), `DocumentedSingles/` (5). |
| Import health | 55 move-broken lines rewritten, 47 pre-existing Category A danglers repaired, 18 lines across 6 modules waived. **0 unwaived dangling imports** across 497 archived import lines in 156 archived files. |
| C11 | New check in `scripts/check-module-invariants.sh`, shipped **enforced** with no opt-out flag. Reuses C4's regex and resolver, honours `scripts/boneyard-import-waivers.txt`, reports stale waiver entries on the C5 model. Adversarially tested. |
| B0 | Asserts **1** Boneyard directory; the header comment block and the `MODULE_INVARIANTS.md` row are rewritten. |
| Kamp documentation | **10 new READMEs** plus an expanded region index. All **14** directories under `Boneyard/Kamp/` holding a `.lean` have one, and all **85** `.lean` files appear in an original-path table. |
| Single-sourced counts | `FormalSystem/Boneyard/README.md` states the archive's counts in one place (156 files / 88,275 lines / 35 subdirectories / 1 archive), citing B0/C7 as the live source. Nine live-side files now link rather than restate. |

## Final Verification

Every gate below was run at the end of Phase 10, not inferred.

| # | Check | Result |
|---|---|---|
| 1 | rename accounting | 90 `R100` in the phase-2 batch, 35 in the phase-6 batch (28 `R100`, 7 `R098`/`R099`), **0** delete+add pairs |
| 2 | `git log --follow`, one file per moved subdirectory | resolves for all **14** sampled, 6-79 commits of prior history each |
| 3 | `lake build` | **exit 0**, "Build completed successfully (2462 jobs)" |
| 4 | `lake build BimodalTest` | **exit 0**, "Build completed successfully (2512 jobs)" |
| 5 | B0 | PASS at 1 directory; "excluded 156 archived .lean files (553 total -> 397 live)" |
| 6 | C3 | PASS, exactly 1 sorry, `countermodel_discrete`, `WeakCanonical/Transfer.lean` |
| 7 | C4 | PASS, all 1388 live import lines resolve |
| 8 | C5 | PASS, 4 allowlisted, unchanged |
| 9 | C7 | 451 live (397 FormalSystem / 53 Tests) |
| 10 | C11 | PASS: 497 archived import lines, 156 files, **0 unwaived**, 6 waived, 0 stale |
| 11 | `check-module-invariants.sh` | **ALL CHECKS PASSED, exit 0** (C1, C2, C6 compile-check included) |
| 12 | `readme-lint.sh` | exit 1 — **byte-identical to the Phase 1 baseline**; see Divergence D1 |
| 13 | Grep audit | exactly **7** deliberate comment-only mentions in 3 live `.lean` files; nothing else outside `specs/**` |
| 14 | Kamp README coverage | 14 directories, 85 files, **0** problems |
| 15 | `typst-sync-check.sh` | **PASS (all 3 checks green)** |
| 16 | `typst-status-counts.sh` | every count identical to the Phase 1 baseline; `status.typ` regenerates byte-identical to HEAD apart from the commit stamp |

Build-job counts (2462 / 2512 against the baseline's 2458 / 2508) and the live inventory
(451 against 448) rose because several other tasks added live modules concurrently. Archive-side
figures — 156 archived files, 59,019 + 29,256 lines — reconcile exactly with the Phase 1 baseline.

## Plan Deviations

Every divergence is recorded inline on the plan's checklist items and in `baselines/MEASURED.md`.

1. **`readme-lint.sh` was RED at baseline, not green** (Phase 1, D1). The plan's Research
   Integration item 4 asserts all four gates were green; `readme-lint.sh` exits 1 with
   `RESULT: FAIL (7 missing READMEs, 5 broken references)`, none Boneyard-related. It also carried
   a latent `set -euo pipefail` bug: `grep -oP | while read` aborted the whole script mid-Check-3
   on any README with zero markdown links, so it never printed its own summary. Fixed in scope
   (`scripts/readme-lint.sh` is in `file_scope`). **Every later phase's "readme-lint PASS"
   criterion was downgraded to "no worse than baseline"**, and the final output is byte-identical
   to it. A PASS needs 7 live-side READMEs the plan's non-goals put out of scope.
2. **`scripts/typst-status-counts.sh` had to be edited, contradicting the plan's explicit
   "do NOT touch — verified safe"** (Phase 9). The plan's argument holds for
   `sorry-total-excl-boneyard` but not for `sorry-total`: `SORRY_WEAKCANONICAL_ALL` scanned
   `Metalogic/WeakCanonical/`, which *contained* the nested archive and its 4 sorries, so after the
   move it fell 5 -> 1 and `typst-sync-check.sh` went RED. Fixed by pointing `SORRY_KAMP_BONEYARD`
   at the new path and **adding** it rather than subtracting a now-always-zero value. Both figures
   now mean what they meant before the move.
3. **The Category A/B split is 47/18, not 48/17** (D3). `FormalSystem.Metalogic.Completeness` has
   four candidate `Completeness.lean` files and no unique target, so it is Category B — which the
   plan already seeded into the waiver file while also counting it inside its 48.
4. **Total/live file counts are 553/397, not 550/394** (D2), from concurrent tasks adding live
   files. All archive-side counts match exactly.
5. **Real archived import-line counts are 349 + 148 = 497, not 364 + 149** (D4). The plan's
   *point* — use the strict prefixed regex, never a naive `^import` — holds; only its recorded
   numbers were off.
6. **90 renames in Phase 2, not 85.** The plan counted `.lean` only; 5 `README.md` files ride
   along in the moved directories.
7. **7 of Phase 6's 35 renames are `R098`/`R099`, not `R100`.** Those are exactly the moved files
   that also import another moved file — the same phase both relocates them and rewrites an import
   inside them, which the plan asks for. A phase cannot rewrite a file's imports and leave it
   byte-identical.
8. **22 import rewrites in Phase 6, not the predicted "at most 7."** The prediction counted only
   intra-`KampWeakCanonical` edges; `KampBypassArchive/` and `RabinovichPath/` also import flat
   root files. C11 was already enforcing, so a missed rewrite would have failed the gate.
9. **Phase 2's commit attribution.** The 90 staged renames were swept into a concurrently running
   agent's commit `94da79d88`, which staged the whole working tree. All 90 are recorded there as
   `R100` and `git log --follow` resolves; only the carrying commit is misattributed. History was
   not rewritten — five agents were committing to this branch at the time.
10. **`typst/SYNC-MAP.md` stamps were annotated, not rewritten.** It is a dated audit record;
    editing a dated measurement to match today's tree would falsify it. A consolidation note near
    the top explains the convention.
11. **Two pre-existing README inventory gaps closed** while auditing Phase 7 coverage:
    `Separation/Hierarchy/README.md` listed 3 of its 4 files, and `VecEADecomposition/README.md`
    had no file table. Three broken in-archive markdown links were also repaired — one caused by
    the move, two pre-existing. `readme-lint.sh` sees none of these: its Check 3 skips
    `Boneyard`-named directories.

## Reported at Completion (out of scope, per the plan's non-goals)

- **Six missing non-Kamp top-level archive READMEs**: `StaviDiscretePath/`, `DeadConvergenceProof/`,
  `FMPVariants/`, `SoundnessVariants/`, `BXCanonicalQuasimodel/`, `RestrictedMCSDeferral/`.
  Deliverable (g) targeted the Kamp region; these are a pre-existing gap in the top-level archive
  and belong in a follow-up task.
- **Seven comment-only mentions of the old path in three live `.lean` files** —
  `Kamp/DedekindINF.lean` (1), `Kamp/NfMultiAnchorBridge.lean` (5),
  `Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (1) — left untouched under the
  no-live-module non-goal. The decision is recorded in `Boneyard/Kamp/README.md` and
  `Boneyard/Kamp/KampWeakCanonical/README.md`.
- **`readme-lint.sh` remains RED** on 7 pre-existing missing live-side READMEs and 5 pre-existing
  broken references. Unchanged by this task and outside its non-goals.
- **`check-copyright-headers.sh --strict`** exits 1 on `Metalogic/WeakCanonical/RealModel/OrderIsoReal.lean`,
  which lacks a header. Committed in `ce349825f` by unrelated work; not in this task's verification
  contract.
