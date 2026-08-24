# Research: Consolidate the Two Boneyard Archives

**Task type**: lean4 (repository hygiene; no proof work)
**Verified against**: working tree at `4b6d6e5fd`, 2026-08-24
**Scope note**: this report re-verified every quantity the charter asserts. Several are
stale. All numbers below were measured today; where they differ from the charter, both
are shown.

---

## 1. Executive Summary

The move itself is as safe as the charter says: zero live `.lean` importers, namespaces are
not path-derived, outbound imports are unaffected, and both tooling filters match by the
`Boneyard` *name* so they keep working. Confirmed.

Four findings change the shape of the work:

1. **The archive is already rotten.** 65 import lines inside the two archives name modules
   that do not exist on disk *today*, before anything moves. Deliverable (d)'s checker
   therefore cannot be green on arrival; the charter's verification bullet ("the new checker
   is green") is unachievable without a repair pass, a waiver mechanism, or both. This is the
   single largest planning consequence.
2. **The rewrite set is 55 lines, not 52.** Three imports in the *top-level* archive point
   into the Kamp archive and break on the move. The charter states the top-level tree is
   "unaffected"; for these three files it is not.
3. **The declared `file_scope` is too narrow.** Nine files outside it must change, and two of
   them turn `scripts/readme-lint.sh` RED (exit 1) if they are not touched.
4. **The charter's baseline numbers and its "pre-existing RED" list are stale.** Live count is
   394, not 373. `lake build`, `lake build BimodalTest`, and all of `check-module-invariants.sh`
   are currently GREEN. Nothing is inherited red.

---

## 2. Verified Baseline (measured 2026-08-24)

### 2.1 Inventory

| Quantity | Measured today | Charter says | Status |
|---|---:|---:|---|
| `FormalSystem/**/*.lean` total | 550 | 529 | stale |
| Archived `.lean` (both trees) | 156 | 156 | ok |
| Live `FormalSystem` `.lean` | **394** | 373 | **stale** |
| Live `Tests` `.lean` | 53 | — | — |
| Live total (C7 headline) | 448 | — | — |
| `FormalSystem/Boneyard/` | 93 files, **59,019** lines | 93 / 59,019 | ok |
| `.../Kamp/Boneyard/` | 63 files, **29,256** lines | 63 / 29,256 | ok |

The C7 assertion in the verification contract must read **394 live `FormalSystem` .lean /
448 live total**, unchanged across the move. Using 373 would fail a correct implementation.

### 2.2 Gate baseline — everything is currently green

| Gate | Result | Evidence |
|---|---|---|
| `lake build` | **exit 0** — "Build completed successfully (2458 jobs)" | run today |
| `lake build BimodalTest` | **exit 0** — "Build completed successfully (2508 jobs)" | run today |
| `check-module-invariants.sh --no-build` | **ALL CHECKS PASSED** (B0, C3, C4, C5, C6, C8, C9, C10) | run today |
| `scripts/readme-lint.sh` | **RESULT: PASS**, exit 0 | run today |

**The charter's "PRE-EXISTING RED, inherited not caused" paragraph is obsolete.** C6
(`SoundnessLemmas/CoValidity.lean` `simp` no-progress), C9 (task-number citation in
`WeakCanonical/PriorExpressivenessDense.lean:185`), and the `BimodalTest` `#guard_msgs`
drift in `RegionGateProbe` / `TableauConformance` / `BoxSpreadProbe` have all been fixed.
There is no inherited red to "confirm is no worse". The implementation inherits a clean
tree, which raises the bar: **any red after the move is caused by this task.**

### 2.3 Live-tree safety re-confirmation

- `grep -rn "^import .*Boneyard" FormalSystem/ Tests/ --include=*.lean | grep -v "/Boneyard/"`
  → **empty**. Confirmed.
