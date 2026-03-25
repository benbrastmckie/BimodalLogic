# Teammate A Findings: G-lift Blocker for Extended Seed

**Task**: 55 - Prove SuccChain Temporal Coherence Directly
**Date**: 2026-03-24
**Blocker**: G-lift argument fails for `resolving_successor_seed_consistent` (line 1570)

---

## Key Findings

### Finding 1: The Sorry is in a Mathematically Flawed Proof

**Location**: `UltrafilterChain.lean:1566-1570`

```lean
exact absurd h_neg_phi_in_M (by
  -- The contradiction arises because the G-lift of the temporal_box_seed part
  -- combined with the M-elements leads to G(neg(phi)) ∈ M.
  -- Full proof requires derivation restructuring infrastructure.
  sorry)
```

The sorry tries to prove `neg(phi) ∉ M` after having already derived `neg(phi) ∈ M` at line 1552. This is an impossibility — the sorry cannot be filled. The proof structure itself is wrong.

### Finding 2: Why `neg(phi) ∈ M` and `F(phi) ∈ M` is NOT a Contradiction

`F(phi) = neg(G(neg(phi)))`. Having `neg(phi) ∈ M` and `F(phi) ∈ M` simultaneously is semantically valid: phi is false NOW (neg(phi)) but true at some FUTURE time (F(phi)). These coexist in a maximal consistent set.

The confusion arises from pattern-matching on `temporal_theory_witness_consistent` which DOES produce a contradiction (G(neg(phi)) contradicts F(phi)), but only because the context is restricted to G-liftable elements.

### Finding 3: The G-lift Cannot Be Extended to deferralDisjunctions or p_step_blocking_formulas

The G-lift argument (`G_lift_from_context`, line 1067) requires that every context element `x` satisfies `G(x) ∈ M`. This holds for `temporal_box_seed M` by `G_of_temporal_box_seed` (line 1053).

**For `deferralDisjunctions M`**: Elements are of form `psi ∨ F(psi)` where `F(psi) ∈ M`. We have `psi ∨ F(psi) ∈ M` (disjunction intro from `F(psi) ∈ M`), but `G(psi ∨ F(psi)) ∈ M` would require `A → G(A)` for arbitrary `A`. This axiom does NOT hold in temporal logic (only `G(A) → A` via temp_t_future, NOT the converse).

**For `p_step_blocking_formulas M`**: Elements are of form `H(neg(chi))` where `P(chi) ∉ M`. These are in M but there's no reason `G(H(neg(chi))) ∈ M`.

**Conclusion**: The G-lift argument is fundamentally inapplicable to the extended seed. This is confirmed in the research report `04_resolving-chain-detailed.md`, Section 3.4.

### Finding 4: `{phi} ∪ M` Consistency Requires `phi ∈ M`

An alternative approach — proving `{phi} ∪ M` consistent, then using subset monotonicity — also fails. Since M is an MCS (negation-complete), `{phi} ∪ M` is inconsistent iff `neg(phi) ∈ M`. The assumption `F(phi) ∈ M` does NOT prevent `neg(phi) ∈ M` (they coexist). Therefore `{phi} ∪ M` is consistent iff `phi ∈ M`, which is not given.

### Finding 5: The Extended Seed Theorem May Be Unnecessarily Strong

Looking at what the extended seed is needed FOR (Phase 3: `resolving_chain_fam`), the plan (Phase 3, line 121-131) uses the resolving successor only to force `phi ∈ W` at position `query_n + 1`. The F-step for OTHER formulas is handled by separate per-obligation invocations.

**The current `resolving_successor_seed` includes `deferralDisjunctions M ∪ p_step_blocking_formulas M` to satisfy the FULL `Succ M W` relation. But `forward_F` only needs `phi ∈ W`, not full Succ.**

---

## Recommended Approach

### Option A: Reduce the Seed to `{phi} ∪ temporal_box_seed M` (HIGH CONFIDENCE)

**Change `resolving_successor_seed` to the SMALLER seed** that is already proven consistent:

```lean
def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M
  -- Remove deferralDisjunctions M and p_step_blocking_formulas M
```

The consistency proof is then exactly `temporal_theory_witness_consistent`.

**Tradeoff**: The resolving successor W from Lindenbaum extension may NOT satisfy full `Succ M W` for F-step (other formulas than phi) or P-step. But per the plan's per-obligation architecture, this is acceptable — `forward_F` only needs `phi ∈ W` + G-persistence + box-class agreement.

**Verified properties from `temporal_theory_witness_exists`**:
- `phi ∈ W` (seed contains `{phi}`)
- `G(a) ∈ M → G(a) ∈ W` (from G_theory in seed) → `a ∈ W` for all `a ∈ g_content M`
- `box_class_agree M W` (from box_theory in seed)

