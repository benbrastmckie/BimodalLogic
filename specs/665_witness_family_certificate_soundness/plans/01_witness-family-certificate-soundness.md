# Implementation Plan: Witness-family certificate soundness

- **Task**: 665 - Witness-family certificate soundness (the quasimodel / ShiftSet route, soundness half)
- **Status**: [NOT STARTED]
- **Effort**: 15 hours
- **Dependencies**: None blocking. Held-stable neighbour: `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`. Concurrent sibling this cycle: task 667 (no declared file scope).
- **Research Inputs**: `specs/665_witness_family_certificate_soundness/reports/01_witness-family-certificate-soundness.md`; compiled spike `specs/665_witness_family_certificate_soundness/evidence/t1-agreement-spike.lean`
- **Artifacts**: plans/01_witness-family-certificate-soundness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land the soundness half of the quasimodel / ShiftSet route: a labelled bi-lasso family that
satisfies local coherence, fulfilment and box faithfulness presents a `ShiftSet intOrder` model
whose truth agrees with the labels on the subformula closure, so any such family is a
machine-checkable refutation of a ℤ-time consequence. The work is a new presentation-free
subdirectory `FormalSystem/Metalogic/Decidability/WitnessFamily/` holding the datatype, the three
certificate predicates, the standard shift-set model, the agreement theorem and its consequence
corollaries, the decidability instances, and the non-vacuity witnesses. Definition of done:
T1, T1', T2 and T3 landed sorry-free with axioms inside `[propext, Classical.choice, Quot.sound]`,
`lake build` green, `scripts/check-module-invariants.sh` green, and the two README tables updated.
The completeness (compression) direction and the `Decidable (ValidZTime)` assembly stay with
task 623 and are explicitly out of scope here.

### Research Integration

The research report is unusually load-bearing and the plan is built directly on it:

- **T1 and T1' are already machine-checked.** `evidence/t1-agreement-spike.lean` is 262 lines,
  compiles clean against the live tree with zero `sorry`, and measures
  `[propext, Classical.choice, Quot.sound]`. Phases 3, 4 and 5 are transcription of that spike
  onto the real datatype, not discovery. Every proof term in those phases has a verified
  ancestor in the spike.
- **The inductive statement must be generalised over the carrier point**, not over the lasso
  index alone: `ShiftTruth`'s `box` clause quantifies over the whole carrier, so the induction
  runs at `∀ (w : std.Carrier) (t : ℤ)` and the dispatch's stated form is its instance at
  `(i, 0)`. Proving against `ShiftTruth` first and composing with `ShiftSet.forward_repr`
  afterwards is what keeps the `box` case to three lines.
- **T2 is a transposition, not a proof effort.** Every window-collapse lemma in
  `BiLasso/Decide.lean` reads only the label function and the three segment lengths, never the
  presentation, and `LocalCoherentLab` is strictly easier than `LocalCoherent` because it drops
  the atom and state clauses (so `unroll_congr_back` / `unroll_congr_fwd` are not needed at all).
  Phases 6-8 carry the per-lemma inventory the research tabulated.
- **T3's second deliverable was infeasible as dispatched** and is replaced per the recorded
  decision (see Decisions below).
- Placement, the `@[reducible]` prohibition on `std`, the `@`-application for
  `TaskFrame.isZTime_of_instances`, and the `@LT.lt ℤ _` re-ascription idiom all come from the
  report's Decisions and Risks sections and are carried into the phases verbatim.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied for this dispatch and no ROADMAP.md consultation was requested.

## Goals & Non-Goals

**Goals**:
- `closureOf`
- `lab`
- `L`
- `LocalCoherentLab`
- `FulfillingLab`
- `BoxFaithful`
- `Target`
- `std`
- `std_isZTime`
- `shiftTruth_iff_mem`
- `truth_iff_mem`
- `not_consequence_ztime`
- `not_consequence_base`
- `joint_countermodel`
- `no_witnessFamily_of_validZTime`
- `no_witnessFamily_of_MF`
- `decidableLocalCoherentLab`
- `decidableFulfillingLab`
- `decidableBoxFaithful`
- `decidableTarget`

**Non-Goals**:
- The completeness / compression direction (every ℤ-time countermodel yields a witness family).
  That stays with task 623, together with the `Decidable (ValidZTime φ)` assembly.
- Any edit to `BiLasso/Basic.lean` (held stable by the BiLasso README) or to `BiLasso/Decide.lean`
  (consumed by the live `check`). The duplication between `Decide.lean`'s window collapses and
  this task's is recorded with a named retirement trigger instead of refactored away.
- Choice-freedom. The decidability instances must be computable; they are not promised
  choice-free, per `BiLasso/Check.lean`'s note on `wlem_of_saturation`.
- The ModelChecker JSON schema itself. Only the consequence that field names must stay stable is
  in scope.
