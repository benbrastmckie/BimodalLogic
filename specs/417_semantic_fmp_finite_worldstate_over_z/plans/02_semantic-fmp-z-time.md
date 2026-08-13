# Implementation Plan: Semantic FMP over ℤ-Time (finite WorldState)

- **Task**: 417 - `semantic_fmp_finite_worldstate_over_z`
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: 414 (totality semantics — landed), 420 (four-axiom `TaskFrame` — landed), 438 (paper reconciliation — landed)
- **Research Inputs**: `specs/417_semantic_fmp_finite_worldstate_over_z/reports/02_semantic-fmp-rescoped-z-time.md` (authoritative); `reports/01_semantic-fmp-finite-worldstate.md` (superseded, retained as history)
- **Artifacts**: plans/02_semantic-fmp-z-time.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Deliver a `TruthAt`-connected finite model property for the **ℤ-time** discrete case, plus a
decidable model-checking presentation for finite-`W`-over-ℤ frames. The spine is a **ℤ-frame
normal form**: over `D = ℤ` every `TaskFrame` is determined by its one-step relation, `H_F` is
exactly the set of bi-infinite step-paths, and time-homogeneity makes the `□` clause a model
constant. The finite frame itself already exists (`FiniteFilteredTaskFrame ℤ φ`) and already
carries all four axioms — the truth lemma is the whole remaining mathematical job, and its
`untl`/`snce` eventuality-fulfilment core is isolated in a dedicated phase with a `[BLOCKED]`
escalation route rather than a `sorry` deferral.

**Definition of done**: the semantic FMP theorem over ℤ-time is machine-checked; `IntPresentation.check`
has a proved `= true ↔ TruthAt …` correctness bridge; the repository's live-`sorry` count is
still exactly 1 (`Metalogic/WeakCanonical/Transfer.lean`, invariant C3); `lake build` is green.

### Research Integration

The plan is written against report `02_semantic-fmp-rescoped-z-time.md` and adopts all six of its
Decisions. Three of its results are already machine-checked (zero diagnostics) and are transcribed
rather than re-derived: `spherical_of_finite` (Phase 2), `iter`/`iter_add` (Phase 3), and the
Seriality-independence counterexample (which fixes Seriality as a genuine per-construction
obligation, Phase 5). Its stale-name corrections are binding: use `TaskFrame.limit_of_succOrder`
(never `limit_nullity_of_succOrder`, which does not exist), and do not attempt to reuse or repair
`validity_decidable`, which has been deleted with a retirement note.

**Target correction (load-bearing).** The task description's target — "satisfiable over the
**Discrete** class ⇒ satisfiable with finite `W` over `D = ℤ`" — is **refuted by the paper itself**:
`CO` is refutable on the discrete order `ℤ ×_lex ℤ` yet valid in every model over `D = ℤ`, so the
implication has a counterexample. `cor:tm-decidability` has deleted that premise as false and now
states decidability as **open**. This plan targets **ℤ-time** (successor-Archimedean discrete),
which is what Lean's `ValidDiscrete`/`satisfiable ℤ` vocabulary already expresses. No phase may
restate the Discrete-class target. The remaining six stale points are inventoried in the report's
Appendix A and are corrected inline in the phases below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task (no `roadmap_path` in the delegation context).

## Goals & Non-Goals

**Goals**:
- Establish a `TruthAt`-connected finite model property over **ℤ-time**: every formula satisfiable
  over ℤ-time is satisfiable in a model with finite `WorldState` over `D = ℤ`.
- Land the ℤ-frame normal form as reusable library content: `iter`/`iter_add`,
  `TaskFrame.step`/`taskRel_eq_iter` (decomposition), `TaskFrame.ofStep` (synthesis),
  `mem_HF_iff_adjacent`, and `box_const`.
- Land `TaskFrame.spherical_of_finite` as a general library lemma (independently valuable to the
  sibling finite-carrier tasks).
- Deliver a computational presentation `IntPresentation` with a `Bool`-valued `check` and a proved
  `check … = true ↔ TruthAt …` correctness bridge, discharging part of the open obligation named
  in the `validity_decidable` retirement note.
- Keep the repository at exactly one live `sorry`.

**Non-Goals**:
- **No edits under `/home/benjamin/Philosophy/Papers/`.** The paper is read-only ground truth.
- No claim of decidability for TM or any of its variants. `cor:tm-decidability` states decidability
  is open; this work is a step toward it, not a proof of it.
- No FMP for the dense or complete frame classes, and no non-Archimedean carriers such as
  `ℤ ×_lex ℤ`.
- No deletion or rewrite of the existing syntactic closure-MCS FMP theorems in `FMP/`; this work
  adds the truth-connected layer above them.
