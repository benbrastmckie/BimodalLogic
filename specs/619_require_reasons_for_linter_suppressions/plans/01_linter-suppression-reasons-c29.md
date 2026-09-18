# Implementation Plan: Linter-Suppression Reason Requirement

- **Task**: 619 - require_reasons_for_linter_suppressions
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: 585 (burn-down; complete — its recorded Ultraproduct measurement is an input here)
- **Research Inputs**: specs/619_require_reasons_for_linter_suppressions/reports/01_linter-suppression-reasons.md
- **Artifacts**: plans/01_linter-suppression-reasons-c29.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Every `set_option linter.* false` occurrence in the live tree must carry a recorded reason at
its site, and a new build-free invariant check (C29) must keep it that way. Research settled the
inventory (12 live occurrences, **7 bare** — one more than the task description lists) and ran
four empirical deletion trials, so the disposition of every bare suppression is already decided
on evidence: delete five, rename-and-delete one, keep one with a documented reason. Definition of
done: zero bare suppressions in `FormalSystem/`, `Tests/` and `scripts/`; C29 enforced and
negative-tested; `lake build` green; `scripts/warning-budget.txt` unchanged at zero.

### Research Integration

The report supplies the plan's factual spine and removes all the exploratory work from
implementation:

- **Inventory**: 12 live occurrences, 5 already documented, 7 bare. The seventh bare one —
  `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean:50` — is absent from the task
  description and is in scope here. The description's path for `UntlSnceFree.lean` is wrong: it is
  under `…/Verified/Termination/MintBound/`, not `…/Verified/Bridge/`. Re-verified against the
  clean tree at plan time: all 12 line numbers still hold.
- **Trial 1** (`RegionFrame.lean:128`): hides **nothing**. `bcb8e110b` inserted
  `regionRel_fib_subsingleton` between the suppression and its original target, silently
  retargeting it; `e18cd2271` then fixed the original target with a `_ι` binder. Dead since
  `bcb8e110b`.
- **Trial 2** (`RegionFrame.lean:278`): hides exactly one warning — `f` unused at
  `RegionFrame.lean:292:19` in `def regionHistory`. `scripts/warning-budget.txt`'s own disposition
  row for `linter.unusedVariables` prescribes the `_`-prefix rename, and the sibling `regionFrame
  (W _ι D : Type)` in the same file already took that route.
- **Trial 3** (`UntlSnceFree.lean:352`): **load-bearing**. Replacing the covered `assumption` at
  `:404` with `skip` fails the build with two unsolved goals at `:389:26` (`case h_2.inr.inr`,
  once per `Sign`). The `assumption` is the alternative's *failure* mechanism, forcing
  fall-through to the `_oriented` twin — the `MintBound/Invariants.lean` pattern, not the
  `TimeCensus.lean` one.
- **Trial 4** (`DependentUltraproductProbe.lean:50`): hides nothing.
- **Burn-down's recorded Ultraproduct measurement** (read, not re-derived): `Carrier.lean` 3
  warnings (lines 85, 267, 271); `Los.lean` 0; `ShiftSetProduct.lean` 0.
- **C29 design**: next free ID is C29 (C28 verified highest at plan time). Build-free, masked via
  `scripts/lib/lean_debug_artifacts.mask`, walked via `scripts/lib/live_walk.live_files`,
  upward-walk past stacked `set_option … in` lines, exit-2 anti-silence guard. A prototype
  classified all 12 occurrences correctly in 0.11s with a `'linter.' in text` pre-filter.
- **No companion allowlist.** The task description offers one as an alternative; research declines
  it and this plan follows: reasons live at the site, where a reader meets the suppression and
  where it goes stale with the code it covers.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but was not supplied as roadmap context for this dispatch and no
roadmap flag was set; no roadmap phases are included and no roadmap item is claimed.

## Goals & Non-Goals

