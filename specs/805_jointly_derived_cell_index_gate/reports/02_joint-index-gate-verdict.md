# Research Report: The jointly-derived cell index — gate verdict

- **Task**: 805 - Jointly derived cell index gate
- **Started**: 2026-10-16T00:00:00Z
- **Completed**: 2026-10-16T00:00:00Z
- **Effort**: ~1 research round (one dispatch); the conditional sufficiency attempt in step (5) was
  not reached and is not deferred work but a step the verdict removes
- **Dependencies**: None (parent: task 761, blocked on this sub-problem)
- **Sources/Inputs**:
  - `.claude/context/project/lean4/domain/ladder-counter-observables.md` (governing guidance; the
    five mechanisms and the parameter-origin rule as it stood)
  - `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` (fifteenth probe:
    `ladderIndexRes` body, fixtures A and B, `reachStep`, `truth_nextPow`)
  - `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` (fourteenth probe:
    gates 1-3)
  - `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` (thirteenth probe)
  - `FormalSystem/Metalogic/Decidability/RaySummary/{RunLayer,AnchorLayer,LadderModel}.lean`
  - `FormalSystem/PlusLanguage/{Formula,Subformulas,PlusTruth}.lean`
  - `specs/805_jointly_derived_cell_index_gate/reports/01_jointly-derived-index-gate.md` (round-0
    seed report: the verified starting state and the gate table)
  - `specs/761_ladder_realization_theorem/.blocker-research.json` (the stale record corrected here)
  - `scripts/check-evidence-probes.sh` (the probe rot guard)
