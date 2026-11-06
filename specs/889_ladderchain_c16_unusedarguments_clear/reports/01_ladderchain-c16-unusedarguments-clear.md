# Research Report: Task #889

**Task**: 889 - Clear the live C16 (env_linter) gate failure so `scripts/check-module-invariants.sh` exits 0 again
**Started**: 2026-11-05T17:10:00Z
**Completed**: 2026-11-05T17:40:00Z
**Effort**: ~0.5 hours
**Dependencies**: None
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`, `scripts/nolints.json`, `scripts/check-module-invariants.sh`), live `lake exe runLinter FormalSystem` run, git history of `scripts/nolints.json`, prior-task plans and challenge manifests under `specs/`, lean-lsp MCP (degraded: symbol index `warming`)
**Artifacts**: - specs/889_ladderchain_c16_unusedarguments_clear/reports/01_ladderchain-c16-unusedarguments-clear.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The finding is live and reproduces exactly as described.** A guarded
  `lake exe runLinter FormalSystem` run exits 1 with `Found 1 error in 18103 declarations`:
  `@FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_shift_of_hasForwardSlack 1 unused
  argument: argument 23: (hslk : n + … ≤ c)` at `LadderChain.lean:2136:1`. The `FormalSystem/` tree
  is clean; the declaration's `.olean` is current.
- **Root cause**: `LadderChain.lean:2135` already carries
  `set_option linter.unusedVariables false in`, which silences only Lean's **frontend**
  `unusedVariables` linter. C16's finding comes from Batteries' **`@[env_linter] unusedArguments`**,
  a declaration linter that reads the compiled environment and is unaffected by that `set_option`.
  One of the two linters was silenced and the other was missed.
- **DECISION: exempt via one hand-inserted row in `scripts/nolints.json`.** Removal of `hslk` is
  **not available**: `mem_cellAt_of_shift_of_hasForwardSlack` is a **pinned Challenge statement**
  (`specs/849_forward_slack_discharge_and_exact_shift_iteration/challenge/manifest.json`, and that
  plan's `## Lean Challenge Statements` block pins `hslk` verbatim). Dropping the binder is exactly
  the same-name-different-signature drift `plan-compliance.md`'s Statement Fidelity section
  forbids.
- The repair also requires **extending the existing reason comment** at `LadderChain.lean:2132-2134`
  so it names the environment linter and the ledger row, not only `linter.unusedVariables`. The
  frontend `set_option` stays: `hslk` is still an unused binder at the frontend too.
- `lake exe runLinter --update` is **not** run, per the dispatch and per the `nolints.json`
  burndown record: it rewrites the whole ledger in a different serialization rather than adding
  one row.

## Context & Scope

Researched: which of three dispositions for the unused `hslk` binder on
`mem_cellAt_of_shift_of_hasForwardSlack` the repository's own conventions and constraints admit —
signature removal, proof-level consumption, or a hand-inserted `scripts/nolints.json` row — and
what the concrete repair looks like.

Out of scope: the 227 pre-existing `unusedArguments` rows already in `scripts/nolints.json`
(a separate burndown), and the second, reporting-only half of C16 behind `ENFORCE_C16_ROOTS`.

Constraint carried from the dispatch and honoured: `lake exe runLinter --update` was never run.

Evidence tier note: lean-lsp was reachable but its symbol index reported `index: warming`, so one
declaration-existence check degraded to a grep sweep. Every claim below rests on file reads, grep,
git history, or the live `runLinter` run — none on an empty LSP result.

## Findings

### Codebase Patterns

**The declaration (`LadderChain.lean:2132-2173`).** The body is a two-line term that forwards to
`mem_cellAt_of_shift_of_hasForwardSlack_exact`, passing `hgap`, `hTc`, and
`hasForwardSlack_mono g z hslack (Nat.le_add_right _ _)`. `hslk` appears nowhere in the term, and
nowhere in the statement's conclusion. It is genuinely dead, exactly as the linter reports.

**Why the existing suppression misses it.** Lines 2132-2135 read:

```
-- `linter.unusedVariables`: the statement is kept verbatim; `hslk` (the gap `n + budget² ≤ c`)
-- is slack the `_exact` form does not need once the regime amount is `m · (P + 1)`, so it is
-- not read.
set_option linter.unusedVariables false in
```

