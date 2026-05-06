# Handoff: Burgess C5a Alignment and Guard Propagation Analysis

## Status: PARTIAL — h_actual aligned, guard-in-B' strategy identified

## Completed work

### 1. h_actual aligned with Burgess C5a (BUILD PASSES)

Changed the counterexample check in `CounterexampleElimination.lean` for both forward and backward cases from f-value check to Burgess C5a g-value check:

```lean
-- Forward (c5_forward): OLD → NEW
¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
    ∀ z ∈ χ.dom, pc.x < z → z < y → pc.ξ ∈ χ.f z ∧ Formula.untl pc.ξ pc.η ∈ χ.f z
→
¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧ pc.ξ ∈ χ.g pc.x y

-- Backward (c5_backward): analogous with snce and reversed ordering
```

Fixed downstream: replaced `h_eta_not_x'` / `h_eta_neg_x'` with `h_guard_implies_no_event` derived from Burgess 2.10 (ii).

### 2. Key discovery: `xi ∈ B'` in lemma_2_7

From reading Burgess 2.7 carefully: the conclusion is "η ∈ B', ξ ∈ D" where η = guard (our xi), ξ = event (our eta). So Burgess 2.7 guarantees the **guard enters B'** (the new g-value).

Our `lemma_2_7` currently returns `eta ∈ D` and `B ⊆ B'` but NOT `xi ∈ B'`. Adding `xi ∈ B'` to the return type is the key missing piece.

### 3. Proof strategy for `xi ∈ B'`

The seed D₀ in lemma_2_7 includes `{S(β ∧ xi, α) : β ∈ B, α ∈ A}`. This gives:
1. `snce(β ∧ xi, α) ∈ D` for all β ∈ B, α ∈ A (step 5b, line ~3669)
2. `burgessRSince(D, β ∧ xi, A)` for β ∈ B → `burgessR(A, β ∧ xi, D)` (via 2.3)
3. `untl(β ∧ xi, γ) ∈ A` for all β ∈ B, γ ∈ D

These satisfy the hypotheses of `dc_delta_B_burgessR3` (line 659), giving:
```
burgessR3(A, DC({xi} ∪ B), D)
```

Then pass `DC({xi} ∪ B)` as the Zorn seed to `burgessR3Maximal_extension_exists`:
```
B' ⊇ DC({xi} ∪ B) ⊇ {xi}  ⟹  xi ∈ B'
```

**Remaining sub-task**: prove `SetConsistent ({xi} ∪ B)` (or equivalently `deductiveClosure_is_dcs` for the enriched seed). This follows from the seed consistency already established, since D ⊇ B ∪ ... and D is MCS. Specifically, from `xi ∈ D` and `B ⊆ D` and D is MCS: `{xi} ∪ B ⊆ D` which is MCS, hence consistent.

## Full chain to close the 2 sorries

1. **Add `xi ∈ B'` to `lemma_2_7`** output (PointInsertion.lean:3627). ~30 lines.
   - Start Zorn from `DC({xi} ∪ B)` instead of B
   - Consistency: `{xi} ∪ B ⊆ D` (MCS), hence consistent
   - `burgessR3`: `dc_delta_B_burgessR3` with existing hypotheses

2. **Add `xi ∈ B'` to `lemma_2_8`** (mirror, same file). ~30 lines.
   Same approach — seed already contains the same S(β∧xi, α) formulas.

3. **Add `xi ∈ B'` to `lemma_2_7_since` and `lemma_2_8_since`** (backward mirrors). ~60 lines.

4. **Thread `xi ∈ B'` through `CounterexampleElimination.lean`**:
   - Update splitting result destructuring in all cases to capture `xi ∈ B'`
   - The splitting result `h_split_result` existential gains one more conjunct
   - ~50 lines of mechanical updates

5. **Strengthen `c5_forward_witness`** to include guard info:
   ```lean
   c5_forward_witness : ... →
       ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧
         ∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b
   ```
   Update all ~18 instances in CounterexampleElimination.lean. ~200 lines.

6. **Build omega chain guard theorem** in ChronicleConstruction.lean. ~30 lines.
   - Extract guard from c5_forward_witness at stage n+1
   - Use `adj_g_mem_limit_f` for each adjacent pair

7. **Close the 2 sorries**. ~10 lines each.

### Total estimate: ~400 lines of changes across 3 files

## Key files
- `CounterexampleElimination.lean` — h_actual changes (DONE), threading guard (TODO)
- `PointInsertion.lean` — add `xi ∈ B'` to lemma_2_7/2_8/mirrors (TODO)
- `ChronicleConstruction.lean` — close sorry sites (TODO)

## Convention reminder
Our `untl(guard=ξ, event=η)` = Burgess `U(event=ξ, guard=η)`. SWAPPED.
Burgess 2.7: η ∉ B (guard not in B), result η ∈ B' (guard in B').
Our code: xi ∉ B (guard not in B), need xi ∈ B' (guard in B').
