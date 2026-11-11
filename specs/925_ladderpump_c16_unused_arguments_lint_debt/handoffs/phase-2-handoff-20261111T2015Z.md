# Phase 2 Handoff — Task 925 (dispatch_seq 21)

- **Phase**: 2 of 3, "Both LadderPump dispositions, under the net-zero line budget"
- **Outcome**: `[BLOCKED]` — Edit A escalated; Edit B verified then reverted
- **Tree state**: `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` is
  byte-identical to `f7b64854b`. No Lean source committed or left dirty by this phase.
- **Gates**: `bash scripts/check-module-invariants.sh --no-build` exits **0**, identical to
  Phase 1's close (C26 at 15 pairs + the one expected stale INFO for the dangling allowlist key).

## Immediate next action

Get a user decision on the single question in the BLOCKER block of the plan's Phase 2, then
apply **both** edits in one atomic commit with `A_new = B_new = 5`. Do not apply either edit
alone.

## The blocker, in one paragraph

Phase 2's own pre-edit gate requires "zero term-level applications" of
`exists_idleSpliced_ladderPath` before its `[Fintype Q]`/`[Nonempty Q]` binders may be deleted,
and names that consumer set as "what licenses the removal". The live sweep returns one:
`FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean:1294`,
`obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ := exists_idleSpliced_ladderPath g₁ hg₁ α k hk hidle₁ hrep₁`,
introduced by `a94510cf3` ("task 918 phase 3.6") after this plan was authored. The plan's
prescribed remedy for exactly this case is "stop and treat the removal half as `[BLOCKED]`",
and `plan-compliance.md` bars annotating-and-proceeding on a `.lean` file, so the call was
escalated rather than overridden.

**The merits, stated plainly for the decider**: the two binders are *instance-implicit*. They
are supplied by synthesis, never positionally. The call site passes exactly the seven explicit
arguments the signature declares (`g hg a l hl hidle hrep`), so removing the two instance
binders moves no positional slot and generalizes the statement — the plan's own Edit A
rationale says precisely this. The gate's wording, not its purpose, is what the new call site
trips.

## Verified-ready specification for Edit B (re-apply verbatim next dispatch)

Edit B was fully applied and verified green before being reverted. Its content is settled:

Replace `LadderPump.lean` lines 1862-1866 with **5** lines (not 4 — see budget below) whose
opening token is the literal option name, then keep line 1867
(`set_option linter.unusedVariables false in`) untouched, then insert
`@[nolint unusedArguments]` on its own line between the docstring's closing `-/` (1872) and
`theorem exists_idleTypeBlock_of_budget_le_run` (1873).

Two corrections learned empirically, which cost a gate round-trip each:

1. **C29 requires the literal option name.** A draft comment saying "the source linter" instead
   of `` `linter.unusedVariables` `` failed:
   `FAIL C29 1 reason comment(s) never name the linter being suppressed` /
   `LadderPump.lean:1866: comment above does not mention `linter.unusedVariables``.
   Keep `` `linter.unusedVariables` `` as the comment's opening token, as the pre-existing
   comment does.
2. **Comment lines must stay ≤ 100 characters** to match house style in this file (the widest
   existing line in the region is 99).

## The budget is two-dimensional — the plan's arithmetic captures only one axis

The root `README.md` generated inventory block counts `Live lines of code` and `Live comment
lines` **separately**, and gate `INV` fails if either drifts:

| Edit | comment lines | code lines | total |
|------|---------------|------------|-------|
| A (delete 5-line comment + `set_option`, add 5-line comment) | 0 | **−1** | −1 |
| B (rewrite 5-line comment to 5, add attribute) | 0 | **+1** | +1 |
| **Both together** | **0** | **0** | **0** |

So the plan as written is correct and complete. The failure mode is *withholding one half*:
with Edit A blocked, holding the 1931 total forces `B_new = 4`, which gives comment −1 / code
+1 — total still 1931, but `FAIL INV 1 file(s) carry a stale generated inventory block
(README.md)`, a third file the plan requires untouched. That is the unbalanced intermediate
state `Commit Mode: atomic-batch` exists to forbid, which is why Edit B was reverted rather
than committed alone.

**Do not** absorb a drift by editing `README.md`, `RaySummary/README.md`, or
`typst/generated/status.typ`.

## Evidence obtained while Edit B was applied

- Guarded full `lake build`: guard exit **0**, `Build completed successfully (2974 jobs)`, zero
  `error:` lines; `.olean` newer than source confirmed for `LadderPump`, `LadderIdle`,
  `LadderWindow`.
- Guarded `lake exe runLinter FormalSystem`: exit 1 with **exactly one** `unusedArguments`
  finding —
  `LadderPump.lean:1825:1: @...exists_idleSpliced_ladderPath 2 unused arguments: argument 2:
  [Fintype Q], argument 3: [Nonempty Q]`.
  The `exists_idleTypeBlock_of_budget_le_run` finding was gone. **C16 goes green exactly when
  Edit A lands, and on nothing else.**
- `check-module-invariants.sh --no-build`: C26 went from 15 pairs + 1 stale INFO to **16 pairs
  + 0 stale INFO**, proving Phase 1's allowlist key and the as-written declaration name agree.

## Carried figures re-derived this dispatch

| Figure | Plan/description said | Live |
|--------|----------------------|------|
| `LadderPump.lean` line count | 1931 | **1931** (confirmed) |
| Edit A region | comment 1819-1823, `set_option` 1824, signature 1830 | **confirmed exact** |
| Edit B region | comment 1862-1866, `set_option` 1867, `-/` 1872, signature 1873 | **confirmed exact** |
| `exists_idleSpliced_ladderPath` consumers | 4 docstrings at `LadderWindow:181,425`, `LadderIdle:19,75`; zero term-level | 4 docstrings at **`LadderWindow:223,467`**, `LadderIdle:19,75`, **plus one term-level at `LadderWindow:1294`** |
| `hg` pass-through citation | `LadderWindow.lean:472` decl, `:486` pass-through | **confirmed exact** |
| Allowlist `^unusedArguments:` keys | 7 after Phase 1 | **7** (file 136 lines) |
| Task 918 status | "in task 918's `file_scope` this cycle" | **complete** (`51faa61b9`) — not live territory |
| C16 findings | "two unusedArguments findings on the two named declarations" | **confirmed**: two flagged declarations; one declaration carries 2 unused args |

## Territory observations

- Foreign uncommitted modifications present throughout, all disjoint from this task's files and
  all predating this dispatch: `specs/893_.../issues.jsonl`, `specs/events.jsonl`, untracked
  `.pid`, `specs/893_.../stale-dispatch-2-plan-report.md`, `specs/evidence/history-morphism-saturation-audit/`.
  Not touched.
- A foreign `git stash` entry `stash@{0}` (`git-snapshot-894-...`) exists; a `stash push`/`pop`
  probe was correctly refused by `guard-destructive-git.sh` and was **not** retried or
  overridden. The entry is intact.
- One running `lake shake Distsys.Trace.Interface` process belongs to a different project on
  toolchain v4.31.0 (this repo pins v4.33.0-rc1); not this repo, not started here.
