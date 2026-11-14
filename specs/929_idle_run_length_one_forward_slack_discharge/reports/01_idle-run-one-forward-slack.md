# Research Report: Task #929

**Task**: 929 - Discharge the `I = 1` idle-run sub-regime so `ForwardSlackWitnessed` becomes
unconditional
**Started**: 2026-11-13T00:00:00Z
**Completed**: 2026-11-13T00:00:00Z
**Effort**: ~1 dispatch (research, `--hard`)
**Dependencies**: None blocking. Territory-concurrent with task 930 (no declared file scope); no
foreign commit, foreign uncommitted modification, or foreign build was observed during this
dispatch.
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/RaySummary/`), compiled
probes via `lake env lean`, `#print axioms` measurements; no literature source bears on this task
(see **Context & Scope**)
**Artifacts**: - `specs/929_idle_run_length_one_forward_slack_discharge/reports/01_idle-run-one-forward-slack.md`
- `specs/929_idle_run_length_one_forward_slack_discharge/evidence/i-one-ceiling.lean` (compiled,
sorry-free, standard axioms)
- `specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean` — the probe above,
promoted to the tracked evidence collection and wired into `scripts/check-evidence-probes.sh`;
cite this path, not the task-local one, which no longer exists
**Standards**: report-format.md, subagent-return.md, lean4-anti-analysis.md,
lean4-reference-grounding.md, lean4-adversarial-verification.md, lean4-sorry-discipline.md

## Executive Summary

- **The task's stated goal is REFUTED, and the refutation is compiled, not argued.**
  `ForwardSlackWitnessed` cannot be made unconditional in the shape task 924's theorem has
  (a conclusion at EVERY amount `l`). On an object with no idle self-loop every idle run has
  length exactly `1` on every path, and `hasForwardSlack_amount_le`'s ceiling
  `l ≤ n + cntAt g z + I` then binds uniformly over all paths through the state — which is what
  defeats the standing "existential over paths" escape that kept the hypothesis unrefuted until
  now. The compiled statement is `Probe929.forwardSlackWitnessed_refuted_I_one`.
- **This is the repository's first CELL-level refutation of `ForwardSlackWitnessed`.** Every
  landed refutation is path-level (`ClimbWitness.hasForwardSlack_refuted_unconditional`), and
  `LadderChain.lean`'s module docstring explicitly records that the pin-cascade refutation does
  NOT reach the cell level because some other path may witness the same type. The object-level
  forcing used here closes that gap at the `I = 1` regime.
- **The boundary is sharp.** At the same state and at `φ = ⊥`, `ForwardSlackWitnessed` HOLDS at
  every amount `l ≤ 3 = n + c + 1` and fails at `4`
  (`Probe929.forwardSlackWitnessed_holds_below_ceiling`). The ceiling, not some further
  obstruction, is exactly what the `I = 1` regime refuses.
- **The refutation does NOT reach the five depth-`0` consumer schemas**, and this is compiled too
  (`Probe929.ceiling_slack_at_consumer_amount`). Those schemas ask for the hypothesis at amount
  `m · (P + 1)` at the HIGHER state, whose countdown is already `c + m · (P + 1)`; the ceiling is
  then satisfied for free and says nothing. **The frontier therefore moves rather than closing**:
  what survives is the strictly narrower question stated in *Findings → The surviving frontier*.
- **Recommended disposition**: land the refutation and restate the frontier; do NOT attempt an
  `I = 1` discharge at every amount, and do NOT make `certStabK`'s restatement obligation
  permanent on the strength of this refutation alone — it refutes the "every amount" shape, not
  the consumer-relevant instantiation.

## Context & Scope

Task 924 landed `forwardSlackWitnessed_of_cell_idleRunPumpable`
(`FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean:1035`), a cascade-free
CONDITIONAL discharge concluding `ForwardSlackWitnessed` at every amount from the amount-free,
run-local premise `IdleRunPumpable` (`LadderIdle.lean:992`). It names as its entire frontier the
paths whose intervening idle run has length `1`, where no repeat block exists to pump, and left
`certStabK`'s restatement obligation PROVISIONAL on the belief that this case is dischargeable on
the pumpable side.

