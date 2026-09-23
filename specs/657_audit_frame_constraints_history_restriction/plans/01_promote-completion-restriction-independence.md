# Implementation Plan: Task #657

- **Task**: 657 - audit_frame_constraints_history_restriction
- **Status**: [IMPLEMENTING]
- **Effort**: 11.5 hours
- **Dependencies**: Task 656 (general frames + `FrameOver.IsRegular`; the refactor that made this
  audit statable), Task 659 (the existing constraint witnesses this plan cites rather than
  rebuilds), Task 658 (the state-topology collection)
- **Research Inputs**: `specs/657_audit_frame_constraints_history_restriction/reports/01_audit-frame-constraints-restriction.md`
- **Artifacts**: plans/01_promote-completion-restriction-independence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round returned a **verdict, not an open question**: all four of `def:frame`'s
constraints are kept, nothing is added and nothing is dropped, and every claim is backed by one of
five sorry-free probes (1,012 lines) under `specs/657_.../probes/`. This is therefore a
**promotion plan**. The mathematics is finished and axiom-checked; the work is deciding which
probe content is library-grade, transcribing it into `FormalSystem/` at the correct sites,
correcting the three in-tree docstring defects the audit located, protecting the one probe that is
*not* promoted from rot, and propagating the certification through the module READMEs, the theorem
index and the C14 axiom pins.

The plan follows the report's ranked promotion table (R7) with one deliberate departure: **rank 6
is not promoted into the library**; it is relocated to `specs/evidence/` and wired into
`scripts/check-evidence-probes.sh` instead. See Goals & Non-Goals for why.

### Research Integration

Findings that drive the phase structure:

- **The verdict is "keep all four as stated" (D1).** No phase touches `def:frame`'s axiom list,
  `TaskFrame.Compositional`, `.Serial`, `.Limit` or `.Saturation`. Everything promoted is a
  *result about* those constraints.
- **`Completion` is the exact condition `thm:extension` consumes** (`completion_iff_onePointExtension`,
  `extension_of_completion`), *Saturation* enters only to establish it, and `Compositionality`
  drops out of the extension theorem entirely once `Completion` is assumed. This is the highest
  value item and the report's R1/R7-rank-1; it gets its own new module.
- **`Saturation` is redundant over discrete time** (`extension_of_isZTime`), formalizing
  `lem:step`'s own closing remark. It belongs in the same new module as `Completion` (R7 rank 5),
  since `completion_of_hasNearest` is stated about `Completion`.
- **The anchor case — partial histories *are* restrictions of complete histories — is settled in
  both directions and at the order** (`restrict`, `exists_restrict_eq`,
  `exists_worldHistory_restricting_pair`, `restrict_le_restrict_iff`). The report's §3d says
  keep the coherence definition primitive and state the identification as a corollary; the plan
  does exactly that, which is why nothing in `PartialHistory.lean`'s existing definition changes.
- **The independence matrix is now complete**: the two constraints that had no witness
  (*Seriality*, *Compositionality*) get the void frame and the bump frame. These belong beside the
  existing constraint-failure witnesses (R7 rank 4).
- **Three docstring defects are located, all in files rank 1-3 already touch** (§1a): `constraint`
  under-reports *Limit*, `FrameOver.reflection` over-reports *Seriality*, and `Step.lean`'s "one
  grep hit" claim is false as written. The report says they should land in the same phase as the
  promotions in those files.
- **The probes duplicate `Completion`, `reflection_of_limit` and `extension_of_completion` across
  three files**, because standalone probes cannot import one another. On promotion each is defined
  once; the transcription phases must not land three copies.

### Prior Plan Reference

No prior plan for this task. The sibling task 659's plan
(`specs/659_.../plans/01_promote-saturation-r0-witnesses.md`, [COMPLETED]) is the effort-calibration
reference: a comparable promotion round (1,190 probe lines, 11 phases, 12.75 hours) whose recorded
deviations inform three risks below — the `linter.style.longFile` ceiling, the paired
C14 baseline/heredoc edit, and `readme-lint.sh` firing on a directory whose file count changes.

### Roadmap Alignment

No `roadmap_path` supplied in the dispatch context; no roadmap consultation performed and no
ROADMAP.md phases added.

## Goals & Non-Goals

**Goals**:

- Land `PartialHistory.Completion` and its equivalence with the one-point extension property in a
  new `FormalSystem/Semantics/Extension/Completion.lean`, so the manuscript's R1 (`lem:completion`)
  has a citable declaration and `lem:step`'s attribution can be sharpened.
- Land the discrete-time redundancy result `extension_of_isZTime`: `thm:extension` over `def:BX-z`'s
  ℤ-time from *Compositionality* + *Seriality* + *Limit* alone, no *Saturation*.
- Land the restriction identification — `restrict`, `eq_restrict_of_extends`, `exists_restrict_eq`,
  `exists_worldHistory_restricting_pair`, `restrict_le_restrict_iff` — so the manuscript's R2
  (`cor:restriction`) has citable declarations for both directions and for the order-level form.
- Land `FrameOver.reflection_of_limit` and re-prove `FrameOver.reflection` from it, so the
  library records that the reflection law costs *Limit* **alone** (R3).
- Complete the independence matrix in-tree with the void frame and the bump frame.
- Correct the three located docstring defects, deleting the false claims rather than softening them.
- Keep the mixed-sign obstruction alive as a tracked, compile-guarded record without putting
  `TotalComp` into the library.
- Keep every promoted declaration sorry-free on `[propext, Classical.choice, Quot.sound]` or
  tighter, and preserve the structural invariant the audit certified: **`PartialHistoryOrder.lean`
  contains zero occurrences of `IsRegular`** — the Zorn layer stays constraint-free.

**Non-Goals**:

- **Changing `def:frame`'s axiom list.** D1 is "keep all four as stated". `Completion` is promoted
  as a *lemma about* task frames, never as a constraint field or a replacement for *Saturation*.
  The R4 replacement option is specified in the report and deliberately **not** taken here; see
  the user decision recorded below.
