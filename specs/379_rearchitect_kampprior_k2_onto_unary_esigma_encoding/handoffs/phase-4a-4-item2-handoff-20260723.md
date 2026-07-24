# Phase 4a-4 item 2 handoff — ExistsForallLemmas Fin layer landed; ConjInterleave scoped

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: `b0cecf3ca` (4a-4 item 2: ExistsForallLemmas Fin-variants) — 1 green
  commit on top of green_head `9724c133a` (whose code head is `bd5f253e6`).

## Immediate Next Action

**Phase 4a-4 item 3: `ConjInterleave.lean` (`conjInterleaveFin` / `veeConjFin`)** — a FULL sub-run
of its own (997 lines, forward proof ~180 lines, backward ~130, plus a genuine design decision;
see "ConjInterleave scoping" below). Then continue in plan order: `Prop35*` (PROMOTE
`RenderGate.translateProp35Fin_correct` from `PerFormulaRenderProbe.lean` into
`Prop35Assembly.lean` — Decision 1 of `phase-4a-4-handoff-20260723.md` still stands) →
`Prop42ExistsForall` → negation stack → `Prop43Translate`; then 4b (LiftPair, last and alone),
4c, 4-flip.

## Current State

- **4a-4 item 2 COMPLETED** (commit `b0cecf3ca`). `ExistsForallLemmas.lean` gained §9 (sub-namespace
  `Kamp`, +601 lines), the complete Fin mirror of the efSat lemma layer on
  `ExistsForallFormulaFin`/`efSatFin`:
  - §9.1 conjunctive dual: `ConjExistsForallFin`, `conjSatFin`, `conjSatFin_{nil,cons,append}`
  - §9.2 `pairProjectFin`, `pairwiseProjectionsFin`, `lemma_32_2_forwardFin`
  - §9.3 `dropPinFin`, `lemma_32_3Fin`, **`VeeExistsForallFin`/`veeSatFin`** (the per-formula
    ∨∃∀ object now lives HERE, not in `VeeExistsForall.lean`), `veeSatFin_exists`
  - §9.4 `pairwiseProjectionsFin_sat`, `pairProjectFin_pins`, `env_lt_of_pin_lt_fin`,
    `env_eq_of_pin_eq_fin`, `pointType_holds_at_env_fin`, `partialHolds_subinterval`
  - §9.5 `existenceSentenceFin`, `AugConjExistsForallFin`, `augConjSatFin`, `augTargetFin`,
    `augTargetFin_forward`, `augTargetFin_backward_zero`
  - §9.6 private gluing infra (`pinnedPositionsFin` … `gluedChainFin_*`), `augTargetFin_backward`,
    `augTargetFin_iff`
  - All proofs are verbatim transcriptions (the constructions are representation-independent —
    the seven-clause satisfaction shape is identical; `partialHolds`/`intervalHoldsFin`/
    `ψ.intervalType` substitute `unaryHolds`/`intervalHolds`/`ψ.intervalSet`). First-pass green.
  - ZERO alphabet instances in §9 (`Fintype sig.preds` nowhere); the only `Finset.univ` is over
    `Fin r` (free-variable indices) in `pinnedPositionsFin` — documented in-source.
- **NOTE**: `ExistsForallLemmas.lean` is in the DEFAULT build (imported by `WeakCanonical.lean`),
  so `PerFormulaExistsForall.lean` (new import) is now also in the default build. Build green.
