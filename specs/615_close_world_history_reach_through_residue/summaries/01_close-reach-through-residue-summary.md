# Implementation Summary: Close the world-history reach-through residue

- **Task**: 615 - Close world history reach-through residue
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T00:16:00Z
- **Completed**: 2026-09-18T00:40:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_close-reach-through-residue.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The possible-world-index retarget's 36-site residue is closed. One three-line accessor lemma
(`WorldHistory.respects_task`) replaced 22 hand-spelled dependent projections, the two named
layer-crossing defects were restated at the `state` layer, the never-firing `CoeOut` instance was
deleted, and the remaining 13 sites are disposed of by the explicit triage recorded below. No
`WorldHistory` consumer outside `FormalSystem/Semantics/PartialHistory.lean` now opens the
subtype.

## What Changed

- `FormalSystem/Semantics/PartialHistory.lean` — added `WorldHistory.respects_task`
  (`F.TaskRel (τ.state s) (t - s) (τ.state t)`, proved by feeding `τ.property` at both endpoints
  to `PartialHistory.respects_task`; deliberately not `@[simp]`, since it proves a relation
  rather than an equation). Deleted the `CoeOut (WorldHistory F) (PartialHistory F)` instance and
  its docstring.
- `FormalSystem/Semantics/IntNormalForm.lean` — 1 call site swept; `WorldHistory.path`'s body
  changed from `fun t => τ.val.states t (τ.property t)` to `τ.state`, with the docstring rewritten
  to say the accessor now reads through `state`.
- `FormalSystem/Semantics/ShiftSet.lean` — 2 call sites swept.
- `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` — 4 call sites swept (the `_ _`
  placeholder form; the two underscores simply disappear).