- Wiring the research spike into a Lake target. It is evidence, not a deliverable.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `omega` cannot see through `↑intOrder`, so temporal bookkeeping silently fails to close | M | H | Use the idiom `TruthLemma.lean` and `Unfold.lean` already use: `have h : @LT.lt ℤ _ t s := hts`, `replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → …`, and `show @LT.lt ℤ _ a b by omega` when the goal is the inequality. Every occurrence is already exercised in the spike |
| `haveI` shadows the `SuccOrder` instance that `IsSuccArchimedean` is indexed by, so `std_isZTime` will not elaborate | M | H | Explicit `@`-application of `TaskFrame.isZTime_of_instances` with four `inferInstanceAs` arguments (Phase 4). Do not attempt `inferInstance` for `SuccOrder S.frame.Duration` — it fails even though the equality holds by `rfl` |
| Marking `std` `@[reducible]` breaks synthesis of `ShiftSet.frame_isRegular` | M | M | `std` must NOT be `@[reducible]`. Ascribe carrier points explicitly (`((i, 0) : W.std.Carrier)`) and close the final transfer with `Iff.trans`, never `rw [ShiftSet.forward_repr]` (the motive will not match syntactically) |
| A binder named `Σs` fails to parse (`Σ` is a reserved token) | L | H | Name the conclusion set `Del` in Lean source and `Σ` only in prose |
| Both ℤ-SuccPred imports are needed and neither alone suffices | M | M | Import `Mathlib.Data.Int.SuccPred` **and** `Mathlib.Order.SuccPred.LinearLocallyFinite` in the module defining `std_isZTime`; verified by bisection in research |
| `Decide.lean` transposition is ~650 lines and may overrun a single agent run | M | H | Split across Phases 6, 7 and 8 along the report's own three natural seams (label windows / fulfilment block / BoxFaithful+Target), each with its own green commit boundary |
| `no_witnessFamily_of_MF`'s direct box-clause argument may not close as sketched | M | M | Primary route is the validity route, which needs no new mathematics: MF is valid (`modal_future_valid`, `Metalogic/Soundness.lean`), so `joint_countermodel` at `Target Γ [MF]` is immediately contradictory. The direct box-clause argument is a fallback, not the plan of record |
| C17 dead-declaration scan rejects named `Decidable` instances that are only reached by typeclass resolution | M | M | Cite every new instance name in the Decidability/BiLasso README rows (Phase 10) and exercise them by name in `Examples.lean`'s `#guard`s (Phase 9) |
| C33 requires the root `FormalSystem.lean` to be byte-identical to generated output | L | H | Regenerate with `lake exe mk_all --lib FormalSystem`; never hand-edit the root aggregator |
| C28 per-file warning budget: the spike carries two `unusedVariables` warnings | L | H | Clean both before landing. A new file with zero warnings needs no `scripts/warning-budget.txt` entry; a new file with warnings would need a baseline row and should instead be fixed |
| Concurrent sibling (task 667) shares the working tree with no declared file scope | M | M | Re-read any file immediately before editing; stage only this task's own hunks with an explicit file list (never `git add -A`, never a directory or glob pathspec); never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside `WitnessFamily/` as possibly a sibling's in-flight edit and report rather than "fix" it |
| The Decidability README calls `BiLasso/` "outside the build graph" while the root aggregator imports its modules directly | L | M | Verify which description is current before copying either phrasing into the new `WitnessFamily/` row; do not propagate the pre-existing tension |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5, 6 | 3, 4 |
| 5 | 7 | 6 |
| 6 | 8 | 7 |
| 7 | 9 | 5, 8 |
| 8 | 10 | 9 |

Phases within the same wave can execute in parallel. Wave 4 is the only genuine parallel
opportunity: Phase 5 needs Phases 3 and 4, Phase 6 needs only Phase 3.

---

### Phase 1: Set-level subformula closure [NOT STARTED]

**Goal**: `WitnessFamily/Closure.lean` — the set-level closure a certificate's target set needs,
since `subformulaClosure` is single-formula only.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Closure.lean` with the module
      docstring, copyright header, and imports (`FormalSystem.Syntax.SubformulaClosure.Closure`,
      `FormalSystem.Syntax.Context`)
- [ ] Define `closureOf (S : Context) : Finset Formula := (S.map subformulaClosure).foldr (· ∪ ·) ∅`
- [ ] Prove `mem_closureOf : ψ ∈ closureOf S ↔ ∃ χ ∈ S, ψ ∈ subformulaClosure χ` with the
      explicit `constructor` / `rintro` proof — `simp` followed by `tauto` fails because `tauto`
      cannot fold the `foldr` back
- [ ] Prove `self_mem_closureOf`
- [ ] Prove the six projections `closureOf_imp_left`, `closureOf_imp_right`, `closureOf_box`,
      `closureOf_untl_left`, `closureOf_untl_right`, `closureOf_snce_left`, `closureOf_snce_right`,
      each three lines from the corresponding single-formula lemma in `SubformulaClosure/Closure.lean`
- [ ] Add the `DecidablePred (· ∈ closureOf S)` instance
- [ ] Build the module in isolation and confirm zero warnings and zero `sorry`

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~90 lines, with the six projections each ~3 lines. Confirm at
implementation time by `wc -l` on the finished module and by checking that every projection in
`FormalSystem/Syntax/SubformulaClosure/Closure.lean` used by Phase 5's induction has a set-level
counterpart here (grep Phase 5's `closure_*` uses against this file's exports). If the
`foldr`-based definition proves awkward, the documented fallback is to index the family by a
single `φ : Formula` exactly as `Annot P φ` does, and have ModelChecker emit the conjunction —
the spike was written that way and compiles; the cost is an unnatural JSON field, not a proof
obstacle.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Closure.lean` - new file

