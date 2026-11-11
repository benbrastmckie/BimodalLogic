# Implementation Plan: Task #911

- **Task**: 911 - Idle-cycle sharpening of the idle-gap lengthening route
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: 909 (completed)
- **Research Inputs**: None (see Decisions, "No research round")
- **Artifacts**: plans/01_idle-cycle-sharpening.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The idle-gap lengthening schema is refuted outright (`idleGapLengthening_refuted`, namespace
`Probe838C`, in `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean`):
a ladder path's object walk steps along `step` at every position, so an idle run of length two
needs an idle-to-idle edge, and an object need not have one. This plan lands the sharpening the
refutation's own docstring names as open: the premise under which the lengthening IS available,
stated explicitly, together with a determination of what it buys and what it does not.

The premise is **run-local, not merely object-level**: a block of the idle run whose two ends
carry the same object state. That block is an idle cycle met by the path, and it is exactly the
hypothesis `spliceObj_step` already needs. Three further facts shape the whole plan and were
each confirmed against the tree at authoring time:

1. **The increment is not free even under the premise.** Duplicating a repeated block of length
   `k` raises the run by `k`, so the available increments are the multiples of `k`. A schema
   quantifying over every `l > 0` stays FALSE under the premise, not merely weaker — an object
   whose idle states carry a 2-cycle and no self-loop has only even-length idle runs. Phase 6
   compiles that exclusion.
2. **Sub-question (ii), type preservation, is reachable and is answered here.** The premise route
   goes through the `(objAt, tpOf)` pigeonhole, which hands a block matching in TYPE as well as
   in object state; `tpOf_eq_spliceIdx_of_tpOf_eq` (already landed, `LadderPump.lean:782`) then
   preserves the realized type at `z`. The clause the refutation never reached is discharged, not
   deferred.
3. **The register clause needs a module boundary crossed.** `exists_ladderPath_of_walk_nxt_at`,
   the only lift that controls `nxtAt` at a chosen position, lives in `LadderChain.lean:605` —
   downstream of `LadderPump.lean`. The pump-layer content (phases 1-3) therefore lands in
   `LadderPump.lean`, and the register-controlled assembly plus the schema and its verdict land
   in a new leaf module `LadderIdle.lean` importing `LadderChain`. Nothing imports the new
   module, so `LadderCell.lean` — a concurrent sibling's territory — is untouched.

### Research Integration

No research report exists for this round. The task description is a specification carrying a
compiled refutation, the located obstruction, the witness, and the acceptance bar; the remaining
unknowns were all resolvable by direct reads of the tree within this planning dispatch (see
Decisions).

### Prior Plan Reference

No prior plan for this task. The parent task's plan
(`specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md`)
supplies one calibration point consumed here: a decision-gate schema is stated as a named `def`
so the verdict is a theorem about a named object either way, and the refuting object is declared
fresh rather than reused from a sibling probe whose `step` admits every edge.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

**Goals**:

- `idleCycleLens` -- the idle mirror of `objCycleLens`: cycle lengths among idle object states.
- `no_consecutive_idle_of_no_idle_step` -- the generic mechanism of the refutation, promoted out
  of the prototype into the library.
- `idleCycleLens_of_idle_segment` -- a repeated object state inside an idle run yields an idle
  cycle.
- `exists_idleCycle_of_card_le_run` -- an idle run at least as long as the idle-state count
  carries such a repeat.
- `idle_run_lt_tIdle_of_no_idleCycle` -- without an idle cycle every idle run is shorter than
  `tIdle pend`; the NECESSITY direction that makes the premise the right one rather than an
  arbitrary strengthening.
- `idleSpliceCnt` -- the countdown the idle-block-duplicated walk forces.
- `exists_idleSpliced_ladderPath` -- the idle-block duplication lifts to a ladder path, with the
  pin condition discharged outright.
- `idleBudget` -- the idle-restricted `(objAt, tpOf)` pigeonhole budget.
- `exists_idleTypeBlock_of_budget_le_run` -- a long enough idle run carries a block matching in
  object state AND realized type.
- `exists_iterIdleSpliced_ladderPath` -- the `d`-fold idle pump with the register at `z` held and
  the realized types below the block preserved.
- `IdleGapLengtheningOfIdleRunRepeat` -- the sharpened schema, with the run-repeat premise
  explicit and the increment restricted to multiples of the repeat length.
- `idleGapLengtheningOfIdleRunRepeat_holds` -- the sharpened schema is a theorem.
- `IdleGapLengtheningAllIncrements` -- the same schema with the increment freed.
- `idleGapLengtheningAllIncrements_refuted` -- the freed-increment form is NOT a theorem, even
  granted the run-repeat premise.

**Non-Goals**:

- No edit to `LadderCell.lean`, `LadderChain.lean`, or `LadderPin.lean`. `LadderCell.lean` is a
  concurrent sibling's declared territory (task 910) and `LadderChain.lean` is the module
  `LadderCell.lean` imports; the new leaf module reaches what it needs by importing, never by
  editing.
- No removal of the `ForwardSlackWitnessed` hypothesis from
  `cellAt_subset_of_shift_of_pend_past_rev` and no promotion of the reserved unrestricted cell
  obligation. The premise landed here is an object/run hypothesis and not a consequence of
  `ParamsOk`, so it cannot discharge a `ParamsOk`-level restriction; phase 7 records that as a
  determination.
- No row added to `docs/theorem-index.md`. That file carries curated headline results (it names
  no `LadderPump.lean` declaration today) and is a concurrent sibling's declared territory
  (task 895).
- No change to `IdleGapLengthening` or to the prototype that refutes it. The prototype is the
  evidence record of the FAIL verdict and stays as it is.
- No claim about sub-question (ii) beyond the stab-free fragment. Every type statement consumed
  here carries the stab-free hypothesis, as the pump layer's own do.

## Decisions

