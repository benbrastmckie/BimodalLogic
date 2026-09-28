# Research Report: The Agreement Lemma Over All Walks

- **Task**: 684 - agreement_lemma_over_all_walks
- **Started**: 2026-09-28T17:42:47Z
- **Completed**: 2026-09-28T17:52:00Z
- **Effort**: ~1 hour
- **Dependencies**: 683 (state-sharing witness structure, completed)
- **Sources/Inputs**:
  - Repository (compiled-live, `lake env lean` at Lean v4.33.0-rc1):
    `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/{Agreement,Histories,Frame,Predicates,Decide,Fulfil,Specialize,README.md}`,
    `FormalSystem/PlusLanguage/{PlusTruth,PlusDeterminism,PlusLimitClosure}.lean`,
    `FormalSystem/Semantics/{HistoryMorphism,Frames/TranslationProduct}.lean`
  - Predecessor artifacts: `specs/683_state_sharing_witness_structure_and_c3/reports/01_*.md`,
    `.../plans/01_*.md`, `.../summaries/01_*.md` (via state.json summaries and the landed code)
  - Coordination partner: task 559's ESTABLISHED items (a)-(m) and priority questions (P1)-(P4)
    in `specs/state.json`, and `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/04_semantics-first-task-frames.md`
    sections 4.1-4.4
  - Concurrent sibling: task 690's description in `specs/state.json` (declared scope and cost analysis)
  - Lean MCP: `lean_verify` (axiom audit), `lean_local_search`
- **Artifacts**:
  - `specs/684_agreement_lemma_over_all_walks/reports/01_agreement-lemma-over-all-walks.md`
  - `specs/684_agreement_lemma_over_all_walks/probes/01_stab_quantifier_collapse.lean` (compiled-live, sorry-free)
  - `specs/684_agreement_lemma_over_all_walks/probes/02_recurrence_free_frame.lean` (compiled-live, sorry-free)
- **Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: `WitnessFamily/Sharing/` (the branching device, landed green by 683),
  `WitnessFamily/{Basic,Closure,Predicates,Agreement,Decide}.lean` (the deterministic device, read-only),
  `PlusLanguage/` (the L-plus inductive and its truth predicate)
- **Downstream Dependents**: task 685 (compression and assembly), task 690 (the (C5) stability condition),
  task 559 priority question P2 (the ZTime truth lemma for a proof system)
- **Alternative Paths**: none needed for the L-fragment; the ⊡ case has exactly one viable path
  (L-plus re-indexing of the certificate), which is 690's declared substrate work
- **Potential Extensions**: a language-polymorphic certificate layer serving `Formula` and `PlusFormula` at once

## Executive Summary

- **The task's literal deliverable is already landed and green.** The agreement (truth) lemma over
  all walks of the branching witness structure, **including the box case**, is
  `SharingWitnessFamily.truth_iff_mem` (`Sharing/Agreement.lean:211`), delivered by the predecessor
  task in the same round. `lean_verify` reports axioms `{propext, Classical.choice, Quot.sound}`
  and no warnings; there are no sorries anywhere under `WitnessFamily/`. Its `box` case is grounded
  in `total_eq_thread` (`Sharing/Histories.lean:101`) exactly as this task specifies, and
  `ShiftSet.total_eq_orbit` is not used.
- **What genuinely remains is the ⊡ case, and it is strictly easier than the box case.** A new
  compiled-live result, `stabQuant_iff_share_class` (probe 01), proves that on the branching frame
  the stability modal's history quantifier — "every history through the present world state" —
  **collapses to a finite quantifier over the `share`-class of the present index**. No quantifier
  over walks survives; the right-hand side ranges over `Fin S.lassos.length`.
- **Therefore (C5) `StabFaithful` is decidable by the machinery already landed**, with no new
  fixpoint and no new window analysis: it is a one-time condition on `rep u` and `L · u`, the exact
  data shape `Sharing/Decide.lean`'s `AtomCoherentAt` window reduction already handles. The
  decidability constraint that governs (C1')/(C2') does not bind here at all.
