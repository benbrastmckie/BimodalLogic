# Implementation Plan: L⁺ Compression and Completeness

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IMPLEMENTING]
- **Effort**: 25 hours
- **Dependencies**: `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` (landed,
  `FormalSystem/PlusLanguage/PlusIntTransfer.lean`); the redesigned sharing substrate as finally
  corrected, i.e. `FormalSystem.Metalogic.Decidability.SharingSkeleton` together with
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` and its `trans`/`share`
  projections (landed). See "Dependency statement by declaration name" below for the
  `trans_refl` follow-on and why this plan is compatible with the field either way.
- **Research Inputs**: `specs/703_lplus_compression_and_completeness/reports/01_lplus-compression-completeness-research.md`
- **Artifacts**: plans/01_lplus-compression-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Prove the L⁺ twin of `exists_witnessFamily_of_not_validZTime`: every `PlusValidZTime`
non-validity of a `PlusFormula` compresses to a bounded, canonically guessed
`PlusSharingWitnessFamily` that certifies the refutation under all six conditions. Research
established that this is not a transcription: the `Formula`-side theorem produces a
non-branching `WitnessFamily` with four conditions, while the target is a sharing family with a
representative skeleton and six conditions, and no sharing-side compression theorem exists
anywhere in the tree on either side. The plan therefore transcribes the `Formula`-side
compression pipeline to L⁺ and then builds the representative structure, the lifting obligation,
(C0) and (C5) with no precedent. Definition of done: the theorem below is proved sorry-free, no
new axioms appear, `docs/theorem-index.md` carries its row, and the C2 `AXIOM_BASELINE` pair in
`scripts/check-module-invariants.sh` pins it.

### Research Integration

The research round answered all four dispatch obligations and its answers set this plan's shape.

- **O1 (`Liftable` decidability)**: answered YES. `LiftableRaw` is decidable by bi-infinite
  language inclusion via subset construction on `2^(Fin n)` plus a compactness step, **not** by
  the finite-graph simulation the survey guessed, which is sound but incomplete. The decision
  procedure does not degrade to a semi-decision procedure. Per research Recommendation 2, **no
  `Decidable (LiftableRaw …)` instance is on this plan's critical path**; the compression
  discharges `lift` by a structural certificate instead.
- **O2 (general liftable `trans`)**: the general case is reached through
  `liftable_of_spliceClosed` with a constant lift, not through a new pigeonhole. The pigeonhole
  is already discharged in the tree as `exists_cofinal_value`, private to `Sharing/Skeleton.lean`
  and reached only through that public lemma. `transFull` is a **closed option**: with `trans`
  full, (C1')'s `untl` and `snce` clauses revert to the pre-redesign reading that made the
  certificate class empty for exactly the targets this task exists to certify. No phase should
  reopen it.
- **O3 ((C5) bound)**: the lasso count is neither `|closure| + 1` nor `|closure| × window`. It is
  singly exponential, of the order `2^|plusClosureOf (Γ ++ Del)| × W`, because a (C5) witness
  index is itself an index that generates its own demands at every window time, so the accounting
  is a saturation over closure-types rather than a count of failing closure members. Phase 8 owns
  this and Phase 12 states it in the theorem.
- **O4 (GKWZ product-undecidability)**: answered NO. No product-undecidability result bounds this
  combination. The two S5-like modalities are nested rather than independent product factors, and
  the stability modal fails both left commutativity and the Church-Rosser property against the
  temporal relation, so these are not product frames and no grid encoding applies. The closest
  product reading, `PTL × S5₂`, is decidable though non-elementary. O4 does not change the target
  and no phase below depends on a GKWZ statement.

Two further research findings reshape the phase order and are load-bearing here.

- **(C5) is designed first, not last** (research Recommendation 5). The saturation determines the
  index count, which determines the lasso list, which determines every other field. Phase 8
  precedes every representative-structure phase for this reason.
- **All cycle lengths are padded to one common value** (research Recommendation 3). `SharingWindow`
  requires `NB` and `NF` to be common multiples of the representative-cycle lengths and of every
  lasso's label-cycle lengths; leaving segments at differing lengths makes them a least common
  multiple over up to `n` lengths, which is super-exponential in the segment bound. Padding is
  cheap from the start and expensive to retrofit, so it is a declared construction invariant of
  Phases 7-9, not an optimization.

### Corrections to the dispatch's inherited path claims

Both corrections come from the research round and are recorded so no phase cites a path that does
not exist. Neither affects the substance of the prerequisite.

1. `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean:165` **does not
   exist** and there is no `PlusWitnessFamily/Compression/` directory yet — this plan creates it.
   The `rw [validZTime_iff_validInt]` that is Step 0 lives in the `Formula`-side file
   `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean:165`. The
   prerequisite claim itself is confirmed: that rewrite is Step 0 and
   `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` is its only L⁺ counterpart.
2. The acceptance gate the dispatch calls "a C2 `AXIOM_BASELINE` pin" is real, but note that the
   `Formula`-side compression theorem is pinned by **C14**, not C2. Every landed
   `PlusSharingWitnessFamily` flagship is pinned by **C2**, so the new L⁺ theorem follows the L⁺
   convention and goes in the C2 pair. Phase 13 owns this.

### Dependency statement by declaration name

This plan's dependency on the redesigned substrate is on the substrate **as finally corrected**,
stated by fully-qualified declaration name rather than by task number, and including the
follow-on that has been proposed but not filed.

- Required and used: `FormalSystem.Metalogic.Decidability.SharingSkeleton.LiftableRaw`,
  `...SharingSkeleton.SpliceClosedRaw`, `...SharingSkeleton.liftable_of_spliceClosed`,
  `...SharingSkeleton.transIdOf`, `...SharingSkeleton.transId_refl`,
  `...SharingSkeleton.transIdOf_refl`, `...PlusSharingWitnessFamily.trans`,
  `...PlusSharingWitnessFamily.share`, `...PlusSharingWitnessFamily.trans_refl'`.