**No research round.** The dispatch carries no `research_artifact`. The description is a
specification, not a research question: it states the defect, names the compiled refutation and
its namespace, locates the obstruction one level below the pin condition, exhibits the witness,
and fixes the acceptance bar. The three facts that were genuinely unknown at dispatch — where the
register-anchored lift lives, whether the existing `spliceCnt` is reusable for an idle block, and
whether the pin condition is a side condition or discharges outright — were each settled by
direct reads of `LadderAgree.lean`, `LadderPump.lean` and `LadderChain.lean` inside this planning
dispatch. No research phase was requested.

**The sharpened schema is `ParamsOk`-free.** `IdleGapLengthening` carries
`ParamsOk step pend lab φ Tc Tn P B` and `Tc ≤ cntAt g z` as hypotheses because it was stated in
the shape its intended consumer would use. The sharpening needs neither: the construction is
pure idle-run surgery. Dropping both hypotheses makes the sharpened schema STRICTLY STRONGER than
the corresponding restriction of the original, and it keeps the new module free of a parameter
condition it does not consume. The exclusion of phase 6 nevertheless also records that its
witness object admits `ParamsOk` at the periodicity fixpoint's own outputs via `paramsOk_params`,
so the refutation is not an artifact of the dropped hypothesis.

**`spliceObj` is reused; `spliceCnt` is not.** `spliceObj_step` (`LadderAgree.lean:1123`) needs
only the endpoint repeat `objAt g a = objAt g (a + l)` and no `pend` hypothesis, so the object
half of the surgery transfers verbatim. `spliceCnt` does not: its definition raises the countdown
by `l` at every position whose region reaches `a`, and at an in-block position `v` (where
`a ≤ v` and `cntAt g v = 0`) that condition holds vacuously, yielding `l` where an idle position
must carry `0`. `idleSpliceCnt` is therefore a new definition, not a reuse.

**The increment restriction is stated, not assumed away.** The task description's standing
warning — the idle run's length is a datum of the object, not a parameter a construction may
raise, and any statement claiming otherwise is false rather than weaker — is discharged by
naming and refuting the freed-increment form (`IdleGapLengtheningAllIncrements`,
`idleGapLengtheningAllIncrements_refuted`) alongside the restricted one, rather than by stating
only the restricted form and leaving the stronger one unaddressed.

**File scope departs from the declared one.** `specs/state.json` records
`file_scope: ["FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean"]` for this task.
That entry is the anticipated scope recorded at creation time; the register clause of the schema
is unreachable from `LadderPump.lean` (fact 3 of the Overview), so this plan adds the new leaf
module `LadderIdle.lean` and the four generated or aggregating surfaces a new Lean module and a
line-count change oblige (`FormalSystem.lean`, `RaySummary.lean`, the two README inventory
blocks, `typst/generated/status.typ`). The per-phase `Files to modify` blocks are the authority.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `longFile` 1500-line ceiling: `LadderPump.lean` stands at 1485 lines with no baseline, so the first added line trips a lint that CI's `--wfail` makes a hard failure | H | H | Phase 1 sets `set_option linter.style.longFile N` directly after the module docstring, and every later phase touching the file re-checks the `N - 200 <= lines < N` acceptance window and adjusts `N` at its own close (gate-collision Condition 7) |
| The pre-commit hook blocks any commit staging a `.lean` path while `typst/generated/status.typ` has drifted | H | H | Every Lean-editing phase runs `bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in the SAME phase, never deferred (gate-collision Condition 1, surface (b)) |
| A new module fails `lake exe mk_all --lib FormalSystem --check` because the generated library root was not regenerated | H | H | Phase 4 regenerates `FormalSystem.lean` via `lake exe mk_all --lib FormalSystem` in the same phase that creates `LadderIdle.lean`, and lists both files in its own scope |
| Proof-effort duplication between the pump-layer single splice (phase 2) and the register-anchored iterate (phase 4) | M | M | Phase 2's deliverable is deliberately factored as five reusable lift INPUT lemmas about `spliceObj`/`idleSpliceCnt` plus one unanchored lift; phase 4 consumes those five inputs and supplies only the anchor condition, rather than re-deriving the surgery |
| The idle-restricted pigeonhole needs `Fintype` on the idle subtype, where the landed pending version needs only `Fintype Q` | M | M | Phase 3 is isolated as its own phase; the map is into `{q : Q // pend q = false} x (powerset of the closure)` with `Fintype.card_subtype` relating it to `(Finset.univ.filter (fun q => pend q = false)).card` |
| The phase 6 witness object must be serial in BOTH directions on the admissible carrier, which is where the sibling prototype's own object cost the most | M | M | The object is pinned in phase 6's task list: one pending state and two idle states with exactly five edges, with the forward and backward seriality proofs mirroring `Probe838C.fwdO`/`bwdO` case-for-case |
| A sibling task commits to a shared file between a read and an edit on this shared working tree | M | M | Territory discipline: re-read each file immediately before editing it, stage only this task's own hunks with an explicit file list, never a directory or glob add, and never run `git-snapshot.sh` in its reverting default mode |
| `check-metalogic-cycles.sh` Assertion B asserts set EQUALITY and fails on surplus upward imports | L | L | Phase 4 runs the script in the same phase as the new import and, if it fires, extends the allowlist in that same phase, carrying `scripts/check-metalogic-cycles.sh` in its scope |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Idle-cycle vocabulary and the bound without one [COMPLETED]

**Goal**: Name the idle-cycle set, promote the refutation's generic mechanism into the library,
and prove both directions of the pigeonhole that connects an idle cycle to a long idle run — so
that the premise later phases assume is visibly the right premise and not an arbitrary
strengthening.

**Tasks**:

- [x] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` immediately before
      editing (concurrent siblings are live on this working tree).
- [x] Insert `set_option linter.style.longFile N` directly after the module docstring, with `N`
      chosen so `N - 200 <= lines < N` holds at this phase's close.
- [x] Open a new section `IdleCycle` after the `Pigeonhole` section, with the file's existing
      `variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q -> Q -> Bool} {pend : Q -> Bool}`
      shape. *(deviation: altered — section opened, but binders are written out per declaration
      instead of taken from a `variable` block. Lean 4 includes a section instance binder
      whenever a variable its type mentions is used, so a `variable [Fintype Q]` would have
      added `[Fintype Q]` to `no_consecutive_idle_of_no_idle_step`, whose Challenge-pinned
      signature carries no such instance. The Challenge signatures are the binding contract
      (`plan-compliance.md`, "Statement Fidelity"), so they won; the section itself and all
      five declarations are exactly as planned. Recorded in the section docstring.)*
- [x] Define `idleCycleLens`, mirroring `objCycleLens` (`CounterQuotient.lean:512`) with
      `pend (f i) = false` in place of `pend (f i) = true`.
- [x] Prove `no_consecutive_idle_of_no_idle_step`, transcribed from
      `Probe838C.no_consecutive_idle_of_no_idle_step`; its body is four lines over `objAt_step`.
- [x] Prove `idleCycleLens_of_idle_segment`, mirroring `objCycleLens_of_segment`
      (`LadderAgree.lean:944`): the periodic walk `k |-> objAt g (a + (k % l))` steps along
      `step`, is idle throughout because the block lies inside the run, and closes at `l`.
- [x] Prove `exists_idleCycle_of_card_le_run`, mirroring `exists_objCycle_of_card_le_cnt`
      (`LadderAgree.lean:984`), with the pigeonhole over the idle-state count rather than
      `Fintype.card Q`.
- [x] Prove `idle_run_lt_tIdle_of_no_idleCycle` by contraposition of the previous lemma, citing
      `tIdle pend = (idle-state count) + 1` so the bound reads against `tIdle`'s own shape.
- [x] Extend the module docstring's contract paragraph with one sentence naming the new section
      and recording that it adds no certificate object and no `ParamsOk`.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase is estimated to add roughly 120 lines, putting
`LadderPump.lean` near 1605 lines and fixing the first `longFile` baseline near `N = 1800`. Both
numbers are hypotheses: confirm the actual `wc -l` at the phase's close and choose `N` from the
measured count against the `N - 200 <= lines < N` window rather than from this estimate.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`
covers the edit, which adds declarations to one module and changes no existing signature.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - new `IdleCycle` section, the
  `longFile` baseline, and the docstring contract sentence
