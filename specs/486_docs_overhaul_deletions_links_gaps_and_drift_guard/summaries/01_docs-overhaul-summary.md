# Implementation Summary: `docs/` Overhaul — Deletions, Links, Gaps, and Drift Guard

- **Task**: 486
- **Plan**: `specs/486_docs_overhaul_deletions_links_gaps_and_drift_guard/plans/01_docs-overhaul-and-drift-guard.md`
- **Status**: all ten phases `[COMPLETED]`
- **Type**: lean4 (documentation correction against a Lean source of truth; zero `.lean` edits)

## Outcome

`docs/` now describes the repository that exists. Every status, count, and path claim is
traceable to Lean source, `#print axioms`, or a filesystem walk; the link resolver returns zero;
the nine missing `FormalSystem/` READMEs exist; and three new checks make this class of drift
fail the build rather than accumulate.

## Verification Gate (all four commands pass)

| Gate | Result |
|------|--------|
| `bash scripts/check-module-invariants.sh` | **ALL CHECKS PASSED**, exit 0, with C12, C13 and C14 all reporting real (non-skipped, non-soft) results and C14's `#print axioms` half running |
| `bash scripts/check-module-invariants.sh --no-build` | **ALL CHECKS PASSED**, C14's `#print axioms` half skipping cleanly |
| `bash scripts/readme-lint.sh` | `Missing READMEs: 0`, `Broken file references: 0`, **RESULT: PASS** |
| Report §6.1 link resolver | **0 lines** |
| `git diff --name-only <base> HEAD -- '*.lean'` | **empty** — no `.lean` declaration, signature, import, or tactic changed |

## Closing Ground Truth, Re-derived

| Fact | Value | Source |
|------|-------|--------|
| Repository metrics | 539 files / 170,898 code / 96,290 comment | `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .` |
| Axiom constructors | 45 | `inductive Axiom` in `FormalSystem/ProofSystem/Axioms.lean` |
| Axiom layer split | Base 37 / Dense 2 / Discrete 3 / Dedekind 3 | `Axiom.minFrameClass` (`Axioms.lean:588`) |
| Structural sorries | 0 | check C3 |
| Import numerals (485 handoff 3) | 9 and 4 | `grep -rhc '^import FormalSystem.Metalogic.{WeakCanonical,Algebraic}' FormalSystem/Metalogic/BXCanonical/` |

## Hypotheses vs. Measurements

The plan required three figures to be re-derived rather than trusted. All three diverged, and
in each case the gate was a command rather than a number, so the divergence was recorded rather
than forcing rework.

| Hypothesis | Measured | Note |
|------------|----------|------|
| 74 actionable dead links | **74 at baseline**, then 71 -> 61 -> **0** | The hypothesis was exactly right at baseline. The count drifted downward as adjacent phases deleted host files and rewrote host prose; gating on the resolver command rather than the number is what made that harmless |
| 15 `SORRY_REGISTRY` inbound references | **28** | The report's table omitted `docs/project-info/README.md` (4 sites) and `tactic-registry.md` (2) entirely, and counted 9 `MAINTENANCE.md` sites where there are 16 |
| 152 task-number citations under `docs/` | **138** | The Phase 1 deletions plus citations removed incidentally while rewriting host prose. 100 of the 138 remain in `docs/development/PHASED_IMPLEMENTATION.md` |

Two further plan hypotheses held **exactly**: the nine README directories with their per-directory
`.lean` file counts (6, 5, 3, 15, 4, 9, 5, 7, 5), and the axiom layer split 37/2/3/3 = 45.

## What Was Deleted

Both targets were confirmed as fiction before removal. The `Bimodal/` tree they both reference
does not exist, and neither do any of the specific files they name.

| File | Lines | Evidence it was fiction |
|------|-------|------------------------|
| `docs/project-info/SORRY_REGISTRY.md` | 196 | Claimed 9 active sorries in `Domain/DiscreteTimeline.lean` and `Canonical/ConstructiveFragment.lean` — neither file exists anywhere in the tree. Its own verification commands at `:24-31` and `:56-69` glob `Bimodal/**/*.lean`, a path that does not exist |
| `docs/project-info/IMPLEMENTATION_STATUS.md` | 331 | Duplicated and contradicted the lowercase `implementation-status.md`, to which its own `:7-9` scope note defers as authoritative. Claimed the same 9 nonexistent sorries |

Both remain recoverable from git history. Two `SORRY_REGISTRY` mentions were retained
deliberately: `reference/readme-standard.md:166` (a row in a naming-convention table that is
*about* the uppercase/lowercase convention) and `MAINTENANCE.md:669` (a historical change-log
record of a past commit, annotated "since deleted").

## Phase Results

