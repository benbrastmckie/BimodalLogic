# Implementation Plan: Task #653

- **Task**: 653 - What sees recurrence and transposition in a task frame: state registers, state nominals, since/until, and the stability modal (verdict-first)
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: 645 (translation-product port; delivered). Related, not blocking: 624 (originating report), 628 (hybrid/quantifier port; delivered), 651 (sibling, concurrently editing `FormalSystem/Metalogic/Conservativity/**` and `FormalSystem.lean` — never touched here).
- **Research Inputs**: specs/653_what_sees_recurrence_language_extensions/reports/01_what-sees-recurrence.md; compiled probes specs/653_what_sees_recurrence_language_extensions/probes/0{1,2,3}_*.lean
- **Artifacts**: plans/01_what-sees-recurrence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round delivered everything the task asked for: a numbered report with five verdicts,
the feature-by-language table, three recommendations, and three sorry-free probes (568 lines, 26
declarations). This task's own contract confines every deliverable to its task directory ("reports
and sorry-free probe files under this task's directory only; no changes to FormalSystem/ or
Tests/; do not begin implementation here"), and its declared `file_scope` is exactly
`specs/653_.../probes` and `specs/653_.../reports`. The plan therefore does three things inside
that boundary and nothing outside it: (1) re-verify the three probes against the live source tree
rather than trusting the research round's `lake env lean` run (a stale `.olean` can make a probe
look green — the failure mode the 628 plan documented); (2) close the one UNVERIFIED item of the
report that is routinely checkable, the quantified transposition sentence, with a fourth probe
whose statement was type-checked against the live tree at plan time; (3) write the summary that
hands the report's three recommendations on in actionable form — a ready-to-paste description
for the follow-up port task, the manuscript remark's final text and placement, and the
completeness take-aways — without creating a task or editing the manuscript. Definition of done:
all four probes compile from fresh `.olean`s with zero `sorry` and the axiom profiles recorded,
the report's table and appendices reflect probe 04, the summary exists, and `git diff --stat`
shows no path outside `specs/653_what_sees_recurrence_language_extensions/`.

### Research Integration

- **Verdicts Q1–Q5** are complete and are not redone. Phase 1 turns the report's "compiled,
  sorry-free" claims from a one-time run into a reproducible check against fresh `.olean`s and
  pins the axiom profiles of Appendix A.
- **Appendix B item 6** ("the quantified transposition sentence", table cell Transposition ×
  L + `∀p`, currently "visible (paper: two quantified atoms; UNVERIFIED)") becomes
  `qTrans_defines` in probe 04. The proof is the composition of two landed results: `isAtom_iff`
  / `qRec_defines` (`FormalSystem/QuantLanguage/QuantRecurrence.lean`) supply the state-naming
  and the refuting instantiation at a singleton; `recurrenceFree_not_transposed`
  (`FormalSystem/HybridLanguage/HybridTransposition.lean`) supplies the frame-level core. No
  other UNVERIFIED item is closable inside this task's scope (see Non-Goals for the reasons).
- **Recommendations (i)–(iii)** are hand-offs, not work for this task: (i) the port of probes
  01–02 (and now 04) is a separate lean4 task with its own `file_scope`; (ii) the manuscript
  lives outside this repository; (iii) the completeness notes are for the completeness research
  task to cite. Phase 3 writes each in the form its consumer needs.

### Prior Plan Reference

No prior plan for this task. The 628 plan is used for two lessons only: a probe's `lake env lean`
exit status is not evidence of compiling against the live tree unless the imported modules'
`.olean`s were rebuilt from source first; and registration-file collisions between concurrent
tasks are avoided by never leaving the task directory. No phase is copied from it.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch; no ROADMAP.md consulted.

## Goals & Non-Goals

**Goals**:
- `qTrans_defines`

**Supporting declarations (delivered, not challenge identifiers)**: `qTrans` (the sentence, an
`abbrev` in the challenge preamble), `qTrans_valid` (the `←` direction as its own lemma,
mirroring `qRec_valid`).

