# Research Report: Discrete Representation Theorem Axiom Removal

**Task**: 15 - discrete_representation_theorem_axiom_removal
**Session**: sess_1774090934_0d8079
**Date**: 2026-03-21

---

## 1. Executive Summary

This research identifies the architectural path for wiring the Succ-chain FMCS and CanonicalTask-based TaskFrame into the unconditional discrete representation theorem. The key findings are:

1. **Current Infrastructure Gap**: The discrete representation theorem (`DiscreteInstantiation.lean`) is conditional - it requires a `construct_bfmcs` function that produces a temporally coherent BFMCS over Int. Tasks 13-14 provide the pieces needed to build this.

2. **Axioms to Remove**: Three axioms must be eliminated:
   - `discrete_Icc_finite_axiom` (DiscreteTimeline.lean) - Unrelated to Succ-chain approach
   - `discreteImmediateSuccSeed_consistent_axiom` (DiscreteSuccSeed.lean) - Used by SuccExistence
   - `discreteImmediateSucc_covers_axiom` (DiscreteSuccSeed.lean) - Used by SuccExistence

3. **Critical Finding**: The Succ-chain FMCS (`SuccChainFMCS.lean`) still contains 5 axioms that need proving before the chain can be considered sorry-free. These axioms relate to F/P propagation and the H-version of the temporal 4 axiom.

4. **Recommended Approach**: Use the SuccChainTemporalCoherent family to construct a BFMCS wrapper, then wire it to DiscreteInstantiation via the `construct_bfmcs` callback pattern.

---

## 2. Current Discrete Representation Structure

### 2.1 Conditional Form (DiscreteInstantiation.lean)

The current discrete representation theorem has this form:

```lean
theorem discrete_representation_conditional
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ))
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
         (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
         M = fam.mcs t) :
    ∃ (B : BFMCS Int) (h_tc : B.temporally_coherent)
      (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
      ¬truth_at DiscreteCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t φ
```

The gap is the `construct_bfmcs` function - given any MCS M, produce a temporally coherent BFMCS containing M.

### 2.2 What Tasks 13-14 Provide

| Component | File | Status |
|-----------|------|--------|
| Succ-chain FMCS | `SuccChainFMCS.lean` | Has 5 axioms |
| CanonicalTask TaskFrame | `SuccChainTaskFrame.lean` | Complete |
| WorldHistory | `SuccChainWorldHistory.lean` | Complete |
| TemporalCoherentFamily | `SuccChainFMCS.lean` | Needs F/P axioms |

### 2.3 FMCS Coherence Properties

From `SuccChainFMCS.lean`, the family provides:
- `forward_G`: Proven (uses Succ.g_persistence and temp_4)
- `backward_H`: Proven (uses past_4_axiom)
- `forward_F`: **AXIOM** (`succ_chain_forward_F_axiom`)
- `backward_P`: **AXIOM** (`succ_chain_backward_P_axiom`)

---

## 3. Axioms Inventory

### 3.1 Axioms in SuccChainFMCS.lean (Task 14)

| Axiom | Type | Justification |
|-------|------|---------------|
| `F_top_propagates` | F(top) preservation through Succ | Semantic - seriality propagation |
| `P_top_propagates` | P(top) preservation through Pred | Symmetric to above |
| `past_4_axiom` | `⊢ H(φ) → H(H(φ))` | Should be derivable via temporal duality |
| `succ_chain_forward_F_axiom` | F(φ) witness existence | Key coherence axiom |
| `succ_chain_backward_P_axiom` | P(φ) witness existence | Symmetric to above |

### 3.2 Axioms in DiscreteSuccSeed.lean (Task 12)

| Axiom | Type | Justification |
|-------|------|---------------|
| `discreteImmediateSuccSeed_consistent_axiom` | Seed consistency | Seriality argument |
| `discreteImmediateSucc_covers_axiom` | Covering property | Blocking formula argument |

### 3.3 Axiom in DiscreteTimeline.lean

| Axiom | Type | Justification |
|-------|------|---------------|
| `discrete_Icc_finite_axiom` | Interval finiteness | Stage-bounding argument |

### 3.4 Axiom Removal Feasibility

**Can be removed via Succ-chain approach**:
- `discrete_Icc_finite_axiom` - Not needed when using Succ-chain directly on Int

