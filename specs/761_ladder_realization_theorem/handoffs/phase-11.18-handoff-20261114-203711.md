# Phase 11.18 Handoff — The Parameter Margin

- **Phase**: 11.18, `[COMPLETED]`
- **Plan**: `specs/761_ladder_realization_theorem/plans/15_depth-stratified-threshold-margins.md`
- **Dispatch**: seq 42, session `sess_1794715258_f96bc3`

## Immediate next action

Phase 11.19 — the two unexposed clauses of the iterated splice (interior-copy countdown
`cntAt g' (u + i*l + j) = cntAt g (u + j) + (d - i)*l`, and the register
`nxtAt g' (u + i*l + j) = nxtAt g (u + j)`), exposed on
`exists_iterSpliced_ladderPath_idx_of_pend_past`. It is independent of 11.18 and was always
enterable; together with this phase it is the recorded S-2 obligation's first gate, and BOTH must
land before any depth induction (Phase 11.6) is attempted. Phase 11.20 then depends on both.

## State landed

`(K2)` now carries a third conjunct,
`b * (P + 1) * (D + 1) ≤ Tc` with `b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` and
`D := (plusSubformulaClosure φ).sup stabDepth`. `paramsOkK2` gained a `(P : ℕ)` binder; the
conjunct was added THIRD so no existing projection into `ParamsOk` moved. `Tcof` gained one outer
`max` arm reading `Pof`. `paramsOk_params` is RE-PROVED green at the new `Tcof` with its signature
unchanged token-for-token and no binder added, so the parameter hypothesis stays dischargeable.
`paramsOk_inflate` is restated with an explicit `hroom` premise and `paramsOk_inflate_raise` is
its unconditional sibling. Two room lemmas landed: `budget_mul_spacing_le_Tc` and
`margin_room_at_depth`.

## Key decisions

1. **`stabDepth` relocated.** The pinned conjunct reads `(plusSubformulaClosure φ).sup stabDepth`,
   but `stabDepth` was declared in `LadderAgree.lean`, which IMPORTS `CounterQuotient.lean`. The
   purely syntactic `def stabDepth` was moved DOWN into `CounterQuotient.lean` (same namespace, so
   no axiom pin moved); `StabPinned`, `stabDepth_stab`, `stabDepth_arg_le_of_le_succ`,
   `stabDepth_le_sup` and `stabPinned_of_stabDepth_le` stay in `LadderAgree.lean` behind a pointer
   comment. This is the one file beyond the phase's listed set.
2. **`margin_room_at_depth`'s base is `Tc_0 = 0`, and that is forced.** The conjunct supplies
   `b * (P + 1) * (D + 1)` and no more, so the `D + 1` reserved blocks consume all of it. Phase
   11.20's `Tc_d := Tc_0 + (D - d) * b * (P + 1)` instantiates at `Tc_0 = 0`; its two required
   readings (`Tc_D = Tc_0`, `Tc_0 ≤ Tc_d`) are then immediate. A positive base at the DEEPEST
   level is available only by raising `Tc`.
3. The lemma is stated for every `d : ℕ` with no `d ≤ D` side condition — `D - d` is truncated
   subtraction, so the stated form implies the plan's `d ≤ D` form and carries no redundant
   hypothesis.

## Verification

Full `lake build` 0/0; `lake build BimodalTest` 0/0 with every `#guard_msgs` pin green;
`check-evidence-probes.sh` exit 0 (`all 62 wired probe(s) compile`);
`check-module-invariants.sh`, `typst-sync-check.sh`, `readme-lint.sh`,
`check-task-references.sh --quiet` each exit 0; `sorry_count: 0`; axiom count 14, identical to
`HEAD`; vacuous grep 0 in `CounterQuotient.lean`, 1 repo-wide (baseline).

## Deviations

One, annotated inline on the phase's first checklist item: the `stabDepth` relocation above, which
touches `LadderAgree.lean`, a file outside the phase's listed set. The pinned conjunct itself is
landed token-for-token; no decomposition step was skipped and no Challenge signature changed.

## Carried-figure correction

The phase's verification text cited a re-measured `57 WIRED / 1 WIRED_REPO` figure for
`check-evidence-probes.sh`. The live gate emits no such tokens: it prints a per-probe `PASS`/`SKIP`
table and `PASS all 62 wired probe(s) compile`. Measured live: 62 wired, 1 SKIP, unchanged by this
phase.