- `typst/generated/status.typ` - regenerated line/count figures (pre-commit hook, blocking)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`
  exits 0 with no warning (CI builds with `--wfail`, so a warning is a failure).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0, which is the condition the
  pre-commit hook reads.
- The four new theorems carry no `sorry`: `lean_verify` on each fully qualified name reports the
  standard axiom profile with no `sorryAx`.

---

### Phase 2: The idle-block splice and its lift inputs [COMPLETED]

**Goal**: Land the countdown the idle-block duplication forces, the three local readings of
`Count` for it, the pin condition (which discharges outright rather than being carried), and the
unanchored lift.

**Tasks**:

- [x] Re-read `LadderPump.lean` immediately before editing.
- [x] Open a section `IdleSplice`. Record in its section docstring that `spliceObj` is reused
      verbatim (`spliceObj_step` needs only the endpoint repeat and no `pend` hypothesis) and
      that `spliceCnt` is NOT reusable, with the in-block `cntAt g v = 0` reason.
- [x] Define `idleSpliceCnt g a l := fun v => if v < a + (l : Int) then cntAt g v else cntAt g (v - (l : Int))`,
      with the two read-off lemmas `idleSpliceCnt_of_lt` and `idleSpliceCnt_of_ge`.
- [x] Prove `idleSpliceCnt_idle`, the idle-zero reading, in both position cases from
      `cntAt_eq_zero_of_idle`.
- [x] Prove `idleSpliceCnt_pend_pend`, the count-down reading. The wrap case `v + 1 = a + l` is
      VACUOUS: `spliceObj g a l v = objAt g (a + l - 1)` is idle because the block is, so the
      hypothesis `pend (spliceObj g a l v) = true` is unsatisfiable there.
- [x] Prove `idleSpliceCnt_pend_idle`, the region-end reading; its wrap case is vacuous for the
      same reason.
- [x] *(deviation: altered — the planned `idleSplice_pins` landed, plus one unplanned helper
      `idleSplice_pull` that factors out the pin classification the three cases all read; and
      `idleSplice_pins` carries NO endpoint-repeat hypothesis, since the classification needs
      only the block's idleness. Strictly fewer hypotheses than planned, so strictly stronger.)*
- [x] Prove `idleSplice_pins`: the spliced walk's pin family is pairwise compatible,
      UNCONDITIONALLY. The three cases are both pins below `a` (inherited from
      `pinCompat_of_ladderPath` on `g`), both at or above `a + l` (positions and values both
      shifted by `+l` and `0`, so the distance is unchanged), and mixed (the upper pin's position
      rises by `l` while its countdown is unchanged, so the demand is strictly looser). Record in
      the lemma's docstring that this is the clause the FAIL verdict's docstring predicted would
      loosen, and that it is the pending splice's carried side condition becoming free here.
- [x] Prove `exists_idleSpliced_ladderPath` via `exists_ladderPath_of_walk_of_pins`
      (`LadderAgree.lean:1322`), feeding the five lemmas above.
- [x] Re-check the `longFile` baseline against the measured line count and adjust `N` if the
      window no longer holds.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase is estimated to add roughly 230 lines, putting the file near
1835 lines and requiring the baseline to be re-tightened to roughly `N = 2000`. Confirm against
the measured count at the phase's close, not against this estimate.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`
covers the edit, which adds declarations to one module and changes no existing signature.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - new `IdleSplice` section
- `typst/generated/status.typ` - regenerated line/count figures (pre-commit hook, blocking)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`
  exits 0 with no warning.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `lean_verify` on `exists_idleSpliced_ladderPath` reports no `sorryAx`.
- `idleSplice_pins` carries no hypothesis beyond `IsLadderPath`, the block's idleness, and the
  endpoint repeat — read off its own signature, confirming the pin condition is discharged and
  not carried.

---

### Phase 3: The idle-run type pigeonhole [COMPLETED]

**Goal**: Produce from a long enough idle run a block matching in object state AND in realized
type, which is what makes sub-question (ii) reachable rather than deferred.

**Tasks**:

- [x] Re-read `LadderPump.lean` immediately before editing.
- [x] Open a section `IdlePigeonhole` beside the existing `Pigeonhole` section.
- [x] Define `idleBudget pend φ := (Finset.univ.filter (fun q : Q => pend q = false)).card * 2 ^ (plusSubformulaClosure φ).card`,
      with a docstring recording that it is the idle-restricted form of the budget
      `exists_typeBlock_of_budget_le_cnt` uses and an OVER-ESTIMATE of the quantity it names.
- [x] Prove `exists_idleTypeBlock_of_budget_le_run`, mirroring
      `exists_typeBlock_of_budget_le_cnt_within` (`LadderPump.lean:1295`): pigeonhole the
      `idleBudget + 1` positions of the run into
      `{q : Q // pend q = false} x {T // T ∈ (plusSubformulaClosure φ).powerset}`, relating the
      subtype's card to the filter's via `Fintype.card_subtype`, and orient the resulting pair
      exactly as the landed lemma does.
- [x] State the conclusion so that the block's idleness (`∀ i < k, pend (objAt g (a + i)) = false`)
      and its containment in the run are both exposed — phases 4 and 5 consume both.
- [x] Re-check the `longFile` baseline and adjust `N` if the window no longer holds.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase is estimated to add roughly 90 lines. The phase 2 baseline is
expected to still hold at that count; confirm the window against the measured count rather than
assuming it.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`
covers the edit, which adds declarations to one module and changes no existing signature.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - new `IdlePigeonhole` section
- `typst/generated/status.typ` - regenerated line/count figures (pre-commit hook, blocking)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`
  exits 0 with no warning.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `lean_verify` on `exists_idleTypeBlock_of_budget_le_run` reports no `sorryAx`.

---

### Phase 4: The new module and the register-anchored iterated idle pump [COMPLETED]

**Goal**: Create the leaf module `LadderIdle.lean` and land in it the `d`-fold idle pump that
holds the register at `z`, holds every countdown at and below the block, lengthens the idle run
by `d * k`, and preserves the realized type below the block.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` with the
      repository's copyright header (`scripts/check-copyright-headers.sh --strict` is a CI gate),
      `import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`, the namespace
      `FormalSystem.Metalogic.Decidability.RaySummary`, and the same `open` lines
      `LadderPump.lean` carries.
- [x] Write the module docstring with a `## Contract` section stating: the module holds the idle
      pump's register-anchored assembly and the sharpened lengthening schema with its verdict; it
      imports `LadderChain` for `exists_ladderPath_of_walk_nxt_at` alone and is imported by
      nothing; and it states no cell-level consequence.
- [x] Add `import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle` to
      `FormalSystem/Metalogic/Decidability/RaySummary.lean`, placed after the `LadderCell` import
      so the aggregator's order still reads bottom-up, and add the matching bullet to that file's
      `## Modules` list.
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`, then confirm
      `lake exe mk_all --lib FormalSystem --check` exits 0.
- [x] Prove `exists_iterIdleSpliced_ladderPath` by induction on `d`. The zero case returns `g`
      itself with the type clause from `tpOf_stabFree_eq_of_objAt_eq`. The successor case applies
      phase 2's five lift inputs to the previous path — whose block is still idle and still
      carries the endpoint repeat, both ends now reading `objAt g a` — and performs the lift with
      `exists_ladderPath_of_walk_nxt_at` at the anchor `nxtAt g z`, discharging its `hn0`
      condition from `cntAt_eq_nxtAt_of_idle_pend` and `nxtAt_lipschitz_two_sided` on the
      previous path together with the `+l` push on the pins above the block.
- [x] Carry the type clause through the induction with `tpOf_eq_spliceIdx_of_tpOf_eq`, exposing
      the realized type only below `a + k`, mirroring the exposure discipline
      `exists_iterSpliced_ladderPath_of_pend_past` already follows.
- [x] Run `bash scripts/check-metalogic-cycles.sh`; if Assertion B fires on the new import,
      extend its allowlist in this same phase. *(deviation: altered — Assertion B did NOT
      fire; all three assertions PASS unchanged, so `scripts/check-metalogic-cycles.sh` is not
      touched, exactly as the phase's own file list provides for.)*
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase is estimated to add roughly 150 lines to a new file well under
the 1500-line ceiling, so no `longFile` baseline is expected in `LadderIdle.lean`. Confirm with
`wc -l` at the phase's close before concluding none is needed.

**Tier Justification**: a new module plus an aggregator import and a regenerated library root
changes the import graph, so `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
(the aggregator, the enumerated one-hop dependent of the new module) plus
`lake exe mk_all --lib FormalSystem --check` is the cheapest check that covers it.

**Commit-mode note**: the module, the aggregator import, the `## Modules` bullet, and the
regenerated root are one atomic batch — any proper subset leaves
`lake exe mk_all --lib FormalSystem --check` red, which is the pre-declared expected-red
intermediate state this mode exists for.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - created: module docstring and
  `exists_iterIdleSpliced_ladderPath`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - new import and `## Modules` bullet
- `FormalSystem.lean` - regenerated library root (exists; `lake exe mk_all --lib FormalSystem`
  rewrites it, and if the regeneration is a no-op the file is simply left unstaged)
- `scripts/check-metalogic-cycles.sh` - allowlist extension, ONLY if Assertion B fires on the new
  import; if it does not fire, this file is not touched
- `typst/generated/status.typ` - regenerated line/count figures (pre-commit hook, blocking)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
  exits 0 with no warning.
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `bash scripts/check-copyright-headers.sh --strict` reports no finding naming
  `LadderIdle.lean`.
- `bash scripts/check-metalogic-cycles.sh` exits 0, or its findings are confined to the
  allowlist entry this phase added.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `lean_verify` on `exists_iterIdleSpliced_ladderPath` reports no `sorryAx`.

---

### Phase 5: The sharpened schema and its verdict [COMPLETED]

**Goal**: State the sharpened lengthening as a named `def` with the run-repeat premise explicit
and the increment restricted to multiples of the repeat length, and prove it.

**Tasks**:

- [x] Re-read `LadderIdle.lean` immediately before editing.
- [x] Define `IdleGapLengtheningOfIdleRunRepeat` as a `Prop`-valued `def`, following
      `Probe838C.IdleGapLengthening`'s shape clause for clause, with these differences and no
      others: `ParamsOk` and `Tc <= cntAt g z` are dropped (see Decisions); the free increment
      `l` is replaced by `d * k` where `k` is the repeat length; and the run-repeat premise is
      added as four hypotheses — the block lies at or above the run's first position, ends at or
      below the run's last, carries the object repeat, and carries the type repeat for the
      history over `g`.
- [x] Write the `def`'s docstring stating what the schema asserts, that it is the sharpening the
      FAIL verdict's own docstring named as open, and that the premise is a datum of the object's
      step graph met by this path and is not a consequence of `ParamsOk`.
- [x] Prove `idleGapLengtheningOfIdleRunRepeat_holds` by applying
      `exists_iterIdleSpliced_ladderPath` at the block the premise supplies, then reading the
      schema's seven conclusion clauses off its conclusion: the three agreements at `z` from the
      below-block clause and the register clause; the lengthened run and its terminating region
      start from the pumped-run clause and the shift clause; the displaced region start's
      countdown from the shift clause; and the type at `z` from the type clause, `z` being below
      the block.
- [x] Record in the theorem's docstring that sub-question (ii) is DISCHARGED here, not deferred:
      the type clause the FAIL verdict never reached follows because the premise's block matches
      in type as well as in object state.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle`
covers the edit, which adds two declarations to the module phase 4 created and changes no
existing signature and no import.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - the schema `def` and its
  theorem
- `typst/generated/status.typ` - regenerated line/count figures (pre-commit hook, blocking)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle`
  exits 0 with no warning.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `lean_verify` on `idleGapLengtheningOfIdleRunRepeat_holds` reports the standard axiom profile
  with no `sorryAx`.
- `lean_minimal_hypotheses` on `idleGapLengtheningOfIdleRunRepeat_holds` confirms no hypothesis
  of the schema is dead weight; a dead premise would mean the schema was stated weaker than
  intended.

---

### Phase 6: The increment restriction, refuted at a freed increment [COMPLETED]

**Goal**: Compile the record that freeing the increment makes the schema FALSE even granted the
run-repeat premise — the honesty guard the task description demands, so no later reader can read
the sharpening as licensing an arbitrary lengthening.

**Tasks**:

- [x] Re-read `LadderIdle.lean` immediately before editing.
- [x] Define `IdleGapLengtheningAllIncrements` as `IdleGapLengtheningOfIdleRunRepeat`'s shape with
      `∀ l : ℕ, 0 < l -> ...` in place of `∀ d`, and `I + l` in place of `I + d * k`. Every other
      clause, including the run-repeat premise, is identical.
- [x] Open a namespace for the witness object and define it: three states, one pending (`p`) and
      two idle (`i0`, `i1`), with exactly five admitted edges — `p -> p`, `p -> i0`, `i0 -> i1`,
      `i1 -> i0`, `i1 -> p`. The three denied edges that matter are `i0 -> i0`, `i1 -> i1` and
      `i0 -> p`: the first two deny an idle self-loop and the third denies an exit from `i0`, so
      every idle run begins at `i0`, alternates, ends at `i1`, and therefore has EVEN length.
- [x] Prove the object's forward and backward seriality on the admissible carrier, mirroring
      `Probe838C.fwdO` and `Probe838C.bwdO` case for case: an idle state forces countdown `0`, a
      pending state at countdown `0` steps to `i0`, and at countdown `d + 1` stays pending.
- [x] Define the stab-free atomic closure for the object and prove its closure is a singleton
      with no `stab`, mirroring `Probe838C.closure_aO` and `Probe838C.no_stab_in_closure_aO`.
- [x] Define the witnessing walk: pending at every position at or below `C`, and above `C`
      periodic with period `5` — four idle positions (`i0`, `i1`, `i0`, `i1`) then one pending —
      with the countdown the region through `0` forces (`(C - v).toNat`, clipped) and the register
      constantly `0`. Lift it with `exists_ladderPath_of_walk_nxt_at`.
- [x] Prove the run-repeat premise IS met on this path at `I = 4`: the block at the run's first
      position with `k = 2` is idle throughout and carries both the object repeat (`i0` at both
      ends) and the type repeat.
- [x] *(deviation: altered — the `Fintype QI` instance is written out
      (`⟨{pnd, idl0, idl1}, fun x => by cases x <;> decide⟩`) rather than taken from
      `deriving Fintype`: the deriving handler's generated membership proof does not elaborate
      on this toolchain (`Application type mismatch: QI.enumList_nodup`). Recorded in the
      instance's own docstring.)*
- [x] Prove the parity lemma: on this object no ladder path has an idle run of odd length,
      because a run of length three would need an exit from `i0`, which `step` denies — the
      argument closes by `decide` on the step table plus `objAt_step`.
- [x] Prove `idleGapLengtheningAllIncrements_refuted`: the universally quantified freed-increment
      form is not a theorem, instantiated at this object with `I = 4` and `l = 1`, where the
      conclusion asks for an idle run of length `5`.
- [x] Prove the companion corollary that this object admits `ParamsOk` at the periodicity
      fixpoint's own outputs via `paramsOk_params`, and that `2 <= Tc` there, so the exclusion is
      not an artifact of the schema's dropped parameter hypothesis.
- [x] Add `#print axioms` lines for the exclusion theorem, following the prototype's own closing
      convention.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the witness object, its two seriality proofs, the walk and the parity lemma
are estimated at roughly 280 lines, putting `LadderIdle.lean` near 600 lines and still under the
1500-line ceiling. Confirm with `wc -l` at the phase's close; if the file crosses 1500, add a
`longFile` baseline in this phase rather than deferring it.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle`
covers the edit, which adds declarations to one module and changes no existing signature and no
import.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - the freed-increment schema,
  the witness object, the witnessing path, the parity lemma, and the refutation
- `typst/generated/status.typ` - regenerated line/count figures (pre-commit hook, blocking)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle`
  exits 0 with no warning.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `lean_verify` on `idleGapLengtheningAllIncrements_refuted` reports the standard axiom profile
  with no `sorryAx` — a refutation resting on `sorryAx` records nothing.
- The witness object's `step` table is confirmed to deny `i0 -> i0`, `i1 -> i1` and `i0 -> p` by
  a `decide`-closed lemma, so the parity argument rests on the table and not on an assumption.

---

### Phase 7: The record, the generated surfaces, and the full gate set [NOT STARTED]

**Goal**: Record what the sharpening buys and what it does not, bring every generated surface
back into agreement, and run the repository's complete gate set.

**Tasks**:

- [ ] Re-read every file this phase edits immediately before editing it.
- [ ] Extend `LadderIdle.lean`'s module docstring with a `## What this buys` section recording
      three determinations, each against a named declaration:
      (i) sub-question (i), ADMISSIBILITY, is available under the run-repeat premise, with the
      increment restricted to multiples of the repeat length
      (`idleGapLengtheningOfIdleRunRepeat_holds`), and the pin clause discharges outright rather
      than being carried (`idleSplice_pins`);
      (ii) sub-question (ii), TYPE PRESERVATION, is DISCHARGED and no longer untouched, because
      the premise route runs through the `(objAt, tpOf)` pigeonhole
      (`exists_idleTypeBlock_of_budget_le_run`) and the landed duplication type lemma;
      (iii) the premise is an object/run hypothesis and NOT a consequence of `ParamsOk`
      (`idle_run_lt_tIdle_of_no_idleCycle` is the generic bound without an idle cycle), so it
      does not remove the `ForwardSlackWitnessed` hypothesis from
      `cellAt_subset_of_shift_of_pend_past_rev` and the reserved unrestricted cell obligation
      stays reserved. State clause (iii) as a statement about what is NOT claimed, with no edit
      to `LadderCell.lean`.
- [ ] Add one sentence to `LadderPump.lean`'s module docstring recording that the idle mirror of
      the splice now lives in the three new sections, and that the pin condition the pending
      splice carries is free for an idle block.
- [ ] Regenerate the module-inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`,
      which rewrites the row for `LadderPump.lean`, adds the row for `LadderIdle.lean`, and
      updates the root `README.md` totals block.
- [ ] Re-tighten `LadderPump.lean`'s `longFile` baseline to the value the final measured line
      count admits under the `N - 200 <= lines < N` window, and do the same for `LadderIdle.lean`
      if phase 6 found it crossed the ceiling.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
- [ ] Record issues and wins for this task via `bash .claude/scripts/issue-record.sh` as they
      arose, or attest explicitly that there were none.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - the `## What this buys`
  determination section
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - docstring sentence and the
  re-tightened `longFile` baseline
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - regenerated inventory block
  (exists, and its generated block already carries a `LadderPump.lean` row; if
  `--emit-inventory` reports no registered block for this directory, stop and report rather than
  hand-editing the table)
- `FormalSystem/Metalogic/README.md` - regenerated `dir=FormalSystem/Metalogic` inventory blocks,
  whose subdirectory rows carry this directory's file and line totals (exists)
- `FormalSystem/README.md` - regenerated `dir=FormalSystem rows=loose` inventory block (exists)
- `README.md` - regenerated `dir=FormalSystem rows=totals` inventory block
- `typst/generated/status.typ` - regenerated line/count figures (pre-commit hook, blocking)

**Ancestor-chain note**: `--emit-inventory` rewrites EVERY registered block whose directory
covers a touched Lean path, not only the nearest one, so all four READMEs above are rewritten by
the single run and all four must be staged. `plan-file-scope-harvest.sh` appends this same
ancestor chain to the harvested scope automatically; the entries are listed here so the
implementer stages what the regeneration actually touches rather than discovering the drift at
`--emit-inventory --check`.

**Verification**:

The complete gate set for this repository is the CI gate set in `.github/workflows/ci.yml`, run
locally. Each item is a recorded PASS when it exits 0, or when every finding it reports is
pre-existing, named explicitly, and outside this task's file scope — a repo-wide gate is a
baseline delta, never an absolute zero:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, no
  warning, since CI builds with `--wfail`).
- `lake exe mk_all --lib FormalSystem --check`.
- `lake exe lint-style`.
- `bash scripts/check-module-invariants.sh --no-build`.
- `bash scripts/check-module-invariants.sh --emit-inventory --check`.
- `bash scripts/check-copyright-headers.sh --strict`.
- `bash scripts/readme-lint.sh`.
- `bash scripts/check-metalogic-cycles.sh`.
- `bash scripts/typst-sync-check.sh`.
- `bash scripts/check-paper-definitions.sh`.
- `bash scripts/check-evidence-probes.sh`.
- `lean_verify` on all fourteen named declarations of the `## Lean Challenge Statements` section:
  every one present, every one on the standard axiom profile with no `sorryAx`.

## Lean Challenge Statements

The five `def` declarations below carry their REAL bodies rather than `sorry`. For the three
small ones this is a convenience; for the two schemas it is the point, because a schema's BODY
is its statement and pinning it as `sorry` would pin nothing. `lean-challenge-snapshot.sh` forces
every body to `sorry` when it assembles the Challenge module, so this authoring choice changes
nothing downstream. Verified at authoring time against this repository's own toolchain: the block
below compiles as written, with warnings only on the nine `sorry`-bodied theorems — so both
schemas' full statements type-check, and so does every pinned theorem signature.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-- Cycle lengths among the IDLE object states: the mirror of `objCycleLens`. -/
def idleCycleLens {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool) : Set ℕ :=
  {l | 0 < l ∧ l ≤ Fintype.card Q ∧
    ∃ f : ℕ → Q, (∀ i, step (f i) (f (i + 1)) = true) ∧ (∀ i, pend (f i) = false) ∧ f l = f 0}

theorem no_consecutive_idle_of_no_idle_step {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (hstep : ∀ x y : Q, pend x = false → pend y = false → step x y = false)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (v : ℤ)
    (h0 : pend (objAt g v) = false) : pend (objAt g (v + 1)) = true := sorry

theorem idleCycleLens_of_idle_segment {Q : Type} [Fintype Q] {step : Q → Q → Bool}
    {pend : Q → Bool} (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a : ℤ) (k : ℕ) (hk : 0 < k) (hcard : k ≤ Fintype.card Q)
    (hidle : ∀ i : ℕ, i < k → pend (objAt g (a + (i : ℤ))) = false)
    (hrep : objAt g a = objAt g (a + (k : ℤ))) :
    k ∈ idleCycleLens step pend := sorry

theorem exists_idleCycle_of_card_le_run {Q : Type} [Fintype Q] {step : Q → Q → Bool}
    {pend : Q → Bool} (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) (L : ℕ)
    (hrun : ∀ i : ℕ, i ≤ L → pend (objAt g (z + (i : ℤ))) = false)
    (hlen : (Finset.univ.filter (fun q : Q => pend q = false)).card ≤ L) :
    ∃ i k : ℕ, 0 < k ∧ k ≤ (Finset.univ.filter (fun q : Q => pend q = false)).card ∧
      i + k ≤ L ∧
      objAt g (z + (i : ℤ)) = objAt g (z + (i : ℤ) + (k : ℤ)) ∧
      k ∈ idleCycleLens step pend := sorry

theorem idle_run_lt_tIdle_of_no_idleCycle {Q : Type} [Fintype Q] {step : Q → Q → Bool}
    {pend : Q → Bool} (hno : idleCycleLens step pend = ∅)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (L : ℕ)
    (hrun : ∀ i : ℕ, i ≤ L → pend (objAt g (z + (i : ℤ))) = false) :
    L < tIdle pend := sorry

/-- The countdown the idle-block-duplicated walk forces: unchanged below the block's upper end,
and the original's `l` positions earlier from there on. NOT `spliceCnt`, whose region-raise
clause fires vacuously at an in-block position and returns `l` where `0` is forced. -/
def idleSpliceCnt {Q : Type} {pend : Q → Bool} (g : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ) :
    ℤ → ℕ :=
  fun v => if v < a + (l : ℤ) then cntAt g v else cntAt g (v - (l : ℤ))

theorem exists_idleSpliced_ladderPath {Q : Type} [Fintype Q] [Nonempty Q]
    {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (a : ℤ) (l : ℕ) (hl : 0 < l)
    (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = spliceObj g a l v) ∧
      (∀ v : ℤ, cntAt g' v = idleSpliceCnt g a l v) := sorry

/-- The idle-restricted `(objAt, tpOf)` pigeonhole budget. -/
def idleBudget {Q : Type} [Fintype Q] (pend : Q → Bool) (φ : PlusFormula) : ℕ :=
  (Finset.univ.filter (fun q : Q => pend q = false)).card * 2 ^ (plusSubformulaClosure φ).card

theorem exists_idleTypeBlock_of_budget_le_run {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hg : IsLadderPath step pend g) (z : ℤ) (L : ℕ)
    (hrun : ∀ i : ℕ, i ≤ L → pend (objAt g (z + (i : ℤ))) = false)
    (hbud : idleBudget pend φ ≤ L) :
    ∃ (a : ℤ) (k : ℕ), 0 < k ∧ k ≤ idleBudget pend φ ∧ z ≤ a ∧
      a + (k : ℤ) ≤ z + (L : ℤ) ∧
      (∀ i : ℕ, i < k → pend (objAt g (a + (i : ℤ))) = false) ∧
      objAt g a = objAt g (a + (k : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ a
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)) := sorry

theorem exists_iterIdleSpliced_ladderPath {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (z a : ℤ) (k : ℕ) (hk : 0 < k) (hza : z < a)
    (hidle : ∀ i : ℕ, i < k → pend (objAt g (a + (i : ℤ))) = false)
    (hrep : objAt g a = objAt g (a + (k : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ a
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, v < a + (k : ℤ) → objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v) ∧
      nxtAt g' z = nxtAt g z ∧
      (∀ i : ℕ, i < (d + 1) * k → pend (objAt g' (a + (i : ℤ))) = false) ∧
      (∀ v : ℤ, a + (((d + 1) * k : ℕ) : ℤ) ≤ v →
        objAt g' v = objAt g (v - ((d * k : ℕ) : ℤ)) ∧
          cntAt g' v = cntAt g (v - ((d * k : ℕ) : ℤ))) ∧
      (∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, w < a + (k : ℤ) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' w
            = tpOf (ladderModel step pend fwd bwd lab) φ σ w) := sorry

/-- **THE SHARPENED LENGTHENING.** The idle gap above `z`'s region may be lengthened by `d · k`
when the run carries a `k`-block matching in object state and in realized type — the idle-cycle
premise, met inside the run. `ParamsOk` and `Tc ≤ cntAt g z` are NOT hypotheses: the construction
is idle-run surgery and consumes neither. -/
def IdleGapLengtheningOfIdleRunRepeat {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : Prop :=
  (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      (∀ t : ℤ, σ.state t = (t, g t)) →
    ∀ (z : ℤ) (I k d : ℕ) (a : ℤ),
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) →
      nxtAt g z + 2 ≤ cntAt g z →
      0 < I → 0 < k → 0 < d →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      z + (cntAt g z : ℤ) + 1 ≤ a →
      a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ) →
      objAt g a = objAt g (a + (k : ℤ)) →
      tpOf (ladderModel step pend fwd bwd lab) φ σ a
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)) →
      ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
        objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
        (∀ i : ℕ, i < I + d * k →
          pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + (i : ℤ))) = false) ∧
        pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + d * k : ℕ) : ℤ))) = true ∧
        cntAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + d * k : ℕ) : ℤ))
          = cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) ∧
        ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
          (∀ t : ℤ, σ'.state t = (t, g' t)) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' z
            = tpOf (ladderModel step pend fwd bwd lab) φ σ z