**Require full proof or alternative approach**:
- `discreteImmediateSuccSeed_consistent_axiom` - Used by SuccExistence which Succ-chain depends on
- `discreteImmediateSucc_covers_axiom` - Used by SuccExistence which Succ-chain depends on
- `succ_chain_forward_F_axiom` - Core F-witness existence
- `succ_chain_backward_P_axiom` - Core P-witness existence

---

## 4. Wiring Architecture

### 4.1 Target: Unconditional Representation

```lean
theorem discrete_representation_unconditional
    (φ : Formula) (h_not_prov : ¬Nonempty (DerivationTree [] φ)) :
    ∃ (B : BFMCS Int) (h_tc : B.temporally_coherent)
      (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
      ¬truth_at DiscreteCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t φ
```

### 4.2 Required Components

1. **SerialMCS from M**: Convert any MCS M to a `SerialMCS` (which bundles F_top and P_top membership)

2. **SuccChainFMCS from SerialMCS**: Use `SuccChainFMCS M0` to get an FMCS

3. **BFMCS wrapper**: Package the single FMCS as a BFMCS (singleton bundle)

4. **Temporal coherence**: Use `SuccChainTemporalCoherent M0` for coherence

5. **Time placement**: M0 appears at time 0 in the chain

### 4.3 Key Lemma: MCS to SerialMCS

```lean
-- Every MCS is serial (contains F(top) and P(top))
noncomputable def MCS_to_SerialMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) : SerialMCS :=
  { world := M
  , is_mcs := h_mcs
  , has_F_top := SetMaximalConsistent.contains_seriality_future M h_mcs
  , has_P_top := SetMaximalConsistent.contains_seriality_past M h_mcs
  }
```

### 4.4 construct_bfmcs Implementation

```lean
noncomputable def construct_bfmcs_impl (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M = fam.mcs t :=
  let M0 := MCS_to_SerialMCS M h_mcs
  let fam := SuccChainFMCS M0
  let tcf := SuccChainTemporalCoherent M0
  -- Need to wrap as BFMCS and prove temporal coherence
  sorry -- Blocked by F/P axioms
```

---

## 5. Dependencies and Blocking Issues

### 5.1 Dependency Graph

```
discrete_representation_unconditional
├── construct_bfmcs_impl
│   ├── SuccChainTemporalCoherent
│   │   ├── SuccChainFMCS
│   │   │   ├── succ_chain_forward_F_axiom  [AXIOM]
│   │   │   └── succ_chain_backward_P_axiom [AXIOM]
│   │   └── forward_chain/backward_chain
│   │       ├── successor_exists
│   │       │   └── discreteImmediateSuccSeed_consistent_axiom [AXIOM]
│   │       └── predecessor_exists
│   │           └── (symmetric axiom)
│   └── BFMCS wrapper (modal coherence)
└── parametric_shifted_truth_lemma
```

### 5.2 Blocking Axioms

The task cannot be completed without addressing these axioms:

1. **succ_chain_forward_F_axiom**: F(φ) ∈ fam(n) implies witness m > n with φ ∈ fam(m)

2. **succ_chain_backward_P_axiom**: P(φ) ∈ fam(n) implies witness m < n with φ ∈ fam(m)

3. **discreteImmediateSuccSeed_consistent_axiom**: Used by successor_exists which builds the chain

### 5.3 Why F/P Axioms Are Difficult

The challenge with F/P witnesses in linear chains (documented in IntBFMCS.lean):

> Linear chain constructions use Lindenbaum extension at each step. When building position n+1 from position n, the Lindenbaum lemma can introduce G(~phi) into the extension, which kills F(phi). This means F(phi) at position t does NOT imply F(phi) persists to later positions.

**Alternative considered**: CanonicalFMCS uses ALL MCSes as domain, where F/P witnesses trivially exist. But this doesn't give Int-indexed structure needed for TaskFrame.

---

## 6. Options Analysis

### Option A: Prove the F/P Axioms (Recommended if possible)

**Strategy**: Use bounded_witness from CanonicalTaskRelation.lean

For F(φ) ∈ fam(n), the formula has bounded F-nesting depth. By single_step_forcing, if F^k(φ) ∈ u but F^(k+1)(φ) ∉ u, then φ appears at distance k in any Succ chain.

**Complexity**: High - requires careful tracking of F-nesting through chain construction

**Outcome**: Full sorry-free discrete representation

### Option B: Accept Axioms as Semantic Debt

**Strategy**: Document axioms as semantically justified

