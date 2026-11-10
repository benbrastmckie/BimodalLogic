# Implementation Plan: Task #894

- **Task**: 894 - The forward-cone unravelling as a regular ZTime frame: inr-layer oriented forest and the two-layer Saturation split
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
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
and axiom-clean, the five pinned Challenge statements are proved at the recorded signatures, the
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

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap phases are therefore scheduled.

## Goals & Non-Goals

**Goals**:
- `coneRin_isOrientedForest` -- the inr layer is an oriented forest, over the full `W × List W`.
- `coneRin_bwd_unique` -- every inr node has a unique inr-predecessor along iterated steps.
- `coneR_serial_fwd`, `coneR_serial_bwd` -- double seriality of `coneR` on the literal sum carrier.
- `saturation_coneR` -- the two-layer *Saturation* split, with no seriality hypothesis.
- `coneF_surjective` -- the projection is surjective, axiom-free.
- `exists_coneUnravelling_of_constraints` -- the headline: a frame over `intOrder` carrying only
  *Compositionality*, *Seriality* and *Limit* has a regular cone-unravelling frame with
  surjective, two-way bounded projection, along which L⁺ truth transfers.

**Non-Goals**:
- The formula-level Auxiliary-Atoms rule. This task is the frame-side prerequisite only;
  `NamingRules.lean`'s `clock_irr_sound` and `irr_sound` are untouched.
- Any completeness or decidability claim built on top of the unravelling.
- Any modification of `UniversalCover.lean`. The two constructions answer different questions
  (verbatim-copy-plus-tree vs. forest-everywhere) and the existing module's headline has its own
  consumers.
- Unique path lifting and any `Prefunctor.IsCovering` machinery. `TwoWayBounded` has two fields
  and `plus_invariance_of_isZTime_of_constraints` consumes those two plus surjectivity.
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

theorem exists_coneUnravelling_of_constraints (F : FrameOver intOrder)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (M : TaskModel F.toTaskFrame) :
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

`coneF_twoWayBounded_of_constraints` and the `coneFrameOfSerial` / `coneFrame` pair are real
Phase 5 deliverables but are deliberately not pinned here: their statements mention the frame
`def` itself, which cannot be stated in an isolated Challenge module without pulling the whole
assembly in. They are governed by Phase 5's task list and verification criteria instead.

## Decisions

- **The promiscuous entry edge is load-bearing and is not narrowed.** Recorded here as well as
  in the module docstring because `h = [u]` is the "obvious" reading and will look like a
  correctness improvement to a later reader. It is not: under it the carrier holds incoherent
  nodes `inr (v, a :: t)` with `¬ E a v` that have no predecessor at all, so
  `TaskFrame.Serial` fails and the carrier would have to be cut to a subtype.
- **`saturation_coneR`'s signature takes `hbase` in `ofStepRel` form**, mirroring
  `saturation_of_orientedForest'`'s own `hgen`-parameterised design, because this tree has no
  relation-level `F.TaskRel = ofStepRel F.step` equality for a general regular `F` — only the
  pointwise `taskRel_eq_iter_of_constraints`. Phase 5 bridges it once at the frame assembly.
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

### Phase 5: Frame assembly, TwoWayBounded, and the headline [BLOCKED]

**BLOCKER** (Phase 5):

- **What failed**: every frame-assembly signature this phase declares omits the base-*Saturation*
  hypothesis the cone construction provably consumes. Concretely:
  `coneFrameOfSerial (F : FrameOver intOrder) (hser : TaskFrame.Serial F.TaskRel) : FrameOver intOrder`
  cannot be defined, because `FrameOver.ofStepSat` demands
  `TaskFrame.Saturation (ofStepRel (coneR F.step))` and the only route to it,
  `saturation_coneR`, demands `TaskFrame.Saturation (ofStepRel F.step)` — which `hser` does not
  supply and nothing else in scope provides. The same omission runs through
  `coneF_twoWayBounded_of_constraints` and the pinned headline
  `exists_coneUnravelling_of_constraints (F) (hcomp) (hser) (hlim) (M)`, and through this phase's
  `- **Goals**:` claim that a frame "carrying only *Compositionality*, *Seriality* and *Limit*"
  has a cone unravelling.
