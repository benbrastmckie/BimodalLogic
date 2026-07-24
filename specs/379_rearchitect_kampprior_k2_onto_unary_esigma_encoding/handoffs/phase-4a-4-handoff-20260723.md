# Phase 4a-2/4a-3/4a-4(1) handoff — render micro-gate GO, per-formula ∃∀ object landed

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: `9d0d12511` (4a-2), `85ece8198` (4a-3), `bd5f253e6` (4a-4 item 1) —
  3 green commits on top of green_head `c2f8396d0`.

## Immediate Next Action

**Phase 4a-4 item 2: `ExistsForallLemmas.lean`** — add Fin-variants of the `efSat` lemma layer
(705 lines, 51 declarations; a full sub-run of its own). Read the file, identify the `efSat`
lemma layer, and mirror it onto `efSatFin` (`Kamp/PerFormulaExistsForall.lean`) via the bridge
`efSatFin_iff_efSat_completions` where a total lemma is being transported, or directly where the
proof is representation-independent. One green commit for the file. Then continue in plan order:
`ConjInterleave` → `Prop35*` (promote the RenderGate probe content to production
`translateProp35Fin` in `Prop35Assembly.lean`) → `Prop42ExistsForall` → negation stack →
`Prop43Translate`; then 4b (LiftPair, last and alone), 4c, 4-flip.

## Current State

- **4a-2 render MICRO-GATE: VERDICT GO** (commit `9d0d12511`). New
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PerFormulaRenderProbe.lean` (namespace
  `RenderGate`, off-path): `efPointTPFin`/`efIntervalSetTPFin` (+ eval lemmas routed through
  `unaryToFormulaFin_correct`), probe-local `EFFin`/`efSatFin`, **`translateProp35Fin`** and the
  FULL generic correctness `translateProp35Fin_correct` (`efSatFin ↔ temporal_truth`, mirroring
  `translateProp35_correct` with the three total interfaces swapped for Fin ones), instantiated
  on the nontrivial `n = 1` input `ψGate` with NON-EMPTY singleton interval clauses
  (`ψGate_intervalType_nonempty`, `gate_translateProp35Fin`). `#print axioms
  RenderGate.gate_translateProp35Fin` = `[propext, Classical.choice, Quot.sound]`. Zero
  `Finset.univ` in code; zero alphabet instance binders in the module.
- **4a-3 COMPLETED** (commit `85ece8198`). New `Kamp/PerFormulaExistsForall.lean`: production
  `ExistsForallFormulaFin` (bundles `M`), `efSatFin` + `efSatFin_interval_iff`,
  `completionsSet`/`intervalHolds_biUnion_completions_iff`, `ExistsForallFormulaFin.toTotal`,
  and the bridge `efSatFin_iff_efSat_completions` (choice-of-completions form). Only the bridge
  side takes `[Fintype sig.preds]`; the Fin object consumes no alphabet finiteness.
- **4a-4 item 1 COMPLETED** (commit `bd5f253e6`). `IntervalType.lean` §5 (sub-namespace `Kamp`):
  `intervalConjFin`/`intervalBotFin`/`intervalTopFin`/`ofCompleteFin` +
  `intervalHoldsFin_{ofCompleteFin_iff,bot,top,mono,inter_iff,inter_left,inter_right}` —
  M-relative direct proofs, no alphabet instances (`intervalTopFin` is `open Classical in
  noncomputable`: `Fintype (UnaryTypeFin)` = Finset-subtype Fintype + classical subtype decEq).
- Full `lake build` EXIT 0 (1771 jobs); `#print axioms completeness_discrete` byte-identical to
  baseline `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler,
  Quot.sound]`; chain heads (`Prop35Assembly`, `LiftPair`, `Prop43Translate`, `ESigmaCapture`,
  `ZetaAtomMapReconcile`) rebuild green.

## Key Decisions Made

1. **The generic `translateProp35Fin_correct` already exists** (probe, `RenderGate` namespace):
   the 4a-4 `Prop35*` migration step can PROMOTE this proof to `Prop35Assembly.lean` (Kamp
   namespace) nearly verbatim instead of re-deriving it. The `RenderGate` sub-namespace was
   chosen precisely so promotion causes no name clash; retire/alias the probe copy when
   promoting.
