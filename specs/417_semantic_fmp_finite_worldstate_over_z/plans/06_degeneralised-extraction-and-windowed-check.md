# Implementation Plan: Task #417 — degeneralised extraction and the windowed `check` (handoff Task A, final leg)

- **Task**: 417 - Semantic FMP, finite WorldState over ℤ
- **Status**: [IMPLEMENTING]
- **Effort**: 12.5 hours remaining (Phases 10.1–10.3, 11, 12); ~19 hours already landed across Phases 1–10
- **Dependencies**: Task 414, Task 420, Task 438, Task 439 (semantics/frame prerequisites, all landed upstream); Task 450 gates the DEFERRED half only (see Non-Goals) and does **not** gate any phase here; Task 441 is a *coordination* dependency — it owns `BiLasso/Extend.lean` and shares `scripts/module-invariants-manifest.txt`, and it is implementing concurrently (see Risks). **Task 441 does not gate any phase of this plan**, because repair 1b — the only route that would have needed it — is rejected below on the evidence.
- **Research Inputs**:
  - `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase10-origin-anchoring-obstruction.lean` (**primary** — the machine-checked obstruction that forced this revision)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/.orchestrator-handoff.json` (dispatch 6 blocker record)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean` (drove plan 05; still the standing regression guard)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/plans/05_annotated-bi-lasso-decision-layer.md` (superseded; the full text of Phases 1–10 lives there)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/reports/04_filteredstep-fwd-gating-spike.md`
  - `specs/417_semantic_fmp_finite_worldstate_over_z/reports/02_semantic-fmp-rescoped-z-time.md`
  - `specs/417_semantic_fmp_finite_worldstate_over_z/handoffs/01_phase-7-12-revision-handoff.md` (architecture of record, §4.1/§4.2/§4.3/§4.5/§5/§7)
- **Artifacts**: plans/06_degeneralised-extraction-and-windowed-check.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan supersedes `plans/05_annotated-bi-lasso-decision-layer.md`. Scope boundary unchanged:
handoff §5's **Task A** only; Tasks B and C stay deferred, B blocked on task 450.

Plan 05's architecture is **not** in question. Route 2 (annotated bi-lassos) worked: Phases 4–9 all
landed sorry-free, including the declared crux `truth_along_annot`, which compiled first try with
no weakening. Phase 10 then landed its type-sequence groundwork sorry-free and blocked at the
*extraction*, with two machine-checked obstructions recorded in
`evidence/phase10-origin-anchoring-obstruction.lean`. This revision changes exactly two things: the
shape `check` reads, and the pigeonhole datum the extraction closes its loops on. Everything else
is carried over verbatim.

### The two obstructions, and what each actually requires

**Obstruction 1 — origin anchoring.** A `BiLasso` has no left prefix (`Basic.lean:145-161`: `back`
repeated on the negatives, `mid` on `[0, |mid|)`, `fwd` repeated at or past `|mid|`), so a two-sided
pigeonhole forces the lasso origin to the backward repeat `c₂`, putting source time `0` at lasso
position `-c₂`. Plan 05's Phase 12 `check` reads `A.lasso.unroll 0` and `A.label 0` only. Demanding
`c₂ = 0` demands a recurrence of the *type* at the point of interest, and
`type_at_origin_never_recurs` exhibits a total history whose closure formula `prev⁵ w` has truth set
exactly `{0}` — no such recurrence exists.

**Obstruction 2 — no explicit bound.** The good-cycle condition follows from a recurrence argument
that gives existence with no bound on the cycle length. Plan 05's asserted `P.card · 2^k · 2^k`
needs the Büchi degeneralisation with a genuine `pending` component; only `(state, type)` landed as
`pigeonDatum`.

### Evaluation of the recommended repair (not adopted on say-so)

The implementation agent recommended repair 1a: let `check` range over a position in the derived
coherence window instead of position `0` only. **Verdict: adopted, for reasons checked against the
tree rather than accepted from the recommendation — and it is confirmed to address obstruction 1
only.** Four checks were run:

1. **Soundness at an arbitrary position is real, not hoped for.** `truth_along_annot`
   (`TruthLemma.lean:153`) is stated `∀ (t : ℤ), TruthAt P.toModel A.hist t ψ ↔ ψ ∈ A.label t`, with
   `LocalCoherent` and `Fulfilling` themselves `∀ t : ℤ` (`Annotation.lean:301`, `:336`). Nothing in
   the landed truth lemma privileges `0`. `truth_along_annot_at` (`:224`) is already the
   position-indexed form. So the soundness direction at `i` is a *specialisation of a landed
   theorem*, not new work.
2. **The window genuinely contains the witness, with no side condition.** `cohWindowLo = -2·nb`,
   `cohWindowHi = nm + 2·nf` (`Decide.lean:373`, `:376`), and `back_ne` / `fwd_ne` (`Basic.lean:153`,
   `:155`) give `nb ≥ 1`, `nf ≥ 1` (`Decide.lean:84`, `nb_pos`). Hence
   `[0, nm] ⊆ [cohWindowLo, cohWindowHi)` **unconditionally**, and the extraction's witness sits at
   `-c₂ ∈ [0, nm]`. The `|mid| = 0` corner (witness at position `nm` exactly, when `c₂ = a₁ = 0`) is
   covered, which a naive `Finset.Ico 0 A.nm` would have silently dropped. This is why the plan uses
   the coherence window rather than the tighter mid window.
3. **Nothing is weakened at the specification level.** The predicate `check` decides is
   `∃ τ total, ∃ t, τ.states t = w ∧ TruthAt P.toModel τ t φ` — already existentially quantified over
   the time. It is quantified that way in *either* shape, because Phase 10's hypothesis is truth at
   an arbitrary `t`. Anchoring at `0` was only ever a normalisation, and the bi-lasso's pinned origin
   is exactly what makes that normalisation unavailable. So repair 1a is spec-neutral, not a
   weakening.
4. **Decidability holds with the landed instances.** `Finset.Ico` on `ℤ` is a `Finset`, equality on
   `Fin P.card` is decidable, `Finset Formula` membership is decidable, and the outer `∃ A ∈ list` is
   a decidable bounded list existential. No `Classical.dec` is introduced.

**One consequence the recommendation did not mention, found by evaluating it: repair 1a pushes a
time-shift obligation into Phase 11.** `BoxOracleSound` (`Annotation.lean:356`) is stated at time
`0`: `bx χ = true ↔ ∀ σ total, TruthAt P.toModel σ 0 χ`. With an anchored `check`, the oracle's `←`
direction reads its refuting witness off position `0` directly. With the windowed shape, the witness
arrives at position `i` and must be transported to time `0`. **That transport is already landed**:
`Semantics.TimeShift.time_shift_preserves_truth` (`Truth.lean:457`),
`WorldHistory.timeShift` (`WorldHistory.lean:262`), `WorldHistory.isTotal_timeShift`, and
`TaskFrame.HF.timeShift` (`WorldHistory.lean:521`) — the same machinery `box_const`
(`Truth.lean:740`) is built on. So the consequence is a **citation, not a phase**; Phase 11 below
names it as a required step so it is not rediscovered mid-proof. `BoxOracleSound` is **not** to be
restated: it is consumed by the landed truth lemma.

**Why the shift lemma does not rescue anchoring** (checked, because it looks like it should): the
shift moves the *history*, and `check` enumerates *lassos*. `timeShift A.hist i` is a perfectly good
total history, but it is not the `unroll` of any enumerated `BiLasso` — which is precisely
obstruction 1. Repair 1a (or an equivalent extra degree of freedom) is therefore necessary, not
merely convenient.