- Proposed but **not filed as a numbered task**: an audit of the redesign found that the
  skeleton-wide field `FormalSystem.Metalogic.Decidability.SharingSkeleton.trans_refl`, mirrored
  at `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.trans_refl`, relocates rather
  than repairs a clause-shape collapse, and should be replaced by a per-producer existential. **No
  task number exists for that follow-on and none is invented here.**
- **Why it is not a blocker.** This plan needs `trans` reflexivity only as a hypothesis of
  `liftable_of_spliceClosed`, and supplies it locally from `transId_refl` / `transIdOf_refl`. The
  construction is therefore compatible with the field whether it survives as a structure field or
  is dropped in favour of a per-producer existential. If the follow-on lands mid-task, Phase 9's
  `trans_refl` field assignment becomes a local hypothesis discharge at the same lemma, and
  nothing else in the plan changes.

### Soundness is not in question

`FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem` and
`...plusRefutes_of_certifies` are **consumed, never modified**. Their statements must survive this
task unchanged, and both are C2-pinned, so any edit to either would be caught by the gate. No
phase below lists either file for modification except as a read.

## Goals & Non-Goals

**Goals**:

- Prove `exists_plusSharingWitnessFamily_of_not_plusValidZTime`, the L⁺ compression theorem, with
  zero sorries and no new axioms.
- Establish the two hop-free collapse lemmas `plusLocalCoherentShare_of_transId` and
  `plusThreadFulfilling_of_transId`, which reduce (C1') and (C2') on a hop-free family to the
  per-lasso forms the compression supplies.
- Define the two bounds the theorem states: `plusCompressionBound` for segment lengths and
  `plusFamilyBound` for the lasso count, the latter singly exponential in the closure per O3.
- Land a theorem-index row and a C2 axiom-baseline pin for the new theorem, in
  `docs/theorem-index.md` and `scripts/check-module-invariants.sh` respectively.

**Non-Goals**:

- The L⁺ **enumerator** and the L⁺ **decidability assembly**. The `Formula`-side
  `Compression/Enumerate.lean` and `Compression/Assembly.lean` have no counterpart in this task.
  The acceptance criterion is the compression theorem, not `decidablePlusValidZTime`.
- A `Decidable (LiftableRaw …)` instance. O1 establishes it is provable; research Recommendation 2
  keeps it off the critical path. If a later enumerator needs it, it should be added then, by
  subset construction rather than by simulation.
- Any change to `plusTruth_iff_mem`, `plusRefutes_of_certifies`, or any other soundness-side
  declaration.
