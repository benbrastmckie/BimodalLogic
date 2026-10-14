# Research Report: Lem canonical frames translation two state

**Task**: 790 - Lem canonical frames translation two state
**Started**: 2026-10-14T21:29:00Z
**Completed**: 2026-10-14T21:45:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**:
- Lean source: `FormalSystem/Semantics/Frames/Standard.lean`, `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/DurationClassification.lean`, `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean`, `FormalSystem/Semantics/IntNormalForm.lean`
- Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (`def:canonical-frames`, `lem:canonical-frames` and its `% PORT:` comment)
- Gates: `scripts/check-module-invariants.sh` (C15, C17, C19, C24, C33), `scripts/check-paper-definitions.sh`, `scripts/typst-sync-check.sh`, `scripts/readme-lint.sh`
- Record: `docs/reference/paper-definitions-of-record.md` (MANIFEST + KNOWN-ANCHORS blocks), `docs/theorem-index.md`
- Compiled probes: four standalone files compiled with `lake env lean` against the live `.olean` cache
- Precedent: `specs/792_pin_lem_state_set_flow_frames/reports/01_pin-lem-state-set-flow-frames.md` (paper-side `% PORT:` policy)
**Artifacts**:
- `specs/790_lem_canonical_frames_translation_two_state/reports/01_lem-canonical-frames-characterizations.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All four claims are proved.** Every deliverable (a)-(d) was discharged in standalone probe
  files compiled with `lake env lean` in this session, with no `sorry` and no change to either
  frame definition. The proofs are reproduced verbatim in the Appendix; the plan can be a
  transcription plan rather than a discovery plan.
- **The documented reducibility barrier is real but repairable.** `RealTranslationFrame.lean`
  records that history-level `+` statements over `translationFrame D` fail `HAdd` synthesis
  (its "symptom 2"), and that type ascription does not repair it. Both halves are confirmed
  measured. The repair is a `def translationStates (τ) : ↑D → ↑D := τ.state` view — neither an
  ascription nor a reducible alias — on the established `WorldHistory.path` precedent
  (`Semantics/IntNormalForm.lean`). Every arithmetic statement of claim (b) routes through it.
- **Placement: extend `Semantics/Correspondence/DurationFrames.lean`; add no new module.**
  `Frames/Standard.lean` cannot host any of it (its import list is `TaskFrame` and nothing else
  by deliberate design, so it has neither `TaskFrame.Deterministic` nor the discreteness
  dichotomy in closure); a new module would pull in `Correspondence.lean`, the generated library
  root, and the C24/C33 gates for no gain.
- **Claim (c) must be stated at the bare relation, not at the frame.** `permissiveFrame D so nm`
  cannot be formed without the `SuccOrder`/`NoMaxOrder` data that discreteness supplies, so
  "is a task frame iff `D` is Discrete" is statable only about the relation
  `fun (w : Bool) (d : ↑D) (u : Bool) => d ≠ 0 ∨ w = u`, tied back to the frame by
  `FrameOver.ofReflectiveRegular_taskRel_eq`.
- **Two gate obligations the implementation must carry**, neither of which is a Lean proof:
  (1) C15 requires a row for `def:canonical-frames` and `lem:canonical-frames` in
  `docs/reference/paper-definitions-of-record.md` — a file in concurrent task 756's declared
  `file_scope`; (2) `typst/generated/status.typ` carries a live `formalsystem-line-count`, so
  adding lines under `FormalSystem/` requires `bash scripts/typst-sync-check.sh --fix`.
- **(a) is cheaper to generalise than to transfer**, and transfer is not actually available:
  the ℝ instance's `F1` is `oneShift.frame` (a `ShiftSet` fibre), a different frame from
  `translationFrame realTemporalOrder`, so a transfer would first need a frame isomorphism.
  Generalising is a one-line citation of `TaskFrame.fib_subsingleton_of_functional`.

## Context & Scope

Researched: how to state and prove, over an arbitrary `(D : TemporalOrder)`, the four claims
`lem:canonical-frames` makes about `def:canonical-frames`' two frames — (a) the translation
frame is a Deterministic task frame; (b) its possible worlds are exactly the translations
`σ_c(z) = z + c`; (c) the two-state frame is a task frame iff `D` is Discrete; (d) when it is, it
is not Deterministic and every `D → {w₀, w₁}` is a possible world.

Constraints honoured: no change to `translationFrame` or `permissiveFrame` (both are consumed by
`validOn_df_iff_isDiscrete`, `validOn_dn_iff_denselyOrdered` and the Independence modules); no
new `sorry`; no new axiom; `lake build FormalSystem` must stay green.

Out of scope and left alone: the paper file itself (see Decisions), `docs/theorem-index.md`
(see Decisions), and the 26-anchor drift wave `check-paper-definitions.sh` already reports.

## Findings

### Codebase Patterns

- **What exists, confirmed by reading.** `translationFrame D` and `permissiveFrame D so nm`
  (`Frames/Standard.lean`), with `translationFrame_taskRel` / `permissiveFrame_taskRel` as their
  `@[simp]` relation bridges and `translationRel_fib_subsingleton` as the raw singleton-fibre
  fact. `translationHist D`, `permissiveHist D so nm f`, the realisation lemmas and the three
  (T1) biconditionals (`Correspondence/DurationFrames.lean`). `noMaxOrder_of_duration` and
  `succOrderOfIsLeastPos` are the glue that turns non-density into the frame's two arguments.
- **`Deterministic` is a `TaskFrame` predicate, not a `FrameOver` one**
  (`Semantics/FrameProperty.lean`), so claim (a) reads
  `(translationFrame D).toTaskFrame.Deterministic`, with the unrestricted duration binder that
  predicate's docstring argues for at length.
- **`translationRel_fib_subsingleton` is not directly reusable for (a).** Its `Fib` argument is
  the raw relation `fun w x u => u = w + x`; the goal's is
  `(translationFrame D).toTaskFrame.TaskRel`, and the two do not unify at the transparency the
  elaborator uses for the `Fib` motive. Measured error:
  `Type mismatch ... but is expected to have type (TaskFrame.Fib (translationFrame D).toTaskFrame.TaskRel w d).Subsingleton`.
  `TaskFrame.fib_subsingleton_of_functional` applied to `translationFrame_taskRel` goes through
  instead, in one line.
- **The history layer's instance-transparency barrier.** `translationFrame` is a plain `def`
  whose body is `FrameOver.ofReflectiveRegular` (also a plain `def`, deliberately non-reducible
  so the `IsRegular` auto-instance keys on it). `WorldState` therefore reduces to `↑D` at default
  transparency (so unification succeeds) but not during instance search. Consequences, each
  measured:
  - `τ.state 0` passed where a `↑D` is expected: **works**.
  - Any `+` with a `τ.state _` operand: **fails** with
    `failed to synthesize instance ... HAdd (translationFrame D).toTaskFrame.WorldState D.carrier ?m`.
  - A type ascription `(τ.state 0 : ↑D) + t`: **also fails**, same error — the `binop%`
    elaborator reads the operand's inferred type before the ascription's. This confirms
    `RealTranslationFrame.lean`'s claim that symptom 2 is not ascription-repairable.
  - A view definition `def translationStates (τ) : ↑D → ↑D := τ.state`: **works**, and every
    `+` statement written through it elaborates and proves. The house precedent for exactly this
    move is `WorldHistory.path` (`Semantics/IntNormalForm.lean`), documented there as "the bare
    path underlying a possible world: the ... reading of `WorldHistory.state`".
- **`WorldHistory.ext_state` and `WorldHistory.timeShift` are the two tools (b) and (d) need.**
  `ext_state` (states agree pointwise ⟹ equal) discharges every `Equiv` round trip;
  `(τ.timeShift Δ).state t = τ.state (t + Δ)` means `σ_c` need not be built with a fresh
  `ofTotal`: `translationSigma D c := (translationHist D).timeShift c` has state function
  `t ↦ t + c` by `rfl`, which keeps the problematic `+` out of the *definition* entirely.
- **(c)'s "if" half is already prose in the tree.** `TaskFrame.limit_of_permissive`'s docstring
  states: "over a dense `D` every state lies in every cone of every other state ... and *Limit*
  fails outright." This task machine-checks that sentence.
- **The discreteness bridge exists.** `isLeast_succ_of_isLeast_pos`
  (`Semantics/DurationClassification.lean`) turns a least positive duration into
  `IsLeast {y | x < y} (x + p)` at every `x`, and `TaskFrame.exists_pos_of_nontrivial` gives the
  reverse instantiation at `x = 0`. Together they prove
  `IsDiscrete ↔ ∃ p, IsLeast {x | 0 < x} p`, which is the form `duration_dense_or_least_pos`
  (the dichotomy) consumes. `FrameProperty.lean`'s `IsDiscrete` docstring explicitly flags this
  equivalence as something that should be "a proof step rather than a definitional assumption" —
  this is that proof step.
- **No name collisions.** All ten proposed identifiers (`translationSigma`,
  `translationStates`, `permRel`, `permissiveStates`, `permissiveHistEquiv`,
  `translationHistEquiv`, `isDiscrete_iff_exists_isLeast_pos`, `translationFrame_deterministic`,
  `permissiveFrame_not_deterministic`, `translationStates_eq`) have zero occurrences under
  `FormalSystem/`, `Tests/` and `BimodalTools/`.

### External Resources

No Mathlib search was required: every lemma the proofs use is either local or elementary
(`abs_pos`, `abs_of_pos`, `add_comm`, `zero_add`, `Set.eq_univ_of_forall`, `Equiv`). The
`lean-lsp` MCP index was therefore not the evidence of record; evidence is compiled probes
(`lake env lean`), which is the stronger tier.

Paper text of record (quoted from `possible_worlds.tex`, `lem:canonical-frames`): "the
translation frame ... is a Deterministic task frame ..., whose possible worlds are the
translations $\sigma_c$ for $c \in D$. The two-state frame ... is a task frame just in case $\D$
is Discrete, in which case it is not Deterministic and every function from $D$ to
$\set{w_0, w_1}$ is one of its possible worlds."

### Gate Obligations (non-Lean work the implementation must carry)

- **C15, paper-anchor integrity (ENFORCED).** `scripts/check-module-invariants.sh` requires every
  `def:|thm:|lem:|cor:|app:|rmk:`-shaped citation under `FormalSystem/`, `Tests/`,
  `BimodalTools/`, `typst/`, `docs/` and `README.md` to have either a MANIFEST row or a
  KNOWN-ANCHORS row in `docs/reference/paper-definitions-of-record.md`. Measured: neither
  `def:canonical-frames` nor `lem:canonical-frames` appears anywhere under `docs/`, `scripts/`,
  `FormalSystem/` or `typst/`. The dispatch mandates docstrings citing both, so **two rows must
  be added**.
- **`typst/generated/status.typ` freshness (CI-gated via `typst-sync-check.sh` Check 2).** The
  generated file carries `#let formalsystem-line-count = 354249` and
  `#let formalsystem-file-count = 681`. Measured now: `bash scripts/typst-sync-check.sh
  --counts-only` reports `MISMATCH_COUNT=0` (in sync). Adding lines under `FormalSystem/` drifts
  the line count, so the phase that lands the Lean edit must also run
  `bash scripts/typst-sync-check.sh --fix` (needs a built library) and stage the regenerated
  `typst/generated/status.typ`.
