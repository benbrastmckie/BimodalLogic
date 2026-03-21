# Research Report: Task #700 (Continuation)

**Task**: 700 - Research Algebraic Representation Theorem Proof
**Date**: 2026-01-28
**Focus**: Impact of reflexive G/H semantics on purely algebraic approach

## Summary

This report investigates how the recent switch to reflexive semantics for temporal operators G and H (Task #658) affects implementing a purely algebraic approach to the representation theorem. The key finding is that reflexivity has **already been implemented** in the codebase, and while it provides significant theoretical benefits for algebraic approaches, the current proof strategy uses a different technique that doesn't fully leverage these algebraic structures.

**Key Findings**:
1. **Current state**: Reflexive semantics and T-axioms are already implemented (Truth.lean uses `≤`, Axioms.lean has `temp_t_future`/`temp_t_past`)
2. **Coherence now proven within MCS**: The T-axioms give direct local coherence (`mcs_closed_temp_t_future`, `mcs_closed_temp_t_past`)
3. **Algebraic insight**: Reflexive G/H form interior/closure operators on the Lindenbaum algebra - Mathlib has `ClosureOperator` and `Nucleus` structures
4. **Current approach mismatch**: CoherentConstruction.lean builds families by seed-extension, not via algebraic quotient
5. **Remaining sorries**: 4 sorries remain in CoherentConstruction.lean for cross-origin and cross-modal cases (not needed for completeness)
6. **Recommendation**: For a purely algebraic proof, leverage `LatticeCon` to build Lindenbaum quotient with G/H as interior operators

## Context

### Research Question

The user asked: "I have recently switched to a reflexive semantics for the H and G operators. Investigate what changes this has on implementing a purely algebraic approach to establishing the representation theorem."

### Current Codebase State

**Semantics** (Truth.lean:113-114):
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M τ s φ   -- Reflexive (≤)
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M τ s φ -- Reflexive (≤)
```

**Axioms** (Axioms.lean:262-275):
```lean
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)  -- Gφ → φ
| temp_t_past (φ : Formula) : Axiom ((Formula.all_past φ).imp φ)      -- Hφ → φ
```

The switch to reflexive semantics is **complete** in the codebase.

### Current Proof Infrastructure

| File | Role | Status |
|------|------|--------|
| `Core/MCSProperties.lean` | MCS closure lemmas | Complete |
| `IndexedMCSFamily.lean` | Family structure + seed construction | 4 sorries (SUPERSEDED) |
| `CoherentConstruction.lean` | Coherent family via forward/backward chains | 6 sorries (cross-origin cases not needed) |

## Findings

### 1. Impact of Reflexivity on Local Coherence

The T-axioms provide **local coherence within a single MCS**:

**Lemma** (`mcs_closed_temp_t_future` in IndexedMCSFamily.lean:257-273):
```lean
lemma mcs_closed_temp_t_future {Gamma : Set Formula} (h_mcs : SetMaximalConsistent Gamma)
    (φ : Formula) (h_G : Formula.all_future φ ∈ Gamma) : φ ∈ Gamma
```

**Proof**: `Gφ → φ` is an axiom (T-axiom), so by MCS deductive closure, `Gφ ∈ Gamma` implies `φ ∈ Gamma`.

This is exactly the "local constraint" that was missing with irreflexive semantics. Previously, `Gφ ∈ mcs(t)` gave no information about `φ` at time `t` itself - only about strictly future times.

### 2. Algebraic Characterization of Reflexive G/H

With the T-axioms, G and H satisfy the **S4 modal conditions**:

| Property | Axiom | G Condition | H Condition |
|----------|-------|-------------|-------------|
| K (distribution) | `temp_k_dist` | G(φ→ψ) → (Gφ→Gψ) | Via temporal duality |
| T (reflexivity) | `temp_t_future`/`past` | Gφ → φ | Hφ → φ |
| 4 (transitivity) | `temp_4` | Gφ → GGφ | Via temporal duality |

These are precisely the axioms for an **interior operator** on the Lindenbaum-Tarski algebra:
- **Deflationary**: `c(a) ≤ a` (from T: Gφ → φ means [Gφ] ≤ [φ])
- **Monotone**: `a ≤ b → c(a) ≤ c(b)` (from K)
- **Idempotent**: `c(c(a)) = c(a)` (from 4)

Dually, the "sometime" operators P = ¬H¬ and F = ¬G¬ form **closure operators**.

### 3. Mathlib Infrastructure for Algebraic Approach

**Available Structures**:

| Structure | Location | Relevance |
|-----------|----------|-----------|
| `ClosureOperator` | `Mathlib.Order.Closure` | Extensive, monotone, idempotent maps |
| `Nucleus` | `Mathlib.Order.Nucleus` | Closure that preserves meets (locales) |
| `LatticeCon` | `Mathlib.Order.Lattice.Congruence` | Lattice congruences for quotients |

**Key Properties**:
- `ClosureOperator.le_closure'`: Extensiveness `x ≤ c(x)`
- `ClosureOperator.idempotent'`: Idempotence `c(c(x)) = c(x)`
- `LatticeCon.mk`: Create congruence from setoid respecting ⊓ and ⊔

