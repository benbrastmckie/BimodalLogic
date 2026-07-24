# Phase 4-flip terminal summand flip handoff — COMPLETE (Phase 4 CLOSED)

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784869380_2459bd
- **Date**: 2026-07-23
- **Commits this dispatch** (2 green commits on top of `0ce5987e6`'s predecessor `825b1be1d`,
  each verified by scoped build; the first also by FULL `lake build` EXIT 0, 1772 jobs):
  - `728e0586c` — the flip proper: `sigE sig F` fresh summand `{A // A ∈ F}` → `Formula`
    (infinite E[Σ], Rabinovich Def 4.1 PDF p.5); `esigmaPred A` drops `hA`;
    `sigE_fintypePreds` + unconsumed staging helper `finite_F_suffices_per_stage` deleted;
    `canonExpand` match arm `.inr A => sat A a`; `atom_eval_new` hA-dropped. ESigmaCapture:
    finite-alphabet interval-capture trio (`intervalCapture_of_atomNamed`,
    `intervalCapture_forall_mem`, `esigmaCapture_canonExpand` — the whole-alphabet
    `Finset.univ.filter` witness machinery) DELETED per the phase's Prohibited clause;
    `temporal_truth_canonExpand` KEPT verbatim; `canonExpand_atom_named` now holds for
    EVERY `Formula` (no `A ∈ F`).
  - `0ce5987e6` — `ZetaAtomMapReconcile.lean` hA-drop fallout (`collapse_leaf_fresh`,
    `reconciled_no_surj_onto_inr`), re-verified green with `MonadicFormulaMap`.

## Immediate Next Action

**Phase 5 (ζ re-wire; the ONLY live-path phase; retires the KampPrior `_k+2` arm LAST).**
Read the plan's Phase 5 section first. Consumes landed FILES `ZetaAtomMapReconcile.lean`
(post-flip green), `ZetaPriorTransfer.lean`, `MonadicFormulaMap.lean` (post-flip green).
Capture is discharged DIRECTLY: every readback is an atom of the infinite expansion
(`canonExpand_atom_named` at any `A : Formula`) — REMOVE `hCapture`/`capFn` parameters
entirely; the old `esigmaCapture_canonExpand` discharge no longer exists (deleted here).
Optional 5a/5b split per plan note. Residual deletion + `#print axioms` check MUST be
terminal.

## Current State

- Phase 4 is **[COMPLETED]** in the plan (all sub-phases 4a-0/4a-R/4a-1/4a-2/4a-3/4a-4..N/
  4b/4c/4-flip done). End-state is exactly Def 4.1 infinite E[Σ] + per-formula rep.
- Full `lake build` EXIT 0 (1772 jobs — job count unchanged from 4c baseline; the whole live
  chain was flip-safe exactly as the 4c audit predicted: all live enumeration is
  `UnaryTypeFin`/M-relative).
- `#print axioms completeness_discrete` byte-identical to baseline:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  (the `sorryAx` is the charter-permitted KampPrior `_k+2` residual; no spine file touched).
- Flipped declarations axiom-clean (`[propext, Classical.choice, Quot.sound]`):
  `atom_eval_new`, `temporal_truth_canonExpand`, `canonExpand_atom_named`,
  `collapse_leaf_fresh`, `reconciled_no_surj_onto_inr`.
- Spine-safety grep re-run: `sigE`/`UnaryType`/`IntervalType` over `BXCanonical/` +
  `Decidability/` — EMPTY.
- Task-zone live sorries: exactly the 3 permitted (KampPrior `nf_nvar_exist_all_depths`
  `| _k+2` arm ~:562; EANegation :1090, :1249). 0 new sorries, 0 vacuous defs, 0 new axioms.

## Key Decisions Made

1. **Interval-capture trio deleted, not ported.** It is a finite-alphabet encoding artifact:
   the `∃ S : IntervalType` witness is `Finset.univ.filter` over the whole `UnaryType` — after
   the flip `Fintype (sigE sig F).preds` is uninhabitable (`Formula` infinite), and over an
   infinite alphabet the finite-complete-type-cover claim is not even provable in general
   (the report-18 NO-GO content). Zero code consumers existed (docstring mentions only, all in
   orphaned ζ files). Phase 5 removes `hCapture`/`capFn` entirely, so nothing will ever consume
   it. The atomic content survives as `canonExpand_atom_named` (now unconditional in `A`).
2. **`F` parameter of `sigE` retained as `_F`** — a pure type-level stage index so every
   downstream arity (`UnaryType sig F`, `IntervalType sig F`, `ExistsForallFormula sig F r`,
   the whole Fin chain) is untouched. Only the summand changed.
3. **Files deliberately NOT touched**: `OptionBLocalityProbe.lean` (committed refutation
   record, plan-prohibited to delete), `ZetaUniformExtract.lean`/`ZetaPriorTransfer.lean`/
   `HCaptureDischarge.lean` (orphaned/stale, Phase-5 capture-site scope), all spine files.

## What NOT to Try (carried forward)

- Standing do-not-retry list unchanged: no chain_split, EANegation :1090/:1249 untouchable,
  no Feferman-Vaught/novel math, Rabinovich by PDF page only (companion .md corrupt).
- The `_k+2` arm is retired ONLY at the END of Phase 5 (terminal action, with the
  `#print axioms` check after it).
- Do NOT resurrect the deleted capture trio or the `completions` bridge for Phase 5 — the ζ
  discharge is direct (`canonExpand_atom_named`).

## Remaining Goals (plan v24)

- [ ] Phase 5 (ζ re-wire; retires the `_k+2` arm LAST) — the only remaining phase.

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted sorries (KampPrior `_k+2` arm residual;
EANegation :1090; EANegation :1249). Nothing introduced this dispatch.

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
  (4-flip section [COMPLETED] with deviation annotations; parent Phase 4 [COMPLETED])
- Prior handoff: `phase-4c-switchover-handoff-20260723.md`
- Rabinovich anchors: Def 4.1 (PDF p.5), p.6 collapse-to-atom note —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt)