**Verification**:
- `lake env lean FormalSystem/Metalogic/Decidability/WitnessFamily/Closure.lean` exits 0 with no
  warnings
- `grep -c sorry` on the new file returns 0

---

### Phase 2: `LabelledLasso` and `WitnessFamily` [NOT STARTED]

**Goal**: `WitnessFamily/Basic.lean` — the presentation-free datatype over
`Periodic.unrollOf`, with the decoded label function and the two periodicities. Field names are
part of the deliverable: the ModelChecker JSON export mirrors them field for field.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean`, importing Phase 1's
      `Closure.lean` and `FormalSystem.Metalogic.Decidability.BiLasso.Periodic`
- [ ] Define `structure LabelledLasso (C : Finset Formula)` with fields `back`, `mid`, `fwd`
      (`List (Finset Formula)`), `back_ne : back ≠ []`, `fwd_ne : fwd ≠ []`, and
      `label_sub : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C`
- [ ] Define `LabelledLasso.lab := Periodic.unrollOf back mid fwd` at `Finset Formula` (the
      `[Inhabited α]` instance is `∅`), plus the abbreviations `nb`, `nm`, `nf`
- [ ] Derive the two periodicities from `Periodic.unrollOf_sub_back_length` and
      `Periodic.unrollOf_add_fwd_length`
- [ ] Prove `LabelledLasso.lab_subset` — the decoded form of `label_sub`, mirroring
      `Annot.label_subset_closure`
- [ ] Define `structure WitnessFamily (Γ Del : Context)` with fields `bx : Formula → Bool`,
      `lassos : List (LabelledLasso (closureOf (Γ ++ Del)))`, `lassos_ne : lassos ≠ []`
- [ ] Derive `WitnessFamily.k`, `WitnessFamily.L : Fin (k+1) → ℤ → Finset Formula`, and
      `WitnessFamily.main := L 0`, pinning the origin as in `BiLasso`
- [ ] Add a "Deliberate duplication" docstring section naming the retirement trigger: *once a
      shared periodic-label presentation lands, `Annot`'s window collapses and `LabelledLasso`'s
      should be redefined as its two instances and the duplicated arithmetic deleted* — mirroring
      how `BiLasso/Periodic.lean` already records its duplication against `Basic.lean`
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: ~180 lines. The alignment bookkeeping `Annot` needs (`readIndex`,
`label_unroll_aligned`) is asserted to be unnecessary here, because that lemma exists only to
align labels with *states* and a `LabelledLasso` has no states. Confirm by checking that no
Phase 5 or Phase 6 proof reaches for an alignment lemma; if one does, the hypothesis was wrong
and the alignment layer must be added to this module before those phases proceed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` - new file

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- `#print axioms` on the two periodicity lemmas stays within `[propext, Classical.choice, Quot.sound]`
- Field names match this plan's `## Lean Challenge Statements` block exactly (they are the
  JSON-export contract)

---

### Phase 3: The three certificate predicates and the target [NOT STARTED]

**Goal**: `WitnessFamily/Predicates.lean` — `LocalCoherentLab`, `FulfillingLab`, `BoxFaithful`,
`Target`, transcribed from the spike onto the real datatype.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean` importing
      Phase 2's `Basic.lean`
- [ ] Define `LocalCoherentLab`: the `LocalCoherent` clauses of `BiLasso/Annotation.lean` minus
      the atom and presentation clauses — `bot ∉ L i t` (unconditional, no in-closure guard),
      `imp` iff, `box χ ∈ L i t ↔ bx χ = true`, and the one-step `untl` / `snce` unfoldings at
      `t+1` / `t-1`. Atoms are deliberately unconstrained: the valuation *is* the atom part of
      the label
- [ ] Define `FulfillingLab` — `Fulfilling` from `BiLasso/Annotation.lean` verbatim on the
      decoded label function
- [ ] Define `BoxFaithful` — for each `box χ` in the closure, `bx χ = true ↔ ∀ i t, χ ∈ L i t`
- [ ] Define `Target (W) (t : ℤ) : Prop` — every `γ ∈ Γ` in `L 0 t` and no `σ ∈ Del` in `L 0 t`
- [ ] Document in each definition's docstring why the corresponding `Annotation.lean` clause was
      dropped or kept, so a reader can diff the two predicate families
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: ~110 lines, and the claim that exactly two clause families (atom, state)
are dropped relative to `BiLasso/Annotation.lean`'s `LocalCoherent`. Confirm at implementation
time by reading `LocalCoherent` in `Annotation.lean` and enumerating its clauses against this
file's, recording the correspondence in the docstring.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean` - new file

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- Each predicate's clause structure matches the spike's (`evidence/t1-agreement-spike.lean`,
  the `## The three certificate predicates` section), modulo `Fam.L` replaced by
  `WitnessFamily.L`

---

### Phase 4: The standard shift-set model [NOT STARTED]