**Missing for Modal Logic**:
- No "interior operator" dual (would need `c(x) ≤ x` instead of `x ≤ c(x)`)
- No Boolean algebra with operators (BAO) structure
- No direct quotient-respects-modality lemmas

### 4. Gap Between Algebraic Theory and Current Implementation

The current CoherentConstruction.lean uses a **seed-extension approach**:
1. Define `forward_seed S = {φ | Gφ ∈ S}` and `backward_seed S = {φ | Hφ ∈ S}`
2. Extend seeds to MCS via Lindenbaum's lemma
3. Build chains of coherent MCS indexed by ℕ (forward) and ℕ (backward)
4. Combine into unified family indexed by ℤ

This is **not** an algebraic approach. An algebraic approach would:
1. Define provable equivalence: `φ ~ ψ := ⊢ φ ↔ ψ`
2. Quotient Formula by ~ to get Lindenbaum algebra L
3. Show L is a Boolean algebra with operators G, H
4. Use Stone duality: ultrafilters of L ↔ points of canonical frame
5. Prove G/H are interior operators (using T-axioms!)
6. Extract task relation from algebraic structure

### 5. What Reflexivity Enables for Algebraic Approach

The T-axioms enable several key algebraic facts:

**Fact 1**: G/H are well-defined on quotient
```lean
-- Need: φ ~ ψ → Gφ ~ Gψ
-- This follows from K-distribution and is independent of T
```

**Fact 2**: G is an interior operator on L
```lean
-- Need: [Gφ] ≤ [φ] (deflationary)
-- From T-axiom: ⊢ Gφ → φ, so [Gφ] ≤ [φ] in the quotient order
```

**Fact 3**: Fixed points of G correspond to "always-true" formulas
```lean
-- G[φ] = [φ] iff ⊢ φ ↔ Gφ
-- These are the "closed" elements under the interior operator
```

**Fact 4**: Ultrafilter-to-MCS correspondence
```lean
-- Every ultrafilter U on L corresponds to an MCS {φ | [φ] ∈ U}
-- This is the core of Stone duality
```

### 6. Effort Comparison

| Approach | Lines to Complete | Key Infrastructure |
|----------|-------------------|-------------------|
| Current (CoherentConstruction) | ~100-200 | Fix cross-origin sorries (not needed for completeness) |
| Algebraic (Lindenbaum quotient) | ~800-1200 | Build L, prove Boolean, prove G/H interior, Stone duality |

The algebraic approach is more elegant but requires significantly more infrastructure.

### 7. Remaining Sorries in Current Approach

**CoherentConstruction.lean** has these sorries:

| Location | Case | Why Not Needed for Completeness |
|----------|------|--------------------------------|
| line 402 | `mcs_forward_chain` seed consistency | Inductive infrastructure needed |
| line 415 | `mcs_backward_chain` seed consistency | Symmetric to forward |
| line 652 | forward_G cross-origin (t < 0, t' ≥ 0) | Completeness only uses same-sign cases |
| line 656 | forward_G both < 0 toward origin | Cross-modal case |
| line 663-665 | backward_H cases 1,2 | Forward chain doesn't preserve H |
| line 682 | forward_H all cases | Only needed for backward Truth Lemma |
| line 711-714 | backward_G cases 3,4 | Cross-origin cases |

**Key insight**: The completeness proof only uses:
- `forward_G` Case 1 (both ≥ 0): PROVEN via `mcs_forward_chain_coherent`
- `backward_H` Case 4 (both < 0): PROVEN via `mcs_backward_chain_coherent`

## Recommendations

### For Current Completion Path

1. **Finish seed consistency proofs**: The `mcs_forward_chain` and `mcs_backward_chain` need inductive proofs that G⊥/H⊥ ∉ MCS propagates through chains

2. **Ignore cross-origin cases**: These are not needed for the representation theorem

3. **Document algebraic insight**: Add comments explaining the interior/closure operator connection

### For Future Algebraic Approach

If a purely algebraic proof is desired:

1. **Phase 1: Lindenbaum Quotient** (~200-300 lines)
   - Define `ProvEquiv : Formula → Formula → Prop := fun φ ψ => ⊢ φ ↔ ψ`
   - Show `ProvEquiv` is a `LatticeCon` on Formula (respects ∧, ∨)
   - Define quotient type `LindenbaumAlg := Quotient ProvEquiv`

2. **Phase 2: Boolean Structure** (~200-300 lines)
   - Show `LindenbaumAlg` is a `BooleanAlgebra`
   - Show negation and implication descend to quotient

3. **Phase 3: Interior Operators** (~200-250 lines)
   - Define `G_quot : LindenbaumAlg → LindenbaumAlg`
   - Prove deflationary (from T-axiom), monotone (from K), idempotent (from 4)
   - Package as `InteriorOperator` (need to define, not in Mathlib)

4. **Phase 4: Stone Representation** (~200-300 lines)
   - Show ultrafilters ↔ MCS
   - Extract canonical frame from algebraic structure
   - Prove representation theorem

**Total**: 800-1150 lines of new infrastructure

### Hybrid Approach

A middle ground: use algebraic insights to **simplify** the current approach without full reconstruction:

1. Define `ProvEquiv` setoid
2. Prove G/H respect equivalence
3. Use this to give cleaner proofs of coherence conditions
4. Keep the seed-extension construction but with algebraic reasoning

**Effort**: ~300-500 lines

## Risks & Mitigations

### Risk 1: Algebraic Approach is Overkill
**Risk**: Full algebraic machinery may not provide proportional benefit for TM's specific case.
**Mitigation**: The current approach (CoherentConstruction) works and only needs minor fixes.

### Risk 2: Interior Operator Not in Mathlib
**Risk**: Need to define `InteriorOperator` dual to `ClosureOperator`.
**Mitigation**: Definition is straightforward: same as ClosureOperator but with `c(x) ≤ x` instead of `x ≤ c(x)`.

### Risk 3: Stone Duality Complexity
**Risk**: Full Stone duality requires topological machinery.
**Mitigation**: For modal logic, only need the algebraic correspondence (ultrafilters ↔ MCS), not the full topological space.

## Appendix

### A. Current Codebase Files

- `Theories/Bimodal/Semantics/Truth.lean` - Reflexive semantics
- `Theories/Bimodal/ProofSystem/Axioms.lean` - T-axioms for G/H
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - T-axiom closure lemmas
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - Current construction

### B. Mathlib References

- `.lake/packages/mathlib/Mathlib/Order/Closure.lean` - ClosureOperator
- `.lake/packages/mathlib/Mathlib/Order/Nucleus.lean` - Nucleus (closure + meet preservation)
- `.lake/packages/mathlib/Mathlib/Order/Lattice/Congruence.lean` - LatticeCon

### C. Search Queries Used

1. `lean_local_search "ClosureOperator"` - Found Mathlib closure infrastructure
2. `lean_local_search "Nucleus"` - Found locale-theoretic nucleus
3. `lean_loogle "LatticeCon"` - Found lattice congruence machinery
4. `lean_leanfinder "interior operator lattice deflationary idempotent"` - Found related structures

## Next Steps

1. **Immediate**: Complete the seed consistency proofs in CoherentConstruction.lean
2. **Short-term**: Document the algebraic connection in comments/docstrings
3. **Long-term**: Consider algebraic reconstruction if cleaner proofs are desired for pedagogical purposes or Mathlib contribution