- **`check-paper-definitions.sh` is already red, pre-existing.** Measured: exit 1, "26 recorded
  definition(s) drifted", including `def:deterministic`, `app:discrete`, `def:frame-properties`.
  It is `continue-on-error: true` in `.github/workflows/ci.yml` and takes the neutral-skip path
  on the runner (the paper is not visible to CI), so it is advisory, not blocking. This task
  should not absorb that wave.
- **Not triggered, checked:** C24 (`FormalSystem.Init` reachability) and C33 (generated library
  root byte-currency) fire only on a *new* module — the recommendation adds none. C17
  (dead-declaration scan) is reporting-only, with no `ENFORCE_C17` flag. C19 (docstring
  coverage) is reported, not gated, and every new declaration gets a docstring regardless.
  `readme-lint.sh` staleness is reported-not-gated and already stale tree-wide.

### Recommendations

Ordered as a single implementation sequence. Every Lean step below is a transcription of an
already-compiled proof (Appendix).

1. **Record the two anchors** in `docs/reference/paper-definitions-of-record.md`'s
   KNOWN-ANCHORS block as `LIVE-UNPINNED` (two lines, `anchor_id|status|note`), noting that the
   docstrings cite them as pointers and quote no text. This is the minimum-diff route and avoids
   writing fresh sha pins into a record with a pending drift wave. **Coordinate with task 756
   first** (see Risks).
