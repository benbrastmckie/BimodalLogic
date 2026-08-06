# Blocker Analysis: Task #428

**Parent Task**: #428 - engine_totality_at_a_quantified_branch_budget
**Generated**: 2026-08-06
**Blocker**: The terminus `buildTableauAt_isSome_of_budget` (`MintBound.lean:4416`) is proved but
**conditional** on four named residual hypotheses. All 17 plan-v4 phases are `[COMPLETED]`, the
module is green, sorry-free and axiom-free, but obstruction O1 is closed modulo the residuals
rather than closed outright, so a caller cannot yet use the result.

## Root Cause

Not an implementation defect — a **known, deliberately-recorded scope gap**. The plan's own
"Status at plan close" block and Success Criterion 11 (`plans/04_ordtimesknown-strengthening-
totality.md:6-34, :1613`) state it plainly: "no criterion in the original list required the
terminus to be unconditional." The four residuals are each landed as a named `def` in
`MintBound.lean` with an in-source docstring stating exactly what would discharge it:

1. **`UniverseClosed fc U`** (`MintBound.lean:3901`) — closure of the universe `U` under (a) the
   engine's unblocked-expansion step and (b) an ordered split's identification arm, which
   *relabels* the branch. Clause (b) is genuinely new relative to the unsplit totality theorem's
   `hU` obligation. For `U = signedUniverse C L` this is a statement about the label set `L`
   being closed under time-merging — a caller's obligation, not a fact about the engine.

2. **`DifficultyBounded fc U D`** at `β ≥ 3` (`MintBound.lean:3914`) — bounds
   `estimateBranchDifficulty` on every successor branch. This is **not a proof problem**: the
   coefficients `estimateBranchDifficulty` is built from (`temporalCount`, `modalCount`,
   `Saturation.lean:330,342`) are `private` to `Saturation.lean`, which plan v4's territory
   forbids editing (`Fuel.lean`, `Saturation.lean`, `Tableau.lean` are md5-pinned byte-identical
   to their recorded baselines). It is a **scope decision**: widen visibility, or restate the
   bound from `estimateBranchDifficulty`'s public interface and branch-confinement alone.

3. **`PostBlockingSettles fc`** (`MintBound.lean:4344`) — the post-blocking `| some _ => none`
   arm is still textually present in `buildTableauAt` (`Saturation.lean`). The blocking-aware
   certificate change removed the *permanent* disagreement (the literal test no longer reports
   forever on label-introducing work `saturateBlocked` refuses by construction) but did not prove
   the arm unreachable. `PostBlockingSettles` also subsumes `resolveOpenArm`'s `none` arm via
   `armSettlement_of_postBlockingSettles` (`MintBound.lean:4354`) — `ArmSettlement` alone is
   proved too weak, since `resolveOpenArm` tests `findClosure satBr` first and `buildTableauAt`
   does not. Its own docstring states the gap is open: "Whether the gap can be closed by fuel
   alone is exactly the question `Saturation.lean` leaves open, and nothing here decides it."
   `saturateBlocked` (`Saturation.lean:431`) and `blockedTimes`/`findUnexpandedUnblockedWith`
   (`Tableau.lean:2104,2115`) are the frozen definitions this residual is stated against.

