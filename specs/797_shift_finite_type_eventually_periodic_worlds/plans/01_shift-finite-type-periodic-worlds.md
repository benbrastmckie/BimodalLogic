# Implementation Plan: Task #797

- **Task**: 797 - Shift of finite type and eventually periodic possible worlds
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours
- **Dependencies**: None
- **Research Inputs**: specs/797_shift_finite_type_eventually_periodic_worlds/reports/01_shift-finite-type-periodic-worlds.md
- **Artifacts**: plans/01_shift-finite-type-periodic-worlds.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The cut shift-of-finite-type remark asks for three things: the SFT identification of `H_F` over
ℤ for a finite carrier, the choice-free (effective) form of the extension theorem, and a finite
prefix-plus-cycle certificate with a decidable check. The mathematical content of all three is
largely in the tree already — `FrameOver.mem_HF_iff_adjacent` is the SFT identification up to
naming, `FrameOver.extend_periodic` is the doubly-periodic extension at `[Finite W]`, and
`IntPresentation.extend_periodic` plus `PlacedBiLasso` are the certificate over a *presented*
frame. What is missing, and what this plan builds, is the named SFT packaging, a choice-free
restatement whose axiom profile is measured rather than claimed, and a certificate stated at a
bare `FrameOver` rather than at an `IntPresentation`. Definition of done: nine new or changed
declaration clusters landed, `lake build` green with no new `sorry`, and every axiom claim in a
docstring pinned by a `#guard_msgs` block in the test library.

### Research Integration

The report (`reports/01_shift-finite-type-periodic-worlds.md`) is integrated in four decisive
ways, each of which changes the plan from what the dispatch's prose alone would produce:

- **Measured choice accounting.** `FrameOver.reflection` is the single `Classical.choice` carrier
  on the `H_F`-membership path, and its choice comes from `eq_or_ne`. A compiled probe replacing
  it with `Decidable.eq_or_ne` (legitimate at `D = intOrder`, since `ℤ` has `DecidableEq`) makes
  the whole chain measure `[propext]` / `[propext, Quot.sound]`. Phase 2 is that scrub, stated as
  new declarations beside the originals rather than as an in-place edit.
- **Two forced statement shapes.** `Nat.card` carries `Classical.choice` *in the statement*, so
  the period bound must be `enum.length`; and `[Finite W]` alone supports no choice-free
  enumeration (`Fintype.ofFinite`, `Finset.toList`, `Multiset.toList` all measured
  choice-carrying), so the carrier arrives as data. The prior-cycle user decision confirms both
  shapes ship: the carrier-as-data theorem is new, and `FrameOver.extend_periodic` is left
  untouched, each docstring naming the other.
- **Reuse target fixed by measurement.** `Metalogic/Decidability/BiLasso/Periodic.lean`'s
  `Periodic.cyc` / `Periodic.unrollOf` is the carrier-generic three-segment decoding and is
  entirely choice-free; `BiLasso.unrollOf` is not, and `BiLasso/Basic.lean` is held byte-stable.
  The certificate is built on `Periodic.unrollOf` at `α := F.WorldState`. `RaySummary/Periodic.lean`
  decodes *label words*, not state paths, and is deliberately not instantiated.
- **Two stale provenance records.** Both `BiLasso/Agreement.lean`'s module docstring and
  `docs/reference/paper-definitions-of-record.md`'s "finite-case effectiveness footnote" entry
  locate the footnote in `JPL/possible_worlds.tex`, where it no longer is, and quote it as one
  run-on sentence where the cut file now has five. The record file's own rule — verbatim means
  verbatim against the record file — makes the record entry the first thing to fix.

Two plan-time deviations from the report's recommendations, both recorded in Risks below: the
report's suggestion to relocate the scratchpad probes into this task's own `evidence/` directory
is **not** adopted (`scripts/check-evidence-probes.sh` rules explicitly that a probe does not live
under a task directory, and the measurements are better pinned by an in-build guard test anyway);
and deliverables (2) and (3) land under `Metalogic/Decidability/` rather than `Semantics/`,
because no file under `FormalSystem/Semantics/` imports `FormalSystem.Metalogic` and the
choice-free pigeonhole the report tells us to reuse (`exists_dup_lt`) lives there.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch's delegation context, so no roadmap was consulted
and none is modified. One alignment note carries over from research: the dispatch attributes the
phrase "root paths of a finite class graph" to `specs/ROADMAP.md`, where it does not occur. The
docstrings therefore cite the durable anchors instead —
`specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` ("ultimately periodic (lasso)
root paths") and `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — never a task number
and never the inexact attribution.

## Goals & Non-Goals

- **Goals**: land, with measured axiom profiles, the choice-free ℤ membership chain
  (`reflection_int`, `taskRel_eq_iter_int`, `respects_of_isStepPath_int`,
  `worldHistoryOfStepPathInt`, `mem_HF_iff_adjacent_int`); the named shift-of-finite-type
  identification and its forbidden-block vocabulary (`Forbidden`, `finite_forbiddenBlocks`,
  `mem_HF_iff_no_forbidden`) together with the Mathlib dictionary half
  (`isStepPath_iff_mem_forbidden`); the choice-free effective toolkit (`succOfEnum`,
  `succOfEnum_step`, `exists_dup_of_enum`); the choice-free extension theorem
  (`extend_periodic_enum`); and the finite certificate with its decidable check and both
  directions of its correctness (`presentsWindow`, `presentsWindow_sound`,
  `presentsWindow_complete`).
- **Non-Goals**:
  - No edit to `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`, which is held
    byte-stable by an explicit ruling in that directory's README.
  - No execution of `BiLasso/Periodic.lean`'s recorded retirement trigger (refactoring
    `Basic.lean`'s decoding onto the generic one). That is a separate, wider change.
  - No change to `FrameOver.extend_periodic`, `FrameOver.reflection`, `taskRel_eq_iter`,
    `respects_of_isStepPath`, `worldHistoryOfStepPath` or `mem_HF_iff_adjacent`. Choice-free
    variants are added beside them; the originals keep their current axiom profiles, which pinned
    guard tests elsewhere in the tree may already depend on.
  - No relocation of the prior session's scratchpad probes into this task's directory (see
    Research Integration).
  - No `sorry`, and no strategic-sorry skeleton: every component has a compiled probe or an
    existing theorem behind it.
  - No entry added to `docs/project-info/FEATURE_REGISTRY.md` or
    `docs/reference/axiom-reference.md`; the axiom evidence lives in the guard-test module and the
    theorem-index rows.
  - No edit under `.claude/**`. The report's context-extension recommendation (recording the
    statement-versus-proof axiom rule in `patterns/dependency-tracing.md`) belongs to the source
    store and to a separate `/meta` task, not here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `Nat.card` creeps back into a statement and silently restores `Classical.choice` | H | M | Phase 9's guard test pins `extend_periodic_enum` and the whole Phase 2 chain; the statement-level `Nat.card` trap is pinned there too as a local probe declaration, so the trap is demonstrated in-build rather than described |