`linter.unusedVariables` is the frontend elaborator linter. C16 runs
`lake exe runLinter FormalSystem`, whose `unusedArguments` check is a Batteries
`@[env_linter]` (`.lake/packages/batteries/Batteries/Tactic/Lint/Basic.lean`) operating on the
compiled environment. No `set_option linter.*` reaches it. The two are independent, and the
reason comment names only the first.

**The signature is pinned.** `specs/849_.../challenge/manifest.json` lists
`mem_cellAt_of_shift_of_hasForwardSlack` among its seven `theorem_names`, and that plan's
`## Lean Challenge Statements` block (line 702ff) carries the full header with
`(hslk : n + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (…) ≤ c)` in place. The landed
declaration matches it. A later task (`specs/850_.../plans/01_…`, Phase 6) then rewrote the *body*
to a corollary of the `_exact` form while recording "the STATEMENT is not touched" as an explicit
verification criterion, with before/after header diffs required empty.

**No Lean consumers.** `grep -rn` across `FormalSystem/`, `Tests/` and `typst/` finds the name only
in docstrings and prose (`LadderChain.lean:66`, `:569`, `LadderAgree.lean:2789`,
`RaySummary/README.md:991`). Nothing applies it. Its reason for existing is the pinned statement
itself.

**`scripts/nolints.json` format and precedent.** A flat JSON array of 2-element arrays
`["unusedArguments", "<fully.qualified.Name>"]`, currently 227 rows, all of linter
`unusedArguments`. Its git history is pure hand-insertion — recent commits add 4, 8, 4, 8 and 16
lines (1-4 rows each), never a wholesale reserialization. The most recent, `e379d42c6`, is titled
*"record the four pinned-signature unusedArguments rows dropped as a file_scope excursion"*: the
same class as this finding, resolved the same way.

**The competing in-source route.** `fa50d3909` ("task 539 phase 7") migrated the repo's single
`structureInType` exemption out of `nolints.json` into an in-source
`@[nolint structureInType]` carrying a reason comment (`FormalSystem/Automation/ProofSearch/Core.lean:225`),
as part of a burndown that reduced the ledger 307 → 217 and left it carrying `unusedArguments`
alone. That burndown deliberately did **not** migrate the `unusedArguments` category; every
`unusedArguments` exemption added since (tasks 746, 794, 761, 836) went into the ledger.

**No other consumer of the ledger.** `grep` over `scripts/*.sh` and `scripts/lib/*.sh` finds
`nolints.json` referenced only by `check-module-invariants.sh`. Nothing diffs its length against a
baseline, so adding a row breaks no second check. Note the script's own header comments
(lines 633 and 3443) still say "217 findings" against a live 227 — already stale by ten, from the
hand-additions above.

### External Resources

- Batteries `Batteries/Tactic/Lint/Basic.lean:168-191` — defines the `@[nolint linterName]`
  parametric attribute and `shouldBeLinted`. The `runLinter` output itself advertises this route:
  *"This linter can be disabled with `@[nolint unusedArguments]`."*
- Mathlib/Batteries `unusedArguments` semantics: an argument is reported when it occurs in neither
  the declaration's type nor its value, which matches the hand reading of the term above.

### Recommendations

**Recommended repair** (sorry-free; it touches no proof and no statement):

1. Append one row to `scripts/nolints.json`, in the file's existing format, after the final entry:

   ```json
     [
       "unusedArguments",
       "FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_shift_of_hasForwardSlack"
     ]
   ```

   Hand-edit only. Do **not** run `lake exe runLinter --update`.

2. Extend the reason comment at `LadderChain.lean:2132-2134` so it names **both** linters and
   points at the ledger row — the current text names only `linter.unusedVariables`, which is
   precisely the gap that let this finding reach the gate. Keep the
   `set_option linter.unusedVariables false in` line: `hslk` remains an unused binder at the
   frontend, so removing it reintroduces a build warning.

3. Verify: `lake exe runLinter FormalSystem` exits 0 (`Found 0 errors`), then
   `bash scripts/check-module-invariants.sh` exits 0 with `PASS C16`. Both through
   `lake-build-guard.sh`. No rebuild of `LadderChain.lean` is required for step 1; step 2 touches a
   comment only, so a scoped guarded build of
   `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` is the covering check.