- **Promoting R7 rank 6 (`TaskFrame.TotalComp`, `saturation_of_completion`, `not_totalComp_F0`)
  into `FormalSystem/`.** Three reasons, in order of force. (i) `TotalComp` is a condition the
  library must *not* satisfy — `not_totalComp_F0` exists precisely to record that the drift frame
  `F°` fails it, and giving a refuted condition a library home invites a future reader to add it.
  (ii) The report itself ranks it last, flags `saturation_of_completion` as the longest new proof
  with a `Classical.choose` on a domain predicate, and says that if promoted it needs its own
  regression test — cost the content does not repay. (iii) `scripts/check-evidence-probes.sh`
  already documents the correct home for exactly this genre: "a machine-checked record of a design
  obstruction … the reasons the layer has the shape it has". Phase 8 puts it there, which is
  strictly better than leaving it under a task directory that `/todo` will archive into a
  `.gitignore`d path.
- **Editing the manuscript.** `possible_worlds.tex` and `typst/FormalFoundations.typ` are not
  touched. The dispatch is explicit that the user makes the R1/R2/R3/R5 edits after this task and
  the refactor are both complete; Phase 11 produces the handoff record they will work from.
- **Adding `lem:completion` or `cor:restriction` to `docs/reference/paper-definitions-of-record.md`.**
  That file records *paper* labels; neither label exists in the paper yet. Recording them there
  before the manuscript edit would corrupt the citation source of record and break C15.
- **Settling the final-topology coincidence question (report §5a / R6).** It is labelled UNVERIFIED
  in the report, is used to support nothing, and is routed to a successor task.
- **Determining whether the rational two-origin frame satisfies `Completion`** (§2b's one-probe
  follow-up that would settle `Completion → Saturation`). It is a discovery question, not a
  promotion; `extension_of_completion` landing in Phase 2 is what makes it a one-probe task later.
- **Promoting R5 (`saturation_of_deterministic`) — it is already in the tree.** The report's R5 is a
  *manuscript* recommendation about an existing declaration, so it appears in Phase 11's handoff
  record and nowhere else.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `TaskFrame.lean` is at 2,632 lines against a `linter.style.longFile 2700` ceiling (line 274); Phase 1 adds to it and `--wfail` makes the warning fatal | M | M | Phase 1 measures with `wc -l` after the edit and raises the ceiling in the same commit only if actually crossed — never pre-emptively |
| Three copies of `Completion` / `reflection_of_limit` / `extension_of_completion` land, one per source probe | H | H | Phase 2 owns all three definitions; Phases 3 and 8 are explicitly forbidden from re-declaring them and must consume Phase 2's. Phase 9 gates on `grep -rn "def Completion" FormalSystem/` returning exactly one hit |
| A new `@[simp]` lemma in `PartialHistory.lean` (`restrict_domain`, `restrict_states`) changes simp behavior across the whole development | H | M | Phase 4 is tier `full`: `lake build --wfail` on the entire library, never a scoped build. If either lemma perturbs an unrelated proof, drop the `@[simp]` attribute rather than repairing the downstream proof |
| `restrict_mono` / `restrict_le_restrict_iff` land in `PartialHistoryOrder.lean` carrying an `IsRegular` binder, destroying the constraint-free-Zorn-layer invariant the audit certified | H | M | Phase 4 gates on `grep -c "IsRegular" FormalSystem/Semantics/PartialHistoryOrder.lean` returning **0**, exactly as today. The `[F.IsRegular]` results go to `Extension/Extension.lean` in Phase 5 instead |
| `Extension/Completion.lean` needs `FrameProperty` (for `IsZTime`) and `PartialHistoryOrder` (for Zorn), creating an import cycle or a widened closure | M | L | Both import only `FormalSystem.Semantics.TaskFrame` / `PartialHistory` respectively — verified: no cycle is possible. Phase 3 runs `lake build --wfail` and Phase 9 re-checks the module graph |
| Docstring corrections disturb a `check-paper-definitions.sh` anchor or a hashed `verbatim:` block | H | L | All three corrections are to prose *about the Lean proof*, not to any recorded quotation. Phase 7 gates on `bash scripts/check-paper-definitions.sh` passing and on `git diff` showing no `verbatim:` line changed |
| The audit's own claim that `step` is the sole *Saturation* elimination site silently stops holding once `Completion` gives a second route | M | M | Phase 7's replacement docstring states the *accurate* claim the audit verified ("the sole site where *Saturation* is eliminated into a non-*Saturation* conclusion") rather than the false grep claim, and Phase 11 re-derives the five `F.saturation` application sites by grep before closing |
| The relocated evidence probe is wired into `check-evidence-probes.sh` but its `EVIDENCE` variable is hard-coded to the bi-lasso directory | M | H | Phase 8 must read the script first: `EVIDENCE="specs/evidence/bi-lasso-decision-layer"` is a single-directory constant, so wiring a second collection requires generalizing it (per-entry paths or a second loop), not just appending to `WIRED` |
| C14 baseline and its `#print axioms` heredoc edited out of step (compared by exact string equality) | H | M | Phase 10 edits `C14_BASELINE` and the `C14LEAN` source heredoc together, appending in the same order in both — the recorded failure mode from the sibling promotion round |
| New `.lean` files change a directory's file count and surface `readme-lint.sh`'s missing/stale-README checks on directories the plan did not list | M | M | Phase 9 runs `readme-lint.sh` and `check-module-invariants.sh --emit-inventory` and treats any newly surfaced README obligation as in-scope for that phase rather than deferring it |
| `omega` fails on `↑intOrder`-typed goals during transcription of the two witnesses | L | H | The report's tactic survey: state binders at `(x : ℤ)`, or route through `TaskFrame.limit_of_succOrder` with `SuccOrder`/`NoMaxOrder` instances supplied explicitly and `Mathlib.Data.Int.SuccPred` imported |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4, 6 | -- |
| 2 | 2, 5 | 1, 4 |
| 3 | 3, 7, 8 | 2 |
| 4 | 9 | 3, 5, 6 |
| 5 | 10 | 9 |
| 6 | 11 | 7, 8, 10 |

Phases within the same wave can execute in parallel; each wave-1 phase edits a different file
(`TaskFrame.lean`, `PartialHistory.lean`+`PartialHistoryOrder.lean`, `ConstraintWitnesses.lean`).

