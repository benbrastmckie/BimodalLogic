# Phase 5 (completion dispatch): nameOf/hName generalization, ζ wire, residual retirement

- **Task**: 379 — rearchitect KampPrior k≥2 onto the unary E[Σ] encoding
- **Plan**: `plans/24_restore-offpath-chain-then-bridge.md` (Phase 5, terminal live-path phase)
- **Session**: sess_1784869380_2459bd
- **Date**: 2026-07-24
- **Result**: **Phase 5 [COMPLETED]; task definition-of-done met** — the
  `nf_nvar_exist_all_depths | _k+2` residual is retired and
  `#print axioms completeness_discrete` lists NO `sorryAx`.

## What was done

### (i) The nameOf/hName render generalization (5.5–5.15, 11 files, one green commit each)

The predecessor's seam finding: `translate_uniformFin`'s
`h_surj : ∀ p : (sigE sig F).preds, ∃ a, atomMap (.atom a) = p` is unsatisfiable at the ζ
atom map `atomMap = oldPred ∘ g` (`Sum.inr` is never hit). The decided, faithful fix — the
literal Rabinovich p.6 collapse inlined into the render — was implemented exactly:

- **Definitions** now take a model-free naming function
  `nameOf : (sigE sig F).preds → Formula` (new literal `nameLit`, `PerFormulaRender.lean`);
- **Correctness lemmas** take the per-model premise
  `hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y`;
- `h_surj`-naming is the degenerate case `nameOfSurj`/`nameOfSurj_hName`;
- In the uniform extraction (`ZetaUniformExtract.lean`), `nameOf` stays OUTSIDE `∀N`
  (it is syntax) and `hName` joins `hNamed` inside `∀N` — preserving the
  `∃Ψ`-outside-`∀N` shape;
- The two structural atom cases (`translate_correctFin`, `translate_uniformFin`) now name a
  predicate `p` by `nameOf p` and close by `hName p` — no chosen atom, no surjectivity.

Files: PerFormulaRender, Prop35Assembly, Prop42ExistsForall, Prop42NegationGeneral,
VVecEA2Collapse, EFSatNegation, EFSatNegationGeneral, VeeSatNegation, Prop43Translate,
ZetaUniformExtract, PerFormulaRenderProbe. `h_surj` over `sigE` is GONE from the chain.

### (ii) The ζ wire (5.16, `ZetaUniformExtract.lean` §7)

- `zetaNameOf g h_surj`: `Sum.inl q ↦ .atom (choice)` (base surjectivity onto `sig.preds`,
  which holds), `Sum.inr A ↦ A` — the p.6 collapse;
- `zetaNameOf_hName`: the naming premise holds on any `N` with `hMap` + `hNamed`
  (`inl` by choice + definitional `oldPred`, `inr` = `hNamed` verbatim);
- `kampArm_zeta` (**general in the depth `k`**): for `sub_nf : NormalForm sig k 2`, a single
  temporal formula `A` with
  `temporal_truth M g t A ↔ ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`
  uniformly over all Prior structures `M`. Pipeline: `nf_to_formula` → `.ex` →
  `mapPreds oldPred` → `translate_uniformFin` (with `zetaNameOf`) → per-`M` instantiation at
  `canonExpand sig ∅ M (fun B x => temporal_truth M g x B)` (premises:
  `canonExpand_atom_named`, `canonExpand_hasAttainedINF/SUP`, `hne := ⟨t⟩`, `StrictMono` on
  `Fin 1` trivial) → readback `translateVeeProp35Fin` → descent
  `temporal_truth_canonExpand`. `atomMap = oldPred ∘ g` kept exactly as committed.

### (iii) Residual retirement (5.17–5.18, TERMINAL)

- `KampPrior.lean` imports `ZetaUniformExtract`; the `| _k+2` arm's `sorry` + arity-cap
  rationale block replaced by `(kampArm_zeta atomMap h_surj sub_nf).imp …` with the
  `insertEnv`/`Fin.cons` environment adapter. No consumer re-point was needed —
  `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` are supplied through `nf_characterizable_temporal_prior`.
- `BXCanonical/Completeness.lean` audit block updated to record the sorryAx-free state.

## Final verification

| Check | Result |
|-------|--------|
| `#print axioms completeness_discrete` | `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — **no `sorryAx`** |
| Full `lake build` | EXIT 0, 1789 jobs (floor rose from 1772: the ζ chain is now live, as intended) |
| Task-zone live sorries | exactly EANegation `:1090`, `:1249` (charter-permitted, untouched) |
| KampPrior residual | **RETIRED** |
| New sorries / vacuous defs / new axioms | 0 / 0 / 0 |

## Plan deviations

- The consumer re-point task required NO file edits (the arm supplies the three consumers) —
  annotated in the plan as an alteration.
- `collapseEFFin_translate` (VVecEA2Collapse) dropped the naming hypothesis entirely (it is a
  pure definitional equation) rather than gaining `hName`.
- `kampArm_zeta` is general in `k`, so it subsumes what per-depth `kampArm_*_k≥2` triples
  would have provided; the k=0/k=1 arms retain their landed per-depth route.

## Commits (14, this dispatch)

5.5 `3ebd95cf8` · 5.6 `1726916be` · 5.7 `2a602960b` · 5.8 `34db09125` · 5.9 `a1845a636` ·
5.10 `ecee82df4` · 5.11 `7a39e8551` · 5.12 `660e3e920` · 5.13 `204b74b17` · 5.14 `7f3e28eeb` ·
5.15 `525b941e3` · 5.16 `68d00666f` · 5.17 `9b3bfa100` · 5.18 `10fe1d939`
