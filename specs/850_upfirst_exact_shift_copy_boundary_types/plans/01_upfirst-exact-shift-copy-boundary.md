# Implementation Plan: Task #850

- **Task**: 850 - Re-derive the iterated splice in LadderChain.lean with copy-boundary realized types exposed, then restate the exact-shift theorem under the clean up-first hypotheses, dropping the budget-squared slack penalty the landed deletions-first ordering pays
- **Status**: [COMPLETED]
- **Effort**: 11.5 hours (Phases 1-7 at 1.5 / 1.5 / 2 / 1.5 / 2 / 1.5 / 1.5)
- **Dependencies**: None at the `state.json` level. Predecessor record: `specs/849_forward_slack_discharge_and_exact_shift_iteration/` (its landed baseline is consumed; its seven Challenge-pinned statements keep their text)
- **Research Inputs**: `specs/850_upfirst_exact_shift_copy_boundary_types/reports/01_upfirst-exact-shift-copy-boundary.md`, with its compiled prototype `specs/850_upfirst_exact_shift_copy_boundary_types/prototype/upfirst-helpers-compiled.lean` (855 lines, fully proved, exit 0 with zero diagnostics against the built library)
- **Artifacts**: plans/01_upfirst-exact-shift-copy-boundary.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research closed the whole question with a compiled object: the up-first ordering (raise by
`budget` copies of the original pigeonhole block with the register held, run the landed overshoot
loop ABOVE the run of copies, then delete the exact remainder as one block of the run) proves the
exact-shift theorem under exactly `HasForwardSlack g z (m · (P + 1)) (nxtAt g z)` and the gap
`nxtAt g z + m · (P + 1) ≤ cntAt g z`, and its cell-level consumer under exactly `n + 2 ≤ c`,
`Tc ≤ c` and `HasForwardSlack g z (m · (P + 1)) n` -- no `budget²` term in either anchor
direction. The device that makes it possible is the re-derived iterated duplication, which exposes
the walk and the realized stab-free types at EVERY position through one index map
`iterSpliceIdx u l d` (copy boundaries `u + i · l` retract to `u`, the run's top to `u + l`,
everything above by `-d · l`). This plan lands the prototype's seven pieces in `LadderChain.lean`
in the prototype's own order, re-baselines the long-file linter in place, keeps the two landed
849-pinned theorems as verbatim-statement corollaries, and brings the module's record (docstrings,
README) to the new state. Definition of done: the six pinned declarations under
`## Lean Challenge Statements` landed with no `sorry`; the two landed theorems' headers diff empty
against their 849 Challenge; the full gate green; the reserved name `cellLE_zero_const_of_kappa_eq`
still claimed by nothing.

Facts fixed at authoring time, re-derived in source (not carried):

- **Placement and file budget.** `LadderChain.lean` is 1,780 lines under
  `set_option linter.style.longFile 1800` (L66); `LadderPump.lean` is 1,485 with no baseline and is
  not edited. Every new declaration goes into `LadderChain.lean`. The research measures the net
  growth at about +400 lines (sections IterIdx 85, Raise 60, Iterate 91, AssemblyIdx 130, the
  up-first theorem 216, the clean cell inclusion about 40, minus about 70 for the landed wrapper
  and the two landed theorems shrinking to corollaries and about 165 of landed step/loop text that
  is replaced rather than added), landing near 2,200. **Decision: re-baseline in place, never
  split.** `docs/development/LEAN_STYLE_GUIDE.md` ("The long-file baseline") rules "Long files
  are baselined, not split: splitting a file only to satisfy this linter is not a justification
  for the split", `MODULE_INVARIANTS.md` C30 excepts exactly this baseline, acceptance (a) names
  the file, and the new material is the bridge's own exact-shift layer with no content-level seam.
  The alternative (a new `LadderExact.lean` importing `LadderChain`) would either move the two
  849-pinned theorems across modules or leave their now-redundant proofs in place, add a README
  row, and meet acceptance (a) only in spirit; it is recorded here and rejected.
- **The linter's actual rule** (Mathlib `Mathlib/Tactic/Linter/Style.lean`, `longFileLinter`,
  re-read at authoring): with `lastLine` the file's length and
  `candidate := (lastLine / 100) * 100 + 200`, the option value `N` is accepted only when
  `lastLine ≤ N` and `N ∈ {candidate - 100, candidate}`. Any other value warns, and the gate
  requires zero warnings. So the baseline moves MORE THAN ONCE during this plan: **every phase that
  changes the file's length re-derives `wc -l` after its edit and, if the current `N` is no longer
  accepted, sets `N := candidate`** (the linter's own suggestion). Expected trajectory from the
  research's section sizes: 1800 -> 2100 (Phase 1, about 1,925 lines) -> 2200 (Phase 3, about
  2,050) -> 2400 (Phase 5, about 2,270) -> 2300 or 2400 after Phase 6 (about 2,200). The final
  value is measured in Phase 6, never predicted. This is the decision the task asked to be made
  at plan time; it is not to be discovered mid-phase.
- **The six pinned statements elaborate.** The block under `## Lean Challenge Statements` was
  elaborated standalone against the built library at authoring (`lake env lean` through the build
  guard, `sorry` bodies; result recorded in that section). Every pinned statement is verbatim
  from the prototype, whose BODIES compiled during research, with the section-variable binders
  (`{Q : Type}`, `[Finite Q]`/`[Fintype Q]`, `[Nonempty Q]`, `{step}`, `{pend}`) written out
  explicitly, as `lean-challenge-snapshot.sh --check` compares header text and a header that
  relies on a section `variable` reads as drift.
- **The landed loop's hypothesis change is in place, not a parallel variant.**
  `exists_deleted_ladderPath_step_of_pend_past` and
  `exists_deleted_ladderPath_overshoot_of_pend_past` are not Challenge-pinned, have exactly one
  consumer each inside the module (grep at authoring: the step is consumed by the loop; the loop by
  the landed exact theorem; no reference outside `LadderChain.lean`), and consume `hwb`/`hroom`
  only to derive the sampling window. Replacing those two hypotheses by the window itself
  (`hwin`) costs about zero lines; `_win` twins would cost about 170. The prototype's `_win_`
  names exist only to coexist with the library in one namespace and are NOT the wired names.
- **Axiom baseline.** The task's "14-axiom baseline" is the predecessor's summary figure
  [CARRIED-UNVERIFIED: `specs/849_forward_slack_discharge_and_exact_shift_iteration/summaries/01_forward-slack-exact-shift-summary.md`
  L58, "Axiom count: 14", measurement not named there]. Measured at authoring by two named
  commands: `grep -rn "^axiom " FormalSystem --include=*.lean | wc -l` = 10, and
  `bash scripts/typst-status-counts.sh --json | jq .axiom_count` = 20 (the figure
  `typst/generated/status.typ` carries). Phase 7's gate is "both named measurements unchanged
  before and after, and `lean_verify` on every new declaration reports a subset of
  `[propext, Classical.choice, Quot.sound]`" -- nothing in this plan declares an `axiom`.

### Research Integration

- The seven prototype sections are landed in their prototype order (index map -> slack-raise
  transport -> iteration -> wrapper -> window-generalized loop -> up-first exact theorem and clean
  cell inclusion -> landed statements as corollaries), with the proofs copied from the prototype
  and only the section context, binders and docstrings adjusted.