---

### Phase 1: `FrameOver.reflection_of_limit` and the reflection docstring correction [COMPLETED]

**Goal**: Record in the library that the reflection law costs *Limit* **alone**, and delete the
docstring sentence that says otherwise. This is the report's R3 and R7 rank 2, and it is the
foundation Phase 2 consumes.

**Tasks**:
- [ ] Read `probes/Completion.lean:111-133` (`reflection_of_limit`) and locate `FrameOver.reflection`
      at `FormalSystem/Semantics/TaskFrame.lean:1158`
- [x] Transcribe the probe's proof as `FrameOver.reflection_of_limit (F : FrameOver D)
      (hlim : TaskFrame.Limit F.TaskRel) (w : F.WorldState) (d : ↑D) …` — a hypothesis binder, **not**
      an `[F.IsRegular]` instance binder; that is the whole point of the declaration. Site it
      immediately before `reflection` *(deviation: altered — landed at `[propext, Classical.choice,
      Quot.sound]`, not the plan's predicted `[propext]`; the probe's figure was measured at the
      `TaskFrame` level, and `FrameOver.eq_of_taskRel_zero_of_limit` at this level already carries
      choice. `FrameOver.reflection`'s own profile is byte-identical before and after, which is the
      invariant that mattered.)*
- [ ] Re-prove `FrameOver.reflection` as `reflection_of_limit F F.limit …` (or whatever the
      `IsRegular` accessor for *Limit* is named — read it off the class rather than guessing), leaving
      its statement byte-identical so no call site changes
- [ ] **Correct `reflection`'s docstring** (defect 2 of 3, report §1a): the current text says the zero
      case uses `eq_of_taskRel_zero` "and `nullity` (*Seriality* plus *Limit*)". The proof body never
      calls `nullity`. Delete that clause and state that the zero case is `eq_of_taskRel_zero` in both
      directions, i.e. *Limit* alone, citing `reflection_of_limit`
- [ ] Do **not** change `TaskFrame.reflection` (line ~2437) — it is a citation wrapper and its
      `[F.IsRegular]` binder is correct for its level
- [ ] Measure `wc -l FormalSystem/Semantics/TaskFrame.lean`; raise `linter.style.longFile` at line 274
      only if the file now exceeds 2,700

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: one new declaration (~20 lines) plus one docstring paragraph, in one file;
the file is 2,632 of 2,700 permitted lines. Confirm with `wc -l` and `git diff --stat` before
committing. A delta above ~40 lines means the probe proof was transcribed with scaffolding that
`TaskFrame.lean` already provides — strip it rather than raising the ceiling.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - add `FrameOver.reflection_of_limit`; re-prove
  `FrameOver.reflection` from it; correct `reflection`'s docstring

**Verification**:
- `lake build --wfail` green (`TaskFrame.lean` is the most widely imported module in the library; a
  scoped build is not sufficient)
- `#print axioms FormalSystem.Semantics.FrameOver.reflection_of_limit` reports `[propext]` or
  tighter, matching the probe
- `#print axioms FormalSystem.Semantics.FrameOver.reflection` is unchanged from before the edit
- `grep -n "nullity" ` on the `reflection` docstring region returns nothing
- No `sorry` in the changed region

---

### Phase 2: New module `Extension/Completion.lean` — the exact condition `thm:extension` needs [COMPLETED]

**Goal**: Land the audit's headline Q1 result: `Completion` is what `lem:step` actually consumes,
it is equivalent to the one-point extension property, and it yields `thm:extension` in full from
*Seriality* + *Limit* with no *Saturation* and no *Compositionality*.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Extension/Completion.lean` with the standard copyright header,
      importing `FormalSystem.Semantics.Extension.Admissible` and
      `FormalSystem.Semantics.PartialHistoryOrder` (the Zorn layer, needed by
      `extension_of_completion`; it carries no frame constraint) *(deviation: altered — imports
      `Extension.Step`, not `Extension.Admissible`. `completion_of_isRegular` is defined as
      `completion_of_onePointExtension (fun τ z => step F τ z)`, so `step` must be in scope;
      `Step.lean` imports `Admissible.lean`, so the closure is unchanged apart from `Step` itself.
      The aggregator import in Phase 9 is correspondingly sited after `Step`, not before it.)*
- [ ] Write the module docstring in the directory's house style: the paper anchors it serves
      (`lem:step`, `lem:admissible`, `thm:extension`), the verdict it records (*Saturation* is
      sufficient, `Completion` is exactly necessary-and-sufficient for the one-point extension
      property), and an explicit statement that this module does **not** propose replacing
      *Saturation* in `def:frame` — D1 keeps all four constraints
- [ ] Transcribe from `probes/Completion.lean`, in the probe's order: `Completion`,
      `CoherentCompletion`, `completion_iff_coherentCompletion`, `OnePointExtension`,
      `completion_of_onePointExtension`, `onePointExtension_of_completion`,
      `completion_iff_onePointExtension`, `completion_of_isRegular`, `extension_of_completion`
- [ ] Replace the probe's local copy of `reflection_of_limit` with Phase 1's
      `FrameOver.reflection_of_limit`. The probe's copy is in the `PartialHistory` namespace; the
      promoted one is `FrameOver.` — adjust the call sites, do not re-declare
- [ ] Keep `CoherentCompletion` and `completion_iff_coherentCompletion`: the bare-coherent-family
      form mentions no notion of history and is the form R4 would need if the author ever takes the
      replacement option, so it is the one piece of R4 worth landing now
- [ ] Docstring `completion_of_isRegular` with the consumption fact the audit established: it routes
      through the existing `step`, so *Saturation* enters here and nowhere else
- [ ] Docstring `extension_of_completion` with the orthogonality certificate: it elaborates with **no**
      `[F.IsRegular]` binder at all, which is the machine-checked form of "Zorn and the four
      constraints meet only at `extension`"

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: the probe is 201 lines of which ~150 are the promoted declarations (the rest
is the preamble and the `AxiomCheck` section, neither of which is promoted); the new module is
expected at roughly 200-260 lines including its docstrings. Confirm with `wc -l` after landing; a
figure above ~320 means scaffolding was carried over that `Admissible.lean` already provides.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Completion.lean` - new module