| The scrubbed reflection law reads as a pointless duplicate of `FrameOver.reflection` | M | M | Name it `reflection_int` so the specialization is visible, and state in its docstring that the sole difference is `Decidable.eq_or_ne` for `eq_or_ne`; the general `reflection` cannot take that substitution, since `D` there is an arbitrary ordered carrier with no `DecidableEq` |
| Retrofitting the choice-free chain in place would move the axiom profile of a large part of the tree | H | L | Add variants in a new module; leave the originals untouched. Before any in-place edit is even considered, audit `Tests/BimodalTest/**` for pinned axiom expectations |
| Mathlib's `SymbolicDynamics.FullShift` API is a new-module-system file whose names resolve only under the full prefix, and every declaration in it carries choice | M | M | Confine `import Mathlib.Dynamics.SymbolicDynamics.Basic` to the Phase 4 dictionary module; keep it out of every choice-free module, and measure and record the dictionary's profile in its own docstring and in the guard test |
| `Pattern` requires `[Inhabited A]`, and `F.worldNonempty` is `Prop`-level, so deriving it costs choice | M | H | Take `[Inhabited F.WorldState]` as an instance binder on the dictionary declarations and on the certificate type — supplied as data by the caller, never extracted from `Nonempty` |
| Layering: deliverable (2) cannot sit under `Semantics/` and still reuse `exists_dup_lt` | M | H (already realized) | Land deliverables (2) and (3) under `Metalogic/Decidability/` as flat modules, with the rationale in each module docstring and a cross-pointer added to `Semantics/Extension/PeriodicExtension.lean`'s docstring in Phase 10 |
| Concurrency: `docs/reference/paper-definitions-of-record.md` and `docs/theorem-index.md` are inside a sibling task's declared `file_scope` | M | M | Re-read each file immediately before editing it; stage with an explicit single-file pathspec, never a directory or glob; if a foreign uncommitted modification or foreign commit is observed, stop and report rather than proceeding |
| A new module compiles under a scoped build but is invisible to `lake build` because the generated library root was not regenerated | M | M | Every phase that adds a `.lean` file under `FormalSystem/` regenerates the root with `lake exe mk_all --lib FormalSystem` in the same phase, and Phase 10 runs `scripts/check-module-invariants.sh` (C33) over the result |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 5 | 2 |
| 3 | 4, 6 | 3, 5 |
| 4 | 7 | 6 |
| 5 | 8 | 7 |
| 6 | 9 | 4, 6, 8 |
| 7 | 10 | 1, 9 |

Phases within the same wave can execute in parallel.

### Phase 1: Repoint the Provenance Records [COMPLETED]

- **Goal:** Make the "verbatim" label on both quoting surfaces true again, against the cut file
  that now holds the remark and its footnote.
- **Tasks:**
  - [ ] Re-read `docs/reference/paper-definitions-of-record.md` immediately before editing it
    (sibling-task territory; see Risks).
  - [ ] In its "Untracked sources" section, update the "finite-case effectiveness footnote" entry:
    **Location** becomes `JPL/appendix_cut_material.tex`, under the header as it actually prints,
    `\section*{Categorical connections (cut from sub:Conclusion)}` (the footnote at the lines
    following the shift-of-finite-type sentence); record that `JPL/possible_worlds.tex` now
    retains only a `% PARAGRAPH CUT` record and that the live replacement paragraph mentions only
    the sheaf and Johnstone route.
  - [ ] Replace the run-on quote with the cut file's five sentences, verbatim, ending with the
    `See Lind and Marcus~\cite{Lind2021}.` sentence that the old quote omitted entirely.
  - [ ] Add the shift-of-finite-type sentence itself to the entry as a second quoted block: it is
    the specification deliverable (1) transcribes, and no record currently quotes it.
  - [ ] Correct **Relied on by**: the general finite-carrier theorem is
    `FormalSystem.Semantics.FrameOver.extend_periodic`, not
    `FormalSystem.Semantics.TaskFrame.extend_periodic`.
  - [ ] Re-quote `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean`'s module docstring
    against the corrected record entry: the five-sentence footnote, the corrected file reference,
    and the `Lind2021` citation. Leave "The source" section's reasoning about the missing
    `\label` as it stands — it is still correct.
  - [ ] Confirm no task number entered either file (`.claude/rules/no-task-references-in-deliverables.md`).
- **Timing:** 0.75 hours
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** exactly two files change and exactly one record entry is re-quoted; the
  implementer confirms by grepping both files for `possible_worlds.tex` after the edit and
  checking that every surviving hit is a deliberate reference to the live paper rather than a
  stale footnote location.
- **Tier Justification:** both edits are comment/prose-only, so the scoped guarded build of
  `FormalSystem.Metalogic.Decidability.BiLasso.Agreement` covers the Lean docstring edit and
  `bash .claude/scripts/check-task-references.sh` covers the record-file prose.
- **Files to modify:**
  - `docs/reference/paper-definitions-of-record.md` - repoint, re-quote and correct the
    finite-case effectiveness footnote entry
  - `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` - re-quote the module docstring
    against that entry
- **Verification:**
  - Both quoted blocks match `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`
    character for character (diff the quoted lines against a `sed -n` extraction of the source).
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.BiLasso.Agreement`
    green, run detached.
  - `bash .claude/scripts/check-task-references.sh` reports no new finding.

---

### Phase 2: The Choice-Free ℤ Membership Chain [COMPLETED]

- **Goal:** A choice-free route from adjacency to `H_F` membership at `D = intOrder`, measured
  `[propext]` / `[propext, Quot.sound]`, with the existing chain untouched.
- **Tasks:**
  - [ ] Create `FormalSystem/Semantics/IntNormalFormEffective.lean` with the standard copyright
    header and a module docstring stating: what the module is for, that the sole difference from
    `IntNormalForm.lean`'s chain is `Decidable.eq_or_ne` in place of `eq_or_ne`, and why the
    substitution is unavailable in the general `FrameOver D` setting.
  - [ ] `reflection_int` — `FrameOver.reflection_of_limit` specialized to `intOrder`, with
    `rcases Decidable.eq_or_ne d 0` replacing `rcases eq_or_ne d 0`, everything else unchanged.
  - [ ] `taskRel_eq_iter_int` — a copy of `taskRel_eq_iter` routed through `reflection_int` at both
    of its two reflection uses (the `→` branch's `hconv` and the `←` branch's final `mpr`).
  - [ ] `respects_of_isStepPath_int` — a copy of `respects_of_isStepPath` built on
    `taskRel_eq_iter_int`, reusing `iter_of_isStepPath` unchanged (already
    `[propext, Quot.sound]`).
  - [ ] `worldHistoryOfStepPathInt` — `WorldHistory.ofTotal` at `respects_of_isStepPath_int`, plus
    a `@[simp]` `path` lemma mirroring `worldHistoryOfStepPath.path`.
  - [ ] `mem_HF_iff_adjacent_int` — the biconditional, forward by `WorldHistory.isStepPath`
    (already choice-free), converse by `worldHistoryOfStepPathInt`.
  - [ ] Give each of the five a docstring naming its `FrameOver` counterpart and stating that the
    counterpart is the general one and this is the ℤ-specific choice-free one.
  - [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`.
  - [ ] Add the module's row to `FormalSystem/Semantics/README.md` and refresh that file's
    `Last verified` date.