- Sharpening the O3 bound. The working bound is recorded and stated honestly; finding a better
  construction is out of scope.

## Lean Challenge Statements

```lean
import FormalSystem

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability

variable {Γ Del : PlusContext}

/-- Segment-length bound for the L⁺ compression. -/
def plusCompressionBound (Γ Del : PlusContext) : ℕ := sorry

/-- Lasso-count bound for the (C5)-saturated L⁺ family; singly exponential in the closure. -/
def plusFamilyBound (Γ Del : PlusContext) : ℕ := sorry

/-- On a hop-free family, (C1') follows from the per-lasso local coherence. -/
theorem plusLocalCoherentShare_of_transId (S : PlusSharingWitnessFamily Γ Del)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j)
    (h : S.toPlusWitnessFamily.PlusLocalCoherentLab) :
    S.PlusLocalCoherentShare := sorry

/-- On a hop-free family, (C2') follows from the per-lasso fulfilment. -/
theorem plusThreadFulfilling_of_transId (S : PlusSharingWitnessFamily Γ Del)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j)
    (h : S.toPlusWitnessFamily.PlusFulfillingLab) :
    S.PlusThreadFulfilling := sorry

/-- **The L⁺ compression theorem.** Every ℤ-time non-validity of a `PlusFormula` admits a
bounded, canonically guessed sharing witness family certifying the refutation. -/
theorem exists_plusSharingWitnessFamily_of_not_plusValidZTime
    (φ : PlusFormula) (h : ¬ PlusValidZTime φ) :
    ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) [φ]) (t : ℤ),
      (∀ Λ ∈ S.lassos,
        Λ.back.length ≤ plusCompressionBound ([] : PlusContext) [φ] ∧
        Λ.mid.length ≤ plusCompressionBound ([] : PlusContext) [φ] ∧
        Λ.fwd.length ≤ plusCompressionBound ([] : PlusContext) [φ]) ∧
      S.lassos.length ≤ plusFamilyBound ([] : PlusContext) [φ] ∧
      (∃ B : Finset PlusFormula, B ⊆ plusClosureOf (([] : PlusContext) ++ [φ]) ∧
        S.bx = fun χ => decide (χ ∈ B)) ∧
      0 ≤ t ∧ t ≤ (plusCompressionBound ([] : PlusContext) [φ] : ℤ) ∧
      S.PlusCertifies t := sorry

end FormalSystem.Metalogic.Decidability
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The splice-closure seam obligation is as expensive as a bespoke `lift`. `WorldHistory.respects_task` is stated for **all pairs** of times, not only consecutive ones, so splicing two histories at a common state does not automatically yield a history and the spliced index's label row must be justified condition by condition at the seam | H | M | Phase 10 is dedicated to it and is scheduled before assembly, not discovered mid-assembly. Declared contingency, not a mid-phase improvisation: prove `lift` bespoke for the compressed `trans` by the O1 subset-construction reasoning specialized to the constructed data. Strictly more work, so it is the fallback |
| Witness lassos lose their time alignment under compression. `exists_labelledLasso_of_history_realized` returns the position the original time lands at, and (C5) pins its witness to the **same** time `u`, so a re-timed witness certifies nothing | H | M | Phase 7 declares common time alignment as a construction invariant and carries the landing position through; Phase 8's saturation consumes it. Verified by the alignment lemma listed in Phase 8 |
| `NB`/`NF` become a least common multiple over up to `n` differing cycle lengths, which is super-exponential in the segment bound | M | M | Pad every cycle to one common length as a declared invariant from Phase 7 onward (research Recommendation 3), so `NB = NF = plusCompressionBound` |
| The exponential O3 bound makes a future enumerator impractical | M | H | The theorem is the deliverable and remains correct. State the bound in the statement rather than tuning it silently, and relay it so the paired repository's search-bound expectations are reset. Out of scope to sharpen |
| The `Compression/Extract.lean` transcription overruns one agent run (614 lines on the `Formula` side) | M | M | Split across Phases 6 and 7 at the generic-readout / lasso-extraction boundary, each sized to one run |
| A phase cannot close a goal and reaches for a `sorry` | H | L | Acceptance is zero sorries. The correct response is plan decomposition into a new decimal sub-phase, never deferral. Research found every obligation to be a finite construction or a bounded induction |
| Concurrent siblings (tasks 701 and 650) share this working tree with no declared `file_scope`, so either may touch any file | M | M | Re-read every file immediately before editing; stage only this task's own hunks with an explicit file list, never a directory or glob `git add`; never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this task's files as possibly a sibling's in-flight edit; stop and report any foreign commit or foreign uncommitted modification after checking `git log` |
| A `Formula`-side file is edited by mistake during transcription | M | L | Every phase's `Files to modify` lists only new `PlusWitnessFamily/Compression/` files plus named aggregator/gate files. The `Formula`-side `Compression/` tree is read-only throughout |

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
| 9 | 12 | 1, 10, 11 |
| 10 | 13 | 12 |

Phases within the same wave can execute in parallel.

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

### Phase 8: The (C5) saturation — the lasso list and its bound [NOT STARTED]

**Goal**: Build the lasso list by saturating the (C5) witness demand, and prove the resulting
count is bounded by `plusFamilyBound`. This is the novel core and the phase that fixes `n`, so it
precedes every representative-structure phase.

**Tasks**:
- [ ] Define the (C5) demand: for an index `i`, a window time `u`, and `stab φ` in the closure
      with `stab φ ∉ L i u`, the countermodel supplies a history `τ` with the same world state as
      `i`'s history at `u` and `¬ PlusTruthAt M τ u φ`. Prove this from `PlusTruthAt`'s `stab`
      clause.
- [ ] Define the saturation operator: one round adds, for every outstanding demand, the lasso
      extracted from that witness history at that time by Phase 7's extraction, under Invariants A
      and B.
- [ ] Prove the saturation closes. Two facts do the work, both landed: the demand is constant on a
      `share`-class rather than per index (`stabFaithful_share_congr`), and it is periodic, so it
      collapses to the combined window (`stabFaithful_iff_window`). The fixpoint is reached at the
      number of distinct closure-**type** rows, not the number of closure members, because two
      indices with the same type row are interchangeable for all six conditions.
- [ ] Define `plusFamilyBound` as the resulting closed form, of the order
      `2 ^ (plusClosureOf (Γ ++ Del)).card * W` where `W` is the combined window width, and prove
      `lassos.length ≤ plusFamilyBound Γ Del`.
- [ ] Prove every listed lasso is bounded by `plusCompressionBound`, locally coherent, fulfilling
      and realized — inherited from Phase 7 for each element, preserved by the saturation.
- [ ] Record in the module docstring that this bound supersedes both the `|closure| + 1` accounting
      (which does not transfer, because `PlusBoxFaithful` needs one witness anywhere whereas (C5)
      pins its witness to a time) and the `|closure| × window` estimate (which is only the first
      round of the saturation).

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: interface

**Scope Hypothesis**: `plusFamilyBound` is asserted to be of the order
`2 ^ |plusClosureOf (Γ ++ Del)| * W`. Research records this as an upper bound from the
type-saturation argument, not a proof that no sharper construction exists. Confirm at
implementation time by proving the count bound against whatever closed form the saturation
actually yields, and record the proved form rather than forcing the estimate.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Saturate.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The count bound is a proved theorem, not a commented estimate.

---

### Phase 9: The representative structure and the hop-free succession [NOT STARTED]

**Goal**: Define the three `rep` segments, the three `trans` segments as `transIdOf`, and every
remaining `PlusSharingWitnessFamily` field except `lift`.

**Tasks**:
- [ ] Define the three `rep` segments so that `share u i j` holds exactly when the histories
      underlying lassos `i` and `j` name the same world state at `u`. Use Phase 7's Invariant B so
      that `u` means the same time on every lasso.
- [ ] Prove `rep_idem`: each listed map is idempotent, i.e. picks a class representative. Choose
      the representative canonically, by least index in the class.
- [ ] Prove `repBack_ne` and `repFwd_ne`, which follow from Invariant A's common non-zero length.
- [ ] Set `transBack`, `transMid`, `transFwd` to `transIdOf` applied to the three `rep` segments.
      Discharge `transBack_len`, `transMid_len`, `transFwd_len` by `transIdOf_length`.
- [ ] Discharge `trans_refl` by `transIdOf_refl`. **If** the proposed follow-on that drops
      `SharingSkeleton.trans_refl` as a structure field has landed by the time this phase runs,
      discharge the per-producer existential from `transId_refl` instead — the construction is
      compatible either way and nothing else changes.
- [ ] Prove `plus_hid`: this family satisfies Phase 1's `hid` hypothesis, via `transIdOf_hid`.
- [ ] Prove `rep` non-triviality: the representative structure is **not** the diagonal. The
      diagonal collapses (C5) to `⊡φ ↔ φ`, which certifies only targets on which that collapse
      holds, so a diagonal `rep` would silently void the phase's purpose.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Rep.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The non-triviality lemma is present and proved, so the diagonal degeneration is excluded by a
  theorem rather than by intent.

---

### Phase 10: Splice closure and the lifting obligation [NOT STARTED]

**Goal**: Prove `SpliceClosedRaw` for the constructed representative data and discharge `lift` by
`liftable_of_spliceClosed`. This is the plan's highest-risk phase.

**Tasks**:
- [ ] State splice closure for the constructed `rep`: for any two indices naming the same state at
      `u`, there is an index copying the first strictly before `u` and the second from `u` on.
- [ ] Close the **seam obligation**. `WorldHistory` is a subtype of `PartialHistory` whose
      `respects_task` field is stated for **all pairs** of times, not only consecutive ones, so
      splicing two histories at a common state does not automatically yield a history. The spliced
      index's label row must therefore be justified condition by condition at the seam rather than
      inherited from a spliced countermodel history.
- [ ] Close the saturation under splicing: show the Phase 8 saturation already contains, or can be
      extended by finitely many rounds to contain, every spliced index the closure condition
      demands, without breaking the `plusFamilyBound` count.
- [ ] Discharge `lift` by `liftable_of_spliceClosed`, supplying reflexivity of `trans` from
      `transIdOf_refl`. The lifted path is constant, which is why reflexivity is the only
      succession demand.
- [ ] Record in the docstring that `transFull` was considered and is a **closed option**: it
      discharges `lift` in one term but reverts (C1') to the reading that made the certificate
      class empty for exactly the targets this theorem must certify.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts that splice closure is reachable by finitely many
saturation rounds within the Phase 8 bound. Confirm at implementation time by proving the count is
preserved; if the splice rounds blow the bound, widen `plusFamilyBound` explicitly and propagate
the new form to Phases 8 and 12 rather than leaving the stated bound wrong.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Lift.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- `lift` is discharged through `liftable_of_spliceClosed`, confirmed by reading the proof term,
  not through `liftable_of_transFullOf`.

**Contingency**: if the seam obligation proves as expensive as a bespoke proof, switch to proving
`lift` directly for the compressed `trans` by the subset-construction reasoning O1 established,
specialized to the constructed data. This is strictly more work and is the declared fallback, not
the first attempt. Taking it means adding decimal sub-phases 10.1 and 10.2 rather than carrying a
`sorry`.

---

### Phase 11: (C0) atom coherence and (C5) stability faithfulness [NOT STARTED]

**Goal**: Prove the two genuinely sharing-side conditions on the constructed family.

**Tasks**:
- [ ] Prove `PlusAtomCoherent` for the construction. Indices sharing a state at `u` have histories
      naming that same state, and atoms are state-determined in the countermodel, so the labels
      agree on atoms. This is the condition the branching model's `Quotient.lift` valuation needs
      to be well defined.
- [ ] Prove the `→` direction of `StabFaithful`: if `stab φ ∈ L i u` then every `share`-class
      member carries `φ` at `u`. This follows from `⊡` being state-determined in the countermodel
      and the labels being truth sets.
- [ ] Prove the `←` direction, contraposed: if `stab φ ∉ L i u` there is a `j` in the class with
      `φ ∉ L j u`. This is exactly the demand Phase 8's saturation was built to discharge, so the
      proof is a lookup into the saturation, not a new construction.
- [ ] Confirm the window collapse applies: cite `stabFaithful_iff_window` so the two directions
      only have to be checked on the combined window.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Stab.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The `←` direction's proof cites the saturation lemma, confirming Phase 8 actually discharged
  the demand rather than merely bounding a count.

---

### Phase 12: Assembly — the L⁺ compression theorem [NOT STARTED]

**Goal**: Assemble all six conditions and prove
`exists_plusSharingWitnessFamily_of_not_plusValidZTime`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean`.
- [ ] **Step 0**: normalize the carrier with
      `rw [plusValidZTime_iff_plusValidInt]`, then `simp only [PlusValidInt, not_forall]` to
      extract the frame, model, history and time. This is the step that has no substitute — there
      is no provable Step 0 for the L⁺ statement without that transfer theorem.