Zero-sorry impact: none. No proof term, statement, or axiom profile changes.

## Decisions

**DECISION: exempt `mem_cellAt_of_shift_of_hasForwardSlack` by a hand-inserted
`scripts/nolints.json` row, and repair the reason comment at the declaration site.**

Grounds, on the merits: the binder is dead but the signature is pinned, so the only honest
dispositions are "exempt" or "repin", and repinning is a larger change than the finding warrants.
Among the two exemption mechanisms the repo actually uses, the ledger is where all 227 of this
linter's exemptions already live; routing the 228th in-source would split a single linter's
exemption inventory across two mechanisms and make "how many `unusedArguments` exemptions does this
repo carry" unanswerable from one place. The locality objection — that a ledger row carries no
reason — is answered by step 2, which puts the reason at the declaration where a reader of the
code will find it.

### Rejected: remove `hslk` from the signature

On its own merits this is the cleanest outcome: `hslk` is unread, the theorem has no Lean
consumers, and dropping a hypothesis *strengthens* the statement, so no downstream claim could lose
force. It would also retire the `set_option` suppression and its comment, shrinking the C29
suppression inventory by one, and it resolves the finding rather than grandfathering it — the
direction the `nolints.json` burndown set.

It is rejected because the signature is a pinned Challenge statement in
`specs/849_.../challenge/manifest.json`, with `hslk` written out verbatim in that plan's
`## Lean Challenge Statements` block, and a successor plan re-asserted "the STATEMENT is not
touched" with an empty-header-diff verification criterion. `plan-compliance.md`'s Statement
Fidelity section makes a pinned declaration's *signature*, not only its identifier, part of the
contract; a same-named declaration with a different header is the drift that section exists to
catch, and the sanctioned response to "the pinned statement itself looks wrong" is to escalate,
never to quietly change the implementation or the pin. Repinning is a deliberate decision about
two completed tasks' records, not a lint repair, and is out of this task's scope.

### Rejected: consume `hslk` in the proof

No honest consumption exists. The only hypothesis `hslk` could discharge is `hgap : n + 2 ≤ c`:
the closure is nonempty (`self_mem_plusSubformulaClosure`, used at
`RaySummary/Closure.lean:101`) and `Q` is `Nonempty` + `Fintype`, so the budget is at least 2 and
`budget² ≥ 4 ≥ 2`, making `hslk → hgap` derivable. Routing the `_exact` call's gap argument through
`hslk` therefore does not remove an unused binder — it merely moves the deadness onto `hgap`, and
the linter reports argument 20 instead of 23. Any remaining route (a `have := hslk` before the
term, or threading `hslk` through a transitivity step that needs nothing from it) manufactures an
occurrence without a need: it defeats the linter's detection rather than answering its finding, and
leaves a reader of the proof with a step that cannot be justified.

### Rejected: in-source `@[nolint unusedArguments]`