**Goals**:
- Zero bare `set_option linter.* false` occurrences across `FormalSystem/`, `Tests/` and
  `scripts/` — every retained suppression carries an in-source reason naming what its deletion
  trial showed.
- C29 added to `scripts/check-module-invariants.sh`: build-free, `--no-build`-safe, enforced from
  the outset, with a fixture self-test and an exit-2 anti-silence guard.
- C29 negative-tested: an injected bare suppression produces both a printed `FAIL C29` naming
  file and line **and** a non-zero script exit.
- `docs/development/MODULE_INVARIANTS.md` carries a C29 row; the script's header check list
  carries a C29 entry.
- `docs/development/LEAN_STYLE_GUIDE.md`'s "Suppressing Linters" snippet stops modelling the exact
  shape C29 rejects.
- `lake build` green; `scripts/warning-budget.txt` unchanged at zero warnings across zero files.

**Non-Goals**:
- Converting the file-scoped Ultraproduct blankets to `in`-scoped form, or adding a shape ratchet.
  That is the sibling Mathlib-linter-set task's work. This plan **deletes** three of those four
  blankets outright and fixes-then-deletes the fourth, which removes the object of that conversion
  rather than performing it.
- Adding any entry to `scripts/nolints.json`, or baselining any warning in
  `scripts/warning-budget.txt`.
- Touching `specs/428_.../scratch/04_witness-preservation.lean:430` (scratch under `specs/`, out
  of scope by design).
- Fixing the seven ungrandfathered `unusedArguments` findings C16 already reports from the
  burn-down. They pre-date this task and are explicitly not absorbed here.
- Editing any other task's state entry or description. The sibling-task coordination note is
  recorded in this task's summary only.

## Lean Challenge Statements