- The research's ordering decision is adopted: raise by `d := budget` copies and loop to target
  `R := m · q` (so the remainder `r := R + b - t` is always in `[1, b]` and no `m = 0`/`r = 0`
  case split arises), exposure as ONE index-map clause with characterization lemmas rather than a
  list of boundary clauses, landed statements kept verbatim as 3-line corollaries by
  `hasForwardSlack_mono` + `omega`.
- The three `omega` cast-form rules measured by the research are carried into every Lean phase:
  (i) `generalize hbq : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card = b at … ⊢` before
  `omega` on any goal mixing the budget product with `l` -- never `push_cast` on such a goal;
  (ii) a hand-written `ℤ` bound on a `ℕ` product is stated as `((… : ℕ) : ℤ)`, never with the
  coercion at the leaves; (iii) the loop's base case needs `b ≥ 1`, which comes from `hlb : l ≤ b`
  and `hl : 0 < l` -- keep `hlb` on the loop even though the step drops it.
- The research's context-extension recommendation (a pattern note on `omega` with the budget
  product under `context/project/lean4/`) is a `.claude/` source-store change outside this
  lean4 task; it is a Non-Goal here and is left for the task record's follow-up channel.

### Prior Plan Reference

No prior plan for this task. The predecessor's plan
(`specs/849_forward_slack_discharge_and_exact_shift_iteration/plans/01_forward-slack-exact-shift.md`,
eight phases, 13 hours, all `[COMPLETED]`) is referenced for conventions kept here: every Lean
phase builds scoped, runs `bash scripts/typst-sync-check.sh --fix`, and commits
`typst/generated/status.typ` with the `.lean` file; pinned headers are copied character-for-
character with explicit binders; a refactored theorem's statement fidelity is verified by a
before/after header diff; the Challenge `--check` is advisory and its exit 71 from a `specs/**`
prototype is answered by a header diff. Its effort calibration (1-2 hours per 40-130 lines of
proof text whose body already compiled in a prototype) is reused and is what sets the 11.5-hour
total; the one phase it reported as over-budget was the loop's bookkeeping, which this plan does
not re-derive (the loop keeps its landed proof under a changed hypothesis).

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch; `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

- **Goals**:
  - `iterSpliceIdx` -- the iterated splice index map (the retraction of d splices of the block on
    positions), with its characterization lemmas (zero, succ, below the block, above the run, the
    block offset form, the copy boundary, the run's top, membership in the run) (Phase 1).
  - `hasForwardSlack_raise` -- forward slack transports across a raise by d copies, increased by
    exactly d times the block length; the mirror of the landed deletion transport (Phase 1).
  - `exists_iterSpliced_ladderPath_idx_of_pend_past` -- the re-derived iterated duplication: the
    walk, the countdown before the block and above the run, and the realized stab-free type at
    EVERY position, read through the index map; acceptance (a) (Phase 2).
  - `exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` -- the register-held iterated
    duplication of a given block with the same full exposure (Phase 3).
  - `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` -- the exact-shift theorem under
    the gap at exactly m times (P + 1) and the regime at exactly m times (P + 1); acceptance (b)
    (Phase 5).
  - `mem_cellAt_of_shift_of_hasForwardSlack_exact` -- the downward cell inclusion on the witnessing
    path under exactly n + 2 at most c, Tc at most c, and the regime at m times (P + 1);
    acceptance (b) (Phase 6).
  - Not pinned, named deliverables: the landed step and loop restated with the sampling window
    as the hypothesis (Phase 4); the landed register-held wrapper, the landed exact-shift theorem
    and the landed cell inclusion re-derived as corollaries with their statements verbatim
    (Phases 3 and 6; acceptance (c)); the module's record (Phase 7; acceptance (e)).
- **Non-Goals**:
  - Any statement under the reserved name `cellLE_zero_const_of_kappa_eq`, and any cell-level
    statement quantified over the STATE rather than the witnessing path. The path-versus-state
    quantification gap is the open core the RaySummary README names; it is not touched.
  - Re-litigating that `HasForwardSlack` is a regime (the compiled `ClimbWitness.climb` refutes the
    unconditional claim), that spacing `P + 1` is unusable for the pigeonhole, or that `(K1)` does
    not constrain a spanning block's length.
  - Any edit to `LadderPump.lean`, `LadderPin.lean`, `RunLayer.lean`, or `LadderAgree.lean`
    (`LadderAgree.lean:2199-2203` names the two landed theorems by name only and stays correct).
  - Strengthening the landed `exists_iterSpliced_ladderPath_of_pend_past` in `LadderPump.lean`
    (at 1,485 of 1,500 lines; the direction of import fixes the placement here).
  - Any edit to `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (its pins at L1752-1756
    name `exists_ladderPath_through_shifted_of_pend_past` and
    `cellAt_subset_of_shift_of_pend_past`, neither of which this plan edits).
  - A pattern note under `.claude/context/project/lean4/` on `omega` with the budget product (a
    source-store change; recommended by the research, out of this task's type).
  - Editing the research prototype under `specs/**` to silence the Challenge checker's
    exit-71 ambiguity; the prototype is a research record.

### Decisions

- **Sections, in file order.** `section IterIdx` (the index map and its lemmas) is a new section
  directly after `end Assembly` (L642) and before `section AssemblyFin` (L644), under a
  `/-! ## The iterated splice index map -/` header; `section Iterate` (the `_idx` duplication,
  `[Finite Q]`) directly after it; the `_idx` wrapper joins `section AssemblyFin` immediately
  before the landed wrapper, which becomes its corollary; `hasForwardSlack_raise` joins
  `section Slack` directly after `hasForwardSlack_del` and before `hasForwardSlack_of_idle_above`;
  the up-first exact theorem and the clean cell inclusion join `section DelNxtIter` directly after
  the loop and before the landed exact theorem, which (with the landed cell inclusion) becomes a
  corollary in place.
- **The index map is pinned as its definition text, not as a `sorry`.** `iterSpliceIdx` is a
  three-line pattern-matching definition with no top-level `:=`; `lean-challenge-snapshot.sh`
  appends such a chunk unchanged (it forces `sorry` only where a top-level `:=` exists), and
  `--check` compares the whole chunk. The implementer copies the definition character-for-
  character from the Challenge block, so the pinned and the wired text are identical.
- **Pinned headers are copied character-for-character, including their explicit binders**, as in
  the predecessor's plan: the Iterate/AssemblyIdx statements carry `{Q : Type} [Finite Q]
  [Nonempty Q]` explicitly (the prototype relies on section variables; the `Finite` binder with
  `Fintype.ofFinite` inside the proof is what the `unusedFintypeInType` linter demands, as the
  predecessor's Phase 4 found); `hasForwardSlack_raise` carries `{Q : Type} {step : Q → Q → Bool}
  {pend : Q → Bool}` explicitly, like the pinned `hasForwardSlack_del`. Shadowing a section
  variable with an explicit binder is permitted and harmless.
- **The landed step drops `hlb`; the landed loop keeps it.** Exactly as the prototype: the step
  never reads `l ≤ b` once the window is a hypothesis; the loop's base case needs `b ≥ 1` from it.
- **Statement fidelity of the three landed declarations that change body** (the register-held
  wrapper, the exact theorem, the cell inclusion) is verified twice: by a before/after header diff
  extracted with `sed` inside the editing phase, and in Phase 7 by a whitespace-normalized header
  diff of the two 849-pinned theorems against `git show cd052276c1d1734ac8d94f8fc5ee8d7c2c9932db:Challenge.lean`
  (the 849 manifest's commit). The regime-A assembly is not touched at all.
- **The `unusedVariables` linter on the verbatim cell corollary**: the pinned statement carries
  `hslk`, which the corollary does not read; it is silenced with the scoped
  `set_option linter.unusedVariables false in` immediately preceded by a `--` comment naming the
  linter and the reason (C29 form, as the prototype writes it). Nothing else needs a suppression.
- **Challenge snapshot timing.** The snapshot (`bash .claude/scripts/lean-challenge-snapshot.sh 850 .`)
  is taken at plan time by the planning dispatch, immediately after this file is written and the
  block below has elaborated, because the status gate refuses it once the task is `implementing`
  (exit 73). It overwrites the root `Challenge.lean` (whose 849 content stays retrievable at the
  849 manifest's commit) and commits `task 850: snapshot lean challenge statements`; the manifest
  lands at `specs/850_upfirst_exact_shift_copy_boundary_types/challenge/manifest.json`.
  `--check 850` is expected to exit 71 (advisory: the research prototype under `specs/` declares
  every pinned name a second time); drift is then verified by header diff against
  `git show <manifest.commit>:Challenge.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `omega` cast-form mismatches recur when the prototype's proofs are re-typed in the library (the research lost four build rounds to exactly three forms) | M | H | Copy the prototype's working forms verbatim; apply the three rules under Research Integration; keep the budget product as one atom via `generalize … at … ⊢` |
| The long-file linter warns mid-plan because `N` falls outside `{candidate - 100, candidate}` after an edit | M | H | Every Lean phase re-derives `wc -l` after its edit and sets `N := (lines / 100) * 100 + 200` when the current value is no longer accepted (rule under Overview); the 0-warnings gate is run scoped in every phase |
| A same-named weaker statement slips in under a pinned name, or a landed pinned statement drifts when its body is replaced | H | L | Six headers elaborated standalone at authoring and snapshotted at plan time; before/after `sed` header diffs in Phases 3 and 6; Phase 7's normalized header diff of all thirteen pinned names (six of 850, seven of 849) against the two Challenge commits |
| The `_idx` wrapper's 115-line register rebuild does not transplant cleanly from the landed wrapper (different exposure clauses feed `hpend_all` and the above-run `objAt`) | M | L | The prototype's `AssemblyIdx` section carries the complete working rebuild (L265-394); copy it, do not re-derive; the only two changed derivations are named in Phase 3 |
| Replacing `hwb`/`hroom` by `hwin` in place breaks the landed exact theorem's call site before that theorem is itself replaced | M | M | Phase 4 patches the landed call site in the same phase with a 10-line derivation of `hwin` from `hul`, `hlb`, `budget_mul_succ_le_Tc` and `hTc` (the arithmetic the step's old `hroom'` did); the module is green at the end of every phase |
| `typst-sync-check.sh --fix` needs a built library and the pre-commit gate refuses a `.lean` commit without a fresh `status.typ` | M | H | Every phase builds before committing, runs `bash scripts/typst-sync-check.sh --fix`, and names `typst/generated/status.typ` in its pathspec |
| The Challenge checker exits 71 (ambiguity from `specs/**` prototypes) and is misread as a failure | L | H | Recorded here as expected and advisory; Phase 7 performs the header diff fallback and records the outcome in the summary |
| Eleven prose sites assert the deletions-first ordering or the `budget²` term and one is missed | M | M | Phase 7 opens with the grep listed in its Scope Hypothesis; the same grep must return only the new wording after |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. The chain is deliberately linear: Phase 4 is
logically independent of Phases 2-3, but every phase edits `LadderChain.lean`, so the phases are
serialized on file territory rather than run concurrently. Phase 7 is the final phase: a terminal
node that depends transitively on every other phase.