**Verification**:
- `lake build --wfail` green
- `#print axioms` reports, matching the probe: `completion_of_onePointExtension` and
  `completion_iff_coherentCompletion` at `[propext]`; `onePointExtension_of_completion`,
  `completion_of_isRegular`, `extension_of_completion` at `[propext, Classical.choice, Quot.sound]`
  or tighter
- `extension_of_completion`'s signature carries **no** `[F.IsRegular]` binder
- `grep -c sorry FormalSystem/Semantics/Extension/Completion.lean` returns 0
- The module is not yet imported by anything — Phase 9 wires it

---

### Phase 3: `HasNearest` and `extension_of_isZTime` — *Saturation* is redundant over discrete time [COMPLETED]

**Goal**: Turn `lem:step`'s own closing remark into a theorem: over `def:BX-z`'s ℤ-time,
`thm:extension` follows from *Compositionality* + *Seriality* + *Limit* alone.

**Tasks**:
- [ ] Append to `FormalSystem/Semantics/Extension/Completion.lean`, under a new `## Discrete time`
      section heading, transcribing from `probes/Nearest.lean`: `HasNearest`, `hasNearest_int`,
      `hasNearest_of_succPred`, `completion_of_hasNearest`, `extension_of_hasNearest`,
      `extension_of_isZTime`
- [ ] Add the imports the probe needed and `Admissible.lean` does not supply:
      `Mathlib.Data.Int.LeastGreatest`, `Mathlib.Order.SuccPred.Archimedean`, and
      `FormalSystem.Semantics.FrameProperty` (for `TaskFrame.IsZTime`). `FrameProperty` imports only
      `TaskFrame`, so no cycle is possible — confirm with `lake build`, not by inspection alone
- [ ] Do **not** re-declare `Completion`, `reflection_of_limit` or `extension_of_completion` — the
      probe carries its own copies because probes cannot import one another; Phase 2 owns all three
- [ ] Docstring `completion_of_hasNearest` with the sharp fact: it uses `C` + `S` + `HasNearest` and
      **neither `Sat` nor `L`**, because it excludes `z ∈ dom τ` first and so never reaches
      `reflection` at duration zero. This is the one *Limit*-free route through the chain and it
      should be recorded as such
- [ ] Docstring `extension_of_isZTime` with the job description it gives *Saturation*: needed only
      over temporal orders where a subset of times can approach a time without reaching a nearest
      one — i.e. only over dense time. Cross-reference the two existing free classes,
      `TaskFrame.saturation_of_finite` (`cor:saturation-finite`) and
      `TaskFrame.saturation_of_deterministic`, and `Extension/PeriodicExtension.lean` as the
      independent Zorn-free confirmation over ℤ-time with a finite carrier
- [ ] Use `abel`, not `ring`, on the four duration-group goals — the duration carrier is
      `AddCommGroup` + `LinearOrder`, not a ring (report tactic survey)

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: `probes/Nearest.lean` is 263 lines, of which ~180 are the six promoted
declarations (the rest is the duplicated `Completion`/`reflection_of_limit`/`extension_of_completion`
preamble Phase 2 already owns, plus `AxiomCheck`). The append is expected at ~200 lines, taking
`Completion.lean` to roughly 400-460. Confirm with `wc -l`; if it crosses a `longFile` ceiling,
split the discrete-time section into its own module rather than raising the ceiling.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Completion.lean` - append the discrete-time section; add three
  imports

**Verification**:
- `lake build --wfail` green
- `#print axioms` on `hasNearest_int`, `hasNearest_of_succPred`, `completion_of_hasNearest`,
  `extension_of_hasNearest`, `extension_of_isZTime` each reports
  `[propext, Classical.choice, Quot.sound]` or tighter
- `grep -c "def Completion" FormalSystem/Semantics/Extension/Completion.lean` returns exactly 1
- `completion_of_hasNearest`'s signature carries no *Limit* and no *Saturation* hypothesis
- No `sorry` in the module

---

### Phase 4: The restriction map — constraint-free core [COMPLETED]

**Goal**: Land the easy direction of the anchor case, which the audit certified costs **no frame
constraint and not even `[F.IsRegular]`**, plus the two order-level facts that are equally free.

**Tasks**:
- [ ] Transcribe into `FormalSystem/Semantics/PartialHistory.lean`, from `probes/Restriction.lean`:
      `restrict`, `restrict_domain`, `restrict_states` (both `@[simp]`), `restrict_isPartialHistory`,
      `extends_restrict`, `restrict_univ`, `IsRestriction`, `eq_restrict_of_extends`
- [ ] Transcribe into `FormalSystem/Semantics/PartialHistoryOrder.lean`: `restrict_mono` and
      `restrict_le_restrict_iff`. Both are stated at `≤` and neither carries a frame constraint, so
      they belong with the order and **must not** bring an `IsRegular` binder with them
- [ ] Write a docstring on `restrict` recording the audit's strongest finding about it: its four
      fields are the time set, the nonemptiness hypothesis, the world history's states, and its
      `respects_task` — **with no glue at all**. The coherence condition of a restriction *is* the
      world history's own, which is why the direction is free
- [ ] Write a docstring on `eq_restrict_of_extends` recording that it is an equality of
      `PartialHistory` values, and the transcription trap the report's tactic survey names: a
      non-dependent `congrArg` on the structure literal does **not** typecheck, because
      `respects_task`'s type depends on `states`. Destructure and substitute the `states` variable,
      then close by `rfl`
- [ ] Write a docstring on `restrict_le_restrict_iff` stating what it and
      `exists_worldHistory_restricting_pair` (Phase 5) together give: restriction is an
      order-surjection, not merely a pointwise one
- [ ] Do **not** change the existing definition of `PartialHistory` — report §3d is explicit that the
      coherence definition stays primitive and restriction is defined from it, never the reverse

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: 8 declarations into `PartialHistory.lean` (~75 lines) and 2 into
`PartialHistoryOrder.lean` (~20 lines); the files are 501 and 209 lines today. Confirm with
`git diff --stat`. Both files are widely imported, so any figure materially above this is a signal
that a dependency was inlined rather than cited.