This is a `lean4`-typed task that introduces **no new theorem or definition statements** — every
Lean-side edit is a suppression deletion, a binder rename, an `omit … in` insertion, or a comment.
The identifier set committed by this plan is therefore empty, matching the empty set of Lean
identifiers named under `- **Goals**:` above. No Challenge module is assembled for this task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `nolints.json` entry for `regionHistory` goes stale after the `f → _f` rename (Mathlib's `unusedArguments` ignores `_`-prefixed binders) | M | M | After the rename run the env_linter (C16) and drop the entry in the same commit if reported stale. Never add entries. |
| C16 is already red from the burn-down (seven ungrandfathered `unusedArguments` findings) and an implementer misreads it as caused by this task | M | H | Phase 1 captures the C16 state **before** any edit; every later C16 reading is a diff against that capture, never an absolute judgement. |
| Trace-store race: a concurrent `lake build` (other agents are active in this repo) yields a spurious `FAIL C28` | M | M | Build only through `.claude/scripts/lake-build-guard.sh` — lake args start at the **subcommand** (`-- build …`, never `-- lake build …`, which the guard rejects with exit 77). Re-run C28 after the build completes before investigating any failure. |
| `omit … in` on `Carrier.lean` changes the affected declarations' signatures, breaking dependents | H | M | Treat Phase 4 as an `interface` change: enumerate and build `Carrier`'s direct dependents, not just `Carrier`. Take the `omit` text verbatim from what Lean prints, not from memory. |
| A named-argument call site `regionHistory (f := …)` exists after all, breaking the rename | M | L | Phase 3 carries a Scope Hypothesis: re-grep for `(f :=` against `regionHistory` before editing. Documented fallback: keep the suppression with a comment naming the `:292:19` warning verbatim and why `_f` was refused — never a bare keep. |
| C29 lands enforced while bare suppressions remain, turning the harness red mid-plan | M | L | Phase ordering: all dispositions (Phases 2-5) land before C29 is authored (Phase 6). |
| A "comment immediately above" rule misclassifies a suppression carrying a stacked `set_option` (`UntlSnceFree.lean:351` is `set_option maxHeartbeats 4000000 in`) | H | H if naive | Implement the upward-walk rule and ship a stacked-`set_option` fixture in C29's self-test. |
| A task-number citation lands in `docs/development/MODULE_INVARIANTS.md` and trips C9D | L | M | C9D is enforced over `docs/`. Cite durable anchors (file paths, commit SHAs, check IDs) in the C29 row — never a task number. |
| Line-number drift between plan and edit time | L | M | Re-grep (`grep -rn "set_option linter\." --include="*.lean" FormalSystem Tests scripts`) at the start of each editing phase. |
| Deleting suppressions under `Bridge/` invalidates downstream oleans, making the final build long | L | H | Budget for a long full `lake build` in Phase 9; detached, guarded builds only. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 5 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 6 | 3, 4, 5 |
| 5 | 7 | 6 |
| 6 | 8 | 7 |
| 7 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 2 and 5 touch disjoint files
(`RegionFrame`/`Los`/`ShiftSetProduct`/`DependentUltraproductProbe` vs. `UntlSnceFree`). Phase 3
re-enters `RegionFrame.lean`, so it must not run concurrently with Phase 2.

---

### Phase 1: Capture Pre-Edit Baselines [COMPLETED]

**Goal**: Record the tree's exact starting state so every later measurement is a diff, not an
absolute judgement — specifically the already-red C16 inherited from the burn-down.

**Tasks**:
- [x] Confirm the working tree is clean over `FormalSystem/ Tests/ scripts/ docs/`
      (`git status --porcelain`).
- [x] Re-grep the inventory: `grep -rn "set_option linter\." --include="*.lean" FormalSystem Tests scripts`.
      Expect 12 occurrences at the lines recorded in the report; record any drift.
- [x] Run the full invariant harness (`bash scripts/check-module-invariants.sh`) and save its
      output to the task scratch. Record C16's exact finding list and C28's line verbatim. *(deviation: altered — C16 is GREEN on the clean tree, not red as the Risks row assumed; baseline is `PASS C16 ... has no un-nolisted finding` plus the pre-existing `TODO C16 161 finding(s) across 10 of 14 non-FormalSystem lakefile root(s)` which is not-yet-enforced)*
- [x] Run `python3 scripts/warning-budget.py` and record the result (expected:
      `0 warning(s) across 0 file(s)`).
- [x] Confirm C28 is the highest live check ID
      (`grep -oE '\bC[0-9]+\b' scripts/check-module-invariants.sh | sort -uV | tail`), so C29 is free.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the tree holds exactly 12 live occurrences, 7 of them bare, at the line
numbers in the report. Confirm by the re-grep above plus a per-site read of the three lines above
each match; correct the plan's site list in place if the count or the documented/bare split
differs, before any edit.

**Files to modify**:
- None. Measurement only; outputs go to the task scratch directory.

**Verification**:
- Baseline harness output and warning-budget output are recorded and readable.
- Inventory count and bare/documented split are stated explicitly.

---

### Phase 2: Delete the Four Zero-Warning Suppressions [COMPLETED]

**Goal**: Remove the four suppressions measured to hide nothing, with no other source change.

**Tasks**:
- [x] Delete `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:128`
      (`set_option linter.unusedVariables false in`) — Trial 1: zero warnings.
- [x] Delete `FormalSystem/Semantics/Ultraproduct/Los.lean:47` (file-scoped) — burn-down: 0.
- [x] Delete `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean:60` (file-scoped) —
      burn-down: 0.
- [x] Delete `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean:50` (file-scoped) —
      Trial 4: zero warnings.
- [x] Build each touched module through the guard and confirm **zero** new warnings:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionFrame
      FormalSystem.Semantics.Ultraproduct.Los FormalSystem.Semantics.Ultraproduct.ShiftSetProduct
      BimodalTest.Semantics.DependentUltraproductProbe`
- [x] Confirm each module reports *Built* rather than replayed; a replay proves nothing about a
      just-edited file.
- [x] Re-run `python3 scripts/warning-budget.py` after the build completes: still zero.
- [x] Commit (`task 619 phase 2: …`) once green.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: each of these four deletions surfaces exactly zero warnings. Confirm from
the guarded build's own output per module; if any warning appears, stop and dispose of it under
Phase 3's evidence rule (fix the warning or keep the suppression with a reason) rather than
baselining it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` - delete line 128
- `FormalSystem/Semantics/Ultraproduct/Los.lean` - delete line 47
- `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean` - delete line 60
- `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` - delete line 50

**Verification**:
- All four modules build (not replay) with zero warnings attributable to the deleted sites.
- `scripts/warning-budget.py` still reports `0 warning(s) across 0 file(s)`.

---

### Phase 3: Rename `f` to `_f` and Delete `RegionFrame.lean:278` [COMPLETED]

**Goal**: Remove the one suppression that hides a real warning by fixing the warning the way the
tree's own disposition row prescribes.

**Tasks**:
- [x] Re-grep for named-argument call sites before editing:
      `grep -rn "regionHistory" --include="*.lean" FormalSystem Tests | grep "f :="` — expect none.
- [x] Rename the binder `f` to `_f` in `def regionHistory` (was `RegionFrame.lean:292`).
- [x] Delete the suppression (was `RegionFrame.lean:278`).
- [x] Update the `regionHistory` docstring if it names `f` by that spelling.
- [x] Build `FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionFrame` plus its enumerated
      direct dependents through the guard; confirm *Built*, zero warnings.
- [x] Run the env_linter (C16 via `bash scripts/check-module-invariants.sh`, or
      `lake exe runLinter FormalSystem`) and diff against the Phase 1 capture. If the
      `regionHistory` entry in `scripts/nolints.json:838-841` is now reported stale, delete that
      entry in this same commit. Do not add entries. *(deviation: deferred — `lake exe runLinter
      FormalSystem` cannot run against a partial build (`DecisionProcedure.olean does not exist`),
      so the C16 diff against the Phase 1 capture moves to Phase 9, which runs the full harness
      after a full `lake build`.)*
- [x] Commit once green.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: every `regionHistory` call site is positional (~36 uses across
`FormalSystem/` and `Tests/`), so the rename is source-compatible. Confirm with the `f :=` grep
above **before** editing. If a named-argument site exists, take the documented fallback instead:
keep the suppression and add a comment quoting the `RegionFrame.lean:292:19` warning verbatim and
stating why `_f` was refused — never a bare keep.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` - rename binder, delete suppression
- `scripts/nolints.json` - drop the `regionHistory` `unusedArguments` entry only if the linter reports it stale

**Verification**:
- `RegionFrame` and its direct dependents build with zero warnings.
- C16's finding list is unchanged from the Phase 1 capture, or changed only by the removal of the
  now-stale `regionHistory` entry.

---

### Phase 4: Fix Carrier's Three Warnings, Then Delete Its Blanket [COMPLETED WITH EXCLUSIONS]

**Goal**: Remove the last Ultraproduct blanket by fixing what it hides, with no warning baselined.

**Tasks**:
- [x] Comment out `FormalSystem/Semantics/Ultraproduct/Carrier.lean:63` and build
      `FormalSystem.Semantics.Ultraproduct.Carrier` through the guard. Read the **current** line
      numbers and the exact `omit [...] in` text Lean prints for each of the three
      `unusedSectionVars` warnings (recorded at lines 85, 267, 271 during the burn-down).
- [ ] Apply the printed `omit [...] in` form verbatim at each of the three declarations. *(deviation: altered — applied, measured, then reverted: the fix does not converge; see the Reasoned Exclusions table below)*
- [ ] Delete the file-scoped blanket at line 63. *(deviation: skipped — this phase's own documented fallback was taken instead: the blanket is KEPT, with an in-source reason comment naming the trial's three warnings and both measured cascade rounds)*
- [x] Build `Carrier` plus its enumerated direct dependents (at minimum `Los`,
      `ShiftSetProduct`, `BimodalTest.Semantics.DependentUltraproductProbe`, plus anything else
      importing `FormalSystem.Semantics.Ultraproduct.Carrier`) through the guard; confirm *Built*,
      zero warnings.
- [x] Re-run `python3 scripts/warning-budget.py` after the build completes: still zero.
- [x] Commit once green.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the blanket hides exactly three `unusedSectionVars` warnings and each is
fixable by the `omit … in` form. The recorded line numbers (85, 267, 271) are a hypothesis;
confirm from the trial build's own output at implementation time. If a fourth warning appears, or
one resists the `omit` fix, keep the blanket with an in-source comment naming each unfixable
warning verbatim — never delete it by moving a warning into the budget.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Deleting `Carrier.lean`'s file-scoped `linter.unusedSectionVars` blanket | The `omit [...] in` fix the tree's own disposition row prescribes does not reach a fixpoint on this file: each `omit` narrows that lemma's signature, so its consumers stop mentioning the instance too and the linter moves on to the next declaration and the next instance. The route ends with an `omit` line above nearly every theorem in the file. The real fix is the `variable`-block split the linter's own message suggests first — a restructuring of `Carrier.lean`, not a suppression decision, and outside this plan's scope. | Trial (blanket commented out): exactly 3 warnings, all naming `[∀ (i : I), IsOrderedAddMonoid (D i)]`, at `mem_evZero`, `mk_surjective`, `mk_zero`. Round 2 (those three `omit`s applied): 6 warnings — the same three, now for `[(i : I) → LinearOrder (D i)]`, plus `mk_eq_mk`, `mk_le_mk`, `shU_mk`. Round 3 (six `omit`s applied): 6 further — `mk_eq_mk` and `shU_mk` for `LinearOrder`, plus `mk_lt_mk`, `shU_zero`, `shU_add`, `mk_max`. |

The suppression is retained but is no longer bare: an 18-line `--` comment above it names the
linter, the trial's three warnings and both cascade rounds. Nothing was added to
`scripts/warning-budget.txt`, and `warning-budget.py` still reports zero. The task's acceptance
criterion is zero **bare** suppressions, which this satisfies; the consequence for the sibling
Mathlib-linter-set task is that its file-scoped blanket count drops from four to one, not to zero.

**Files to modify**:
- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` - reason comment above the retained blanket

**Verification**:
- `Carrier` and every enumerated dependent build with zero warnings.
- `scripts/warning-budget.txt` is unedited; `warning-budget.py` still reports zero.

---

### Phase 5: Document the Load-Bearing `UntlSnceFree` Suppression [COMPLETED]

**Goal**: Give the one retained suppression a reason comment that names what its deletion trial
actually showed.

**Tasks**:
- [x] Re-verify the suppression's line (was
      `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/UntlSnceFree.lean:352`)
      and that `set_option maxHeartbeats 4000000 in` sits directly above it at `:351`.
