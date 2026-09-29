# Implementation Plan: L⁺ Certificate Limits and the Finite-Graph Certificate

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IMPLEMENTING]
- **Effort**: 51 hours (16 landed in Phases 1-8; 35 remaining in Phases 9-18)
- **Dependencies**: `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` (landed,
  `FormalSystem/PlusLanguage/PlusIntTransfer.lean`) — still required by the Stage 3 successor
  named under Non-Goals, and no longer on this plan's own critical path, for the reason given
  under "What the carrier-normalization prerequisite now buys" below; the redesigned sharing
  substrate as finally corrected, i.e.
  `FormalSystem.Metalogic.Decidability.SharingSkeleton` together with
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` and its `trans`/`share`
  projections (landed). See "Dependency statement by declaration name" below for the
  `trans_refl` follow-on.
- **Research Inputs**:
  - `specs/703_lplus_compression_and_completeness/reports/01_lplus-compression-completeness-research.md`
  - `specs/703_lplus_compression_and_completeness/reports/02_semantics-first-compression-research.md`
- **Artifacts**: plans/02_lplus-certificate-limits-graph-certificate.md (this file)
- **Reports Integrated**: `01_lplus-compression-completeness-research.md`,
  `02_semantics-first-compression-research.md`
- **Plan Version**: 2 (revision of `plans/01_lplus-compression-completeness.md`)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The theorem this task was originally asked to prove is **false**, and the refutation is
machine-checked. `specs/703_lplus_compression_and_completeness/probes/NoFiniteCertificate.lean`
proves that a specific ℤ-time non-validity of a `PlusFormula` admits **no**
`PlusSharingWitnessFamily` satisfying `PlusCertifies` at any time, for every lasso count, every
segment length and every succession relation. No choice of bounds repairs it. The plan is
therefore re-scoped, on the user's decision, to **candidate H** of the round-2 research report:
a finite-graph certificate whose liveness is computed as a fixpoint rather than demanded.

The re-scoped task has two stages, both of which land results that depend on no open problem.
**Stage 1** turns the refutation into library declarations and corrects every piece of in-tree
documentation that overstates the landed certificate class's coverage. **Stage 2** builds the
finite-graph certificate itself: the certificate type over a finite bi-serial one-step graph
(`FrameOver.ofStep`), its decidable checker with liveness computed as a fixpoint, its soundness
theorem landing the existing `PlusWitnessFamily.PlusRefutes` interface, and the resulting
**completeness relative to finite models**. Stage 3, the finite model property and hence full
completeness, is an explicit **non-goal** of this task and is specified below as a separate,
research-first successor that is **not filed here**.

Definition of done: Stages 1 and 2 land sorry-free with no new axioms, every new flagship
carries a `docs/theorem-index.md` row and a C2 `AXIOM_BASELINE` pin, and
`bash scripts/check-module-invariants.sh` passes in full.

### Withdrawal record — read this before resurrecting anything

**The Lean Challenge Statement of plan v1 is WITHDRAWN.** The withdrawn statement was
`FormalSystem.Metalogic.Decidability.exists_plusSharingWitnessFamily_of_not_plusValidZTime`,
together with the bound `plusFamilyBound` it quantified over. It is not blocked, not
under-resourced, and not waiting on a better bound: **it is false**, and this plan carries the
refutation into the library precisely so that a later reader meets it as a theorem rather than
as a finding in a report.

- **Evidence**: `probes/NoFiniteCertificate.lean`, declaration `Probe703.compression_statement_fails`.
  Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. The orchestrator independently
  recompiled it, and `probes/HopFreeIncomplete.lean`, at dispatch 20. Treated here as established
  fact, not as a claim to re-litigate.
- **Root cause**, from research report 02 section 2.5: the presented frame is limit closed, so a
  path postponing an eventuality for any finite length exists and needs a truthful thread; the
  certificate is finite and eventually periodic, so long postponements can be pumped; and (C2')
  quantifies over **all** threads, so the pumped thread must fulfil, and it cannot. The landed
  class can express only safety structure on threads, while the true type sequences of a
  branching model are defined by a fairness condition.
- **Scope of the failure**: not a corner case. Any target whose countermodels must contain, in a
  periodic region, a cycle with an exit under a pending eventuality is affected.
- **The three Phase 8 BLOCKER resolutions of plan v1 are NOT carried forward.** Widening the
  `mid` bound, reinstating a common cycle length by strengthening Phase 4, and seeking a
  seam-preserving rotation each change a bound or a construction and leave the certificate class
  alone, so each inherits the refutation. They fail the gate criterion (the target statement must
  be true). They are recorded in `plans/01_lplus-compression-completeness.md`, which is retained
  unedited as history; nothing in this plan depends on them and no phase should reopen them.
- **The cycle-6 decision to drop Invariant A is moot**, not overturned. It was sound reasoning
  about a route that does not reach a true theorem. It is preserved in `.decisions.json` and in
  Phase 7 below because the work it governs is landed and stays landed.
- **Also not carried forward**: plan v1's Phases 9 through 13 (`Rep.lean`, `Lift.lean`,
  `Stab.lean`, `Family.lean` and the gate phase that pinned the withdrawn theorem). All five were
  `[NOT STARTED]`, all five exist only to serve the withdrawn statement, and none of the four
  Lean files was ever created. **Do not create them.**

### Research Integration

This plan integrates `reports/02_semantics-first-compression-research.md` (round 2, semantics
first) on top of `reports/01_lplus-compression-completeness-research.md` (round 1). Round 2
supersedes round 1 where they disagree, and the four corrections it records are binding here.

- **Round 1's O2 and O3 answers are superseded.** O3's lasso-count bound does not exist for the
  landed class, because for some targets no family exists at all. O2's general liftable `trans`
  construction serves a withdrawn route.
- **Round 1's O1 and O4 answers stand.** `LiftableRaw` is decidable by subset construction, and
  no GKWZ-style product-undecidability result bounds this combination. Neither is on this plan's
  critical path; both are recorded so a later task does not re-derive them.
- **Round 1's F3 was wrong**: splicing two histories of a regular frame at a common state **does**
  yield a history — `FormalSystem.PlusLanguage.paste` constructs it from Compositionality alone.
  The true seam fact is that a *label row* splices only where state and type agree, proved in
  `probes/TypePreservingPaste.lean`. The corresponding risk row of plan v1 is retired.
- **The five structural facts (S1-S5) of report 02 Part 1 are this plan's semantic ground.**
  Over ℤ a regular task frame is a bi-serial one-step graph whose histories are exactly the
  bi-infinite step paths (`FrameOver.mem_HF_iff_adjacent`, `FrameOver.ofStep`); truth is shift
  invariant (`plusTruthAt_timeShift`); `⊡` is state determined (`stab_state_only`); the histories
  are fusion closed and limit closed; and type-preserving pasting is the correct seam lemma.
  Stage 2's design is read off these five facts and off nothing else.
- **Complexity, stated at its true order.** CTL\* satisfiability reduces to L⁺ ℤ-time
  satisfiability (report 02 section 1.6, labelled *argued*, not machine-checked), so ℤ-time
  validity of L⁺ is 2EXPTIME-hard. The landed **segment** bounds of Phases 3-7 are singly
  exponential and true, but they bound one history's type sequence and say nothing about the
  state space. The expected **state** bound is **doubly exponential**. No phase of this plan
  states a state bound, because this plan proves no state bound; Stage 3 owns that.

### What the carrier-normalization prerequisite now buys

`FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` was Step 0 of the withdrawn
compression theorem: the rewrite that normalizes an arbitrary discrete duration carrier to `ℤ`
before a countermodel is dissected. Under the re-scoped target **no phase of this plan needs it**,
because neither Stage 1 nor Stage 2 starts from `¬ PlusValidZTime φ`: Stage 1 refutes certificate
existence and Stage 2 goes from a finite ℤ-graph countermodel to a certificate and back to
`PlusRefutes`. The theorem remains a genuine prerequisite of the **Stage 3 successor**, which does
start from `¬ PlusValidZTime φ`, and the dependency is therefore retained in the metadata block
rather than dropped. The dispatch's claim that there is no provable Step 0 for the L⁺ statement
without it is correct and unaffected; what changed is that this task no longer has that Step 0.

### Corrections to the dispatch's inherited path claims

Both corrections come from round 1 and are retained because both are still true.

1. `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean:165` does not
   exist and will not be created — see the withdrawal record. The `rw [validZTime_iff_validInt]`
   that is Step 0 lives in the `Formula`-side file
   `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean:165`.
2. The acceptance gate the dispatch calls "a C2 `AXIOM_BASELINE` pin" is real. The `Formula`-side
   compression theorem is pinned by **C14**, not C2, but every landed `PlusSharingWitnessFamily`
   flagship is pinned by **C2**, so the new L⁺ declarations follow the L⁺ convention and go in
   the C2 pair. Phases 12 and 18 own this.

### Dependency statement by declaration name

Stated by fully-qualified declaration name rather than by task number, including the follow-on
that has been proposed but not filed.

- **Required and used by Stage 1** (the refutation quantifies over them, so they must not move):
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` and its `trans`, `share`, `L`,
  `lassos` and `bx` projections; `...PlusSharingWitnessFamily.PlusCertifies`; the six condition
  predicates in `PlusWitnessFamily/Predicates.lean`;
  `FormalSystem.Metalogic.Decidability.SharingSkeleton.Thread` and its `step` field;
  `...SharingSkeleton.transRaw_congr_NF` and `...data_congr_fwd` (the pumping step);
  `FormalSystem.PlusLanguage.PlusNonValidities.NF` and `natModel` (the refuting frame).