**Repair 1b is rejected**, and the rejection is what removes task 441 from this plan's critical
path. 1b asks for a satisfying history whose type at the point of interest recurs in its past — the
effective-periodic-extension problem. The implementation agent correctly flagged that plan 05's
"441 is a coordination dependency gating nothing" is false *for 1b*. Taking 1b would therefore make
this plan's crux depend on another task's in-flight research. 1a needs no new theorem at all. The
handoff's framing is corrected here: **441 gates 1b; 1a is chosen; therefore 441 gates nothing in
this plan**, and the coordination reduces to file territory (see Risks).

**A third repair, 1c, was considered and rejected.** Task 441 has already landed
`BiLasso/Extend.lean` with `PlacedBiLasso` — a `BiLasso` plus an `origin : ℤ`, whose decoding is
`L.lasso.unroll (t - L.origin)` — and its module docstring states the same obstruction independently
("everything strictly left of `0` is already spoken for by the periodic `back` segment"). One could
keep `check` anchored at `0` by enumerating `PlacedBiLasso`s. Rejected: it would require re-proving
the enumeration and both decidability instances at the placed type, and would couple this plan's
shipped deliverable to a file another task is actively editing. The `∃ i ∈ window` of repair 1a is
the *same* degree of freedom 441 made structural; unifying the two is a worthwhile follow-up for
whichever task owns the shared abstraction, and is explicitly not in scope here.

### Obstruction 2, addressed explicitly

**Repair 1a does not touch obstruction 2, and it must not be allowed to look as if it does.** The
bound is about which annotations `boundedAnnots P φ bx n` enumerates — `mem_boundedAnnots`
(`Enumerate.lean:306`) requires all three segment lengths `≤ n` — and is entirely independent of
where in the annotation the witness sits.

**The handoff's fallback for obstruction 2 — "state Phase 10 with an existential bound and have
Phase 12 consume that" — is rejected as unimplementable.** `check` must call `boundedAnnots` at a
*computed* `n`. An existential `∃ n` supplies no such `n`, so that route does not yield a decision
procedure at all; it yields a `Decidable` instance only via `Classical.dec`, which the Non-Goals
forbid and which would make `check` non-computing. The degeneralisation is therefore **forced**, not
preferred.

The construction prescribed below closes the bound without a counter automaton, using a reduction
that the landed `LocalCoherent` clauses make available:

- **Interior eventualities are free.** `LocalCoherent`'s `untl` clause (`Annotation.lean:311-314`)
  is `untl g e ∈ label t ↔ (e ∈ label (t+1) ∨ (g ∈ label (t+1) ∧ untl g e ∈ label (t+1)))`. So an
  `untl` carried at an interior position of a cycle either delivers its event before the cycle ends,
  or is still carried at the cycle's endpoint — whose type equals the base type. Contrapositively:
  **if every `untl` in the *base* type is discharged inside the cycle, every `untl` carried anywhere
  in the cycle is too.** The same clause also supplies the guard for free: each undischarged step
  forces `g` at the next position, which is exactly `Fulfilling`'s interval condition
  (`Annotation.lean:336-340`). `snce` mirrors, backwards.
- **Therefore only `m ≤ k` obligations need marking**, where `m` is the number of `untl`-formulas in
  the base type. A single loop from a recurring datum to a later occurrence of it, chosen past all
  `m` source witnesses, contains all `m` marks; shortening each of the `m+1` inter-mark segments
  independently to at most one full residue system gives an explicit total length.
- **The shortening step already exists**: `exists_lt_iter_of_card_le` (`FMP/Periodicity.lean:140`)
  shortens an `iter R n` walk to `iter R m` with `m < n` once `Nat.card W ≤ n`, and
  `exists_path_of_iter` (`:62`) / `iter_of_path` (`:85`) / `iter_add` convert between the walk and
  path presentations. `exists_repeat_of_card_lt` (`:104`) supplies the recurrence over `ℤ`.
- **Splicing is sound because coherence is local.** Cutting a segment between two positions with the
  same `(state, type)` datum preserves adjacency (state components agree) and preserves every
  `LocalCoherent` clause at the seam (each clause at a position reads only that position's label,
  one neighbour's label, and that position's state — all realised at some source time). This is the
  one lemma the whole extraction rests on and it is Phase 10.1's deliverable.

The resulting datum stays the **pair** `(state, type)` — plan 05's `pigeonDatum` (`SmallModel.lean:225`)
is consumed unchanged — and the `pending` component is replaced by *marks on a walk*. This is the
Büchi degeneralisation, done as an iterated pigeonhole rather than an enriched state space, and it
is chosen because it reuses three landed helpers instead of building an automaton. The derived
bound is a **hypothesis to confirm, not an assertion**: see Phase 10.2's Scope Hypothesis.

### Research Integration

Newly integrated into this revision, beyond plan 05's inputs:

1. **`evidence/phase10-origin-anchoring-obstruction.lean`** (new since plan 05) — sorry-free, four
   clean `#print axioms`. Drives the `check` re-shape. Its `Phase10Target` (`:235`) is the
   position-indexed deliverable shape; Phase 10.3 below **strengthens** it by requiring `i` to lie in
   the coherence window rather than being a bare `∃ i : ℤ`, since Phase 12 must range over a finite
   set to stay decidable.
2. **`Semantics.TimeShift.time_shift_preserves_truth` is landed** (`Truth.lean:457`, verified this
   revision) — the transport Phase 11 needs under the windowed shape. This turns what would have
   been a new obligation into a citation, and it is why the windowed shape costs nothing downstream.
3. **Task 441 has landed `BiLasso/Extend.lean`** (commit `809994a8d`, `PlacedBiLasso` with `origin`
   and `isStepPath_shift`), verified this revision. Two consequences: independent corroboration of
   obstruction 1 from another task's docstring, and a concrete file-territory boundary (Risks).
4. **The landed window constants are usable as-is.** `cohWindowLo`/`cohWindowHi` (`Decide.lean:373`,
   `:376`) with `nb_pos`/`nf_pos` make `[0, nm] ⊆ [cohWindowLo, cohWindowHi)` unconditional. Phase 12
   reads the bounds off `Decide.lean` rather than restating the arithmetic — the same
   read-off-don't-restate discipline plan 05's Phase 8 established.
5. **`typeAt` and `pigeonDatum` are `noncomputable`** (`SmallModel.lean:99`, `:225`), by design —
   they filter on `TruthAt`. That is fine and must stay fine: they appear only in the extraction's
   *proof*, never inside `check`. Phase 12's verification re-checks that `check` computes.

### Carried forward unchanged from plan 05

The Overview sections of plan 05 remain the architecture of record and are not restated here: the
route-1/route-2 evaluation and route 1's recorded mathematics; the CORRECTION OF RECORD on
guard-first argument order (`Truth.lean:159-168`, re-verified again this revision); the plan-04
mapping table. **Guard first, event second** — `Formula.untl g e`, `Formula.snce g e` — in every new
line written under this plan.

### Roadmap Alignment

No `specs/ROADMAP.md` exists in this repository; `roadmap_flag` was not set for this dispatch. No
roadmap phases are added.

## Goals & Non-Goals

**Goals**:

- Preserve Phases 1–9 and Phase 10's landed groundwork exactly as they are. They are sorry-free and
  committed; they are consumed, not rebuilt.
- Close Phase 10 honestly as `[COMPLETED WITH EXCLUSIONS]`, with its four unfinished tasks
  enumerated, evidenced, and re-homed to Phases 10.1–10.3.
- Build the realised-datum graph over the pair `(state, type)`, with a `Fintype` whose cardinality is
  `P.card · 2^k`, and prove the splice lemma: a walk of realised edges yields `LocalCoherentSeq`.
- Extract good forward and backward cycles **with an explicit length bound**, derived from the
  finiteness proof and the interior-eventuality reduction.
