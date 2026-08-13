# Implementation Summary: Phases 14.1 and 15 (plan v4)

- **Task**: 420 - align_task_frame_with_positive_cone_axioms
- **Plan**: `plans/04_axiom-fields-split-batch.md`
- **Phases in this dispatch**: 14.1 [COMPLETED], 15 [COMPLETED]
- **Not in scope, still [NOT STARTED]**: 14.2 (`[Nontrivial D]` structure binder,
  `Nonempty WorldState`, the `FilteredWorld` nonemptiness proof)

## What landed

`TaskFrame` now carries all four of `def:frame`'s axioms as structure fields, and the Step Lemma
chain consumes them. The Cross-Task Acceptance Criterion is discharged: `step` applies
`F.spherical` at the sole *Spherical* application site the paper names, so the fields cannot be
inert.

### The four fields (`FormalSystem/Semantics/TaskFrame.lean`)

| Paper axiom | Field | Stated as |
|---|---|---|
| *Compositionality* (biconditional) | `comp` | `TaskFrame.Compositional TaskRel` |
| *Seriality* | `serial` | `TaskFrame.Serial TaskRel` |
| *Limit* | `limit` | the literal transcribed shape `∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ TaskRel w y u) → u = w` |
| *Spherical* | `spherical` | `TaskFrame.Spherical TaskRel` |

`forward_comp` ceased to be a field and is re-derived as the `←` projection of `comp`, with its
former statement verbatim — all 46 references across 12 files apply it unchanged.
`TaskFrame.interpolates` is the `→` projection, definitionally `TaskFrame.Interpolates TaskRel`.

Five `example`s in a `DefinitionalContent` section at the foot of `TaskFrame.lean` mechanize the
definitional-content check: each elaborates by `rfl`, and would fail if any field's statement were
a restatement rather than a citation.

### The acceptance criterion, demonstrably consumed

The consuming declaration is **`FormalSystem.Semantics.PartialHistory.step`**
(`FormalSystem/Semantics/Extension/Step.lean`), whose body reads

```lean
obtain ⟨u, hu⟩ := F.spherical (Constraints τ z) hdir fun c hc => …
```

`step`'s four hypothesis binders (`hSph`, `hSer`, `hInt`, `hLim`) are gone; it now takes
`(F : TaskFrame D) (τ : PartialHistory F) (z : D)` only.

## Declarations converted to field projections, and declarations left bare

