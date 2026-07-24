# Phase 5 handoff — green prefix 5.0–5.4 landed; ζ-wire seam finding recorded

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784869380_2459bd
- **Date**: 2026-07-23/24
- **Commits this dispatch** (5 green commits on top of `e042477c8`, each verified by scoped or
  full build):
  - `7c3df162f` — 5.0: retire RED post-flip total-render remnants (4c-mandated deletions that
    only surfaced RED at 4-flip): `unaryToFormula`/`unaryToFormula_correct`
    (Prop35ExistsForall, now a doc-anchor stub), Prop35Assembly total sections 1–4
    (`efPointTP`/`efIntervalTP`/`efIntervalSetTP`(+`_eval`)/`translateProp35`(+`_correct`)/
    `translateVeeProp35`(+`_correct`)), `Prop35VeeLift.lean` DELETED (import-orphan),
    `InfAlphabetProbe.lean` §4 deleted (gate §§1–3 kept). Off-path chain green per-file
    (1045 jobs).
  - `dc85bc4dc` — 5.1: direct M-relative capture in `ESigmaCapture.lean`: `capTypeFin p`
    (singleton `IntervalTypeFin` over singleton mentioned set, instance-free),
    `intervalHoldsFin_capTypeFin` (generic over every `N`), `capTypeFin_atomNamed`
    (atom-naming premise → capture fact).
  - `6dacd07ce` — 5.2: `hCapture` REMOVED from the whole Fin negation stack, replaced by the
    atom-naming premise `hNamed : ∀ A y, N.interp (esigmaPred A) y ↔ temporal_truth N atomMap y A`
    (at ζ this is exactly `canonExpand_atom_named`): `vvecea2_collapse_bridgeFin`,
    `intervalTypeFin_captures_temporalPred`, `efSat_negation_pairFin`,
    `efSat_negation_diagonalFin`, `efSat_negation_existenceFin`, `efSat_negation_generalFin`,
    `veeSat_negationFin`, `translate_correctFin`. Capture is CONSTRUCTED (`capTypeFin`), never
    hypothesized.
  - `60ef3816d` — 5.3: `ZetaUniformExtract.lean` fully rewritten as the Fin uniform extraction
    (`∃Ψ`-outside-`∀N`, no `capFn`): `translate_uniformFin` + uniform
    diagonal/existence/pair/engine/bridge/general(β)/negation-closure(γ)/ex-closure stack.
    Compiled green first build.
  - `3523a40b1` — 5.4: `BXCanonical/Completeness.lean` in-file audit block corrected —
    residual anchored by DECLARATION NAME (`nf_nvar_exist_all_depths`, the `| _k+2` arm), no
    line refs, k=0/k=1 arms recorded as discharged. Full `lake build` EXIT 0 (1772 jobs).

## Immediate Next Action

**Resolve the render-naming seam (below), then wire ζ and retire the residual LAST.**
Read this section + the plan's Phase 5 remaining tasks. Everything through the uniform
extraction is landed and green; what remains is: (a) the `nameOf` render generalization,
(b) the NF→`MonadicFormula` bridge into the arm, (c) the ζ `canonExpand` instantiation +
spine re-point, (d) residual deletion + `#print axioms` (TERMINAL).

## THE SEAM FINDING (blocks sub-step "Construct the ζ canonExpand" as literally planned)