2. **Claim (a)** in `Correspondence/DurationFrames.lean`:
   `translationFrame_deterministic : (translationFrame D).toTaskFrame.Deterministic`, by
   `TaskFrame.fib_subsingleton_of_functional` at `f := fun w x => w + x`. Docstring cites
   `lem:canonical-frames` and records that it generalises `f1_deterministic`.
3. **Claim (b)**, same module, in this order: the view `translationStates`; `translationSigma`
   (as `(translationHist D).timeShift c`); the `@[simp]` state lemmas
   `translationSigma_states` (`= t + c`) and `translationHist_states`; `translationSigma_zero`;
   `translationStates_eq` (the pointwise `τ(t) = τ(0) + t`); `translation_eq_sigma`
   (`τ = σ_{τ(0)}`); then the three user-facing forms — `translationHistEquiv`
   (`WorldHistory … ≃ ↑D`), `translation_histSet_eq` (the paper's `H_F = {σ_c | c ∈ D}` as
   `Set.range (translationSigma D) = Set.univ`), and `translation_exists_unique`.
4. **Claim (c)**, same module: `permRel` and its `rfl` bridge `permRel_iff`;
   `permissiveFrame_taskRel_eq` (ties `permRel` to the frame's own relation by
   `FrameOver.ofReflectiveRegular_taskRel_eq` — without it the biconditional is about a
   lookalike); `permRel_limit_of_isLeast`; `permRel_not_limit_of_dense`;
   `isDiscrete_iff_exists_isLeast_pos`; then the two headline statements
   `permRel_limit_iff_isDiscrete` and `permRel_constraints_iff_isDiscrete` (the four `def:frame`
   constraints conjoined, which is the honest reading of "is a task frame iff"), plus
   `permRel_reflection` recording that reflection holds unconditionally.
