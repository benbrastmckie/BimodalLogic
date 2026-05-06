# Handoff: dom_new_unique closed, C5 guard root cause identified

## Status: 2 sorries remain (down from 3)

### What was done

1. **Closed `omega_chain_dom_new_unique`** (sorry #1):
   - Added `dom_new_unique` field to `EliminationResult` structure in CounterexampleElimination.lean
   - Field: `∀ u v, u ∈ val.dom → u ∉ χ.dom → v ∈ val.dom → v ∉ χ.dom → u = v`
   - Proved for all 18 cases: 7 unchanged (vacuously true) and 11 insert (`Finset.mem_insert` reasoning)
   - Proved `omega_chain_dom_new_unique` using the new field
   - Build passes

2. **Identified the root cause of the C5 guard problem**

### ROOT CAUSE: lemma_2_7 is missing `xi ∈ B'`

Burgess Lemma 2.7 conclusion states (in Burgess notation ξ=event, η=guard):
> ∃ B', D, B'' such that **η ∈ B'**, ξ ∈ D, and R(A, B', D), R(D, B'', C) and B = B' ∩ D ∩ B''

The guard η ∈ B' is critical. Our `lemma_2_7` at PointInsertion.lean:3616 ONLY gives:
```
eta ∈ D ∧ B ⊆ B' ∧ B ⊆ D ∧ B ⊆ B''
```
It does NOT give `xi ∈ B'` (guard ∈ B'). This is the missing piece.

### Why xi ∈ B' is provable

The seed `lemma_2_7_seed` already contains `snce(β ∧ xi, α)` for all β ∈ B, α ∈ A (line 2866). This gives:

1. `burgessRSetSince(D, β ∧ xi, A)` for each β ∈ B
2. By lemma 2.3: `burgessRSet(A, β ∧ xi, D)` for each β ∈ B  
3. So `r(A, β ∧ xi, D)` for all β ∈ B

From step 3: `DC(B ∪ {xi})` satisfies `burgessR3(A, DC(B ∪ {xi}), D)`:
- Any γ ∈ DC(B ∪ {xi}) is derivable from some β ∧ xi with β ∈ B (since B is DCS)
- From `U(δ, β ∧ xi) ∈ A` and BX3 (right monotonicity with ⊢ β ∧ xi → γ): `U(δ, γ) ∈ A`

So if we start the Zorn construction from `DC(B ∪ {xi})` instead of `B`, the resulting B' will contain xi.

### How to fix lemma_2_7

**Option A** (cleanest): Change the Zorn seed for B' from `B` to `DC(B ∪ {xi})`:

```lean
-- Current (line 3692):
obtain ⟨B', h_B_sub_B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_B_dcs h_r3_ABD h_no_univ_AD

-- New: start from DC(B ∪ {xi})
have h_B_xi_dcs : SetDeductivelyClosed (DC(B ∪ {xi})) := ...
have h_r3_ABxi_D : burgessR3 A (DC(B ∪ {xi})) D := ... -- from the snce seed
obtain ⟨B', h_Bxi_sub_B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_B_xi_dcs h_r3_ABxi_D h_no_univ_AD
have h_xi_B' : xi ∈ B' := h_Bxi_sub_B' (mem_DC_right xi)
```

**Option B** (post-hoc): Keep the current Zorn from B, then prove xi ∈ B' using maximality contradiction.

### Chain of fixes needed

1. **PointInsertion.lean**: Add `xi ∈ B'` to conclusion of `lemma_2_7` and `lemma_2_8`
2. **CounterexampleElimination.lean**: 
   - Strengthen `c5_forward_witness` to include `∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b`
   - In each actual-counterexample case, prove the guard using `xi ∈ B'`:
     - n=0: `ξ ∈ B` from `lemma_2_4_with_guard` (already done)
     - Condition (i): `ξ ∈ g(x, x')` from condition (i), walk continues via reduction
     - Splitting: `ξ ∈ B'` from the enhanced `lemma_2_7`/`lemma_2_8`
   - In unchanged cases: push_neg gives g-value guard directly (with strengthened counterexample condition)
3. **ChronicleConstruction.lean**: 
   - Update `omega_chain_c5_witness` to extract the guard
   - Close the 2 remaining sorries using `adj_g_mem_limit_f`

### Convention reminder
Our `untl(guard=ξ, event=η)` = Burgess `U(event=ξ, guard=η)`. SWAPPED.

### Files modified so far
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`: Added `dom_new_unique` field
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`: Closed `omega_chain_dom_new_unique` sorry

### Remaining sorries
1. **ChronicleConstruction.lean:1445** — `limit_satisfies_c5_strong` guard (Until)
2. **ChronicleConstruction.lean:1457** — `limit_satisfies_c5'_strong` guard (Since mirror)