- **Artifacts**:
  - `specs/805_jointly_derived_cell_index_gate/reports/02_joint-index-gate-verdict.md` (this report)
  - `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean` (the sixteenth
    wired probe; 1580 lines, sorry-free, no new axiom)
  - `scripts/check-evidence-probes.sh` (probe registered: `WIRED` entry plus its decision row)
  - `specs/761_ladder_realization_theorem/.blocker-research.json` (corrected)
  - `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
    (source store, outside this repository: mechanism (6), gate 6, and the strengthened modulus
    clause)
- **Standards**: report-format.md, subagent-return.md, plan-compliance.md (Statement Fidelity),
  source-store-deploy-boundary.md

## Executive Summary

- **Verdict: REFUTED.** The candidate index at parameters derived from the object and the formula
  jointly, in the sense the parameter-origin rule states, does not factor the cells. The refutation
  is machine-checked at the rule's own parameters, with the rule's own predicate discharged:
  `Probe805.rule_derived_parameters_refuted`.
- **Gates 1-3 pass; gates 4 and 5 are disarmed; a sixth gate refutes.** The formula-derived
  threshold leaves mechanism (4) no witness at all, and by a diagonal that cannot be closed. The
  formula-coupled modulus disarms mechanism (5) on the very object that produced it. Neither
  disarming is a hypothesis going unsatisfiable: each is the separation itself failing, exhibited as
  a compiled theorem.
- **The new mechanism (6):** the rule's modulus clause quantifies over the sub-objects a formula's
  **letters** can name. A formula can carve out a sub-object no set of atoms carves out, by
  forbidding a **pattern** instead of a letter. On the coprime-cycle object with `d` relabelled to
  `b`'s letter, every letter-definable sub-object admits the modulus `2`, while the letter-free
  pattern `(p ∧ ℓ_a) ∧ X X (p ∧ ℓ_a)`, forbidden at every position, forces the region's length to be
  a multiple of three and separates a pair the index identifies for every `(T, P, B)`.
- **What survives is a strictly stronger necessary condition, and nothing positive.** The modulus
  must be a multiple of the period of every sub-object the formula's **closure** can carve out —
  the object-closure product. This promotes the first of the four standing proof obligations from a
  step a proof would have to take into a necessary condition on the index's own parameter.
- **No weakened substitute was produced.** No `ladderRealized`, no `LadderCons`, no
  `ladderCons_localRun`, under those names or any other; the `box`/`stab` clause is untouched. Step
  (5) of the dispatch was conditional on the gate being survived and is removed by the verdict, not
  deferred.
- **Every index shape the governing guidance anticipated is now spent**, which returns the next move
  to the user ruling that report 01 §7 already named. See Recommendations, and the `user_decision`
  on this dispatch's return metadata.

## Context & Scope

`cellAt` must factor through some computable index of ladder states, or `ladderRealized` and
`LadderCons`'s `box`/`stab` acceptance clause cannot be **stated** — the parent record's blocker is
a missing type, not a failed proof. Four index shapes were on record: three refuted
(counter-pair clipping; gap-carrying clipping; the six-coordinate residue-carrying candidate at its
object-exhibited parameters) and one ungated — the same six-coordinate body at parameters derived
from the object **and** the formula jointly. This round defines that candidate and runs the
five-part falsification gate against it as compiled theorems, before any sufficiency attempt.

Scope as dispatched and as honoured: reports under this task's own directory, and a sorry-free
evidence probe under `specs/evidence/seam-gluing-ray-product/`. No edits under `FormalSystem/` or
`Tests/`. A refutation was an explicitly acceptable outcome and is reported as the successful one.

The index's definitional body is the fifteenth probe's `ladderIndexRes`, ported byte-for-byte as
`ladderIndexJnt`, so what is gated is the index as landed there and the only thing changed is where
its parameters come from — which is the entire content of the parameter-origin rule.

## Findings

### The candidate, as defined

- `untlDepth`, `snceDepth` — the `untl`- and `snce`-nesting depths, by recursion on the formula.
- `thrJ φ := untlDepth φ` — the threshold. `X χ = ⊥ U χ`, so the `X`-nesting depth is bounded by
  this.
- `clipJ φ := untlDepth φ + snceDepth φ` — the clip bound, covering both directions the first and
  third gates force.
- `RuleParams φ T P B` — the rule as a predicate: `thrJ φ ≤ T`, `clipJ φ ≤ B`, `1 ≤ P`. The fourth
  clause (the modulus a multiple of the period of every letter-definable sub-object) is
  object-dependent and enters each fixture as its own hypothesis; it cannot be stated once for all
  objects.
- `ruleParams_derived` — the rule's own triple satisfies it.

### Gate 1 — PASSES

`gate1_gap_separates`: on counters `(B, B+1)` against `(B, B+2)`, where both counters saturate
every threshold, the gap coordinate gives `B+1` against `B+2` and the clip keeps them apart for
every `2 ≤ B`. The lower bound on `B` is the earlier gate's collision half read as a constraint,
not a defect.

### Gate 2 — PASSES

`gate2_residue_separates`: on counters `(2B, 4B+2)` against `(2B+1, 4B+2)` — equal next deadlines,
both countdowns saturating the threshold coordinate, both gaps saturating the clip — the countdown
residue separates, for every modulus of at least two, which `RuleParams.mod_ge_two` supplies. Both
gates at the rule's own parameters: `gates_one_two_at_rule_params`.

### Gate 3 — PASSES (no refutation forward; the past half is answered by the rule)

- Forward: `second_region_sets_agree`, `third_region_any_length`. `Count false false` holds the
  countdown at `0` through an idle interval of any length while `Drift` moves the next deadline
  freely, so the achievable second-region lengths are all of `ℕ` from every pending state. The
  verdict does not mention `(T, P, B)` and so is unaffected by moving their origin to the formula.
- Past: `gap_le_region_age`, `region_start_beyond_depth`, `clipped_gap_collides`. The collision pair
  is unchanged, but under the rule it is no longer a defect: `B` covers the `snce`-nesting depth and
  the bound puts both region starts beyond that depth.

### Gate 4 — DISARMED, by a diagonal that cannot be closed

- `untlDepth_phiDepth`: mechanism (4)'s observable, the depth-`(T+1)` next-chain `phiDepth T`, costs
  `untl`-nesting depth exactly `T + 1`.
- `untlDepth_le_of_mem_closure`: the depth is monotone along subformulas.
- `gate4_witness_not_in_closure`: hence `phiDepth T` lies in the closure of **no** formula of
  `untl`-depth at most `T`; `gate4_disarmed`: at the rule's own threshold the witness is outside
  `cl φ` for **every** `φ`.
- `gate4_diagonal_escapes`: taking the witness itself as the formula does not recover the
  refutation — the threshold the rule then derives is `T + 1`, strictly above the depth that witness
  reads. The pair the index must keep apart moves with the formula and the witness never catches it.

### Gate 5 — DISARMED, at a rule-admissible modulus

- `lab5_d_only`: on mechanism (5)'s own labelling, `ℓ_d` is true at the pending state `d` and at no
  other state, so the `d`-free sub-object **is** letter-definable.
- `dfree_walk_mod3`: its `a`-to-`a` walk lengths are exactly the multiples of three. The rule's
  modulus clause therefore forces `3 ∣ P + 1` on this object.
- `reach_period_refuted` (ported and re-run at the renamed index) has hypothesis `¬ 3 ∣ P + 1`, so
  it reaches no rule-admissible modulus.
- `gate5_disarmed`: and the separation genuinely fails there — **both** cells of mechanism (5)'s
  pair contain a type lacking `phi5`, because both countdowns are then divisible by three and the
  reference 3-cycle history runs through each of them.

### Gate 6 — THE REFUTATION

The same object, with one change: `d` is given the letter of `b`.

- `lab6_d_eq_b`: no atom whatsoever distinguishes pending `d` from pending `b`.
- `lab6_keep_d_iff_b`: so every letter-restricted sub-object keeps `d` exactly when it keeps `b`.
- `cycle_not_letter_definable`: the 3-cycle `{a, b, c}`, whose `a`-to-`a` walk lengths are the
  multiples of three, is cut out by no set of atoms.
- `letter_definable_keeps_two_cycle`: wherever a letter restriction keeps the 3-cycle it keeps the
  2-cycle beside it, so the shortest `a`-to-`a` return in any letter-definable sub-object is `2`.
- `reach5_eventually_constant`: the full graph's exhibited period is `1` from threshold `4`, in
  exactly the shape `reachN_eventually_periodic` returns.
- Hence the rule's modulus clause forces nothing beyond `2 ≤ P + 1` here, and `P + 1 = 2` is the
  least modulus it admits.

A formula nonetheless carves the 3-cycle out, without forbidding a letter:

- `psi2 := (p ∧ ℓ_a) ∧ X X (p ∧ ℓ_a)` — a pending `a` with a pending `a` exactly two instants later.
  The 2-cycle `a → d → a` exhibits it; the 3-cycle does not. It **requires** `ℓ_a` and forbids
  nothing, and mentions no atom of `b`, `c` or `d`.
- `chi := ¬psi2 ∧ ¬(⊤ U psi2)` — the pattern fails here and at every strictly later instant.
- `pred_of_d`, `succ_of_d`, `chi_forces_dfree`: `d`'s only pending predecessor and only pending
  successor are `a`, so a pending `d` strictly inside the region exhibits the forbidden pattern; a
  `d` at the region's last position would hand the idle end the index `d`, which `endA` forbids.
- `chi_ref`, `endA_refL`: the reference 3-cycle history realizes `endA ∧ chi` at every region length
  divisible by three.
- `period_collision`: the pair `(a, C, n)` against `(a, C + (P+1), n)` at `n = C + (P+1) + B` with
  `C = 3(P+1)(T+1)` collides in the index for **every** `(T, P, B)`.
- `exists_cell_not_phi6`, `phi6_mem_of_mem_cell`, `cell6_ne`, `joint_parameters_refuted`: the cells
  differ for every modulus coprime to three.
- `rule_derived_parameters_refuted`: the refutation at `T = thrJ phi6`, `B = clipJ phi6`,
  `P + 1 = 2`, with `RuleParams phi6 (thrJ phi6) 1 (clipJ phi6)` discharged.

### Mechanical state

- `lake env lean specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean` exits
  `0` with no output other than the file's own `#print axioms` lines (measured this session).
