# Phase 5: FUC/FSC Coherence Research Report

**Research Teammate D** | Task 107 | Session: sess_1777762781_b2f826

## Executive Summary

This report analyzes the final sorry sites (FUC/FSC - Forward Until/Since Coherence) in `ChronicleToCountermodel.lean` (lines 615, 619). These represent the culmination of Burgess's completeness proof - the truth lemma establishing that the chronicle construction faithfully represents Until/Since formulas.

**Key Finding**: The FUC/FSC proofs require connecting finite-stage C5 elimination (which establishes witnesses with guards at intermediate points) to the limit construction via Claim 2.11. The current `limit_satisfies_c5_weak` provides endpoint witnesses, but the guard at intermediate points requires `limit_satisfies_c5_full`.

## 1. Mathematical Analysis of FUC/FSC Coherence

### 1.1 The Coherence Conditions

In `ChronicleToCountermodel.lean`, the restricted forward Until/Since coherence requires:

**Forward Until Coherence (FUC)**:
```
U(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ ∀ r ∈ (t,s), φ ∈ mcs(r)
```

**Forward Since Coherence (FSC)**:
```
S(φ,ψ) ∈ mcs(t) → ∃ s < t, ψ ∈ mcs(s) ∧ ∀ r ∈ (s,t), φ ∈ mcs(r)
```

### 1.2 The Problem Structure

The current proof has:
- **Endpoint witness**: From `limit_satisfies_c5_weak`, we get y > x with η ∈ limit_f(y)
- **Missing**: The guard φ ∈ limit_f(z) for all z ∈ (x,y) in limit_dom

The backward coherence (BUC/BSC) was already proved using C4's contrapositive - if a witness exists but the guard fails, C4 provides a contradiction point. The forward direction requires the positive guarantee that guards hold.

### 1.3 Connection to C5

C5 is defined in `ChronicleTypes.lean` (lines 427-433):
```lean
def Chronicle.c5 (χ : Chronicle) : Prop :=
  ∀ x ∈ χ.dom,
    ∀ (γ δ : Formula),
      Formula.untl γ δ ∈ χ.f x →
      ∃ y ∈ χ.dom, x < y ∧ δ ∈ χ.f y ∧
        ∀ z ∈ χ.dom, x < z → z < y →
          γ ∈ χ.f z ∧ Formula.untl γ δ ∈ χ.f z
```

The critical part is the guard condition: `∀ z ∈ χ.dom, x < z → z < y → γ ∈ χ.f z`

## 2. Burgess 1982 Reference: Section 2.11 Claim 2.11

### 2.1 Claim 2.11 (The Truth Lemma)

From Burgess 1982, Section 2.11 (p. 373-374):

> **Claim 2.11**: For any formula φ and any point x in the limit domain:
> - φ ∈ f(x) iff the valuation V satisfies φ at x
> - Where V(α) = {x : α ∈ f(x)} for atoms α

This claim is proved by **induction on formula complexity**:

**Base cases** (atoms, bot): By definition of V

**Inductive cases**:
- Imp: Follows from MCS implication property
- Box: Follows from MCS Box property (maximal consistency)
- **G/H**: Follows from g_content/h_content and C3 three-way decomposition
- **Until/Since**: This is the hard case - requires C5/C5' at the limit

### 2.2 The Until Case Analysis

For Until(φ,ψ) at point x:

**Forward direction** (syntax → semantics):
1. Assume Until(φ,ψ) ∈ f(x)
2. By C5: ∃ y > x with ψ ∈ f(y) and φ ∈ f(z) for all z ∈ (x,y)
3. By induction: ψ true at y, φ true at all z ∈ (x,y)
4. Therefore: Until(φ,ψ) true at x

**Backward direction** (semantics → syntax):
1. Assume Until(φ,ψ) true at x
2. ∃ y > x with ψ true at y, φ true on (x,y)
3. By induction: ψ ∈ f(y), φ ∈ f(z) for all z ∈ (x,y)∩dom
4. By C5-completeness (contrapositive of C4): Until(φ,ψ) ∈ f(x)

### 2.3 Why C5 Implies the Full Guard