This dispatch researched that case. Scope boundaries honoured:

- The `(K1)` amendment constraining spanning-block length is PROHIBITED and was not assessed as a
  route.
- The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing in this report or in
  the probe.
- Task 761's Phase 11.6 depth-`0` gate is untouched; nothing here bears on it.
- A refutation is an equally reportable outcome and must be compiled. It is: see **Findings**.

**Literature**: no literature source bears on this task. The construction is internal to this
repository's ladder-frame scheme (`Rlad`, `Drift`, `Count`, `Adm`), which `LadderModel.lean`'s own
`Paper:` annotations record as having no literature counterpart — the nearest corpus object,
HWZ 2000's quasimodel, chooses its run set freely and has no counterpart constructor. Per H3's
graceful-degradation clause: **no literature source identified; first-principles lean4
development.** The 5-column Tier 1 mapping table is therefore replaced by the Tier 3 proof-status
table under **Findings → Compiled inventory**.

## Findings

### Codebase Patterns

**The regime is a bound on ONE number.** `hasForwardSlack_iff_next_region_cnt_le`
(`LadderChain.lean:1600`) makes `HasForwardSlack g z l n` EQUIVALENT to

```
cntAt g (z + cntAt g z + 1 + I) ≤ n + cntAt g z + I - l
```

— a bound on the countdown of the first region start above `z`'s region, where `I` is the length
of the intervening idle run. Both directions are landed and exact.

**Nothing else in the path is free.** Three landed facts jointly pin every quantity in that
inequality once the state at `z` and the object walk are fixed:

1. `cntAt_sub_of_pend` + `not_pend_of_count` (`LadderAgree.lean:716`) force positions `z … z + c`
   pending and `z + c + 1` idle, for `c = cntAt g z`.
2. `cntAt_eq_nxtAt_of_idle_pend` (`LadderAgree.lean`) forces
   `nxtAt g (z + c + I) = cntAt g (z + c + 1 + I)`: the register at the idle position before a
   region start IS that region's countdown.
3. `cntAt_eq_of_pend_eq` (`LadderAgree.lean`) forces the countdown to be a function of the pend
   profile alone.

The practical consequence, which is what makes the route space small: **the register's value at
every position strictly inside a pending region is invisible to both the type and the regime.**
It is observable only at idle→pending transitions, where it equals the next region's countdown.
So lowering intermediate registers buys nothing, and the only way to move the inequality is to
move the WALK.