- No live `.lean` imports either archive. Confirmed.
- 7 live `.lean` files mention `Kamp/Boneyard` **in comments only** (`Kamp/DedekindINF.lean:100`,
  `Kamp/NfMultiAnchorBridge.lean:{34,44,68,278,348}`,
  `Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:26`). Each is prose of the form "parking
  this in `Kamp/Boneyard/` would put it under no glob and in no CI build" — the *policy*
  statement stays true after the move; only the path string goes stale. These are `.lean`
  files, so editing them collides with the non-goal "do not modify any live module". See §6.3
  for the recommended handling.
- Namespaces: no archived file derives a namespace from the `Boneyard` path segment. Confirmed.
- `lakefile.lean` has **no** `BoneyardArchive` target (older `specs/reviews/` documents claim
  one exists; they are wrong). Neither archive is referenced. Nothing to do here, consistent
  with the non-goal.

---

## 3. Finding 1 (critical): the archive is already rotten — 65 dangling imports

Parsing every `.lean` file in both archives with a block-comment-aware parser and resolving
each import against disk (project roots `.` and `Tests/`, plus all nine `.lake/packages/`):

| Archive | Files | Real import lines | **Unresolvable** |
|---|---:|---:|---:|
| `FormalSystem/Boneyard/` | 93 | 364 | **63** |
| `.../Kamp/Boneyard/` | 63 | 149 | **2** |
| **Total** | 156 | 513 | **65** |

Import-target breakdown:

| Target class | Top-level | Kamp |
|---|---:|---:|
| `FormalSystem.Boneyard.*` (self) | 47 | 0 |
| `*.Kamp.Boneyard.*` | **3** | 52 |
| other `FormalSystem.*` | 299 | 96 |
| external (Mathlib etc.) | 15 | 1 |

The charter's "47 pre-existing top-level self-imports" all resolve fine. The rot is in the
*other* 299 live-looking imports, 63 of which point at modules that no longer exist.

### 3.1 The 65 split into two repair classes

**Category A — 48 lines, repairable.** The import names a module whose file still exists,
just at a different path (usually because the target was itself archived and its module path
changed). Every one can be fixed by rewriting the import to the target's current archive
module path. Representative cases:

| Source | Dangling import | Where the file actually is |
|---|---|---|
| `Boneyard/KampBypassArchive/KampBypass.lean:1` | `...Kamp.KampBypassEqCase` | `Boneyard/KampBypassArchive/KampBypassEqCase.lean` |
| `Boneyard/KampBypassArchive/KampBypass.lean:4` | `...Kamp.KampComposition` | `Kamp/Boneyard/KampComposition.lean` |
| `Boneyard/RabinovichPath/RabinovichGeneralized.lean:5` | `...Kamp.NfCharFormula` | `Boneyard/KampBypassArchive/NfCharFormula.lean` |
| `Boneyard/RoundRobinChain/DRMChain.lean:2` | `...Metalogic.Bundle.SuccExistence` | `Boneyard/BundleSuccessorSeed/SuccExistence.lean` |
| `Boneyard/StaviDiscretePath/DiscreteStaviCompleteness.lean:5` | `...EFGames.DiscreteGameTransfer` | `Boneyard/StaviDiscretePath/DiscreteGameTransfer.lean` |
| `Kamp/Boneyard/KampComposition.lean:1` | `...Kamp.NfComposition` | `Kamp/Boneyard/NfComposition.lean` |
| `Kamp/Boneyard/NfExistTL.lean:2` | `...Kamp.FOToVEA` | `Kamp/Boneyard/FOToVEA.lean` |

Concentration: `KampBypassArchive/` (22 lines), `RabinovichPath/` (8), `KampNegationClosure/`
(4), `BundleSuccessorSeed` consumers (4), `StaviDiscretePath/` (2), scattered singles.

**Category B — 17 lines, NOT repairable.** The module was deleted outright and exists nowhere.
Six distinct modules, all deleted in one commit:

```
FormalSystem.Metalogic.Algebraic.ParametricTruthLemma            (5 sites)
FormalSystem.Metalogic.Algebraic.ParametricCompleteness          (4 sites)
FormalSystem.Metalogic.Algebraic.RestrictedParametricTruthLemma  (4 sites)
FormalSystem.Metalogic.Algebraic.ParametricHistory               (2 sites)
FormalSystem.Metalogic.Algebraic.ParametricCanonical             (1 site)
FormalSystem.Metalogic.Completeness                              (1 site, ambiguous)
```

`git log --diff-filter=D` attributes all five `Algebraic.*` deletions to commit `6c3419a4f`
("delete superseded canonical model stack"). Affected files: `ChainCompleteness/Algebraic/DeterministicFMCS.lean`,
`DeadChronicleGapElimination/ChronicleGapChainExcision.lean`, `DefectDirectedChain/RootScopedChain.lean`,
`QuasimodelOracle/OracleCoherence.lean`, `ScheduleBasedBFMCS/RootScopedChain.lean`,
`StrictSemanticsLegacy/Algebraic/{DovetailedChain,RestrictedTruthLemma,UltrafilterChain}.lean`,
`UltrafilterFrame/UltrafilterFrame.lean`.

Category B cannot be fixed without reviving deleted modules, which the non-goals forbid.

### 3.2 A documented policy contradicts deliverable (d)

`FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` currently states:

> "Import lines inside archived files are historical text, not build edges. They are kept
> coherent with file locations where cheap ... but **stale imports in never-built code are
> cosmetic and need not be repaired.**"

Deliverable (d) reverses this policy. The plan must retire that sentence explicitly in the
consolidated README, or the archive will carry a written rule that its own new gate violates.

### 3.3 Recommended checker design

Model it on the existing **C4** (`scripts/check-module-invariants.sh`, the `python3` heredoc
block), which already does exactly this job for live files, and on **C5**, which already
supplies the allowlist idiom (`scripts/module-invariants-allowlist.txt`, with stale-entry
reporting). Concretely, add **C11** to the same Python block:

- Walk both archive trees (post-consolidation, one tree).
- Reuse C4's regex `^import\s+((?:FormalSystem|BimodalTest)(?:\.[A-Za-z0-9_]+)*)\s*$` with
  `re.M`. **Do not widen it to all imports** — see §3.4.
- Resolve via C4's `mod_to_path`.
- Read waivers from a new `scripts/boneyard-import-waivers.txt`, same comment/parse idiom as
  the C5 allowlist, one module per line with a `#` reason. Seed it with the six Category B
  modules.
- Report stale waivers (entry no longer occurring) the way C5 does — this is what stops the
  waiver file from becoming a dumping ground.
- Fail on any unwaived dangling import.

Gate policy recommendation: repair all 48 Category A lines (they are archived files, so
editing them breaks no non-goal), waive the 17 Category B lines with the commit SHA as the
recorded reason, and ship C11 enforcing from day one. If the planner prefers to defer the
Category A repair, C11 must instead follow the C8/C9/C10 precedent of an `ENFORCE_C11`
flag defaulting to 0 — but note the script's own comment forbids ever flipping a flag back
to 0, so shipping it enforced-and-green is the cleaner outcome.

### 3.4 Trap: a naive `grep '^import'` checker gets 15 false positives

Block-comment continuation lines and a fenced code block inside a doc-comment start with the
word `import` at column 0:

- 13 in the Kamp archive, e.g. `ExteriorAmbientDeepAnchorProbeK.lean:6` —
  `"import closure, so uncompiled). Ambient deep-anchor refutation probe."` (a wrapped
  sentence inside a `/- ... -/` header), and `Prop43.lean:185`.
