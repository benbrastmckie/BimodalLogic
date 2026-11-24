# Research Report: Task #991

**Task**: 991 - Depth-0 gate verdict: `cellLE_zero_const_of_kappa_eq` as a theorem, or `CellLEZeroConstOfKappaEq` refuted under `ParamsOk`
**Started**: 2026-11-24T00:00:00Z
**Completed**: 2026-11-24T00:00:00Z
**Effort**: ~3 hours (research dispatch; includes four compiled measurements)
**Dependencies**: None
**Sources/Inputs**:
- Codebase read directly: `FormalSystem/Metalogic/Decidability/RaySummary/{LadderAgree,LadderCell,LadderChain,LadderRealize,LadderWindow,LadderStepFrag,LadderIdle,CounterQuotient,RunLayer,LadderModel,AnchorLayer}.lean`
- Wired evidence probes read directly: `specs/evidence/seam-gluing-ray-product/{ladder-cell-agreement-refutation,ladder-step-fragment-gap-depth}.lean`, `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`
- Prior records: `specs/archive/934_depth_zero_reachability_probe/summaries/01_consumer-shape-reachability-probe-summary.md`, `specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md`, `specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md` (section `What would lift the depth-0 gate`)
- lean-lsp MCP: registered and reachable; evidence of record here is compiled probes (`lake env lean` through `lake-build-guard.sh`), not LSP lookups
**Artifacts**:
- `specs/991_depth_zero_gate_verdict/reports/01_depth-zero-gate-verdict.md` (this report)
- `specs/991_depth_zero_gate_verdict/probe-draft/ordinary-window-regime.lean` (compiled, exit 0, six `#print axioms` lines, no `sorryAx`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **VERDICT: neither lifting event is deliverable, and the recorded crux is MIS-NARROWED.** The
  gate does not turn on whether `ForwardSlackWitnessed` is satisfiable at a positive amount. That
  question is one of **four** independent deficits between the five landed depth-`0` schemas and
  the reserved statement, and settling it affirmatively — in full generality, not just at the
  consumer shape the archived probe reached — would still leave the gate unlifted.
- **The refutation direction has NO candidate at depth `0`, for a structural reason now measured.**
  All four compiled cell-separating families in the tree (`thetaC`, `sigC b`, `mixC a k`,
  `dblC j`) are `diaF`- or `.stab`-rooted, so each carries a `⊡` letter in its subformula closure
  and each falls outside the depth-`0` schema's stab-free hypothesis. Compiled here:
  `diaF_not_stabFree`, `stab_not_stabFree`.
- **The obligation's collision space splits into two `kappa`-SEGREGATED halves, and the landed
  schemas discharge exactly one.** Compiled here: `kappa_ne_of_regime_cross` (no collision crosses
  the boundary between `n + 2 ≤ c` and `c' ≤ n' + 1` once `2 ≤ B`), and
  `ordinary_window_collision_nonvacuous` (the other half carries a collision at the periodicity
  fixpoint's own parameters, above both thresholds, with a ladder path through each state, at
  which every landed schema's hypothesis is false).
- **The positive direction has a landed engine and an exactly-identified two-item deficit.**
  `cellAt_const_of_kappa_eq_stepFrag` is the filed agreement's shape, proved for every finite
  object, on the **step fragment**. Its bridge `Zrel_of_kappa_eq` consumes `2 * dFwd φ + 2 ≤ B`
  where `paramsOkK4` supplies only `2 * dFwd φ + 1 ≤ B` — a one-token deficit that bites at `Bof`
  itself (compiled here: `paramsOkK4_one_short_of_Zrel_forward_arm`) — plus two threshold
  inequalities the step-fragment module's own docstring records as owed.
- **Recommended route**: do NOT re-enter forward slack. Enter the step-fragment bridge instead —
  repair `(K4)`'s forward conjunct, discharge the two owed thresholds, and land the depth-`0`
  schema on `StepFrag ∩ stab-free`. That is a genuinely enterable, bounded piece of the gate. The
  residue after it — stab-free formulas carrying an **unbounded** `U`/`S` jump — is the actual open
  core, and it is where the gate should be re-sited.

## Context & Scope

`specs/ROADMAP.md` Stage 0 carries "Decide who owns the depth-`0` gate" as its one unchecked
blocking item; `plans/13_depth-zero-gate-rest-state.md` records that the ladder realization theorem
has ten `[NOT STARTED]` phases and one `[BLOCKED]` phase sitting behind it with zero enterable
phases, and that the gate lifts on exactly one of two events:

1. `cellLE_zero_const_of_kappa_eq` lands as a `sorryAx`-free theorem, discharging the schema
   `CellLEZeroConstOfKappaEq` (`LadderAgree.lean:3346`); or
2. `CellLEZeroConstOfKappaEq` is refuted under `ParamsOk`.

The dispatch narrows the crux to: whether a `ForwardSlackWitnessed` hypothesis at a POSITIVE amount
is satisfiable at any state the depth-`0` induction reaches, in its existential-over-paths form.
The per-path form is already refuted (`ClimbWitness.hasForwardSlack_refuted_unconditional`) and was
not re-attempted. The archived consumer-shape probe
(`specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`) was read in full and its
results are taken as given, not re-derived: `fsw_consumer_shape` establishes satisfiability at the
shape the five schemas use, at a positive amount, on `stepOr` at `φ = ⊥`; `climbC_isLadderPath`
with `climbC_not_hasForwardSlack` establish that the existential over paths is doing real work; and
the probe disclaims deciding the gate.

This research therefore did two things the prior work did not: it **measured the distance from the
named crux to the gate**, and it **swept the tree for a depth-`0` refutation candidate**.

## Findings

### Codebase Patterns

**F1. The reserved statement, read exactly.** `CellLEZeroConstOfKappaEq`
(`LadderAgree.lean:3346-3360`) assumes `ParamsOk` and a stab-free closure
(`∀ χ, PlusFormula.stab χ ∉ plusSubformulaClosure φ`), and asserts cell equality at every
`kappa`-collision between two admissible counter pairs at **one** object state, at every `z`. Its
free variables are `c n c' n'` with **no** regime, threshold, displacement-shape, or room
hypothesis of any kind.

**F2. All five landed schemas carry four added-hypothesis families, not one.** Read directly from
`LadderCell.lean`: `CellLEZeroConstOfKappaEqForwardSlack` (`:1502`), `…CommonShift…` (`:1602`),
`…Monotone…` (`:1736`), `…Antitone…` (`:1878`), and
`cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` (`:1971`). Every one of them adds:

| Family | Content | Reaches the reserved statement? |
|---|---|---|
| (a) displacement shape | equal register / common shift / `MonotoneCollisionDisplacement` / `AntitoneCollisionDisplacement` | YES — `kappa_collision_monotone_or_antitone` makes monotone ∪ antitone exhaustive over collisions |
| (b) pending-forever gap | `n + 2 ≤ c` **and** `n' + 2 ≤ c'` | NO — see F4 |
| (c) thresholds | `Tc ≤ c` **and** `Tc ≤ c'` | NO |
| (d) forward slack | `ForwardSlackWitnessed … (positive amount)` plus room bounds | NO — the named crux |

Only (a) is exhausted. The dispatch's crux is (d); (b) and (c) are independent of it and neither is
addressed by any amount of progress on it.

**F3. The in-source record already names three surviving restrictions, and the crux is one of
them.** `forwardSlackWitnessed_iff_next_region_cnt_le`'s docstring (`LadderCell.lean:1021-1045`)
states, under the heading "What this does NOT buy, and must not be read as", that even with the
witnessing condition restated as a checkable region-length bound, three restrictions "survive
untouched": the pending-forever gap, the ordinary window regime `c ≤ n + 1`, and the room bounds.
That is the library telling a reader, in its own voice, that the crux the roadmap records is not the
gate.

**F4. The two counter regimes are `kappa`-SEGREGATED — so (b) costs exactly half the collision
space.** Compiled here as `kappa_ne_of_regime_cross`: once `2 ≤ B` (which `paramsOkK4` always
gives), a collision cannot have `n + 2 ≤ c` on one side and `c' ≤ n' + 1` on the other. The gap
coordinate `clipIdx B c n` reads `≤ B - 2` on the first and `≥ B - 1` on the second. Consequences:

- The pending-forever hypothesis is not a corner-case restriction but a clean partition: the five
  schemas discharge the `n + 2 ≤ c` half and say nothing whatsoever about the `c ≤ n + 1` half.
- The two halves cannot be reduced to one another by any collision, so no amount of work inside the
  pending-forever half reaches the other.

**F5. The ordinary half is populated, and no landed schema's hypothesis holds there.** Compiled
here as `ordinary_window_collision_nonvacuous`: at `Tcof/Tnof/Pof/Bof` for `stepOr`/`pendT`/`labB`
at `φ = ⊥` (so `ParamsOk` by `paramsOk_params`), the counter pairs `(c, n) = (Tc + Tn, Tc + Tn)` and
`(c', n') = (c + (P+1), n + (P+1))` collide, with `c ≠ c'`, both pairs above `Tc` and above `Tn`,
both in the ordinary regime `c ≤ n + 1`, and `n + 2 ≤ c` FALSE at both. A ladder path through each
state is exhibited (`regN`, a new fixture: countdown and register descend together to `0`, then
length-`1` regions forever), so the collision is non-vacuous on the model side too.

**F6. The ordinary half is NOT wholly unaddressed — the in-source claim in F3 is stale in one
direction.** `cellAt_subset_of_window_raise` (`LadderWindow.lean:1690`) is a landed cell inclusion
carrying `hroom : c + m * (P + 1) ≤ n` and `Tc ≤ c` and **no** pending-forever gap; it addresses
the ordinary regime in the UPWARD countdown direction, under a different witnessing family
`WindowIdleRunWitnessed`. What is genuinely absent is (i) the DOWNWARD direction in that regime —
no `…window_raise_rev` exists anywhere in the tree — and (ii) any coverage of collisions in the
ordinary regime that are not register-held (the collision in F5 is a common shift, for which
`hroom` fails at the lower pair because `c = n`). This correction is recorded as an issue, not
silently fixed.

**F7. The refutation direction has no depth-`0` candidate, and the obstruction is the `⊡`-dual.**
Every compiled cell-separating family in the tree reads the gap through `diaF`, which is
`PlusFormula.neg (.stab (PlusFormula.neg ·))` — the `⊡`-dual, **not** the modal diamond:

| Family | Definition site | Shape | Depths | Separates |
|---|---|---|---|---|
| `thetaC` | agreement-refutation probe `:2029` | `.stab (nxtF (.stab (neg pastIdleC)))` | `(1, 1)` | gap `-3` from `-(P+4)` at clip `3` |
| `sigC b` | step-fragment probe `:924` | `diaF (nxtN b (diaF (.snce .bot (neg (.atom pC)))))` | `(1, b)` | needs clip `2b + 2` |
| `mixC a k` | agreement-refutation probe `:2508` | `diaF (backC a (diaF (readC k)))` | `(a, k+2)` | gap `2a+k` from `≥ 2a+k+1` |
| `dblC j` | agreement-refutation probe `:2928` | `diaF (.untl (.atom pC) (andF (neg (.atom pC)) (lvlC j)))` | `(j, 3)` | gap `2^(j+1)-1` from one modulus above |

`plusSubformulaClosure φ = (PlusFormula.subformulas φ).toFinset`
(`FormalSystem/PlusLanguage/Subformulas.lean:187`) adds nothing, so a `diaF`- or `.stab`-rooted
formula always has a `stab` letter in its closure. Compiled here: `diaF_not_stabFree`,
`stab_not_stabFree`. **None of the four families bears on `CellLEZeroConstOfKappaEq`.**

This also explains why `exists_kappa_collision_cellAt_ne_at_K4_clip`
(`LadderRealize.lean:2135`) — a real, landed refutation of the agreement at `(K4)`'s own clip `Bof`
— does not touch the gate: its separating formula is `thetaC`, which carries `⊡`. The same holds
for the strongest compiled family, `dblC j`, whose `gap_clip_below_exponential_refuted` defeats
EVERY clip below `2^(j+1)` at every threshold pair and modulus, and would otherwise be an immediate
refutation of the depth-`0` schema at `Bof` (which is linear in the depths). It is blocked solely by
`diaF`. This was checked explicitly and is the single most load-bearing negative result here.

**F8. The positive direction's engine is landed, and its deficit is two items long.**
`cellAt_const_of_kappa_eq_stepFrag` (step-fragment probe `:754`) is the filed agreement's exact
shape — `kappa`-collision in, cell equality out — proved for **every** finite object and every
`StepFrag` formula (`⊡` and `□` unrestricted; `untl`/`snce` admitted only at guard `⊥`, i.e. `X` and
its mirror). Its bridge from the counter class is `Zrel_of_kappa_eq` (`:731`), which consumes four
numeric hypotheses:

| Hypothesis of `Zrel_of_kappa_eq` | What `ParamsOk` supplies | Status |
|---|---|---|
| `2 * dBack φ ≤ B` | `paramsOkK4`: `2 * dBack φ + 1 ≤ B` | SATISFIED, with one to spare |
| `2 * dFwd φ + 2 ≤ B` | `paramsOkK4`: `2 * dFwd φ + 1 ≤ B` | **ONE SHORT** |
| `2 * (dBack φ + dFwd φ) ≤ Tc` | nothing | OWED |
| `2 * (dBack φ + dFwd φ) ≤ Tn` | nothing | OWED |

The forward deficit is real at the fixpoint's own output: compiled here as
`paramsOkK4_one_short_of_Zrel_forward_arm` — at `xp := X p` (`dBack = 0`, `dFwd = 1`),
`paramsOkK4 xp 3` holds, `Bof stepOr pendT labB xp = 3`, and `2 * dFwd xp + 2 = 4 > 3`. The two
owed thresholds are recorded as owed by `LadderStepFrag.lean`'s own module docstring, point 3:
"That they lie below `Tcof` and `Tnof` is plausible and is compiled nowhere."

The asymmetry is not an accident of either side: `LadderStepFrag.lean`'s docstring point 2 derives
`G⁺ = 2a`, `G⁻ = 2b + 2` as the **solution** of the one-step closure conditions, and says in terms
that `paramsOkK4`'s clip "does not carry" that asymmetry. `(K4)` is the side that is wrong by one.

**F9. The actual open core, restated.** `StepFrag` excludes the unbounded temporal jump; the
depth-`0` schema excludes `⊡`. The intersection is already within reach (F8); the union is refuted
(F7's families, all outside stab-free). The open residue is exactly:

> stab-free formulas carrying an **unbounded** `U` or `S` jump (guard other than `⊥`).

Every mechanism the gate's history has attacked — forward slack, the pump, the splice, the idle
insertion cascade, the row link — is a mechanism for that residue. `LadderStepFrag.lean` records
that the path forth producing row-linked pairs at a positive budget is OWED, and that the state
relation it would take cannot be `Zrel` at any budgets (`no_rowLinked_path_of_Zrel`, wired probe
`ladder-row-link-residue-obstruction.lean`), so the relation must read a residue of the countdown —
which is `Srel`/`Mrel`, on which the same module records "neither a path forth from it nor a
refutation of one is landed".

### External Resources

No external search was required or performed: every object this verdict rests on is a declaration
or a wired probe in this repository, and the four gaps named above are read off landed signatures.
Mathlib was not consulted — nothing here is a Mathlib-shaped lemma. The literature-extraction
protocol does not apply: the task references no literature source, and `kappa`, `(K4)` and
`ForwardSlackWitnessed` have no literature counterpart (so recorded in `CounterQuotient.lean`'s own
`Paper:` lines).

### Recommendations

- **Do NOT file further work on `ForwardSlackWitnessed` as a gate-lifting route.** It is deficit
  (d) of four (F2), and deficits (b) and (c) partition the collision space independently of it
  (F4, F5). A full, general discharge of the crux as the roadmap records it would leave the gate
  exactly where it is. [VERIFIED: PASS — `kappa_ne_of_regime_cross` and
  `ordinary_window_collision_nonvacuous` compiled via `lake-build-guard.sh build -- env lean`,
  exit 0, `#print axioms` showing no `sorryAx`; the collision they exhibit satisfies `ParamsOk` at
  `paramsOk_params` and falsifies `n + 2 ≤ c` at both pairs, so every landed schema is vacuous
  there]
- **Do NOT file a refutation attempt at depth `0` on the strength of any existing separating
  family.** `thetaC`, `sigC b`, `mixC a k` and `dblC j` are each `diaF`- or `.stab`-rooted and so
  fail the stab-free hypothesis; in particular `dblC j`'s exponential-clip refutation, which would
  otherwise refute the schema at `Bof` immediately, is blocked solely by that. [VERIFIED: PASS —
  `diaF_not_stabFree` and `stab_not_stabFree` compiled in the same run; `diaF`'s definition copied
  verbatim from `ladder-cell-agreement-refutation.lean:2349`, and the four families' rootedness read
  off their definition sites cited in F7]
- **Enter the step-fragment bridge as the next unit of work**: (i) repair `paramsOkK4`'s forward
  conjunct from `2 * dFwd φ + 1 ≤ B` to `2 * dFwd φ + 2 ≤ B`, updating `Bof` to match (every
  consumer of `(K4)` reads only the inequality, and `paramsOk_params` discharges the repaired form
  by the same `max` arms); (ii) discharge `2 * (dBack φ + dFwd φ) ≤ Tcof` and `≤ Tnof`; (iii) land
  the depth-`0` schema restricted to `StepFrag φ`. This is a bounded, enterable route with a landed
  engine, and it converts the gate from "owned by nobody" into "owned, with a named residue".
  [VERIFIED: PASS — `paramsOkK4_one_short_of_Zrel_forward_arm` compiled in the same run, measuring
  the deficit at `Bof` itself (`Bof stepOr pendT labB xp = 3`, requirement `4`); the two owed
  thresholds are quoted from `LadderStepFrag.lean`'s own module docstring point 3 rather than
  asserted]
- **Re-site the gate in `specs/ROADMAP.md` Stage 0 on stab-free formulas carrying an UNBOUNDED
  `U`/`S` jump**, replacing the forward-slack crux wording. The current wording sends every
  dispatch at a question that cannot decide the gate. [No compiled gate applicable — this names an
  edit to a roadmap record, and no compiled predicate decides a roadmap item's wording]
- **Repair the stale clause in `forwardSlackWitnessed_iff_next_region_cnt_le`'s docstring**
  (the "What this does NOT buy" block above `LadderCell.lean:1046`): the ordinary window regime is addressed in the UPWARD direction by
  `cellAt_subset_of_window_raise`; what is unaddressed is the DOWNWARD direction there and the
  non-register-held collisions. [No compiled gate applicable — a docstring's accuracy is decided by
  reading the cited declaration, which F6 does, and by no compiled predicate in the tree]

## Decisions

- **The verdict is reported as a correction to the premise, not as a partial on the named crux.**
  The dispatch asked for one of two events; neither is deliverable, and the reason is not effort
  but shape. Reporting "still open" would have concealed the measurable fact that the recorded crux
  cannot decide the gate.
- **The per-path forward-slack form was not re-attempted**, per the dispatch's instruction; the
  archived consumer-shape results were taken as given and are cited, not re-derived.
- **No refutation of the depth-`0` schema was attempted by constructing a new separating family.**
  The sweep in F7 shows the whole compiled stock is excluded by stab-freeness, and the
  expressiveness reason is structural: a stab-free formula reads the counter pair along a SINGLE
  history (a `□`-rooted subformula's truth at a fixed time does not depend on which world state at
  that time it is evaluated at, so `□` cannot separate two states at one time either), where the
  register's influence is confined to the two landed windows. Constructing a family that beats
  `(K4)`'s factor-2 margin from inside that fragment is the open core, not a research-dispatch task.
- **No file under `FormalSystem/**`, `specs/ROADMAP.md`, or `scripts/check-evidence-probes.sh` was
  edited.** The new probe is a task-local draft; promoting and wiring it is implement-phase work.
- **The schema's own name was not claimed.** Nothing in the draft probe carries
  `cellLE_zero_const_of_kappa_eq`, and no signature in the library was touched.

## Risks & Mitigations

- **Risk**: the `(K4)` repair in the recommended route changes a definition every `ParamsOk`
  consumer reads, and could break a downstream proof that happens to need the exact value `Bof`
  outputs today. **Mitigation**: `clip_thetaC` (`LadderRealize.lean:2091`) is `rfl` against the
  current `Bof`, and `exists_kappa_collision_cellAt_ne_at_K4_clip` is stated at
  `max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)` written out, not at `Bof`; so the repair
  must either keep that theorem's own written clip or restate it. A plan for the route must name
  this collision as a phase, not discover it mid-proof.
- **Risk**: the step-fragment restriction may look like a weakened statement landed under a filed
  name. **Mitigation**: land it under its own name (`cellLE_zero_const_of_kappa_eq_stepFrag` or
  similar), never the reserved one, exactly as the five forward-slack schemas already do; the
  reserved name stays claimed by nothing.
- **Risk**: the two owed threshold inequalities (`2 * (dBack φ + dFwd φ) ≤ Tcof`) may be FALSE
  rather than merely unproved — `Tcof` is a `max` of several arms and nothing obviously dominates a
  depth sum. **Mitigation**: this is the first checkable item of the recommended route and should be
  its first phase, so a negative answer surfaces before any `(K4)` edit is made. It was not
  compiled here.
- **Risk**: the regime segregation (F4) is proved at `2 ≤ B`, which is `paramsOkK4`'s own third
  conjunct; if the recommended `(K4)` repair changed that conjunct the segregation would need
  re-checking. **Mitigation**: the repair touches the forward conjunct only; `2 ≤ B` is untouched.

## Tactic Survey Results

Tactic survey was performed on the four new goals, by direct compilation rather than
`lean_multi_attempt` (the goals are whole theorem statements in a file with project imports, not
positions inside an existing proof, so a file compile is the cheaper and more faithful probe).

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `kappa_ne_of_regime_cross` (clip separates the two regimes) | `simp only [kappa, Prod.mk.injEq, Fin.mk.injEq]` then `simp only [clipIdx]; split_ifs <;> omega` | success | `omega` handles `min` and `Nat` truncated subtraction directly |
| `regN_isLadderPath` (new fixture is a ladder path) | `unfold Rlad Drift Count regRaw stepOr pendT; split_ifs <;> simp_all <;> omega` | success | same shape as the archived `climbC_isLadderPath`; `% 2` is a numeral modulus, so `omega` closes it |
| `regRaw_adm` (admissibility) | `intro h; unfold regRaw at *; split_ifs at * <;> simp_all [pendT]` | success | needs `open ClimbWitness (pendT)`; without it `pendT` auto-binds as an implicit variable and every goal becomes unprovable |
| `ordinary_window_collision_nonvacuous` (collision + paths) | `set` the four fixpoint parameters, `refine` with `paramsOk_params`, then `simp only [kappa, …]` + `omega` / `simp` / `split_ifs <;> omega` | success | `Nat.add_mul_mod_self_right` was NOT needed — plain `simp` discharges both residue coordinates |
| `diaF_not_stabFree`, `stab_not_stabFree` | `intro h; exact h _ (by simp [plusSubformulaClosure, PlusFormula.subformulas, …])` | success | `plusSubformulaClosure` is literally `subformulas`, so `simp` reduces membership to a syntactic disjunction |
| `paramsOkK4_one_short_of_Zrel_forward_arm` | `refine ⟨⟨?_, ?_, ?_⟩, ?_, ?_⟩` with `rw [dBack_xp]; omega` / `rw [dFwd_xp]` / `simp [Bof, …]` | success | `rw` closes `3 ≤ 3` by its trailing `rfl`; an added `omega` there fails with "No goals to be solved" |

`lean_hammer_premise` and the rate-limited search tools were not used: no goal here needed a
Mathlib lemma, and `lean_local_search` plus direct file reads located every project declaration.

## Context Extension Recommendations

- **Topic**: reading a Lean fixture's "modal diamond" notation
  **Gap**: `diaF ψ := neg (stab (neg ψ))` in this repository's probes is the `⊡`-DUAL, not the
  modal `◇`. A reader (and the archived docstrings) can and did read `dblC j := ◇ (p U …)` as a
  `□`-fragment formula and conclude it is stab-free. That misreading would have produced a false
  refutation of the depth-`0` schema here.
  **Recommendation**: add a short entry to `.claude/context/project/lean4/domain/` (or to
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`'s notation list) recording that `diaF`
  is `⊡`-dual and that any `diaF`-rooted formula fails every stab-free hypothesis in the tree.
- **Topic**: hypothesis-deficit accounting between a landed schema and a reserved statement
  **Gap**: the gate's history shows repeated dispatches treating one added-hypothesis family as
  "the" gap. No context file records the practice of tabulating ALL added families and marking each
  reached/unreached before entering a route.
  **Recommendation**: a short pattern file (e.g.
  `context/project/lean4/patterns/schema-hypothesis-deficit-table.md`) prescribing the F2 table
  shape as the first artifact of any dispatch aimed at discharging a reserved statement.

## Appendix

### Compiled measurements (all in `specs/991_depth_zero_gate_verdict/probe-draft/ordinary-window-regime.lean`)

Invocation: `bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- env lean <probe>`,
exit `0`, no `sorry` and no `native_decide` in the file.

| Declaration | `#print axioms` |
|---|---|
| `kappa_ne_of_regime_cross` | `[propext, Quot.sound]` |
| `regN_isLadderPath` | `[propext, Classical.choice, Quot.sound]` |
| `ordinary_window_collision_nonvacuous` | `[propext, Classical.choice, Quot.sound]` |
| `diaF_not_stabFree` | `[propext, Classical.choice, Quot.sound]` |
| `stab_not_stabFree` | `[propext, Classical.choice, Quot.sound]` |
| `paramsOkK4_one_short_of_Zrel_forward_arm` | `[propext, Classical.choice, Quot.sound]` |

### Declarations read directly (with sites)

- `CellLEZeroConstOfKappaEq` — `LadderAgree.lean:3346`
- `ForwardSlackWitnessed` — `LadderCell.lean:1008`; `forwardSlackWitnessed_iff_next_region_cnt_le`
  and its three-restriction docstring — `LadderCell.lean:1021-1045` (theorem at `:1046`)
- the five depth-`0` schemas — `LadderCell.lean:1502`, `:1602`, `:1736`, `:1878`, `:1971`
- `cellAt_subset_of_window_raise` — `LadderWindow.lean:1690`
- `cellAt_subset_of_register_raise` / `_lower` — `LadderRealize.lean:1067`, `:1200`
- `exists_kappa_collision_cellAt_ne_at_K4_clip` and `thetaC` — `LadderRealize.lean:2135`, `:2029`
  (probe copy)
- `Zrel` — `LadderStepFrag.lean:207`; `StepFrag` — `:775`; `cellAt_subset_of_Zrel` — `:968`
- `Zrel_of_kappa_eq` — step-fragment probe `:731`; `cellAt_const_of_kappa_eq_stepFrag` — `:754`
- `dblC`, `lvlC`, `Kc`, `gap_clip_below_exponential_refuted`, `repaired_clip_refuted` —
  agreement-refutation probe `:2928`, `:2920`, `:2897`, `:3295`, `:3314`
- `paramsOkK4`, `Bof`, `dBack`, `dFwd`, `kappa`, `clipIdx`, `ParamsOk`, `paramsOk_params` —
  `CounterQuotient.lean:920`, `:854`, `:668`, `:683`, `:169`, `:160`, `:929`, `:938`
- `Count`, `Drift`, `Rlad` — `RunLayer.lean:261`, `:254`, `:268`; `Adm`, `LadderState` —
  `LadderModel.lean:159`, `:163`; `cellAt` — `AnchorLayer.lean:132`
- `plusSubformulaClosure` — `FormalSystem/PlusLanguage/Subformulas.lean:187`;
  `PlusFormula.next` — `FormalSystem/PlusLanguage/Formula.lean:176`

### Search queries used

No rate-limited search tool was invoked. Project-local lookups were `grep`/`Read` sweeps over
`FormalSystem/Metalogic/Decidability/RaySummary/` and `specs/evidence/` for: the schema name, every
`cellAt_subset_*` / `mem_cellAt_of_*` / `cellLE_zero_*` declaration, the four separating families,
`dFwd`/`dBack`/`Bof`/`paramsOkK4`, and `diaF`/`andF`/`nxtF`.

### Prior records read

- `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` (in full)
- `specs/archive/934_depth_zero_reachability_probe/summaries/01_consumer-shape-reachability-probe-summary.md`
- `specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md`
- `specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md`, section
  `### What would lift the depth-0 gate`