- [ ] Build the canonical box guess: `bxTrue` as the truth-decided guess, `B` as the filtered
      boxed part of the closure, `bxC` as its decision function, and the agreement lemma between
      them on boxed closure members. Mirror the `Formula`-side construction.
- [ ] Extract the main lasso from the refuting history at the refuting time, and one witness lasso
      per closure member whose box guess is false, both by Phase 7's extraction.
- [ ] Run Phase 8's saturation over the resulting list to close the (C5) demands.
- [ ] Assemble the `PlusSharingWitnessFamily` from Phases 9 and 10's fields.
- [ ] Discharge the six conditions: (C0) and (C5) from Phase 11; (C1') and (C2') from Phase 1's
      collapse lemmas applied to the per-lasso forms Phase 7 supplies, via Phase 9's `plus_hid`;
      (C3) from the box-guess agreement and the witness lassos; (C4) from the main lasso at the
      landing position.
- [ ] Discharge the four side conditions: the three segment bounds from Invariant A, the lasso
      count from Phase 8, the canonical `bx` form, and the target time's own bound.
- [ ] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.

**Timing**: 2 hours

**Depends on**: 1, 10, 11

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean` - new file, the
  main theorem
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- Full `lake build` exits 0.
- `#print axioms FormalSystem.Metalogic.Decidability.exists_plusSharingWitnessFamily_of_not_plusValidZTime`
  reports exactly `[propext, Classical.choice, Quot.sound]`.