- `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — 2 call sites swept.
- `FormalSystem/Semantics/Extension/Extension.lean` — `occurrence`'s statement changed from
  `∃ τ : WorldHistory F, τ.val.states x (τ.property x) = w` to `∃ τ : WorldHistory F, τ.state x = w`;
  the proof term `exact ⟨τ, hext.agree x rfl⟩` is unchanged, and both consumers
  (`Extension.lean`'s `hF_nonempty` and `Semantics/Validity.lean`'s `not_validOn_bot`) destructure
  as `⟨τ, _⟩` and needed no edit.
- `FormalSystem/Metalogic/Independence/{PastingIndependence,ForwardDeterministicFrame,DriftHistories,LoopingDuration,RealTranslationFrame,CoNotPriorU}.lean`
  — 8 call sites swept.
- `FormalSystem/Metalogic/{Algebraic/FlowFrame,WeakCanonical/IntegerModel/ReynoldsBridge,Decidability/Verified/Bridge/RegionFrame}.lean`
  — 5 call sites swept.
- Four `rw [WorldHistory.states_eq_state]` lines, which lose their rewrite target once the
  surrounding hypotheses arrive in `state` normal form, were adjusted in the same edits:
  `ForwardDeterministicFrame.lean` trimmed to `rw [h] at hτr`, and one line each deleted in
  `FlowFrame.lean` (two) and `RegionFrame.lean` (one).

## Decisions

- **`respects_task` is not `@[simp]`.** It proves `F.TaskRel _ _ _`, not an equation, so there is
  no normal form for simp to drive toward.
- **The four `states_eq_state` rewrite lines were trimmed or deleted, not worked around.** Once a
  hypothesis comes from `τ.respects_task`, it is already in `state` form; keeping the rewrite
  would have required re-introducing the dependent projection just to rewrite it away.
- **`WorldHistory.path` was redefined through `state` rather than deleted.** It is the
  `ℤ`-indexed reading the BiLasso and periodic-extension layers are stated over; the two bodies
  are definitionally equal, so all three `rfl` lemmas riding on it (`IntNormalForm.lean:325`,
  `Decidability/BiLasso/Extend.lean:89`, `Decidability/BiLasso/Basic.lean:276`) still close by
  `rfl`.
- **The `CoeOut` instance was deleted rather than retained defensively.** It was dead by every
  available measure: no `↑τ` coercion of a world history anywhere in the tree, no
  `(τ : PartialHistory F)` ascription of one, and all nine layer crossings spelled with an
  explicit `.val`/`.property`. The full rebuild after deletion is the real confirmation, and it
  passed, so the plan's documented abort path was not needed.

## Plan Deviations

- **Phase 4 verification count altered.** The plan predicted the post-sweep inventory grep would
  return exactly 4 hits inside `PartialHistory.lean`; it returns 6. The two extra hits belong to
  the Phase 1 lemma, which did not exist when research took the measurement — its docstring
  (prose, not code) and its proof body. See the count-deviation note under the reach-through
  triage below.
- **Phase 4's one-hop build was replaced by a full build.** The phase's own Scope Hypothesis
  requires this when a `.path` dependent turns up outside the enumerated set of three `rfl`
  lemmas, and several did (`PeriodicExtension.lean:162-163`, `:406-407`, and
  `IntNormalForm.lean:343`, `:530`, which mention `.path` in statements).
- **Line numbers cited in the plan drifted for three sites.** `CoNotPriorU.lean` is at `:367-368`
  (plan: `:371-372`) and `ReynoldsBridge.lean` at `:642`/`:832` (plan: `:648`/`:838`). The site
  lists were re-derived from the phase greps, as each phase's Scope Hypothesis directs; the
  per-directory counts (9 and 13) matched the plan exactly.
- **Phases 2 and 3 were executed in one edit pass and verified by one shared full build**, then
  committed as two separate per-phase commits. The plan's own dependency analysis places them in
  the same wave and marks them parallel-dispatchable on disjoint file sets.

## Reach-through triage (28 sites)

| Site | Disposition |
|------|-------------|
| `Semantics/IntNormalForm.lean:328` | REWRITTEN (Phase 2) |
| `Semantics/ShiftSet.lean:244`, `:335` | REWRITTEN (Phase 2) |
| `Semantics/PlusLanguage/PlusPasting.lean:85`, `:86`, `:101`, `:104` | REWRITTEN (Phase 2) |
| `Semantics/PlusLanguage/PlusDeterminism.lean:108`, `:110` | REWRITTEN (Phase 2) |
| `Metalogic/Independence/PastingIndependence.lean:156` | REWRITTEN (Phase 3) |
| `Metalogic/Independence/ForwardDeterministicFrame.lean:269`, `:270` | REWRITTEN (Phase 3) |
| `Metalogic/Independence/DriftHistories.lean:137` | REWRITTEN (Phase 3) |
| `Metalogic/Independence/LoopingDuration.lean:83` | REWRITTEN (Phase 3) |
| `Metalogic/Independence/RealTranslationFrame.lean:156`, `:163` | REWRITTEN (Phase 3) |
| `Metalogic/Independence/CoNotPriorU.lean:367-368` | REWRITTEN (Phase 3) |
| `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:642`, `:832` | REWRITTEN (Phase 3) |
| `Metalogic/Algebraic/FlowFrame.lean:376`, `:381` | REWRITTEN (Phase 3) |
| `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:336` | REWRITTEN (Phase 3) |
| `Semantics/IntNormalForm.lean:282` (`WorldHistory.path` body) | FIXED (Phase 4) — body is now `τ.state` |
| `Semantics/Extension/Extension.lean:219` (`occurrence` statement) | FIXED (Phase 4) — statement is now `τ.state x = w` |
| `Semantics/PartialHistory.lean:420` (`state` body) | KEEP — this *is* the accessor being defined |
| `Semantics/PartialHistory.lean:425` (`states_eq_state` statement) | KEEP — the proof-irrelevance bridge itself |
| `Semantics/PartialHistory.lean:426` (`states_eq_state` proof) | KEEP — same |
| `Semantics/PartialHistory.lean:482` (`timeShift` body) | KEEP — constructs the subtype pair, so it must open it |

**22 REWRITTEN, 2 FIXED, 4 KEEP.** The four KEEP sites are the accessor API itself and are the
only places in the tree where the subtype may legitimately be opened.

**One count deviation from the plan.** The plan's Phase 4 verification predicted the
post-sweep inventory grep would return exactly 4 hits, all inside `PartialHistory.lean`. It
returns 6: the 4 KEEP sites above, plus two lines belonging to the Phase 1 lemma that did not
exist when research took the measurement — its docstring at `:433` (prose naming the pattern it
replaces, not code) and its proof body at `:440`. The proof body is a fifth legitimate
accessor-API site by exactly the same reasoning as the other four: `WorldHistory.respects_task`
is the sanctioned single place the `respects_task` obligation crosses the subtype boundary. No
site outside `PartialHistory.lean` survives.

## Layer-crossing triage (9 sites)

| Site | Disposition |
|------|-------------|
| `Semantics/Extension/Extension.lean:172` | KEEP |
| `Semantics/Extension/PeriodicExtension.lean:159` | KEEP |
| `Semantics/Extension/PeriodicExtension.lean:403` | KEEP |
| `Semantics/Extension/PeriodicExtension.lean:429` (`.property` direction) | KEEP |
| `Metalogic/Decidability/BiLasso/Agreement.lean:114` | KEEP |
| `Metalogic/Decidability/BiLasso/Agreement.lean:137` | KEEP |
| `Semantics/IntTransfer.lean:205` | KEEP |
| `Semantics/IntTransfer.lean:235` | KEEP |
| `Semantics/PartialHistory.lean:444` (`WorldHistory.ext`) | KEEP |

**All 9 KEEP**, for one reason stated once for the group: `PartialHistory.Extends` is a
partial-history-layer relation, the Extension Theorem is out of this task's scope, and the only
world-history-level restatement that would remove the crossing *is* the flat-structure refactor.
Introducing a world-history-level `Extends` here would relocate the bridging rather than remove
it — precisely what the predecessor research warned against. `IntTransfer.lean:205`/`:235`
(`WorldHistory.map`/`comap`) and `PartialHistory.lean:444` (`WorldHistory.ext`) construct or
destructure the subtype pair directly, so they cannot avoid it while `WorldHistory` is a subtype.

(`PartialHistory.lean:444` is the line the plan cited as `:433`; the Phase 1 lemma pushed it
down 13 lines and the Phase 5 deletion pulled it back up 3.)

## Parked items

- **`WorldHistory.ext`** (`PartialHistory.lean:444`) — zero call sites, but it carries `@[ext]`,
  so deleting it silently changes what the `ext` tactic does on a world-history goal. Retained
  deliberately; belongs to the flat-structure task (research R6).
- **`WorldHistory.states_eq_state`** (`PartialHistory.lean:425`) — drops to zero *explicit* call
  sites after Phase 3, but remains `@[simp]` and may still fire implicitly. An explicit-call-site
  count is not evidence of deadness for a simp lemma, so it is retained.

## Verification

- Build: Success — `lake build FormalSystem` completed 2660 jobs with zero error lines, and an
  independent unguarded `lake build FormalSystem` re-check afterwards exited 0 as a no-op
- Sorry count: 0 in non-Boneyard `FormalSystem/` (`lean-sorry-census.sh FormalSystem/` reports
  hits only under `FormalSystem/Boneyard/`; every `sorry` occurrence in live modules is docstring
  prose, e.g. "PROVEN (zero sorry)")
- Vacuous count: 0 attributable to this task. The vacuous-pattern grep returns 2 pre-existing
  hits, neither introduced here: `Boneyard/SemanticBenchmarkToyEvaluator/SemanticBenchmark.lean:67`
  and `Examples/TemporalStructures.lean:480` (`intTimeHistory.domain t := trivial`, a genuine
  proof — that example history's domain really is `fun _ => True`).
- Axiom count: 9 in non-Boneyard `FormalSystem/`, unchanged from the `855d04e86` baseline; the
  diff over this task's five commits contains no `axiom` line in either direction.
- Tests: N/A (no test-suite change; `Tests/BimodalTest` contains no reach-through site)
- Files verified: Yes

### Axiom gate

Verbatim, from `lake env lean specs/615_close_world_history_reach_through_residue/probes/02_final-gate.lean`
(exit 0):

```
'FormalSystem.Semantics.validZTime_iff_validInt' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.truthAt_map' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Exactly the permitted three, with no `sorryAx`. `FormalSystem/MainResults.lean`'s own
`#print axioms` block, re-elaborated during the same build, likewise reports
`[propext, Classical.choice, Quot.sound]` throughout.