- **Required and used by Stage 2**: `FormalSystem.Semantics.FrameOver.ofStep`,
  `...FrameOver.mem_HF_iff_adjacent`, `...FrameOver.taskRel_eq_iter`;
  `FormalSystem.PlusLanguage.plusTruthAt_timeShift`, `...stab_state_only`, `...stab_congr_state`,
  `...paste`; `FormalSystem.Metalogic.Decidability.AUFix` (generic over an arbitrary vertex type
  with `[DecidableEq]`, so reusable verbatim);
  `...PlusWitnessFamily.PlusRefutes` (the interface Stage 2's soundness lands).
- **Proposed but not filed as a numbered task**: an audit of the substrate redesign found that
  the skeleton-wide field `FormalSystem.Metalogic.Decidability.SharingSkeleton.trans_refl`,
  mirrored at `...PlusSharingWitnessFamily.trans_refl`, relocates rather than repairs a
  clause-shape collapse, and should be replaced by a per-producer existential. **No task number
  exists for that follow-on and none is invented here.**
- **Why it is not a blocker, and why that is now easier than it was.** Plan v1 needed `trans`
  reflexivity as a hypothesis of `liftable_of_spliceClosed`, on the withdrawn route. This plan
  **constructs no `PlusSharingWitnessFamily` at all**: Stage 1 quantifies over arbitrary ones and
  Stage 2 introduces a new certificate type that does not extend `SharingSkeleton`. If the
  follow-on lands mid-task, Stage 1's theorems continue to hold — they are universally quantified
  over whatever the structure's fields are — and Stage 2 is untouched. The one obligation is
  mechanical: Phase 9's restatement must be re-checked against the field set on the day it is
  written, since it names `S.trans` in the hop-free hypothesis.

### Soundness is not in question

`FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem` and
`...plusRefutes_of_certifies` are **consumed, never modified**. Their statements must survive this
task **verbatim**, and both are C2-pinned, so any edit to either would be caught by the gate. No
phase below lists `PlusWitnessFamily/Agreement.lean` for modification except as a read. Stage 2's
own soundness theorem is a **new** declaration in a **new** namespace
(`PlusGraphCertificate.plusRefutes_of_certifies`); it lands the same
`PlusWitnessFamily.PlusRefutes Γ Del` interface and does not shadow, replace or weaken the landed
one.

## Goals & Non-Goals

**Goals**:

The identifier set below is exactly the identifier set declared under
`## Lean Challenge Statements`, as that section's contract requires.

- Stage 1, the refutation as library declarations: `pumpTarget`,
  `not_plusValidZTime_pumpTarget`, `not_exists_plusCertifies_pumpTarget`, `hopTarget`,
  `not_plusValidZTime_hopTarget`, `not_exists_hopFree_plusCertifies_hopTarget`.
- Stage 2, the finite-graph certificate and its checker: `PlusGraphPath`,
  `PlusGraphCertificate`, `PlusGraphCertificate.Certifies`,
  `PlusGraphCertificate.decidableCertifies`.
- Stage 2, soundness into the existing interface:
  `PlusGraphCertificate.plusRefutes_of_certifies`.
- Stage 2, completeness relative to finite models:
  `exists_plusGraphCertificate_of_finite_countermodel`.
- Beyond the pinned identifiers, and deliberately named without backticks so the identifier-set
  cross-check above is not polluted: correct every piece of in-tree documentation that overstates
  the landed certificate class's coverage, and add the theorem-index rows and C2 axiom-baseline
  pins the new declarations need. Phases 12 and 18 own that work and name the files.

**Non-Goals**:

- **Stage 3 — the finite model property, and hence full completeness for L⁺ over ℤ — is a
  NON-GOAL of this task.** Its ready-to-file successor description is given below. It is **not
  filed here**, and no phase of this plan may file it.
- The withdrawn compression theorem, its bound `plusFamilyBound`, and the four Lean modules of
  plan v1's Phases 9-12 (`Rep.lean`, `Lift.lean`, `Stab.lean`, `Family.lean`). Do not create them.
- Any state-space bound. This plan proves none and states none. The expectation to relay is
  doubly exponential in the closure; that is a research finding, not a theorem of this tree, and
  every place this plan mentions it says so.
- Characterizing the fragment the landed certificate class **does** cover. Recorded below as an
  open question rather than planned as a phase; the reasoning is in "Open questions recorded, not
  planned".
- An L⁺ enumerator or a decidability assembly. Stage 2 gives a checker, not a search.
- A `Decidable (LiftableRaw …)` instance. Round 1 established it is provable by subset
  construction; nothing here needs it.
- Any change to `plusTruth_iff_mem`, `plusRefutes_of_certifies`, or any other soundness-side
  declaration.
- Any write to the paired repository `/home/benjamin/Projects/ModelChecker`. Phase 12 **reads** it;
  it does not edit it.
- Restating task 704's non-vacuity and shape gates. See "Notes for other tasks" below.

### The Stage 3 successor, specified and deliberately not filed

A future task should be filed with the following description. **This plan does not file it**, and
no phase below may.

> RESEARCH-FIRST. Establish the finite model property for L⁺ over ℤ with a computable state
> bound, and derive full completeness of the finite-graph certificate class from it: every ℤ-time
> non-validity of a `PlusFormula` admits a `PlusGraphCertificate` meeting
> `PlusGraphCertificate.Certifies`, with the carrier bounded by a stated, computable function of
> `plusClosureOf (Γ ++ Del)`. Together with the landed
> `PlusGraphCertificate.plusRefutes_of_certifies` and
> `PlusGraphCertificate.decidableCertifies` this yields decidability of L⁺ ℤ-time validity.
> `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` is the Step 0 this statement rests
> on and has no substitute.
>
> This is expected to be **at least as hard as the corresponding result for CTL\***, and
> **doubly exponential state bounds are expected**: L⁺ ℤ-time validity is 2EXPTIME-hard by the
> CTL\* reduction argued in task 703's round-2 report section 1.6, CTL\*'s known finite models are
> doubly exponential, and the natural quotient by realized-type bundles is known to fail here for
> the reason Reynolds 2001 records — in the limit, a step-by-step or filtration construction
> produces many more paths than were ever chosen explicitly, and a new path can postpone an
> eventuality forever. Any computable bound suffices for decidability; the bound must be stated at
> its true order and never tuned silently.
>
> The research round must decide between the two known routes before any plan is written: the
> deterministic-automata route the CTL\* proofs take (Emerson and Jutla 1988 via Reynolds 2001),
> and a direct construction over the product of the state graph with the Hintikka types. It must
> also decide whether to do the CTL-like fragment first — the fragment in which each `⊡` governs a
> single temporal operator, for which singly exponential finite models are standard — as a staging
> step, or to go at full L⁺ directly. Zero sorries, no new axioms. If the property cannot be
> proved, the correct outcome is a task marked blocked with the obstruction recorded as a theorem
> where possible, never a deferred obligation behind a placeholder.

### Notes for other tasks

- **Task 704 (`certificate_non_vacuity_and_shape_gates`, `[NOT STARTED]`, depends on 696 and
  703).** Its non-vacuity and shape gates are specified against the **old** certificate class and
  need restating against whichever class survives. That restatement is **work for 704, not for
  this task**, and no phase below touches it. Concretely: 704's standin/non-vacuity assertion
  should be restated against `PlusGraphCertificate` once Stage 2 lands, and it should additionally
  gate on the Stage 1 refutation declarations continuing to exist, since they are what stop the
  old class's coverage being overstated again. This note is the hand-off; it is not a dependency
  edit, and this plan does not modify task 704's description or state.
- **The paired repository** `/home/benjamin/Projects/ModelChecker` is hand-off by content only.
  Phase 12 reads it and records what it finds; it never writes to it. See Phase 12 for the
  standing prohibition.

### Open questions recorded, not planned

1. **Which fragment does the landed `PlusSharingWitnessFamily` class actually cover?** Uncharacterized.
   The two refutations delimit it from above (it does not cover `pumpTarget`, and hop-free families
   do not cover `hopTarget`) and `probes/HoppingCertificateExists.lean` delimits it from below, but
   no characterization exists. **This plan records it as an open question and does not allocate a
   phase to it.** Reason: a characterization is an inclusion between bi-infinite fair path
   languages — the same machinery candidate G of report 02 section 3.2 would need, and nothing in
   the tree supports it. It is research-level, it gates nothing in Stage 1 or Stage 2, and the
   honest cheap alternative (a fragment guessed and not proved) is worse than an explicit open
   question. Phase 12 records it in the corrected module documentation so a reader meets the
   question where the class is described.
2. **Whether a singly exponential state bound is possible for L⁺.** Unknown. Nothing excludes it
   unconditionally, but a singly exponential certificate checkable in time polynomial in its size
   would put a 2EXPTIME-hard problem in NEXPTIME. Stage 3's question, not this task's.
3. **Whether L⁺'s past operators, global `□` and two-sided `⊡` raise the complexity above CTL\*'s.**
   Unknown; S5 suggests not, since past and future halves separate, but this is not proved.
4. **The CTL\* reduction of report 02 section 1.6 is argued, not formalized.** It affects the
   complexity picture only. No declaration of this plan depends on it.

## Lean Challenge Statements

Two blocks, one per stage. They concatenate in document order.

Note on shape: `PlusGraphPath` and `PlusGraphCertificate` are `structure`s and therefore carry no
proof body to set to `sorry`. They appear in the second block because the four declarations below
cannot be stated, let alone type-check standalone, without them — the field lists are this plan's
design commitment, and Phase 13 carries a Scope Hypothesis for recording any divergence rather
than absorbing it. The four declarations that do have bodies all carry `sorry`, as the contract
requires.

```lean
import FormalSystem

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Semantics

namespace FormalSystem.Metalogic.Decidability

namespace PlusSharingWitnessFamily

/-- The pumping target: a ℤ-time non-validity no sharing family certifies, at any size. -/
def pumpTarget : PlusFormula := sorry

/-- `pumpTarget` is a genuine ℤ-time non-validity. -/
theorem not_plusValidZTime_pumpTarget : ¬ PlusValidZTime pumpTarget := sorry

/-- **The landed certificate class is incomplete.** No sharing witness family certifies
`pumpTarget` at any time, for any lasso count, segment length or succession relation. -/
theorem not_exists_plusCertifies_pumpTarget :
    ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) [pumpTarget]) (t : ℤ),
        S.PlusCertifies t := sorry

/-- The hop-free target: a ℤ-time non-validity with no long-range eventuality. -/
def hopTarget : PlusFormula := sorry

/-- `hopTarget` is a genuine ℤ-time non-validity. -/
theorem not_plusValidZTime_hopTarget : ¬ PlusValidZTime hopTarget := sorry

/-- **Hop-free families are incomplete independently.** No family whose succession relation
never leaves the index it is read at certifies `hopTarget`. -/
theorem not_exists_hopFree_plusCertifies_hopTarget :
    ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) [hopTarget]) (t : ℤ),
        (∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j) ∧ S.PlusCertifies t :=
  sorry

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
```

```lean
import FormalSystem

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Semantics

namespace FormalSystem.Metalogic.Decidability

/-- **A labelled path through the carrier.** An eventually periodic bi-infinite sequence of
(label, state) pairs, on the same three-segment scheme a `PlusLabelledLasso` decodes. Pairing
the label with the state in one object is what keeps the certificate finite data: the state
sequence and the label sequence are cut at the same recurrence, so they decode together. -/
structure PlusGraphPath (n : ℕ) (C : Finset PlusFormula) where
  /-- Labels and states for the leftward cycle, indexed left-to-right in time. -/
  back : List (Finset PlusFormula × Fin n)
  /-- Labels and states for the finite window `[0, |mid|)`. -/
  mid : List (Finset PlusFormula × Fin n)
  /-- Labels and states for the rightward cycle, indexed left-to-right in time. -/
  fwd : List (Finset PlusFormula × Fin n)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  fwd_ne : fwd ≠ []
  /-- Every listed label is drawn from the given closure. -/
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X.1 ⊆ C

/-- **The finite-graph certificate.** A finite bi-serial one-step graph with a state labelling,
one eventually periodic labelled path for the target, and one labelled witness path for each
stability obligation a state's label leaves open. There is no absolute time, no period and no
alignment: by shift invariance there is nothing to align to. -/
structure PlusGraphCertificate (Γ Del : PlusContext) where
  /-- The finite carrier. -/
  n : ℕ
  /-- The carrier is non-empty. -/
  n_pos : 0 < n
  /-- The one-step relation, as a decidable Boolean graph. -/
  stepR : Fin n → Fin n → Bool
  /-- Forward seriality. -/
  stepR_fwd : ∀ w, ∃ u, stepR w u = true
  /-- Backward seriality. -/
  stepR_bwd : ∀ w, ∃ v, stepR v w = true
  /-- The state labelling: the closure's atoms, `⊡`-formulas and `□`-formulas true at a state. -/
  stateLab : Fin n → Finset PlusFormula
  /-- Every state label is drawn from the target closure. -/
  stateLab_sub : ∀ w, stateLab w ⊆ plusClosureOf (Γ ++ Del)
  /-- The box guess. -/
  bx : PlusFormula → Bool
  /-- The target path, and the time on it at which the target is read. -/
  target : PlusGraphPath n (plusClosureOf (Γ ++ Del))
  /-- The time on the target path at which the target is read. -/
  targetTime : ℤ
  /-- For each state and each stability formula, a labelled witness path. It is constrained by
  the checker only where `⊡χ` is absent from that state's label; elsewhere it is unread. -/
  witness : Fin n → PlusFormula → PlusGraphPath n (plusClosureOf (Γ ++ Del))

/-- **The checker.** Every condition is decided; liveness in particular is COMPUTED as a
fixpoint on the finite product of the state graph with the Hintikka types, never demanded as a
field. -/
def PlusGraphCertificate.Certifies {Γ Del : PlusContext}
    (G : PlusGraphCertificate Γ Del) : Prop := sorry

/-- The checker is decidable. -/
def PlusGraphCertificate.decidableCertifies {Γ Del : PlusContext}
    (G : PlusGraphCertificate Γ Del) : Decidable G.Certifies := sorry

/-- **Soundness.** A certificate meeting the checker produces an explicit ℤ-time joint
countermodel, landing the existing refutation interface unchanged. -/
theorem PlusGraphCertificate.plusRefutes_of_certifies {Γ Del : PlusContext}
    (G : PlusGraphCertificate Γ Del) (h : G.Certifies) :
    PlusWitnessFamily.PlusRefutes Γ Del := sorry

/-- **Completeness relative to finite models.** Every countermodel carried by a finite bi-serial
graph yields a certificate the checker accepts. -/
theorem exists_plusGraphCertificate_of_finite_countermodel
    (Γ Del : PlusContext) {W : Type} [Fintype W] [DecidableEq W] [Nonempty W]
    (R : W → W → Prop) [DecidableRel R]
    (fwd : ∀ w, ∃ u, R w u) (bwd : ∀ w, ∃ v, R v w)
    (M : TaskModel (FrameOver.ofStep R fwd bwd).toTaskFrame)
    (τ : WorldHistory (FrameOver.ofStep R fwd bwd).toTaskFrame) (t : ℤ)
    (hΓ : ∀ γ ∈ Γ, PlusTruthAt M τ t γ) (hDel : ∀ σ ∈ Del, ¬ PlusTruthAt M τ t σ) :
    ∃ G : PlusGraphCertificate Γ Del, G.Certifies := sorry

end FormalSystem.Metalogic.Decidability
```

## Reuse of landed work, stated per file

This section exists so the implementer neither deletes landed true work nor rebuilds what
already exists. **Nothing listed below is to be deleted.** "Unused" means no declaration of
Stage 1 or Stage 2 calls it; it stays compiled, documented and in the tree.

| File | Status under the re-scoped target | What specifically |
|------|-----------------------------------|-------------------|
| `PlusWitnessFamily/TransId.lean` | **True, left in place, unused.** Not a completeness route | `plusLocalCoherentShare_of_transId`, `transId_forces_const_thread`, `thread_eq_const_of_transId`, `plusThreadFulfilling_of_transId`, `transIdOf_hid` are all true and all stay. The hop-free collapse they prove is exactly what Phase 10's refutation shows is **incomplete**, so its module header needs the correction Phase 12 makes — the declarations themselves need nothing |
| `Compression/Types.lean` | **Reused unchanged** | `plusTypeAtM`, `mem_plusTypeAtM`, `plusTypeAtM_subset`, `PlusLocalCoherentSeqLab`, `PlusFulfillingSeqLab`, `plusTypeAtM_localCoherentSeqLab`, `plusTypeAtM_fulfillingSeqLab`, and the three added truth lemmas `plusBox_const`, `plusTruth_untl_succ`, `plusTruth_snce_pred`. This is the label machinery for the target path and every witness path in Stage 2 |
| `Compression/Cycle.lean` | **Reused unchanged** | `PlusTypeState`, `plusTypeOfT`, `card_plusTypeState`, `natCard_plusTypeState`, `PlusSeqStepT`, `iter_plusSeqStepT`, `plusJoinPathT` and its three lemmas, `exists_recurring_plusTypeState`, `plusUntlEventT`/`plusSnceEventT` and their inversions, `plusCycleBoundC`, `exists_base_plusCycleT`, `exists_good_cycle_of_plusTypeSeq`. Phase 17 uses the pigeonhole and the good-cycle theorem to make a finite model's target path eventually periodic |
| `Compression/Fulfil.lean` | **Reused unchanged** | `plusUntl_propagates_to_endC`, `plusSnce_propagates_to_startC`, `plusLab_add_mul_nfC`, `plusLab_sub_mul_nbC`, `plusFulfillingSeqLab_of_good_cycles` |
| `Compression/Extract.lean` — reused half | **Reused unchanged** | `plusTypeOfT_unrollOf`, `plusMidBoundC`, `plusMidBoundC_eq`, `plusCompressionBound`, `plusCycleBoundC_le_plusCompressionBound`, `plusMidBoundC_le_plusCompressionBound`, `plusCompressionBound_pos`, `plusLocalCoherentSeqLab_of_edges`, `exists_plusLabelledLasso_of_history_realized`, `exists_plusLabelledLasso_of_history`, `plusLocalCoherentSeqLab_congr_bx`, `lab_neg`, `lab_mid`, `lab_fwd`. These bound and decode the paths Stage 2's certificate carries |
| `Compression/Extract.lean` — alignment half | **True, left in place, UNUSED.** Nothing is aligned, because on a graph there is nothing to align to (report 02 section 1.3) | `plusAlignOffset`, `plusAlignOffset_pos`, `plusAlignOffset_eq_natCard`, `two_mul_plusAlignOffset_le`, `preBlock`, `shiftBack`, `getD_preBlock`, `getD_shiftBack`, `mem_preBlock_subset`, `mem_shiftBack_subset`, `shiftBy`, `shiftBy_back_length`, `shiftBy_mid_length`, `lab_shiftBy`, `lab_shiftBy_eq`, `plusLocalCoherentSeqLab_comp_sub`, `plusFulfillingSeqLab_comp_sub`, `exists_plusLabelledLasso_of_history_aligned`. **Do not delete any of them** |
| `Compression/Saturate.lean` | **Reused, in a new role**: the (C5) demand layer becomes the state labelling's well-definedness | `plusSameState` and its three equivalence lemmas, `plusTruthAt_stab_of_sameState`, `plusTypeAtM_mem_of_stab_of_state_eq`, `plusTypeAtM_stab_congr_state`, `plusTypeAtM_atom_congr_state`, `exists_history_state_eq_of_not_stab`, `plusTypeAtM_stab_demand`, `plusTypeAtM_stab_iff_forall_sameState`. The two state congruences are exactly what makes `stateLab` a function of the state in Phase 17 |
| `PlusWitnessFamily/{Basic,Closure,Predicates,Decide,Fulfil,Examples,Incompleteness}.lean` | **Unchanged, consumed.** Phase 12 edits documentation in some of them; no declaration changes | Stage 1 quantifies over `PlusSharingWitnessFamily` and `PlusCertifies`; Stage 2 reuses `PlusLabelledLasso` and its decoding |
| `PlusWitnessFamily/Agreement.lean` | **READ-ONLY throughout.** `plusTruth_iff_mem` and `plusRefutes_of_certifies` keep their statements verbatim; `PlusWitnessFamily.PlusRefutes` is the interface Stage 2 lands | Confirmed by an empty `git diff` over the file at Phases 16 and 18 |
| `WitnessFamily/Sharing/Fulfil.lean` | **Reused by import**, generic | `AUFix.step`, `AUFix.iter`, `AUFix.lfp` and their monotonicity/fixpoint/induction lemmas are stated at `{α : Type*} [DecidableEq α]` and mention no formula, so Phase 14 imports them. **AUFix is the universal (`A[g U e]`) fixpoint**; Phase 14 additionally needs an existential fair-path fixpoint, which does not exist in the tree and is new work |
| `WitnessFamily/**` (the `Formula` side) | **Read-only throughout.** No phase edits it | |
| `Compression/{Rep,Lift,Stab,Family}.lean` | **Never created; retired with the withdrawn route** | Do not create them |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 14's existential fair-path fixpoint has no precedent in the tree. `AUFix` is the universal operator and gives the `A[g U e]` half only; the liveness computation needs a greatest-fixpoint / cycle-reachability argument over the product graph, in both time directions | H | M | Phase 14 is dedicated to it, is scheduled before the checker rather than discovered inside it, and is the one phase carrying an explicit decimal-sub-phase contingency. Type-preserving pasting (report 02's S5, `probes/TypePreservingPaste.lean`) is what lets the forward and backward halves be computed separately and then combined, so the two fixpoints never have to be solved jointly |
| Phase 17 (relative completeness) needs the **completeness direction** of the liveness fixpoint: that every live position is realized by an actual labelled path. This is the harder direction and it is the one that makes Stage 2 useful rather than merely sound | H | M | Phase 14 proves both directions of the fixpoint characterization as named lemmas, so Phase 17 cites a lemma rather than re-deriving it. If Phase 17 overruns one agent run it decomposes into 17.1 (forward half) and 17.2 (backward half plus assembly), never into a `sorry` |
| Phase 11's restatement of `no_certificate` is the largest single transcription (the probe is about 420 lines) and may overrun one agent run | M | M | Phase 9 lifts out the shared target syntax and closure-membership scaffolding first, so Phase 11 carries only the pumping argument. Declared contingency: split at the pigeonhole step into 11.1 (the forced-successor consequences of (C0), (C3), (C4), (C5)) and 11.2 (the pumping contradiction with (C2')) |
| The probes were compiled against built `.olean` files that could have gone stale, and the library restatement will be compiled against a different import surface | M | L | Each of Phases 9-11 ends with a real `lake build` of the new module, not a probe recompile. The probes stay in `probes/` as the provenance record and are **not** deleted when the library declarations land |
| A `structure` field of `PlusGraphCertificate` turns out wrong once the checker is written, invalidating the pinned Lean Challenge Statement | M | M | Phase 13 carries a Scope Hypothesis: the field list is confirmed by writing the checker's signature against it before the structure is declared final, and any divergence is recorded at the phase heading as a deviation rather than absorbed. The three theorem statements are what must not drift; the field list is a design commitment that may be corrected once, loudly |
| C17's dead-declaration census reports the now-unused alignment half of `Compression/Extract.lean` | L | H | **Not a gate failure.** C17 is reporting-only: `scripts/check-module-invariants.sh` states "No ENFORCE_C17 flag -- reporting-only per the delegation", and a textual census with a known false-positive rate never affects the exit code. Phase 12 records the expected C17 report in the module docstring so a later reader does not mistake it for rot |
| `.githooks/pre-commit` fires on every commit staging a `.lean` file because this task's new modules move the committed counts in `typst/generated/status.typ` | M | H | Same mechanism plan v1 recorded, and its condition is now met: `specs/state.json` reports task 650 as `completed`. Phase 18 runs `bash scripts/typst-sync-check.sh --fix` and commits **only** `typst/generated/status.typ`, by explicit path. Before any use of the hook's `--no-verify` bypass, confirm the count drift is the **only** failing gate; anything else the hook reports is to be fixed, never bypassed |
| A concurrent sibling touches this working tree | M | M | Re-read every file immediately before editing; stage only this task's own files by explicit path, never a directory or glob `git add`; never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this task's files as possibly a sibling's in-flight edit; stop and report any foreign commit or foreign uncommitted modification after checking `git log` |
| A phase cannot close a goal and reaches for a `sorry` | H | L | Acceptance is zero sorries and no vacuous placeholder definitions. The correct response is plan decomposition into a new decimal sub-phase, never deferral and never a `def X := True` |
| Documentation corrections in Phase 12 overstate in the other direction, reading the refutation as a defect in the substrate redesign | M | M | It is not one. The redesign did what it was for: `Examples.lean`'s two certificates are real and `Incompleteness.lean`'s two refuted congruences are real. What Phase 12 corrects is a claim about **coverage**, and each edit must say what remains true as well as what does not |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 6 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 7 | 4, 5, 6 |
| 6 | 8 | 7 |
| 7 | 9 | 8 |
| 8 | 10, 11 | 9 |
| 9 | 12 | 10, 11 |
| 10 | 13 | 12 |
| 11 | 14 | 13 |
| 12 | 15 | 14 |
| 13 | 16 | 15 |
| 14 | 17 | 16 |
| 15 | 18 | 17 |

