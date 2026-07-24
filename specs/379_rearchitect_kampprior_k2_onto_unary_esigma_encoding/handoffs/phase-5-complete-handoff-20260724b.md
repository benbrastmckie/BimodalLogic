# Phase 5 COMPLETE — nameOf/hName generalization landed, ζ wired, `_k+2` residual RETIRED

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784869380_2459bd
- **Date**: 2026-07-24
- **Status**: Phase 5 [COMPLETED]; plan Status [COMPLETED]. This was the terminal live-path phase.

## Immediate Next Action

None for Phase 5 — the task's definition of done is met. Downstream: task 375 (final
`#print axioms` audit, `deps:[379]`) can now consume the sorryAx-free spine. Boneyard
hygiene (`HCaptureDischarge.lean` orphan disposal, arity-4 apparatus archival) is owned by
task 359, not this task.

## What landed this dispatch (14 green commits on top of `bf97f91c7`)

**(i) nameOf/hName render generalization** (the decided fix for the recorded seam — the
literal Rabinovich p.6 collapse inlined into the render), bottom-up, one file per green commit:

- `3ebd95cf8` 5.5 — `PerFormulaRender.lean`: `nameLit`/`nameLit_correct` (naming-function
  literal), `nameOfSurj`/`nameOfSurj_hName` (the degenerate `h_surj` case),
  `unaryToFormulaFin` now takes `nameOf : (sigE sig F).preds → Formula` (syntax only);
  `unaryToFormulaFin_correct` takes the per-model premise
  `hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y`.
- `1726916be` 5.6 — `Prop35Assembly.lean` (renders + correctness).
- `2a602960b` 5.7 — `Prop42ExistsForall.lean`.
- `34db09125` 5.8 — `Prop42NegationGeneral.lean`.
- `a1845a636` 5.9 — `VVecEA2Collapse.lean` (`collapseEFFin_translate` needs NO hName — pure
  definitional equation).
- `ecee82df4` 5.10 — `EFSatNegation.lean`.
- `7a39e8551` 5.11 — `EFSatNegationGeneral.lean`.
- `660e3e920` 5.12 — `VeeSatNegation.lean`.
- `204b74b17` 5.13 — `Prop43Translate.lean`: the `translate_correctFin` ATOM case now names
  `p` by `nameOf p` directly (PROBE 1 seam closed at the render; `h_surj` gone from the file).
- `7f3e28eeb` 5.14 — `ZetaUniformExtract.lean`: `nameOf` OUTSIDE `∀N` (model-free), `hName`
  a per-N premise inserted before `hNamed` in every uniform statement; uniform atom case via
  `nameOf p`.
- `525b941e3` 5.15 — `PerFormulaRenderProbe.lean` (gate record). Full `lake build` EXIT 0
  (1772 jobs) with the residual still present.

**(ii) the ζ wire**:

- `68d00666f` 5.16 — `ZetaUniformExtract.lean` §7: `zetaNameOf` (`inl q ↦ chosen atom` via the
  arm's base `h_surj` — surjectivity onto `sig.preds`, which HOLDS; `inr A ↦ A`),
  `zetaNameOf_hName` (general in `N`: `inl` by `hMap`+choice, `inr` = `hNamed` verbatim), and
  `kampArm_zeta` — GENERAL IN k: `nf_to_formula` → `mapPreds oldPred` → `translate_uniformFin`
  at `atomMap = oldPred ∘ g` KEPT exactly as committed → per-`M` instantiation at
  `canonExpand sig ∅ M (fun B x => temporal_truth M g x B)` (naming `canonExpand_atom_named`,
  INF/SUP `ZetaPriorTransfer`, `hne` from the point) → readback `translateVeeProp35Fin` →
  descent `temporal_truth_canonExpand`. Compiled green FIRST build.

**(iii) TERMINAL — residual retirement**:

- `9b3bfa100` 5.17 — `KampPrior.lean`: import `ZetaUniformExtract`; the
  `nf_nvar_exist_all_depths | _k+2` arm's `sorry` + arity-cap rationale block REPLACED by
  `(kampArm_zeta atomMap h_surj sub_nf).imp …` + the `insertEnv`/`Fin.cons` env adapter.
  No consumer re-point needed: `kamp_prior_expressive_completeness` /
  `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` are supplied
  through `nf_characterizable_temporal_prior` unchanged.
- `10fe1d939` 5.18 — audit corrections: `BXCanonical/Completeness.lean` in-file audit block
  now records the sorryAx-free state; `KampPrior.lean` n=1 narration updated.

## Final verification (all machine-checked)

- **`#print axioms completeness_discrete`**:
  `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` —
  **NO `sorryAx`** (checked after 5.17 and re-checked after 5.18).
- Full `lake build` EXIT 0 — 1789 jobs (up from 1772: the ζ chain is now on the live path,
  as intended).
- Task-zone live sorries: exactly the 2 charter-permitted EANegation anchors (`:1090`,
  `:1249` — backward-direction, UNTOUCHED). The KampPrior residual is GONE.
- 0 new sorries, 0 vacuous defs, 0 new axiom declarations introduced by this dispatch.

## Sorry Inventory

| file | anchor | status |
|------|--------|--------|
| `EANegation.lean` | `:1090` (backward-direction B.1 case) | charter-permitted, untouched, off the `completeness_discrete` proof term |
| `EANegation.lean` | `:1249` (backward-direction n≥1) | charter-permitted, untouched, off the `completeness_discrete` proof term |

(KampPrior `nf_nvar_exist_all_depths | _k+2`: **RETIRED** this dispatch.)

## What NOT to do (for any successor touching this area)

- Do not resurrect `h_surj` over `(sigE …).preds` — it is FALSE at the ζ atom map
  (`Sum.inr` never hit); the render is now parameterized by `nameOf`/`hName` and the
  degenerate case is `nameOfSurj`.
- EANegation `:1090`/`:1249` remain untouchable (charter).
- Rabinovich by PDF page only; companion .md corrupt.
- `HCaptureDischarge.lean` is orphaned — disposal belongs to the Boneyard-hygiene owner.

## References

- Plan: `plans/24_restore-offpath-chain-then-bridge.md` (Phase 5 [COMPLETED], all boxes checked)
- Predecessor handoff: `phase-5-handoff-20260724.md` (the seam finding + decided fix)
- Rabinovich anchors: Def 3.1 (p.4), Prop 3.5 (p.5), Def 4.1 (p.5), Prop 4.3 / Thm 4.4 +
  collapse note (p.6) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
