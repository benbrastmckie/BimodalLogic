# Teammate B Research Findings: Refactoring Strategy and Implementation Path

**Task**: 23 - F/P temporal witness chain construction
**Session ID**: sess_1774126357_b611bb
**Run**: 05
**Date**: 2026-03-21

## Executive Summary

The analysis reveals a fundamental architectural gap between the sorry-free CanonicalMCS construction and the TaskFrame-based algebraic completeness pipeline. CanonicalMCS lacks the algebraic structure (AddCommGroup) required by TaskFrame, making direct integration impossible. The recommended approach is to use FMCSTransfer infrastructure to bridge these domains, though this requires resolving cardinality and surjectivity constraints.

---

## Type-Level Analysis

### CanonicalMCS Structure

From `CanonicalFMCS.lean`, CanonicalMCS has:

```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

noncomputable instance : Preorder CanonicalMCS where
  le a b := a = b ∨ CanonicalR a.world b.world
```

**Key observations**:
- CanonicalMCS has `Preorder` only (reflexive closure of CanonicalR)
- The Preorder is NOT total (multiple incomparable MCSes exist)
- No algebraic structure: no `Zero`, no `Add`, no `Neg`
- Uncountable (continuum-many MCSes exist)

### TaskFrame Requirements

From `TaskFrame.lean`:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

**Required type-class instances**:
1. `AddCommGroup D` - zero, addition, negation, associativity, commutativity
2. `LinearOrder D` - total order
3. `IsOrderedAddMonoid D` - order compatible with addition

### The Type Gap

| Property | CanonicalMCS | TaskFrame D |
|----------|--------------|-------------|
| Order | Preorder (partial) | LinearOrder (total) |
| Zero | None | Required |
| Addition | None | Required |
| Negation | None | Required |
| Cardinality | Uncountable | Typically countable (Int, Rat) |

**Verdict**: CanonicalMCS CANNOT satisfy TaskFrame requirements. These are fundamentally different types.

---

## Architecture Options

### Option A: Replace IntBFMCS Entirely with CanonicalFMCS

**Approach**: Use CanonicalMCS as the domain D everywhere.

**Pros**:
- Sorry-free forward_F and backward_P
- No dovetailing complexity
- Simple direct construction

**Cons**:
- **BLOCKED**: CanonicalMCS lacks AddCommGroup structure
- Cannot be used as D parameter in TaskFrame
- Violates the semantic model architecture (TaskFrame requires algebraic time)
- No way to define duration arithmetic (t + d, t - s)

**Verdict**: NOT VIABLE - Type mismatch is fundamental.

### Option B: Keep IntBFMCS but Delegate F/P to CanonicalFMCS

**Approach**: Use FMCSTransfer to embed IntBFMCS chain into CanonicalMCS, prove F/P there, transfer back.

**Implementation via FMCSTransfer (from `FMCSTransfer.lean`)**:

```lean
structure FMCSTransfer (D : Type*) [Preorder D] where
  embed : CanonicalMCS →o D
  retract : D → CanonicalMCS
  retract_left_inverse : ∀ w : CanonicalMCS, retract (embed w) = w
  embed_retract_eq : ∀ d : D, embed (retract d) = d  -- surjectivity
  retract_lt : ∀ d₁ d₂ : D, d₁ < d₂ → retract d₁ < retract d₂
  embed_lt : ∀ w₁ w₂ : CanonicalMCS, w₁ < w₂ → embed w₁ < embed w₂
```

**Pros**:
- Leverages sorry-free CanonicalMCS proofs
- Existing infrastructure in FMCSTransfer.lean
- Maintains separation between proof-theoretic and semantic domains

**Cons**:
- **Surjectivity blocker**: `embed_retract_eq` requires every `d : Int` to equal `embed(retract d)`
- For Int chain: only countably many MCSes are in the chain
- CanonicalMCS is uncountable, so `embed` cannot be surjective
- The chain construction picks specific MCSes via Lindenbaum - not all MCSes