- 2 in the top-level archive: `DenseChronicle/CantorIsoCountermodel.lean:{28,29}`, inside a
  markdown ```` ``` ```` block headed "## Old Imports (for reference)".

Naive counts are therefore 366 (top) and 162 (Kamp) against real counts of 364 and 149.
Restricting the pattern to `FormalSystem`/`BimodalTest` prefixes (as C4 does) removes all 15
today. A block-comment-aware parser is cheap insurance but not strictly required.

---

## 4. Finding 2: the rewrite set is 55 lines, not 52

The 52 intra-Kamp import lines are confirmed. **Three additional lines in the top-level
archive import into the Kamp archive and break identically:**

```
FormalSystem/Boneyard/RabinovichPath/RabinovichGeneralized.lean:6
FormalSystem/Boneyard/RabinovichPath/RabinovichNegation.lean:6
FormalSystem/Boneyard/RabinovichPath/RabinovichWiring.lean:5
    import FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.RabinovichTranslation
```

The charter's statement that top-level files "are not moving and are unaffected" holds for
their 47 self-imports but not for these three. **Total rewrite target: 55 lines.**

### 4.1 Where the 52 intra-Kamp edges point (this makes deliverable (g) cheap)

| Target location | Inbound intra-archive edges |
|---|---:|
| Files inside existing subdirectories (`Separation/`, `NfMultiAnchorBridgeRetired/`, `ExpressiveCompleteness/`) | **45** |
| Files flat at the archive root | **7** |

Only 7 edges target the 35 flat root files (`VecEA_m` ×2, `NegationIndep`, `VecEAArityFirewall`,
`ExteriorFiberConsistencyProbeK`, `NavigatedEndCharSinglePoint`, `EAVecNegationClosure`).
So regrouping the flat files into per-approach subdirectories — deliverable (g) — adds **at
most 7 further import rewrites**. Deliverable (g) is not expensive; do it in the same pass.

---

## 5. Finding 3: `file_scope` is too narrow — 9 files outside it must change

Declared scope: `FormalSystem/Boneyard/`, `.../Kamp/Boneyard/`,
`scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`.

### 5.1 Two files that turn `readme-lint.sh` RED if untouched

`readme-lint.sh:165-174` resolves every markdown link in every non-Boneyard README and
**exits 1** on any that does not exist. Two links point into the moving tree:

| File | Line | Link | After move |
|---|---:|---|---|
| `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md` | 65 | `[Kamp Boneyard inventory](Boneyard/README.md)` | **broken** |
| `FormalSystem/README.md` | 19 | `[...](Metalogic/WeakCanonical/Kamp/Boneyard/README.md)` | **broken** |

This is a hard, mechanically-detectable failure, not a cosmetic one. It also means the
charter's "verify readme-lint still skips the consolidated tree correctly" understates the
risk: the skip logic is fine (all six `*Boneyard*` guards and both `grep -v Boneyard`
filters match by name and keep working); the *link* check is what breaks.

### 5.2 Full list of out-of-scope files needing edits

| File | What is stale | Severity |
|---|---|---|
| `FormalSystem/README.md` | "TWO Boneyards" section + table (`62 / 27,394`, `93 / 59,010`) + broken link :19 | **breaks readme-lint** |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md` | whole `## This Directory Has Its Own Boneyard` section (:8-16), table row :26, :56, broken link :65 | **breaks readme-lint** |
| `FormalSystem/Metalogic/README.md` | :8, :14-17, :185, :191, :249, :293 — two-Boneyard prose and counts | prose |
| `FormalSystem/Metalogic/WeakCanonical/README.md` | :31, :36-38 — "carries its own local `Boneyard/`" | prose |
| `docs/development/MODULE_INVARIANTS.md` | :19 B0 row ("Both Boneyards"); also needs the new C11 row | doc gate |
| `scripts/check-copyright-headers.sh` | :22 comment names both trees, says "151 archived files" (actual 156) | comment |
| `scripts/add-copyright-headers.sh` | :18 comment names the Kamp tree, "62 files" | comment |
| `scripts/typst-sync-check.sh` | :97 comment example uses the Kamp path | comment |
| `typst/SYNC-MAP.md` | :174, :177, :310, :394 — counts split around the nested archive | prose |

