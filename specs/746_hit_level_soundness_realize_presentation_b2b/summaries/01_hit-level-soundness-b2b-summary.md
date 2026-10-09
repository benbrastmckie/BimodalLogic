# Implementation Summary: Task #746

- **Task**: 746 - Requirement (S) of the ray-product verdict: Hit-level soundness — realize a presentation by a constructed regular ℤ-model (B2b)
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T19:42:00Z
- **Completed**: (not complete — 6 of 8 phases)
- **Effort**: ~2.5 hours total (Phase 1 ~0.5 h against 1 h budgeted; Phase 2 ~0.7 h against 2 h budgeted; Phase 3 ~0.4 h against 2 h budgeted; Phase 4 ~0.3 h against 1 h budgeted; Phase 5 ~0.3 h against 2 h budgeted; Phase 6 ~0.3 h against 1.5 h budgeted)
- **Dependencies**: None. (C) (task 745) is independent; (W) depends on this and on (C).
- **Artifacts**: plans/01_hit-level-soundness-b2b.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-6 of 8, across six single-phase dispatches (seq 13, 14, 15, 16, 17 and 18). Phase 6
builds the model: `frameOf`, the presentation's own state set `Q` carried through
`FrameOver.ofSlicedStep` with the time-constant relation `fun _ q q' => step q q' = true`,
together with its regularity instance, the explicit record that the carrier `ℤ × Q` is NOT
finite, `modelOf` whose valuation reads the state component's label, and the three rewrite
lemmas (`modelOf_valuation`, `frameOf_step`, `frameOf_mem_HF_iff`) through which Phase 7 reads
runs off histories and back. Every frame law is cited from `Semantics/SlicedFrame.lean`, none
re-proved and none generalized — the whole section is seven one-line citations, which is why it
came in at +113 lines against a ~90-130 budget. Phase 5
closes the consistency conditions: the ten-field `Cons` bundle on a finite labelled presentation
and `cons_localRun`, which reads every field of `LocalRun` off it — `bot` and `imp` from the
per-state label equations, `untl` and `snce` by citing Phases 2 and 3 verbatim, with no new
induction anywhere. Its non-vacuity is permanent and computed: one three-state presentation on
which `UCoh`, `ULive`, `SCoh`, `SLive` and both bi-serialities all hold with real deferral edges
in both time directions, plus a one-label negative control that breaks both liveness conditions
while leaving both coherence conditions true — the `Probe735.pump_isRun` shape. Phase 4 lands
this task's scope line as syntax: `PlusFormula.BoxStabFree` in
`FormalSystem/PlusLanguage/Subformulas.lean`, with its subformula-inheritance lemma and the two
closure-vacuity lemmas that collapse an `Anchored` certificate to its `now` and `atom` fields for
a `box`/`stab`-free `φ` — which is what Phase 7 consumes. It is territory-disjoint from
`Realize.lean` and touched nothing Phases 1-3 landed. Phase 3 completes
the consistency conditions' two temporal halves: the backward (`snce`) mirror, proved outright
rather than transported, in the same module. Phase 2 lands the
first `FormalSystem/` content of this task: the new module
`FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean`, carrying the forward (`untl`) half
of the consistency conditions on a finite labelled presentation and the theorem that they force
`LocalRun`'s `untl` clause on every `step`-path — generically over `sig` and `Q`, with no model,
no frame, and no carrier finiteness anywhere in any statement. It is a transcription of the
research dispatch's compiled probe, not a re-derivation. The aggregator import edge is
deliberately still absent (Phase 8 owns it), so a full build does not yet pull the module.

Phase 1 wires the research dispatch's
machine-checked frame-constructor findings into the tracked, rot-guarded evidence collection, so
that the plan's descoping of the carried 300-500 line "regular-frame constructor for finitely many
fibre shapes per time" prerequisite rests on a green compiled artifact rather than on a report
paragraph. That phase discharged no proof obligation and touched nothing under `FormalSystem/`.
Phases 6-8 (`frameOf`/`modelOf`, `presented_modelOf`, the Hit-level corollary and the
acceptance statement) remain.

## What Changed

### Phase 6

- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` — appended `section Constructed`,
  571 → 684 lines (+117 insertions, −4 deletions; the deletions are the header sentence that said
  `frameOf`/`modelOf` were owed to a later section, replaced by a paragraph describing what
  landed plus a new owed-work sentence naming `presented_modelOf`), zero sorries. Seven
  declarations, each a one-line citation:
  `frameOf (hC : Cons φ lab step) : FrameOver intOrder` = `FrameOver.ofSlicedStep` at `W := Q`
  with `fun _ q q' => step q q' = true` and `fwd`/`bwd` from `Cons.serialFwd`/`Cons.serialBwd`;
  the `instance frameOf_isRegular` from `ofSlicedStep_isRegular`;
  `frameOf_not_finite_worldState : ¬ Finite (frameOf hC).WorldState` from
  `ofSlicedStep_not_finite_worldState`; `modelOf φ lab step hC : TaskModel (frameOf hC).toTaskFrame`
  with valuation
  `fun w p => ∃ h : PlusFormula.atom p ∈ plusSubformulaClosure φ, lab w.2 (clLetter φ h) = true`;
  and the rewrite lemmas `modelOf_valuation`, `frameOf_step`, `frameOf_mem_HF_iff`.
  `FormalSystem.Syntax` and `FormalSystem.Semantics` are opened SECTION-locally, so Phases 2-5's
  elaboration environment is unchanged. No existing declaration in the file was modified.
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix` after the
  pre-commit gate refused the phase commit on the `formalsystem-line-count` drift this phase's
  +113 lines caused. Same remedy Phases 2-5 each applied.

