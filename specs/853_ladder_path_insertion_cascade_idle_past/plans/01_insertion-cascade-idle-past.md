# Implementation Plan: Task #853

- **Task**: 853 - Construct the Phase 11.8 insertion cascade for the ladder-path region lemmas: the idle-past half (`exists_ladderPath_at_region_of_idle_past`) and, given it, the unconditional join (`exists_ladderPath_at_region`)
- **Status**: [COMPLETED]
- **Effort**: 12 hours across 7 phases (1.5 / 1.5 / 2 / 2 / 2 / 1.5 / 1.5). Phases 3 and 4 carry the two largest proofs (the inserted walk's region-start trichotomy and the pin bound it feeds); Phase 5 is short because every component it composes is landed by then
- **Dependencies**: Task 838 (`two_sided_open_core_pin_free_pigeonhole`) at the `state.json` level — the recorded serializing edge for shared `LadderAgree.lean` territory. Its implementation closed before this dispatch (`HEAD` carries `task 838: complete implementation`), so the edge is satisfied and nothing here waits on it. Parent: task 761, whose Phase 11.12 is exactly this construction and whose Phase 11.11 landed the inserted walk and its four LOCAL ladder conditions as this plan's INPUTS
- **Research Inputs**: None. No research report exists for this round; the `research_artifact` field of `.dispatch/10.md` is empty. The Stage 1.5 opening assessment applies and is recorded under "Research Integration" below. The substantive inputs are the task description's four verified findings, the landed library (`LadderAgree.lean`'s `Cascade` section and the lift lemma above it, `RunLayer.lean`'s `drift_extension_of_pins`), and the parent's own Phase 11.11 handoff
- **Artifacts**: plans/01_insertion-cascade-idle-past.md (this file); summaries/01_insertion-cascade-idle-past-summary.md (written by Phase 7)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`exists_ladderPath_at_region_of_idle_past` and `exists_ladderPath_at_region` are the two
unclaimed names of the interface the counter lift reads at the comparison position. Both are
gated on one owed construction: a ladder path carrying the original's object state at the
comparison position with the countdown raised by exactly the cycle length, in the regime where
the splice point has an idle position in its past. The `spliceObj`-shaped conclusion is REFUTED
there, so the walk must differ from the splice strictly below the comparison position's region
start; the inserted walk that does this (`insObj`/`insCnt`) and its four LOCAL ladder conditions
are landed, and what is owed is the PIN half (`hpins`, `hn₀`), the existential, and the join.

This plan closes that in five construction phases plus two closing phases. Its two load-bearing
planning findings, both re-derived against the Lean source at authoring, are that neither owed
pin obligation needs the machinery the recorded mechanism anticipated:

- **The cascade collapses to a single insertion.** Taking the insertion site `u` to be the region
  start of `a`'s OWN region — the greatest idle position at or below `a` — moves every earlier
  region start down by `d` *together*, so their mutual distances are preserved and only their
  distance to the raised pin grows. `d := l` then discharges `hpins` exactly, with no iteration
  and no doubling recurrence. The landed `cascadeDemand`, `cascadeDemand_add_succ` and
  `cascadeDemand_le_cascadeBound` therefore stay as the sizing RECORD and are not consumed;
  neither is `pinnedRegions` or `pin_deficit_le_of_lengthen`.
- **The `hn₀` anchor obligation is eliminable rather than constructible.** `hpins` already asserts
  that the walk's pin family is pairwise compatible, which is exactly
  `drift_extension_of_pins`'s hypothesis; the register it returns has a value at `0`, and that
  value witnesses `hn₀`. So an anchor-free lift lemma (`exists_ladderPath_of_walk_of_pins`) drops
  `hn₀` entirely, which removes the sign-case analysis the insertion's two-sided displacement
  would otherwise force on it.

The one premise that is NOT eliminable is the self-loop. The parent's Phase 11.11 decided to
carry it explicitly on `insObj_step` and recorded that an unconditional idle-past interface needs
more than that layer lands. This plan does not pretend otherwise: both names are claimed with an
explicit, path-local idle self-loop hypothesis
(`hself : ∀ p ≤ a, pend (objAt g p) = false → step (objAt g p) (objAt g p) = true`), and the
"unconditional join" is unconditional in the *regime dichotomy* sense the task description means —
it needs no pending-past hypothesis — not in the sense of carrying no hypotheses at all. Every
record that currently says no binder was added to these names is brought current by Phase 6
rather than left to contradict the tree.

Definition of done: both names are landed `theorem`s whose signatures match the
`## Lean Challenge Statements` block token for token, with `#print axioms` showing no `sorryAx`,
every record naming them as unlanded brought current, and the complete gate set green.

### Research Integration

No research report exists for this round, so the Stage 1.5 opening assessment is recorded here
rather than left implicit. The verdict was to plan directly. Three grounds, each re-derived in
this dispatch by reading the repository:

- **The task description is a specification, not a research question.** Its four numbered
  findings are already blocker research checked against the Lean source, and each was re-verified
  here: `pinCompat_of_ladderPath` (`LadderAgree.lean`) does make the splice demand necessary;
  `cntAt_eq_of_obj_eq` does make the countdown a function of the object walk; and
  `grep -rn 'exists_ladderPath_at_region' FormalSystem/ Tests/` returns only
  `exists_ladderPath_at_region_of_pend_past` plus docstring lines, so both target names are
  genuinely unclaimed.
- **Every object the construction needs is in the tree and was read.** The lift lemma
  (`exists_ladderPath_of_walk`, with its `hpins`/`hn₀` slots), the splice
  (`spliceObj`/`spliceCnt`/`spliceIdx` and `spliceObj_eq_objAt_spliceIdx`), the inserted walk
  (`insIdx`, `insObj`, `insCnt`, the three retraction facts, `insIdx_of_ge`,
  `insIdx_succ_of_lt_block`, `insObj_of_gt`, `insCnt_of_gt`, `insObj_step`, `insCnt_idle`,
  `insCnt_pend_pend`, `insCnt_pend_idle`, `le_region_start_of_idle`), the region-start extraction
  model (`cntAt_le_nxtAt_succ_of_idle_past`, whose `Nat.find` over backward idle distances is
  Phase 2's proof almost verbatim), `cntAt_add_of_pend_back`, `cntAt_sub_of_pend`,
  `cntAt_eq_nxtAt_of_idle_pend`, `nxtAt_lipschitz_two_sided` and `drift_extension_of_pins`. No
  literature search and no external API is involved.
- **The remaining uncertainty is a proof-engineering question, not a fact an agent could go
  establish.** Whether `d := l` suffices for `hpins` is settled by arithmetic this plan does
  (see Overview); what is left is writing seven Lean proofs. A research dispatch has nothing to
  add to that.

All seven Goal signatures were elaborated standalone at this plan's authoring time through the
build guard
(`bash .claude/scripts/lake-build-guard.sh build --timeout 500 -- env lean <file>`, against
`import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` in namespace `Probe853`):
`exit_status=0`, zero errors, exactly seven `declaration uses 'sorry'` warnings — one per theorem.

### Prior Plan Reference

No prior plan for task 853. The parent's plan v11
(`specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md`) carries
the Phase 11.11 that landed this plan's inputs, and its close handoff
(`specs/761_ladder_realization_theorem/handoffs/phase-11.11-handoff-20261104T205250Z.md`) is read
here as an input record rather than as a template. Three things were taken from it:

- the self-loop premise is inherited, not re-litigated (its candidate-(b) pigeonhole is above this
  module in the import DAG and the regime hypothesis supplies one idle position where that
  pigeonhole needs many idle runs);
- its recorded judgment against splitting the Cascade section into `LadderCascade.lean` is
  honoured (see "Module siting" below);
- its measured effort calibration — fifteen declarations with docstrings and axiom pins in one
  phase — is what makes this plan's 1.5-2h per-phase estimates credible rather than optimistic.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and no `roadmap_flag` is set,
so no roadmap phases are added. `specs/ROADMAP.md` was not consulted.

### Module siting

All new declarations land in `LadderAgree.lean`: the two lift-lemma strengthenings immediately
after `exists_ladderPath_of_walk` inside `section Path`, and the five cascade declarations at the
end of `section Cascade`. No new module is created. Two reasons, both measured at authoring:

1. The parent's Phase 11.11 close records the reasoned judgment against the split — the insertion
   walk reads `spliceObj`/`spliceCnt` and the same section's pin bookkeeping at every step, so a
   split would put one argument across an import edge.
2. The split's cost is a seven-file ripple (new module, two root import lines, four generated
   README inventory blocks) for no mathematical gain.

The cost of NOT splitting is that `LadderAgree.lean`'s in-source `longFile` baseline must rise
from `2900` to `3400` (the file is 2,887 lines at authoring, `wc -l`, so 13 lines of headroom
against roughly 500 owed). That is the same pre-authorized primary remedy Phase 11.11 used when
it raised the baseline from 2600 to 2900. `scripts/check-module-invariants.sh` accepts a raised
in-source baseline as a recorded length ceiling provided the `set_option linter.style.longFile N`
line does not end in `in` and `N > 0`.

`state.json`'s `file_scope` for this task anticipates
`FormalSystem/Metalogic/Decidability/RaySummary/LadderCascade.lean`. That file does not exist and
this plan does not create it on the primary route; it is declared in Phase 5's `Files to modify`
as a named CONTINGENCY only, annotated as such, so the task's declared territory is not silently
narrowed. See Rollback/Contingency for the trigger.

## Goals & Non-Goals

**Goals**:

- `drift_lipschitz_two_sided` -- a `Drift`-chained register is two-sidedly `1`-Lipschitz between any two positions, the `Drift`-level counterpart of the landed `nxtAt_lipschitz_two_sided`.
- `exists_ladderPath_of_walk_of_pins` -- the anchor-free lift: `exists_ladderPath_of_walk` with `hn₀` dropped, derived rather than assumed.
- `exists_region_start_of_idle_past` -- an idle position at or below a pending `a` yields the region start of `a`'s own region, with its window inequality and the maximality that says every position strictly between it and `a` is pending.
- `insRegionStart_trichotomy` -- every region start of the inserted walk (at `u` the region start of `a`'s region, with `d := l`) is the raised pin at `u`, or an original region start below `u` displaced by `-l`, or an original region start at or above `a` displaced by `+l`; with its `insCnt` value in each case.
- `insPins_of_region_start` -- `hpins` for the inserted walk, the nine-case reduction of the trichotomy to `pinCompat_of_ladderPath` on the original.
- `exists_ladderPath_at_region_of_idle_past` -- the interface in the idle-past regime, under an explicit path-local idle self-loop.
- `exists_ladderPath_at_region` -- the join of the two regimes by `by_cases` on the pending-past predicate, under the same self-loop.

**Non-Goals**:

- Discharging the self-loop premise. Candidate (b) (insert a copy of an idle-containing cycle obtained by a pigeonhole over a finite object type) needs many idle runs below the region start where the regime hypothesis gives one, and the one landed pigeonhole of that family is in `LadderPin.lean`, above this module in the import DAG. It is cited by path, never as a proof term.
- Claiming `exists_spliced_ladderPath_of_idle_past`. That name stays unclaimed and its refutation stays legible; nothing here weakens or relaxes any pin hypothesis of `exists_spliced_ladderPath`.
- Consuming `cascadeDemand`, `cascadeDemand_add_succ`, `cascadeDemand_le_cascadeBound`, `pinnedRegions*` or `pin_deficit_le_of_lengthen` as proof terms. They remain the sizing record; Phase 6 says so in the docstring rather than deleting them.
- Reaching for `two_pow_card_prodState_le_Tc`. It lives in `LadderChain.lean`, which imports this module. `cascadeBound` from `CounterQuotient.lean` remains the only citable sizing anchor here, and this plan needs neither.
- Any type-transport, model-level or cell-level statement. Nothing here says the realized TYPE is preserved, and no certificate object is named: `LadderAgree.lean`'s import list stays at `AnchorLayer` + `CounterQuotient` and its certificate-freedom grep stays at zero matches.
- Touching the parent's artifacts, `specs/761_*` or `specs/838_*`. This task's only `specs/**` write is its own summary.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `d := l` turns out insufficient for one `hpins` pair, so an iteration is needed after all | H | L | The nine-case arithmetic is written out in Phase 4's task list, pair by pair, with the exact bound each case needs; the tight case is (raised pin `u`, displaced-down start `y - l`), where the demand is `(u - y) + l` and `pinCompat_of_ladderPath` gives `u - y`. If a case fails, Phase 4 marks `[BLOCKED]` and reports rather than silently generalising `d` — `rules/plan-compliance.md` forbids substituting a different construction mid-phase |
| `drift_extension_of_pins`'s pin family needs a `DecidablePred` the walk does not supply | M | M | Open the `classical` scope (`classical` tactic or `open Classical in`) for the `if … then some (c (v + 1)) else none` family; `drift_extension_of_pins` itself opens `classical` in its own proof, so the precedent is in place |
| `LadderAgree.lean`'s raised `longFile` baseline is rejected, or the module grows past 3,400 lines | M | L | The contingency split named in Rollback/Contingency: move Phases 3-5's five declarations to `LadderCascade.lean` importing `LadderAgree` alone, which `state.json`'s `file_scope` already anticipates. Phases 1-2's two declarations stay in `LadderAgree.lean` regardless — they belong beside `exists_ladderPath_of_walk` |
| The axiom test crosses its own in-source `longFile 2300` (it is 2,216 lines at authoring, so 84 lines of headroom against seven new pins plus a prose block) | L | M | Pre-authorized: raise that baseline in place to `2400`, the same remedy Phase 11.11 used on the same file. Record it as a measurement, not a deviation |
| Bringing the records current reads as weakening a recorded refutation | H | L | Phase 6's task list separates the three claims explicitly: the `spliceObj`-shaped refutation stands verbatim, `exists_spliced_ladderPath_of_idle_past` stays unclaimed, and only the two restated-existential names move from unlanded to landed-with-`hself`. The self-loop's status is restated, never dropped |
| A concurrent writer touches `LadderAgree.lean` (task 838 shares it) | M | L | 838's implementation is closed at `HEAD`; before the first edit, re-run `git log --oneline -3 -- FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` and `git status --short` on it, and stop if another writer is live rather than editing over them |
| The region start `u` is not strictly below the comparison position `v`, so `insObj_of_gt`/`insCnt_of_gt` do not apply | H | L | Proved in Phase 5's task list: `v` is pending (an idle `v` would force `cntAt g v = 0` and so `a ≤ v ≤ a`, contradicting `a` pending), and `v < u ≤ a ≤ v + cntAt g v` would put the idle `u` inside `v`'s own pending span against `cntAt_sub_of_pend`. So `u < v` |

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

Phases within the same wave can execute in parallel; this plan has no parallel pair, and that is
deliberate rather than an artefact. Phases 1, 2 and 3 are mathematically INDEPENDENT of one
another — Phase 3 takes the region start and its properties as hypotheses rather than importing
Phase 2's existence proof — but all three append to the same two files
(`LadderAgree.lean`, `KTypeSummaryAxiomTest.lean`), so the plan serialises them rather than
declaring a three-phase wave a batch runner would try to execute concurrently on shared
territory. Phase 7 is the final phase: it is the highest-numbered phase, nothing depends on it,
and it depends transitively on every other phase.

---

### Phase 1: The Anchor-Free Lift [COMPLETED]

**Goal**: `exists_ladderPath_of_walk` with `hn₀` dropped. A walk whose pin family is pairwise
compatible already determines a `Drift` register through those pins, and that register's value at
`0` witnesses the anchor condition — so the anchor is derived rather than assumed, and no
consumer of the lift ever has to construct one again.

**Tasks**:

- [x] Before the first edit, confirm no concurrent writer: `git log --oneline -3 -- FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` and `git status --short FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`. Stop and report if the file is dirty from another session.
- [x] Raise `LadderAgree.lean`'s in-source `set_option linter.style.longFile 2900` to `3400`, extending the existing comment above it to record that the cascade's pin half and the two restated existentials are what the raise pays for. Keep the `set_option` line free of a trailing `in`. *(deviation: altered — raised to `3100`, not `3400`. Lean's `longFile` linter requires the baseline to EQUAL the file's own round-up to the next hundred, not a forward-looking ceiling: at 2,968 lines a `3400` baseline emits `The current limit is 3400, but it is expected to be 3100`, introducing a new build warning into a previously warning-free module. The comment records that the baseline tracks the file across the cascade's phases instead of being set once to its final value; later phases bump it as they grow. The `set_option` line carries no trailing `in`.)*
- [x] `drift_lipschitz_two_sided` (Goal, signature as pinned below): for `n : ℤ → ℕ` with `∀ t, Drift (n t) (n (t + 1))`, `((n u : ℤ) - n v).natAbs ≤ (u - v).natAbs`. Model the proof on the landed `nxtAt_lipschitz_two_sided` / `nxtAt_lipschitz` pair: a `Nat` induction on the one-sided distance with `simp only [Drift]` then `omega` at the step, wrapped in `rcases le_total u v` for the two-sided form. Place it immediately before `exists_ladderPath_of_walk` in `section Path`.
- [x] `exists_ladderPath_of_walk_of_pins` (Goal, signature as pinned below): `classical`; set `pin : ℤ → Option ℕ := fun v => if pend (w v) = false ∧ pend (w (v + 1)) = true then some (c (v + 1)) else none`; feed `drift_extension_of_pins` the compatibility, which unfolds to `hpins` after the two `if` splits; obtain `n` with its `Drift` chain and `∀ t a, pin t = some a → n t = a`; apply `exists_ladderPath_of_walk w c (n 0) hw hidle hpp hpi hpins` and discharge the final `hn₀` slot by rewriting `c (v + 1)` to `n v` through the pin equation and appealing to `drift_lipschitz_two_sided n _ v 0`.
- [x] Docstring both: `drift_lipschitz_two_sided` states that it is the `Drift`-level form of the landed `nxtAt_lipschitz_two_sided` and names it; `exists_ladderPath_of_walk_of_pins` states that `hn₀` is DERIVED from `hpins` via the McShane extension of `drift_extension_of_pins`, that this makes it strictly more general than `exists_ladderPath_of_walk`, and that `exists_ladderPath_of_walk` is NOT deleted or restated in terms of it (every landed consumer keeps reading the anchored form).
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: add a `#guard_msgs in #print axioms` pin for each of the two new names, in a new subsection beside the existing lift-lemma pins. If the file crosses its in-source `longFile 2300`, raise that baseline to `2400` in place and record the measurement. *(measurement: the file is 2,236 lines after the two pins, below the `2300` baseline, so no raise was needed — the narrower outcome the Scope Hypothesis anticipates.)*
- [x] Record in `issues.jsonl` whether `drift_extension_of_pins` accepted the pin family without a `DecidablePred` instance, and whether the `hn₀` discharge needed `drift_lipschitz_two_sided` in two-sided form or only one-sided.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Two declarations, 40-70 lines with docstrings (the model
`nxtAt_lipschitz_two_sided` is 9 lines and `exists_ladderPath_of_walk` is 15, both re-derived at
authoring by reading `LadderAgree.lean`), and two files change plus the `longFile` baselines.
Confirm by `wc -l` on both files and `git diff --stat` before the commit; if the axiom test's
baseline does not need raising, that is a narrower outcome, not a deviation.

**Tier Justification**: The edit adds two declarations inside `LadderAgree.lean` and two pins in
the axiom test, changing no existing signature and adding no import edge, so guarded scoped builds
of `FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and of
`BimodalTest.Metalogic.KTypeSummaryAxiomTest` are the complete covering check — no third file
reads either new name yet.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - exists; the two lift-lemma strengthenings and the raised `longFile` baseline
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - exists; two pins added, no existing pin changed

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0. Read the guard's `result` subcommand, never a piped exit code.
- `#print axioms` on both new names shows a subset of `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.
- `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` is 0.
- Both signatures match the `## Lean Challenge Statements` block token for token.
- `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` is below the raised in-source baseline.

---

### Phase 2: The Region Start of `a`'s Own Region [COMPLETED]

**Goal**: The one place the idle-past regime hypothesis does real work. An idle position at or
below a pending `a` yields the greatest idle position `s ≤ a`, which is the region start of `a`'s
own region: it carries the window inequality `a ≤ s + 1 + cntAt g (s + 1)` and the maximality
that every position strictly between `s` and `a` is pending. That maximality is what makes the
single insertion at `s` sufficient in Phases 3 and 4.

**Tasks**:

- [x] `exists_region_start_of_idle_past` (Goal, signature as pinned below): from `hg`, `hpa : pend (objAt g a) = true`, `hp : p ≤ a` and `hpi : pend (objAt g p) = false`, produce `s` with `p ≤ s`, `s + 1 ≤ a`, `pend (objAt g s) = false`, `pend (objAt g (s + 1)) = true`, `a ≤ s + 1 + (cntAt g (s + 1) : ℤ)`, and `∀ t, s < t → t ≤ a → pend (objAt g t) = true`.
- [x] Model the proof on the landed `cntAt_le_nxtAt_succ_of_idle_past` (`LadderAgree.lean`), whose first half is this construction almost verbatim: `Nat.find` over `{j | pend (objAt g (a - j)) = false}`, nonempty by `(a - p).toNat`; `Nat.find_min` gives the run of pending positions above it; `0 < j₀` because `a` is pending; set `s := a - (j₀ : ℤ)`.
- [x] The window inequality comes from `cntAt_add_of_pend_back g hg a (j₀ - 1)` on that run: `cntAt g (s + 1) = cntAt g a + (j₀ - 1)`, so `s + 1 + cntAt g (s + 1) = a + cntAt g a ≥ a`. Do NOT route it through `pend_of_mem_region` — that reads the span from the start, which is the direction this phase is establishing.
- [x] The maximality clause is `Nat.find_min` re-indexed from `j` to `t := a - j`; state it in the `t` form the later phases consume rather than leaving a `j` form for them to convert.
- [x] Docstring: state that this is where the idle-past regime hypothesis is consumed, that the landed `le_region_start_of_idle` is the COMPLEMENTARY fact (an idle witness lies at or below a given region start) and is not what this lemma proves, and that the maximality clause is the hypothesis the trichotomy of the next phase needs.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: one `#guard_msgs in #print axioms` pin. *(measurement: the pin reads `[propext, Quot.sound]` — no `Classical.choice`; the file is 2,255 lines against its unchanged `2300` baseline, and `LadderAgree.lean` is 3,024 against its `3100` baseline, so neither needed raising.)*
- [x] Record in `issues.jsonl` whether the `Nat.find` route was reusable as written or whether the shared machinery was worth factoring out of `cntAt_le_nxtAt_succ_of_idle_past` into a named helper. Do NOT refactor the landed lemma as part of this phase if a helper would change its signature. *(outcome: the `Nat.find` route was reusable as written; no helper was factored out and `cntAt_le_nxtAt_succ_of_idle_past` is untouched.)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: One declaration, 50-80 lines with docstring (the model's first half is
`LadderAgree.lean` lines 831-868 by its own proof structure, 38 lines, re-derived at authoring;
the maximality clause and the window inequality add the rest), and two files change. Confirm by
`git diff --stat` before the commit.

**Tier Justification**: The edit adds one declaration to `LadderAgree.lean` and one pin to the
axiom test, changing no existing signature, so guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and
`BimodalTest.Metalogic.KTypeSummaryAxiomTest` are the complete covering check.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - exists; the region-start extraction, at the end of `section Cascade`
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - exists; one pin added

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` shows no `sorryAx`; the module-scoped vacuous grep is 0.
- The signature matches the `## Lean Challenge Statements` block token for token, including the maximality clause's `∀ t, s < t → t ≤ a` shape.
- `wc -l` on both files is below their in-source baselines.

---

### Phase 3: The Inserted Walk's Region-Start Trichotomy [COMPLETED]

**Goal**: Every region start of the inserted walk — inserted at `u`, the region start of `a`'s own
region, with depth `d := l` — is exactly one of three things, with its `insCnt` value known in
each case: the raised pin at `u` itself (countdown `cntAt g (u + 1) + l`), an original region
start strictly below `u` displaced down by `l` (countdown unchanged), or an original region start
at or above `a` displaced up by `l` (countdown unchanged). This is the whole content of the pin
half; Phase 4 is then arithmetic.

**Tasks**:

- [x] `insRegionStart_trichotomy` (Goal, signature as pinned below): hypotheses `hg`, `hl : 0 < l`, `hcl : l ≤ cntAt g a`, and `u` with `hu0`, `hu1`, `hua : u + 1 ≤ a`, `hreg : a ≤ u + 1 + (cntAt g (u + 1) : ℤ)` and `hmax` (Phase 2's output, taken as hypotheses).
- [x] Case `x > u`: show `a + (l : ℤ) ≤ x`. `insIdx_of_gt` makes the inserted walk the spliced walk at `x` and `x + 1`; `spliceObj_of_lt` / `spliceObj_of_ge` then put `x` on the original. Rule out `u < x < a + l` three ways — `hmax` for `u < x ≤ a`, the pending span `cntAt_sub_of_pend g hg a` under `hcl` for `a < x < a + l`, and the seam `x + 1 = a + l` (where `x = a + l - 1` is itself pending) — so the only survivor is `x ≥ a + l`, where `spliceCnt_of_ge` gives `insCnt (x + 1) = cntAt g (x - l + 1)`.
- [x] Case `x = u`: `insCnt (u + 1) = spliceCnt (u + 1)` by `insIdx_of_gt`, and `spliceCnt_of_lt` with `hreg` makes the `if a ≤ v + cntAt g v` branch fire, giving `cntAt g (u + 1) + l`. This is the ONE raised pin, and `hreg` is exactly what raises it.
- [x] Case `x < u`: `insIdx_of_mem_block` makes the whole block `[u - l, u]` read the idle `objAt g u`, so `x` with `u - l ≤ x + 1 ≤ u` cannot be a region start (its successor is idle) — that kills `u - l - 1 ≤ x < u`. For `x < u - l - 1`, `insIdx_of_lt_block` and `insIdx_succ_of_lt_block` put `x` and `x + 1` at `x + l` and `x + l + 1` on the spliced walk, hence on the original (both are `≤ u ≤ a < a + l`), so `x + l` is an original region start.
- [x] In that last case, show the splice's `+ l` branch does NOT fire at `x + l + 1`: if `a ≤ (x + l + 1) + cntAt g (x + l + 1)` then `pend_of_mem_region g hg (x + l) u` would make the idle `u` pending, since `x + l < u ≤ a` places `u` in that region's span. So `insCnt (x + 1) = cntAt g (x + l + 1)`, unchanged.
- [x] Docstring: state that the trichotomy is where `d := l` is fixed and why — the three families' displacements are `0`, `-l` and `+l`, and only the `0` family's countdown is raised — and that the `hmax` hypothesis is what makes the middle band `u < x < a + l` empty, which is the reason one insertion suffices where the recorded mechanism anticipated an iteration.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: one `#guard_msgs in #print axioms` pin. *(measurement: the pin reads `[propext, Classical.choice, Quot.sound]` — unlike Phase 2's, the splice countdown lemmas in the dependency closure bring `Classical.choice`; the test file is 2,288 lines against its unchanged `2300` baseline, while `LadderAgree.lean` reached 3,115 and its in-source `longFile` baseline was raised in place from `3100` to `3200`, the pre-authorized primary remedy.)*
- [x] Record in `issues.jsonl` whether the middle band needed all three sub-arguments or whether `hmax` plus the pending span sufficed, and whether any case needed a hypothesis not in the pinned signature. If one does, mark the phase `[BLOCKED]` and report rather than adding a binder to the pinned statement (`rules/plan-compliance.md`, Statement Fidelity). *(outcome: all three middle-band sub-arguments were needed — `hmax` for `u < x <= a`, the pending span of `a` under `hcl` for `a < x < a + l`, and the collapsed block excluded separately because its image is the idle `u`; the seam `x + 1 = a + l` fell inside the pending-span argument rather than needing its own. No case needed a hypothesis outside the pinned signature; `hu1` turned out unread by this lemma and is carried for the next layer under a scoped `linter.unusedVariables` silencing, the established convention in this file family.)*

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: One declaration, 90-140 lines with docstring (three cases, each a rewrite
chain through two or three of the landed `insIdx_*` retraction facts; the comparable landed
`insCnt_pend_pend` is 17 lines of proof over the same case structure, re-derived at authoring, and
this lemma's cases each carry an extra exclusion argument), and two files change. Confirm by
`git diff --stat` before the commit.

**Tier Justification**: The edit adds one declaration to `LadderAgree.lean` and one pin to the
axiom test, changing no existing signature, so guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and
`BimodalTest.Metalogic.KTypeSummaryAxiomTest` are the complete covering check.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - exists; the trichotomy, at the end of `section Cascade`
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - exists; one pin added

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` shows no `sorryAx`; the module-scoped vacuous grep is 0.
- The signature matches the `## Lean Challenge Statements` block token for token, including `insObj g a l u l` / `insCnt g a l u l` with `d` instantiated to `l`.
- The certificate-freedom grep `certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod` returns no match on `LadderAgree.lean`, and its import list is still `AnchorLayer` + `CounterQuotient`.

---

### Phase 4: `hpins` for the Inserted Walk [COMPLETED]

**Goal**: The pin obligation the splice refutation left open, discharged. Nine pairs of
trichotomy cases, every one of them reducing to `pinCompat_of_ladderPath` on the ORIGINAL path
plus `omega`. This is the phase that establishes that `d := l` is enough.

**Tasks**:

- [x] `insPins_of_region_start` (Goal, signature as pinned below): the same `u` hypotheses as Phase 3, concluding `hpins` for `insObj g a l u l` / `insCnt g a l u l` in exactly the shape `exists_ladderPath_of_walk_of_pins` consumes.
- [x] `rcases` both region starts through `insRegionStart_trichotomy` and handle the nine pairs. In each, rewrite both `insCnt` values and then close with `pinCompat_of_ladderPath` on the two original starts plus `omega`. The pairs and the bound each needs, written out so no case is discovered mid-proof:
  - (raised `u`, raised `u`): reflexive, `omega` alone.
  - (raised `u`, displaced-down `y - l` with `y < u`): demand `|cntAt g (u+1) + l - cntAt g (y+1)| ≤ (u - y) + l`; compatibility gives `u - y`. THE TIGHT CASE, and the reason `d := l` is exactly enough.
  - (raised `u`, displaced-up `t + l` with `t ≥ a`): demand `≤ (t - u) + l`; compatibility gives `t - u`.
  - (displaced-down, displaced-down): distances and countdowns both unchanged; compatibility directly.
  - (displaced-down `y - l`, displaced-up `t + l`): new distance `(t - y) + 2l`; compatibility gives `t - y`.
  - (displaced-up, displaced-up): distances and countdowns both unchanged; compatibility directly.
  - the three mirror pairs: by the symmetry of `natAbs` on the two arguments, not by re-proof.
- [x] Docstring: state that `cascadeDemand` and its closed form are NOT consumed, that the single insertion at the region start of `a`'s own region is what replaces the anticipated iteration, and that the recurrence stays landed as the sizing record for the iteration the construction turned out not to need.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: one `#guard_msgs in #print axioms` pin.
- [x] Record in `issues.jsonl` whether all nine pairs closed with `pinCompat_of_ladderPath` plus `omega`, and whether the three mirror pairs were reachable by symmetry or needed writing out. If any pair genuinely needs `d > l`, mark the phase `[BLOCKED]` and report the pair and its deficit, because a general `d` changes the pinned signatures of Phases 3-5.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: One declaration, 60-110 lines with docstring (nine cases, each two rewrites
and an `omega`; the landed `exists_spliced_ladderPath_of_pend_past` discharges the same obligation
in one case in 13 lines, re-derived at authoring), and two files change. Confirm by
`git diff --stat` before the commit.

**Tier Justification**: The edit adds one declaration to `LadderAgree.lean` and one pin to the
axiom test, changing no existing signature, so guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and
`BimodalTest.Metalogic.KTypeSummaryAxiomTest` are the complete covering check.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - exists; the pin bound, at the end of `section Cascade`
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - exists; one pin added

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` shows no `sorryAx`; the module-scoped vacuous grep is 0.
- The signature matches the `## Lean Challenge Statements` block token for token.
- `grep -n 'cascadeDemand' FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` shows the recurrence only in its own three declarations and in docstrings — never inside this phase's proof.

---

### Phase 5: The Two Existentials [COMPLETED]

**Goal**: Both unclaimed names landed. The idle-past half assembles Phases 1-4 with the four
landed LOCAL conditions and the two landed pointwise facts; the join is `by_cases` on the
pending-past predicate over it and the landed pending-forever half.

**Tasks**:

- [x] `exists_ladderPath_at_region_of_idle_past` (Goal, signature as pinned below). Derive `pend (objAt g a) = true` from `hl` and `hcl` through `cntAt_eq_zero_of_idle` rather than taking it as a binder — the landed pending-forever half does not take it either, and adding it would drift from the pinned signature.
- [x] Obtain `u` from `exists_region_start_of_idle_past` on the regime witness, then show `u < v`: `v` is pending (an idle `v` forces `cntAt g v = 0`, so `hvreg` reads `a ≤ v` and with `hv` gives `v = a`, contradicting `a` pending); and `v < u` would place the idle `u` inside `v`'s own pending span by `cntAt_sub_of_pend g hg v`, since `v < u ≤ a ≤ v + cntAt g v`.
- [x] Apply `exists_ladderPath_of_walk_of_pins (insObj g a l u l) (insCnt g a l u l)` with: `insObj_step hg hl hrep u l (le_of_lt hua') (hself u _ hu0)` for `hw`; `insCnt_idle hg hpa hcl` for `hidle`; `insCnt_pend_pend hg hl hpa hcl u l hu0 hua'` and `insCnt_pend_idle hg hl hpa hcl u l hu0 hua'` for `hpp`/`hpi`; and Phase 4's `insPins_of_region_start` for `hpins`. *(deviation: altered — each cited lemma is applied with its full explicit argument list (`insCnt_idle hg hpa hcl u l`, not `insCnt_idle hg hpa hcl`) and the `u ≤ a` slots are discharged by `by omega` rather than `le_of_lt hua'`; same lemmas, same routing)*
- [x] Read the conclusion at `v` through `insObj_of_gt u l v hlt` then `spliceObj_eq_of_le hl v hv` for the object half, and `insCnt_of_gt u l v hlt` then `spliceCnt_add_of_mem_region hl v hv hvreg` for the countdown half.
- [x] `exists_ladderPath_at_region` (Goal, signature as pinned below): `by_cases hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true`; on the `true` branch apply the landed `exists_ladderPath_at_region_of_pend_past` (which does not read `hself`); on the `false` branch `push_neg` and `Bool.not_eq_true` give the regime witness for the idle-past half. *(deviation: altered — `push Not` in place of the named `push_neg`, which is deprecated on this toolchain and would add two warnings to a warning-free module; same tactic, repository-standard surface)*
- [x] Docstring both. State explicitly: `hself` is the self-loop premise the parent's Phase 11.11 decided to carry, it is a genuine additional premise on a general object relation and not a consequence of `IsLadderPath`, it is stated path-locally (only at the path's own idle positions at or below `a`) rather than globally over `Q`, and the join is unconditional in the REGIME sense — it needs no pending-past hypothesis — while still carrying `hself` because its idle-past branch does. Cite `specs/evidence/seam-gluing-ray-product/ladder-idle-past-interface-decision.lean` by path for the probe whose carrier's `step` is total, and say that the probe therefore decides refutability and not provability.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: a `#guard_msgs in #print axioms` pin for each of the two names.
- [x] Record in `issues.jsonl` the `hself` shape that actually worked, and whether the `u < v` argument needed both halves as written.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: Two declarations, 70-120 lines with docstrings (the landed
`exists_ladderPath_at_region_of_pend_past` is a 3-line composition, re-derived at authoring; the
idle-past half carries the `u`-extraction and the `u < v` argument on top of an otherwise
mechanical application), and two files change on the primary route. Confirm by `git diff --stat`
before the commit; if the contingency below fires, three files change instead and that is the
declared contingency rather than a deviation.

**Tier Justification**: Landing the two names is the first point at which this task exposes
symbols the parent task's Phase 11.12 and the counter-lift consumer will read, so the one-hop
dependent set — `FormalSystem` (the root that imports `LadderAgree`), the `RaySummary` aggregator,
and `BimodalTest.Metalogic.KTypeSummaryAxiomTest` — must be built rather than only the module
itself.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - exists; the two existentials, at the end of `section Cascade`
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - exists; two pins added
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCascade.lean` - does NOT exist; CONTINGENCY ONLY, created solely if the Rollback/Contingency trigger below fires (`LadderAgree.lean` past 3,400 lines or the raised baseline rejected). On the primary route this phase does not create it and leaves it absent

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0; `… -- build FormalSystem` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0. Read the guard's `result` subcommand, never a piped exit code.
- `#print axioms` on both names shows a subset of `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.
- Both signatures match the `## Lean Challenge Statements` block token for token — in particular neither acquires a `hpa` binder and neither loses `hself`.
- `grep -rn 'exists_spliced_ladderPath_of_idle_past' FormalSystem/ Tests/` still returns docstring lines only; no declaration claims that name.
- `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 6: The Records Brought Current [COMPLETED]

**Goal**: Every record that says these names are unlanded, that no binder was added to them, or
that the restated existential is open, brought current — without touching the three claims that
still stand: the `spliceObj`-shaped refutation, the continued reservation of
`exists_spliced_ladderPath_of_idle_past`, and the self-loop's status as a genuine premise.

**Tasks**:

- [x] `LadderAgree.lean`'s `section Cascade` opening docstring (the paragraph naming the three declarations that carry the interface): change `exists_ladderPath_at_region_of_idle_past` and `exists_ladderPath_at_region` from "NOT landed" to landed, naming `hself`. Leave the `exists_spliced_ladderPath_of_idle_past` refutation paragraph above it byte-identical.
- [x] `LadderAgree.lean`'s "What the idle-past half needs, and why it is not landed here" subsection: retitle and rewrite. Its four bullets are now: the rigidity bullet stands (it is why the walk had to move); the splice-refutation bullet stands; the third bullet's "the iteration over the pins is unbuilt, no existential is claimed" clause is replaced by what landed and by the finding that no iteration was needed; the fourth bullet's "the restated existential is open, not known" is replaced by the statement that it is now landed under `hself` and that the `spliceObj`-shaped one remains refuted.
- [x] `LadderAgree.lean`'s self-loop subsection docstring: the sentence "no binder is added to any of `exists_ladderPath_at_region_of_idle_past`, `exists_ladderPath_at_region` or `exists_spliced_ladderPath_of_idle_past`, all three of which remain unclaimed names" is now false for two of the three. Replace it with the true statement: the self-loop is carried on `insObj_step` and, path-locally, on the two names this task landed; `exists_spliced_ladderPath_of_idle_past` remains unclaimed. Keep the candidate-(b) paragraph and its import-DAG reason verbatim.
- [x] `LadderAgree.lean`'s sizing paragraph: add one sentence recording that the cascade's recurrence was NOT consumed by the construction that closed the pin half, and that `cascadeDemand*`, `pinnedRegions*` and `pin_deficit_le_of_lengthen` stay as the record of the iteration the single insertion made unnecessary. Do not delete any of them.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: the two prose blocks at the pend-past pin and at the idle-insertion subsection both assert the three names are "claimed by nothing" and that "no binder was added". Bring both current in the same three-way split; change no existing `#guard_msgs` pin.
- [x] *(deviation: narrower — three inventory blocks rolled, not four; `FormalSystem/README.md` did not move)* `bash scripts/check-module-invariants.sh --emit-inventory` to roll every generated inventory block the changed line counts move, then `--emit-inventory --check` to confirm a rewrite would change no byte. Do NOT hand-edit a generated block. `LadderAgree.lean`'s description cell in `RaySummary/README.md` is a `<!-- TODO: add description -->` placeholder at authoring and is left as it is — filling it is not this task's scope.
- [x] *(deviation: altered — the sweep surfaced four further stale prose records in `LadderAgree.lean` and three in the test file beyond the enumerated passages; all brought current, prose only, no declaration or `#guard_msgs` pin touched)* Re-run `grep -rn 'exists_ladderPath_at_region' FormalSystem/ Tests/` and confirm every remaining prose occurrence is consistent with the landed state.
- [x] Record in `issues.jsonl` how many generated inventory blocks actually rolled (the parent's Phase 11.11 found four: `RaySummary/README.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md` and the root `README.md`) and whether any other file moved.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: No Lean declaration is added, removed or restated in this phase, and six
files change: the two Lean files (docstring and prose text only) plus the four generated inventory
blocks the parent's Phase 11.11 measured. Confirm by `git diff --stat` and by
`git diff -U0 -- 'FormalSystem/**/*.lean' 'Tests/**/*.lean' | grep -cE '^[+-](theorem|def|lemma|abbrev|instance)'` being 0; if fewer than four inventory blocks roll, that is a narrower outcome, not a deviation.

**Tier Justification**: The inventory regeneration rewrites generated blocks in four README files
across three directory levels, which is a multi-file surface no single-module build observes, so
the covering check is `bash scripts/check-module-invariants.sh --emit-inventory --check` together
with guarded scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and
`BimodalTest.Metalogic.KTypeSummaryAxiomTest` for the two docstring edits.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - exists; four docstring passages brought current, no declaration changed
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - exists; two prose blocks brought current, no pin changed
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - exists; regenerated inventory block (line count only)
- `FormalSystem/Metalogic/README.md` - exists; regenerated inventory block
- `FormalSystem/README.md` - exists; regenerated inventory block
- `README.md` - exists; regenerated repository-metrics inventory block

**Verification**:

- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 — a rewrite would change no byte.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `bash scripts/readme-lint.sh` exits 0 with zero broken references.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on every changed non-`specs/**` file.
- `grep -n 'no binder is added' FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` returns nothing, and `grep -n 'exists_spliced_ladderPath_of_idle_past' FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` still shows the refutation paragraph.

---

### Phase 7: The Complete Gate Set and the Summary [COMPLETED]

**Goal**: The task's terminal phase: the full gate set run and read, and the summary written with
the finding the parent's reviser needs — that the pin half closed with a single insertion, that
both names carry an explicit path-local self-loop, and that the cascade's recurrence is unconsumed
record rather than live machinery.

**Tasks**:

- [x] Write `specs/853_ladder_path_insertion_cascade_idle_past/summaries/01_insertion-cascade-idle-past-summary.md` per `context/formats/summary-format.md`: the seven declarations with their roles, the `hself` premise and its exact shape, the single-insertion finding against the anticipated iteration, the unconsumed sizing record, every recorded deviation, and the measurements table (`LadderAgree.lean` lines and baseline before and after, axiom-test lines and baseline before and after, inventory blocks rolled).
- [x] State plainly in the summary what task 761's Phase 11.12 and the counter-lift consumer inherit: the admissibility half of the counter-lift lemma is now unconditional in the pending-forever regime and conditional on `hself` in the idle-past regime, rather than conditional with nothing available.
- [x] Run the complete gate set and read its verdict, not a piped exit code. *(deviation: altered — discharged against the SCOPED tier per this dispatch's Batch Gate Deferral directive, not the complete set independently: this task is one of several implement-phase dispatches in one multi-task /orchestrate batch, so the full set runs once for the whole batch at the end of the invocation and is attributed back by `modified_files`. Every verdict read below was read from the command's own exit status, never a piped one.)*
- [x] Record in `issues.jsonl` any gate that needed a second run, and the total wall clock of the unscoped build. *(deviation: narrower — no gate needed a second run in this phase and no unscoped build was launched here, the unscoped build being the deferred batch-stage gate; both facts recorded in `issues.jsonl` and in the summary's gate-deferral subsection rather than left as a silent omission.)*

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: One new `specs/**` file and no change to any Lean declaration or any file
under `FormalSystem/` or `Tests/`. Confirm by `git diff --stat` showing only the summary, and by
`git diff -U0 -- 'FormalSystem/**/*.lean' 'Tests/**/*.lean'` being empty.

**Files to modify**:

- `specs/853_ladder_path_insertion_cascade_idle_past/summaries/01_insertion-cascade-idle-past-summary.md` - does not exist; created by this phase

**Verification**:

- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete gate set, every gate, no `--only-gate` filter and no `--skip-slow`. A selected-subset or `--skip-slow` pass does NOT satisfy this phase.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped) exits 0, read through the guard's `result` subcommand.
- `bash scripts/check-module-invariants.sh` exits 0; `bash scripts/check-evidence-probes.sh` exits 0; `bash scripts/readme-lint.sh` exits 0; `bash scripts/check-copyright-headers.sh` exits 0.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0 over every non-`specs/**` file this task changed.
- `grep -rcE 'sorry|native_decide|^axiom|:= True|:= trivial' FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` is 0, and `#print axioms` on all seven Goals shows no `sorryAx`.
- `bash .claude/scripts/validate-artifact.sh specs/853_ladder_path_insertion_cascade_idle_past/summaries/01_insertion-cascade-idle-past-summary.md summary` exits 0.

## Lean Challenge Statements

The seven `theorem` declarations below are this plan's Goals, with `sorry` bodies, listed in the
order the phases prove them (Phase 1's two, Phase 2's one, Phase 3's one, Phase 4's one, Phase 5's
two). The identifier set here equals the identifier set named under `- **Goals**:` above. Every
landed object (`LadderState`, `IsLadderPath`, `objAt`, `cntAt`, `Drift`, `insObj`, `insCnt`) is
imported from the library rather than pinned, because it is landed. Identifiers and connectives
are ASCII for the snapshot tool's regex.

All seven were elaborated standalone at this plan's authoring time through the build guard
(`bash .claude/scripts/lake-build-guard.sh build --timeout 500 -- env lean <file>`):
`exit_status=0`, zero errors, exactly seven `declaration uses 'sorry'` warnings — one per theorem.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe853

theorem drift_lipschitz_two_sided (n : Int -> Nat)
    (hd : forall t : Int, Drift (n t) (n (t + 1))) (u v : Int) :
    ((n u : Int) - n v).natAbs <= (u - v).natAbs := sorry

theorem exists_ladderPath_of_walk_of_pins {Q : Type} {step : Q -> Q -> Bool} {pend : Q -> Bool}
    (w : Int -> Q) (c : Int -> Nat)
    (hw : forall v, step (w v) (w (v + 1)) = true)
    (hidle : forall v, pend (w v) = false -> c v = 0)
    (hpp : forall v, pend (w v) = true -> pend (w (v + 1)) = true -> c (v + 1) + 1 = c v)
    (hpi : forall v, pend (w v) = true -> pend (w (v + 1)) = false -> c v = 0)
    (hpins : forall s v, pend (w s) = false -> pend (w (s + 1)) = true ->
      pend (w v) = false -> pend (w (v + 1)) = true ->
      ((c (s + 1) : Int) - c (v + 1)).natAbs <= (s - v).natAbs) :
    exists g' : Int -> LadderState Q pend, IsLadderPath step pend g' /\
      (forall v, objAt g' v = w v) /\ (forall v, cntAt g' v = c v) := sorry

theorem exists_region_start_of_idle_past {Q : Type} {step : Q -> Q -> Bool} {pend : Q -> Bool}
    (g : Int -> LadderState Q pend) (hg : IsLadderPath step pend g) (a p : Int)
    (hpa : pend (objAt g a) = true) (hp : p <= a) (hpi : pend (objAt g p) = false) :
    exists s : Int, p <= s /\ s + 1 <= a /\ pend (objAt g s) = false /\
      pend (objAt g (s + 1)) = true /\ a <= s + 1 + (cntAt g (s + 1) : Int) /\
      (forall t : Int, s < t -> t <= a -> pend (objAt g t) = true) := sorry

theorem insRegionStart_trichotomy {Q : Type} {step : Q -> Q -> Bool} {pend : Q -> Bool}
    {g : Int -> LadderState Q pend} {a : Int} {l : Nat}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l <= cntAt g a)
    (u : Int) (hu0 : pend (objAt g u) = false) (hu1 : pend (objAt g (u + 1)) = true)
    (hua : u + 1 <= a) (hreg : a <= u + 1 + (cntAt g (u + 1) : Int))
    (hmax : forall t : Int, u < t -> t <= a -> pend (objAt g t) = true)
    (x : Int) (hx0 : pend (insObj g a l u l x) = false)
    (hx1 : pend (insObj g a l u l (x + 1)) = true) :
    (x = u /\ insCnt g a l u l (x + 1) = cntAt g (u + 1) + l)
    \/ (x + (l : Int) < u /\ pend (objAt g (x + (l : Int))) = false
        /\ pend (objAt g (x + (l : Int) + 1)) = true
        /\ insCnt g a l u l (x + 1) = cntAt g (x + (l : Int) + 1))
    \/ (a + (l : Int) <= x /\ pend (objAt g (x - (l : Int))) = false
        /\ pend (objAt g (x - (l : Int) + 1)) = true
        /\ insCnt g a l u l (x + 1) = cntAt g (x - (l : Int) + 1)) := sorry

theorem insPins_of_region_start {Q : Type} {step : Q -> Q -> Bool} {pend : Q -> Bool}
    {g : Int -> LadderState Q pend} {a : Int} {l : Nat}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l <= cntAt g a)
    (u : Int) (hu0 : pend (objAt g u) = false) (hu1 : pend (objAt g (u + 1)) = true)
    (hua : u + 1 <= a) (hreg : a <= u + 1 + (cntAt g (u + 1) : Int))
    (hmax : forall t : Int, u < t -> t <= a -> pend (objAt g t) = true) :
    forall s v : Int, pend (insObj g a l u l s) = false ->
      pend (insObj g a l u l (s + 1)) = true ->
      pend (insObj g a l u l v) = false -> pend (insObj g a l u l (v + 1)) = true ->
      ((insCnt g a l u l (s + 1) : Int) - insCnt g a l u l (v + 1)).natAbs
        <= (s - v).natAbs := sorry

theorem exists_ladderPath_at_region_of_idle_past {Q : Type} {step : Q -> Q -> Bool}
    {pend : Q -> Bool} {g : Int -> LadderState Q pend} {a : Int} {l : Nat}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l <= cntAt g a)
    (hidle : exists p : Int, p <= a /\ pend (objAt g p) = false)
    (hrep : objAt g a = objAt g (a + (l : Int)))
    (hself : forall p : Int, p <= a -> pend (objAt g p) = false ->
      step (objAt g p) (objAt g p) = true)
    (v : Int) (hv : v <= a) (hvreg : a <= v + (cntAt g v : Int)) :
    exists g' : Int -> LadderState Q pend, IsLadderPath step pend g' /\
      objAt g' v = objAt g v /\ cntAt g' v = cntAt g v + l := sorry

theorem exists_ladderPath_at_region {Q : Type} {step : Q -> Q -> Bool} {pend : Q -> Bool}
    {g : Int -> LadderState Q pend} {a : Int} {l : Nat}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l <= cntAt g a)
    (hrep : objAt g a = objAt g (a + (l : Int)))
    (hself : forall p : Int, p <= a -> pend (objAt g p) = false ->
      step (objAt g p) (objAt g p) = true)
    (v : Int) (hv : v <= a) (hvreg : a <= v + (cntAt g v : Int)) :
    exists g' : Int -> LadderState Q pend, IsLadderPath step pend g' /\
      objAt g' v = objAt g v /\ cntAt g' v = cntAt g v + l := sorry

end Probe853
```

## Testing & Validation

- [ ] Each of the seven Goals is a `theorem` in `FormalSystem.Metalogic.Decidability.RaySummary` whose signature matches the Challenge block token for token, with `#print axioms` showing no `sorryAx`.
- [ ] Neither `exists_ladderPath_at_region_of_idle_past` nor `exists_ladderPath_at_region` is landed as a weakened restatement: neither acquires a pending-past hypothesis, neither drops `hself`, and neither has its conclusion narrowed from the pinned existential.
- [ ] `exists_spliced_ladderPath_of_idle_past` is still claimed by nothing: `grep -rn 'theorem exists_spliced_ladderPath_of_idle_past' FormalSystem/` returns nothing.
- [ ] No pin hypothesis of `exists_spliced_ladderPath` or `exists_ladderPath_of_walk` is dropped or relaxed: `git diff` names neither statement.
- [ ] `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial'` is 0 on every `FormalSystem/` file this task changes.
- [ ] `LadderAgree.lean` passes the certificate-freedom grep `certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod` with no match, and its import list is unchanged at `AnchorLayer` + `CounterQuotient`.
- [ ] `wc -l` on `LadderAgree.lean` and on `KTypeSummaryAxiomTest.lean` is below each file's own in-source `longFile` baseline, and every raise is recorded in the summary's measurements table.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 (no probe count changes — this task wires no new probe).
- [ ] `bash scripts/readme-lint.sh` exits 0 with zero broken references.
- [ ] `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on every changed non-`specs/**` file.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped) exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0 with no gate filter and no `--skip-slow`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — the seven new declarations (two lift-lemma strengthenings in `section Path`, five cascade declarations at the end of `section Cascade`), the four brought-current docstring passages, and the raised in-source `longFile` baseline.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — seven `#print axioms` pins and two brought-current prose blocks.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — regenerated inventory blocks (line counts only; no hand edit).
- `specs/853_ladder_path_insertion_cascade_idle_past/summaries/01_insertion-cascade-idle-past-summary.md` — the summary, carrying the single-insertion finding and the `hself` premise for task 761's reviser.

## Rollback/Contingency

- Every phase is its own commit, and Phases 1-4 land material that is useful independently of
  whether Phase 5 closes: the anchor-free lift is a strictly more general lift lemma, the
  region-start extraction is the regime hypothesis made usable, and the trichotomy and pin bound
  are the pin half the recorded mechanism said had no landed component. A Phase 5 blocker
  therefore never requires reverting them.
- **The module-split contingency.** Trigger: `LadderAgree.lean` passes 3,400 lines, or
  `scripts/check-module-invariants.sh` rejects the raised in-source baseline. Action: create
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderCascade.lean` importing
  `FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and nothing else, with a copyright
  header and a contract docstring; move Phases 3-5's five declarations into it; restore
  `LadderAgree.lean`'s baseline to `2900`; add the import line to both
  `FormalSystem/Metalogic/Decidability/RaySummary.lean` (after the `LadderAgree` line) and
  `FormalSystem.lean`'s RaySummary block (alphabetically between `LadderAgree` and `LadderCell`);
  add a `RaySummary.LadderCascade` bullet to the aggregator's module docstring; re-run
  `check-module-invariants.sh --emit-inventory` and hand-write the new row's description cell,
  which the generator seeds as `<!-- TODO: add description -->`. Phases 1-2's two declarations
  stay in `LadderAgree.lean` either way. `state.json`'s `file_scope` already names this path, so
  the contingency widens no declared territory.
- **If a `hpins` pair genuinely needs `d > l`** (Phase 4's recorded blocker condition): mark
  Phase 4 `[BLOCKED]` and report the pair and its deficit. Do not generalise `d` in place —
  the pinned signatures of Phases 3, 4 and 5 all instantiate `d := l`, so a general `d` is a
  plan revision, not a deviation (`rules/plan-compliance.md`, Statement Fidelity).
- **If an intentional rollback of uncommitted work becomes necessary**, follow
  `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation
  shape, including its out-of-scope override flag. Do not emit a bare `git-snapshot.sh 853` as a
  routine start-of-phase precaution; an ordinary defensive checkpoint before risky work uses
  `--no-revert`.
