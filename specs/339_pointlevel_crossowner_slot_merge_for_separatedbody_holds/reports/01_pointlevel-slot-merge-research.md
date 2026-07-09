# Blocker Analysis: Task #337

**Parent Task**: #337 - Build joint multi-owner disjunct bracket.holds engine for kvE2_sepDisjunct
**Generated**: 2026-07-08
**Blocker**: Task 338's cross-owner enrichment added a merged-chain RANK to the weak order, but
the slot lists it uses (`kvE2_sepSlotsLOf`/`ROf`, SharedWitness.lean:869-876) sequence whole
per-owner BLOCKS by that rank, not individual points. `IntervalPattern.holds` (ExistsForallNF.lean:
106-132, `holds_eq_succ` :188-204) demands ONE globally strictly-monotone witness sequence over the
full concatenated slot list. For honest models where two owners' interior witnesses genuinely
interleave, no block ordering (in either owner direction) can supply that global witness — this is
proven rank-independent by adversarial verification (report 04), so task 338's fix, while correct
and necessary, resolved the wrong layer of the problem.

## Root Cause

This is the third layer of a structural granularity mismatch that has now been diagnosed at
increasing precision across three research rounds on this task:

1. **Report 02** (`02_coincident-order-and-weakorder-scope.md`) established that Rabinovich's
   merged disjuncts (Def 3.1, md:65; Lemma 3.2(1), md:77) each pin a single GLOBAL order over the
   UNION of both owners' points, and that the pre-338 Lean carrier (`KvE2SepWeakOrder`, then
   `List (σ × tag)`) recorded only PER-OWNER tags relative to the shared anchor `w`, with no
   conjunct linking σ's tag to τ's tag into one consistent global order. This report correctly
   diagnosed the missing cross-owner order and authorized task 338 to add it.

2. **Task 338** (completed, summary at
   `specs/338_.../summaries/01_weakorder-crossowner-enrichment-summary.md`) enriched
   `KvE2SepWeakOrder` to `List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × ℕ)`, adding an
   orthogonal merged-chain RANK, and rewired `kvE2_sepBody` (SharedWitness.lean:933) to consume
   `wo` instead of the previously-discarded fixed `kvE2_sepSlotsL/R qnf` concatenation. This
   closed the Q2 gap report 02 identified: the carrier now DOES encode a genuine cross-owner
   order, and two interleavings are machine-distinguishable (938 build, no-collapse invariant
   holds). Task 338 was necessary and its acceptance criteria were met in full.