The key insight from Burgess: C5 at the **finite stages** carries the full guard information. When we eliminate a C5 counterexample at stage n, we:

1. Insert a witness point y with ψ ∈ f(y)
2. **Crucially**: For all intermediate points z already in dom(n), we have φ ∈ f(z)

The omega-chain construction ensures that **all** intermediate points between x and y eventually enter the domain. Since the C5 elimination adds the witness y and ensures φ at all existing intermediate points, and future C5 eliminations for nested Until formulas preserve this property, the guard holds at the limit.

## 3. Analysis of `limit_satisfies_c5_full` Requirement

### 3.1 Current vs Full C5

**Current (`limit_satisfies_c5_weak`)**: Lines 569-592 in ChronicleConstruction.lean
```lean
theorem limit_satisfies_c5_weak (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y
```

**Required (`limit_satisfies_c5_full`)**:
```lean
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z
```

### 3.2 Why the Guard is Hard

The difficulty is that:
1. At finite stage n, when we eliminate (x, ξ, η), we add witness y_n
2. At that moment, dom(n) has only finitely many points between x and y_n
3. Future stages add more points in (x, y_n) ∩ limit_dom
4. **We must prove**: For any z added later to (x, y_n), ξ ∈ limit_f(z)

## 4. g-Value Propagation from Finite to Limit Stages

### 4.1 The Limit Interval Function

Defined in ChronicleConstruction.lean (lines 837-839):
```lean
noncomputable def limit_g (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat → Rat → Set Formula :=
  fun x z => { φ | ∀ y ∈ limit_dom A h_mcs, x < y → y < z → φ ∈ limit_f A h_mcs y }
```

This is the **C3-derived g**: it captures formulas true at ALL intermediate points.

### 4.2 C3 Three-Way Property at the Limit

Theorem `limit_c3` (lines 852-868):
```lean
theorem limit_c3 (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y z : Rat)
    (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hz : z ∈ limit_dom A h_mcs) (hxy : x < y) (hyz : y < z) :
    limit_g A h_mcs x z = limit_g A h_mcs x y ∩ limit_f A h_mcs y ∩ limit_g A h_mcs y z
```

### 4.3 Key Consequence: Interval Subset Point

Theorem `limit_c3_interval_subset_point` (lines 877-885):
```lean
theorem limit_c3_interval_subset_point (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y z : Rat)
    (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hz : z ∈ limit_dom A h_mcs) (hxy : x < y) (hyz : y < z) :
    limit_g A h_mcs x z ⊆ limit_f A h_mcs y
```

**This is the key**: If ξ ∈ limit_g(x,y), then ξ ∈ limit_f(z) for all z ∈ (x,y).

## 5. Connection Between c2' and FUC/FSC

### 5.1 What is c2'?

From ChronicleTypes.lean (lines 372-374):
```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)
```

For adjacent pairs, g(x,y) is a **maximal DCS** satisfying the Burgess r3-relation with f(x) and f(y).

### 5.2 How c2' Enables FUC/FSC

The c2' property at **finite stages** ensures:

1. For adjacent (x,y) at stage n: g_n(x,y) is BurgessR3Maximal
2. BurgessR3Maximal contains all formulas "allowed" by the r-relation
3. Specifically: if Until(φ,ψ) ∈ f(x) and we have the right structure, φ propagates through g-values

The proof strategy for FUC:
1. At stage n, eliminate Until(φ,ψ) at x → get witness y_n with ψ ∈ f(y_n)
2. For any z in dom(n) with x < z < y_n: φ ∈ f(z) by elimination construction
3. For future z' added to (x, y_n): use c2' maximality + C3 propagation
4. At the limit: φ ∈ limit_f(z) for all z ∈ (x, y) by construction of limit_g

## 6. Step-by-Step Proof Plan for Both Sorry Sites

### 6.1 FUC Proof Plan (Line 615)

