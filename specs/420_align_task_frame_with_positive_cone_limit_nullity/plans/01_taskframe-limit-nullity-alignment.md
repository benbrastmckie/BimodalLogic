# Implementation Plan: Task #420

- **Task**: 420 - align_task_frame_with_positive_cone_limit_nullity
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours (Phases 1-5, in scope) + ~3 hours (Phase 6, deferred/blocked)
- **Dependencies**: Task 415 (`bundleFlowFrame`) — blocks Phase 6 only; Phases 1-5 have no dependencies
- **Research Inputs**: `specs/420_align_task_frame_with_positive_cone_limit_nullity/reports/01_taskframe-positive-cone-limit-nullity.md`
- **Artifacts**: plans/01_taskframe-limit-nullity-alignment.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The Lean `TaskFrame` structure already agrees with the paper's refactored `def:frame` on three of
four clauses (iff-Nullity, positive-cone lax Compositionality, the converse convention); the
module's prose says the opposite, its paper anchors are stale, and the fourth clause — Limit
Nullity — is absent. This plan lands every non-breaking correction (anchors, docstring inversion,
two reusable discharge helpers, one new derived theorem, the LaTeX frame-definition restatement)
as Phases 1-5, each ending on a green `lake build` with no `sorry` and no new axiom. The actual
`limit_nullity` structure field is isolated as a single terminal Phase 6 marked `[BLOCKED]`,
because the frame that cannot discharge it (`ParametricCanonicalTaskFrame` over `ℚ`/`ℝ`) is
already slated for replacement by task 415.

**Definition of done for this dispatch**: Phases 1-5 complete, `lake build` green, standalone
`pdflatex` of `02-Semantics.tex` green, all work committed. The correct terminus is then task
status `[BLOCKED]` on task 415 — **not** `[COMPLETED]`, and never a `sorry` or placeholder axiom.

### Research Integration

All findings below are Lean-verified in the research report unless flagged otherwise:

- The current `converse` field IS the paper's definitional converse convention packaged as
  structure data, not a substantive temporal-symmetry axiom. The `Axiomatization Notes` block at
  `TaskFrame.lean:93-97` is factually **inverted**: it claims divergence from a paper that has now
  **adopted** the same positive-cone presentation (`possible_worlds.tex:964` calls it "its
  official form"; `:957-959` gives the same nondeterminism-collapse argument).
- The discrete discharge helper needs `[SuccOrder D] [NoMaxOrder D]`, **not** `IsSuccArchimedean`
  — the task description over-specified. `NoMaxOrder D` follows by `infer_instance` from
  `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`, so the repo's existing
  discrete binder bundle already subsumes it.
- Deterministic-shift frames (duration recoverable from endpoints) satisfy Limit Nullity for
  **any** `D`, dense included — this covers 3 live sites and is the shape of every future flow
  frame.
- `identityFrame` needs `[Nontrivial D]` (an obligation the task description missed, and one the
  paper independently mandates).
- `ParametricCanonicalTaskFrame` is duration-blind above zero and is literally the paper's own
  `app:topology-r0` countermodel; it witnesses the live theorem `countermodel_dense_enriched` at
  `Completeness.lean:143` over `ℚ`. Restricting it to discrete `D` breaks the build.
- The T1 stretch goal is deferred: no topology exists anywhere in `FormalSystem/`, so the cone
  topology infrastructure is the entire cost. `finite_uniform_radius` (verified) substitutes.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` consulted for this dispatch.

### Decision Gate Resolution (settled — do not re-litigate)

The research raised decision gate `parametric-canonical-carrier`. The orchestrator adopted the
research's recommendation, **Option B**: land all non-breaking work now; add the `limit_nullity`
field only after task 415 replaces `ParametricCanonicalTaskFrame` with a deterministic-shift
carrier (`bundleFlowFrame`, `WorldState := FamIdx × D`), which discharges this task's hardest
obligation as a side effect. Option C (doing the `MCS × D` carrier change here) was rejected:
14 references to `ParametricCanonicalWorldState` plus three witness sites, duplicating 415's work
and risking two divergent refactors of the same definitions.

## Goals & Non-Goals

**Goals**:
- Re-anchor every stale `def:frame, line 1835` citation to `possible_worlds.tex:2423` (formal) /
  `908-926` (body).
- Rewrite the `TaskFrame` module and field docstrings from "we diverge, here is why it is
  harmless" to "we agree; this is the paper's official form", recording that Reflection and
  backward composition are derived and mixed-sign composition is inexpressible at the primitive
  level.
- Land two reusable, sorry-free Limit Nullity discharge helpers (succ-order and
  deterministic-shift) as standalone theorems, ahead of the field that will consume them.
- Land `TaskFrame.exists_uniform_radius_of_finite` as the substitute for the deferred T1 goal.
- Restate the `latex/subfiles/02-Semantics.tex` Task Frame definition against both the paper and
  the live tree, keeping standalone compilation green.
- Leave the `limit_nullity` field as a clean, fully specified drop-in for the moment 415 lands.

**Non-Goals**:
- No edits under `Philosophy/Papers/` (the paper is upstream and out of this repo).
- No change to `WorldHistory` / `respects_task` (unaffected — it evaluates at `d = t - s` with the
  converse handling signs).
- No validity/semantics refactor — task 414 owns that.
- No edits to `04-Metalogic.tex` or `06-Notes.tex` — task 409 owns identifier-architecture
  fidelity there.
- No cone topology, no `TopologicalSpace` instance, no formalization of `app:topology-r0`.
- No repair of `typst/chapters/02-semantics.typ:37` or `typst/SYNC-MAP.md:230` — flagged by
  research, out of scope; note them in the summary only.
- No structure-level `[Nontrivial D]` binder on `TaskFrame` itself (recorded as a follow-up).
- No `sorry`, no new axiom, no vacuous definition anywhere.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `ParametricCanonicalTaskFrame` at `ℚ`/`ℝ` cannot satisfy Limit Nullity without a carrier change | H | Certain | Resolved by gate Option B: Phase 6 is `[BLOCKED]` on 415; Phases 1-5 never touch it |
| Implementer adds the `limit_nullity` field early "to make progress", breaking the build | H | M | Phase 6 is the only phase permitted to touch the structure signature, and it is `[BLOCKED]`. Phases 1-5 add standalone theorems only |
| Deterministic-shift helper statement (Phase 3) is prose-argued in research, not machine-checked | M | M | Declared as a Scope Hypothesis; implementer must confirm or adjust hypotheses in Lean. If the general form resists, narrow it to the concrete shape the three live sites use — never `sorry` it |
| Adding `\label{def:frame}` to the subfile collides with a label in the master document | M | L | Phase 5 verifies both the standalone compile and the master `latexmk` build |
| Docstring edits cross out of the comment region and break elaboration | M | L | Phase 1 and 2 close on a full `lake build`, not a diff read-through alone |
| Task-number citations leak into deliverable files outside `specs/**` | M | M | Explicit prohibition restated in every phase that writes a deliverable; verified by grep at task close |
| Phase 6 later lands as one un-splittable atomic change | M | M | Declared `Commit Mode: atomic-batch` up front; a `/revise` pass once 415 lands may split it if the site inventory has shifted |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 6 | 3, 4 (and task 415) |

Phases within the same wave can execute in parallel. Phases 1-4 are serialized because they all
edit `FormalSystem/Semantics/TaskFrame.lean`; Phase 5 is LaTeX-only and shares no file with any
other phase.

---

### Phase 1: Re-anchor stale def:frame citations [COMPLETED]

**Goal**: Every `def:frame, line 1835` citation in the tree points at the correct live anchor.

**Tasks**:
- [x] Replace the stale anchor at `FormalSystem/Semantics/TaskFrame.lean:17`, `:68`, `:90`
- [x] Replace the stale anchor at `FormalSystem/Examples/TemporalStructures.lean:20`, `:57`
- [x] Replace the stale anchor at `docs/user-guide/architecture.md:454`
- [x] Replace the stale anchor at `docs/reference/API_REFERENCE.md:147`
- [x] Use the correct anchor: `possible_worlds.tex:2423-2451` for the formal `def:frame` (inside
      `\label{app:TaskSemantics}` at line 2415), `possible_worlds.tex:908-926` for the body
      statement with gloss at 932
- [x] Re-run the discovery grep to confirm zero remaining `line 1835` hits outside `specs/**`

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Research asserts exactly 7 stale-anchor sites across 4 files (Lean ×2,
markdown ×2). Confirm at implementation time with
`grep -rn "line 1835" --include=*.lean --include=*.md . | grep -v "^./specs/"` before editing and
again after; the after-count outside `specs/**` must be 0. If the count differs from 7, fix every
site found and record the corrected count in the summary rather than stopping at 7.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - 3 anchor citations in module and structure docstrings
- `FormalSystem/Examples/TemporalStructures.lean` - 2 anchor citations
- `docs/user-guide/architecture.md` - 1 anchor citation
- `docs/reference/API_REFERENCE.md` - 1 anchor citation

**Constraints**:
- These are deliverable files outside `specs/**`: **do not** cite any task number in them
  (repo rule `no-task-references-in-deliverables.md`). Cite the paper anchor, never "task 420".

**Verification**:
- `lake build` — green, no new warnings
- `grep -rn "line 1835" --include=*.lean --include=*.md . | grep -v "^./specs/"` returns nothing

---

### Phase 2: Recast TaskFrame docstrings from divergence to agreement [COMPLETED]

**Goal**: The module's prose states the true relationship to the paper: agreement on the
positive-cone presentation, with Reflection and backward composition derived and mixed-sign
composition inexpressible.

**Tasks**:
- [x] Rewrite the `converse` field docstring (`TaskFrame.lean:122-128` region): it is the paper's
      **definitional converse convention** packaged as a structure field
      (`w ⇒_x u := u ⇒_{-x} w` for `x < 0`), **not** a substantive temporal-symmetry axiom. State
      that the two-sided `TaskRel` plus this field is precisely the paper's *extended* relation
      over a primitive relation living on the positive cone.
- [x] Invert the `Axiomatization Notes` block (`TaskFrame.lean:93-97`). It currently claims the
      restricted form is a workaround for something "algebraically impossible". Replace with a
      statement of agreement: the paper adopts the same positive-cone presentation and calls it
      "its official form" (`possible_worlds.tex:964`), states the lax law
      `R_{s+t} ⊇ R_s ∘ R_t` there — the inclusion replaces equality, which would additionally
      assert interpolation, and is **not** adopted — and gives the same nondeterminism-collapse
      argument for why mixed-sign composition must stay inexpressible
      (`possible_worlds.tex:957-959`).
- [x] Record in the docstring that Reflection and backward composition are **derived**, matching
      the paper's derived status, and that mixed-sign composition is not prohibited but
      inexpressible at the primitive level (primitive durations are nonnegative).
- [x] Record the known gap: the paper requires `W` nonempty and `D` nontrivial; neither is
      currently enforced by the Lean structure. State it plainly rather than fixing it silently.
- [x] Add a forward-looking note that Limit Nullity is the one paper clause still absent from the
      structure, with the intended statement (see Phase 6) — as prose, **not** as a field.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - module docstring, structure docstring, `converse`
  field docstring, `Axiomatization Notes` block

**Constraints**:
- Notation (binding user decision): if any explicit converse *operation* is named, use
  `inv`/`⁻¹` vocabulary (consistent with Mathlib's `Inv`), never breve or smile. Research
  confirms no rename is forced here — the `converse` field name matches the paper's "converse
  convention" verbatim and should be kept; only its docstring is recast.
- No task-number citations in this file.
- Do **not** add or remove any structure field in this phase.

**Verification**:
- `lake build` — green
- `git diff FormalSystem/Semantics/TaskFrame.lean` shows changes confined to comment/docstring
  regions; no change to any field name, type, or the structure signature

---

### Phase 3: Add the two reusable Limit Nullity discharge helpers [NOT STARTED]

**Goal**: Both discharge strategies exist as standalone, sorry-free theorems before any field
consumes them.

**Tasks**:
- [ ] Add the succ-order helper (research-verified, transcribe as given):

      ```lean
      theorem limit_nullity_of_succOrder [SuccOrder D] [NoMaxOrder D]
          {W : Type} {R : W → D → W → Prop} (hnull : ∀ w u, R w 0 u ↔ w = u) :
          ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w := by
        intro w u h
        obtain ⟨y, hy, hR⟩ := h (Order.succ 0) (Order.lt_succ 0)
        have h1 : |y| ≤ 0 := Order.lt_succ_iff.mp hy
        have h2 : y = 0 := abs_eq_zero.mp (le_antisymm h1 (abs_nonneg y))
        subst h2
        exact ((hnull w u).mp hR).symm
      ```

- [ ] Add the deterministic-shift helper. Target statement (see Scope Hypothesis — confirm or
      adjust in Lean):

      ```lean
      theorem limit_nullity_of_shift {W : Type} (pos : W → D) {R : W → D → W → Prop}
          (hshift : ∀ w y u, R w y u → pos u = pos w + y)
          (hzero : ∀ w u, R w 0 u → u = w) :
          ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w
      ```

      Argument: `hshift` makes `y = pos u - pos w` the *same* witness for every `x`, so
      `|pos u - pos w| < x` for all `x > 0`, forcing `y = 0`; then `hzero` closes it. Both
      hypotheses are satisfiable at the three live deterministic-shift sites
      (`zTaskFrameV2` at `ReynoldsBridge.lean:453`, `multiFamTaskFrame` at `ReynoldsBridge.lean:671`,
      `multiFamTaskFrameGen` at `ChronicleMonadicBridge.lean:139`), where `hzero` is exactly the
      `mp` direction of `nullity_identity`.
- [ ] Place both in `FormalSystem/Semantics/TaskFrame.lean` under `namespace TaskFrame`, with
      docstrings citing the paper anchor and stating which frame class each discharges.
- [ ] Add a docstring note that `NoMaxOrder D` is an instance consequence of `[Nontrivial D]` on
      this repo's standard duration binders, so the existing discrete bundle in
      `SoundnessLemmas/FrameClassVariants.lean` needs no new hypotheses.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: The succ-order helper is machine-verified in research and should compile
as transcribed. The deterministic-shift helper's *general* statement above is derived from a
prose argument in research §7, **not** machine-checked — treat the exact hypothesis set as a
hypothesis. Confirm by elaborating it; if the general `pos`-indexed form resists, narrow to the
concrete shape the three live sites share and record the narrowing in the summary. Under no
circumstance introduce a `sorry` or an axiom to close either helper — if the shift helper cannot
be proved as stated, land the succ-order helper alone and report the shift helper as deferred.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - two new theorems in `namespace TaskFrame`

**Constraints**:
- Standalone theorems only. Do **not** add the `limit_nullity` structure field in this phase.
- No task-number citations in this file.
- Naming: `succOrder` names the actual hypothesis and is preferred over the task description's
  `limit_nullity_of_discrete` (`discrete` is not a class in this repo).

**Verification**:
- `lake build` — green
- `grep -n "sorry" FormalSystem/Semantics/TaskFrame.lean` returns nothing
- `#print axioms FormalSystem.Semantics.TaskFrame.limit_nullity_of_succOrder` (and the shift
  helper) shows only the three standard Lean axioms — no new axiom

---

### Phase 4: Add the finite uniform-radius theorem [NOT STARTED]

**Goal**: The substitute for the deferred T1 stretch goal lands as a machine-checked derived
result.

**Tasks**:
- [ ] Add `TaskFrame.exists_uniform_radius_of_finite` (research-verified statement):

      ```lean
      theorem exists_uniform_radius_of_finite [Nontrivial D] {W : Type} [Fintype W]
          (R : W → D → W → Prop)
          (hlim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
          (w : W) : ∃ x : D, 0 < x ∧ ∀ u y, |y| < x → R w y u → u = w
      ```

      Proof shape: for each `u ≠ w` the contrapositive of `hlim` supplies a radius `x_u`; take
      the `Finset.inf'` over the finite carrier.
- [ ] Address the `push_neg` deprecation warning research observed, so the phase closes with no
      new warnings.
- [ ] Docstring it with the mathematical reading (Limit Nullity upgrades from pointwise to a
      *uniform* positive radius per state on a finite carrier) and the consequence: a finite frame
      satisfying Limit Nullity over a dense `D` is temporally rigid, so finite/filtration frames
      cannot remain dense-polymorphic once the axiom lands.
- [ ] Add a docstring note that this is the deliberate substitute for the deferred cone-topology
      T1 result, and why (no topology exists anywhere in `FormalSystem/`; the infrastructure, not
      the one-line proof, is the cost).

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - one new theorem in `namespace TaskFrame`

**Constraints**:
- The docstring must state the consequence for finite frames **without** citing task numbers —
  refer to "the filtration and FMP frames" and "the move of FMP to `ℤ`" by name, not by task
  number.
- No `sorry`, no new axiom.

**Verification**:
- `lake build` — green, no new warnings
- `#print axioms FormalSystem.Semantics.TaskFrame.exists_uniform_radius_of_finite` — no new axiom
- `grep -n "sorry" FormalSystem/Semantics/TaskFrame.lean` returns nothing

---

### Phase 5: Restate the LaTeX Task Frame definition [NOT STARTED]

**Goal**: `latex/subfiles/02-Semantics.tex`'s frame-definition subsection matches both the paper
and the live Lean tree, and still compiles standalone.

**Tasks**:
- [ ] Rewrite the `Task Frame` definition (currently lines 25-31) to state, in order: a nonempty
      set of world states `\worldstate`; a **nontrivial** totally ordered abelian group `D`; a
      primitive task relation on the **positive cone** `D^+ = \{x \in D : x \geq 0\}`, extended to
      negative durations by the **converse convention** `w \taskto{x} u := u \taskto{-x} w` for
      `x < 0`; the two-sided cone `(w)_x = \{u : w \taskto{y} u \text{ or } u \taskto{y} w,\ 0 \leq y < x\}`.
- [ ] State the three axioms correctly: **Nullity** as an *iff* (`w \taskto{0} u` iff `w = u`),
      replacing the current one-way form; **Compositionality** as the lax positive-cone law on
      `D^+`, replacing the current unrestricted mixed-sign form; **Limit Nullity**
      `\bigcap_{x > 0} (w)_x = \{w\}`.
- [ ] Add a remark after the definition: Reflection and backward composition are **derived**;
      mixed-sign composition is not prohibited but inexpressible at the primitive level, since
      primitive durations are nonnegative.
- [ ] Correct the primitives table (lines 13-23): add a `D^+` row and correct the task relation's
      stated type to reflect the positive-cone primitive plus the extended relation.
- [ ] Update the gloss paragraph (lines 33-35) so it describes the three axioms actually stated.
- [ ] Add `\label{def:frame}` to the definition. The file currently contains zero `\label`
      commands, so nothing cross-references it and the addition is safe.
- [ ] If the restatement needs new notation (positive cone, cone `(w)_x`), either add macros to
      `latex/assets/bimodal-notation.sty` or write them inline. Available today: `\taskframe`
      (line 51), `\worldstate` (53), `\taskto` (56).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The rewrite is scoped to the subsection at lines 6-35 of a 137-line file,
with the definition environment at 25-31 and the primitives table at 13-23. Line numbers are a
plan-time hypothesis; confirm the actual extents by reading the file before editing, and keep the
diff inside the `\subsection{Task Frames}` block — the `World Histories` subsection at line 37
onward is out of scope for this phase.

**Files to modify**:
- `latex/subfiles/02-Semantics.tex` - primitives table, `Task Frame` definition, gloss
- `latex/assets/bimodal-notation.sty` - only if new macros are needed

**Constraints**:
- **Notation (binding user decision)**: any explicit converse operation is written
  `$\Rightarrow^{-1}$` (and `$R^{-1}$` for abstract relations) — **never** `$\breve{R}$` or
  `$R^{\smallsmile}$`. Note the paper itself introduces no operator symbol for the converse
  (subscript negation only), so the safest restatement introduces none either; the constraint
  binds only if a symbol is added.
- Scope boundary: `04-Metalogic.tex` and `06-Notes.tex` belong to another task — do not touch
  them.
- No task-number citations anywhere in the `.tex` or `.sty` files.
- The file has no local `\usepackage`; everything inherits from the master preamble
  (`\documentclass[../BimodalReference.tex]{subfiles}` at line 1). Do not add local package
  loads.

**Verification**:
- Standalone: `cd latex/subfiles && TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 02-Semantics.tex`
  — exits clean, produces a PDF, no undefined-control-sequence errors
- Master: `cd latex && latexmk BimodalReference.tex` (the `latexmkrc` sets `$pdf_mode = 5`
  XeLaTeX and `$out_dir = 'build'`) — green, and no duplicate-label warning for `def:frame`
- Read the rendered definition and confirm all three axioms plus the converse convention and cone
  are present

---

### Phase 6: Add the limit_nullity field and discharge all sites [BLOCKED]

**Goal**: `TaskFrame` carries the paper's fourth clause as a structure field, with every live
construction site discharging it sorry-free.

**BLOCKED ON**: task 415's `bundleFlowFrame`. `ParametricCanonicalTaskFrame`
(`Algebraic/ParametricCanonical.lean:207`) is duration-blind above zero
(`if d > 0 then ExistsTask M N`) and genuinely violates Limit Nullity over dense `D`. It witnesses
the **live** theorem `countermodel_dense_enriched` (`BXCanonical/Completeness.lean:133-160`,
`∃ (F : TaskFrame Rat) …`) feeding both `completeness` and `completeness_dense`, is the witness at
`ChronicleToCountermodelBasic.lean:839`, and is elaboration-probed at `ℝ`
(`CompletenessDedekind.lean:71`). Adding `[SuccOrder D] [NoMaxOrder D]` to the frame breaks all of
these — `ℚ` and `ℝ` have no `SuccOrder`. Task 415's planned `bundleFlowFrame`
(`WorldState := FamIdx × D`, a deterministic-shift carrier) resolves the obligation as a side
effect, and that report independently flags the parametric canonical frame as unable to survive
Omega removal.

**Do not start this phase until 415 has landed.** If tempted to proceed anyway, the correct
outcome is to leave this phase blocked — never a `sorry`, never a placeholder axiom, never a
vacuous field.

**Tasks** (specified now so the phase is a clean drop-in once unblocked):
- [ ] Add the field to the structure, two-sided form (research-verified as compiling alongside the
      existing four):

      ```lean
      limit_nullity : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
      ```

      Conclusion orientation `u = w` (not `w = u`) matches the paper's `⋂ = {w}` reading and is
      what the succ-order helper produces. The `⊇` direction of the paper's equality is `nullity`
      plus cone monotonicity and needs no field. Use `|y| < x` strict, matching the paper. Do
      **not** use the forward-only form — the two-sided form is the paper's official statement and
      is what the `app:topology-r0` proof consumes.
- [ ] Discharge Class A (holds unconditionally, 7 sites): `trivialFrame`
      (`Semantics/TaskFrame.lean:173`), `intTimeFrame` (`Examples/TemporalStructures.lean:72`),
      `genericTimeFrame` (`:151`), `zIntervalTaskFrame` (`WeakCanonical/Transfer.lean:568` — 415
      reports this as dead/deletable; coordinate), `zTaskFrameV2` (`ReynoldsBridge.lean:453`),
      `multiFamTaskFrame` (`:671`), `multiFamTaskFrameGen` (`ChronicleMonadicBridge.lean:139`).
      The first four are subsingleton-carrier (`Subsingleton.elim`); the last three use
      `limit_nullity_of_shift` from Phase 3.
- [ ] Discharge Class B: `identityFrame` (`Semantics/TaskFrame.lean:187`) needs `[Nontrivial D]`
      — verified to discharge via `exists_ne (0 : D)` plus a sign case split. Add the binder
      locally to the affected example frames; do **not** add `[Nontrivial D]` to the `TaskFrame`
      structure binders in this phase (that is a signature change touching every
      `(F : TaskFrame D)` binder in the tree — record as a separate follow-up).
- [ ] Discharge tractable Class C: restrict `natFrame` (`Semantics/TaskFrame.lean:219`) and
      `genericNatFrame` (`Examples/TemporalStructures.lean:163`) to `[SuccOrder D] [NoMaxOrder D]`
      via `limit_nullity_of_succOrder`. `intNatFrame` (`:85`) and `TaskFrameTest.customFrame`
      (`Tests/…/TaskFrameTest.lean:56`) are at `Int` and need no restriction. The `SampleableExt`
      generators at `Generators.lean:150/167` use `D := Int` throughout, so the restriction is
      transparent to the tests.
- [ ] Delete or re-carrier the `regionFrame` dense probes at `Omega.lean:387-388`. They
      instantiate `regionFrame Unit (Fin 1) ℚ` and `… ℝ`; the carrier is
      `W × (Set ι × Set ι)`, which has 4 elements at `W = Unit, ι = Fin 1` — **not** a
      subsingleton, so these two elaboration probes will genuinely fail. Research recommends
      deleting them rather than repairing.
- [ ] Restrict the filtration frames — `RefinedFilteredTaskFrame` (`FMP/Filtration.lean:197`) and
      `FiniteFilteredTaskFrame` (`FMP/FiniteModel.lean:159`), reached via `filteredFiniteFrame`
      (`FMP.lean:175`) — in coordination with task 417's move of FMP to `ℤ`. Phase 4's uniform
      radius theorem is the reason these cannot stay dense-polymorphic.
- [ ] `ParametricCanonicalTaskFrame`: consume 415's `bundleFlowFrame` (deterministic-shift
      carrier), which makes `limit_nullity` free via `limit_nullity_of_shift`. Do not perform an
      independent `MCS × D` carrier change here.
- [ ] Ignore Class D (dead): `Boneyard/ChainCompleteness/Bundle/SuccChainTaskFrame.lean:95`,
      `Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean:267` (both use the
      obsolete field name `task_rel`; nothing outside `Boneyard/` imports them and the default
      lake target roots only `FormalSystem`), and
      `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` (`benchFrame`, explicitly excluded
      at `Tests/BimodalTest.lean:75`).

**Timing**: ~3 hours (estimate only; re-plan via `/revise` once 415 lands and the site inventory
is re-confirmed)

**Depends on**: 3, 4 — and, externally, task 415

**Verification Tier**: full

**Commit Mode**: atomic-batch

Rationale for `atomic-batch`: adding a structure field is inherently atomic across all live
construction sites. No `TaskFrame.mk` occurs anywhere in the repo — every construction uses
anonymous-constructor or `where` syntax — so the compiler enumerates every missing-field site
cleanly, but the build is red from the moment the field is added until the last site is
discharged. Intermediate per-file states are expected red and MUST NOT be committed. This is why
the research's proposed 6/7/8 split is collapsed here: splitting it would leave the build red at
two phase boundaries, contradicting the every-phase-ends-green invariant.

**Scope Hypothesis**: Research asserts 18 total construction sites (16 live, 2 dead in
`Boneyard/`), classified 7 Class A / 1 Class B / 8 Class C / 2 Class D. This inventory was taken
before task 415 landed and will have shifted. Re-run the discovery greps (`: TaskFrame`,
`TaskFrame D where`, `.mk`) at implementation time and reconcile against this list before
starting; treat any newly-appeared site as in scope and any disappeared site as resolved.

**Verification**:
- `lake build` — green
- `grep -rn "sorry" FormalSystem/` shows no new occurrences relative to the pre-phase baseline
- `#print axioms` on the frames touched shows no new axiom
- `countermodel_dense_enriched`, `completeness`, and `completeness_dense` still elaborate

---

## Testing & Validation

- [ ] `lake build` green after each of Phases 1-4 (and after Phase 6, if ever unblocked)
- [ ] `grep -n "sorry" FormalSystem/Semantics/TaskFrame.lean` returns nothing
- [ ] `#print axioms` on each new theorem (`limit_nullity_of_succOrder`, `limit_nullity_of_shift`,
      `exists_uniform_radius_of_finite`) shows only the standard Lean axioms
- [ ] `grep -rn "line 1835" --include=*.lean --include=*.md . | grep -v "^./specs/"` returns
      nothing
- [ ] `cd latex/subfiles && TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 02-Semantics.tex`
      exits clean
- [ ] `cd latex && latexmk BimodalReference.tex` green with no duplicate-label warning
- [ ] No task-number citation appears in any file changed outside `specs/**`
      (`bash .claude/scripts/check-task-references.sh` if available, else grep the diff)
- [ ] `git status` shows no stray edits outside the phases' declared file sets

## Artifacts & Outputs

- `specs/420_align_task_frame_with_positive_cone_limit_nullity/plans/01_taskframe-limit-nullity-alignment.md` (this file)
- `specs/420_align_task_frame_with_positive_cone_limit_nullity/summaries/01_taskframe-limit-nullity-alignment-summary.md`
- `FormalSystem/Semantics/TaskFrame.lean` — re-anchored, docstrings recast, 3 new theorems
- `FormalSystem/Examples/TemporalStructures.lean` — re-anchored
- `docs/user-guide/architecture.md`, `docs/reference/API_REFERENCE.md` — re-anchored
- `latex/subfiles/02-Semantics.tex` — frame definition restated
- `latex/assets/bimodal-notation.sty` — new macros, only if needed

**Deferred, recorded for follow-up (do not implement here)**:
- The `limit_nullity` structure field and the 18-site discharge (Phase 6, blocked on 415)
- `[Nontrivial D]` on the `TaskFrame` structure binders rather than per-example (would remove the
  ad-hoc binders scattered through `Metalogic/`, but is a signature change touching every
  `(F : TaskFrame D)` binder)
- Enforcing the paper's nonempty-`W` requirement (pre-existing gap)
- Collapsing the six duplicated frame bodies (`intTimeFrame`/`genericTimeFrame`/
  `zIntervalTaskFrame` are byte-identical to `trivialFrame`; `intNatFrame`/`genericNatFrame`/
  `customFrame` copy `natFrame` verbatim) into thin wrappers
- The cone-topology T1 result (`app:topology-r0`)
- `typst/chapters/02-semantics.typ:37` (same stale one-way Nullity) and `typst/SYNC-MAP.md:230`
  (cites the pre-refactor range `possible_worlds.tex:902-907`) — flagged, out of scope

## Rollback/Contingency

Every phase is a small, self-contained, independently revertible commit. Phases 1, 2, and 4 are
additive or comment-only and can be reverted with `git revert` of a single commit with no
downstream effect. Phase 3 adds standalone theorems that nothing yet consumes, so reverting it is
likewise inert. Phase 5 touches only LaTeX and cannot affect `lake build`.

If Phase 3's deterministic-shift helper cannot be proved as stated, land the succ-order helper
alone and report the shift helper as deferred — do not `sorry` it and do not block the remaining
phases on it.

**Terminal state for this dispatch**: with Phases 1-5 green and committed and Phase 6 blocked, the
correct task status is `[BLOCKED]` on task 415, per the research's zero-debt statement. Marking the
task `[COMPLETED]` with Phase 6 open would misrepresent the state; introducing a `sorry` or
placeholder axiom to close Phase 6 early is explicitly forbidden.