**Goal**: `WitnessFamily/Std.lean` — `WitnessFamily.std : ShiftSet intOrder`, its ℤ-time
membership and its frame-class satisfaction.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean` importing Phase 2's
      `Basic.lean`, `FormalSystem.Semantics.ShiftSet`, `FormalSystem.Semantics.Validity`,
      `FormalSystem.Semantics.FrameClassValidity`, **and both** `Mathlib.Data.Int.SuccPred`
      and `Mathlib.Order.SuccPred.LinearLocallyFinite`
- [ ] Define `WitnessFamily.std` with `Carrier := Fin (k+1) × ℤ`, `sh (i,t) d := (i, t+d)`,
      `A p (i,t) := atom p ∈ L i t`. `sh_zero` is `simp`; `sh_add` is `simp [add_assoc]`; `sep`
      coerces first (`have h : (|(y : ℤ)| : ℤ) < 1 := hy`) and closes with `Int.abs_lt_one_iff`
- [ ] **Do not mark `std` `@[reducible]`** — it breaks synthesis of `ShiftSet.frame_isRegular`.
      Record the reason in the docstring
- [ ] Prove `std_isZTime` by explicit `@`-application of `TaskFrame.isZTime_of_instances` with
      four `inferInstanceAs` arguments. Do not use `haveI`; do not use bare `inferInstance`
- [ ] Prove `std_sat_ztime : FrameClass.ZTime.Sat W.std.frame` and `std_sat_base` (via
      `FrameClass.Sat.anti (by decide)`)
- [ ] Prove `sh_surj`, `sh_fst`, `sh_snd` and `lab_sh` (the carrier-point helpers the Phase 5
      `box` case consumes)
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: ~120 lines, all five of `std`, `std_isZTime`, `std_sat_ztime`,
`std_sat_base`, `sh_surj` asserted to be verified in the spike. Confirm by diffing each against
the spike's corresponding declaration; any that is not a near-verbatim transcription is new work
and should be flagged before proceeding.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean` - new file

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- `#print axioms WitnessFamily.std_isZTime` reports within `[propext, Classical.choice, Quot.sound]`
- Removing either of the two Mathlib SuccPred imports breaks the build (confirming both are
  load-bearing, as research established by bisection)

---

### Phase 5: T1 agreement and T1' consequence corollaries [NOT STARTED]

**Goal**: `WitnessFamily/Agreement.lean` — the agreement theorem and the three consequence
corollaries ModelChecker reports.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` importing
      Phases 3 and 4
- [ ] Transcribe `untl_mem_of_witness` and `snce_mem_of_witness` — the two ℤ-distance inner
      inductions — from the spike, with `Fam.L` replaced by `WitnessFamily.L`
- [ ] Prove `shiftTruth_iff_mem`: the inductive form, generalised over the carrier point
      `(w : std.Carrier)` and the time `t`, stated against `ShiftSet.ShiftTruth`. Cases: `atom`
      is `Iff.rfl`; `bot` uses the unconditional `bot ∉ L i t`; `imp` rewrites by the coherence
      clause; `box` uses `sh_surj` (three lines, because `total_eq_orbit` is already discharged
      inside `forward_repr`); `untl`/`snce` use the inner inductions plus `FulfillingLab`
- [ ] Prove `truth_iff_mem` — T1 as dispatched, at `std.hist ((i, 0) : std.Carrier)` — by
      `(ShiftSet.forward_repr …).trans (by simpa using shiftTruth_iff_mem …)`. Do **not** use
      `rw [ShiftSet.forward_repr]`; the motive will not match syntactically
- [ ] Prove `not_consequence_ztime` — for every `σ ∈ Del`, `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ`
- [ ] Prove `not_consequence_base` via `FrameClass.Sat.anti (by decide)`
- [ ] Prove `joint_countermodel` — the `∃ F, Sat F, M, τ, t` form ModelChecker reports, mirroring
      `not_validZTime_of_satAtState` in `BiLasso/Assembly.lean`
- [ ] Add docstrings (C19 floor is 90% coverage) and clean the spike's two `unusedVariables`
      warnings
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 2 hours

**Depends on**: 3, 4

**Verification Tier**: local

**Scope Hypothesis**: ~230 lines, asserted to be transcription-plus-docstrings because every
proof term has a sorry-free ancestor in the spike. Confirm by checking, per declaration, that
the transcribed proof compiles without a new tactic being introduced; the appearance of any
genuinely new proof step (other than the `Fam.L` → `WitnessFamily.L` substitution) falsifies the
hypothesis and should be reported in the phase's commit message.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` - new file

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- `#print axioms` on `truth_iff_mem`, `not_consequence_ztime` and `joint_countermodel` each
  reports exactly `[propext, Classical.choice, Quot.sound]`
- The statement of each theorem matches this plan's `## Lean Challenge Statements` block

---

### Phase 6: Decidability part A — label windows and `LocalCoherentLab` [NOT STARTED]