- Prove `exists_annot_of_truth` in the position-indexed shape, delivering `i` inside the landed
  coherence window, together with a `bound P φ` definition that Phase 12 consumes verbatim.
- Construct the box oracle by `modalDepth` stratification, transporting its refuting witness to time
  `0` with the landed `time_shift_preserves_truth`.
- Deliver `check`, `check_correct`, and a `Decidable` instance in the windowed shape; wire the four
  green evidence probes in as permanent regression guards.

**Non-Goals** (carried from plan 05 unless marked new):

- **No anchoring of `check` at position `0`.** `evidence/phase10-origin-anchoring-obstruction.lean`
  is the standing refutation and becomes a permanent regression guard in Phase 12. *(new)*
- **No enumeration over `PlacedBiLasso`, and no edit to `BiLasso/Extend.lean`** — that file is task
  441's territory. Read-only reference is fine; changing it is not. *(new)*
- **No `Classical.dec` and no `open Classical` anywhere `check` can reach**, and no existential
  (uncomputed) bound passed to `boundedAnnots`. *(sharpened)*
- **`eval` is retired and must not be reintroduced.** No `def eval … : ℤ → Formula → Bool` with a
  lasso-computed scan range.
- **No route-1 machinery.** No eventual-periodicity-of-`TruthAt` theorem, no formula-indexed
  threshold function. Route 1 stays the documented fallback (see Rollback/Contingency).
- **No modification of `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`.** Frozen; task 441
  consumes it.
- **No restatement of `LocalCoherent`, `Fulfilling`, `BoxOracleSound`, `Annot`, `boundedAnnots`, or
  `truth_along_annot`.** They are landed and consumed by landed proofs. If one of them looks like it
  needs to change, that is a blocker, not an edit. *(new)*
- **No `ClosureMCS`, no `BXPoint`, no derivability, no `BXCanonical` import.**
- **Task B is out of scope and is blocked** on task 450 deliverables (a) and (c). No `filteredStep`,
  `filteredStep_fwd` / `_bwd`, `FilteredStepFrame`.
- **Task C is out of scope.** No `Fulfilling` over `FilteredWorld φ`, no `truth_along_fulfilling` in
  its §4.5 generality, no assembly of the semantic FMP.
- **No frame-class re-parameterisation of the restricted-MCS layer** — task 450's charter.
- **No repair of the three inherited red `BimodalTest` modules** (`BoxSpreadProbe`,
  `RegionGateProbe`, `TableauConformance`) and no re-baselining of them.
- **No efficiency claim.** State the cost honestly in docstrings; keep `#eval` smoke tests to
  closures of two or three formulas.
- No edits under `/home/benjamin/Philosophy/Papers/` — read-only ground truth.
- No claim, in any docstring, that this decides the logic. It decides only *presented* ℤ-frames.
- No `sorry`, in any form. No vacuous definitions.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **The good-cycle bound does not close** — the third strike on this task's central pigeonhole | H | M | The route prescribed here is *not* the one that failed. Plan 05 asked for an enriched `(state, type, pending)` datum and got existence without a bound; this plan keeps the landed pair datum and puts the degeneralisation in *marks on a walk*, closing the bound with three already-landed helpers (`exists_lt_iter_of_card_le`, `exists_path_of_iter`, `iter_add`). The step that previously had no bound — "extend the loop until every obligation is discharged" — is replaced by the interior-eventuality reduction (Overview), which caps the marks at `m ≤ k` **before** any loop is chosen. Phase 10.2 remains a declared stop-and-escalate point. |
| **Discharging `BiLasso.coherent` from a walk is index bookkeeping, not mathematics, and can eat the phase** | M | H | `coherent` is `Fin (nb+1+nm+nf)`-indexed through `windowTime` (`Basic.lean:133`, `:159`). Phase 10.3 must first prove the converse of `step_of_mem_window` (`Basic.lean:204`) **in its own file** — `(∀ t ∈ [-nb-1, nm+nf), P.step (unroll t) (unroll (t+1))) → coherent` — and then feed it realised edges. Budgeted explicitly. Do not "simplify" by touching `Basic.lean`. |
| **Task 441 is implementing concurrently against a symmetric freeze of `Basic.lean`** | M | H | Three-part territory contract. (a) `Basic.lean` frozen both ways — `git diff --exit-code` on that path at every phase close. (b) `Extend.lean` is 441's file; this plan neither edits nor imports it. (c) `scripts/module-invariants-manifest.txt` is shared: re-read it immediately before editing, **append only** the lines for this plan's new modules, never rewrite or reorder existing lines, and re-read again if the edit fails. Name proximity between 441's `Extend.lean` and this plan's `Extraction.lean` is deliberate-adjacent, not accidental — keep both names as written. |
| **`Fulfilling` of the assembled annotation resists** | H | M | Two sanctioned routes, both compliant; record which was taken. **Prescribed**: the sequence-level propagation argument of Phase 10.2 (`fulfilling_of_good_cycles`). **Sanctioned fallback**: `Decide.lean`'s landed window collapse (`fulfilling_iff_window`, `fulWindowLo`/`fulWindowHi` at `:842`/`:845`) reduces `Fulfilling` to finitely many positions, at which the good-cycle property is applied pointwise. Taking the fallback is not a deviation; taking a third route is. |
| **The box oracle's `←` direction is quietly time-anchored** | M | H (it *is* anchored, at time `0`) | Named in the Overview and made an explicit task in Phase 11: transport with `time_shift_preserves_truth` (`Truth.lean:457`) plus `TaskFrame.HF.timeShift` (`WorldHistory.lean:521`). Do **not** restate `BoxOracleSound` to dodge it — it is consumed by the landed truth lemma. |
| **`TruthAt`'s `box` clause quantifies over all total histories, not the enumerated lassos** | H | M | Exactly what makes the oracle depend on the small-model theorem, hence ordering 10.3 → 11. Phase 11 must **cite** Phase 10.3 for the bridge, never assume it. `box_const` (`Truth.lean:740`) supplies history- *and* time-independence, so one `Bool` per box-subformula is the whole content. |
| **The extraction's `noncomputable` machinery leaks into `check`** | H | L | `typeAt` and `pigeonDatum` are `noncomputable` by design. Phase 12's verification includes an `#eval` of `check` on a small presentation — if it fails to reduce, the leak is real and is a blocker, not a `noncomputable def` to be added. |
| **Argument-order transposition applied backwards** | H | M | Every phase states guard-first explicitly; roles are quoted from `Truth.lean:159-168`. `BXCanonical/Quasimodel/` is **not** a model for the order — see the out-of-scope finding recorded at the end of this plan. |
| **Repository-wide pre-existing red mistaken for damage caused here** | M | H | Known and inherited, confirmed identical to HEAD by dispatches 3 and 6: `check-module-invariants.sh` C6 (7 unreachable) and C9 (1 task-number citation), `check-paper-definitions.sh` case (c), and `lake build BimodalTest` `#guard_msgs` mismatches in `BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`. Capture the baseline before Phase 10.1 and compare; never blame, never re-baseline. |
| **Scope creep from Task A into B or C once the layer works** | M | M | Non-Goals enforced at every phase close. B's precondition is another task's deliverable. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- (landed) |
| 2 | 3 | 2 (landed, closed with exclusions) |
| 3 | 4, 5 | 2 (landed) |
| 4 | 6 | 4, 5 (landed) |
| 5 | 7, 8 | 6 (landed) |
| 6 | 9 | 6, 8 (landed) |
| 7 | 10 | 7, 9 (landed groundwork; closed with exclusions) |
| 8 | 10.1 | 10 |
| 9 | 10.2 | 10.1 |
| 10 | 10.3 | 10.2 |
| 11 | 11 | 7, 10.3 |
| 12 | 12 | 7, 9, 10.3, 11 |

