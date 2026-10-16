# Implementation Plan: Task #802

- **Task**: 802 - Derive every TM-system theorem the paper cites, cite the derivations rather than derivability, and prune the superseded derivability results.
- **Status**: [COMPLETED]
- **Effort**: 16.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/802_derive_cited_tm_theorems_and_cite_derivations/reports/01_derive-cited-tm-theorems.md
- **Artifacts**: plans/01_derive-cited-tm-theorems.md (this file), summaries/01_derive-cited-tm-theorems-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The audit is already done and its verdict is narrow: Z1 is the only paper-cited schema that
reaches the tree through a completeness engine, and DN carries one removable engine cross-check
beside its direct derivation. So the task is not an audit-and-sweep; it is one new derivation
(Z1, from UZ and US at `FrameClass.ZTime`), four named past mirrors that derivation factors
through, a two-stage prune of `Metalogic/CompletenessDerived.lean` down to nothing, and a prose
tail across roughly two dozen surfaces. One precursor phase sits in front of all of it: the
deduction theorem's gratuitous `Classical.propDecidable` instances, whose removal is the single
thing standing between four existing derivations (DF, CO, the discreteness witness, P5/P6) and
the computability the proof extractor requires. Definition of done: Z1 has a direct, computable
`DerivationTree` from the axioms; `CompletenessDerived.lean` no longer exists; no surface in the
tree still describes Z1 or DN as recovered through an engine; `docs/theorem-index.md` carries a
row for every paper-cited schema; the full gate battery is green except the one pre-existing
failure named in Risks; and the per-schema table of item (5) is reported.

### Research Integration

The report (`reports/01_derive-cited-tm-theorems.md`) changes this plan from what the dispatch
prose alone would produce, in six decisive ways:

- **Item (5)'s acceptance criterion is rewritten, not inherited.** "`#print axioms` showing
  `propext` at most for the derivations" is a criterion the tree fails *today* for `dfSchema`,
  `succIndicator` and `coDerived` — all three are direct derivation trees that nonetheless
  measure `[propext, Classical.choice, Quot.sound]`, the same profile as the engine-routed
  `z1Thm`. The axiom profile therefore cannot discriminate a direct derivation from an
  engine-routed one in this tree, and the criterion is replaced throughout this plan by: zero
  `sorryAx`; no completeness engine in the dependency closure, asserted by the Shape 1 `def`-
  closure probe together with a source reading; and the measured axiom profile recorded per
  declaration as a fact rather than asserted as a bound. The substitution is stated in Phase 11's
  report obligation and in Non-Goals.
- **The two acceptance criteria of item (2) collapse into one root cause, and the repair is
  probe-verified.** `Metalogic.Core.deductionTheorem` is `noncomputable` solely because
  `DeductionTheorem.lean` installs `Classical.propDecidable` in five places, even though
  `Formula` derives `DecidableEq`. The report ran the repair (five `inferInstance` substitutions,
  both `noncomputable` markers dropped), got a green scoped build and `isNoncomputable = false`.
  That becomes Phase 1, because without it Z1 cannot be computable and cannot get a proof-
  extractor entry — which the dispatch names as a goal of item (2).
- **Z1's placement and shape are fixed.** `FormalSystem/Theorems/DiscreteUnfolding.lean`,
  `.ZTime`-pinned, with the frame-class-gated companion obtained in one line by
  `DerivationTree.lift` (`FormalSystem/ProofSystem/Derivation.lean`). Not a new module, not
  `Metalogic/`. The gated-vs-pinned worry the dispatch raises is a non-problem: `lift` is
  computable and structural, and `Combinators.baseThm` and `DiscreteUnfolding.succIndicatorAt`
  are the two existing instances of exactly this pattern.
- **The item-(4) expansion is identified concretely, not left open.** It is the four past mirrors
  the Z1 route factors through — `prevIndicator`, `prevConj`, the backward `snce` unfolding, and
  `snceBotFalse` — each built by the `prevAllPast` recipe (`DerivationTree.time_reflection` plus
  one `reflect_time_*_eq` normalization lemma proved by a single `simp only`). These are Phase 3,
  and they come before Z1 so that the unverified Z1 sketch is attempted against named, compiled
  helpers rather than four simultaneous unknowns.
- **The prune inventory the dispatch gives is incomplete and this plan uses the corrected one.**
  Added: a second term-level shape pin in `Metalogic/Independence/ArchimedeanSharpness.lean`;
  eight further in-tree prose surfaces (`Metalogic/Conservativity.lean`,
  `Independence/StaticFrame.lean`, `MinusLanguage/Axioms.lean`, `ProofSystem.lean`,
  `Semantics/FrameClassValidity.lean`, `Semantics/FrameProperty.lean`,
  `BimodalTools/AxiomNames.lean`); four Z1 spots in `Metalogic/Independence/README.md`. Both
  must-not-prune claims are verified and both lemmas stay.
- **P5 and P6 were missed by the first pass and need no derivation.** The paper presents them as
  derived in `sub:Logic` ("Given P4, we may derive the following") with no `\leanfoot`; both
  already exist (`Perpetuity.perpetuity5` at `Theorems/Perpetuity/Principles.lean`,
  `perpetuity6` at `Theorems/Perpetuity/MonotonicityDuality.lean`). They need index rows only —
  part of a roughly twelve-row coverage gap in `docs/theorem-index.md`, which today has no row
  for DF, CO, TK, T4, TF, P1–P6 or the discreteness witness.

One plan-time judgment call against a research recommendation, recorded here rather than
deferred: recommendation 7 asks that `typst/FormalFoundations.typ`'s "TM_z adds UZ and Z1" prose
be raised as a scope question. This plan resolves it as **out of scope** and reports it as a
finding. That file carries no engine-recovery prose at all — a grep for the recovery phrasing
hits `typst/chapters/03-proof-theory.typ` and not `FormalFoundations.typ` — so its four stale
spots present Z1 as an *axiom* of TM_z, which is demotion-wave fallout from the minimal-axiom-set
reduction, not a derivability-route citation. The dispatch's Non-Goals bar changes to the axiom
set; fixing an axiom-list presentation is that kind of change, and it belongs to its own task.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch's delegation context, so no roadmap was consulted
and `specs/ROADMAP.md` is neither read as a constraint nor modified.

## Goals & Non-Goals

**Goals**:

- A direct `DerivationTree` for Z1 at `FrameClass.ZTime` from the UZ, US and BX/TM axioms,
  `FormalSystem.Theorems.DiscreteUnfolding.z1Schema`, with the frame-class-gated companion
  `z1SchemaAt` that `tryGatedDerivedMatch`, the `plusValidIn_of_tm_deriv` branches and
  `mkEntryAt` consume.
- The four named past mirrors the derivation factors through — `prevIndicatorAt`/`prevIndicator`,
  `prevConj`, `unfoldBackwardSince`, `snceBotFalse` — each with a docstring, an index row, and
  the `reflect_time_*_eq` normalization lemma its `▸`-rewrite needs.
- `Metalogic.Core.deductionTheorem` computable, and with it `dfSchema`, `succIndicator`,
  `coDerived`, `perpetuity5` and `perpetuity6`.
- A proof-extractor entry for Z1 in `BimodalTools/ProofExtractorMain.lean`, replacing the
  by-name skip.
- `FormalSystem/Metalogic/CompletenessDerived.lean` deleted in full — `z1Thm`, `z1Derivable`,
  `densityDerivable` — with its five term-level consumers redirected first and its seven import
  sites removed.
- No surface anywhere in the tree (Lean docstring, README, `docs/**`, `typst/chapters/`) still
  describes Z1 or DN as recovered through a completeness engine.
- `docs/theorem-index.md` carrying a row for every paper-cited schema in the target table,
  closing the roughly twelve-row gap, with measured Axioms cells.

**Non-Goals**:

- **No `propext`-only claim.** It is out of reach: a residual `Classical.choice` survives inside
  a `theorem` body that the `def`-closure probe cannot see, and the repair in Phase 1 buys
  computability, not a smaller axiom profile. Phase 11 records measured profiles instead.
- No change to the axiom set, and no fix to `typst/FormalFoundations.typ`'s presentation of Z1 as
  an axiom of TM_z (see Research Integration).
- No deletion of `SoundnessLemmas.z1_valid` or `Metalogic.density_valid`; both have verified
  independent consumers and both stay.
- No change to the completeness engines (`derivable_of_validZTime`, `derivable_of_validQTime`,
  `derivable_of_validDense`, the `Deterministic/Engines.lean` family), to soundness, to
  `ZTimeProvability.lean`'s derivability-validity equivalence, or to the independence and
  non-compactness results.
- No edit to the JPL paper or anything in its repository, and no prose added anywhere explaining
  a citation convention.
- No extractor entries for `dfSchema`, `coDerived` or `succIndicator`, which Phase 1 also
  unblocks — reported as findings rather than silently absorbed.
- No `sorry`, and no strategic-sorry skeleton.
- No edit under `.claude/**`; the report's two context-extension recommendations belong to the
  source store and a separate `/meta` task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The Z1 derivation sketch is a research sketch, not a checked proof; the US (`enrichment_until`) instantiation and the backward `snce` unfolding are the two steps most likely to need a different payload than `¬Gφ` | H | M | Phase 3 lands the four mirrors first, so Phase 4 attempts the sketch against named, compiled helpers; Phase 4 is sized for one schema and nothing else; verify the US instantiation before building the rest of the chain |
| The `DeductionTheorem` repair is probe-verified for one module's compilation and for computability, not for the whole downstream cascade — `DiscreteUnfolding`, `DedekindDerived`, `Perpetuity` and every `orElim` consumer were never rebuilt against it | H | M | Phase 1 is its own phase with a full `lake build` plus `lake build BimodalTest` as its exit criterion; on a cascade failure, revert Phase 1 entirely rather than patching forward, and take the recorded fallback (Phase 10 drops, Z1 stays noncomputable, both recorded as exclusions) |
| `check-metalogic-cycles.sh` assertion B is **already red** before this task starts: a surplus import `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.LinearityDerived` from commit `ba6c0f5dd`, independently hit and reported by two sibling tasks in this batch and still unowned | M | H (already realized) | Treat as pre-existing and attributable: record the failure with the commit attribution in Phase 11's verification notes as a reasoned exclusion, and do not repair it. Confirm before the run that the failure is the same assertion-B surplus line and not a new one this task introduced |
| Deleting `z1Thm`/`z1Derivable`/`densityDerivable` makes this task's own live description in `specs/state.json` a `check-phantom-citations.sh` finding, because that check scans live task descriptions | M | H | Phase 11 rewrites the live description to cite the direct derivation instead, then re-runs the check; any finding that is not this task's own description is treated as blocking |
| C35 (`export-lean-citations.py --check`) goes red on any docstring edit in a file carrying seeded manifest entries — `Metalogic/Independence/ZTimeSharpness.lean` (4 entries) and `ProofSystem/Axioms.lean` (1) are both edited here | M | H | Phase 11 regenerates with `python3 scripts/export-lean-citations.py` before running `--check`; the regeneration is a plan step, not a remedy improvised at gate time |
| Nine-plus prose surfaces risk an incomplete rewrite, and `check-phantom-citations.sh` catches only deleted *names*, not prose that still correctly-but-stalely describes an engine recovery | M | M | Phase 11 runs the complementary sweep `grep -rn "completeness engine\|recovered through\|recovered at" ` over the non-`specs/` tree and requires every surviving hit to be about a genuine engine use, not about Z1 or DN |
| Deleting a module leaves the generated library root stale, so a module can vanish from `lake build`'s view without the build noticing | M | M | Phase 6 regenerates with `lake exe mk_all --lib FormalSystem` in the same phase; Phase 11 re-runs it and requires "No update necessary", and runs C33 via `check-module-invariants.sh` |
| `FormalSystem/Metalogic/README.md`'s `CompletenessDerived.lean` row (76 lines) and `FormalSystem/Theorems/README.md`'s inventory both sit inside `BEGIN GENERATED: inventory` blocks that move when the module is deleted and `DiscreteUnfolding.lean` grows | L | H | Phase 11 regenerates both with `bash scripts/check-module-invariants.sh --emit-inventory` rather than hand-editing a generated block |
| Concurrency: `docs/theorem-index.md` and `docs/reference/paper-definitions-of-record.md` are shared territory with sibling tasks in this batch | M | M | Re-read each file immediately before editing it; stage with explicit single-file pathspecs, never a directory or glob; on observing a foreign uncommitted modification or a foreign commit mid-phase, stop and report rather than proceeding |
| An unexplained Lean failure during implementation is attributed to this task's own edits when it is in fact a concurrent unguarded `lake` invocation or a sibling's landed commit | M | M | Route every build through `lake-build-guard.sh`; check `git log` and `git status` before concluding a failure is a regression of this task's work |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5, 10 | 4 |
| 5 | 6 | 2, 5 |
| 6 | 7, 8, 9 | 6 |
| 7 | 11 | 7, 8, 9, 10 |

Phases within the same wave can execute in parallel.

### Phase 1: Make the Deduction Theorem Computable [COMPLETED]

- **Goal:** Remove the gratuitous classical `Decidable` instances that make
  `Metalogic.Core.deductionTheorem` noncomputable, so that Z1 — and `dfSchema`, `succIndicator`,
  `coDerived`, `perpetuity5`, `perpetuity6` with it — can carry a runtime-walkable tree.
- **Tasks:**
  - [x] In `FormalSystem/Theorems/DeductionTheorem.lean`, delete the
    `attribute [local instance] Classical.propDecidable` line and replace each of the four
    `haveI : Decidable (A ∈ Γ...) := Classical.propDecidable _` sites with `inferInstance`.
    `Formula` derives `DecidableEq` in `FormalSystem/Syntax/Formula.lean`, so `List` membership
    in a `Context` is constructively decidable and none of the five is needed.
  - [x] Drop the `noncomputable` marker from `deductionWithMem` and from `deductionTheorem`.
  - [x] Update the two docstring passages in that file that explain the `noncomputable` markers
    and tell consumers they need not inherit them, so the prose matches the new reality.
  - [x] Remove `DiscreteUnfolding.lean`'s `noncomputable section` / closing `end` pair, so the
    computability cascade actually reaches `succIndicator`, `nextAllFuture`, `prevAllPast` and
    `dfSchema`.
  - [x] Build the full project and the test library. On any failure in the cascade, revert this
    phase's edits in full (see the contingency below) rather than patching forward.
  - [x] Measure and record, for `Metalogic.Core.deductionTheorem`, `DiscreteUnfolding.dfSchema`,
    `DiscreteUnfolding.succIndicator`, `DedekindDerived.coDerived`, `Perpetuity.perpetuity5` and
    `Perpetuity.perpetuity6`: `Lean.isNoncomputable` and `#print axioms`. The axiom profiles are
    expected to be unchanged (`pcq`); only the computability flags should move.
  - [x] Sweep the tree for `noncomputable` markers that existed only because of
    `deductionTheorem` and are now redundant; remove only those whose removal keeps the build
    green, and leave the rest. *(deviation: altered — the sweep had to be wider than the Scope
    Hypothesis predicted. Stripping only `DedekindDerived`/`Principles`/`Interaction` left the
    build red on upstream markers in `GeneralizedNecessitation` and `TemporalDerived`, so all 93
    explicit `noncomputable def/abbrev` markers under `FormalSystem/Theorems/` were removed,
    together with four inert `noncomputable section` wrappers and about fifteen stale prose
    passages. Full build and `BimodalTest` both green afterwards, so the revert contingency was
    not taken.)*
