# Phase 4a-4 item 3 summary — ConjInterleave Fin layer (conjInterleaveFin / veeConjFin)

- **Task**: 379 — plan v24, Phase 4a-4 consumer migration, item 3 (full sub-run)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Status**: item COMPLETED; Phase 4 continues at item 4 (Prop35*)

## What was done

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean` gained §10 (sub-namespace
`Kamp`, +827 lines; file 998 → 1824 lines): the complete per-formula (Fin) mirror of the
Lemma 3.2(1)/3.4-∧ layer, ending in `conjInterleaveFin_iff` and `veeConjFin`/`veeConjFin_iff`.

### Design decision (the item-2 scoping crux, resolved)

Adopted **M-relative completions in the disjunction**, anchored to Rabinovich Lemma 3.2(1)
(PDF p.4): each disjunct is a `MergePair` together with a per-merged-point choice
`pt : Fin (k+1) → UnaryTypeFin sig F (mergedM ψ₁ ψ₂)`, filtered by `choiceCompatible`
(restriction equations to each chain's point types; cross-membership of the other-chain
restriction in the other chain's interval set at the enclosing slot). Licensed by Def 3.1 (p.4:
point predicates are arbitrary quantifier-free 1-formulas) + the disjunction-of-∃∀ conclusion of
Lemma 3.2(1); Prop 3.5 (p.5) translatability preserved. Finite from mentioned atoms alone —
no alphabet instance anywhere in §10.

### Proof route

Direct re-proof on partial relations (scoping note 6 evaluated: bridge transport would need a
nontrivial `toTotal` commutation with its own completion choice). `partialHolds_eq_charTypeFin`
is the uniqueness engine replacing `nf_eval_unique`; the forward witness uses the CANONICAL
choice `pt j := charTypeFin N (mergedM ψ₁ ψ₂) (w j)`, making the merged point clause trivial.
Slot-placement lemmas transcribed verbatim (bodies never unfold the satisfaction relation).

## Commits (all green, per-file build at each)

| Commit | Content |
|---|---|
| `02ac3cd85` | §10.0-10.3: leaf lemmas, `mergedM`, `intervalGlueFin` + glue iff, `chainIntervalTypeFin`, `choiceCompatible`, `mergedFormulaFin`, `conjInterleaveFin`, membership assembly/extraction |
| `0624dc6d1` | §10.4: slot-placement transcriptions |
| `c9e6c0afe` | §10.5: `conjInterleaveFin_forward` |
| `6ffc98556` | §10.6-10.7: backward direction, `conjInterleaveFin_iff`, `veeSatFin_flatMap`, `veeConjFin`, `veeConjFin_iff`, pin-strictMono lemmas |

## Final verification

- Full `lake build` EXIT 0 (1772 jobs); per-file `lake build …Kamp.ConjInterleave` green.
- `lean_verify Kamp.veeConjFin_iff`: `[propext, Classical.choice, Quot.sound]` — no sorryAx,
  no new axioms.
- Sorry census (`lean-sorry-census.sh --cross-check`): live sorries unchanged — exactly the 3
  charter-permitted (`KampPrior.lean:562`, `EANegation.lean:1090`, `EANegation.lean:1249`) plus
  Boneyard; zero introduced this dispatch.
- Vacuous-definition scan: none introduced.
- No alphabet instances (`Fintype sig.preds`/`DecidableEq sig.preds`) in §10; the one classical
  `DecidableEq` site is confined to `mergedM`.

## Plan deviations

- *(altered)* Checklist wording "via the bridge": implemented by direct re-proof on partial
  relations rather than transport through `efSatFin_iff_efSat_completions` — sanctioned by the
  item-2 scoping which left the route open; annotated inline in plan v24.
- `veeConjFin` and its lemmas live in `ConjInterleave.lean` §10.7 (not a new `VeeConjFin`
  home) per the one-file-per-commit discipline, mirroring the item-2 `VeeExistsForallFin`
  precedent.

## Next

Item 4 (`Prop35*`): promote `RenderGate.translateProp35Fin_correct` from
`PerFormulaRenderProbe.lean` into `Prop35Assembly.lean` (do NOT re-derive), switch the chain to
`unaryToFormulaFin`. Handoff:
`handoffs/phase-4a-4-item3-handoff-20260723.md`.