```lean
theorem cantor_bfmcs_restricted_fuc ...
  ...
  · -- Forward Until: U(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ guard
    intro t φ ψ _h_sub h_until
    
    -- Step 1: Transfer to limit coordinates
    set offset := s - cantor_zero N h_N
    have h_until' : Formula.untl φ ψ ∈ limit_f N h_N 
        ((cantor_iso N h_N).symm (t - offset)).val := h_until
    have h_dom_t := ((cantor_iso N h_N).symm (t - offset)).property
    
    -- Step 2: Use limit_satisfies_c5_weak to get endpoint witness
    obtain ⟨y, hy_dom, hy_lt, hy_ψ⟩ := 
      limit_satisfies_c5_weak N h_n ((cantor_iso N h_N).symm (t - offset)).val 
        h_dom_t φ ψ h_until'
    
    -- Step 3: Establish the guard using Claim 2.11 property
    -- Key insight: C5 elimination at stage n ensures φ at all intermediate points
    -- that exist at stage n. For future points, use the structure of omega-chain.
    
    -- Step 4: Construct witness in rational coordinates
    set y_rat := (cantor_iso N h_N) ⟨y, hy_dom⟩ + offset
    have hy_rat_lt : t < y_rat := ...
    have hy_ψ_rat : ψ ∈ (rooted_cantor_fmcs N h_N s).mcs y_rat := ...
    
    -- Step 5: Prove the guard at all intermediate points
    have h_guard : ∀ r : Rat, t < r → r < y_rat → φ ∈ (rooted_cantor_fmcs N h_N s).mcs r := by
      intro r ht_r r_y
      -- Transfer r to limit coordinates
      set r_lim := (cantor_iso N h_N).symm (r - offset)
      -- Show r_lim is between t and y in limit domain
      have h_r_between : ((cantor_iso N h_N).symm (t - offset)).val < r_lim.val := ...
      have h_r_y : r_lim.val < y := ...
      -- Key: Prove φ ∈ limit_f(r_lim)
      -- This requires showing that any point in (t, y) was either:
      -- (a) Present at the elimination stage and got φ assigned then, OR
      -- (b) Added later but φ was preserved via the g-value chain
      sorry -- Requires c2' + Claim 2.11 argument
    
    exact ⟨y_rat, hy_rat_lt, hy_ψ_rat, h_guard⟩
```

### 6.2 Detailed FUC Proof Architecture

**Phase A: Setup**
1. Transfer from Cantor family coordinates to limit coordinates
2. Apply `limit_satisfies_c5_weak` to get endpoint witness y

**Phase B: Guard Propagation**
The guard proof requires analyzing the omega-chain construction:

For any z ∈ limit_dom with t < z < y:
- z entered the domain at some stage n_z
- The C5 elimination for (t, φ, ψ) happened at stage n_witness
- Case analysis:
  - If n_z < n_witness: z was already in dom when witness was added
    - C5 elimination ensures φ ∈ f(z) at stage n_witness
    - f-agreement preserves this to the limit
  - If n_z ≥ n_witness: z was added after the witness
    - Use C3 + limit_g construction
    - Show φ ∈ limit_g(t,y) by C3 properties
    - Use `limit_c3_interval_subset_point` to get φ ∈ limit_f(z)

**Phase C: Coordinate Transfer**
Transfer the witness and guard back to rational coordinates

### 6.3 FSC Proof Plan (Line 619)

Mirror of FUC using:
- `limit_satisfies_c5'_weak` for endpoint witness
- C5' (Since) condition for backward guard
- Same c2' + Claim 2.11 argument structure

## 7. Helper Lemmas Needed

### 7.1 Core Lemmas (Must Prove)

