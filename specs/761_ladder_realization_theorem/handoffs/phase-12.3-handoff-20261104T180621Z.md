# Phase 12.3 Handoff — `repsCnt` Widened, `rk_of_count_drift` Landed

- **Phase**: 12.3 (plan `plans/10_rk-bounded-representative-widening.md`), status `[COMPLETED]`
- **Immediate next action**: Phase 12.4 (the frozen-bound probe and the gate's two owed wirings),
  then 12.5, then 12.6. All three are now unblocked: 12.3 was their only open prerequisite.

## What landed

`FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`:

- `repsCnt` widened to `Finset.range (Tc + Tn + 3 * P + 2 * B + 5)` in both factors, still a
  square product of two ranges. Its docstring records the compiled reason in both directions
  (the saturated-gap direction at `P = 0`, the residue-coupling direction) and cites the Phase
  12.4 probe by path and by declaration name. The "a COUNT of candidate pairs" sentence is kept.
- `rk_of_count_drift`, at the signature the phase pinned token-for-token, with NO `ParamsOk`
  binder and no size or regime hypothesis. Proved by construction, not by `decide`.
- Nine supporting declarations: `kappa_eq_of_components`, `clipIdx_sub_sub`,
  `clipIdx_of_add_le`, `clipIdx_of_le_sub`, `mod_sub_cancel`, `add_mod_mod_cancel`,
  `mem_repsCnt`, `exists_nShift` (stage one), `exists_aRep` (stage two).
- `rkStepB`, `RKb`, `RK`, `decidableRK`, `rkStepB_iff` and `rk_iff` re-closed UNCHANGED: none of
  their proofs mentions the bound numerically, as the phase predicted.

`FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean`: the open-sub-question
sentence is retired and replaced by the compiled answer; the adjacent now-false clause ("no
theorem of this library derives an `RK` edge …") is corrected in the same pass. The
independent-reduction counterexample (`c = 100`, `n = 101`, `B = 3`, `Tc = Tn = 1`, `P = 0`) is
kept verbatim.

Wiring: axiom pin in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`; three generated
inventory blocks (RaySummary README, `FormalSystem/Metalogic/README.md`, repository `README.md`);
`typst/generated/status.typ`.

## The construction, as landed (what a successor should read, not re-derive)

Write `L = P + 1`. Stage one takes `Θ = Tc + Tn + B + L` and one COMMON downward shift `k`, a
multiple of `L`, bringing `min n n'` to within `L` of `Θ` while keeping both members at or above
it (or `k = 0` when they already lie below). The drift and the signed gap survive a common shift,
which is why the two counters may not be reduced independently.

Stage two chooses the first coordinate `a` by gap regime:

| regime | choice | bound on `a` |
|---|---|---|
| `n + B + 2 ≤ c` (gap saturated DOWN with margin) | least member of `c`'s residue class at or above `max (Tc + 1) ((n - k) + B + 2)` | `Tc + Tn + 2*B + 3*L + 1` |
| `c + B ≤ n` (gap saturated UP) | `c` itself when `c ≤ Tc`, else least member of `c`'s residue class at or above `Tc + 1` | `Tc + L` |
| otherwise (gap EXACT) | `c - k`, the same common shift | `(n - k) + B + 1` |

Stage three reads the post-step coordinate off the `Count` arm: `0` for a non-pending successor,
`a - 1` pending-to-pending, the reduced next deadline for a pending successor of an idle
position. The `Tc + 1` floor rather than `Tc` is forced by the `a - 1` reading.

**The bound is tight, not slack.** The largest coordinate the construction produces is exactly
`Tc + Tn + 2*B + 3*L + 1 = Tc + Tn + 3*P + 2*B + 4`, which is `M - 1` for
`M = Tc + Tn + 3*P + 2*B + 5` — so the figure the research input recorded (its Appendix A
analytic bound `Tc + Tn + 3P + 2B + 4` for the largest coordinate, and Decision D4's range
`Tc + Tn + 3P + 2B + 5`) is CONFIRMED at implementation, with no discrepancy and no room to
spare. A narrower range would not close the saturated-down regime.

## Deviations, measured facts and gotchas

1. **The phase's cited helper lemmas are not citable from its own target module.**
   `kappa_eq_components`, `eq_or_both_ge_of_min_eq`, `kappa_eq_of_shift` and
   `clipIdx_regime_of_eq` all live in `LadderAgree.lean`, which imports `CounterQuotient.lean`.
   Landed locally under honest names instead (see above), per the phase's own escape clause. The
   two destructors were not needed at all: this proof must PROVE class equalities, not read them,
   so what was wanted was the CONSTRUCTOR direction, which did not exist and is now
   `kappa_eq_of_components`.
2. **Heartbeats.** `rk_of_count_drift` carries `set_option maxHeartbeats 400000 in` with the
   style linter's mandated reason comment. Two refactors were needed first and should NOT be
   undone: the shift is carried as an opaque `k` with `(P + 1) ∣ k` rather than as `s * (P + 1)`
   (a variable-variable product is an atom to `omega` and makes every downstream goal
   non-linear), and the `n`-side facts are established BEFORE the `exists_aRep` `obtain` so the
   a-side bundle is not in scope for them.
3. **Two mechanical repairs** a successor touching this proof will hit again: `Finset` product
   membership must be an explicit term (`Finset.mem_product.mpr ⟨Finset.mem_range.mpr …, …⟩`)
   after `unfold repsCnt` — a `simp` there times out; and the `py = false` `Count` arm's first
   conjunct normalises to `True`, so it closes with `trivial`, not `rfl`.
4. **Scope measured at close**: `CounterQuotient.lean` 758 → 1013 lines; `LadderRealize.lean`
   371 → 375. Both well under the package-wide 1500, so no length remedy is in prospect. Seven
   files touched, two more than the phase's `Files to modify` list, both machine-owned generated
   blocks (`FormalSystem/Metalogic/README.md`, repository `README.md`).
5. **Namespace collision to avoid in Phase 12.4**: the plan directs that probe to namespace
   `Probe761R`, which `ladder-unconstrained-parameter-refutation.lean` already uses (the
   fourteenth wired probe, named as `Probe761R` in `CounterQuotient.lean`'s own module
   docstring). `repsCnt`'s new docstring and the axiom test both cite the Phase 12.4 probe under
   `Probe761W` instead, with declaration names `repsCntPre`, `rkStepBPre`, `RKbPre`, `RKPre`,
   `witnessA_not_RKPre`/`witnessB_not_RKPre`/`witnessC_not_RKPre` and
   `witnessA_RK`/`witnessB_RK`/`witnessC_RK`. Phase 12.4 must use exactly those names or the
   citations go stale.

## Verification evidence

- Full guarded `lake build`: exit 0, `Build completed successfully (2895 jobs)`, zero `error:`
  over both captured streams; `.olean` newer than source for every module this phase touched.
- Scoped guarded builds of `CounterQuotient`, `LadderAgree`, `LadderRealize`, `LadderChain` and
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: each exit 0, zero warnings.
- Signature fidelity: `diff` of the extracted signature against the phase's recorded statement
  is empty (the recorded `:= sorry` terminator aside).
- `#print axioms` on `rk_of_count_drift`, `rk_iff`, `rkStepB_iff`, `RKb`, `decidableRK` and all
  nine new helpers: standard profile, no `sorryAx`, no custom axiom, no `native_decide`. The
  axiom test pin for `rk_of_count_drift` passes under `#guard_msgs`.
- `lean_minimal_hypotheses` on `rk_of_count_drift`: all five binders `load-bearing`, `hc` and
  `hd` among them, no redundant binder. (`hc`'s break surfaced as a heartbeat timeout rather than
  an unknown-identifier error, because the tool's mutated copy does not carry the
  `set_option`; the verdict is still that the proof does not close without it.)
- Parameter layer UNMODIFIED: `git diff` on `CounterQuotient.lean` touches `ParamsOk`,
  `paramsOkK1`-`paramsOkK4`, `Tcof`, `Tnof`, `Pof`, `Bof`, `paramsOk_params` and
  `not_paramsOk_allZero` only inside the new docstring's prose; no code line changes and no fifth
  parameter source exists.
- No landed theorem decides `RK` or `relK` at a concrete tuple: the single `decide` occurrence
  matching `RK` is `RKb`'s own definitional body, not a proof.
- `LadderAgree.lean` unmodified; its certificate-freedom grep (the Phase 11.3 form extended with
  `prodPre_periodic`, `prodPreStep`, `cohIdle`, `satThreshold`, `satPeriod`) returns 0; imports
  unchanged at `AnchorLayer` and `CounterQuotient`.
- `lean-sorry-census.sh FormalSystem Tests`: exit 0, `sorry_count: 0`. Module-scoped vacuous grep
  over `CounterQuotient.lean`: 0. Repository-wide vacuous grep: 1, unchanged. `^axiom ` counts:
  10 / 2, unchanged.
- `typst-sync-check.sh`, `readme-lint.sh`, `check-evidence-probes.sh` (PASS, 47 wired — the
  authoring baseline, unchanged since this phase wires nothing) and
  `check-task-references.sh --quiet`: each exit 0.
- `check-module-invariants.sh`: every group passes except the single pre-existing `C16`
  `unusedArguments` finding at `LadderChain.lean:2136`
  (`mem_cellAt_of_shift_of_hasForwardSlack`, argument 23) — "Found 1 error", unchanged in content
  and count, and naming none of this phase's declarations.
