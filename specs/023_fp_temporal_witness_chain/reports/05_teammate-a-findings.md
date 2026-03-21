# Teammate A Findings: CanonicalFMCS Usage and Dependency Analysis

**Task**: 23 - F/P temporal witness chain construction
**Session ID**: sess_1774126357_b611bb
**Run Number**: 05
**Focus**: IntBFMCS usage sites and CanonicalFMCS refactoring requirements

## IntBFMCS Usage Map

### Primary Usage Sites

1. **AlgebraicBaseCompleteness.lean** (lines 191-196)
   - Function: `construct_bfmcs_from_mcs_Int`
   - Purpose: Entry point for completeness proof - constructs BFMCS Int from MCS
   - Delegates to: `construct_bfmcs_from_mcs_Int_v4` (DirectMultiFamilyBFMCS)

2. **DirectMultiFamilyBFMCS.lean** (lines 406-414)
   - Function: `directFamily_temporally_coherent`
   - Direct calls to `intFMCS_forward_F` and `intFMCS_backward_P`
   - Purpose: Proves temporal coherence for direct families

3. **ClosedFlagIntBFMCS.lean** (lines 279-283)
   - Function: `rootClosedFlagFMCS_Int_tc`
   - Direct calls to `intFMCS_forward_F` and `intFMCS_backward_P`
   - Purpose: Proves temporal coherence for root family (older v3 construction)

### Dependency Chain

```
algebraic_base_completeness
    └── construct_bfmcs_from_mcs_Int (calls v4)
        └── construct_bfmcs_from_mcs_Int_v4
            └── directMultiFamilyBFMCS_temporally_coherent
                └── directFamily_temporally_coherent
                    ├── intFMCS_forward_F  <-- SORRY
                    └── intFMCS_backward_P <-- SORRY
```

### What Callers Actually Need

Callers require `FMCS_temporally_coherent`, which demands:
1. `forward_F`: `F(phi) ∈ mcs(t) → ∃ s > t, phi ∈ mcs(s)`
2. `backward_P`: `P(phi) ∈ mcs(t) → ∃ s < t, phi ∈ mcs(s)`

The specific type constraint is **BFMCS Int** (Int-indexed), not generic D.

## CanonicalFMCS Capabilities

### Type Structure

```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

noncomputable instance : Preorder CanonicalMCS where
  le a b := a = b ∨ CanonicalR a.world b.world
  -- Reflexive closure of CanonicalR
```

**Key Properties**:
- `Preorder` only (NOT `LinearOrder`, NOT `AddCommGroup`)
- Non-total ordering (multiple incomparable MCSes possible)
- Domain: ALL maximal consistent sets

### Sorry-Free Theorems

1. **`canonicalMCS_forward_F`** (CanonicalFMCS.lean:240-246)
   ```lean
   theorem canonicalMCS_forward_F
       (w : CanonicalMCS) (phi : Formula)
       (h_F : Formula.some_future phi ∈ canonicalMCS_mcs w) :
       ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ canonicalMCS_mcs s
   ```
   **Proof**: Witness from `canonical_forward_F` IS an MCS, hence a CanonicalMCS element.

2. **`canonicalMCS_backward_P`** (CanonicalFMCS.lean:258-269)
   ```lean
   theorem canonicalMCS_backward_P
       (w : CanonicalMCS) (phi : Formula)
       (h_P : Formula.some_past phi ∈ canonicalMCS_mcs w) :
       ∃ s : CanonicalMCS, s ≤ w ∧ phi ∈ canonicalMCS_mcs s
   ```
   **Proof**: Witness from `canonical_backward_P` IS an MCS, hence a CanonicalMCS element.

3. **`temporal_coherent_family_exists_CanonicalMCS`** (CanonicalFMCS.lean:312-330)
   - Proves existence of sorry-free temporally coherent FMCS over CanonicalMCS
   - Root context preserved via Lindenbaum extension

### Why CanonicalFMCS Works

The "All-MCS approach" sidesteps the fundamental blocker:
- Every MCS is in the domain by construction
- No reachability requirement for witnesses
- `canonical_forward_F` returns an MCS, which is automatically a domain element
- No chain embedding needed, no Lindenbaum killing F/P formulas

