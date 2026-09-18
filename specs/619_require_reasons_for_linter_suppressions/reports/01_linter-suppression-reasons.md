# Research Report: Linter-Suppression Reason Requirement

**Task**: 619 - require_reasons_for_linter_suppressions
**Started**: 2026-09-17T00:00:00Z
**Completed**: 2026-09-17T00:00:00Z
**Effort**: Medium (one implementation round; three build trials already spent here)
**Dependencies**: None blocking. Coordinates with the Mathlib-linter-set task in the same topic (see Decisions).
**Sources/Inputs**: - Codebase (`FormalSystem/`, `Tests/`, `scripts/`), git archaeology, three empirical deletion trials via `lake build`, the compiler-warning burn-down's recorded measurement, `scripts/check-module-invariants.sh`, `docs/development/MODULE_INVARIANTS.md`
**Artifacts**: - specs/619_require_reasons_for_linter_suppressions/reports/01_linter-suppression-reasons.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The tree has 12 live `set_option linter.* false` occurrences, not 10, and SEVEN are bare, not
  six.** The seventh is `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean:50`, absent
  from the task description's list. Five are already documented (the burn-down added four of them).
- **One path in the task description is wrong**: `UntlSnceFree.lean` is at
  `…/Verified/Termination/MintBound/UntlSnceFree.lean:352`, not `…/Verified/Bridge/`.
- **Deletion trials are done and conclusive.** `RegionFrame.lean:128` hides **nothing** — git
  archaeology shows it silently retargeted onto a theorem inserted below it, and its original
  target was separately fixed with a `_ι` binder. `RegionFrame.lean:278` hides **one** warning
  (`f` unused at `RegionFrame.lean:292:19`). `UntlSnceFree.lean:352` hides one warning **and is
  load-bearing**: deleting the tactic it covers fails the build with two unsolved goals.
  `DependentUltraproductProbe.lean:50` hides **nothing**.
- **Recommended dispositions: delete four, rename-and-delete one, keep one with a reason, and
  one (`Carrier.lean:63`) needs a 3-warning `omit` fix before its blanket can go.** Net effect:
  the warning budget stays at its current zero; nothing is baselined to accommodate a deletion.
- **The next free check ID is C29** (C28 is live). A prototype of the C29 matcher was run against
  the tree and correctly classifies all 12 occurrences (5 documented / 7 bare) in 0.11s,
  build-free, with no false positives from commented-out or docstring text.

## Context & Scope

Researched: (a) the true inventory of linter suppressions in the live tree; (b) why each bare one
exists, on evidence rather than commit prose; (c) the design of a build-free invariant check that
keeps every suppression reasoned; (d) the division of labour with the sibling Mathlib-linter-set
task.

Constraint honoured throughout: `scripts/warning-budget.txt` currently records **zero** warnings
across zero files. Any disposition that surfaces a warning must fix it, never baseline it.

Constraint honoured on process: every build ran detached through
`.claude/scripts/lake-build-guard.sh`. All trial edits were reverted and verified byte-identical
by `md5sum -c`; the trace store was rebuilt afterwards and `scripts/warning-budget.py` re-reports
`0 warning(s) across 0 file(s)`. `git status --porcelain` over `FormalSystem/ Tests/ scripts/
docs/` is empty.

The lean-lsp MCP server failed to connect this session (`CONNECT_TIMEOUT`). No Mathlib search was
needed — this task is tree-local — so nothing was lost; `Read`/`Grep`/`Bash` and real builds
covered the work.

## Findings

### Codebase Patterns

#### The real inventory: 12 occurrences, 5 documented, 7 bare

| # | Site | Linter | Scope | Reason present? |
|---|------|--------|-------|-----------------|
| 1 | `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:128` | `unusedVariables` | `in` | **bare** |
| 2 | `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:278` | `unusedVariables` | `in` | **bare** |
| 3 | `…/Verified/Termination/MintBound/UntlSnceFree.lean:352` | `unusedTactic` | `in` | **bare** |
| 4 | `FormalSystem/Semantics/Ultraproduct/Carrier.lean:63` | `unusedSectionVars` | file | **bare** |
| 5 | `FormalSystem/Semantics/Ultraproduct/Los.lean:47` | `unusedSectionVars` | file | **bare** |
| 6 | `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean:60` | `unusedSectionVars` | file | **bare** |
| 7 | `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean:50` | `unusedSectionVars` | file | **bare — not in the task list** |
| 8 | `…/Verified/Termination/MintBound/Invariants.lean:797` | `unusedTactic` | `in` | yes (8-line comment; the house model) |
| 9 | `…/Verified/Termination/MintBound/TimeCensus.lean:358` | `unusedTactic` | `in` | yes (7 lines) |
| 10 | `…/Verified/Termination/SubformulaProperty.lean:1085` | `unusedTactic` | `in` | yes (9 lines) |
| 11 | `…/Verified/Termination/SubformulaProperty.lean:1127` | `unusedTactic` | `in` | yes (9 lines) |
| 12 | `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Singletons.lean:471` | `unusedSectionVars` | `in` | yes (6 lines) |

