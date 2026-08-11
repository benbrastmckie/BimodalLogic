# Research Report: Task #439

**Task**: 439 - guard_paper_definition_drift_with_definitions_of_record
**Started**: 2026-08-10T23:40:48Z
**Completed**: 2026-08-11T00:10:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**: - Live paper source (`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`), its git history, `specs/state.json`, `FormalSystem/Semantics/{Truth,Validity}.lean`, the archived task-361 design document, and the paper-refactor cluster's re-issued task descriptions (420, 414, 415, 417, 419, 427).
**Artifacts**:
- `specs/paper-definitions-of-record.md` (deliverable 1)
- `scripts/check-paper-definitions.sh` (deliverable 2)
- `specs/state.json` (task 424 description + dependencies edited; deliverable 3)
- `specs/TODO.md` (regenerated from state.json)

## Executive Summary

- Built `specs/paper-definitions-of-record.md`: 18 tracked anchors (13 whole-environment
  definitions/theorems, 4 item-level sub-anchors for `def:frame`'s axioms, 2 `\aitem`-key
  anchors) covering everything the task named as "cover at minimum," resolved by `\label`/`\aitem`
  name, never by line number.
- Built `scripts/check-paper-definitions.sh`, a bash lint that re-derives every anchor's hash
  directly from the live paper (or an arbitrary historical commit via `--against`) and reports
  the required three-outcome contract: silent pass, notice-pass, or FAIL naming each drifted
  anchor with old/new text.
- **Verified all three outcomes against real data, not synthetic fixtures**: case (a) against the
  live paper (exit 0, silent); case (c) against commit `c3da9852` (exit 1, correctly names 6
  drifted anchors + 3 dangling-at-that-commit anchors, with old/new text for each); and case (b)
  happened *live, unprompted*, during authoring — the paper's working tree picked up an
  uncommitted edit mid-session (restructuring `lem:constraint`'s proof and adding a new
  `lem:fibers` lemma) that touched none of the 18 tracked anchors, and the script correctly
  reported the quiet-pass notice both times it was exercised.
- Found and fixed a real extraction bug during testing: an unfiltered `grep -m1` for an
  `\item[\it NAME:]` or `\aitem{NAME}` pattern can match the paper's own `%% OLD: ...` editorial
  comment (which routinely repeats the same substring) instead of the live line beneath it. Fixed
  by filtering LaTeX-comment lines (`^[ \t]*%`) out of every resolver before matching; re-verified
  against both the live paper and commit `c3da9852` afterward.
- Audited task 424 (`prove_shift_set_representation_theorem_compactness_feasibility_gate`,
  topic `strong_completeness`, outside the paper-refactor cluster): **exposure verdict YES**, but
  a different failure mode than the cluster's six — 424's governing design document is built
  directly on the current Lean `TruthAt`'s `Omega : Set (WorldHistory F)` parameter and the
  matching `Omega`-quantified `valid`/`SemanticConsequence`/`satisfiable`, which task 414
  (`refactor_semantics_to_total_history_validity`) is explicitly chartered to eliminate. Rewrote
  424's description (preserving its full original scope, gate contract, and acceptance criteria)
  and added `414` to its `dependencies` array.

## Context & Scope

Infrastructure-only task for the `paper-refactor` cluster: record the paper's current semantic
definitions verbatim with content hashes, build a lint that detects drift against that record, and
audit one task (424) that sat outside the cluster's own re-issue sweep. No definition was
restated, re-derived, or "improved"; no file under `FormalSystem/`, `latex/`, `typst/`, or
`/home/benjamin/Philosophy/Papers/` was touched; no CI wiring was attempted (verified structurally
impossible — the paper lives in a repository CI cannot see).

## Findings

### The paper moved again, live, during this task

At session start, `git log --since='3 days ago' -- possible_worlds.tex` in the paper's repo showed
20+ commits, confirming the motivating pattern. Partway through authoring deliverable 1, the
paper's working tree picked up a **sixth, uncommitted** edit (`git status --porcelain` went from
clean to `M possible_worlds.tex`, `git diff --stat HEAD` showed 32 insertions / 12 deletions,
confined to the `def:constraints`/`lem:constraint`/`lem:admissible` proof-machinery region — a
region deliberately outside this file's coverage). This is recorded transparently in the record's
"Recording provenance" / "Dirty-pin caveat" section rather than silently absorbed: the file is
pinned by **content checksum** (the byte-exact, reproducible signal), not by a claim that the
checksum matches a clean commit, because at recording time the working tree was already dirty
relative to its own git HEAD.

### Extraction method and the anchor-kind requirement