- **Timing:** 1.5 hours
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** the chain is exactly five declarations plus one `@[simp]` path lemma; the
  implementer confirms the count is sufficient by measuring each new declaration with
  `#print axioms` and checking that none reports `Classical.choice` — a sixth declaration is
  needed only if a measurement comes back choice-carrying.
- **Tier Justification:** the phase only adds a new module and no existing signature changes, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.IntNormalFormEffective`
  covers the whole edit.
- **Files to modify:**
  - `FormalSystem/Semantics/IntNormalFormEffective.lean` - new module: the five choice-free
    declarations
  - `FormalSystem.lean` - regenerated library root
  - `FormalSystem/Semantics/README.md` - module row and `Last verified` date
- **Verification:**
  - Scoped guarded build green, run detached via `Bash(run_in_background: true)`.
  - `#print axioms` on all five: `reflection_int` reports `[propext]`; the other four report
    `[propext]` or `[propext, Quot.sound]`, and none reports `Classical.choice`.
  - `grep -c sorry` on the new file is 0.

---

### Phase 3: Deliverable (1a) — The Named Shift-of-Finite-Type Identification [COMPLETED WITH EXCLUSIONS]

- **Goal:** `H_F` over ℤ named as the bi-infinite paths of the labelled graph `(W, ⇒₁)`, presented
  as a forbidden-2-block subshift, with the "finite type" half earned by a separate finiteness
  theorem.
- **Tasks:**
  - [ ] Create `FormalSystem/Semantics/ShiftFiniteType.lean` with header and module docstring. The
    docstring quotes the shift-of-finite-type sentence from
    `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` as the
    specification (not as a theorem to cite, since it is cut from the live paper), states the
    alphabet/edge/bi-infinite-path dictionary explicitly, and distinguishes this module from
    `Semantics/ShiftSet.lean`, which is the unrelated shift-set representation theorem.
  - [ ] `Forbidden F w u := ¬ F.step w u` — the forbidden 2-block predicate, with a docstring
    naming it as the non-edges of the one-step graph.
  - [ ] `forbiddenBlocks F` — the same thing as a `Set (F.WorldState × F.WorldState)`, so the
    finiteness statement has an object to be about.
  - [ ] `finite_forbiddenBlocks` — at `[Finite F.WorldState]`, the forbidden-block set is finite.
    This is the declaration that earns the word "finite type"; state it separately rather than
    folding it into the identification.
  - [ ] `mem_HF_iff_no_forbidden` — the identification: `(∃ τ : WorldHistory F, τ.path = f)` iff
    `f` contains no forbidden 2-block. Route it through Phase 2's `mem_HF_iff_adjacent_int`, not
    through `mem_HF_iff_adjacent`, so the result is choice-free.
  - [ ] `instDecidableForbidden` — a named `Decidable (Forbidden F w u)` instance under
    `[DecidableRel F.step]`, so the block test is executable.
  - [ ] Connect the docstrings, by durable anchor only: the paper's `cor:path-fibration` `D = ℤ`
    clause (iterating *Compositionality* identifies `⇒ₙ` with the `n`-fold composite of `⇒₁`, `⇒₀`
    is the identity, so a function on `[0, l]` is a convex history exactly when it is a length-`l`
    path in `(W, ⇒₁)`, and `Path(F)` is the free category on that graph — described, not cited,
    since no `Path(F)` exists in the tree yet); and the decidability route's root-path
    presentation, citing `FormalSystem/Metalogic/Decidability/RaySummary/README.md` and
    `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`. No task numbers.
  - [ ] Note in the docstring that *Saturation* for a finite carrier is already
    `TaskFrame.saturation_of_finite`, so the finite-carrier hypothesis needs no separate frame-law
    work here.
  - [ ] Regenerate the library root; add the README row.