**Files to modify**:
- `FormalSystem/Semantics/PartialHistory.lean` - the restriction map and the constraint-free facts
- `FormalSystem/Semantics/PartialHistoryOrder.lean` - the two order-level facts

**Verification**:
- `lake build --wfail` green (full build — two new `@[simp]` lemmas change simp behavior library-wide)
- `grep -c "IsRegular" FormalSystem/Semantics/PartialHistoryOrder.lean` returns **0**, exactly as
  before the edit — the Zorn layer stays constraint-free
- `#print axioms` on `restrict`, `restrict_isPartialHistory`, `restrict_le_restrict_iff` reports
  `[propext]`; `eq_restrict_of_extends` reports `[propext, Quot.sound]`
- No previously-passing proof anywhere in the library required repair; if one did, the `@[simp]`
  attribute is dropped instead
- No `sorry` in either file

---

### Phase 5: The identification at `[F.IsRegular]` — `cor:restriction`'s hard direction [COMPLETED]

**Goal**: Land the hard direction and the order-level surjection, at the module that already owns
`thm:extension`, so the corollary sits directly beneath the theorem it is.

**Tasks**:
- [ ] Transcribe into `FormalSystem/Semantics/Extension/Extension.lean`, after `extension` and before
      or beside `occurrence`, from `probes/Restriction.lean`: `isRestriction_of_isRegular`,
      `exists_restrict_eq`, `exists_worldHistory_restricting_pair`
- [ ] Add a `## The identification` section to the module docstring recording R2's content in both
      directions and the asymmetry that **is** the content: the first conjunct costs no frame
      constraint (Phase 4), the second is `thm:extension` exactly and nothing more
- [ ] Record in the same section the §3d verdict and its four reasons in brief — the paper keeps
      partial histories defined by coherence and states the identification as a corollary, because
      defining them as restrictions would make `thm:extension` a tautology while relocating rather
      than removing its content, would make `lem:constraint`/`lem:admissible` presuppose the world
      they build, and would deprive the Zorn argument of a poset with chain suprema
- [ ] Do not add a `cor:restriction` anchor to any docstring as though it were a live paper label —
      the label does not exist in the manuscript yet. Refer to it as *proposed* and point at this
      task's report

**Timing**: 1.0 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: 3 declarations (~35 lines) plus a docstring section (~25 lines) into a
272-line module. Confirm with `git diff --stat`.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Extension.lean` - the three `[F.IsRegular]` identification results
  and the docstring section

**Verification**:
- `lake build --wfail` green
- `#print axioms exists_restrict_eq` and `#print axioms exists_worldHistory_restricting_pair` each
  report `[propext, Classical.choice, Quot.sound]`
- `thm:extension`'s own statement and proof are byte-unchanged (`git diff` on the `extension` block
  shows only additions beneath it)
- No `sorry` in the module

---

### Phase 6: The last two independence witnesses — the void frame and the bump frame [COMPLETED]

**Goal**: Complete the independence matrix in-tree. Every one of `def:frame`'s four constraints
then has a compiled witness satisfying the other three and failing it.

**Tasks**:
- [ ] Transcribe from `probes/Independence.lean` into
      `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — already the home of
      constraint-failure witnesses — the void frame block (`voidRel`, `voidRel_refl_law`, `voidFrame`,
      `voidFrame_taskRel`, `voidFrame_compositional`, `voidFrame_limit`, `voidFrame_saturation`,
      `voidFrame_not_serial`) and the bump frame block (`bumpRel`, `bumpRel_refl_law`, `bumpFrame`,
      `bumpFrame_taskRel`, `bumpFrame_serial`, `bumpFrame_limit`, `bumpFrame_saturation`,
      `bumpFrame_not_compositional`)
- [ ] Namespace them as the existing witnesses are namespaced; follow the file's local convention
      rather than the probe's `ConstraintIndependence` namespace if the file already has one
- [ ] Add `Mathlib.Data.Int.SuccPred` to the module's imports if `bumpFrame_limit`'s route through
      `TaskFrame.limit_of_succOrder` needs it
- [ ] Give each frame a docstring naming the constraint it refutes and why the shape refutes it: the
      void frame is the empty task relation on `Bool` over ℤ-time (every constraint is vacuous except
      *Seriality*, which needs a successor to exist); the bump frame is identity at `0`, everything at
      `±1` and identity from `|d| ≥ 2` (composition of two `±1` steps lands outside the `|d| ≥ 2`
      identity, which is exactly the failure)
- [ ] Record in each docstring that *Saturation* is free by `TaskFrame.saturation_of_finite`
      (`cor:saturation-finite`) because the carrier is finite, and *Limit* by
      `TaskFrame.limit_of_succOrder` because the time is ℤ — neither is proved by hand
- [ ] Add a module-docstring paragraph stating that **the matrix is now complete**, with the four
      rows and their witnesses: bump (¬`C`), void (¬`S`), the four-state funnel (¬`L`), the rational
      two-origin frame (¬`Sat`)
- [ ] Record honestly in that paragraph the packaging asymmetry the audit found: three witnesses are
      certified at the frame level, but `RationalTwoOrigins.rel` is certified at the **bare-relation**
      level only, with no `FrameOver` wrapper, because wrapping it would need a reflection law for
      its carrier that the module does not prove. The independence is genuine at the level
      `def:frame` states its constraints; do not overstate the row
- [ ] Do **not** declare an `IsRegular` instance for either new frame — each fails one constraint by
      construction
- [ ] Measure the file (582 lines today) and check its `longFile` ceiling before committing

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: 16 declarations, ~130 lines, into a 582-line module. Confirm with `wc -l` and
`git diff --stat` before and after.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` - the two new witnesses and the
  completed-matrix docstring paragraph

**Verification**:
- `lake build --wfail` green
- `#print axioms` on all eight headline witness facts; `voidFrame_compositional` and
  `voidFrame_not_serial` report `[propext, Quot.sound]`, the rest `[propext, Classical.choice,
  Quot.sound]` or tighter
