# Implementation Plan: Task #894

- **Task**: 894 - The forward-cone unravelling as a regular ZTime frame: inr-layer oriented forest and the two-layer Saturation split
- **Status**: [IMPLEMENTING]
- **Effort**: 10.5 hours (7 landed across Phases 1-4; ~3.5 remaining across Phases 5-6)
- **Dependencies**: None
- **Research Inputs**: specs/894_cone_unravelling_frame_layer_split_saturation/reports/01_cone-unravelling-frame-layer-split.md
- **Artifacts**: plans/01_cone-unravelling-frame-layer-split.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land `FormalSystem/Semantics/ConeUnravelling.lean`: the Auxiliary-Atoms carrier
`W ⊕ (W × List W)` with the one-step relation `coneR`, presented as a regular
`FrameOver intOrder`, together with the three lemmas the task names — the inr layer is an
`IsOrientedForest`, `TaskFrame.Saturation (ofStepRel (coneR E))` splits across the two layers,
and the projection `coneF` is surjective and `TwoWayBounded` so
`plus_invariance_of_isZTime` applies. The module is modelled declaration-for-declaration on
`FormalSystem/Semantics/UniversalCover.lean`, which is the proven template for every
frame-assembly and `TwoWayBounded` step in this tree. Done means: the module compiles sorry-free
and axiom-clean, the seven pinned Challenge statements are proved at the recorded signatures
(`exists_coneUnravelling` at the amended, instance-projected one), the
*Saturation* obligation recorded in `FormalSystem/Metalogic/NamingRules.lean`'s module docstring
is discharged and that docstring no longer asserts it open, and every repository gate the new
Lean lines disturb is regenerated and green.

### Research Integration

The research report is machine-checked rather than argued: a compiled probe
(`specs/evidence/cone-unravelling-frame-layer-split/cone-core-probe.lean`, 295 lines, 23
declarations, zero errors and zero warnings at the pinned toolchain) already contains the whole
structural core — `coneRin`/`coneR`/`coneF`/`parIn`, the three `IsOrientedForest` fields and
their assembly, double seriality on the literal sum carrier, the projection homomorphism, five
`iter`-level transport identities, the four `Fib`-level preimage bridges, and both `step`-direction
lifts. Phases 1 and 2 below are therefore a **promotion** of already-green code with docstrings
added, not a re-derivation. The report's four findings this plan treats as binding:

1. **The entry edge stays promiscuous** (`inl u → inr (v, h)` for *every* `h` whenever `E u v`).
   It is what makes the plain sum carrier doubly serial and what collapses the inl-anchored
   fibre computation to a single base fibre. The narrower `h = [u]` rule breaks
   `TaskFrame.Serial`. This is recorded in the module docstring as a decision, not left for a
   later reader to "tidy".
2. **The carrier is the literal sum type**, not a coherence subtype — `IsOrientedForest` holds
   on the full `W × List W`, incoherent records included, because a record tracing no real
   `E`-path simply has no incoming edge.
3. **`saturation_coneR` takes no seriality hypothesis.** Every nonemptiness obligation in the
   split is discharged by the projection homomorphism from the member's own nonemptiness.
   Adding a seriality hypothesis would silently weaken the statement.
4. **The split is on `∃ s₀ ∈ S, s₀ ⊆ Set.range Sum.inr`**, with Case B going through
   cofinality (directedness replaces the inr-contained member under any other member) rather
   than per-member reshaping.

The report's single unprobed step — the member-shape classification feeding the split — is
hoisted into its own phase (Phase 3) and its own named lemma, exactly as the report's own risk
mitigation asks, so a missing cell fails at a named declaration rather than mid-proof.

### Prior Plan Reference

This plan is the round-01 plan, revised in place rather than superseded by a round-02 file: no
new research report has landed since it was written, and the revision is driven by a user
decision on one recorded Challenge signature rather than by new findings.

What the revision changed, and nothing else:

- `exists_coneUnravelling`'s pinned signature, from
  `exists_coneUnravelling_of_constraints (F) (hcomp) (hser) (hlim) (M)` to instance-projected
  `exists_coneUnravelling (F) [F.IsRegular] (M)`, with the `_of_constraints` layer dropped
  throughout. The trail is under `## Lean Challenge Statements`, *Amendment record*.
- Phase 5, from `[BLOCKED]` to `[IN PROGRESS]`: the blocker narrative is replaced by a resolved
  form, its four machine-checked findings are preserved under `## Decisions`, and its task list
  is re-pointed at the instance-projected API (`FrameOver.taskRel_eq_iter`,
  `TwoWayBounded.plus_invariance_of_isZTime`) with the base-*Saturation* bridge hoisted into a
  named lemma of its own.
- Phase 6's `NamingRules.lean` and challenge-snapshot criteria, to name the amended declarations
  and the expected missing-manifest verdict.

Phases 1-4 are `[COMPLETED]` and their content is carried through untouched. The research report
is unchanged and remains the sole research input.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap phases are therefore scheduled.

## Goals & Non-Goals

**Goals**:
- `coneRin_isOrientedForest` -- the inr layer is an oriented forest, over the full `W × List W`.
- `coneRin_bwd_unique` -- every inr node has a unique inr-predecessor along iterated steps.
- `coneR_serial_fwd`, `coneR_serial_bwd` -- double seriality of `coneR` on the literal sum carrier.
- `saturation_coneR` -- the two-layer *Saturation* split, with no seriality hypothesis.
- `coneF_surjective` -- the projection is surjective, axiom-free.
- `exists_coneUnravelling` -- the headline, stated in the instance-projected form: a regular
  frame over `intOrder` (`[F.IsRegular]`) has a regular cone-unravelling frame with surjective,
  two-way bounded projection, along which L⁺ truth transfers. The cone's own *Saturation* is
  inherited from the base's `IsRegular` instance, not manufactured from *Compositionality*,
  *Seriality* and *Limit* alone -- see Phase 5's blocker resolution.

**Non-Goals**:
- The formula-level Auxiliary-Atoms rule. This task is the frame-side prerequisite only;
  `NamingRules.lean`'s `clock_irr_sound` and `irr_sound` are untouched.
- Any completeness or decidability claim built on top of the unravelling.
- Any modification of `UniversalCover.lean`. The two constructions answer different questions
  (verbatim-copy-plus-tree vs. forest-everywhere) and the existing module's headline has its own
  consumers.
- Unique path lifting and any `Prefunctor.IsCovering` machinery. `TwoWayBounded` has two fields
  and `TwoWayBounded.plus_invariance_of_isZTime` consumes those two plus surjectivity. The
  *instance-projected* form is the one this module calls — both the cone frame and the base carry
  `IsRegular` instances at every call site here — so the `_of_constraints` form, which
  `UniversalCover.lean` needs because its base is not assumed regular, is not used.