The Phase 1 lemma itself depends on `[propext]` alone.

### A verification-method correction worth recording

The per-phase build confirmations taken during Phases 1-5 were **false positives**, and the
phases were committed before any of them had really passed. Two causes compounded:

1. Another `/orchestrate` session held the `lake-build-guard.sh` lock for the whole of Phases 1-5,
   so all five guarded invocations queued rather than running. None of them ever reached `lake`.
2. The completion detectors were wrong in a way that read as green: the first two tested the
   output file for being merely non-empty, which the guard's immediate
   `lake-build-guard: memory pressure detected` stderr line satisfies within a second; the later
   ones grepped for a sentinel that a still-queued build had not yet written.

The tell was structural rather than textual: `.lake/build/lib/lean/.../PartialHistory.olean`
was still timestamped before the Phase 1 edit, and `lake env lean` on a scratch file reported
`Unknown constant FormalSystem.Semantics.WorldHistory.respects_task` — that is, the lemma the
sweep depends on was not in the environment the "passing" builds were supposedly checking. The
four redundant queued invocations were then terminated (SIGTERM, exit 143, which is itself the
record that they had never run), and a single genuine `lake build FormalSystem` was allowed to
take the lock and run to completion against the working tree carrying all five phases.
**Only that last build, and the artifact-level checks re-run after it, are evidence here.**