None of these is a live Lean *module*, so editing them does not violate the non-goal. But
`file_scope` in `state.json` should be extended before implementation, or the implementer
will hit a scope wall mid-task.

### 5.3 Scripts that are safe — verified, do not touch

- `scripts/typst-status-counts.sh:110` computes `SORRY_KAMP_BONEYARD` from the moving
  directory. Its helper `strip_and_count_sorries` (:75-83) explicitly returns `0` for a
  missing path — the comment says "subtrees legitimately disappear when they are archived".
  Post-move, `SORRY_WEAKCANONICAL_ALL` drops by the same amount that `SORRY_KAMP_BONEYARD`
  goes to 0, so the subtraction stays arithmetically correct. **No change needed.**
- `scripts/typst-sync-check.sh` matches `Boneyard` by name in its walk filter. Safe.
- No `typst/**/*.typ` source references the Kamp Boneyard path (`grep`: zero hits).
- `check-module-invariants.sh` C5 skips directories named `Boneyard` during its walk, so
  archive READMEs are exempt from the markdown module-path check. No live markdown contains a
  module-shaped `FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.*` path (only
  `specs/TODO.md`, which C5 excludes). **C5 stays green.**

---

## 6. Deliverable-by-Deliverable Findings

### 6.1 (a) The move

`git mv` preserves history reliably here — `git log --follow` already resolves through the
prior archival of `Boneyard/KampBypassArchive/KampBypass.lean` back through two path
renames (`task 402 phase 2/3`, `task 359 phase 3`). Rename detection is at its default
(both `diff.renames` and `status.renames` unset = on).

**Recommendation: two commits, not one.**
1. Commit 1: pure `git mv` of all 63 files, no content edits. `git status` shows 63 clean
   `R100` renames; this is the artifact the verification contract asks for.
2. Commit 2: the 55 import rewrites plus README work.

Combining them still yields rename detection (similarity stays far above 50%), but the
`R100` evidence is unambiguous only if the move commit is content-free. Cheap insurance.

Structure to preserve under `FormalSystem/Boneyard/KampWeakCanonical/`:
`ZetaProbes/` (5), `NfMultiAnchorBridgeRetired/` (5), `ExpressiveCompleteness/` (2 + README),
`Separation/` (16 + `DedekindZ/README.md` + `Hierarchy/README.md`), plus 35 flat root files
and the tree README.

### 6.2 (b) Reconciling with the existing Kamp material — it is 4 directories, not 1

The charter names `KampBypassArchive/` (13 files). Measuring which top-level archive
directories import `FormalSystem.Metalogic.WeakCanonical.Kamp.*`:

| Directory | Files | Kamp-import edges |
|---|---:|---:|
| `KampBypassArchive/` | 13 | 34 |
| `KampNegationClosure/` | 4 | 12 |
| `RabinovichPath/` | 4 | 11 |
| `VecEADecomposition/` | 1 | 3 |
| `MergedBracketQuarantine/` | 1 | 2 (borderline) |

So "ONE coherent Kamp region" means reconciling **22 files across 4 directories** with the
incoming 63, not 13 with 63.

Two viable readings, both sanctioned by the charter's "either ... or state in writing why":

- **Option A (literal, minimal risk).** Move the 63 to `FormalSystem/Boneyard/KampWeakCanonical/`
  exactly as (a) specifies. Satisfy (b) in prose: a "Kamp region" section in
  `FormalSystem/Boneyard/README.md` that indexes all five Kamp directories and states which is
  authoritative for what. 63 renames.
