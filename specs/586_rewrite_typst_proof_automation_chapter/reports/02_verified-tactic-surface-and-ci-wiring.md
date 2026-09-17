# Research Report: Verified Tactic Surface, Widened Retired-Tactic Prose, and CI Wiring for Task 586

**Task**: Rewrite `typst/chapters/p4-proof-automation.typ` against the retired-tactics tree; widened to all non-`docs/` retired-tactic prose; final phase wires `typst-sync-check.sh` into CI.
**Produced**: 2026-09-17 (research phase, dispatch seq 2)
**Supersedes/extends**: `specs/586_rewrite_typst_proof_automation_chapter/reports/01_retired-tactics-chapter-drift.md` (2026-09-16 sweep-evidence report). Report 01's diagnosis is correct as far as it goes; this report re-verifies every number directly against live source **as of 2026-09-17** (one day later) and finds that **report 01's own live-count claim for `Tactics/Commands.lean` (586) is already stale** — a commit landed the same day the review was written that cut it further. All numbers below are freshly measured, not copied from the review or from report 01.

## Executive Summary

- `bash scripts/typst-sync-check.sh` still exits 1 with the same 4 Check-1 violations (Checks 2/3 pass). Nothing has fixed the chapter yet.
- **Live tactic/search surface, verified directly from `FormalSystem/Automation/Tactics/*.lean`, `FormalSystem/Automation/ProofSearch/*.lean`, `FormalSystem/Automation/SuccessPatterns.lean`, `FormalSystem/Metalogic/WeakCanonical/EFGameTactics.lean`, and `FormalSystem/Automation.lean`'s docstring** — see the corrected Module Map table below. `sorry`-freedom re-verified by direct grep (0 hits) on all nine live files.
- **The old `Tactics/Helpers.lean` (1,032 lines, archived 2026-09-07) was split into three live files**: `UserTactics.lean` (275, user-facing macros), `Search.lean` (657, the search engine), `Meta.lean` (99, shared `MetaM` plumbing) — not reunited under one name. The chapter's current "`apply_axiom` and `modal_t` live in `Automation/Tactics/Helpers.lean`" is wrong on both counts: wrong path, and `tm_auto` (the tactic the sentence also names) does not exist at all.
- **`tm_auto`, `temporal_search`, `propositional_search` are gone**, absorbed into `modal_search` (per `FormalSystem/Automation.lean`'s own docstring, quoted below). `AesopRules.lean`/`AesopRuleSet.lean` (322 lines total) are archived to `FormalSystem/Boneyard/RetiredTactics/`, retired on measured evidence of zero call sites (`FormalSystem/Boneyard/RetiredTactics/README.md`).
- **Widened-scope re-grep** (outside `docs/` and `Boneyard/`) finds exactly four live-tree locations still describing the retired tactics as present-tense, beyond the chapter itself: two lines in `FormalSystem/Automation/README.md` (84, 137), one line in `FormalSystem/Automation/ProofSearch/README.md` (19), and one line in `typst/chapters/p4-dual-verification.typ` (36). All four are named explicitly below with exact current line numbers (re-verified — they have drifted slightly from the numbers named in the dispatch's WIDENED note, since that note was itself written against an earlier commit).
- **A related but distinct staleness bug, found incidentally**: `FormalSystem/Automation/ProofSearch/README.md`'s own hand-written module table claims `Core.lean` is 1018 lines; it is actually 1,283. This is not "retired-tactic prose" (Core.lean is fully live) and is not named in the dispatch, but it sits in the same file being touched for the `tm_auto` fix, costs nothing extra to correct, and is currently caught by **no** automated check (see the machine-generation analysis below). Flagging for the plan to decide whether to fold in.
- **Decision recommendation on machine-generating the Module Map**: generate it. Concrete extension path identified below, modeled on the `sorry-table` split-row precedent already in `scripts/typst-status-counts.sh` / `typst-sync-check.sh` Check 2, and on the working precedent of `FormalSystem/Automation/Tactics/README.md`'s own `<!-- BEGIN GENERATED: inventory -->` block (verified accurate, unlike the two READMEs above that lack such a marker).
- **CI wiring for the FINAL PHASE**: `typst-sync-check.sh` has **zero** `lake`/`typst` binary dependency (confirmed: Check 2's `--json` mode of `typst-status-counts.sh` explicitly documents "must run without a build"; Check 3 is jq/python/awk only). It has no cache-warm placement constraint and can be appended as a plain step before "Report results" in `.github/workflows/ci.yml`, following the exact convention `docs/development/CI_CD_PROCESS.md`'s "Wiring a New Check Script" section records (task 583). Exact block given below.

## 1. Verified live tactic surface

Quoting `FormalSystem/Automation.lean`'s module docstring directly (ground truth, not inferred from the chapter):

> `modal_search`: Bounded proof search for TM derivability goals — the single proof-search entry
> point. It replaced `temporal_search`, `propositional_search` and `tm_auto`, which differed
> from it only in `SearchConfig` weight fields that `searchProof` never read, and which have
> been removed.

`apply_axiom`, `modal_t` (macros) and `assumption_search` (elab) are declared in
`FormalSystem/Automation/Tactics/UserTactics.lean:72,89,110`. `modal_search`'s two syntax forms
and elaborators are in `FormalSystem/Automation/Tactics/Commands.lean:99,108,145,150`.

**Why `Commands.lean`'s line count moved a second time.** Report 01 and `specs/reviews/review-2026-09-16.md` both cite `Tactics/Commands.lean` as 586 live lines (down from a stale chapter claim of 710). That was correct on 2026-09-16 at the time of measurement, but commit `dcd99a330` ("task 594 phase 7: relocate test-labelled example sections", same day, timestamped after the review) cut `Commands.lean` from 586 to **163** by moving embedded round-trip test examples out into `Tests/BimodalTest/Automation/TacticsTest.lean` and three other test files. Use **163**, not 586 — the freshest measurement, not the review's.

`ProofSearch/Core.lean` (1,283), `ProofSearch/Strategies.lean` (401), and `SuccessPatterns.lean`
(429) have not changed since the 2026-09-07 retirement (confirmed via `git log --follow`: last
touch to each predates the 2026-09-16 review), so the review's numbers for those three are
still accurate and match my fresh `wc -l`.

`EFGameTactics.lean` lives at `FormalSystem/Metalogic/WeakCanonical/EFGameTactics.lean` (**not**
under `Automation/` at all) and is **331** lines, not 326 as both the chapter and the review
state — a small discrepancy worth using the freshly measured number for.

## 2. Corrected Module Map data (for the chapter table)

All nine rows independently re-verified 2026-09-17 (`wc -l` + `grep -c sorry` on the live file):

| Module | Path | Lines | sorry-free | Role |
|---|---|---:|---|---|
| `Commands.lean` | `Automation/Tactics/Commands.lean` | 163 | yes | The `modal_search` tactic: its `SearchConfig`, its two syntax forms, and the elaborators that run the search |
| `Deduction.lean` | `Automation/Tactics/Deduction.lean` | 182 | yes | `deduction`, `deduction n`, `undischarge`: frame-class-polymorphic applications of `Metalogic.Core.deductionTheorem` |
| `Meta.lean` | `Automation/Tactics/Meta.lean` | 99 | yes | Shared `MetaM` plumbing for derivability goals (goal recognition, head-symbol readers, context rebuilding) — the third of the old `Helpers.lean` shared by `PropDecide.lean` and `Commands.lean` |
| `PropDecide.lean` | `Automation/Tactics/PropDecide.lean` | 158 | yes | `propDecide`: reflective tautology tactic; the one genuinely load-bearing tactic in `Tactics/` per `ProofSearch/README.md` |
| `Search.lean` | `Automation/Tactics/Search.lean` | 657 | yes | The bounded proof-search engine: `searchProof` and its five strategies (axiom match, tagged-lemma match, assumption lookup, MP decomposition, modal/temporal K), run in `TacticM` because `Axiom` is `Prop`-valued and `DerivationTree` is `Type`-valued |
| `UserTactics.lean` | `Automation/Tactics/UserTactics.lean` | 275 | yes | The tactics a proof author writes by hand — `apply_axiom`, `modal_t`, `assumption_search` — plus the `Formula` predicates/extractors deciding when they apply |
| `Core.lean` | `Automation/ProofSearch/Core.lean` | 1,283 | yes | `boundedSearch`, `iddfsSearch`, heuristic scoring (`heuristicScore`/`advancedHeuristicScore`/`patternAwareScore`), memoization |
| `Strategies.lean` | `Automation/ProofSearch/Strategies.lean` | 401 | yes | Best-first search (`bestFirstSearch`), `SearchStrategy` dispatcher, learning variant (`searchWithLearning`) |
| `SuccessPatterns.lean` | `Automation/SuccessPatterns.lean` | 429 | yes | `PatternDatabase` learned-heuristic layer |

**Live total for these nine modules: 3,647 lines.** The chapter's header currently claims
"~4,300-line tactic, Aesop-integration, and bounded-proof-search half of `Automation/`" — also
stale (it predates both the `Helpers.lean`/`AesopRules.lean` retirement and the `Commands.lean`
test-relocation). Recommend either updating the approximate figure to ~3,650 or dropping the
specific number entirely in favor of prose, given how twice this exact number has already gone
stale within two months.

`EFGameTactics.lean` (331 lines, sorry-free) should **not** appear in this table: the table's
own caption scopes it to `Automation/`, and this module lives under
`Metalogic/WeakCanonical/`. The chapter's existing `== Learning and Game-Theoretic Tactics`
prose already frames it correctly as a cross-reference ("The module belongs to the
discrete-case expressiveness infrastructure of the metalogic chapter") — keep that framing, just
correct 326 → 331 there.

## 3. The `== Aesop Integration` section

Confirmed archived: `FormalSystem/Boneyard/RetiredTactics/AesopRules.lean` and
`AesopRuleSet.lean` (322 lines total, moved unchanged). `Boneyard/RetiredTactics/README.md`
records the measurement: the `TMLogic` Aesop rule set had **zero** consumers anywhere in the
live tree or `Tests/` — not merely unused, *unreachable*, since the rules sat in a dedicated
rule set that plain `aesop` never sees and no `aesop (rule_sets := [TMLogic])` call existed
anywhere. `Tactics/README.md` already states the correct current fact for the live tree: "There
is no Aesop rule set. One existed and was retired."

Recommend replacing the whole section with a short retirement note citing this measurement and
pointing at `Boneyard/RetiredTactics/README.md`, per the dispatch's own suggestion — this is
"genuinely good content for a proof-automation chapter" (the *why* something was removed is
often more instructive than an inventory of what remains) and is a much smaller, more durable
target than re-describing a live Aesop integration that no longer exists.

**Whitelist consequence**: `typst/sync-check-whitelist.txt` currently carries two entries —
`` @[aesop norm unfold] `` and `` @[aesop safe forward] `` — added specifically to suppress Check-1
false positives from this chapter's Aesop-attribute exposition (the whitelist's own comment
names `p4-proof-automation.typ` and `AesopRules.lean` explicitly). If the section is replaced
with a retirement note that no longer quotes bare Aesop attribute syntax, these two whitelist
entries become orphaned and should be removed in the same change — an orphaned whitelist entry
is exactly the kind of silent drift `typst-sync-check.sh` exists to prevent elsewhere.

## 4. Widened scope: retired-tactic prose outside `docs/` and `Boneyard/`

Re-grepped `tm_auto|temporal_search|propositional_search` across the whole tree, excluding
`docs/` (owned by task 590, `[RESEARCHING]`, not yet touchable) and `Boneyard/` (deliberately
historical). Current hits, with **freshly re-verified line numbers** (they have shifted since
the dispatch's WIDENED note, which named lines 61/114 for `Automation/README.md`):

- `typst/chapters/p4-proof-automation.typ` — the chapter itself, 9 occurrences (lines 20, 25, 28,
  29, 37, 38, 42, 70, 93) — in scope, handled by the main rewrite.
- `typst/chapters/p4-dual-verification.typ:36` — `+ *Decide.* Run \`decide\` (or, inside a proof,
  attempt \`tm_auto\`/\`modal_search\`).` Fix: drop `` tm_auto/ `` and cite only `modal_search`.
- `FormalSystem/Automation/README.md:84` — inside the file's `<!-- BEGIN GENERATED -->` inventory
  block (lines 51–85), but this specific row (`Tactics/` — a **directory** row with `—` in the
  Lines column) is hand-authored free text, not machine-checked: `check-module-invariants.sh`
  passed cleanly with this line present, confirming the inventory checker validates only
  leaf-file line counts, never directory-row prose. Current text: `` Tactic elaborators:
  `apply_axiom`, `modal_t`, `tm_auto` (Commands.lean, Helpers.lean) ``. Fix: drop `tm_auto`, drop
  `Helpers.lean` (archived), and update the file list to the current six (`Commands.lean`,
  `Deduction.lean`, `Meta.lean`, `PropDecide.lean`, `Search.lean`, `UserTactics.lean`).
- `FormalSystem/Automation/README.md:137` — a hand-written usage example, `` tm_auto  --
  Uses Aesop with TMLogic rule set ``, under a `## Usage Examples` heading with a live
  `apply_axiom` example directly above it. Fix: replace with a `modal_search` example, matching
  `Tactics/README.md`'s own usage examples for consistency.
- `FormalSystem/Automation/ProofSearch/README.md:19` — `` - Integration point for \`tm_auto\`
  and other high-level tactics ``. Fix: replace with `modal_search` (or `Search.lean`'s
  `searchProof`, the actual caller).

`FormalSystem/Automation/README.md:14` and `FormalSystem/Automation/Tactics/README.md:6-7`
already describe the removal correctly in the past tense ("were removed after measurement
showed...") — confirmed these stay untouched, matching the dispatch's own note that files
"already describ[ing] them correctly as removed... stay."

No other live-tree (non-`docs/`, non-`Boneyard/`) hits exist for any of the three retired names.

## 5. Decision: should the Module Map become machine-generated?

**Recommendation: yes, generate it — record this explicitly rather than hand-fixing.** Three
independent pieces of evidence point the same way:

1. **The chapter's own hand-maintained table has now drifted twice** in two months (once at the
   2026-09-07 retirement, caught by this task; the "~4,300" approximate figure in the header
   drifted a second, smaller time on 2026-09-16 without anyone noticing, because nothing checks
   prose approximations either).
2. **The identical hand-vs-generated contrast already exists side by side in the Lean tree**:
   `FormalSystem/Automation/Tactics/README.md`'s `<!-- BEGIN GENERATED: inventory
   dir=FormalSystem/Automation/Tactics -->` block is *currently completely accurate* (163, 182,
   99, 158, 657, 275 — matching my fresh `wc -l` exactly), while the sibling
   `FormalSystem/Automation/ProofSearch/README.md`, which has no such marker, is stale by 265
   lines on `Core.lean` (1018 vs 1,283) and nobody caught it. Machine-checked tables in this
   codebase stay correct; hand-written ones drift, even when both live one directory apart.
3. **The infrastructure to extend already exists and has a working precedent for exactly this
   shape of problem**: `scripts/typst-status-counts.sh` already regenerates scalar counts and a
   `sorry-table` tuple array into `typst/generated/status.typ`, and `typst-sync-check.sh` Check 2
   already diffs the committed file against a live regeneration — including, notably, a prior
   *split* of one logical row into two (`WeakCanonical/ (live)` vs `WeakCanonical/ (archived,
   Boneyard/Kamp/)`) specifically because a stale single row once produced a contradictory
   reading. That same split-row technique is the right model here: module *name* and *line
   count* are cheaply regenerable facts (a `wc -l` over a fixed file list, excluding
   `Boneyard/`), while the *Role* column is genuinely hand-written prose that no script should
   try to synthesize.

**Concrete extension path** (for the plan to size, not to implement here):
- Add a fixed module list (the nine Tactics/ProofSearch/SuccessPatterns paths above) to
  `scripts/typst-status-counts.sh`, emitting a `module-map` tuple array —
  `(path, lines, sorry_free)` — into both `--json` output and a new `#let module-map = (...)`
  binding in `generated/status.typ` (or a dedicated `generated/module-map-automation.typ`,
  mirroring how the machine appendix got its own generated file rather than crowding
  `status.typ`).
- Extend `typst-sync-check.sh` Check 2's Python comparison block to diff this new tuple array the
  same way it already diffs `sorry-table`.
- The chapter's `Role` column stays a hand-written array keyed by the same path strings, joined
  at render time by a small typst function — so a renamed/added/removed module fails loudly
  (missing key) rather than silently drifting, while the Role text itself is never
  machine-generated.
- This is strictly larger than "just fix the table's numbers this once," so the plan should
  treat it as an explicit sub-decision: implement the generator now, or record "hand-fix now,
  defer generation with a named reason" — either is acceptable per the dispatch, but silence is
  not (the dispatch's own words: "The whitelist is not the fix" / "a hand-fix will drift again").

## 6. Dependency check: task 591 (module renames)

Report 01 flagged a dependency on task 591 ("that task may rename modules in `Automation/`...
Rewrite the table once, after the names are final"). Confirmed via `specs/state.json`: **task
591 status is `completed`**. None of its five renamed modules
(`DataExport.lean`/`DatasetExport.lean`/`DatasetExporter.lean`/`ProofStepExport.lean`/
`ProofStepExtractor.lean`) overlap the tactic/search modules this chapter covers, so the rename
does not directly touch the Module Map rows above — but its completion does mean names in
`Automation/` are now stable, clearing the dependency report 01 raised. Safe to proceed.

## 7. CI wiring for the FINAL PHASE (task 583's pattern)

`docs/development/CI_CD_PROCESS.md`'s "Wiring a New Check Script" section (§160+) is the
authoritative convention, established by task 583 and already followed by five existing steps in
`.github/workflows/ci.yml` (`check-module-invariants.sh --no-build`,
`check-copyright-headers.sh --strict`, `readme-lint.sh`, `check-evidence-probes.sh`,
`check-metalogic-cycles.sh`). Three rules from that section apply directly:

1. **Step naming**: `name:` contains the script's exact invocation.
2. **Cache-warm placement**: a check with no `lake`/`lean` dependency "has no placement
   constraint of its own," but by convention is still appended directly before `Report results`.
   **Verified `typst-sync-check.sh` has no `lake`/`lean`/`typst`-binary dependency at all**: its
   own header states Check 3 is "jq/python/awk only; no lake invocation," and Check 2's
   `typst-status-counts.sh --json` mode is explicitly documented (in that script, around line
   199) as deliberately excluding the one `lake env lean` call the script contains (used only for
   the axiom report in the full write path) — "`--json` is consumed by `typst-sync-check.sh`,
   which must run without a build." So this step can run immediately after checkout with zero
   ordering dependency on the Lean build steps, though by convention it is still placed last,
   before `Report results`.
3. **Skip-and-report-neutral**: not applicable — `typst-sync-check.sh` has no legitimately-absent
   input in CI (the whole `typst/` tree and `FormalSystem/` are always present in this repo).

Exact step to append, immediately before the existing `- name: Report results` step:

```yaml
      - name: Typst sync check (scripts/typst-sync-check.sh)
        run: |
          set -euo pipefail
          echo "::group::bash scripts/typst-sync-check.sh"
          bash scripts/typst-sync-check.sh
          echo "::endgroup::"
```

No new dependency installs are needed (jq/python3 are already present on `ubuntu-latest`
runners; the script itself asserts this). Note this wiring covers **only** `typst-sync-check.sh`
per the dispatch's FINAL PHASE — it does not add a `typst compile` CI gate (no such step exists
today; `typst` the binary is not currently installed in CI at all). That is a related but
separate gap, out of this dispatch's stated scope; flagging for awareness only.

## Verification checklist for the implementation phase

- `bash scripts/typst-sync-check.sh` exits 0 (all three checks pass, including after the
  whitelist-entry removal in §3).
- `typst compile typst/BimodalReference.typ <scratch-output>.pdf` succeeds (confirmed the command
  and current baseline both work today, before any edits: exit 0, only pre-existing
  `unknown font family` warnings unrelated to this task).
- Every module named in the rewritten chapter resolves to a live path with a `wc -l` matching
  what is printed, re-checked at commit time (not copied from this report, which will itself age).
- No archived declaration (`tm_auto`, `temporal_search`, `propositional_search`, `AesopRules.lean`,
  `AesopRuleSet.lean`, `Tactics/Helpers.lean`) is described in the present tense anywhere in the
  chapter, `FormalSystem/Automation/README.md`, `FormalSystem/Automation/ProofSearch/README.md`,
  or `typst/chapters/p4-dual-verification.typ`.
- `bash scripts/check-module-invariants.sh` still reports `ALL CHECKS PASSED` (the two README
  fixes touch only hand-authored prose the checker does not currently validate, so this is a
  regression guard, not an expected-change target).
- If the CI-wiring FINAL PHASE is done in the same implementation pass: a deliberately
  reintroduced violation (e.g. temporarily re-adding `` `tm_auto` `` to the chapter) makes the new
  CI step fail, confirming the gate is live before removing the test edit.