- **Timing:** 1.5 hours
- **Depends on:** none
- **Verification Tier:** full
- **Scope Hypothesis:** exactly five classical-instance sites and two `noncomputable` markers in
  `DeductionTheorem.lean`, plus one `noncomputable section` in `DiscreteUnfolding.lean`; the
  implementer confirms by grepping both files for `Classical.propDecidable` and `noncomputable`
  after the edit and requiring zero hits in `DeductionTheorem.lean`, and by the
  `Lean.isNoncomputable` measurements above coming back `false` for all six declarations. A sixth
  site, or a seventh declaration whose marker will not come off, is a signal that the cascade is
  wider than probed and that the contingency may apply.
- **Tier Justification:** the deduction theorem's computability status is a cross-cutting property
  of the whole library — every `Theorems/` module routes through it and `ProofExtractorMain`'s
  `mkEntryAt` silently excludes anything noncomputable — so no single-module build and no
  enumerable one-hop dependent set observes the blast radius; the complete gate set is the only
  check that does.
- **Files to modify:**
  - `FormalSystem/Theorems/DeductionTheorem.lean` - five classical-instance sites, two
    `noncomputable` markers, two explanatory docstring passages
  - `FormalSystem/Theorems/DiscreteUnfolding.lean` - remove the `noncomputable section` wrapper
  - any module whose `noncomputable` marker is now redundant and comes off cleanly
- **Verification:**
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project),
    detached, green with zero errors.
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`,
    detached, green.
  - `Lean.isNoncomputable` reports `false` for all six declarations named above.
  - `#print axioms` for the same six, recorded verbatim in the phase notes.
  - `bash scripts/check-module-invariants.sh --no-build` — no new finding (C14's stale-literal
    scan in particular).
- **Contingency:** if the full build or the test library goes red and the cause is the cascade
  rather than a concurrent writer, revert every edit of this phase (`git checkout` of the two
  files from HEAD is safe only on a clean tree; otherwise take a `--no-revert` snapshot first and
  undo the edits by hand), mark the phase `[BLOCKED]`, and record the fallback: Z1 stays
  noncomputable, Phase 10 is dropped with its reason stated, and Phases 3–9 and 11 proceed
  unchanged. The fallback costs the extractor entry and nothing else.

---

### Phase 2: Prune `densityDerivable` [COMPLETED]

- **Goal:** Remove the DN engine cross-check, which has no consumer anywhere outside its own
  file, together with the prose that presents it as a cross-check.
- **Tasks:**
  - [x] Re-confirm zero consumers before deleting: grep `densityDerivable` across
    `FormalSystem/`, `Tests/`, `BimodalTools/`, `docs/`, `typst/` and expect hits only in
    `FormalSystem/Metalogic/CompletenessDerived.lean` and `FormalSystem/Metalogic/README.md`.
  - [x] Delete the `densityDerivable` declaration and its docstring from
    `FormalSystem/Metalogic/CompletenessDerived.lean`.
  - [x] Delete the module docstring's DN bullet (the "cross-check only" paragraph) and the
    Dense-engine bullet of its "Non-circularity" section. Leave the Z1 material in place; Phase 6
    takes the whole file.
  - [x] Remove the `densityDerivable` clause from `FormalSystem/Metalogic/README.md`'s
    `CompletenessDerived.lean` row, leaving the Z1 description. The row's line count is inside a
    `BEGIN GENERATED: inventory` block and is regenerated in Phase 11, not hand-edited here.
- **Timing:** 0.5 hours
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** exactly one declaration and two docstring paragraphs are deleted and the
  declaration has exactly zero consumers; the implementer confirms by the grep above returning
  only the two expected files, and escalates rather than deleting if a third file appears.
- **Tier Justification:** the deleted declaration has no consumer outside its own module, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.CompletenessDerived`
  covers the whole edit.
- **Files to modify:**
  - `FormalSystem/Metalogic/CompletenessDerived.lean` - delete `densityDerivable`, its docstring,
    and the two module-docstring paragraphs about it
  - `FormalSystem/Metalogic/README.md` - drop the `densityDerivable` clause from the module row
- **Verification:**
  - The pre-deletion grep returns exactly the two expected files.
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.CompletenessDerived`
    green, detached.
  - A post-deletion grep for `densityDerivable` across the non-`specs/` tree returns nothing.

---

### Phase 3: The Four Past Mirrors [COMPLETED]

- **Goal:** Name, rather than inline, the helper derivations the Z1 route factors through: the
  four missing past duals, each built by the `prevAllPast` recipe, each a declaration in its own
  right.
- **Tasks:**
  - [x] `prevIndicatorAt {fc} (h : FrameClass.ZTime ≤ fc) : ⊢[fc] Formula.prev Formula.top` and
    `prevIndicator : ⊢[FrameClass.ZTime] Formula.prev Formula.top`, mirroring `succIndicatorAt` /
    `succIndicator` exactly — including the `le_rfl` instantiation convention and the docstring
    note on why the gate is what makes the `{fc}`-generalization safe.
  - [x] `prevConj {fc} (A B : Formula)`, the dual of `nextConj`, with its
    `reflect_time_next_conj_eq` normalization lemma proved by one `simp only` over
    `Formula.next`, `Formula.prev`, `Formula.and`, `Formula.neg`, `Formula.reflectTime` and
    `Formula.reflect_time_involution`, following `reflect_time_next_all_future_eq` verbatim as
    the recipe.
  - [x] `unfoldBackwardSince (e g : Formula)`, the `snce` dual of `unfoldForward`, with its own
    `reflect_time_unfold_forward_eq` normalization lemma. Note that the mirror of
    `unfoldBackward` (the `Base`-level converse) is *not* needed by the Z1 route; add it only if
    Phase 4 turns out to need it, and otherwise report it as an available cheap dual.
  - [x] `snceBotFalse {fc} (X : Formula) : ⊢[fc] (Formula.snce X Formula.bot).imp Formula.bot`,
    the dual of `untlBotFalse`, with its normalization lemma.
  - [x] Placement: `prevIndicatorAt`/`prevIndicator`, `prevConj` and `unfoldBackwardSince` go in
    `FormalSystem/Theorems/DiscreteUnfolding.lean` beside their primaries; `snceBotFalse` goes in
    `FormalSystem/Theorems/Propositional/Core.lean` beside `untlBotFalse`. Confirm both against
    `FormalSystem/Theorems/README.md`'s "Where a derived schema lives" rule (lowest module whose
    imports supply the proof) before writing, and follow the rule if it says otherwise.
  - [x] Give every new declaration a docstring naming its primary, stating that the mirror is
    free because `DerivationTree.time_reflection` is a primitive rule at every frame class, and
    recording that no past-mirrored axiom is introduced — the `prevAllPast` docstring is the model.
  - [x] Measure `#print axioms` and `Lean.isNoncomputable` for each new declaration and record
    the values for Phase 11's table.
- **Timing:** 2 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Scope Hypothesis:** exactly four mirror declarations (five counting the `prevIndicator`
  `le_rfl` instantiation) plus one normalization lemma each; the implementer confirms the count
  is sufficient by attempting the Phase 4 sketch against them and adding a fifth mirror only if
  the sketch demands a dual that none of the four supplies. If a mirror turns out NOT to be free
  — that is, if `time_reflection` plus one `simp only` does not close it — that is a finding to
  report, not a licence to prove it the long way inside this phase.
- **Tier Justification:** the phase only adds declarations to two modules and changes no existing
  signature, so the scoped guarded builds of `FormalSystem.Theorems.DiscreteUnfolding` and
  `FormalSystem.Theorems.Propositional.Core` cover the whole edit.