Phases within the same wave can execute in parallel. Phases 1 through 8 are landed and are
reproduced below as the record of what exists; the live work starts at Phase 9.

---

## Landed work, preserved (Phases 1-8)

The eight phases below are the record of what exists in the tree. Phases 1 through 7 are
reproduced from plan v1 unchanged, including their deviation and closure records, because the
work they describe is landed, true and — with the single exception noted in the reuse table —
reused by Stage 2. **Nothing in these eight phases is to be redone, and nothing is to be
deleted.** Phase 8 is the one whose status changed at this revision; its own heading says why.

**Forward references inside the preserved text point at plan v1's numbering, not this plan's.**
Where Phases 1, 6 and 7 below say "Phase 8", "Phase 9" or "Phase 12" they mean plan v1's
representative-structure, splice-closure and assembly phases — all withdrawn, none of which
exists here. Phases 9 through 18 of *this* plan are Stage 1 and Stage 2 and have nothing to do
with them. The preserved sentences are history and are left unedited so the record is not
retouched; they are not instructions.

One superseding note applies to Phases 7 and 8 and is stated once, here, rather than being
interleaved into their preserved text: both phases argue about **alignment**, and alignment is
an artefact of representing a shift-invariant semantics as rows pinned to absolute time. On the
graph Stage 2 builds there is nothing to align to, so neither phase's remaining difficulty
recurs. Their landed declarations are unaffected by that observation and remain correct.

---

### Phase 1: The `transId` collapse for (C1') and (C2') [COMPLETED]

**Goal**: Prove that on a hop-free family — one whose `trans` relates an index only to itself —
the two branching conditions (C1') and (C2') follow from the per-lasso conditions
`PlusLocalCoherentLab` and `PlusFulfillingLab`. This is the design claim the whole route rests
on, so it is established first and as a reusable library lemma rather than as a throwaway probe.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean` with the module
      docstring, `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Predicates`, and
      the `FormalSystem.Metalogic.Decidability` namespace.
- [x] Prove `plusLocalCoherentShare_of_transId`. Under `hid`, the `untl` clause's `j` and the
      `snce` clause's `k` are forced equal to `i`, so each branching clause is exactly its
      one-position instance. Mirror the shape of the landed `plusUntl_self_of_share` and
      `plusSnce_self_of_share`, which are the same instantiation read in the opposite direction.
- [x] Prove `transId_forces_const_thread`: under `hid`, every `Thread`'s index function is
      constant. `Thread.step θ u : S.trans u (θ.idx u) (θ.idx (u + 1))` plus `hid` gives
      `θ.idx u = θ.idx (u + 1)`; extend to all of ℤ by induction in both directions.
- [x] Prove `plusThreadFulfilling_of_transId` from the previous item plus `Thread.ext` and
      `Thread.const_idx`. *(deviation: altered — routed through a named intermediate
      `thread_eq_const_of_transId`, which is exactly the `Thread.ext` + `Thread.const_idx` step
      the task names, extracted as a reusable lemma rather than inlined)*
- [x] Prove `transIdOf_hid`: a family whose three `trans` segments are `transIdOf` applied to the
      three `rep` segments satisfies `hid`. This is the form Phase 9 will hand in.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.
- [x] Confirm the new module transitively imports `FormalSystem.Init` (invariant C24).

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean` - new file, the five
  declarations above
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.PlusWitnessFamily` exits 0.
- `#print axioms` on each new declaration shows no axiom beyond `propext`,
  `Classical.choice`, `Quot.sound`.