5. **Claim (d)**, same module: `permissiveFrame_not_deterministic` and the view
   `permissiveStates` + `permissiveHistEquiv : (↑D → Bool) ≃ WorldHistory …`.
6. **Extend the module docstring's "Main results" list** with the new names, and add a
   `lem:canonical-frames` paragraph to the module header explaining that `DurationFrames.lean`
   now carries the canonical-frame characterizations as well as the correspondence witnesses.
7. **One-sentence amendment to `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean`'s
   module docstring** (recommended, small): its symptom-2 paragraph says the world-set
   characterization "is exactly the statement that fails to elaborate on the `translationFrame`
   route". That stays true of the ascription-shaped statement but is now misleading, since
   `translation_eq_sigma` proves the analogue through a view definition. Recommend adding one
   sentence naming the view and keeping the `ShiftSet` route's justification (which does not
   depend on it — `total_eq_orbit` is still handed over for free).
8. **Verification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
   detached, then `bash scripts/typst-sync-check.sh --fix` and stage `status.typ`, then
   `bash scripts/check-module-invariants.sh` for C15.

## Decisions

- **Placement: `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, one module, no new
  file.** `Frames/Standard.lean` is excluded by its own documented invariant ("This module's
  import list is `TaskFrame` and nothing else") — `Deterministic` lives in `FrameProperty.lean`
  and the dichotomy in `DurationClassification.lean`, neither in that closure. A
  `Frames/Canonical.lean` would have to import `Correspondence/DurationFrames` for
  `translationHist`, inverting the directory layering that `Standard.lean`'s docstring was
  written to prevent. The file grows from 435 to roughly 620 lines, well under the 1500-line
  `linter.style.longFile` threshold.
- **(a) is generalised, not transferred.** Recorded answer to the dispatch's open question: the
  ℝ instance proves determinism of `oneShift.frame`, which is a different frame object from
  `translationFrame realTemporalOrder` — `RealTranslationFrame.lean` says so explicitly and
  records why it took the `ShiftSet` route. Transfer would need a frame isomorphism that does not
  exist in the tree; generalising is one line.
- **(c) is stated at the bare relation, with an explicit tie-back.** `permissiveFrame` cannot be
  applied without the `SuccOrder`/`NoMaxOrder` data, so a frame-level "iff" is not well formed.
  `permissiveFrame_taskRel_eq` is what makes the relation-level statement a statement about the
  frame.
- **No `docs/theorem-index.md` rows.** That index's Axioms column is generated from the C2/C14
  axiom baselines (`pinned:C2` / `pinned:C14`), so adding rows would require adding axiom
  baselines for frame-characterization lemmas — scope the dispatch does not ask for, and a trap
  worth naming. `DurationFrames.lean` has no rows there today.
- **The paper's `% PORT:` comment is not cleared by this task.** `possible_worlds.tex` is
  read-only input from a repository this one cannot see — the charter
  `docs/reference/paper-definitions-of-record.md` states it, and sibling task 792 reached and
  recorded the same conclusion in this same cycle ("Updating either is a paper-side edit, outside
  this task's scope"). The marker is the gap's *identifier*; deleting it is a paper-side edit for
  the author. The report records what a later `\leanproof{}` citation would name.
- **The KNOWN-ANCHORS route is preferred over a MANIFEST pin** for the two new anchors, because
  the docstrings cite them as pointers rather than quoting their text, and because 26 pinned
  anchors are currently drifted — adding a 27th pin mid-wave mixes two decisions.

## Risks & Mitigations

- **Territory collision on `docs/reference/paper-definitions-of-record.md` (highest risk).** That
  file is in concurrent task 756's declared `file_scope` (research phase this cycle; its
  implement phase may edit it). Mitigations, in preference order: (1) keep this task's diff to
  the two KNOWN-ANCHORS lines, re-reading the file immediately before editing and staging only
  those hunks; (2) if 756 has already modified it, treat the modification as a sibling's
  in-flight edit and report rather than reconciling; (3) if sequencing is possible, land 790's
  record edit after 756's implement phase. Recorded in `issues.jsonl` as
  `cross-task ownership/territory`, severity `costly`.
- **C15 fails the moment a citing docstring lands without its row.** Mitigation: step 1 of the
  sequence is the record edit, before the Lean edit, so the tree is never in the failing state
  across a commit boundary.
- **`status.typ` drift is silent until CI.** The line count is build-free to check: a cheap
  `bash scripts/typst-sync-check.sh --counts-only` after the Lean edit catches it immediately.
- **A sibling's concurrent `lake` invocation can lose this task's build.** Five siblings are
  dispatched this cycle on the same tree. Mitigation: route every build through
  `lake-build-guard.sh`, detached, and treat a failure in a file outside this task's scope as
  possibly foreign.
- **`permissiveHistEquiv`'s `right_inv` is proved by `ext_state` + `rfl`.** If a future change
  makes `permissiveHist` non-`rfl` in its states, that proof breaks loudly (not silently). No
  mitigation needed; noted so the planner does not treat the `rfl` as fragile cleverness.

## Tactic Survey Results

Measured in this session with `lake env lean` on four standalone probe files; "success" means
the whole declaration compiled with no error and no `sorry`.

| Goal | Tactic / route | Result | Premises/Config |
|------|----------------|--------|-----------------|
| (a) `(translationFrame D).toTaskFrame.Deterministic` | `exact translationRel_fib_subsingleton w d` after `intro w d` | fail | type mismatch: raw relation vs `TaskRel` in the `Fib` motive |
| (a) same | `TaskFrame.fib_subsingleton_of_functional` + `translationFrame_taskRel` | success | `f := fun (w x : ↑D) => w + x` |
| (b) `τ.state t = τ.state 0 + t`, ascription form | term proof via `translationFrame_taskRel` + `rw [sub_zero]` | fail | `HAdd …WorldState D.carrier ?m` synthesis failure |
| (b) same, through the `↑D → ↑D` view | identical term proof | success | `def translationStates (τ) : ↑D → ↑D := τ.state` |
| (b) `translationSigma D c` as a world history | `(translationHist D).timeShift c` | success | no `ofTotal`, no `+` in the definition |
| (b) `(σ_c).state t = t + c` | `rfl` | success | `timeShift_state` + `ofTotal_state` are both `rfl` |
| (b) `τ = translationSigma D (translationStates τ 0)` | `WorldHistory.ext_state` + `translationStates_eq` + `add_comm` | success | — |
| (b) `WorldHistory … ≃ ↑D` | `Equiv` literal; `left_inv` from the above, `right_inv` by `zero_add` | success | `show` needed on `right_inv` to beta-reduce before `rw` |
| (b) `Set.range (translationSigma D) = Set.univ` | `Set.eq_univ_of_forall` | success | — |
| (b) `∃! c, τ = translationSigma D c` | `congrArg` + `simpa` | success | — |
| (c) Limit from a least positive `p` | `obtain … := h p hp.1`; `abs_pos`; `not_le` | success | `IsLeast {x | 0 < x} p` |
| (c) ¬Limit over a dense carrier | `hd.dense 0 x hx`; `abs_of_pos`; `Or.inl` | success | witness `w = true`, `u = false` |
| (c) `IsDiscrete ↔ ∃ p, IsLeast {x | 0 < x} p` | `exists_pos_of_nontrivial` / `isLeast_succ_of_isLeast_pos` | success | one line each way |
| (c) the four constraints ↔ Discrete | `duration_dense_or_least_pos` + the four `*_of_permissive` helpers | success | `permRel_iff` is `Iff.rfl` |
| (d) `¬ (permissiveFrame …).toTaskFrame.Deterministic` | `exists_pos_of_nontrivial`; two `Fib` memberships; `simp` | success | `Fib` membership is the bridge applied, by `rfl` |
| (d) `(↑D → Bool) ≃ WorldHistory …` | `left_inv := rfl`, `right_inv := ext_state … rfl` | success | view `permissiveStates` for `invFun` |

`lean_multi_attempt` and the rate-limited search tools were not used: the evidence tier available
here (full-declaration compilation against the live `.olean` cache) strictly dominates a tactic
probe at a cursor position, and no Mathlib name search was needed.

## Context Extension Recommendations

- **Topic**: the instance-transparency barrier on frames built by `FrameOver.ofReflectiveRegular`.
- **Gap**: `context/project/lean4/` has no note on it. The knowledge currently lives in one
  module docstring (`RealTranslationFrame.lean`) that states the barrier is unrepairable by the
  two repairs its author tried, which reads as "unrepairable" and discouraged exactly the route
  this task took. The general rule — *a plain-`def` frame's `WorldState` unifies but does not
  synthesize instances; retype it with a view `def`, never an ascription* — is reusable at every
  frame in the census.
- **Recommendation**: add `context/project/lean4/patterns/frame-carrier-transparency.md` with
  the three measured behaviours (argument position works, `+` fails, ascription fails), the view
  repair, and the `WorldHistory.path` precedent.

## Appendix

### Compiled proof scripts

Verified by `lake env lean` in this session, in the `FormalSystem.Semantics` namespace with
`variable {D : TemporalOrder}`. Docstrings are omitted here and are to be written at
transcription time.

```lean
-- (a)
theorem translationFrame_deterministic (D : TemporalOrder) :
    (translationFrame D).toTaskFrame.Deterministic :=
  TaskFrame.fib_subsingleton_of_functional (f := fun (w : ↑D) (x : ↑D) => w + x)
    (fun w x u => translationFrame_taskRel w x u)

