# Phase 4a-4 item 3 handoff — ConjInterleave Fin layer landed (conjInterleaveFin / veeConjFin)

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: 4 green commits on top of `b0cecf3ca`:
  `02ac3cd85` (defs: mergedM, glue set, mergedFormulaFin, conjInterleaveFin),
  `0624dc6d1` (slot-placement transcriptions),
  `c9e6c0afe` (forward direction),
  `6ffc98556` (backward direction, conjInterleaveFin_iff, veeConjFin) — every chunk first-pass
  green, per-file build at each step, full `lake build` EXIT 0 at the end.

## Immediate Next Action

**Phase 4a-4 item 4: `Prop35*`** (`Prop35ExistsForall.lean` / `Prop35Assembly.lean` /
`Prop35Chain.lean`): switch the exists-forall chain to the Fin renderer `unaryToFormulaFin`;
`translateProp35Fin`/`translateProp35Fin_correct`. **SUCCESSOR NOTE (still pending, carried
from two handoffs back): PROMOTE `RenderGate.translateProp35Fin_correct` from
`PerFormulaRenderProbe.lean` into `Prop35Assembly.lean` — do NOT re-derive it.** Then in plan
order: `Prop42ExistsForall` → negation stack (`EFSatNegationGeneral`/`VeeSatNegation`/
`VVecEA2Collapse`) → `Prop43Translate`; then 4b (LiftPair, last and alone), 4c, 4-flip.

## Design decision resolved this dispatch (the item-2 scoping crux)

**Adopted: M-relative completions in the disjunction** (the candidate resolution scoped in
`phase-4a-4-item2-handoff-20260723.md`), anchored to **Lemma 3.2(1), PDF p.4**: each
`conjInterleaveFin` disjunct is a merge datum `m : MergePair` TOGETHER WITH a per-point choice
`pt : Fin (k+1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂)`, filtered by `choiceCompatible`:
1. `weaken` to `ψ₁.M` of `pt (m.e₁ i₁)` equals `ψ₁.pointType i₁` (and symmetrically for chain 2)
   — subsumes the total layer's `pointConsistent` at shared points;
2. at a point pinned by only one chain, the OTHER-chain restriction of `pt` lies in the other
   chain's partial interval set at the enclosing slot (`intervalSlot`) — the Fin
   `crossConsistent`, folded into the choice constraint.

Faithfulness: Def 3.1 (p.4) takes point predicates `αⱼ` as arbitrary quantifier-free 1-formulas;
a cross point's conjoined constraint `α₁ ∧ (ψ₂'s interval formula)` expands to the finite
disjunction of its complete types over the mentioned atoms, absorbed by Lemma 3.2(1)'s
disjunction-of-∃∀ conclusion (Prop 3.5 p.5 translatability preserved: every disjunct is still a
Def 3.1 object). The expansion is finite from `M` alone — never alphabet-sized.

**Proof route**: direct re-proof on partial relations (NOT transport through
`efSatFin_iff_efSat_completions`) — scoping note 6 left the route open; the toTotal commutation
would itself need a completion choice, whereas the direct route reuses the total proof shapes
with `partialHolds_eq_charTypeFin` replacing `nf_eval_unique` as the uniqueness engine.

## Current State

- **4a-4 item 3 COMPLETED.** `ConjInterleave.lean` gained §10 (sub-namespace `Kamp`, +827 lines,
  file now 1824 lines), importing `ExistsForallLemmas` (no cycle; sanctioned by item-2 handoff
  Decision 1):
  - §10.0 `partialHolds_weaken`, `partialHolds_eq_charTypeFin`, `weaken_charTypeFin` (rfl)
  - §10.1 `mergedM` (classical `Finset` union — the ONE definition consuming classical
    `DecidableEq (AtomKind …)`, since the global instance `atomKind_decEq` needs the prohibited
    `DecidableEq sig.preds`), `subset_mergedM_left/right`, `intervalGlueFin` (generalized over an
    ambient superset `M₁ ⊆ M ⊇ M₂` — avoids `∪` in types), `mem_intervalGlueFin`,
    `intervalHoldsFin_glue_iff`
  - §10.2 `chainIntervalTypeFin`, `choiceCompatible`
  - §10.3 `mergedFormulaFin`, `conjInterleaveFin`, membership assembly/extraction
  - §10.4 slot-placement transcriptions (`chain_interval_clauseFin`,
    `chainIntervalTypeFin_eq_pointSlot`, `intervalSlot_eq_pointSlotFin`,
    `regions_of_pointSlotFin`) — verbatim: bodies never unfold the satisfaction relation
  - §10.5 `conjInterleaveFin_forward` — same sorted-union rank construction; the point-type
    choice is CANONICAL (`pt j := charTypeFin N (mergedM ψ₁ ψ₂) (w j)`), making the point clause
    trivial and compat/cross discharge by uniqueness readback
  - §10.6 `conjInterleaveFin_backward`, `conjInterleaveFin_iff`
  - §10.7 `veeSatFin_flatMap`, `veeConjFin`, `veeConjFin_iff`,
    `conjInterleaveFin_pin_strictMono`, `veeConjFin_pin_strictMono` (the `VeeConj.lean` content
    lives HERE per one-file-per-commit discipline; migrate consumers to these names later)
- ZERO alphabet instances in §10; `Finset.univ` only over `Fin` index types and
  `UnaryTypeFin _ _ M` (M-finite, the `intervalTopFin` precedent).
- `#lean_verify Kamp.veeConjFin_iff` = `[propext, Classical.choice, Quot.sound]`.
- Full `lake build` EXIT 0 (1772 jobs). Sorry census cross-check: compiler count unchanged
  (the 3 permitted live sorries + Boneyard only).