- `bash scripts/check-evidence-probes.sh` reports `PASS  all 34 wired probe(s) compile`, with
  `seam-gluing-ray-product/ladder-joint-index-refutation   PASS` among them (measured this session).
- No `sorry`, no `axiom`, no `native_decide`, no vacuous definition. Axioms: `[propext]` on
  `lab6_d_eq_b`; `[propext, Quot.sound]` on the arithmetic and depth theorems;
  `[propext, Classical.choice, Quot.sound]` on the cell theorems. No new axiom.
- The probe is staged in git (`git ls-files --error-unmatch` succeeds), which the guard's
  tracked-not-merely-present test requires.

## Decisions

1. **Report the refutation as the verdict and stop there.** Step (5) of the dispatch was explicitly
   conditional on the gate being survived. It is removed by the verdict, not deferred. No positive
   lemma is attempted, stated, or sketched.
2. **No weakened substitute, under any name.** The dispatch and `plan-compliance.md`'s Statement
   Fidelity section both forbid it, and `stab_mem_tpOf_iff` pins the stab letter per cell, so a
   `LadderCons` without the `box`/`stab` clause would be a same-named weaker statement. Nothing of
   the kind appears in the probe or in this report.
3. **No seventh coordinate and no wider tuple.** The direction on record for a successor — a
   set-valued per-state datum over a quotient — is unchanged, and this round chooses no successor.