**Goal**: `WitnessFamily/Decide.lean` (first tranche) — the label-window machinery and the
`LocalCoherentLab` window collapse, transposed from `BiLasso/Decide.lean`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` importing Phase 3
- [ ] Transpose verbatim (label-only, no presentation): `label_sub_nf`, `label_add_nb`,
      `label_reduce_fwd`, `label_reduce_back`, `label_congr_fwd`, `label_congr_back`,
      `scan_forward`, `scan_backward`, `mem_all_neg_of_period`, `mem_all_fwd_of_period`
- [ ] **Drop** `unroll_congr_back` / `unroll_congr_fwd` — a `LabelledLasso` has no states
- [ ] Transpose `clauseAt` dropping the `atom` case (the `bot` case stays `True`)
- [ ] Transpose `LocalCoherentAt`, `localCoherent_iff_forall`, `localCoherentAt_congr`
      (congruence now needs only label periodicity), `localCoherent_iff_window`
- [ ] Keep the window constants unchanged: `cohWindowLo = -2 * nb`, `cohWindowHi = nm + 2 * nf`
- [ ] Define the named instance `decidableLocalCoherentLab`
- [ ] Add the "Deliberate duplication" docstring section with the same retirement trigger as
      Phase 2's, naming `BiLasso/Decide.lean` as the sibling that should collapse into a shared
      periodic-label abstraction once one exists
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: ~300 lines, transposing `BiLasso/Decide.lean`'s lines 76-270 region. The
load-bearing claim is that every lemma listed above reads only `A.label`, `A.nb`, `A.nm`, `A.nf`
and the two periodicities — never the presentation. Confirm per lemma at implementation time by
reading the source lemma before transposing it; a lemma that turns out to touch the presentation
must be reported, not silently adapted. `BiLasso/Decide.lean` is 920 lines (README records 905);
re-measure with `wc -l` rather than trusting either number.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` - new file (first tranche)

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- `#eval` smoke test: `decide (LocalCoherentLab W)` evaluates to a Bool on a two-position
  hand-built family without stack overflow or timeout

---

### Phase 7: Decidability part B — the fulfilment block [NOT STARTED]

**Goal**: `WitnessFamily/Decide.lean` (second tranche) — the eventuality-obligation descent and
the `FulfillingLab` window collapse.

**Tasks**:
- [ ] Transpose the whole fulfilment block of `BiLasso/Decide.lean` modulo `A.label → Λ.lab`:
      `UntlObl`, `SnceObl`, `UntlOblB`, `SnceOblB`, `untlObl_descend`, `snceObl_descend`,
      `untlObl_iff_bounded`, `snceObl_iff_bounded`, the four shift lemmas, `eventClauseAt`,
      `FulfilAt`, `fulfilling_iff_forall`, `fulfilling_iff_window`
- [ ] Define the named instance `decidableFulfillingLab`
- [ ] Extend the per-lemma correspondence table in the module docstring so a reader can map each
      declaration back to its `BiLasso/Decide.lean` ancestor by name (not by line number — C20
      gates `file.lean:NNN` citations)
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: ~300 lines — the report identifies this as the largest single chunk
(`BiLasso/Decide.lean` lines 477-909) and as a verbatim transposition. Confirm by checking that
no declaration in this tranche requires a new lemma about `LabelledLasso` that Phase 6 did not
already provide; if one does, add it to Phase 6's tranche rather than inventing a parallel
helper here.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` - extend

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- `#eval` smoke test: `decide (FulfillingLab W)` evaluates to a Bool on the Phase 6 hand-built
  family

---

### Phase 8: Decidability part C — `BoxFaithful`, `Target`, T2 assembly [NOT STARTED]

**Goal**: `WitnessFamily/Decide.lean` (third tranche) — the two remaining predicates, completing T2.

**Tasks**:
- [ ] Prove the `BoxFaithful` window collapse — the one genuinely new collapse:
      `(∀ t : ℤ, χ ∈ lab t) ↔ (∀ t ∈ Finset.Ico (-nb) (nm + nf), χ ∈ lab t)`, by
      `mem_all_neg_of_period` on the left, the `mid` window in the middle, and
      `mem_all_fwd_of_period` on the right
- [ ] Lift the collapse over the family's finite list of lassos
- [ ] Define the named instance `decidableBoxFaithful`
- [ ] Define the named instance `decidableTarget` — decidable outright, two `List.all`s over
      `Γ` and `Del`
- [ ] Confirm all four instances are computable (`#eval` on each, not merely `decide`), and
      record in the module docstring that choice-freedom is **not** claimed, citing
      `BiLasso/Check.lean`'s note on `wlem_of_saturation`
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: local

**Scope Hypothesis**: ~120 lines, and the claim that `BoxFaithful`'s collapse needs only the two
existing period lemmas plus the `mid` window. Confirm by attempting exactly that three-part
decomposition first; if it does not close, the hypothesis is falsified and the extra machinery
required must be reported before being added.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` - extend

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- `#eval` on each of the four instances returns a Bool on a hand-built family
- `#print axioms` on each instance's correctness lemma stays within the declared budget

---

### Phase 9: T3 non-vacuity and impossibility [NOT STARTED]

**Goal**: `WitnessFamily/Examples.lean` — the positive witness, the separation witness, and the
impossibility theorem that replaces the infeasible `#guard`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Examples.lean` importing
      Phases 5 and 8
- [ ] Build the positive witness: a one-lasso family for `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` with `p`
      only at `0`, accepted by the Phase 6-8 instances via `#guard decide (…)`, following
      `BiLasso/Examples.lean` exactly. The consistency check is on record: at `t < 0` the
      disjunct `Fp` holds (witness `0`); at `t = 0`, `p`; at `t > 0`, `Pp` (witness `0`); `¬Pp`
      at `0` holds because `p` occurs nowhere earlier; `Formula.top = bot.imp bot` is forced into
      every label by the `imp` clause together with `bot ∉ L i t`
- [ ] Build the separation witness: a family that is `LocalCoherentLab` and **not**
      `FulfillingLab`, discharged by `#guard !decide (…)`, mirroring `negAnnot`. This is the
      load-bearing one — it is what rules out the silent collapse of the greatest-fixpoint /
      least-fixpoint distinction