**Current Status**: FMCSTransfer exists but `embed_retract_eq` cannot be satisfied for linear chains.

### Option C: Create a New Hybrid Construction

**Approach**: Build a new domain that combines CanonicalMCS structure with algebraic properties.

**Sub-option C1: Quotient Construction**

Take the Int chain and quotient by "same MCS at time t":
- Define `D := Int` (keep algebraic structure)
- For F/P witnesses, embed into CanonicalMCS, find witness, then map back

**Problem**: The witness MCS from `canonical_forward_F` may not be in the Int chain.

**Sub-option C2: Expanded Chain with Forced Witnesses**

Build chain that immediately processes F/P obligations:
- When F(phi) appears at position t, immediately extend chain to include witness
- "Omega-squared" construction: for each position, process all outstanding obligations

**Problem**: This is exactly what the dovetailing was supposed to do, but fails because:
1. Lindenbaum extensions can kill F(phi) = ~G(~phi) by adding G(~phi)
2. The witness may be needed at position t+k for k very large (dovetailing delay)
3. By the time we process the obligation, F(phi) may have been killed

**Sub-option C3: Direct Multi-Family Approach (Task 22)**

From `DirectMultiFamilyBFMCS.lean`:
- Index families by `discreteClosedMCS M0` (modally closed MCSes)
- Each family is an Int chain rooted at one closed MCS
- At t=0, families cover all closed MCSes by construction

**Status**: This addresses modal coherence but NOT temporal F/P witnesses.
The Int chains within each family still have the Lindenbaum/dovetailing blocker.

---

## Recommended Approach

### Two-Layer Architecture

**Layer 1: Proof-Theoretic (CanonicalMCS domain)**
- Use `FMCS CanonicalMCS` with sorry-free forward_F/backward_P
- This is a valid FMCS but cannot be a TaskFrame parameter

**Layer 2: Semantic (TaskFrame with D = Int or Rat)**
- Use `ParametricCanonicalTaskFrame D` for semantic evaluation
- Duration arithmetic uses D's AddCommGroup structure

**Bridge**: The TruthLemma connects Layer 1 MCS membership to Layer 2 semantic truth.

### Current State in Codebase

From `Completeness.lean`:

```lean
theorem dense_completeness_components_proven :
    (Nonempty (TimelineQuot root_mcs root_mcs_proof ≃o Rat)) ∧
    (∀ Gamma : List Formula, ContextConsistent Gamma →
      ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS), ...)
```

**The gap**: "The gap is connecting CanonicalMCS (used in BFMCS/TruthLemma) to TimelineQuot (used in TaskFrame)."

### Concrete Resolution Path

1. **Accept the domain separation**: CanonicalMCS for proof, D for semantics
2. **Prove completeness via contrapositive**:
   - If not provable, neg(phi) consistent
   - Extend to MCS M via Lindenbaum
   - CanonicalMCS FMCS contains M with sorry-free F/P
   - Truth lemma: neg(phi) true at M
   - This contradicts validity
3. **The key insight**: For completeness, we only need to exhibit ONE model falsifying phi. The CanonicalMCS-based model suffices even without algebraic structure on the domain.

---

## Implementation Roadmap

### Phase 1: Verify Current Pipeline (Low Effort)

Files to verify are already sorry-free:
- `CanonicalFMCS.lean` - `temporal_coherent_family_exists_CanonicalMCS`
- `TruthLemma.lean` - `bmcs_truth_lemma`

**Status**: Already done according to `Completeness.lean` comments.

### Phase 2: Domain Separation Theorem (Medium Effort)

Create a theorem that explicitly states the domain separation is acceptable:

```lean
-- Sketch
theorem completeness_via_canonical_mcs :
    ∀ phi, (∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
            valid_over_D D phi) →
           Nonempty (DerivationTree [] phi)
```