- No `sorry` in the new file.

---

### Phase 2: L⁺ compression types and the sequence-level predicates [COMPLETED]

**Goal**: Transcribe the `Formula`-side `Compression/Types.lean` layer to L⁺: the type-at-a-model
map and the two sequence-level predicates that the cycle extraction and the readout both consume.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Types.lean`.
- [x] Define `plusTypeAtM`, the L⁺ twin of `typeAtM` (`Compression/Types.lean:81`): the closure
      members true at a history and time. Note the model side needs no new types —
      `PlusValidInt` quantifies over the same `FrameOver intOrder`, `TaskModel` and
      `WorldHistory` the `Formula` side uses; only the truth predicate differs (`PlusTruthAt`
      rather than `TruthAt`).
- [x] Prove `mem_plusTypeAtM` and `plusTypeAtM_subset`, the membership characterization and the
      closure containment.
- [x] Define `PlusLocalCoherentSeqLab` and `PlusFulfillingSeqLab`, the sequence-level twins of
      `LocalCoherentSeqLab` and `FulfillingSeqLab`. These are stated on a bare `ℤ → Finset
      PlusFormula`, with no family in sight, which is what lets the cycle extraction manipulate
      them.
- [x] Prove `plusTypeAtM_localCoherentSeqLab` and `plusTypeAtM_fulfillingSeqLab`: the truth oracle
      realizes both predicates. Five clauses for the first, two directions for the second.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis** *(confirmed at implementation time)*: the declaration list was diffed
against `WitnessFamily/Compression/Types.lean`. The L⁺ `stab` constructor forces **no** extra
clause in either predicate — `⊚` is not an eventuality and has no one-step unfolding, and (C5) is
a family condition that cannot be stated at a bare label sequence — so both predicates keep
exactly five and two clauses respectively. Three supporting truth lemmas *were* added, and are
recorded rather than absorbed: `plusBox_const`, `plusTruth_untl_succ` and `plusTruth_snce_pred`.
The `Formula` side gets these free from `Semantics/TruthTransport.lean` and
`BiLasso/Unfold.lean`; neither has an L⁺ counterpart anywhere in the tree, so the L⁺ module
proves all three. Original hypothesis, for the record: the `Formula`-side `Compression/Types.lean` is 224 lines and the L⁺
transcription is estimated at a comparable size with no structural additions. Confirm at
implementation time by diffing the declaration list against
`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Types.lean`; if the L⁺ `stab`
constructor forces an extra clause in either predicate, record the addition rather than absorbing
it silently.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Types.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- Each of the two realization lemmas is confirmed to mention `PlusTruthAt`, not `TruthAt`.

---

### Phase 3: Type-state carrier, pigeonhole, and path joining [COMPLETED]

**Goal**: Transcribe the first half of the cycle machinery: the finite type-state carrier, its
cardinality bound, the step relation on it, and the path-joining lemmas that let two cycles be
concatenated.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Cycle.lean`.
- [x] Define `PlusTypeState` over a `C : Finset PlusFormula` and `plusTypeOfT`; prove
      `plusTypeOfT_subset`.
- [x] Prove `card_plusTypeState` and `natCard_plusTypeState`, the cardinality bounds that make the
      pigeonhole finite.
- [x] Define `PlusSeqStepT` and prove `iter_plusSeqStepT`.
- [x] Transcribe `exists_iterT_lt_card_aux` and `exists_iterT_lt_card`, the generic finite-relation
      pigeonhole. *(deviation: altered — REUSED by import, not transcribed; see the Scope
      Hypothesis result below)* These are stated over an abstract `[Finite W] [Nonempty W]`, so they may be
      reusable verbatim from the `Formula` side — check before re-proving.
- [x] Define `plusJoinPathT` and prove `plusJoinPathT_left`, `plusJoinPathT_right`,
      `plusJoinPathT_steps`.
- [x] Prove `exists_recurring_plusTypeState`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis** *(confirmed at implementation time: REUSE, not transcribe)*: both
signatures were read. `exists_iterT_lt_card_aux {W : Type} [Finite W] [Nonempty W]
(R : W → W → Prop)` and `exists_iterT_lt_card` mention neither `Formula` nor `TypeState C`
anywhere, load-bearing or otherwise. Both are therefore reused by importing
`FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Cycle`, and that import is
recorded in the new module's header as a decision. Every other declaration of the `Formula`-side
module IS monomorphic in `Formula` through `TypeState C = {S : Finset Formula // S ∈ C.powerset}`
and was transcribed. Original hypothesis, for the record: the generic pigeonhole pair `exists_iterT_lt_card_aux` /
`exists_iterT_lt_card` is asserted to be formula-agnostic and therefore reusable from the
`Formula`-side module without re-proof. Confirm at implementation time by reading their
signatures in `WitnessFamily/Compression/Cycle.lean`; if either mentions `Formula` or
`TypeState C` in a load-bearing position, transcribe instead of importing and say so.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Cycle.lean` - new file,
  first half

**Verification**:
- `lake build` of the new module exits 0; no `sorry`.
- `card_plusTypeState` is checked against a small concrete closure to confirm the bound is not
  off by a factor.

---

### Phase 4: Eventuality events, the cycle bound, and good cycles [COMPLETED]

**Goal**: Complete the cycle machinery: the eventuality-event decoders, the cycle-length bound,
and the extraction of a good cycle from an arbitrary type sequence.

**Tasks**:
- [x] Define `plusUntlEventT` and `plusSnceEventT` and prove their `eq_some` inversion lemmas.
- [x] Define `plusCycleBoundC` and prove `plusCycleBoundC_eq`.
- [x] Prove `exists_base_plusCycleT`.
- [x] Prove `exists_good_cycle_of_plusTypeSeq`, the phase's deliverable: from any type sequence,
      a cycle bounded by `plusCycleBoundC` on which every eventuality present is discharged.
- [x] Confirm the L⁺ closure's `stab` members need no event decoder. `⊡` is not an eventuality —
      it has no unfolding clause in (C1') by design — so the two decoders stay at `untl` and
      `snce` exactly as on the `Formula` side.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Cycle.lean` - second half,
  appended

**Verification**:
- `lake build` exits 0; no `sorry`.
- `exists_good_cycle_of_plusTypeSeq`'s statement is diffed against the `Formula`-side
  `exists_good_cycle_of_typeSeq` and any divergence is explained in the docstring.

---

### Phase 5: Fulfilment from good cycles [COMPLETED]

**Goal**: Transcribe the fulfilment layer: eventuality propagation to a cycle endpoint, label
periodicity under the two cycle lengths, and the assembly of `PlusFulfillingSeqLab` from a pair of
good cycles.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Fulfil.lean`.
- [x] Prove `plusUntl_propagates_to_endC` and `plusSnce_propagates_to_startC`.
- [x] Prove `plusLab_add_mul_nfC` and `plusLab_sub_mul_nbC`, the forward and backward label
      periodicities.
- [x] Prove `plusFulfillingSeqLab_of_good_cycles`, the phase's deliverable.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Fulfil.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.

---

### Phase 6: Generic readout and the segment bound [COMPLETED]

**Goal**: Transcribe the generic readout layer — the lemmas that turn three finite segments into a
bi-infinite function and back — and define `plusCompressionBound`.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean`.
- [x] *(resolved: ALL EIGHT reused by import, zero transcribed)* Transcribe or import `getD_mapC`, `getD_range_mapC`, `reduce_emodC`, `emod_succ_congrC`,
      `periodic_rel_of_windowC`, `readout_backC`, `readout_midC`, `readout_fwdC`. These are
      generic over `α` with `[Inhabited α]` on the `Formula` side, so they are candidates for
      reuse rather than transcription — check each signature first.
- [x] Prove `plusTypeOfT_unrollOf`, the decoding lemma specialized to L⁺ type states.
- [x] Define `plusMidBoundC` and prove `plusMidBoundC_eq`.
- [x] Define `plusCompressionBound` and prove `plusCycleBoundC_le_plusCompressionBound` and
      `plusMidBoundC_le_plusCompressionBound`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis** *(confirmed at implementation time; count: 8 reused, 0 transcribed)*: each
signature was read. `getD_mapC`, `getD_range_mapC`, `periodic_rel_of_windowC`, `readout_backC`,
`readout_midC` and `readout_fwdC` are declared over `{α : Type*} [Inhabited α]`; `reduce_emodC`
and `emod_succ_congrC` are pure `Int.emod` facts over bare integers. None mentions `Formula`,
`Context`, `closureOf` or `TypeState`, so all eight are reused by importing
`WitnessFamily/Compression/Extract.lean`. The one readout-layer declaration that is NOT generic,
`typeOfT_unrollOf`, is stated at `TypeState C` and was transcribed as `plusTypeOfT_unrollOf`.
One declaration was added beyond the plan's list and is recorded here rather than absorbed:
`plusCompressionBound_pos`, which Phase 7's Invariant A needs so a padded segment is never the
empty list.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean` - new file,
  first half

**Verification**:
- `lake build` of the new module exits 0; no `sorry`.
- `plusCompressionBound` is evaluated on a small concrete `φ` to confirm it is finite and
  non-zero.

---

### Phase 7: Single-history lasso extraction, with the two construction invariants [COMPLETED WITH EXCLUSIONS]

**PLAN DEVIATION — Invariant A dropped (orchestrator decision, cycle 6, 2026-09-29)**:
resolution 1 of the "What is needed" list below was taken. Invariant A ("pad every segment to a
common length `plusCompressionBound`") is **dropped**: it is unprovable as written, and nothing
downstream needs it for correctness. The segment bounds Phase 12 states come free from the
unpadded extraction. Invariant B survives via the shift mechanism recorded in the BLOCKER's
"Invariant B is not blocked by the same argument" bullet. The compression theorem's stated
segment bound and the Lean Challenge Statement are **unchanged**. Recorded in
`specs/703_lplus_compression_and_completeness/.decisions.json`. The decision was taken by the
orchestrator on the previous agent's recommendation because the user was unavailable, and the
user may overturn it.

*Refinement found at implementation time*: the BLOCKER's Invariant B sketch normalizes to the
**maximum landing offset over the extracted lassos**, which makes the common offset depend on the
list and pushes `|mid'|` to below `3 · 2^κ`. The implementation instead normalizes to the
**constant** `plusAlignOffset Γ Del = 2 ^ κ`, which is independent of the history, the time and
the list, and which keeps `|mid'| < 2 · 2^κ = plusMidBoundC ≤ plusCompressionBound` — the original
mid bound rather than a widened one. This is strictly stronger than the sketched mechanism and
needs no `κ ≥ 1` side condition.

**BLOCKER** (Phase 7) *(retained for the record; resolved by the deviation above)*:

- **What failed**: Invariant A, "pad `back` and `fwd` by repetition so every extracted lasso has
  `back.length = fwd.length = plusCompressionBound Γ Del`". It is not provable as written, and
  the risk-table mitigation it serves ("so `NB = NF = plusCompressionBound`") is false about the
  landed substrate independently of it.

- **What was tried**: the padding lemma was attempted first, before the main extraction, exactly
  as this phase's Scope Hypothesis directs. Three routes were considered and each fails on the
  arithmetic rather than on a tactic.

  1. *Padding by repetition.* Repeating a cycle list `m` times preserves the decoded label
     function, because `Periodic.cyc` reads `i % length` and `i % (m·L) % L = i % L`. So
     repetition reaches exactly the multiples of `L` and nothing else. Hitting
     `plusCompressionBound` therefore requires `L ∣ plusCompressionBound` for every extracted
     cycle length `L`, which the good-cycle theorem does not provide and which is false.
  2. *Changing a cycle's length some other way.* The decoded function's period on the `back`
     segment is exactly `back.length`, through `Periodic.cyc`. A non-multiple length changes the
     decoded function, so no other length-changing operation preserves `lab`.
  3. *Choosing a common length at construction time.* Achievable cycle lengths through a
     recurring type are the differences of its recurrence times, closed under addition but not
     arbitrary. `exists_base_plusCycleT` returns `L = b + 1` with `b < Nat.card (PlusTypeState C)`,
     so every `L` in `1 … 2^|C|` is permitted by its own statement.

