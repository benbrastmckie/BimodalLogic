# Research Report: Task #938

**Task**: 938 - Convert the repository's measured-but-unenforced health signals into pinned baselines that block regressions
**Started**: 2026-11-18T23:27:36Z
**Completed**: 2026-11-18T23:35:42Z
**Effort**: Medium (3 independent baseline mechanisms, no content rewrites)
**Dependencies**: None (research only). Shares territory with concurrent sibling tasks 937 (fix red CI workflows on main) and 829, both research-phase this same `/orchestrate` cycle.
**Sources/Inputs**:
- `scripts/readme-lint.sh` (read in full) and a live run against the default `FormalSystem` root
- `scripts/check-module-invariants.sh` (C16 and C20 sections read in full, ~3200-3800 and ~620-900) and a live `--no-build` run
- `scripts/nolints.json`, `scripts/c20-declaration-baseline.txt`, `scripts/warning-budget.txt`, `scripts/warning-budget.py` (read for precedent)
- `docs/development/MODULE_INVARIANTS.md`'s "Adding a Check" section
- `.github/workflows/ci.yml` (read for how these two scripts are actually wired into CI)
- `.lake/packages/batteries/scripts/runLinter.lean` (read to confirm `nolints.json`'s read path is root-independent)
- `lakefile.toml` (read to independently cross-check the C16-roots denominator)
**Artifacts**: specs/938_enforceable_repo_health_baselines/reports/01_enforceable-health-baselines.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The repository already has a working, in-tree pattern for exactly this problem — a committed,
  keyed, ratchet-only baseline file plus an `ENFORCE_*` flag — used three different ways today:
  `scripts/nolints.json` (keyed by declaration name, read unconditionally by `runLinter`
  regardless of which root is named), `scripts/c20-declaration-baseline.txt` (keyed by
  `citer|target|names`, no line number so legitimate re-anchoring does not churn it), and
  `scripts/warning-budget.txt` (keyed by `path|linter`, deliberately a per-file-per-class count,
  not a bare aggregate, "so one warning fixed and another introduced in the same class" cannot
  cancel out invisibly). All three recommendations below are variations on this one established
  model, not a new mechanism.
- Live-measured today (2026-11-18, this session): README `STALE DATE` = 62, `MISSING DATE` = 4,
  of 84 total READMEs (`bash scripts/readme-lint.sh`, exit 0). C20: tier-1 clean (1000/1000);
  10 recorded declaration-span mismatches still on `scripts/c20-declaration-baseline.txt`; 145 of
  1030 citations carry no declaration name (residual, tier-1-only); 39 name something the target
  file does not declare or declares ambiguously; 30 name a filename that is ambiguous or resolves
  to no live file (`bash scripts/check-module-invariants.sh --no-build`, exit 0). These four
  numbers match the dispatch's own stated measurement exactly.
- C16's non-`FormalSystem` root count is independently confirmed at 18 (4 `lean_lib` + 15
  `lean_exe` roots in `lakefile.toml`, minus `FormalSystem` itself = 18), consistent with the
  dispatch's "16 of 18" framing; the 231-finding/16-dirty-root figure itself was not
  re-executed this session (each root needs its own `lake build` before linting, and sweeping
  all 18 is multi-minute) and is carried from the dispatch's 2026-11-18 measurement —
  see the Findings section's explicit `CARRIED-UNVERIFIED` mark.
- **Load-bearing CI finding, not previously stated in the dispatch**: `check-module-invariants.sh`
  is invoked in CI (`.github/workflows/ci.yml`) with `--no-build`, which structurally skips
  *both* halves of C16 (the block is gated on `RUN_BUILD=1`, which `--no-build` sets to 0). The
  first half's real CI enforcement path is a *different* mechanism entirely — `lean-action`'s
  `lint: true` step, which runs `lake lint` (hence `runLinter`, hence `nolints.json`) directly
  against the default library target and is NOT `continue-on-error`. Flipping
  `ENFORCE_C16_ROOTS` to `1` makes the **local full-mode run** (`bash
  scripts/check-module-invariants.sh`, no `--no-build`, the default) exit non-zero on a
  regression — which is exactly what this task's own verification bullet asks for — but it does
  **not**, by itself, add CI coverage for the other 18 roots, because CI never runs that code
  path. Wiring that gap into CI is additional scope this task's own boundary note defers ("does
  NOT own the two red CI workflows, separately filed") — recorded here as a risk, not assumed
  away.