| Phase | Content | Result |
|-------|---------|--------|
| 1 | Deletions + `MAINTENANCE.md` procedure rewrite | 28 inbound references repaired; Four-Document Model became a Three-Document Model with the sorry inventory delegated to check C3 |
| 2 | `known-limitations.md` | 178 -> 299 lines. Limitations 1 and 6 rewritten; new Limitation 7 (discrete non-compactness) |
| 3 | Remaining false-status sites | 5 files. `BFMCS_ARCHITECTURE.md` 377 -> 302 lines; `architecture.md`'s 57-line fictional `Logos/` tree replaced |
| 4 | Counts, classification, reference layer | 9 files. `axiom-reference.md` 253 -> 343 lines; `operators.md` gained a primitive-operator section |
| 5 | Nine missing READMEs | `readme-lint.sh` missing count 9 -> 0 |
| 6 | Documentation gaps G1-G9 | All 15 gap-coverage terms now hit ≥1 `docs/` file (research measured 0 for 14 of them) |
| 7 | Dead-link sweep | Resolver 61 -> 0; 25 further non-link stale slash paths repaired |
| 8 | C12 + C13 | Both enforced, both green, zero allowlisted slash paths |
| 9 | C14 + C9D + `readme-lint.sh` scope | C14 enforced and green; C9D soft and reporting 138 |
| 10 | Final gate | All four gate commands pass |

## The Guard

Three new checks in `scripts/check-module-invariants.sh`, plus one soft computation:

- **C12** — every slash-shaped source path in `docs/` + `README.md` resolves. This closes the
  blind spot that let `BFMCS_ARCHITECTURE.md`'s dead source table survive a green gate: C5
  matches only *dotted* module names. C5's regex was **not** extended, per report F8 — doing so
  would have turned the gate red on `FormalSystem/**/README.md` files outside this task's scope.
  C12's pattern includes `Logos/` and `Bimodal/`, the two pre-merge tree roots, since neither
  resolves to anything today and any occurrence is therefore a defect by construction.
- **C13** — every relative markdown link in `docs/` + `README.md` resolves, with three
  documented ignore-paths held in a companion allowlist **file** rather than hardcoded.
- **C14** — a content scan asserting no stale axiom or sorry counts are documented, plus a
  `#print axioms` half pinning `sound_of_isValid` (G1) and `completeness_dedekind` (G3) to a
  recorded baseline. The content scan always runs; the `#print axioms` half skips under
  `--no-build` exactly as C2 does.
- **C9D** — C9's no-task-citations rule computed over `docs/`, soft-enforced behind
  `ENFORCE_C9_DOCS=${ENFORCE_C9_DOCS:-0}` per the script's own documented pattern. The debt is
  visible at every gate without blocking. `ENFORCE_C9_DOCS=1` exits 1 with a count, confirming
  the computation is live rather than a stub.

`scripts/readme-lint.sh` was extended to classify each root: a root containing `.lean` files
keeps the README.md-only scope, any other root has Checks 3-4 scan every `*.md`. Pointing it at
`docs/` now covers 70 files rather than 6. It accepts multiple roots, reads C13's allowlist so
the two cannot disagree, and its summary now prints the two reported-not-gated counts so that
"not gated" cannot be misread as "not measured".

## Negative Tests

Every new check was verified to fail on an injected defect and to revert cleanly.

| Check | Injected defect | Result |
|-------|-----------------|--------|
| C12 | A `FormalSystem/Metalogic/Bundle/DovetailingChain.lean` path in `docs/README.md` | `FAIL C12`, named by file and line; exit 1 |
| C13 | A `[a link](nonexistent-target.md)` in `docs/README.md` | `FAIL C13`, named by file and line; exit 1 |
| C14 | `\| Sorry Placeholders \| 7 \|` in `test-coverage.md` | `FAIL C14  0 stale axiom count(s), 1 documented non-zero sorry count(s)`; exit 1 |
| C9D | `ENFORCE_C9_DOCS=1` | `FAIL C9D 138 task-number citation(s)`; exit 1 |

C12 and C14 additionally caught **their own documentation** while `MODULE_INVARIANTS.md` was
being written — an illustrative `.../Foo.lean` path and the phrase "claimed 21 axioms". Both
were genuine hits and were fixed; the file now carries a closing note explaining why prose in
`docs/` must not name hypothetical paths or quote stale counts in tripwire shape.

## Plan Deviations