```lean
-- Lemma 1: C5 elimination preserves guard at existing points
theorem omega_chain_c5_preserves_guard (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x : Rat) (φ ψ : Formula)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (h_until : Formula.untl φ ψ ∈ (omega_chain_val A h_mcs n).f x)
    (z : Rat) (hz : z ∈ (omega_chain_val A h_mcs n).dom)
    (hxz : x < z) :
    -- After C5 elimination at step n (if this counterexample is processed),
    -- either z is not in the new witness interval, or φ ∈ f(z) in the result
    sorry

-- Lemma 2: If φ ∈ g_n(x,y) at stage n, and z ∈ (x,y) is added later,
-- then φ ∈ f(z) at the limit
theorem g_value_propagates_to_future_points (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x y z : Rat)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (hy : y ∈ (omega_chain_val A h_mcs n).dom)
    (hxy : x < y)
    (φ : Formula)
    (h_g : φ ∈ (omega_chain_val A h_mcs n).g x y)
    (hz : z ∈ limit_dom A h_mcs)
    (hxz : x < z) (hzy : z < y) :
    φ ∈ limit_f A h_mcs z :=
  sorry

-- Lemma 3: C5 implies φ ∈ g(x,y) at the elimination stage
theorem c5_implies_phi_in_g (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x y : Rat) (φ ψ : Formula)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (hy : y ∈ (omega_chain_val A h_mcs (n+1)).dom)
    (h_until : Formula.untl φ ψ ∈ (omega_chain_val A h_mcs n).f x)
    (h_processed : counterexample_enum (Nat.unpair n).2 = ⟨x, 0, φ, ψ, .c5_forward⟩)
    (h_y_witness : ψ ∈ (omega_chain_val A h_mcs (n+1)).f y ∧ x < y) :
    φ ∈ (omega_chain_val A h_mcs (n+1)).g x y :=
  sorry

-- Lemma 4: g-values persist through the omega-chain
theorem g_value_persistence (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    {n m : Nat} (hnm : n ≤ m)
    (x y : Rat)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (hy : y ∈ (omega_chain_val A h_mcs n).dom)
    (φ : Formula)
    (h_g : φ ∈ (omega_chain_val A h_mcs n).g x y) :
    φ ∈ (omega_chain_val A h_mcs m).g x y :=
  sorry
```

### 7.2 From Existing Library

Already available:
- `limit_c3` - three-way C3 at limit
- `limit_c3_interval_subset_point` - key consequence
- `omega_chain_f_agrees_le` - f agreement across stages
- `limit_f_eq` - limit_f characterization
- `limit_dom_dense` - density of limit domain

## 8. Complete Proof Architecture

### 8.1 Dependency Graph

```
Phase 4 (c2' at finite stages)
        |
        v
Lemma: c2'_implies_g_maximal
        |
        v
Lemma: g_maximal_plus_c3_implies_guard_propagation
        |
        v
Lemma: limit_satisfies_c5_full (NEW)
        |
        v
Theorem: cantor_bfmcs_restricted_fuc (COMPLETE FUC)
        |
        v
Theorem: cantor_bfmcs_restricted_fsc (COMPLETE FSC - mirror)
        |
        v
Theorem: dd_countermodel_chronicle (ZERO SORRIES!)
        |
        v
Theorem: bx_completeness (BX COMPLETENESS!)
```

### 8.2 The Full Proof Flow

1. **Start**: U(φ,ψ) ∈ (rooted_cantor_fmcs M h_mcs s).mcs t
2. **Transfer**: Convert to limit_f coordinates
3. **Apply weak C5**: Get y > x with ψ ∈ limit_f(y)
4. **Claim 2.11 argument**: 
   - At stage n where C5 counterexample was eliminated:
     - If z ∈ dom(n) and x < z < y: φ ∈ f_n(z) by elimination construction
     - If z added later: use g_n(x,y) ⊆ g_m(x,y) for m ≥ n
   - At limit: φ ∈ limit_g(x,y) implies φ ∈ limit_f(z) for all z ∈ (x,y)
5. **Return witness**: Transfer y and guard back to rational coords

### 8.3 Key Insight: Why This Works

The omega-chain construction has a **monotonicity property**:
- Once φ is in f(z) at stage n, it stays in f(z) at all later stages
- The g-values are also monotonic (or at least, their "content" propagates)
- C5 elimination doesn't just add a witness; it ensures the guard at all existing points

When a new point z' is inserted between x and y:
- It's inserted as part of some other C5 elimination
- The c2' property at that stage ensures g-values are maximal
- This maximality ensures φ propagates through the new interval

## 9. Estimated Effort

### 9.1 Breakdown