Phases within the same wave can execute in parallel. **The first executable phase is 10.1**; every
earlier phase is landed. The remaining chain is strictly sequential — each of 10.1 → 10.2 → 10.3
consumes the previous phase's main theorem — so there is no parallelism to exploit here and no
territory contract is needed beyond the 441 boundary in Risks.

---

### Phase 1: Repair the spike evidence file to guard-first order [COMPLETED]

**Goal**: `evidence/spike-untl-unfolding-and-fwd-obstruction.lean` sorry-free in the live guard-first
order.

**Landed**: as specified. Full text in `plans/05_annotated-bi-lasso-decision-layer.md`, Phase 1.

**Depends on**: none

**Verification Tier**: local

**Completed**: dispatch 3 (plan 04), preserved verbatim through plans 05 and 06.

---

### Phase 2: `BiLasso` datatype, `unroll`, and `unroll_isStepPath` [COMPLETED]

**Goal**: `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` — the bi-lasso structure, its
decoding, and the proof that the decoding is a step path.

**Landed**: as specified, and **frozen** from here on. Full text in plan 05, Phase 2.

**Depends on**: none

**Verification Tier**: local

**Completed**: dispatch 3 (plan 04). `git diff --exit-code` on this path is a verification criterion
of every later phase.

---

### Phase 3: Periodicity of `unroll`; scan bounds refuted [COMPLETED WITH EXCLUSIONS]

**Goal**: leftward and rightward periodicity of `unroll`, plus the scan bound plan 04 asked for.

**Landed**: the two periodicity lemmas, in `Basic.lean`.

#### Reasoned Exclusions

| Item | Reason | Evidence | Re-homed to |
|------|--------|----------|-------------|
| The scan bound "any property of `L.unroll` holding at some `s > t` holds at some `s ≤ t + \|mid\| + \|fwd\|`" | **Refuted**, not deferred. Formula truth along a bi-lasso is not a function of the state at a time, so no bound computed from the segment lengths alone can be correct | `evidence/phase3-scan-bound-is-false.lean` (`plan_scan_bound_fails`, `no_formula_independent_scan_bound`), sorry-free | Recovered in corrected form over *label membership* in Phase 8, which landed |

**Depends on**: 2

**Verification Tier**: local

**Completed**: dispatch 3 (plan 04); exclusions recorded in plan 05 and carried here unchanged.

---

### Phase 4: The exact ℤ one-step unfolding of `TruthAt` [COMPLETED]

**Goal**: `Unfold.lean` — `truth_untl_succ` and `truth_snce_pred` in guard-first order, plus the two
ℤ-distance induction wrappers over Mathlib's `Int.leInduction` / `Int.leInductionDown`.

**Landed**: as specified, sorry-free. Consumed by Phases 7 and 10 exactly as anticipated.

**Depends on**: 2

**Verification Tier**: local

**Completed**: dispatch 6.

---

### Phase 5: Generic periodic decoding and the annotated bi-lasso datatype [COMPLETED]

**Goal**: `Periodic.lean` (three-segment periodic decoding at arbitrary `[Inhabited a]`) and
`Annotation.lean`'s `Annot`, `readIndex`, `label_unroll_aligned`, the two label periodicities, and
`label_subset_closure`.

**Landed**: as specified, sorry-free. The generic helper went in a new file, not into `Basic.lean`,
per the 441 coordination constraint.

**Depends on**: 2

**Verification Tier**: local

**Completed**: dispatch 6.

---

### Phase 6: `LocalCoherent`, `Fulfilling`, `BoxOracleSound`, and the non-vacuity witnesses [COMPLETED]

**Goal**: the three predicates plus a positive and a negative concrete witness.

**Landed**: `Annotation.lean:301` (`LocalCoherent`), `:336` (`Fulfilling`), `:356` (`BoxOracleSound`);
`Examples.lean` with `posAnnot`, `negAnnot`, `fulfilling_not_implied_by_localCoherent`, and
`boxOracle_false_not_sound`. The box oracle is a single global `Formula → Bool`, per `box_const`.

**Depends on**: 4, 5

**Verification Tier**: local

**Completed**: dispatch 6.

---

### Phase 7: `truth_along_annot` — the truth lemma [COMPLETED]

**Goal**: along a locally coherent, fulfilling annotated bi-lasso, relative to a sound box oracle,
`TruthAt` at a position equals membership in that position's label, for every closure formula.

**Landed**: `TruthLemma.lean:153` (`truth_along_annot`, `∀ t : ℤ`) and `:224`
(`truth_along_annot_at`). The declared crux; compiled with no weakening. **This is the theorem that
makes repair 1a free** — it is already position-indexed.

**Depends on**: 6

**Verification Tier**: local

**Completed**: dispatch 6.

---

### Phase 8: Decidability of `LocalCoherent` and `Fulfilling` — the corrected scan bound [COMPLETED]

**Goal**: `DecidablePred` instances for both predicates via the corrected, label-level scan bound.

**Landed**: `Decide.lean`, with the derived window `[-2·nb, nm + 2·nf)` exposed as
`cohWindowLo`/`cohWindowHi` (`:373`, `:376`) and `fulWindowLo`/`fulWindowHi` (`:842`, `:845`), plus
`nb`/`nm`/`nf` abbreviations and `nb_pos`/`nf_pos`. Computing instances, no `Classical.dec`.

*(Scope Hypothesis outcome, carried from plan 05: **confirmed exactly** — window size
`2·nb + nm + 2·nf`. Phase 12 of this plan reads the bounds off these definitions rather than
restating the arithmetic.)*

**Depends on**: 6

**Verification Tier**: local

**Completed**: dispatch 6.

---

### Phase 9: Bounded enumeration of annotated bi-lassos [COMPLETED]

**Goal**: `boundedBiLassos` and `boundedAnnots` with completeness and soundness.

**Landed**: `Enumerate.lean`, with `mem_boundedAnnots` (`:306`) and `boundedAnnots_sound` (`:315`).
`boundedAnnots` takes the box oracle `bx` as an explicit parameter, and the subset universe is built
from `List.sublists` rather than `Finset.powerset` because `Finset.toList` is noncomputable — both
recorded deviations, both correct, both carried forward.

**Depends on**: 6, 8

**Verification Tier**: local

**Completed**: dispatch 6.

---

### Phase 10: The type sequence of a genuine history [COMPLETED WITH EXCLUSIONS]

**Goal (as landed)**: the sequence-level restatement of both predicates, the type of a history at a
position, and the pigeonhole datum — everything the extraction consumes.