- **What was tried**:
  1. Reading the base *Saturation* off `F` — unavailable: a bare `FrameOver` carries no frame
     axiom at all (`FormalSystem/Semantics/TaskFrame.lean:1072`, `structure FrameOver`; the four
     axioms live in the separate `FrameOver.IsRegular` class at line 1189).
  2. Deriving base *Saturation* from `hcomp`/`hser`/`hlim` — **refuted**, machine-checked:
     `FormalSystem/Semantics/FrameConstraintIndependence.lean`'s
     `constraints_pairwise_independent` has as its third conjunct
     `⟨ℤ, rayRel, rayRel_compositional, rayRel_serial, rayRel_limit, rayRel_not_saturation⟩`.
  3. Deriving the cone's *Saturation* structurally, as `UniversalCover.lean` does — **impossible**
     for this construction, and this is the substantive finding. `saturation_of_orientedForest`
     cannot apply to `coneR E`: `IsOrientedForest (coneR E)` is false, since the `inl` layer is a
     verbatim copy of `E` and inherits its loops and opposite edges. Only the `inr` layer is a
     forest, which is exactly why *Saturation* had to be split in two in the first place, and
     why the `inl`-anchored half (`sInter_nonempty_of_no_inr_member`) reads `hbase`.
  4. Checking whether base *Saturation* is merely convenient rather than necessary —
     **necessary**. Take `E := fun w u => (w ≤ u : Prop)` on `ℤ`, i.e. `rayRel ·' 1 ·`. The family
     `{TaskFrame.Fib (ofStepRel (coneR E)) (.inl w) 1 | w : ℤ}` has as its `w`-th member
     `{.inl u | w ≤ u} ∪ {.inr q | w ≤ q.1}`; it is `⊇`-directed (the member at `max w₁ w₂` sits
     inside the intersection, both parts being monotone in `w`), every member is a nonempty
     `IsFiber`, and `⋂₀` of it is empty. So `TaskFrame.Saturation (ofStepRel (coneR E))` fails for
     a base that satisfies *Compositionality*, *Seriality* and *Limit*: there is **no** way to
     give the cone carrier over such a base a *Saturation* field.
- **Why it's stuck**: the pinned `exists_coneUnravelling_of_constraints` signature is *satisfiable*
  — but only by `exists_orientedForest_cover_of_constraints F hcomp hser hlim M`, the universal
  cover's existing headline, whose existential witness is the cover and not the cone. Proving a
  declaration named `exists_coneUnravelling_of_constraints` that way would be fraudulent: it
  would assert nothing whatever about this module's construction while passing every
  name-existence, sorry and axiom check. The honest cone headline requires one more hypothesis,
  and `rules/plan-compliance.md`'s *Statement Fidelity* section forbids adding a hypothesis to a
  recorded Challenge statement without raising it.
- **What is needed**: a one-line decision on which corrected signature to adopt. Both options are
  mechanical once chosen, and the remaining Phase 5 work is otherwise ready:
  - **(a) thread the hypothesis** — `coneFrameOfSerialSat (F) (hcomp) (hser) (hlim) (hsat)`,
    `coneF_twoWayBounded_of_constraints (F) (hcomp) (hser) (hlim) (hsat)`, and
    `exists_coneUnravelling_of_constraints (F) (hcomp) (hser) (hlim) (hsat) (M)`, with `hsat :
    TaskFrame.Saturation F.TaskRel` bridged into `ofStepRel` form once against
    `FrameOver.taskRel_eq_iter_of_constraints` exactly as this phase's second task already
    directs. The `_of_constraints` suffix then names all four constraints it consumes, which is
    the house meaning of the suffix.
  - **(b) state the headline only in the instance-projected form** —
    `coneFrame (F) [F.IsRegular]` and `exists_coneUnravelling (F) [F.IsRegular] (M)`, dropping the
    `_of_constraints` layer entirely. This is strictly less API but needs no signature that
    enumerates constraints at all.
  - Either way, record in the plan that the cone's *Saturation* is **inherited**, not
    manufactured — the asymmetry with `UniversalCover.lean`, whose base need not be saturated, is
    the substantive difference between the two constructions and should be stated rather than
    smoothed over.
- **Prohibited workarounds**: do NOT use `sorry`, `def X := True`, or any vacuous placeholder; and
  do NOT discharge `exists_coneUnravelling_of_constraints` by delegating to
  `exists_orientedForest_cover_of_constraints`.

**Landed in this phase before the blocker** (committed, green, sorry-free):
`coneF_surjective`, at the pinned Challenge signature, axiom-free (measured: `#print axioms`
reports no axioms). It is independent of the frame assembly. Nothing else in this phase's task
list was attempted, per `rules/plan-compliance.md`'s escalate-before-deviating requirement.