- `grep -n "IsRegular" ` on the two new blocks returns nothing
- `Tests/BimodalTest/Semantics/StateTopologyTest.lean` still builds
- No `sorry` in the module

---

### Phase 7: The two remaining docstring defects [COMPLETED]

**Goal**: Delete the two false claims the audit located in `Extension/`, replacing each with the
claim the audit actually verified. (The third, in `FrameOver.reflection`, lands in Phase 1 — it is
in a different file.)

**Tasks**:
- [ ] `FormalSystem/Semantics/Extension/Constraint.lean`, `constraint`'s docstring: the sentence
      "*Limit* is not consumed either" is **wrong** at the level of the elaborated proof term.
      `constraint` reaches `FrameOver.reflection` on three paths
      (`fib_subset_fib_of_le_of_le'`, `nonempty_fib_of_serial`, `nonempty_seg_of_interpolates`), and
      `reflection`'s `d = 0` branch is discharged by *Limit*. The zero case is genuinely reachable:
      `nonempty_fib_of_serial` at `t = z` invokes `reflection` at duration `0`. Replace the sentence
      with the accurate consumption list `C→`, `C←`, `S`, `L` — and **not** `Sat`
- [ ] Same file, `nonempty_fib_of_serial`'s docstring: the same caveat applies to its "No other axiom
      is used" claim. Correct it the same way
- [ ] In both corrections, record that a *Limit*-free route exists in principle — the `d ≠ 0` branch is
      definitional (`TaskFrame.reflect_reflection_of_ne`) — but that no declaration in the current
      tree takes it, and cite `completion_of_hasNearest` (Phase 3) as the one declaration that does
      take exactly that route, by excluding `z ∈ dom τ` first
- [ ] `FormalSystem/Semantics/Extension/Step.lean`, module docstring: the claim "a `grep` for
      `Saturation` across `FormalSystem/` should therefore find exactly one consuming proof" is false
      as written — `F.saturation` is *applied* at five sites. Replace it with the claim that survives
      the audit: **`step` is the sole site where *Saturation* is eliminated into a
      non-*Saturation* conclusion**, and name the four transport/restatement sites
      (`OpenLanguage/OpenReversal.lean`, `Semantics/IntTransfer.lean`,
      `Semantics/Frames/TranslationProduct.lean`,
      `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`,
      `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`) as taking *Saturation* in and
      giving *Saturation* out
- [ ] Re-derive the site list by `grep -rn "\.saturation\b" FormalSystem/` at implementation time
      rather than trusting the list above — the report names five files for what it calls five sites,
      which is one more file than the arithmetic allows, so the discrepancy must be resolved by
      measurement before it is written into a docstring
- [ ] Add a pointer from `Step.lean`'s docstring to `Extension/Completion.lean`: what `step` consumes
      is exactly `Completion`, and *Saturation* enters only to establish it
- [ ] Change no `verbatim:` block, no recorded paper quotation, and no code

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/Constraint.lean` - `constraint` and `nonempty_fib_of_serial`
  docstrings
- `FormalSystem/Semantics/Extension/Step.lean` - module docstring

**Verification**:
- `lake build --wfail` on the two changed modules is green
- `grep -n "Limit. is not consumed either" FormalSystem/Semantics/Extension/Constraint.lean` returns
  nothing
- `grep -n "exactly one consuming proof" FormalSystem/Semantics/Extension/Step.lean` returns nothing
- `bash scripts/check-paper-definitions.sh` passes
- `git diff` shows no line inside a `verbatim:` block changed

---

### Phase 8: Relocate the mixed-sign obstruction to `specs/evidence/` and guard it [NOT STARTED]

**Goal**: Keep the Q4 verdict "mixed-sign composition is not addable" alive as a compile-guarded,
version-controlled record — without giving a refuted condition a home in `FormalSystem/`.

**Tasks**:
- [ ] Read `scripts/check-evidence-probes.sh` in full first. Its `EVIDENCE` variable is a **single**
      hard-coded directory (`specs/evidence/bi-lasso-decision-layer`), so wiring a second collection
      requires generalizing the loop (per-entry relative paths, or a second collection block) — not
      merely appending to `WIRED`. Choose the smaller generalization and keep the existing entries'
      behavior byte-identical
- [ ] Create `specs/evidence/frame-constraints-audit/` and move `probes/MixedSign.lean` there as
      `mixed-sign-composition-obstruction.lean`
- [ ] Rewrite its header docstring to the genre the script's own header defines: state the design
      decision it holds in place — *mixed-sign composition (`TotalComp`) must not be added to
      `def:frame`, because `not_totalComp_F0` plus `fzeroFrame_isRegular` show the drift frame `F°`
      satisfies all four constraints and fails `TotalComp`, and `app:drift` needs `F°` for
      `cor:no-characterization`* — and state the positive content it also carries:
      `saturation_of_completion`, i.e. `Completion → Saturation` holds **under** `TotalComp`, which
      is what locates the obstruction exactly
- [ ] Replace the probe's local copies of `Completion` and `reflection_of_limit` with imports of the
      promoted `FormalSystem.Semantics.Extension.Completion` and Phase 1's
      `FrameOver.reflection_of_limit`. An evidence probe is compiled by `lake env lean` against the
      built library, so it *can* import — unlike a task-directory probe
- [ ] Add the file to `WIRED` and add its row to the script's WIRED comment table, in the table's
      existing two-column style
- [ ] Add a `README.md` to `specs/evidence/frame-constraints-audit/` if the sibling collections have
      one; match whatever convention `specs/evidence/translation-product/` uses
- [ ] Leave the other four probes where they are — their content is promoted in Phases 1-6, so the
      library is now the record and the probe copies are redundant

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: one file moved, one script generalized (one variable plus one loop), one
`WIRED` entry, one comment-table row. Confirm with `git status` and `git diff --stat`; a larger
script diff means the generalization went further than needed and should be trimmed.

**Files to modify**:
- `specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean` - moved from
  `specs/657_.../probes/MixedSign.lean`, re-headed, imports rewired
- `scripts/check-evidence-probes.sh` - generalize `EVIDENCE`; add the WIRED entry and its table row

**Verification**:
- `bash scripts/check-evidence-probes.sh` passes, reporting PASS for the four existing probes **and**
  the new one
- `lake env lean specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean`
  prints only its `#print axioms` lines