- The theorem's statement matches the Lean Challenge Statements block above, modulo the confirmed
  form of `plusFamilyBound`.
- `plusTruth_iff_mem` and `plusRefutes_of_certifies` are unchanged: confirm by
  `git diff` over `PlusWitnessFamily/Agreement.lean` showing no hunk.

---

### Phase 13: Acceptance gates [NOT STARTED]

**Goal**: Land the documentation row and the axiom pin, and run the full gate set.

**Tasks**:
- [ ] Add one row to `docs/theorem-index.md`'s Decidability section, in the format of the
      neighbouring L⁺ rows: paper label `—`, the statement, the fully-qualified name, the file,
      frame class `ZTime`, axioms `pcq pinned:C2`.
- [ ] Add one `#print axioms` line for the new theorem to the `AX_SRC` heredoc in
      `scripts/check-module-invariants.sh`.
- [ ] Add the matching `'<name>' depends on axioms: [propext, Classical.choice, Quot.sound]` line
      to the `AXIOM_BASELINE` heredoc in the **same relative order**. The check is a whole-string
      equality, so an order mismatch fails the gate.
- [ ] Update the C2 pass message from "all eighteen pinned axiom sets match baseline" to
      "nineteen". This does not fail the gate, which is exactly why it is easy to miss.