- [x] Insert a comment block **above the whole stacked `set_option` group**, modelled on
      `MintBound/Invariants.lean:789-796` (the house model), naming: the warning the suppression
      hides (`UntlSnceFree.lean:404:15: 'assumption' tactic does nothing`); the two goals the
      deletion trial left unsolved (`unsolved goals`, `case h_2.inr.inr`, once for
      `Sign.pos` and once for `Sign.neg`) *(deviation: altered — the trial's `UntlSnceFree.lean:389:26`
      line citation was replaced by a citation of the declaration
      `applyRule_emitted_time_mem_of_untlSnceFree`; inserting the 13-line comment shifts every line
      below it, so a pinned line number would have been wrong the moment it was written and C20
      gates `file.lean:NNN` citations)*; the mechanism — the `assumption` is the alternative's
      *failure* mechanism, so `first` falls through to the
      `mem_identifyTime_time_at_trigger_oriented` twin, and without it the alternative succeeds
      vacuously and orphans the `?_` that `refine` created; and the kinship with
      `MintBound/Invariants.lean` (not the `TimeCensus.lean` pattern, which is a closer for a goal
      `refine` left open).
- [x] Name the linter (`linter.unusedTactic`) explicitly in the comment — C29 will require it.
- [x] Read the resulting diff and confirm every changed hunk is comment text only.
- [x] Build `FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.UntlSnceFree`
      through the guard as a cheap sanity check (comment edits cannot change elaboration, but this
      file is heartbeat-sensitive).