**Landed** (sorry-free, committed, in `SmallModel.lean`): `LocalCoherentSeq`, `FulfillingSeq`,
`localCoherent_iff_seq`, `fulfilling_iff_seq`, `typeAt` (`:99`), `mem_typeAt`, `typeAt_subset`,
`typeAt_localCoherentSeq` (`:119`, consuming Phase 4's unfolding lemmas exactly as planned),
`typeAt_fulfillingSeq` (`:192`), `pigeonDatum` (`:225`), `pigeonDatum_mem` (`:230`).

#### Reasoned Exclusions

| Item | Reason | Evidence | Re-homed to |
|------|--------|----------|-------------|
| The `pending` component of the pigeonhole datum | The Büchi degeneralisation was specified as an enriched datum and produced existence without a bound. This plan replaces it with marks on a walk over the landed pair datum (Overview, obstruction 2) | `.orchestrator-handoff.json` dispatch 6 blocker, obstruction 2; `evidence/phase10-origin-anchoring-obstruction.lean` §"The second, independent gap" | Phase 10.2 |
| Forward/backward loop extraction and splice | Blocked behind the datum above; the splice needs a stated soundness lemma that did not exist | same | Phases 10.1 (splice lemma), 10.2 (extraction) |
| Assembly into an `Annot P φ` | Blocked behind obstruction 1: the assembled lasso's origin is forced to `c₂`, so the deliverable's shape had to change before assembly could be stated | `evidence/phase10-origin-anchoring-obstruction.lean` (`origin_past_periodic`, `type_at_origin_never_recurs`, `typeAt_origin_never_recurs`), sorry-free, four clean `#print axioms` | Phase 10.3 |
| `exists_annot_of_truth` and the explicit bound | Both obstructions land here | same | Phase 10.3 |

**Depends on**: 7, 9

**Verification Tier**: local

**Completed**: dispatch 6, with the exclusions above. Nothing landed in this phase is wasted: every
declaration listed is consumed by Phases 10.1–10.3.

---

### Phase 10.1: The realised-datum graph and the splice lemma [COMPLETED]

**Goal**: a finite type of pigeonhole data with a computed cardinality, the realised-step relation
over it, and the lemma that any walk of realised edges induces a `LocalCoherentSeq` label sequence.
This is the soundness of cutting and pasting, and everything after it depends on it.

Guard-first throughout: `Formula.untl g e`, `Formula.snce g e`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Realized.lean`, importing `SmallModel.lean`.
      Do not edit `SmallModel.lean`; do not import or edit `Extend.lean`.
- [ ] Define `PigeonState P φ := Fin P.card × {S : Finset Formula // S ∈ (subformulaClosure φ).powerset}`
      with a `Fintype` instance (the subtype's instance comes from `FinsetCoe.fintype`; the product's
      is derived). Prove `card_pigeonState : Nat.card (PigeonState P φ) = P.card * 2 ^ subformulaClosureCard φ`,
      citing `Closure.lean:56` for `subformulaClosureCard`.
- [ ] Define `datum P φ τ hτ u : PigeonState P φ` as the subtype refinement of the landed
      `pigeonDatum` (`SmallModel.lean:225`), discharging the subtype's side condition with
      `pigeonDatum_mem` (`:230`). Supply `datum_state` and `datum_type` projection lemmas so later
      phases never unfold the definition.
- [ ] Define `RealizedStep P φ τ hτ : PigeonState P φ → PigeonState P φ → Prop` as
      `fun x y => ∃ u : ℤ, datum … u = x ∧ datum … (u + 1) = y`.
- [ ] Prove `realizedStep_step`: a realised edge's state components are `P.step`-adjacent. From the
      history's own `respects_task` via `IntPresentation.isStepPath_iff`.
- [ ] Define `CoherentEdge P φ bx : PigeonState P φ → PigeonState P φ → Prop` — the six
      `LocalCoherent` clause obligations (`Annotation.lean:301-318`) read across one edge: atom, `bot`
      and `imp` at the source position; `box` against `bx`; the `untl` clause relating source label to
      target label; the `snce` clause relating target label to source label. Prove
      `coherentEdge_of_realizedStep` from `typeAt_localCoherentSeq` (`SmallModel.lean:119`).
- [ ] **The splice lemma.** Prove `localCoherentSeq_of_edges`: given `st : ℤ → Fin P.card` and
      `lab : ℤ → Finset Formula` such that every consecutive pair satisfies `CoherentEdge` (with the
      state components matching `st`), `LocalCoherentSeq P φ bx st lab` holds. The content is that
      each clause at a position reads only that position's label, one neighbour's label, and that
      position's state — the `snce` clause consuming the edge to the left and the `untl` clause the
      edge to the right. Docstring this explicitly: **it is why cutting a segment between two
      positions with equal data is sound**, and it is the lemma whose absence blocked plan 05's
      assembly step.

**Timing**: 2.5 hours

**Depends on**: 10

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts `Nat.card (PigeonState P φ) = P.card * 2 ^ subformulaClosureCard φ`.
Confirm by proving it, not by asserting it, and expose it as a named theorem — Phases 10.2 and 10.3
consume that theorem rather than the arithmetic. If the `Fintype` instance forces a different
normal form (e.g. `Fintype.card` rather than `Nat.card`), state both and record which the downstream
bound uses.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Realized.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Realized` exits 0, sorry-free.
- `#print axioms localCoherentSeq_of_edges` reports no `sorryAx`.
- `git diff --exit-code FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` is clean.
- `git diff --exit-code FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` is clean.

---

### Phase 10.2: Good cycles with an explicit bound [COMPLETED]

**Goal**: forward and backward cycles that discharge every eventuality they carry, **with a length
bound derived from `card_pigeonState`**, plus the lemma that two good cycles and local coherence
imply fulfilment. This phase discharges obstruction 2 and is a declared stop-and-escalate point.

**This phase is a declared stop-and-escalate point.** If the bound resists, mark `[BLOCKED]`, write
the precise resisting goal state to `evidence/`, and stop. Do not weaken to an existential bound —
`check` cannot consume one (Overview, obstruction 2) — do not add `Classical.dec`, and do not start
Phase 10.3.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/GoodCycle.lean`, importing `Realized.lean`.
- [ ] **The interior-eventuality reduction.** Prove `untl_propagates_to_end`: along a
      `LocalCoherentSeq` label sequence, if `Formula.untl g e ∈ lab t` and no `s ∈ (t, T]` has
      `e ∈ lab s`, then `Formula.untl g e ∈ lab T` and `g ∈ lab r` for every `r ∈ (t, T]`. By
      induction on `(T - t).toNat` using the `untl` clause (`Annotation.lean:311-314`) and Phase 4's
      `Int.leInduction` wrapper. Mirror as `snce_propagates_to_start`. **This is the lemma that caps
      the marks at `m ≤ k` before any loop is chosen**, and it also supplies `Fulfilling`'s interval
      guard for free — state both consequences in the docstring.
- [ ] Prove `exists_recurring_datum`: some `x : PigeonState P φ` satisfies `datum u = x` for
      arbitrarily large `u`, and (mirror) for arbitrarily small `u`. From
      `exists_repeat_of_card_lt` (`FMP/Periodicity.lean:104`) plus finiteness.
- [ ] **`exists_good_fwd_cycle`.** For a recurring `x`, produce `L : ℕ` with `1 ≤ L` and
      `L ≤ (subformulaClosureCard φ + 1) * Nat.card (PigeonState P φ)`, and a path
      `p : ℕ → PigeonState P φ` with `p 0 = x`, `p L = x`, every step `RealizedStep`, and: for every
      `Formula.untl g e ∈ x.type` there is `j < L` with `e ∈ (p (j + 1)).type`. Construction: take a
      source witness for each of the `m ≤ k` untl-formulas in `x.type` (they exist —
      `typeAt_fulfillingSeq`, `SmallModel.lean:192`), take a later occurrence of `x` past all of them,
      cut the resulting walk at the `m` marks, and shorten each of the `m + 1` segments with
      `exists_lt_iter_of_card_le` (`FMP/Periodicity.lean:140`), reassembling with `iter_add` and
      `exists_path_of_iter` / `iter_of_path` (`:62`, `:85`).
- [ ] **`exists_good_bwd_cycle`**: the mirror, over `snce`-formulas, on the reversed datum sequence
      `fun u => datum (-u)`. State it as its own theorem; do not inline it into the forward proof.
- [ ] **`fulfilling_of_good_cycles`.** Given a `LocalCoherentSeq` label sequence that is `nb`-periodic
      strictly left of `0` and `nf`-periodic at or past `nm`, whose forward cycle discharges every
      `untl` in the type at `nm` and whose backward cycle discharges every `snce` in the type at `-1`,
      prove `FulfillingSeq`. Route: `untl_propagates_to_end` to move any position's obligation to the
      cycle entry, then the good-cycle property inside the cycle, then periodicity to cover positions
      beyond the first copy. **Sanctioned alternative** (record which was taken, either is compliant):
      reduce first with `Decide.lean`'s landed window collapse (`fulWindowLo`/`fulWindowHi`, `:842`,
      `:845`) and apply the good-cycle property pointwise over the finite window.
      *(Route taken: the **prescribed** sequence-level propagation argument. The window-collapse
      fallback was not needed and is not usable here anyway — it is stated for an `Annot`, whereas
      the assembly needs the conclusion at bare sequences, before any `Annot` exists.)*

**Timing**: 3 hours

**Depends on**: 10.1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the forward cycle length is bounded by
`(k + 1) * (P.card * 2 ^ k)` with `k = subformulaClosureCard φ`, and the backward cycle by the same
quantity. *(Outcome: **derived as `(2k + 1) * (P.card * 2 ^ k)`**, exported as `cycleBound P φ` in
`GoodCycle.lean`. The plan's own contingency for this case is followed — Phase 10.3's `bound` reads
`cycleBound` rather than restating the arithmetic, so consumer and derivation cannot drift. The
factor of two arises because laying the `m` marks along a single increasing traversal requires
sorting the witness times; the construction instead reaches each mark by an out-and-back excursion
`x ⟶ mark ⟶ x`, which costs two shortened segments per mark rather than one. Both halves of the
hypothesis are derived, not asserted: the mark count is capped at `m ≤ k` by
`untl_propagates_to_end` before any loop is chosen, and each segment shortens to fewer than
`Nat.card (PigeonState P φ)` steps by `exists_lt_iter_of_card_le`.)* The hypothesis has two halves and both must be *derived*, not asserted: that `m + 1`
segments suffice (from the interior-eventuality reduction, which caps marks at the untl-formulas of
the **base** type), and that each segment shortens to at most one full residue system (from
`exists_lt_iter_of_card_le`). If the derived bound differs — e.g. if the mark ordering forces
`2(m+1)` segments — update Phase 10.3's `bound` and say so in the phase record. Do not let the
derived quantity and the consumer drift apart.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/GoodCycle.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.GoodCycle` exits 0, sorry-free.
- `#print axioms exists_good_fwd_cycle`, `exists_good_bwd_cycle`, `fulfilling_of_good_cycles`: no
  `sorryAx` in any.
- The bound appears in the theorem statement as a closed arithmetic expression in `P.card` and
  `subformulaClosureCard φ` — not as an existentially quantified `n`.
- `git diff --exit-code` clean on `Basic.lean` and `Extend.lean`.

---

### Phase 10.3: Assembly and `exists_annot_of_truth` in the windowed shape [NOT STARTED]

**Goal**: `bound P φ` and the small-model theorem, delivering the witness at a position inside the
landed coherence window. This phase discharges obstruction 1.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Extraction.lean`, importing
      `GoodCycle.lean` and `Enumerate.lean`. Keep the name distinct from task 441's `Extend.lean`.
- [ ] Prove the converse of `step_of_mem_window` in this file:
      `coherent_of_window_step : (∀ t : ℤ, -nb - 1 ≤ t → t < nm + nf → P.step (unrollOf … t) (unrollOf … (t+1)) = true) → coherent …`,
      by mapping each `Fin (back.length + 1 + mid.length + fwd.length)` index through `windowTime`
      (`Basic.lean:133`). This is index bookkeeping and it is budgeted; do it first, so the assembly
      below is not blocked on it. **Do not touch `Basic.lean`.**
- [ ] Build the mid segment: shorten the walk from the backward cycle's base datum to `datum 0`, and
      from `datum 0` to the forward cycle's base datum, **separately**, each with
      `exists_lt_iter_of_card_le`, so that the position of source time `0` survives as a marked
      interior point. Record the witness position `i₀` and prove `0 ≤ i₀ ≤ nm`.
- [ ] Define `bound P φ : ℕ` as the maximum of the three derived segment bounds, as a `def` — Phase 12
      consumes this definition, never a restatement of the arithmetic. State it in terms of `P.card`
      and `subformulaClosureCard φ` and prove the three segment-length facts against it.
- [ ] Assemble the `Annot P φ`: the three state lists and the three label lists from the three walks;
      `coherent` from `coherent_of_window_step` fed by `realizedStep_step`; `label_sub` from
      `typeAt_subset`; `LocalCoherent` from `localCoherentSeq_of_edges` and `localCoherent_iff_seq`;
      `Fulfilling` from `fulfilling_of_good_cycles` and `fulfilling_iff_seq`.
- [ ] Prove `witness_pos_mem_cohWindow : 0 ≤ i₀ → i₀ ≤ A.nm → i₀ ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A)`,
      from `nb_pos` and `nf_pos` (`Decide.lean:84`). State it as its own lemma — it is the formal
      content of "the windowed shape loses nothing", and Phase 12 cites it.
- [ ] Prove `exists_annot_of_truth`:
      ```lean
      theorem exists_annot_of_truth (hbx : BoxOracleSound P bx)
          (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ)
          (hφ : TruthAt P.toModel τ t φ) :
          ∃ A ∈ boundedAnnots P φ bx (bound P φ),
            ∃ i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A),
              A.lasso.unroll i = τ.states t (hτ t) ∧ φ ∈ A.label i
      ```
      Membership in `boundedAnnots` via `mem_boundedAnnots` (`Enumerate.lean:306`); the label
      membership at `i` because the label there *is* `typeAt τ t` and `φ ∈ typeAt τ t` by `mem_typeAt`.
      This strengthens `Phase10Target` (`evidence/phase10-origin-anchoring-obstruction.lean:235`) from
      a bare `∃ i : ℤ` to window membership, which is what keeps Phase 12 decidable.
- [ ] Docstring the shape decision where a reader will hit it: the origin of a `BiLasso` is pinned to
      its backward repeat, so the witness cannot be normalised to position `0`; cite the evidence file
      by path, and cite `time_shift_preserves_truth` for why shifting the *history* does not help
      (the enumeration ranges over lassos, not histories). **No task numbers in any `.lean` file** —
      refer to the concurrent work as "the effective-periodic-extension work".

**Timing**: 3 hours

**Depends on**: 10.2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the mid segment is bounded by twice one full residue system
plus one (`2 * Nat.card (PigeonState P φ) + 1`), and hence that `bound P φ` is dominated by the
forward/backward cycle bound whenever `subformulaClosureCard φ ≥ 1` — which always holds, since a
formula is in its own closure. Confirm both by proof. If the mid bound dominates instead, `bound`
still takes the max and Phase 12 is unaffected; say which term dominated.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Extraction.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Extraction` exits 0, sorry-free.
- `#print axioms exists_annot_of_truth` reports no `sorryAx`.
- The theorem statement contains `Finset.Ico (cohWindowLo A) (cohWindowHi A)` and a closed-form
  `bound P φ` — neither an unbounded `∃ i : ℤ` nor an existential bound.