## Gap Analysis

### Fundamental Type Mismatch

| Aspect | IntBFMCS (Current) | CanonicalFMCS (Alternative) |
|--------|-------------------|---------------------------|
| Indexing Type | `Int` | `CanonicalMCS` |
| Type Classes | `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid` | `Preorder` only |
| Domain | Countable linear chain | Uncountable set of ALL MCSes |
| F/P Proof | Sorry (fundamentally blocked) | Sorry-free |

### TaskFrame Requirements

The semantic framework (`TaskFrame`, `TaskModel`, `WorldHistory`) requires:
```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

**CanonicalMCS lacks ALL of these**:
- No `AddCommGroup` (no additive structure)
- No `LinearOrder` (CanonicalR is not total)
- No `IsOrderedAddMonoid` (no monoid structure)

### Why IntBFMCS F/P is Fundamentally Blocked

From IntBFMCS.lean documentation (lines 19-32, 1157-1174):

> Linear chain constructions use Lindenbaum extension at each step. When building
> position n+1 from position n, the Lindenbaum lemma can introduce G(~phi) into the
> extension, which kills F(phi) = ~G(~phi). This means:
> - F(phi) at position t does NOT imply F(phi) persists to later positions
> - The dovetailing step where phi is processed may have already lost F(phi)

**This is not fixable for ANY linear chain construction.**

### Properties IntBFMCS Has That CanonicalFMCS Lacks

1. **AddCommGroup structure**: Int has `+`, `-`, `0`, group laws
2. **LinearOrder**: Int has total ordering
3. **IsOrderedAddMonoid**: Ordering compatible with addition
4. **Countability**: Int is countable (CanonicalMCS is uncountable)

These are needed for:
- `ParametricCanonicalTaskFrame D` construction
- `WorldHistory` domain convexity
- Shift-closedness of Omega
- Time arithmetic in semantic evaluation

## Refactoring Requirements

### Path 1: Direct Substitution (BLOCKED)

Cannot simply replace Int with CanonicalMCS because:
- Type class constraints incompatible
- Would require rewriting entire semantic framework
- CanonicalMCS has no additive structure for time shifts

### Path 2: Transfer Theorem Approach

Current architecture attempts this via:
```
CanonicalFMCS (sorry-free) --> Transfer --> IntBFMCS (requires embedding)
```

But transfer fails because:
- Embedding Int → CanonicalMCS gives linear chain
- Linear chain CANNOT satisfy F/P (fundamental blocker)
- There is no functorial correspondence preserving F/P witnesses

### Path 3: Alternative Semantic Framework

Would require:
1. Generalize `TaskFrame` to work with `Preorder` instead of `LinearOrder`
2. Remove `AddCommGroup` requirements from `WorldHistory`
3. Redefine time shifts without additive structure
4. Prove soundness/completeness in generalized framework

**Estimated impact**: Major architectural change to 10+ files

### Path 4: ω² Construction

Research suggests (IntBFMCS.lean lines 1172-1174):
> Would require omega-squared construction that processes F-obligations IMMEDIATELY
> when they appear, before Lindenbaum extension.

This is unexplored and may have its own blockers.

## Summary Table

| Component | IntBFMCS Status | CanonicalFMCS Status | Gap |
|-----------|-----------------|---------------------|-----|
| forward_G | Proven | Proven | None |
| backward_H | Proven | Proven | None |
| forward_F | **SORRY** (blocked) | **Proven** | Type mismatch |
| backward_P | **SORRY** (blocked) | **Proven** | Type mismatch |
| AddCommGroup | Yes | **NO** | Semantic framework |
| LinearOrder | Yes | **NO** | Semantic framework |

## Confidence Level

**HIGH** - The analysis is based on:
1. Direct code inspection of IntBFMCS.lean, CanonicalFMCS.lean, and AlgebraicBaseCompleteness.lean
2. Documented fundamental blockers with references to Task 1004 and Task 916 research
3. Clear type class constraints in the semantic framework
4. Multiple corroborating comments in the codebase explaining why this approach fails

## Key Files Referenced

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean`
