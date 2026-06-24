# Phase 1 Gate Handoff — Boneyard Triage + Prop 4.3 Decision Gate

- **Task**: 305 (rabinovich_ea_formula_implementation, lean4)
- **Plan**: plans/37_faithful-rabinovich-path.md (v37 faithful Rabinovich path)
- **Session**: sess_1782337996_6c54a7
- **Date**: 2026-06-24
- **Phase**: 1 of 6 — read-only triage spike + decision gate (no live-path .lean edits)

---

## GATE VERDICT: REBUILD

Phase 4 will **reconstruct Prop 4.3 fresh** from Rabinovich §4 (atomic / disjunction /
negation-via-Prop-4.2 / existential-via-Lemma-3.4, no depth parameter, arity ≤ 2).
REVIVE is **impossible** — there is no archived structural Prop 4.3 to revive.

### Why REBUILD (decisive evidence)

1. **`Kamp/Boneyard/Prop43.lean` is the WRONG asset.** It is NOT the structural
   FO-induction Prop 4.3. Its actual contents are `nf_quant_clause_tl`,
   `nf_succ_char_formula`, `nf_succ_char_formula_correct`, `nf_2var_exist_depth0_tl_fn`
   — i.e. the **depth-(k+1) NF-characterization / arity-tower machinery**. Its own
   header (lines 24–30) states: *"At k>0: Requires depth-k arity-2 existential
   conversion, which involves depth-(k-1) arity-3 NFs (arity tower obstruction)."*
   It is sorry-free, but reviving/wiring it would **reintroduce the forbidden NF-depth
   recursion** the plan explicitly removes (Non-Goals; report 37 §4). Forbidden.

2. **No live `StructuralInduction.lean` exists anywhere.** `KampPrior.lean:28` references
   `StructuralInduction.lean` as the home of Prop 4.3, but `find Theories -name
   StructuralInduction.lean` returns nothing. The structural Prop 4.3 has never been
   built. So there is no archived proof to lift.

3. **Decision criterion result**: REVIVE requires "Prop43 compiles with ≤ 2 named gaps
   mapping exactly to Phase 2 / Phase 3, no NF-depth, no arity-3+." Prop43 fails this on
   every clause: it IS the NF-depth/arity-tower construction. Criterion → REBUILD.
   (Ambiguity would have defaulted to REBUILD anyway; this is not ambiguous.)

---

## Baseline (confirmed GREEN, unchanged this phase)

- `lake build Bimodal.Metalogic.Metalogic` → **GREEN, 1671 jobs**.
- `completeness_discrete` axioms: `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
  Lean.trustCompiler, Quot.sound]`. **This is the baseline axiom set.** `sorryAx` present
  (traces to the 2 live sorries below). No new top-level axioms.
- Live-path sorries on the discrete chain: **2** — `KampPrior.lean:391` (n=1 arm) and
  `KampPrior.lean:394` (n≥2 arm), both inside `nf_nvar_exist_all_depths`.

## The live obstruction (precise)

`nf_nvar_exist_all_depths` (`KampPrior.lean:252–394`) is the arity-tower depth recursion.
- `k=0` arm: sorry-free (`nf_nvar_exist_depth0_tl_fn`).
- `k+1, n=0` arm: sorry-free (uses `char_k1` = `nf_succ_char_formula`).
- `k+1, n=1` arm (`:391`): **sorry** — needs a depth-(k+1) arity-2 existential converter
  that does not exist (report 37 §2.3, MCP-confirmed type wall). THE critical-path sorry.
- `k+1, n+2` arm (`:394`): **sorry** — documented off-critical-path (main theorem needs
  only n=0, n=1). Phase 6 will confirm reachability via `lean_verify`.

**Consumer scope**: `nf_nvar_exist_all_depths` has NO external live consumer — it is
referenced only inside `KampPrior.lean` (via `nf_nvar_exist_all_depths_fn` →
`nf_characterizable_temporal_prior` → `nf_succ_char_formula` chain). Only
`PriorExpressiveness.lean` imports `KampPrior` (live); `Boneyard/KampNegationClosure/
NegationClosure.lean` is off-path. This means Phase 5's re-anchor can replace the
`nf_nvar_exist_all_depths` route at `:391` without disturbing external callers — the
re-wire surface is contained.

## Faithful asset inventory (all sorry-free unless noted) — REUSE, do not rebuild

