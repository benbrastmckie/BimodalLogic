# Research Report: Task #934

**Task**: 934 - Depth-0 reachability probe: is `ForwardSlackWitnessed` satisfiable at the consumer instantiation
**Started**: 2026-11-14T09:20:54Z
**Completed**: 2026-11-14T09:26:41Z
**Effort**: ~1 hour research; implementation estimated 1-2 hours (transcription + wiring)
**Dependencies**: None (consumes landed declarations of tasks 917 and 929; edits none of them)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/RaySummary/{LadderCell,LadderChain,LadderIdle,LadderAgree,CounterQuotient,RunLayer,LadderModel}.lean`), `specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean`, `scripts/check-evidence-probes.sh`, compiled scratch probes via `lake env lean` through `lake-build-guard.sh`
**Artifacts**: - specs/934_depth_zero_reachability_probe/reports/01_consumer-shape-reachability-probe.md; compiled draft probe at specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Verdict direction: POSITIVE, compiled.** `ForwardSlackWitnessed` HOLDS at the consumer shape `(q, c + m*(P+1), n)` with amount `m*(P+1) > 0` on the object `stepOr` at `φ = ⊥`, for every `c`, `m`, `P` (draft theorem `fsw_consumer_shape`). The draft compiles sorry-free with axioms `[propext, Classical.choice, Quot.sound]`.
- **The restricted schema fires non-vacuously.** Draft theorem `consumer_fires` exhibits, at the periodicity fixpoint's own parameters (`Tcof/Tnof/Pof/Bof`, so `ParamsOk` holds by `paramsOk_params`), `c := Tc + B + 2`, `m := 1`: the regime hypotheses (`0 + 2 ≤ c`, `Tc ≤ c`), the `kappa`-collision, the witnessing hypothesis at the positive amount `P + 1`, and the cell equality obtained by APPLYING `cellLE_zero_const_of_kappa_eq_of_forwardSlack`. This is the first compiled inhabitant of that theorem's whole hypothesis set at a positive amount.
- **The existential over paths is doing real work at this state.** Draft theorems `climbC_isLadderPath` / `climbC_not_hasForwardSlack` compile a second ladder path through the SAME state `(true, C, 0)`, for every `C`, that has NO forward slack at ANY positive amount. So at the consumer shape the per-path form fails and the cell-level form holds, on one object — the trap in the task description, exhibited rather than recalled.
- **The xState of task 929 cannot itself be put in consumer shape at `m ≥ 1`**: its countdown is `2`, and the lower pair needs `n + 2 ≤ c`, i.e. `c ≥ 2`, forcing `m*(P+1) = 0`. The transcription therefore moves to the plateau at height `c + m*(P+1)`; everything else (object, labelling, formula, plateau path, `hasForwardSlack_plateau`) is reused as landed.
- **Bound on reach (must go in the probe docstring).** The cell at `φ = ⊥` is the singleton `{∅}`, so one path witnesses every type. The result decides the crux AS THE ROADMAP STATES IT (satisfiable at SOME reached state at a positive amount: yes) and does NOT discharge the hypothesis in general. No non-ceiling failure mechanism was found; the one candidate identified (residue pinning of the next region's countdown) is argued, not compiled, to be closed by `cascadeBound`'s margin.
- **Which lifting event it supports**: the `cellLE_zero_const_of_kappa_eq`-lands-as-a-theorem event, as existence evidence only. It refutes nothing about `CellLEZeroConstOfKappaEq` and does not claim the reserved name.

## Context & Scope

The five depth-0 schemas ask for `ForwardSlackWitnessed … ⟨(q, c', n')⟩ z (m*(P+1)) n'` with `c' = c + m*(P+1)` (`LadderCell.lean:1503-1508`). Unfolding `HasForwardSlack` (`LadderChain.lean:1517`) at that shape, the regime's inequality reads

    nxtAt g s₀ ≤ n + c' + I − m*(P+1) = n + c + I,

where `s₀` is the idle position before the first region start above `z`'s region and `nxtAt g s₀` is that region's countdown `K`. `Drift` (`RunLayer.lean:254`) lets the register move by ±1 per step, so paths through the higher state reach every `K ∈ [0, n + c' + I]`; the regime keeps those with `K ≤ n + c + I`. The open half is therefore exactly: is every cell type at the higher state realized by a path whose next region's countdown is at most the LOWER pair's Lipschitz allowance.

Constraints honoured: `LadderCell.lean` untouched; no per-path restatement; pin-layer route (task 917) not retried; no gate ruling taken.

## Findings

### Codebase Patterns

- `IdleRunOne` (`LadderIdle.lean:1140-1343`) already supplies `stepOr`, `fwdOr`, `bwdOr`, `labB`, `plateau_isLadderPath_stepOr`, `tpOf_bot_eq_empty`; `ClimbWitness.hasForwardSlack_plateau C l (hl : l ≤ C + 1)` (`LadderChain.lean:2023`) gives slack on the plateau with a genuine next region (`I = 1`, countdown `0`).
- The upward inclusion `cellAt_subset_of_shift_of_pend_past` (lower ⊆ higher) is unconditional; only the reverse inclusion consumes the witnessing hypothesis (`LadderCell.lean:1530-1560`). Consequence: a FAILURE of `ForwardSlackWitnessed` at the consumer shape would not by itself refute `CellLEZeroConstOfKappaEq`; a refutation needs a type in the higher cell absent from the lower one.
- The unrestricted `CellLEZeroConstOfKappaEq` (`LadderAgree.lean:3350`) carries neither `n = n'` nor the pending-forever regime, so even a general discharge of `ForwardSlackWitnessed` at the consumer shape covers only the equal-register pending-forever collisions.
- `kappa` equality at `(c, 0)` vs `(c + m*(P+1), 0)` needs `Tc ≤ c` and `B ≤ c` (gap clip saturated); `kappa_eq_of_shift` does not apply (it shifts both counters), so the draft proves the collision directly by `omega` on `clipIdx`.

### External Resources

- None needed; no Mathlib search was required (all lemmas are project-local and were confirmed by compilation, not by name lookup).

### Analysis of the failure direction (ARGUED, NOT COMPILED)

A non-ceiling failure needs a type `T` at the higher state all of whose realizing paths have `K > n + c + I`. Region lengths are exact (`Count true true` admits no early discharge), so `K` is a feature of the object word and a type can constrain it. A stab-free closure can pin `K` exactly only below a formula-depth threshold (then `K ≤ Tc ≤ c` and slack holds) and otherwise only modulo the object's true period `p₀` (`p₀ ∣ P + 1` by (K1)). Re-realizing `T` with a smaller `K' ≡ K (mod p₀)` above the pinning threshold needs a window of width `p₀` below `n + c + I`; `c ≥ Tc ≥ cascadeBound = 2^|ProdState| * (tIdle + 2)` makes that window available on every object small enough to write down, and idle self-loops only loosen the bound (`I` grows; this is the landed `IdleRunPumpable` discharge). Re-realization also has to adjust later regions consistently — this is "route 4, simultaneous multi-region shortening", which remains unproved. So: no concrete refuting object was found, and the search suggests none is cheap; the general positive statement is equivalent to route 4 at the cell level and is NOT established here.

### Recommendations

- Land `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` from the draft `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean` (namespace `Probe934` to be renamed to a task-number-free name, e.g. `ProbeConsumerShape`; add the module docstring stating what is established and the bound on reach above), wired as a `WIRED` entry `"forward-slack-pin-cascade/consumer-shape-witness"` with its documentation-table row in `scripts/check-evidence-probes.sh` (rows near lines 2470 and 2678). [VERIFIED: PASS -- the gate `check_probe` runs `lake env lean` on the file; the draft was compiled with `lake-build-guard.sh build -- env lean <draft>`, exit 0, no `sorry`, axioms ⊆ `[propext, Classical.choice, Quot.sound]` on all five headlines. The git-tracked half of the gate and the wiring row itself are implementation-phase and were not run.]
- Headline declarations to keep, in this order: `fsw_consumer_shape`, `plateau_next_region` (the slack premise is inhabited on the witness path, so the regime is not met vacuously), `consumer_fires`, `climbC_isLadderPath`, `climbC_not_hasForwardSlack`. [VERIFIED: PASS -- same compile run as above]
- Write the verdict as: "supports the `cellLE_zero_const_of_kappa_eq`-lands event, as existence evidence: the witnessing hypothesis is satisfiable at the consumer shape at a positive amount and the restricted theorem fires there; no general discharge, no refutation, reserved name unclaimed". Do not write that the gate is decided. [No compiled gate applicable]
- Do NOT attempt a richer-formula instance (multi-type cell) inside this task: characterizing a cell with a temporal formula requires the route-4 argument on that instance and is a separate, larger unit. If wanted, file it as a follow-up probe. [No compiled gate applicable]

## Decisions

- Probe direction chosen: positive transcription, after confirming it compiles; the failure direction was analysed and no candidate object survived.
- `c := Tc + B + 2` (not `max`) to keep the collision arithmetic in `omega`.
- The climbing companion uses a register that descends back to `0` across the next region and then period-2 tail, so the whole path is linear arithmetic with `% 2` only (a period-`(C+3)` tail would put a variable modulus outside `omega`).
- No `user_decision` raised: the gate ruling stays reserved to the user and is not requested by this report.

## Risks & Mitigations

- **Over-reading the result.** A singleton-cell instance could be cited as discharging the hypothesis. Mitigation: the bound on reach goes in the module docstring and the table row, in the same "what this does NOT establish" shape task 929 used.
- **Duplicate names.** The draft `open`s `IdleRunOne` rather than re-declaring the object, unlike 929's probe which copies it; either is fine, but copying into the probe namespace would shadow. Keep the `open`.
- **Task-number namespace.** `Probe934` in a file outside `specs/<task>/` is still under `specs/**` (exempt), matching `Probe929`; renaming is optional.
- **Concurrent builds.** Other agents are live on this repo; compile only through `lake-build-guard.sh`.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `IsLadderPath stepOr pendT (climbC C)` | `unfold …; split_ifs <;> simp_all <;> omega` | success | `Rlad Drift Count climbCRaw stepOr pendT` |
| `kappa` collision at `(c,0)` / `(c+(P+1),0)` | `simp only [kappa, …]`; `omega`; `simp`; `unfold clipIdx; split <;> split <;> omega` | success | `Prod.mk.injEq, Fin.mk.injEq` |
| `l ≤ C + 1` at consumer amount | `omega` | success | N/A |
| vacuous downward branch (`c = c + (P+1) + m*(P+1)`) | `nlinarith` | success | `Nat.zero_le (m * (P + 1))` |
| `stab χ ∉ closure ⊥` | `unfold plusSubformulaClosure PlusFormula.subformulas; simp` | success | N/A |

## Context Extension Recommendations

- **Topic**: reading `HasForwardSlack` at the consumer shape
- **Gap**: no context note records that at `c' = c + l` the regime reduces to "next region's countdown ≤ n + c + I", nor that the upward cell inclusion is unconditional
- **Recommendation**: none required for this task; the probe docstring should carry both facts

## Appendix

- Compile commands: `bash .claude/scripts/lake-build-guard.sh build --timeout 500 -- env lean <file>` on two scratch files and on the merged draft; all exit 0.
- Draft probe (compiled): `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean`
- No rate-limited search tools were used; lean-lsp MCP was not needed (evidence tier: compiled probes).