- No revival of `validity_decidable` or `validity_has_decision_procedure`.
- No `sorry` anywhere, including as a temporary scaffold that a later phase would remove.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `untl`/`snce` eventuality fulfilment resists (six Boneyard precedents with sorries) | H | H | Isolated in Phase 9 with its own risk budget; pigeonhole/lasso machinery pre-landed in Phase 8 so Phase 9 is proof-assembly not tool-building; strategy stated up front; `[BLOCKED]` escalation for user review, **never** a `sorry` |
| Refuted Discrete-class target propagates back into the work | H | M | Target restated as ℤ-time in Overview, Goals, and every phase that names the theorem; Phase 10 verification includes a grep that no new declaration or docstring asserts the Discrete-class form |
| `cor:spherical-finite` is untracked and could drift | M | M | Phase 1 tracks it before any phase quotes it; `scripts/check-paper-definitions.sh` re-run at every phase boundary |
| Transfer from abstract succ-Archimedean `D` to concrete `ℤ` is not in the tree | M | M | Mathlib supplies `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` and `orderIsoIntOfLinearSuccPredArch`; binder fit is verified early, in Phase 3, before anything depends on it |
| `Finite` vs `Fintype` mismatch blocks the checker late | M | M | `IntPresentation` carries `Fin card` by construction (Phase 11), sequenced after the normal form lands; `FiniteTaskFrame.finite_world : Finite` is never used to drive `decide` |
| Live `sorry` count regresses from 1 | M | L | Verify with the repo's own regex via `scripts/check-module-invariants.sh`, never naive grep (which over-counts doc-comment prose); checked at every phase close |
| Paper drifts again mid-task (this neighborhood moved three times in four days) | M | M | Re-run `scripts/check-paper-definitions.sh` at every phase boundary; a case-(b)-or-worse result pauses the phase and re-quotes before proceeding |
| Adapting `regionFrame` is attempted as a shortcut | M | L | `not_regionConstant_regionHistory` forecloses any lasso argument on that carrier; the plan builds fresh on the normal form and phases name this explicitly |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 6 | -- |
| 2 | 4, 5 | 2, 3 |
| 3 | 7, 8, 11 | 4, 5, 6 |
| 4 | 9, 12 | 7, 8, 11 |
| 5 | 10 | 9 |
| 6 | 13 | 10, 12 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Track `cor:spherical-finite`, `lem:nesting`, `lem:nonempty` in the definitions record [NOT STARTED]

**Goal**: This task quotes `cor:spherical-finite` verbatim as its transcription source while that
anchor is **untracked** by `specs/paper-definitions-of-record.md` — so the central citation is
unprotected by the drift lint. Close that gap before any phase relies on the quote.

**Tasks**:
- [ ] Follow the record's own four-step extension protocol (its `## How to extend this record`
      section): resolve each anchor by `\label{}` name, never by line number.
- [ ] For each of `cor:spherical-finite`, `lem:nesting`, `lem:nonempty`, run
      `bash scripts/check-paper-definitions.sh --resolve "ANCHOR|KIND|ENCLOSING|LOCATOR"` and record
      the printed text and sha256.
- [ ] Add one `### \`ANCHOR\`` entry per anchor quoting the resolved text verbatim (including any
      in-block `%%` editorial comments — they are literal source text and are hashed).
- [ ] Add one row per anchor to the machine-readable manifest with the printed hash.
- [ ] Update the record's "Known residual gap" prose: it currently names these three as untracked
      and notes that tracked `thm:extension` cross-references untracked `cor:spherical-finite`.
      That note is discharged by this phase.
- [ ] Re-pin the provenance table's file checksum and line count if the run reports the paper moved.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Exactly three anchors are added and the record's tracked count moves from 26
to 29. Confirm at implementation time by `grep -c` over the manifest rows before and after, and by
the record's own stated count in its coverage-extension prose. If the paper has since renamed or
merged any of the three, record what the paper actually says — never restate or "improve" it.

**Files to modify**:
- `specs/paper-definitions-of-record.md` - three new anchor entries, three manifest rows, residual-gap prose discharged, provenance re-pin if needed

**Verification**:
- `bash scripts/check-paper-definitions.sh` (no arguments) reports the quiet case-(a) pass.
- The three anchors each appear in both the entry section and the manifest.
- No file under `/home/benjamin/Philosophy/Papers/` is modified (`git -C /home/benjamin/Philosophy/Papers/PossibleWorlds status --porcelain` unchanged from its pre-phase state).

---

### Phase 2: Land `TaskFrame.spherical_of_finite` [NOT STARTED]

**Goal**: Transcribe `cor:spherical-finite` into `FormalSystem/Semantics/TaskFrame.lean` as a
general library lemma. The proof is already machine-checked (report Finding 2, zero diagnostics,
first attempt) — transcribe it, do not re-derive the argument.