**Goal**: Present the carrier as a regular `FrameOver intOrder`, prove the projection surjective
and `TwoWayBounded`, and assemble the L⁺ transfer headline — mirroring
`UniversalCover.lean`'s assembly tail declaration-for-declaration.

**Tasks**:
- [ ] `coneFrameOfSerial (F : FrameOver intOrder) (hser : TaskFrame.Serial F.TaskRel) : FrameOver intOrder` *(deviation: blocked — signature omits the base-*Saturation* hypothesis; see BLOCKER)*
      via `FrameOver.ofStepSat (coneR F.step)`, with the two seriality fields from
      `coneR_serial_fwd`/`coneR_serial_bwd` at `hser w 1 zero_le_one`, and the *Saturation* field
      from `saturation_coneR` applied to the base's own *Saturation* in `ofStepRel` form.
- [ ] Bridge the base *Saturation* into `ofStepRel` form once, with `funext`/`propext` against
      `FrameOver.taskRel_eq_iter_of_constraints`, since this tree has no relation-level
      `F.TaskRel = ofStepRel F.step` equality for a general regular `F`.
- [ ] `coneFrameOfSerial_taskRel` and the `coneFrameOfSerial_isRegular` instance, via
      `FrameOver.ofStepSat_taskRel` / `ofStepSat_isRegular`.
- [ ] `coneFrame (F) [F.IsRegular]`, `coneFrame_taskRel`, and the `coneFrame_isRegular` instance —
      the `[F.IsRegular]`-projected specialisations, keeping the house `_of_constraints` /
      instance-projected pairing.
- [x] `coneF_surjective` with the `Sum.inl` section, axiom-free as `endpt_surjective` is. *(completed)*
- [ ] `coneF_twoWayBounded_of_constraints (F) (hcomp) (hser) (hlim)`: `forth` from `coneF_iter` on
      the two sign-guarded conjuncts of `ofStepRel` read against
      `taskRel_eq_iter_of_constraints`; `step` by the four-way split — `.inl w` either sign via
      `iter_inl_inl`; `.inr p` with `0 ≤ x` via `exists_iter_coneRin`; `.inr p` with `x < 0` via
      `iter_inl_inr` landing on `.inl v`.
- [ ] `coneF_twoWayBounded (F) [F.IsRegular]`, the instance-projected specialisation.
- [ ] `exists_coneUnravelling_of_constraints` and its `[F.IsRegular]` specialisation
      `exists_coneUnravelling`, via
      `TwoWayBounded.plus_invariance_of_isZTime_of_constraints` with `SuccOrder ℤ` /
      `IsSuccArchimedean ℤ` by `inferInstanceAs`, mirroring
      `exists_orientedForest_cover_of_constraints`.
- [ ] Give `exists_coneUnravelling_of_constraints` a doc comment carrying a
      `Constraints consumed:` line and a `Paper: — (formalization-native; ...)` line, as
      `exists_orientedForest_cover_of_constraints` does, so Phase 6's theorem-index row is
      anchored at its declaration.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts an eleven-declaration assembly tail mirroring
`UniversalCover.lean`'s. Confirm by listing `UniversalCover.lean`'s own assembly-tail
declarations at implementation time and checking the one-to-one correspondence; record any
declaration of that tail that has no cone analogue, and why, in the progress file.

**Tier Justification**: `suite_selection_select` over this phase's paths returns
`__FULL_SWEEP__`, so the covering check is the `local` row's single-module build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling`;
the phase adds only new declarations inside one module, changes no existing signature, and the
import-closure and whole-library consequences are what Phase 6's `full` gate exists to observe.

**Files to modify**:
- `FormalSystem/Semantics/ConeUnravelling.lean` - the frame assembly, surjectivity, both `TwoWayBounded` forms, and both headline forms
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` is green with zero warnings.
- `grep -c 'sorry' FormalSystem/Semantics/ConeUnravelling.lean` is 0.
- `coneF_surjective` and `exists_coneUnravelling_of_constraints` match the
  `## Lean Challenge Statements` block exactly.
- `bash scripts/typst-sync-check.sh --counts-only` is green.

---

### Phase 6: Documentation reconciliation, axiom-profile pin, and the full gate set [NOT STARTED]

**Goal**: Retire `NamingRules.lean`'s "left open" assertion, pin the headline axiom profiles as
permanent evidence, add the theorem-index rows, regenerate the module-inventory surface, and run
the complete gate set over the finished tree.