- A coherence subtype of the carrier, a `Sigma` type, or any `HEq` discipline.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A member shape is missed in the *Saturation* classification, leaving a gap mid-proof | H | M | Phase 3 states the classification as its own named lemma over the exhaustive 12-cell grid (`IsFiber`/`IsSegment` × anchor side × duration sign) before Phase 4 touches the main proof. A missing cell then fails at a named declaration. |
| The pre-commit hook refuses the first Lean-touching commit because `typst/generated/status.typ` drifted | M | H | Every Lean-touching phase (1-5) runs `bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in its own commit. Surface (b) cannot be deferred — the hook is blocking. |
| A later reader "fixes" the promiscuous entry edge and breaks `TaskFrame.Serial` | M | M | Phase 1 records the rule and its necessity in the module docstring, in the shape `UniversalCover.lean` uses for its own multigraph convention; Phase 6's test module pins `coneR_serial_fwd`'s axiom profile. |
| `NamingRules.lean` keeps asserting the obligation open after this lands | M (documentation correctness) | M | Phase 6 deliverable, not cleanup. The target paragraph was confirmed present at authoring time (see that phase's `Files to modify` annotation for the fallback if it has moved). |
| The module docstring introduces an unregistered paper anchor and trips C15 | M | L | C15's sweep matches any `def:`/`thm:`/`lem:`/`cor:`/`app:`/`rmk:` token in a live `.lean` file. The only anchor this module needs, `def:frame#Saturation`, is already registered (it is carried by `saturation_of_orientedForest`'s own doc comment). Phase 6 adds no new anchor. |
| `simp_all [parIn]` in the acyclicity proof is brittle under a Mathlib bump | L | L | It compiles at this pin; Phase 1 records it in the module's "Verified Mathlib names" table as `OrientedForest.lean` already does. |
| A repo-wide gate is red for pre-existing, unrelated reasons and is read as this task's failure | M | M | Phase 6's criteria are stated as touched-file scope plus a baseline delta, never an absolute repo-wide zero; a finding naming no file this task touched is a recorded PASS with the pre-existing findings enumerated. |

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.OrientedForest
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.ForMathlib.Combinatorics.SimpleGraphAcyclic

open FormalSystem.Semantics
open FormalSystem.PlusLanguage

variable {W : Type}

abbrev coneRin (E : W → W → Prop) : (W × List W) → (W × List W) → Prop :=
  fun p q => E p.1 q.1 ∧ q.2 = p.1 :: p.2

abbrev coneR (E : W → W → Prop) : (W ⊕ (W × List W)) → (W ⊕ (W × List W)) → Prop :=
  fun z z' =>
    match z, z' with
    | .inl u, .inl v => E u v
    | .inl u, .inr q => E u q.1
    | .inr p, .inr q => coneRin E p q
    | .inr _, .inl _ => False

abbrev coneF : (W ⊕ (W × List W)) → W :=
  fun z =>
    match z with
    | .inl u => u
    | .inr p => p.1

theorem coneRin_isOrientedForest (E : W → W → Prop) : IsOrientedForest (coneRin E) := sorry