Mechanically valid and verified available: a probe file importing
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` and declaring
`@[nolint unusedArguments] theorem probe_nolint …` elaborated with exit 0, so the attribute is in
this module's import scope. It has in-repo precedent (`@[nolint structureInType]` at
`ProofSearch/Core.lean:225`), it is what `runLinter`'s own output suggests, and it places the
exemption directly above the reason comment that already explains it — the C29 house style of
evidence at the site.

It is rejected on inventory coherence, stated above: `unusedArguments` is the one category the 539
burndown deliberately left in the ledger, and every exemption of it added since has gone there. It
remains the right mechanism if a future burndown migrates the whole category in-source, and should
be reached for then rather than for a single row now.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| The repair is mistaken for grandfathering a genuine regression | The row names a declaration whose unused binder is *required* by a pinned Challenge statement, and the reason comment at the site says so. The alternative — removing the binder — is recorded above with its merits, not silently dropped. |
| A future `lake exe runLinter --update` reserializes the ledger and buries the row | Out of this task's control, but the prohibition is already recorded in three places (this report, the dispatch, `specs/archive/539_…/plans/01_linter-debt-burndown.md:41`). Worth restating in the implementation commit message. |
| Editing `scripts/nolints.json` collides with a concurrent sibling | Sibling scopes this cycle are `TranslationProduct.lean`, three `Semantics`/`Conservativity` files, and one undeclared-scope task. Re-read `scripts/nolints.json` immediately before editing and stage only that file plus `LadderChain.lean` by explicit path. |
| Touching `LadderChain.lean` for a comment triggers a long rebuild | The file's `.olean` is current and the edit is comment-only, so the scoped guarded build is the covering check; budget for one scoped build regardless, since the module is large. |
| The script's stale "217 findings" header comments drift further | Advisory only — no check reads them. The implementation may update both occurrences (lines 633, 3443) to 228 in the same commit, or leave them; neither affects the gate. |

## Tactic Survey Results

- Not applicable (no tactic survey performed). The repair touches no proof term and no goal state;
  the whole task is a linter-exemption disposition.

## Context Extension Recommendations

- **Topic**: frontend `set_option linter.*` suppressions versus Batteries `@[env_linter]` findings
- **Gap**: `.claude/context/project/lean4/` documents the blocked MCP tools and the build-guard
  contract, but nothing records that `set_option linter.unusedVariables false` does not suppress
  C16's `unusedArguments`. This single confusion produced a finding that blocked the repo-wide gate
  for every Lean task across at least nine tasks' handoffs.
- **Recommendation**: add a short subsection to
  `.claude/context/project/lean4/` (alongside the existing linter guidance) stating the two-linter
  distinction, the matching remedies (`set_option … in` for the frontend; a `nolints.json` row or
  `@[nolint …]` for the environment linter), and the standing prohibition on
  `lake exe runLinter --update`. A C29-adjacent mechanical check — "a reason comment naming
  `linter.unusedVariables` on a declaration that also has unused *arguments* must say which
  mechanism covers the env linter" — is a possible follow-on, not proposed here.

## Appendix

### Commands run

```
timeout 560 bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- exe runLinter FormalSystem
git status --short FormalSystem/ scripts/
git log -1 --oneline -- FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean
git log --oneline -- scripts/nolints.json          (+ per-commit --stat)
git show fa50d3909 -- FormalSystem/Automation/ProofSearch/Core.lean
grep -rn "mem_cellAt_of_shift_of_hasForwardSlack" --include=*.lean .
grep -rn "@\[nolint" --include=*.lean FormalSystem/ Tests/
grep -rn "nolints.json" scripts/*.sh scripts/lib/*.sh
python3 -c "<count and group scripts/nolints.json rows by linter>"
lake env lean <scratchpad>/NolintProbe.lean      # @[nolint unusedArguments] availability probe
```

The probe in the last line elaborated a single scratch file against cached `.olean`s; it built no
project target. Every project build in this dispatch went through `lake-build-guard.sh`.

### Live gate transcript (excerpt)

```
Running linter on specified modules: [FormalSystem]
-- Found 1 error in 18103 declarations (plus 27885 automatically generated ones) in FormalSystem with 14 linters

/- The `unusedArguments` linter reports:
UNUSED ARGUMENTS.
This linter can be disabled with `@[nolint unusedArguments]`. -/
-- FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
…/LadderChain.lean:2136:1: error: @FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_shift_of_hasForwardSlack 1 unused argument:
  argument 23: (hslk : n + Fintype.card Q * 2 ^ (…plusSubformulaClosure φ).card * (…) ≤ c)
lake-build-guard: STATUS: exit_status=1
```

### References

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2132-2173`
- `scripts/check-module-invariants.sh:631-642, 3437-3545` (C16, both halves)
- `scripts/nolints.json` (227 rows, all `unusedArguments`)
- `.lake/packages/batteries/Batteries/Tactic/Lint/Basic.lean:168-191` (`@[nolint]`)
- `specs/849_forward_slack_discharge_and_exact_shift_iteration/challenge/manifest.json`
  and that task's `plans/01_forward-slack-exact-shift.md:702ff`
- `specs/850_upfirst_exact_shift_copy_boundary_types/plans/01_upfirst-exact-shift-copy-boundary.md:586-650`
- `specs/archive/539_linter_debt_burndown_nolints_dupnamespace/plans/01_linter-debt-burndown.md`
- `.claude/rules/plan-compliance.md` (Statement Fidelity)
