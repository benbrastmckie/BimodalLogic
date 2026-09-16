# Sweep Evidence Report: Task #583

**Task**: 583 — Wire the six uncalled repository check scripts into CI
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence.
**Effort**: Medium. Mechanically small; the judgment is per-script — what "red" should mean for each.
**Dependencies**: Soft. Three scripts are red today (tasks 581, 582, 586 fix them). CI wiring can land first with those steps non-blocking, or after, gating from day one. That sequencing is part of this task's decision.
**Sources/Inputs**:
- `.github/workflows/ci.yml` (65 lines), `.github/workflows/docs.yml.disabled`
- `scripts/check-*.sh`, `scripts/readme-lint.sh`, `scripts/typst-sync-check.sh`
- `specs/reviews/review-2026-09-16.md`, Finding H3 (the headline finding of that sweep)

## Executive Summary

- **This is the root cause of three other sweep findings.** The `Metalogic/` second import cycle
  (task 582) went 99 commits undetected; four evidence probes left version control entirely
  (task 581); a typst chapter has documented archived code as live since 2026-09-07 (task 586).
  All three are caught by scripts that already exist and run correctly — and that CI never
  executes.
- **`check-module-invariants.sh` — 26 checks, ~3,300 lines, the phase gate every architecture
  document in this repository cites — appears in `ci.yml` only inside a comment** (line 48, in
  the rationale for the `lean_exe` step). Nothing runs it.
- **Five more standalone checks are referenced nowhere outside their own file and the docs that
  describe them**: `check-copyright-headers.sh`, `check-metalogic-cycles.sh`,
  `check-evidence-probes.sh`, `check-paper-definitions.sh`, `readme-lint.sh`,
  `typst-sync-check.sh`.
- **Runtime is not the obstacle.** Measured on this machine, the structural pass and all four
  fast checks together are under a minute.

## What CI runs today

`.github/workflows/ci.yml`, in full outline:

| Step | What it does |
|---|---|
| `actions/checkout@v4` | — |
| `leanprover/lean-action@v1` | `build: true`, `test: true`, `lint: true` (Batteries `env_linter` against `scripts/nolints.json`), `use-mathlib-cache: true` |
| "Compile `lean_exe` roots" | scrapes `root :=` from `lakefile.lean`, `lake build` each — added because the exe roots sit outside both library closures and `proof_extractor` was broken for an extended period with CI green throughout |
| "Report results" | echoes the three statuses |

The `lean_exe` step is the template to follow: it already demonstrates the pattern of a
repository-specific check reusing the cache `lean-action` populated, and its comment explains
precisely the class of problem this task generalizes — *"CI green throughout, because no step
here could observe it."*

## Measured runtimes (local, warm Lake cache)

| Script | Runtime | Exit today | Needs a Lean build? |
|---|---|---|---|
| `check-module-invariants.sh --no-build` | 20s | 0 | No |
| `check-module-invariants.sh` (full) | minutes | 0 | Yes — C1/C2/C6/C16/C24/C25 |
| `check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem` | 13s | 0 | No |
| `check-metalogic-cycles.sh` | <1s | **1** | No |
| `readme-lint.sh` | 7s | 0 | No |
| `typst-sync-check.sh` | 15s | **1** | No |
| `check-evidence-probes.sh` | ~1min | **1** | Yes — `lake env lean` per probe |
| `check-paper-definitions.sh` | ~1s | **1** | No, but see below |

## Per-script wiring decisions

This is where the judgment is. The scripts are not interchangeable and a uniform "add six steps"
would be wrong for at least two of them.

### Straightforward — gate them

- **`check-module-invariants.sh`** (full, not `--no-build`). It is the phase gate; it should run
  after `lean-action` so the Lake cache is warm. Its build-dependent half (C1/C2/C6/C16/C24/C25)
  is exactly what CI should be asserting. Note it internally re-runs `lake build` — confirm this
  reuses rather than rebuilds under the action's cache before accepting the runtime.
- **`check-metalogic-cycles.sh`** — <1s, no build, currently red. Gate it once task 582 lands.
- **`readme-lint.sh`** — 7s, green.
- **`check-copyright-headers.sh`** — 13s. Must be invoked in its *strict live-set* form
  (`--strict --exclude '*/Boneyard/*' FormalSystem`); the bare invocation exits 0 unconditionally
  and reports 154 "missing" because it counts the deliberately unheadered archive. The sweep
  verified the strict form is 520/520 green today.
- **`typst-sync-check.sh`** — 15s, currently red. Gate it once task 586 lands.

### Needs a decision — `check-paper-definitions.sh`

This one reads `$PAPER_TEX`, which defaults to a file in a *different* repository on the author's
machine (`~/Philosophy/Papers/.../possible_words.tex`). CI cannot see it. Wiring it naively makes
every CI run fail on a missing file.

Options: make it skip-and-report-neutral when the paper is absent (probably right — its value is
as a local pre-dispatch check); or commit a checksum-only mode that verifies the *record* file's
internal consistency without the paper; or leave it out of CI entirely and instead document it as
a required local step, which is the status quo and is what let 16 definitions drift unnoticed.
Recommend the first.

### Needs a decision — `check-evidence-probes.sh`

Runs `lake env lean` per probe, so it needs the Lean toolchain and a warm cache — fine after
`lean-action`. The question is whether a rotted probe should *fail* CI or *report*. The script's
header argues strongly for fail: a probe that has quietly stopped compiling "is no longer an
obstacle to anyone, so a future change can undo the very decision it records." Recommend gating,
after task 581 turns it green.

## Secondary observation, worth folding in

`.github/workflows/docs.yml.disabled` is disabled for a well-documented reason (docgen-action
hard-requires `lakefile.toml`; this project uses `lakefile.lean`). That file's header already
records the two paths to re-enabling. Not part of this task, but the same CI pass is the natural
moment to confirm the decision still stands — and `README.md`'s documentation section already
tells readers the published API site is not rebuilt on push.

## Recommended approach

1. Add the four currently-green checks as separate `ci.yml` steps first, so the workflow starts
   enforcing something immediately and each step's failure is individually legible.
2. Resolve `check-paper-definitions.sh`'s absent-paper behaviour in the script, then add it.
3. Add `check-metalogic-cycles.sh`, `typst-sync-check.sh` and `check-evidence-probes.sh` as their
   respective repair tasks (582, 586, 581) land — or add them immediately with
   `continue-on-error: true` and remove that flag per script as each goes green. The second
   option is preferable: it makes the red visible on every run instead of waiting.
4. Give each step a `::group::` block and a name that says which script it is, matching the
   existing `lean_exe` step's style.

## Verification

- A CI run on a branch with a deliberately introduced violation of each wired check fails, and
  the failing step names the script.
- A clean run is green end to end.
- Total CI wall-clock increase is measured and recorded in the PR description.
- `docs/development/MODULE_INVARIANTS.md` and `.github/workflows/ci.yml`'s comments agree about
  what is enforced where — the comment on line 48 that currently *describes* the local script
  should become a reference to the step that now runs it.