**Non-Goals**:
- Any edit under `FormalSystem/`, `Tests/`, `docs/`, `scripts/`, `typst/`, or the repository
  root: the task forbids it and the port is a follow-up task (Phase 3 drafts its description).
- Any edit to the manuscript `possible_worlds.tex` (outside this repository); Phase 3 records the
  remark's text and placement only.
- Creating the follow-up task. Task creation is the user's `/task` call; the summary carries the
  description ready to paste, and `.return-meta.json` raises a non-blocking `user_decision`.
- Closing UNVERIFIED items 1, 2, 5 (no world register, nomic operator, or non-Limit frame type
  exists in the tree to state them against), 3 (determinism under L^▷ — the report records why a
  `satSet` clause for `▷` is not routine), 7 (Kamp's theorem, paper), 8 (decidability, out of
  scope). They stay labelled UNVERIFIED, which the task's hard constraints permit.
- Re-running the corpus or Mathlib searches; re-reading the manuscript.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A stale `.olean` makes a probe look green while an imported declaration has changed | H | L | Phase 1 rebuilds the nine imported modules from source through the guard before any `lake env lean`; only then is exit 0 evidence |
| The build guard's project-granular lock is held by sibling 651's build | M | M | Bounded wait per `context/patterns/bounded-build-waiter.md`; the scoped targets here do not overlap 651's `Conservativity/**`, so a foreign build failure there is not this task's regression |
| `exist_iff` / `all_iff` unfold to a shape `simp only` will not match in probe 04 | L | M | Chain the clause `Iff`s by `rw` exactly as `qRec_defines` does; the statement is fixed by the challenge block and is not weakened |
| The pinned `qTrans_defines` statement proves false as written | H | L | It was reasoned through both directions at plan time and type-checked; if it fails anyway, mark Phase 2 `[BLOCKED]` per `rules/plan-compliance.md` and raise it — never add a hypothesis or restate under the same name |
| A concurrent session modifies `specs/state.json`/`TODO.md` between commits | L | H | Stage explicit file lists under `specs/653_.../` only; never a directory or glob add |
| Phase 3's follow-up description drifts from the report's Recommendation 1 file list | L | M | Copy the list from report §Recommendations item 1 and add probe 04's two declarations; do not re-derive |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. The plan is sequential: probe 04 must
compile against the same freshly built `.olean`s Phase 1 establishes, and the summary reports
Phase 2's measured result.