### Phase 5

- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` — appended `section Bundle`,
  452 → 571 lines (+123 insertions, −2 deletions; the deletions replace the header sentence that
  said the `Cons` bundle was still owed), zero sorries. Two declarations:
  `Cons (φ) (lab : Q → (clSig φ).preds → Bool) (step)` — ten named fields in the plan's six
  clause groups (`serialFwd`, `serialBwd`, `botFalse`, `impEq`, `ucoh`, `ulive`, `scoh`, `slive`,
  `nowOnce`, `boxStabFree`) — and `cons_localRun`, exactly the plan-pinned signature, 20 lines of
  proof. No existing declaration in the file was modified.
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` — one added import
  (`…RaySummary.Realize`, which the `RaySummary` aggregator does not yet re-export) and an
  appended non-vacuity section, 132 → 236 lines (+104 insertions), zero sorries: the fixtures
  `sigCons` (`⟨Fin 4⟩`, letters `u = 0`, `g = 1`, `e = 2`, `now = 3`), `QCons` (`Fin 3`),
  `labCons`, `stepCons` (`0 → 0`, `0 → 1`, `1 → 2`, `2 → 2`) and the one-label control
  `labConsBad`, with 15 `#guard`s against the landed declarations themselves rather than
  re-spelled copies.

### Phase 4

- `FormalSystem/PlusLanguage/Subformulas.lean` — appended a `## box/stab-freeness` section,
  256 → 373 lines (+118 insertions, 0 deletions), zero sorries. Four declarations:
  `PlusFormula.BoxStabFree` (seven arms matching `subformulas`: `True` on the two atomic ones,
  conjunction across the three binary ones, `False` on `box` and `stab`),
  `PlusFormula.decidableBoxStabFree` (hand-rolled `Decidable` instance, one arm per constructor,
  so every check below computes with no `Classical` on that path),
  `PlusFormula.boxStabFree_of_mem_subformulas` (inheritance by subformulas, by induction on `φ`),
  and the two plan-pinned closure-vacuity lemmas `not_box_mem_plusSubformulaClosure` and
  `not_stab_mem_plusSubformulaClosure`. Two bullets added to the module header's Main Definitions
  and Main Results lists. No existing declaration in the file was modified.