4. **`MintPaysForTime fc U Tmax`** (`MintBound.lean:3945`) — the open mathematical core, two
   disjuncts. First disjunct: "non-`ruleMintsFreshLabel` implies no new time" is **false** as a
   rule-list reading — `densityRule` and the active arms of `untlNeg`/`snceNeg` create times
   without being witness-guarded — the correct reading tests `newOrd.constraints.length`
   (`expandOnceNoFresh`'s own test), so discharge needs a time-dimension analogue of
   `applyRule_emitted_world_mem`. Second disjunct: the σ-hit / time-reuse question —
   `Branch.nextTime = maxTime + 1` while `Branch.identifyTime` can *lower* `maxTime`, so whether
   the engine can re-issue a time an earlier identification retired is genuinely open, and the
   live-times reformulation carries the identical obligation.

The `partial_progress` field in the task's own `.return-meta.json` from the closing cycle already
ranks these "cheapest first: DifficultyBounded, UniverseClosed, PostBlockingSettles,
MintPaysForTime," which this analysis adopts as the task index order below.

**Two plan premises did not survive contact with source and MUST NOT be re-attempted** (do-not-
re-attempt register, `MintBound.lean:4455-4510`, eight entries): the naked `BudgetedTotality` is
refuted at `β = 0` (`budgetedTotality_beta_zero_false`), and Phase 12's path-figure claim was
withdrawn — the landed figure is the derived `mintAwareFuel`
(`splitAwareFuel_le_mintAwareFuel` proves enlargement, not replacement). None of the four
proposed tasks below touches either of these; all four residuals are independent named
obligations that the register explicitly leaves open rather than refutes.

## Proposed New Tasks

### New Task 0: Discharge `DifficultyBounded` (scope decision + proof)
- **Effort**: 3-5 hours
- **Task Type**: lean4
- **Rationale**: Cheapest residual and structurally different from the other three — it is
  blocked on a **visibility scope decision**, not unfound mathematics, so it should be resolved
  first and separately so an implementer does not waste effort trying to prove it purely inside
  `MintBound.lean`.
- **Depends on**: None (mathematically). Auto-serialized behind nothing since it is index 0.

### New Task 1: Discharge `UniverseClosed`
- **Effort**: 4-6 hours
- **Task Type**: lean4
- **Rationale**: A closure property of `U = signedUniverse C L` under the engine's unblocked step
  (already a familiar shape from the unsplit totality theorem's `hU` obligation) plus, newly, the
  ordered split's identification/relabelling arm.
- **Depends on**: New Task 0 (auto: file overlap — both edit `MintBound.lean`; no genuine
  mathematical ordering exists between `DifficultyBounded` and `UniverseClosed`).

### New Task 2: Discharge `PostBlockingSettles`
- **Effort**: 6-10 hours
- **Task Type**: lean4
- **Rationale**: The post-blocking settlement residual, stated against the frozen
  `saturateBlocked` (`Saturation.lean:431`) and `blockedTimes`/`findUnexpandedUnblockedWith`
  (`Tableau.lean:2104,2115`). Its own docstring records the gap as open at the fuel-vs-condition
  level, so this is a genuine proof effort, not a restatement.
- **Depends on**: New Task 0, New Task 1 (auto: file overlap — all three edit `MintBound.lean`;
  no genuine mathematical ordering exists among the three).

### New Task 3: Discharge `MintPaysForTime`
- **Effort**: 10-15 hours
- **Task Type**: lean4
- **Rationale**: The open mathematical core — both disjuncts (the ordering-length reading of
  "does a step mint a time" and the σ-hit/time-reuse obligation) are unresolved mathematics, not
  bookkeeping. Sized largest and last because it is the hardest and the plan's own residual
  ordering places it last.
- **Depends on**: New Task 0, New Task 1, New Task 2 (auto: file overlap — all four edit
  `MintBound.lean`; no genuine mathematical ordering exists among the four independent residuals).

## Dependency Reasoning

The four residuals are **mathematically independent** — none of `UniverseClosed`,
`DifficultyBounded`, `PostBlockingSettles`, `MintPaysForTime` is used in the statement or proof of
any other, and the terminus theorem (`MintBound.lean:4416-4430`) takes all four as separate,
unrelated hypotheses. Absent the file-scope overlap, all four tasks would be independent and
dispatchable in parallel.

Every task's `file_scope` includes `FormalSystem/Metalogic/Decidability/Verified/Termination/
MintBound.lean` (each residual is a `def` living in that one file, and its discharge is proved
in that file), so the pairwise file-footprint overlap check
(`.claude/context/patterns/file-footprint-overlap.md`) fires on every pair and auto-adds a
serializing edge for each: **Task 1 depends on Task 0, Task 2 depends on Tasks 0-1, Task 3
depends on Tasks 0-2 (all auto: file overlap)**. This produces a full chain
`0 -> 1 -> 2 -> 3`, ordered cheapest/most-structurally-distinct first per the parent task's own
closing-cycle note. If a future dispatch splits the discharge proofs into separate files (e.g.
one file per residual, `import`ed back into `MintBound.lean`), the overlap — and therefore the
forced serialization — would disappear and the four could run in parallel; that restructuring is
out of scope for this analysis and not assumed.

## After Completion

Once all four spawned tasks are complete, resume the parent task #428 with `/implement 428` (or
simply re-verify the terminus is discharged, since each residual task should independently drop
its named hypothesis to a proved lemma rather than modify the terminus statement itself).

The blocker will be resolved because: with `UniverseClosed`, `DifficultyBounded`,
`MintPaysForTime`, and `PostBlockingSettles` each proved as a standalone theorem (rather than
carried as an assumed `def`/hypothesis), `buildTableauAt_isSome_of_budget` can be restated (or a
new unconditional corollary added) discharging all four hypotheses internally, closing
obstruction O1 outright rather than conditionally.