- Recommended model, per signal: (1) README dates — a committed keyed baseline listing the 62
  currently-stale README paths (plus the 4 missing-date paths, or a second smaller baseline),
  gating readme-lint.sh's existing Check 4 the same way C20's third assertion already gates;
  (2) C20's three residual counts — extend `scripts/c20-declaration-baseline.txt`'s per-key
  ratchet model (or a `warning-budget.txt`-style per-file count, since residual/unverifiable
  citations have no "target" to key against the way a wrong-declaration mismatch does) to the
  145/39/30 counts; (3) C16 roots — extend `scripts/nolints.json` itself (the mechanism the
  dispatch explicitly points at) with the current per-root findings' declaration names, then
  flip `ENFORCE_C16_ROOTS` to `1`, since `nolints.json` is read unconditionally by `runLinter`
  for *any* module argument — confirmed by reading the vendored `runLinter.lean` source, not
  assumed.

## Context & Scope

This is a research-only dispatch for task 938: convert three already-measured, already-reported,
but exit-code-inert repo-health signals into committed baselines with a flag that fails on a
NEW finding (not a zero-findings burn-down). The three signals, each already instrumented by an
existing script at an advisory tier:

1. README `Last verified` staleness (`scripts/readme-lint.sh` Check 4).
2. C20's three un-gated sub-counts (`scripts/check-module-invariants.sh`'s citation-tier block):
   the 10 recorded declaration-span mismatches already on a baseline file (not itself the gap —
   this one already ratchets and is already gated for *new* mismatches); the 145 residual
   (unnamed) citations; the 39 unverifiable-against-target-file citations; the 30
   unresolvable/ambiguous-filename citations.
3. C16's "second half" — the env_linter batch widened to every non-`FormalSystem` lakefile root,
   currently reporting-only behind `ENFORCE_C16_ROOTS=0`.

