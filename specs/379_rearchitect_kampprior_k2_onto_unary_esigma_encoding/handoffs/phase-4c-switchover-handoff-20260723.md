# Phase 4c switchover + deletions handoff — COMPLETE

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784869380_2459bd
- **Date**: 2026-07-23
- **Commits this dispatch** (4 green commits on top of `45210eb91`, every batch first-verified
  by scoped build, final batch by FULL `lake build` EXIT 0, 1772 jobs):
  - `5ccf55e8b` — delete the `completions` bridge (PerFormulaType §4: `completions`,
    `mem_completions`, `intervalHolds_completions_iff`; PerFormulaExistsForall §2-3:
    `completionsSet`, `intervalHolds_biUnion_completions_iff`, `toTotal`,
    `efSatFin_iff_efSat_completions`). Zero consumers outside the two home files.
  - `7119839e3` — negation-stack totals (2,247 lines): Prop43Translate
    (`translate_correct`, `ex_closure_translate`, total `renamePin`/`efSat_renamePin`/
    `veeSat_renamePin`, `skelDisjunct_efSat`, `atomEmit`(+`_iff`),
    `strictMono_of_veeSat_pin_mono`); VeeSatNegation totals; EFSatNegation totals;
    EFSatNegationGeneral §1-4 (with `order_point_forall_iff` retained — instance-free,
    Fin-consumed); Prop42NegationGeneral §1-5; VVecEA2Collapse totals (with
    `exists_piFinset_forall_iff` retained — generic, Fin-consumed).
  - `7a41a4385` — conjunction engine + Prop42 totals (2,346 lines): LiftPair total sections
    (kept: `LiftMergePair` + `equivProd` + `Fintype` instance + `valid`/`valid1`/`validS` +
    `Decidable` instances — index-level, reused verbatim by the Fin layer); ConjInterleave
    §2/§4-4a/§5/parts of §6/§6a/§6aa/§7/§8/§9 (kept: §1 `belowCount`/`intervalSlot`, §3
    `MergePair` family, `mergedSet`(+`_card_succ`), §6b rank lemmas, §6c
    `strictMono_lt_iff_val_lt_filterCard` — all Fin-consumed); Prop42ExistsForall §1-4;
    **`VeeConj.lean` DELETED whole-file** (importers LiftPair/VeeSatNegation repointed —
    `veeConjFin` lives in ConjInterleave §10.7 and is reachable transitively).
  - `825b1be1d` — lemma layer + interval algebra (702 lines): ExistsForallLemmas §1-8
    (the two `private` `dite_max'_congr`/`dite_min'_congr` helpers restored inline — §9.6
    Fin gluing consumes them); IntervalType §2-3 (kept: `efSat_interval_iff` +
    `intervalSet`, pinned by Prop35Assembly).

## Immediate Next Action

**Phase 4-flip: terminal `sigE` summand flip `{A // A ∈ F}` → `Formula`** (plan v24, its own
dispatch — do NOT fold into anything else). Read the plan's 4-flip section first. Note for the
grep-guard step: the remaining `Finset.univ` at `UnaryType`-typed sites live in the
generic-`sig` Prop35 renderer layer (`Prop35Assembly`/`Prop35ExistsForall`, pinned by the live
Phase-1 gate `InfAlphabetProbe`) and in `ESigmaCapture` (Phase-5 deletion scope) — these are
generic declarations with `[Fintype sig.preds]` BINDERS, not `sigE`-instantiated enumerations,
so they compile unchanged after the flip; only instantiations at `sigE` would break, and the
audit found none in the live closure.

## Current State

- The exists-forall chain is Fin-only end to end: `translate_correctFin` and
  `efSat_negation_generalFin` re-verified axiom-clean (`[propext, Classical.choice,
  Quot.sound]`, lean_verify, no warnings) AFTER the deletions.
- `#print axioms completeness_discrete` unchanged from baseline:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  (the `sorryAx` is the charter-permitted KampPrior `_k+2` residual; spine untouched — no
  KampPrior/BXCanonical/Decidability file was edited).