**The amount ceiling.** `hasForwardSlack_amount_le` (`LadderChain.lean:1628`) extracts from the
above: whenever a genuine next region exists, `HasForwardSlack g z l n` forces
`(l : ℤ) ≤ n + cntAt g z + I`. `paramsOk_inflate`'s docstring (`CounterQuotient.lean`) already
records this at the PATH level ("an unboundedly inflated modulus is exactly what the regime
refuses"). What was not recorded, and is this dispatch's finding, is that the ceiling lifts to
the CELL level whenever `I` is forced uniformly over all paths through the state.

### The compiled refutation

All declarations below are in
`specs/929_idle_run_length_one_forward_slack_discharge/evidence/i-one-ceiling.lean`, namespace
`FormalSystem.Metalogic.Decidability.RaySummary.Probe929`. The object is `Bool` with
`pendT = id` (reused from `ClimbWitness`) and

```lean
def stepOr : Bool → Bool → Bool := fun x y => x || y
```

whose single distinguishing property is `stepOr false false = false`: **no idle self-loop**, hence
no idle cycle. Seriality holds in both directions (`fwdOr`, `bwdOr` are proved, not assumed), so
`ladderFrameAdm` and `ladderModel` are available over it and nothing is vacuous.

| Declaration | Statement | Status |
|---|---|---|
| `stepOr_idle_idle` | `stepOr false false = false` | transcribed |
| `fwdOr` / `bwdOr` | two-sided seriality of `RladAdm stepOr pendT` | transcribed |
| `next_pend_of_idle` | an idle position is followed by a pending one — so every idle run has length exactly `1`, on every path | transcribed |
| `plateau_isLadderPath_stepOr` | `ClimbWitness.plateau C` is a `stepOr` ladder path | transcribed |
| `xState_regime` | `xState = (true, 2, 0)` is realized by a path pending forever into the past, with the gap `nxtAt + 2 ≤ cntAt` | transcribed |
| `not_hasForwardSlack_of_four` | EVERY ladder path through `xState` at `0` fails `HasForwardSlack · 0 4 0` | transcribed |
| **`forwardSlackWitnessed_refuted_I_one`** | **`¬ ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB ⊥ xState 0 4 0`** | **transcribed** |
| `forwardSlackWitnessed_holds_below_ceiling` | the same state carries the hypothesis at every `l ≤ 3`, at `φ = ⊥` | transcribed |
| `not_idleRunPumpable` | `IdleRunPumpable` is false for EVERY path, history and anchor on `stepOr` | transcribed |
| `ceiling_slack_at_consumer_amount` | `m·(P+1) ≤ n + (c + m·(P+1)) + I` for `0 < I` | transcribed |
| `tpOf_bot_eq_empty` | at `φ = ⊥` every closure type is `∅` | transcribed |

**Measured, not assumed**: `lake env lean` on the probe exits `0` with zero `error:` and zero
`warning:`; `grep -c sorry` returns `0`; `#print axioms` on all five headline declarations returns
`[propext, Classical.choice, Quot.sound]` (and `[propext, Quot.sound]` for the pure-arithmetic
one). No `sorryAx`, no non-standard axiom.

**Why the refutation reaches the cell level, where the landed one does not.**
`ForwardSlackWitnessed` is existential over paths, and `LadderChain.lean`'s docstring records
exactly why the pin-cascade refutation stops short: "a saturated path may still realize each of
its types via some OTHER path carrying `HasForwardSlack`". The escape is closed here without any
appeal to types at all: on `stepOr` the ceiling `l ≤ n + c + I` binds with `I = 1` for EVERY path
through `xState`, so no choice of witnessing path can satisfy amount `4`. Cell non-emptiness is
supplied by `ClimbWitness.plateau 2` through `mem_cellAt_ladder_iff`, so the refutation is not a
vacuous-antecedent artefact.

**Consistency with task 924, compiled.** `not_idleRunPumpable` shows `IdleRunPumpable` is
unsatisfiable on this whole object, so `forwardSlackWitnessed_of_cell_idleRunPumpable`'s premise
`hprem` is false here and the two results cannot collide. The `I = 1` frontier is thus exhibited
not as one awkward path but as an entire serial object on which 924's route is structurally
unavailable.

### The route space at `I = 1`, closed

Four routes can move `cntAt g (z + c + 1 + I) ≤ n + c + I - l`. Three are structurally
unavailable precisely when `I = 1` is forced:

1. **Pump the idle run** (924's route). Requires an `(objAt, tpOf)`-repeat block INSIDE the run;
   a length-`1` run has none, and more sharply a repeat block inside an idle run IS an idle cycle
   in the object. Compiled: `not_idleRunPumpable`.
2. **Splice an idle block in from elsewhere.** Same requirement: inserting idle positions at the
   run needs a cycle through the run's own idle state. Not separately compiled; it reduces to
   route 1's requirement by the same argument.
3. **Vacuity — idle forever above** (`hasForwardSlack_of_idle_above`, `LadderChain.lean:1783`).
   An infinite idle walk in a finite object is an idle cycle, so this is available exactly when
   routes 1-2 are. On `stepOr` it is unavailable (`next_pend_of_idle`).
4. **Shorten the next region by deleting a type-repeat block inside it.** Path-level REFUTED by
   the pin-cascade straddle (`no_deleted_ladderPath_of_straddle_break`,
   `specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean:103`), with a deficit of
   exactly `2·l` per deletion. NOT refuted at the cell level. This is the only survivor.

### The surviving frontier

Stated precisely, because the task description's frontier must now be restated:

> At the HIGHER state `(q, c + m·(P + 1), n)` in the pending-forever gap with `Tc ≤ c`, is every
> type the cell realizes also realized by some ladder path whose first region above `z`'s region
> has countdown at most `n + c + I`?

Three facts bound this question and none of them is the ceiling:

- **The ceiling is silent here** (`ceiling_slack_at_consumer_amount`). The consumer's amount is
  `l = m·(P + 1)` and the higher state's countdown is `c + l`, so `l ≤ n + (c + l) + I` always.
- **The target bound is generous.** `N < budget ≤ Tc ≤ c ≤ n + c + I` — so ANY walk whose regions
  above `z` are all shorter than the `(objAt, tpOf)` pigeonhole budget satisfies the regime at
  every amount the consumer asks for. The problem is not the size of the amount; it is realizing
  the same TYPE with a non-saturated walk.
- **The cascade recurrence is the real constraint.** Between consecutive idle positions the
  register must drift from `N_j` to `N_{j+1}` over `N_j + 2` steps, so
  `N_{j+1} ≤ 2·N_j + 2` — which is `(K2)`'s `cascadeBound` recurrence
  `a(k+1) ≤ 2·a(k) + J + 1`, as `LadderChain.lean`'s docstring already records the saturated
  configuration ATTAINING with equality.

**The route that this analysis newly identifies as not-yet-refuted** (route 4 at the cell level):
shorten EVERY region above `z` simultaneously rather than region 2 alone. Under a simultaneous
shortening `N'_j = N_j - a_j` the Drift constraint becomes
`|N'_{j+1} - N'_j| ≤ N'_j + 2`, and the `2·l` deficit that refutes the single-region deletion
CANCELS exactly when the deleted amounts double, `a_{j+1} = 2·a_j`: substituting gives back
`N_{j+1} ≤ 2·N_j + 2`, the original recurrence. The pin-cascade refutation is therefore a
refutation of a one-region deletion, not of the route. What it does NOT settle, and what any
plan on this route must discharge, is: (i) each region `j` must be long enough and carry a
type-repeat block of the required length (available once `N_j` exceeds the budget, by
`exists_typeBlock_of_budget_le_cnt`); (ii) the shortened sequence must remain Drift-feasible at
the junctions where a region is already below the budget and cannot be shortened further; and
(iii) each deletion must preserve the type at `z`.

**A counter-consideration recorded rather than suppressed.** A refutation of the consumer-relevant
instantiation would need a formula `φ` pinning the next region's countdown exactly. Pinning a
countdown of size `N` requires nesting depth `~N` (via `⊥ untl ψ` as a next-operator), which drives
`Tc`'s threshold — a function of `|plusSubformulaClosure φ|` through `tShort Q φ =
Fintype.card (ProdState Q φ)` — above `c`, violating the schemas' own `Tc ≤ c`. That tension is
evidence AGAINST a cheap consumer-relevant refutation and in favour of route 4; it is not a
proof, and it is tagged accordingly in **Risks**.

### External Resources

None. No Mathlib declaration is load-bearing for this result; every lemma consumed is local
(`LadderChain.lean`, `LadderAgree.lean`, `LadderCell.lean`, `LadderIdle.lean`). No
`lean_leansearch` / `lean_loogle` / `lean_leanfinder` query was needed, and none is cited.
`lean_local_search` was not used: the LSP-backed path was replaced by `grep` plus direct
`lake env lean` compilation, which is a STRONGER evidence tier than an index lookup, not a
degraded one — every name cited below was either read from source or exercised by a compiled
proof.

### Recommendations

- **Land the probe's five headline declarations in
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean`, in a new `section IOne`
  beside the existing `section Pumpable`.** `LadderIdle` already imports `LadderCell` (and
  transitively `LadderChain`, hence `ClimbWitness`), it is where 924's route lives, and at 1080
  lines plus ~200 it stays under the default `linter.style.longFile 1500` with no new baseline.
  [VERIFIED: PASS — `timeout 900 lake env lean specs/929_.../evidence/i-one-ceiling.lean` exits
  `0`, zero `error:`, zero `warning:`, `grep -c sorry` = `0`, `#print axioms` on all five
  declarations = `[propext, Classical.choice, Quot.sound]`]
- **State the refutation at exactly its reach and no further**: it refutes `ForwardSlackWitnessed`
  at EVERY amount (the shape 924's theorem has), and does NOT reach the five depth-`0` schemas'
  instantiation at amount `m·(P + 1)` at the higher state.
  [VERIFIED: PASS — `ceiling_slack_at_consumer_amount` compiles the arithmetic that the ceiling
  is slack at the consumer's instantiation; same `lake env lean` run]
- **Keep `certStabK`'s restatement obligation PROVISIONAL, not permanent.** The compiled result
  refutes the "every amount" shape; the consumer-relevant instantiation survives via route 4. A
  plan that flips the obligation to permanent would overstate what is compiled.
  [No compiled gate applicable — this is a disposition about documentation wording, naming no
  landable Lean artifact]
- **Do NOT open an `I = 1` discharge phase at every amount.** It is refuted. Direct any follow-on
  construction work at route 4's cell-level form (simultaneous multi-region shortening), whose
  three obligations are enumerated under *The surviving frontier*.
  [No compiled gate applicable — a scoping recommendation, no artifact named]
- **If the probe is wired into CI**, add it to `scripts/check-evidence-probes.sh`'s `WIRED` table
  (relocating it under `specs/evidence/`, which is where the script's own comment says a probe
  belongs) and move the wired total `55 → 56`. Wiring is a plan-time decision, not a research
  one; the alternative — leaving it as a task-local evidence file — is also consistent with the
  script's contract.
  [No compiled gate applicable — the registry edit is not an artifact a compiled gate accepts or
  rejects; the probe's own compilation is already verified above]

## Decisions

- **Refutation over discharge.** The dispatch's own description admits a refutation as an equally
  reportable outcome provided it is compiled. It is compiled; no discharge attempt was made at the
  refuted shape.
- **`stepOr` over a bespoke multi-state object.** An earlier candidate — a forced-length pending
  chain `a₀ → … → a_{L-1} → i`, which would have forced the next region's countdown outright and
  refuted the consumer instantiation too — was REJECTED after checking seriality: `(a₀, 0, n)` is
  an admissible state with no `RladAdm`-successor, so `fwd` fails and `ladderFrameAdm` is
  unavailable over it. This is `no_fwd`'s hazard (`LadderModel.lean:124`) in concrete form, and it
  is recorded because it is the reason a cheap consumer-relevant refutation is NOT available:
  seriality forces every pending state to admit an idle successor, which returns the next region's
  length to the register's free choice.
- **`ClimbWitness.plateau` reused rather than re-derived.** `HasForwardSlack` mentions no `step`,
  so `ClimbWitness.hasForwardSlack_plateau` transfers to `stepOr` verbatim; only
  `IsLadderPath stepOr` had to be reproved. This is what made the sharpness result cheap.
- **`φ = ⊥` for the sharpness half only.** The refutation half is `φ`-independent (it never reads
  the type); the holds-below-ceiling half needs a `φ` whose cell is a singleton, and `⊥` is the
  cheapest. The asymmetry is deliberate and is stated in the probe's docstrings.

## Risks & Mitigations

- **Risk: the refutation is read as closing the whole `ForwardSlackWitnessed` programme.** It does
  not — the consumer instantiation is untouched. *Mitigation*: `ceiling_slack_at_consumer_amount`
  is compiled alongside precisely so the limit is a measured fact rather than a caveat in prose,
  and every statement of the result in the library should cite it.
- **Risk: the counter-consideration against a consumer-relevant refutation (`Tc` outruns `c` once
  `φ` pins the countdown) is argued, not compiled.** It is the one claim in this report that does
  not clear the H4 verification bar. *Mitigation*: it is tagged UNVERIFIED here and must not be
  relied on as settled; confirming or refuting it is a candidate scope item for a follow-on task,
  not a premise of any recommendation above.
- **Risk: route 4's cancellation arithmetic is verified only as arithmetic.** The substitution
  `a_{j+1} = 2·a_j` recovering `N_{j+1} ≤ 2·N_j + 2` is elementary and correct, but Drift
  feasibility at the junctions and type preservation under simultaneous deletion are NOT
  established. *Mitigation*: all three obligations are enumerated explicitly so a plan cannot
  silently assume them.
- **Risk: deployed `.claude/` tree is stale for `core`, `lean`, `sapience`.** Recorded, not acted
  on; no file under `.claude/**` was written by this dispatch and no stale-sourced command was
  relied upon (every build invocation used `lake env lean` directly on a probe file).

## Tactic Survey Results

Measured during probe construction, not hypothesised. The goals are the probe's own.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `RladAdm` seriality cases (`fwdOr`/`bwdOr`) | `simp [Count, pendT]` | success | `Count` unfolded; `Drift` discharged by `Or.inl rfl` |
| `Adm pend q` side conditions with a free `n` | `decide` | **fail** | "Expected type must not contain free variables" — `decide` is unusable under a free variable; replaced |
| same | `simp [pendT]` | success | the replacement actually used |
| `IsLadderPath stepOr pendT (plateau C)` | `split_ifs <;> simp_all <;> omega` | success | after `unfold Rlad Drift Count plateauRaw stepOr pendT`; the `ClimbWitness` precedent transfers verbatim |
| `Int.toNat 2 = 2` | `norm_num` | **fail** | left `⊢ Int.toNat 2 = 2` unsolved |
| same | `decide` | success | closed-term goal, no free variables |
| `(4 : ℤ) ≤ 0 + 2 + 1` contradiction | `norm_num` | success | after `rw [hc]` |
| cast juggling `↑(1 : ℕ)` vs `(1 : ℤ)` | `rw [show … by push_cast; ring]` | **fail** | pattern already normalised by `omega`/`simpa`; `simp only [Nat.cast_one]` succeeded instead |
| consumer-ceiling arithmetic | `push_cast; omega` | success | no premises |

The usable rule extracted: **under a free variable prefer `simp [pendT]` to `decide`**, and
**after `simpa`/`omega` have normalised casts, prefer `simp only [Nat.cast_one]` to a `show … by
push_cast; ring` rewrite** — the latter fails to find its pattern because the normalisation
already fired.

## Context Extension Recommendations

- **Topic**: the ceiling-versus-cell distinction for existential-over-paths hypotheses.
- **Gap**: `context/project/lean4/` has no note on the pattern this dispatch turned on — that a
  path-level refutation lifts to a cell-level one exactly when the quantity it bounds is forced by
  the OBJECT rather than by the path, and that forcing is cheapest to obtain by removing a
  transition (`step false false = false`) rather than by adding structure.
- **Recommendation**: add
  `context/project/lean4/patterns/object-level-forcing-for-cell-refutations.md`, naming the
  seriality trap (`no_fwd`) as the standing constraint on which forcings are admissible — the
  trap that killed the forced-length-chain candidate recorded under **Decisions**.

## Appendix

**Searches and reads of record** (no rate-limited search tool was invoked):

- `grep` sweeps for `HasForwardSlack` / `ForwardSlackWitnessed` / `IdleRunPumpable` declaration
  sites across `FormalSystem/`.
- Source reads: `LadderChain.lean:80-160` (module disposition), `:1440-1810` (the `Slack`
  section), `:1850-1995` (`ClimbWitness`); `LadderCell.lean:940-1120`, `:1790-1830`;
  `LadderIdle.lean:880-1080`; `LadderAgree.lean:560-790`, `:2620-2700`;
  `LadderModel.lean:120-231`; `RunLayer.lean:254-274`; `CounterQuotient.lean:845-900`;
  `LadderPump.lean:1845-1905`; `AnchorLayer.lean:95-157`.
- Prior-task record: `specs/archive/924_forward_slack_witnessed_frontier_disposition/summaries/01_forward-slack-frontier-disposition-summary.md`.
- Compilation: `timeout 900 env LEAN_NUM_THREADS=4 lake env lean specs/929_idle_run_length_one_forward_slack_discharge/evidence/i-one-ceiling.lean` — exit `0`.

**Reserved-name check**: `cellLE_zero_const_of_kappa_eq` is not declared anywhere in the probe and
is not claimed by this report on any branch.