A 13th occurrence exists at
`specs/428_engine_totality_at_a_quantified_branch_budget/scratch/04_witness-preservation.lean:430`
and is correctly out of scope: it is scratch under `specs/`, not library or test code.

There are **no project-wide suppressions**: `lakefile.toml` sets only `pp.unicode.fun` and
`autoImplicit` on both libraries, and `FormalSystem/Init.lean` contains no `set_option` at all.
The 12 in-source occurrences are the whole population.

Re-verify line numbers before editing — they were checked at 2026-09-17 against a clean tree, but
the burn-down moved several of these.

#### Trial 1 — `RegionFrame.lean:128` hides nothing, and archaeology says why

Method: comment the suppression out, `lake build …Bridge.RegionFrame`. Result: module reported
**Built** (1.4s, not replayed), **zero warnings attributable to this site**.

The archaeology explains it, and it is worth recording in the commit because the failure mode is
reusable. The suppression was introduced in `6f4c7c2a0` directly above `def regionFrame`, whose
`ι` parameter had just become vestigial when the task relation went deterministic. Two later
commits dismantled it without touching it:

1. `bcb8e110b` ("Helper D and the Saturation sites") inserted the new theorem
   `regionRel_fib_subsingleton` **between** the suppression and `regionFrame`. Since
   `set_option … in` binds only the next declaration, the suppression silently **retargeted** onto
   a theorem that has no unused variable at all.
2. `e18cd2271` (the burn-down) renamed the `regionFrame` binder `ι` to `_ι` — the real in-source
   silencer — so the original target no longer needs a suppression either.

The suppression has therefore been dead since `bcb8e110b`. This is the argument for C29 in one
example: a suppression with no reason attached cannot be noticed going stale.

#### Trial 2 — `RegionFrame.lean:278` hides exactly one warning

Same method, same build. The one warning:

```
warning: FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:292:19:
Variable name `f` is not explicitly referenced.
Hint: … Alternatively, prefix the name with `_` to silence this warning:  [apply] _f
```

Line 292 is `def regionHistory (f : ι → D) (w : W) (Δ : D) : WorldHistory (regionFrame W ι D)`.
`f` genuinely does not occur in the body; the docstring already states it is retained "so that
every declaration below keeps its shape."

The tree's own recorded remedy for this class disagrees with keeping the suppression.
`scripts/warning-budget.txt` carries the disposition row:

```
# disposition linter.unusedVariables blocking rename to a `_`-prefixed binder; do not delete (arity)
```

and the sibling declaration in this very file already took that route (`regionFrame (W _ι D : Type)`).
No call site uses `regionHistory (f := …)` — checked across `FormalSystem/` and `Tests/`; every
one of the ~36 uses is positional — so `f → _f` is source-compatible.

#### Trial 3 — `UntlSnceFree.lean:352` is load-bearing, on a build failure

Removing the suppression surfaces one warning:
`UntlSnceFree.lean:404:15: 'assumption' tactic does nothing`. Line 404 is the `assumption` in the
`mem_identifyTime_time_at_trigger` alternative of the `first` chain inside
`applyRule_emitted_time_mem_of_untlSnceFree`.

A second trial replaced that `assumption` with `skip` (semantically a deletion, line-preserving).
The build **failed**:

```
error: …/UntlSnceFree.lean:389:26: unsolved goals
case h_2.inr.inr   (twice: once for Sign.pos, once for Sign.neg)
…
⊢ firstIncomparablePair b ord = some (max t₁✝ t₂✝, min t₁✝ t₂✝)
```