**Tasks**:
- [ ] Add `theorem TaskFrame.spherical_of_finite {W : Type} [Finite W] (R : W → D → W → Prop) :
      TaskFrame.Spherical R` with the report's verified proof (`Set.Finite.exists_minimal` plus
      directedness; choice-free; the `IsFiber ∨ IsSegment` disjunct is never consumed).
- [ ] Place it beside the existing family (`spherical_of_subsingleton`, `spherical_of_permissive`,
      `spherical_of_eq`).
- [ ] Docstring must cite `cor:spherical-finite` via `specs/paper-definitions-of-record.md`, not by
      paper line number, and must record that the argument is indifferent to the kind of member
      (matching the paper's own `%% CHANGE (sigma-elim)` note).
- [ ] Re-derive `spherical_of_subsingleton`'s **proof body** through the new lemma. Its signature
      MUST NOT change — do not retire or rename it; downstream call sites (including the three
      `Unit`-carriered universal frames) must continue to elaborate unchanged.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The new declaration is ~12 lines and the only signature-affecting edit is
zero (additive declaration plus one proof-body rewrite). Confirm by enumerating direct dependents
of `TaskFrame.lean` that reference `spherical_of_subsingleton` (`grep -rn "spherical_of_subsingleton"
--include=*.lean`) and building each; if any dependent's elaboration changes, the interface
assumption is falsified and the phase escalates to a `full` gate.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - add `spherical_of_finite`; re-derive `spherical_of_subsingleton` body

**Verification**:
- Module builds with zero diagnostics; each enumerated dependent of `TaskFrame.lean` builds.
- `lean_verify TaskFrame.spherical_of_finite` shows no `Classical.choice` dependency beyond what
  the ambient `Finite`→`Set.Finite` route already carries; record the actual axiom list in the
  commit message.
- Live-`sorry` count still 1 via `scripts/check-module-invariants.sh`.

---

### Phase 3: ℤ normal form, decomposition direction [NOT STARTED]

**Goal**: Establish that over `D = ℤ` an arbitrary `TaskFrame ℤ` is determined by its one-step
relation. This is the plan's spine and every later phase consumes it.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Semantics/IntNormalForm.lean`).
- [ ] Transcribe the machine-checked arithmetic core verbatim: `iter (R : W → W → Prop) : ℕ → W → W → Prop`
      and `iter_add : iter R (m + n) w u ↔ ∃ v, iter R m w v ∧ iter R n v u`.
- [ ] Define `TaskFrame.step (F : TaskFrame ℤ) : F.WorldState → F.WorldState → Prop :=
      fun w u => F.TaskRel w 1 u`.
- [ ] Prove `taskRel_eq_iter`: for all `d : ℤ`, `F.TaskRel w d u ↔ (0 ≤ d → iter F.step d.natAbs w u)`
      and the negative-`d` case via the `converse` field. State it as a single clean
      characterization; the sign split is an implementation detail of the proof, not of the
      statement, if a uniform form is available.
- [ ] Derivation chain to follow (all field-carried, no new axioms): `⇒₀ = Eq` is the
      `nullity_identity` field; `⇒ₙ = step^n` for `n ≥ 0` by induction from `Compositional` at
      `x = n, y = 1`; negative durations by the `converse` field.
- [ ] Verify the Mathlib succ-Archimedean-to-ℤ binder fit early in this phase (report's Risks row):
      confirm `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` and
      `orderIsoIntOfLinearSuccPredArch` have binders compatible with `ValidDiscrete`'s
      `[SuccOrder] [PredOrder] [IsSuccArchimedean] [IsPredArchimedean] [Nontrivial]`. Record the
      finding in the module docstring even if the transfer itself is not used until Phase 10.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` (new) - `iter`, `iter_add`, `TaskFrame.step`, `taskRel_eq_iter`
- import-aggregator module (confirm which at implementation time)

**Verification**:
- New module builds with zero diagnostics.
- `iter_add` and `taskRel_eq_iter` each `lean_verify` clean.
- Binder-fit finding for the Mathlib ℤ transfer is recorded in the module docstring.

---

### Phase 4: `mem_HF_iff_adjacent` — `H_F` over ℤ is the bi-infinite step-paths [NOT STARTED]

**Goal**: Characterize the total-history space of an arbitrary `TaskFrame ℤ` as the set of
`τ : ℤ → WorldState` with `step (τ n) (τ (n+1))` for all `n`. This is what makes both the truth
lemma and the model checker tractable.

**Tasks**:
- [ ] Prove the forward direction: a total `WorldHistory` on ℤ satisfies the adjacency condition
      (instantiate `respects_task` at consecutive times).
- [ ] Prove the converse: any adjacency-satisfying `τ : ℤ → WorldState` yields a total
      `WorldHistory`; the all-pairs `respects_task` obligation follows from `taskRel_eq_iter` plus
      `iter_add`, by induction on the gap.
- [ ] State the result as `mem_HF_iff_adjacent` over `TaskFrame.HF`, in whichever of the two
      equivalent forms (predicate on histories vs. membership in `HF`) elaborates most cleanly;
      supply the other as a one-line corollary.
- [ ] Do **not** route through `regionFrame`. `not_regionConstant_regionHistory` machine-checks that
      no history on that carrier repeats a state, foreclosing every lasso argument on it; this phase
      exists precisely so later phases have an obstruction-free carrier.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` - `mem_HF_iff_adjacent` and its corollary form

**Verification**:
- Module builds with zero diagnostics; both directions are theorems, not `sorry`.
- A smoke `example` instantiates the characterization at an existing ℤ frame in the tree and closes.

---

### Phase 5: `TaskFrame.ofStep` synthesis + promote `customFrame` into the library [NOT STARTED]

**Goal**: The converse of Phase 3 — build a `TaskFrame ℤ` from a bi-serial relation on a finite
nonempty carrier — and validate it against the paper's own two-state witness.

**Tasks**:
- [ ] Define `TaskFrame.ofStep {W : Type} [Finite W] [Nonempty W] (R₁ : W → W → Prop)
      (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w) : TaskFrame ℤ`.
- [ ] Field discharges, per the report's axiom-discharge table: `nonempty` from the instance;
      `nullity_identity` free (`iter R 0 = Eq`); `comp` free via `iter_add`; `converse` free by
      construction; `limit` via `TaskFrame.limit_of_succOrder` (**this is the live name** —
      `limit_nullity_of_succOrder` does not exist and must not be written); `spherical` via
      `spherical_of_finite` from Phase 2.
- [ ] `serial` is the **one genuine obligation**: it is exactly bi-seriality of `R₁`, and it is
      **not** free over ℤ. The report machine-checks a counterexample (`R w d u := (d = 0)` on
      `W = Unit` satisfies `nullity_identity`, `Compositional`, `converse`, `Limit`, and `Spherical`
      but fails `Serial`, and finiteness does not rescue it). Take `fwd`/`bwd` as hypotheses; do not
      attempt to derive them.
- [ ] Add a module-level note recording that Seriality is free *from Occurrence*, never *from ℤ*.
- [ ] Promote `customFrame` (`Tests/BimodalTest/Semantics/TaskFrameTest.lean`, `WorldState := Bool`,
      `TaskRel := fun w d u => d ≠ 0 ∨ w = u`) into the library as the paper's canonical
      off-zero-universal two-state ℤ witness, with axiom discharges cited to the paper's
      `app:dense`/`app:deterministic` proof text via the definitions record.
- [ ] Leave the test file's coverage intact: the test may re-express `customFrame` as the library
      declaration or as an `ofStep` instance, but the existing test assertions must still run.
- [ ] The task description's rebase CAUTION is a **negative finding** and needs no action: no
      two-state universal-relation frame exists in the tree; all three universal frames
      (`trivialFrame`, `intTimeFrame`, `genericTimeFrame`) are `Unit`-carriered and get *Limit* free
      by `limit_of_subsingleton`. Do not search for or "repair" a nonexistent violating frame.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: interface

**Scope Hypothesis**: Promotion touches exactly two files (one library module, one test module) and
no other call site references `customFrame`. Confirm with
`grep -rn "customFrame" --include=*.lean` before editing; if the count exceeds the two files, widen
the phase's enumerated dependent set and rebuild each.

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` - `TaskFrame.ofStep` and its seven field discharges
- library home for the promoted witness (confirm at implementation time; `TaskFrame.lean` or `Examples/TemporalStructures.lean`)
- `Tests/BimodalTest/Semantics/TaskFrameTest.lean` - re-point `customFrame` at the library declaration

**Verification**:
- `ofStep` builds with zero diagnostics and all seven fields discharged without `sorry`.
- The promoted witness elaborates and its four axiom discharges are cited to record anchors.
- Test suite still passes; `TaskFrameTest.lean` assertions unchanged in meaning.

---

### Phase 6: `box_const` — `□` is a model constant [NOT STARTED]

**Goal**: Prove `TruthAt M τ t φ.box ↔ TruthAt M σ s φ.box` for all total `τ, σ` and all `t, s`.
This dissolves the round-1 assessment that the box clause was the hardest case: the set of total
histories is uncountable even for finite `W`, but the box **predicate** is constant on it.

**Tasks**:
- [ ] Prove `box_const` from time-homogeneity of `TaskRel` plus `WorldHistory.isTotal_timeShift`:
      `TruthAt M τ t (box φ)` unfolds to `∀ σ, σ.IsTotal → TruthAt M σ t φ`, which is already
      `τ`-independent by the clause itself; the `t`-independence comes from substituting the
      `(t - s)`-shift of an arbitrary total `σ`.
- [ ] Note in the docstring that the `τ`-independence is definitional (the clause does not mention
      `τ`) and only the `t`-independence needs the shift argument — do not over-engineer the proof.
- [ ] State it for a general `D` if the shift lemma supports it; specialize to ℤ only if a general
      statement does not elaborate.
- [ ] Place under `namespace Truth` in `FormalSystem/Semantics/Truth.lean` (additive; no existing
      signature changes).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - `Truth.box_const` (additive)

**Verification**:
- Module builds with zero diagnostics; no existing declaration in `Truth.lean` changes signature.
- `lean_verify` on `box_const` is clean.

---

### Phase 7: Truth-lemma target statement + atom, `⊥`, `→`, and `□` cases [NOT STARTED]

**Goal**: State the truth lemma for `FiniteFilteredTaskFrame ℤ φ` and discharge the four
non-eventuality cases. The finite frame **already exists** and already carries all four axioms
(`FMP/FiniteModel.lean`, the only live `FiniteTaskFrame` in the library) — nothing new is
constructed here.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean`).
- [ ] State the truth lemma: for `ψ` in the closure of `φ`, `TruthAt M τ t ψ` on the filtered model
      iff `ψ ∈ (τ.states t _).carrier` (the exact filtered-world/MCS form to be pinned against
      `FMP/Filtration.lean`'s `FilteredWorld` and `ClosureMCSSetoid` at implementation time).
- [ ] Confirm the premise the plan rests on before proving anything: `FMP/` still contains **zero**
      occurrences of `TruthAt` (`grep -rn "TruthAt" FormalSystem/Metalogic/Decidability/FMP/`). If
      this has changed, stop and report — the gap analysis would be stale.
- [ ] Discharge `Formula.atom` (via `Truth.atom_iff_of_domain`), `Formula.bot` (via
      `Truth.bot_false`), and `Formula.imp` (via `Truth.imp_iff`) — these are routine.
- [ ] Discharge `Formula.box` using `box_const` (Phase 6) plus `PartialHistory.occurrence`
      (`Semantics/Extension/Extension.lean`, `cor:occurrence` in frame-intrinsic form: for any world
      state and time there is a total history through it). `occurrence` is what supplies the witness
      history the box clause quantifies over; `hF_nonempty` is available if a bare nonemptiness
      witness suffices.
- [ ] Leave `Formula.untl` and `Formula.snce` as explicitly named open goals **structured as
      separate lemmas with full statements** so Phase 9 has a fixed target. They must be genuine
      unproven lemma *statements* that Phase 9 fills — **not** `sorry`-ed declarations. If the
      induction cannot be structured to defer them without a `sorry`, split the induction so the
      eventuality cases are hypotheses of the main lemma and Phase 9 discharges them.

**Timing**: 2 hours

**Depends on**: 4, 6

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean` (new)

**Verification**:
- Module builds with zero diagnostics and **zero `sorry`** — verified with
  `scripts/check-module-invariants.sh`, not naive grep.
- The `untl`/`snce` obligations appear as named hypotheses or named unproven lemma statements, and
  the phase closes green because nothing is asserted that is not proved.
- `bash scripts/check-paper-definitions.sh` still case-(a) at phase close.

---

### Phase 8: Pigeonhole/lasso machinery over finite `W` and ℤ [NOT STARTED]

**Goal**: Build the reusable periodicity toolkit that Phase 9 and Phase 12 both consume. Landing it
separately shrinks the highest-risk phase from tool-building-plus-proof to proof-assembly. **No
such machinery exists anywhere in the tree** — no `UltimatelyPeriodic`, `EventuallyPeriodic`, or
lasso detection — so this is new construction.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean`).
- [ ] Prove the core pigeonhole: on a bi-infinite step-path in a finite carrier, any window of
      length exceeding `card W` repeats a state.
- [ ] Derive the bounded-witness-distance lemma: if a state satisfying a property is reachable along
      the path at all, it is reachable within a bound expressible in `card W`.
- [ ] Derive the segment-splice lemma: a repeated state licenses excising or inserting the loop
      between its two occurrences, yielding another adjacency-satisfying path
      (`mem_HF_iff_adjacent`, Phase 4).
- [ ] State everything against `mem_HF_iff_adjacent`'s adjacency form so it applies to any
      `TaskFrame ℤ` with finite `WorldState`, not only to the filtered frame.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Three lemmas (pigeonhole, bounded witness distance, splice) suffice for both
consuming phases. This is a hypothesis: Phase 9 may reveal a fourth obligation. Confirm by having
Phase 9 report which lemmas it actually consumed; if Phase 9 needs machinery not present here, add
it to this module rather than inlining it into the eventuality proof.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean` (new)

**Verification**:
- Module builds with zero diagnostics and zero `sorry`.
- Each lemma has a standalone `example` exercising it on a concrete small frame.

---

### Phase 9: `untl`/`snce` eventuality fulfilment — HIGHEST-RISK PHASE [NOT STARTED]

**Goal**: Discharge the two eventuality cases of the truth lemma. **This is the single largest risk
in the task.** Six previous attempts at precisely this machinery are archived in `Boneyard` with
sorries: `ScheduleBasedBFMCS/RootScopedChain.lean` (3), `QuasimodelOracle/RoundRobinChain.lean` (3),
`QuasimodelOracle/OracleStep.lean` (7), `QuasimodelOracle/OracleCoherence.lean` (6),
`SorriedDeclExcisions/BundleUntilSinceStep.lean` (7),
`SorriedDeclExcisions/WeakTruthLemmaCluster.lean` (6).

**Strategy, stated up front (do not improvise a different one without recording why)**:
1. Work in the adjacency presentation from Phase 4, never on `regionFrame` — that carrier's
   `not_regionConstant_regionHistory` forecloses lassos by construction.
2. Fulfil an `untl φ ψ` obligation at a filtered world by exhibiting a **bounded** forward witness,
   using Phase 8's bounded-witness-distance lemma with the bound in `card (FilteredWorld φ)`.
3. Use Phase 8's splice lemma to convert a witness reachable along *some* path into a witness along
   *the* path, keeping adjacency.
4. `snce` is the time-reversed mirror; derive it through the `converse` field rather than
   duplicating the argument, if the symmetry is expressible.
5. **Note the constructor-argument-order convention**: this repository's `untl`/`snce` are
   event-first/guard-second (`Formula.untl φ ψ` = "`φ` holds at some future `s`, `ψ` throughout
   between"), which reads backwards from a naive guard-first reading. See
   `specs/decisions/untl-snce-argument-order.md`. Getting this backwards is a silent, expensive
   failure mode.

**Tasks**:
- [ ] Discharge `Formula.untl` in `TruthLemma.lean` using Phase 8's machinery.
- [ ] Discharge `Formula.snce`, preferably by reversal rather than duplication.
- [ ] Record in the phase's progress notes which Phase 8 lemmas were actually consumed and which
      were missing (feeds Phase 8's Scope Hypothesis confirmation).

**Timing**: 2 hours budgeted; this phase is permitted to consume its full budget without closing

**Depends on**: 7, 8

**Verification Tier**: full

**Escalation contract (binding)**:
- **No `sorry`, under any framing.** Not a scaffold, not a placeholder, not a "to be removed in the
  next phase" marker. The zero-debt decision is explicit in the research report and this phase is
  the one it exists for.
- If the argument resists within the phase's budget: set this phase's heading to `[BLOCKED]`, write
  a blocker record naming the precise goal state that resisted, the Phase 8 lemmas that were
  insufficient, and the specific Boneyard file whose failure mode it most resembles, and **stop**.
  Escalate for user review. Do not proceed to Phase 10.
- A `[BLOCKED]` outcome here blocks Phases 10 and 13. Phases 11 and 12 remain independently
  completable and should be reported as such.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean` - `untl` and `snce` cases
- `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean` - only if a missing lemma must be added

**Verification**:
- Full repository gate set: `lake build` green.
- `scripts/check-module-invariants.sh` reports live-`sorry` count still exactly 1.
- The truth lemma is a complete theorem with no remaining hypotheses standing in for the
  eventuality cases.

---

### Phase 10: Assemble the semantic FMP over ℤ-time [NOT STARTED]

**Goal**: State and prove the deliverable: every formula satisfiable over **ℤ-time** is satisfiable
in a model with finite `WorldState` over `D = ℤ`.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/FMP/SemanticFMP.lean`).
- [ ] State the theorem in Lean's existing vocabulary: `ValidDiscrete` / `satisfiable ℤ` /
      `FormulaSatisfiable` (`Semantics/Validity.lean`). Lean's `ValidDiscrete` already quantifies
      over `[SuccOrder] [PredOrder] [IsSuccArchimedean] [IsPredArchimedean] [Nontrivial]` — the
      successor-Archimedean class, i.e. ℤ-time by Hölder — so the correct target is already
      expressible without new definitions.
- [ ] Prove it by composing: the syntactic closure-MCS FMP already in `FMP/`, the truth lemma
      (Phase 9), and `FiniteFilteredTaskFrame ℤ`'s finiteness.
- [ ] Docstring must state the scope honestly and cite the record: the target is **ℤ-time**, not the
      paper's broader `def:frame-properties` Discrete class; the Discrete-class form is **false**
      (`CO` is refutable on `ℤ ×_lex ℤ` yet valid in every model over `D = ℤ`); and
      `cor:tm-decidability` states decidability is **open**, so this theorem is a step toward an
      open result and backs no decidability claim.
- [ ] Add a cross-reference note at the head of `FMP/FMP.lean` (or the `FMP/README.md`) pointing
      from the syntactic theorems to the new truth-connected layer.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/SemanticFMP.lean` (new)
- `FormalSystem/Metalogic/Decidability/FMP/FMP.lean` or `FMP/README.md` - cross-reference note

**Verification**:
- `lake build` green; the theorem is `sorry`-free.
- Grep gate: no new declaration name or docstring in this task's touched files asserts the
  Discrete-class form. Search for `Discrete` in the diff and confirm every occurrence either says
  ℤ-time or explicitly records the refutation.
- `bash scripts/check-paper-definitions.sh` case-(a) at phase close.

---

### Phase 11: `IntPresentation` and `toFiniteFrame` [NOT STARTED]

**Goal**: A computational presentation of a finite-`W`-over-ℤ frame. `FiniteTaskFrame.finite_world`
is `Finite`, which is non-constructive and yields no enumeration, so it **cannot** drive `decide` —
a `Fintype`/`DecidableEq` presentation is required and is what this phase supplies.

**Tasks**:
- [ ] New module (proposed `FormalSystem/Metalogic/Decidability/IntPresentation.lean`).
- [ ] Define the structure along the report's recommended shape:
      `card : ℕ`, `step : Fin card → Fin card → Bool`, `val : Atom → Fin card → Bool`,
      `fwd : ∀ w, ∃ u, step w u = true`, `bwd : ∀ w, ∃ v, step v w = true`.
- [ ] `IntPresentation.toFiniteFrame : IntPresentation → FiniteTaskFrame ℤ` built through
      `TaskFrame.ofStep` (Phase 5) — do not re-discharge the seven fields by hand.
- [ ] `IntPresentation.toModel` supplying the valuation.
- [ ] Carry `Fin card` throughout; never route computation through `Finite`.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` (new)

**Verification**:
- Module builds with zero diagnostics.
- `#eval`-able smoke instance: the promoted two-state witness from Phase 5 expressed as an
  `IntPresentation` and its `toFiniteFrame` elaborating.

---

### Phase 12: `IntPresentation.check` — the Bool-valued decision procedure [NOT STARTED]

**Goal**: A computable `check` deciding truth of a formula at a state of an `IntPresentation`.

**Tasks**:
- [ ] `IntPresentation.check (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Bool`.
- [ ] Atom/`⊥`/`→`: direct on `val`.
- [ ] `□`: decided **once per model**, not per history — `box_const` (Phase 6) makes the box facts a
      single finite set. Compute it once and reuse; do not re-derive per call site.
- [ ] `untl`/`snce`: bounded search over the finite step-graph, with the witness-distance bound from
      Phase 8's pigeonhole lemma.
- [ ] Keep `check` structurally terminating on the formula with the graph search as an inner bounded
      loop; if termination needs a measure, state it explicitly rather than relying on `decreasing_by`
      guesswork.
- [ ] Do **not** revive, reference, or repair `validity_decidable` / `validity_has_decision_procedure`.
      They are deleted, with a retirement note at `Metalogic/Decidability/Correctness.lean` recording
      that the former "was proved by `exact Classical.em (⊨ φ)`" and "is in no sense a decidability
      statement". `isValid` (`DecisionProcedure.lean`) remains a `Bool` with no correctness theorem;
      that bridge is Phase 13's business, not this phase's.

**Timing**: 2 hours

**Depends on**: 11

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` - `check`

**Verification**:
- Module builds; `check` is computable and `#eval`s on the two-state witness for a handful of
  formulas covering all six constructors.
- Hand-computed expected values for those formulas match.

---

### Phase 13: `check_correct`, the `Decidable` instance, and final gates [NOT STARTED]

**Goal**: Prove the correctness bridge and close out the task.

**Tasks**:
- [ ] Prove `IntPresentation.check_correct : P.check w φ = true ↔ ∃ τ, τ.IsTotal ∧ τ.states 0 _ = … ∧
      TruthAt (P.toModel) τ 0 φ` (exact statement pinned at implementation time against Phase 11's
      `toModel`).
- [ ] Derive a genuine `Decidable` instance for truth-at-a-state on an `IntPresentation` from
      `check_correct` — an instance that produces a procedure, unlike the retired `validity_decidable`.
- [ ] Update the `Correctness.lean` retirement note: it names the still-open obligation
      (`isValid φ fc = true ↔ ⊨ φ`, plus `Decidable (⊨ φ)` for the four frame classes). Record
      precisely which part this task discharges (model checking on an `IntPresentation`) and which
      part remains open (validity over the frame classes). Do not overclaim.
- [ ] Update `FormalSystem/Semantics/README.md` and `FMP/README.md` to describe the new normal-form
      and truth-connected layers.
- [ ] Final gate sweep.

**Timing**: 2 hours

**Depends on**: 10, 12

**Verification Tier**: full

**Scope Hypothesis**: The repository's live-`sorry` count is exactly 1 at task end
(`Metalogic/WeakCanonical/Transfer.lean`, declared invariant C3), unchanged from task start.
Confirm with `scripts/check-module-invariants.sh` — **not** naive grep, which over-counts
doc-comment prose. Any deviation is a task-blocking regression, not a rounding difference.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` - `check_correct`, `Decidable` instance
- `FormalSystem/Metalogic/Decidability/Correctness.lean` - retirement-note update (prose only)
- `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/Decidability/FMP/README.md`

**Verification**:
- `lake build` green across the whole repository.
- `bash scripts/check-module-invariants.sh` — live-`sorry` count exactly 1.
- `bash scripts/check-paper-definitions.sh` — case-(a) quiet pass.
- `bash scripts/check-task-references.sh` — no task-number references in deliverable files (all new
  Lean modules and READMEs are outside `specs/**`).
- Test suite green.
- `git -C /home/benjamin/Philosophy/Papers/PossibleWorlds status --porcelain` shows no change
  attributable to this task.

---

## Testing & Validation

- [ ] `lake build` green at every phase close, and at task end.
- [ ] `bash scripts/check-module-invariants.sh` reports exactly 1 live `sorry`
      (`Metalogic/WeakCanonical/Transfer.lean`, invariant C3) at every phase close.
- [ ] `bash scripts/check-paper-definitions.sh` reports the quiet case-(a) pass at every phase
      boundary. This neighborhood moved three times in four days; a case-(b)-or-worse result pauses
      the phase for re-quoting before proceeding.
- [ ] `bash scripts/check-task-references.sh` clean — no task-number citations in any new Lean
      module, README, or docstring.
- [ ] Existing test suite (`Tests/BimodalTest/`) still passes, including `TaskFrameTest.lean` after
      the Phase 5 `customFrame` promotion.
- [ ] Smoke instances: the promoted two-state ℤ witness exercises `ofStep`, `mem_HF_iff_adjacent`,
      `IntPresentation.toFiniteFrame`, and `check` end to end.
- [ ] No new declaration or docstring asserts the refuted Discrete-class FMP; every `Discrete`
      occurrence in the diff either says ℤ-time or explicitly records the refutation.
- [ ] No file under `/home/benjamin/Philosophy/Papers/` is modified.

## Artifacts & Outputs

- `specs/paper-definitions-of-record.md` - three newly tracked anchors (`cor:spherical-finite`, `lem:nesting`, `lem:nonempty`)
- `FormalSystem/Semantics/TaskFrame.lean` - `TaskFrame.spherical_of_finite`
- `FormalSystem/Semantics/IntNormalForm.lean` (new) - `iter`, `iter_add`, `TaskFrame.step`, `taskRel_eq_iter`, `mem_HF_iff_adjacent`, `TaskFrame.ofStep`
- `FormalSystem/Semantics/Truth.lean` - `Truth.box_const`
- library home for the promoted off-zero-universal two-state ℤ witness
- `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean` (new) - pigeonhole, bounded witness distance, splice
- `FormalSystem/Metalogic/Decidability/FMP/TruthLemma.lean` (new) - the truth lemma, all six constructors
- `FormalSystem/Metalogic/Decidability/FMP/SemanticFMP.lean` (new) - the semantic FMP over ℤ-time
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` (new) - `IntPresentation`, `toFiniteFrame`, `toModel`, `check`, `check_correct`, `Decidable` instance
- README and retirement-note updates
- `specs/417_semantic_fmp_finite_worldstate_over_z/summaries/02_semantic-fmp-z-time-summary.md`

## Rollback/Contingency

- Every phase commits independently at each green sub-step, so any single phase can be reverted with
  `git revert` without disturbing earlier landed work. The normal-form module (Phases 3-5) and
  `spherical_of_finite` (Phase 2) are additive and independently valuable to sibling tasks; they
  survive even if the truth lemma does not.
- **If Phase 9 escalates to `[BLOCKED]`**: Phases 1-8 and 11-12 remain landed and green. Phases 10
  and 13 are blocked. Set the task status to `[BLOCKED]` with a blocker record naming the resisting
  goal state, the Phase 8 lemmas that proved insufficient, and the most-similar Boneyard precedent.
  Do **not** land a `sorry` to unblock the downstream phases.
- If the paper drifts mid-task in a way that invalidates a tracked quote, pause, re-run the
  definitions lint, re-quote per the record's extension protocol, and only then resume. Never
  restate or "improve" a definition from memory.
- If `lake build` breaks, fix forward. Never discard uncommitted changes to reach a passing build.