- `#print axioms Kamp.augTargetFin_iff` = `[propext, Classical.choice, Quot.sound]`;
  `completeness_discrete` axiom baseline byte-identical
  (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`).
- Full `lake build` EXIT 0 (1772 jobs).

## ConjInterleave scoping (read this before starting item 3)

The item-2 pattern (verbatim mirror) does NOT apply. Findings from a scoping read of
`ConjInterleave.lean` §1-6 and `PerFormulaType.lean` §1-4:

1. **The design crux**: `mergedFormula`'s Fin-variant needs a merged atom set `M := ψ₁.M ∪ ψ₂.M`.
   At a merged point pinned by chain 1 ONLY, the total version's merged pointType is just
   ψ₁'s complete type (cross-consistency handles chain 2's interval constraint via MEMBERSHIP
   `ψ₁.pointType i₁ ∈ ψ₂.intervalType (intervalSlot …)`). On the Fin side a single
   `UnaryTypeFin (M₁ ∪ M₂)` CANNOT express "c₁ on M₁ ∧ (∨ of ψ₂'s partial interval types on
   M₂)" — the M₂∖M₁ atoms are constrained disjunctively. Candidate resolution, faithful to
   Prop 3.5 (p.5): let the Fin disjunction ALSO range over **M-relative completions** — per
   cross point, a choice of `c₂` in the (M₂-relative, hence M-finite) interval set, extending
   `c₁` to `M₁ ∪ M₂`. This multiplies disjuncts finitely FROM `M` ALONE — never alphabet-sized.
   Decide this at the start of the sub-run; it may warrant checking Rabinovich Lemma 3.2(1)
   (PDF p.4) for how the paper conjoins point-vs-interval constraints.
2. **Building blocks that already exist** (`PerFormulaType.lean` §3): `restrict : UnaryType →
   UnaryTypeFin M` and `weaken : M ⊆ M' → UnaryTypeFin M' → UnaryTypeFin M`. An EXTENSION map
   (combine `c₁ : UnaryTypeFin M₁` and `c₂ : UnaryTypeFin M₂` agreeing on `M₁ ∩ M₂` into
   `UnaryTypeFin (M₁ ∪ M₂)`) does NOT yet exist and will be needed.
3. **`pointConsistent` Fin-variant** compares partial types across different `M`s — state it on
   the `M₁ ∩ M₂` overlap via `weaken` (agreement on shared atoms), NOT as bare equality.
4. **`crossConsistent` Fin-variant**: membership of (the restriction of) a partial point type in
   the other chain's partial interval set — mind the `M` domains.
5. **Enumeration**: `MergePair` and its `Fintype` are pure `Fin` combinatorics — reusable as-is
   (no Fin-variant needed). The `Decidable` instances for the Fin-variant `valid`/consistency
   predicates need the classical M-relative route (Decision 3 of the prior handoff): `open
   Classical in`, never `[Fintype sig.preds]`.
6. **Bridge option**: `conjInterleaveFin_iff` may alternatively be proved by transporting
   `conjInterleave_iff` through `efSatFin_iff_efSat_completions` — but the commutation
   `toTotal (mergedFormulaFin …) ~ mergedFormula (toTotal …)` is itself nontrivial because
   `toTotal` needs a choice of point-type completions. Evaluate both routes; direct re-proof on
   partial relations may be no harder (the item-2 experience: partial-relation transcription was
   verbatim where clause shapes match).

## Key Decisions Made

1. **`VeeExistsForallFin`/`veeSatFin` live in `ExistsForallLemmas.lean` §9.3** (not
   `VeeExistsForall.lean`): keeps one-file-per-commit discipline; `ConjInterleave.lean` already
   imports the total layer and will import `ExistsForallLemmas` (or the consumer does) for the
   Fin Vee object.
2. **Naming convention for the Fin layer**: defs/structures get a `Fin` suffix on the object
   segment (`conjSatFin`, `pairProjectFin`, `augTargetFin_iff`); where the total name has no
   object segment, `_fin` is appended (`env_lt_of_pin_lt_fin`).
3. **Same-file privates are reusable**: `dite_max'_congr`/`dite_min'_congr` (total §8) serve the
   Fin gluing too — `private` is file-scoped, not namespace-scoped.

## What NOT to Try

- Do NOT mirror ConjInterleave verbatim the way item 2 was mirrored — the merged-`M`
  heterogeneity makes the point-type layer genuinely different (see scoping above).
- Do NOT thread `[Fintype sig.preds]` into any Fin-layer declaration (prior handoff Decision 3).
- Do NOT re-derive render correctness at the `Prop35*` step — promote the probe proof.
- All prior prohibitions hold: no chain_split; EANegation charter anchors untouchable; no
  full-alphabet `Finset.univ`; a red obligation is STOP + handoff, never a hole.
- Per-file-build any off-path file you touch (`InfAlphabetProbe` lesson).

## Remaining Goals (verbatim from plan v24, 4a-4 checklist)

- [ ] `ConjInterleave.lean`: `conjInterleaveFin` / `veeConjFin` via the bridge.
- [ ] `Prop35ExistsForall.lean` / `Prop35Assembly.lean` / `Prop35Chain.lean`: switch the
      exists-forall chain to the Fin renderer `unaryToFormulaFin`;
      `translateProp35Fin`/`translateProp35Fin_correct`.
- [ ] `Prop42ExistsForall.lean`: Fin-variant.
- [ ] `EFSatNegationGeneral.lean` / `VeeSatNegation.lean` / `VVecEA2Collapse.lean`: Fin-variants
      of the beta/gamma negation stack (SHAPE survives; enumeration becomes `M`-relative).
- [ ] `Prop43Translate.lean`: `M`-relative delta-translate filter Fin-variant (preserve the
      report-15 `StrictMono psi.pin` conclusion-strengthening).
- Then Phase 4b (`LiftPair.lean`, hardest, last and alone), Phase 4c (switchover + deletions),
  Phase 4-flip (`sigE` summand flip), Phase 5.

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted literal sorries (`KampPrior.lean:562`
`nf_nvar_exist_all_depths | _k+2` arm; `EANegation.lean:1090`; `EANegation.lean:1249` — anchor
by declaration, positions drift). Nothing introduced this dispatch (§9 is sorry-free, axioms
`[propext, Classical.choice, Quot.sound]`).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
- Prior handoffs: `phase-4a-4-handoff-20260723.md` (Decisions 1-4 all still in force),
  `phase-4a-1-handoff-20260723.md`, `phase-4a-R-handoff-20260723.md`
- Key files: `Kamp/ExistsForallLemmas.lean` §9 (new Fin layer), `Kamp/PerFormulaExistsForall.lean`
  (Fin object + bridge), `Kamp/PerFormulaType.lean` §3 (`restrict`/`weaken`),
  `Kamp/ConjInterleave.lean` §1-6 (item-3 target), `Kamp/PerFormulaRenderProbe.lean`
  (Prop35 promotion source)
- Rabinovich anchors: Lemma 3.2 (PDF p.4), Lemma 3.2(1) point-vs-interval conjunction (p.4),
  Lemma 3.4 (p.5), Prop 3.5 (p.5) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt).