2. **Chain machinery is representation-independent**: `translateEF1_correct`,
   `buildRight_spec_iff_chain`, `buildLeft_spec_iff_chain` need NO changes for the Fin layer —
   the only representation-dependent interfaces are the two eval lemmas + the `efSat` unfold.
3. **Fin-algebra instance route**: `Fintype (UnaryTypeFin sig F M)` does NOT synthesize bare —
   use `open Classical in` (subtype decEq classically) + Finset-subtype `Fintype`. No alphabet
   instance is consumed; this is the sanctioned M-relative route.
4. **4a-3 bridge shape**: `efSatFin ↔ ∃ choice of point-type completions, efSat (toTotal ψ
   choice)` (choice-function form via `Classical.choose` on per-point
   `intervalHolds_completions_iff`). Interval clauses transport via
   `completionsSet := S.biUnion completions`.

## FINDING (fixed forward this dispatch)

`InfAlphabetProbe.lean` was **RED at HEAD** — invisible because it is outside both the default
build (`roots := #[Bimodal]`; nothing imports the probes) and the 19-file 4a-R census. Two
pre-existing artifacts, same family as the 4a-R census correction: `partialIntervalHolds`
needed the classical M-relative `Fintype` route, and `translateProp35_input` lacked the 4a-R
instance binders. Both repaired in `bd5f253e6`; probe green + axiom-clean again. **Successor
note**: per-file-build any off-path file you touch — "not in the census" does not mean green.

## What NOT to Try

- Do NOT re-derive the render correctness at `Prop35Assembly` migration time — promote the
  probe proof (Decision 1).
- Do NOT thread `[Fintype sig.preds]` into any Fin-layer declaration to fix instance failures —
  use the classical M-relative route (Decision 3). Alphabet instances are permitted ONLY on
  bridge/total-side declarations (deleted at 4c).
- All prior prohibitions hold: no chain_split; EANegation charter anchors untouchable; no
  full-alphabet `Finset.univ`; a red obligation is STOP + handoff, never a hole.

## Remaining Goals (verbatim from plan v24)

- [ ] `ExistsForallLemmas.lean`: Fin-variants of the `efSat` lemma layer.
- [ ] `ConjInterleave.lean`: `conjInterleaveFin` / `veeConjFin` via the bridge.
- [ ] `Prop35ExistsForall.lean` / `Prop35Assembly.lean` / `Prop35Chain.lean`: switch the exists-forall
      chain to the Fin renderer `unaryToFormulaFin`; `translateProp35Fin`/`translateProp35Fin_correct`.
- [ ] `Prop42ExistsForall.lean`: Fin-variant.
- [ ] `EFSatNegationGeneral.lean` / `VeeSatNegation.lean` / `VVecEA2Collapse.lean`: Fin-variants of the
      beta/gamma negation stack (SHAPE survives; enumeration becomes `M`-relative).
- [ ] `Prop43Translate.lean`: `M`-relative delta-translate filter Fin-variant (preserve the report-15
      `StrictMono psi.pin` conclusion-strengthening).
- Then Phase 4b (`LiftPair.lean`, hardest, last and alone), Phase 4c (switchover + deletions),
  Phase 4-flip (`sigE` summand flip), Phase 5.

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted literal sorries (`KampPrior.lean:562`
`nf_nvar_exist_all_depths | _k+2` arm; `EANegation.lean:1090`; `EANegation.lean:1249` — anchor
by declaration, positions drift). Nothing introduced this dispatch (all new material sorry-free,
axioms `[propext, Classical.choice, Quot.sound]`).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
- Prior handoffs: `phase-4a-1-handoff-20260723.md`, `phase-4a-R-handoff-20260723.md`
- Key files: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PerFormulaRenderProbe.lean` (4a-2
  gate, promotion source), `Kamp/PerFormulaExistsForall.lean` (production Fin object + bridge),
  `Kamp/IntervalType.lean` §5 (Fin algebra), `Kamp/PerFormulaRender.lean` (renderer),
  `Kamp/PerFormulaType.lean` (types + completions).
- Rabinovich anchors: Def 3.1 (PDF p.4), Prop 3.5 (p.5), Def 4.1 (p.5) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt).