theorem coneRin_bwd_unique {E : W → W → Prop} :
    ∀ (n : ℕ) (p p' q : W × List W),
      iter (coneRin E) n p q → iter (coneRin E) n p' q → p = p' := sorry

theorem coneR_serial_fwd {E : W → W → Prop} (hfwd : ∀ w, ∃ u, E w u) :
    ∀ z : W ⊕ (W × List W), ∃ z', coneR E z z' := sorry

theorem coneR_serial_bwd {E : W → W → Prop} (hbwd : ∀ w, ∃ v, E v w) :
    ∀ z : W ⊕ (W × List W), ∃ z', coneR E z' z := sorry

theorem saturation_coneR {E : W → W → Prop}
    (hbase : TaskFrame.Saturation (ofStepRel E)) :
    TaskFrame.Saturation (ofStepRel (coneR E)) := sorry

theorem coneF_surjective {E : W → W → Prop} :
    Function.Surjective (coneF (W := W)) := sorry

theorem exists_coneUnravelling (F : FrameOver intOrder) [F.IsRegular]
    (M : TaskModel F.toTaskFrame) :
    ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (f : F'.WorldState → F.WorldState),
      TwoWayBounded f ∧ Function.Surjective f ∧
        ∃ g : HistMorphism F' F, g.toFun = f ∧
          ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑intOrder),
            PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := sorry
```

`FormalSystem.PlusLanguage` is opened at the top of this block rather than with the
`open ... in` prefix `UniversalCover.lean` uses on its own headline, because the snapshot
extractor chunks at the declaration keyword and would strip a per-declaration `open ... in`,
leaving the extracted module unable to resolve `PlusFormula` and `PlusTruthAt`. The module itself
should keep the `open FormalSystem.PlusLanguage in` form on both headline theorems, matching
`UniversalCover.lean`.

The three carrier definitions are written as `abbrev` here deliberately: an `abbrev` keeps its
real body verbatim and contributes no name to the cross-validated identifier set, which is what
lets this block type-check standalone while the pinned identifier set stays exactly the seven
names listed under `- **Goals**:`. The module itself declares them as ordinary `def`s.

`coneF_twoWayBounded` and `coneFrame` (both `[F.IsRegular]`-parameterised, per Phase 5's blocker
resolution) are real Phase 5 deliverables but are deliberately not pinned here: their statements
mention the frame `def` itself, which cannot be stated in an isolated Challenge module without
pulling the whole assembly in. They are governed by Phase 5's task list and verification
criteria instead.

### Amendment record

`exists_coneUnravelling`'s pinned signature above is **not** the statement this plan recorded
when it was first written. It was recorded as
`exists_coneUnravelling_of_constraints (F) (hcomp) (hser) (hlim) (M)`, and Phase 5 then
established — machine-checked, evidence preserved under `## Decisions`, *"Base Saturation is
inherited, not manufactured"* — that no such declaration can be proved of this construction. The
signature above, instance-projected `exists_coneUnravelling (F) [F.IsRegular] (M)` with the
`_of_constraints` layer dropped entirely, is a **user decision**, recorded in
`specs/894_cone_unravelling_frame_layer_split_saturation/.decisions.json` (cycle 3). It is not a
silent edit: `rules/plan-compliance.md`'s *Statement Fidelity* section requires exactly this
trail — a recorded Challenge is amended by raising it and getting an answer, never by quietly
rewriting it to match whatever turned out to be provable.

Two consequences the implementer should hold on to:

- **The amended signature is stronger-or-equal, not weaker.** `FrameOver.IsRegular`
  (`FormalSystem/Semantics/TaskFrame.lean:1189`) bundles exactly `comp`, `serial`, `limit` and
  `saturation`, so `[F.IsRegular]` supplies everything the four-hypothesis form would have
  supplied *plus* the base *Saturation* the cone provably consumes. Dropping `_of_constraints`
  removes an API layer, not a theorem.
- **No consumer breaks and no name is squatted.** `coneFrame`, `coneF_twoWayBounded` and
  `exists_coneUnravelling` are the names `FormalSystem/Semantics/ConeUnravelling.lean`'s own
  module docstring already reserves, in its *Main definitions* and *Main results* lists; the
  `_of_constraints` spelling was the departure from that module contract. Landed work in the file
  stops at `coneF_surjective`, and nothing in the tree references any of the three yet.

## Decisions

- **The promiscuous entry edge is load-bearing and is not narrowed.** Recorded here as well as
  in the module docstring because `h = [u]` is the "obvious" reading and will look like a
  correctness improvement to a later reader. It is not: under it the carrier holds incoherent
  nodes `inr (v, a :: t)` with `¬ E a v` that have no predecessor at all, so
  `TaskFrame.Serial` fails and the carrier would have to be cut to a subtype.
- **The assembly tail is routed through the instance-projected API throughout**, not through the
  `_of_constraints` layer. Three concrete choices follow from the recorded decision and are
  fixed here so Phase 5 does not re-litigate them mid-proof:
  - the base-*Saturation* bridge reads `FrameOver.taskRel_eq_iter` (`IntNormalForm.lean:297`),
    not `taskRel_eq_iter_of_constraints`;
  - `coneF_twoWayBounded` reads the base side through the same `F.taskRel_eq_iter`;
  - the headline calls `TwoWayBounded.plus_invariance_of_isZTime`
    (`HistoryMorphism.lean:707`), not `..._of_constraints`. The task description names this
    entry point directly, and both frames carry `IsRegular` instances at the call site, so the
    constraint-threading form would only re-expand instances the synthesiser already has.
  `UniversalCover.lean` keeps the two-layer (`_of_constraints` + instance) shape because its base
  is deliberately *not* assumed regular; the cone's base must be, so the second layer would have
  nothing to parameterise over.
- **Base *Saturation* is inherited, not manufactured — and that asymmetry with
  `UniversalCover.lean` is the substantive content of this module, not slack to be tidied away.**
  This is the finding that produced the signature amendment, and it is machine-checked, so it is
  recorded here rather than left in a phase's blocker narrative:
  1. A bare `FrameOver` carries no frame axiom at all. The four axioms live in the separate
     `FrameOver.IsRegular` class (`TaskFrame.lean:1189`), not in the structure
     (`TaskFrame.lean:1072`).
  2. Base *Saturation* does **not** follow from *Compositionality* + *Seriality* + *Limit*.
     `FormalSystem/Semantics/FrameConstraintIndependence.lean`'s
     `constraints_pairwise_independent` has as its third conjunct
     `⟨ℤ, rayRel, rayRel_compositional, rayRel_serial, rayRel_limit, rayRel_not_saturation⟩`.
  3. The cone's *Saturation* cannot be obtained structurally the way the cover's is.
     `saturation_of_orientedForest` cannot apply to `coneR E`, because `IsOrientedForest (coneR E)`
     is false: the `inl` layer is a verbatim copy of `E` and inherits its loops and opposite
     edges. Only the `inr` layer is a forest — which is precisely why *Saturation* had to be
     split in two, and why the `inl`-anchored half (`sInter_nonempty_of_no_inr_member`) reads
     `hbase`.
  4. Base *Saturation* is **necessary**, not merely convenient. Take `E := fun w u => (w ≤ u : Prop)`
     on `ℤ`. The family `{TaskFrame.Fib (ofStepRel (coneR E)) (.inl w) 1 | w : ℤ}` has `w`-th
     member `{.inl u | w ≤ u} ∪ {.inr q | w ≤ q.1}`; it is `⊇`-directed (the member at
     `max w₁ w₂` sits inside the intersection, both parts being monotone in `w`), every member is
     a nonempty `IsFiber`, and `⋂₀` of it is empty. So *Saturation* of the cone genuinely fails
     over a base satisfying *Compositionality*, *Seriality* and *Limit*: there is no way to give
     the cone carrier a *Saturation* field over such a base.
  The prohibition that came with this finding stands and is permanent: `exists_coneUnravelling`
  must **not** be discharged by delegating to `exists_orientedForest_cover`, which has a
  satisfying witness of the right *type* and the wrong *construction*. Such a proof would assert
  nothing about this module while passing every name-existence, `sorry` and axiom check.

- **`saturation_coneR`'s signature takes `hbase` in `ofStepRel` form**, mirroring
  `saturation_of_orientedForest'`'s own `hgen`-parameterised design, because this tree ships no
  relation-level `F.TaskRel = ofStepRel F.step` equality for a general regular `F` — only the
  pointwise biconditional `FrameOver.taskRel_eq_iter`
  (`FormalSystem/Semantics/IntNormalForm.lean:297`, the `[F.IsRegular]` projection of
  `taskRel_eq_iter_of_constraints`). Phase 5 closes that gap once, as its own named lemma, at the
  frame assembly.
- **The evidence probe is promoted, then left in place and tracked, and is NOT added to
  `scripts/check-evidence-probes.sh`'s `WIRED` list.** That list guards probes recording a design
  *obstruction*; this probe records a *construction* that the library module and Phase 6's
  axiom-profile test pin supersede. Wiring it would duplicate the library's own build coverage
  and create a second place to repair on every Mathlib bump.
- **Phase 6 regenerates inventory surface (a) but no phase defers surface (b).** The asymmetry is
  mechanical, not stylistic: surface (b) (`typst/generated/status.typ`) is enforced by
  `.githooks/pre-commit` and blocks the commit of the phase that moved it, while surface (a)
  (the `README.md` inventory blocks) is checked by a later verification step and may legitimately
  be reconciled once at the end.

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

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
consumes declarations the previous one lands.

### Phase 1: Module skeleton, carrier, relation, oriented forest [COMPLETED]

**Goal**: Create `FormalSystem/Semantics/ConeUnravelling.lean` with its full module docstring,
the four definitions, the three `IsOrientedForest` obligations and their assembly, the
unique-inr-predecessor lemma, and double seriality — all promoted from the compiled probe with
docstrings added — and get the new module into the library root and the generated count surface.

**Tasks**:
- [x] Create the module with the standard copyright header and the three imports the probe uses
      (`FormalSystem.Semantics.OrientedForest`, `FormalSystem.Semantics.HistoryMorphism`,
      `FormalSystem.ForMathlib.Combinatorics.SimpleGraphAcyclic`), opening
      `namespace FormalSystem.Semantics` with `variable {W : Type}`.
- [x] Write the module docstring on `UniversalCover.lean`'s pattern: the construction, a
      **"The promiscuous entry edge, and why narrowing it breaks seriality"** section stating the
      decision and the counterexample shape, a "Why not reuse the universal cover" section
      (verbatim-copy-plus-tree vs. forest-everywhere, and that `ProofSystem.FrameClass.Sat`'s
      `IsRegular` demand is what both exist to satisfy), Main definitions, Main results, a
      "What is deliberately absent" section, and a "Verified Mathlib names" note recording
      `SimpleGraph.isAcyclic_of_rank_parent` and the `simp_all [parIn]` obligation as pin-sensitive.
- [x] Introduce no `def:`/`thm:`/`lem:`/`cor:`/`app:`/`rmk:`-shaped token in the docstring other
      than `def:frame#Saturation`, which is already registered in
      `docs/reference/paper-definitions-of-record.md`.
- [x] Promote `coneRin`, `coneR`, `coneF`, `parIn` verbatim from the probe's `Probe894` namespace,
      each with its own doc comment. Keep the names exactly as probed — all four are
      lowerCamelCase and therefore C26-clean.
- [x] Promote `coneRin_loopFree`, `coneRin_oppFree`, `coneRin_acyclic`,
      `coneRin_isOrientedForest`.
- [x] Promote `coneRin_bwd_unique` and `coneRin_bwd_subsingleton`.
- [x] Promote `coneR_serial_fwd`, `coneR_serial_bwd`.
- [x] Confirm `Nonempty (W ⊕ (W × List W))` is derivable from `Nonempty W` for
      `FrameOver.ofStepSat`'s `[Nonempty W]` binder; if it is not found by instance search, add a
      named instance beside the definitions, mirroring `CoverPt.instNonempty`.
- [x] Run `lake exe mk_all --lib FormalSystem` and stage the regenerated `FormalSystem.lean`
      (C33: a plan adding files carries this step explicitly).
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`
      in the same commit as the Lean lines.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that the eleven declarations named above
(`coneRin`, `coneR`, `coneF`, `parIn`, `coneRin_loopFree`, `coneRin_oppFree`, `coneRin_acyclic`,
`coneRin_isOrientedForest`, `coneRin_bwd_unique`, `coneRin_bwd_subsingleton`,
`coneR_serial_fwd`, `coneR_serial_bwd`) promote without proof change from the probe's `Probe894`
namespace. Confirm by diffing each promoted body against the probe file before compiling; if any
body needs a change, record which and why in the progress file rather than silently editing.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__` -- no shell suite maps any of them -- so the covering check is the `local`
row's own single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling`,
which is the only thing that can observe a break confined to one brand-new module no other
module imports yet.

**Files to modify**:
- `FormalSystem/Semantics/ConeUnravelling.lean` - created: docstring, four definitions, three oriented-forest obligations and their assembly, unique-predecessor pair, double seriality
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem` to import the new module
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`; blocking surface, cannot be deferred

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` is green with zero warnings (CI builds with `--wfail`, so a lint warning is a failure).
- `grep -c 'sorry' FormalSystem/Semantics/ConeUnravelling.lean` is 0.
- `bash scripts/typst-sync-check.sh --counts-only` is green, so the phase's own commit is not refused by `.githooks/pre-commit`.
- Each promoted declaration's statement matches the probe's character-for-character, as diffed in the task above.

---

### Phase 2: The transport layer [COMPLETED]

**Goal**: Land the projection homomorphism, the `iter`-level transport identities, the
`Fib`-level preimage bridges and the two inr-layer lifts — the vocabulary both halves of the
*Saturation* split and both `TwoWayBounded` fields consume. All promoted from the probe's
`Probe894`/`Probe894b`/`Probe894c` namespaces.

**Tasks**:
- [x] Promote `coneF_step` and `coneF_iter` with doc comments naming their role (the projection is
      a homomorphism of one-step relations, and iterated).
- [x] Promote the four `iter`-level identities: `iter_inl_target`, `iter_inl_inl`, `iter_inr_fwd`,
      `iter_inl_inr`. Give `iter_inl_inr` a doc comment recording that it is where the promiscuous
      entry edge collapses a union over entry points into a single base fibre.
- [x] Promote the four `Fib`-level bridges: `inl_preimage_fib_inl`, `inl_preimage_fib_inr_neg`,
      `fib_inr_pos_subset`, `inr_preimage_fib_inr_pos`.
- [x] Promote the two lifts: `exists_iter_coneRin` and `exists_iter_coneR_bwd_inr`.
- [x] Add a `/-! ## ... -/` section header before each group, as `UniversalCover.lean` does.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that twelve declarations promote without proof change
(`coneF_step`, `coneF_iter`, `iter_inl_target`, `iter_inl_inl`, `iter_inr_fwd`, `iter_inl_inr`,
plus the four `Fib`-level bridges and the two lifts). Confirm the same way as Phase 1 — diff
each body against the probe before compiling, and record any body that needed a change.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__`, so the covering check is the `local` row's single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling`;
no externally visible signature changes and no other module imports this one yet, so nothing
downstream can observe the edit.

**Files to modify**:
- `FormalSystem/Semantics/ConeUnravelling.lean` - the projection homomorphism, four `iter`-level identities, four `Fib`-level preimage bridges, two inr-layer lifts
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Semantics/ConeUnravelling.lean` is 0.
- `bash scripts/typst-sync-check.sh --counts-only` is green.

---

### Phase 3: The member-shape classification and the split's set-level scaffolding [COMPLETED]

**Goal**: State and prove, as named lemmas, every bookkeeping fact the *Saturation* split
consumes — the exhaustive member-shape classification, the inl-element-existence fact that
excludes shapes in Case B, the inr-layer subsingleton fact for Step 1, and the frame-independent
cofinality equality — so that a missing cell fails here, at a named declaration, rather than
inside Phase 4's case analysis.

**Tasks**:
- [x] State `cone_member_classification` (name may be adjusted for namespace fit, recorded in the
      progress file if so): for a member `s` of a `DirectedFamily` over `ofStepRel (coneR E)`
      satisfying `(IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty`, enumerate the shape cells over the
      grid `{IsFiber, IsSegment} × {inl-anchored, inr-anchored} × {0 ≤ x, x < 0}` and name for
      each cell which disposition Phase 4 uses (subsingleton, `Sum.inl ⁻¹'` transport,
      `Sum.inr ⁻¹'` transport, or excluded by `s ⊆ Set.range Sum.inr`). All twelve cells must be
      accounted for; a cell with no disposition is a blocker, not a gap to paper over.
- [x] Prove `mem_range_inl_of_mem`: an inl-anchored fibre, and a negative-duration inr-anchored
      fibre, always contain an element of `Set.range Sum.inl` — obtained from any member element
      via `coneF` together with `iter_inl_inl` / `iter_inl_inr`. This is the fact that excludes
      those shapes from `S_inr` in Case B.
- [x] Prove `subsingleton_of_subset_range_inr`: a segment contained in the inr layer is a
      subsingleton, via `coneRin_bwd_subsingleton` and `seg_subsingleton`. *(deviation: altered — `seg_subsingleton` is inapplicable (it demands `IsOrientedForest (coneR E)`, false for the inl layer); proved at its named statement via `coneRin_bwd_unique` through `iter_inr_fwd`)*
- [x] Prove `fib_or_seg_inl_preimage`: Case A's table as one lemma — for a member not contained
      in `Set.range Sum.inr`, `Sum.inl ⁻¹' s` is a base fibre or segment of
      `ofStepRel E`, nonempty, with `inl b ∈ s ↔ b ∈ Sum.inl ⁻¹' s`. Compose the two
      negative/positive `Fib` rows from Phase 2 for the `Seg` case.
- [x] Prove `cofinal_sInter_eq`: if `T ⊆ S` is cofinal in `S` under `⊆` then `⋂₀ T = ⋂₀ S`. This
      mentions no relation; place it in the set-level preamble of this module (not in
      `OrientedForest.lean`, which is not modified by this task).
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts five intermediate lemmas and a twelve-cell exhaustive
classification grid. Both are hypotheses: confirm the grid is exhaustive by enumerating it
against `TaskFrame.IsFiber` / `TaskFrame.IsSegment`'s actual definitions in
`FormalSystem/Semantics/TaskFrame.lean` at implementation time, and record in the progress file
any cell the research report's table did not anticipate. A thirteenth cell, or a cell whose
disposition cannot be named, is a `[BLOCKED]` outcome naming that cell — never a placeholder.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__`, so the covering check is the `local` row's single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling`;
every declaration added here is new, private to this module's own later proofs, and changes no
existing signature.

**Files to modify**:
- `FormalSystem/Semantics/ConeUnravelling.lean` - the member-shape classification plus the four scaffolding lemmas named in this phase's task list
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Semantics/ConeUnravelling.lean` is 0.
- The classification lemma's statement, read back, covers all twelve cells with a named
  disposition each.
- `bash scripts/typst-sync-check.sh --counts-only` is green.

---

### Phase 4: The two-layer Saturation lemma [COMPLETED]

**Goal**: Prove `saturation_coneR` at the pinned signature — `TaskFrame.Saturation (ofStepRel (coneR E))`
from `TaskFrame.Saturation (ofStepRel E)`, with no seriality hypothesis — as the four-step case
analysis the research report derives.

**Tasks**:
- [x] Open the proof with the intersect-nonemptily handle: directedness plus member-nonemptiness
      gives that any two members meet, by taking the common sub-member and using its nonemptiness.
- [x] Step 1: close via `sInter_nonempty_of_subsingleton_member` whenever some member is a
      subsingleton — disposing of every duration-zero fibre (`fib_zero_eq_singleton`), every
      segment with `x = 0` or `y = 0`, and every segment contained in the inr layer (via
      Phase 3's `subsingleton_of_subset_range_inr`).
- [x] Step 2: split on `∃ s₀ ∈ S, s₀ ⊆ Set.range Sum.inr`.
- [x] Step 3 (Case A, no member inside the inr layer): transport the whole family by
      `Sum.inl ⁻¹'` using Phase 3's `fib_or_seg_inl_preimage`, apply `hbase`, and return
      `Sum.inl b`.
- [x] Step 4 (Case B): put `S_inr := {s ∈ S | s ⊆ Set.range Sum.inr}`; prove it cofinal in `S`
      by directedness; conclude `⋂₀ S_inr = ⋂₀ S` by Phase 3's `cofinal_sInter_eq`; use
      `mem_range_inl_of_mem` to show every post-Step-1 member of `S_inr` is
      `Fib R (.inr p) x` with `0 ≤ x`; transport by `Sum.inr ⁻¹'` using
      `inr_preimage_fib_inr_pos`; and close with
      `saturation_of_orientedForest (coneRin_isOrientedForest E)` on the transported family.
- [x] Do not substitute `sInter_nonempty_of_forward_fibres` for the Step 4 endpoint. It is an
      equally valid endpoint and skips the `IsFiber` repackaging, but this plan selects
      `saturation_of_orientedForest` for fidelity to the task description; a switch is a
      `[BLOCKED]` escalation under `rules/plan-compliance.md`, not an in-flight choice.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: none asserted — this phase names one theorem and no count, file list, or
scope estimate beyond its single declared file.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__`, so the covering check is the `local` row's single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling`,
plus `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` deferred to Phase 6;
nothing imports this module yet, so no downstream surface exists for a cheaper-tier blind spot
to hide in.

**Files to modify**:
- `FormalSystem/Semantics/ConeUnravelling.lean` - `saturation_coneR` and any step lemmas its proof factors out
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Semantics/ConeUnravelling.lean` is 0.
- `saturation_coneR`'s signature matches the `## Lean Challenge Statements` block exactly: one
  `hbase` hypothesis, no seriality hypothesis, conclusion `TaskFrame.Saturation (ofStepRel (coneR E))`.
- `bash scripts/typst-sync-check.sh --counts-only` is green.

---

### Phase 5: Frame assembly, TwoWayBounded, and the headline [COMPLETED]

**Prior blocker, resolved.** This phase stalled once, on a signature defect: every
frame-assembly declaration it originally declared omitted the base-*Saturation* hypothesis the
cone construction provably consumes, so `coneFrameOfSerial (F) (hser)` could not be defined at
all and the pinned `exists_coneUnravelling_of_constraints (F) (hcomp) (hser) (hlim) (M)` could not
be proved of this construction. The finding was escalated and answered: the headline is stated in
the **instance-projected** form only — `coneFrame (F) [F.IsRegular]` and
`exists_coneUnravelling (F) [F.IsRegular] (M)` — with the `_of_constraints` layer dropped
entirely. The decision is recorded in
`specs/894_cone_unravelling_frame_layer_split_saturation/.decisions.json`; the signature trail is
under `## Lean Challenge Statements`, *Amendment record*; and the four machine-checked facts that
forced it (no axiom on a bare `FrameOver`; base *Saturation* independent of the other three; no
structural route for `coneR`; base *Saturation* necessary, by the `ℤ`/`≤` witness) are preserved
under `## Decisions`, *"Base Saturation is inherited, not manufactured"*, together with the
standing prohibition on discharging the headline through `exists_orientedForest_cover`. Nothing
about the blocker is open; the task list below is the resolved form and is executable as written.

**Landed in this phase before the stall** (committed, green, sorry-free): `coneF_surjective`, at
the pinned Challenge signature, axiom-free (measured: `#print axioms` reports no axioms). It is
independent of the frame assembly. Nothing else in the task list was attempted, per
`rules/plan-compliance.md`'s escalate-before-deviating requirement — so no landed work needs
revisiting and the five remaining items are all new.

**Goal**: Present the carrier as a regular `FrameOver intOrder`, prove the projection surjective
and `TwoWayBounded`, and assemble the L⁺ transfer headline — mirroring
`UniversalCover.lean`'s assembly tail declaration-for-declaration.

**Tasks** (in order; the bridge lemma comes first because every later item reads it):
- [x] State and prove the base-*Saturation* bridge as its own named lemma, before the frame
      assembly consumes it: `base_taskRel_eq_ofStepRel (F : FrameOver intOrder) [F.IsRegular] :
      F.TaskRel = ofStepRel F.step`, by `funext w d u` then `propext` of
      `FrameOver.taskRel_eq_iter F w u d` (`FormalSystem/Semantics/IntNormalForm.lean:297` — the
      `[F.IsRegular]` projection; `ofStepRel F.step w d u` is *definitionally* that theorem's
      right-hand conjunction, which is what makes the `propext` step go through). Place it in
      `ConeUnravelling.lean`, not in `IntNormalForm.lean`: the statement is general enough to
      belong upstream eventually, but `IntNormalForm.lean` is widely imported and this task's
      blast radius is deliberately one module. Record that placement rationale in its doc comment
      so a later reader can promote it deliberately rather than duplicate it.
- [x] `coneFrame (F : FrameOver intOrder) [F.IsRegular] : FrameOver intOrder` via
      `FrameOver.ofStepSat (coneR F.step)`: the two seriality fields from
      `coneR_serial_fwd`/`coneR_serial_bwd` applied to `F.serial w 1 zero_le_one`, and the
      *Saturation* field from `saturation_coneR` applied to `F.saturation` rewritten by the
      bridge lemma. `[Nonempty (F.WorldState ⊕ _)]` is discharged by `instNonemptyCone` off
      `FrameOver`'s instance-implicit `worldNonempty` field (`TaskFrame.lean:1072`), so no new
      instance is needed; confirm that synthesis actually fires rather than assuming it.
      There is **no** `coneFrameOfSerialSat` intermediate layer — see `## Decisions`.
- [x] `coneFrame_taskRel : (coneFrame F).TaskRel = ofStepRel (coneR F.step)` via
      `FrameOver.ofStepSat_taskRel`, and the `coneFrame_isRegular` instance via
      `FrameOver.ofStepSat_isRegular` — mirroring `coverFrame_taskRel` / `coverFrame_isRegular`
      (`UniversalCover.lean:476-487`). `coneFrame_isRegular` must be an `instance`, not a
      `theorem`: the headline's call to `plus_invariance_of_isZTime` needs it by synthesis.
- [x] `coneF_surjective` with the `Sum.inl` section, axiom-free as `endpt_surjective` is. *(completed)*
- [x] `coneF_twoWayBounded (F : FrameOver intOrder) [F.IsRegular] :
      TwoWayBounded (F' := coneFrame F) (F := F) coneF`: `forth` from `coneF_iter` on the two
      sign-guarded conjuncts of `ofStepRel`, with the source side rewritten by `coneFrame_taskRel`
      and the base side by `F.taskRel_eq_iter` (not `taskRel_eq_iter_of_constraints`); `step` by
      the four-way split — `.inl w` either sign via `iter_inl_inl`; `.inr p` with `0 ≤ x` via
      `exists_iter_coneRin`; `.inr p` with `x < 0` via `iter_inl_inr` landing on `.inl v`.
      `endpt_twoWayBounded_of_constraints` (`UniversalCover.lean:497`) is the line-for-line
      template for the two fields; read it before writing this one.
- [x] `exists_coneUnravelling (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)`,
      via `TwoWayBounded.plus_invariance_of_isZTime` (`HistoryMorphism.lean:707` — the
      instance-projected form, which reads `[F'.IsRegular]` and `[F.IsRegular]` by synthesis, so
      the `coneFrame_isRegular` instance above is what makes it apply) with `SuccOrder ℤ` /
      `IsSuccArchimedean ℤ` by `inferInstanceAs`. The existential is discharged with
      `⟨coneFrame F, coneFrame_isRegular F, coneF, coneF_twoWayBounded F, coneF_surjective, …⟩`,
      mirroring `exists_orientedForest_cover`'s own assembly shape.
- [x] Give `exists_coneUnravelling` a doc comment recording that its *Saturation* is
      **inherited** from `[F.IsRegular]`, not manufactured from `Compositional`/`Serial`/`Limit`
      alone -- the asymmetry with `UniversalCover.lean` recorded in `## Decisions` -- plus a
      `Constraints consumed:` line and a `Paper: — (formalization-native; ...)` line, as
      `exists_orientedForest_cover_of_constraints` does, so Phase 6's theorem-index row is
      anchored at its declaration.
- [x] Re-point the module's three constraint-form citations at the instance-projected entry
      points this phase actually calls. All three are in
      `FormalSystem/Semantics/ConeUnravelling.lean`, confirmed present at revision time:
      line 23 (module overview) and line 114 (*What is deliberately absent*) both cite
      `TwoWayBounded.plus_invariance_of_isZTime_of_constraints`, and line 792
      (`saturation_coneR`'s doc comment) cites the pointwise
      `FrameOver.taskRel_eq_iter_of_constraints`. Name `plus_invariance_of_isZTime` and
      `FrameOver.taskRel_eq_iter` respectively, keeping the surrounding claims — "two fields plus
      `Function.Surjective`", and that the bridge is made once at the frame assembly — both of
      which stay true, and pointing line 792 at `base_taskRel_eq_ofStepRel` as the lemma that now
      makes the bridge. Prose correction inside the file this phase already edits; no new
      surface, no declaration change. If a line has moved, grep for the cited name rather than
      trusting the number.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
      *(run once per sub-step commit rather than once at phase end: `.githooks/pre-commit` enforces the line-count field, so every commit this phase fired needed it already staged)*

**Timing**: 2.5 hours (`coneF_surjective` already landed; the bridge lemma and the docstring
correction are the additions over the original estimate)

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts a seven-declaration assembly tail
(`base_taskRel_eq_ofStepRel`, `coneFrame`, `coneFrame_taskRel`, `coneFrame_isRegular`,
`coneF_surjective`, `coneF_twoWayBounded`, `exists_coneUnravelling`), all instance-projected (no
`_of_constraints` layer, per `## Decisions`), against `UniversalCover.lean`'s eleven-declaration
tail. The correspondence is deliberately **not** one-to-one: each of that module's
`_of_constraints`/instance pairs collapses to a single instance-projected declaration here, and
`base_taskRel_eq_ofStepRel` has no cover analogue because the cover never needs base
*Saturation* in `ofStepRel` form. Confirm by listing `UniversalCover.lean`'s assembly-tail
declarations at implementation time and checking that every one of them is either collapsed into
a named declaration above or recorded in the progress file as having no cone analogue, with the
reason. A cover declaration that is neither is a scope finding, not a silent omission.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__`, so the covering check is the `local` row's single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling`;
the phase adds only new declarations inside one module, changes no existing signature, and the
import-closure and whole-library consequences are what Phase 6's `full` gate exists to observe.

**Files to modify**:
- `FormalSystem/Semantics/ConeUnravelling.lean` - the base-*Saturation* bridge lemma, the frame assembly, surjectivity, `TwoWayBounded`, and the headline, all in instance-projected form (`[F.IsRegular]`, no `_of_constraints` layer); plus the one-name docstring correction in *What is deliberately absent*
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Semantics/ConeUnravelling.lean` is 0.
- `coneF_surjective` and `exists_coneUnravelling` match the `## Lean Challenge Statements`
  block exactly — `exists_coneUnravelling` in its amended, instance-projected form
  (`(F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)`), which is the recorded
  statement as of the user decision; the superseded `_of_constraints` spelling must not reappear.
- No declaration in the module takes `hcomp`/`hser`/`hlim`/`hsat` as an explicit
  frame-constraint hypothesis, and `grep -n '_of_constraints'
  FormalSystem/Semantics/ConeUnravelling.lean` returns nothing — the three prose citations are
  re-pointed by this phase's docstring task and the module calls no constraint-form lemma, so an
  empty result is the expected one here rather than merely an acceptable one.
- `bash scripts/typst-sync-check.sh --counts-only` is green.

---

### Phase 6: Documentation reconciliation, axiom-profile pin, and the full gate set [COMPLETED]

**Goal**: Retire `NamingRules.lean`'s "left open" assertion, pin the headline axiom profiles as
permanent evidence, add the theorem-index rows, regenerate the module-inventory surface, and run
the complete gate set over the finished tree.

**Tasks**:
- [x] Create `Tests/BimodalTest/Semantics/ConeUnravellingTest.lean` on
      `OrientedForestSaturationTest.lean`'s pattern: a docstring saying it is permanent evidence
      rather than a conventional test, a "When one of these guards fires" paragraph, and
      `#guard_msgs in #print axioms` blocks for `saturation_coneR`,
      `coneRin_isOrientedForest`, `coneF_surjective`, `coneF_twoWayBounded` and
      `exists_coneUnravelling`. Every expected block is **measured** in this
      dispatch, never typed from memory.
- [x] Add `import BimodalTest.Semantics.ConeUnravellingTest` to `Tests/BimodalTest.lean`.
- [x] Amend `FormalSystem/Metalogic/NamingRules.lean`'s module docstring: rewrite the paragraph
      ending "Discharging *Saturation* for a path-recording relation directly is left open." so
      it instead records that the obligation is discharged, naming
      `Semantics.saturation_coneR` and `Semantics.exists_coneUnravelling` (the
      instance-projected names; there is no `_of_constraints` form of either to cite), and
      keeping the three-routes-do-not-apply analysis (which remains true and is now the reason
      the new route was needed). Add the new module to that docstring's `## References` list.
      Introduce no import — this is a prose change only, so no new upward edge reaches
      `scripts/check-metalogic-cycles.sh`'s Assertion B.
- [x] Add `docs/theorem-index.md` rows for `saturation_coneR` (paper label
      `def:frame#Saturation`) and `exists_coneUnravelling` (paper label `—`), each
      anchored by the `Paper:` line already placed in its declaration's doc comment, and each
      naming `Tests/BimodalTest/Semantics/ConeUnravellingTest.lean` as the profile guard.
- [x] Add a cross-reference paragraph to both `UniversalCover.lean`'s and
      `ConeUnravelling.lean`'s docstrings stating the division of labour between the two
      unravelling constructions (verbatim-copy-plus-tree vs. forest-everywhere) and that
      `ProofSystem.FrameClass.Sat`'s `IsRegular` demand is what both exist to satisfy. This is
      the only edit this task makes to `UniversalCover.lean` and it adds no declaration.
- [x] `git add` the evidence probe directory
      `specs/evidence/cone-unravelling-frame-layer-split/` so the research report's citation
      resolves from a fresh clone. Do **not** add an entry to
      `scripts/check-evidence-probes.sh`'s `WIRED` list (see Decisions).
      *(already tracked: `git ls-files` resolves `specs/evidence/cone-unravelling-frame-layer-split/cone-core-probe.lean`, committed in an earlier phase, so no `git add` was needed; no `WIRED` entry added)*
- [x] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated
      inventory blocks.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
      *(run once per sub-step commit, as in Phase 5: `.githooks/pre-commit` enforces the line-count field)*
- [x] Run the complete gate set and record its outcome per the criteria below.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts (a) that the regenerated module-inventory surface lands
within the ancestor-chain READMEs listed below and nowhere else, and (b) that the
`NamingRules.lean` target paragraph still reads "Discharging *Saturation* for a path-recording
relation directly is left open." Confirm (a) by reading the staged diff after
`--emit-inventory` and staging exactly the files it actually rewrote — some listed READMEs carry
`rows=loose` blocks that a file added under `FormalSystem/Semantics/` does not move, so a
no-change outcome for one of them is expected, not a failure; confirm (b) by grepping for that
sentence before editing.

**Files to modify**:
- `Tests/BimodalTest/Semantics/ConeUnravellingTest.lean` - created: measured `#guard_msgs`-gated `#print axioms` blocks for the five headline declarations
- `Tests/BimodalTest.lean` - add the import of the new test module
- `FormalSystem/Metalogic/NamingRules.lean` - CORRECTION TARGET, confirmed present at authoring time: the module-docstring paragraph ending "Discharging *Saturation* for a path-recording relation directly is left open." If that sentence is absent when this phase runs, do not invent a replacement target: grep the docstring for the surrounding three-routes analysis, amend whatever sentence now carries the open-obligation claim, and record the discrepancy in the progress file; if no such claim remains at all, record the paragraph as already retired and skip the edit
- `FormalSystem/Semantics/ConeUnravelling.lean` - the cross-reference paragraph to the universal cover
- `FormalSystem/Semantics/UniversalCover.lean` - CORRECTION TARGET, confirmed present at authoring time: its module docstring gains the reciprocal cross-reference paragraph; no declaration changes. If the docstring's shape has changed, place the paragraph after its "Why not Mathlib's `Quiver/Covering.lean`" section and record the placement
- `docs/theorem-index.md` - two new rows, each anchored by a `Paper:` line at its declaration
- `README.md` - generated inventory block regenerated by `check-module-invariants.sh --emit-inventory`
- `FormalSystem/README.md` - generated inventory block regenerated by the same run, if that run touches it
- `FormalSystem/Metalogic/README.md` - generated inventory block regenerated by the same run, if that run touches it
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped) is green with zero warnings.
- `bash .claude/scripts/verify-deploy.sh` — the agent-system deploy gate set — records its
  outcome. The repo's deployed `.claude/` tree is already stale for the core, lean, literature
  and memory extensions (see this dispatch's deploy-freshness context), so findings there are
  pre-existing baseline, not this task's: the criterion is that no finding names a file this task
  touched. Enumerate any pre-existing findings rather than reporting a bare pass or fail.
- The repository's own complete gate set runs, each stated as a touched-file scope or a baseline
  delta, never an absolute repo-wide zero:
  `bash scripts/check-module-invariants.sh` (C26, C33, C15 paper-anchor integrity, C15's
  theorem-index anchoring assertion, and `FAIL INV` on the inventory blocks),
  `bash scripts/typst-sync-check.sh`,
  `bash scripts/check-metalogic-cycles.sh`,
  `bash scripts/check-copyright-headers.sh`,
  `bash scripts/check-paper-definitions.sh`,
  `bash scripts/check-phantom-citations.sh`,
  `bash scripts/check-evidence-probes.sh`,
  `bash scripts/readme-lint.sh`.
- `grep -rn 'sorry' FormalSystem/Semantics/ConeUnravelling.lean Tests/BimodalTest/Semantics/ConeUnravellingTest.lean` returns nothing.
- Every `#guard_msgs` block in the new test module was populated from a measured `#print axioms`
  run in this dispatch, and the module compiles — a red guard here means a profile moved and is
  never re-baselined to turn the build green.
- `grep -n 'left open' FormalSystem/Metalogic/NamingRules.lean` no longer returns the
  path-recording-*Saturation* sentence.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 894 .` is run and its verdict
  recorded; per `rules/plan-compliance.md` the verdict is ADVISORY ONLY and a drift finding is a
  signal to investigate, never grounds to fail the phase on its own. **Expect
  `ERROR: no manifest found ... exit 71`**: no snapshot was ever taken for this task (there is no
  `specs/894_cone_unravelling_frame_layer_split_saturation/challenge/manifest.json`), and
  snapshot mode refuses to create one once the task's status is past `planned`. Record that
  missing-manifest outcome as the verdict; it is the expected result, not a drift finding and not
  a failure. Do **not** run the script without `--check` to manufacture a manifest after the
  fact — a snapshot taken after implementation records the implementation, not the contract, and
  would launder exactly the signature drift the mechanism exists to catch. The *Amendment record*
  subsection under `## Lean Challenge Statements` is this task's fidelity trail in its place.

---


#### Gate-set outcome, as run

Every line below is a measured result from this dispatch, scoped as the criteria ask.

- `lake build` (unscoped, `defaultTargets = ["FormalSystem"]`): exit 0, 2970 jobs, zero `error:`, zero `warning`. `lake build BimodalTest`: exit 0, 3036 jobs, zero `error:`, zero `warning`. Both are needed — the default target does **not** include the test library, so the unscoped build alone would not have compiled the new `#guard_msgs` module.
- `verify-deploy.sh --skip-slow`: **PASS, 15 checks, 0 failures** — no findings at all, hence none naming a file this task touched. The dispatch's deploy-freshness context flags the deployed tree as stale for core/lean/literature/memory; that staleness produced no finding here because this repository is a deploy *consumer*, so every source-store-only gate `[SKIP]`s. Gate 8 (`tests/run-all.sh`, measured at 117.9s of the full run) is the one gate `--skip-slow` defers; per this dispatch's Batch Gate Deferral it runs once for the whole batch at the end of the invocation, deferred rather than forgiven.
- `check-module-invariants.sh`: exit 0 after two real findings were fixed. **C34a** flagged `base_taskRel_eq_ofStepRel` and `coneF_twoWayBounded` for carrying `Constraints consumed: Compositionality, Seriality, Limit` over an `[F.IsRegular]` binder that also supplies *Saturation*. `UniversalCover.lean`'s instance-projected declarations are excused by their binder-free twins (`coverFrameOfSerial` carries the three-constraint claim); this module has no twin by the recorded decision, so the markers were corrected to list all four with the reason stated inline. **FAIL INV** flagged a stale inventory block, fixed by re-running `--emit-inventory`.
- `typst-sync-check.sh`: exit 0. `check-metalogic-cycles.sh`: exit 0 (the `NamingRules.lean` change is prose-only and adds no import, so Assertion B sees no new upward edge). `check-copyright-headers.sh`: exit 0. `check-phantom-citations.sh`: exit 0. `check-evidence-probes.sh`: exit 0. `readme-lint.sh`: exit 0.
- `check-paper-definitions.sh`: exit 1, **pre-existing baseline, not this task's**. The drift is in `def:`, `def:frame`, `def:frame-properties`, `def:id`, `def:lang`, `def:qe` and `def:task-relation` between the paper source and `docs/reference/paper-definitions-of-record.md`. That record file and the paper `.tex` are the gate's only inputs and neither appears in this dispatch's changed-file set (`git diff --name-only dc881fc2b` plus the working tree), so no finding names a file this task touched.
- `lean-challenge-snapshot.sh --check 894 .`: `ERROR: no manifest found ... exit 71` — **exactly the predicted outcome**. No snapshot was ever taken for this task and snapshot mode refuses to create one past `planned`. Recorded as the verdict; not a drift finding, not a failure, and no manifest was manufactured after the fact. The *Amendment record* subsection under `## Lean Challenge Statements` is the fidelity trail in its place.
- Zero-debt scope: `lean-sorry-census.sh` over the four resolved source roots reports `sorry_count: 0`. `grep -rn 'sorry'` over both of this task's files returns nothing. Axiom count is **14 at both** `dc881fc2b` and the working tree — no increase. The vacuous-pattern sweep returns one hit, `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal ... := trivial`), in a file this task never touched and where the goal genuinely is trivially true: pre-existing baseline, not introduced here.
- Every `#guard_msgs` block in the new evidence module was populated from a measured `lean_verify` run in this dispatch and all five compile green. Measured profiles: `coneRin_isOrientedForest`, `saturation_coneR`, `coneF_twoWayBounded` and `exists_coneUnravelling` at `[propext, Classical.choice, Quot.sound]`; `coneF_surjective` axiom-free.
- `grep -n 'left open' FormalSystem/Metalogic/NamingRules.lean` returns nothing.
## Testing & Validation

- [ ] Full project build green, zero warnings (CI builds with `--wfail`; a lint warning is a CI failure).
- [ ] Zero `sorry` and zero new axiom in both new files.
- [ ] All seven `## Lean Challenge Statements` identifiers present at the pinned signatures,
      `exists_coneUnravelling` at its amended instance-projected signature (see that section's
      *Amendment record*).
- [ ] The five axiom-profile `#guard_msgs` blocks compile against measured profiles.
- [ ] `scripts/check-module-invariants.sh` clean for every touched file, with any pre-existing repo-wide finding enumerated.
- [ ] `scripts/typst-sync-check.sh` green (both Check 2 and the inventory-block check).
- [ ] `scripts/check-phantom-citations.sh`: the task description's `coneR` / `coneF` citations now resolve to definition sites in `FormalSystem/`.
- [ ] `scripts/check-metalogic-cycles.sh` unchanged — this task introduces no new upward import.
- [ ] `.githooks/pre-commit` accepted every Lean-touching commit without `--no-verify`.

## Artifacts & Outputs

- `FormalSystem/Semantics/ConeUnravelling.lean` — the new module (842 lines landed through
  `coneF_surjective`; ~150-250 more expected for Phase 5's assembly tail).
- `Tests/BimodalTest/Semantics/ConeUnravellingTest.lean` — the permanent axiom-profile evidence pin.
- `Tests/BimodalTest.lean`, `FormalSystem.lean` — root imports regenerated/extended.
- `FormalSystem/Metalogic/NamingRules.lean` — the retired "left open" paragraph.
- `FormalSystem/Semantics/UniversalCover.lean` — the reciprocal cross-reference paragraph only.
- `docs/theorem-index.md` — two new rows.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks.
- `typst/generated/status.typ` — regenerated counts.
- `specs/evidence/cone-unravelling-frame-layer-split/cone-core-probe.lean` — tracked, not wired.
- `specs/894_cone_unravelling_frame_layer_split_saturation/summaries/01_cone-unravelling-frame-layer-split-summary.md` — the completion summary.

## Rollback/Contingency

Each phase is one commit (or a short series of green sub-step commits), and every phase before
Phase 6 touches only the new module plus two generated files, so reverting is `git revert` of the
phase's own commits — no snapshot-then-rollback is needed for an ordinary back-out.

Should a phase need a genuine working-tree rollback that would discard uncommitted work, follow
`context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
including its out-of-scope override flag; do not emit a bare precautionary
`git-snapshot.sh 894`. For an ordinary defensive checkpoint before the Phase 4 case analysis —
the one phase whose proof is genuinely new work — use `git-snapshot.sh --no-revert`, which is
durable without reverting the tree.

Phases 1-4 are complete and Phase 5's prior blocker is resolved, so the live contingency
surface is Phase 5's remaining five declarations and Phase 6's documentation reconciliation. If
either stalls, the correct response is `[BLOCKED]` naming the stalled declaration — never a
`sorry`, a vacuous definition, or a weakened restatement of a pinned Challenge signature, and in
particular never a headline discharged through `exists_orientedForest_cover` (see
`## Decisions`). The module is additive and nothing imports it yet, so nothing landed before a
stall needs reverting: the partial module stays, with the blocker recorded.