- **559's failure mode does NOT transfer, and this is the central coordination finding.** The
  "trace that postpones an inevitability forever" and its recorded cure (limit-closure schemata
  `LC_n` plus state-carried progress measures) are *completeness-side* problems: there, fulfilment
  must be **derived** from the logic for every trace in the closure of a canonical bundle. Here
  fulfilment over all threads is an **assumed and checked** hypothesis, (C2') `ThreadFulfilling`,
  decided by `Sharing/Fulfil.lean`'s `A[g U e]` least fixpoint over a finite position graph. 559's
  P2 and this task are therefore **not** the same lemma; they share a substrate, not a difficulty.
- **Three of 559's results do transfer**, one of them newly load-bearing:
  (g) `stab_state_only` is why the ⊡ condition is class-local; (h) "frame axioms are not the
  obstacle at any class" is confirmed on the certificate side by `Sharing/Frame.lean` discharging
  all four `def:frame` constraints for a non-functional task relation; and
  `plusValidIn_iff_recurrenceFree` (`Semantics/Frames/TranslationProduct.lean:597`) licenses the
  branching device's time-stamped carrier, which probe 02 machine-checks is recurrence-free.
- **The task as scheduled will duplicate sibling 690 unless re-scoped.** 684's declared
  `file_scope` names the *deterministic* modules, which 683's standing "ADD ALONGSIDE, DO NOT
  REPLACE" constraint forbids touching. A concrete, non-overlapping re-scoping is recommended
  below and recorded as a `user_decision`.

## Context & Scope

This is a research round for a task whose description was written **before** its predecessor
landed. The description asks for a deliverable ("prove the agreement lemma over all walks,
including the box case") that the predecessor's final phases in fact produced. The round's job was
therefore threefold: verify that claim against the compiled repository rather than against
prose; identify what mathematical content of the task is genuinely outstanding; and carry out the
COORDINATION instruction against task 559 and concurrent sibling 690.

Constraints honoured: no edits to any `FormalSystem/` or `Tests/` file (research round); probes
written under this task's own directory only; territory respected — nothing was written under
`Sharing/Predicates.lean`, `Sharing/README.md`, `PlusLanguage/` (sibling 690) or
`BiLasso/`, `Decidability.lean`, `FormalSystem.lean`, `docs/theorem-index.md` (sibling 623). No
foreign commit, foreign modification or foreign build was observed.

Evidence labels used below follow 559's convention: **compiled-live** = checked by
`lake env lean` against this repository in this round; **landed** = present and green in the
repository from prior work; **paper**/**UNVERIFIED**/**recalled** as in 559.

## Findings

### 1. The box case is done, and done the way this task specifies (landed, re-verified)

`SharingWitnessFamily.truth_iff_mem` (`Sharing/Agreement.lean:211`) states, for a state-sharing
family satisfying (C0) `AtomCoherent`, (C1') `LocalCoherentShare`, (C2') `ThreadFulfilling` and
(C3) `BoxFaithful`:

> for every `ψ ∈ closureOf (Γ ++ Del)`, every thread `θ` and all `s t : ℤ`,
> `TruthAt (S.model hat) (S.hist θ s) t ψ ↔ ψ ∈ S.L (θ.idx (s + t)) (s + t)`.

Verified this round:

- `lean_verify` on the fully qualified name returns `{"axioms":["propext","Classical.choice","Quot.sound"],"warnings":[]}`
  — the three standard axioms, nothing else, no warnings.
- `grep -rn sorry FormalSystem/Metalogic/Decidability/WitnessFamily/` returns one hit, in a prose
  comment in `Examples.lean`. No sorry in any proof.
- The `box` case's two halves consume exactly the two lemmas this task names: `←` uses
  `total_eq_thread` composed with `WorldHistory.ext_state`; `→` uses `Thread.const` plus `hist`.
  `ShiftSet.total_eq_orbit` appears nowhere in the branching development.
- The consumers are landed too: `Certifies` (`Agreement.lean:329`), `decidableCertifies`, and
  `refutes_of_certifies` (`Agreement.lean:402`) producing the unchanged
  `WitnessFamily.Refutes Γ Del`.

The predecessor's README also records a **correction to this task's premise**: (C3) `BoxFaithful`
is recombination-stable and was reused verbatim. Its right-hand side, `∀ i t, χ ∈ W.L i t`,
quantifies over the label pool, not over histories, so recombination adds no label for `□` to
range over. The conditions that genuinely broke were (C1) and (C2), both stated per lasso. This
task's description ("the box case that the deterministic design's version cannot cover") is
accurate about *which case was at risk* but the risk was discharged by replacing the histories
characterization underneath the condition, not by redesigning the condition.

### 2. The ⊡ case: the history quantifier collapses to a finite class quantifier (compiled-live, new)

`PlusTruth.lean:93` gives the stability clause verbatim:

```
| .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ
```

On `SharingWitnessFamily.frame` this quantifier is **not** a quantifier over walks. Probe 01
(`specs/684_agreement_lemma_over_all_walks/probes/01_stab_quantifier_collapse.lean`, exit 0,
sorry-free) proves, at the existing `Formula`-indexed device:

> `StabQuant S hat (S.hist θ s) t ψ ↔ ∀ j, S.share (s + t) (θ.idx (s + t)) j → ψ ∈ S.L j (s + t)`
> for every `ψ ∈ closureOf (Γ ++ Del)`.

The quantifier shape is expressible at `Formula` even though the modal is not, because the clause
never inspects the formula. The proof is four lines of structure:

- `→` instantiates the history quantifier at `Thread.const S j` for each class member `j`; that is
  a history by `Thread.const` + `hist`, and truth is read back as membership by T1.
- `←` decomposes an arbitrary history by `total_eq_thread`, extracts `share` (and the equality of
  time offsets) from the state equality by `share_of_cls_eq` (`Sharing/Frame.lean:100`), and reads
  membership forward as truth by T1.

Both directions consume exactly the lemmas the `box` case already consumes. The ⊡ case is
therefore **structurally the box case with the global label pool replaced by one `share`-class**,
and is strictly easier: `□` needs the pool-wide (C3), `⊡` needs only a class-local condition.

Probe 01 also proves the deterministic cross-check `stabQuant_iff_self_of_share_eq`: when
`share u` is equality the class is a singleton and the collapse reads `⊡ψ ↔ ψ`, matching
`PlusLanguage.stab_iff_of_deterministic` (`PlusDeterminism.lean:123`). This is a genuine
consistency check on the design, not a restatement: it confirms the branching device is the
minimal extension at which ⊡ stops collapsing.

### 3. The (C5) condition this determines, and why it is decidable for free

Probe 01 fixes the statement of (C5) up to notation. On an L-plus-indexed certificate:

> **(C5) `StabFaithful`**: for every `i`, every `u : ℤ` and every `φ` with `stab φ` in the closure,
> `stab φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`.

Three properties follow without further work:

- **Decidable by the landed window machinery.** The condition reads only `rep u` and `L · u` —
  one-time data. `Sharing/Decide.lean:237`'s congruence (`u % NB = v % NB → rep u = rep v ∧ ∀ i, L i u = L i v`)
  is language-agnostic and already gives exactly this, and the `AtomCoherentAt` / `cohWindowLo` /
  `cohWindowHi` reduction (`Decide.lean:377`, `:495`, `:516`) applies with `Formula.atom p`
  replaced by `stab φ`. **There is no analogue of (C2')'s recorded relative-decidability gap**:
  (C5) is a standalone `Decidable`, so a five-or-six-condition `Certifies` still assembles by
  `inferInstanceAs`.
- **It is non-vacuous precisely because labels differ across a class.** `Sharing/README.md` records
  that two lassos may carry different `untl` labels at a shared position; (C5) does not ask the
  labels to agree, it asks the ⊡-label to *record the class conjunction*.
- **It reproduces a semantic fact as a derived corollary.** Because `share u` is an equivalence,
  the right-hand side is class-invariant, so (C5) forces ⊡-labels to agree across a class — the
  certificate-level shadow of `stab_congr_state` (`PlusTruth.lean:221`), i.e. of ⊡φ being a state
  formula. Nothing extra needs to be assumed to get it.

### 4. The frame is recurrence-free, and that is a licence rather than a limitation (compiled-live, new)

`WorldState` is `Quotient (Fin |lassos| × ℤ)` and `share_of_cls_eq` forces equal classes to sit at
equal times, so the same state is never revisited. Probe 02
(`.../probes/02_recurrence_free_frame.lean`, exit 0, sorry-free) proves
`S.frame.toTaskFrame.RecurrenceFree` (`Semantics/HistoryMorphism.lean:132`) from `total_eq_thread`
and `share_of_cls_eq`.

Two consequences:

- It is what makes the probe-01 collapse a **one-time** quantifier. `stab_state_only`
  (`PlusTruth.lean:332`) says ⊡-truth depends on the state alone even across times; on this frame
  that cross-time content is vacuous, which is why the class quantifier needs no time argument.
- It costs no refuting power. `plusValidIn_iff_recurrenceFree`
  (`Semantics/Frames/TranslationProduct.lean:597`) says L-plus validity over a frame class equals
  validity over that class's recurrence-free members. Whatever a recurrence-free witness frame
  cannot refute, no frame refutes. This is 559's item (h), used here for a purpose 559 did not
  need it for, and it closes off an objection a reviewer would otherwise raise against the
  time-stamped carrier.

### 5. Coordination with task 559: what transfers, what does not, and what flows back

**Transfers from 559 to this task (all confirmed against the repository this round):**

| 559 item | Content | Status here |
|---|---|---|
| (g) | ⊡-truth is a function of the present world state alone (`stab_state_only`, landed) | **Transfers and is load-bearing.** It is the semantic reason (C5) is a class-local, one-time condition rather than a walk condition |
| (h) | Frame axioms are not the obstacle at any class | **Transfers verbatim**, as the description states. Confirmed on the certificate side: `Sharing/Frame.lean` discharges all four `def:frame` constraints for a non-functional task relation, landed green |
| (h) | `plusValidIn_iff_recurrenceFree`, validity = validity over recurrence-free members | **Transfers, newly load-bearing.** Licenses the time-stamped carrier (finding 4) |
| (c)/§4.1 | All-histories semantics = closed bundles; `H_F` is the closure of `H` | **Transfers as a sanity check only.** `total_eq_thread` is the certificate-side instance in which the bundle is *already* closed (`H_F = H` exactly), which is why no closure axiom is needed here |
| (f) | States must not be MCSs, or Determined is forced | **Transfers as a design confirmation.** The branching carrier's states are `share`-classes of (index, time), never theories |

**Does NOT transfer — the central finding:**

| 559 item | Content | Why it does not bear here |
|---|---|---|
| (i)/§4.2 | Failure mode: a trace in the closure that postpones an inevitability `⊡Fα` forever | On the completeness side the constructor does not control the closure of the canonical bundle, so fulfilment must be **derived**. On the certificate side fulfilment over all threads is **assumed and checked**: (C2') `ThreadFulfilling` (`Sharing/Predicates.lean:197`) is a hypothesis of T1, decided by `Sharing/Fulfil.lean`'s `A[g U e]` least fixpoint over a finite position graph |
| (j) | Cure: `LC_n` limit-closure schemata in the logic plus progress measures in the state | Neither is needed for the certificate-side lemma. The logic-side `LC_n` has no certificate-side counterpart; the "progress measure carried in the state" **does**, and it is already built: the position graph's least-fixpoint rank |

**Consequence for the COORDINATION instruction.** The task description says 559's P2 and this task
"target THE SAME MATHEMATICS from two directions", and that whichever reaches it first should state
the lemma reusably for the other. The accurate refinement is: **they share a substrate, not a
difficulty.** The common mathematics is the histories characterization (walks of the branching
digraph = the frame's total histories), and on the certificate side it is `total_eq_thread`,
landed. The P2 difficulty — making every closure trace of a *canonical* bundle coherent — is
absent from the certificate side by construction, because certificates are finitely presented and
their fulfilment is a decided predicate. Neither task should wait on the other.

**What flows back to 559.** `total_eq_thread` + `Fulfil.lean`'s fixpoint is a worked,
machine-checked instance of §4.2's obligation on finitely presented structures: a bundle whose
closure equals itself and all of whose inevitabilities are discharged, with the discharge witnessed
by a least-fixpoint rank over a finite graph. It does not solve P2 (canonical bundles are not
finitely presented), but it makes P2's "state-carried progress measures" option concrete rather
than programmatic, and it is the first compiled example in this repository of the coherent-family
side of §4.2 being realized. Recommend this be cited into 559's next round rather than re-derived.

### 6. Coordination with sibling 690, and the scope defect in this task

Sibling task 690 (`stability_condition_over_branching_frame`, status `researching`, same
`/orchestrate` cycle) is chartered to build (C5) on this frame and declares scope
`Sharing/Predicates.lean`, `Sharing/README.md`, `PlusLanguage/Formula.lean`,
`PlusLanguage/PlusTruth.lean`. Overlap with this task as written is near-total in the only
remaining content.

Two independent defects in this task's own scheduling data:

- **Declared `file_scope` is wrong.** It names `WitnessFamily/{Agreement,Basic}.lean`,
  `WitnessFamily/README.md`, `WitnessFamily.lean` — the **deterministic** device. The branching
  agreement lemma lives in `Sharing/Agreement.lean`, and editing the deterministic modules is
  forbidden by 683's standing "ADD ALONGSIDE, DO NOT REPLACE" constraint and by `Sharing/README.md`'s
  recorded invariant that nothing under `Sharing/` edits its parent.
- **The premise "the box case the deterministic design cannot cover is unproved" is false**
  (finding 1).

L-plus re-indexing cost, honestly stated (this round's own measurement, complementing 690's):
of the nine `Sharing/` modules, four mention `Formula` zero times (`Basic` 254, `Thread` 273,
`Frame` 397, `Histories` 141 lines = 1,065 lines, language-agnostic), `Specialize` mentions it
once (455 lines), and four are language-dependent: `Predicates` 226, `Decide` 567, `Fulfil` 1,669,
`Agreement` 411 lines. On the L-plus side there is **no closure module at all** —
`FormalSystem/PlusLanguage/` contains no `subformulas`, `closureOf` or `Closure.lean`, against
`WitnessFamily/Closure.lean` (131 lines) plus `Decide.lean` (942 lines) on the `Formula` side.
This confirms 690's cost estimate and is a reason to prefer a shared polymorphic closure layer,
but it is 690's decision to make, not this task's.

**The non-overlapping deliverable this task can own.** Probe 01's `stabQuant_iff_share_class` and
probe 02's `frame_recurrenceFree` are stateable **at `Formula`, today, with no L-plus
re-indexing**, and belong in a *new* file (`Sharing/Stability.lean`) that is in neither sibling's
declared scope. Landing them gives 690 the exact (C5) statement to adopt, together with its
soundness argument, its decidability argument and its deterministic cross-check, and removes the
hardest step from 690's critical path. This is the "prove it once and cite it across" instruction
applied to the sibling it actually binds.

## Decisions

- **D1.** Record that this task's literal deliverable is discharged by `SharingWitnessFamily.truth_iff_mem`,
  verified this round by axiom audit rather than by prose, and do not re-prove it. (Finding 1.)
- **D2.** Treat the ⊡ case as this task's remaining mathematical content, and state it as the
  quantifier-collapse lemma rather than as a condition, because the collapse is what makes any
  condition decidable and is language-independent. (Finding 2.)
- **D3.** Fix (C5)'s statement as `stab φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`, with the
  decidability route being `Decide.lean`'s existing one-time window reduction, and hand it to 690
  rather than implementing the L-plus re-indexing here. (Finding 3.)
- **D4.** Record that 559's (i)/(j) failure mode and `LC_n` cure do **not** transfer, correcting
  this task's description on that point, and that the shared content with P2 is the histories
  characterization only. (Finding 5.)
- **D5.** Do not touch the deterministic modules named in this task's `file_scope`; propose a new
  `Sharing/Stability.lean` instead, which collides with no sibling's declared scope. (Finding 6.)
- **D6.** Do not adopt the "certificate-side `LC_n`" framing the description gestures at. There is
  no such thing: the certificate's counterpart to a limit-closure schema is a decided fixpoint,
  already landed. (Finding 5.)

## Recommendations

Prioritized; owner in brackets.

1. **[planner, this task] Re-scope 684 to land probes 01-02 as `Sharing/Stability.lean`.**
   Two theorems (`stabQuant_iff_share_class`, `frame_recurrenceFree`) plus the deterministic
   cross-check, a module header recording D4/D6, and a `Sharing/README.md` line — **deferred** to
   690, which owns that file. Both proofs are compiled-live already; this is a transcription
   phase, one agent run, roughly 120-180 lines including documentation. Update `file_scope` to
   `["FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean"]` and add the new
   module to `WitnessFamily.lean`'s import list only if that file is not a sibling's territory at
   the time (it is currently in 685's declared scope, not 623's or 690's — re-check at dispatch).
2. **[690] Adopt (C5) as stated in D3, and cite `stabQuant_iff_share_class` as its soundness
   argument** instead of re-deriving the collapse. 690's remaining work is then the L-plus
   closure layer and the re-indexing, not the ⊡ mathematics.
3. **[559, next round] Cite finding 5 into P2's framing.** Specifically: record that the
   certificate line does not and cannot discharge P2, that the shared content is the histories
   characterization, and that `Fulfil.lean`'s fixpoint rank is a compiled instance of the
   "progress measure carried in the state" device §4.2 names.
4. **[685] Note that the compression target is unchanged by this round.** T1 for the branching
   device is green, so 685's stated dependency ("a bound on structures whose truth lemma has not
   been proved certifies nothing") is satisfied for the L-fragment now, and will be satisfied for
   L-plus exactly when 690 lands. 685 need not wait on 684 under the re-scoping in (1).
5. **[orchestrator] Correct 684's `file_scope` before any implementation dispatch.** The current
   value would route an implementation agent at the deterministic device, which 683's constraint
   forbids.

## Risks & Mitigations

- **Risk: duplicated work with 690 on the ⊡ mathematics.** Both tasks are live in the same cycle.
  *Mitigation*: recommendation (1) confines 684 to a file neither sibling declares, and
  recommendation (2) makes 690 a consumer rather than a re-deriver. If the orchestrator instead
  merges 684 into 690, the probes in this task's directory remain the usable artifact.
- **Risk: (C5) as stated is class-local and therefore might be thought too weak.** It is not: the
  collapse lemma is an `iff`, proved in both directions against the full history quantifier, so
  (C5) is equivalent to the semantic clause under the other four conditions, not a sound
  approximation of it.
- **Risk: the L-plus re-indexing turns out more expensive than 690's estimate.** The measurement in
  finding 6 (2,873 language-dependent lines under `Sharing/`, plus a missing 131+942-line closure
  layer on the L-plus side) is this round's independent confirmation; if a plan commits to a
  monomorphic second copy it should carry that number explicitly. *Mitigation*: the polymorphic
  closure layer alternative is 690's to evaluate; nothing in this task's re-scoping depends on the
  outcome.
- **Risk: the recurrence-free carrier is read as a restriction on the device.** *Mitigation*:
  finding 4 pins `plusValidIn_iff_recurrenceFree` as the licence; cite it in the module header so
  the question is not reopened.
- **Risk: a reader takes "the box case was the obstruction" from this task's title.** *Mitigation*:
  the correction is recorded in `Sharing/README.md` already and in D1 here; the module header for
  `Sharing/Stability.lean` should not repeat the superseded framing.

## Tactic Survey Results

Two probes were developed this round; both are compiled-live and sorry-free. Survey of what closed
each obligation:

| Goal | Tactic / route | Result | Premises/Config |
|------|----------------|--------|-----------------|
| `stabQuant_iff_share_class`, `→` direction | `Thread.const` + `hist` + `cls_eq`, then T1 `.mp` | success | `truth_iff_mem`, `Thread.const_idx`, `cls_eq` |
| `stabQuant_iff_share_class`, `←` direction | `total_eq_thread` + `WorldHistory.ext_state` + `share_of_cls_eq`, then T1 `.mpr` | success | `truth_iff_mem`, `share_of_cls_eq`, `total_eq_thread` |
| Aligning the two time offsets after `share_of_cls_eq` | `subst` on `s' = s` | fail | `subst` eliminated the bound `s` rather than `s'`, leaving `Unknown identifier s` |
| same | `rwa [show s + t = s' + t from by omega] at hmem` | success | `omega` on the `htime` component |
| `frame_recurrenceFree` | `total_eq_thread` + `share_of_cls_eq`, then `omega` | fail | `omega` saw no linear constraints: `Duration` is not syntactically `ℤ` at that goal |
| same | ascribe `(s + a : ℤ) = (s + b : ℤ)` then `add_left_cancel` | success | the ascription is what exposes the `ℤ` structure |
| Axiom audit of the landed T1 | `lean_verify` on `...SharingWitnessFamily.truth_iff_mem` | success | `{propext, Classical.choice, Quot.sound}`, no warnings |

No rate-limited search tool was needed: every lemma required was located by `lean_local_search` or
by direct file reading, and no Mathlib lemma outside `add_left_cancel` and `omega` was used.

## Context Extension Recommendations

- **Topic**: The certificate-side / completeness-side distinction for the stability modal.
  **Gap**: Nothing in `context/project/lean4/` or `context/project/logic/` records that a *decided*
  fulfilment predicate and a *derived* one face different obstructions, which is why this task's
  description equated 559's P2 with a lemma that was already proved.
  **Recommendation**: add a short note to `context/project/logic/domain/` capturing finding 5's
  transfer table, so future task descriptions in this line do not re-import the completeness-side
  failure mode into certificate-side work.
- **Topic**: Task descriptions written against a predecessor's plan rather than its outcome.
  **Gap**: This task's premise was falsified by its own dependency completing.
  **Recommendation**: not a context gap so much as a scheduling one; the orchestrator's dependency
  handling could re-read a dependency's summary before dispatch. Recorded for manual review only.

## Appendix

**Probe files** (this task's directory, both `lake env lean` exit 0):

- `probes/01_stab_quantifier_collapse.lean` — `StabQuant`, `stabQuant_iff_share_class`,
  `stabQuant_iff_self_of_share_eq`
- `probes/02_recurrence_free_frame.lean` — `frame_recurrenceFree`

**Repository anchors cited**

- `Sharing/Agreement.lean:211` `truth_iff_mem`; `:329` `Certifies`; `:402` `refutes_of_certifies`
- `Sharing/Histories.lean:101` `total_eq_thread`
- `Sharing/Frame.lean:100` `share_of_cls_eq`
- `Sharing/Predicates.lean:127` `AtomCoherent`; `:138` `LocalCoherentShare`; `:197` `ThreadFulfilling`
- `Sharing/Decide.lean:237` window congruence; `:377` `AtomCoherentAt`; `:495`, `:516` the reduction and instance
- `Sharing/Specialize.lean:425` `truth_iff_mem_toSharing`
- `PlusLanguage/PlusTruth.lean:93` the `stab` clause; `:221` `stab_congr_state`; `:332` `stab_state_only`
- `PlusLanguage/PlusDeterminism.lean:104` `states_eq_of_deterministic`; `:123` `stab_iff_of_deterministic`
- `Semantics/HistoryMorphism.lean:132` `TaskFrame.RecurrenceFree`
- `Semantics/Frames/TranslationProduct.lean:597` `plusValidIn_iff_recurrenceFree`

**External references**: none consulted this round. No literature source was named in the dispatch
and `--lit` was not active, so the Literature Extraction Protocol did not apply. Every claim above
is either compiled-live in this round, landed in the repository, or attributed to task 559's own
labelled findings.