3. **Report 04** (`04_honest-case-blocker-verification.md`, adversarial verification) proved that
   task 338's fix, though correct as far as it goes, does not reach the granularity
   `IntervalPattern.holds` requires. The rank reorders whole owner BLOCKS:
   `kvE2_sepOrderOwners wo` (SharedWitness.lean:861-863) is `wo.mergeSort (rank ≤ rank) |>.map
   Prod.fst`, and `kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` (SharedWitness.lean:869-876) are
   `(kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor/RFor` — i.e. each owner's ENTIRE region
   block (`[lXU ... in (x,x1_σ)] ++ [lX1 @ x1_σ] ++ [lUW ... in (x1_σ,w)]`, SharedWitness.lean:
   292-299) moves as one contiguous unit; the rank only permutes which block comes first, never
   interleaves individual points ACROSS owners. `IntervalPattern.holds`
   (ExistsForallNF.lean:117, and `holds_eq_succ` :188-204) requires ONE witness function
   `Fin (n+1) → M.carrier` strictly monotone across the FULL concatenated index set — i.e. genuine
   point-level interleaving is exactly what a global monotone witness must realize.

   Report 04's five `lean_run_code` scratch experiments confirm the mismatch is real and
   RANK-INDEPENDENT: for an honest coincident model with two left-interior owners σ, τ whose
   self-coincident anchors interleave (`x < a=x1_σ < b=x1_τ < w`) but whose required base-type
   witnesses land OUTSIDE the segregated-owner pattern (σ needs a `zUW` witness realized at
   `u > b`, not in `(a,w)`; τ needs a `zXU` witness realized at `p < a`, not in `(x,b)`), BOTH
   block orders (σ-then-τ and τ-then-σ) force a contradictory monotonicity constraint
   (`a<u, p<a, u<p ⊢ False` via `omega`, Experiment 4). Experiment 5 confirms the block interface
   is realizable exactly when owner regions are totally segregated — which interleaving honest
   models are not. No choice of `wo ∈ kvE2_sepArr'` (task 338's entire enumeration) rescues the
   builder, because the enumeration only ever supplies a permutation of BLOCKS, never a
   point-level merge.

   Report 04 also confirms this is not dissolved by the "coincident" framing: Lean "coincidence"
   (SharedWitness.lean:684, `.coincident` tag) is SELF-coincidence — owner σ's own χ-witness
   sitting at σ's own anchor `x1_σ` — not cross-owner anchor sharing. `kvE2_sepCoincidentOrder`
   (SharedWitness.lean:1548-1550) assigns each owner a DISTINCT rank via `zipIdx`, and the honest
   completeness proof `kvE2_sepCoincidentOwner_valid_left/_valid_right` (SharedWitness.lean:1566,
   1577) extracts a SEPARATE anchor per owner with nothing forcing `x1_σ = x1_τ`. So interleaving
   honest coincident inputs are real, not an artifact of ignoring the coincidence case.

**Category**: Missing prerequisite (the deliverable — a `.holds` BUILDER, i.e. a constructive
witness-realization proof — structurally requires a carrier whose slot list is already in
model-realizable point order; the current carrier's granularity is one layer too coarse to ever
supply that witness, no matter how the builder itself is written).

**Why this is additive-unreachable from task 337 itself**: task 337's `.holds` obligation is a
CONSUMER of the slot list shape (SharedWitness.lean:970-988,
`kvE2_sepBody_holds_iff.mpr`); it cannot alter that shape without editing
`kvE2_sepSlotsLOf`/`ROf`/`kvE2_sepOrderOwners`, which live in the file scope task 337 already
touches but structurally belong to the carrier task 338 built (per report 04's explicit
recommendation and the v3 plan's own Non-Goals/Rollback constraints, which correctly kept this out
of task 337's additive scope).

## Proposed New Task

### New Task 1: Point-level cross-owner slot merge for separated-body holds

- **Effort**: complex
- **Task Type**: lean4
- **Rationale**: Redesigns `kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` (SharedWitness.lean:869-876) and
  their owner-block sequencing `kvE2_sepOrderOwners` (SharedWitness.lean:861-863) from a per-owner
  BLOCK flatMap into a genuine POINT-LEVEL cross-owner merge — every owner's individual slot
  entries (interval endpoints/anchors) interleaved into ONE globally value-sorted chain keyed by
  merged-chain position, faithful to Rabinovich's Def 3.1 single global chain (md:65-74) rather
  than a reordering of owner blocks. This is the exact fix report 04 identifies as necessary and
  sufficient to close the `.holds` gap; task 338's rank enrichment remains the correct
  cross-owner-consistency layer underneath it (Q2 in report 02), and this task builds the
  point-level realization on top rather than re-deriving it.
- **Depends on**: None among newly-spawned tasks (task 338, its true foundation, is already
  COMPLETED; the skill-spawn postflight wires this task's dependency on 338 directly, and wires
  task 337's dependency on this new task).

## Dependency Reasoning

- **This task depends on task 338 (already completed)**: task 338's rank field on
  `KvE2SepWeakOrder` is the cross-owner-consistency data (Nodup ranks = a genuine total order on
  the merged chain, per its summary) that this task's point-level merge must be KEYED BY — the new
  slot-merge logic sorts individual points by (owner rank, intra-owner position), not by an
  independently-invented order. Without 338's rank, there is no cross-owner order to merge against
  at all. Since 338 is complete, this is a data/foundation dependency, not a blocking one.
- **Task 337 depends on this new task**: task 337's Phases 2-6 (the `.holds` BUILDER) consume the
  slot list produced by `kvE2_sepSlotsLOf`/`ROf` and the dependent lemma bodies
  (`kvE2_sepBody_holds_iff`, `_nonvacuous`, `_extract`, `kvE2_sepDisjunct_extract`) whose INDEX
  READS assume a specific slot ordering. This task changes that ordering's very shape (block ->
  point-level merge), so the concrete indices, monotonicity witnesses, and segment-boundary proofs
  task 337's builder must produce depend entirely on the exact merge design this task settles.
  Task 337 cannot be attempted against the current block-shaped carrier (report 04's verdict), and
  cannot be attempted against a not-yet-decided merge shape either — it must wait for this task's
  concrete implementation choices (how the merge indexes points, what the boundary/segment
  membership lemmas look like) before its own witness-construction proof can be written.
- **No other new tasks are proposed**: this is a single, well-scoped carrier redesign confined to
  one file (`SharedWitness.lean`) and a bounded set of downstream lemmas already enumerated by task
  338's own precedent (`kvE2_sepBody_holds_iff`/`_extract`/`_nonvacuous`,
  `kvE2_sepDisjunct_extract`). Splitting the design decision (what point-level shape to use) from
  its implementation would violate the Sequentiality principle in reverse — the design choice
  itself IS the implementation-affecting decision, so it must be made and executed by the same
  task, not decomposed further.

## After Completion

Once the spawned task is complete, resume the parent task #337 with `/implement 337`.

The blocker will be resolved because: `kvE2_sepSlotsLOf`/`ROf` will produce a slot list in genuine
merged-chain point order (not block order), so `kvE2_sepBody_holds_iff.mpr`'s obligation will match
`IntervalPattern.holds`'s global-monotonicity requirement exactly — the same shape
`k1v_sorted_realizationK`'s `interleaveK` output already assumes (per report 04's engine-interface
note) — allowing task 337's Phases 2-6 `.holds` builder to be written additively against the
corrected carrier, exactly as task 338's rank enrichment was intended to (but, per report 04, did
not by itself) enable.