The mechanism is the *house model's* mechanism, not the `TimeCensus` one, and the in-source
comment should say so. `assumption` is the alternative's **failure** mechanism: it cannot prove
the *oriented* equation `some (max, min)` from the unoriented `heq✝ : … = some (t₁, t₂)` in
context, so the alternative fails and `first` falls through to the
`mem_identifyTime_time_at_trigger_oriented` twin two lines below, which closes it. Without
`assumption` the alternative succeeds vacuously, commits, and orphans the `?_` that `refine`
created — two goals, one per sign. This is exactly the pattern
`MintBound/Invariants.lean:789-796` already documents ("it is the alternative's *failure*
mechanism"), and the reason comment should cite that kinship.

#### Trial 4 — `DependentUltraproductProbe.lean:50` hides nothing

`lake build BimodalTest.Semantics.DependentUltraproductProbe` with the blanket commented out:
module reported **Built** (887ms, not replayed), **zero warnings** — only the file's intended
`#print axioms` info lines. The blanket is dead weight.

#### The Ultraproduct three — the burn-down's recorded measurement (read, not re-derived)

`specs/585_burn_down_compiler_warnings_and_add_gate/summaries/02_warning-burndown-and-c28-gate-summary.md`
("Impacts") records the measurement this task was told to read rather than repeat:

> Commenting out the three file-scoped `Ultraproduct/` suppressions and rebuilding all three
> modules — verified *Built*, not replayed — reveals **3 warnings total: `Carrier.lean` 3 (lines
> 85, 267, 271); `Los.lean` 0; `ShiftSetProduct.lean` 0.** … All three files restored
> byte-identically.

So `Los.lean:47` and `ShiftSetProduct.lean:60` are dead weight like the test probe, and
`Carrier.lean:63` is the only Ultraproduct blanket hiding anything.

### External Resources

No external sources were needed. Every in-tree source consulted:

- `scripts/check-module-invariants.sh` — C27 (lines 3429-3546) is the structural template: a
  `python3` heredoc, `scripts/lib/live_walk.py` for the Boneyard-pruning walk, a companion file
  whose entries each need a `#` reason line directly above, a masker fixture self-test that runs
  **first** and fails the check outright rather than trusting a count it cannot vouch for, and
  `ENFORCE_C27=${ENFORCE_C27:-1}`.
- `scripts/lib/lean_debug_artifacts.py` — exposes `mask(text)` (nested block comments, docstrings,
  line comments, plain and raw strings, char literals) and `self_test()`. Reusable as-is.
- `scripts/warning-budget.txt` — the per-linter disposition rows are the tree's own prescribed
  remedy per warning class, and two of them decide dispositions here.
- `scripts/nolints.json` — grandfathers `unusedArguments` for `regionFrame`, `regionHistory` and
  `regionRel_fib_subsingleton` (lines 834-843). Relevant to the rename; see Risks.
- `docs/development/MODULE_INVARIANTS.md` — 3-column table `| ID | Check | Why it exists |`, one
  long prose row per check (C28's row at line 40 is the model for length and tone).
- `docs/development/LEAN_STYLE_GUIDE.md:807-830` — "Suppressing Linters", which already states the
  in-source-reason-at-the-site principle for `nolint` attributes but says nothing about
  `set_option linter.*`.
- `.github/workflows/ci.yml:98-102` — CI runs the harness as `--no-build`, which is why C29 must
  be textual.

### Recommendations

#### Dispositions (work items 1-3)

| Site | Evidence | Disposition |
|------|----------|-------------|
| `RegionFrame.lean:128` | Trial 1: 0 warnings; retargeted by `bcb8e110b`, original target fixed by `_ι` in `e18cd2271` | **Delete.** No source change beyond the line. |
| `RegionFrame.lean:278` | Trial 2: 1 warning, `f` at `:292:19` | **Rename `f` → `_f` in `def regionHistory` and delete the suppression.** Lean's own printed hint, the `warning-budget.txt` disposition row for this class, and the sibling `regionFrame (W _ι D : Type)` all prescribe it; no named-argument call site exists. *Fallback if the rename is rejected on API grounds:* keep the suppression with a comment naming the `:292:19` warning verbatim and why `_f` was refused — never a bare keep. |
| `UntlSnceFree.lean:352` | Trial 3: build fails, 2 unsolved goals at `:389:26` | **Keep, with an in-source comment** naming the two goals the deletion trial left unsolved and the fall-through-to-`_oriented` mechanism, citing `MintBound/Invariants.lean` as the same pattern. |
| `Carrier.lean:63` | Burn-down: 3 warnings (lines 85, 267, 271) | **Fix the three, then delete the blanket.** The `unusedSectionVars` disposition row prescribes "fix per declaration with the `omit [...] in` form Lean prints". One trial build of `FormalSystem.Semantics.Ultraproduct.Carrier` is needed to read the current line numbers and the exact `omit` text Lean prints — the recorded numbers predate nothing, but the fix text is only obtainable from the build. |
| `Los.lean:47` | Burn-down: 0 | **Delete.** |
| `ShiftSetProduct.lean:60` | Burn-down: 0 | **Delete.** |
| `DependentUltraproductProbe.lean:50` | Trial 4: 0 warnings | **Delete.** Seventh bare suppression; in scope for the reason requirement even though absent from the task's list. |

Net budget effect: zero warnings added anywhere. `scripts/warning-budget.txt` needs no edit.

#### The C29 check (work item 4)

**ID: C29.** C26, C27 and C28 are all live and enforced; C28 is the current highest. Verified by
enumerating every `C<n>` token in `scripts/check-module-invariants.sh`.

**Shape**, following C27 verbatim where it applies:

1. **Scope**: live `.lean` under `FormalSystem/`, `Tests/` **and** `scripts/` via
   `live_walk.live_files` (588 files today; `scripts/` holds one `.lean` and no suppressions, but
   including it costs nothing and closes the gap in advance). `Tests/` must be in scope — that is
   where the seventh bare suppression lives. This is a deliberate departure from C27, which
   excludes `Tests/` because probes *belong* there; a suppression does not belong anywhere
   unreasoned.
2. **Match**, on **masked** text (`lean_debug_artifacts.mask`):
   `^\s*set_option\s+(linter\.[A-Za-z0-9_.']+)\s+false\b`. Masking is what stops a commented-out
   or docstring occurrence counting — verified live: a `-- TRIAL set_option linter…` line during
   the trials was correctly ignored by the prototype.
3. **Reason rule**: from the match line, walk upward past any contiguous stacked
   `set_option … in` lines (`UntlSnceFree.lean:351` is `set_option maxHeartbeats 4000000 in`,
   directly above its suppression — a naive "line immediately above" rule gets this one wrong),
   then require the first remaining line to begin a contiguous block of `--` line comments with
   non-blank content.
4. **Recommended strengthening — the comment must name the linter.** All five currently
   documented suppressions already satisfy it (verified by the prototype: `names_linter=True` on
   every one). It is what stops `-- see above` passing, and it is free.
5. **Anti-silence guard**: if the scan matches **zero** suppressions anywhere, exit **2** with a
   distinct message. Per C28's precedent, exit 2 is an error in **every** mode and is **not**
   suppressed by `ENFORCE_C29=0`: a measurement the harness cannot trust is never a pass. Run
   `lean_debug_artifacts.self_test()` first and fail outright on a masker regression, exactly as
   C27 does, plus a small C29-specific fixture set (bare / documented / stacked-`set_option` /
   commented-out / docstring-mention) so a broken matcher fails rather than quietly passing.
6. **Build-free**: pure source text, so it runs identically with and without `--no-build`. Do not
   add it to the `--no-build` skip list.
7. **Enforced from the outset** (`ENFORCE_C29=${ENFORCE_C29:-1}`), on the C24/C25/C26/C27
   precedent — the tree is at zero bare once the dispositions above land.
8. **Performance**: pre-filter on `'linter.' in text` before masking. Measured: 2.07s without the
   pre-filter, **0.11s** with it (only 11 of 588 files need masking), and the pre-filter is exact
   for this pattern because every match contains the literal `linter.`.

**No companion allowlist.** The task description offers "a companion allowlist with a reason
column" as an alternative, and it should be declined: the house model named in the task itself
(`MintBound/Invariants.lean`) puts the reason *at the suppression site*, which is where a reader
meets the suppression and where it goes stale together with the code it covers. C27's allowlist
exists because a debug directive has no natural place to carry prose; a `set_option … in` line
always does. Adding a second file would create the exact drift C29 exists to prevent. There is no
shape in the tree today that a site comment cannot serve.

**Negative test** (the acceptance criterion): inject
`set_option linter.unusedTactic false in` above some declaration with no comment above it, confirm
`FAIL C29` naming the file and line and a non-zero script exit — both, not just the printed line,
per the C25 precedent recorded at `scripts/check-module-invariants.sh:3044-3045` — then revert.
Test the anti-silence guard separately by pointing the scan at an empty walk and confirming
**exit 2**.

**Prototype result** (run this session, tree clean): 12 occurrences found, 5 classified documented,
7 classified bare — matching the hand audit exactly, no false positives, no false negatives.

#### `MODULE_INVARIANTS.md` row (work item 5)

Add a `| C29 (enforced) | … | … |` row after C28's, in the existing 3-column table. The "Why it
exists" column should carry the `RegionFrame.lean:128` story as its evidence: a suppression
introduced for one declaration, silently retargeted onto another by an unrelated insertion, and
left dead for the lifetime of two further commits with every gate green. Also update the check
list in the script header (lines 55-79) and, if no allowlist ships, leave the "Companion files"
block (lines 92-104) untouched.

#### Documentation follow-on (not in the task's five items)

`docs/development/LEAN_STYLE_GUIDE.md:807-830` shows `set_option linter.unusedVariables false in`
as an example with no reason comment — the exact shape C29 will reject. Update that snippet in
the same change, or the style guide will be teaching the violation.

## Decisions

- **`Tests/` is in scope, and the seventh bare suppression is dispositioned here.** The task
  description lists six; the tree has seven. Excluding the test one would leave C29 either failing
  on day one or scoped to `FormalSystem/` only, and a `Tests/` blind spot in a
  "zero bare suppressions in the tree" invariant is not defensible.
- **Prefer the `_`-prefix rename over retaining `RegionFrame.lean:278`.** The tree's own recorded
  disposition for `linter.unusedVariables` prescribes it, the sibling declaration in the same file
  already uses it, and no call site is affected. This is reversible if the API objection is
  raised; the fallback is stated above.
- **No companion allowlist file.** Reasons live at the site. Rationale above.
- **Division of labour with the Mathlib-linter-set task (currently `[NOT STARTED]`).** That task
  owns converting file-scoped blankets to `in`-scoped form and the shape ratchet; it does not
  require reasons. Since it has not run, the Ultraproduct three are still file-scoped. This task
  does **not** convert them — it **deletes** three of the four blankets outright (`Los`,
  `ShiftSetProduct`, `DependentUltraproductProbe`, all measured at zero hidden warnings) and, for
  `Carrier`, fixes the three warnings and deletes the fourth. Deleting a suppression is neither a
  scoping conversion nor a reason addition; it removes the object of both tasks. The sibling task
  should be told its item (4) drops from 4 blankets to 0 and that its ratchet needs its own
  anti-silence guard as a result — or, better, that it fold the shape ratchet into C29 rather than
  adding a C30, since both read the same matched set.
- **`UntlSnceFree.lean:352`'s reason cites the `Invariants.lean` mechanism, not the
  `TimeCensus.lean` one.** The trial distinguishes them: here the tactic is the alternative's
  failure mechanism (fall-through to the `_oriented` twin), not a closer for a goal `refine` left
  open. Getting this wrong would put a plausible but false explanation in the source.

## Risks & Mitigations

- **`nolints.json` staleness after the `f → _f` rename.** `scripts/nolints.json:838-841`
  grandfathers `unusedArguments` for `regionHistory` (and for `regionFrame` and
  `regionRel_fib_subsingleton`). Mathlib's `unusedArguments` ignores `_`-prefixed binders, so the
  `regionHistory` entry may become stale. *Mitigation*: after the rename, run
  `lake exe runLinter FormalSystem` (or the full harness with C16) and drop the entry if it is
  reported stale, in the same commit. Do not add entries.
- **C16 is already red from the burn-down** — that task's summary records seven ungrandfathered
  `unusedArguments` findings it introduced, deliberately not absorbed into `nolints.json`. *Risk*:
  an implementer reads a red C16 as caused by this task. *Mitigation*: capture the C16 state
  **before** any edit and compare, rather than assuming.
- **Trace-store races.** C28 reads Lake's trace store, which a concurrent `lake build` rewrites;
  a half-written store yields a spurious `FAIL C28`. Other agents are active in this repository.
  *Mitigation*: always build through `.claude/scripts/lake-build-guard.sh` (its lake args start
  with the subcommand — `-- build …`, **not** `-- lake build …`, which the guard rejects with
  exit 77), and re-run C28 after a build completes before investigating a failure.
- **Deleting a suppression invalidates downstream oleans.** `RegionFrame.lean` sits under
  `Bridge/`; editing it re-elaborates its dependents. *Mitigation*: detached, guarded builds only;
  budget for a long full `lake build` at the end.
- **A `set_option … in` chain above a suppression.** `UntlSnceFree.lean:351` is a
  `maxHeartbeats` line. A "comment immediately above" rule that does not skip stacked
  `set_option`s will misclassify any suppression that later acquires one. *Mitigation*: the
  upward-walk rule in the design above; include a stacked fixture in the self-test.
- **Line-number drift.** Every line number in this report was verified on a clean tree at
  2026-09-17 and the burn-down moved several of these files. *Mitigation*: re-grep before editing
  (`grep -rn "set_option linter\." --include="*.lean" FormalSystem Tests`).

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task adds no proof obligation; the only
  tactic-level question — whether the `assumption` at `UntlSnceFree.lean:404` is dead — was
  answered by an empirical deletion trial rather than a tactic search, and the answer is recorded
  under Trial 3.

## Context Extension Recommendations

- **Topic**: the `set_option … in` retargeting failure mode.
- **Gap**: nothing in `.claude/context/project/lean4/` or `docs/development/LEAN_STYLE_GUIDE.md`
  warns that inserting a declaration below a `set_option … in` line silently moves the option onto
  the new declaration. It happened here, survived two commits, and was invisible to every gate.
- **Recommendation**: add a short note to `docs/development/LEAN_STYLE_GUIDE.md`'s "Suppressing
  Linters" section (which also needs its reasonless example fixed — see Recommendations), and
  update its `set_option linter.unusedVariables false in` snippet to carry a reason comment so the
  guide stops modelling what C29 rejects.

## Appendix

### Commands and trials run

```
grep -rn "set_option linter\." --include="*.lean" .        # inventory: 13 hits, 12 live
git log --follow --oneline -S "set_option linter.unusedVariables false in" -- …/RegionFrame.lean
git show bcb8e110b -- …/RegionFrame.lean                   # the retargeting insertion
git log --oneline -S "def regionFrame (W _ι D : Type)" --all -- …  # e18cd2271, the `_ι` fix

# Trials 1+2 (one build), 3, 4 — all detached, all through the guard:
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build \
  FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionFrame \
  FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.UntlSnceFree
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build \
  BimodalTest.Semantics.DependentUltraproductProbe

# Restoration verified:
md5sum -c … && git status --porcelain -- FormalSystem/ Tests/ scripts/ docs/   # empty
python3 scripts/warning-budget.py   # OK -- 0 warning(s) across 0 file(s)
```

### Trial outcomes, verbatim

| Trial | Command result | Warnings surfaced |
|-------|----------------|-------------------|
| 1+2 (`RegionFrame` suppressions removed) | `⚠ Built …Bridge.RegionFrame (1.4s)` | 1: `RegionFrame.lean:292:19: Variable name \`f\` is not explicitly referenced` |
| 1+2 (`UntlSnceFree` suppression removed) | `⚠ Built …MintBound.UntlSnceFree (16s)`, `Build completed successfully` | 1: `UntlSnceFree.lean:404:15: 'assumption' tactic does nothing` |
| 3 (`assumption` at `:404` → `skip`) | `✖ Building …UntlSnceFree`, `error: build failed` | `error: …:389:26: unsolved goals` × 2 (`case h_2.inr.inr`, `Sign.pos` and `Sign.neg`) |
| 4 (`DependentUltraproductProbe` blanket removed) | `ℹ Built BimodalTest.Semantics.DependentUltraproductProbe (887ms)` | 0 |

### References

- `scripts/check-module-invariants.sh:3429-3546` — C27, the structural template
- `scripts/check-module-invariants.sh:3557-3610` — C28, the anti-silence / exit-2 precedent
- `scripts/lib/lean_debug_artifacts.py` — `mask()` and `self_test()`
- `scripts/lib/live_walk.py` — `live_files()`
- `scripts/warning-budget.txt` — per-linter disposition rows (the prescribed remedies)
- `scripts/nolints.json:834-843` — the `regionFrame` / `regionHistory` / `regionRel_fib_subsingleton` entries
- `docs/development/MODULE_INVARIANTS.md:35-40` — the table rows C29's must match
- `docs/development/LEAN_STYLE_GUIDE.md:807-830` — "Suppressing Linters"
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Invariants.lean:789-796` — the house model comment
- `specs/585_burn_down_compiler_warnings_and_add_gate/summaries/02_warning-burndown-and-c28-gate-summary.md` — the recorded Ultraproduct measurement