4. **Gate 6 runs as a relabelling of the existing coprime-cycle fixture, not a new object.** Frames
   do not depend on a labelling, so the frame, its regularity, its histories and the reference run
   are shared with gate 5 and the truth layer is stated once, generically in `lab`. This keeps the
   two gates' objects provably identical, which is what makes the contrast between them evidence
   about the *rule* rather than about two unrelated fixtures.
5. **State gate 6's letter-definability content as four sharp theorems rather than an enumeration of
   every letter-definable sub-object's period.** An enumeration over the `2^8` subsets of the
   carrier by `decide` was judged not worth its kernel cost; `lab6_d_eq_b`,
   `lab6_keep_d_iff_b`, `cycle_not_letter_definable` and `letter_definable_keeps_two_cycle` settle
   the only question the rule turns on — whether any letter restriction exhibits a period divisible
   by three — and they settle it structurally rather than by exhaustion.
6. **Correct `.blocker-research.json` rather than delete it.** Its `summary` and most of its
   `root_cause` remain accurate and are the parent record's only statement of *why* 761 is blocked
   on a missing type. What was stale was its recommendation, which is now withdrawn and replaced by
   the two standing alternatives with no index candidate recommended; the correction carries
   `corrected_on`, `corrected_by` and `supersedes` fields so the withdrawal is legible.