- **Timing:** 1.5 hours
- **Depends on:** 2
- **Verification Tier:** local
- **Tier Justification:** a new module with no existing signature touched, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ShiftFiniteType`
  covers the whole edit.
- **Files to modify:**
  - `FormalSystem/Semantics/ShiftFiniteType.lean` - new module: the bespoke SFT identification
  - `FormalSystem.lean` - regenerated library root
  - `FormalSystem/Semantics/README.md` - module row
- **Verification:**
  - Scoped guarded build green.
  - `#print axioms FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden` reports no
    `Classical.choice`.
  - `#print axioms FormalSystem.Semantics.FrameOver.finite_forbiddenBlocks` recorded (it may
    legitimately carry choice through `Set.Finite` at `[Finite W]`; whatever it reports is written
    into the docstring and into Phase 9's guard, not assumed).
  - No `sorry` in the new file.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Verification bullet "`#print axioms … mem_HF_iff_no_forbidden` reports no `Classical.choice`" | Jointly unsatisfiable with the recorded Challenge statement, which is implemented verbatim. `Forbidden F w u := ¬ F.step w u`, so `∀ n, ¬ Forbidden F (f n) (f (n+1))` is `∀ n, ¬¬ F.step (f n) (f (n+1))`, and the `←` direction is double-negation elimination at a `Prop`-valued relation carrying no `Decidable` instance. Intuitionistically underivable; the double-negation shift is not available either. The two sanctioned escapes were both rejected as weakenings: adding `[DecidableRel F.step]` to the theorem changes the recorded signature, and restating the conclusion positively is `mem_HF_iff_adjacent_int`, which already exists. Classical reasoning is in the *statement*, exactly as `Nat.card` is in the statement of `FrameOver.extend_periodic` — the plan's own Risks table names that pattern. | Measured `'FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden' depends on axioms: [propext, Classical.choice, Quot.sound]`. The substantive route is choice-free: `mem_HF_iff_adjacent_int` measures `[propext, Quot.sound]` (Phase 2) and is what Phases 6-8 consume; nothing downstream depends on this theorem's profile. Recorded in the theorem's own docstring and pinned in Phase 9. |

---

### Phase 4: Deliverable (1b) — The Mathlib Subshift Dictionary [COMPLETED]

- **Goal:** Identify the same set with Mathlib's own forbidden-pattern subshift at `G = ℤ`, as an
  explicitly choice-carrying dictionary theorem kept out of every choice-free module.
- **Tasks:**
  - [ ] Create `FormalSystem/Semantics/ShiftFiniteTypeDictionary.lean`. This is the only module in
    this task that imports `Mathlib.Dynamics.SymbolicDynamics.Basic`.
  - [ ] Module docstring: state that every declaration reachable here measures
    `[propext, Classical.choice, Quot.sound]`, with the reason (Mathlib's `Pattern.occursInAt` and
    `forbidden` both carry it), and that this is why the dictionary is a separate module from
    `ShiftFiniteType.lean`. Record that the file's own doc list advertises a
    `subshift_of_finite_type` that does not exist as a declaration, which is why the bundling is
    written here rather than imported.
  - [ ] `nonEdgePatterns F` — the forbidden patterns: those supported on `{0, 1} : Finset ℤ` whose
    two values form a forbidden block. Note in its docstring that names resolve only under the
    full `SymbolicDynamics.FullShift.` prefix.
  - [ ] `isStepPath_iff_mem_forbidden` — `IsStepPath F f` iff `f ∈ SymbolicDynamics.FullShift.forbidden (nonEdgePatterns F)`.
    The `←` direction needs, for each forbidden pair, a pattern in the set realizing it: build
    `config := fun g => if g = 0 then w else if g = 1 then u else default` and discharge
    `Pattern.condition` from `g ∉ ({0, 1} : Finset ℤ)`.
  - [ ] Take `[Inhabited F.WorldState]` as an instance binder rather than deriving it from
    `F.worldNonempty`, and say so in the docstring: the binder is data supplied by the caller, and
    extracting it from `Nonempty` would be a second, avoidable choice use.
  - [ ] Regenerate the library root; add the README row.
- **Timing:** 1.5 hours
- **Depends on:** 3
- **Verification Tier:** local
- **Tier Justification:** a new leaf module that nothing imports, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ShiftFiniteTypeDictionary`
  covers the whole edit, the new Mathlib import included.
- **Files to modify:**
  - `FormalSystem/Semantics/ShiftFiniteTypeDictionary.lean` - new module: the Mathlib dictionary
  - `FormalSystem.lean` - regenerated library root
  - `FormalSystem/Semantics/README.md` - module row
- **Verification:**
  - Scoped guarded build green.
  - `#print axioms FormalSystem.Semantics.FrameOver.isStepPath_iff_mem_forbidden` measured, and
    the measured value written verbatim into the module docstring.
  - `grep -rn "Mathlib.Dynamics.SymbolicDynamics" FormalSystem/` returns this file and nothing
    else.
  - No `sorry` in the new file.

---

### Phase 5: The Choice-Free Effective Toolkit [NOT STARTED]

- **Goal:** A computable successor and predecessor from an enumeration, and a choice-free
  pigeonhole at an enumerated carrier — the two pieces `FrameOver.extend_periodic` currently gets
  from `Classical.choose` and `exists_repeat_of_card_le`.
- **Tasks:**
  - [ ] Create `FormalSystem/Metalogic/Decidability/EffectiveOrbit.lean`. Module docstring records
    the layering reason this module is not under `Semantics/`: no file under
    `FormalSystem/Semantics/` imports `FormalSystem.Metalogic`, and the choice-free pigeonhole
    this module reuses (`exists_dup_lt`) lives under `Metalogic/Decidability/`. Duplicating it
    into `Semantics/` was considered and rejected.
  - [ ] `succOfEnum` — the first state in `enum` that the current state steps to, selected with
    `List.find?` and made total by refuting the `none` branch from `F.serial` at duration `1`
    (through `exists_iter_fwd` and `step_of_iter_one`, exactly as `FrameOver.extend_periodic` does
    for seriality) together with `henum`. Model the shape on
    `IntPresentation.succOf`, which the existing guard test already measures choice-free.
  - [ ] `succOfEnum_step` — the selection really steps.
  - [ ] `predOfEnum` / `predOfEnum_step` — the mirror, from `exists_iter_bwd`.
  - [ ] `iterSuccEnum` / `iterPredEnum` plus their `_step` lemmas — the orbits, mirroring
    `IntPresentation.iterSucc` / `iterPred`.
  - [ ] `exists_dup_of_enum` — for `g : ℕ → W` with `[DecidableEq W]`, `enum : List W`,
    `∀ w, w ∈ enum` and `enum.length < n`, there are `i < j < n` with `g i = g j`. Prove it by
    composing `List.idxOf` into `Fin enum.length` and applying `exists_dup_lt`; the round-trip
    lemma is `List.getElem_idxOf` taken with the `xs`/`x` binder names and an index bound, not a
    membership proof.
  - [ ] Each docstring states the declaration it replaces on the choice-carrying path
    (`Classical.choose` at `PeriodicExtension.lean`'s successor selection;
    `exists_repeat_of_card_le`, whose statement mentions `Nat.card` and is therefore
    choice-carrying before its proof is even read).
  - [ ] Regenerate the library root; add rows to
    `FormalSystem/Metalogic/Decidability/README.md`. Do **not** add the module to
    `FormalSystem/Metalogic/Decidability.lean`: the generated root imports every module directly,
    and the `Extend`/`Successor`/`Orbit`/`Agreement` precedent is deliberate non-aggregation.
- **Timing:** 2 hours
- **Depends on:** 2
- **Verification Tier:** local
- **Scope Hypothesis:** the toolkit is nine declarations (four selection, four orbit, one
  pigeonhole); the implementer confirms sufficiency by proving Phase 6's statement against them
  and adding a declaration only where a gap is reached, rather than guessing at the boundary now.
- **Tier Justification:** a new module with no existing signature touched, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.EffectiveOrbit`
  covers the whole edit.
- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/EffectiveOrbit.lean` - new module: the effective toolkit
  - `FormalSystem.lean` - regenerated library root
  - `FormalSystem/Metalogic/Decidability/README.md` - module row
- **Verification:**
  - Scoped guarded build green.
  - `#print axioms` on every new declaration reports no `Classical.choice`.
  - `#eval` the successor and predecessor on a concrete two-state frame, so the selection is shown
    to *run* and not merely to be choice-free (the distinction the existing
    `PeriodicExtensionAxiomTest.lean` docstring draws).
  - No `sorry` in the new file.

---

### Phase 6: Deliverable (2) — The Choice-Free Extension Theorem [NOT STARTED]

- **Goal:** A bounded convex history over a finite-state regular frame at ℤ-time extends to a
  doubly ultimately periodic possible world, with both periods bounded by `enum.length`, and with
  `#print axioms` showing no `Classical.choice`.
- **Tasks:**
  - [ ] Create `FormalSystem/Metalogic/Decidability/EffectivePeriodicExtension.lean`.
  - [ ] `extend_periodic_enum` — the carrier-as-data theorem. Binders:
    `{F : FrameOver intOrder} [F.IsRegular] [DecidableEq F.WorldState] [DecidableRel F.step]`,
    `(enum : List F.WorldState) (henum : ∀ w, w ∈ enum)`, and the window as
    `FrameOver.extend_periodic` takes it (`τ`, `a`, `b`, `hab`, `hdom`). Conclusion: a
    `WorldHistory F` extending `τ`, ultimately periodic in both directions, both periods positive
    and `≤ (enum.length : ℤ)`.
  - [ ] Mirror `FrameOver.extend_periodic`'s construction with three substitutions: `succOfEnum` /
    `predOfEnum` for the two `Classical.choose` selections; `exists_dup_of_enum` for
    `exists_repeat_of_card_le`; and `worldHistoryOfStepPathInt` for `worldHistoryOfStepPath` at
    the final step.
  - [ ] **Avoid `classical` entirely.** Two specific traps: do not open with `classical` (it
    installs `Classical.dec` and contaminates the profile), and do not case on `τ.domain t`, which
    has no `Decidable` instance. Instead rewrite the domain through `hdom` to `a ≤ t ∧ t ≤ b`,
    which is decidable over ℤ, and use the window's own left endpoint value
    (`τ.states a` via `hdom` and `hab`) as the off-window filler in place of `default` — the
    `Inhabited` instance `FrameOver.extend_periodic` obtains from `Classical.inhabited_of_nonempty`
    is itself a choice use and must not be reproduced.
  - [ ] Keep the window segment lists reachable as data (`windowBack` / `windowMid` / `windowFwd`
    analogues over `F.WorldState`), stated so Phase 8 can build a certificate from the same
    construction rather than re-deriving it.
  - [ ] Docstrings: name `FrameOver.extend_periodic` as the `[Finite W]` version the paper's
    hypothesis literally supports, state that it is left untouched and why it is choice-carrying
    for a measured reason (`Nat.card` in its statement, `Classical.choose` for the successor), and
    state that no bridge between the two is attempted —
    `Semantics/Extension/PeriodicExtension.lean`'s docstring already explains why none exists, and
    the `Fintype.ofFinite` / `Finset.toList` measurements confirm it. Quote the cut footnote's
    "without appeal to Zorn's lemma" sentence and preserve the existing distinction: no Zorn is an
    import-graph fact, choice-freedom is a separate and stronger claim, and here both hold.
  - [ ] Regenerate the library root; add the README row.
- **Timing:** 2 hours
- **Depends on:** 5
- **Verification Tier:** local
- **Tier Justification:** a new module with no existing signature touched, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.EffectivePeriodicExtension`
  covers the whole edit.
- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/EffectivePeriodicExtension.lean` - new module:
    `extend_periodic_enum` and the window segment data
  - `FormalSystem.lean` - regenerated library root
  - `FormalSystem/Metalogic/Decidability/README.md` - module row
- **Verification:**
  - Scoped guarded build green.
  - `#print axioms FormalSystem.Metalogic.Decidability.extend_periodic_enum` reports no
    `Classical.choice`; if it does report it, the phase is not complete, and the offending
    dependency is located with a per-declaration `#print axioms` sweep over the new module before
    anything else is attempted.
  - `grep -n "Nat.card\|classical\|Classical" ` on the new file returns only docstring prose.
  - No `sorry` in the new file.

---

### Phase 7: Deliverable (3a) — The Certificate Type, Its Decidable Check, and Soundness [NOT STARTED]

- **Goal:** A finite prefix-plus-cycle-each-way certificate at a bare `FrameOver`, a `Bool`-valued
  check that it presents a possible world through a given bounded window, and the soundness of
  that check.
- **Tasks:**
  - [ ] Create `FormalSystem/Metalogic/Decidability/FrameLassoCertificate.lean`, built on
    `Periodic.unrollOf` at `α := F.WorldState` — **never** on `BiLasso.unrollOf`, which is
    choice-carrying and lives in a module held byte-stable.
  - [ ] `FrameLasso F` — the structure: `back`, `mid`, `fwd` as `List F.WorldState`, `origin : ℤ`,
    and the two non-emptiness fields `back_ne` / `fwd_ne`. Coherence is deliberately **not** a
    field here: the dispatch asks for a decidable check that the certificate presents a world, so
    the type is bare data and the check carries the coherence obligation. Record that departure
    from `BiLasso`'s shape, and the reason, in the structure's docstring.
  - [ ] `unroll` (in the `FrameLasso` namespace) — `Periodic.unrollOf` at the structure's own
    fields, shifted by `origin`; plus the two periodicity lemmas as corollaries of
    `Periodic.unrollOf_sub_back_length` and `Periodic.unrollOf_add_fwd_length`.
  - [ ] `presentsWindow` — the `Bool`-valued check, under
    `[Inhabited F.WorldState] [DecidableEq F.WorldState] [DecidableRel F.step]`: the conjunction of
    (a) adjacency across one full window `[-|back|-1, |mid|+|fwd|)` indexed over a `Fin`, decided
    through `DecidableRel F.step`, and (b) pointwise agreement with the given window list placed at
    a given absolute time, decided through `DecidableEq F.WorldState`.
  - [ ] Promote `Agreement.lean`'s decidability `example` to a named instance here rather than
    leaving the claim as an `example`; `Agreement.lean` itself is not edited for this (its Phase 1
    docstring re-quote is its only change in this task).
  - [ ] `presentsWindow_sound` — a `true` check yields a `WorldHistory F` whose path is the
    certificate's decoding, agrees with the window pointwise, and is ultimately periodic in both
    directions with periods `|back|` and `|fwd|`. Route the `H_F` conclusion through Phase 2's
    `worldHistoryOfStepPathInt`, so soundness is choice-free.
  - [ ] Module docstring: carry forward, by reference rather than by restatement,
    `Agreement.lean`'s three limits (box truth is a property of the model, not of a history;
    `Past` / `Future` do not transfer off the window; path periodicity is not truth periodicity),
    and state in one sentence that this certificate licenses an existential claim about the window
    found and nothing about universal obligations.
  - [ ] Regenerate the library root; add the README row.
