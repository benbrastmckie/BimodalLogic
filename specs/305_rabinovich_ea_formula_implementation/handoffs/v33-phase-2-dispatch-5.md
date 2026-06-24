# Handoff: Task 305 Phase 2 Dispatch 5

## Current State
- Phase 2 IN PROGRESS, **1 sorry remaining** (down from 3 at dispatch start)
- Build passes (`lake build` succeeds)
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` (649 lines)

## What Changed (This Dispatch)

### Infrastructure Added
- `skipFin_ne`: proof that `skipFin skip k ≠ skip` for all k
- `unskipFin`: inverse of `skipFin` for positions ≠ skip
- `skipFin_unskipFin`: right inverse property
- `unskipFin_skipFin`: left inverse property
- `merge_forward`: complete proof of forward direction of NF merge

### Sorrys Resolved
1. **Sorry 1 (j=free-var, was line 217)**: FILLED. Uses `merge_forward` with swapped i/j roles. When j is the free variable (position n+1), we merge i instead (since i.val ≤ n). The backward direction is proved by dropping position i (symmetric to the j ≠ free-var backward proof).

2. **Sorry 2 (merge forward, was line 237)**: FILLED. Uses `merge_forward` directly. The proof constructs `full_val : Fin (n+2) → M.carrier` that duplicates i's value at position j, then transfers NF satisfaction atom-by-atom using `h_pred` (predicates) and `h_ord` (orders). Key technique: `nf_order_irrel` handles dependent type issues in order atoms.

### Key Technical Challenge Solved
The main difficulty was dependent types in `AtomKind.order pos₁ pos₂ h_ne_pos` where `h_ne_pos : pos₁ ≠ pos₂`. Rewriting `pos₁` to `j` with `rw` or `subst` fails because the proof argument depends on `pos₁`. Solution: prove `nf_order_irrel` (proof irrelevance for NF order atoms) and use `subst` followed by `nf_order_irrel` to construct explicit equalities.

## Sorry Inventory

| # | File | Line | Statement | Why Deferred | Next Dispatch |
|---|------|------|-----------|--------------|---------------|
| 1 | NfDepth0Generalized.lean | 574 | Case B: transitive strict total order → translateEF1 | Requires rank function construction, translateEF1_correct API research | Build nf_rank, prove injective (from h_trans), construct translateEF1 parameters, prove biconditional |

## Remaining Sorry: TranslateEF1 Case (Line 574)

### Goal State
```
h_has_eq : ∀ (i j) (h : i ≠ j), sub_nf (.order i j h) = false → sub_nf (.order j i _) ≠ false
h_trans : ∀ (a b c) (h_ab h_bc h_ac), sub_nf (.order a b h_ab) = true →
  sub_nf (.order b c h_bc) = true → sub_nf (.order a c h_ac) = true
⊢ ∃ A, ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
    temporal_truth M atomMap t A ↔ ∃ env, nf_eval_nf M 0 (n + 2) (insertEnv env t) sub_nf
```

### Approach
1. `h_has_eq` ensures every pair has exactly one true order boolean (strict tournament)
2. `h_trans` ensures transitivity → strict total order on n+2 positions
3. Define `nf_rank : Fin (n+2) → Fin (n+2)` counting positions strictly before each position
4. Prove rank is injective (from transitivity + tournament), hence bijective
5. Let `k = nf_rank ⟨n+1, _⟩` (rank of free variable)
6. Build `alpha i = nfPredAtPos atomMap h_surj sub_nf (rank⁻¹ i)` for sorted positions
7. Build `beta j = TemporalPred.top` (depth 0 = no interval conditions)
8. Formula = `translateEF1 (n+1) k alpha beta`
9. Prove biconditional using `translateEF1_correct`

### Key References
- `Translation.lean`: `translateEF1`, `translateEF1_correct` signatures
- `ExistsForallNF.lean`: `translateEF1` definition (line 311)
- `NfToVecEA.lean`: arity-2 pattern for reference

## Immediate Next Action
- Research `translateEF1_correct` signature and requirements
- Define rank function and prove bijectivity
- Build alpha/beta parameters
- Prove biconditional