**Converted** (axiom hypotheses dropped; the frame's fields read off `F`):

| Declaration | File |
|---|---|
| `nonempty_fib_of_serial`, `nonempty_seg_of_interpolates`, `nonempty_of_mem_Constraints`, `constraint` | `Extension/Constraint.lean` |
| `admissible` | `Extension/Admissible.lean` |
| `step` | `Extension/Step.lean` |
| `isTotal_of_isMax`, `extension`, `occurrence`, `hF_nonempty` | `Extension/Extension.lean` |
| `not_validOn_bot`, `hF_nonempty_of_frameAxioms` | `Semantics/Validity.lean` |

`occurrence` and `hF_nonempty` are thereby in **frame-intrinsic** form — quantifying over a frame
alone, which is how `cor:occurrence` literally reads. The one argument still taken explicitly is
the world state `w`, because `Nonempty WorldState` is Phase 14.2.

**Left bare, deliberately** — these are stated over a bare relation `R : W → D → W → Prop` and are
more useful that way, so the field is passed at the call site instead:

- `TaskFrame.nullity_of_serial_limit` (`Semantics/FrameAxioms.lean`) — now applied as
  `nullity_of_serial_limit F.serial F.limit u` inside `admissible`.
- The whole Phase 10 class-helper family (`serial_of_total`, `interpolates_of_permissive`,
  `limit_of_shift`, `spherical_of_eq`, …) and the `Serial` / `Interpolates` / `Spherical` /
  `Compositional` predicates themselves. They are what the fields cite; collapsing them into the
  structure would defeat the citation discipline.

## Per-site binder propagation (sub-step 14.1.1, green, five separate commits)

| Frame | Binders acquired | Propagation reached |
|---|---|---|
| `staticFrame` | `[Nontrivial D]` | its four axiom lemmas only; all consumers at `Int` |
| `natFrame` | `[SuccOrder D] [NoMaxOrder D]` | `WorldHistory.universalNatFrame`; `Tests/BimodalTest/Property/Generators.lean` needed `import Mathlib.Data.Int.SuccPred` |
| `genericNatFrame` | `[SuccOrder D] [NoMaxOrder D]` | nothing — zero consumers |
| `multiFamTaskFrameGen` | `[Nontrivial D]` | 25 declarations in `FlowFrame.lean` (including all of `bundleFlow*`) plus `Bundle/LimitMCS.lean` |
| `regionFrame` | `[Nontrivial D]` | section variables in `RegionFrame.lean`, `TruthLemma.lean`, `Valuation.lean`, `RegionLabel.lean`, `IntTruth.lean`, `DenseTruth.lean` |

Each was green on its own and committed before the atomic batch opened, exactly as the plan's
"pre-repair before the batch" pattern requires.

## The 14 sites

All 14 live `where`-sites discharge every field. `FiniteFilteredTaskFrame` inherits through
`toTaskFrame := RefinedFilteredTaskFrame D phi` and needed no edit; `bundleFlowFrame` is a
definitional specialization of `multiFamTaskFrameGen` and is not a site.

Nine sites discharge by direct citation of a Phase 10 class helper (`*_of_total`,
`*_of_permissive`, `*_of_eq`, `limit_of_subsingleton`, `spherical_of_subsingleton`) applied to
`fun _ _ _ => Iff.rfl`. The four deterministic-shift sites (`multiFamTaskFrameGen`,
`zTaskFrameV2`, `multiFamTaskFrame`, `regionFrame`) transcribe their already-landed lemma's proof
term over the raw relation — see "Plan Deviations" for why citation was not available there.

## Plan Deviations

- **`comp` is stated as a named Prop, `TaskFrame.Compositional TaskRel`** (altered). The plan's
  field-target table writes the field type unfolded. `Compositional` is declared beside `Serial`,
  `Interpolates`, and `Spherical` above the structure and delta-reduces to exactly that shape.
  Naming it is what keeps the field a *citation* rather than an inline restatement, and it makes
  every site discharge unify first-order instead of against an applied metavariable
  (`?R w (x + y) v` is not a Miller pattern). `comp_of` assembles it from the two halves;
  `forward_of_comp` and `interpolates_of_comp` project them back out.
- **The four deterministic-shift sites transcribe rather than cite** (altered). The plan's
  pre-batch gate asks that every site have "a citable lemma from Phases 10-13". All 56 frame-level
  lemmas were verified present — but they are stated over `(X).TaskRel` and therefore cannot be
  named inside `X`'s own `where` block, which precedes them. The bare-relation class helpers *are*
  citable and serve the other nine sites; for the four shift sites the landed lemma's proof term
  was transcribed over the raw relation. **No proof was discovered**: each transcription is the
  landed proof with the frame reference replaced by the relation it unfolds to, and the landed
  lemmas remain in the tree as the independent check.
- **`Semantics/Validity.lean` was edited in Phase 15** (altered). The plan's Phase 15 file list
  names only the four `Extension/` files. `not_validOn_bot` and `hF_nonempty_of_frameAxioms`
  carried the same four hypothesis binders and the same provisional prose, and are reached as call
  sites of `occurrence` / `hF_nonempty`.
- **`Tests/BimodalTest/Property/Generators.lean` gained `import Mathlib.Data.Int.SuccPred`**
  (altered). Forced by `natFrame`'s new discrete binders; `TaskFrameTest.lean` already carried the
  import.
- **Sub-step 14.1.1's contingency was not exercised** (skipped). No frame's binder propagation
  turned out to need folding into the batch; all five were green standalone.
- `nullity_identity` is untouched, per caveat (b): `ls specs/decisions/` still returns only
  `total-history-validity-decisions.md` and `untl-snce-argument-order.md`, and neither mentions it.

## Verification

| Check | Result |
|---|---|
| `lake build` | **green, 2331 jobs**, exit 0 |
| `lake build BimodalTest` | 7 `#guard_msgs` failures, **all 7 the pre-existing enumerated exclusions** recorded in commit `86eb8963c` (TableauConformance 4, RegionGateProbe 2, BoxSpreadProbe 1); zero frame-related failures |
| `sorry` count, `FormalSystem/` + `Tests/` outside `Boneyard/` | 329 — **byte-identical to the pre-work baseline** |
| `sorry` count including `Boneyard/` | 985 — byte-identical |
| `axiom` declarations | 6 — byte-identical |
| `#print axioms` on all 14 frames, `bundleFlowFrame`, `forward_comp`, `interpolates` | only `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx` |
| `#print axioms` on `step`, `extension`, `occurrence`, `hF_nonempty`, `constraint`, `admissible`, `not_validOn_bot` | only the standard three |
| Definitional-content examples (`Serial`, `Spherical`, `Compositional`, `Interpolates`, *Limit*) | all elaborate by `rfl` |
| `bash scripts/check-paper-definitions.sh` | exit 0, no anchor drift |
| `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/` | 0 |
| `grep -rn "Limit Nullity" FormalSystem/` | 0 |
| `bash .claude/scripts/check-task-references.sh` | PASS, 0 unexempted occurrences |

## Still open (Phase 14.2, not started)

`[Nontrivial D]` as a `TaskFrame` structure binder (measured at 575+ mentions across 49 files) and
`Nonempty WorldState`, including the `Nonempty (FilteredWorld phi)` proof that does not exist in
the tree. Neither gates anything that landed here.