Two anchor kinds are handled, both resolved without line numbers:
- **`env`**: a `\label{X}` on the same line as `\begin{ENV}` — hash covers every line from
  `\begin{ENV}` through the next literal `\end{ENV}`.
- **`item`**: one of `def:frame`'s four axioms, which are `\item[\it NAME:]` entries with no
  `\label` of their own — the enclosing environment is resolved first, then the single matching
  item line inside it is hashed.
- **`aitem`**: an axiom introduced via the paper's `\newcommand{\aitem}[2][]{...\label{#2}}` macro
  (e.g. `\aitem{CO}`, `\aitem[CO]{TMP-CO}`) — the paper's own macro sets the *displayed* key to
  the optional first argument but the *`\label`* (hence `\aref`-resolvable anchor) to the second.
  `CO` and `TMP-CO` are two different `\label` anchors sharing the same displayed key "CO",
  included specifically because the task named this anchor kind as something the record must
  handle.

Satisfiability was explicitly investigated and found to have **no paper-native definition** — an
exhaustive `satisfiab` grep over the current paper text turned up only informal prose, never a
`\label`led clause, independently corroborated by task 417's own description ("Satisfiability has
no labeled paper definition"). Per the "record what the paper says, verbatim, and nothing more"
charter, this is recorded as an explicit gap in the record file rather than fabricated; the Lean
`satisfiable`/`SatisfiableAbs` family is noted as repository-native vocabulary, not paper-sourced.

### The comment-line extraction bug

During case-(c) testing against `c3da9852`, `def:frame#Compositionality` initially resolved to
`%% OLD: \item[\it Compositionality:] If $w \Rightarrow_x u$ and $u \Rightarrow_y v$, then
$w \Rightarrow_{x + y} v$.` — a dead comment line documenting the axiom's *previous* wording, not
its live text at that commit, because an unfiltered `grep -m1` took the first textual match in
file order and the paper's `%% OLD:` comments routinely precede their live replacement and share
the same searched-for substring. Fixed by adding a shared `filter_noncomment_keep_ln` helper that
drops any candidate line whose content (after optional whitespace) starts with `%`, applied to all
three resolvers (`env`'s label search, `env`'s end-marker search, `item`'s and `aitem`'s content
search). Re-verified against both the live paper (case a, unaffected) and `c3da9852` (case c, now
resolves the correct live axiom text — e.g. `def:frame#Seriality` now correctly shows the
one-sided-to-two-sided wording change instead of a stray comment).

### Verification performed

- `bash -n scripts/check-paper-definitions.sh` — passes.
- Script is executable (`chmod +x`, `-rwxr-xr-x`).
- Case (a): `./scripts/check-paper-definitions.sh` against the live (dirty-pinned) paper — exit 0,
  zero bytes of output (silent pass), confirmed twice (once at initial recording, once after the
  comment-filtering fix).
- Case (b): `./scripts/check-paper-definitions.sh --against eb5be99ea3f19a86c9891d7798e619890e36cd43`
  (the paper's HEAD commit, older than the dirty-pinned content) — exit 0, notice naming the new
  checksum and confirming all 18 recorded definitions unchanged. This is the same outcome the
  live mid-session drift produced organically.
- Case (c): `./scripts/check-paper-definitions.sh --against c3da9852` (the snapshot the
  paper-refactor cluster's earlier re-issue pinned, differing from current by 309 changed lines
  per the task's own note) — exit 1, correctly names 6 drifted anchors (`def:frame` and all four
  of its axiom sub-anchors, plus `def:world-history`) with full old/new text for each, and 3
  anchors that could not be resolved at that commit (`def:temporal-order`, `def:task-relation`,
  `def:directed` — genuinely did not exist as separate labels at that point in history; their
  content was folded into a monolithic `def:frame` at the time, correctly reported as missing
  rather than silently skipped).
- Full-manifest resolution: independently re-resolved all 18 manifest anchors against the live
  paper via the script's `--resolve` helper mode and diffed each against its recorded hash —
  all 18 match exactly, confirming no dangling `\label`/`\aitem`.

### Task 424 audit (deliverable 3)

Full reasoning is recorded in the rewritten task description (`specs/state.json`, project 424) —
summarized here:

- **Verdict**: exposed, but to a *different* failure mode than the paper-refactor cluster's six.
  424's design document (`specs/archive/361_.../design/02_compactness-route.md`, path corrected
  in the rewrite since task 361 archived after completion) does not quote the paper directly — it
  cites Lean source (`Truth.lean:128-137`, `Validity.lean:77-139`) and states its entire
  Representation Theorem (both directions, the sole content of this gate) directly against the
  *current* `TruthAt (M) (Omega : Set (WorldHistory F)) ...` signature, with the reverse direction
  literally setting `Ω := Omega`.