-- (b)
def translationSigma (D : TemporalOrder) (c : ↑D) :
    WorldHistory (translationFrame D).toTaskFrame :=
  (translationHist D).timeShift c

def translationStates (τ : WorldHistory (translationFrame D).toTaskFrame) : ↑D → ↑D := τ.state

@[simp] theorem translationSigma_states (D : TemporalOrder) (c t : ↑D) :
    translationStates (translationSigma D c) t = t + c := rfl

@[simp] theorem translationHist_states (D : TemporalOrder) (t : ↑D) :
    translationStates (translationHist D) t = t := rfl

@[simp] theorem translationSigma_zero (D : TemporalOrder) :
    translationSigma D 0 = translationHist D := by
  refine WorldHistory.ext_state fun t => ?_
  show translationStates (translationSigma D 0) t = translationStates (translationHist D) t
  rw [translationSigma_states, translationHist_states, add_zero]

theorem translationStates_eq (τ : WorldHistory (translationFrame D).toTaskFrame) (t : ↑D) :
    translationStates τ t = translationStates τ 0 + t := by
  have h := (translationFrame_taskRel (D := D) (τ.state 0) (t - 0) (τ.state t)).mp
    (τ.respects_task 0 t)
  rw [sub_zero] at h
  exact h

theorem translation_eq_sigma (τ : WorldHistory (translationFrame D).toTaskFrame) :
    τ = translationSigma D (translationStates τ 0) := by
  refine WorldHistory.ext_state fun t => ?_
  show translationStates τ t = translationStates (translationSigma D _) t
  rw [translationSigma_states, translationStates_eq τ t, add_comm]