- ~5,500 lines of total-alphabet twins deleted; 0 new sorries, 0 vacuous defs, 0 new axioms.
- Kamp-zone live sorries: exactly the 3 permitted (`KampPrior.lean` `nf_nvar_exist_all_depths`
  `| _k+2` arm, ~:562; `EANegation.lean` :1090, :1249 — anchor by declaration, lines drift).
  Pre-existing sorries in `OrderedSum.lean`/`Expressiveness/DConsistencyTransport.lean` are
  OUTSIDE the task zone, predate this dispatch, and were not touched.
- The 4c "repoint" task resolved as VACUOUS by audit: KampPrior never imported the chain;
  after 4a/4b no live total consumption remained to repoint; the actual KampPrior wiring is
  Phase 5 by the plan's own Prohibited clause. Recorded as a deviation annotation in the plan.

## Key Decisions Made

1. **Live-closure test for "now-unconsumed"**: a consumer counts only if it is in the default
   `lake build` target closure (olean freshness cross-check + import audit).
   `ZetaUniformExtract.lean` — the biggest apparent pin — is orphaned (nothing imports it),
   outside the default target, and was already 68-errors RED at pre-dispatch HEAD
   (machine-verified via git stash + scoped build), so it pins nothing. Same for
   `ZetaEngineClosure`/`ZetaPriorTransfer`/`HCaptureDischarge`/`Prop35VeeLift`/
   `MonadicFormulaMap`/`OptionBLocalityProbe` (stale oleans).
2. **Honored live pins** (these totals STAY until their pinning consumer dies in Phase 5, or
   forever where the pin is the preserved Phase-1 gate): `InfAlphabetProbe` →
   `translateProp35` + renderer layer + `ExistsForallFormula` object; `ESigmaCapture` → base
   `UnaryType`/`unaryHolds`/`intervalHolds`/`IntervalType`; `Prop35Assembly` →
   `efSat_interval_iff`/`intervalSet`.
3. **Kept generic substrate consumed by Fin proofs**: ConjInterleave §1/§3/§6(mergedSet)/
   §6b/§6c; Prop43Translate §0 + gap-insertion block + §2c; `order_point_forall_iff`;
   `exists_piFinset_forall_iff`; `LiftMergePair` index family; the two private dite
   congruence helpers (ExistsForallLemmas).
4. **`VeeConj.lean` deleted as a whole file** once its total decls were unconsumed — its Fin
   twins (`veeConjFin`(+`_iff`), `veeSatFin_flatMap`) live in ConjInterleave §10.7.
5. ConjInterleave's file-level `variable {sig} {F}` line sat inside a deleted span; reinserted
   as a plain (instance-free) variable line — kept decls and the Fin layer need no alphabet
   instances.

## What NOT to Try (carried forward)

- Do NOT re-derive anything in the standing do-not-retry list; chain_split remains
  non-applicable; EANegation :1090/:1249 untouchable; the `_k+2` arm is retired ONLY in
  Phase 5 (terminal).
- Do NOT delete the pinned totals listed in Key Decision 2 during 4-flip — they are
  generic-`sig` and flip-safe; their deletion (where scheduled at all) is Phase 5's
  capture-site scope.
- Do NOT resurrect the `completions` bridge to prove anything: the Fin layer is
  self-contained; any new lemma goes on the Fin side.

## Remaining Goals (plan v24)

- [ ] Phase 4-flip: terminal `sigE` summand flip (next dispatch)
- [ ] Phase 5 (ζ re-wire; retires the `_k+2` arm LAST)

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted sorries (KampPrior `_k+2` arm residual;
EANegation :1090; EANegation :1249). Nothing introduced this dispatch (deletions only).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md` (4c section now [COMPLETED] with deviation annotations)
- Prior handoff: `phase-4-decompose-handoff-20260723.md`
- Rabinovich anchors unchanged: Prop 4.2 (PDF p.6-7), Prop 4.3 (p.6), Lemma 3.4 (p.5),
  Def 3.1 (p.4), Def 4.1 (p.5) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt)
