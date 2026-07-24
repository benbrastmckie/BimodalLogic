# Phase 4a-1 handoff — per-formula renderer landed green

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: `9da3e1e5c` .. `eda96b0e8` (14 green commits: 13 for 4a-R, 1 for 4a-1)

## Immediate Next Action

**Phase 4a-2: render MICRO-GATE** (HARD GO/NO-GO). Define `translateProp35Fin` on a nontrivial
`n = 1` input (non-empty interval clauses) and prove it correct end-to-end through
`unaryToFormulaFin_correct`, sorry-free, WITHOUT a full-alphabet `Finset.univ` and WITHOUT
weakening any correctness statement. Probe file: extend `InfAlphabetProbe.lean` or new
`PerFormulaRenderProbe.lean`. STOP CONDITION: a red render obligation is a return-to-`/research`,
never a hole to force. See plan Phase 4a-2 block for the full gate contract.

## Current State

- **4a-R COMPLETED** (see `handoffs/phase-4a-R-handoff-20260723.md`): off-path chain 19/19 GREEN;
  breakages/census-sorries were elaboration artifacts; zero proof-content edits; amended sorry
  gate holds (only the 3 spine-permitted sorries live anywhere).
- **4a-1 COMPLETED**: new `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PerFormulaRender.lean`:
  - `atomPred1` / `atomKind1_eq_pred` / `atom_eval1_iff_interp` — total arity-1 atom classification
    (a NON-private, reusable counterpart of `Prop35ExistsForall`'s private `atomKind1_is_pred`).
  - `unaryToFormulaFin atomMap h_surj (c : UnaryTypeFin sig F M) : Formula` — conjunction of
    `atom_literal`s folding over `M.attach.toList` (per-formula-finite; no `Fintype
    (sigE sig F).preds`, no whole-alphabet `Finset.univ`).
  - `unaryToFormulaFin_correct : temporal_truth N atomMap t (...) ↔ partialHolds N c t` —
    sorry-free; `#print axioms` = `[propext, Classical.choice, Quot.sound]`.
  - Reuses `formula_conjList`/`atom_literal` FROM `Separation/KampTranslation.lean` without
    editing it (git diff empty on that file).
- Full `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline.

## Key Decisions

1. Renderer folds over `M.attach.toList` (not bare `M.toList`) because `UnaryTypeFin` consumes
   subtype elements `{a // a ∈ M}` — same `M`, subtype-carrying enumeration.
2. 4a-2 ingredients already in place: `unaryToFormulaFin_correct` (this phase),
   `translateProp35`/`translateProp35_correct` (green `Prop35Assembly` since 4a-R),
   `partialHolds`/`completions` bridge (`PerFormulaType.lean`, 4a-0).

## Sorry Inventory

Unchanged from 4a-R handoff: exactly the 3 spine-permitted literal sorries
(`nf_nvar_exist_all_depths | _k+2` arm in KampPrior.lean; EANegation.lean:1090; :1249).
Nothing introduced this dispatch.