Explicitly out of scope per the dispatch: the two red CI workflows (filed separately, and visible
as sibling task 937 in this same orchestrate cycle's territory), and any content rewrite of the
mathematics. Where burning a finding down to zero is cheaper than baselining it, the dispatch
permits that, but a baseline-and-gate is required in every case, including a burned-to-zero one.

## Findings

### Codebase Patterns — the three existing baseline mechanisms

**`scripts/nolints.json`** (228 entries at last count in this session, all `unusedArguments`,
one `[linterClass, FullyQualifiedDeclName]` pair per line). Consumed by Batteries'
`runLinter.lean` (vendored at `.lake/packages/batteries/scripts/runLinter.lean:133-134`):
`nolintsFile : FilePath := "scripts/nolints.json"`, read unconditionally and used to filter
reported findings before deciding pass/fail — **independent of which module name is passed to
`runLinter`**. This is the single most important mechanical fact for the C16 recommendation
below: the same file already grandfathers findings for whichever root(s) `lake exe runLinter`
is pointed at, so extending it to the other 16 dirty roots reuses the live mechanism rather than
adding a second one beside it. The script's own comment already warns that `--update` rewrites
the file **wholesale**, keeping only findings for the root(s) named on that invocation and
silently dropping every other root's grandfathered entries (observed: 914 -> 237 lines) — so a
safe extension must run `--update` once against the full root list (`FormalSystem` plus the
other 18), not once per root.

**`scripts/c20-declaration-baseline.txt`** (22 lines, 19 non-comment keys at last count). Key
shape: `citer_path|target_path|comma_joined_declaration_names`, deliberately carrying **no line
number** because a legitimate re-anchoring pass (`reanchor-lean-citations.py --by-name`) moves
the number without making the citation any more wrong. The check-module-invariants.sh block
computes `seen[key]` vs `baseline[key]` and only counts a mismatch as `new_fail` when
`seen[key] > baseline.get(key, 0)` — i.e. it is a per-key **count** ratchet, not a boolean
present/absent list, so two mismatches sharing a key can still register one new failure if a
third appears. A key with `baseline[k] > seen.get(k, 0)` is reported as stale (available for
pruning) but never fails anything on its own.

**`scripts/warning-budget.txt` / `scripts/warning-budget.py`** (C28). Key shape:
`<count> <path> <linter>` — explicitly documented in the generator's own docstring as
"deliberately not a per-class scalar (which cannot catch one warning fixed and another
introduced in the same class), and deliberately without line numbers (so ordinary edits above a
warning do not churn the baseline)." This is the cleanest statement in the repository of why a
*global aggregate count* ceiling is the wrong shape for this kind of baseline, and argues for a
per-file (or per-file-per-category) key wherever the signal lacks a natural "target" identity to
key against (as C20's residual/unverifiable counts do — see below).

### Signal 1 — README verification dates

Live run this session, `bash scripts/readme-lint.sh` (default root `FormalSystem`): 62
`STALE DATE` lines, 4 `MISSING DATE` lines, 84 total READMEs found, exit 0 (`RESULT: PASS`).
Both counts are WARNINGS in the script's own accounting and neither affects `MISSING`/`BROKEN`,
the only two variables the final `if` checks. The summary block even already prints
`Missing dates (info): 4` but has **no corresponding printed count for STALE DATE at all** — the
62 figure is visible only by scrolling the per-line warning output, not the summary — worth
fixing regardless of the gating decision, since a reader skimming only the summary currently
cannot see the 62 number exists.

CI calls this script as `bash scripts/readme-lint.sh FormalSystem BimodalTools`
(`.github/workflows/ci.yml`), so the roots in scope for CI are the same two the baseline would
need to cover; `docs/`, `latex/`, `typst/` are explicitly excluded from Check 4 in the script
already (`case "$dir" in *docs*|*latex*|*typst*) continue ;; esac`).

### Signal 2 — C20 citation tiers

Live run this session, `bash scripts/check-module-invariants.sh --no-build`: tier 1 clean
(1000/1000 resolvable citations land on a real, non-blank line); tier 2 clean (zero
publication-scope `file.lean:NNN` citations); declaration-span: "all 866 named citation(s) land
inside a declaration they name, or are on the recorded baseline", with 10 on the baseline still
to repair, 39 unverifiable (name resolves nowhere in the target, or ambiguously), and 145 of
1030 total citations carrying no name at all (residual). Overall script exit 0. Every one of
these four numbers matches the dispatch's own stated 2026-11-18 measurement exactly, independent
of this session's run.

Two of the three "still to extend" counts (unverifiable-against-target and
no-live-file/ambiguous) are structurally different from the wrong-declaration count the existing
baseline already covers: a wrong-declaration mismatch has a well-defined `(citer, target,
names)` triple to key against, but an unverifiable or residual citation has **no target** (the
name resolves nowhere, or there is no name) — so the existing key shape does not transplant
directly. The nearest available identity is the citer file path (optionally with the raw
`ref:num` citation text, but never the line number, for the same reason `c20-declaration-baseline.txt`
omits it — an unrelated edit above the citation would otherwise silently manufacture a "new"
finding). This points toward a `warning-budget.txt`-shaped per-citer-file count ceiling for
these three counts rather than a literal reuse of `c20-declaration-baseline.txt`'s triple-key
format.

### Signal 3 — C16 env_linter roots

The dispatch's "231 findings across 16 of 18 non-FormalSystem lakefile roots" is a **carried**
figure in this report: it was not re-executed this session.

    231 findings across 16 of 18 non-FormalSystem lakefile roots [CARRIED-UNVERIFIED: dispatch
    file specs/938_enforceable_repo_health_baselines/.dispatch/3.md, "The three signals, as
    measured 2026-11-18" section, point 3]

What *was* independently re-derived this session is the denominator: `lakefile.toml` declares 4
`[[lean_lib]]` roots (`FormalSystem`, `BimodalTest`, `BimodalTools`, `BimodalToolsTest`) and 15
`[[lean_exe]]` roots, for 19 roots total, 18 of them non-`FormalSystem` — consistent with the
dispatch's "18" denominator (re-executing the per-root `lake build` + `lake exe runLinter` sweep
itself was judged too costly for this research pass: 18 separate module builds, several of
which are first builds for exe roots CI does cache but this session's shell does not start
warm).

The script's own header records an *older* measurement (2026-09-21, pre-dating two new exe roots
`check_certificate` and `translate_sentence` visible in today's `lakefile.toml`): "196 findings
across 13 of 16 roots" — so the finding count has grown by 35 and the dirty-root count by 3 in
the ~8 weeks since that comment was last updated, which is itself direct evidence for the
dispatch's framing that an advisory-tier, PASS-reporting signal drifts upward silently. That
2026-09-21 table should be refreshed (or replaced by a pointer to the generated baseline file,
once one exists) in the same change that adds the baseline, since a hand-written snapshot
comment living beside a check that explicitly distrusts hand-written snapshots (see C14's own
rationale, referenced in the same file) is exactly the defect class this file otherwise guards
against.

### C16/CI wiring gap (load-bearing, not previously stated in the dispatch)

`.github/workflows/ci.yml`'s "Check module invariants" step runs
`bash scripts/check-module-invariants.sh --no-build`. `RUN_BUILD` is set to `0` only when
`--no-build` is passed (`check-module-invariants.sh:204-205`, default `RUN_BUILD=1`), and *both*
C16 blocks — the `FormalSystem`-only first half AND the all-roots second half — are wrapped in
`if [ "$RUN_BUILD" -eq 1 ]; then ... fi` (lines 3671 and 3694). So CI's invocation of this script
never executes either C16 block; it prints `INFO C16 env_linter batch skipped (--no-build)`
instead for both. The FIRST half's actual CI enforcement comes from an entirely separate
mechanism: the `lean-action` step earlier in the same workflow runs with `lint: true`, which
invokes `lake lint` (and therefore `runLinter`, and therefore `scripts/nolints.json`) directly
against the build's default targets, and that step is **not** `continue-on-error: true` — a
`lake lint` regression against `nolints.json` already fails CI today through this path, not
through check-module-invariants.sh's C16 block at all.

The practical consequence for this task: flipping `ENFORCE_C16_ROOTS` to `1` makes the exit code
of a **local, full-mode** run (`bash scripts/check-module-invariants.sh`, the default with no
`--no-build`) regression-sensitive for all 18 roots, which satisfies this task's own
verification bullet ("introducing one new finding... makes the corresponding gate fail"). It
does **not** add CI coverage for those 18 roots, because CI structurally never runs the code
path the flag gates. Since `BimodalTools` is outside Lake's `defaultTargets` and the other 17
roots are either a second library or `lean_exe` targets `lean-action`'s `build: true` never
elaborates for linting purposes, none of the 18 roots this task would baseline are linted in CI
by any existing step today. Whether to also add a CI step for the widened C16 scope is a
decision this task's own scope boundary explicitly defers to the separately-filed CI-workflow
task(s); it is recorded here so the plan phase does not silently assume local enforcement implies
CI enforcement.

## Decisions

- Treat "a gate that fails on an increase" as the complete, sufficient target for this task,
  per its own completion criterion — no signal here requires burning its existing debt to zero
  first, matching the `ENFORCE_C9_DOCS`/`ENFORCE_C16_ROOTS` soft-ladder precedent already
  documented in `docs/development/MODULE_INVARIANTS.md`'s "Adding a Check" section, except that
  this task deliberately pins a nonzero ceiling rather than waiting for the count to reach zero
  before flipping the enforcement flag — a documented, deliberate departure from that section's
  "flip the default to 1 once it reaches zero" phrasing, consistent with the dispatch's own
  explicit instruction.
- Do not propose a bare global-aggregate-count ceiling for any of the three signals. The
  in-repo precedent (`warning-budget.py`'s own documented rationale) is explicit that an
  aggregate count cannot distinguish "one fixed, one new, net unchanged" from "truly no new
  finding," and every existing baseline mechanism in this repository (`nolints.json`,
  `c20-declaration-baseline.txt`, `warning-budget.txt`) is keyed by item identity, never a bare
  total.
- Flag, rather than silently resolve, the CI-wiring gap found for C16: this task can make the
  local full-mode gate regression-sensitive, but cannot by itself make CI catch a regression in
  the 18 widened roots without also adding a CI step — which the dispatch's own scope boundary
  places outside this task.

## Recommendations

1. **README dates** — add a committed baseline file (e.g. `scripts/readme-stale-baseline.txt`)
   listing the 62 currently-stale README paths (one per line, same comment-header convention as
   `c20-declaration-baseline.txt`), and a second small list or a shared file for the 4
   missing-date paths. Change `readme-lint.sh`'s Check 4 to compare the live stale/missing set
   against the baseline set: a path newly stale or newly missing that is NOT on the baseline
   increments `ERRORS` (not `WARNINGS`) and is therefore gated by the existing
   `[ "$MISSING" -gt 0 ] || [ "$BROKEN" -gt 0 ]` exit condition (extended with the new variable),
   while a path already on the baseline continues to print as a warning only. Also print the
   STALE DATE count in the Summary block (currently absent there, see Findings) in the same
   change, since gating a number that is not even summarized would be an odd pairing.
   Verified against the live corpus this session: the 62/4/84 figures above are this session's
   own measurement, not carried.
2. **C20 residual/unverifiable/ambiguous counts** — extend the existing per-key ratchet
   mechanism, but key by **citer file path** (optionally plus category, in the
   `warning-budget.txt` shape: `<count> <path> <category>`) rather than reusing
   `c20-declaration-baseline.txt`'s `citer|target|names` triple verbatim, since two of the three
   counts have no target to key against. Generate the baseline from the current per-file
   breakdown of the 145/39/30 totals (the Python block in `check-module-invariants.sh` already
   computes `unverifiable`, `unnamed`, and the residual `verdicts[lc.RESIDUAL]` tally per
   citation; grouping those by `p` — the citer path already available in each tuple — is a small
   addition to the existing loop, not a new scan). Gate: a citer file whose current count in any
   of the three categories exceeds its baseline entry fails; a file not in the baseline with a
   nonzero count also fails (new file introducing the defect class). This is a direct structural
   extension of code already in the script, not new scanning logic.
   [CORPUS-UNVERIFIED: FormalSystem/BimodalTools/BimodalTest/Tests/docs/typst/scripts citation
   corpus / the per-citer-file count ceiling rule above, since the per-file breakdown itself was
   not computed this session — only the aggregate 145/39/30/10 totals were]
3. **C16 roots** — extend `scripts/nolints.json` (not a new file) with the current findings
   across the 16 dirty roots, keyed exactly as the existing 228 entries are
   (`[linterClass, FullyQualifiedDeclName]`), then flip `ENFORCE_C16_ROOTS` from `0` to `1`. This
   reuses the mechanism the dispatch explicitly names as already established, is mechanically
   confirmed to apply root-independently (the vendored `runLinter.lean` reads
   `scripts/nolints.json` unconditionally regardless of the module argument), and needs no new
   comparison logic in `check-module-invariants.sh` at all — only data gathering (run
   `lake exe runLinter --update FormalSystem <other 18 roots...>` in one invocation, per the
   script's own warning that `--update` is destructive across unlisted roots) and the flag flip.
   Before committing to this over a parallel `warning-budget.txt`-style per-root ceiling file,
   the plan phase should run `lake exe runLinter BimodalTools` once by hand and confirm its
   findings are indeed suppressed after adding matching `nolints.json` entries — this was
   confirmed by reading the tool's source, not by an executed end-to-end test, and is cheap
   to check directly.
4. Refresh (or remove) the 2026-09-21 hand-written per-root finding table in
   `check-module-invariants.sh`'s C16 comment in the same change that adds the new baseline —
   it is currently 35 findings and 3 roots stale relative to this session's cross-checked root
   count, which is the exact silent-drift failure mode this whole task exists to close,
   happening inside the very script meant to close it.
5. Record, in the plan or its own follow-up note, that flipping `ENFORCE_C16_ROOTS=1` changes
   only the local full-mode gate's exit code, not CI's — and explicitly decide (rather than
   silently assume) whether a CI step for the widened C16 scope belongs in this task, the
   separately-filed CI-workflow task, or neither for now.

## Risks & Mitigations

- **`nolints.json` `--update` destructiveness**: running `--update` against a subset of roots
  silently drops every other root's grandfathered entries (the script's own comment records an
  observed 914 -> 237 line collapse). Mitigation: always pass the full root list in one
  invocation when regenerating, and diff the result before committing, exactly as the script's
  own existing C16 note already recommends for the `FormalSystem`-only case.
- **Line-number churn in any new per-citer-file baseline**: keying by path only (not path+line)
  avoids baseline churn from unrelated edits above a citation, mirroring
  `c20-declaration-baseline.txt`'s and `warning-budget.txt`'s own documented rationale for
  omitting line numbers — carrying this forward is low-risk precisely because it repeats an
  already-validated in-repo choice.
- **CI/local enforcement mismatch for C16**: addressed explicitly in Recommendation 5 above
  rather than left implicit; the risk is a false sense that "enforced" (flag=1) means
  "CI-blocking," which it would not for the widened C16 scope without separate CI wiring.
- **Build cost of re-measuring the C16-roots figure**: this report carries the 231/16/18 figure
  rather than re-deriving it, because re-deriving it requires building all 18 roots. The plan
  phase will need to do this gathering regardless (to generate the `nolints.json` entries), so
  the cost is deferred, not avoided — flagged rather than silently absorbed into the research
  pass's own verified-figures.

## Context Extension Recommendations

- **Topic**: the generic "committed ratchet baseline + `ENFORCE_*` flag" pattern this repository
  already uses three times (`nolints.json`, `c20-declaration-baseline.txt`,
  `warning-budget.txt`) with three slightly different key shapes.
- **Gap**: `docs/development/MODULE_INVARIANTS.md`'s "Adding a Check" section documents the
  soft-then-enforced *flag* ladder well, but nowhere consolidates the three existing *baseline
  file* key shapes (declaration name; `citer|target|names` triple; `path|linter` count) and when
  each applies, which this task's own research had to re-derive from three separate script
  headers.
- **Recommendation**: after this task lands its new baseline(s), add a short section to
  `docs/development/MODULE_INVARIANTS.md` (or a new `docs/development/BASELINE_PATTERNS.md`)
  naming the three key shapes and the rule of thumb this report used to choose among them:
  prefer the existing mechanism outright when one already covers the exact surface
  (`nolints.json` for any `runLinter`-observable finding, regardless of root); otherwise key by
  whatever identity is stable across the kind of edit that legitimately shifts the finding
  (declaration name when a target declaration exists; file path alone when it does not); never
  key by a bare aggregate count.

## Appendix

### Commands run this session

```
bash scripts/readme-lint.sh                                  # exit 0; 62 STALE DATE, 4 MISSING DATE, 84 READMEs
bash scripts/check-module-invariants.sh --no-build            # exit 0; C20 tier1/tier2/decl-span block
grep -n "^\[\[lean_lib\]\]\|^\[\[lean_exe\]\]\|^name = " lakefile.toml   # 4 lean_lib + 15 lean_exe = 19 roots
grep -n "nolintsFile" .lake/packages/batteries/scripts/runLinter.lean    # confirms root-independent read
grep -n "readme-lint\|check-module-invariants" .github/workflows/ci.yml
```

### Key references

- `scripts/check-module-invariants.sh:3243-3551` — C20 (both tiers plus the declaration-span
  third assertion and its baseline-diff logic)
- `scripts/check-module-invariants.sh:3577-3733` — C16 (both halves, including the
  2026-09-21 per-root table needing refresh)
- `scripts/warning-budget.py:1-40` — the documented rationale for per-file-per-category keys
  over a bare aggregate count (C28's precedent)
- `docs/development/MODULE_INVARIANTS.md:260-320` — "Adding a Check", the soft-then-enforced
  flag ladder this task deliberately departs from (pin-and-ratchet instead of zero-then-flip)
- `.github/workflows/ci.yml:17-166` — the `lean-action`/`lint: true` step that actually enforces
  `nolints.json` for `FormalSystem` in CI, and the later `--no-build` invocation of
  `check-module-invariants.sh` that skips both C16 halves