- **Timing:** 2 hours
- **Depends on:** 6
- **Verification Tier:** local
- **Tier Justification:** a new module with no existing signature touched, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.FrameLassoCertificate`
  covers the whole edit.
- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/FrameLassoCertificate.lean` - new module: `FrameLasso`,
    `presentsWindow`, the named decidability instance, `presentsWindow_sound`
  - `FormalSystem.lean` - regenerated library root
  - `FormalSystem/Metalogic/Decidability/README.md` - module row
- **Verification:**
  - Scoped guarded build green.
  - `#print axioms` on `presentsWindow` and `presentsWindow_sound` reports no `Classical.choice`.
  - `#eval presentsWindow` on a concrete two-state certificate returns `true`, and on a
    deliberately incoherent one returns `false`, both pinned with `#guard`.
  - `grep -n "BiLasso.unrollOf" ` on the new file is empty.
  - No `sorry` in the new file.

---

### Phase 8: Deliverable (3b) — Completeness of the Check Against the Extension Theorem [NOT STARTED]

- **Goal:** Every bounded convex history over an enumerated carrier is presented by some
  certificate whose check returns `true`, with segment lengths bounded by `enum.length`.
- **Tasks:**
  - [ ] `presentsWindow_complete` — from Phase 6's construction: given `enum`, `henum`, an
    absolute time and a non-empty adjacent window list, produce `L : FrameLasso F` with
    `presentsWindow L a win = true`, `L.back.length ≤ enum.length` and
    `L.fwd.length ≤ enum.length`.
  - [ ] Build `L` from Phase 6's window segment data rather than re-running the orbit argument;
    if a gap appears between the segment data's shape and `FrameLasso`'s fields, close it with a
    named conversion lemma in this module rather than by changing Phase 6's statement.
  - [ ] Discharge the check's coherence half from the adjacency facts the segments already carry,
    and its agreement half from the construction's own fidelity on `[a, b]`.
  - [ ] Docstring: state the pairing explicitly — `presentsWindow_sound` and
    `presentsWindow_complete` are the two directions of the same claim, and together they say the
    decidable check is exactly the predicate "this certificate presents a possible world through
    this bounded history". Name `IntPresentation.extend_periodic_extends` as the presented-frame
    counterpart and state the difference (that one is stated at an `IntPresentation` and is
    choice-carrying; this one is at a bare `FrameOver` with its carrier as data, and is not).
