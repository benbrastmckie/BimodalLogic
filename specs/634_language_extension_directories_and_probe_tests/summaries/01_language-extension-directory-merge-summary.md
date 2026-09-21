# Implementation Summary: Task #634

- **Task**: 634 - Language-extension directories and probe tests
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T07:02:02Z
- **Completed**: 2026-09-21T09:05:00Z
- **Effort**: ~2 hours
- **Dependencies**: 626 (completed), 632 (completed), 633 (completed)
- **Artifacts**: plans/01_language-extension-directory-merge.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed `PUBLICATION_REFACTOR.md` Phase 5. The six directories
`FormalSystem/{Syntax,Semantics}/{Plus,Minus,Star}Language/` are now three self-contained
components at the library root, each carrying its language's syntax, proof system and semantics
together; `Metalogic/Conservativity/MinusLanguageSoundness.lean` became `MinusLanguage/Soundness.lean`;
the 16 semantics modules and `Soundness.lean` were renamed out of `FormalSystem.Semantics` into
flat `FormalSystem.{X}Language`; the 8 `*Probe.lean` files and `TableauConformance.lean` left the
`Tests/BimodalTest/` root for `Tests/BimodalTest/Metalogic/Decidability/`; and the three
foreign-namespace Chronicle files were settled as recorded exceptions.

This task relocates modules and renames namespaces. It introduced no declaration, no theorem and
no `sorry`, and had zero proof obligations.

## What Changed

**Directory merge (Phase 3).** 29 `.lean` files moved from the six source directories into
`FormalSystem/{Plus,Minus,Star}Language/`, plus `MinusLanguageSoundness.lean` and the three
syntax aggregators. The three semantics aggregators were hand-merged into the moved syntax
aggregators and removed; 6 READMEs became 3, each with a generated inventory block covering the
merged directory and a refreshed `Last verified` stamp.

**Namespace rename (Phase 4).** 34 `namespace`/`end` lines across 17 files moved 241 declarations
from `FormalSystem.Semantics` to `FormalSystem.{X}Language`. Each renamed block gained
`open FormalSystem.Semantics`; `MinusFrame.lean` did not, since it imports nothing from
`Semantics/`. Three `TaskFrame.{Minus,Plus,Star}ValidOn` definitions were kept in nested
`namespace FormalSystem.Semantics` blocks — see Decisions.

**Test-root move (Phase 2).** 9 files relocated; `Tests/BimodalTest/` root now holds exactly
`Property.lean`, `WalkthroughAxioms.lean` and `README.md`.

**Harness.** `scripts/check-metalogic-cycles.sh`'s `ALLOWLIST` is now `frozenset()` (its 7 entries
all keyed on a file that left `Syntax/`), and its reporting block prints an empty-allowlist PASS
instead of dereferencing the removed `_DISCHARGE`. `scripts/check-module-invariants.sh` had two
pinned `#print axioms` declarations re-pointed at all four sites.
`scripts/module-invariants-allowlist.txt` lost the three `FormalSystem.{X}Language` entries that
now resolve as real modules. `scripts/measure-refactor-partitions.py`'s docstring counts were
refreshed.

**Documentation.** `PUBLICATION_REFACTOR.md` (the falsified "namespaces unchanged" claim, the
"15 files" count, the Phase 5 heading and acceptance list), `ORGANISATION.md` (a new
extension-language section), `docs/ARCHITECTURE.md` (layer diagram and upward-set section),
`docs/development/MODULE_ORGANIZATION.md`, `FormalSystem/{README,Syntax/README,Semantics/README}.md`,
`docs/theorem-index.md` and 62 files' worth of stale partial-path citations.

## Decisions

- **Two tool runs, not one, for the merge.** The plan assumed one `move-modules.py` invocation
  could carry both the file rows and the three syntax-aggregator rows, on the theory that the file
  rows would consume the directory first. They do not: the tool resolves every row up front,
  before any move, so all three aggregator rows resolved to the *directory* — the silent-orphan
  hazard the plan's own risk table names. Caught in the dry run. Split into 30 file rows, then the
  README merge and `rmdir`, then the 3 aggregator rows.
- **Dot-notation forced three declarations to stay in `FormalSystem.Semantics`.**
  `TaskFrame.MinusValidOn` and its Plus/Star twins are reached as `F.MinusValidOn`. Generalized
  field notation resolves against the *type's* namespace and ignores `open`, so renaming their
  enclosing namespace broke every call site. Each now sits in a nested
  `namespace FormalSystem.Semantics` block. This is acceptance-neutral: `measure_namespaces`
  classifies on `first_namespace(p)`, so only a file's first namespace is audited.
- **The `ChronicleRealExtension.lean` hoist was refuted, not attempted-and-reverted.** A reference
  scan showed the Chronicle block's `cantor_bfmcs_dense_real_restricted_buc` applying two lemmas
  from the Bundle block above it (lines 934 and 943). The interleaving is load-bearing, so the
  file is recorded rather than reordered.
- **Test namespaces were renamed, contrary to a Non-Goal.** `move-modules.py` did it as a side
  effect of its dotted-citation rewrite, since a test module's namespace and module name coincide.
  The result is consistent and the test library is outside the audit either way, so it was left as
  produced rather than hand-reverted across 18 lines.

## Plan Deviations

- **Phase 2** altered: the `BimodalTest.{FileName}` namespace Non-Goal was overridden by the tool.
- **Phase 2** added: 36 prose lines re-wrapped after the longer citation paths pushed them past
  the 100-character limit. One landed inside a `#guard_msgs` docstring and broke
  `lake build BimodalTest` outright; the rest put C28 16 entries above the warning budget. The
  resulting line shifts also required one C20 citation fix and an `--emit-inventory` regeneration.