- [ ] Prove `no_witnessFamily_of_validZTime`: if `ValidZTime σ` and `σ ∈ Del`, then no
      `WitnessFamily Γ Del` satisfying the three predicates has a `Target`. Route: instantiate
      `joint_countermodel` (Phase 5) and contradict the validity. **This needs no new
      mathematics** — it is a corollary of T1'
- [ ] Prove `no_witnessFamily_of_MF` as the instance at the bimodal axiom MF, using
      `modal_future_valid` from `FormalSystem/Metalogic/Soundness.lean` (which gives universal
      `Valid`, descended to `ValidZTime` by the existing monotonicity lemma). This is the real
      impossibility result the dispatched `#guard` was reaching for
- [ ] Cite every Phase 6-8 instance name in at least one `#guard` or `example` in this file, so
      the C17 dead-declaration scan sees them referenced outside their declaring lines
- [ ] Build in isolation; zero warnings, zero `sorry`

**Timing**: 2 hours

**Depends on**: 5, 8

**Verification Tier**: local

**Scope Hypothesis**: ~250 lines. `(subformulaClosure (□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp))).card = 16`
per research, so the hand-built labels are 16-element-bounded `Finset`s — asserted to be well
inside what `decide` evaluates. Confirm by `#eval (subformulaClosure …).card` before writing the
labels, and by timing the `#guard`; if `decide` does not return promptly, fall back to
`Decidable.decide` on a narrower sub-closure and record the reduction as a reasoned exclusion.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Examples.lean` - new file

**Verification**:
- Module builds in isolation, zero warnings, zero `sorry`
- Both `#guard`s pass at elaboration time
- `#print axioms no_witnessFamily_of_MF` reports within `[propext, Classical.choice, Quot.sound]`

---

### Phase 10: Aggregators, READMEs and the full gate set [NOT STARTED]

**Goal**: Wire the new directory into the build graph and bring every module invariant green.

**Tasks**:
- [ ] Create the sibling aggregator
      `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` re-exporting the six modules (C8)
- [ ] Regenerate the library root with `lake exe mk_all --lib FormalSystem` — never hand-edit
      `FormalSystem.lean` (C33)
- [ ] Update `FormalSystem/Metalogic/Decidability/README.md`'s Modules table with a
      `WitnessFamily/` row. Verify first whether the existing `BiLasso/` row's "outside the build
      graph" phrasing is still accurate before copying it; do not propagate the pre-existing
      tension between that phrasing and the root aggregator's direct imports
- [ ] Update `FormalSystem/Metalogic/Decidability/BiLasso/README.md`: add a pointer to the new
      directory from the Modules section and from the `Basic.lean is held stable` section,
      recording that the new work stands beside `Basic.lean` rather than changing it
- [ ] Cite the new declaration names (not line numbers — C20) in both README tables, covering the
      Phase 6-8 instances for C17
- [ ] If any new flagship theorem needs a C14 documented-axiom baseline row, add it
- [ ] Run `lake build` and confirm green
- [ ] Run `bash scripts/check-module-invariants.sh` and confirm green; address C3, C8, C9, C14,
      C17, C19, C20, C28, C33 findings specifically
- [ ] Confirm zero entries were needed in `scripts/warning-budget.txt` (every new file carries
      zero warnings)

**Timing**: 1 hour

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: two README tables and one regenerated root aggregator, with six new
modules plus one sibling aggregator. Confirm the module count by `ls
FormalSystem/Metalogic/Decidability/WitnessFamily/` and the README row count by diffing the two
tables; the `git diff` on `FormalSystem.lean` must show only added import lines in generated
order.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - new sibling aggregator
- `FormalSystem.lean` - regenerated, not hand-edited
- `FormalSystem/Metalogic/Decidability/README.md` - Modules table row
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - pointer to the new directory

**Verification**:
- `lake build` exits 0
- `bash scripts/check-module-invariants.sh` exits 0
- `git diff --stat` shows no modification to `BiLasso/Basic.lean` or `BiLasso/Decide.lean`

## Lean Challenge Statements

Note for whoever consumes this section: `lean-challenge-snapshot.sh` assembles its Challenge
module by slicing from the first `def`/`theorem`/`instance` match onward, so the two `structure`
declarations below — which are interleaved between definitions because `WitnessFamily` depends on
`closureOf` — are dropped from the assembled module and it will not type-check standalone as
assembled. The block as written here is nonetheless the authoritative statement record, and the
structures are part of it: their field names are the ModelChecker JSON contract and Phase 2 is
required to match them exactly.