**Build command used throughout** (scoped; raise the Bash tool `timeout` to `600000`):

```bash
timeout 590 bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
```

Green means exit 0 with ZERO warnings (the long-file linter and `unusedVariables` both warn, and
the landed baseline is 0 warnings).

**Commit discipline used throughout**: after the scoped build is green, run
`bash scripts/typst-sync-check.sh --fix` (it needs the built library) and include
`typst/generated/status.typ` in the commit pathspec alongside the `.lean` file; a commit touching
`FormalSystem/**/*.lean` without it is refused by `.githooks/pre-commit`.

**Long-file baseline step used throughout** (after every edit that changes the file's length):
`wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`; with `lines` the result and
`candidate := (lines / 100) * 100 + 200`, if the current `set_option linter.style.longFile N` at L66
has `N < lines` or `N ∉ {candidate - 100, candidate}`, set `N := candidate`. Record each change in
the phase's notes.

**Budget abbreviation used throughout**: `b` stands for
`Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card`, written out in full in every statement (the
module defines no abbreviation for it, and the pinned statements write it out).

**Prototype line references** are to
`specs/850_upfirst_exact_shift_copy_boundary_types/prototype/upfirst-helpers-compiled.lean`
(namespace `Probe850`); library line references are to the file at authoring (1,780 lines) and
drift as phases land -- re-derive by `grep -n` before editing.

---

### Phase 1: The index map and the slack-raise transport [COMPLETED]

**Goal**: The retraction `iterSpliceIdx u l d` exists in the library with the eight lemmas that
read it (below the block, above the run, the offset form, the copy boundary, the run's top,
membership), and forward slack is known to transport across a raise increased by exactly the
raised amount -- the two ingredients every later phase consumes.

**Tasks**:
- [x] Re-derive `wc -l` on `LadderChain.lean` and the current baseline at L66 (expected 1,780 / 1800).
- [x] Insert a new `section IterIdx` directly after `end Assembly` and before `section AssemblyFin`,
  opened by a `/-! ## The iterated splice index map -/` header that says what the retraction is
  (identity below `u + l`; `u + ((v - u) mod l)` inside the run of `d + 1` copies; `v - d · l`
  above the run) and why it is defined by iterating `spliceIdx` (one application of the
  duplication type lemma per step). Copy from the prototype's `section IterIdx` (L20-104):
  `def iterSpliceIdx` CHARACTER-FOR-CHARACTER as the Challenge block below writes it (the
  pattern-matching form, no `:=`), `@[simp] theorem iterSpliceIdx_zero`, `iterSpliceIdx_succ`
  (both `rfl`), `iterSpliceIdx_of_lt`, `iterSpliceIdx_of_ge`, `iterSpliceIdx_add_mul`,
  `iterSpliceIdx_boundary`, `iterSpliceIdx_top`, `iterSpliceIdx_mem`, each with its prototype
  docstring. The proofs are `induction d generalizing v` with `rw [spliceIdx_of_lt/ge]` and
  `omega` / `push_cast; ring`, using `Int.natCast_nonneg` for the sign of `↑(d * l)`.
- [x] Insert `hasForwardSlack_raise` into `section Slack`, directly after `hasForwardSlack_del`
  and before `hasForwardSlack_of_idle_above`, with the header exactly as the Challenge block
  writes it (explicit `{Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}`), the prototype's
  docstring ("the mirror of `hasForwardSlack_del`; only two exposure clauses of the raise are
  consumed: the countdown at `z` and the walk above the run"), and the prototype's proof
  (L119-166): `intro I hI hidle hnext`; `hczZ` and `e` by `push_cast; ring`; `hab` (every position
  above `z`'s raised region sits above the run); `hpull` reading `objAt g'` off `habove`; the two
  `cntAt_eq_nxtAt_of_idle_pend` applications; `Nat.cast_sub` on `I - 1`; close by `omega`.
- [x] Long-file baseline step (expected: 1,925 lines, `N := 2100`). *(measured: 1,931 lines; `N := 2100`)*
- [x] `lean_verify` on `hasForwardSlack_raise` (expected `[propext, Quot.sound]` or a subset) and on
  `iterSpliceIdx_mem`; scoped build green with zero warnings; `--fix`; commit
  (`task 850 phase 1: the index map and the slack-raise transport`).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: One definition and nine lemmas, about 145 lines in total (prototype
sections IterIdx 85 and Raise 60, measured by the research), no new imports, the baseline
re-set once. Confirm by `wc -l` before and after (delta about +145) and by
`grep -c "^theorem iterSpliceIdx\|^def iterSpliceIdx\|^theorem hasForwardSlack_raise" FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`
returning 10 (the `@[simp]`-attributed `iterSpliceIdx_zero` sits on the line after its attribute
and is counted by that grep only if the attribute is on the same line -- read the output, do not
trust the number blindly).

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` with zero warnings is the complete
covering check -- every declaration added here is new, consumed by nothing yet, and lives in the
one module built.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - new `section IterIdx`; `hasForwardSlack_raise` in `section Slack`; the `longFile` baseline at L66
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0 with zero warnings (the long-file linter accepts the new `N`).
- `lean_verify` on `hasForwardSlack_raise` and `iterSpliceIdx_mem`: no `sorry`, axioms a subset of `[propext, Classical.choice, Quot.sound]`.
- The definition text of `iterSpliceIdx` in the file equals the Challenge block's text
  (`diff <(sed -n '/^def iterSpliceIdx/,/spliceIdx u l v)$/p' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean) <(sed -n '/^def iterSpliceIdx/,/spliceIdx u l v)$/p' Challenge.lean)` is empty).

---

### Phase 2: The iterated duplication read through the index map [COMPLETED]

**Goal**: Acceptance (a): an iteration lemma in `LadderChain.lean` exposes the walk, the countdown
and the realized stab-free type at EVERY position through `iterSpliceIdx u l d` -- in particular
the original's `(objAt, tpOf)` at `u` at every copy boundary `u + i · l` for `i ≤ d`
(`iterSpliceIdx_boundary`), at `u + l` at the run's top `u + (d + 1) · l` (`iterSpliceIdx_top`),
and the original's displaced by `-d · l` above the run (`iterSpliceIdx_of_ge`).

**Tasks**:
- [x] Insert a new `section Iterate` directly after `end IterIdx` (before `section AssemblyFin`)
  with `variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}` and
  `exists_iterSpliced_ladderPath_idx_of_pend_past`, header exactly as the Challenge block writes
  it, docstring from the prototype (L174-184: "every one of the landed iteration's clauses is a
  reading of this one through the characterization lemmas of `iterSpliceIdx`").
- [x] Proof, copied from the prototype (L209-260): `classical; haveI : Fintype Q := Fintype.ofFinite Q;
  induction d with`. Base case: `g` itself with `rfl`/`simp` clauses and the type clause by
  `tpOf_stabFree_eq_of_objAt_eq` at `k := 0, k' := 0`. Step case: from the inductive hypothesis
  `⟨g₁, hg₁, hobj₁, hcnt₁, habove₁, hty₁⟩` derive `hidx_ul`/`hty_ul` (the original's object and
  type at the retraction of `u + l` are those at `u`, by `rcases d` and `iterSpliceIdx_boundary`
  at `i := 1`), `hpast₁`, `hrep₁`, `hcu₁`, `hcl₁`; splice once with
  `exists_spliced_ladderPath_of_pend_past`; read the new walk through `spliceObj_eq_objAt_spliceIdx`;
  the four conclusion clauses by `iterSpliceIdx_succ`, `spliceCnt_add_of_mem_region`,
  `spliceCnt_of_ge` (with the `(d + 1 + 1) * l` cast identity `e`), and
  `tpOf_eq_spliceIdx_of_tpOf_eq` composed with `hty₁` through a history `σ₁` of `g₁`.
- [x] Long-file baseline step (expected: about 2,016 lines; `N = 2100` still accepted since *(measured: 2,025 lines; `N = 2100` kept)*
  `candidate = 2200` and `2100 = candidate - 100`).
- [x] `lean_verify`; scoped build green with zero warnings; `--fix`; commit
  (`task 850 phase 2: the iterated duplication read through the index map`).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: One theorem of about 91 lines (prototype section Iterate, measured by the
research); the `[Finite Q]` binder is required (the predecessor's Phase 4 note: `[Fintype Q]` in
the type with `Fintype` used only inside the proof trips `unusedFintypeInType`). Confirm by the
zero-warnings build and `wc -l` delta.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` with zero warnings covers the edit
completely -- the theorem is new and consumed by nothing yet.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - new `section Iterate`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0 with zero warnings.
- `lean_verify` on `exists_iterSpliced_ladderPath_idx_of_pend_past`: no `sorry`, axioms a subset of `[propext, Classical.choice, Quot.sound]`.
- Header text equals the Challenge block's (whitespace-normalized diff empty).

---

### Phase 3: The register-held wrapper with full exposure; the landed wrapper as its corollary [COMPLETED]

**Goal**: The register-held iterated duplication of a GIVEN block exposes the walk and the types
at every position through the index map and the countdown above the run, so Phase 5 can raise the
original block of a path and still read `(objAt, tpOf)` at every copy boundary; the landed wrapper
`exists_ladderPath_through_iterSpliced_nxt_of_pend_past` keeps its statement verbatim and becomes
a short corollary.

**Tasks**:
- [x] Before the edit, save the landed wrapper's header:
  `sed -n '/^theorem exists_ladderPath_through_iterSpliced_nxt_of_pend_past/,/:= by$/p' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean > <scratchpad>/wrapper-header-before.txt`
  (absolute scratchpad path).
- [x] Insert `exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` into `section AssemblyFin` *(deviation: altered — the pinned one-line header is 101 characters and trips the line-length linter; broken after the name, whitespace only, normalized header diff empty)*
  immediately BEFORE the landed wrapper, header exactly as the Challenge block writes it, docstring
  from the prototype (L268-274). Proof: the prototype's (L298-393), which is the landed wrapper's
  proof with exactly two changed derivations -- `hpend_all` (every position of `g₁` below
  `u + (d + 1) · l` is pending) is derived from `iterSpliceIdx_of_lt` below `u` and
  `iterSpliceIdx_mem` plus `cntAt_sub_of_pend` inside the run, and the above-run `objAt` clause
  `hobj_above` from `iterSpliceIdx_of_ge`; the register rebuild (`w`, `c`, `hg₂`, the five clauses
  `hw`/`hidle`/`hpp`/`hpi`/`hn₀`, `habove₁`, `nxtAt_lipschitz_two_sided`, the lift
  `exists_ladderPath_of_walk_nxt`, the translate-back) is copied, not re-derived. The full
  exposure of the result follows because the lift exposes `∀ v, objAt g' v = w v` and
  `∀ v, cntAt g' v = c v`.
- [x] Re-prove the landed wrapper as a corollary (about 20 lines): obtain
  `⟨g', hg', hobj, hcz, hnxt, _, hty⟩` from the `_idx` wrapper with the same arguments; the
  below-`u + l` walk clause by `hobj v` and `iterSpliceIdx_of_lt`; `cntAt`/`nxtAt` at `z` direct;
  the type clause at `z` by `hty σ' hσ' z` and `iterSpliceIdx_of_lt` (`z < u + l` from `hzu` and
  `hl`). The STATEMENT is not touched. Rewrite the last sentence of its docstring ("Taking the
  block as an input … a path that has since been shortened by the overshoot loop") to say the
  raise now comes first and the full exposure is the `_idx` wrapper's.
- [x] After the edit, extract the header again and `diff` against the saved copy: empty diff required.
- [x] Confirm `exists_ladderPath_through_shifted_of_pend_past` (the regime-A assembly, test-pinned)
  is textually untouched: `git diff -U0 -- FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean | grep -c "exists_ladderPath_through_shifted_of_pend_past"` is 0.
- [x] Long-file baseline step (expected: about 2,050 lines; `N := 2200` or `2100` per the rule). *(measured: 2,065 lines; `N = 2100` kept)*
- [x] `lean_verify` on both names; scoped build green with zero warnings; `--fix`; commit
  (`task 850 phase 3: the register-held wrapper with full exposure`).

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: The new wrapper is about 130 lines and the landed wrapper's body shrinks from
115 lines to about 20 (net about +35). The landed wrapper has exactly two consumers, both in this
module (the regime-A assembly and the landed exact theorem) and prose mentions in
`LadderChain.lean`'s own docstrings and the RaySummary README; confirm by
`grep -rn exists_ladderPath_through_iterSpliced_nxt_of_pend_past FormalSystem/ Tests/ typst/` before the edit.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` covers both consumers of the
refactored wrapper (same module), and the before/after header diff is the covering check for its
statement; nothing outside the module calls it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the `_idx` wrapper in `section AssemblyFin`; the landed wrapper's body and docstring; the `longFile` baseline
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0 with zero warnings; `lean_verify` on both names reports no `sorry` and the standard axiom profile.
- The before/after header diff of `exists_ladderPath_through_iterSpliced_nxt_of_pend_past` is empty.
- `exists_ladderPath_through_shifted_of_pend_past` and `cellAt_subset_of_shift_of_pend_past` have no diff hunks.

---

### Phase 4: The overshoot step and loop with the sampling window as the hypothesis [COMPLETED]

**Goal**: The landed step and loop accept their sampling window directly, so the loop can start from
`u + (b + 1) · l` -- a start the old `hwb : w₀ ≤ z + b` forbids once a run of `b` copies has been
raised -- while the landed exact theorem (still deletions-first until Phase 6) keeps compiling.

**Tasks**:
- [x] In `exists_deleted_ladderPath_step_of_pend_past`: replace the hypotheses `hwb`, `hlb` and
  `hroom` by the single
  `(hwin : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ))`
  placed directly after `(hl : 0 < l)`, exactly as the prototype's `_win` step (L407-427); delete
  the proof's opening `have hroom' : … := by generalize …; omega` block and use `hwin` where
  `hroom'` was read (the pigeonhole call and `hal`); nothing else in the body changes (prototype
  L430-476). Rewrite the docstring's first sentence to say the window is the hypothesis.
- [x] In `exists_deleted_ladderPath_overshoot_of_pend_past`: replace `hwb` and `hroom` by
  `(hwin : w₀ + ((R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ))`
  placed after `(R : ℕ)`; KEEP `hlb` (the base case's `b ≥ 1`). In the proof (prototype L503-566):
  the base case is unchanged; in the step, derive `hwin₀` (the step's window, by
  `exact_mod_cast Nat.le_add_left _ _` and `omega`) before calling the step, and `hwin₁` (the
  recursive call's window from `hcnt₁` by `exact_mod_cast` and `omega`) before recursing; the
  gap and slack bookkeeping is unchanged. Rewrite the docstring's parenthetical "hence fewer than
  `budget · l ≤ budget²` positions, which is what the exact-shift theorem's `budget²` summand pays
  for" to the neutral "fewer than `budget` blocks of length `l`".
- [x] In the landed `exists_ladderPath_through_deleted_exact_of_pend_past` (its body is replaced in
  Phase 6; here it must only keep compiling): replace its `have hroom : (m * q) * l + b * (b + 1)
  ≤ cntAt g z` by `have hwin : u + (l : ℤ) + (((m * q) * l + b * l : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ)`
  proved from `hul : u + l ≤ z + b` (the within-pigeonhole's room clause), `hbl : b * l ≤ b * b`
  (`Nat.mul_le_mul_left _ hlb`), `hb2 := budget_mul_succ_le_Tc …`, `hRl` and `hTc` by
  `generalize hbq : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card = b at … ⊢; omega` (the
  arithmetic the step's old `hroom'` performed), and pass `hwin` to the loop in place of
  `hul … hroom`. About ten lines.
- [x] Confirm no other consumer: `grep -rn "exists_deleted_ladderPath_step_of_pend_past\|exists_deleted_ladderPath_overshoot_of_pend_past" FormalSystem/ Tests/` lists only the three sites above plus prose.
- [x] Long-file baseline step (expected: no change needed; net about +5 lines). *(measured: 2,072 lines; `N = 2100` kept)*
- [x] `lean_verify` on the three names; scoped build green with zero warnings; `--fix`; commit
  (`task 850 phase 4: the overshoot loop with the sampling window as the hypothesis`).

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: Net about +5 lines (the research: about 165 lines of landed step/loop text
are replaced rather than added); the step has exactly one consumer (the loop) and the loop exactly
one (the landed exact theorem), both in this module and neither Challenge-pinned -- confirm by the
grep in the tasks before editing.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` covers the only consumer of each
restated declaration (both in the same module), and neither declaration is pinned, so no header
diff applies.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the step and loop hypotheses, proofs and docstrings; the landed exact theorem's call site
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0 with zero warnings.
- `lean_verify` on the step, the loop and `exists_ladderPath_through_deleted_exact_of_pend_past`: no `sorry`, standard axiom profile.
- The landed exact theorem's HEADER is textually unchanged (`git diff -U0` shows hunks only inside its body).

---

### Phase 5: The exact-shift theorem, up-first [COMPLETED]

**Goal**: Acceptance (b), first half: `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`
under the gap `nxtAt g z + m · (P + 1) ≤ cntAt g z` and the regime
`HasForwardSlack g z (m · (P + 1)) (nxtAt g z)` -- no `budget²` term -- with the landed
conclusion verbatim.

**Tasks**:
- [x] Insert the theorem into `section DelNxtIter` directly after the loop and before the landed
  exact theorem, header exactly as the Challenge block writes it, docstring from the prototype
  (L575-586: the four-step ordering (i)-(iv) and "No `budget²` term: the raise pays for the
  overshoot before it happens").
- [x] Proof, copied from the prototype (L603-744), in its four steps: *(deviation: altered — one prototype line (`ert`) exceeds 100 characters and was broken across two lines; no proof change)*
  (i) `hz`, `hbud := budget_le_Tc …`, `hb2 := budget_mul_succ_le_Tc …`; a history `σ₀` of `g`;
  the within-pigeonhole `exists_typeBlock_of_budget_le_cnt_within` giving `u l hl hlb hzu hcl hul
  hrep hty` with `hul : u + l ≤ z + b`; `hpast_u` (pending up to `u`, through `cntAt_sub_of_pend`);
  `q` with `l * q = P + 1` from `typeBlock_length_dvd_of_paramsOk`; `hRl : (m * q) * l = m * (P + 1)`;
  `hul'`; the three named product facts `hbl`, `hbb`, `hb1l` (`Nat.mul_le_mul_left`, `Nat.mul_succ`,
  `Nat.succ_mul`).
  (ii) The raise by `b` copies with the register held: the `_idx` wrapper at `d := b`, giving
  `g₁` with `hobj₁ hcz₁ hnxt₁ habove₁ hty₁`; `hobj_above₁` by `iterSpliceIdx_of_ge`; the slack at
  `(m * q) * l + b * l` on `g₁` by `hasForwardSlack_raise` after `rw [hRl]`.
  (iii) The loop above the run: a history `σ₁` of `g₁`; `hpast₁` by `iterSpliceIdx_of_lt`; the
  window `hwin` by `rw [hcz₁, hb1l]; generalize hbq : … = b at hul hbl hbb hb2 hbud ⊢; omega`
  (rule (i) -- no `push_cast`); the loop at `w₀ := u + (b + 1) * l`, `R := m * q`, giving `g₂ t`
  with `R ≤ t < R + b`, `hagree₂` up to `w₀` (the whole run), `hcnt₂`, `hnxt₂`, `hslack₂`, `hty₂`.
  (iv) The remainder `r` with `r + t = m * q + b` (`⟨m * q + b - t, by omega⟩`), `1 ≤ r ≤ b`,
  `hrl`, `ert`, `hcz₂`, `hrw₀`; `hrep₂` (the block `[u, u + r · l)` of `g₂` is type-respecting
  on the walk, by `hagree₂`, `hobj₁`, `iterSpliceIdx_of_lt`, `iterSpliceIdx_boundary`); `hpast₂`;
  `hz₂`; `huzb : u - z ≤ ((b : ℕ) : ℤ)` STATED WITH THE CAST ON THE PRODUCT (rule (ii)); `hc₂big`;
  `hcl₂` (through `cntAt_sub_of_pend` at `(u - z).toNat`); `hal₂`; `hamt` rewriting the loop's
  slack amount to `r * l`; `hfirst` and the anchor clause by `anchor_clause_of_first_region_start`;
  the deletion with the register exposed `exists_deleted_ladderPath_of_pend_past_nxt`; the
  `objAt`/`cntAt` clauses by `delObj_eq_of_le` and `delCnt_sub_of_mem_region`; the type clause
  through histories `σ₂` (deletion, `tpOf_eq_delIdx_of_tpOf_eq` with the `z = u` case split on
  `delIdx`), `σ₁` (the loop), `σ₀` (the raise), and `tpOf_stabFree_eq_of_objAt_eq` to the
  caller's `σ`.
- [x] Long-file baseline step (expected: about 2,270 lines; `N := 2400`). *(measured: 2,239 lines; `N := 2400`)*
- [x] `lean_verify` (expected `[propext, Classical.choice, Quot.sound]`); scoped build green with
  zero warnings; `--fix`; commit (`task 850 phase 5: the exact-shift theorem, up-first`).

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: One theorem of about 216 lines (prototype section ExactUpFirst's first
declaration, measured by the research), whose body compiled in the prototype after three `omega`
cast-form corrections; the risk is re-typing, not mathematics. Confirm by `wc -l` delta and the
zero-warnings build.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` with zero warnings covers the edit
completely -- the theorem is new and consumed by nothing until Phase 6.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the up-first theorem in `section DelNxtIter`; the `longFile` baseline
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0 with zero warnings.
- `lean_verify` on `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`: no `sorry`, axioms a subset of `[propext, Classical.choice, Quot.sound]`.
- Header text equals the Challenge block's (whitespace-normalized diff empty); the hypothesis list contains no `Fintype.card Q * 2 ^ … * (Fintype.card Q * 2 ^ …)` summand (grep the header for `card *` followed by `(Fintype` returns nothing).

---

### Phase 6: The clean cell inclusion; the landed statements as corollaries [COMPLETED]

**Goal**: Acceptance (b), second half, and acceptance (c): `mem_cellAt_of_shift_of_hasForwardSlack_exact`
under exactly `n + 2 ≤ c`, `Tc ≤ c` and `HasForwardSlack g z (m · (P + 1)) n`; the landed
`exists_ladderPath_through_deleted_exact_of_pend_past` and `mem_cellAt_of_shift_of_hasForwardSlack`
survive with their statements verbatim as 3-line corollaries, and the file's baseline is
re-tightened to its final value.

**Tasks**:
- [x] Before the edit, save both landed headers with `sed -n '/^theorem NAME/,/:= by$/p' … > <scratchpad>/NAME-before.txt` for each of the two names.
- [x] Insert `mem_cellAt_of_shift_of_hasForwardSlack_exact` directly after the up-first theorem,
  header exactly as the Challenge block writes it, docstring from the prototype (L742-745) extended
  with the landed cell inclusion's paragraph on the witnessing path and the reserved name (the
  docstring at L1674-1686 of the file at authoring, with the `budget²` clauses removed). Proof from
  the prototype (L764-786): `hoz`/`hcz`/`hnz` by `simp [objAt/cntAt/nxtAt, hgz]`; `hz` by
  `by_contra` through `h`; `hpast` by `pend_past_of_nxtAt_lt`; the up-first theorem with the three
  arithmetic side goals by `rw [hcz, hnz]; omega`; `hc'`; a history `τ'` of `g'`;
  `mem_cellAt_ladder_iff`; `Subtype.ext` on the state; `hty τ τ' hτ hτ'`.
- [x] Replace the body of the landed `exists_ladderPath_through_deleted_exact_of_pend_past` by the
  term `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno g hg z hpast m hTc (by omega) (hasForwardSlack_mono g z hslack (Nat.le_add_right _ _))`
  (prototype L795-823); the STATEMENT is not touched. Rewrite its docstring: it is now "the landed
  exact-shift theorem as a corollary of the up-first one: monotonicity of the regime and arithmetic
  on the gap", keeping the one-sentence description of what it concludes and deleting the
  "OVERSHOOT-THEN-UP" and "the price of ordering the deletions first" sentences.
- [x] Replace the body of the landed `mem_cellAt_of_shift_of_hasForwardSlack` by the term
  `mem_cellAt_of_shift_of_hasForwardSlack_exact step pend fwd bwd lab φ Tc Tn P B hp hno q c n h m h' hgap hTc z g hg hgz (hasForwardSlack_mono g z hslack (Nat.le_add_right _ _)) τ hτ`
  (prototype L827-851), preceded by the two-line `--` comment naming `linter.unusedVariables` and
  the reason (`hslk` is implied by `hgap` once the regime amount is `m · (P + 1)` and is not read)
  and then `set_option linter.unusedVariables false in` (C29 form). The STATEMENT is not touched.
  Rewrite its docstring to point at the `_exact` form for the witnessing-path discussion and to
  say it is the verbatim landed statement kept as a corollary.
- [x] After the edits, extract both headers again and `diff` against the saved copies: empty diffs required.
- [x] Long-file baseline step -- the FINAL value: expected about 2,200 lines, so `N := 2400` if *(measured: 2,197 lines; final `N := 2300`)*
  `lines ≥ 2200` else `2300`; record the measured `wc -l` and the chosen `N` in this phase's notes.
- [x] `lean_verify` on all three names (the `_exact` inclusion expected `[propext, Classical.choice, Quot.sound]`);
  scoped build green with zero warnings (the scoped suppression must leave zero warnings);
  `--fix`; commit (`task 850 phase 6: the clean cell inclusion and the landed statements as corollaries`).

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: The new inclusion is about 42 lines; the landed exact theorem's body shrinks
from 96 lines to a 2-line term and the landed cell inclusion's from 45 lines to a 2-line term plus
the scoped suppression (net about -70, per the research's measurement). The two landed names are
consumed by nothing in Lean outside this module (grep at authoring: `LadderAgree.lean:2199-2203`
and README prose only; no test pins them); confirm by
`grep -rn "exists_ladderPath_through_deleted_exact_of_pend_past\|mem_cellAt_of_shift_of_hasForwardSlack" FormalSystem/ Tests/ typst/`
before editing.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` covers every Lean consumer of the
two refactored theorems (there are none outside the module), and the before/after header diffs are
the covering check for their statements.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the `_exact` inclusion; the two landed theorems' bodies and docstrings; the final `longFile` baseline
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0 with zero warnings.
- `lean_verify` on `mem_cellAt_of_shift_of_hasForwardSlack_exact`, `exists_ladderPath_through_deleted_exact_of_pend_past`, `mem_cellAt_of_shift_of_hasForwardSlack`: no `sorry`, standard axiom profile.
- Both before/after header diffs are empty.
- The `_exact` inclusion's header carries exactly the hypotheses `hgap : n + 2 ≤ c`, `hTc : Tc ≤ c`, `hslack : HasForwardSlack g z (m * (P + 1)) n` and no `hslk` (grep its header for `hslk` returns nothing).

---

### Phase 7: Record, sync, drift check, and the full gate [COMPLETED]

**Goal**: Acceptance (d) and (e): the module's record describes the up-first ordering and the
dropped slack penalty everywhere the deletions-first ordering was asserted, statement fidelity of
all thirteen pinned names (six of this task, seven of the predecessor) is verified, and the
complete gate set runs green with `sorry` 0 and the axiom census unchanged.

**Tasks**:
- [x] Open with the grep in this phase's Scope Hypothesis and rewrite each site it lists in
  `LadderChain.lean` (line numbers at authoring; re-derive): the module docstring's exact-shift
  sentence (L52-55) to name the up-first ordering and the regime at exactly `m · (P + 1)`, with the
  landed names as corollaries; the `DelNxtFin` docstring's "EXACTNESS, met by overshooting with
  sampled blocks at spacing `l` and raising by the overshoot" clause (L1276-1278); the `DelNxtIter`
  section header (L1360-1373), rewritten as "raise first, overshoot above the run, delete the exact
  remainder inside it", with the `budget²` justification deleted and the index-map exposure named
  as what makes the raise-first order possible; the upward inclusion's docstring clause "(with the
  gap `n + budget² ≤ c`)" (L1740) replaced by the clean hypotheses and the `_exact` name; the
  `Spacing` header (L450) checked (the loop still needs spacing `l`; adjust only if a clause names
  the order).
- [x] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: row 39 (`LadderChain.lean`) -- *(line count re-derived: 2,216)*
  re-derive the line count with `wc -l` and replace the exact-shift clause ("overshoot by sampled
  blocks at spacing `l`, then raise by the overshoot on the original block" and "the regime at
  amount `m · (P + 1) + b²`") with the up-first ordering under the regime at exactly `m · (P + 1)`,
  naming the index map, the raise transport, the `_idx` duplication and wrapper, the up-first
  theorem and the `_exact` inclusion, and the landed names as corollaries; row 42
  (`LadderPump.lean`) -- rewrite the "Exposure:" sentence's ending ("which is why
  `LadderChain.lean`'s exact-shift construction orders its deletions first and raises last") to
  say the full exposure is re-derived in `LadderChain.lean` through `iterSpliceIdx`; the depth-`0`
  status paragraph (L984-987) -- replace "(overshoot by sampled blocks …, then raise by the
  overshoot)" and `HasForwardSlack g z (m · (P + 1) + b²) n` by the up-first ordering and
  `HasForwardSlack g z (m · (P + 1)) n`, and record that the `budget²` penalty is dropped.
- [x] Statement fidelity, both routes: (1) `bash .claude/scripts/lean-challenge-snapshot.sh --check 850 .` *(outcome: `--check 850` and `--check 849` both exit 71, advisory as predicted; thirteen normalized header matches)*
  and `… --check 849 .` -- exit 0 expected only if the `specs/**` prototypes have been moved; exit
  71 (ambiguity from `specs/849_…/prototype/helpers-compiled.lean` and
  `specs/850_…/prototype/upfirst-helpers-compiled.lean`) is EXPECTED and advisory; exit 65 is
  advisory and must be investigated. (2) Independently of (1): for each of the six 850 names,
  diff the whitespace-normalized header (from the `theorem`/`def` keyword to `:=`, or the whole
  definition for `iterSpliceIdx`) in `LadderChain.lean` against
  `git show $(jq -r .commit specs/850_upfirst_exact_shift_copy_boundary_types/challenge/manifest.json):Challenge.lean`,
  and for each of the seven 849 names against `git show cd052276c1d1734ac8d94f8fc5ee8d7c2c9932db:Challenge.lean`;
  thirteen matches required. Record the outcome in the summary.
- [x] Unscoped guarded build: `timeout 590 bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (or detached with the bounded waiter if it does not fit one call), exit 0 with zero warnings.
- [x] `sorry` census: `grep -rn "\bsorry\b" FormalSystem/ --include=*.lean | grep -v Boneyard | wc -l` is 0.
- [x] Axiom census, both named measurements unchanged from authoring:
  `grep -rn "^axiom " FormalSystem --include=*.lean | wc -l` = 10 and
  `bash scripts/typst-status-counts.sh --json | jq .axiom_count` = 20; `lean_verify` on every name
  landed in Phases 1-6 reports a subset of `[propext, Classical.choice, Quot.sound]`.
- [x] `bash scripts/typst-sync-check.sh --fix`; then `bash scripts/typst-sync-check.sh` exits 0.
- [x] The complete gate set: `bash .claude/scripts/verify-deploy.sh` exits 0.
- [x] `grep -rn "task 8" FormalSystem/ typst/` returns nothing; the README and docstrings cite
  durable anchors (names, section headings) only, and no deliverable narrates its own draft
  history ("previously", "no longer", "used to" are not used -- state the current design).
- [x] Commit (`.lean`, README, `status.typ`; `task 850 phase 7: record, sync and the full gate`);
  write the implementation summary.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: After Phases 3, 4 and 6 have rewritten the docstrings attached to the
declarations they edit, the remaining prose sites asserting the deletions-first ordering or the
`budget²` term are expected to be exactly five in `LadderChain.lean` (the module docstring, the
`DelNxtFin` docstring, the `DelNxtIter` header, the upward inclusion's docstring, and possibly
the `Spacing` header) and three in the README (rows 39 and 42, the status paragraph); confirm
before editing by
`grep -n "budget²\|b²\|deletions first\|raises last\|raise by the overshoot\|OVERSHOOT-THEN-UP\|then raise" FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean FormalSystem/Metalogic/Decidability/RaySummary/README.md FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`
and after editing by the same grep returning only wording that describes the up-first ordering or
the dropped penalty as dropped.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - docstrings and section headers only
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - rows 39 and 42; the depth-`0` status paragraph
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` exits 0 (the complete gate set, not a subset).
- The unscoped guarded `lake build` exits 0 with zero warnings; `bash scripts/typst-sync-check.sh` exits 0.
- `sorry` census 0; both axiom measurements unchanged (10 and 20); `lean_verify` on every new declaration from Phases 1-6 reports a subset of `[propext, Classical.choice, Quot.sound]` and no `sorry`.
- Thirteen header matches (six 850 names against the 850 Challenge commit, seven 849 names against the 849 Challenge commit); `--check` exit codes recorded with their reading.
- `grep -rn "task 8" FormalSystem/ typst/` returns nothing; the Scope Hypothesis grep returns only the new wording.
- `cellLE_zero_const_of_kappa_eq` is still claimed by nothing: `grep -rn "cellLE_zero_const_of_kappa_eq" FormalSystem/ --include=*.lean` matches prose only (no `theorem`/`lemma` line).

## Lean Challenge Statements

All six declarations below were elaborated standalone at authoring time against the built library
(`lake env lean` through the build guard on this block with the five `sorry` bodies: exit 0,
exactly five `declaration uses 'sorry'` warnings, no errors; `lean-challenge-snapshot.sh 850 .
--dry-run` exit 0 with the identifier sets agreeing). Every statement is verbatim from
`prototype/upfirst-helpers-compiled.lean`, whose BODIES compiled during research, with the
section-variable binders written out explicitly. `iterSpliceIdx` is pinned as its definition text
(a pattern-matching definition carries no top-level `:=`, so the snapshot tool appends it unchanged
and `--check` compares the whole definition); the implementer copies it character-for-character.
The unpinned deliverables (the window-generalized step and loop of Phase 4; the three landed
declarations re-derived as corollaries in Phases 3 and 6, whose statements are fixed by the
predecessor's Challenge at commit `cd052276c1d1734ac8d94f8fc5ee8d7c2c9932db` and by before/after
header diffs) are deliberately not pinned -- see Decisions. Two of the names below cannot be
re-pinned here even in principle: a Challenge module importing `LadderChain` cannot re-declare a
name the module already holds.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

def iterSpliceIdx (u : ℤ) (l : ℕ) : ℕ → ℤ → ℤ
  | 0, v => v
  | d + 1, v => iterSpliceIdx u l d (spliceIdx u l v)

theorem hasForwardSlack_raise {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {u : ℤ} {l d : ℕ} (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    {L n : ℕ} (hslack : HasForwardSlack g z L n)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hcz : cntAt g' z = cntAt g z + d * l)
    (habove : ∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v →
      objAt g' v = objAt g (v - (d * l : ℕ)) ∧ cntAt g' v = cntAt g (v - (d * l : ℕ))) :
    HasForwardSlack g' z (L + d * l) n := sorry

theorem exists_iterSpliced_ladderPath_idx_of_pend_past {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u)
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + d * l) ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := sorry

theorem exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u) (hzu : z ≤ u)
    (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      cntAt g' z = cntAt g z + d * l ∧
      nxtAt g' z = nxtAt g z ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := sorry

theorem exists_ladderPath_through_deleted_exact_upfirst_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

theorem mem_cellAt_of_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [x] Each Lean phase: scoped guarded build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` exits 0 with zero warnings; `lean_verify` on every declaration touched reports no `sorry` and a subset of `[propext, Classical.choice, Quot.sound]`.
- [x] Phases 3 and 6: before/after header diffs of the three landed declarations whose bodies change are empty.
- [x] Phase 7: thirteen header matches against the two Challenge commits; `--check` exit codes recorded and read as advisory.
- [x] Phase 7: unscoped guarded `lake build` exit 0 with zero warnings; `sorry` census 0; both axiom measurements unchanged (10 and 20); `bash scripts/typst-sync-check.sh` exit 0; `bash .claude/scripts/verify-deploy.sh` exit 0.
- [x] Phase 7: the test module `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` is untouched and its `#guard_msgs` pins pass inside the full build.
- [x] Phase 7: `grep -rn "task 8" FormalSystem/ typst/` empty; no record-versioning language in the README or docstrings.

## Artifacts & Outputs

- `specs/850_upfirst_exact_shift_copy_boundary_types/plans/01_upfirst-exact-shift-copy-boundary.md` (this file)
- `specs/850_upfirst_exact_shift_copy_boundary_types/challenge/manifest.json` and the root `Challenge.lean` at the snapshot commit (written by `lean-challenge-snapshot.sh 850 .` at plan time)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` -- the six pinned declarations, eight index-map lemmas, the restated step and loop, the three landed declarations as corollaries, the re-baselined `longFile` option, revised docstrings
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` -- rows 39 and 42, the depth-`0` status paragraph
- `typst/generated/status.typ` -- regenerated with every commit touching the `.lean` file
- `specs/850_upfirst_exact_shift_copy_boundary_types/summaries/01_upfirst-exact-shift-copy-boundary-summary.md` -- written at the end of Phase 7

## Rollback/Contingency

- Every phase ends green and committed, so a failed phase is abandoned by fixing forward within
  the phase (the prototype carries a compiled body for every declaration; re-copy it) -- never by
  discarding uncommitted work. If a genuine rollback of an uncommitted, broken phase is
  unavoidable, follow `context/contracts/recovery.md`'s rung (c): snapshot first with
  `bash .claude/scripts/git-snapshot.sh 850` (the task number explicit), then the smallest-scope
  revert; the previous phase's commit is the resume point.
- If the long-file linter's accepted set is misjudged at some phase, the fix is the one-line
  `N := candidate` change the linter's own warning names; it is never a reason to split the file.
- If Phase 4's in-place hypothesis change cannot keep the landed exact theorem green (the only
  consumer), the pre-authorized fallback is to land the window-generalized step and loop under
  the prototype's `_win` names beside the landed ones for Phases 4-5 and delete the landed pair
  in Phase 6 when their consumer becomes a corollary; the final state is identical and the cost
  is about 170 transient lines of file length, re-baselined per the rule.
- If a pinned header is found to be genuinely wrong at implementation (not merely inconvenient),
  mark the phase `[BLOCKED]` and escalate per `plan-compliance.md`'s Statement Fidelity section;
  do not edit the Challenge or restate the theorem under its pinned name.
