# Phase 1 Handoff: D₀ Seed Consistency for Burgess Lemma 2.6

## Session
- Session ID: `sess_1777317319_5b7f64`
- Date: 2026-04-27

## Completed Work

### 1. Reverted "theorems-as-interval" shortcut
- Deleted lines 706-957 from `PointInsertion.lean` (theorems_dcs, lemma_2_6_simple_seed, lemma_2_6_simple_seed_consistent, F_in_A_of_g_content_sub, P_in_C_of_h_content_sub, P_in_D_of_g_content_sub, F_in_D_of_h_content_sub, burgessR3_theorems_left, burgessR3_theorems_right, burgess_lemma_2_6_content)
- Verified `lake build` succeeds (785 jobs, no errors, 1 unused variable warning at line 251)
- The 4 maximality theorems from Phase 1.1 are preserved and sorry-free:
  - `dc_delta_B_controlled` (lines ~544-596)
  - `BurgessR3Maximal_extension_fails` (lines 598-611)
  - `dc_delta_B_burgessR3` (lines 615-633)
  - `BurgessR3Maximal_maximality_combined` (lines 641-704)

### 2. Research on theorems_dcs (completed but no longer needed)
- Proved (in `lean_run_code`) that the set of theorems is a DCS:
  - Consistency via soundness (construct trivial model, use bot_false)
  - Closure via `eliminate_theorem_hypotheses` (induction on L, deduction theorem + modus_ponens)
  - Requires `import Bimodal.Metalogic.Soundness`
- This work is NO LONGER NEEDED since the theorems-as-interval approach was reverted. However, `theorems_dcs` may be useful as a standalone lemma if needed later.

### 3. Analysis of g_content(A) subset B
- Investigated whether `BurgessR3Maximal A B C` implies `g_content(A) ⊆ B`
- Conclusion: This is NOT easily provable from BurgessR3Maximal alone under strict semantics (BX axiom system with irreflexive G)
- BX2 (left_mono_until) requires `(β → β ∧ φ) ∧ G(β → β ∧ φ)` but we need φ ∈ A which strict G doesn't give
- BX7 (linearity) gives wrong guard structure (β instead of β ∧ φ)
- The "simple seed" approach assuming g_content(A) ⊆ B is therefore mathematically suspect

## Remaining Work: D₀ Seed Consistency (Phase 1.2-1.5)

### D₀ Definition
```
D₀ = {S(α,β) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ∈C, β∈B}
```
In Lean, this would be:
```lean
def burgess_D0 (A B C : Set Formula) (delta : Formula) : Set Formula :=
  {φ | ∃ α ∈ A, ∃ β ∈ B, φ = Formula.snce β α} ∪
  B ∪
  ({delta.neg} : Set Formula) ∪
  {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl β γ}
```

### Key Observations About D₀
1. B ⊆ D₀ (second component)
2. For β ∈ B, γ ∈ C: U(β,γ) ∈ D₀ (fourth component) and U(β,γ) ∈ A (from burgessRSet)
3. For β ∈ B, α ∈ A: S(β,α) ∈ D₀ (first component) and S(β,α) ∈ C (from burgessRSetSince)
4. ¬δ ∈ D₀ (third component)

### Consistency Proof Strategy (from coordinator)
The coordinator outlined this approach:
- For any particular ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β), show ζ is consistent
- Use `BurgessR3Maximal_maximality_combined` to extract witness β₀, γ₀ with ¬U(γ₀, β₀∧δ) ∈ A
- Chain BX5 (self_accum) + BX7 (linear_until) to derive U(β∧U(γ,β)∧¬δ, β) ∈ A
- Then BX4 (connect_future) for Since part
- Apply a "2.2 consistency criterion"

### Challenges
1. D₀ is NOT a subset of any single consistent set (B, A, or C) — elements span all three
2. The consistency proof requires synthesizing information from A (Until part), C (Since part), and B
3. Need to handle interactions between Until/Since/B formulas carefully
4. The BX axiom chains (BX5+BX7+BX4) are intricate and not yet formalized for this purpose

### After D₀ Consistency
- **1.3**: Construct MCS D via Lindenbaum extension of D₀. Prove ¬δ ∈ D, B ⊆ D.
- **1.4**: Construct B' maximal wrt burgessR3(A, —, D) with B ⊆ B', and B'' maximal wrt burgessR3(D, —, C) with B ⊆ B''. Use `burgessR3Maximal_exists_from_seed` or `burgessR3Maximal_extension_exists` from RRelation.lean.
- **1.5**: Prove B = B' ∩ D ∩ B'' (Lemma 2.5 identity).

### Key Infrastructure References
- `BurgessR3Maximal_maximality_combined`: Line 641 of PointInsertion.lean — the KEY tool for extracting witnesses
- `burgessR3Maximal_extension_exists`: RRelation.lean line ~786 — Zorn extension to maximal
- `burgessR3Maximal_exists_from_seed`: RRelation.lean line 1184 — construct from seed element
- `untl_left_mono_thm`: RRelation.lean line 1074 — left monotonicity via theorem
- `dcs_neg_union_consistent`: PointInsertion.lean line 381 — adding ¬φ to DCS when φ ∉ S
- `deductiveClosure_is_dcs`: ChronicleTypes.lean — DC of consistent set is DCS
- `forward_temporal_witness_seed_consistent`: WitnessSeed.lean line 81 — template for seed consistency proof
- `generalized_temporal_k`: GeneralizedNecessitation.lean line 148 — G distributes over derivation

## File State
- `PointInsertion.lean`: 706 lines, 0 sorries, builds clean
- Last theorem: `BurgessR3Maximal_maximality_combined` (line 641-704)
- All code after line 704 was deleted (was the flawed theorems-as-interval approach)