```lean
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.FrameClassValidity
import FormalSystem.Syntax.Context
import FormalSystem.Syntax.SubformulaClosure.Closure
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic
import Mathlib.Data.Int.SuccPred
import Mathlib.Order.SuccPred.LinearLocallyFinite

namespace FormalSystem.Metalogic.Decidability.WitnessFamilyChallenge

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability

/-- Set-level subformula closure: the certificate's target set is a `Context`, but
`subformulaClosure` is single-formula only. -/
def closureOf (S : Context) : Finset Formula := sorry

/-- A labelled bi-lasso: three label segments decoded by `Periodic.unrollOf`, with every
label inside the target closure `C`. Field names are the ModelChecker JSON contract. -/
structure LabelledLasso (C : Finset Formula) where
  back : List (Finset Formula)
  mid : List (Finset Formula)
  fwd : List (Finset Formula)
  back_ne : back ≠ []
  fwd_ne : fwd ≠ []
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C

/-- The decoded label function of a single labelled lasso. -/
def lab {C : Finset Formula} (Λ : LabelledLasso C) (t : ℤ) : Finset Formula := sorry

/-- A witness family: a box guess plus a nonempty list of labelled lassos, lasso `0` main. -/
structure WitnessFamily (Γ Del : Context) where
  bx : Formula → Bool
  lassos : List (LabelledLasso (closureOf (Γ ++ Del)))
  lassos_ne : lassos ≠ []

namespace WitnessFamily

variable {Γ Del : Context}

/-- The family's decoded label function, indexed by lasso and time. -/
def L (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) (t : ℤ) : Finset Formula := sorry

/-- Local coherence on labels: the `BiLasso.LocalCoherent` clauses minus the atom and
presentation clauses. Atoms are unconstrained — the valuation is the atom part of the label. -/
def LocalCoherentLab (W : WitnessFamily Γ Del) : Prop := sorry

/-- `BiLasso.Fulfilling` verbatim on the decoded label function. -/
def FulfillingLab (W : WitnessFamily Γ Del) : Prop := sorry

/-- The box guess is exactly global label membership, for every boxed formula in the closure. -/
def BoxFaithful (W : WitnessFamily Γ Del) : Prop := sorry

/-- A time at which every premise is labelled on the main lasso and no conclusion is. -/
def Target (W : WitnessFamily Γ Del) (t : ℤ) : Prop := sorry

/-- The standard shift set over `intOrder`: carrier `Fin (k+1) × ℤ`, shift by time
translation, valuation read off the labels. NOT `@[reducible]`. -/
def std (W : WitnessFamily Γ Del) : ShiftSet intOrder := sorry

/-- The standard model's frame lies in the ℤ-time class. -/
theorem std_isZTime (W : WitnessFamily Γ Del) : W.std.frame.IsZTime := sorry

/-- **T1**, in the inductive shift-set form generalised over the carrier point. -/
theorem shiftTruth_iff_mem (W : WitnessFamily Γ Del)
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful) :
    ∀ ψ : Formula, ψ ∈ closureOf (Γ ++ Del) →
      ∀ (w : W.std.Carrier) (t : ℤ),
        ShiftSet.ShiftTruth W.std w t ψ ↔ ψ ∈ W.L w.1 (w.2 + t) := sorry

/-- **T1**, in `TruthAt` form, via `ShiftSet.forward_repr`. -/
theorem truth_iff_mem (W : WitnessFamily Γ Del)
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (i : Fin W.lassos.length) (t : ℤ) (ψ : Formula) (hψ : ψ ∈ closureOf (Γ ++ Del)) :
    TruthAt W.std.model (W.std.hist ((i, 0) : W.std.Carrier)) t ψ ↔ ψ ∈ W.L i t := sorry

/-- **T1'** — a witness family with a target refutes ℤ-time consequence. -/
theorem not_consequence_ztime (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) {σ : Formula} (hσ : σ ∈ Del) :
    ¬ SemanticConsequenceIn FrameClass.ZTime Γ σ := sorry

/-- **T1'** at the unconstrained class, via `FrameClass.Sat.anti`. -/
theorem not_consequence_base (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) {σ : Formula} (hσ : σ ∈ Del) :
    ¬ SemanticConsequenceIn FrameClass.Base Γ σ := sorry

/-- **T1'**, the joint form ModelChecker reports. -/
theorem joint_countermodel (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) :
    ∃ (F : TaskFrame) (_ : FrameClass.ZTime.Sat F) (M : TaskModel F)
      (τ : WorldHistory F) (u : F.Duration),
      (∀ γ ∈ Γ, TruthAt M τ u γ) ∧ (∀ σ ∈ Del, ¬ TruthAt M τ u σ) := sorry

/-- **T3**, impossibility: no witness family can target a ℤ-time validity. -/
theorem no_witnessFamily_of_validZTime {σ : Formula} (hσ : σ ∈ Del) (hvalid : ValidZTime σ)
    (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) : False := sorry

/-- **T3**, the MF instance: no witness family refutes the bimodal axiom MF. -/
theorem no_witnessFamily_of_MF (φ : Formula)
    (W : WitnessFamily [] [(φ.box).imp ((φ.allFuture).box)]) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) : False := sorry

/-- **T2** — local coherence decides by a bounded window scan. -/
instance decidableLocalCoherentLab (W : WitnessFamily Γ Del) :
    Decidable W.LocalCoherentLab := sorry

/-- **T2** — fulfilment decides by a bounded window scan. -/
instance decidableFulfillingLab (W : WitnessFamily Γ Del) :
    Decidable W.FulfillingLab := sorry

/-- **T2** — box faithfulness decides by the `mid` window plus the two periodicities. -/
instance decidableBoxFaithful (W : WitnessFamily Γ Del) :
    Decidable W.BoxFaithful := sorry

/-- **T2** — the target decides outright, by two list scans. -/
instance decidableTarget (W : WitnessFamily Γ Del) (t : ℤ) :
    Decidable (W.Target t) := sorry

end WitnessFamily

end FormalSystem.Metalogic.Decidability.WitnessFamilyChallenge
```