| Asset | File | Status |
|---|---|---|
| Def 3.1/3.3 V-EA types | `VecEAFormula.lean` | sorry-free |
| Lemma 3.2(1) conj + V-EA closure | `VecEAClosure.lean` | sorry-free (0) |
| Lemma 3.4 arbitrary-arity ∃-closure | `VecEA_m.lean` | sorry-free (0): `VecEA_m.existClosure` + `existClosure_correct` (:245) + `existClosure_correct_rev` (:314) — **bidirectional** |
| Prop 3.5 translate_correct | `RabinovichTranslation.lean` | sorry-free (0): `ExistsForallSpec.translate_correct` (:200) |
| Prop 4.2 model-DEPENDENT + Lemma 5.1 | `EANegationClosure.lean` | sorry-free (0) |
| VecEA decomposition | `VecEADecomp.lean`, `VecEATranslation.lean` | present |
| Prop 4.2 model-INDEP forward | `NegationIndep.lean:319` | `neg_2var_vec_ea_indep_correct` sorry-free |

**ALL of these are OFF the live import path** of `KampPrior` (which imports only
ExistsForallNF, NfToVecEA, NfDepth0Generalized). Phase 5 rewires imports to bring them on.

## The 3 real gaps (per report 37 §4.4)

1. **Lemma 3.2(2) arity firewall** (Phase 2) — no live identifier exists. The piece that
   *prevents* the arity tower. Target file: `VecEAClosure.lean` or new firewall module.
2. **Prop 4.2 model-independent backward** (Phase 3) — `NegationIndep.lean:331`. ⚠️ **HIGH
   RISK / likely BLOCKED**: the NOTE at `:331–347` states this was attempted and found
   **UNFIXABLE at the BracketFormula level** (report 18 §4 definitive analysis): V-bracket
   formulas are existentially quantified but the backward direction needs universal
   quantification over per-model bracket-witness arrangements. The NOTE explicitly says
   this **does NOT block completeness** because the model-DEPENDENT `neg_interval_formula`
   (in `EANegationClosure.lean`, sorry-free) suffices. **Plan's Phase 3 contingency
   (line 226) already anticipates this**: if backward resists after a bounded budget,
   STOP, record divergence, and wire Prop 4.3 with the model-DEPENDENT Prop 4.2 as a
   documented interim. The next dispatch should budget Phase 3 cautiously and lean on
   the model-dependent form rather than re-litigating the unfixable BracketFormula gap.
3. **Prop 4.3 structural FO induction** (Phase 4, **REBUILD mode**) — build fresh, no
   archived asset. Replaces `nf_nvar_exist_all_depths`.

## Import-rewire surface (for Phase 5)

Current KampPrior imports: `ExistsForallNF`, `NfToVecEA`, `NfDepth0Generalized`,
`NormalForm`, `PriorDefs`, `Separation.KampTranslation`.
Must ADD (Phase 5): the module hosting the rebuilt Prop 4.3 (e.g. new
`Kamp/StructuralInduction.lean` or `Kamp/Prop43.lean`), which transitively pulls in
`VecEA_m`, `RabinovichTranslation`, `NegationIndep`, `VecEAClosure`, `EANegationClosure`.
Cycle risk: LOW — these faithful modules do NOT import `KampPrior` (verified: only
`PriorExpressiveness` and an off-path Boneyard file import KampPrior). Verify acyclicity
with a build BEFORE touching `:391`.

## Forbidden (do NOT take under any failure)

Route A′ in-situ zone-split; Route B re-anchor; any NF-depth/arity-tower reintroduction
(including reviving `Kamp/Boneyard/Prop43.lean`); `nf_succ_char_formula2` / single
pair-`Formula`. All refuted (report 37), stay closed.

---

## Next action (next dispatch)

Phase 2 (Lemma 3.2(2) arity firewall) and Phase 3 (Prop 4.2 model-indep backward) are
Wave 2 — independent, gate now settled. Recommend starting Phase 2 (lower risk, the
firewall is a clean construction reusing Lemma 3.2(1) conjunction closure). Budget
Phase 3 cautiously given the documented unfixable-at-BracketFormula risk; fall back to
the model-dependent Prop 4.2 interim per plan line 226 rather than churning.

**No live-path .lean edits were made this phase.** Baseline preserved exactly.