- **Timing:** 1.5 hours
- **Depends on:** 7
- **Verification Tier:** local
- **Tier Justification:** the phase adds declarations to one module and changes no existing
  signature, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.FrameLassoCertificate`
  covers the whole edit.
- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/FrameLassoCertificate.lean` - add
    `presentsWindow_complete` and any named conversion lemma it needs
- **Verification:**
  - Scoped guarded build green.
  - `#print axioms FormalSystem.Metalogic.Decidability.presentsWindow_complete` reports no
    `Classical.choice`.
  - No `sorry` in the file.

---

### Phase 9: The Axiom-Profile Guard Test [NOT STARTED]

- **Goal:** Every axiom claim this task's docstrings make is pinned in-build, so the claims cannot
  silently rot.
- **Tasks:**
  - [ ] Create `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean`, modelled on
    the existing `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`, including its
    claim-to-guard table and its "when one of these guards fires" instruction (update the expected
    block in the same commit as the change that moved it, never on its own to turn a red build
    green).
  - [ ] `#guard_msgs` + `#print axioms` for the Phase 2 chain (five declarations), the Phase 3
    identification and its finiteness theorem, the Phase 5 toolkit, `extend_periodic_enum`,
    `presentsWindow`, `presentsWindow_sound` and `presentsWindow_complete`.
  - [ ] One guard for the Phase 4 dictionary theorem, recording its choice-carrying profile as the
    measurement it is — deliberately not a defect, exactly as `PeriodicExtensionAxiomTest.lean`
    records its own last row.
  - [ ] Pin the statement-versus-proof trap in-build: a local one-line probe declaration whose
    *type* mentions `Nat.card` and whose proof is `rfl`, guarded to show
    `[propext, Classical.choice, Quot.sound]`, with a comment naming it as the reason
    `extend_periodic_enum`'s bound is `enum.length`.
  - [ ] `#eval` / `#guard` blocks running the successor selection and the check on a concrete
    frame, so choice-freedom of the proofs is accompanied by evidence that the definitions
    compute.
  - [ ] Add `import BimodalTest.Metalogic.EffectivePeriodicExtensionAxiomTest` to
    `Tests/BimodalTest.lean` (hand-maintained aggregator).
- **Timing:** 1 hour
- **Depends on:** 4, 6, 8
- **Verification Tier:** local
- **Scope Hypothesis:** roughly 18 guard blocks are needed, one per declaration this task
  introduces plus the `Nat.card` probe; the implementer confirms the exact set by enumerating the
  new declarations with `grep -n "^theorem\|^def\|^instance\|^structure"` over the five new
  modules and guarding each one, rather than working to the estimate.
- **Tier Justification:** the phase adds one test module and one aggregator import, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest.Metalogic.EffectivePeriodicExtensionAxiomTest`
  covers the whole edit.
- **Files to modify:**
  - `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean` - new guard-test module
  - `Tests/BimodalTest.lean` - aggregator import
  - `Tests/BimodalTest/Metalogic/README.md` - module row, if that directory carries one
- **Verification:**
  - Scoped guarded build of the test module green, every `#guard_msgs` satisfied.
  - Every measured value written into a docstring in Phases 2-8 appears verbatim in a guard block
    here; a disagreement is resolved by re-measuring, never by editing the guard to match the
    prose.

---

### Phase 10: Documentation, Index Rows, and the Full Gate Sweep [NOT STARTED]

- **Goal:** The new results are discoverable from the repository's own ledgers, and the whole
  repository is green.
- **Tasks:**
  - [ ] Add a cross-pointer to `FormalSystem/Semantics/Extension/PeriodicExtension.lean`'s module
    docstring: the choice-free carrier-as-data counterpart now exists, where it lives, why it is
    not a corollary, and that this module's own theorem is unchanged.
  - [ ] Re-read `docs/theorem-index.md` immediately before editing it (sibling-task territory),
    then add rows for `mem_HF_iff_no_forbidden`, `extend_periodic_enum`, `presentsWindow_sound`
    and `presentsWindow_complete`, with fully qualified Lean names, paths without line numbers,
    and the Axioms column written out literally (the measured value) plus a pointer to the Phase 9
    guard module — not a `pinned:C2` token, since these are not C2 baseline rows.
  - [ ] Confirm `FormalSystem/Semantics/README.md` and
    `FormalSystem/Metalogic/Decidability/README.md` carry a row for each new module and a current
    `Last verified` date.
  - [ ] Confirm the generated library root is byte-current for the whole task:
    `lake exe mk_all --lib FormalSystem` leaves no diff.
  - [ ] Sweep for prohibited content in every file this task touched outside `specs/**`: no task
    numbers, no `specs/`-path citations carrying a task number, no draft-history or
    version-supersession language.
  - [ ] Run the complete gate set (below) and record the outcomes.
- **Timing:** 1.5 hours
- **Depends on:** 1, 9
- **Verification Tier:** full
- **Scope Hypothesis:** four theorem-index rows, three README surfaces and one docstring
  cross-pointer; the implementer confirms the row set by checking that every declaration named
  under this plan's Goals either has a row or is a supporting declaration whose principal result
  does, and adds a row wherever that check fails.
- **Files to modify:**
  - `FormalSystem/Semantics/Extension/PeriodicExtension.lean` - docstring cross-pointer only
  - `docs/theorem-index.md` - rows for the four principal new results
  - `FormalSystem/Semantics/README.md` - row and date audit
  - `FormalSystem/Metalogic/Decidability/README.md` - row and date audit
  - `FormalSystem.lean` - regenerated library root, if any phase left it stale