- `evidence/phase10-origin-anchoring-obstruction.lean` still compiles unchanged
  (`lake env lean` exits 0). **Do not edit that file to match the landed theorem** — it is a dated
  record of the obstruction, not a moving target.
- `git diff --exit-code` clean on `Basic.lean` and `Extend.lean`.

---

### Phase 11: The box oracle by modal-depth stratification [NOT STARTED]

**Goal**: a concrete `bx` with `BoxOracleSound P bx` proved, breaking the annotation ↔ oracle
circularity.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean`.
- [ ] Define `boxOracle P : Formula → Bool` by strong recursion on `modalDepth`
      (`Syntax/Formula.lean:397`): at depth `k`, decide `□χ` as "no bounded annotated bi-lasso carries
      `¬χ` at any position of its coherence window", where the annotations consulted have box entries
      only at depth `< k`.
- [ ] Prove the stratification well-founded — every `□`-subformula consulted has strictly smaller
      modal depth. No `partial`, no `decreasing_by sorry`.
- [ ] Prove `BoxOracleSound P (boxOracle P)`. The `→` direction bridges "no enumerated annotated
      bi-lasso carries `¬χ`" to "no total history refutes `χ` at time `0`" and must **cite** Phase
      10.3, not assume it.
- [ ] **The `←` direction needs the time shift, and this is not optional.** `BoxOracleSound`
      (`Annotation.lean:356`) is anchored at time `0`, while the windowed oracle finds its refuting
      witness at a position `i`. Transport with `time_shift_preserves_truth` (`Truth.lean:457`),
      `TaskFrame.HF.timeShift` (`WorldHistory.lean:521`), and `WorldHistory.isTotal_timeShift`: the
      `i`-shift of the annotation's history is a total history refuting `χ` at `0`. Do **not** restate
      `BoxOracleSound` — it is consumed by the landed `truth_along_annot`.
- [ ] Cite `box_const` (`Truth.lean:740`) for history- and time-independence, so the oracle stays a
      single `Formula → Bool` with no time parameter.

**Timing**: 2 hours

**Depends on**: 7, 10.3

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.BoxOracle` exits 0, sorry-free.
- `#print axioms boxOracle_sound` reports no `sorryAx`.
- The oracle elaborates without `partial` and without `decreasing_by sorry`.
- `git diff --exit-code` clean on `Basic.lean` and `Extend.lean`.