def translationHistEquiv (D : TemporalOrder) :
    WorldHistory (translationFrame D).toTaskFrame ≃ ↑D where
  toFun τ := translationStates τ 0
  invFun c := translationSigma D c
  left_inv τ := (translation_eq_sigma τ).symm
  right_inv c := by
    show translationStates (translationSigma D c) 0 = c
    rw [translationSigma_states, zero_add]

theorem translation_histSet_eq (D : TemporalOrder) :
    Set.range (translationSigma D)
      = (Set.univ : Set (WorldHistory (translationFrame D).toTaskFrame)) :=
  Set.eq_univ_of_forall fun τ => ⟨translationStates τ 0, (translation_eq_sigma τ).symm⟩

theorem translation_exists_unique (τ : WorldHistory (translationFrame D).toTaskFrame) :
    ∃! c : ↑D, τ = translationSigma D c := by
  refine ⟨translationStates τ 0, translation_eq_sigma τ, fun c hc => ?_⟩
  have := congrArg (fun σ => translationStates σ 0) hc
  simpa using this.symm

-- (c)
def permRel (D : TemporalOrder) : Bool → ↑D → Bool → Prop := fun w d u => d ≠ 0 ∨ w = u

theorem permRel_iff (D : TemporalOrder) (w : Bool) (d : ↑D) (u : Bool) :
    permRel D w d u ↔ (d ≠ 0 ∨ w = u) := Iff.rfl

