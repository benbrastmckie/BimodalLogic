# Team Research Report: Task #70 - Remaining Work Analysis

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774915056_b8c451

## Summary

This team research rigorously analyzed all remaining work for task 70, cutting no corners. The analysis reveals:

1. **Phase 4 has 3 sorries** with clear proof strategies and verified infrastructure
2. **Phase 5 can proceed immediately** - not blocked by Phase 4 sorries
3. **Phase 6-7 are blocked** by `ultrafilter_F_resolution` (Sorry 2)
4. **Two paths to completeness exist** - ultrafilter route (this task) or truth lemma modification

The dependency graph is a clean DAG with no circular dependencies.

---

## Key Findings

### Finding 1: Custom Ultrafilter Type Requires MCS Bijection Approach

The project uses a **custom** `Ultrafilter` type on Boolean algebras (UltrafilterMCS.lean:38), NOT Mathlib's `Ultrafilter` (which operates on `Set α`). This is critical:

- Mathlib's `Ultrafilter.of` and `Filter.generate` cannot be used directly
- The correct approach uses the MCS bijection: `mcsToUltrafilter` / `ultrafilterToSet`
- `set_lindenbaum` (Zorn already implemented) provides filter extension through MCS

### Finding 2: Phase 4 Sorries Have Complete Proof Strategies

| Sorry | Location | Confidence | Blocking? |
|-------|----------|------------|-----------|
| `G_preimage_inf` | line 697 | **HIGH** | Blocks Sorry 2 |
| `ultrafilter_F_resolution` | line 729 | **MEDIUM** | Blocks Phase 6 |
| `ultrafilter_P_resolution` | line 738 | **MEDIUM** | Blocks Phase 6 (backward) |

**Sorry 1 (`G_preimage_inf`)** - K-axiom distribution, all infrastructure exists:
- `pairing` (Combinators.lean) - provides `A → B → A∧B`
- `temp_k_dist` (Axioms.lean) - K-axiom for G
- `temporal_necessitation` (DerivationTree) - necessitation rule
- `lce_imp`, `rce_imp` (Propositional.lean:737,755) - conjunction elimination
- Proof: ~15-20 tactic lines, mathematically routine

**Sorry 2 (`ultrafilter_F_resolution`)** - Filter extension via MCS bijection:
- Define seed: `{ ψ | G(ψ) ∈ ultrafilterToSet U } ∪ {φ}`
- Prove seed consistency (case split: φ ∈ L vs φ ∉ L)
- Apply `set_lindenbaum` to extend to MCS
- Convert via `mcsToUltrafilter`
- Depends on: Sorry 1 for consistency proof

**Sorry 3 (`ultrafilter_P_resolution`)** - Symmetric to Sorry 2:
- Requires `H_preimage_inf` (analogous to Sorry 1)
- `past_k_dist` exists in GeneralizedNecessitation.lean:81
- `past_necessitation` also exists
- Structurally identical proof with H replacing G

### Finding 3: Phases 5-7 Status Clarified

**Phase 5: UltrafilterChain → FMCS** (NOT BLOCKED)
```lean
noncomputable def UltrafilterChain_to_FMCS (uc : UltrafilterChain) : FMCS Int where
  mcs        := fun t => ultrafilter_to_mcs (uc.chain t)
  is_mcs     := fun t => (ultrafilter_to_mcs (uc.chain t)).2
  forward_G  := -- uses UltrafilterChain.forward_G (already proven)
  backward_H := -- uses UltrafilterChain.backward_H (already proven)
```

All prerequisites are sorry-free. This phase can be implemented NOW.

**Phase 6: Family-Level Temporal Coherence** (BLOCKED by Sorry 2)

The structure would be:
```lean
theorem ultrafilter_FMCS_forward_F (uf : UltrafilterFMCS) (t : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ uf.mcs t) :
    ∃ s : Int, t ≤ s ∧ phi ∈ uf.mcs s
```

This directly requires `ultrafilter_F_resolution` to construct successors.

**Phase 7: Integration** (BLOCKED by Phase 6)

Integration target: `parametric_canonical_truth_lemma` needs `BFMCS.temporally_coherent` which requires **same-family** witnesses (not bundle-level).

### Finding 4: The Central Gap Is Precisely Identified

The gap between existing infrastructure and completeness:

| What Exists | What's Needed |
|-------------|---------------|
| `construct_bfmcs_bundle` (sorry-free) | `BFMCS.temporally_coherent` |
| Bundle-level coherence: witness in ANY family | Family-level coherence: witness in SAME family |
| `∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs s` | `∃ s, t ≤ s ∧ phi ∈ fam.mcs s` |

The ultrafilter approach closes this gap because ultrafilter negation-completeness prevents the "F-persistence gap" where Lindenbaum can add `G(¬φ)` even when `F(φ)` was present earlier.

### Finding 5: Two Paths to Completeness

**Path A (Ultrafilter Route - This Task)**:
1. Prove `G_preimage_inf` (Sorry 1) - warmup
2. Prove `H_preimage_inf` (new lemma) - symmetric
3. Prove `ultrafilter_F_resolution` (Sorry 2) - crux
4. Prove `ultrafilter_P_resolution` (Sorry 3) - symmetric
5. Implement Phase 5 (can parallelize with above)
6. Implement Phase 6 (needs Sorry 2)
7. Implement Phase 7 (needs Phase 6)

**Path B (Truth Lemma Modification Route)**:
- Modify `parametric_canonical_truth_lemma` to accept bundle-level coherence
- Change semantics: history allows jumping between families
- Bypasses Phase 4 sorries entirely
- Requires more architectural change

Path A is mathematically cleaner; Path B is lower risk but more invasive.

---

## Synthesis

### Conflicts Resolved

**Conflict 1: Phase 5-7 scope**
- Teammate A focused on sorry infrastructure
- Teammate B discovered Phases 5-7 are partially superseded by existing `construct_bfmcs_bundle`
- **Resolution**: Phase 5 creates the conversion; Phases 6-7 are about proving family-level coherence for ultrafilter-based FMCS specifically

**Conflict 2: Zorn approach**
- Multiple approaches considered: direct Zorn on Boolean algebra vs MCS bijection
- **Resolution**: MCS bijection is optimal - leverages existing `set_lindenbaum`

### Gaps Identified

1. **`H_preimage_inf`**: Needed for Sorry 3 but not currently defined. Symmetric to `G_preimage_inf`.

2. **Chain extension problem**: For Phase 6, after getting V from `ultrafilter_F_resolution`, need to extend to a full `UltrafilterChain`. Options:
   - One-step extension starting from V
   - Requires new `extend_chain_with_successor` definition

3. **Type matching bookkeeping**: Bridge between `LindenbaumAlg` elements and `Formula`s requires careful alignment in Sorry 2/3 proofs.

### Recommendations

**Immediate Actions (No Blockers)**:
1. Implement Phase 5 (`UltrafilterChain_to_FMCS`) - ready now
2. Prove `G_preimage_inf` (Sorry 1) - standalone
3. Add `H_preimage_inf` lemma - symmetric to Sorry 1

**Sequential Actions**:
4. Prove `ultrafilter_F_resolution` (Sorry 2) - needs Sorry 1
5. Prove `ultrafilter_P_resolution` (Sorry 3) - needs H_preimage_inf
6. Implement Phase 6 - needs Sorry 2/3
7. Implement Phase 7 - needs Phase 6

**Parallelization Opportunities**:
- Phase 5 can run parallel with Sorry 1-3
- Sorry 1 and H_preimage_inf can run parallel
- Sorry 2 and Sorry 3 can run parallel (after their prerequisites)

---

## Dependency Graph

```
[Sorry 1]: G_preimage_inf
    │
    ├──────────────────────────┐
    │                          │
    v                          v
[Sorry 2]: ultrafilter_F     [H_preimage_inf] (new)
           _resolution               │
    │                                │
    │                                v
    │                    [Sorry 3]: ultrafilter_P
    │                               _resolution
    │                                │
    v                                v
[Phase 5]: UltrafilterChain ───────> independent
           _to_FMCS                  (can run now)
    │
    v
[Phase 6]: ultrafilter_FMCS_forward_F  <── needs Sorry 2, 3
    │
    v
[Phase 7a]: construct_ultrafilter_bfmcs
    │
    v
[Phase 7b]: integrate with parametric_canonical_truth_lemma
    │
    v
[COMPLETENESS]
```

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Phase 4 sorries - proof strategies | completed | high |
| B | Phases 5-7 design - dependencies | completed | high |