**Conventions that bind every phase**: no file outside
`specs/653_what_sees_recurrence_language_extensions/` is written; probes live in namespace
`Probe653` with the research round's header form ("Research probe only ... nothing here is
proposed for `FormalSystem/`"); every build runs through
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <modules>` detached with
`run_in_background`, and the verdict is read from the guard, never from a pipeline exit code;
`lake env lean <probe>` is the only way to elaborate a file that is not a Lake target, and is run
only after that guarded build; the manuscript is cited by label or quotable phrase; commits are
`task 653 phase {P}: {name}` with an explicit file list.

### Phase 1: Re-verify probes 01–03 against the live tree and pin their axiom profiles [NOT STARTED]

**Goal**: Turn the research round's compile claim into evidence that holds against fresh
`.olean`s, and record the measured axiom profiles in the report.

**Tasks**:
- [ ] Confirm every `import` of the three probes resolves to a source file (a `MISSING` is a
  report defect to record, not a probe to edit): `FormalSystem.Semantics.Frames.TranslationProduct`,
  `FormalSystem.OpenLanguage.OpenValidity`, `FormalSystem.HybridLanguage.{HybridInvariance,
  HybridValidity, HybridRecurrence, HybridTransposition}`,
  `FormalSystem.Metalogic.Independence.{DeterminismUndefinable, TranslationProductCoarse,
  LimitClosureCountermodel}`. (All nine resolved at plan time.)
- [ ] Guarded, detached, scoped build of those nine modules so their `.olean`s are fresh from
  source. Read the guard's verdict; on a lock held by another session, wait per the bounded
  waiter contract.
- [ ] `lake env lean` on each of `probes/01_invariant-languages-blind.lean`,
  `probes/02_nominals-break-product.lean`, `probes/03_limit-closure-device.lean`: exit 0, no
  warning. `grep -n "sorry" probes/*.lean` matches only the docstring phrase "sorry-free".
- [ ] Axiom profiles: copy each probe to the scratchpad directory (never into the task
  directory), append `#print axioms Probe653.<name>` for every declaration Appendix A lists, run
  `lake env lean` on the copy, and compare with Appendix A (`[propext]` for
  `boxFree_histMap_invariance` and `hybridTruthAt_iff_mem_hsatSet`; `[propext, Classical.choice,
  Quot.sound]` for every other listed theorem; no `sorryAx`). Delete the copies.
- [ ] Cross-check that every backticked declaration name the report attributes to a probe
  (Appendix A inventory and the table's evidence cells) exists in that probe by `grep`. A name in
  the report absent from the probes is a report defect: fix the report, not the probe.
- [ ] Edit `reports/01_what-sees-recurrence.md` Appendix A: one line per probe, "Re-verified at
  implementation, 2026-09-22, against source-rebuilt `.olean`s of the nine imported modules;
  profiles as listed." Record any discrepancy found instead of the word "as listed".
- [ ] Commit: `task 653 phase 1: re-verify probes against the live tree`, staging the report
  only (nothing else changed).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Appendix A names 27 declarations across the three probes (12 + 13 + 2; the
report header says 26 because `constHist` is `private`). Confirm the count by `grep -c
"^theorem\|^def\|^abbrev\|^private def"` per probe before the axiom pass; a mismatch is recorded
in the Appendix A line, not silently reconciled.

**Files to modify**:
- `specs/653_what_sees_recurrence_language_extensions/reports/01_what-sees-recurrence.md` — Appendix A verification lines

**Verification**:
- Guard verdict green for the nine scoped modules; three `lake env lean` runs exit 0 with no
  warnings
- The 27 measured profiles match Appendix A, or every mismatch is written into Appendix A
- `git diff --stat` shows only the report

---

### Phase 2: Probe 04 — the quantified transposition sentence defines recurrence-freeness [NOT STARTED]

**Goal**: Close UNVERIFIED item 6: under standard propositional quantification, the transposition
sentence built from two quantified state-naming letters is valid on a frame iff the frame is
recurrence-free.

**Tasks**:
- [ ] Create `probes/04_quantified-transposition.lean` with the research round's header form,
  imports `FormalSystem.QuantLanguage.QuantRecurrence` and
  `FormalSystem.HybridLanguage.HybridTransposition`, `namespace Probe653`, and `open
  FormalSystem.Syntax FormalSystem.Semantics FormalSystem.QuantLanguage` (add
  `FormalSystem.QuantLanguage.QuantTruth` and `FormalSystem.HybridLanguage` as the proofs need).
- [ ] `qTrans p q r` exactly as the challenge block below spells it (the `abbrev` body is part of
  the statement; do not re-associate the connectives).
- [ ] `qTrans_valid (hG : G.RecurrenceFree) (M) (τ) (t) (hpq hpr hqr) : QuantTruthAt M τ t
  Set.univ (qTrans p q r)`: after `all_iff` twice, `imp_iff`, `isAtom_iff _ _ _ hpr` and
  `isAtom_iff _ _ _ hqr` (the updated model's `p`- and `q`-valuations are read through
  `TaskModel.updateAtom_valuation_self` / `updateAtom_valuation_of_ne _ hpq`, as `qRec_valid`
  does), `neg_iff`, `and_iff`, `exist_iff`, `someFuture_iff`, `atom_iff`: the two `Atom` facts
  give the named states `w_p`, `w_q` with uniqueness; `E(p ∧ F q)` gives `ρ₁`, `s₁ < t₁` with
  `ρ₁.state s₁ = w_p`, `ρ₁.state t₁ = w_q`; `E(q ∧ F p)` gives `ρ₂`, `s₂ < t₂` with
  `ρ₂.state s₂ = w_q`, `ρ₂.state t₂ = w_p`; close with
  `recurrenceFree_not_transposed hG ρ₁ ρ₂ h₁ h₂ hi hj` where `hi : ρ₁.state s₁ = ρ₂.state t₂`
  and `hj : ρ₁.state t₁ = ρ₂.state s₂` are the two uniqueness chains.
- [ ] `qTrans_defines` with the pinned signature. `←` is `qTrans_valid`. `→` mirrors
  `qRec_defines`: `by_contra`, obtain `τ`, `s ≠ t`, `τ.state s = τ.state t`; specialise at the
  model `⟨fun _ _ => False⟩`, instantiate both quantifiers at `{τ.state s}`; discharge the two
  `Atom` premises by `⟨τ.state s, Set.mem_singleton _, fun ρ u hu => hu⟩`; refute the negation
  by exhibiting both existentials on `τ` at `min`/`max` of `s, t` via `lt_or_gt_of_ne` (both
  named states are the same state — a same-state transposition, exactly as
  `transF_refuted_of_recur`).
- [ ] Docstrings: the sentence is the quantified form of `transF` with `Atom(·)` manufacturing the
  nominal (report §2.1, `HybridRecurrence.lean`'s "minimal resource"); the `←` direction is the
  hybrid frame-level core reused verbatim, which is the content of "state nominals and standard
  quantifiers see the same features". No manuscript line numbers.
- [ ] Axiom profile on a scratch copy: `#print axioms Probe653.qTrans_defines`; record the
  measured profile (expected `[propext, Classical.choice, Quot.sound]` through
  `PartialHistory.occurrence` and `paste`; record what is measured, not what is expected).
- [ ] Report edits in `reports/01_what-sees-recurrence.md`: (a) header `Artifacts` line and
  `Sources/Inputs` probe list gain probe 04; (b) §6 table cell Transposition × "L + ∀p
  (standard)" becomes "**visible** (`qTrans_defines`, probe 04)"; (c) Appendix A gains a probe 04
  entry with line count, declarations and measured profile; (d) Appendix B item 6 is marked
  closed by probe 04 (keep the numbering; do not renumber); (e) Recommendations item 1's port
  list gains "`QuantLanguage/QuantRecurrence.lean`: `qTrans`, `qTrans_valid`, `qTrans_defines`"
  and its line estimate becomes "~400 lines"; (f) the §6 row note "the quantified transposition
  sentence (§6; 628 Appendix B item 4, unchanged)" is updated to say it is now compiled.
- [ ] Commit: `task 653 phase 2: quantified transposition probe`, staging the new probe and the
  report.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Three distinct atoms suffice (`p`, `q` bound by the outer quantifiers, `r`
the letter `Atom(·)` binds internally) and the three inequalities `p ≠ q`, `p ≠ r`, `q ≠ r` are
exactly the hypotheses the `updateAtom` rewrites consume. Confirm during `qTrans_valid`: if a
fourth atom or a further inequality is needed, the pinned statement is wrong and the phase is
`[BLOCKED]`, not silently restated.

**Files to modify**:
- `specs/653_what_sees_recurrence_language_extensions/probes/04_quantified-transposition.lean` — new
- `specs/653_what_sees_recurrence_language_extensions/reports/01_what-sees-recurrence.md` — table cell, Appendix A/B, Recommendation 1, header lists

**Verification**:
- `lake env lean probes/04_quantified-transposition.lean` exits 0 with no warning (no `sorry`
  warning in particular)
- `qTrans_defines`'s signature is character-for-character the challenge block's
- The measured axiom profile is written into Appendix A; no `sorryAx`
- `git diff --stat` shows only the two files above

---

### Phase 3: Hand-off summary — follow-up task description, manuscript remark, completeness notes [NOT STARTED]

**Goal**: Put each of the report's three recommendations into the form its consumer needs,
without acting on any of them.

**Tasks**:
- [ ] Write `summaries/01_what-sees-recurrence-summary.md` per `summary-format.md`: what Phases
  1–2 verified and measured; the four-probe inventory with profiles; then three hand-off sections.
- [ ] **Follow-up port task (Recommendation i)**: a ready-to-paste `/task` description — type
  `lean4`; title "Port the translation-product invariance and hybrid-determinism probes into the
  library"; the file targets copied from report Recommendation 1 (the meta-theorem, stability
  bijection and `projH_mem_stabClass` in `Semantics/Frames/TranslationProduct.lean`; new
  `OpenLanguage/OpenInvariance.lean`; `HybridLanguage/HybridInvariance.lean` with the "Not
  formalized" row deleted; new `Metalogic/Independence/HybridDeterminismUndefinable.lean`;
  `BoxFree` and `boxFree_histMap_invariance` in `Semantics/Truth.lean` or a small
  `Semantics/TenseFragment.lean`; the two worked instances in
  `Metalogic/Independence/TranslationProductCoarse.lean`; `qTrans*` in
  `QuantLanguage/QuantRecurrence.lean`); a `file_scope` naming those files plus the registration
  files a module-adding port touches (`FormalSystem.lean`, the relevant aggregators and READMEs,
  `scripts/measure-refactor-partitions.py`, `scripts/check-module-invariants.sh` C14 pins,
  `docs/theorem-index.md`, the axiom-profile tests under `Tests/BimodalTest/Semantics/`);
  constraints (no new axiom; every probe declaration ported, none rediscovered; the
  "proof device, never an intended model" caveat restated in every new docstring); dependencies:
  none blocking (645 and 628 delivered); estimate ~400 lines, one round. State plainly that this
  task did not create it.
- [ ] **Manuscript remark (Recommendation ii)**: the §5.3 draft verbatim, its placement
  (`sub:Conclusion`, immediately after the unfolding sentence; alternative `sec:Construction`
  after "it is by specifying a time x in a history τ ..."), the optional one-clause addition at
  `sub:Extension`, and the repository evidence to cite for each half (`*ValidIn_iff_recurrenceFree`;
  `recF_defines`, `bindRec_defines`, `transF_defines`; after the port, the ported names). No
  manuscript edit.
- [ ] **Completeness take-aways (Recommendation iii)**: items (a)–(d) restated as a block the
  completeness research can cite by this summary's path, each tied to its compiled witness
  (`classValid_iff_recurrenceFree_of_prodInvariant`, `hybridValidOn_incomparable`,
  `boxFree_histMap_invariance`, `blc_cRefuted_product`, `deterministic_not_hybridDefinable`).
- [ ] Final checks: `git diff --stat HEAD~2` (or the two phase commits) names only paths under
  `specs/653_what_sees_recurrence_language_extensions/`; `grep -rn "task 653" FormalSystem Tests
  docs scripts README.md` prints nothing (nothing there was touched, so this is a no-op
  confirmation).
- [ ] Commit: `task 653: complete implementation`, staging the summary (and the plan's status
  markers).

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Files to modify**:
- `specs/653_what_sees_recurrence_language_extensions/summaries/01_what-sees-recurrence-summary.md` — new
- `specs/653_what_sees_recurrence_language_extensions/plans/01_what-sees-recurrence.md` — phase status markers only

**Verification**:
- The summary's follow-up description names every file in report Recommendation 1 plus
  `QuantLanguage/QuantRecurrence.lean`; a diff of the two lists is empty apart from that addition
- The manuscript remark text in the summary is byte-identical to report §5.3's blockquote
- No path outside the task directory appears in any of this task's commits

## Lean Challenge Statements

**Authoring note.** Every carrier sits in the preamble as an `abbrev` (not matched by the
snapshot tool, so its body survives and stays out of the identifier set); the one theorem has a
simple, undotted name; the namespace is left open after it on purpose. The identifier set of this
block is `{qTrans_defines}`, equal to the `- **Goals**:` list. The block was type-checked
standalone against the live source modules at plan time (`lake env lean`, exit 0, one `sorry`
warning, no error). The solution lives in `probes/04_quantified-transposition.lean`, not under
`FormalSystem/`, so a Comparator run (advisory, `--compare` only) is expected to report
`solution_module_unresolved`; the plan-compliance obligation is the signature, checked by eye
and by `lake env lean`.

```lean
import FormalSystem.QuantLanguage.QuantRecurrence
import FormalSystem.HybridLanguage.HybridTransposition

namespace Probe653

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.QuantLanguage

/-- `∀p ∀q (Atom_r(p) → Atom_r(q) → ¬(E(p ∧ F q) ∧ E(q ∧ F p)))`: the quantified transposition
sentence, with `r` the fresh letter that `Atom(·)` binds internally. -/
abbrev qTrans (p q r : Atom) : QuantFormula :=
  QuantFormula.all p (QuantFormula.all q
    ((QuantFormula.isAtom p r).imp ((QuantFormula.isAtom q r).imp
      ((QuantFormula.exist ((QuantFormula.atom p).and
          (QuantFormula.someFuture (QuantFormula.atom q)))).and
        (QuantFormula.exist ((QuantFormula.atom q).and
          (QuantFormula.someFuture (QuantFormula.atom p))))).neg)))

theorem qTrans_defines (G : TaskFrame) {p q r : Atom} (hpq : p ≠ q) (hpr : p ≠ r)
    (hqr : q ≠ r) :
    (∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration),
      QuantTruthAt M τ t Set.univ (qTrans p q r)) ↔ G.RecurrenceFree := sorry
```

## Testing & Validation

- [ ] Guarded scoped build of the nine imported modules green before any `lake env lean`
- [ ] Probes 01–04 each: `lake env lean` exit 0, no warnings; `sorry` occurs only in the docstring
  phrase "sorry-free"
- [ ] 27 + 3 axiom profiles measured on scratch copies and recorded in Appendix A; no `sorryAx`
- [ ] Every declaration name the report cites as probe evidence exists in the named probe
- [ ] `qTrans_defines` matches the pinned signature exactly
- [ ] `git diff --stat` over the task's commits shows only `specs/653_what_sees_recurrence_language_extensions/**`
- [ ] The summary exists and carries the three hand-off sections

## Artifacts & Outputs

- `specs/653_what_sees_recurrence_language_extensions/plans/01_what-sees-recurrence.md` (this file)
- `specs/653_what_sees_recurrence_language_extensions/probes/04_quantified-transposition.lean` (new)
- `specs/653_what_sees_recurrence_language_extensions/reports/01_what-sees-recurrence.md` (Appendix A verification lines; probe 04 in the table, appendices and Recommendation 1)
- `specs/653_what_sees_recurrence_language_extensions/summaries/01_what-sees-recurrence-summary.md` (new)

## Rollback/Contingency

Every change is additive and confined to the task directory; nothing under `FormalSystem/`,
`Tests/`, or any registration file is touched, so there is no library state to roll back and no
snapshot is needed. If Phase 2 cannot close `qTrans_defines` as pinned, mark the phase
`[BLOCKED]` with the goal state reached, delete `probes/04_quantified-transposition.lean`, revert
the report's probe-04 edits by `Edit` (re-read the file first — the item stays UNVERIFIED, which
the task permits), and proceed to Phase 3 recording the blocker; the research deliverable is
complete without probe 04. If Phase 1 finds a probe that no longer compiles against fresh
`.olean`s, do not edit the probe: record the failing declaration and cause in Appendix A and in
the summary, mark the affected report claim UNVERIFIED, and continue — a precisely located
failure is a complete outcome under this task's contract.