## Testing & Validation

- [ ] `lake build` exits 0 with no errors
- [ ] `bash scripts/check-module-invariants.sh` exits 0
- [ ] Every new module reports zero `sorry` (C3)
- [ ] `#print axioms` on `truth_iff_mem`, `not_consequence_ztime`, `not_consequence_base`,
      `joint_countermodel`, `no_witnessFamily_of_validZTime` and `no_witnessFamily_of_MF` each
      reports exactly `[propext, Classical.choice, Quot.sound]`
- [ ] Both T3 `#guard`s (positive witness accepted, separation witness rejected by
      `FulfillingLab`) pass at elaboration time
- [ ] All four `Decidable` instances are computable: each is exercised by `#eval`, not only
      `decide`
- [ ] Every new file carries zero compiler warnings, so no `scripts/warning-budget.txt` entry is
      needed (C28)
- [ ] `git diff` shows no modification to `BiLasso/Basic.lean` or `BiLasso/Decide.lean`
- [ ] Both README tables name the new declarations, satisfying C17 for the four instances
- [ ] `FormalSystem.lean` is byte-identical to `lake exe mk_all --lib FormalSystem` output (C33)

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Closure.lean` (new, ~90 lines)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` (new, ~180 lines)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean` (new, ~110 lines)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Std.lean` (new, ~120 lines)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` (new, ~230 lines)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` (new, ~720 lines across
  Phases 6-8)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Examples.lean` (new, ~250 lines)
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` (new sibling aggregator)
- `FormalSystem.lean` (regenerated)
- `FormalSystem/Metalogic/Decidability/README.md` (Modules table row)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (pointer to the new directory)
- `specs/665_witness_family_certificate_soundness/summaries/01_*-summary.md` (at implementation
  completion)

## Rollback/Contingency

The work is almost entirely additive: one new directory plus one new aggregator, with only three
pre-existing files touched (`FormalSystem.lean`, regenerated; the two READMEs). Rollback is
therefore cheap and low-risk.

- **Preferred**: `git revert` this task's own commits, newest first. Every phase commits at a
  green boundary, so any prefix of the phase sequence is a consistent tree.
- **If a phase must be abandoned mid-flight**: delete the phase's new file and re-run
  `lake exe mk_all --lib FormalSystem` if the aggregator had already been regenerated. Nothing
  outside `WitnessFamily/` depends on these modules until Phase 10.
- **If a working-tree rollback is genuinely needed** (not a routine checkpoint): follow
  `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation,
  including its `--allow-out-of-scope` override — required here because a concurrent sibling
  (task 667) may have left tracked modifications outside this task's file scope. Never use the
  bare default-mode call as a precautionary checkpoint; a defensive checkpoint before risky work
  uses `--no-revert`.
- **Contingency for Phase 1's `closureOf`**: index the family by a single `φ : Formula`, exactly
  as `Annot P φ` does, and have ModelChecker emit the conjunction. The research spike was written
  this way and compiles; the cost is an unnatural JSON field, not a proof obstacle.
- **Contingency for Phase 9's impossibility theorem**: if the validity route does not close, fall
  back to the direct box-clause argument — MF's negation needs a point where `□φ` holds and
  `□Gφ` fails, but `BoxFaithful` makes `bx` a global constant, so the two box clauses at a single
  family are contradictory.

## Decisions

1. **Prove agreement against `ShiftTruth`, then compose with `forward_repr`** — not directly
   against `TruthAt`. This is what keeps the `box` case to three lines.
2. **Generalise the inductive statement over the carrier point**, not over the lasso index alone.
   Forced by the `box` clause; the dispatch's stated form is its instance at `(i, 0)`.
3. **`WitnessFamily.std` must not be `@[reducible]`** — reducibility breaks synthesis of
   `ShiftSet.frame_isRegular`.
4. **Place the work in `Metalogic/Decidability/WitnessFamily/`, not inside `BiLasso/`.** The
   family is presentation-free; its only BiLasso dependency is `Periodic.lean`, which is
   deliberately directory-independent.
5. **Index by a set-level `closureOf (Γ ++ Del)`**, with single-`φ` indexing as the documented
   fallback.
6. **Do not touch `Decide.lean` or `Basic.lean`.** The duplication is recorded with a named
   retirement trigger instead of refactored away, because a shared abstraction would put a large
   refactor under a concurrent sibling's feet.
7. **T3's second deliverable is replaced.** The dispatched `#guard` — that no witness family with
   all segment lengths ≤ 2 exists for the negation of MF — is computationally infeasible by about
   twelve orders of magnitude: `(subformulaClosure MF.neg).card = 10`, so up to `1024^6 ≈ 1.2e18`
   label assignments for a single lasso. Per the recorded decision in `.decisions.json`, it is
   replaced by **both** a proved impossibility theorem (`no_witnessFamily_of_validZTime` and its
   MF instance) **and** a hand-built negative witness rejected by the Phase 6-8 instances. These
   deliver the content T3 was reaching for — a real impossibility result plus genuine predicate
   separation — at no enumeration cost. Phase 9 carries both.
8. **Name the conclusion set `Del` in Lean source.** `Σ` is a reserved token and a binder named
   `Σs` fails to parse.