| Component | Estimated Hours | Notes |
|-----------|----------------|-------|
| Helper Lemma 1 (C5 guard preservation) | 4-6 | Complex case analysis on elimination |
| Helper Lemma 2 (g-value propagation) | 3-4 | Uses c2' maximality |
| Helper Lemma 3 (C5 implies φ ∈ g) | 2-3 | From elimination result structure |
| Helper Lemma 4 (g-value persistence) | 2-3 | Monotonicity argument |
| `limit_satisfies_c5_full` | 4-6 | Integration of above lemmas |
| `cantor_bfmcs_restricted_fuc` | 3-4 | Apply full C5 + coordinate transfer |
| `cantor_bfmcs_restricted_fsc` | 2-3 | Mirror of FUC |
| Testing & verification | 2-3 | Ensure no new sorry introduced |
| **Total** | **~22-32 hours** | Parallelizable with other teammates |

### 9.2 Risk Factors

1. **c2' complexity**: If c2' at finite stages doesn't provide enough structure, may need additional invariants
2. **EliminationResult structure**: May need to extend `c5_forward_witness` to include guard info
3. **g-value monotonicity**: Need to verify g-values actually persist (not recomputed at each stage)

## 10. Dependencies: Phase 4 Completion

### 10.1 What Phase 4 Provides

Phase 4 establishes `c2'` at finite stages in `CounterexampleElimination.lean`:
- 7 sorry sites for c2' in elimination functions
- These prove that when we eliminate a counterexample, c2' is preserved

### 10.2 How c2' is Used in Phase 5

The c2' property ensures:
1. For adjacent pairs (x,y) at any stage n: g_n(x,y) is maximal w.r.t. burgessR3
2. This maximality is crucial for propagating formulas through intervals
3. When a new point is inserted between existing points, the g-values on the sub-intervals are also maximal

### 10.3 Blocking Analysis

**If Phase 4 is incomplete**:
- Cannot prove g-value propagation lemmas
- Cannot establish the connection between finite-stage guards and limit guards
- Phase 5 is **BLOCKED** on Phase 4

**Recommended approach**: 
1. Assume c2' is available (as specified in EliminationResult structure)
2. Write Phase 5 proof conditional on c2' lemmas
3. When Phase 4 completes, the integration should be seamless

## 11. References

### 11.1 Burgess 1982

- **Section 2.5**: Definition of chronicle conditions C0-C5, C0'-C5'
- **Section 2.6**: Definition 2.5 (r-relation, R-maximality) - corresponds to c2'
- **Section 2.7-2.8**: Lemma 2.5 (absorption), Lemma 2.6 (splitting)
- **Section 2.9**: Omega-chain construction
- **Section 2.10**: C5 satisfaction at finite stages
- **Section 2.11**: Claim 2.11 (truth lemma) - **THE KEY SECTION**

### 11.2 Code Files

- `ChronicleToCountermodel.lean`: Lines 604-619 (FUC/FSC sorry sites)
- `ChronicleConstruction.lean`: Lines 569-592 (limit_satisfies_c5_weak), 837-839 (limit_g), 1194-1246 (Claim 2.11)
- `ChronicleTypes.lean`: Lines 372-374 (c2'), 427-433 (C5 definition)
- `CounterexampleElimination.lean`: c2' sorry sites (lines 756, 768, 794, 806, 834, 845, 872, 883, 918, 931)
- `RRelation.lean`: Lines 442-600 (Lemma 2.5 absorption)
- `PointInsertion.lean`: Lines 219-235 (Lemma 2.5 reference)

## 12. Conclusion

The FUC/FSC sorry sites represent the **final step** in proving the Burgess completeness theorem. The proof strategy is clear:

1. **Connect finite to limit**: Use Claim 2.11 to show that C5 at finite stages (with full guard) propagates to the limit
2. **Leverage c2'**: The maximality property from c2' ensures formula propagation through g-values
3. **Apply C3**: The three-way decomposition provides the bridge between g-values and point values

**Estimated timeline**: ~4 hours per proof plan, ~24-32 hours total for complete FUC/FSC implementation.

**Critical path**: Phase 4 (c2' at finite stages) must complete first. Once c2' is available, Phase 5 can proceed to establish the truth lemma and complete the representation theorem.

---

**Report completed**: 2026-05-02
**Next steps**: Implement helper lemmas once Phase 4 provides c2' infrastructure