### Probe 01

The plan's Testing & Validation list includes "the research probe at `probes/01_respects-task-residue.lean`
still elaborates". After Phase 1 it did not, and for the right reason: the probe *declared*
`WorldHistory.respects_task` in order to machine-check it before the library had it, so once the
library had it the probe failed with `has already been declared`. The probe's local declaration
was replaced by a `#check` of the library constant plus an anonymous `example` carrying the
identical proof term, which preserves exactly what the probe was checking. It elaborates again at
exit 0, and its later examples — including the `PlusPasting` `_ _` form and the
`ForwardDeterministicFrame` rewrite — now resolve `τ.respects_task` against the real library
lemma rather than a local stand-in, which is a stronger check than the original.

## Impacts

- `WorldHistory.respects_task` is now the single sanctioned way to read the task-respect
  obligation at the world-history layer; no downstream module needs `.val`/`.property` for it.
- `WorldHistory.path` and `PartialHistory.occurrence` are both stated purely at the `state` layer,
  so a future flat-structure conversion of `WorldHistory` has two fewer sites to touch.
- The `CoeOut (WorldHistory F) (PartialHistory F)` instance is gone, so the codebase no longer
  carries a false signal that subtype crossings are implicit; the nine surviving crossings are all
  explicit and enumerated above.
- `WorldHistory.states_eq_state` now has zero explicit call sites (it remains `@[simp]`).

## Follow-ups

- **The `PossibleWorld` rename** (503 binders plus the namespace) remains blocked on settling
  whether `H_F` or the time-shift quotient `W_F` owns the name; `possible_worlds.tex:1046` makes
  them different objects and `:1050` licenses both names. Out of scope by decision, not oversight.
- **Converting `WorldHistory` from a subtype to a flat structure** is a real net win per research
  (the `CoeOut` instance is now gone, `WorldHistory.ext` has zero call sites, `states_eq_state`
  would go away) at the cost of a ~6-line `toPartialHistory` bridge for the Extension Theorem.
  It relocates bridging rather than removing it, so it belongs in its own task. All nine KEEP
  layer crossings are that task's inbox.
- **`WorldHistory.ext` and `WorldHistory.states_eq_state`** are both retained deliberately (see
  Parked items) and should be re-examined as part of that flat-structure task, not before.
- **Build-guard ergonomics.** `lake-build-guard.sh` writes its live lake output to
  `.lake/build-guard.stdout` but only refreshes `.lake/build-guard.log` and the `state=`/
  `exit_status=` fields of `.lake/build-guard.result` at the end of a run, and it emits its
  memory-pressure notice to stderr immediately on start. A caller that treats "output file is
  non-empty" or "the log's last line says success" as a completion signal will read a queued
  build as a finished one. A documented, unambiguous per-invocation completion sentinel would
  have made this task's false-green episode impossible.

## References

- `specs/615_close_world_history_reach_through_residue/plans/01_close-reach-through-residue.md`
- `specs/615_close_world_history_reach_through_residue/reports/01_close-reach-through-residue.md`
- `specs/615_close_world_history_reach_through_residue/probes/01_respects-task-residue.lean`
- `specs/615_close_world_history_reach_through_residue/probes/02_final-gate.lean`
- Commits `e3cfa4f58`, `0368d633b`, `868f6abb1`, `2536d98d0`, `086463982`