These are exactly what `temporal_theory_witness_exists` already provides.

**Action**: The `resolving_successor_seed_consistent` theorem should be replaced by `temporal_theory_witness_consistent` directly. The `resolving_successor_from_seed` should use `temporal_theory_witness_exists` as its consistency proof.

### Option B: Factor Out the Derivation (MEDIUM CONFIDENCE, HIGH COMPLEXITY)

Keep the extended seed but restructure the consistency proof:

1. Assume `L ⊆ resolving_successor_seed M phi` with `L ⊢ ⊥` and `phi ∈ L`
2. Apply deduction theorem repeatedly to REMOVE all `deferralDisjunctions ∪ p_step_blocking` elements from `L_no_phi`, getting:
   - `L_temporal ⊢ (m₁ → m₂ → ... → neg(phi))` where `L_temporal ⊆ temporal_box_seed M`
3. By `G_lift_from_context`: `G(m₁ → m₂ → ... → neg(phi)) ∈ M`
4. Apply temporal K distribution: `G(m₁ → rest) ∈ M` and need `G(m₁) ∈ M`
5. **STUCK**: `m₁ ∈ M` does NOT imply `G(m₁) ∈ M`. This approach fails at step 4.

**Conclusion**: Option B does not work without additional axioms. The G-lift cannot be recovered for M-only elements.

### Option C: Prove Consistency via Lindenbaum Extension (LOW CONFIDENCE)

Extend `{phi} ∪ temporal_box_seed M` to MCS `W'` (using `temporal_theory_witness_exists`). Show that the full resolving seed is consistent with respect to `W'` — i.e., that `deferralDisjunctions M ∪ p_step_blocking_formulas M ⊆ W'`.

**Problem**: W' was built from `{phi} ∪ temporal_box_seed M`. It may not contain deferralDisjunctions. For example, `psi ∨ F(psi) ∈ deferralDisjunctions M` requires `psi ∈ W'` or `F(psi) ∈ W'`, which Lindenbaum doesn't guarantee.

---

## Evidence and Line References

| Claim | Evidence | Location |
|-------|----------|----------|
| All `temporal_box_seed M` elements are G-liftable | `G_of_temporal_box_seed` | `UltrafilterChain.lean:1053-1059` |
| G-lift from G-liftable context | `G_lift_from_context` | `UltrafilterChain.lean:1067-1083` |
| `{phi} ∪ temporal_box_seed M` consistent when `F(phi) ∈ M` | `temporal_theory_witness_consistent` | `UltrafilterChain.lean:1111-1152` |
| deferralDisjunctions ⊆ M | `deferralDisjunctions_subset_mcs` | `UltrafilterChain.lean:1487` |
| p_step_blocking ⊆ M | `p_step_blocking_formulas_subset_u` | `UltrafilterChain.lean:1488` |
| Full seed ⊆ `{phi} ∪ M` | `resolving_seed_subset_phi_union_M` | `UltrafilterChain.lean:1493-1502` |
| `{phi} ∪ M` consistent iff `phi ∈ M` | MCS negation completeness | `MCSProperties.lean:170-190` |
| Research report confirming G-lift failure | Section 3.4 "Separate the Concerns" | `reports/04_resolving-chain-detailed.md:710-718` |

---

## Confidence Assessment

**High confidence**: The sorry at line 1570 cannot be filled as-is. The mathematical argument is definitively broken.

**High confidence**: Option A (reduce seed to `{phi} ∪ temporal_box_seed M`) resolves the immediate consistency blocker. This makes `resolving_successor_seed_consistent` trivially true by `temporal_theory_witness_consistent`.

**Medium confidence**: The reduced seed provides sufficient properties for the per-obligation `forward_F` proof in Phase 3. The key properties (`phi ∈ W`, G-persistence, box-class agreement) are all provided by `temporal_theory_witness_exists`.

**Low confidence**: The full `Succ M W` relation holds for the resolving successor with reduced seed. F-step for non-phi formulas is not guaranteed, but the plan's per-obligation architecture may not require it.

---

## Recommended Immediate Action

1. **Redefine `resolving_successor_seed`** as `{phi} ∪ temporal_box_seed M` (removing deferralDisjunctions and p_step_blocking)
2. **Replace `resolving_successor_seed_consistent`** with a trivial proof: just apply `temporal_theory_witness_consistent`
3. **Replace `resolving_successor_from_seed`** with `temporal_theory_witness_exists`
4. **Check Phase 2 theorems** — the Succ relation proofs that use `deferralDisjunctions` and `p_step_blocking` in the seed may need different arguments or may be droppable for the per-obligation architecture

The F-step for non-phi formulas can be deferred to the next per-obligation invocation. The P-step backward constraint may require separate treatment.
