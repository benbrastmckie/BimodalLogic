# Task 352 Phase 1 Implementation Summary: Full-Fiber Content Channel + F2 Separation Probe

- **Task**: 352 - build_depthk_navigated_exterior_negation_clause_layer_via_existproviders
- **Phase**: 1 of 6 (GO/NO-GO gate) — [COMPLETED]
- **Verdict**: **GO** (postmortem rule 12 gate passed; Phases 2+ may proceed)
- **Date**: 2026-07-12
- **Session**: sess_1783886300_43b617

## Phases Executed

### Sub-phase 1.1 — channel core (`ExteriorFiberK.lean`, NEW, 139 lines)

| Decl | What it is |
|---|---|
| `kvE_fiber` | Positive-sub fiber of `σ : NormalForm sig (k+1) 4` as Fintype-backed nodup list of `s : NormalForm sig k 5` with `σ.2 s = true` (mirrors `kvE_sepPos`/`kvE2_futGapList` conventions) |
| `kvE_fiber_mem` | Membership ↔ quant-layer bit |
| `kvE_fiberPosOn` | Bucketed content disjunction: `formula_disjList (l.map (P.existF 4))` over an arbitrary sub-list `l` (G6-compliant by construction — `P.existF` applied DIRECTLY to full fiber elements) |
| `kvE_fiberPos` | Whole-fiber instance |
| `kvE_fiberPosOn_correct` | UZ/SZ-conditional: truth at `t` ↔ `∃ s ∈ l, ∃ env : Fin 4 → M.carrier, nf_eval_nf M k 5 (insertEnv env t) s` — `P.correct 4` distributed over `formula_disjList_iff` |
| `kvE_fiberPos_correct` | Headline: truth ↔ `∃ s, σ.2 s = true ∧ ∃ env, nf_eval_nf M k 5 (insertEnv env t) s` |

Rabinovich citations (mapping table rows 1-2): Def 7.5 rung-(k+1) entries are rung-k
formulas; those formulas are Def 4.1/7.7 canonical-expansion images `P.existF 4 s`
rendered by the canonical `ExistProviders` bundle consumed verbatim (postmortem rule 11).

### Sub-phase 1.2 — F2 separation probe (`ExteriorFiberProbeK.lean`, NEW, 341 lines)

Probe-local (`private`) template copies of the F2 machinery — `p2sig`/`p2atomMap`/`p2surj`/
`P2M`/`p2_int_first`/`p2_int_last`/`p2_UZ`/`p2_SZ`/`p2_eval_iff_char`/`p2_char0_congr`/
`p2env3`/`p2qnf`/`p2sub1`/`p2sub2`/`p2qnf'`/`p2estar` + entry lemmas. RefutationF2.lean
NOT edited (frozen diff empty).

Concrete provider instance: `p2P : ExistProviders p2sig p2atomMap 0` from the SORRY-FREE
depth-0 all-arity converter `nf_nvar_exist_depth0_tl_fn` (NfDepth0Generalized.lean:1615,
unconditional correctness) — no KampPrior import, no inheritance of the
`nf_nvar_exist_all_depths` n≥1 strategic sorries (verified: no `sorryAx` in axiom prints).

Separation theorems (all public, all green):
1. `kvE_fiber_separates_pair` — syntactic: `e* ∈ kvE_fiber p2sub1`, `e* ∉ kvE_fiber p2sub2`,
   WHILE `p2sub1.1 = p2sub2.1`, `nf0_zoneSpec` agrees, and `kvE_projFreshD` agrees
   (via `kvE_projFreshD_zero`) — the marginal channels provably cannot see the difference.
2. `kvE_sepPos_separates_qnf_pair` — syntactic at the exact `f2_carrier_eq` pair shape:
   `p2sub2 ∈ kvE_sepPos p2qnf`, `p2sub2 ∉ kvE_sepPos p2qnf'`.
3. `kvE_fiberPos_separates_F2` — SEMANTIC, the GO theorem: the `e*`-bucketed content
   disjunction under `p2P` is TRUE at `t = 18` for `p2sub1` (witness env `[10,12,15,2]`,
   `insertEnv` bookkeeping `p2_insertEnv4`) and FALSE for `p2sub2` (empty `e*`-bucket).

## Final Verification Results

| Check | Result |
|---|---|
| Scoped `lake build` ExteriorFiberK | GREEN (first attempt) |
| Scoped `lake build` ExteriorFiberProbeK | GREEN (first attempt) |
| sorry count (both new modules) | 0 (grep hits are docstring "sorry-free" only) |
| Vacuous-def patterns | 0 |
| New axioms | 0 |
| FORBIDDEN `nf_char3_deeper_split` | 0 uses |
| `lean_verify` axioms on `kvE_fiberPos_correct`, `kvE_fiberPos_separates_F2`, `kvE_fiber_separates_pair`, `kvE_sepPos_separates_qnf_pair` | exactly `[propext, Classical.choice, Quot.sound]` |
| Frozen diffs (7 providers + KampPrior + RefutationF2 + ExteriorBracketK + PriorInterface + Lemma32Reduction) | EMPTY at every commit |
| G6 review | clean — every content-bearing disjunct is `P.existF 4` on a full fiber element; marginal reads appear only in navigation-agreement lemmas (probe) |

## Plan Deviations

- None skipped/deferred. Two beneficial generalizations recorded inline in the plan
  checklist: `kvE_fiberPosOn_correct` proved for arbitrary sub-lists (not only fiber
  sub-lists); marginal-agreement half of the probe stated in the new layer's own channels
  (atom layer / zone / `kvE_projFreshD`) instead of replicating the ~150-line depth-1
  `f2_sub_proj_eq` proof — `f2_carrier_eq` is cited, not replicated, per the plan's
  replication list.

## Sorry Inventory

`[]` (empty).

## Next

Phase 2 (wave 2): shared navigation and fiber-partition layer, additive tail of
`ExteriorFiberK.lean`. See `handoffs/phase-1-handoff-20260712.md`.