theorem idleGapLengtheningOfIdleRunRepeat_holds {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) :
    IdleGapLengtheningOfIdleRunRepeat step pend fwd bwd lab φ := sorry

/-- **THE FREED-INCREMENT FORM.** `IdleGapLengtheningOfIdleRunRepeat` with the increment freed
from the multiples of the repeat length. Named so the verdict on it is a theorem about a named
object. -/
def IdleGapLengtheningAllIncrements {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : Prop :=
  (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      (∀ t : ℤ, σ.state t = (t, g t)) →
    ∀ (z : ℤ) (I k l : ℕ) (a : ℤ),
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) →
      nxtAt g z + 2 ≤ cntAt g z →
      0 < I → 0 < k → 0 < l →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      z + (cntAt g z : ℤ) + 1 ≤ a →
      a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ) →
      objAt g a = objAt g (a + (k : ℤ)) →
      tpOf (ladderModel step pend fwd bwd lab) φ σ a
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)) →
      ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
        objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
        (∀ i : ℕ, i < I + l →
          pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + (i : ℤ))) = false) ∧
        pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + l : ℕ) : ℤ))) = true ∧
        cntAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + l : ℕ) : ℤ))
          = cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) ∧
        ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
          (∀ t : ℤ, σ'.state t = (t, g' t)) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' z
            = tpOf (ladderModel step pend fwd bwd lab) φ σ z