- **Concrete refutation** (κ = |plusClosureOf (Γ ++ Del)| = 3): `Nat.card (PlusTypeState C) = 8`,
  so `exists_base_plusCycleT` permits every cycle length in `1 … 8`, and
  `plusCompressionBound = (2·3 + 1) · 2^3 = 56`. Three lassos with back lengths 5, 7 and 8 admit
  no common padded length below `lcm(5, 7, 8) = 280`, which exceeds 56. So no common segment
  length satisfying the theorem's own `Λ.back.length ≤ plusCompressionBound` bound exists.
  (At κ = 2 the invariant happens to be satisfiable — `lcm(1…4) = 12 ≤ 20` — which is why the
  failure is not visible on a small example.)

- **Why it is stuck — the second, independent defect**: the invariant's stated purpose does not
  describe this tree. `PlusWitnessFamily/Decide.lean`'s `perBack` is
  `repBack.length * (lassos.map (·.back.length)).prod` — a **product**, never a least common
  multiple. So "leaving segments at differing lengths makes `NB`/`NF` a least common multiple
  over up to `n` lengths" is not what the landed substrate does, and a common length `L` would
  give `NB = |repBack| · L^n`, not `plusCompressionBound`. The mitigation's stated outcome
  `NB = NF = plusCompressionBound` holds only when `n = 1` and `|repBack| = 1`.

- **What is needed** (a plan decision, not a proof): one of

  1. **Drop Invariant A.** Nothing downstream needs it for *correctness*. The segment bounds
     Phase 12 states come free from the unpadded extraction, which already returns
     `≤ plusCompressionBound`. Phase 9's `repBack_ne` / `repFwd_ne` are about the representative
     segments, which this task constructs directly and can make non-empty without A. `NB`/`NF`
     are `abbrev`s whose well-formedness (`NB_pos`, `nbr_dvd_NB`, …) is already proved generically
     for an arbitrary family. This is the recommended resolution.
  2. **Keep a common length and widen the bound.** Set the common length to a common multiple of
     the extracted cycle lengths and enlarge `plusCompressionBound` accordingly, propagating the
     new form into Phases 8 and 12 and into the Lean Challenge Statement's segment bounds. This
     makes the stated bound substantially worse for no correctness gain.
  3. **Strengthen the good-cycle theorem** so it returns a cycle whose length divides a declared
     modulus. That is a real change to Phase 4's landed `exists_good_cycle_of_plusTypeSeq` and
     needs its own design round.

