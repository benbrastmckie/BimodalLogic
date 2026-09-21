# Implementation Plan: Task #568

- **Task**: 568 - C3/C4 consequence relations as library definitions
- **Status**: [IMPLEMENTING]
- **Effort**: 18.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/568_c3_c4_consequence_relations_as_library_definitions/reports/01_c3-c4-library-definitions.md
- **Artifacts**: plans/01_c3-c4-library-definitions.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Promote the alternative consequence relations C3 and C4 from the archived probe files into the
library: a convex-index truth recursion written beside the library's own truth definition, the two
validity notions, the germ theorems, shift invariance, the C1/C3/C4 separations, and the
axiom-survival table as one theorem per row, including the six failures and the four gaps the
source table left open. C1 is left semantically untouched; the library build must be green with no
new sorry at the end of every phase. Definition of done: all 50 pinned statements below are proved
sorry-free, the named alternative box range exists as a definition, and the full gate set passes.

### Research Integration

The research report is the primary input. Its module layout, its phasing and its API-drift
findings are adopted. One thing is NOT adopted at face value: the report's executive summary says
that a sorry-free path exists for every deliverable and that no axiom's status is left open. The
evidence behind the individual rows is of four different strengths, and this plan keeps them
apart, because a phase that ports a checked proof and a phase that must find a proof for the first
time carry different risk.

| Evidence tier | Rows | What it licenses |
|---|---|---|
| Proof machine-checked against the LIVE tree (research probe `probes/01_gap-closures.lean`, via the LSP, never `lake build`) | the clause lemmas, NA (`discrete_propagate_bwd`), Z1, Prior-U, Sep, the C4 last-point validity and its C3 refutation, the C1 seriality validity, the BOX STEP ONLY of shift invariance | Port, then confirm under a real build |
| Proof machine-checked against the OLD tree only (archived 553 probes 02/03, over the since-deleted convex-history structure) | germ theorems, necessitation, the five S5 rows, `connect_future`, `until_F`, `F_until_equiv`, `modal_future`, the six refutations, the full shift-invariance induction | Port with API repair; the `untl`/`snce` cases of shift invariance were not re-run |
| Audited by argument only, never machine-checked anywhere | the four propositional rows, `left_mono_until_G`, `right_mono_until`, `enrichment_until`, `self_accum_until`, `absorb_until`, `linear_until`, `temp_linearity`, `prior_UZ`, `density`, `dense_indicator`, and every past mirror other than those in the row above | A proof must be found. The SURVIVES verdict is a hypothesis until it compiles |
| Not checked at all | `prior_S_gap` under C3 (the report estimates about 45 lines and says so) | As above |

Planning-time check performed for this plan: the 50 statements in the Lean Challenge Statements
section were elaborated together, with `sorry` bodies, against the live tree through the LSP. The
result was 50 sorry warnings and no errors. That establishes that the statements are well-formed
against today's API. It establishes nothing about whether any of them is true.

Other adopted findings:
- The index type is a partial history plus the convexity predicate; there is no convex-history
  structure to reuse, and the library's truth definition is indexed by total histories, so C2 is
  no longer statable with it. C2 is recorded in a docstring as retired by the type.
- The abstract clause layer fixes a total-history index and cannot be instantiated; C3 carries its
  own clause lemmas.
- The one-point history already exists as `PartialHistory.point`; only its convexity lemma is new.
- The axiom inductive has 29 constructors. Two of the six named failures (`serial_past`,
  `discrete_symm_bwd`) are now derived time-reflection mirrors, not constructors, and are stated
  against the formulas `DerivedAxioms.serialPast` and `DerivedAxioms.discreteSymmBwd` derive.
- There is no semantic time-reflection soundness to inherit from, so a mirror row's verdict is not
  implied by its forward row. Each mirror needs its own proof.
- A C3-versus-C4 separation is new since the source report: the containment is strict.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch.

## Goals & Non-Goals

**Goals**:
- Containment and box structure: `validC3_imp_validC4`, `truthC3_box_indep`.
- Germ theorems: `germ_untl_false`, `germ_snce_false`, `c3_box_untl_unsat`, `c3_box_snce_unsat`,
  `c3_nec`, `c3_valid_imp_germ_valid`.
- Time uniformity: `truthC3_timeShift`, `c3_box_time_uniform`.
- Separations: `valid_C1_someFuture_top`, `refute_C3_someFuture_top`, `refute_C3_somePast_top`,
  `refute_C4_someFuture_top`, `validC4_lastPoint`, `refute_C3_lastPoint`.
- The six failures: `refute_C3_serial_future`, `refute_C3_serial_past`,
  `refute_C3_discrete_symm_fwd`, `refute_C3_discrete_symm_bwd`,
  `refute_C3_discrete_propagate_fwd`, `refute_C3_discrete_box_necessity`.
- Propositional and S5 survivals: `c3_prop_k`, `c3_prop_s`, `c3_ex_falso`, `c3_peirce`,
  `c3_modal_t`, `c3_modal_4`, `c3_modal_b`, `c3_modal_5_collapse`, `c3_modal_k_dist`.
- Tense survivals: `c3_left_mono_until_G`, `c3_right_mono_until`, `c3_connect_future`,
  `c3_enrichment_until`, `c3_self_accum_until`, `c3_absorb_until`, `c3_linear_until`,
  `c3_until_F`, `c3_temp_linearity`, `c3_F_until_equiv`.