- **Files to modify:**
  - `FormalSystem/Theorems/DiscreteUnfolding.lean` - `prevIndicatorAt`, `prevIndicator`,
    `prevConj`, `unfoldBackwardSince` and their normalization lemmas
  - `FormalSystem/Theorems/Propositional/Core.lean` - `snceBotFalse` and its normalization lemma
- **Verification:**
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Theorems.DiscreteUnfolding`
    green, detached.
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Theorems.Propositional.Core`
    green, detached.
  - Every new declaration measures `isNoncomputable = false` (Phase 1 having landed) and its
    `#print axioms` output is recorded.
  - `grep -n "sorry" ` over both files returns nothing outside a docstring.

---

### Phase 4: The Z1 Derivation [COMPLETED]

- **Goal:** Z1 as a direct `DerivationTree` from the axioms at `FrameClass.ZTime`, with the
  frame-class-gated companion the tree's consumers need.
- **Tasks:**
  - [x] Before building anything else, verify the sketch's US step in isolation:
    `Axiom.enrichment_until` at guard `¬Gφ`, event `Gφ`, payload `¬Gφ` should carry the
    currently-true `¬Gφ` to the nearest `Gφ`-witness as a `snce`-formula. If the payload has to
    change, record the change and adjust the remaining steps before writing them — this is the
    step the research flags as most likely to need adjustment.
  - [x] Build `z1Schema (φ : Formula) : ⊢[FrameClass.ZTime] ((φ.allFuture.imp φ).allFuture.imp
    (φ.allFuture.someFuture.imp φ.allFuture))` following the recorded route: assume `¬Gφ`,
    `G(Gφ→φ)` and `FGφ`; get `U(Gφ, ¬Gφ)` from `Axiom.prior_UZ` instantiated at `Gφ`; enrich by
    US to reach, at the nearest `Gφ`-witness, both `Gφ ∧ φ` and `S(¬Gφ, ¬Gφ)`; unfold the
    `snce`-formula one step backwards with `unfoldBackwardSince` to get `Y(¬Gφ)` at the witness;
    independently get `Y(Gφ)` there by transporting `Gφ ∧ φ` to the predecessor and closing with
    `nextAllFuture`; merge the two `Y`-formulas with `prevConj` and refute with `snceBotFalse`.
    The argument is finite — no induction.
  - [x] Build `z1SchemaAt {fc} (h : FrameClass.ZTime ≤ fc) (φ : Formula)` as
    `DerivationTree.lift h (z1Schema φ)`, matching the argument order of
    `DerivedAxioms.priorSZ` so that `tryGatedDerivedMatch`'s `apply`-then-`decide` discharge
    works unchanged. `Combinators.baseThm` and `succIndicatorAt` are the precedents; confirm
    `lift`'s signature at `FormalSystem/ProofSystem/Derivation.lean` before writing.
    *(deviation: altered — the route needed three additions the Scope Hypothesis did not
    anticipate: a new `import FormalSystem.Theorems.TemporalDerived` in
    `DiscreteUnfolding.lean` for TK, which step 2's event-strengthening requires; and two named
    helpers in `Combinators.lean`, `necH` and `snceEventMono`, the free past mirrors of `necG`
    and `eventMono`. The contradiction itself was additionally factored out as the named
    theorem `z1EventBot`. The research sketch's US payload `¬Gφ` needed no adjustment.)*
  - [x] Docstring both: the paper anchor (`def:BX-z`), the route in the numbered-step style
    `dfSchema`'s docstring uses, the named helpers it factors through, and — on `z1SchemaAt` —
    the note that the gated form is what the automation and extractor surfaces consume.
  - [x] Measure `#print axioms` and `Lean.isNoncomputable` for both, and run the Shape 1
    `def`-closure probe against the engine suspect set
    (`derivable_of_validZTime`, `derivable_of_validQTime`, `derivable_of_validDense`,
    `completeness`) to assert that no engine is in the closure. Record the result together with
    the probe's known `theorem`-boundary blind spot.
- **Timing:** 2 hours
- **Depends on:** 3
- **Verification Tier:** local
- **Scope Hypothesis:** the derivation is one declaration plus its one-line gated companion, and
  needs no helper beyond Phase 3's four mirrors; the implementer confirms by building it and, if
  a further helper is needed, naming and docstringing that helper rather than inlining it —
  per the dispatch's "a derivation worth having is worth naming" obligation. If the route turns
  out to need a fifth mirror, add it here and note the Phase 3 scope hypothesis as revised.
- **Tier Justification:** the phase adds two declarations to one module and changes no existing
  signature, so the scoped guarded build of `FormalSystem.Theorems.DiscreteUnfolding` covers the
  whole edit.
- **Files to modify:**
  - `FormalSystem/Theorems/DiscreteUnfolding.lean` - `z1Schema`, `z1SchemaAt`, their docstrings
- **Verification:**
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Theorems.DiscreteUnfolding`
    green, detached.
  - `#print axioms` for `z1Schema` and `z1SchemaAt` recorded; `sorryAx` absent.
  - `Lean.isNoncomputable` reports `false` for both (Phase 1 having landed), or the Phase 1
    contingency is in force and that is recorded.
  - The Shape 1 `def`-closure probe finds no completeness engine, and a source reading of the two
    declarations confirms the same.
  - `grep -n "sorry" FormalSystem/Theorems/DiscreteUnfolding.lean` returns nothing outside a
    docstring.
- **Escalation:** if the sketch cannot be closed as written, mark the phase `[BLOCKED]` and
  report what was tried and the goal state reached. Per `.claude/rules/plan-compliance.md` this
  is a `.lean` file, so a silent substitution of a different route — in particular, keeping the
  engine recovery under a new name — is not available.

---

### Phase 5: Redirect the Five Term-Level Z1 Consumers [COMPLETED]

- **Goal:** Every term-level use of `CompletenessDerived.z1Thm` points at the direct derivation,
  so that the module can be deleted.
- **Tasks:**
  - [x] `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — the shape pin at the
    `noncomputable example`: point it at `Theorems.DiscreteUnfolding.z1Schema` and drop the
    `noncomputable` modifier, which the direct tree no longer needs.
  - [x] `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` — the same treatment for
    its own `noncomputable example` shape pin. This site is **not** in the dispatch's list; it is
    the report's addition.
  - [x] `FormalSystem/Metalogic/Conservativity/Backward.lean` — `z1_translate`'s
    `impTrans (… z1Thm (tr φ)) …` becomes `impTrans (… z1Schema (tr φ)) …`.
  - [x] `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` — both branches
    (`plusValidIn_of_tm_deriv` and `plusValidIn_reflect_time_of_tm_deriv`) take `z1Schema` in
    place of `z1Thm`; if either branch wants the gated form, use `z1SchemaAt`.
  - [x] `FormalSystem/Automation/Tactics/Search.lean` — replace
    ``FormalSystem.Metalogic.CompletenessDerived.z1Thm`` in `tryGatedDerivedMatch`'s lemma-name
    list with ``FormalSystem.Theorems.DiscreteUnfolding.z1SchemaAt``, the gated form the
    `apply`-then-`decide` discharge expects.
  - [x] In each of the five files, add the `FormalSystem.Theorems.DiscreteUnfolding` import if it
    is not already reachable, but leave the `FormalSystem.Metalogic.CompletenessDerived` import
    in place — Phase 6 removes it, and removing it here would red the build before the
    docstrings that still cite the old name are rewritten.
  - [x] Leave every *docstring* mention of `CompletenessDerived.z1Thm` untouched in this phase;
    Phase 7 owns the prose, and a backticked name in a comment does not break the build.
- **Timing:** 1.5 hours
- **Depends on:** 4
- **Verification Tier:** interface
- **Scope Hypothesis:** exactly five files carry a term-level use, six use sites in total (two in
  `AxiomValidity.lean`); the implementer confirms by grepping the non-`specs/` tree for
  `z1Thm` after the redirect and requiring every surviving hit to be inside a comment, a
  docstring or `CompletenessDerived.lean` itself — a surviving term-level hit means the inventory
  was short and the extra site must be redirected before Phase 6 runs.
- **Tier Justification:** the redirect changes which declaration five enumerated modules call,
  so the guarded builds of those five modules plus `FormalSystem.Automation` and
  `FormalSystem.Metalogic` as their direct aggregating dependents cover the edit.
- **Files to modify:**
  - `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - shape pin, drop `noncomputable`
  - `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean` - shape pin, drop
    `noncomputable`
  - `FormalSystem/Metalogic/Conservativity/Backward.lean` - `z1_translate`
  - `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` - two branches
  - `FormalSystem/Automation/Tactics/Search.lean` - `tryGatedDerivedMatch`'s lemma-name list
- **Verification:**
  - Guarded, detached scoped builds of all five modules, each green.
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic`
    and `... -- build FormalSystem.Automation`, both green.
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` green —
    `Tests/BimodalTest/Automation/TacticsTest.lean` and `EdgeCaseTest.lean` exercise the tactic
    whose lemma list just changed, so this is the check that the gated form actually matches.
  - A grep for `z1Thm` outside comments returns only `CompletenessDerived.lean`.

---

### Phase 6: Delete `CompletenessDerived.lean` and Its Import Sites [COMPLETED]

- **Goal:** The module, its two remaining declarations and all seven imports of it are gone, and
  the library root is current.
- **Tasks:**
  - [x] Re-confirm, immediately before deleting, that no term-level consumer of `z1Thm` or
    `z1Derivable` remains (the Phase 5 grep, re-run).
  - [x] Delete `FormalSystem/Metalogic/CompletenessDerived.lean`.
  - [x] Remove the `import FormalSystem.Metalogic.CompletenessDerived` line from all seven import
    sites: `FormalSystem.lean`, `FormalSystem/Metalogic.lean`,
    `FormalSystem/Automation/Tactics/Search.lean`,
    `FormalSystem/Metalogic/Conservativity/Backward.lean`,
    `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean`,
    `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean`,
    `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`. Confirm the count by grepping for
    the import line rather than trusting the list.
  - [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`.
  - [x] Confirm no manifest, allowlist or baseline file under `scripts/` names the module
    (a grep over `scripts/*.txt`, `scripts/*.json`, `scripts/*.sh` found none at plan time;
    re-run it and act on any hit).
- **Timing:** 1 hour
- **Depends on:** 2, 5
- **Verification Tier:** interface
- **Scope Hypothesis:** exactly seven import sites and zero `scripts/` manifest entries; the
  implementer confirms by `grep -rn "FormalSystem.Metalogic.CompletenessDerived" ` over the
  non-`specs/`, non-`.lake/` tree returning only docstring/prose hits after the deletion, and
  escalates if a manifest or baseline file turns up.
- **Tier Justification:** deleting a module can break only the modules that import it, and those
  seven are enumerated above, so the guarded build of the `FormalSystem` library root — which
  transitively covers every one of them — is the covering check.
- **Files to modify:**
  - `FormalSystem/Metalogic/CompletenessDerived.lean` - deleted
  - `FormalSystem.lean`, `FormalSystem/Metalogic.lean`,
    `FormalSystem/Automation/Tactics/Search.lean`,
    `FormalSystem/Metalogic/Conservativity/Backward.lean`,
    `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean`,
    `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean`,
    `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - import line removed
- **Verification:**
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project)
    green, detached.
  - `lake exe mk_all --lib FormalSystem` leaves no diff on a second run.
  - `grep -rn "FormalSystem.Metalogic.CompletenessDerived" ` over the non-`specs/`,
    non-`.lake/` tree returns only prose hits, which Phases 7–9 then clear.
  - `bash scripts/check-module-invariants.sh --no-build` — C6 (no unmanifested unreachable
    module) and C33 (library root byte-current) in particular.

---

### Phase 7: The In-Tree Prose Tail [COMPLETED]

- **Goal:** No Lean docstring or comment in the tree still describes Z1 or DN as recovered
  through a completeness engine; each cites the derivation instead.
- **Tasks:**
  - [x] Rewrite the Z1 prose in the surfaces the dispatch names:
    `FormalSystem/ProofSystem/Axioms.lean` (four spots), `FormalSystem/MainResults.lean`,
    `FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean` (two spots),
    `Tests/BimodalTest/Automation/EdgeCaseTest.lean`,
    `Tests/BimodalTest/Automation/TacticsTest.lean`.
  - [x] Rewrite the Z1 prose in the surfaces the dispatch does **not** name (the report's
    additions): `FormalSystem/Metalogic/Conservativity.lean`,
    `FormalSystem/Metalogic/Independence/StaticFrame.lean` (two spots),
    `FormalSystem/MinusLanguage/Axioms.lean`, `FormalSystem/ProofSystem.lean`,
    `FormalSystem/Semantics/FrameClassValidity.lean`,
    `FormalSystem/Semantics/FrameProperty.lean`, `BimodalTools/AxiomNames.lean`.
  - [x] In `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` and
    `ArchimedeanSharpness.lean`, rewrite the docstrings that still name
    `CompletenessDerived.z1Thm` (twelve and four mentions respectively at plan time, most of them
    prose).
  - [x] In `FormalSystem/Automation/Tactics/Search.lean`, rewrite `tryGatedDerivedMatch`'s
    docstring sentence about Z1 being "recovered through the ZTime completeness engine".
  - [x] Each rewrite says what is now true: Z1 is a direct derivation from UZ and US at
    `FrameClass.ZTime`, named `Theorems.DiscreteUnfolding.z1Schema` (gated: `z1SchemaAt`). Do not
    add prose explaining a citation convention, and do not narrate that the engine route used to
    exist — see `.claude/rules/no-record-versioning-in-deliverables.md`.
  - [x] Confirm no task number entered any of these files
    (`.claude/rules/no-task-references-in-deliverables.md`).
  - [x] `BimodalTools/ProofExtractorMain.lean` is **not** in this phase's territory; Phase 10
    owns both its comment and its entry.
- **Timing:** 1.5 hours
- **Depends on:** 6
- **Verification Tier:** prose
- **Scope Hypothesis:** roughly seventeen Lean/test files carry prose mentions, a figure carried
  from the research report's grep sweep (`z1Thm|z1Derivable|CompletenessDerived|densityDerivable`
  across `*.lean`, 20 files, minus the three Phase 5/6 files whose mentions are already term-level
  and minus `ProofExtractorMain.lean`); the implementer re-derives it by re-running that grep at
  the start of the phase and treats the re-derived list, not this one, as the work list.
- **Tier Justification:** every hunk lies inside a docstring or comment with zero elaboration
  surface, so the `prose` diff read-through plus
  `bash scripts/check-phantom-citations.sh` (which flags any surviving backticked reference to a
  declaration this task deleted) covers the edit; a scoped guarded build of any file whose hunk
  turns out to touch code is the escape hatch.
- **Files to modify:** the roughly seventeen Lean and test files enumerated above, docstrings and
  comments only
- **Verification:**
  - Diff read-through confirming every changed hunk lies inside a comment or docstring region.
  - `grep -rn "z1Thm\|z1Derivable\|densityDerivable\|CompletenessDerived" ` over
    `FormalSystem/`, `Tests/` returns nothing (`BimodalTools/` is cleared by Phase 10).
  - `bash scripts/check-phantom-citations.sh` reports no finding from these files.
  - `bash .claude/scripts/check-task-references.sh` reports no new finding.

---

### Phase 8: Close the `docs/theorem-index.md` Coverage Gap [COMPLETED]

- **Goal:** Every paper-cited schema in the target set has a row, and the Z1 rows cite the
  derivation.
- **Tasks:**
  - [x] Re-read `docs/theorem-index.md` immediately before editing it (sibling-task territory;
    see Risks).
  - [x] Replace the two `CompletenessDerived` Z1 rows with one row for
    `FormalSystem.Theorems.DiscreteUnfolding.z1Schema` and one for `z1SchemaAt`, each with the
    `def:BX-z` paper label, the `FormalSystem/Theorems/DiscreteUnfolding.lean` path (no line
    numbers), frame class `ZTime`, and the measured Axioms cell from Phase 4.
  - [x] Add rows for the schemata that have none today: DF
    (`Theorems.DiscreteUnfolding.dfSchema`), the discreteness witness
    (`Theorems.DiscreteUnfolding.succIndicator`), CO (`Theorems.DedekindDerived.coDerived`), TK
    (`Theorems.TemporalDerived.temporalKDistDerived`), T4
    (`Theorems.TemporalDerived.temporal4Derived`), TF
    (`Theorems.Combinators.temporalFutureDerived`), and P1–P6
    (`Theorems.Perpetuity.perpetuity1`–`perpetuity4` at
    `FormalSystem/Theorems/Perpetuity/Principles.lean`, `perpetuity5` at the same file,
    `perpetuity6` at `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean` — confirm each
    path before writing the row).
  - [x] Add rows for Phase 3's four mirrors and their `le_rfl` instantiation, per the dispatch's
    "give each new declaration a docs/theorem-index.md row" obligation.
  - [x] Every Axioms cell states the value measured in Phases 1, 3 and 4, written out literally
    or as `pcq`, never as `pinned:` — none of these declarations is in the C2 or C14 baseline
    pair.
  - [x] Update the section's lead-in prose: the "Nine schemata are theorems of the 20-constructor
    system" count and the per-schema enumeration behind it both move, and the closing sentence
    "The nine Base-polymorphic derivations are computable and carry `propext` only" must be
    restated to match what is now true — Phase 1 makes more of the table computable, and rows
    with a `pcq` cell now join it.
  - [x] Give each row its paper anchor where it has one, per the target table in the research
    report; P5 and P6 are cited in `sub:Logic` with no `\leanfoot`, so their Paper label is the
    `sub:Logic` anchor the neighbouring P1–P4 rows use. *(deviation: altered — C15's second assertion
    requires every index row's label to be matched by a `Paper:` line in the named
    declaration's own `/--` block, so nineteen declarations across six `Theorems/` modules
    gained one; the free mirrors and the two new `Combinators` helpers carry
    `Paper: — (reason)`, which C15 accepts as a satisfied cell.)*
- **Timing:** 1.5 hours
- **Depends on:** 6
- **Verification Tier:** prose
- **Scope Hypothesis:** roughly twelve missing schema rows plus five mirror rows plus two
  replaced Z1 rows, a figure carried from the research report's coverage-gap finding (the derived-
  schemata table has 11 rows and none for DF, CO, TK, T4, TF, P1–P6 or the witness); the
  implementer re-derives it by checking every schema in the report's target table against the
  live table and adding a row wherever the check fails, rather than working from this count.
- **Tier Justification:** the edit is confined to one markdown file with no executable surface, so
  the `prose` diff read-through plus `bash scripts/check-phantom-citations.sh` — which scans
  `docs/**/*.md` for backticked declaration names with no definition site and so catches a
  mistyped or stale Lean name in any new row — covers it.
- **Files to modify:**
  - `docs/theorem-index.md` - Z1 row replacement, roughly seventeen added rows, lead-in prose
- **Verification:**
  - Diff read-through: every new row's Lean name is fully qualified, every File cell is a path
    with no line number, every Axioms cell states a measured value.
  - `bash scripts/check-phantom-citations.sh` reports no finding from this file.
  - `bash .claude/scripts/check-task-references.sh` reports no new finding.
  - Spot-check three new rows by grepping the named declaration in the named file.

---

### Phase 9: The Remaining Doc, README and Typst Surfaces [COMPLETED]

- **Goal:** Every documentation surface outside `docs/theorem-index.md` cites the derivation.
- **Tasks:**
  - [x] `docs/reference/axiom-reference.md` — three spots: the ZTime row of the layer table, the
    `z1Thm` row of the derived-schemata table, and the Z1 paragraph. Replace the engine
    description with the derivation in each.
  - [x] Re-read `docs/reference/paper-definitions-of-record.md` immediately before editing it
    (sibling-task territory), then update its two Z1/DN spots.
  - [x] `docs/development/MODULE_ORGANIZATION.md` — the "Z1 in `Metalogic.CompletenessDerived`"
    placement claim, now `Theorems.DiscreteUnfolding`.
  - [x] `docs/project-info/FEATURE_REGISTRY.md` — the entry naming
    `FormalSystem/Metalogic/CompletenessDerived.lean` among its files.
  - [x] `FormalSystem/README.md` — two spots: the layer-6 table row and the Z1 paragraph.
  - [x] `FormalSystem/Theorems/README.md` — its `CompletenessDerived` mention, plus a "Where a
    derived schema lives" note recording that Z1 and the four mirrors now live in
    `DiscreteUnfolding.lean`. The file's `BEGIN GENERATED: inventory` block is regenerated in
    Phase 11, not hand-edited here.
  - [x] `FormalSystem/Metalogic/README.md` — remove the `CompletenessDerived.lean` prose outside
    the generated block; the generated row itself disappears when Phase 11 regenerates.
  - [x] `FormalSystem/Metalogic/Independence/README.md` — four Z1 spots (the report's addition;
    not in the dispatch's list).
  - [x] `typst/chapters/03-proof-theory.typ` — two spots: the Z1 table row (which names
    `` `CompletenessDerived.z1Thm` (derived)``) and the paragraph asserting "it is recovered at
    `ZTime` from UZ through the ZTime completeness engine". Both become the direct derivation,
    keeping the surrounding claim that UZ remains the only `ZTime`-tagged constructor, which is
    still true.
  - [x] Do **not** touch `typst/FormalFoundations.typ`. Its four Z1 spots present Z1 as an axiom
    of TM_z — demotion-wave fallout, not an engine-recovery citation — and it carries no
    engine-recovery prose at all. Record it as a finding for Phase 11's report.
  - [x] Confirm no task number and no draft-history or supersession language entered any of these
    files.
- **Timing:** 1.5 hours
- **Depends on:** 6
- **Verification Tier:** prose
- **Scope Hypothesis:** nine documentation surfaces plus one Typst chapter, a figure carried from
  the research report's doc-surface inventory; the implementer re-derives it by re-running
  `grep -rn "z1Thm\|z1Derivable\|densityDerivable\|CompletenessDerived" ` over `docs/`, `typst/`
  and every `README.md` outside `specs/` at the start of the phase, and works from that list.
- **Tier Justification:** every edit is markdown or Typst prose with no Lean elaboration surface,
  so the `prose` diff read-through plus `bash scripts/check-phantom-citations.sh` (which scans
  `docs/**/*.md` for stale declaration names) covers it; the two Typst documents are compiled in
  Phase 11, which is where a Typst syntax error would surface.
- **Files to modify:**
  - `docs/reference/axiom-reference.md`, `docs/reference/paper-definitions-of-record.md`,
    `docs/development/MODULE_ORGANIZATION.md`, `docs/project-info/FEATURE_REGISTRY.md`,
    `FormalSystem/README.md`, `FormalSystem/Theorems/README.md`,
    `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Independence/README.md`,
    `typst/chapters/03-proof-theory.typ`
- **Verification:**
  - Diff read-through of every changed hunk.
  - `grep -rn "z1Thm\|z1Derivable\|densityDerivable\|CompletenessDerived" docs/ typst/` returns
    nothing.
  - `bash scripts/check-phantom-citations.sh` reports no finding from `docs/`.
  - `bash scripts/readme-lint.sh` exits 0.
  - `bash .claude/scripts/check-task-references.sh` reports no new finding.

---

### Phase 10: The Proof-Extractor Entry for Z1 [COMPLETED]

- **Goal:** Z1 has a registry entry with a runtime-walkable tree, replacing the by-name skip.
- **Tasks:**
  - [x] In `BimodalTools/ProofExtractorMain.lean`, delete the two-line comment explaining that Z1
    "has no runtime-walkable tree and no entry", and add
    `mkEntryAt "z1_axiom" .ZTime (FormalSystem.Theorems.DiscreteUnfolding.z1SchemaAt (fc := .ZTime) le_rfl p)`
    plus the `_q` companion, following the `prior_SZ_axiom` / `prior_SZ_axiom_q` pair immediately
    above it as the shape model (confirm the gate-discharge idiom those entries use — `trivial`
    for `priorSZ` — and use whatever `z1SchemaAt`'s gate actually needs).
  - [x] Check whether the `G_`, `H_` and `GG_` prefixed entry families further down the file have
    a Z1 member by convention; add it if they do, and record the decision either way.
  - [x] Run the extractor and confirm the Z1 entries appear in its output with a walkable tree.
  - [x] Record, as a finding for Phase 11's report, that Phase 1 also unblocks extractor entries
    for `dfSchema`, `coDerived` and `succIndicator` — and that this task deliberately does not add
    them, since they are outside the dispatch's named scope.
  - [x] *(not applicable: Phase 1's contingency was not taken.)* If Phase 1's contingency is in force (the repair was reverted), skip this phase entirely,
    mark it `[BLOCKED]` with that reason, and leave the by-name skip comment in place with its
    wording corrected to cite the direct derivation rather than the engine.
- **Timing:** 1 hour
- **Depends on:** 1, 4
- **Verification Tier:** local
- **Scope Hypothesis:** two new entries (the base pair), possibly more if the prefixed families
  carry a Z1 member by convention; the implementer confirms by reading the `prior_UZ` entry
  family — which appears in the base, `G_`, `H_` and `GG_` groups — and matching Z1's coverage to
  whatever the neighbouring ZTime schema does.
- **Tier Justification:** the edit is confined to one executable's source with no change to any
  library signature, so
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTools`
  plus one run of the extractor covers it.
- **Files to modify:**
  - `BimodalTools/ProofExtractorMain.lean` - the skip comment, the new entries
- **Verification:**
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTools` green,
    detached.
  - The extractor runs and its output contains the Z1 entries with a non-trivial tree.
  - `grep -n "CompletenessDerived\|z1Thm" BimodalTools/ProofExtractorMain.lean` returns nothing.

---

### Phase 11: Regeneration, the Full Gate Sweep, and the Per-Schema Report [COMPLETED WITH EXCLUSIONS]

- **Goal:** Every generated artefact is current, the whole repository is green except the one
  pre-existing failure, and item (5)'s per-schema table is reported.
- **Tasks:**
  - [x] Regenerate the citation manifest: `python3 scripts/export-lean-citations.py`. C35 goes
    red on any docstring edit in a file carrying seeded entries, and this task edits two such
    files (`Metalogic/Independence/ZTimeSharpness.lean`, 4 entries; `ProofSystem/Axioms.lean`,
    1) — regeneration is the remedy, run before the `--check`.
  - [x] Regenerate the README inventory blocks:
    `bash scripts/check-module-invariants.sh --emit-inventory`. `FormalSystem/Metalogic/README.md`
    loses its `CompletenessDerived.lean` row entirely and `FormalSystem/Theorems/README.md`'s
    line counts move.
  - [x] Re-run `lake exe mk_all --lib FormalSystem` and require "No update necessary".
  - [x] Rewrite this task's own live description in `specs/state.json` so it cites
    `Theorems.DiscreteUnfolding.z1Schema` instead of the three deleted declarations, then
    regenerate `specs/TODO.md` with `bash .claude/scripts/generate-todo.sh`. Without this,
    `check-phantom-citations.sh` reports the task's own record as a phantom citation.
  - [x] Run the complementary staleness sweep that no mechanical check covers:
    `grep -rn "completeness engine\|recovered through\|recovered at" ` over `FormalSystem/`,
    `Tests/`, `BimodalTools/`, `docs/`, `typst/`, and confirm every surviving hit is about a
    genuine engine use (`StrongCompleteness.lean`, `Metalogic.lean`, `MainResults.lean`'s
    compactness prose, `ax-lean-appendix.typ`) and none is about Z1 or DN.
  - [x] Measure `#print axioms` for every new declaration (Phase 3's mirrors, Phase 4's
    `z1Schema` and `z1SchemaAt`) and re-measure the six declarations Phase 1 touched.
  - [x] Run the complete gate set (below) and record every outcome in a verification-notes table.
  - [x] Report the per-schema table item (5) asks for — schema, direct-derivation declaration
    name, `#print axioms` output, what was deleted — covering the full target set: TC, TL, NP,
    NF, NA, P1–P6, TF, TK, T4, DF, the discreteness witness, DN, CO, Z1. State explicitly, in the
    report, that the dispatch's "`propext` at most" criterion was replaced (see Non-Goals) and
    why, with the measured profiles standing as the record.
  - [x] Report the findings this task deliberately did not absorb: `typst/FormalFoundations.typ`'s
    four Z1-as-axiom spots; the three further extractor entries Phase 1 unblocks; and any cheap
    dual Phase 3 identified but did not add.
- **Timing:** 2 hours
- **Depends on:** 7, 8, 9, 10
- **Verification Tier:** full
- **Scope Hypothesis:** the per-schema report covers nineteen schemata — the research report's
  target table (TC, TL, NP, NF, NA, P1–P6, TF, TK, T4, DF, the witness, DN, CO, Z1) — and the
  citation manifest seeds exactly two files this task edits. The seed counts were re-derived at
  plan-authoring time against `scripts/lean-citation-manifest.json` (4 entries for
  `Metalogic/Independence/ZTimeSharpness.lean`, 1 for `ProofSystem/Axioms.lean`), confirming the
  research report's figure; the implementer re-derives both at run time, because an earlier phase
  may have added a seeded file, and treats the re-derived values as authoritative.
- **Files to modify:**
  - `scripts/lean-citation-manifest.json` - regenerated
  - `FormalSystem/Metalogic/README.md`, `FormalSystem/Theorems/README.md` - regenerated inventory
    blocks
  - `FormalSystem.lean` - regenerated library root, if any phase left it stale
  - `specs/state.json`, `specs/TODO.md` - this task's own description, to clear the self-inflicted
    phantom citation
- **Verification:** the complete gate set, every item run and observed green in this dispatch,
  never trusted on sight:
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project),
    detached.
  - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`,
    detached.
  - `bash scripts/check-module-invariants.sh` — the full battery, C6, C14 and C33 in particular.
  - `lake exe checkInitImports`.
  - `bash scripts/check-copyright-headers.sh`.
  - `bash scripts/readme-lint.sh`.
  - `bash scripts/check-evidence-probes.sh` — tracked probes still compile against the changed
    declarations.
  - `python3 scripts/export-lean-citations.py --check` exits 0 (after the regeneration above).
  - `bash scripts/check-phantom-citations.sh` — no finding.
  - `bash scripts/check-paper-definitions.sh` — still case (b), exit 0; this task does not touch
    the paper.
  - `bash .claude/scripts/check-task-references.sh` — no task number outside `specs/**`.
  - `typst compile typst/BimodalReference.typ` and `typst compile typst/FormalFoundations.typ`,
    both succeeding.
  - `grep -rn "sorry" ` over every file this task touched returns nothing outside a docstring.
  - `bash scripts/check-metalogic-cycles.sh` — **expected red, pre-existing and not owned here**:
    assertion B, surplus import `FormalSystem.MinusLanguage.AxiomDischarge ->
    FormalSystem.Theorems.LinearityDerived` from commit `ba6c0f5dd`. Confirm the failure is that
    same surplus line and record it as a reasoned exclusion with the attribution; if the failure
    is anything else, it is this task's and must be fixed.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `scripts/check-metalogic-cycles.sh` assertion B | Pre-existing and unowned: the surplus upward edge `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.LinearityDerived` comes from commit `ba6c0f5dd` and has been reported, unrepaired, by three sibling tasks in this batch. The plan records it in Risks and here as an expected exclusion. | The run reports `1 surplus, 0 shortfall` and names exactly that edge, so this task's own new edge (`DiscreteUnfolding -> TemporalDerived`) is not among the findings. |
| `scripts/check-module-invariants.sh` C16 | Not this task's: the single new `unusedArguments` finding is `FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden` in `FormalSystem/Semantics/ShiftFiniteType.lean`, a file this task never edited. | `git log -1 -- FormalSystem/Semantics/ShiftFiniteType.lean` returns commit `250a74ae0`; `git log 47411ec92..HEAD --name-only` contains no occurrence of that path. |
| The complete agent-system gate set (`run-all.sh --only` / `verify-deploy.sh --only-gate`) | The dispatch's Batch Gate Deferral narrows this phase's `full` tier to those entry points, which gate the agent-system extensions. This task modified no file under `agent-system/**` or `.claude/**`, so the scoped narrowing is empty. | `git status`/`git diff --name-only` over this task's commits show no path under `agent-system/` or `.claude/`. The repository's own gate battery was run in full here instead, and is tabulated in the summary. |

## Lean Challenge Statements

```lean
import FormalSystem.Theorems.DiscreteUnfolding
import FormalSystem.Theorems.Propositional.Core

namespace FormalSystem.Theorems.DiscreteUnfolding

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/-- **`⊢[fc] Y ⊤` at every `fc` above `FrameClass.ZTime`.** The past mirror of
`succIndicatorAt`, free by `DerivationTree.time_reflection`. -/
def prevIndicatorAt {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) :
    ⊢[fc] Formula.prev Formula.top := sorry

/-- **`⊢[Discrete] Y ⊤`.** The `le_rfl` instantiation of `prevIndicatorAt`. -/
def prevIndicator : ⊢[FrameClass.ZTime] Formula.prev Formula.top := sorry

/-- `⊢ (YA ∧ YB) → Y(A ∧ B)`: the past mirror of `nextConj`. -/
def prevConj {fc : FrameClass} (A B : Formula) :
    ⊢[fc] ((Formula.prev A).and (Formula.prev B)).imp (Formula.prev (Formula.and A B)) := sorry

/-- The `snce` mirror of `unfoldForward`: one backward step out of a since-formula. -/
def unfoldBackwardSince (e g : Formula) :
    ⊢[FrameClass.ZTime]
      (Formula.snce g e).imp
        ((Formula.prev e).or (Formula.prev (Formula.and g (Formula.snce g e)))) := sorry

/-- **Z1**, `G(Gφ → φ) → (FGφ → Gφ)`, as a direct derivation tree from UZ and US at ℤ-time.

Paper: `def:BX-z` -/
def z1Schema (φ : Formula) :
    ⊢[FrameClass.ZTime]
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) := sorry

/-- The frame-class-gated form of `z1Schema`, by `DerivationTree.lift`. This is the shape
`Automation/Tactics/Search.lean`'s `tryGatedDerivedMatch`, the `plusValidIn_of_tm_deriv`
branches and `ProofExtractorMain`'s `mkEntryAt` consume. -/
def z1SchemaAt {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) (φ : Formula) :
    ⊢[fc] ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) := sorry

end FormalSystem.Theorems.DiscreteUnfolding

namespace FormalSystem.Theorems

/-- `⊢ S(X, ⊥) → ⊥`: the `snce` mirror of `untlBotFalse`. Placement to be confirmed against
`FormalSystem/Theorems/README.md`'s "Where a derived schema lives" rule. -/
def snceBotFalse {fc : FrameClass} (X : Formula) :
    ⊢[fc] (Formula.snce X Formula.bot).imp Formula.bot := sorry

end FormalSystem.Theorems
```

Each mirror additionally carries its own `reflect_time_*_eq` normalization lemma, stated as the
`reflectTime` image of its primary's statement and proved by a single `simp only`, following
`reflect_time_next_all_future_eq` as the model. Those lemmas are implementation detail of the
recipe and are not pinned here.

## Testing & Validation

- [x] `lake build` (full project) green with zero errors and no new `sorry`.
- [x] `lake build BimodalTest` green — in particular `Tests/BimodalTest/Automation/TacticsTest.lean`
      and `EdgeCaseTest.lean`, which exercise the tactic whose gated-lemma list changed.
- [x] `#print axioms` recorded for every new declaration and for the six Phase 1 touched; no
      `sorryAx` anywhere.
- [x] The Shape 1 `def`-closure probe finds no completeness engine in `z1Schema`'s closure, and a
      source reading agrees.
- [x] `scripts/readme-lint.sh`, `scripts/check-module-invariants.sh`,
      `scripts/check-copyright-headers.sh`, `lake exe checkInitImports`,
      `scripts/check-evidence-probes.sh`, `.claude/scripts/check-task-references.sh` all exit 0.
- [x] `python3 scripts/export-lean-citations.py --check` exits 0 after regeneration.
- [x] `scripts/check-phantom-citations.sh` reports no finding, including from this task's own
      live description.
- [x] Both Typst documents compile.
- [x] `scripts/check-metalogic-cycles.sh` fails only on the pre-existing assertion-B surplus line
      from commit `ba6c0f5dd`, recorded as a reasoned exclusion.

## Artifacts & Outputs

- `FormalSystem/Theorems/DiscreteUnfolding.lean` — four new mirrors (five declarations) and the
  Z1 derivation with its gated companion, no longer inside a `noncomputable section`.
- `FormalSystem/Theorems/Propositional/Core.lean` — `snceBotFalse` and its normalization lemma.
- `FormalSystem/Theorems/DeductionTheorem.lean` — computable deduction theorem.
- `FormalSystem/Metalogic/CompletenessDerived.lean` — deleted.
- Five redirected term-level consumers and seven removed import sites.
- `BimodalTools/ProofExtractorMain.lean` — Z1 registry entries.
- `docs/theorem-index.md` — roughly seventeen added rows and two replaced ones.
- Nine further documentation surfaces and one Typst chapter rewritten.
- The per-schema report of item (5), delivered in the implementation summary.

## Rollback/Contingency

Phase 1 carries its own documented revert-and-continue fallback (see that phase); taking it costs
the extractor entry and nothing else, and the rest of the plan proceeds unchanged.

Beyond that, the destructive step is Phase 6's module deletion, which is reversible from git
history for as long as the task's commits are intact — each phase commits on its own green
sub-steps, so a bad Phase 6 is undone by reverting that phase's commit rather than by
reconstructing the file. Phase 6 is deliberately sequenced after Phase 5's redirect precisely so
that the deletion is never the thing that reds the build.

Before any intentional rollback that `guard-destructive-git.sh` would otherwise block, run
`bash .claude/scripts/git-snapshot.sh 802` first, then retry. For an ordinary defensive
checkpoint before a risky edit — Phase 1 and Phase 4 are the two candidates — use
`bash .claude/scripts/git-snapshot.sh 802 --no-revert`, which is durable without reverting the
working tree.

If Phase 4's sketch cannot be closed, the task stops there rather than degrading: Phases 5–10
all presuppose a direct Z1 derivation, and keeping the engine route under a new name would
defeat the task's entire purpose. Mark Phase 4 `[BLOCKED]`, keep Phases 1–3 (which stand on their
own merits — the computability repair and the four named mirrors are deliverables regardless),
and report.