- `typst/generated/status.typ` — regenerated (line counts moved with the module's growth).

### Phase 3

- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` — appended `section Snce`, 249 →
  452 lines (+203), zero sorries, scoped build green with zero `error:` and zero `warning:`.
  Eight declarations: `SCoh` (the `snce` clause unfolded across one `step`, oriented backward —
  the claim at the LATER state read in terms of the EARLIER one), `bwdDeferGraph` (an edge out of
  every state claiming the past eventuality and lacking its event, to that state's `step`-
  predecessors), `SLive` (acyclicity of that graph), `DischBwd` (the right-hand side of
  `LocalRun`'s `snce` field, open interval `(s, z)` with `s < z`, verbatim), the two decidability
  instances `decidableSCoh`/`decidableSLive`, the backward persistence lemma `persistBwd`, the
  hard direction `disch_of_SCoh_SLive`, the easy direction `u_of_dischBwd`, and the plan-pinned
  `snce_iff_of_SCoh_SLive`. Nothing in the section is defined as an application of a Phase 2
  declaration; `UCoh`/`deferGraph`/`ULive` occur inside it only in docstrings and comments.
- `typst/generated/status.typ` — regenerated (file/line counts moved with the module's growth).

### Phase 2

- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` — new module, 249 lines, zero
  sorries, scoped build green with zero `error:` and zero `warning:`. Ten declarations:
  `UCoh` (the `untl` clause of `PlusTruthAt` unfolded across one `step`, per-edge and decidable),
  `deferGraph` (an edge out of every state claiming the eventuality and lacking its event),
  `ULive` (acyclicity of that graph, decided through `Present.lean`'s `live`), `Disch` (the
  right-hand side of `LocalRun`'s `untl` field), the two decidability instances `decidableUCoh`
  and `decidableULive`, and the four theorems `persist`, `disch_of_UCoh_ULive`, `u_of_disch` and
  the plan-pinned `untl_iff_of_UCoh_ULive`. The module header states the scope line (one seam,
  `box`/`stab`-free `φ`, under `[F.IsRegular]`, over the ℤ time axis) and the four negative
  claims it never makes — no validity statement in any form, no complexity bound, no
  `box`/`stab` realization beyond the degenerate one, and no finite-fibre or finite-width
  assumption (the only finiteness anywhere is `[Fintype Q]` on the PRESENTATION) — records that
  `Cons` is read off `Probe735.not_presented`'s pumping proof rather than HWZ Definition 10's
  bare type set (which `quasistate_does_not_determine_hit` refutes for this semantics), and
  states that the fixtures are forward-only.
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix` (the
  pre-commit gate's own prescribed remedy) after the new `.lean` file moved the live
  `formalsystem-file-count` 670 → 671 and `formalsystem-line-count` 347552 → 347801.
  `FormalSystem.lean` was deliberately NOT regenerated with `mk_all`: that root imports every
  module directly, so adding `Realize` to it would make a full build pull a module the plan
  keeps out of the aggregator until Phase 8. Its 670-vs-671 import warning is therefore expected
  through Phases 2-7 and is Phase 8's to clear.

### Phase 1

- `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean` — new wired
  evidence probe, 283 lines, 18 declarations carried verbatim from the research probe plus a
  91-line house header and a 27-line `#print axioms` foot. POSITIVE content:
  `fib_finite_of_finBranch` / `saturation_of_finBranch` replace
  `FormalSystem.Semantics.ofSlicedStep_fib_finite`'s `[Finite W]` by two-sided finite branching on
  the one-step relation with no carrier hypothesis, two-sided because `TaskFrame.Fib` at negative
  durations is the step relation's preimage and finiteness is not converse-stable;
  `shift_saturation` / `shift_slice_infinite` make it non-vacuous on the genuinely infinite slice
  `ℤ`. REFUTED content: `Rbad_fwd` / `Rbad_bwd_infinite` / `Rbad_fib_infinite` confirm the named
  reset-from-any-level hazard, and `Rok_bwd` / `Rok_fwd_infinite` refute the obvious repair —
  firing the reset only from level `0` merely swaps the failing side, so no reset placement
  rescues an unbounded nondeterministic deadline.
- `scripts/check-evidence-probes.sh` — the probe registered in `WIRED` (one entry appended at the
  end of the array) with its catalogue block in the house verdict-label / what-it-shows /
  what-it-does-not form. Append-only: 57 insertions, 0 deletions.
- `specs/746_hit_level_soundness_realize_presentation_b2b/plans/01_hit-level-soundness-b2b.md` —
  Phase 1 heading `[COMPLETED]`, its four checklist items checked, the stale probe-count
  prediction annotated as a deviation, and a measured Scope-Hypothesis outcome recorded.

## Decisions

- **Phase 6: the valuation is an existential over the closure-membership proof, not a `dite`.**
  An atom holds at `(z, q)` iff it is an atom of `φ`'s subformula closure AND the presentation
  labels `q` with its letter; off the closure it holds nowhere. Membership in
  `plusSubformulaClosure φ` is a `Prop`, so any two proofs are definitionally equal and
  `clLetter φ h'` IS `clLetter φ h` — which is why `modelOf_valuation` is
  `⟨fun hv => hv.2, fun hl => ⟨h, hl⟩⟩` with no transport and no `Subsingleton` appeal. A `dite`
  would have needed `DecidablePred` plumbing and a `dif_pos` rewrite at every use for no gain.
- **Phase 6: off-closure atoms are false, and `Anchored` does not constrain that choice.**
  `Anchored.atom` quantifies over `h : PlusFormula.atom p ∈ plusSubformulaClosure φ`, so it says
  nothing about an atom `φ` never mentions. Making those false keeps the valuation a per-STATE
  datum of the presentation with no extra parameter; `modelOf`'s docstring states this explicitly
  rather than leaving it to be inferred.
- **Phase 6: the sliced relation is inline, not a named helper.** A named `stepRel` abbreviation
  would have been a declaration the plan's `## Lean Challenge Statements` does not carry.
  `IsSlicedStepPath` beta-reduces at this relation, which is why `frameOf_mem_HF_iff`'s
  right-hand side can be spelled `∀ t, step (g t) (g (t + 1)) = true` and still be closed by
  `FrameOver.ofSlicedStep_mem_HF_iff _ _ _ f` outright.
- **Phase 6: the `WorldState` projections needed no coercion help.** `w.2` in the valuation,
  `(z, q)` in `modelOf_valuation` and `p q : ℤ × Q` in `frameOf_step` all unified with the
  `ofSlicedStep` carrier definitionally — no `show`, no `change`, no `TaskFrame.WorldState`
  rewrite. This was the phase's one mechanical risk and it did not materialize.
- **Phase 4: `BoxStabFree` is `Prop`-valued, not `Bool` with a `decide` bridge.** The plan bullet
  offered either spelling. `Prop` is what the `Anchored` fields and the two vacuity lemmas consume
  directly, and — decisively — this phase's own verification criterion is written
  `#eval decide ((…).BoxStabFree)`, which only typechecks when `BoxStabFree` is a `Prop` with a
  `Decidable` instance. Hence the hand-rolled `decidableBoxStabFree`, one arm per constructor,
  which keeps every computed check free of `Classical` on that path.
- **Phase 4: the two modal arms carry the content, so the `stab` lemma is proved outright.** In
  `boxStabFree_of_mem_subformulas` the `box` and `stab` cases need no membership reasoning at all:
  `BoxStabFree (.box _)` is `False`, so the hypothesis discharges them via `absurd hφ not_false`.
  That is also why `not_stab_mem_plusSubformulaClosure` is proved outright rather than by any
  symmetry with the `box` case — the two route through different arms of the recursion.
- **Phase 3: the backward graph reverses `step`, against the plan's parenthetical.** The plan's
  Phase 3 bullet wrote `bwdDeferGraph … := lab y u && !(lab y e) && step x y`; the body landed as
  the converse, `fun x y => lab x u && !(lab x e) && step y x`. `live`/`HasChain` in
  `Present.lean` always ask for an infinite FORWARD chain `G (f n) (f (n + 1))`, so the
  parenthetical hands `live` the forward graph — whose acyclicity is equivalent over a finite `Q`,
  but only through a cycle-extraction argument, and which cannot be read off `persistBwd`'s
  backward stretch directly. The reversal is the house precedent: `Present.lean`'s `bwdLive`
  passes `pathTypes … y x` to `live` for exactly this reason. The label test stays at the edge's
  SOURCE as in `deferGraph`. The same plan bullet instructs recording which argument order of
  `live` is used and why, which is read as delegating the choice; the justification is in
  `bwdDeferGraph`'s docstring, 14 lines of it, including why the forward spelling was rejected.
- **Phase 3: proved outright, no symmetry claimed.** `persistBwd`, `disch_of_SCoh_SLive` and
  `u_of_dischBwd` each have their own content — `persistBwd` recovers the guard over
  `(z - 1 - n, z)` from its own induction hypothesis, and `u_of_dischBwd` walks coherence FORWARD
  from the past witness where `u_of_disch` walks it backward from the future one. The two halves
  share tactic shape, not content, and no declaration in the backward section applies a forward
  one. `SCoh`'s docstring says in so many words that it is not `UCoh` with arguments swapped.

- **Phase 2 — transcription, not re-derivation.** All four proof bodies are
  `evidence/02_cons-untl-core.lean` verbatim; the only change is binder shape (the probe's
  `variable (lab) (step) (u g e)` section line became explicit per-declaration binders, so every
  signature matches the plan's `## Lean Challenge Statements` exactly).
- **Phase 2 — the pinned binder block was kept over a clean linter run.** `[Fintype sig.preds]`
  and `[DecidableEq sig.preds]` go unused in three of the four theorems' types, but they are part
  of the plan's pinned variable block for the whole namespace. Rather than `omit` them and
  diverge from the pinned signature, the two linters are suppressed section-scoped with an
  explanatory comment, following `RaySummary/Compose.lean`'s own precedent for the same linters.
- **Phase 2 — `show` kept over `change`.** `linter.style.show` asks for `change`; the phase's
  task list directs keeping the explicit `show` that beta-reduces the `HasChain` lambda witness
  before `rw [hcast]` (the research tactic survey's recorded finding). The `show` was kept and
  the linter suppressed declaration-scoped with a comment citing the survey.
- All 18 declarations were carried, including the three `def`s (`Rbad`, `Rok`, `Rshift`) and
  `Rshift_fwd`/`Rshift_bwd` that the plan's parenthetical 13-name list omits: "keeping every
  declaration" governs over the non-exhaustive list.
- The axiom foot was written fresh rather than copied — the source probe carried no
  `#print axioms` lines, despite the task text's assumption that it did.
- The header states the descoping claim literally ("the frame constructor is not a dependency of
  requirement (S)"), so the phase's criterion is met mechanically as well as in substance.
- The word `sorry` was kept out of the probe entirely; a first draft of the axiom-foot comment
  said `sorryAx`, which would have made `grep -c sorry` report 1.

## Plan Deviations

- **Task 1** (Phase 6) altered: the new section's `variable` block carries `[Nonempty Q]`, which
  the Phase 6 task body instructs ("taking `[Fintype Q]` (hence `[Finite Q]`) and `[Nonempty Q]`
  from the presentation") but which the plan's `## Lean Challenge Statements` `variable` line
  omits. `FrameOver` carries a `worldNonempty` field and `ofSlicedStep` requires `[Nonempty W]`,
  so without it the pinned `frameOf` is not inhabitable at all; the phase body is the more
  specific instruction and authorizes exactly this. `frameOf`'s and `modelOf`'s own pinned
  signatures are otherwise matched character for character, and the five other declarations the
  phase added are named in its task bullets and the plan's Goals prose with no Challenge pin to
  drift from.
- **Task 1** (Phase 5) altered: the six clause groups landed as TEN named fields. Groups 1-4 each
  name two independent conditions (forward/backward seriality; `botFalse`/`impEq`; `UCoh`/`ULive`;
  `SCoh`/`SLive`), and bundling each pair into a conjunction field would force `cons_localRun` to
  destructure at every use — the opposite of the field-by-field shape the bullet asked for. The
  grouping is recorded in `Cons`'s docstring.
- **Task 3** (Phase 5) altered, three additive changes. (a) The test module gained one
  `import FormalSystem.Metalogic.Decidability.RaySummary.Realize` line against the bullet's
  "append-only", because the `RaySummary` aggregator does not re-export `Realize` until Phase 8;
  without it the fixtures would have had to re-spell `UCoh`/`ULive`/`deferGraph` as evidence probe
  `03_cons-non-vacuity.lean` does, and would then be checking copies rather than the landed
  declarations. (b) The backward half (`SCoh`, `SLive`, `bwdDeferGraph` and their control) was
  added alongside the forward one, per the Phase 3 handoff's instruction to carry its backward
  fixture into the permanent witness; one changed label serves as the control for both time
  directions. (c) The once-only `now` condition is checked by the depth-3 enumeration the bullet
  asks for, which is a computed check on the fixture and NOT a witness of the
  `StepPath`-quantified `Cons.nowOnce` field — the appended test prose states the completeness
  argument as prose and marks it as such rather than implying a machine check.
- **Task 2** (Phase 4) altered: the inheritance lemma does NOT route through the helpers its plan
  bullet named. The bullet said to go "through the existing `subformulas_trans` / per-arm
  membership lemmas rather than re-deriving them"; neither is usable. `subformulas_trans` is a
  statement about membership and says nothing about `BoxStabFree`, and the eight per-arm lemmas
  CONSTRUCT a membership (`ψ ∈ subformulas (.imp ψ χ)`) where this proof must DESTRUCTURE one
  (`ψ ∈ subformulas (.imp a b)` → a three-way disjunction) — the opposite direction. The landed
  proof is an induction on `φ` mirroring `subformulas_trans`'s own arm-for-arm shape and
  destructuring with `simp only [subformulas, List.mem_cons, List.mem_append]` exactly as that
  proof does, so no project lemma is re-derived — which is what the hint was protecting. Statement
  and decomposition are exactly as pinned, nothing is unproved, and no alternative approach was
  substituted, so the phase was not marked `[BLOCKED]`. Annotated inline in the plan and recorded
  in `issues.jsonl` as `plan-defect`/`minor`. No other Phase 4 task was skipped, altered, or
  deferred.
- **Scope Hypothesis** (Phase 4) altered: 118 insertions against the predicted ~60-95. The
  hypothesis's binding half — insertions only, zero existing declarations touched — holds exactly
  (`git diff --stat`: 118 insertions, 0 deletions). The overshoot is documentation: a 22-line
  section-header `/-! … -/` block recording why `SemanticBridge`'s `isBoxFree` is not reusable and
  why the predicate is `Prop`-valued, plus per-declaration docstrings. Library code proper is ~85
  lines, inside the band. Same pattern as Phase 3's overshoot, and recorded so the remaining phase
  estimates are read as code-line estimates that exclude docstring prose.
- **Task 2** (Phase 3) altered: the `bwdDeferGraph` body is the converse of the plan bullet's
  parenthetical spelling — see the first Decisions entry above for the mechanism and the house
  precedent. The bullet's own "record which argument order of `live` is being used and why"
  instruction is what makes this a delegated choice rather than a substitution; it is annotated
  inline in the plan and recorded in `issues.jsonl` as `plan-defect`/`minor`. No other Phase 3
  task was skipped, altered, or deferred.
- **Scope Hypothesis** (Phase 3) altered: +203 lines against the predicted 140-180. The
  hypothesis's actual watch condition — "markedly SHORTER than Phase 2 … a symmetry shortcut" —
  did not fire; the delta came out longer than Phase 2's whole module. The excess is docstring,
  not proof: the orientation justification is 14 lines and the "not `UCoh` swapped" paragraph 8,
  both demanded by this phase's own task bullets. Proof bodies run ~115 lines against Phase 2's
  ~110.

- **Scope Hypothesis** (Phase 2) altered: 249 lines against the predicted ~170-210, still well
  under the phase's own 300-line red line for "the probe is being re-proved rather than
  transcribed". Every proof body is the probe's verbatim; the excess is the ~60-line module
  header the phase's first task itself specifies (scope line plus four negative claims plus the
  `Cons`-provenance paragraph) and two commented linter-suppression blocks. No plan task was
  skipped, altered, or deferred in Phase 2.

- **Scope Hypothesis** (Phase 1) altered: the predicted "14 pre-existing registered probes
  becoming 15" was stale — the gate script actually carried 21 `WIRED` plus 3 `WIRED_REPO`
  entries, so the count is 24 before and 25 after. The plan made that count the test for
  append-only editing; append-only was instead verified structurally from the diff (57 insertions,
  0 deletions, one `WIRED` entry at the end of the array).
- **Scope Hypothesis** (Phase 1) altered: line estimates were low in both files — 283 lines in the
  probe against 175-200 predicted, and 57 lines in the gate script against 12-18. The catalogue's
  comment column is 38 characters wide, so a house-format entry runs long; the two neighbouring
  entries are ~55 and ~60 lines, which is why 57 is in-house-norm and the estimate was the thing
  that was wrong.
- **Task 1** (Phase 1) altered: "keeping ... the `#print axioms` lines" could not be executed as
  written because the source has none; an axiom foot covering all 18 declarations was written, as
  the phase's own Verification criterion requires.

## Verification

### Phase 6

- Build: Success. Scoped guarded build, detached —
  `lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Metalogic.Decidability.RaySummary.Realize`: guard's own exit code 0 (un-piped),
  `✔ [1930/1930] Built …Realize (3.7s)`, `Build completed successfully (1930 jobs)`,
  `lake-build-guard: STATUS: exit_status=0`, 0 `error:`, 0 `warning:`; `.olean` confirmed newer
  than source. No full-project build was run: the plan assigns that to Phase 8, and this
  dispatch's status is `partial`, not `implemented`.
- Sorry count: 0 on `Realize.lean`.
- Sorry inventory: None.
- Vacuous count: 1 repo-wide, unchanged and pre-existing
  (`FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`); 0 lines in this
  phase's additions match `:= (True|Unit|trivial|Trivial)$`.
- Axiom count: 15, unchanged; no new axiom.
- Axiom pins, all exactly `[propext, Classical.choice, Quot.sound]` against the built module:
  `modelOf_valuation`, `frameOf_step`, `frameOf_mem_HF_iff`, `frameOf_not_finite_worldState`,
  `frameOf_isRegular`, `frameOf`, `modelOf` — the plan's two named rewrite lemmas plus every
  other declaration the phase added.
- The regularity instance resolves: `example … : (frameOf hC).IsRegular := inferInstance`
  elaborates silently.
- No finite-width or finite-fibre reintroduction: `grep 'Finite\|WorldState\|FiniteWidth'` over
  this phase's additions returns exactly ONE code hit, `¬ Finite (frameOf hC).WorldState` — the
  negative statement, never a hypothesis.
- `grep -niE 'PlusValidZTime|EXPSPACE|PSPACE|exponential time|complexity bound'` over this
  phase's additions returns nothing.
- Phase 7 consumption contract pre-checked in the scratchpad against the built module: both
  `Presented (modelOf φ lab step hC) τ t φ lab (fun q q' => step q q' = true)` and
  `Anchored (modelOf φ lab step hC) φ t (runTrace lab ρ) σ` elaborate, with `Presented`'s
  `[F.IsRegular]` synthesized for `frameOf hC` with nothing passed at the call site.
- Scope Hypothesis: +113 net (+117/−4) against the ~90-130 band — inside it, and far under the
  200-line tripwire that would have meant a field discharge was being re-proved.

### Phase 5

- Build: Success. Scoped guarded build of
  `FormalSystem.Metalogic.Decidability.RaySummary.Realize` — guard exit 0,
  `✔ [1930/1930] Built …Realize (4.7s)`, `Build completed successfully (1930 jobs)`, 0 `error:`,
  0 `warning:`. Scoped guarded build of `BimodalTest.Metalogic.KTypeFinEvalTest` — guard exit 0,
  `✔ [1933/1933] Built …KTypeFinEvalTest (80s)`, `Build completed successfully (1933 jobs)`,
  0 `error:`, 0 `warning:`. A failing `#guard` is a build error, so all 15 new `#guard`s passed.
  `.olean` newer than source confirmed for both modules.
- Sorry count: 0 on both files. Sorry inventory: None.
- `#print axioms cons_localRun` = exactly `[propext, Classical.choice, Quot.sound]`.
- Vacuous count: 1 repo-wide, pre-existing and unchanged (`int_domain_universal`). This phase's
  insertions contain no `:= True`, `:= Unit`, `:= trivial` or `:= Trivial` body (0 matches in
  `git diff`); `Cons` is a ten-field structure.
- Axiom count: 15, unchanged — no new axiom.
- Non-vacuity, computed: `deferGraph labCons stepCons 0 2 1 2` and
  `bwdDeferGraph labCons stepCons 0 2 1 0` both true, so neither `ULive` nor `SLive` holds merely
  because its graph is empty.
- Negative control, computed and genuinely negative in both directions:
  `!decide (ULive labConsBad stepCons 0 2)`, `live (deferGraph labConsBad stepCons 0 2) 0`,
  `!decide (SLive labConsBad stepCons 0 2)` and `live (bwdDeferGraph labConsBad stepCons 0 2) 0`
  all pass, while `UCoh` and `SCoh` stay true on the same altered labelling.
- Scope Hypothesis: `Realize.lean` +123 against ~130-180 (under, because `cons_localRun` cites
  rather than re-derives); test module +104 against ~70-100 (4 over, prose). `cons_localRun` is
  20 lines against the plan's ~80-line re-derivation tripwire.

### Phase 4

- Build: Success. Scoped guarded build of `FormalSystem.PlusLanguage.Subformulas` — guard exit 0,
  `Build completed successfully (707 jobs)`, 0 `error:`. Then the phase's `interface` tier: the
  module plus its two nearest importing aggregators, `FormalSystem.PlusLanguage` and
  `FormalSystem.Metalogic.Decidability.RaySummary` — guard exit 0, `Build completed successfully
  (1938 jobs)`, 0 `error:`, 0 `warning:`. `.olean` newer than source. (Two
  `linter.style.longLine` warnings on the first scoped run, both on docstring bullets this phase
  added; shortened, and the interface run is clean.)
- Sorry count: 0 in the edited module; task-wide sorry inventory still empty.
- Axiom pins against the built module: `not_box_mem_plusSubformulaClosure` and
  `not_stab_mem_plusSubformulaClosure` each exactly `[propext, Classical.choice, Quot.sound]`;
  `boxStabFree_of_mem_subformulas` is `[propext]` alone, a strict subset.
- `BoxStabFree` is not a vacuous definition — six computed checks, so `lean4.md`'s
  `def X := True` prohibition is checked rather than assumed: `box p` → `false`, `untl p q` →
  `true`, `stab p` → `false`, `imp p (box q)` → `false`, `snce p (untl q ⊥)` → `true`,
  `imp p (untl ⊥ (stab q))` → `false`. The last three show the recursion descends rather than
  only reading the head constructor.
- Scope Hypothesis: `git diff --stat` shows 118 insertions and 0 deletions, so the binding half
  (insertions only, zero existing declarations touched) holds exactly; the ~60-95 line band is
  overshot by docstring prose only, library code proper being ~85 lines.
- Repo-wide mechanical checks unchanged by this phase: vacuous-definition pattern count 1
  (pre-existing, `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, a real
  theorem about a total domain rather than a placeholder); `^axiom ` count 15, no new axiom.

### Phase 3

- `lake-build-guard.sh build --timeout 1800 -- build …RaySummary.Realize` (detached): guard
  exit 0, `✔ [1930/1930] Built …Realize (4.3s)`, `Build completed successfully`, 0 `error:`,
  0 `warning:`, `.olean` newer than source.
- `#print axioms` on `persistBwd`, `disch_of_SCoh_SLive`, `u_of_dischBwd` and
  `snce_iff_of_SCoh_SLive`: each exactly `[propext, Classical.choice, Quot.sound]`. Phase 2's
  `untl_iff_of_UCoh_ULive` re-pinned at the same profile — no regression.
- `grep -c sorry FormalSystem/.../Realize.lean` = 0.
- `grep -n 'Finite W\|FrameOver\|TaskModel'` over the whole module: no match.
- `grep -n 'UCoh\|deferGraph\|ULive'` restricted to the `section Snce` block: five hits, all
  docstring or comment prose (lines 9, 13, 28, 117, 178 of the block), no code use.
- `snce_iff_of_SCoh_SLive`'s `DischBwd` read side by side with `LocalRun.snce`
  (`Closure.lean`): both are `∃ s, s < z ∧ event s ∧ ∀ r, s < r → r < z → guard r` — the OPEN
  interval `(s, z)`, not `[s, z)`.
- Scratch decidability check (not a permanent witness — Phase 5 owns that), via `lake env lean`
  on a bespoke backward fixture at `sig := { preds := Fin 4 }`, `Q := Fin 3`:
  `decide (SCoh labS stepS 0 1 2)` = `true`, `decide (SLive labS stepS 0 2)` = `true`,
  `bwdDeferGraph labS stepS 0 2 1 0` = `true` (the graph has a real edge, so `SLive` is a
  satisfied constraint rather than an empty one), and the negative control
  `decide (SLive labBadS stepS 0 2)` = `false` with `decide (SCoh labBadS stepS 0 1 2)` still
  `true` — so `SLive` does work `SCoh` does not.

### Phase 2

- Build: **Success**. `lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Metalogic.Decidability.RaySummary.Realize`, detached: guard exit 0,
  `✔ [1930/1930] Built …Realize (2.4s)`, `Build completed successfully`, 0 `error:`,
  0 `warning:`, and the `.olean` newer than the source. Scoped is the covering check here: the
  module is imported by nothing, so no existing module's build can change.
- Axiom profile: `#print axioms` on `untl_iff_of_UCoh_ULive`, `persist`, `disch_of_UCoh_ULive`
  and `u_of_disch` each reports exactly `[propext, Classical.choice, Quot.sound]`.
- Sorry count: 0. Vacuous count: 0. Axiom count: unchanged (no `axiom` declaration added).
- `grep -n 'Finite W\|FrameOver\|TaskModel'` over the module: no match — the phase's own
  no-model/no-frame criterion, checked mechanically.
- Decidability, checked as a scratch `#eval` and NOT left as a permanent witness (Phase 5 owns
  that): at `sig := ⟨Fin 4⟩` on the research probe-03 fixture,
  `decide (UCoh lab3 step3 0 1 2) = true`, `decide (ULive lab3 step3 0 2) = true`, and the
  negative control `decide (ULive labBad step3 0 2) = false`. So both predicates are `Prop`-valued
  with derivable `Decidable` instances, and `ULive` is a real constraint satisfied rather than an
  empty one.
- `scripts/typst-sync-check.sh --counts-only`: `MISMATCH_COUNT=0` after the regeneration.

### Phase 1

- Build: N/A — no module under `FormalSystem/` was touched, so no `lake build` was run and none
  could regress. The probe lives outside the Lake target roots by construction and is compiled by
  the evidence gate via `lake env lean`.
- `bash scripts/check-evidence-probes.sh`: exit 0, `PASS  all 25 wired probe(s) compile`, with
  `seam-gluing-ray-product/b2b-frame-constructor-branching  PASS` and every pre-existing probe
  still PASS.
- Axiom profile: every theorem in the new probe reports exactly
  `[propext, Classical.choice, Quot.sound]` — including the two the phase names,
  `fib_finite_of_finBranch` and `saturation_of_finBranch`. The five `def`s report no axiom
  dependency.
- Sorry count: 0 (`grep -c sorry` on the new probe).
- Sorry inventory: None.
- Vacuous count: 0 — no `:= True`/`:= Unit`/`:= trivial` definition was written.
- Axiom count: unchanged — no `axiom` declaration exists in the new probe.
- Header-claim check: the probe contains the literal phrase "not a dependency of requirement (S)".
- Substrate claims in the header were re-resolved by name against the current tree, not by line:
  `ofSlicedStepRel_reflect`, `ofSlicedStep_compositional`, `ofSlicedStep_serial` and
  `ofSlicedStep_limit` carry no `[Finite W]`; `ofSlicedStep_fib_finite` bounds the fibre by
  `{p.1 + d} ×ˢ Set.univ` and never reads `R`; `TaskFrame.saturation_of_fib_finite` carries no
  carrier hypothesis; `[Finite W]` occurs across nine declarations of `SlicedFrame.lean`.

## Impacts

- The constructed regular ℤ-model now EXISTS in the tree: `frameOf`/`modelOf` with regularity as
  an instance. Everything requirement (S) still owes is the realization theorem over it, not the
  model. Phase 7's entry point is machine-checked to elaborate.
- The construction's concession of infinite fibres is now a THEOREM of the module rather than a
  claim in its header: `frameOf_not_finite_worldState` says the carrier `ℤ × Q` is not finite,
  however small the presentation. `not_finite_width_fmp`'s refuted shape is therefore visibly
  not reintroduced.
- `SlicedFrame.lean` and `TaskFrame.lean` are untouched, and all five `ofReflectiveRegular` field
  discharges are consumed at `W := Q` exactly as they stand — confirming, now by use rather than
  by inspection, the research finding that the descoped frame-constructor prerequisite is a
  completeness burden and not a soundness one.
- `LocalRun` is now obtainable in full from a consistency bundle on a presentation alone —
  `cons_localRun` — with no model, no frame, and no carrier finiteness beyond `[Fintype Q]` on
  the presentation. That is the single largest obligation Phase 7's `presented_modelOf` carries,
  and it is discharged ahead of the model being built at all.
- The `Cons` bundle gives Phases 6-7 named fields where they previously had side conditions:
  `serialFwd`/`serialBwd` are what `ofSlicedStep`'s serial and limit discharges consume,
  `nowOnce` is what turns a `step`-path into an `IsRun`, and `boxStabFree` is what feeds the two
  closure-vacuity lemmas Phase 4 landed.
- The liveness half of `Cons` is now connected to `Probe735.pump_isRun` by a computed negative
  control in the permanent test suite, in both time directions, rather than only in prose. A
  future edit to any of `UCoh`, `ULive`, `deferGraph`, `SCoh`, `SLive` or `bwdDeferGraph` that
  made the conditions vacuous would turn `KTypeFinEvalTest` red.
- `LocalRun`'s `untl` field is now obtainable from decidable per-edge data on a presentation
  alone, with no model and no carrier finiteness. That is the hardest single obligation
  requirement (S) carries, and Phases 5-7 consume it directly (`cons_localRun` cites it rather
  than re-proving anything).
- The `ULive` condition is the machine-checked statement of what `Probe735.pump_isRun` must be
  ruled out by, so the pumping refutation and this construction are now connected in the library
  rather than only in prose.
- The descoping of the carried frame-constructor prerequisite is now checkable: if the probe stops
  compiling, the evidence gate fails and the descoping claim is flagged for revisit.
- A successor record for the constructor inherits a proved fibre-finiteness/`Saturation` core plus
  two refutations that bound its design space — in particular, that a liveness-commitment encoding
  must finitize the deadline it commits to before two-sided finite branching is available.
- The evidence gate's covering count rises from 24 to 25 wired probes.

## Follow-ups

- Phases 7-8 of the plan remain — Phase 7 on `Realize.lean`, Phase 8 on the aggregator and
  documentation — so they stay serialized. Phase 7 (`anchored_runTrace_of_boxStabFree` and
  `presented_modelOf`) is unblocked, and is the plan's largest phase and its one genuinely
  unproved reduction.
- Two shape notes Phase 7 must handle, read off the landed signatures rather than guessed.
  (a) `frameOf_mem_HF_iff` quantifies the offset `k` existentially, so the `(⇒)` direction yields
  SOME `k` and `k = 0` has to be pinned from the seam anchor `hτ : τ.state t = (t, q₀)` rather
  than assumed. (b) `Cons.nowOnce` is quantified over `StepPath step q q' p` with
  `2 ≤ p.length`, so the `(⇒)` direction has to BUILD a `StepPath` from a stretch of the run to
  consume it.
- The Phase 3 backward fixture is now carried into the permanent witness (Phase 5, `labCons` /
  `labConsBad` in `KTypeFinEvalTest.lean`), so `SLive`'s independence from `SCoh` is recorded in
  the tree. This follow-up is discharged.
- `Cons` has no decision procedure and none is claimed: its formula-indexed clauses quantify over
  all of `PlusFormula` and `nowOnce` over `List Q`. A decidable version would quantify over
  `plusSubformulaClosure φ` instead; whether that is wanted is a question for after Phase 8.
- No inhabitant of `Cons` at a concrete `φ` exists yet — the Phase 5 `#guard`s are clause-level,
  at a bare four-letter alphabet rather than at some `clSig φ`. Phase 7 is where a concrete `φ`
  first appears, and the risk the plan's risk table flagged (an awkward-to-inhabit bundle) is
  therefore only partly retired.
- `FormalSystem.lean`'s import count will stay one behind the file count until Phase 8 adds the
  aggregator edge and regenerates it; the pre-commit gate warns about this on every `.lean`-
  touching commit in the interim, and that warning is expected rather than a defect.
- Phase 8 owes the successor-record description for the frame constructor itself, and the ROADMAP
  (S) paragraph rewrite that records the two refutations found here.
- No encoding is yet exhibited that defers an eventuality AND has two-sided finite branching; the
  refutations bound that design space without closing it. That question belongs to the successor.

## References

- `specs/746_hit_level_soundness_realize_presentation_b2b/plans/01_hit-level-soundness-b2b.md`
- `specs/746_hit_level_soundness_realize_presentation_b2b/reports/01_hit-level-soundness-b2b.md`
- `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/01_fib-finite-generalization.lean`
- `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/02_cons-untl-core.lean`
- `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/03_cons-non-vacuity.lean`
- `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean`
- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean`
- `specs/746_hit_level_soundness_realize_presentation_b2b/handoffs/phase-2-handoff-20261008_200241.md`
- `specs/746_hit_level_soundness_realize_presentation_b2b/handoffs/phase-3-handoff-20261008_202100.md`
- `FormalSystem/Metalogic/Decidability/RaySummary/Present.lean` (`live`, `HasChain`, `live_iff`, `bwdLive` — the argument-order precedent)
- `FormalSystem/Metalogic/Decidability/RaySummary/Closure.lean` (`LocalRun.snce` — the orientation source)
- `scripts/check-evidence-probes.sh`
