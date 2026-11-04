# Phase 12.6 Handoff — The Maximum-Certified-Set Finding Under the Widened `RK`

- **Phase**: 12.6, status `[COMPLETED]`. It is a DECISION GATE and both branches were complete
  and reportable; the branch taken is **MOVED**.
- **Immediate next action**: nothing in this plan is enterable. Phases 11.6, 11.7, 12.2 and 13-18
  remain behind Phase 11.9's INCONCLUSIVE verdict on the open depth-`0` core; Phase 11.8 (behind
  the closed 11.2) is enterable and was not entered in this dispatch.

## VERDICT: MOVED

The sufficiency half of the presentation-decision record's Finding 3 is WEAKER under the widened
`RK` than it reads, and the specific conjunct is nameable.

**The derivation.** `Real`'s definition names no relation, no `RK` and no `repsCnt` — only
realizability by an admissible ladder history — so `Real` is UNCHANGED by the widening. `Dmax` is
literally the union of `certAdmK`-certified sets (`dmax_maximal`: every certified set lies inside
it), and widening `repsCnt` enlarges `RK`, hence `relK`, hence WEAKENS `certBiInfK`, `certFwdK`
and `certBwdK`, each of which is an existential over `relK`-related members. So strictly more sets
are certified, `Dmax` can only grow, and `Dmax ⊆ Real` is a strictly harder statement after the
widening than before.

**The conjunct that does not bound the growth.** `certStabK`'s right-hand side is
`∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1.val`, whose quantifier domain is `R`
ITSELF; `certBoxK`'s is `∀ y ∈ R, argOf ψ ∈ y.2.1.val`. Neither names `cellAt`, `tpOf`, `Rlad` or
any history — `CounterQuotient.lean`'s own "No ladder consequence" bullet records that nothing in
that module relates `certAdmK` or `Dmax` to the model — so neither can force `R`'s fibre at a
`(q, κ)` into `Real`'s fibre there. The two conditions constrain which TYPES a candidate may
carry at a given `(q, κ)`; they never constrain which class pairs are related, which is exactly
where the widening acts.

**What does force the inclusion, and why the widening moves it.** The recorded sufficiency
argument's `⟸` direction is "the induction hypothesis on a chain through each `R`-fibre member".
A chain is admitted by `certLocK` together with `relK`, and `relK`'s counter conjunct is what
grew; so the lift that step consumes — the counter-lift lemma's completeness half — now has a
WEAKER hypothesis and is a STRICTLY STRONGER statement. That lift is the open problem.

**A discrepancy found while re-reading, recorded rather than resolved in either direction.** The
phase's own body paraphrases the finding as "every certified `R` lies inside `Real`". The
archived record states it with a hypothesis: "every certified `R` **with `Real ⊆ R`** satisfies
`R ⊆ Real`", the `⟹` direction using `Real ⊆ R` and the `⟸` direction the chain step above. The
verdict was derived against the record's own statement.

## What this means for Phase 15 — its INHERITED CONTINGENCY

Named here because this agent's plan-file write authority does not extend to another phase's
prose body. **Phase 15's `dmax_subset_real` task inherits this contingency**: `Dmax ⊆ Real` is
not a corollary of the widening and is not bounded by `certStabK`/`certBoxK`; it rests on the
counter-lift lemma's completeness half over `relK`-chains, whose hypothesis the widening weakened.
`ladderRealized`'s own right-hand side is a statement about the GROWN `Dmax`, so the fibre
equation inherits the same contingency through it.

## Follow-up this round records and does not act on

Named here for the same reason (it belongs under the plan's own
`### Follow-ups this revision records and does not act on`, which is prose this agent does not
edit): **a `/revise` should re-scope Phase 15's `dmax_subset_real` against the MOVED verdict** —
either by narrowing it to the record's own `Real ⊆ R` form, or by naming the strengthened lift as
an explicit gated input rather than carrying it inside a corollary. Nothing was narrowed,
weakened or restated in this phase to reach the opposite verdict.

## Deviation

**Three generated inventory blocks were refreshed, against the phase's explicit prohibition on
amending `FormalSystem/Metalogic/Decidability/RaySummary/README.md`.** Reason: the docstring edit
grew `LadderRealize.lean` from 576 to 613 lines, which made the machine-owned blocks stale and
turned `check-module-invariants.sh`'s INV check RED — a NEW failing gate beyond the single
pre-existing `C16` finding. The refresh's whole diff is three line-count numerals inside
`<!-- BEGIN GENERATED -->` markers (`LadderRealize.lean` 576 → 613, the `Decidability/` comment
total, and the repository live-comment-lines figure); the depth-`0` status paragraph and every
line of prose in the RaySummary README are untouched, so the successor-chain collision the
prohibition exists to avoid does not arise. `check-module-invariants.sh` is absent from this
phase's own verification list, which is how the tension went unnoticed at planning time.

## Verification evidence

- Guarded scoped build of `LadderRealize.lean`: exit 0, 0 warnings. Full guarded `lake build`:
  exit 0, `Build completed successfully (2895 jobs)`, zero `error:`.
- The verdict appears in this phase's checklist annotation and in the module docstring, naming
  the branch AND the derivation AND the specific conjunct.
- **No declaration was added, removed or re-signed**: `git diff` on `LadderRealize.lean` over
  this phase's commit is confined to the module docstring.
- No theorem anywhere claims `certAdmK … (Dmax …)`, or `certStabK` or `certBoxK` of a union of
  certified sets: every grep hit is docstring prose, `dmax_maximal`'s own `R ⊆ Dmax`, or
  `LadderCons`'s pre-existing maximality clause.
- `repsCnt`, `Real`, `Dmax`, `ParamsOk` and every filed statement are unmodified.
- `lean-sorry-census.sh FormalSystem Tests`: exit 0, `sorry_count: 0`. Repository-wide vacuous
  grep: 1, unchanged. `^axiom ` counts: 10 / 2, unchanged.
- `readme-lint.sh`, `typst-sync-check.sh` and `check-task-references.sh --quiet`: each exit 0.
- `check-module-invariants.sh`: INV passes after the refresh; the only `FAIL` is the pre-existing
  `C16` `unusedArguments` finding at `LadderChain.lean:2136`, unchanged in content and count.