`translate_uniformFin` (and the whole Fin chain) threads
`h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p`.
At the ζ site the plan prescribes `atomMap = oldPred ∘ g` (ZetaAtomMapReconcile committed
interface) — but that map NEVER hits `Sum.inr`, so `h_surj` is FALSE there (this is exactly
reports/16 PROBE 1's machine-checked content, resurfacing at instantiation time). The two
obvious dodges both fail:

1. A surjective substitute `atomMapZ` (rank-named via `Countable Atom` + countable `Formula`)
   satisfies `h_surj` but breaks the atom-naming premise `hNamed`: with the canonical
   `sat B := temporal_truth M g · B`, `hNamed` w.r.t. `atomMapZ` requires `collapseSubst θ` to
   be truth-preserving over `M`, which fails at any object atom named onto a fresh pred; and
   making `sat` the fixpoint `sat C y = temporal_truth N atomMapZ y C` is not well-founded
   (temporal_truth is non-monotone through `imp`, and a leaf may name a LARGER formula) without
   a ranked-naming construction that no landed report designs.
2. Weakening `h_surj` to old-preds-only was already adjudicated INFEASIBLE
   (ZetaAtomMapReconcile header): the render genuinely names fresh preds — now MORE so, since
   the direct capture puts `esigmaPred` readbacks into the mentioned sets `M` that
   `unaryToFormulaFin` renders.

**Continuation design (faithful, no novel math, consistent with the committed reconcile
interface — the literal p.6 collapse inlined into the render):** generalize the render naming
from `h_surj`-chosen atoms to a naming function

```
nameOf : (sigE sig F).preds → Formula          -- fixed, model-free
hName  : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y   -- per-N premise
```

`h_surj`-naming is the degenerate case `nameOf p := .atom (h_surj p).choose`. At ζ, with
`atomMap = oldPred ∘ g` KEPT exactly as committed:
- `nameOf (Sum.inl q) := .atom a_q` (the arm's base `h_surj` for `g` — surjectivity onto
  `sig.preds` only, which HOLDS);
- `nameOf (Sum.inr A) := A` — the readback IS an atom; `hName` at `inr A` is
  `temporal_truth N atomMap y A ↔ N.interp (esigmaPred A) y`, i.e. `canonExpand_atom_named`
  verbatim; at `inl q` it is `atom_eval_old` + `hMap`.

With `nameOf (inr A) = A`, the emitted TL formula is DIRECTLY over `M`-meaningful leaves — the
`collapseSubst` unwinding is inlined into the render, and `temporal_truth_collapse` is only
needed (if at all) as `θ = id`. Blast radius of the `h_surj → nameOf/hName` swap: the
DEFINITIONS take `nameOf` (syntax only), the correctness lemmas take `hName`; files:
`PerFormulaRender.lean` (`unaryToFormulaFin`), `Prop35Assembly.lean` Fin §§5–6,
`Prop42*`/`ConjInterleave`/`LiftPair` Fin sites that thread `h_surj`, the negation stack, and
`ZetaUniformExtract.lean` — the same mechanical scale as the 5.2 `hCapture` removal (which went
green in one pass). If the orchestrator prefers de-risking first: a one-file probe restating
`unaryToFormulaFin` + `_correct` against `nameOf`/`hName` settles the seam in ~1 hour.

## Remaining sub-steps after the seam (plan order, binding)

1. `nameOf`/`hName` render generalization (above).
2. NF→`MonadicFormula` bridge: express the arm's RHS
   `∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+2) 2 (insertEnv env t) sub_nf` as
   `eval M (fun _ => t) ψ` for a `MonadicFormula sig 1` (`doets_lemma_1_1` substrate;
   `NormalForm.lean`), lift along `mapPreds oldPred` (`MonadicFormulaMap.lean`, green).
3. ζ instantiation at `N := canonExpand sig F M (fun B x => temporal_truth M g x B)`:
   `hNamed := canonExpand_atom_named` (needs `hMap : ∀ φ, atomMap φ = oldPred (g φ)` — holds
   definitionally for `atomMap := oldPred ∘ g`); `h_INF/h_SUP :=
   canonExpand_hasAttainedINF/SUP` (ZetaPriorTransfer, green); `hne` from the carrier witness
   (report 13); readback via `translateVeeProp35Fin` (+`_correct`) at arity 1; StrictMono for
   `env : Fin 1` is trivial.
4. Re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
   `no_gaps_discrete_model_surgery` (the arm supplies them through
   `nf_characterizable_temporal_prior` — the only edit is inside the `| _k+2` arm).
5. Verify green with the residual STILL PRESENT; then delete the `| _k+2` arm LAST; run
   `#print axioms completeness_discrete` and confirm `sorryAx` GONE.

## Current State

- Phase 5 is **[IN PROGRESS]**: sub-steps 1 (capture removal, incl. uniform extraction), 2
  (reconciliation re-verification: ZetaAtomMapReconcile / ZetaPriorTransfer /
  MonadicFormulaMap all green per-file, no signature change needed), and the audit-block
  correction are DONE and checked off in the plan with deviation notes.
- Full `lake build` EXIT 0 — **1772 jobs**, same floor as the 4-flip baseline.
- `#print axioms completeness_discrete` byte-identical to baseline:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  (the `sorryAx` is the charter-permitted `nf_nvar_exist_all_depths | _k+2` residual — NOT yet
  retired; its deletion is the terminal action).
- Task-zone live sorries: exactly the 3 permitted (KampPrior `| _k+2` arm; EANegation
  `:1090`, `:1249`). 0 new sorries, 0 vacuous defs, 0 new axiom declarations.
- Off-path chain green per-file (13-target scoped build incl. Prop43Translate,
  VVecEA2Collapse, ZetaUniformExtract, probes).
- `HCaptureDischarge.lean` untouched (orphaned; its `esigma_descent`-side discharge is not on
  the Phase 5 path — dispose at the terminal wire or leave to the Boneyard-hygiene owner).

## What NOT to Try (carried forward + new)

- Standing list unchanged: no chain_split, EANegation :1090/:1249 untouchable, no
  Feferman-Vaught/novel math, Rabinovich by PDF page only (companion .md corrupt), no task
  numbers in `Theories/**`, anchor the residual by declaration name.
- Do NOT resurrect `hCapture`/`capFn` or the deleted total-render layer.
- Do NOT attempt a surjective `atomMapZ` + `sat`-fixpoint at the ζ site without a ranked-naming
  design (non-well-founded as analyzed above); the `nameOf` generalization is the committed
  continuation.
- Do NOT delete the `| _k+2` arm before the new path is green end-to-end.

## Sorry Inventory

Unchanged from 4-flip: exactly the 3 spine-permitted sorries (KampPrior
`nf_nvar_exist_all_depths | _k+2` arm; EANegation :1090; EANegation :1249). Nothing introduced
this dispatch.

## References

- Plan: `plans/24_restore-offpath-chain-then-bridge.md` (Phase 5 checkboxes annotated)
- Prior handoff: `phase-4-flip-handoff-20260723.md`
- Seam evidence: `reports/16_zeta-wire-blocker-probe.lean` (PROBE 1), `ZetaAtomMapReconcile.lean`
  header (option (a) infeasibility), `ESigmaCapture.lean` §2 (direct capture)
- Rabinovich anchors: Def 4.1 (PDF p.5), Prop 4.3 / Thm 4.4 + collapse note (p.6) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