- **Verification:** the complete gate set, every item run and observed green in this dispatch,
  never trusted on sight:
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project),
    detached.
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`
    (test library, so every `#guard_msgs` in Phase 9 runs), detached.
  - `bash scripts/check-module-invariants.sh` — C33 (library root byte-current), C6
    (no unmanifested unreachable module), and the rest of the battery.
  - `lake exe checkInitImports` — every new module transitively imports `FormalSystem.Init`.
  - `bash scripts/check-copyright-headers.sh` — headers on all five new library modules and the
    new test module.
  - `bash scripts/readme-lint.sh` — README presence and reference health.
  - `bash scripts/check-metalogic-cycles.sh` — no import cycle introduced under `Metalogic/`.
  - `bash scripts/check-evidence-probes.sh` — the tracked probe collection still compiles (this
    task adds no probe, but it changes declarations probes may cite).
  - `bash .claude/scripts/check-task-references.sh` — no task number outside `specs/**`.
  - `grep -rn "sorry" ` over the five new library modules and the new test module returns nothing
    outside a docstring.

---

## Lean Challenge Statements

```lean
import Mathlib.Dynamics.SymbolicDynamics.Basic
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.Periodicity
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic

namespace FormalSystem.Semantics.FrameOver

open FormalSystem.Semantics

/-- Choice-free reflection at `intOrder`: `Decidable.eq_or_ne` for `eq_or_ne`. -/
theorem reflection_int (F : FrameOver intOrder) [F.IsRegular] (w : F.WorldState) (d : ℤ)
    (u : F.WorldState) : F.TaskRel w d u ↔ F.TaskRel u (-d) w := sorry

/-- The decomposition theorem, choice-free at `intOrder`. -/
theorem taskRel_eq_iter_int (F : FrameOver intOrder) [F.IsRegular] (w u : F.WorldState) (d : ℤ) :
    F.TaskRel w d u ↔
      (0 ≤ d → iter F.step d.natAbs w u) ∧ (d ≤ 0 → iter F.step d.natAbs u w) := sorry

/-- All-pairs task-respect from adjacency, choice-free. -/
theorem respects_of_isStepPath_int {F : FrameOver intOrder} [F.IsRegular]
    {f : ℤ → F.WorldState} (h : IsStepPath F f) (s t : ℤ) :
    F.TaskRel (f s) (t - s) (f t) := sorry

/-- The possible world determined by a bi-infinite step-path, choice-free. -/
def worldHistoryOfStepPathInt (F : FrameOver intOrder) [F.IsRegular]
    (f : ℤ → F.WorldState) (h : IsStepPath F f) : WorldHistory F := sorry

/-- `H_F` over ℤ is exactly the bi-infinite step-paths, choice-free. -/
theorem mem_HF_iff_adjacent_int (F : FrameOver intOrder) [F.IsRegular] (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ IsStepPath F f := sorry

/-- A forbidden 2-block: a non-edge of the one-step graph `(W, step)`. -/
def Forbidden (F : FrameOver intOrder) (w u : F.WorldState) : Prop := sorry

/-- The forbidden-block set is finite — the half of "shift of finite type" that must be earned. -/
theorem finite_forbiddenBlocks (F : FrameOver intOrder) [Finite F.WorldState] :
    {b : F.WorldState × F.WorldState | Forbidden F b.1 b.2}.Finite := sorry

/-- **The shift-of-finite-type identification.** Over a finite carrier at ℤ-time, the possible
worlds are exactly the bi-infinite paths of `(W, step)`, presented as the configurations avoiding
every forbidden 2-block. -/
theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular] [Finite F.WorldState]
    (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ ∀ n : ℤ, ¬ Forbidden F (f n) (f (n + 1)) := sorry

/-- The dictionary half, against Mathlib's forbidden-pattern subshift at `G = ℤ`. Choice-carrying
by construction: every `SymbolicDynamics.FullShift` declaration it names carries
`Classical.choice`. -/
theorem isStepPath_iff_mem_forbidden (F : FrameOver intOrder) [Inhabited F.WorldState]
    (f : ℤ → F.WorldState) :
    IsStepPath F f ↔
      f ∈ SymbolicDynamics.FullShift.forbidden
        {p : SymbolicDynamics.FullShift.Pattern F.WorldState ℤ |
          p.support = {0, 1} ∧ Forbidden F (p.config 0) (p.config 1)} := sorry

end FormalSystem.Semantics.FrameOver

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Semantics

/-- The computable one-step successor: the first state of `enum` the current state steps to. -/
def succOfEnum (F : FrameOver intOrder) [F.IsRegular] [DecidableRel F.step]
    (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    F.WorldState := sorry

/-- The chosen successor really is a successor. -/
theorem succOfEnum_step (F : FrameOver intOrder) [F.IsRegular] [DecidableRel F.step]
    (enum : List F.WorldState) (henum : ∀ w, w ∈ enum) (w : F.WorldState) :
    F.step w (succOfEnum F enum henum w) := sorry

/-- Choice-free pigeonhole at an enumerated carrier, replacing `exists_repeat_of_card_le`, whose
statement mentions `Nat.card` and is therefore choice-carrying before its proof is read. -/
theorem exists_dup_of_enum {W : Type} [DecidableEq W] (enum : List W) (henum : ∀ w, w ∈ enum)
    (n : ℕ) (hn : enum.length < n) (g : ℕ → W) :
    ∃ i j, i < j ∧ j < n ∧ g i = g j := sorry

/-- **The choice-free extension theorem.** A bounded convex history over a frame whose carrier
arrives as data extends to a possible world ultimately periodic in both directions, with both
periods bounded by the enumeration's length. The `[Finite W]` counterpart,
`FormalSystem.Semantics.FrameOver.extend_periodic`, is left exactly as it is. -/
theorem extend_periodic_enum {F : FrameOver intOrder} [F.IsRegular]
    [DecidableEq F.WorldState] [DecidableRel F.step]
    (enum : List F.WorldState) (henum : ∀ w, w ∈ enum)
    (τ : PartialHistory F.toTaskFrame) (a b : ℤ) (hab : a ≤ b)
    (hdom : ∀ t : ℤ, τ.domain t ↔ a ≤ t ∧ t ≤ b) :
    ∃ σ : WorldHistory F, PartialHistory.Extends σ.val τ ∧
      ∃ n₀ p₀ n₁ p₁ : ℤ, 0 < p₀ ∧ 0 < p₁ ∧
        p₀ ≤ (enum.length : ℤ) ∧ p₁ ≤ (enum.length : ℤ) ∧
        (∀ x : ℤ, n₁ ≤ x → σ.path (x + p₁) = σ.path x) ∧
        (∀ x : ℤ, x ≤ n₀ → σ.path (x - p₀) = σ.path x) := sorry

/-- The finite certificate: a prefix plus a cycle each way, placed at an absolute time. Coherence
is deliberately not a field — the decidable check below carries that obligation. -/
structure FrameLasso (F : FrameOver intOrder) [Inhabited F.WorldState] where
  /-- The leftward cycle, indexed left-to-right in time. -/
  back : List F.WorldState
  /-- The finite window. May be empty. -/
  mid : List F.WorldState
  /-- The rightward cycle, indexed left-to-right in time. -/
  fwd : List F.WorldState
  /-- The absolute time at which the window begins. -/
  origin : ℤ
  /-- The leftward cycle is non-empty. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty. -/
  fwd_ne : fwd ≠ []

/-- The decidable check: this certificate is a genuine walk in `(W, step)` and agrees with the
given bounded window where that window lives. -/
def presentsWindow {F : FrameOver intOrder} [Inhabited F.WorldState] [DecidableEq F.WorldState]
    [DecidableRel F.step] (L : FrameLasso F) (a : ℤ) (win : List F.WorldState) : Bool := sorry

/-- **Soundness.** A certificate passing the check decodes to a possible world that agrees with
the window and is ultimately periodic in both directions. -/
theorem presentsWindow_sound {F : FrameOver intOrder} [F.IsRegular] [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step]
    (L : FrameLasso F) (a : ℤ) (win : List F.WorldState)
    (h : presentsWindow L a win = true) :
    ∃ σ : WorldHistory F,
      (∀ t : ℤ, σ.path t = Periodic.unrollOf L.back L.mid L.fwd (t - L.origin)) ∧
      (∀ k : ℕ, k < win.length → σ.path (a + (k : ℤ)) = win.getD k default) ∧
      (∀ t : ℤ, t < L.origin → σ.path (t - (L.back.length : ℤ)) = σ.path t) ∧
      (∀ t : ℤ, L.origin + (L.mid.length : ℤ) ≤ t →
        σ.path (t + (L.fwd.length : ℤ)) = σ.path t) := sorry

/-- **Completeness against the extension theorem.** Every bounded adjacent window over an
enumerated carrier is presented by some certificate whose segments are bounded by the
enumeration's length. -/
theorem presentsWindow_complete {F : FrameOver intOrder} [F.IsRegular] [Inhabited F.WorldState]
    [DecidableEq F.WorldState] [DecidableRel F.step]
    (enum : List F.WorldState) (henum : ∀ w, w ∈ enum)
    (a : ℤ) (win : List F.WorldState) (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      F.step (win.getD k default) (win.getD (k + 1) default)) :
    ∃ L : FrameLasso F, presentsWindow L a win = true ∧
      L.back.length ≤ enum.length ∧ L.fwd.length ≤ enum.length := sorry

end FormalSystem.Metalogic.Decidability
```