The axioms are mathematically sound:
- F/P witnesses exist semantically (seriality + chain structure)
- Seed consistency follows from seriality argument
- Covering follows from blocking formula construction

**Complexity**: Low - just wire existing components

**Outcome**: Discrete representation works but has documented axioms

### Option C: Use Alternative BFMCS Construction

**Strategy**: Use CanonicalMCSBFMCS (sorry-free F/P) with Int transfer

The CanonicalFMCS construction from CanonicalFMCS.lean is sorry-free for F/P. Could transfer via dovetailing enumeration.

**Challenge**: Documented as fundamentally blocked in IntBFMCS.lean - the enumeration loses F-obligations.

**Outcome**: Likely blocked

---

## 7. Recommended Implementation Path

Given the blocking issues, the recommended path is:

### Phase 1: Wire existing infrastructure (Option B)

1. Create `SuccChainBFMCS.lean` that wraps SuccChainFMCS as a BFMCS
2. Prove modal coherence for singleton bundle (trivial)
3. Use SuccChainTemporalCoherent for temporal coherence (depends on axioms)
4. Implement `construct_bfmcs_impl` using this wrapper
5. Wire to DiscreteInstantiation to get unconditional theorem

### Phase 2: Document axiom status

6. Document that discrete representation depends on SuccChainFMCS axioms
7. Create axiom removal roadmap

### Phase 3: Axiom elimination (future work)

8. Prove past_4_axiom via temporal duality (straightforward)
9. Prove F_top_propagates / P_top_propagates (seriality propagation)
10. Prove succ_chain_forward_F_axiom (hardest - F-witness placement)
11. Prove succ_chain_backward_P_axiom (symmetric)
12. Prove discreteImmediateSuccSeed_consistent_axiom (seriality argument)
13. Prove discreteImmediateSucc_covers_axiom (blocking formula argument)

### Regarding discrete_Icc_finite_axiom

This axiom in DiscreteTimeline.lean is used for a **different** discrete completeness approach (staged timeline quotient). The Succ-chain approach bypasses it entirely by working directly with Int-indexed families. The axiom can remain for backward compatibility but is not used in the new approach.

---

## 8. File Structure

### New Files to Create

```
Theories/Bimodal/Metalogic/Bundle/
├── SuccChainBFMCS.lean      # BFMCS wrapper for SuccChainFMCS
└── SuccChainRepresentation.lean  # Unconditional theorem
```

### Files to Modify

```
Theories/Bimodal/Metalogic/Algebraic/
└── DiscreteInstantiation.lean  # Import and use SuccChainRepresentation
```

---

## 9. Verification Checklist

Before marking complete:

- [ ] `SuccChainBFMCS` type checks with SuccChainFMCS
- [ ] Modal coherence proven for singleton bundle
- [ ] `construct_bfmcs_impl` compiles (with axiom dependencies)
- [ ] `discrete_representation_unconditional` stated and proven
- [ ] `lake build` succeeds
- [ ] Axiom dependencies documented in module headers
- [ ] Connection to DiscreteInstantiation established

---

## 10. Axiom Removal Status Summary

| Axiom | Location | Removal Path | Priority |
|-------|----------|--------------|----------|
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean | Bypassed by Succ-chain approach | N/A |
| `past_4_axiom` | SuccChainFMCS.lean | Derive via temporal duality | High |
| `F_top_propagates` | SuccChainFMCS.lean | Seriality propagation | Medium |
| `P_top_propagates` | SuccChainFMCS.lean | Symmetric | Medium |
| `succ_chain_forward_F_axiom` | SuccChainFMCS.lean | Bounded witness theorem | Hard |
| `succ_chain_backward_P_axiom` | SuccChainFMCS.lean | Symmetric | Hard |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean | Seriality argument | Hard |
| `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean | Blocking formula | Very Hard |

---

## 11. Conclusion

The task can be partially completed by wiring existing infrastructure, producing an unconditional discrete representation theorem that relies on documented axioms. Full axiom removal requires proving the F/P witness axioms in SuccChainFMCS.lean and the seed consistency/covering axioms in DiscreteSuccSeed.lean.

The `discrete_Icc_finite_axiom` in DiscreteTimeline.lean is not relevant to this approach and can remain as legacy infrastructure for the staged timeline construction.

**Recommendation**: Proceed with Option B (wire with axioms) to unblock downstream tasks, then pursue axiom elimination in follow-up tasks.