- `grep -c "def Completion\|def TotalComp" ` on `FormalSystem/` shows `Completion` once (Phase 2) and
  `TotalComp` **zero** times — the Non-Goal held
- `git status` shows the file tracked under `specs/evidence/`, not under the task directory

---

### Phase 9: Wire the new module into the generated root and refresh the READMEs [NOT STARTED]

**Goal**: `Extension/Completion.lean` reaches the build through the generated root and through the
directory aggregator, and every README that inventories these directories records the new content.

**Tasks**:
- [ ] Add `import FormalSystem.Semantics.Extension.Completion` to
      `FormalSystem/Semantics/Extension.lean`, sited after `Admissible` and before `Step` — the
      position report R7 rank 1 specifies — and add its row to that aggregator's `## Modules` list
- [ ] Run `lake exe mk_all --lib FormalSystem` to regenerate `FormalSystem.lean`; confirm the single
      new import lands beside the other `Semantics.Extension.*` entries and the file is otherwise
      byte-unchanged (C33 compares it exactly)
- [ ] Update `FormalSystem/Semantics/Extension/README.md`: add the `Completion.lean` row to the
      `## Modules` table with its measured line count and its description; update the
      `Admissible.lean`, `Constraint.lean`, `Extension.lean` and `Step.lean` line counts, which
      Phases 5 and 7 changed; extend the prose chain paragraph and the `## Key Results` section
- [ ] Amend that README's sentence "`Step.lean` is **the only place in the development where the
      Saturation axiom is consumed**" to the audited form — the sole *elimination* site — and add the
      discrete-time redundancy result beside the `PeriodicExtension.lean` paragraph, which already
      makes the ℤ-time point from the constructive side
- [ ] Update `FormalSystem/Semantics/README.md` rows for `PartialHistory.lean`,
      `PartialHistoryOrder.lean`, `Extension/` and `StateTopology/` to reflect the new content and
      line counts
- [ ] Run `bash scripts/readme-lint.sh` and `bash scripts/check-module-invariants.sh --emit-inventory`.
      Treat any newly surfaced README obligation as in-scope for this phase — the sibling promotion
      round recorded exactly this surprise when a directory's file count changed
- [ ] Confirm by grep that `Extension/Completion.lean` is reached only from
      `FormalSystem/Semantics/Extension.lean` and the generated root, and from no other aggregator

**Timing**: 0.75 hours

**Depends on**: 3, 5, 6

**Verification Tier**: full

**Scope Hypothesis**: one new root import line, one new aggregator import, one new README table row
plus ~6 edited line-count cells. Confirm with `git diff --stat`; a larger root diff means `mk_all`
picked up something unintended and must be investigated before proceeding.

**Files to modify**:
- `FormalSystem/Semantics/Extension.lean` - import and module-list row
- `FormalSystem.lean` - regenerated
- `FormalSystem/Semantics/Extension/README.md` - module table, chain prose, key results
- `FormalSystem/Semantics/README.md` - affected rows

**Verification**:
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `lake build --wfail` green
- `bash scripts/readme-lint.sh` passes
- `grep -rn "Extension.Completion" FormalSystem/` shows the module reached only from
  `FormalSystem.lean` and `FormalSystem/Semantics/Extension.lean`

---

### Phase 10: Certification sweep — theorem index and C14 axiom pins [NOT STARTED]

**Goal**: Every document that records what the library certifies records the new truth.

**Tasks**:
- [ ] `docs/theorem-index.md`: add rows for `PartialHistory.Completion`,
      `completion_iff_onePointExtension`, `completion_of_isRegular`, `extension_of_completion`,
      `extension_of_isZTime`, `PartialHistory.restrict`, `exists_restrict_eq`,
      `exists_worldHistory_restricting_pair`, `restrict_le_restrict_iff`,
      `FrameOver.reflection_of_limit`, and the eight new witness facts, anchored to the paper labels
      the report's §6 table names (`lem:step`, `thm:extension`, `cor:occurrence`, `def:world-history`,
      `def:task-relation`, `def:BX-z`, `def:frame` and its four sub-anchors)
- [ ] Read the `Frame class` column's definition at `docs/theorem-index.md:17` before filling it. Its
      vocabulary is `Base | Dense | ZTime | RTime` with `—` for class-generic. `extension_of_isZTime`
      is the one new row that genuinely takes `ZTime`; everything else is class-generic and takes `—`.
      Do **not** write "Regular" into that column — regularity belongs in the Statement column
- [ ] `scripts/check-module-invariants.sh`: append the new headline declarations to `C14_BASELINE`
      **and** to the `C14LEAN` `#print axioms` source heredoc, **in the same order in both** — they
      are compared by exact string equality
- [ ] Do **not** add `lem:completion` or `cor:restriction` to
      `docs/reference/paper-definitions-of-record.md` — neither label exists in the manuscript, and
      C15 round-trips that file against the paper
- [ ] Check whether `docs/reference/state-topology-appendix-support.md` carries an independence-matrix
      row that the two new witnesses complete; update it if so, and leave it alone if not
- [ ] Do **not** edit `possible_worlds.tex` or `typst/FormalFoundations.typ`

**Timing**: 1.0 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: ~18 new theorem-index rows and one paired C14 edit. Both counts are
pre-implementation estimates — re-derive the exact declaration list from Phases 1-6's landed
`#print axioms` output and reconcile before closing.

**Files to modify**:
- `docs/theorem-index.md` - new rows
- `scripts/check-module-invariants.sh` - `C14_BASELINE` and the `C14LEAN` heredoc
- `docs/reference/state-topology-appendix-support.md` - only if it carries an independence-matrix row

**Verification**:
- `bash scripts/check-module-invariants.sh` passes, C14 and C15 included
- `git diff docs/reference/paper-definitions-of-record.md` is empty
- `git status` shows no manuscript file touched

---

### Phase 11: Full gate run, axiom record, and the manuscript handoff [NOT STARTED]