- Task 414 (`refactor_semantics_to_total_history_validity`) is explicitly chartered to "eliminate
  the Omega parameter from the semantics core" — exactly the vocabulary 424 depends on. As of this
  audit 414 has not landed, so 424's description is currently accurate to the tree, not stale; the
  risk is forward-looking.
- The underlying model-theoretic argument (two-sorted first-order axiomatizability via the atom
  clause) survives regardless of whether `Box` quantifies over an explicit `Omega` or a fixed
  `H_F` — fixing `Omega := H_F` is a special case, not a different argument. What is at risk is
  the *literal Lean statement* of both directions, which is 424's actual acceptance criterion.
- Added `414` to 424's `dependencies` (previously `[361]`, now `[361, 414]`) as a judgment call
  under this audit's authority — flagged explicitly in the rewrite as reviewable/revertable,
  not a cluster-wide policy decision.
- `specs/TODO.md` regenerated via `bash .claude/scripts/generate-todo.sh` after the `state.json`
  edit, per `.claude/rules/state-management.md`.

## Decisions

- Pinned `specs/paper-definitions-of-record.md` by **file checksum**, not commit SHA, because the
  paper's working tree was dirty at recording time (see Findings above); the commit SHA is
  recorded as best-available provenance, explicitly caveated as not matching the quoted content
  byte-for-byte.
- Scoped the manifest to exactly the task's "cover at minimum" list (18 anchors); explicitly
  excluded `def:constraints`/`lem:constraint`/`lem:admissible`/`lem:step`/`lem:fibers`,
  `def:task-topology`, `def:frame-properties`, `def:derivability`, `def:soundness`, and
  `def:time-shift-histories` as a recorded, non-accidental scope boundary (see the record's
  "Deliberately not covered" section) — not requested, and adding them would widen the
  maintenance surface without a consuming task.
- Recorded satisfiability's absence from the paper rather than fabricating a definition.
- Did not wire the lint into CI (structurally impossible, per the task's own verified constraint)
  or into a skill preflight / git hook; recorded the recommendation (skill-preflight for
  `paper-refactor`-topic tasks, not a pre-commit hook since this repo's commits never touch the
  paper file) in the record's own "Invocation from skills or hooks" section, per the task's
  explicit instruction to decide-and-record without implementing.
- Added a `--resolve` helper mode to the script beyond the three-outcome contract, to make
  extending the manifest with a new anchor practical without hand-deriving hashes.

## Risks & Mitigations

- **Whitespace-sensitive hashing**: the hash covers the literal LaTeX source including
  indentation, so a pure re-indentation (no content change) would register as drift. This is
  documented explicitly in the record's "Hashing method" section as a deliberate simplicity
  trade-off, not a bug — confirmed harmless in practice for `def:frame`'s Compositionality
  sub-anchor during the `c3da9852` test (indentation-only difference correctly flagged as drift,
  consistent with the documented contract).
- **Non-nested-environment assumption**: the `env` resolver takes the first `\end{ENV}` after the
  label line, which would mis-extract if a tracked environment ever nested another instance of
  itself. Verified false (no nesting) for all 18 current entries; documented as an explicit
  constraint in the record so a future contributor adding an anchor is warned.
- **Git history availability for `--against`/OLD-text recovery**: if the pinned commit or a
  `--against` target becomes unreachable (rewritten history), the script degrades gracefully — it
  still reports drift by hash, just without OLD text, rather than failing.

## Context Extension Recommendations

None — this is infrastructure for a specific, already-diagnosed problem (paper drift undetected
mid-dispatch) and does not surface a gap in general `.claude/context/` documentation.

## Appendix

- Paper repo root: `/home/benjamin/Philosophy/Papers/PossibleWorlds`; file:
  `JPL/possible_worlds.tex` (relative), pinned checksum
  `efe6fc74688aa5ee89b91957b3681771cdcbdfaacb6077040024c395c568cbbd`, base commit
  `eb5be99ea3f19a86c9891d7798e619890e36cd43`, 3988 lines at recording time.
- Test commit used for case (c): `c3da9852` (`c3da9852c01d295e70bcfbd0823a94f957c6a304`).
- Manifest anchor count: 18 (13 `env`, 4 `item`, 2 `aitem`).
- Key search commands: `grep -n '\\label{' possible_worlds.tex`, `grep -n '\\aitem\|\\aref{'
  possible_worlds.tex`, `git log --since='3 days ago' -- possible_worlds.tex`, `git show
  <SHA>:./possible_worlds.tex`.