The proof would construct a CanonicalMCS-based countermodel showing non-validity implies non-provability.

### Phase 3: Address Int-Specific Needs (Optional)

If Int-indexed BFMCS is specifically needed:

**Option 3A**: Accept sorries as fundamental limitation
- Document the Lindenbaum blocker thoroughly
- Mark IntBFMCS F/P as "axioms" that reflect semantic completeness

**Option 3B**: Immediate witness construction
- Modify chain construction to process F(phi) obligations immediately
- Build position t+1 specifically to witness F(phi) at t
- This requires abandoning the generic Lindenbaum extension

**Files to modify for Option 3B**:
- `IntBFMCS.lean`: Replace `successorMCS` with F-witness-aware construction
- New file: `FWitnessExtension.lean` for immediate witness construction
- Modify dovetailing to track and clear obligations

### Phase 4: Transfer Theorem Approach (High Effort)

If bijection-free transfer is possible:

```lean
-- Instead of requiring embed_retract_eq, use weaker condition
structure WeakFMCSTransfer (D : Type*) [Preorder D] where
  mcs : D → Set Formula  -- direct MCS assignment
  mcs_is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  -- F/P witnesses exist in CanonicalMCS space and can be "approximated" in D
  forward_F_exists : ∀ t phi, F phi ∈ mcs t → ∃ s > t, phi ∈ mcs s
```

**Challenge**: How to guarantee the CanonicalMCS witness can be represented in the D chain.

---

## Risks & Mitigations

### Risk 1: Completeness Statement Mismatch

**Risk**: The completeness theorem statement requires D-parametric validity, but our proof uses CanonicalMCS.

**Mitigation**: The contrapositive approach works: if provable, then valid (soundness). If not provable, find countermodel (which CanonicalMCS provides). The countermodel doesn't need algebraic structure.

### Risk 2: IntBFMCS Remains Sorry-Backed

**Risk**: Some downstream constructions require specifically `BFMCS Int`.

**Mitigation**:
1. Audit all `BFMCS Int` usages - may be replaceable with generic D
2. Accept Int sorries as fundamental and document
3. The main completeness theorem should not depend on IntBFMCS

### Risk 3: Lindenbaum Blocker is Fundamental

**Risk**: No linear chain construction can have sorry-free F/P.

**Mitigation**: This is confirmed by Task 1004 research. Use CanonicalMCS (all-MCS) approach instead of linear chains.

---

## Confidence Level

**High Confidence**:
- CanonicalMCS cannot satisfy AddCommGroup (type-level fact)
- Linear chains fundamentally cannot preserve F-formulas through Lindenbaum
- FMCSTransfer cannot achieve surjectivity for countable chains

**Medium Confidence**:
- Domain separation approach is mathematically sound
- Completeness can be proven without Int-specific BFMCS

**Low Confidence**:
- Specific implementation details for "immediate witness" construction
- Whether Option 3B is actually achievable without introducing new blockers

---

## Summary

The F/P temporal witness problem in IntBFMCS is a **fundamental limitation** of linear chain constructions, not a bug to be fixed. The recommended path forward is:

1. **Accept domain separation**: Use CanonicalMCS (Preorder) for proof-theoretic F/P witnesses, TaskFrame D (AddCommGroup) for semantic duration arithmetic

2. **Verify completeness pipeline**: The existing `dense_completeness_components_proven` shows all components are sorry-free; the gap is wiring them together

3. **Document IntBFMCS limitations**: The sorries in `intFMCS_forward_F` and `intFMCS_backward_P` reflect a fundamental impossibility, not missing proofs

4. **Consider "immediate witness" extension**: If Int-indexed F/P is truly required, a non-Lindenbaum witness construction may be possible but requires careful design

The codebase is closer to complete than it appears - the CanonicalMCS infrastructure already provides sorry-free F/P witnesses. The remaining work is architectural (connecting domains) rather than mathematical (proving new theorems).