- Interaction and uniformity survivals: `c3_modal_future`, `c3_discrete_propagate_bwd`.
- Frame-class survivals and the gap closures: `c3_prior_UZ`, `c3_z1`, `c3_density`,
  `c3_dense_indicator`, `c3_prior_U_gap`, `c3_prior_S_gap`, `c3_sep`.

**Supporting declarations (delivered, but not challenge identifiers)**:
- Carriers, written out in full in the challenge preamble: `TruthAtConvex`, `ValidC3`,
  `IsInterval`, `ValidC4`, the integer-time frame `NF`, the formula `lastPoint`, and the two gap
  formulas `gapFwd` / `gapBwd`. The library declares the first four with `def`.
- Class-level and consequence wrappers: `ValidC3In`, `ValidC4In`, `ConsequenceC3`,
  `ConsequenceC4`.
- Machinery: `IsInterval.isConvex`, `PartialHistory.point_isConvex`, and the clause lemmas
  (`and_iff`, `someFuture_iff`, `allFuture_iff`, `somePast_iff`, `allPast_iff`, `kPlus_iff`,
  `kMinus_iff`) under a C3 namespace; the fixtures `bdd`, `bdd01`, `totalNF` with their membership
  and convexity lemmas.
- The named alternative box range: `TruthAtConvexCut` (box over the convex histories whose domain
  contains the index's domain), with one contrast theorem.
- The remaining past mirrors, one per declaration in the "Base mirrors" and "Frame-class-gated
  mirrors" sections of `FormalSystem/ProofSystem/DerivedAxioms.lean`, plus the two linearity
  mirrors and the Sep mirror.
- The aggregate table theorem over the 29 constructors, with a Bool-valued `Axiom.failsC3`.
- Registration: aggregator imports, generated root, READMEs, an axiom-profile test.

**Non-Goals**:
- Any edit to the library's own truth definition, `ConsequenceOnFrames`, or any C1 validity
  notion. C1 is read, never written.
- Defining C2. It is documented as unexpressible at the current index type.
- Any claim that C3 equals Burgess-Xu without seriality plus S5. That is a completeness question
  and belongs to the sequel task; docstrings must not assert it.
- A second survival table for the cut-back box range. Only the definition and one contrast
  theorem are delivered.
- The minimum-length-interval variant of the box range (it needs a length parameter that is only
  natural on the integers or the reals).
- A model-reflection route to the mirrors (reversing frames and histories). It was not researched;
  the mirrors are proved by direct dualisation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An argued-only SURVIVES row is false under C3 (endpoint behaviour was reasoned about, never checked) | H | L | The statement is pinned. If a proof attempt produces a countermodel instead, mark the phase `[BLOCKED]` and escalate: a changed verdict is a finding for the author, not something to absorb by weakening the statement, adding a hypothesis, or silently flipping the theorem to a refutation |
| The 553-era proofs do not port cleanly (convexity is now a hypothesis threaded through the box clause; `natFrame` is built differently) | M | M | Known repairs are listed per phase: thread `PartialHistory.isConvex_timeShift` through the box case; discharge `respects_task` on the fixtures with `(FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl)` |
| Every research proof was checked through the LSP only, never under a real build, and the warning budget is zero | M | M | Phase 1 ends with a real scoped build. Expect Mathlib-style linter findings (long lines, unused variables, `push_neg` versus `push Not`); fix at source, never by suppression |
| Parallel phases edit the same two registration files (the directory aggregator and the generated root) | M | M | See the note under the wave table: registration edits are serialised, or same-wave phases run in numeric order |
| A module-invariant check fails on the new modules (C8 aggregator, C9 task numbers, C15 paper anchors, C24 Init import, C26 underscore-free `def`/`abbrev` names, C33 generated root) | M | M | Names in this plan are chosen C26-clean. Each file-creating phase regenerates the root with `lake exe mk_all --lib FormalSystem`. Docstrings cite theorem names and quoted paper text, never task numbers or paper line numbers |
| `NF` already exists as `FormalSystem.PlusLanguage.NF` | L | M | Declare a local reducible abbreviation in the new namespace rather than importing the Plus language into a base-language module. If a downstream file opens both namespaces the name becomes ambiguous; the interface-tier build in Phase 3 is what would surface that |
| The build guard rejects the invocation shape shown in the Lean rules file | L | H | Lake arguments must start at the subcommand: `-- build Module.Name`. A bare `-- Module.Name` exits 77 |
| The plan adds files outside the task's declared `file_scope` | L | H | Listed under Artifacts & Outputs. `file_scope` is prospective and is not rewritten here; the implementer's `modified_files` carries the real list |
| Docstrings overclaim what C3 is | M | L | Use the task's own wording: TM's S5 modal layer over a bounded-interval tense logic; every failure is an existence assertion. No identification with a known system |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 6 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 7, 9 | 5, 6 |
| 6 | 8 | 6, 7 |
| 7 | 10 | 8, 9 |

Phases within the same wave can execute in parallel, with one condition. Every file-creating phase
adds one import line to a shared aggregator and regenerates the root `FormalSystem.lean`. Two
same-wave phases must not make those two edits concurrently: either serialise the registration
step, or run the wave's phases in numeric order.

Build invocation used throughout (detached, guarded, never a foreground `lake build`):
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <Module.Name>`

---

### Phase 1: Core definitions, clause lemmas and germ structure [COMPLETED]

**Goal**: Land `FormalSystem/Semantics/ConvexTruth.lean` with the C3/C4 definitions and everything
that needs no shift invariance, wired into the build.

**Tasks**:
- [x] Create `FormalSystem/Semantics/ConvexTruth.lean` in namespace `FormalSystem.Semantics`,
      importing `Semantics.Truth`, `Semantics.Validity`, `Semantics.FrameProperty`,
      `Semantics.FrameClassValidity` and `Semantics.Extension.Extension`. Copyright header and
      module docstring per the repository standards.
- [x] Define `TruthAtConvex`, `ValidC3`, `IsInterval`, `ValidC4` exactly as in the challenge
      preamble, as `def`. The box clause carries the convexity hypothesis on the quantified
      history.
- [x] Define `ValidC3In`, `ValidC4In` (mirroring `ValidIn`) and `ConsequenceC3`, `ConsequenceC4`
      with a finite context (mirroring `ConsequenceOnFrames`).
- [x] Prove the clause lemmas. `and_iff`, `someFuture_iff`, `allFuture_iff`, `kPlus_iff`,
      `kMinus_iff` port from the research probe; `somePast_iff`, `allPast_iff` are their duals.
- [x] Prove `IsInterval.isConvex` and `PartialHistory.point_isConvex`.
- [x] Prove `validC3_imp_validC4`, `truthC3_box_indep`, `germ_untl_false`, `germ_snce_false`,
      `c3_box_untl_unsat`, `c3_box_snce_unsat`, `c3_nec`, `c3_valid_imp_germ_valid`. Germs use the
      library's `PartialHistory.point` and `F.worldNonempty.some`; do not define a second
      one-point history.
- [x] Module docstring: what C3 is (the task's wording), the quoted paper footnote, C2 retired by
      the index type, and the box-range working default with its rationale.
- [x] Register: import line in `FormalSystem/Semantics.lean`; regenerate `FormalSystem.lean`.
- [x] Scoped build of the new module, then of `FormalSystem.Semantics`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The five listed imports suffice and none pulls in `Metalogic`. Confirm by
the scoped build and by grepping the new file's import block.

**Files to modify**:
- `FormalSystem/Semantics/ConvexTruth.lean` - new
- `FormalSystem/Semantics.lean` - one import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Scoped builds green with zero warnings from the new file.
- `grep -c sorry FormalSystem/Semantics/ConvexTruth.lean` is 0.
- `git diff` shows no change to `FormalSystem/Semantics/Truth.lean` or `Validity.lean`.

---

### Phase 2: Shift invariance and the time-uniform box [COMPLETED]

**Goal**: Prove that C3 truth is invariant under translating the index, and derive time uniformity
of the box.

**Tasks**:
- [x] Prove `truthC3_timeShift` by induction on the formula. Atom, bot and imp cases are direct.
      The box case is the research probe's `truthC3_timeShift_box` argument, with
      `PartialHistory.isConvex_timeShift` supplying convexity of the shifted history in both
      directions.
- [x] Port the `untl` and `snce` cases from the archived probe 03. These were NOT re-run against
      the live tree; expect to adjust how domain membership of a shifted history unfolds.
- [x] Prove `c3_box_time_uniform` from it.
- [x] Docstring: this is the C3 analogue of `app:auto_existence`, and it is what settles
      `modal_future`.
- [x] Scoped build.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/ConvexTruth.lean` - two theorems appended

**Verification**:
- Scoped build green, zero warnings, no sorry.
- The signature of `truthC3_timeShift` matches the pinned statement verbatim.

---

### Phase 3: Fixtures and the C1 / C3 / C4 separations [COMPLETED]

**Goal**: Create the `Metalogic/ConvexConsequence/` cluster and land the separations, including
the strict containment of C3 in C4.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/ConvexConsequence/Separations.lean` in namespace
      `FormalSystem.Metalogic.ConvexConsequence`, importing `Semantics.ConvexTruth`,
      `Mathlib.Algebra.Order.Group.Int` and `Mathlib.Data.Int.SuccPred`.
- [x] Fixtures: `NF`, the one-point history `bdd` at 0, the two-point history `bdd01` on 0 and 1,
      and `totalNF`, each with membership, interval and convexity lemmas. Discharge
      `respects_task` with `(FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl)`.
- [x] Prove `valid_C1_someFuture_top` (stated with the library's frame-level validity),
      `refute_C3_someFuture_top`, `refute_C3_somePast_top`, `refute_C4_someFuture_top`.
- [x] Define `lastPoint`; prove `validC4_lastPoint` and `refute_C3_lastPoint` (both port from the
      research probe).
- [x] Create the sibling aggregator `FormalSystem/Metalogic/ConvexConsequence.lean` and a
      directory `README.md`; add the import to `FormalSystem/Metalogic.lean`; regenerate the root. *(deviation: altered — the README rows Phase 10 lists for `Semantics/README.md` and `Metalogic/README.md`, and the generated inventory blocks, were brought forward to this phase: the pre-phase invariant reading failed `INV` on the missing `ConvexTruth.lean` row, and the per-phase gate has to stay green. No `.lean` content is affected.)*
- [x] Build the new module, the aggregator, and `FormalSystem.Metalogic`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/ConvexConsequence/Separations.lean` - new
- `FormalSystem/Metalogic/ConvexConsequence.lean` - new aggregator
- `FormalSystem/Metalogic/ConvexConsequence/README.md` - new
- `FormalSystem/Metalogic.lean` - one import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Builds green, zero warnings, no sorry.
- `bash scripts/check-module-invariants.sh --no-build` reports no new failure against the
  pre-phase reading (capture that reading first; judge by diff).

---

### Phase 4: Ported survival rows and the six failures [NOT STARTED]

**Goal**: Land every row whose proof already exists in the archived probes, repaired for the
current API.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/ConvexConsequence/AxiomSurvival.lean`, importing
      `Separations` (for the fixtures). Register it in the aggregator and regenerate the root.
- [ ] Propositional rows: `c3_prop_k`, `c3_prop_s`, `c3_ex_falso`, `c3_peirce`. Argued-only in the
      source table but immediate from the `imp`/`bot` clauses.
- [ ] S5 rows: `c3_modal_t`, `c3_modal_4`, `c3_modal_b`, `c3_modal_5_collapse`,
      `c3_modal_k_dist`. Each now threads the convexity hypothesis of the box clause.
- [ ] Ported tense rows: `c3_connect_future`, `c3_until_F`, `c3_F_until_equiv`.
- [ ] `c3_modal_future`, via `c3_box_time_uniform`.
- [ ] `c3_discrete_propagate_bwd`, ported from the research probe.
- [ ] Endpoint helper lemmas on `bdd01` (a forward gap at 0, none at 1; a backward gap at 1, none
      at 0), then the six refutations: `refute_C3_serial_future`, `refute_C3_serial_past`,
      `refute_C3_discrete_symm_fwd`, `refute_C3_discrete_symm_bwd`,
      `refute_C3_discrete_propagate_fwd`, `refute_C3_discrete_box_necessity`. The last is
      `c3_box_untl_unsat` applied to a named axiom.
- [ ] Scoped build.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Scope Hypothesis**: 15 survival theorems and 6 refutations land in this phase. Confirm the count
against the Goals list at phase close; any row moved to Phase 5 is recorded in the phase notes, not
dropped.

**Files to modify**:
- `FormalSystem/Metalogic/ConvexConsequence/AxiomSurvival.lean` - new
- `FormalSystem/Metalogic/ConvexConsequence.lean` - one import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Scoped build green, zero warnings, no sorry.
- Each refutation is stated against the exact formula of its `Axiom` constructor or
  `DerivedAxioms` mirror (compare by reading both).

---

### Phase 5: The argued-only Burgess-Xu block [NOT STARTED]

**Goal**: Find and land proofs for the seven tense rows that have never been machine-checked.

**Tasks**:
- [ ] `c3_left_mono_until_G` and `c3_right_mono_until`: the restricted `G` reaches every guard
      point and the witness, because both lie in the domain by C3's own clause.
- [ ] `c3_enrichment_until`: the since-witness is the evaluation time itself, available because it
      is in the domain.
- [ ] `c3_self_accum_until` and `c3_absorb_until`: order arguments inside the domain.
- [ ] `c3_linear_until` and `c3_temp_linearity`: trichotomy on two domain witnesses. These are the
      case-heavy ones; use `and_iff` and unfold `Formula.or` deliberately rather than by `simp`.
- [ ] Scoped build.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: All seven rows survive. This is the source table's audited-by-argument
verdict and has no machine evidence behind it. If a row resists proof, first try to build a
two-point or three-point integer countermodel through the LSP; if one exists, stop and mark the
phase `[BLOCKED]` with the countermodel recorded.

**Files to modify**:
- `FormalSystem/Metalogic/ConvexConsequence/AxiomSurvival.lean` - seven theorems appended

**Verification**:
- Scoped build green, zero warnings, no sorry.
- All seven signatures match the pinned statements verbatim.

---

### Phase 6: Frame-class rows and the gap closures [NOT STARTED]

**Goal**: Land the six frame-class constructors' rows, three of which close gaps the source table
left open.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/ConvexConsequence/FrameClassSurvival.lean`, importing
      `Semantics.ConvexTruth` and `Metalogic.SoundnessLemmas.Separability`. Register and
      regenerate the root.
- [ ] Port from the research probe: `c3_z1` (backward induction along iterated predecessor),
      `c3_prior_U_gap` (supremum of a set capped at the refuting witness, so it lands in the
      domain; needs completeness only, not density), `c3_sep` (apply
      `SoundnessLemmas.sep_order` to the set of domain points satisfying the formula).
- [ ] New proofs: `c3_prior_UZ` (least witness by the same predecessor iteration as Z1),
      `c3_density` and `c3_dense_indicator` (density interpolates, convexity returns the point to
      the domain).
- [ ] Class-level corollaries at `ValidC3In` for each row, using `sat_intro` or `obtain`.
- [ ] Docstring on the endpoint behaviour of `K⁺`: vacuously true at a right endpoint, which only
      helps the Reynolds consequents.
- [ ] Scoped build.

**Timing**: 2 hours

**Depends on**: 1, 3

**Verification Tier**: local

**Scope Hypothesis**: `prior_UZ`, `density` and `dense_indicator` survive (argued-only). Same
escalation rule as Phase 5. The dependency on Phase 3 is for the directory scaffolding only.

**Files to modify**:
- `FormalSystem/Metalogic/ConvexConsequence/FrameClassSurvival.lean` - new
- `FormalSystem/Metalogic/ConvexConsequence.lean` - one import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Scoped build green, zero warnings, no sorry.
- `c3_prior_U_gap` takes the completeness hypothesis only, as pinned.
- `lean_verify` on `c3_sep`, `c3_z1`, `c3_prior_U_gap`: standard three axioms at most, no
  `sorryAx`.

---

### Phase 7: Base-class past mirrors [NOT STARTED]

**Goal**: One C3 theorem per base-class time-reflection mirror, proved by direct dualisation.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/ConvexConsequence/Mirrors.lean`; register and regenerate.
- [ ] For each declaration in the "Base mirrors" section of
      `FormalSystem/ProofSystem/DerivedAxioms.lean` not already covered by Phase 4, and for
      `linearSince` and `tempLinearityPast`, state the C3 validity of exactly the formula that
      declaration derives, and prove it by dualising the forward proof.
- [ ] Module docstring: why mirror verdicts are not inherited (there is no semantic
      time-reflection soundness on a single frame).
- [ ] Scoped build.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: About ten mirrors: left and right monotonicity, connect, enrichment,
self-accumulation, absorption, since-P, P-since equivalence, and the two linearity mirrors.
Confirm the list by reading `DerivedAxioms.lean` at implementation time; the file is the authority,
not this count.

**Files to modify**:
- `FormalSystem/Metalogic/ConvexConsequence/Mirrors.lean` - new
- `FormalSystem/Metalogic/ConvexConsequence.lean` - one import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Scoped build green, zero warnings, no sorry.
- Every mirror theorem's formula is syntactically the one its `DerivedAxioms` counterpart derives.

---

### Phase 8: Frame-class past mirrors, including Prior-S [NOT STARTED]

**Goal**: Close the last named gap, `prior_S_gap`, and the remaining frame-class mirrors.

**Tasks**:
- [ ] `c3_prior_S_gap`: dual of Phase 6's Prior-U proof. Greatest lower bound via
      `SoundnessLemmas.exists_isGLB_of_lub`; the set is capped below at the refuting witness.
      This proof has never been checked anywhere.
- [ ] The Prior-SZ mirror (dual of `c3_prior_UZ`, via successor iteration).
- [ ] The Sep mirror, via `SoundnessLemmas.sep_order_mirror`.
- [ ] Scoped build.

**Timing**: 2 hours

**Depends on**: 6, 7

**Verification Tier**: local

**Scope Hypothesis**: `prior_S_gap` survives on every complete frame with no density hypothesis,
by symmetry with Prior-U. Same escalation rule as Phase 5.

**Files to modify**:
- `FormalSystem/Metalogic/ConvexConsequence/Mirrors.lean` - three theorems appended

**Verification**:
- Scoped build green, zero warnings, no sorry.
- `c3_prior_S_gap` matches the pinned statement verbatim; `lean_verify` shows no `sorryAx`.

---

### Phase 9: The named alternative box range and the aggregate table [NOT STARTED]

**Goal**: Deliver the cut-back variant as a named definition, and state the table as one theorem.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/ConvexTruthCut.lean`: `TruthAtConvexCut`, identical to the
      primary recursion except that the box ranges over convex histories whose domain contains
      the index's domain. One contrast theorem: a boxed seriality formula is satisfiable under the
      cut variant at a total index of `NF`, where `c3_box_untl_unsat` makes it unsatisfiable under
      the primary reading. If the contrast theorem needs the integer fixtures, place it in the
      `ConvexConsequence` cluster instead and keep the definition in `Semantics/`.
- [ ] Docstring: the cut variant is index-dependent, so `truthC3_box_indep` fails for it and its
      survival table is not the primary one's. State the working default and that an override
      changes what the completeness sequel is about.
- [ ] Create `FormalSystem/Metalogic/ConvexConsequence/SurvivalTable.lean`: a Bool-valued
      `Axiom.failsC3` naming the four failing constructors, and the aggregate theorem that every
      other constructor is C3-valid on its minimum frame class, by cases over the 29 constructors,
      each case one of the row theorems.
- [ ] Register both files and regenerate the root. Scoped builds.

**Timing**: 1.5 hours

**Depends on**: 5, 6

**Verification Tier**: interface

**Scope Hypothesis**: The constructor count is 29 with four failing. Confirm with the `cases`
goal list; an unmatched constructor is a missing row, to be reported, not closed by a wildcard.

**Files to modify**:
- `FormalSystem/Semantics/ConvexTruthCut.lean` - new
- `FormalSystem/Metalogic/ConvexConsequence/SurvivalTable.lean` - new
- `FormalSystem/Semantics.lean`, `FormalSystem/Metalogic/ConvexConsequence.lean` - import lines
- `FormalSystem.lean` - regenerated

**Verification**:
- Scoped builds green, zero warnings, no sorry.
- The aggregate proof contains no wildcard case.

---

### Phase 10: Tests, documentation, registration and the full gate [NOT STARTED]

**Goal**: Pin the axiom profiles, bring the documentation into line, and run the complete gate
set.

**Tasks**:
- [ ] Create `Tests/BimodalTest/Semantics/ConvexTruthTest.lean`, modelled on
      `OpenLanguageAxiomTest.lean`: `#guard_msgs`-gated `#print axioms` blocks for the four gap
      closures, `truthC3_timeShift`, `c3_box_untl_unsat`, and one refutation. Expected strings are
      measured, not guessed. Import it from `Tests/BimodalTest.lean`.
- [ ] Amend the module docstring of `FormalSystem/Semantics/PartialHistory.lean`: the sentence
      saying no proof consumes convexity as a hypothesis is no longer true; name the C3 module as
      the consumer. Documentation only.
- [ ] README rows: `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md`,
      `FormalSystem/README.md`, `Tests/BimodalTest/Semantics/README.md`, and the root `README.md`
      if it lists module clusters.
- [ ] `docs/reference/paper-definitions-of-record.md`: record the paper's alternative-semantics
      footnote verbatim, checked against the paper source named in that file's provenance section,
      as prose anchored to `def:logical-consequence`. Add a manifest row only if the file's
      hashing method admits an unlabelled footnote; otherwise say in the entry that it is
      unpinned and why.
- [ ] Full build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, then
      the test library.
- [ ] Full gate: `bash scripts/check-module-invariants.sh`, plus the copyright-header, README-lint
      and paper-definitions checks.
- [ ] Repository-wide sorry count unchanged from the pre-task reading.

**Timing**: 2 hours

**Depends on**: 8, 9

**Verification Tier**: full

**Scope Hypothesis**: Five READMEs need a row. Confirm with `bash scripts/readme-lint.sh` and
`bash scripts/readme-inventory.sh`; the lint output is the authority.

**Files to modify**:
- `Tests/BimodalTest/Semantics/ConvexTruthTest.lean` - new
- `Tests/BimodalTest.lean` - one import line
- `FormalSystem/Semantics/PartialHistory.lean` - docstring only
- the READMEs listed above
- `docs/reference/paper-definitions-of-record.md` - one entry

**Verification**:
- Full build and test build exit 0; the warning budget stays at zero.
- Every gate script exits 0, or any failure is shown by diff to predate this task.
- `git diff` over the whole task shows no semantic change to `Truth.lean` or `Validity.lean`.

## Lean Challenge Statements

**Authoring note.** The snapshot tool matches `theorem|lemma|def|instance` followed by a simple
name, forces that declaration's body to `sorry`, and discards everything from the `:=` to the next
matched declaration. The block is shaped accordingly: every carrier sits in the preamble as
`abbrev` (not matched, so its body survives and it stays out of the identifier set), no declaration
name is dotted, and nothing follows the last theorem. Consequences for the implementer: the library
declares `TruthAtConvex`, `ValidC3`, `IsInterval` and `ValidC4` with `def`, not `abbrev`; the
fixtures and every theorem from `valid_C1_someFuture_top` onward live in
`FormalSystem.Metalogic.ConvexConsequence`, where this block keeps a single namespace; and `gapFwd`
/ `gapBwd` are challenge-local shorthands for the two formulas the `Axiom` constructors spell out
in full (the library may state those rows either way, since the abbreviations unfold
syntactically). The block was elaborated standalone against the live tree at plan time: 50 sorry
warnings, no errors. That checks well-formedness only.

**Known snapshot-tool defect, observed at plan time.** Run in this host's ambient locale
(`en_US.UTF-8`), `lean-challenge-snapshot.sh 568 <root> --dry-run` exits 71 and reports an
identifier-set mismatch that lists the SAME twelve names on both sides, after `comm: input is not
in sorted order`. The two sets are in fact identical (50 and 50, empty diff). The tool sorts one
side with the shell's locale collation and the other by code point, and this plan's mixed-case
names (`c3_prior_U_gap` beside `c3_prior_UZ`, `valid_C1_…` beside `validC3_…`) are where those
orders differ. Under `LC_ALL=C` the same dry run exits 0 with all 50 names, 50 forced-sorry bodies
and the 8 preamble abbreviations intact. Whoever takes the snapshot must run it under `LC_ALL=C`
until the tool is fixed at its source; the identifiers are the task's own names and are not to be
renamed to work around it.

```lean
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.Extension.Extension
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {F : TaskFrame}

abbrev TruthAtConvex (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) : Formula → Prop
  | .atom p => ∃ ht : τ.domain t, M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => TruthAtConvex M τ t φ → TruthAtConvex M τ t ψ
  | .box φ => ∀ σ : PartialHistory F, σ.IsConvex → σ.domain t → TruthAtConvex M σ t φ
  | .untl ψ φ => ∃ s : F.Duration, τ.domain s ∧ t < s ∧ TruthAtConvex M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → t < r → r < s → TruthAtConvex M τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, τ.domain s ∧ s < t ∧ TruthAtConvex M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → s < r → r < t → TruthAtConvex M τ r ψ

abbrev ValidC3 (F : TaskFrame) (φ : Formula) : Prop :=
  ∀ (M : TaskModel F) (τ : PartialHistory F), τ.IsConvex →
    ∀ x : F.Duration, τ.domain x → TruthAtConvex M τ x φ

abbrev IsInterval (τ : PartialHistory F) : Prop :=
  ∃ a b : F.Duration, ∀ t : F.Duration, τ.domain t ↔ (a ≤ t ∧ t ≤ b)

abbrev ValidC4 (F : TaskFrame) (φ : Formula) : Prop :=
  ∀ (M : TaskModel F) (τ : PartialHistory F), IsInterval τ →
    ∀ x : F.Duration, τ.domain x → TruthAtConvex M τ x φ

abbrev NF : TaskFrame := FrameOver.natFrame (D := ℤ)

abbrev lastPoint : Formula :=
  (Formula.someFuture Formula.top).imp (Formula.someFuture (Formula.allFuture Formula.bot))

abbrev gapFwd : Formula := Formula.untl Formula.bot (Formula.bot.imp Formula.bot)

abbrev gapBwd : Formula := Formula.snce Formula.bot (Formula.bot.imp Formula.bot)

theorem validC3_imp_validC4 {φ : Formula} (h : ValidC3 F φ) : ValidC4 F φ := sorry

theorem truthC3_box_indep (M : TaskModel F) (τ τ' : PartialHistory F) (x : F.Duration)
    (φ : Formula) :
    TruthAtConvex M τ x (Formula.box φ) ↔ TruthAtConvex M τ' x (Formula.box φ) := sorry

theorem germ_untl_false (M : TaskModel F) (w : F.WorldState) (x : F.Duration) (ψ φ : Formula) :
    ¬ TruthAtConvex M (PartialHistory.point F w x) x (Formula.untl ψ φ) := sorry

theorem germ_snce_false (M : TaskModel F) (w : F.WorldState) (x : F.Duration) (ψ φ : Formula) :
    ¬ TruthAtConvex M (PartialHistory.point F w x) x (Formula.snce ψ φ) := sorry

theorem c3_box_untl_unsat (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration)
    (ψ φ : Formula) : ¬ TruthAtConvex M τ x (Formula.box (Formula.untl ψ φ)) := sorry

theorem c3_box_snce_unsat (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration)
    (ψ φ : Formula) : ¬ TruthAtConvex M τ x (Formula.box (Formula.snce ψ φ)) := sorry

theorem c3_nec {φ : Formula} (h : ValidC3 F φ) : ValidC3 F (Formula.box φ) := sorry

theorem c3_valid_imp_germ_valid {φ : Formula} (h : ValidC3 F φ) (M : TaskModel F)
    (w : F.WorldState) (x : F.Duration) :
    TruthAtConvex M (PartialHistory.point F w x) x φ := sorry

theorem truthC3_timeShift (M : TaskModel F) (φ : Formula) :
    ∀ (σ : PartialHistory F) (z Δ : F.Duration),
      TruthAtConvex M (σ.timeShift Δ) z φ ↔ TruthAtConvex M σ (z + Δ) φ := sorry

theorem c3_box_time_uniform (M : TaskModel F) (τ τ' : PartialHistory F) (x y : F.Duration)
    (φ : Formula) (h : TruthAtConvex M τ x (Formula.box φ)) :
    TruthAtConvex M τ' y (Formula.box φ) := sorry

theorem valid_C1_someFuture_top : NF.ValidOn (Formula.someFuture Formula.top) := sorry

theorem refute_C3_someFuture_top : ¬ ValidC3 NF (Formula.someFuture Formula.top) := sorry

theorem refute_C3_somePast_top : ¬ ValidC3 NF (Formula.somePast Formula.top) := sorry

theorem refute_C4_someFuture_top : ¬ ValidC4 NF (Formula.someFuture Formula.top) := sorry

theorem validC4_lastPoint : ValidC4 F lastPoint := sorry

theorem refute_C3_lastPoint : ¬ ValidC3 NF lastPoint := sorry

theorem refute_C3_serial_future :
    ¬ ValidC3 NF (Formula.someFuture (Formula.bot.imp Formula.bot)) := sorry

theorem refute_C3_serial_past :
    ¬ ValidC3 NF ((Formula.bot.imp Formula.bot).imp
      (Formula.somePast (Formula.bot.imp Formula.bot))) := sorry

theorem refute_C3_discrete_symm_fwd : ¬ ValidC3 NF (gapFwd.imp gapBwd) := sorry

theorem refute_C3_discrete_symm_bwd : ¬ ValidC3 NF (gapBwd.imp gapFwd) := sorry

theorem refute_C3_discrete_propagate_fwd :
    ¬ ValidC3 NF (gapFwd.imp (Formula.allFuture gapFwd)) := sorry

theorem refute_C3_discrete_box_necessity :
    ¬ ValidC3 NF (gapFwd.imp (Formula.box gapFwd)) := sorry

theorem c3_prop_k (φ ψ χ : Formula) :
    ValidC3 F ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := sorry

theorem c3_prop_s (φ ψ : Formula) : ValidC3 F (φ.imp (ψ.imp φ)) := sorry

theorem c3_ex_falso (φ : Formula) : ValidC3 F (Formula.bot.imp φ) := sorry

theorem c3_peirce (φ ψ : Formula) : ValidC3 F (((φ.imp ψ).imp φ).imp φ) := sorry

theorem c3_modal_t (φ : Formula) : ValidC3 F ((Formula.box φ).imp φ) := sorry

theorem c3_modal_4 (φ : Formula) :
    ValidC3 F ((Formula.box φ).imp (Formula.box (Formula.box φ))) := sorry

theorem c3_modal_b (φ : Formula) : ValidC3 F (φ.imp (Formula.box φ.diamond)) := sorry

theorem c3_modal_5_collapse (φ : Formula) : ValidC3 F (φ.box.diamond.imp φ.box) := sorry

theorem c3_modal_k_dist (φ ψ : Formula) :
    ValidC3 F ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := sorry

theorem c3_left_mono_until_G (φ χ ψ : Formula) :
    ValidC3 F ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ))) := sorry

theorem c3_right_mono_until (φ ψ χ : Formula) :
    ValidC3 F ((φ.imp ψ).allFuture.imp ((Formula.untl χ φ).imp (Formula.untl χ ψ))) := sorry

theorem c3_connect_future (φ : Formula) : ValidC3 F (φ.imp φ.somePast.allFuture) := sorry

theorem c3_enrichment_until (φ ψ p : Formula) :
    ValidC3 F ((Formula.and p (Formula.untl φ ψ)).imp
      (Formula.untl φ (Formula.and ψ (Formula.snce φ p)))) := sorry

theorem c3_self_accum_until (φ ψ : Formula) :
    ValidC3 F ((Formula.untl φ ψ).imp
      (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ)) := sorry

theorem c3_absorb_until (φ ψ : Formula) :
    ValidC3 F ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp
      (Formula.untl φ ψ)) := sorry

theorem c3_linear_until (φ ψ χ θ : Formula) :
    ValidC3 F ((Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)).imp
      (Formula.or (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
        (Formula.or (Formula.untl (Formula.and φ χ) (Formula.and ψ χ))
          (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))) := sorry

theorem c3_until_F (φ ψ : Formula) :
    ValidC3 F ((Formula.untl φ ψ).imp (Formula.someFuture ψ)) := sorry

theorem c3_temp_linearity (φ ψ : Formula) :
    ValidC3 F ((Formula.and (Formula.someFuture φ) (Formula.someFuture ψ)).imp
      (Formula.or (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))))) := sorry

theorem c3_F_until_equiv (φ : Formula) :
    ValidC3 F ((Formula.someFuture φ).imp
      (Formula.untl (Formula.bot.imp Formula.bot) φ)) := sorry

theorem c3_modal_future (φ : Formula) :
    ValidC3 F ((Formula.box φ).imp (Formula.box (Formula.allFuture φ))) := sorry

theorem c3_discrete_propagate_bwd : ValidC3 F (gapFwd.imp (Formula.allPast gapFwd)) := sorry

theorem c3_prior_UZ (hZ : F.IsZTime) (φ : Formula) :
    ValidC3 F (φ.someFuture.imp (Formula.untl φ.neg φ)) := sorry

theorem c3_z1 (hZ : F.IsZTime) (φ : Formula) :
    ValidC3 F ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := sorry

theorem c3_density (hd : F.IsDense) (φ : Formula) :
    ValidC3 F (φ.allFuture.allFuture.imp φ.allFuture) := sorry

theorem c3_dense_indicator (hd : F.IsDense) : ValidC3 F gapFwd.neg := sorry

theorem c3_prior_U_gap (hc : F.IsComplete) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
      (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) := sorry

theorem c3_prior_S_gap (hc : F.IsComplete) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg)))) := sorry

theorem c3_sep (hR : F.IsRTime) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
      (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := sorry
```

## Testing & Validation

- [ ] `lake build FormalSystem` (through the guard) green at the end of every phase, with no new
      sorry.
- [ ] All 50 pinned statements are present with matching signatures; no hypothesis added, no
      quantifier specialised.
- [ ] `lean_verify` on the four gap closures, `c3_prior_S_gap` and `truthC3_timeShift`: no
      `sorryAx`, no axiom beyond `propext`, `Classical.choice`, `Quot.sound`.
- [ ] The axiom-profile test module compiles, so the measured profiles are build-breaking pins.
- [ ] `git diff` across the task shows no semantic edit to the library's truth or validity
      modules.
- [ ] `scripts/check-module-invariants.sh` and the README, copyright and paper-definition checks
      pass, or each failure is shown to predate the task.
- [ ] Warning budget unchanged at zero.

## Artifacts & Outputs

- `FormalSystem/Semantics/ConvexTruth.lean`
- `FormalSystem/Semantics/ConvexTruthCut.lean` (outside the declared `file_scope`)
- `FormalSystem/Metalogic/ConvexConsequence.lean`
- `FormalSystem/Metalogic/ConvexConsequence/Separations.lean`
- `FormalSystem/Metalogic/ConvexConsequence/AxiomSurvival.lean`
- `FormalSystem/Metalogic/ConvexConsequence/FrameClassSurvival.lean` (outside `file_scope`)
- `FormalSystem/Metalogic/ConvexConsequence/Mirrors.lean` (outside `file_scope`)
- `FormalSystem/Metalogic/ConvexConsequence/SurvivalTable.lean` (outside `file_scope`)
- `FormalSystem/Metalogic/ConvexConsequence/README.md`
- `Tests/BimodalTest/Semantics/ConvexTruthTest.lean`, `Tests/BimodalTest.lean` (the latter outside
  `file_scope`)
- Edited: `FormalSystem.lean`, `FormalSystem/Semantics.lean`, `FormalSystem/Metalogic.lean`,
  `FormalSystem/Semantics/PartialHistory.lean` (docstring), five READMEs,
  `docs/reference/paper-definitions-of-record.md`
- `specs/568_c3_c4_consequence_relations_as_library_definitions/summaries/01_c3-c4-library-definitions-summary.md`

The survival rows are split across four files rather than the two the task's `file_scope`
anticipated, to stay well under the 1500-line long-file linter threshold and to let the
frame-class rows proceed independently of the base rows.

## Rollback/Contingency

Every phase adds new files plus one-line import registrations; nothing existing is rewritten
except one docstring and documentation. Each phase is committed when green, so rollback is
`git revert` of the offending phase commits in reverse order, followed by regenerating the root
with `lake exe mk_all --lib FormalSystem`. No working-tree discard is needed and none should be
used; on a build error, fix forward.

If a pinned SURVIVES statement proves false, do not roll back: the phase is marked `[BLOCKED]`,
the rows already landed stay, and the countermodel goes to the author, because it changes the
table's verdict and therefore what the completeness sequel is about. If a proof is merely hard,
the recovery ladder in `.claude/context/contracts/recovery.md` applies; a strategic sorry would
breach this task's no-new-sorry constraint and needs the author's agreement first.
