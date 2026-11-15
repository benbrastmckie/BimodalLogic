# Research Report: Task #761

**Task**: 761 - Ladder realization theorem
**Started**: 2026-11-15T16:31:08Z
**Completed**: 2026-11-15T16:41:00Z
**Effort**: ~10 min (one compiled probe, one research round)
**Dependencies**: None open (760, 775, 805, 806, 819, 820 discharged per the task description; 836 is an artifact input, not an edge)
**Sources/Inputs**: - Codebase (`RaySummary/LadderCell.lean` register-discriminator sections, `LadderChain.lean` `exists_typeBlock_of_spacing` and `ClimbWitness`, `CounterQuotient.lean` `ParamsOk`/`Tcof`/`Tnof`, `RunLayer.lean` `Rlad`/`Drift`/`Count`); `summaries/17_register-discriminator-blocked-summary.md`; `.dispatch/49.md` Prior Decisions; a compiled probe checked with `lake env lean`. No Mathlib search tool was needed (the question is internal to the ladder relation); no literature source is cited by the focus.
**Artifacts**: - `specs/761_ladder_realization_theorem/reports/18_clipped-register-block-nonvacuity.md` (this report); `specs/761_ladder_realization_theorem/prototype/clipped-register-block-nonvacuity-probe.lean` (compiled probe, 350 lines)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The answer to the focus question is NO.** Blocks with a clipped-constant register do not
  exist in general at spacing `P + 1` on top of `exists_typeBlock_of_spacing`. This is compiled:
  `ProbeB1.no_clipped_block_at_params` exhibits a finite object and a ladder path in the pump's
  scope on which no block of the available room satisfies even the WEAKEST register condition any
  such selection could impose.
- **The weakest condition is a seam condition, not interior constancy.** `clipped_seam_necessary`
  (generic in object and path): for any ladder path to carry the original's clipped register at
  copies `0` and `1` of a block `[u, u + l)`, the original's register must not climb by two or
  more from the block's first position to its last while the first sits two below `Tn`. "Nearly
  constant across the block" is stronger than needed; the seam condition is what is necessary.
- **The fixture defeats the seam condition on every block.** Object `Fin 4` (a pending 3-cycle
  plus an idle sink), path `ramp C`: pending forever into the past, countdown `C` and register
  `0` at position `0`, register climbing by one per step through the region. Every block with a
  repeated object state has length `≥ 3`, so the register climbs `≥ 2` across it. This holds at
  every block length, hence at every spacing and every `P`, with no type hypothesis.
- **`(K3)` is why the room cannot escape.** `ParamsOk` gives `Tc ≤ Tn + 1`
  (`paramsOk_Tc_le_Tn_succ`), so the room the depth-stratified invariant guarantees (`≤ Tc`) lies
  entirely below the register threshold, where the clipped reading is exact. The naive repair —
  a third pigeonhole coordinate for the clipped register — needs room
  `b · (Tn + 1) · (P + 1)`, which `ParamsOk` itself puts strictly above `Tc`
  (`clipped_pigeonhole_room_exceeds_Tc`).
- **Route (B-1)'s recorded Obligation is therefore NOT dischargeable as filed.** The condition is
  inhabited (constant-register paths satisfy it at every block) but not universal, and the pump
  must serve every history through a state.
- **Recommended next step**: a blocking route decision. This report recommends one bounded
  re-measurement of the consumer side at the pump's ACTUAL register-mismatched pairs (which are
  pending states, while every landed consumer measurement is at an idle state) before the
  certificate-side redesign is entered. See Recommendations.

## Context & Scope

The (B-1) ruling of 2026-11-15T11:05:36Z was taken research-first with a named Obligation: a
block-selection condition on top of `exists_typeBlock_of_spacing`, proved non-vacuous at spacing
`P + 1`, under which the register's clipped value is held across the block. The user focus for
this round is exactly the non-vacuity half. This round answers that question and nothing wider:
it does not attempt the depth induction, defines no relation `~_d`, edits no library module, and
takes no `(K2)` ruling.