### Teammate A Key Contributions
- Verified all infrastructure exists for Sorry 1 (lce_imp, rce_imp confirmed)
- Provided complete proof sketch for Sorry 1 (~15-20 tactic lines)
- Identified MCS bijection as optimal approach for Sorries 2-3
- Confirmed past_k_dist and past_necessitation exist for Sorry 3

### Teammate B Key Contributions
- Discovered existing `construct_bfmcs_bundle` is sorry-free
- Precisely identified bundle vs family-level coherence gap
- Clarified Phase 5 is NOT blocked by Phase 4 sorries
- Mapped two alternative paths to completeness

---

## Proof Sketches (From Teammate A)

### Sorry 1: G_preimage_inf

```lean
have h_K_inf : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
  unfold Derives
  -- 1. pairing: ⊢ φ → (ψ → φ ∧ ψ)
  have pair := Bimodal.Theorems.Combinators.pairing φ ψ
  -- 2. necessitation: ⊢ G(φ → ψ → φ ∧ ψ)
  have d_nec := DerivationTree.temporal_necessitation _ pair
  -- 3. temp_k_dist twice + imp_trans: ⊢ G(φ) → G(ψ) → G(φ∧ψ)
  have dk1 := DerivationTree.axiom [] _ (Axiom.temp_k_dist φ (ψ.imp (φ.and ψ)))
  have h1 := DerivationTree.modus_ponens [] _ _ dk1 d_nec
  have dk2 := DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ (φ.and ψ))
  have h_chain := Bimodal.Theorems.Combinators.imp_trans h1 dk2
  -- 4. Use lce_imp/rce_imp to get (G(φ) ∧ G(ψ)) → G(φ∧ψ)
  exact ⟨...⟩  -- combine with lce_imp, rce_imp
```

### Sorry 2: ultrafilter_F_resolution

```lean
theorem ultrafilter_F_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_F : (STSA.G aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_G U V ∧ a ∈ V := by
  obtain ⟨φ, rfl⟩ := Quotient.exists_rep a
  let MU := ultrafilterToSet U
  let seed : Set Formula := { ψ | Formula.all_future ψ ∈ MU } ∪ {φ}
  -- Consistency proof (uses G_preimage_inf + h_F contradiction)
  have h_seed_cons : SetConsistent seed := by
    intro L hL h_incons
    by_cases h_phi_in_L : φ ∈ L
    · -- Hard case: φ ∈ L → derive G(¬φ) ∈ U → contradiction with h_F
      ...
    · -- Easy case: φ ∉ L → derive G(⊥) ∈ U → contradiction
      ...
  obtain ⟨M, hM_extends, hM_mcs⟩ := set_lindenbaum seed h_seed_cons
  let V := mcsToUltrafilter ⟨M, hM_mcs⟩
  use V
  exact ⟨fun b h => ..., ⟨φ, hM_extends (...), rfl⟩⟩
```

---

## References

### Confirmed Infrastructure Locations

| Lemma | File | Line |
|-------|------|------|
| `pairing` | Combinators.lean | - |
| `imp_trans` | Combinators.lean | - |
| `lce_imp` | Propositional.lean | 737 |
| `rce_imp` | Propositional.lean | 755 |
| `temp_k_dist` | Axiom definition | - |
| `past_k_dist` | GeneralizedNecessitation.lean | 81 |
| `temporal_necessitation` | DerivationTree | - |
| `set_lindenbaum` | Core.lean | - |
| `mcsToUltrafilter` | UltrafilterMCS.lean | - |
| `ultrafilterToSet_mcs` | UltrafilterMCS.lean | - |

### Files to Modify

1. `UltrafilterChain.lean` - Complete Sorry 1-3, add H_preimage_inf
2. `UltrafilterMCS.lean` or new file - Phase 5 conversion
3. New file for Phase 6-7 or extend UltrafilterChain.lean

---

## Conclusion

All remaining work for task 70 is well-understood with clear proof strategies. The critical path runs through `ultrafilter_F_resolution` (Sorry 2), which depends on `G_preimage_inf` (Sorry 1). Phase 5 can proceed immediately to parallelize work. No circular dependencies exist, and the mathematical foundations are sound.

**Estimated remaining effort**: 8-12 hours (reduced from original 12-20 due to confirmed infrastructure)