- **Phase 3** altered: the single-tool-run premise is false (see Decisions).
- **Phase 3** added: 152 stale *partial*-path citations re-based across 62 files — the tool only
  rewrites full `FormalSystem/`-rooted paths. The 9 markdown relative links were re-based by depth
  individually.
- **Phase 3** added: `docs/ARCHITECTURE.md` and `docs/development/MODULE_ORGANIZATION.md` updated
  although neither is in any phase's file list; both stated the pre-merge layout as current fact.
- **Phase 4** altered: the predicted 25-importer fan-out was backwards. Only 2 external files
  needed anything; the real work was the 17 moved files losing unqualified access to `Semantics`
  names.
- **Phase 4** altered: the plan's "0 external FQN citations" and "4 sites" were undercounts; the
  real figure is 13 sites across 3 files, including 5 rows in `docs/theorem-index.md` that the
  plan's `.lean`/`.sh`-only scan could not see.
- **Phase 4** added: the dot-notation obstacle (see Decisions).
- **Phase 5** altered: the hoist was refuted by measurement rather than attempted (see Decisions).

## Verification

- Build: Success. `lake build` 2652 jobs, `lake build BimodalTest` 2704 jobs, both green.
- Sorry count: 0 (C3 reports a structural sorry inventory of ZERO across `FormalSystem/` and
  `BimodalTools/`).
- Vacuous count: 0.
- Axiom count: unchanged. C2 reports all four flagship axiom sets matching baseline, and the two
  pinned declarations match under their new names (`FormalSystem.MinusLanguage.truthAt_tr`,
  `FormalSystem.PlusLanguage.plusValidIn_ofFormula_iff`).
- `bash scripts/check-module-invariants.sh` (build-inclusive, **not** `--no-build`): ALL CHECKS
  PASSED.
- `check-evidence-probes.sh`, `check-copyright-headers.sh --strict`, `check-metalogic-cycles.sh`,
  `check-paper-definitions.sh`: all exit 0. Cycles reports exactly 1 directory cycle and zero
  upward import lines against the now-empty allowlist.
- `readme-lint.sh`: exit 1 with exactly the pre-existing 21 broken `../Boneyard/` references, no
  new STALE DATE finding. One new broken link was introduced during the merge and caught by this
  gate going 21 -> 22; fixed.
- `typst-sync-check.sh`: exit 1 with exactly the pre-existing findings —
  `sorry-total committed=4 live=0`, `MISMATCH_COUNT=2`, and `TOTAL_VIOLATIONS=9`. The 9 are
  `docs/training/PIPELINE.md` path violations cited from `typst/chapters/p4-dataset-pipeline.typ`;
  both sides predate this task (the file does not exist at the task's base commit and `typst/` was
  never touched), so they are not attributed here.
- `measure-refactor-partitions.py namespace-audit`: `unrelated` = 8, verified **by name**.
- Orphan check: `ls FormalSystem/Syntax/*Language*` and `ls FormalSystem/Semantics/*Language*`
  both empty.
- Files verified: Yes.

### Acceptance variance to note

The plan's acceptance figure was an `unrelated` bucket of 5 plus 0-2 Chronicle files. The measured
result is **8**: the 5 recorded exceptions plus **all three** Chronicle files. The five names are
exactly as projected and no unexpected name appeared. The variance is entirely
`ChronicleRealExtension.lean`, which the plan hoped to fix by a zero-cost block hoist; that hoist
is refuted by measurement, as recorded above and in the file's own docstring. Every one of the 8
carries a docstring explaining its namespace, which is the substantive acceptance condition.

## Impacts

- `import FormalSystem.Syntax` and `import FormalSystem.Semantics` no longer reach the three
  extension languages even transitively through the old nested aggregators; consumers import
  `FormalSystem.{X}Language` directly, as `FormalSystem/FormalSystem.lean` now does.
- Declarations formerly at `FormalSystem.Semantics.<name>` for the 241 moved declarations are now
  `FormalSystem.{X}Language.<name>`. Downstream code that reached them through
  `open FormalSystem.Semantics` plus re-export is unaffected; code naming them fully-qualified
  must be updated.
- **The three language directories sit outside `LAYERS`.** `layer_of` returns `None` for them, so
  every import into and out of them is now invisible to the upward-edge measurement —
  `Metalogic -> MinusLanguage` and
  `Semantics/StateLocalTransfer.lean -> PlusLanguage.PlusStateLocal` included. The empty allowlist
  means "nothing measured is upward", not "nothing is upward". No harness check catches a
  regression here; `ORGANISATION.md`'s layer-table note is the only record.

## Follow-ups

- Task 614 can now narrow to the other 42 stale README date stamps; the 3 merged
  language-extension READMEs were restamped here, and the other 2 of its 5 in-scope files no
  longer exist.
- The 21 broken `../Boneyard/` README references remain open, in the Boneyard-relocation
  follow-up. None sits in a language-extension README.
- The 9 `docs/training/PIPELINE.md` violations in `typst-sync-check.sh` are pre-existing and
  unowned; `typst/chapters/p4-dataset-pipeline.typ` cites a file that does not exist.
- No mechanical check enforces the syntax-before-semantics ordering inside the three merged
  directories. Before the merge the directory boundary did. A `grep -rln 'import
  FormalSystem.Semantics'` assertion over each language's syntax modules would restore it.

## References

- `specs/634_language_extension_directories_and_probe_tests/plans/01_language-extension-directory-merge.md`
- `specs/634_language_extension_directories_and_probe_tests/reports/01_language-extension-directories-probes.md`
- `docs/development/PUBLICATION_REFACTOR.md` §4 and Phase 5 — the governing programme document,
  corrected by this task
- `ORGANISATION.md` — the layer table and the new extension-language note