**Tasks**:
- [ ] Create `Tests/BimodalTest/Semantics/ConeUnravellingTest.lean` on
      `OrientedForestSaturationTest.lean`'s pattern: a docstring saying it is permanent evidence
      rather than a conventional test, a "When one of these guards fires" paragraph, and
      `#guard_msgs in #print axioms` blocks for `saturation_coneR`,
      `coneRin_isOrientedForest`, `coneF_surjective`, `coneF_twoWayBounded_of_constraints` and
      `exists_coneUnravelling_of_constraints`. Every expected block is **measured** in this
      dispatch, never typed from memory.
- [ ] Add `import BimodalTest.Semantics.ConeUnravellingTest` to `Tests/BimodalTest.lean`.
- [ ] Amend `FormalSystem/Metalogic/NamingRules.lean`'s module docstring: rewrite the paragraph
      ending "Discharging *Saturation* for a path-recording relation directly is left open." so
      it instead records that the obligation is discharged, naming
      `Semantics.saturation_coneR` and `Semantics.exists_coneUnravelling_of_constraints`, and
      keeping the three-routes-do-not-apply analysis (which remains true and is now the reason
      the new route was needed). Add the new module to that docstring's `## References` list.
      Introduce no import — this is a prose change only, so no new upward edge reaches
      `scripts/check-metalogic-cycles.sh`'s Assertion B.
- [ ] Add `docs/theorem-index.md` rows for `saturation_coneR` (paper label
      `def:frame#Saturation`) and `exists_coneUnravelling_of_constraints` (paper label `—`), each
      anchored by the `Paper:` line already placed in its declaration's doc comment, and each
      naming `Tests/BimodalTest/Semantics/ConeUnravellingTest.lean` as the profile guard.
- [ ] Add a cross-reference paragraph to both `UniversalCover.lean`'s and
      `ConeUnravelling.lean`'s docstrings stating the division of labour between the two
      unravelling constructions (verbatim-copy-plus-tree vs. forest-everywhere) and that
      `ProofSystem.FrameClass.Sat`'s `IsRegular` demand is what both exist to satisfy. This is
      the only edit this task makes to `UniversalCover.lean` and it adds no declaration.
- [ ] `git add` the evidence probe directory
      `specs/evidence/cone-unravelling-frame-layer-split/` so the research report's citation
      resolves from a fresh clone. Do **not** add an entry to
      `scripts/check-evidence-probes.sh`'s `WIRED` list (see Decisions).
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated
      inventory blocks.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
- [ ] Run the complete gate set and record its outcome per the criteria below.

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
- `bash .claude/scripts/lean-challenge-snapshot.sh --check` is run and its verdict recorded; per
  `rules/plan-compliance.md` the verdict is ADVISORY ONLY and a drift finding is a signal to
  investigate, never grounds to fail the phase on its own.

---

## Testing & Validation

- [ ] Full project build green, zero warnings (CI builds with `--wfail`; a lint warning is a CI failure).
- [ ] Zero `sorry` and zero new axiom in both new files.
- [ ] All seven `## Lean Challenge Statements` identifiers present at the pinned signatures.
- [ ] The five axiom-profile `#guard_msgs` blocks compile against measured profiles.
- [ ] `scripts/check-module-invariants.sh` clean for every touched file, with any pre-existing repo-wide finding enumerated.
- [ ] `scripts/typst-sync-check.sh` green (both Check 2 and the inventory-block check).
- [ ] `scripts/check-phantom-citations.sh`: the task description's `coneR` / `coneF` citations now resolve to definition sites in `FormalSystem/`.
- [ ] `scripts/check-metalogic-cycles.sh` unchanged — this task introduces no new upward import.
- [ ] `.githooks/pre-commit` accepted every Lean-touching commit without `--no-verify`.

## Artifacts & Outputs

- `FormalSystem/Semantics/ConeUnravelling.lean` — the new module (~450-600 lines expected).
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

If Phase 3's classification turns up a cell with no disposition, or Phase 4's case analysis
stalls, the correct response is `[BLOCKED]` naming the stalled cell — never a `sorry`, a
vacuous definition, or a weakened restatement of a pinned Challenge signature. Phases 1, 2 and 5
are promotions of already-compiling probe code and the module is additive, so nothing landed
before the stall needs reverting: the partial module stays, with the blocker recorded.