- **Invariant B is not blocked by the same argument, but its stated mechanism is.** B ("normalize
  the landing position to a single canonical offset, by rotating the padded segments") is
  achievable by a *different* mechanism: shift a lasso rightward by `k` by prepending the `k`
  labels `lab (-k) … lab (-1)` to `mid` and rotating `back` by `-k`, which satisfies
  `lab' t = lab (t - k)` on all four decoding regions. Taking `k` to the maximum landing offset
  keeps `|mid'| = |mid| + k < 3 · 2^κ ≤ plusCompressionBound` for `κ ≥ 1`. It was **not
  implemented**, because its stated mechanism presupposes Invariant A's padded segments and
  substituting a different mechanism while A is unresolved is exactly the silent substitution
  `.claude/rules/plan-compliance.md` forbids on `.lean` files.

- **Prohibited workarounds**: no `sorry`, no `def X := True`, no vacuous placeholder. Nothing of
  the kind was written; the subtree is sorry-free and axiom-clean.


**Goal**: Prove the L⁺ twin of `exists_labelledLasso_of_history_realized`: every history of a
ℤ-frame countermodel compresses, at a given time, to a bounded `PlusLabelledLasso` that is locally
coherent, fulfilling, and realized by the model. Establish the two construction invariants the
later phases depend on.

**Tasks**:
- [x] Prove `exists_plusLabelledLasso_of_history_realized`. It must return, alongside the lasso,
      the landing position of the original time and the realization fact
      `∀ j, ∃ u, Λ.lab j = plusTypeAtM M Γ Del σ u`.
- [ ] **Invariant A — common cycle length.** *(deviation: skipped — dropped by the orchestrator
      decision recorded above; not provable as written, and not needed for correctness)* Pad
      `back` and `fwd` by repetition so every extracted
      lasso has `back.length = fwd.length = plusCompressionBound Γ Del`, and `mid.length` likewise
      padded to that bound. Prove padding preserves `lab`, hence preserves local coherence,
      fulfilment and realization. This is what keeps `NB`/`NF` from becoming a least common
      multiple over `n` differing lengths.
- [x] **Invariant B — common time alignment.** *(deviation: altered — normalized to the constant
      `plusAlignOffset Γ Del = 2 ^ κ` rather than to the maximum landing offset over a list, and
      by the `plusShift` prepend-and-rotate mechanism rather than by rotating Invariant A's padded
      segments, which no longer exist)* Prove that the landing position can be normalized
      to a single canonical offset across all extracted lassos, by rotating the padded segments.
      (C5) pins its witness to the same time `u` as the demand, so without this the witness lassos
      are re-timed and certify nothing.
- [x] Prove `plusLocalCoherentSeqLab_congr_bx`, transport of local coherence along a change of box
      guess that agrees on the boxed part of the closure.
- [x] Prove `exists_plusLabelledLasso_of_history`, the realization-free corollary.
- [x] *(addition, recorded)* Prove `plusLocalCoherentSeqLab_of_edges`, the presentation-free
      splice lemma the extraction consumes. It is monomorphic in `PlusFormula` and was held back
      from Phase 6 so that Phase 6 matched its own task list exactly.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.

**Timing**: 2 hours

**Depends on**: 4, 5, 6

**Verification Tier**: interface

**Scope Hypothesis** *(result: REFUTED for Invariant A)*: the padding and rotation lemmas were
attempted before the main extraction, as directed. Invariant A does **not** force a structural
change to `PlusLabelledLasso` — the landed type was not edited and must not be — but it is not
provable at the extraction site either, for arithmetic reasons recorded in the BLOCKER above.
Original hypothesis, for the record: this phase asserts that Invariants A and B are provable at the extraction
site rather than requiring a change to `PlusLabelledLasso`. Confirm at implementation time by
proving the padding and rotation lemmas before the main extraction; if either forces a structural
change to the lasso type, stop and record it as a plan deviation rather than editing the landed
type in passing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean` - second half,
  appended
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The two invariants are stated as named lemmas, not as side conditions buried in the extraction
  proof, so Phases 8 and 9 can cite them.

#### Reasoned Exclusions

*(Added at plan v2. The exclusion itself was decided and recorded at plan v1; this table states
it in the format the checklist requires, and adds nothing that was not already decided.)*

| Item | Reason | Evidence |
|------|--------|----------|
| Invariant A, "pad `back` and `fwd` by repetition so every extracted lasso has `back.length = fwd.length = plusCompressionBound Γ Del`" | Not provable as written: repetition reaches only multiples of a cycle's length, and `exists_base_plusCycleT` permits every length in `1 … 2^κ`, so a common padded length would have to exceed the bound the theorem itself states. Nothing downstream needs it for correctness | The concrete refutation at κ = 3 recorded in this phase's BLOCKER: cycle lengths 5, 7 and 8 admit no common padded length below `lcm(5, 7, 8) = 280`, against `plusCompressionBound = 56`. Recorded decision in `specs/703_lplus_compression_and_completeness/.decisions.json`, cycle 6 |
| The invariant's stated purpose, "so `NB = NF = plusCompressionBound`" | False about the landed substrate independently of the invariant: `perBack` is a product, never a least common multiple | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean:181`, `perBack := repBack.length * (lassos.map (·.back.length)).prod` |

**No residual work**: Invariant B was landed by a different and strictly stronger mechanism (the
constant-offset shift), and the segment bounds come free from the unpadded extraction. At plan v2
the question is moot in a second way as well: nothing in Stage 2 is aligned, so no later phase
reopens it.

**Closure record** *(exclusion: Invariant A, per the deviation at this phase's heading)*:
Invariant B is stated as the named lemmas `PlusLabelledLasso.shiftBy`,
`PlusLabelledLasso.lab_shiftBy`, `plusLocalCoherentSeqLab_comp_sub`,
`plusFulfillingSeqLab_comp_sub` and the consumer form
`exists_plusLabelledLasso_of_history_aligned`, all in `Compression/Extract.lean`, so Phases 8 and
9 cite a lemma rather than re-deriving a side condition. `exists_plusLabelledLasso_of_history_realized`
was strengthened, not weakened: it now additionally returns `i < plusAlignOffset Γ Del` and
`Λ.nm - i < plusAlignOffset Γ Del`, which is what makes the shifted mid bound come out at the
original `plusMidBoundC` rather than a widened one. The module builds with zero errors and zero
warnings and the subtree is sorry-free.

---

### Phase 8: The (C5) saturation — the lasso list and its bound [COMPLETED WITH EXCLUSIONS]

**Status change at plan v2, recorded**: this phase was `[BLOCKED]` in plan v1. It is now closed
with exclusions, because the target its remaining tasks served is **withdrawn as false** and no
future dispatch will revisit them. This is the canonical decision-gate shape: the phase's
blocker was the gate, the gate failed, and the plan's contingency branch — Stages 1 and 2 —
runs instead of the phases the gate would have unlocked. **The three resolutions plan v1
enumerated under this phase's BLOCKER are not carried forward and are not to be reopened**; all
three leave the certificate class alone and therefore inherit the refutation. They remain
readable in `plans/01_lplus-compression-completeness.md`.

**Goal** *(as planned; partly achieved, see the exclusions)*: build the lasso list by saturating
the (C5) witness demand, and prove the resulting count is bounded by `plusFamilyBound`.

**Tasks**:
- [x] Define the (C5) demand: for an index `i`, a window time `u`, and `stab φ` in the closure
      with `stab φ ∉ L i u`, the countermodel supplies a history `τ` with the same world state as
      `i`'s history at `u` and `¬ PlusTruthAt M τ u φ`. Prove this from `PlusTruthAt`'s `stab`
      clause. **Landed** as `Compression/Saturate.lean`, sorry-free and axiom-clean:
      `plusSameState`, `plusSameState_refl`, `plusSameState_symm`, `plusSameState_trans`,
      `plusTruthAt_stab_of_sameState`, `plusTypeAtM_mem_of_stab_of_state_eq`,
      `plusTypeAtM_stab_congr_state`, `plusTypeAtM_atom_congr_state`,
      `exists_history_state_eq_of_not_stab`, `plusTypeAtM_stab_demand`,
      `plusTypeAtM_stab_iff_forall_sameState`. *(the `→` direction and the two state congruences
      were added beyond plan v1's list and are recorded rather than absorbed)* This work is
      **design-independent** and is reused by Stage 2 — see the reuse table above.
- [~] *(excluded)* Define the saturation operator.
- [~] *(excluded)* Prove the saturation closes.
- [~] *(excluded)* Define `plusFamilyBound` and prove `lassos.length ≤ plusFamilyBound Γ Del`.
- [~] *(excluded)* Prove every listed lasso is bounded, locally coherent, fulfilling and realized.
- [~] *(excluded)* Record the superseded bound accountings in the module docstring.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The (C5) saturation operator | It exists only to build a `PlusSharingWitnessFamily` certifying an arbitrary ℤ-time non-validity. No such family exists for `pumpTarget`, so the operator cannot have the property it was to be built for, at any size | `probes/NoFiniteCertificate.lean`, `Probe703.compression_statement_fails`: sorry-free, axioms `[propext, Classical.choice, Quot.sound]`, recompiled independently at dispatch 20 |
| The proof that the saturation closes | Same reason: the fixpoint it would reach is a family that is proved not to exist for this target | Same declaration |
| `plusFamilyBound` and the lasso-count bound | There is no lasso-count bound to prove. Round 1's `2^|closure| × W` estimate is superseded, not merely unproved, because for some targets no family exists at any count | `reports/02_semantics-first-compression-research.md`, "Corrections to round 1", item 3; and the probe above |
| The per-lasso preservation lemmas across the saturation | They are properties of a construction that is not being built | Withdrawal record at the head of this plan |
| The module-docstring record of superseded accountings | Superseded by Phase 12, which corrects the coverage claims across the whole subtree in one pass rather than per module | Phase 12 below |
| The alignment budget that blocked this phase | The binding constraint was the withdrawn theorem's own `mid` bound. With the theorem withdrawn there is no budget to resolve, and on a graph there is nothing to align to | `reports/02_semantics-first-compression-research.md` section 1.3 and section 2.2 |

**No residual work**: nothing above is deferred, and no follow-up task records any of it. The
useful content of this phase — the demand layer — is landed and is consumed by Stage 2.

**Timing**: 2 hours planned; the landed task 1 took approximately 1 hour

**Depends on**: 7

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Saturate.lean` - new file, landed
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line, landed

**Verification** *(as achieved)*:
- `lake build` exits 0; the module is sorry-free and axiom-clean; zero errors and zero warnings.
- The count bound is **not** proved, and is excluded above rather than left as a commented
  estimate.

---

## Stage 1 — Land the refutation and correct the record (Phases 9-12)

Stage 1 turns two machine-checked probes into library declarations and stops the tree from
overstating what the landed certificate class covers. It depends on no open problem and it
changes no existing declaration.

---

### Phase 9: The two targets and their ℤ-time non-validity [NOT STARTED]

**Goal**: Restate, in library style rather than as a probe copy, the two targets the refutations
are about, prove each is a genuine ℤ-time non-validity, and land the closure-membership
scaffolding both refutations consume.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` with a
      module docstring, `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples`
      and `import FormalSystem.PlusLanguage.PlusNonValidities`, in the
      `FormalSystem.Metalogic.Decidability` namespace, `PlusSharingWitnessFamily` sub-namespace —
      matching where `Incompleteness.lean` puts its targets.
- [ ] Define `pumpTarget` and `hopTarget`. Record the primitive syntax in the module docstring
      exactly as the research appendix gives it, so a reader can check the abbreviations:
      `Xp := untl ⊥ p`, `Xnp := untl ⊥ (p → ⊥)`, `Fp := untl (⊥ → ⊥) p`,
      `dXp := (⊡(Xp → ⊥)) → ⊥`, `dXnp := (⊡(Xnp → ⊥)) → ⊥`,
      `hopTarget := □dXp → (□dXnp → ⊥)` and
      `pumpTarget := □dXp → (□dXnp → ((Fp → Fp) → ⊥))`.
- [ ] Prove `not_plusValidZTime_pumpTarget` and `not_plusValidZTime_hopTarget`. Both are refuted
      on the permissive frame `FormalSystem.PlusLanguage.PlusNonValidities.NF` with `natModel`,
      at the constant history and time `0`. This is the probes' own route and it transfers.
- [ ] Land the closure-membership chain for both targets — the `plusConclusion_mem_closure` root
      and the `plusClosureOf_imp_left` / `_imp_right` / `_box` / `_stab` / `_untl_left` /
      `_untl_right` steps down to `Xp`, `Xnp`, `np`, `Fp` and `tp`. Name them after the formula
      they place, not after the probe's local abbreviations.
- [ ] Prove the closure-shape fact each refutation uses — that every `untl` member of the target
      closure has the guard the argument assumes — by `decide` on the concrete closure, and state
      the proved form rather than the assumed one.
- [ ] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`. **Never hand-edit
      `FormalSystem.lean`** — invariant C33 compares it byte-for-byte against the generator.
- [ ] Confirm the new module transitively imports `FormalSystem.Init` (invariant C24).
- [ ] **Do not delete the probes.** `specs/703_lplus_compression_and_completeness/probes/`
      remains the provenance record for every declaration landed in Stage 1.

**Timing**: 3 hours

**Depends on**: 8

**Verification Tier**: interface

**Scope Hypothesis**: the two targets share the `Xp`/`Xnp`/`dXp`/`dXnp` prefix, so one
membership scaffolding is asserted to serve both. Confirm at implementation time by diffing the
two probes' membership blocks (`probes/NoFiniteCertificate.lean` lines 72-91 against
`probes/HopFreeIncomplete.lean` lines 64-79); if the two closures diverge enough that factoring
costs more than it saves, land two blocks and record the count rather than forcing the estimate.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`, never by hand

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.PlusWitnessFamily` exits 0.
- No `sorry` in the new file; `#print axioms` on each new theorem shows no axiom beyond
  `propext`, `Classical.choice`, `Quot.sound`.
- The two non-validity theorems are confirmed to mention `PlusValidZTime`, not `PlusValidInt`.

---

### Phase 10: Hop-free families are incomplete [NOT STARTED]

**Goal**: Land `not_exists_hopFree_plusCertifies_hopTarget`: no family whose succession relation
never leaves the index it is read at certifies `hopTarget`. This is an independent incompleteness,
and it is what retires the hop-free route of Phase 1 as a completeness strategy while leaving
Phase 1's theorems true.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/HopFree.lean`,
      importing `Limits/Targets.lean` and `PlusWitnessFamily/TransId.lean`.
- [ ] Derive the forced structure: (C4) and the `imp`/`box` clauses of (C1') force both box
      guesses true, (C3) puts the two `⟐X`-formulas in every label, and (C5) with (C0) then give
      every state, at every time, a successor state carrying `p` and one omitting it.
- [ ] Construct `n + 1` pairwise distinct `Step`-paths from that branching, where `n` is the
      family's lasso count.
- [ ] Close the contradiction: under the hop-free hypothesis, `lift` makes every state path
      class-equal to a constant index, so a family with `n` indices presents at most `n` state
      paths. Use `Fintype.card_le_of_injective`, which the probe confirms closes this goal.
- [ ] Record in the module docstring what this does **not** say: hop-freedom is incomplete, and
      `TransId.lean`'s four collapse theorems remain true and remain in the tree. The theorem
      bounds a *strategy*, not the substrate.
- [ ] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`;
      regenerate the library root with `lake exe mk_all --lib FormalSystem`.

**Timing**: 3 hours

**Depends on**: 9

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/HopFree.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The theorem's hypothesis is confirmed to be exactly the hop-free condition
  `∀ u i j, S.trans u i j → i = j`, matching `TransId.lean`'s `hid`, so the two are about the
  same class.

---

### Phase 11: The landed certificate class is incomplete [NOT STARTED]

**Goal**: Land `not_exists_plusCertifies_pumpTarget`, the phase that makes the withdrawal a
theorem of the tree: **no** `PlusSharingWitnessFamily` certifies `pumpTarget` at any time, for
any lasso count, any segment length and any succession relation.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean`,
      importing `Limits/Targets.lean`.
- [ ] Reuse Phase 10's forced-successor consequences where they factor, and otherwise re-derive
      them here: (C4) and (C1')'s `imp`/`box` clauses force both box guesses true; (C3) puts
      `⟐Xp` and `⟐Xnp` in every label; (C5) and (C0) give every state, at every time, a successor
      carrying `p` and one omitting it.
- [ ] Build the long-postponement path: start in the forward-periodic region at the mid length,
      follow `¬p`-successors for `k := n · perFwd + 1` steps, then take a `p`-successor. Prove it
      is a `Step`-path.
- [ ] Obtain the tracking thread from `lift`, and read `Fp` along the whole run backwards through
      (C1')'s `untl` clause.
- [ ] Apply the pigeonhole over the `n + 1` times spaced by the forward period, using
      `Fintype.exists_ne_map_eq_of_card_lt`, to find two times carrying the same index.
- [ ] Loop the thread between those two times. `SharingSkeleton.transRaw_congr_NF` and
      `...data_congr_fwd` are what make the loop a genuine thread with the same labels; cite them
      rather than re-proving the congruence.
- [ ] Contradict (C2'): the looped thread carries `Fp` at its entry and never reads `p`.
- [ ] Record in the module docstring the **scope** of the failure, at its true generality: any
      target whose countermodels must contain, in a periodic region, a cycle with an exit under a
      pending eventuality. Name the root cause — limit closure against a finite, eventually
      periodic, all-threads-fulfilling structure — and say plainly that no bound repairs it.
- [ ] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`;
      regenerate the library root.

**Timing**: 4 hours

**Depends on**: 9

**Verification Tier**: interface

**Scope Hypothesis**: this phase is asserted to fit one agent run. The source probe is about 420
lines and Phase 9 lifts out roughly 90 of them. Confirm by writing the forced-structure block
first and measuring; if the phase overruns, split at the pigeonhole into **11.1** (the forced
successors from (C0), (C1'), (C3), (C4), (C5), plus the long-postponement path and its thread)
and **11.2** (the pigeonhole, the loop, and the (C2') contradiction). Decompose into decimal
sub-phases; never carry a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The theorem quantifies over **every** `S` and **every** `t`, with no bound, no lasso-count
  hypothesis and no hypothesis on `trans` — confirmed by reading the statement, since a stray
  hypothesis would make the theorem far weaker than the withdrawal it is recording.
- `#print axioms` reports exactly `[propext, Classical.choice, Quot.sound]`.

---

### Phase 12: Correct the record, pin Stage 1, and read the paired repository [NOT STARTED]

**Goal**: Stop the tree overstating the landed certificate class's coverage, land Stage 1's
documentation and gate rows, and establish by reading — not by assumption — what the paired
model checker's export contract currently is.

**Tasks**:
- [ ] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`'s header section
      "A tense operator under a `⊡`: the certificate class was empty, and is not any more". What
      it says is true and stays: the class is non-empty and certifies both stability targets. What
      it must now add is that **non-empty is not complete** — the class does not certify
      `pumpTarget`, by `not_exists_plusCertifies_pumpTarget` — and that which fragment it does
      cover is an open question. Record the open question here, where the class is described.
- [ ] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`'s
      header sentence "It no longer records an obstruction, because there is no longer one to
      record." There is one to record; point at `Limits/`. Keep the rest, which is about the
      retired congruences and is accurate.
- [ ] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` where it says
      completeness of the certificate class "is now repaired". It was repaired **on those two
      targets**; it is refuted in general.
- [ ] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean`'s header,
      which describes hop-freedom as "the compression's choice". There is no compression; add the
      pointer to `Limits/HopFree.lean` and state that the four theorems remain true and are kept.
- [ ] Read `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` around its
      "empty certificate class" sentence and correct it **only if** it makes a coverage claim
      about the L⁺ class; if it is about the pre-redesign history, leave it and say so.
- [ ] Record in `Compression/Extract.lean`'s module docstring that the alignment half
      (`plusAlignOffset` through `exists_plusLabelledLasso_of_history_aligned`) is retained and
      unused, why, and that C17's dead-declaration census is expected to report it. C17 is
      reporting-only and never affects the exit code, so this is documentation, not a waiver.
- [ ] Add four rows to `docs/theorem-index.md`'s Decidability section, in the format of the
      neighbouring L⁺ rows, for `not_plusValidZTime_pumpTarget`,
      `not_exists_plusCertifies_pumpTarget`, `not_plusValidZTime_hopTarget` and
      `not_exists_hopFree_plusCertifies_hopTarget`: paper label `—`, frame class `ZTime` for the
      two non-validities and `—` for the two incompleteness theorems, axioms `pcq pinned:C2`.
- [ ] Add the four matching `#print axioms` lines to the `AX_SRC` heredoc and the four
      `'<name>' depends on axioms: [propext, Classical.choice, Quot.sound]` lines to the
      `AXIOM_BASELINE` heredoc of `scripts/check-module-invariants.sh`, **in the same relative
      order**. The check is a whole-string equality, so an order mismatch fails the gate.
- [ ] Update the C2 pass message's number word. The rule is mechanical: the word must spell the
      value of `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc. This does not fail
      the gate, which is exactly why it is easy to miss.
- [ ] Satisfy invariant C15 for the four new declarations: `Paper: —` plus a reason at the
      declaration, since all four are formalization-native.
- [ ] **Read the paired repository's export contract**, at
      `/home/benjamin/Projects/ModelChecker`, together with the hand-off note
      `specs/archive/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md`,
      which names the issue whose fourth need was to be this task's compression bound. Record, in
      this task's implementation summary, three things: what the export format is today, that the
      compression bound it expected **does not exist** for the landed certificate class, and that
      under the re-scoped target the contract changes shape from a list of lassos to a finite
      model — states, edges, valuation, state labels, one path and a time — whose search bound is
      a bound on the number of world states, expected doubly exponential in the closure in the
      worst case. **This is a read and a record, not a claim to make in advance**: the paired
      repository was not read in research round 2, so nothing above may be asserted about its
      current format until this task is done.
- [ ] **Never write to `/home/benjamin/Projects/ModelChecker`.** The hand-off is by content. No
      file in that repository is created, edited or staged by this task.
- [ ] Run `bash scripts/check-module-invariants.sh` in full and confirm every gate passes.

**Timing**: 3 hours

**Depends on**: 10, 11

**Verification Tier**: full

**Scope Hypothesis**: the gate edits are asserted to be exactly ten — four index rows, four
`AX_SRC` lines, four `AXIOM_BASELINE` lines and one message string, counted as ten line-groups —
and the baseline count is asserted to move from 18 to 22. Confirm by running
`grep -c 'depends on axioms'` over the heredoc before and after. If any other check (C15, C19
docstring coverage, C23 naming, C24 imports, C33 root currency) newly reports against the new
subtree, fix it in this phase rather than deferring it to Phase 18.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - header correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` - header correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` - coverage-claim correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean` - header correction
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - conditional correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean` - docstring note
- `docs/theorem-index.md` - four added rows
- `scripts/check-module-invariants.sh` - four `AX_SRC` lines, four `AXIOM_BASELINE` lines, one
  message string

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with C2 reporting twenty-two pinned sets.
- `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc returns 22.
- No file under `/home/benjamin/Projects/ModelChecker` is modified, confirmed by
  `git -C /home/benjamin/Projects/ModelChecker status --porcelain` being unchanged from its
  state before the read.

---

## Stage 2 — The finite-graph certificate (Phases 13-18)

Stage 2 builds the certificate the semantics actually has: a finite bi-serial labelled graph with
no time origin, whose liveness is computed rather than demanded. It yields **completeness relative
to finite models**, a true and useful result that depends on no open problem: the certificate *is*
the model, and the checker decides truth on it, so a model checker that finds a finite
countermodel can always have it verified.

Each root cause of the withdrawn route disappears by construction, and the plan records which:
absolute time is gone because the graph has none, so there are no periods, no window and no
alignment; histories are no longer the unit, so witness paths raise no demands of their own;
all-threads fulfilment is replaced by fulfilment of **live** positions only, so a path that
postpones an eventuality forever is simply a different, truthful, labelled path; and the demanded
`lift` field is gone, because every history of `FrameOver.ofStep` is a step path and every step
path carries its own true type sequence.

---

### Phase 13: The certificate type and the frame it presents [NOT STARTED]

**Goal**: Declare `PlusGraphPath` and `PlusGraphCertificate`, define the ℤ-frame and model a
certificate presents, and prove that the frame's histories are exactly the certificate's step
paths.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Basic.lean` and the
      aggregator `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean`; add the
      aggregator's import to `FormalSystem/Metalogic/Decidability.lean`; regenerate the library
      root with `lake exe mk_all --lib FormalSystem`.
- [ ] Declare `PlusGraphPath` and `PlusGraphCertificate` with the fields fixed in the Lean
      Challenge Statements block.
- [ ] Define `PlusGraphPath.lab : ℤ → Finset PlusFormula` and `PlusGraphPath.st : ℤ → Fin n` by
      the three-segment readout, reusing the generic readout lemmas of
      `WitnessFamily/Compression/Extract.lean` (`getD_mapC`, `readout_backC`, `readout_midC`,
      `readout_fwdC`, `periodic_rel_of_windowC`), which are stated over `{α} [Inhabited α]` and
      mention no formula. Supply the `Inhabited (Finset PlusFormula × Fin n)` instance from
      `n_pos`.
- [ ] Prove the three decoding-region lemmas for `PlusGraphPath` mirroring `lab_neg`, `lab_mid`
      and `lab_fwd`, so later phases cite a lemma rather than unfolding the readout.
- [ ] Define `G.frame : FrameOver intOrder := FrameOver.ofStep (fun w u => G.stepR w u = true) …`,
      discharging `[Finite]` and `[Nonempty]` on `Fin G.n` from `n_pos`, and seriality from
      `stepR_fwd` / `stepR_bwd`.
- [ ] Define `G.model : TaskModel G.frame.toTaskFrame` from `stateLab` read on atoms.
- [ ] Prove `G.mem_HF_iff_stepPath`: a function `ℤ → Fin G.n` is the path of a world history of
      `G.frame` exactly when it is a `stepR`-path. This is `FrameOver.mem_HF_iff_adjacent`
      specialized, and it is the fact that makes `lift` unnecessary.
- [ ] Define `G.pathHistory : PlusGraphPath … → WorldHistory G.frame.toTaskFrame` for a path whose
      state sequence steps, via the previous item.
- [ ] Confirm the new modules transitively import `FormalSystem.Init` (invariant C24).

**Timing**: 3 hours

**Depends on**: 12

**Verification Tier**: interface

**Scope Hypothesis**: the field lists pinned in the Lean Challenge Statements block are asserted
to be sufficient for the checker of Phase 15 and the soundness proof of Phase 16. Confirm at
implementation time by writing the **signature** of `Certifies` against the declared fields
before the structures are declared final. If a field is missing or wrong, record the correction
as a deviation at this phase's heading and update the Challenge block in this plan, loudly and
once — do not absorb it silently, and do not let the three theorem statements drift.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Basic.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean` - new aggregator
- `FormalSystem/Metalogic/Decidability.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- `mem_HF_iff_stepPath` is a proved biconditional, not a one-directional lemma, since Phase 17
  needs the converse.
- The structures carry no field named `lift`, no field named `trans`, and no time-indexed witness
  demand — confirmed by reading the declaration. Their absence is the design.

---

### Phase 14: Positions, the product graph, and computed liveness [NOT STARTED]

**Goal**: Build the position space and compute liveness on it as a fixpoint, in both time
directions, with **both** directions of the characterization proved. This is Stage 2's novel core
and its highest-risk phase.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Live.lean`.
- [ ] Define `G.Pos χ`: pairs of a state and a Hintikka type over the subformulas of `χ` that
      agrees with `G.stateLab` on the state formulas. Prove it is a `Fintype` with a
      `DecidableEq`, and bound its cardinality by `G.n * 2 ^ |subformulas χ|`.
- [ ] Define `G.succP` and `G.predP`, the `Finset`-valued one-step successor and predecessor on
      positions: an edge requires `G.stepR` on the state component and the (C1') one-step
      unfolding clauses on the type component.
- [ ] Prove `succP` and `predP` are non-empty on the position space, from `stepR_fwd` /
      `stepR_bwd` and the type-completion argument. Without this the fixpoints are vacuous.
- [ ] Define `G.fwdLive χ`, the forward-live positions: the greatest set `X` of positions such
      that from every position of `X` there is a `succP`-path inside `X` discharging each
      eventuality pending at it. Implement as a decreasing `Finset` iteration whose inner
      reachability step is the least fixpoint `AUFix.lfp`, imported from
      `WitnessFamily/Sharing/Fulfil.lean` — it is stated at `{α : Type*} [DecidableEq α]` and
      mentions no formula, so it is reused, not transcribed. Prove termination and the fixpoint
      property.
- [ ] Define `G.bwdLive χ` symmetrically on `predP`, and `G.live χ := G.fwdLive χ ∩ G.bwdLive χ`.
- [ ] Prove the **soundness direction**, `mem_live_of_path`: a position occupied at any time by a
      bi-infinite locally coherent, fulfilling labelled path of `G` is live.
- [ ] Prove the **completeness direction**, `exists_path_of_mem_live`: every live position lies on
      such a path. Factor it through type-preserving pasting — a position lies on a bi-infinite
      fulfilling labelled path exactly when it has a fulfilling forward half and a fulfilling
      backward half — so the two fixpoints are combined rather than solved jointly. The paste
      itself is `FormalSystem.PlusLanguage.paste`, which needs only Compositionality; the label
      row joins because state **and** type agree at the seam, which is the position.
- [ ] Record in the module docstring why liveness is computed rather than demanded, naming the
      refutation: a demanded all-threads fulfilment condition on a finite eventually periodic
      structure is refuted by `not_exists_plusCertifies_pumpTarget`, and asking only live
      positions to fulfil is exactly what removes that root cause.

**Timing**: 4 hours

**Depends on**: 13

**Verification Tier**: interface

**Scope Hypothesis**: `AUFix` is asserted to be reusable verbatim for the inner reachability step,
and the outer greatest fixpoint is asserted to be new work with no counterpart in the tree.
Confirm at implementation time by reading `AUFix`'s binders: it is the **universal** `A[g U e]`
operator, so it supplies the inner "all successors eventually deliver" half and **not** the
existential fair-path half. If the outer iteration needs a second generic fixpoint library rather
than a bespoke `Finset` loop, write it generically in this module and say so, rather than
inlining it twice.

**Contingency**: if this phase overruns one agent run, split into **14.1** (positions, `succP`,
`predP`, their non-emptiness, and `fwdLive` with both of its directions) and **14.2** (`bwdLive`,
`live`, and the two combined characterizations via pasting). Decompose into decimal sub-phases;
never carry a `sorry` and never define a placeholder that is vacuously true.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Live.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- **Both** directions of the liveness characterization are stated as named lemmas, so Phase 16
  cites one and Phase 17 cites the other rather than re-deriving either.
- `G.live` is evaluated on a small concrete certificate and confirmed to be neither empty nor the
  whole position space, so the fixpoint is not vacuous in either direction.

---

### Phase 15: The decidable checker [NOT STARTED]

**Goal**: Define `PlusGraphCertificate.Certifies` and prove it decidable, with liveness computed
by Phase 14's fixpoints.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Check.lean`.
- [ ] Define the **existential side**: the target path and every constrained witness path is
      locally coherent (`PlusLocalCoherentSeqLab` on its decoded labels, reused from
      `Compression/Types.lean`), fulfilling (`PlusFulfillingSeqLab`, likewise), follows `stepR` on
      its state component, and agrees with `stateLab` on the state formulas at every time. Each
      witness path for `(w, ⊡χ)` additionally passes through `w` at some time and omits `χ` there.
- [ ] Define the **universal side**: for every state `w` and every `⊡χ` in `stateLab w`, no live
      position over `w` omits `χ`. This is the clause that replaces the time-indexed (C5) demand,
      and it is a property of a state rather than of a state and a time.
- [ ] Define the **box clause**: `bx χ = true` exactly when `χ` belongs to every live position of
      every state. By `plusBox_const` this is what a global modality needs.
- [ ] Define the **target clause**: every `γ ∈ Γ` is in the target path's label at `targetTime`
      and every `δ ∈ Del` is not.
- [ ] Assemble `Certifies` as the conjunction and prove `decidableCertifies`. Every quantifier
      ranges over a `Finset` or a `Fintype`: states, closure members, position sets, and the three
      finite segments of each path.
- [ ] Exhibit a small concrete certificate and run the checker on it with `#guard`, confirming the
      checker actually evaluates rather than merely type-checking. Record the wall time. Note for
      the record that the landed (C2') decision procedure of the withdrawn route did not finish in
      150 seconds interpreted on a four-lasso family, so a checker that runs is itself a result.

**Timing**: 3 hours

**Depends on**: 14

**Verification Tier**: interface

**Scope Hypothesis**: `Certifies` is asserted to need exactly four groups of clauses — existential,
universal, box, target — with no residual field-shaped demand. Confirm by checking that no clause
quantifies over a time in a way that would need alignment; any clause that does is a relapse into
the withdrawn design and must be recorded and redesigned, not absorbed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Check.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- `decidableCertifies` is confirmed by `example (G) : Decidable G.Certifies := inferInstance`
  synthesizing, not by assertion.
- The `#guard` on the concrete certificate returns, within a recorded wall time.

---

### Phase 16: Soundness into the existing interface [NOT STARTED]

**Goal**: Prove `PlusGraphCertificate.plusRefutes_of_certifies`, landing
`PlusWitnessFamily.PlusRefutes Γ Del` unchanged.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Sound.lean`.
- [ ] Prove the truth lemma: for a labelled path of `G` meeting the existential side, and every
      `χ` in the target closure, `χ ∈ path.lab t ↔ PlusTruthAt G.model (G.pathHistory path) t χ`.
      Structural induction on `χ`, restricted to the subformulas of the formula in hand.
      - `atom`, `bot`, `imp`: local coherence.
      - `box`: the box clause plus `plusBox_const`.
      - `untl`, `snce`: fulfilment plus the one-step clauses. These are the cases
        `plusTruth_iff_mem` already proves along a thread; mirror that proof rather than inventing
        a new one.
      - `stab`: the universal side gives the `→` direction, because every history through the
        state is a step path, hence a labelled path, hence occupies a live position; the witness
        path gives the `←` direction.
- [ ] Prove `plusRefutes_of_certifies` by instantiating `PlusWitnessFamily.PlusRefutes` at
      `G.frame.toTaskFrame`, its `FrameClass.ZTime.Sat` instance, `G.model`, the target path's
      history and `G.targetTime`, discharging the two conjuncts from the target clause and the
      truth lemma.
- [ ] Record in the module docstring that this declaration is **beside** the landed
      `PlusSharingWitnessFamily.plusRefutes_of_certifies`, not in place of it: the two are about
      different certificate classes and land the same interface.

**Timing**: 5 hours

**Depends on**: 15

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Sound.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Full `lake build` exits 0; no `sorry`.
- `#print axioms FormalSystem.Metalogic.Decidability.PlusGraphCertificate.plusRefutes_of_certifies`
  reports exactly `[propext, Classical.choice, Quot.sound]`.
- `plusTruth_iff_mem` and `plusRefutes_of_certifies` are unchanged: confirmed by `git diff` over
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` showing **no hunk**.
- The theorem's conclusion is confirmed to be `PlusWitnessFamily.PlusRefutes Γ Del` verbatim, not
  a new refutation predicate.

---

### Phase 17: Completeness relative to finite models [NOT STARTED]

**Goal**: Prove `exists_plusGraphCertificate_of_finite_countermodel`: every countermodel carried
by a finite bi-serial graph yields a certificate the checker accepts. This is what makes Stage 2
useful rather than merely sound.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Finite.lean`.
- [ ] Build the carrier and the graph: `n := Fintype.card W` through an equivalence to `Fin n`,
      `stepR` from `[DecidableRel R]`, seriality from the two hypotheses.
- [ ] Build `stateLab`: the state formulas of the closure true at a state. It is **well defined**
      because `⊡` and the atoms are state determined —
      `Compression/Saturate.lean`'s `plusTypeAtM_stab_congr_state` and
      `plusTypeAtM_atom_congr_state` are exactly this fact, and `plusBox_const` handles `□`. Cite
      them; do not re-prove them.
- [ ] Build the target path. The label sequence and the state sequence must be cut at the **same**
      recurrence, so run the pigeonhole on the **paired** carrier `W × PlusTypeState C` rather
      than on `PlusTypeState C` alone. `exists_iterT_lt_card` and `exists_iterT_lt_card_aux` are
      stated over `{W : Type} [Finite W] [Nonempty W]` with an abstract relation, so they apply at
      the paired carrier directly.
- [ ] Build the witness paths: for each state `w` and each `⊡χ` absent from `stateLab w`,
      `exists_history_state_eq_of_not_stab` supplies a history through `w` omitting `χ`; extract
      it on the paired carrier the same way.
- [ ] Discharge the existential side from the extraction's realization facts:
      `plusTypeAtM_localCoherentSeqLab` and `plusTypeAtM_fulfillingSeqLab` give local coherence and
      fulfilment, and agreement with `stateLab` is the state-determination step above.
- [ ] Discharge the universal side: a live position over `w` is realized by an actual labelled
      path through `w` (Phase 14's completeness direction), and `plusTypeAtM_stab_iff_forall_sameState`
      turns `⊡χ ∈ stateLab w` into `χ` at every history through `w`. So no live position over `w`
      omits `χ`.
- [ ] Discharge the box clause from `plusBox_const`, and the target clause from the refuting time.
- [ ] Record in the module docstring what this theorem is and is not: it is **completeness
      relative to finite models**, and it is **not** the finite model property. It says nothing
      about whether a ℤ-time non-validity has a finite countermodel at all; that is the Stage 3
      successor's question, named in this plan's Non-Goals. No state bound is stated here, because
      none is proved.

**Timing**: 5 hours

**Depends on**: 16

**Verification Tier**: full

**Scope Hypothesis**: the landed extraction pipeline is asserted to transfer from `PlusTypeState C`
to the paired carrier `W × PlusTypeState C` by instantiating the generic pigeonhole, with the
good-cycle theorem re-run rather than re-proved. Confirm at implementation time by reading
`exists_good_cycle_of_plusTypeSeq`'s binders: if it is monomorphic in `PlusTypeState C` in a
load-bearing position, a parallel paired-carrier version must be **written and recorded**, not
substituted silently. Whichever way it goes, record the count of declarations added.

**Contingency**: if this phase overruns one agent run, split into **17.1** (the carrier, the graph,
`stateLab`, and the paired-carrier extraction of the target and witness paths) and **17.2** (the
four groups of `Certifies` clauses). Decompose into decimal sub-phases; never carry a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/Finite.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Full `lake build` exits 0; no `sorry`; axioms unchanged.
- The theorem's hypotheses are confirmed to place **no** bound on `Fintype.card W`: it is relative
  completeness for an arbitrary finite graph, and a bound would be a different, weaker theorem.
- The module states no state-space bound anywhere, confirmed by grep.

---

### Phase 18: Acceptance gates and the closing record [NOT STARTED]

**Goal**: Land Stage 2's documentation rows and axiom pins, run the full gate set, and close the
task with an honest record of what was proved and what was not.

**Tasks**:
- [ ] Add three rows to `docs/theorem-index.md`'s Decidability section, for
      `PlusGraphCertificate.decidableCertifies`,
      `PlusGraphCertificate.plusRefutes_of_certifies` and
      `exists_plusGraphCertificate_of_finite_countermodel`: paper label `—`, frame class `ZTime`,
      axioms `pcq pinned:C2`.
- [ ] Add the three matching `#print axioms` lines to `AX_SRC` and the three
      `AXIOM_BASELINE` lines, in the same relative order, in
      `scripts/check-module-invariants.sh`.
- [ ] Update the C2 pass-message number word again, by the same mechanical rule: it must spell the
      value of `grep -c 'depends on axioms'` over the heredoc.
- [ ] Satisfy invariant C15 for the three new declarations: `Paper: —` plus a reason, since all
      three are formalization-native.
- [ ] Write the `PlusGraphCertificate` subtree README, or a header section in the aggregator,
      stating plainly: what the certificate class is, that soundness and relative completeness are
      proved, that the finite model property is **not** proved and is a separate task, and that
      the expected state bound is doubly exponential as a research finding rather than a theorem
      of this tree.
- [ ] Regenerate the library root with `lake exe mk_all --lib FormalSystem` and confirm C33 passes.
- [ ] **Regenerate `typst/generated/status.typ`.** This task's new `.lean` modules move the
      committed counts that `.githooks/pre-commit` gates on. `specs/state.json` reports task 650
      as `completed`, so the lead's condition recorded in plan v1 is met: run
      `bash scripts/typst-sync-check.sh --fix` and commit **only** `typst/generated/status.typ`,
      by explicit path. Re-read 650's status from `state.json` at implementation time rather than
      trusting this line; `specs/TODO.md` has been stale on this point before and `state.json` is
      authoritative.
- [ ] Before any use of the pre-commit hook's `--no-verify` bypass, confirm the status-file count
      drift is the **only** failing gate. Anything else the hook reports is to be fixed, never
      bypassed.
- [ ] Run `bash scripts/check-module-invariants.sh` in full and confirm every gate passes,
      C2, C15, C19, C23, C24 and C33 included.
- [ ] Run `#print axioms` on all seven new pinned declarations and confirm each reports exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] Confirm the whole new subtree is sorry-free by content, not by line number (invariant C3).

**Timing**: 2 hours

**Depends on**: 17

**Verification Tier**: full

**Scope Hypothesis**: the gate edits are asserted to be exactly seven line-groups — three index
rows, three `AX_SRC` lines, three `AXIOM_BASELINE` lines counted as one group each, plus one
message string — and the baseline count is asserted to move from 22 to 25. Confirm with
`grep -c 'depends on axioms'` before and after. If another check newly reports against either new
subtree, fix it here rather than closing the task over it.

**Files to modify**:
- `docs/theorem-index.md` - three added rows
- `scripts/check-module-invariants.sh` - three `AX_SRC` lines, three `AXIOM_BASELINE` lines, one
  message string
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean` - closing header section, or a
  new `PlusGraphCertificate/README.md`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with C2 reporting twenty-five pinned sets.
- `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc returns 25.
- `git diff` over `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` shows no
  hunk across the whole task.

---

## Testing & Validation

- [ ] `lake build` exits 0 at the end of every phase, and at task end from a clean state.
- [ ] Zero `sorry` anywhere in either new subtree, asserted by content rather than by line number
      (invariant C3).
- [ ] Zero vacuous placeholder definitions. In particular `Certifies` is confirmed non-trivial by
      the Phase 15 `#guard` and `live` is confirmed non-degenerate by the Phase 14 evaluation.
- [ ] `#print axioms` on each of the seven new pinned declarations reports exactly
      `[propext, Classical.choice, Quot.sound]` — no new axiom.
- [ ] `plusTruth_iff_mem` and `plusRefutes_of_certifies` have unchanged statements, confirmed by
      an empty `git diff` over `PlusWitnessFamily/Agreement.lean`.
- [ ] `bash scripts/check-module-invariants.sh` passes in full, C2 and C33 included.
- [ ] Every new module transitively imports `FormalSystem.Init` (invariant C24).
- [ ] `FormalSystem.lean` is byte-current against `lake exe mk_all --lib FormalSystem`, never
      hand-edited (invariant C33).
- [ ] The four probe files under `specs/703_lplus_compression_and_completeness/probes/` still
      exist and are unmodified, since they are the provenance record for Stage 1.
- [ ] No file under `/home/benjamin/Projects/ModelChecker` was created, edited or staged.
- [ ] No state-space bound appears anywhere in either new subtree, since none is proved.

## Artifacts & Outputs

New Lean modules, Stage 1, under `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/`:

- `Targets.lean` - the two targets, their ℤ-time non-validity, the closure scaffolding
- `HopFree.lean` - hop-free families are incomplete
- `NoCertificate.lean` - the landed certificate class is incomplete

New Lean modules, Stage 2, under `FormalSystem/Metalogic/Decidability/PlusGraphCertificate/`:

- `Basic.lean` - `PlusGraphPath`, `PlusGraphCertificate`, the presented frame and model
- `Live.lean` - positions, the product graph, the two liveness fixpoints, both directions
- `Check.lean` - `Certifies` and `decidableCertifies`
- `Sound.lean` - the truth lemma and `plusRefutes_of_certifies`
- `Finite.lean` - completeness relative to finite models

Modified:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - three added imports, header
  correction
- `FormalSystem/Metalogic/Decidability/PlusGraphCertificate.lean` - new aggregator
- `FormalSystem/Metalogic/Decidability.lean` - one added import
- `FormalSystem.lean` - regenerated, never hand-edited
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Incompleteness,TransId}.lean`,
  `.../PlusWitnessFamily/README.md`, `.../PlusWitnessFamily/Compression/Extract.lean`,
  `.../WitnessFamily/Sharing/README.md` - documentation corrections only, no declaration changes
- `docs/theorem-index.md` - seven added rows
- `scripts/check-module-invariants.sh` - seven `AX_SRC` lines, seven `AXIOM_BASELINE` lines, the
  C2 message string
- `typst/generated/status.typ` - regenerated

Retained and NOT modified:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` - read-only, soundness
- The whole `Formula`-side `WitnessFamily/` tree - read-only
- `specs/703_lplus_compression_and_completeness/probes/` - the provenance record
- `specs/703_lplus_compression_and_completeness/plans/01_lplus-compression-completeness.md` -
  retained unedited as the history of the withdrawn route

Task artifacts:

- `specs/703_lplus_compression_and_completeness/plans/02_lplus-certificate-limits-graph-certificate.md`
- `specs/703_lplus_compression_and_completeness/summaries/02_lplus-certificate-limits-summary.md`
  at implementation time, carrying the paired-repository read of Phase 12

## Rollback/Contingency

Each phase is a self-contained new module plus one aggregator import line and a root
regeneration, so a failed phase is reverted by removing its file, removing its import line and
re-running `lake exe mk_all --lib FormalSystem` — a targeted, non-destructive edit needing no
working-tree rollback. This is the expected recovery path and the one to reach for first.

Phases 12 and 18 are the only phases editing files outside the two new subtrees. Their edits are
small, individually revertible, and each is verified by re-running the gate script.

A genuine whole-tree rollback should not be needed. If one becomes necessary, follow
`context/contracts/recovery.md`'s rollback rung for the exact snapshot-then-revert invocation
shape, including its out-of-scope override flag for the deliberate whole-tree case. Note that
sibling tasks have shared this working tree with no declared `file_scope`, so a whole-tree revert
would discard their work too; prefer the per-file revert above in every case. **Never take a bare
precautionary snapshot in the default reverting mode as a start-of-phase checkpoint**; a defensive
checkpoint before risky work uses the non-reverting `--no-revert` form instead.

Phases 11, 14 and 17 carry their own declared contingencies, stated at the phase: decompose into
decimal sub-phases, never defer behind a `sorry` and never define a vacuous placeholder.

**The one contingency this plan does not have** is a fallback to the withdrawn compression
theorem. It is false. If Stage 2 cannot be completed, the correct outcome is a task marked blocked
with Stage 1 landed, not a return to a statement the tree now refutes.