7. **Edit the guidance note in the source store, not the deployed mirror.** Mechanism (6), gate 6
   and the strengthened modulus clause went to
   `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
   per `source-store-deploy-boundary.md`. That path is outside this repository and needs a separate
   commit there; this repo's scoped-commit path cannot carry it.

## Recommendations

1. **Rule on the successor direction** (the `user_decision` on this dispatch's return metadata).
   Every index shape the governing guidance anticipated is spent, so the choice between the two
   standing alternatives is now the live question and it is a user ruling, as report 01 §7 states.
2. **If the ruling is R1** (a set-valued per-state datum over a quotient): its first obligation is
   the one mechanism (6) promoted — eventual periodicity of the realizable types in the countdown
   over the **product** of the object with the closure. Open it as a research-first record, not a
   proof attempt, and do not re-enter the tuple-widening loop.
3. **Do not gate a modulus read off the object-closure product as if it were this candidate.** It is
   a different candidate: nothing on record says such a modulus is computable or would suffice, and
   gate 6 is what it would have to be run against.
4. **Leave the three remaining obligations named and unmet**: a region-length pumping lemma for
   `untl`/`snce`-depth-bounded formulas; the next deadline's coupling through `Drift`; the
   `box`/`stab` letters through `box_mem_tpOf_iff` and `stab_mem_tpOf_iff`.
5. **Commit the source-store guidance edit separately**, in `~/.config/nvim/agent-system/`.

## Risks & Mitigations

- **Risk: the refutation is read as refuting every jointly-derived parameter triple.** It is not: it
  refutes the modulus clause *as the rule states it*. Mitigation: the probe header's "What this
  probe does NOT say" says so explicitly, and so does the corrected `.blocker-research.json`.
- **Risk: a successor reads "gates 1-5 cleared" as partial credit toward sufficiency.** Mitigation:
  the probe header restates the standing lesson — a gate probing one coordinate certifies one
  coordinate — and now has a third instance of it to point at, since the candidate that reached
  gate 6 is exactly the one that cleared the five before it.
- **Risk: the gate-6 verdict rests on an un-enumerated claim about letter-definable periods.**
  Mitigation: Decision 5. The claim the verdict needs is that no letter restriction of that object
  exhibits a period divisible by three, and `letter_definable_keeps_two_cycle` establishes it
  structurally: wherever the long cycle survives, the short one survives beside it.
- **Risk: the deployed `.claude/` guidance note now disagrees with the source store until the next
  deploy.** Mitigation: the source store is the authority per
  `source-store-deploy-boundary.md`; a redeploy (`bash .claude/scripts/deploy-headless.sh`)
  reconciles it, and the deploy-freshness notice on this dispatch already flags the tree as stale
  for one extension.

## Tactic Survey Results

Not applicable as a tactic-portfolio survey: every proof obligation in this probe is a port of an
established pattern from the thirteenth to fifteenth probes, or a cell-separation argument whose
shape those probes fixed. For the record, the automation that did the work: `decide` on the
object's finite step relation and reach sets (`step5_nxt`, `reach5_four`, `reachStep5_univ`,
`pred_of_d`, `succ_of_d`, and the small `Fin 4` case splits); `omega` on the index's coordinate
arithmetic and on every `cyc`/`toNat` cast; `simp [Mof, ladderModel, ...]` to discharge the
labelling layer. One arithmetic fact is outside `omega`'s fragment and keeps its own lemma, as in
the predecessor: `consec_mod_ne`, that two consecutive naturals are incongruent modulo `P + 1` at a
**symbolic** modulus — fixing the modulus at a literal to let `omega` through would weaken gate 2.

## Context Extension Recommendations

- **Topic**: the parameter-origin rule for a ladder cell index.
- **Gap**: the guidance note recorded five mechanisms, a five-part gate, and a modulus clause
  quantified over letter-definable sub-objects. All three are now out of date.
- **Recommendation**: done this round, in the source store — mechanism (6) added, the gate table
  extended to six rows with the "gates 4, 5 and 6 are refutations, not separations" caveat widened,
  the modulus clause strengthened from the formula's letters to its closure, and the
  "what is still open" section rewritten so the open candidate is the object-closure-product
  modulus and not the refuted one. Needs its own commit in `~/.config/nvim/agent-system/`.

## Appendix

- Probe: `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`, namespace
  `Probe805`, 1580 lines. Compile command in its header.
- Registration: `scripts/check-evidence-probes.sh`, `WIRED` entry
  `seam-gluing-ray-product/ladder-joint-index-refutation` plus its decision row in the table above
  the array.
- Predecessor probes cited and not re-derived: `ladder-cell-refutation.lean` (mechanism 1),
  `ladder-cell-index-obstructions.lean` (mechanisms 2 and 3, gates 1-3),
  `ladder-residue-index-refutation.lean` (mechanisms 4 and 5, fixtures A and B, the index body),
  `ladder-liveness-forward-only.lean` (forward-only liveness, cited by the R2 alternative).
- Library declarations the record leans on and does not touch: `anchorCells_finite`,
  `anchorCells_ncard_le`, `box_mem_tpOf_iff`, `stab_mem_tpOf_iff`, `Rlad_slice_infinite`,
  `ladderFrameAdm_isRegular`, `reachN_eventually_periodic`.
