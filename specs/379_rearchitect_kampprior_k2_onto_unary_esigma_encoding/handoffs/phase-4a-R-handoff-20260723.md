# Phase 4a-R handoff — off-path exists-forall chain RESTORED TO GREEN

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23

## Immediate Next Action

Phase **4a-1** (NEW per-formula renderer `unaryToFormulaFin`, `Separation/` untouched) is now
UNBLOCKED — the restored-green premise it was re-gated on holds. Start there.

## Current State

- **Phase 4a-R COMPLETED** (all four sub-steps R.0-R.3). Chain census: **19/19 GREEN** under
  per-file `lake build Bimodal.Metalogic.WeakCanonical.Kamp.<file>` — the 12 census-RED files,
  the 4 baseline-GREEN files, and **3 additional RED files the prior census missed**
  (`VeeConj`, `EFSatNegation`, `Prop42NegationGeneral`).
- Full `lake build` EXIT 0. `#print axioms completeness_discrete` byte-identical to baseline:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  (the `sorryAx` = permitted KampPrior `nf_nvar_exist_all_depths | _k+2` residual).
- Spine untouched: every edit is an off-path Kamp file; every edit is instance-binder-only.

## Key Decisions / Findings

1. **Instance-threading style**: per-declaration `[Fintype sig.preds] [DecidableEq sig.preds]`
   binders where files bind `sig` per-decl (Prop35Assembly, Prop42ExistsForall, VVecEA2Collapse,
   Prop42NegationGeneral, EFSatNegation, Prop43Translate partial); section-level
   `variable ... [Fintype sig.preds] [DecidableEq sig.preds]` where a file already had a
   section-level `variable {sig ...}` and pervasive need (LiftPair, EFSatNegationGeneral,
   VeeSatNegation) — both styles are established Phase-2 precedent (NfMultiAnchorBridge/*).
2. **The "genuine proof breakages" were NOT genuine** — the `ConjInterleave` `intervalConj`
   mismatch in `conjInterleave_backward` and every `other=2` site (rcases failures, unsolved
   goals, anonymous-constructor errors in LiftPair/EFSatNegationGeneral/VeeSatNegation/
   Prop43Translate) were elaboration artifacts of failed `Fintype sig.preds` synthesis leaving
   metavariables unresolved. R.1's threading discharged R.2 entirely; **zero proof-content edits**.
3. **The "~18 pre-existing off-path sorries" were NOT literal sorries** — they were synthetic
   `uses 'sorry'` compiler diagnostics propagated from errored upstream declarations. The
   literal-sorry census over all non-Boneyard Kamp files finds exactly the 3 spine-permitted:
   KampPrior `| _k+2` arm (KampPrior.lean:562 today), EANegation.lean:1090, :1249. The amended
   sorry gate HOLDS with no retirement work needed; R.3 discharged by demonstration.
4. `Prop35Chain` and `ZetaAtomMapReconcile` needed no edits (redness was inherited from imports).

## Sorry Inventory

Live literal sorries anywhere in the build (all pre-existing, all spine-permitted, none
introduced or touched this dispatch):

| # | Anchor | Status |
|---|--------|--------|
| 1 | `nf_nvar_exist_all_depths` `\| _k+2` arm (KampPrior.lean) | permitted; retired LAST in Phase 5 |
| 2 | EANegation.lean:1090 | permitted; UNFIXABLE by adjudication — do not touch |
| 3 | EANegation.lean:1249 | permitted; UNFIXABLE by adjudication — do not touch |

## Commits this phase (all green)

- `9da3e1e5c` ConjInterleave (incl. the intervalConj sites)
- Prop35ExistsForall, ESigmaCapture, VeeConj, LiftPair, Prop35Assembly, Prop42ExistsForall,
  VVecEA2Collapse, Prop42NegationGeneral, EFSatNegation, EFSatNegationGeneral, VeeSatNegation,
  Prop43Translate — one green commit per file (`git log --oneline` for SHAs), plus this
  phase-completion commit.

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
  (Phase 4a-R block now carries the completion note; 4a-1 block has the renderer spec).
- Prior handoff: `handoffs/phase-4a-0-handoff-20260723.md` (its stratum-2/3 census is now
  corrected by findings 2-3 above).