**Goal**: Close the task on the documented gate set, with a per-declaration axiom record and a
single handoff document the user can make the manuscript edits from.

**Tasks**:
- [ ] `lake build --wfail` — green, no warnings
- [ ] `bash scripts/check-module-invariants.sh` — every check passes (C2, C3's sorry inventory, C14,
      C15, C20, C21, C24, C33)
- [ ] `lake exe mk_all --lib FormalSystem --check` — exits 0
- [ ] `bash scripts/check-evidence-probes.sh` — five probes PASS
- [ ] `bash scripts/check-paper-definitions.sh` and `bash scripts/readme-lint.sh` — pass
- [ ] `#print axioms` on every promoted headline declaration; record the result per declaration in the
      execution summary
- [ ] Re-derive by grep, and record, the `F.saturation` application sites, confirming that `step`
      remains the sole elimination-into-a-non-*Saturation*-conclusion site now that
      `completion_of_isRegular` routes through it
- [ ] Confirm the Non-Goals held, each by an explicit check: `grep -rn "TotalComp" FormalSystem/`
      returns nothing; `def:frame`'s four constraint definitions are byte-unchanged; no manuscript
      file appears in `git status`; `grep -c IsRegular FormalSystem/Semantics/PartialHistoryOrder.lean`
      is 0; `grep -n "lem:completion\|cor:restriction" docs/reference/paper-definitions-of-record.md`
      returns nothing
- [ ] Write the execution summary at
      `specs/657_audit_frame_constraints_history_restriction/summaries/01_promote-completion-restriction-independence-summary.md`
      recording, per audit question (Q1 necessity, Q1 redundancy, Q2, Q3, Q4, Q5), the verdict, the
      landed declaration names, and what each licenses the manuscript to say
- [ ] Include in that summary a **manuscript handoff section**: R1's `lem:completion` block, R2's
      `cor:restriction` block, R3's one-sentence reflection remark and R5's
      `lem:saturation-deterministic` block, each reproduced in the paper's house style from the
      report, each now citing the **promoted** declaration name rather than the probe name, and each
      with the manuscript sites it would change. Record R4 as specified-but-not-taken, and R6 as the
      recommended successor task
- [ ] Record the audit's D1 verdict prominently: the four constraints are kept as stated, on the
      evidence of a completed independence matrix, not by default

**Timing**: 1.0 hours

**Depends on**: 7, 8, 10

**Verification Tier**: full

**Files to modify**:
- `specs/657_audit_frame_constraints_history_restriction/summaries/01_promote-completion-restriction-independence-summary.md` - new

**Verification**:
- Every gate command above exits 0
- The axiom record lists every promoted headline declaration at
  `[propext, Classical.choice, Quot.sound]` or tighter
- Every Non-Goal confirmed by an explicit grep or `git diff` check, with the command recorded
- The handoff section names, for each of R1/R2/R3/R5, at least one promoted declaration and at least
  one manuscript site

---

## Testing & Validation

- [ ] `lake build --wfail` green with zero warnings after every phase from 1 to 9
- [ ] `bash scripts/check-module-invariants.sh` passes, C14 axiom pins included
- [ ] `lake exe mk_all --lib FormalSystem --check` exits 0 (C33: the root is byte-for-byte generated)
- [ ] `bash scripts/check-evidence-probes.sh` passes with the new probe wired
- [ ] `bash scripts/check-paper-definitions.sh` passes (no recorded quotation disturbed)
- [ ] `bash scripts/readme-lint.sh` passes
- [ ] Zero `sorry` in any touched module; C3's repo-wide structural inventory unchanged
- [ ] `Tests/BimodalTest/` builds unchanged — no promoted declaration required a test repair
- [ ] Structural invariants preserved: `PartialHistoryOrder.lean` has zero `IsRegular`;
      `FormalSystem/` has zero `TotalComp`; `def:frame`'s four constraints are byte-unchanged

## Artifacts & Outputs

- `FormalSystem/Semantics/Extension/Completion.lean` — new module: `Completion`,
  `CoherentCompletion`, `OnePointExtension`, the equivalences, `extension_of_completion`,
  `HasNearest`, `extension_of_isZTime`
- `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver.reflection_of_limit`; `reflection` re-proved
  and its docstring corrected
- `FormalSystem/Semantics/PartialHistory.lean`, `PartialHistoryOrder.lean` — the constraint-free
  restriction layer
- `FormalSystem/Semantics/Extension/Extension.lean` — the identification at `[F.IsRegular]`
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — the void and bump frames; the
  completed independence matrix
- `FormalSystem/Semantics/Extension/Constraint.lean`, `Step.lean` — two corrected docstrings
- `specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean` — the relocated,
  guarded obstruction record
- `scripts/check-evidence-probes.sh`, `scripts/check-module-invariants.sh` — guard wiring and C14 pins
- `FormalSystem.lean`, `FormalSystem/Semantics/Extension.lean`, and three READMEs — wiring and inventory
- `docs/theorem-index.md` — new rows
- `specs/657_.../summaries/01_promote-completion-restriction-independence-summary.md` — verdict record,
  axiom record and manuscript handoff

## Rollback/Contingency

Every phase is a self-contained addition committed on its own green build, so rollback is
per-phase `git revert` in reverse dependency order. Three specific contingencies:

- **If a new `@[simp]` lemma in Phase 4 perturbs unrelated proofs**: drop the `@[simp]` attribute
  from `restrict_domain`/`restrict_states` and keep the lemmas plain. Do not repair the downstream
  proofs — the attribute is a convenience, the lemmas are the content.
- **If `Extension/Completion.lean` crosses a `longFile` ceiling after Phase 3**: split the
  discrete-time section into `Extension/DiscreteExtension.lean` rather than raising the ceiling, and
  fold the extra module into Phase 9's wiring.
- **If Phase 8's generalization of `check-evidence-probes.sh` proves larger than one variable and one
  loop**: leave the script untouched, place the probe under the existing
  `specs/evidence/bi-lasso-decision-layer` sibling structure only if that is genuinely where it
  belongs, and otherwise record a follow-up task for the generalization — never leave the probe
  under the task directory, which `/todo` archives into a `.gitignore`d path.