theorem permissiveFrame_taskRel_eq (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    (permissiveFrame D so nm).TaskRel = permRel D :=
  FrameOver.ofReflectiveRegular_taskRel_eq

theorem permRel_reflection (D : TemporalOrder) :
    ∀ w (d : ↑D) u, permRel D w d u ↔ permRel D u (-d) w :=
  TaskFrame.reflection_of_permissive (permRel_iff D)

theorem permRel_limit_of_isLeast {p : ↑D} (hp : IsLeast {x : ↑D | 0 < x} p) :
    TaskFrame.Limit (permRel D) := by
  intro w u h
  obtain ⟨y, hy, hR⟩ := h p hp.1
  rcases hR with hne | heq
  · exact absurd (hp.2 (abs_pos.mpr hne)) (not_le.mpr hy)
  · exact heq.symm

theorem permRel_not_limit_of_dense (D : TemporalOrder) (hd : DenselyOrdered ↑D) :
    ¬ TaskFrame.Limit (permRel D) := by
  intro h
  have : (false : Bool) = true := by
    refine h true false ?_
    intro x hx
    obtain ⟨y, hy0, hyx⟩ := hd.dense 0 x hx
    exact ⟨y, by rwa [abs_of_pos hy0], Or.inl (ne_of_gt hy0)⟩
  simp at this

theorem isDiscrete_iff_exists_isLeast_pos (D : TemporalOrder) :
    (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y')
      ↔ ∃ p : ↑D, IsLeast {x : ↑D | 0 < x} p := by
  constructor
  · intro h
    obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
    obtain ⟨y', hy'⟩ := h 0 ⟨p, hp⟩
    exact ⟨y', hy'⟩
  · rintro ⟨p, hp⟩ x -
    exact ⟨x + p, isLeast_succ_of_isLeast_pos hp x⟩

theorem permRel_limit_iff_isDiscrete (D : TemporalOrder) :
    TaskFrame.Limit (permRel D)
      ↔ (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y') := by
  rw [isDiscrete_iff_exists_isLeast_pos]
  constructor
  · intro h
    rcases duration_dense_or_least_pos (D := ↑D) with hd | hp
    · exact absurd h (permRel_not_limit_of_dense D hd)
    · exact hp
  · rintro ⟨p, hp⟩
    exact permRel_limit_of_isLeast hp

theorem permRel_constraints_iff_isDiscrete (D : TemporalOrder) :
    (TaskFrame.Compositional (permRel D) ∧ TaskFrame.Serial (permRel D)
        ∧ TaskFrame.Limit (permRel D) ∧ TaskFrame.Saturation (permRel D))
      ↔ (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y') := by
  rw [isDiscrete_iff_exists_isLeast_pos]
  constructor
  · rintro ⟨-, -, hlim, -⟩
    rcases duration_dense_or_least_pos (D := ↑D) with hd | hp
    · exact absurd hlim (permRel_not_limit_of_dense D hd)
    · exact hp
  · rintro ⟨p, hp⟩
    exact ⟨TaskFrame.comp_of_permissive (permRel_iff D),
      TaskFrame.serial_of_permissive (permRel_iff D),
      permRel_limit_of_isLeast hp,
      TaskFrame.saturation_of_permissive (permRel_iff D)⟩

-- (d)
theorem permissiveFrame_not_deterministic (D : TemporalOrder) (so : SuccOrder ↑D)
    (nm : NoMaxOrder ↑D) : ¬ (permissiveFrame D so nm).toTaskFrame.Deterministic := by
  intro h
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
  have h1 : (true : Bool) ∈ TaskFrame.Fib (permissiveFrame D so nm).toTaskFrame.TaskRel true p :=
    (permissiveFrame_taskRel so nm _ _ _).mpr (Or.inr rfl)
  have h2 : (false : Bool) ∈ TaskFrame.Fib (permissiveFrame D so nm).toTaskFrame.TaskRel true p :=
    (permissiveFrame_taskRel so nm _ _ _).mpr (Or.inl (ne_of_gt hp))
  exact absurd (h true p h1 h2) (by simp)

def permissiveStates (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (τ : WorldHistory (permissiveFrame D so nm).toTaskFrame) : ↑D → Bool := τ.state

def permissiveHistEquiv (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    (↑D → Bool) ≃ WorldHistory (permissiveFrame D so nm).toTaskFrame where
  toFun f := permissiveHist D so nm f
  invFun τ := permissiveStates D so nm τ
  left_inv f := rfl
  right_inv τ := by
    refine WorldHistory.ext_state fun t => ?_
    rfl
```

### Commands run

- `lake env lean <probe>.lean` on four probe files (the scripts above and the two failing
  variants) — all current scripts compile with no output.
- `bash scripts/check-paper-definitions.sh` — exit 1, 26 drifted anchors (pre-existing).
- `bash scripts/typst-sync-check.sh --counts-only` — `MISMATCH_COUNT=0`, exit 0.
- `bash scripts/readme-lint.sh` — `RESULT: PASS`, with staleness reported for 10 READMEs
  including `Semantics/Correspondence/README.md` (reported, not gated).
- `grep` sweeps for name collisions (zero hits on all ten proposed identifiers) and for
  `canonical-frames` under `docs/`, `scripts/`, `FormalSystem/`, `typst/` (zero hits).

### Paper references

- `possible_worlds.tex`: `def:canonical-frames` and `lem:canonical-frames` with its `% PORT:`
  comment immediately below the `Lthm`; `def:deterministic` immediately above; the lemma is
  invoked by the proofs of `app:discrete`, `app:dense`, `cor:no-characterization` and the
  two-state countermodels.
- The paper's own proof of the lemma matches the Lean route step for step: singleton fibres settle
  Seriality and determinism together; `τ(x) ⇒_{y-x} τ(y)` for all `x, y` holds iff
  `τ = σ_{τ(0)}`; `(w)_ε = ⟨w, 0⟩ = {w}` gives Limit under a least positive `ε`, and otherwise
  `(w)_d ⊇ ⟨w, y⟩ = {w₀, w₁}` kills it; `w₀ ⇒_ε w₀` with `w₀ ⇒_ε w₁` refutes determinism.
