# Teammate B: Temporal Shift Automorphism Analysis

## Key Findings

1. **G lacks an algebraic inverse** because it is deflationary (G(a) <= a) and idempotent (G(G(a)) = G(a)). This means "shifting forward" cannot be defined as G^(-1) at the algebraic level.

2. **The existing `time_shift` operates on histories, not on ultrafilters**. The codebase already has `WorldHistory.time_shift` which shifts by duration Delta, but this is a semantic construction on concrete histories, not an algebraic automorphism.

3. **Temporal duality sigma exists but is reversal, not translation**. The `sigma_quot` in LindenbaumQuotient.lean swaps G and H (past/future duality), but this is temporal reversal (t -> -t), not translation (t -> t+1).

4. **The FMCS construction uses ExistsTask/Succ relations** to build chains. The key insight is that R_G on Spec(A) gives the "potential successor" relation, but it is not functional - multiple futures are possible.

5. **A shift automorphism tau would require a functional successor**, which exists only under specific conditions (discrete time with SuccOrder, or by fixing a particular history).

## Technical Analysis

### Why G Lacks an Inverse

The G operator on the Lindenbaum algebra satisfies:

```lean
-- From InteriorOperators.lean and TenseS5Algebra.lean:
box_deflationary : forall a, box a <= a       -- Modal T
G_monotone : forall a b, a <= b -> G a <= G b -- Temporal K
-- G is NOT an interior operator under strict semantics:
-- temp_t_future (Gφ -> φ) is invalid for strict future
```

The fundamental issue is that G is **deflationary in the reflexive semantics** (when using Gφ -> φ) and **merely monotone in strict semantics**. Neither case admits an inverse:

1. **Reflexive case**: G(a) <= a always. If G had an inverse G^(-1), we would have a <= G^(-1)(G(a)) <= G^(-1)(a), giving a <= G^(-1)(a). But also G(G^(-1)(a)) = a, so G^(-1)(a) >= a. This gives G^(-1)(a) = a for all a, meaning G = id, which contradicts deflationarity.

2. **Strict case**: G doesn't satisfy G(a) <= a, but G is still a "collapse" operator - it identifies different formulas. The image of G is a proper subalgebra (the "temporally persistent" elements), so G is not surjective and cannot have a left inverse.

**Mathematical conclusion**: G is analogous to a projection or closure operator - it loses information. The "shift" cannot be algebraically defined as G^(-1).

### Construction Approaches for tau

#### Approach 1: Successor Relation on R_G-chains

The `ExistsTask` relation from CanonicalFrame.lean defines:

```lean
def ExistsTask (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

This is the canonical R_G relation: M R_G M' iff all G-formulas of M are satisfied at M'. Within an R_□-class (modal equivalence class), the Linearity axiom ensures R_G is a linear preorder.

**Problem**: R_G is not functional. Given U, there may be multiple V with U R_G V. For example, if Fφ and Fψ are both in U, we need witnesses for both, but different witnesses might not be R_G-related to each other.

**Potential resolution**: Use Zorn's lemma to extract a maximal R_G-chain, then define tau along that chain. But this is a Choice-dependent construction, not purely algebraic.

#### Approach 2: Factor through Fixpoint Algebra

The fixed points of G form a subalgebra:
```
Fix(G) = { a : A | G(a) = a }
```

By MF+TF (shift-closure axioms), box formulas are G-fixed:
- MF: □a <= □(G(a)) and box_deflationary: □(G(a)) <= G(a) <= a, so □a <= a.
- Combined with □□a = □a (idempotent) and box_deflationary, we get □a = G(□a) for box elements.

**The problem**: Fix(G) is the "eternal" subalgebra - elements true at all times. Translation on this subalgebra is trivial (identity), which doesn't help build temporally varying FMCS.

#### Approach 3: Use F Directly

Define "existential future" as F(a) = (G(a^c))^c = ¬G¬a. This is the dual of G.

The idea: if F(a) ∈ U, then there exists V with U R_G V and a ∈ V. Could we define tau(U) as "some" such V?

**Problem**: This requires Choice and doesn't give a canonical/functional successor. Different choices of V for different F-obligations might be inconsistent.

**Partial resolution from codebase**: The `canonical_forward_F` theorem shows:
```lean
theorem canonical_forward_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ ExistsTask M W ∧ psi ∈ W
```

This builds a witness W for each F-obligation independently via Lindenbaum extension. But different F-obligations get different witnesses - there's no single "successor MCS".

#### Approach 4: Use SuccChain Construction (Existing in Codebase)

The `CanonicalTask_forward` from CanonicalTaskRelation.lean defines:
```lean
inductive CanonicalTask_forward : Set Formula -> Nat -> Set Formula -> Prop
  | base : CanonicalTask_forward u 0 u
  | step : Succ u w -> CanonicalTask_forward w n v -> CanonicalTask_forward u (n+1) v