## Testing & Validation

- [ ] `lake build` (full project, guarded and detached) green, with no new warning beyond the
  `warning-budget.txt` allowance.
- [ ] `lake build BimodalTest` green, so every `#guard_msgs` block in the new guard-test module
  actually runs.
- [ ] No `sorry` introduced anywhere: `grep -rn "sorry" ` over the five new library modules and
  the new test module returns nothing outside docstring prose.
- [ ] `#print axioms` on the Phase 2 chain, the Phase 3 identification, the Phase 5 toolkit,
  `extend_periodic_enum`, `presentsWindow`, `presentsWindow_sound` and `presentsWindow_complete`
  reports no `Classical.choice`, each value pinned by a guard block.
- [ ] `#print axioms` on the Phase 4 dictionary theorem reports its choice-carrying value, pinned
  as a measurement rather than silently accepted.
- [ ] The `Nat.card`-in-the-statement trap is demonstrated in-build by a local probe declaration
  with a `#guard_msgs` block.
- [ ] `#eval` / `#guard` blocks show the successor selection and the certificate check compute on
  a concrete frame.
- [ ] `scripts/check-module-invariants.sh`, `lake exe checkInitImports`,
  `scripts/check-copyright-headers.sh`, `scripts/readme-lint.sh`,
  `scripts/check-metalogic-cycles.sh` and `scripts/check-evidence-probes.sh` all green.
- [ ] `.claude/scripts/check-task-references.sh` green: no task number in any file outside
  `specs/**`.
- [ ] Both provenance quotes match the cut file character for character.

## Artifacts & Outputs

- `FormalSystem/Semantics/IntNormalFormEffective.lean` — the choice-free ℤ membership chain
- `FormalSystem/Semantics/ShiftFiniteType.lean` — the named shift-of-finite-type identification
- `FormalSystem/Semantics/ShiftFiniteTypeDictionary.lean` — the Mathlib subshift dictionary
- `FormalSystem/Metalogic/Decidability/EffectiveOrbit.lean` — the choice-free effective toolkit
- `FormalSystem/Metalogic/Decidability/EffectivePeriodicExtension.lean` — `extend_periodic_enum`
- `FormalSystem/Metalogic/Decidability/FrameLassoCertificate.lean` — the certificate, its
  decidable check, soundness and completeness
- `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean` — the axiom-profile
  guards
- Updated: `FormalSystem.lean`, `Tests/BimodalTest.lean`, `FormalSystem/Semantics/README.md`,
  `FormalSystem/Metalogic/Decidability/README.md`,
  `FormalSystem/Semantics/Extension/PeriodicExtension.lean` (docstring pointer),
  `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` (docstring re-quote),
  `docs/reference/paper-definitions-of-record.md`, `docs/theorem-index.md`
- `specs/797_shift_finite_type_eventually_periodic_worlds/summaries/01_shift-finite-type-periodic-worlds-summary.md`

## Rollback/Contingency

Every phase is additive: five new library modules, one new test module, and docstring or ledger
edits to seven existing files. Nothing existing is re-signed, so a landed phase is reverted with
`git revert` of that phase's commit followed by `lake exe mk_all --lib FormalSystem` to restore
the generated root.

For a rollback that would discard *uncommitted* work, take the snapshot first and then roll back —
see `context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
out-of-scope override flag for a deliberate whole-tree revert. Do not emit the default
(reverting) snapshot form as a routine start-of-phase checkpoint; a defensive checkpoint before
risky proof work uses the non-reverting form instead.

Phase-specific contingencies:

- **Phase 4** (the Mathlib dictionary) is the one phase whose feasibility rests on an external
  API rather than on a compiled in-tree probe. If the `Pattern` / `forbidden` instantiation at
  `G = ℤ` proves intractable, close the phase as `[COMPLETED WITH EXCLUSIONS]` with a
  `#### Reasoned Exclusions` record whose Evidence column cites the specific elaboration failure,
  and keep the bespoke identification of Phase 3 as deliverable (1) in full — it is the
  choice-free half and the one the dispatch actually asks for. Phase 9's dictionary guard is
  dropped in the same move, and the drop recorded there.
- **Phase 6** is the only phase with genuinely new proof work at risk. If a measurement comes
  back choice-carrying, do not weaken the statement to make it pass and do not reach for
  `classical`: locate the carrier with a per-declaration `#print axioms` sweep, and if the carrier
  is outside this task's reach, mark the phase `[BLOCKED]` with the measurement recorded, rather
  than landing a theorem whose docstring claims more than the guard can pin.
