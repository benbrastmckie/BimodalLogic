# Phase 6 Handoff: NF Characterization (nf_characterizable_by_stavi)

**Task**: 155 (Reynolds Pipeline Activation)
**Session**: sess_1748393400_orch155
**Phase**: 6 -- Keystone Sorry: NF Characterization (S13)
**Status**: BLOCKED
**Date**: 2026-05-27

## Current State

The sorry at `StaviCompleteness.lean:1567` is the inductive step of `nf_characterizable_by_stavi`. Goal state:

```
case succ
sig : MonadicSignature
atomMap : Formula -> sig.preds
h_surj : forall p : sig.preds, exists a, atomMap (Formula.atom a) = p
k : Nat
ih : forall (nf : NormalForm sig k 1), exists A,
       forall (M : OrderedMonadicStructure sig) (t : M.carrier),
         stavi_temporal_truth M atomMap t A <-> nf_eval_nf M k 1 (fun x => t) nf
nf : NormalForm sig (k + 1) 1
|- exists A, forall (M : OrderedMonadicStructure sig) (t : M.carrier),
     stavi_temporal_truth M atomMap t A <-> nf_eval_nf M (k + 1) 1 (fun x => t) nf
```

## Why It's Blocked

The proof requires showing that every depth-(k+1) 1-variable NF is characterizable by a StaviFormula. The IH gives this for depth-k 1-variable NFs. But the quantifier part of a depth-(k+1) NF involves 2-variable depth-k NFs: for each `sub_nf : NormalForm sig k 2`, the parent NF records whether `exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`.

The 2-variable type of (x, t) at depth k is NOT determined by x's 1-variable type alone. Counterexample: the existence of a point z with specific properties between x and t depends on the interval structure, not just x's standalone type. Therefore, the IH cannot be applied directly to construct the temporal formula.

The standard GHR93 proof uses a **composition lemma for EF games** (Proposition 7) that does not exist in the codebase. This lemma composes Duplicator's winning strategies on sub-intervals into a strategy on the full interval, enabling the inductive construction of temporal formulas that capture 2-variable types.

## Existing Infrastructure

| Component | Status | Location |
|-----------|--------|----------|
| Base case (depth 0) | Done (sorry-free) | `nf_base_sf`, `nf_base_sf_correct` |
| Depth-0 existence formula | Done | `nf_exist_sf_depth0` |
| Atom literal StaviFormula | Done | `sf_atom_literal`, `atomKind_to_sf_literal` |
| Conjunction/disjunction builders | Done | `sf_conjList`, `sf_disjList`, `sf_conjList_iff`, `sf_disjList_iff` |
| NF uniqueness | Done | `nf_exists_unique` |
| NF -> FO truth | Done | `doets_lemma_1_1` |
| NF -> StaviFormula truth | Done | `nf_determines_stavi_truth` (on extended structure) |
| StaviFormula -> FO translation | Done | `stavi_table_mu`, `stavi_table_mu_correct` |
| StaviFormula -> FO depth bound | Done | `stavi_table_mu_depth`, `stavi_fo_depth_le_twice_depth` |
| Four-case analysis (Cases I-IV) | Done (with sorries) | `ghr93_case_I`, `ghr93_case_II`, `ghr93_cases_III_IV` |
| Forward-to-backward (Theorem 6) | Done | `ghr93_forward_to_backward_rank_varying` |
| Game <-> decomposition (Lemma 11) | Done | `ghr93_game_iff_decomposition` |
| **Composition lemma (Prop 7)** | **MISSING** | Needed for the inductive step |
| **Depth k >= 1 existence formula** | **MISSING** | Requires composition lemma |

## Recommended Approach

### Option A: Implement Composition Lemma (~200-300 lines)

GHR93 Proposition 7: Given Duplicator winning strategies on [x, c] and [c, y] (in both directions), compose them into a winning strategy on [x, y].

**Sketch**:
1. When Spoiler selects points in [x, y], partition them into [x, c] and [c, y] groups
2. Apply the corresponding sub-interval strategy to each group
3. For the point challenge (Round 2), use the appropriate sub-interval strategy
4. Show the winning condition is preserved under composition

**Files**: New lemma in `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Decomposition.lean` or a new file.

### Option B: Direct Construction (~300-500 lines)

Build the StaviFormula for each 2-variable depth-k sub_nf directly:
1. Extract x's 1-variable type from sub_nf (forgetting variable 1)
2. Use IH to get StaviFormula A_x for x's 1-variable type
3. Determine order direction (x > t, x < t, x = t)
4. For x > t: build U(A_x, B_guard) where B_guard describes intermediate types using IH
5. For gap cases: use U'(A_x, B_guard) or S'(A_x, B_guard)
6. Prove correctness using the game infrastructure

**Requires**: Showing that U(A_x, B_guard) correctly captures "exists x > t with sub_nf(x, t)". This is where the composition lemma enters implicitly.

### Option C: Research Alternative

A non-game-theoretic proof may exist. The abstract approach: the NF partition into finitely many classes is game-closed (same NF -> same game outcome). The temporal connectives can define any game-closed partition. This is a model-theoretic result that might be provable without the full composition infrastructure.

## Immediate Next Action

**Research task**: Investigate whether the composition lemma (GHR93 Proposition 7) can be proved from the existing game infrastructure, or whether it requires new definitions. Check `ghr93_duplicator_wins` signature to see if strategies compose directly.

## Key Decisions Made

1. Phase 6 is BLOCKED, not merely difficult -- the missing composition lemma is structural infrastructure, not a tactic gap
2. Phases 7 and 8 depend on Phase 6 (chain: nf_characterizable -> stavi_expressive_completeness -> no_gaps_discrete -> one_class -> succ_cofinal)
3. The sub-proof sorries in ChronicleToCountermodel.lean (lines 1285, 1441, 1508) are in DEAD helper theorems and don't need closing
4. The Reynolds pipeline (Phase 6 -> 7 -> 8) is the ONLY path to sorry-free bx_completeness; the alternative (task 129 Henkin model) is a separate project

## Files Touched This Session

- `specs/155_reynolds_pipeline_activation/plans/34_reynolds-pipeline-plan.md` -- Phase 6 status updated to [BLOCKED] with detailed blocker documentation
- `specs/155_reynolds_pipeline_activation/handoffs/phase-6-handoff-20260527.md` -- this file