| Phase | Deviation | Reason |
|-------|-----------|--------|
| 1 | Repaired 28 inbound `SORRY_REGISTRY` references, not the 15 the report measured | The report's table omitted `project-info/README.md` and `tactic-registry.md` entirely and undercounted `MAINTENANCE.md` (9 vs. 16 sites) |
| 2 | Also fixed `known-limitations.md:157` ("All 21 axiom schemas") and removed the summary table's six task-number citations | Both are Phase 4-class defects, taken here because wave 2 is split by **file ownership** and this file is Phase 2's exclusive owner |
| 2 | `:178`'s `../../../` escape repointed to `../reference/API_REFERENCE.md`, not `implementation-status.md` | The plan's target duplicated a link two lines above |
| 3 | `BFMCS_ARCHITECTURE.md`'s BFMCS/BMCS ontology names were **inverted** relative to the tree, and its 5.1 chain cited six nonexistent theorems; both corrected beyond the plan's list | Leaving them would have shipped a known falsehood and left C12 red. Real names: `FMCS` (single history, `FMCSDef.lean:103`), `BFMCS` (the bundle, `BFMCS.lean:91`) |
| 3 | `implementation-status.md:129-130` metric drift fixed here rather than in Phase 4 | Phase 3 owns this file exclusively; splitting by defect ID would have violated the file-ownership contract |
| 3 | Repaired `docs/user-guide/examples.md:949` | Surplus site asserting the same false Base-frame proof debt, named nowhere in the plan; found by the Phase 2 verification grep |
| 4 | Two surplus decidability-overstatement sites corrected (`BIMODAL_LOGIC.md:137`, `API_REFERENCE.md:216`) | Found by the phase's own verification greps |
| 6 | Replaced `MODULE_ORGANIZATION.md`'s section 1 directory tree | It described a nested `FormalSystem/Bimodal/` layout with `lakefile.toml` and an in-tree `docs/`, none of which exists |
| 7 | `PROPERTY_TESTING_GUIDE.md:712` repointed to `Tests/BimodalTest/Property/` rather than deleted | The report said no such directory exists; it does |
| 7 | 25 further unresolved slash paths repaired across 17 files, beyond the plan's Classes A-J | Required to give C12 a real zero. Five illustrative placeholder filenames were rewritten to name their containing directory, so C12 needs no allowlist entry for them |
| 8 | Two allowlist files created, not one | C12 got `scripts/markdown-slash-path-allowlist.txt` on the same companion-file convention, though it is currently empty |
| 9 | C14 runs its own `#print axioms` with its own baseline rather than extending C2's four-theorem heredoc | C2's baseline is documented as a HARD STOP; adding entries would have made a hard-stop invariant mutable in passing. G1 and G3 are pinned by the build either way |
| 9 | Also fixed a latent `set -e` abort in `readme-lint.sh` | With a non-Lean root, the summary block's `grep -v Boneyard` received empty input, returned 1, and silently truncated the entire summary — `readme-lint.sh docs` printed a bare `=== Summary ===` and nothing else |
| 9 | Corrected three "42 axiom constructors" occurrences in `competitive-landscape.md` | Surplus defect found by C14's own tripwire; 42 is the stale `Axioms.lean:92-95` docstring figure that omits the Dedekind layer |

## Non-Goals Honoured

- The ~38 dotted `Bimodal.*` module references across `FormalSystem/**/README.md` were **not**
  touched, and C5's regex was **not** extended to catch them (report F8). C12 covers the slash
  form of the same defect over a scope that can be enforced today.
- `docs/development/PHASED_IMPLEMENTATION.md` was **not** deleted. Its 100 task-number citations
  are now *visible* at every gate through C9D without blocking.
- The ~110 files present on disk but absent from their directory README's inventory were **not**
  closed. `readme-lint.sh` Check 2 does not affect its exit code; the summary now prints the
  count (109) explicitly rather than leaving it unmeasured.
- `FormalSystem/ProofSystem/Axioms.lean:92-95`'s stale 42-axiom docstring was **not** corrected
  — outside `file_scope`, and correcting it would have meant editing a `.lean` file. Recommend a
  follow-up task; note that the same defect *was* corrected everywhere it appeared in `docs/`.

## Recommended Follow-Ups

1. Correct `FormalSystem/ProofSystem/Axioms.lean:92-95`, whose layer-breakdown docstring gives
   42 and omits the Dedekind layer. It is prose, so it does not touch a declaration.
2. Clear the 138 task-number citations under `docs/` (100 in `PHASED_IMPLEMENTATION.md`), then
   flip `ENFORCE_C9_DOCS` to 1.
3. The dotted `Bimodal.*` sweep across `FormalSystem/**/README.md` that task 485 handed off.
4. Re-derive `competitive-landscape.md`'s anchor-coverage numerator (14), which is flagged
   in-text as not re-derived.
5. `FormalSystem/Metalogic/Bundle/README.md` lists three files that do not exist
   (`FMCS.lean`, `CanonicalIrreflexivity.lean`, `SuccExistence.lean`). They sit inside a code
   fence as bare filenames, so neither C12 nor readme-lint Check 3 sees them.

## Artifacts

- Deleted: `docs/project-info/SORRY_REGISTRY.md`, `docs/project-info/IMPLEMENTATION_STATUS.md`
- Added: nine `FormalSystem/**/README.md` files; `scripts/markdown-link-allowlist.txt`;
  `scripts/markdown-slash-path-allowlist.txt`
- Modified: 45 files under `docs/`, `scripts/check-module-invariants.sh`,
  `scripts/readme-lint.sh`, `FormalSystem/Metalogic/README.md` (two numerals)

---

**Last verified**: 2026-08-25
