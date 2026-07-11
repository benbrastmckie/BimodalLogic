import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneFlattenNavigable
import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure
import Mathlib.Data.List.Permutation
-- NOTE (task 309 Phase 13.1): `import ...Kamp.EANegationClosure` lands the import edge
-- authorized by plan v6 (report 05 §d, verified on paper; compile-verified this dispatch).
-- Cycle-free: only KampPrior imports this file, and EANegationClosure's transitive closure
-- (EANegation, VecEAClosure, VecEAFormula, PriorINF, ExistsForallNF, PriorDefs, MonadicFO,
-- Table) reaches neither KampPrior nor this file. It transitively supplies PriorINF
-- (`HasAttainedINF`/`prior_hasAttainedINF`, PriorINF:202/:224) and the Lemma 5.1/Cor 5.4/
-- Prop 4.2 negation-stack assets consumed by Phases 13.2-13.4.
-- NOTE (task 309 Phase 13.0): `import ...WeakCanonical.PriorDefs` supplies
-- `semantic_prior_UZ`/`semantic_prior_SZ` (PriorDefs:22/:33) for the F2 decision-probe verdict
-- record at the bottom of this file. Cycle-free: PriorDefs imports only `...WeakCanonical.Table`
-- (already in this file's transitive closure); nothing in PriorDefs' closure imports this file.
-- NOTE (task 311 Phase 4): `import Mathlib.Data.List.Permutation` supplies
-- `List.mem_permutations` (arrangement-disjunct membership ↔ `List.Perm`), consumed by the
-- soundness direction of the V-carrier. Mathlib-only; no project-file import added.
-- NOTE (task 311 Phase 1): `import ...Kamp.NfEFold` is cycle-free — NfEFold imports only
-- `...WeakCanonical.NormalForm` and `...Kamp.NfDepth0Generalized` (NfEFold.lean:1-2), neither of
-- which imports this file. It supplies the task-310 E[Σ]-fold assets (`efold_of_nf1`,
-- `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, the depth-0 split kit) consumed by the
-- k=1 fold carrier `bracketEndChar_k1` below.
-- NOTE (task 307 Phase 7): `import ...KampPrior` was REMOVED to break the import cycle that blocked
-- wiring this bridge into `KampPrior.lean:391`. The two symbols this file used from KampPrior
-- (`nf_quant_clause_tl`/`_correct`, `atomKind_arity1_is_pred`) were relocated to
-- `NfDepth0Generalized` and reach here transitively via `NfZoneFlattenNavigable`.
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.RefutationF2
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2V
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.NavigatedSpine
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorZoneTriage

/-!
# Multi-Anchor Characteristic Formula Bridge (task 308)

A new **leaf** file (nothing imports it; it imports nothing beyond
`NfZoneFlattenNavigable` — which transitively pulls `VecEATranslation`,
`NfZoneDepthK`, `NfDepth0Generalized` — and `KampPrior`). It hosts the
sorry-free depth-graded two-anchor characteristic-formula bridge deliverables.

## Deliverables (built across the task-308 phases)
1. `nf_char2_formula : NormalForm sig (k+1) 2 → Formula` (Phase 3).
2. `nf_zone_flatten_navigable` at arbitrary depth `k` (Phase 5).

## This file — Phase 1 (bottom-of-recursion bases)
- `nf_char2_atom_layer`: the **diagonal depth-0 atom-layer** iff — the depth-0
  characteristic formula of an arity-1 NF characterizes the arity-2 evaluation of
  its diagonal value-duplication `diagDup` on the constant env `[t,t]`. Built from
  `nf_depth0_char_formula` + `diagDup_eval_zero` (i.e. `renameNF_eval_diag0`).
- `nf_zone_flatten_navigable_zero`: the `k = 0` base of deliverable 2 — the arity-3
  tail-diagonal existential of a duplicated NF `diagDup3` on `[w,t,t]` equals the
  arity-2 existential on `[w,t]`. Endpoints are atom/anchor types via
  `renameNF_eval_diag0`; **no `bracketBuild*` navigation yet**.

## Postmortem forbidden-route list (BINDING — read before writing any construction)

Every future dispatch on this file MUST check each candidate construction against
these three refuted routes (task-305 Phase-11b lineage + task-307 blocker audit):

- **(a) Do NOT** re-attempt a projection-based VecEA2 bridge for the `x=t` diagonal
  case. `liftIdx(totalUnskip)` is non-injective; the coupled quant layer does not
  factor through per-variable projections. Split the coupled `∃w` **directly** on the
  full env `[w,x,t]` (`exists_nested_split3` / `exists_trichotomy_split`) and discharge
  through `nf_char3_eq_succ_iff`'s joint decomposition — never per-variable projection.
- **(b) Do NOT** re-attempt a flat single-interval atomic bracket absorption. A depth-0
  atomic `BracketFormula` is confined to `[x,t]` and cannot capture exterior-`w`
  realizability. Endpoint types MUST be **navigated** recursive `bracketBuild*`
  `TemporalPred`s, not depth-0 atomic brackets.
- **(c) Do NOT** re-attempt an arity-1-collapse repair for the diagonal arm
  (`char_k1 (diagCollapse sub_nf)`). At depth `k+1` this is the documented **non-theorem**
  (`NfDepth0Generalized.lean:1691-1719`; `liftIdx r` non-injective, `←` fails).

**Settled**: the diagonal collapse (`renameNF_eval_diag0`) is used **only at the depth-0
atom layer**, where it is a proven iff. The depth-`(k+1)` quant layer goes through the
honest arity-3 navigated existential — **never** collapsed to arity 1.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Cor 5.4 (`F_i` chain).
- `specs/308_multi_anchor_char_formula_bridge/plans/01_multi-anchor-bridge-plan.md`
- `specs/308_multi_anchor_char_formula_bridge/reports/01_multi-anchor-bridge-research.md`
-/
