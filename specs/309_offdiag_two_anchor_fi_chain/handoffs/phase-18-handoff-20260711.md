# Task 309 Phase 18 Handoff — Trichotomy Assembly Skeleton (18a) LANDED; 18b Residual

- **Date**: 2026-07-11
- **Session**: sess_01LM2qEbhaxsXDRMemmWWCcs_309
- **Status**: Phase 18 [PARTIAL] — 18a landed green + committed; 18b (hook discharge) is the residual
- **Commits**: 53a3cd2cd (skeleton, green + axiom-clean), acd45ff86 (plan marker)

## What landed (green, committed)

`kampPrior_case1_trichotomy_assemble` (KampPrior.lean, "Site lemma 4", appended before
`end`). The plan's H8-split "18a" `or_congr` skeleton: given three arm formulas
`A_past`/`A_diag`/`A_future` whose `temporal_truth M atomMap t` realizes the three disjuncts of
`kampPrior_site_trichotomy`, their right-nested `Formula.or` realizes the full `| 1 =>` site RHS
`∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`.

Proof: `rw [temporal_truth_or, temporal_truth_or, h_past, h_diag, h_future]` then
`exact (kampPrior_site_trichotomy M k sub_nf t).symm`.

- Axioms: exactly `{propext, Classical.choice, Quot.sound}` (lean_verify).
- Scoped build green (1021 jobs); full `lake build` green (1724 jobs).
- `:361`/`:364` untouched; KampPrior code sorry count unchanged at 2.

## Immediate next action (18b — the residual, then Phase 19)

To narrow `:361`, close the k=0 AND k=1 arms of the `| 1 =>` case by instantiating the skeleton
with concrete arm formulas. Supplying those reduces (via `nf_char2_past_formula_correct`
Base:1230 / `A_diag_correct` Base:758 / `nf_char2_future_formula_correct` Base:1430) to
discharging the depth-`k` quant-endpoint hooks:

```
h_quant : ∀ x (ordered), ((quantEnd.eval_at x ∧ seg.holds …) ↔
  ∀ qnf : NormalForm sig k 3, ((∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf))
```

The per-qnf `BracketCarrierCorrectVPrior` rungs (`kampPrior_site_rung0_match`/`rung1_match`,
PriorInterface:80/:95) carry a FIXED interior order pattern and only cover the `x<w<t` zone. The
`∀ qnf` ranges over ALL order patterns → route `w` across the five zones (`w<x`, `w=x`, `x<w<t`,
`w=t`, `t<w`) via `nf_zone_flatten_navigable`, whose past/future hooks ARE the depth-`k` IH
(bottoming at `nf_zone_flatten_navigable_zero`). Do this for k=0 (bottoms out) and k=1 (one IH
step), then rewrite the arm:

```
| 1 => match k with
  | 0 => <proof via k=0 arm formulas + skeleton>
  | 1 => <proof via k=1 arm formulas + skeleton>
  | k + 2 => sorry  -- narrowed GO-k1 residue; successor: spawned symbolic-k kvE2Ext task
```

Estimated ~200-400 lines of recursive zone-triage assembly; dedicate a SINGLE-OWNER cycle (no
concurrent agents on KampPrior.lean). If too large for one cycle, land the past / future /
diagonal arm dischargers as separate green lemmas first.

## Guards (binding)

V9-1 frozen provider files byte-unchanged; V9-2 no `hexclExt`; V9-4 do NOT change
`nf_nvar_exist_all_depths` signature; axioms exactly `{propext, Classical.choice, Quot.sound}`;
no simp/omega/aesop shortcut of a chain step; anchors strictly `{x,t}`; the narrowing must NOT
increase live-path code sorries (currently 2: :361, :364).

## Notes

- Phase 17 (hrealI/hrealB/hexcl) is BLOCKED (Track A, peer agents; frozen-interface gap) and is
  INDEPENDENT of this track — do NOT attempt it here.
- Full authoritative recovery state: `specs/309_offdiag_two_anchor_fi_chain/.orchestrator-handoff.json`.