```

Here `Succ` is a specific choice of successor relation. If we can make `Succ` functional (pick a canonical successor), we get:

```
tau(U) := Succ(U)   -- the canonical successor
FMCS(t) := tau^t(U_0) for some base ultrafilter U_0
```

**This is essentially what SuccChainFMCS.lean does**, but the question is: what makes Succ functional?

### R_G to Functional Chains

The key insight from the STSA research report (task 992):

> Within an R_□-class, R_G is a linear preorder (from linearity axiom)
> Seriality (F⊤, P⊤) ensures no endpoints
> For discrete D: SuccOrder gives functional successor
> For dense D: Between any two R_G-related points, there's another

For discrete completeness:

1. **Linear order on times**: D = Int or Nat with standard order
2. **Successor function on D**: succ(t) = t + 1
3. **Succ relation on MCS**: Build inductively

The `SuccRelation.lean` likely defines:
```lean
def Succ (M M' : Set Formula) : Prop :=
  -- M' is a "successor" of M satisfying G-forward and F-witnessing
```

The critical question is whether this is functional. Looking at `canonical_forward_F`, the Lindenbaum extension gives existence but not uniqueness.

**Resolution strategy**: Instead of making Succ functional at the algebra level, make it functional by **fixing a particular FMCS construction** and then showing coherence. This is the SuccChainFMCS approach.

### Algebraic vs. Relational Trade-offs

| Approach | Advantages | Disadvantages |
|----------|------------|---------------|
| **Pure Algebraic** (tau on A) | Elegant, single structure | G non-invertible blocks this |
| **Pure Relational** (chains on Spec(A)) | Matches completeness proof | Choice-dependent, non-canonical |
| **Hybrid** (algebraic local, relational global) | Leverages STSA structure | More complex formalization |

**Recommendation**: The hybrid approach is already implicit in the codebase:
- STSA gives the local algebraic structure (G, H, box, sigma)
- ExistsTask/Succ gives the relational structure on Spec(A)
- FMCS construction picks a specific chain (relational)
- Truth lemma uses algebraic properties within each MCS

## Proposed Construction

Given the analysis, here is a viable tau construction for **discrete time** (D = Int):

### Definition

For an FMCS f : Int -> MCS, define:
```
tau_f : MCS -> MCS
tau_f(U) := f(t+1)   where f(t) = U
```

This is only defined for MCS that appear in the FMCS f. The shift is relative to a fixed history.

### Alternative: Canonical Successor

Define a canonical successor using the "least" extension:
```
canonical_succ(U) := Lindenbaum({φ | Gφ ∈ U} ∪ {ψ | Fψ ∈ U, ψ is "first" F-witness})
```

The "first" is ordered by formula complexity or some other well-order. This is somewhat arbitrary but deterministic.

### Connection to Existing Infrastructure

The codebase has:
1. `ExistsTask` (R_G relation) - CanonicalFrame.lean
2. `canonical_forward_F` (F-witness existence) - CanonicalFrame.lean
3. `CanonicalTask_forward` (n-step forward chains) - CanonicalTaskRelation.lean
4. `FMCS` (time-indexed MCS family) - FMCSDef.lean

A tau automorphism would need to:
- Be defined on all of Spec(A), not just one FMCS
- Commute with G/H in some sense
- Preserve the R_□ equivalence classes

**The key obstacle**: tau_f depends on the choice of f. Different FMCS give different tau. This is unavoidable because Spec(A) is much larger than a single time line.

## FMCS via tau

If tau exists and is well-defined:

### Forward Coherence
Want: F(φ) ∈ fam(t) implies φ ∈ fam(t+1)

If fam(t+1) = tau(fam(t)), this becomes:
F(φ) ∈ U implies φ ∈ tau(U)

This requires tau to satisfy: g_content(U) ⊆ tau(U) (i.e., ExistsTask U tau(U)).

### Backward Coherence
Want: P(φ) ∈ fam(t) implies φ ∈ fam(t-1)

If fam(t-1) = tau^(-1)(fam(t)), this becomes:
P(φ) ∈ U implies φ ∈ tau^(-1)(U)

Equivalently: h_content(U) ⊆ tau^(-1)(U), i.e., h_content(tau(U)) ⊆ U.

### Required tau Properties

For FMCS coherence, tau : MCS -> MCS must satisfy:
1. **G-forward**: g_content(U) ⊆ tau(U)
2. **H-backward**: h_content(tau(U)) ⊆ U
3. **Bijective**: tau is a bijection (for tau^(-1) to exist)
4. **R_□-preserving**: tau preserves modal equivalence classes

Properties 1 and 2 together give temporal coherence. Property 3 is the hard one - it requires tau to be injective and surjective, which is difficult when Spec(A) is infinite and uncountable.

## Mathematical Gaps or Risks

### Gap 1: Functional Successor Selection
No canonical way to select a single successor from multiple R_G-related MCS. Any selection requires Choice and is non-canonical.

### Gap 2: Global vs. Local
tau can be defined locally along a chain (FMCS), but not globally on all of Spec(A). The "shift" is really a shift along a fixed history, not an automorphism of the whole space.

### Gap 3: Algebraic Representation
The elegant "tau([φ]) = [G^(-1)(φ)]" formula is impossible because G^(-1) doesn't exist. The actual construction must be relational, not purely algebraic.

### Risk: Over-engineering
The current SuccChainFMCS approach might already be optimal. Trying to lift it to a global tau automorphism may add complexity without benefit.

## Confidence Level

**Medium**

Justification:
- High confidence that G^(-1) doesn't exist (proven by deflationarity analysis)
- High confidence that existing infrastructure (ExistsTask, FMCS, SuccChain) is the right approach
- Medium confidence in the proposed construction - it works for discrete time but requires careful handling of Choice
- Low confidence that a purely algebraic tau automorphism is achievable - the structure seems to resist this

The recommendation is to proceed with the existing relational approach (SuccChainFMCS) rather than trying to construct a global algebraic tau. The shift is inherently tied to a particular history, not the whole algebra.

## References

### Codebase Files Consulted

1. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` (lines 1-351)
   - STSA typeclass definition
   - LindenbaumAlg instance
   - MF, TF, TA, TL axiom equations

2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` (lines 1-441)
   - sigma_quot (temporal duality)
   - G_quot, H_quot operations
   - Provable equivalence relation

3. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` (lines 1-192)
   - G_monotone, H_monotone
   - box_interior instance
   - Note on strict semantics

4. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (lines 1-244)
   - ExistsTask relation definition
   - canonical_forward_F theorem
   - canonical_forward_G, canonical_backward_H

5. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (lines 1-130)
   - FMCS structure definition
   - forward_G, backward_H coherence conditions

6. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (lines 1-200)
   - iter_F definition
   - CanonicalTask_forward inductive

7. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean` (lines 1-419)
   - WorldHistory structure
   - time_shift construction
   - Convexity and respects_task constraints

8. `/home/benjamin/Projects/ProofChecker/specs/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md` (lines 1-539)
   - STSA mathematical structure
   - Representation theorem architecture
   - MF/TF as shift-closure axioms

### Mathlib Theorems Consulted

- `SuccOrder.mk` - Constructor for successor order structures
- `Order.succ_le_iff` - Characterization of successor in linear orders
- `ClosureOperator` - Dual of interior operators (for contrast)
- `Ultrafilter` - Mathlib ultrafilter definition