---

### Phase 12: `check`, `check_correct`, `Decidable`, and regression wiring [NOT STARTED]

**Goal**: the shipped decision procedure in the windowed shape, plus the module re-export, README
updates, and the evidence probes wired in as permanent regression guards.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean`.
- [ ] Define the specification being decided, explicitly, as its own `def` — do not leave it implicit
      in `check_correct`'s statement:
      ```lean
      def SatAtState (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Prop :=
        ∃ (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ),
          τ.states t (hτ t) = w ∧ TruthAt P.toModel τ t φ
      ```
- [ ] Define `check P w φ : Bool` in the **windowed** shape:
      ```lean
      decide (∃ A ∈ boundedAnnots P φ (boxOracle P) (bound P φ),
                ∃ i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A),
                  A.lasso.unroll i = w ∧ φ ∈ A.label i)
      ```
      Read `bound` from Phase 10.3 and the window bounds from `Decide.lean`; restate neither. The `∃`
      sits **outside** any recursion on `φ`, which is why `no_compositional_imp`
      (`evidence/phase12-check-not-compositional.lean`) does not touch it — say so in the docstring.
- [ ] Docstring the position quantifier where a reader will ask about it: `check` ranges over a
      position because a `BiLasso`'s origin is pinned to its backward repeat and the satisfied formula
      cannot in general be normalised to position `0`; cite
      `evidence/phase10-origin-anchoring-obstruction.lean` by path. State that this decides the same
      predicate an anchored `check` would have — `SatAtState` is existential in the time either way.
- [ ] Prove `check_correct : check P w φ = true ↔ SatAtState P w φ`. The `←` direction is Phase 10.3;
      the `→` direction is `truth_along_annot_at` (`TruthLemma.lean:224`) at the found position `i`,
      with `boundedAnnots_sound` (`Enumerate.lean:315`) supplying `LocalCoherent` and `Fulfilling`.
- [ ] Provide the `Decidable (SatAtState P w φ)` instance via `check_correct`. **No `Classical.dec`.**
- [ ] Add `FormalSystem/Metalogic/Decidability/BiLasso.lean` as the subdirectory re-export, matching
      the existing `FMP.lean` convention. Include `Extraction.lean`, `GoodCycle.lean`, `Realized.lean`,
      `BoxOracle.lean`, `Check.lean`. **Do not add `Extend.lean` to this re-export** — it belongs to
      the effective-periodic-extension work; if that work has already re-exported it, leave its wiring
      alone.
- [ ] Update `FormalSystem/Metalogic/Decidability/README.md`'s module table and finalise
      `BiLasso/README.md`. The latter must record: that `eval` was designed, refuted and retired; the
      route-1/route-2 decision and why route 2 was taken; that `Basic.lean` is held stable for the
      effective-periodic-extension work; and **that `check` reads a position rather than the origin,
      and why**.
- [ ] Append this plan's new modules to `scripts/module-invariants-manifest.txt` for the C6 invariant,
      using the same mechanism the earlier dispatches used. **Re-read the file immediately before
      editing** (the effective-periodic-extension work shares it), append only, never reorder, and
      re-read and retry if the edit fails.
- [ ] Wire the evidence probes in as regression guards, per handoff §7. **Wire four**:
      `phase3-scan-bound-is-false.lean`, `phase7-filtered-frame-is-universal.lean`,
      `phase12-check-not-compositional.lean`, and — newly —
      `phase10-origin-anchoring-obstruction.lean`, which is what stops a future dispatch re-anchoring
      `check` at position `0`. `spike-untl-unfolding-and-fwd-obstruction.lean` stays **out** of the
      build until the frame-class uniformity work lands, per report 04 recommendation 5; record the
      reason in `BiLasso/README.md`.
- [ ] Run `bash scripts/readme-lint.sh` and `bash scripts/check-task-references.sh` — no task-number
      citations in any `.lean` file or `README.md`
      (`.claude/rules/no-task-references-in-deliverables.md`). Refer to the concurrent tasks by *what
      they are* ("the effective-periodic-extension work", "the frame-class uniformity work"), never by
      number, in any file outside `specs/**`.

**Timing**: 2 hours

**Depends on**: 7, 9, 10.3, 11

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **five** evidence probes exist, of which **four** are wired
in and one deferred. Confirm by `ls specs/417_semantic_fmp_finite_worldstate_over_z/evidence/` at
implementation time and by checking each probe's compile status individually — a probe already red
for an unrelated reason must be reported, not wired in red. The wiring mechanism (a `Tests/` module,
a `lake env lean` invocation in `check-module-invariants.sh`, or a lakefile entry) is not fixed here;
choose the one consistent with how the repository already runs non-library checks, and record the
choice.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` — new
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` — new re-export
- `FormalSystem/Metalogic/Decidability/README.md` — module table row
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — finalise
- `scripts/module-invariants-manifest.txt` — append only
- the regression-wiring target chosen above (script or test module)

**Verification**:
- Full gate set: `lake build` exits 0; `bash scripts/check-module-invariants.sh` shows no regression
  against the baseline captured before Phase 10.1; live-sorry count exactly 1
  (`countermodel_discrete`, `WeakCanonical/Transfer.lean`), via the invariant script, never naive grep.
- `#print axioms check_correct` reports no `sorryAx`.
- **`check` computes**: an `#eval` of `check` on a two-state presentation with a two-formula closure
  returns a `Bool` and terminates. If it does not reduce, a `noncomputable` dependency has leaked in
  from the extraction — that is a blocker, not a `noncomputable def` to be added.
- `bash scripts/check-task-references.sh` and `bash scripts/readme-lint.sh` pass.
- All four wired probes are green.
- `lake build BimodalTest` fails at exactly the three known modules and no others.
- `git diff --exit-code` clean on `Basic.lean` and `Extend.lean`.

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase close.
- [ ] Repository live-sorry count is exactly 1 at every phase close, verified with
      `bash scripts/check-module-invariants.sh` — **never** naive grep.
- [ ] `#print axioms` on `localCoherentSeq_of_edges`, `exists_good_fwd_cycle`,
      `exists_good_bwd_cycle`, `fulfilling_of_good_cycles`, `exists_annot_of_truth`, `boxOracle_sound`,
      and `check_correct`: no `sorryAx` in any.
- [ ] **No vacuous definitions.** In particular `SatAtState` must not be provable of everything and
      `check` must discriminate: exhibit one satisfiable and one unsatisfiable `(w, φ)` pair on a
      small presentation and `#eval` `check` to `true` and `false` respectively. Without the negative
      case the whole procedure could be constantly `true`.
- [ ] Decidability instances compute: `#eval` smoke tests on the Phase 6 witnesses (`LocalCoherent`,
      `Fulfilling`), on `boundedBiLassos` / `boundedAnnots`, and on `check`. No `open Classical` under
      `BiLasso/`, and no `Classical.dec` on any path `check` can reach.
- [ ] The explicit bound is a closed arithmetic expression, not an existential, and Phase 12 consumes
      Phase 10.3's `bound` definition rather than restating it.
- [ ] `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` is unchanged from its committed state
      at every phase close (`git diff --exit-code` on that path).
- [ ] `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` is unchanged by this plan at every
      phase close (`git diff --exit-code` on that path) — it belongs to the concurrent
      effective-periodic-extension work.
- [ ] `scripts/module-invariants-manifest.txt` contains this plan's new modules and no lines removed
      or reordered relative to its state at the start of the phase.
- [ ] No `FormalSystem.Metalogic.BXCanonical.*` import anywhere under `BiLasso/`.
- [ ] `bash scripts/readme-lint.sh` and `bash scripts/check-task-references.sh` pass.
- [ ] Inherited red is unchanged, not worsened, and **not repaired here**:
      `check-module-invariants.sh` C6 and C9, `check-paper-definitions.sh` case (c), and
      `lake build BimodalTest` `#guard_msgs` mismatches in `BoxSpreadProbe`, `RegionGateProbe`,
      `TableauConformance`. These fail identically against HEAD. Compare against the baseline captured
      before Phase 10.1 before attributing any failure to this work; **do not re-baseline the three
      test modules**.
- [ ] Argument order: every new `untl` / `snce` occurrence is guard-first, argument 1 the guard.

## Artifacts & Outputs

- `specs/417_semantic_fmp_finite_worldstate_over_z/plans/06_degeneralised-extraction-and-windowed-check.md` (this file)
- `specs/417_semantic_fmp_finite_worldstate_over_z/summaries/06_degeneralised-extraction-and-windowed-check-summary.md`
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` (landed, **frozen**)
- `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean` (landed, Phase 4)
- `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` (landed, Phase 5)
- `FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean` (landed, Phases 5–6)
- `FormalSystem/Metalogic/Decidability/BiLasso/Examples.lean` (landed, Phase 6)
- `FormalSystem/Metalogic/Decidability/BiLasso/TruthLemma.lean` (landed, Phase 7)
- `FormalSystem/Metalogic/Decidability/BiLasso/Decide.lean` (landed, Phase 8)
- `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean` (landed, Phase 9)
- `FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean` (landed, Phase 10 groundwork)
- `FormalSystem/Metalogic/Decidability/BiLasso/Realized.lean` (Phase 10.1)
- `FormalSystem/Metalogic/Decidability/BiLasso/GoodCycle.lean` (Phase 10.2)
- `FormalSystem/Metalogic/Decidability/BiLasso/Extraction.lean` (Phase 10.3)
- `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean` (Phase 11)
- `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` (Phase 12)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (finalised Phase 12)
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` (re-export, Phase 12)
- `FormalSystem/Metalogic/Decidability/README.md` (module table row, Phase 12)
- `scripts/module-invariants-manifest.txt` (appended, Phase 12)
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase10-origin-anchoring-obstruction.lean` (landed, promoted to permanent regression guard in Phase 12)
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean` (landed, permanent regression guard)

## Rollback/Contingency

Every remaining phase is additive: new modules under `Decidability/BiLasso/`, nothing live imports
them until Phase 12's re-export. Reverting any phase is `git revert` of that phase's commit; nothing
downstream breaks, because nothing downstream depends on this subtree until Phase 12. `Basic.lean`
and `Extend.lean` are not touched at all, so neither the landed Phase 2 work nor the concurrent
effective-periodic-extension work can be damaged by a rollback of anything here.

The two shared-surface exceptions are Phase 12's edits to `Decidability/README.md` and to
`scripts/module-invariants-manifest.txt`. The manifest is also written by the concurrent work: append
only, and if a rollback is needed there, remove exactly this plan's added lines rather than restoring
a whole-file snapshot. Take `bash .claude/scripts/git-snapshot.sh 417` before Phase 12 if the wiring
choice turns out to touch `lakefile.lean`.

**Never discard uncommitted changes to reach a passing build.** Fix forward; if a phase cannot be made
green, mark it `[BLOCKED]`, write the resisting goal state to `evidence/`, and stop.

**If Phase 10.2's bound blocks, the fallbacks are ordered and neither is an improvisation.** First
fallback: the enriched-datum degeneralisation plan 05 specified — `(state, type, counter)` with the
counter a genuine `Fin (m+1)` component of the pigeon state, cycling on discharge, so that a simple
cycle through a counter-wrap is good by construction. It is more machinery than the marks route and
that is why it is second, not because it is wrong. Second fallback: route 1 (formula-dependent
eventual periodicity), whose mathematics is recorded in plan 05's Overview so it does not have to be
re-derived; that is a new plan round, not a mid-dispatch switch.

**Repair 1b is not a fallback.** Making the extraction depend on effective periodic extension trades
a bounded, self-contained construction for another task's in-flight research. If both fallbacks above
fail, re-plan; do not reach for 1b.

## Deferred Scope and the Re-Plan Trigger

Tasks B and C of handoff §5 remain open and are **not** planned here:

- **Task B** (`filteredStep`, `filteredStep_fwd` / `_bwd`, `FilteredStepFrame`) is blocked on task 450
  deliverables (a) — parameterise `RestrictedConsistent` / `RestrictedMCS` /
  `closure_mcs_deductively_closed` by `{fc : FrameClass}` — and (c) — the Discrete-system consistency
  lemma. Re-plan B once 450 is `[COMPLETED]`, taking report 04 recommendation 3's four-part re-scope
  as the starting point.
- **Task C** (`Fulfilling` over `FilteredWorld φ`, `truth_along_fulfilling`, the semantic FMP
  assembly) depends on both A and B. Phase 7 delivers the *lasso instance* of its truth lemma and
  Phase 4 the unfolding lemmas it needs; both are written to be reusable at Task C's greater
  generality, per handoff §4.6. C should not be dispatched until A and B are both green.

**Coordination note on task 441** ("Effective periodic extension over finite frames", implementing
concurrently): it owns `BiLasso/Extend.lean` (`PlacedBiLasso`, `isStepPath_shift`) and shares
`scripts/module-invariants-manifest.txt`. This plan freezes `Basic.lean` symmetrically, never edits
`Extend.lean`, and appends only to the manifest. After both land, `PlacedBiLasso`'s `origin` and this
plan's `∃ i ∈ window` are the same degree of freedom expressed two ways; unifying them — and
unifying `Basic.lean`'s `cyc` with `Periodic.lean`'s generic version — is worth doing, but belongs to
whichever task owns the shared abstraction and is explicitly not in scope here.

**Out-of-scope finding, recorded so it is not lost** (belongs to a separate task, not this one):
`FormalSystem/Metalogic/BXCanonical/Quasimodel/Construction.lean:57` has stale argument roles after
the guard-first migration — `Formula.untl psi phi ∈ h1.formulas → psi ∉ h1.formulas → phi ∈ h1.formulas`
reads "guard absent → event present", the transpose of what guard-first semantics require.
`UntilDefect` (`:64`) and `SinceDefect` (`:68`) carry the same transposition. Do **not** fix these
under this plan — that subtree is on the MCS/proof-theoretic side and is out of this layer's scope.

When this plan completes, the correct next action is **not** `/implement 417` again but a re-plan of
B (once 450 lands) and then C.