- [ ] Satisfy invariant C15: the new declaration carries `Paper: —` plus a reason at the
      declaration itself, since it is formalization-native.
- [ ] Run `bash scripts/check-module-invariants.sh` in full and confirm every gate passes,
      C2 and C14 included.
- [ ] **Regenerate `typst/generated/status.typ`, under the team lead's condition.** This task's
      new `.lean` modules move the committed counts that `.githooks/pre-commit` gates on, so the
      hook fires on every commit staging a `.lean` file. The lead's instruction, recorded here so
      a later dispatch does not have to re-derive it: leave the file alone during Phases 1-12;
      at this phase, read task 650's status from `specs/state.json`; **if it is `completed`**,
      run `bash scripts/typst-sync-check.sh --fix` and commit **only**
      `typst/generated/status.typ`, by explicit path; if 650 is still implementing, do not
      regenerate, and record the outstanding regeneration in the summary instead. As of dispatch
      16, `specs/state.json` already reports 650 as `completed`, so the condition is met — note
      that `specs/TODO.md` was stale on this point and `state.json` is the authoritative source.
- [ ] Confirm, before any further use of the hook's `--no-verify` bypass, that the status-file
      count drift is the **only** failing gate. At dispatch 16 it was: the checker reported
      exactly `formalsystem-file-count` and `formalsystem-line-count` and nothing else. Anything
      else the hook reports is to be fixed, never bypassed.