- **Option B (physical umbrella).** Create `FormalSystem/Boneyard/Kamp/` containing
  `KampWeakCanonical/` (the 63, keeping (a)'s directory name) plus `git mv` of
  `KampBypassArchive/`, `KampNegationClosure/`, `RabinovichPath/`, `VecEADecomposition/`
  into it, with `Kamp/README.md` as the region index. 85 renames.

**Recommendation: Option B.** It is what "not two sibling directories that each look
authoritative" actually asks for, and the extra cost is near zero on the import side: all
34+12+11+3 = 60 Kamp-facing imports in those 22 files are *already dangling today* (they are
the bulk of Category A), so moving them adds no new breakage — the same repair pass fixes
them either way. Precedent exists for umbrella directories with a single covering README:
`ChainCompleteness/` (3 subdirs) and `StrictSemanticsLegacy/` (3 subdirs) both work that way.

### 6.3 (c) The rewrite — 55 lines, and the live-comment question

The 55 lines are mechanical. The open judgment call is the **7 comment-only mentions of
`Kamp/Boneyard/` in 3 live `.lean` files** (§2.3). Options:

- Leave them. The policy claim each makes ("parking this under a `Boneyard/` puts it under no
  glob and in no CI build") stays true; only the illustrative path is stale. Honors the
  non-goal exactly.
- Update the path strings. Cleaner, but edits live modules.

**Recommendation: leave them, and record the decision in the consolidated README** with the
note that the correct path is now `FormalSystem/Boneyard/`. If the user wants them updated,
that is the "separate task" the non-goal anticipates. Either way, no `.lean` semantics change
and `lake build` output is unaffected.

### 6.4 (d) The checker — see §3.3. This is the deliverable with real design content.

### 6.5 (e) B0 and the header comment

Exact locations (charter's line numbers are correct):

- `scripts/check-module-invariants.sh:72-79` — `mapfile -t BONEYARDS ...; if [ "${#BONEYARDS[@]}" -eq 2 ]`
  and the two message strings ("covers exactly 2 directories" / "expected 2 Boneyard
  directories"). Change `2` → `1` in all three places.
- `:63` — `live_lean()`'s `-not -path '*/Boneyard/*'`. **Do not change.** It still works, and
  keeping the glob (rather than narrowing to `FormalSystem/Boneyard/*`) is what makes B0's
  count assertion meaningful as a regression detector if a second archive ever reappears.
- `:20-22` — the header comment block ("Every filesystem traversal excludes BOTH Boneyards
  ... ~27k archived lines from the Kamp-local Boneyard"). Rewrite; the "27k" figure was
  already wrong (actual 29,256).
- `:5-16` — the check list at the top of the file needs a C11 line.
- B0's second half (the `ALL_LEAN > LIVE_LEAN` load-bearing proof, :81-88) is unaffected and
  should stay. It will report "excluded 156 archived .lean files (550 total -> 394 live)"
  before and after.

### 6.6 (f) READMEs — the drift is worse than the charter records

| Location | Claims | Actual |
|---|---|---|
| `Boneyard/README.md:36` | top-level `93 / 59,010` | 93 / **59,019** |
| `Boneyard/README.md:37` | Kamp `62 / 27,394` | **63 / 29,256** |
| `Kamp/Boneyard/README.md:36` | top-level `93 / 59,010` | 93 / **59,019** |
| `Kamp/Boneyard/README.md:37` | Kamp `63 / 29,256` | correct |
| `FormalSystem/README.md:18-19` | `93 / 59,010`, `62 / 27,394` | both wrong |
| `Metalogic/README.md:14-15` | `93 / 59,010`, `62 / 27,394` | both wrong |
| `Metalogic/README.md:191` | Kamp `62 / 27,394` | wrong |
| `Kamp/README.md:10, :26` | Kamp `62 / 27,394` | wrong |
| `check-copyright-headers.sh:22` | "151 archived files" | 156 |
| `add-copyright-headers.sh:18` | Kamp "62 files" | 63 |

Nine hand-maintained copies of two numbers, seven of them wrong. **Recommendation: state each
count in exactly one place** — the consolidated `FormalSystem/Boneyard/README.md` — and have
every other location link to it rather than restate it, citing `check-module-invariants.sh`'s
B0/C7 output as the live source. That is the durable fix for the class of bug the task exists
to retire.

Also retire, in writing:
- `Kamp/Boneyard/README.md`'s closing paragraph, which justifies the nesting ("nested here
  rather than under the top-level Boneyard to keep the Kamp pipeline's history next to the
  live `Kamp/` code it descended from"). This task overrules it; say so.
- The "stale imports ... need not be repaired" sentence (§3.2).

### 6.7 (g) Per-approach documentation — the top-level archive is only 76% compliant

**9 of 38 top-level subdirectories have no README**, contradicting the charter's premise that
the top-level archive "already has the right convention":

| Missing README | .lean files |
|---|---:|
| `KampBypassArchive/` | **13** |
| `KampNegationClosure/` | 4 |
| `RabinovichPath/` | 4 |
| `StaviDiscretePath/` | 4 |
| `DeadConvergenceProof/` | 2 |
| `FMPVariants/` | 2 |
| `SoundnessVariants/` | 2 |
| `BXCanonicalQuasimodel/` | 1 |
| `RestrictedMCSDeferral/` | 1 |

The directory deliverable (b) must reconcile — `KampBypassArchive/`, the largest undocumented
subdirectory in the archive — is one of them. Any honest "one coherent Kamp region" outcome
has to write these four Kamp-related READMEs (13+4+4+1 = 22 files) as part of the work.

On the Kamp side, existing sub-READMEs: `ExpressiveCompleteness/`, `Separation/DedekindZ/`,
`Separation/Hierarchy/`. Missing: `ZetaProbes/` (5), `NfMultiAnchorBridgeRetired/` (5),
`Separation/` top (16). Plus the 35 flat root files need grouping — the existing 215-line
`Kamp/Boneyard/README.md` already names the families, so the taxonomy is available rather
than needing invention: `Exterior*ProbeK` family + `InteriorHrealSupplyK` + `NfZone*Probe` +
`SeamPairRefutationProbe` + `ZoneSeamCrossContextProbe` (probe iterations); V-EA / normal-form
infrastructure (`VecEA_m`, `EAVecNegationClosure`, `VecEAArityFirewall`, `ArityReduction`,
`FOToVEA`, `NfComposition`, `NfExistTL`, `NegationIndep`, `EndpointNegation`, `WitnessCount`);
Kamp/translation-era (`KampComposition`, `RabinovichTranslation`, `RefutationF2`, `ZoneBridge`,
`SeparationBridge`, `Separation`); and the individually-documented singles (`Prop43`,
`Prop43DepthCharInfra`, `Arity4CharStackK`, `EANegationVBracketBackward`,
`NavigatedEndCharSinglePoint`).

Per §4.1, physically regrouping costs at most 7 extra import rewrites.

**Original-path recording**: the charter requires every README to record each file's original
path. Note that `Arity4CharStackK.lean` already carries a per-block provenance table in its
own header, and several files record their excision origin in prose — the README tables
should not contradict those.

---

## 7. Recommended Verification Contract (corrected)

Replace the charter's §6 with:

| # | Check | Expected |
|---|---|---|
| 1 | `git status` after the move commit | 63 (Option A) or 85 (Option B) renames, `R100`, zero delete+add pairs |
| 2 | `git log --follow` on one file per moved subdirectory (`ZetaProbes/`, `NfMultiAnchorBridgeRetired/`, `Separation/`, `Separation/DedekindZ/`, `Separation/Hierarchy/`, `ExpressiveCompleteness/`, root) | resolves through the move |
| 3 | `lake build` | exit 0, output unchanged from the recorded baseline |
| 4 | `lake build BimodalTest` | exit 0 (**was green before; must stay green** — not "no worse") |
| 5 | `check-module-invariants.sh` B0 | PASS at **1** directory; "excluded 156 archived .lean files (550 total -> 394 live)" |
| 6 | C3 | exactly 1 sorry, `countermodel_discrete`, `WeakCanonical/Transfer.lean` |
| 7 | C4 | all 1376 live import lines resolve (unchanged) |
| 8 | C5 | PASS, 4 allowlisted (unchanged) |
| 9 | C7 | **394** live `FormalSystem` / 53 `Tests` / 448 total — unchanged |
| 10 | C11 (new) | green: 0 unwaived dangling imports across the consolidated archive; waiver file has 6 entries, 0 stale |
| 11 | `check-module-invariants.sh` overall | ALL CHECKS PASSED, exit 0 |
| 12 | `readme-lint.sh` | **RESULT: PASS**, exit 0, 0 broken references (requires the §5.1 README edits) |
| 13 | Grep audit | zero remaining references to `Metalogic/WeakCanonical/Kamp/Boneyard` outside `specs/**` and `.git/**`, except the 7 deliberate live-comment mentions if §6.3 Option "leave them" is taken |

Record the `lake build` / `lake build BimodalTest` output **before** the first `git mv` so
check 3's "unchanged" is a real comparison rather than an assertion.

---

## 8. Suggested Phase Decomposition

Sized so each phase is one agent run and ends at a green, committable milestone.

| Phase | Work | Gate |
|---|---|---|
| 0 | Record build + invariant + readme-lint baselines to a scratch file. Extend `file_scope` in `state.json` per §5.2. | baselines captured |
| 1 | Pure `git mv`: 63 files → `KampWeakCanonical/` (+ 22 more if Option B). No content edits. | `git status` = all `R100` |
| 2 | Rewrite the 55 broken import lines (52 intra-Kamp + 3 `RabinovichPath/`). | targeted resolution check passes |
| 3 | Repair the 48 Category A dangling imports; create `scripts/boneyard-import-waivers.txt` with the 6 Category B modules. | 0 unwaived danglers |
| 4 | Add C11 to `check-module-invariants.sh`; update B0 to 1; update `:5-16` check list and `:20-22` header comment. | C11 + B0 green, `--no-build` ALL PASS |
| 5 | READMEs — archive side: merge the two "TWO Boneyards" sections into one, single-source the counts, retire the nesting justification and the "stale imports are cosmetic" sentence, write the missing per-approach READMEs (§6.7), regroup the 35 flat files if doing (g) physically (+ up to 7 more import rewrites). | readme-lint PASS |
| 6 | READMEs — live side: the 9 out-of-scope files in §5.2, incl. the two that gate readme-lint. Add the C11 row to `MODULE_INVARIANTS.md`. | readme-lint PASS, C5 PASS |
| 7 | Full verification sweep per §7 (with build). | all 13 checks |

Phases 1 and 2 must not be merged (see §6.1). Phase 3 is separable from 1-2 and could be
dropped to a follow-up task if the planner prefers — but then C11 in phase 4 must ship with
either a much larger waiver file (65 entries) or an `ENFORCE_C11=0` flag, and the script's own
comment discourages the latter.

---

## 9. Open Questions for the Planner

1. **(b) Option A or B?** Report recommends B (physical `Boneyard/Kamp/` umbrella, 85
   renames). A is the literal reading of (a) and is lower-risk.
2. **Category B waivers vs. deferral.** Recommend waive-and-enforce now. The alternative is a
   `[BLOCKED]` note asking whether those 9 files should instead be deleted — but deletion is
   an explicit non-goal.
3. **The 7 live `.lean` comment mentions** (§6.3). Recommend leaving them untouched and
   recording why.
4. **`file_scope` extension** (§5.2) needs to happen before implementation, not during.