## Key Decisions Made

1. **`intervalGlueFin` is generalized over an ambient superset** (`h₁ : M₁ ⊆ M`, `h₂ : M₂ ⊆ M`)
   rather than stated on `M₁ ∪ M₂` — keeps `∪` (and its `DecidableEq` demand) out of types;
   `mergedM` is the only union site.
2. **Guard-hook workaround**: multi-line commit messages containing hyphenated words (e.g.
   "slot-placement") false-positive the `git commit -a` over-staging scan (quote-stripping is
   per-line). Use `git commit -F <file>` for such messages.
3. The route/naming decisions of the item-2 handoff (Fin suffix convention, same-file privates,
   classical decidability at use sites, never `[Fintype sig.preds]`) all held and were applied.

## What NOT to Try (carried forward + new)

- Do NOT re-derive render correctness at the `Prop35*` step — promote the probe proof.
- Do NOT thread `[Fintype sig.preds]`/`DecidableEq sig.preds` into any Fin-layer declaration.
- All task-level prohibitions hold: no chain_split; EANegation charter anchors untouchable; no
  full-alphabet `Finset.univ`; a red obligation is STOP + handoff, never a hole.
- Per-file-build any off-path file you touch.

## Remaining Goals (plan v24, 4a-4 checklist)

- [ ] `Prop35ExistsForall.lean` / `Prop35Assembly.lean` / `Prop35Chain.lean` (item 4; promote
      `RenderGate.translateProp35Fin_correct`)
- [ ] `Prop42ExistsForall.lean` (item 5)
- [ ] `EFSatNegationGeneral.lean` / `VeeSatNegation.lean` / `VVecEA2Collapse.lean` (item 6)
- [ ] `Prop43Translate.lean` (item 7)
- Then Phase 4b (`LiftPair.lean`, hardest, last and alone), 4c (switchover + deletions),
  4-flip (`sigE` summand flip), Phase 5.

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted literal sorries (`KampPrior.lean:562`
`nf_nvar_exist_all_depths | _k+2` arm; `EANegation.lean:1090`; `EANegation.lean:1249` — anchor
by declaration, positions drift). Nothing introduced this dispatch (§10 is sorry-free).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
- Prior handoffs: `phase-4a-4-item2-handoff-20260723.md` (the ConjInterleave scoping this
  dispatch resolved), `phase-4a-4-handoff-20260723.md` (Decisions 1-4, incl. the Prop35
  promotion), `phase-4a-1-handoff-20260723.md`, `phase-4a-R-handoff-20260723.md`
- Key files: `Kamp/ConjInterleave.lean` §10 (this dispatch), `Kamp/ExistsForallLemmas.lean` §9,
  `Kamp/PerFormulaExistsForall.lean`, `Kamp/PerFormulaType.lean` §3,
  `Kamp/PerFormulaRenderProbe.lean` (Prop35 promotion source, NEXT)
- Rabinovich anchors: Def 3.1 (PDF p.4), Lemma 3.2(1) (p.4), Lemma 3.4 (p.5), Prop 3.5 (p.5) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt).