**Timing**: 1 hour

**Depends on**: 12

**Verification Tier**: full

**Scope Hypothesis**: the gate edits are asserted to be exactly four — one index row, two heredoc
lines, one message string. Confirm at implementation time by running the gate script before and
after; if any other check (C5 path resolution, C17 dead-declaration scan, C19 docstring coverage)
newly reports against the new subtree, fix it in this phase rather than deferring.

**Files to modify**:
- `docs/theorem-index.md` - one added row in the Decidability section
- `scripts/check-module-invariants.sh` - one `AX_SRC` line, one `AXIOM_BASELINE` line, one
  message string
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean` - `Paper: —`
  annotation if not already present

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with C2 reporting nineteen pinned sets.
- `grep -c 'depends on axioms' ` over the `AXIOM_BASELINE` heredoc returns 19.

---

## Testing & Validation

- [ ] `lake build` exits 0 at the end of every phase, and at task end from a clean state.
- [ ] Zero `sorry` anywhere in the new subtree, asserted by content rather than by line number
      (invariant C3).
- [ ] `#print axioms` on the new theorem reports exactly `[propext, Classical.choice, Quot.sound]`
      — no new axiom.
- [ ] `plusTruth_iff_mem` and `plusRefutes_of_certifies` have unchanged statements, confirmed by an
      empty `git diff` over `PlusWitnessFamily/Agreement.lean`.
- [ ] `bash scripts/check-module-invariants.sh` passes in full, C2 and C14 included.
- [ ] Every new module transitively imports `FormalSystem.Init` (invariant C24).
- [ ] The `lift` field is discharged through `liftable_of_spliceClosed`, not through
      `liftable_of_transFullOf`, confirmed by reading the proof term.
- [ ] The representative structure is proved non-diagonal, so (C5) does not silently degenerate to
      `⊡φ ↔ φ`.

## Artifacts & Outputs

New Lean modules, all under `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/`:

- `TransId.lean` - the (C1')/(C2') collapse on a hop-free family
- `Compression/Types.lean` - `plusTypeAtM` and the sequence-level predicates
- `Compression/Cycle.lean` - type-state carrier, pigeonhole, good cycles
- `Compression/Fulfil.lean` - fulfilment from good cycles
- `Compression/Extract.lean` - readout, the segment bound, single-history lasso extraction
- `Compression/Saturate.lean` - the (C5) saturation and the lasso-count bound
- `Compression/Rep.lean` - the representative structure and hop-free succession
- `Compression/Lift.lean` - splice closure and the lifting obligation
- `Compression/Stab.lean` - (C0) and (C5)
- `Compression/Family.lean` - the main theorem

Modified:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - aggregator imports
- `docs/theorem-index.md` - one row
- `scripts/check-module-invariants.sh` - C2 heredoc pair and pass message

Task artifacts:

- `specs/703_lplus_compression_and_completeness/plans/01_lplus-compression-completeness.md`
- `specs/703_lplus_compression_and_completeness/summaries/01_lplus-compression-completeness-summary.md`
  at implementation time

## Rollback/Contingency

Each phase is a self-contained new module plus one aggregator import line, so a failed phase is
reverted by removing its file and its import line — a targeted, non-destructive edit needing no
working-tree rollback. This is the expected recovery path and the one to reach for first.

Phase 13 is the only phase editing files outside the new subtree. Its three edits are small,
individually revertible, and each is verified by re-running the gate script.

A genuine whole-tree rollback should not be needed. If one becomes necessary, follow
`context/contracts/recovery.md`'s rollback rung for the exact snapshot-then-revert invocation
shape, including its out-of-scope override flag — and note that two sibling tasks share this
working tree with no declared `file_scope`, so a whole-tree revert would discard their work too.
Prefer the per-file revert above in every case. Never take a bare precautionary snapshot in the
default reverting mode as a start-of-phase checkpoint; a defensive checkpoint before risky work
uses the non-reverting `--no-revert` form instead.

Phase 10 carries its own declared contingency, stated in the phase: switch from splice closure to
a bespoke `lift` proof by subset construction, decomposed into decimal sub-phases, never deferred
behind a `sorry`.