/-- **THE INCREMENT IS NOT FREE, EVEN UNDER THE PREMISE.** On a three-state object whose idle
states carry a `2`-cycle and no self-loop, every idle run has EVEN length, so a run of length `4`
meeting the premise at `k = 2` admits no lengthening to `5`. -/
theorem idleGapLengtheningAllIncrements_refuted :
    ¬ ∀ (Q : Type) [Fintype Q] [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
        (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
        (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
        (lab : Q → Atom → Bool) (φ : PlusFormula),
        IdleGapLengtheningAllIncrements step pend fwd bwd lab φ := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Every one of the fourteen named declarations is present in the resolved Lean source roots
      under the exact signature pinned in `## Lean Challenge Statements`.
- [ ] `lean_verify` on each of the fourteen reports the standard axiom profile with no `sorryAx`.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 with no
      warning (CI's `--wfail` makes a warning a failure).
- [ ] `lake exe mk_all --lib FormalSystem --check` and `lake exe lint-style` exit 0.
- [ ] `bash scripts/check-module-invariants.sh --no-build` and
      `--emit-inventory --check` exit 0.
- [ ] `bash scripts/typst-sync-check.sh` exits 0, including its Check 2 line-count staleness
      check.
- [ ] `bash scripts/check-copyright-headers.sh --strict`, `bash scripts/readme-lint.sh`,
      `bash scripts/check-metalogic-cycles.sh`, `bash scripts/check-paper-definitions.sh` and
      `bash scripts/check-evidence-probes.sh` each exit 0, or every finding is pre-existing,
      enumerated, and outside this task's file scope.
- [ ] `idleGapLengtheningAllIncrements_refuted` and `idleGapLengtheningOfIdleRunRepeat_holds`
      are both present: the sharpening landed alongside its honesty guard, not instead of it.
- [ ] `grep` confirms no edit landed in `LadderCell.lean`, `LadderChain.lean`, `LadderPin.lean`,
      `docs/theorem-index.md`, or the task 838 prototype.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - three new sections
  (`IdleCycle`, `IdleSplice`, `IdlePigeonhole`), a `longFile` baseline, and a docstring sentence.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - created: the
  register-anchored idle pump, the sharpened schema and its theorem, the freed-increment schema
  and its refutation with the witness object, and the `## What this buys` determination.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - the new import and `## Modules` bullet.
- `FormalSystem.lean` - regenerated library root.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`,
  `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md` and `README.md` - regenerated
  inventory blocks (the whole ancestor chain `--emit-inventory` rewrites).
- `typst/generated/status.typ` - regenerated count figures.
- `scripts/check-metalogic-cycles.sh` - an allowlist entry, only if Assertion B fires.
- `specs/911_idle_cycle_sharpening_idle_gap_lengthening/summaries/01_idle-cycle-sharpening-summary.md`
  at completion.

## Rollback/Contingency

Each phase closes with its own commit, so the unit of rollback is one phase. Nothing in this plan
edits an existing declaration: phases 1-3 add sections to `LadderPump.lean`, phases 4-6 build a
leaf module nothing imports, and phase 7 regenerates machine-owned surfaces. Reverting the whole
task is therefore `git revert` of the task's commits in reverse order, followed by
`lake exe mk_all --lib FormalSystem`, `bash scripts/check-module-invariants.sh --emit-inventory`
and `bash scripts/typst-sync-check.sh --fix` to bring the generated surfaces back.

If a phase must be abandoned mid-way with uncommitted work in the tree, take a durable,
non-reverting checkpoint first — `bash .claude/scripts/git-snapshot.sh --no-revert 911` — rather
than the reverting default form, which is reserved for a genuine rollback; see
`context/contracts/recovery.md`'s rollback rung for that invocation's shape and its
out-of-scope override flag.

Two phase-specific contingencies:

- **Phase 4, if `check-metalogic-cycles.sh` Assertion B fires and the allowlist extension is
  judged unacceptable**: mark the phase `[BLOCKED]` and raise it rather than relocating the
  module, since the import `LadderIdle -> LadderChain` is what the register clause needs.
- **Phase 6, if the witness object's backward seriality on the admissible carrier cannot be
  discharged**: mark the phase `[BLOCKED]` and raise it. Do not weaken
  `idleGapLengtheningAllIncrements_refuted` to a statement about a non-serial object, and do not
  land the sharpened schema without its honesty guard.