- [x] Commit once green.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/UntlSnceFree.lean` - reason comment above the stacked `set_option` group

**Verification**:
- Diff read-through: every hunk lies inside `--` comment lines.
- The comment names the linter, the hidden warning, the two unsolved goals, and the mechanism.
- Module builds green.

---

### Phase 6: Add the C29 Check [COMPLETED]

**Goal**: Add a build-free invariant check that fails on any `set_option linter.* false` without a
reason comment at its site.

**Tasks**:
- [x] Re-confirm C29 is still the next free ID before writing (C28 highest at plan time).
- [x] Add the C29 block to `scripts/check-module-invariants.sh`, structurally following C27
      (python3 heredoc, `ENFORCE_C29=${ENFORCE_C29:-1}`) and C28's exit-2 convention.
- [x] Scope: live `.lean` under `FormalSystem/`, `Tests/` **and** `scripts/`, via
      `live_walk.live_files`. `Tests/` is deliberately in scope (unlike C27) — a suppression does
      not belong anywhere unreasoned.
- [x] Pre-filter on `'linter.' in text` before masking (measured 2.07s to 0.11s; exact for this
      pattern since every match contains the literal `linter.`).
- [x] Match on **masked** text via `lean_debug_artifacts.mask`:
      `^\s*set_option\s+(linter\.[A-Za-z0-9_.']+)\s+false\b`.
- [x] Reason rule: from the match line, walk upward past contiguous stacked `set_option … in`
      lines, then require the first remaining line to begin a contiguous block of `--` line
      comments with non-blank content, **and** require that block to name the matched linter.
- [x] Run `lean_debug_artifacts.self_test()` first and fail the check outright on a masker
      regression, as C27 does.
- [x] Add a C29-specific fixture set covering: bare, documented, stacked-`set_option`,
      commented-out, and docstring-mention shapes.
- [x] Anti-silence guard: zero matched suppressions anywhere exits **2** with a distinct message,
      not suppressed by `ENFORCE_C29=0`.
- [x] Do **not** add C29 to the `--no-build` skip list; it is pure source text.
- [x] Do **not** create a companion allowlist file, and leave the header's "Companion files" block
      untouched.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and confirm `PASS C29` reporting
      the expected occurrence count, every one documented. *(deviation: altered — the scan reports
      **7** occurrences in 6 files, not the hypothesised 6: Phase 4 retained `Carrier.lean`'s
      blanket with a reason instead of deleting it, so 12 − 4 (Phase 2) − 1 (Phase 3) = 7. The
      same `--no-build` pass also turned up a stale generated inventory block in three READMEs,
      a downstream consequence of Phases 2–5's line-count changes; regenerated with
      `--emit-inventory` in this phase's commit.)*
- [x] Commit once green.

**Timing**: 2 hours

**Depends on**: 3, 4, 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: after Phases 2-5 the tree should hold **6** live occurrences (12 minus 4
deleted in Phase 2, minus 1 in Phase 3, minus 1 in Phase 4) — the 5 already documented before this
task plus the newly documented `UntlSnceFree` one — with zero bare. This arithmetic is a
hypothesis, not a fact: confirm it against C29's own reported count on its first green run and
record the number the scan actually printed.

**Files to modify**:
- `scripts/check-module-invariants.sh` - new C29 block plus its `ENFORCE_C29` default

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS C29` with a nonzero
  occurrence count and zero bare.
- The masker self-test and the C29 fixture set both run and pass before the tree scan.
- Runtime of the C29 block is well under a second.

---

### Phase 7: Negative-Test C29 [NOT STARTED]

**Goal**: Prove the check fails loudly rather than merely printing — the task's stated acceptance
criterion.

**Tasks**:
- [ ] Inject `set_option linter.unusedTactic false in` above some declaration in a live `.lean`
      file with no comment above it.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build`; confirm **both** a printed
      `FAIL C29` naming the injected file and line **and** a non-zero script exit code (the C25
      precedent at `scripts/check-module-invariants.sh:3044-3045` — the printed line alone is not
      the test).
- [ ] Revert the injection; verify byte-identical restoration (`git status --porcelain` empty over
      the touched path) and confirm `PASS C29` returns.
- [ ] Separately exercise the anti-silence guard by pointing the scan at an empty walk; confirm
      **exit 2** and that `ENFORCE_C29=0` does not suppress it.
- [ ] Exercise a documented-but-does-not-name-the-linter case (e.g. a `-- see above` comment) and
      confirm it fails.
- [ ] Record all three outcomes verbatim for the implementation summary.

**Timing**: 0.75 hours

**Depends on**: 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- None persistently. All injections are reverted; only recorded evidence survives.

**Verification**:
- Injected bare suppression: `FAIL C29` printed **and** non-zero exit, both observed.
- Empty walk: exit 2, under both `ENFORCE_C29=1` and `ENFORCE_C29=0`.
- Tree restored byte-identically; `PASS C29` returns.

---

### Phase 8: Documentation [NOT STARTED]

**Goal**: Record C29 where readers and the harness's own header will find it, and stop the style
guide teaching the shape C29 rejects.

**Tasks**:
- [ ] Add a `| C29 (enforced) | … | … |` row to `docs/development/MODULE_INVARIANTS.md` after
      C28's, in the existing 3-column `| ID | Check | Why it exists |` table, matching C28's row
      for length and tone. The "Why it exists" column carries the `RegionFrame.lean:128` story as
      its evidence: a suppression introduced for one declaration, silently retargeted onto another
      by an unrelated insertion, left dead across two further commits with every gate green.
- [ ] **No task-number citations in this row** — C9D is enforced over `docs/`. Cite durable
      anchors: file paths, commit SHAs (`bcb8e110b`, `e18cd2271`), check IDs.
- [ ] Add a C29 entry to the script header's check list
      (`scripts/check-module-invariants.sh`, the `#   C28 …` block).
- [ ] Update `docs/development/LEAN_STYLE_GUIDE.md`'s "Suppressing Linters" section
      (around lines 807-830): give its `set_option linter.unusedVariables false in` snippet a
      reason comment, and add a short note that inserting a declaration below a `set_option … in`
      line silently retargets the option onto the new declaration.
- [ ] Read the diff and confirm every hunk is prose or comment text.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C9D still passes.
- [ ] Commit once green.

**Timing**: 0.75 hours

**Depends on**: 7

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `docs/development/MODULE_INVARIANTS.md` - C29 row after C28's
- `scripts/check-module-invariants.sh` - C29 entry in the header check list (comment block only)
- `docs/development/LEAN_STYLE_GUIDE.md` - reasoned snippet plus the retargeting note

**Verification**:
- Diff read-through: prose/comment hunks only.
- `PASS C9D` (zero task-number citations under `docs/`).
- The C29 row's Check column matches what the implemented check actually does.

---

### Phase 9: Final Gate and Summary [NOT STARTED]

**Goal**: Prove the acceptance criteria hold across the whole repository, then record the outcome.

**Tasks**:
- [ ] Full `lake build` through the guard
      (`bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build`); confirm green.
- [ ] After the build completes (trace store quiescent), run the full harness:
      `bash scripts/check-module-invariants.sh`. Confirm `PASS C29` and `PASS C28`.
- [ ] Diff C16's finding list against the Phase 1 capture; confirm no new findings are attributable
      to this task.
- [ ] `python3 scripts/warning-budget.py`: still `0 warning(s) across 0 file(s)`, and
      `scripts/warning-budget.txt` unedited (`git diff --stat` over it is empty).
- [ ] Final `grep -rn "set_option linter\." --include="*.lean" FormalSystem Tests scripts` and a
      per-site read confirming every survivor has a reason naming its linter.
- [ ] Write the implementation summary, including the Phase 7 negative-test evidence verbatim.
- [ ] Record in the summary the coordination note for the sibling Mathlib-linter-set task: its
      item (4) drops from four file-scoped blankets to zero, so its shape ratchet needs its own
      anti-silence guard — or better, should fold into C29 rather than adding a C30, since both
      read the same matched set. Do not edit that task's state entry or description here.
- [ ] Commit (`task 619: complete implementation`).

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `specs/619_require_reasons_for_linter_suppressions/summaries/01_*-summary.md` - implementation summary

**Verification**:
- `lake build` green.
- Full `check-module-invariants.sh` shows `PASS C29`, `PASS C28`, `PASS C9D`, and no C16 regression
  against the Phase 1 baseline.
- Zero bare `set_option linter.* false` occurrences anywhere in `FormalSystem/`, `Tests/`,
  `scripts/`.
- `scripts/warning-budget.txt` unchanged.

---

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build` exits green.
- [ ] `bash scripts/check-module-invariants.sh` passes, including the new `PASS C29`.
- [ ] `bash scripts/check-module-invariants.sh --no-build` passes identically for C29 (build-free
      by construction).
- [ ] Negative test: injected bare suppression produces `FAIL C29` **and** a non-zero exit code.
- [ ] Anti-silence test: empty walk produces exit 2, not suppressed by `ENFORCE_C29=0`.
- [ ] `python3 scripts/warning-budget.py` reports `0 warning(s) across 0 file(s)`.
- [ ] `git diff` over `scripts/warning-budget.txt` is empty (nothing baselined).
- [ ] Every surviving `set_option linter.* false` has a reason comment naming its linter.

## Artifacts & Outputs

- `scripts/check-module-invariants.sh` — C29 block, `ENFORCE_C29` default, header check-list entry
- `docs/development/MODULE_INVARIANTS.md` — C29 row
- `docs/development/LEAN_STYLE_GUIDE.md` — reasoned suppression snippet plus the `set_option … in`
  retargeting note
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` — two suppressions gone,
  one binder renamed
- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` — three `omit … in` fixes, blanket gone
- `FormalSystem/Semantics/Ultraproduct/Los.lean`,
  `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean`,
  `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` — blankets gone
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/UntlSnceFree.lean` — reason
  comment added
- `scripts/nolints.json` — one entry possibly removed (only if the linter reports it stale)
- `specs/619_require_reasons_for_linter_suppressions/summaries/01_*-summary.md`

## Rollback/Contingency

Each phase commits independently once green, so the ordinary contingency is `git revert` of the
offending phase commit — no working-tree destruction is involved and no snapshot is required.

If an uncommitted working tree must be discarded mid-phase (a trial edit that cannot be cleanly
undone by hand), take a durable checkpoint first rather than reverting blind: see
`context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
including its out-of-scope override flag for the deliberate whole-tree case. For an ordinary
defensive checkpoint before a risky trial — which is the common case here, since Phases 2-4 each
begin with a comment-out-and-build trial — use the non-reverting `--no-revert` form instead.

Per-phase fallbacks, all stated inline above: Phase 3 falls back to keeping the suppression with a
verbatim-warning comment if a named-argument call site turns up; Phase 4 falls back to keeping the
`Carrier` blanket with a comment naming each unfixable warning. In both cases the fallback is a
*documented* keep, never a bare one, and never a new line in `scripts/warning-budget.txt`.

If C29 itself proves unworkable as designed, the check may ship with `ENFORCE_C29=0` for one
cycle — but the exit-2 anti-silence path remains an error in every mode, and the dispositions in
Phases 2-5 stand on their own regardless.
