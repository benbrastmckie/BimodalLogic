# Handoff: Task 305 v34 Phase 1 — BLOCKED (refined obstacle analysis)

- **Session**: sess_1782319610_816c48
- **Agent**: lean-implementation-hard-agent (H2 + H9)
- **Date**: 2026-06-24
- **Status**: partial / blocked
- **Build**: `lake build` GREEN (1700 jobs). `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` GREEN (992 jobs).
- **Sorry count in KampPrior.lean**: 2 code sorries (unchanged from baseline): line 391 (n=1, critical) and line 394 (n≥2, off-path).

## Immediate Next Action

Generalize the depth-0 merge machinery `mergeNF` / `merge_forward`
(NfDepth0Generalized.lean:157/168) to arbitrary depth `k`, as the first sub-lemma of the n=1
binder. This is the x=t zone of the construction and is the smallest self-contained piece.

## Current State

- The n=1 arm of `nf_nvar_exist_all_depths` (KampPrior.lean:391) and the n≥2 arm (line 394) both
  still contain `sorry`. No regression: build is green, all Preserved Assets intact.
- The stale comment block at the n=1 arm (which described the REFUTED k+2 NF-disjunction strategy)
  was replaced with an accurate one-line pointer to this handoff. This is the only Lean change.
- A throwaway probe theorem was added and removed (no residue).

## Key Decision / Finding (refines report 18)

Report 18 (HIGH confidence, Approach 5) framed the SOLE remaining risk as the "Fin 2 telescoping
bridge". After reading the actual depth-0 binder and support machinery, the real blocker is
deeper and twofold. **This is the central handoff content.**

### Why the n=1 arm is NOT a quick win

The n=1 goal (after the Fin-1 bridge, which IS trivial and already proved twice in-file at lines
317-331 and 497-513) is:

```
temporal_truth M atomMap t A  ↔  ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf
```

`nf_eval_nf M (k+1) 2 (x,t) sub_nf` unfolds (NormalForm.lean:203-207) to:
- atom layer (depth 0, arity 2): `∀ a, atom_eval M (x,t) a ↔ sub_nf.1 a` — includes the ORDER
  between positions 0 (x) and 1 (t).
- quant layer: `∀ qnf : NF(k,3), (∃ y, nf_eval_nf M k 3 (Fin.cons y (x,t)) qnf) ↔ sub_nf.2 qnf`.

**Obstacle 1 — joint x–t coupling.** The quant clause `∃ y, nf_eval_nf M k 3 (y,x,t) qnf`
depends on BOTH the bound x and the free t. The depth-0 binder `nf_2var_exist_depth0_tl`
(NfToVecEA.lean:702) succeeds only because depth-0 NFs have NO quant layer, so it can use
INDEPENDENT projections `nf_x_proj'` (x alone) and `nf_t_proj` (t alone) as the two VecEA2
endpoint predicates. At depth k+1 the endpoints are not independent — the construction cannot
factor into "predicate at x" ∧ "predicate at t".

**Obstacle 2 — depth-0-only support machinery.** Both pieces the construction would reuse exist
only at depth 0:
- Zone-split: `nf_vecEA2_future`/`nf_vecEA2_past`, `VecEA2` reconstruction (NfToVecEA.lean) take
  `NormalForm sig 0 2`.
- Merge/collapse: `mergeNF`/`merge_forward` (NfDepth0Generalized.lean:157/168) take
  `NormalForm sig 0 (m+1)`. The x=t zone needs collapsing the arity-3 quant NF (y,x,t) to (y,t,t),
  i.e. a merge of positions 1,2 — which only exists at depth 0.

Note: VecEA2 endpoints ARE `TemporalPred` (general formulas), so they CAN in principle hold
`char_k1` (the sorry-free depth-(k+1) arity-1 characteriser, in scope at the k+1 arm). The
blocker is not the endpoint type — it is the coupling (Obstacle 1) plus the missing depth-k merge
(Obstacle 2).

## Recommended Construction (next dispatch, in dependency order)

All pieces are additive; place new lemmas BEFORE the recursive `nf_nvar_exist_all_depths`
(KampPrior.lean:252) or in NfDepth0Generalized.lean. None introduce recursion.

1. **`mergeNF_succ` / `merge_forward_succ`**: generalize `mergeNF`/`merge_forward` from
   `NormalForm sig 0 (m+1)` to `NormalForm sig (k) (m+1)`. The forward direction must also map the
   quant layer (depth-k) through the position drop. Handles the x=t zone (collapse y,x,t → y,t).
   Smallest self-contained piece; do this FIRST. (~80-150 lines.)
2. **Depth-(k+1) zone endpoints**: build the three-way order-zone split on `sub_nf.1`'s order
   booleans (positions 0,1), exactly mirroring `nf_2var_exist_depth0_tl`'s four-arm match
   (true/true ⇒ ⊥; true/false ⇒ Until; false/true ⇒ Since; false/false ⇒ x=t). For the x≷t arms,
   the endpoint `TemporalPred` at x must be a depth-(k+1) characterisation incorporating the quant
   clauses — built from `char_k1` AND the arity-3 IH `nf_nvar_exist_all_depths atomMap h_surj k 2`.
   The interval bracket between x and t must carry the cross-clause coupling; this is the genuinely
   new content vs. the depth-0 case (which used a trivial `TemporalPred.top` bracket). (~150-250
   lines.)
3. **Assemble + bind x** via `VecEA2.translateLeft`/`translateRight` (NfToVecEA.lean) /
   equality, then wire into the n=1 arm (KampPrior.lean:391). Use `nf_nvar_exist_all_depths_fn k 2`
   + `_fn_correct` for the IH and the in-file Fin-1 bridge to reduce `∃ env:Fin 1` to `∃ x`.

### What NOT to do (refuted, report 18 §3/§6)
- No k+2 NF-disjunction (recreates the genuine 2-cycle).
- No `mutual` char/exist def (non-terminating as stated).
- No vacuous `def X := True` or leaf-sorry placeholder for steps 1/2.

## Sorry Inventory

| # | File:Line | Critical | Statement | Assumption | Why deferred | Next dispatch |
|---|-----------|:--------:|-----------|------------|--------------|---------------|
| 1 | KampPrior.lean:391 | YES | `nf_nvar_exist_all_depths` k+1 n=1 arm: `∃A, temporal_truth t A ↔ ∃env:Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf` | needs the depth-(k+1) arity-2 existential binder | Blocked on depth-k merge machinery (Obstacle 2) + joint x–t coupling (Obstacle 1); requires steps 1-3 above, ~250-400 lines | Implement `mergeNF_succ` (step 1), then zone endpoints (step 2), then wire (step 3) |
| 2 | KampPrior.lean:394 | No | `nf_nvar_exist_all_depths` k+1 n≥2 arm | needs n-ary generalization of the n=1 binder | Off critical path; depends on #1 | After #1, via `mergeNF_succ` arity merge over the n=1 result |

## Verification

- sorry_count (KampPrior.lean code sorries): 2
- vacuous_count: 0
- axiom_count (Theories/, `^axiom `): 2 (unchanged baseline)
- build_passed: true (full `lake build`, 1700 jobs)