**Obligation verification (required by the dispatch's Prior Decisions section).** The (B-1) route
does NOT discharge its Obligation: the non-vacuity it requires is refuted by compiled theorem.
Per the dispatch's instruction, the original (B-1 vs. certificate-side) question is not re-asked;
a new, specific blocking decision naming the second obstruction is returned (see Decisions and
`.return-meta.json`).

**Premise re-validation (Carried-Figure Discipline).** The three description lines flagged by the
dispatch were re-checked against live state in this session:

| Carried claim | Result |
|---|---|
| `Realize.lean` is 1004 lines | CONFIRMED (`wc -l` = 1004) |
| `w-soundness-shape-refuted.lean` names `modelOf_incomplete` and `stab_iff_of_presented_nowUnique` | CONFIRMED (grep, lines 29/40/45) |
| `ladderFrameAdm_isRegular`, `no_fwd`, `no_bwd_of_idle` in `LadderModel.lean`; `Rlad_slice_infinite` in `RunLayer.lean`; `presented_modelOf` in `Realize.lean` | CONFIRMED (lines 210, 124, 144; 328; 916) |
| Design of record at `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` | **PATH STALE**: the file is now at `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`. Content not re-read this round. |
| "T3 landed no bound"; "README records it has no figure"; "every landed bridge carries `1 ≤ k`" | CARRIED-UNVERIFIED (source: task description); not load-bearing for this round |

Evidence tier: the probe is a standalone file elaborated by `lake env lean` against the built
`LadderCell` olean. No lean-lsp lookup result is used as a negative finding anywhere below.

## Findings

### Codebase Patterns

1. **What the pigeonhole controls.** `exists_typeBlock_of_spacing` (`LadderChain.lean:564`)
   samples `b + 1` positions at spacing `s` from `w₀` and returns two that share
   `(objAt, tpOf)`; its only room hypothesis is `w₀ + b · s ≤ z + cntAt g z`. It says nothing of
   the register: `nxtAt` appears nowhere in its statement or proof.

2. **What the register is free to do.** `Rlad` (`RunLayer.lean:268`) constrains the register by
   `Drift` alone (`n' ∈ {n − 1, n, n + 1}`), and `Count` reads it only at an idle-to-pending
   step. Inside a pending region the register is unconstrained up to `Drift`, independently of
   the object walk. A register climbing by one at every step of a region is a ladder path on
   every object.

3. **Where the block must sit.** The iterated splice raises the countdown at positions at or
   before the block start `u` and shifts positions after the window; to raise the countdown at
   the state of interest `z` the block must lie in `[z, z + cntAt g z]`. The infinite room of a
   pending-forever past is therefore not available to the selection, only the region's forward
   room, of which the invariant guarantees at most `Tc`.

4. **The seam is the whole obstruction (compiled).** `ProbeB1.clipped_seam_necessary`:

   ```lean
   theorem clipped_seam_necessary
       (g : ℤ → LadderState Q pend) {g' : ℤ → LadderState Q pend}
       (hg' : IsLadderPath step pend g') (u : ℤ) (l Tn : ℕ) (hl : 0 < l)
       (hreg : ∀ i j : ℕ, i ≤ 1 → j < l →
         min (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) Tn
           = min (nxtAt g (u + (j : ℤ))) Tn) :
       ¬ (nxtAt g u + 2 ≤ nxtAt g (u + ((l - 1 : ℕ) : ℤ)) ∧ nxtAt g u + 2 ≤ Tn)
   ```

   The hypothesis `hreg` is token-for-token the clause shape of the landed
   `iterSpliced_register_clipped_interior_forces_block_drift`; this lemma drops that lemma's
   `hlo` premise (the last position need not be below `Tn`), so it also covers blocks whose top
   reaches the threshold.

5. **Non-vacuity refuted at the discharged parameters (compiled).**
   `ProbeB1.no_clipped_block_at_params`, for every labelling `lab` and every formula `φ`, at
   `Tcof`/`Tnof`/`Pof`/`Bof`:
   - `ParamsOk step4 pend4 lab φ …` holds (by `paramsOk_params`);
   - `ramp (Tcof …)` is a ladder path, pending at every `p ≤ 0`, with `cntAt … 0 = Tcof …` and
     `nxtAt … 0 = 0`;
   - for every `u ≥ 0`, `d > 0` with `u + d · (Pof + 1) ≤ Tcof` and
     `objAt u = objAt (u + d · (Pof + 1))`, and every ladder path `g'`, the clipped clause at
     copies `0` and `1` FAILS.

   No type-equality hypothesis is assumed, so the statement covers every block
   `exists_typeBlock_of_spacing` can return there. `fwd4`/`bwd4` are compiled, so
   `ladderFrameAdm step4 pend4 fwd4 bwd4` exists and the fixture is a genuine instance of the
   pump's setting rather than a bare relation. The general form `no_clipped_block_on_ramp` holds
   at every `C ≤ Tn + 1` and every block length.

6. **Why the fixture forces length `≥ 3` at every `P`.** The existing two-state `ClimbWitness`
   admits object repeats at length `1`, where the seam condition is trivially met; a refutation on
   it would need `P ≥ 2`. The 3-cycle removes the dependence: an object repeat forces `3 ∣ l`.

7. **The room arithmetic (compiled).** `paramsOk_Tc_le_Tn_succ`: `ParamsOk → Tc ≤ Tn + 1` (from
   `(K3)`'s `Tc + 2ℓ₀ ≤ Tn + 1`). `clipped_pigeonhole_room_exceeds_Tc`:
   `ParamsOk → Tc < b · (Tn + 1) · (P + 1)`. So a pigeonhole over `(object, type, clipped
   register)` cannot be run inside the `Tc` room under ANY parameters satisfying `ParamsOk`; this
   is a property of `(K3)`'s ordering, not of the choice `Tcof`/`Tnof`. Raising `Tc` does not
   help while `(K3)` stands, because `Tn` rises with it.

8. **The condition is inhabited (compiled).** `exists_clipped_block_on_plateau_shape`: on a
   constant-register ladder path the path itself carries the clause at every block. The (B-1)
   condition is satisfiable; it is its universality that fails.

9. **A scope gap in the landed consumer measurement (read, not newly compiled).** Every landed
   side-(B) declaration measures a `⊡` bit at an IDLE state: `stab_alphaR_iff` takes
   `hidle : objAt g t = false`, and `stab_bit_ne_of_register_ne`'s witnesses are
   `regPath 0 0`/`regPath 0 m` at position `0`, where `regPath_objAt_self` gives `false`. The
   pump's block positions are all PENDING (`realized_typeBlock_mem_prodCycleLens` proves it via
   `cntAt_sub_of_pend`). So the refutation of the `Drift`-distance candidate (R-a) and of the
   dropped conjunct (R-c) was measured at a state shape the window's interior never occupies.
   Whether the register mismatch is confined to the window's interior is
   CARRIED-UNVERIFIED (source: summary 16/17's account that the wrapper pins the register at the
   block start and the path follows the original after the window); it was not re-derived here.

### External Resources

- None. The question is decided inside the ladder relation; no Mathlib declaration beyond `omega`,
  `Finset.card_pos`, `Nat.pow_le_pow_right`, `Fintype.card_pos` (all used in the compiled probe)
  is involved.

### Uncompiled analysis (labelled as such; nothing below is a claim of record)

- **Sufficiency of the seam condition.** On paper, clipped-equal block ends suffice for a
  `Drift`-valid register on the spliced path that is clip-equal to the original at every position
  and exact from the first dip below `Tn` onward (use `min(y_j, Tn + j, Tn + (l − j))` on interior
  copies). So the seam condition appears to be exact, not merely necessary. NOT compiled; it is
  moot for the route because non-vacuity fails.
- **The consumer at pending states.** On the two-state fixture with `labR`, the fixed formula
  `¬⊡¬ (r U (¬r ∧ X r ∧ X X ¬r))` at a pending state `(true, c, n)` appears to hold iff
  `n ≤ c + 1` (the register can drift down to `0` by the read time exactly when it starts within
  the countdown's reach). If so, the bit is INSENSITIVE to the register while `n ≤ c + 1` and
  reads the GAP `n − c`, not the clipped register — a different reading from all three measured
  candidates, and one `kappa` already carries as its gap coordinate. On the ramp's own window the
  original satisfies `n_j ≤ c_j` throughout the first half of the region. NOT compiled; it is the
  content of recommendation R2.

### Recommendations

- **R1. Do not revise the plan onto (B-1) as filed; record its Obligation as refuted.** The
  block-selection condition is not non-vacuous at spacing `P + 1` (or any spacing) inside the
  `Tc` room. [VERIFIED: PASS -- `lake env lean specs/761_ladder_realization_theorem/prototype/clipped-register-block-nonvacuity-probe.lean`, exit clean, zero errors and zero warnings; `#print axioms` on all nine theorems reports a subset of `[propext, Classical.choice, Quot.sound]`, no `sorryAx`]
- **R2 (recommended route). One bounded research round re-measuring side (B) at pending states
  above the level threshold**, on a fixture, before any redesign: decide by compilation whether a
  `⊡` bit at a pending state with countdown `≥ Tc_d` reads the clipped register, the gap, or
  neither, and whether a gap-shaped register conjunct is DELIVERED by the iterated splice on the
  `ramp` fixture of this probe (the fixture that kills the clipped reading). Kill criterion: if
  the gap-shaped conjunct is refuted on `ramp`, the path-level route is closed and R3 is entered
  with no further path-level round. [No compiled gate applicable]
- **R3 (alternative route). Move the register bridging to the certificate side**, the second
  successor named in `LadderCell.lean`'s `## The decision` docstring, so that no position-pair
  relation carries a register conjunct. Not costable; no compiled gate decides it.
  [No compiled gate applicable]
- **R4. Do not attempt a `(K2)`/`(K3)` re-basing to make room for a clipped-register
  pigeonhole.** `clipped_pigeonhole_room_exceeds_Tc` holds under every `ParamsOk` instance, so no
  parameter choice compatible with `(K3)` admits it. [VERIFIED: PASS -- same probe compile;
  theorem `ProbeB1.clipped_pigeonhole_room_exceeds_Tc`]
- **R5. Wire the probe as evidence if R1 is accepted**: the file is a self-contained refutation
  in the style of the existing `specs/evidence/seam-gluing-ray-product/` probes and of
  `prototype/stab-bit-copy-pair-probe.lean`. Whether it is promoted from `prototype/` to
  `specs/evidence/` or its two headline theorems are ported beside
  `iterSpliced_register_clipped_interior_refuted` is the planner's call. [No compiled gate applicable]

## Decisions

- **The focus question is answered in the negative, by a fixture forcing block length `≥ 3`**
  rather than by reusing `ClimbWitness`, so that the refutation holds at every `P` including
  `P ∈ {0, 1}` and at the fixture's own `Pof`.
- **The refuted statement drops the type hypothesis** rather than carrying it: it is then
  strictly stronger, and no frame, history or `tpOf` computation is needed on the fixture. Frame
  existence is still compiled (`fwd4`, `bwd4`) so the fixture is in scope.
- **No library module was edited and no `lake build` was run.** The probe lives in
  `prototype/`, matching the round-15 probe's placement.
- **A blocking `user_decision` is returned**, naming the second obstruction, per the dispatch's
  Prior Decisions instruction. The choice between R2 and R3 trades a further bounded measurement
  round on a route that has now failed at four successive register readings against entering an
  uncostable redesign; the artifacts do not settle that trade.
- **No sorry, axiom, or deferral is recommended.** If neither R2 nor R3 is taken, the task stays
  `[BLOCKED]` with this refutation as the recorded goal state, per the description's CONTINGENCY.

## Risks & Mitigations

- **Risk: the refutation is read as "cells disagree on the ramp".** It is not that. It shows no
  path-level correspondence with a clipped register conjunct exists through pump copies there;
  the cells at the two compared states may still agree. Mitigation: the probe's header and this
  report say so; R2 is exactly the measurement that would tell.
- **Risk: R2 becomes a fifth open-ended round.** Mitigation: the kill criterion above is stated
  on a fixture that already exists and compiles.
- **Risk: the pending-state analysis is wrong.** It is uncompiled and labelled so; nothing in R1
  or R4 depends on it.
- **Risk: `Tc_0 = 0` at the deepest level.** `margin_room_at_depth` leaves the threshold vacuous
  at `d = D`, so "pending with countdown `≥ Tc_d`" includes countdown `0` there, where a register
  reading within two steps is plausible. R2's measurement must be taken at a positive threshold
  AND at threshold `0`, and a positive base would need the `(K2)` ruling the plan has not taken.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| seam necessity (`min`/`Drift` arithmetic after two clause instances) | `omega` | success | after `unfold Drift`; `min` handled natively |
| `Rlad` on the ramp, per case | `omega` / `simp` | success | `unfold Drift`/`Count`, `simp [pend4]` |
| closed facts on `Fin 4` (`step4_nxt4`, `step4_prv4`, `pend4_three`) | `decide` | success | must be stated as closed lemmas; inline `decide` under free `c n` fails ("Expected type must not contain free variables") |
| `2 ≤ card Q * 2 ^ card` | `nlinarith` | success | from `1 ≤ card Q`, `2 ≤ 2 ^ card` |
| room strictness | `omega` | success | after one `Nat.mul_le_mul` |

## Context Extension Recommendations

- **Topic**: register-coordinate obstructions on the ladder pump.
- **Gap**: the four successive register readings and their refuting declarations are spread over
  two summaries, one module docstring and two probes.
- **Recommendation**: none filed this round; a planner revising the route may want a single
  table in the next plan's Research Inputs rather than a new context file.

## Appendix

- Probe: `specs/761_ladder_realization_theorem/prototype/clipped-register-block-nonvacuity-probe.lean`
  — theorems `clipped_seam_necessary`, `no_clipped_block_on_ramp`, `no_clipped_block_at_Tc`,
  `fwd4`, `bwd4`, `no_clipped_block_at_params`, `paramsOk_Tc_le_Tn_succ`,
  `clipped_pigeonhole_room_exceeds_Tc`, `exists_clipped_block_on_plateau_shape`.
- Compile command: `lake env lean specs/761_ladder_realization_theorem/prototype/clipped-register-block-nonvacuity-probe.lean` (three runs: the first, before `fwd4`/`bwd4` were added, clean; the second exposed four inline-`decide` errors in `fwd4`/`bwd4`; the third and final run clean).
- Declarations read: `exists_typeBlock_of_spacing` (`LadderChain.lean:564`), `ClimbWitness`
  (`LadderChain.lean:1922-2060`), register-discriminator sections (`LadderCell.lean:2343-2836`),
  `Rlad`/`Drift`/`Count` (`RunLayer.lean:254-271`), `ParamsOk` and `(K1)`-`(K4)`,
  `Tcof`/`Tnof`/`Pof` (`CounterQuotient.lean:773-960`), `budget_mul_spacing_le_Tc`,
  `margin_room_at_depth` (`CounterQuotient.lean:1058-1100`).
- Search queries: none (no rate-limited search tool was needed).
- Issue log: one `issue` (B-1 Obligation refuted) and one `win` (single-file probe decided the
  question) recorded via `issue-record.sh` during the round.
