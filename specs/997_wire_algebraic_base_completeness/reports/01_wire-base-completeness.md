# Research Report: Task #997

**Task**: Wire the Algebraic Base Completeness Theorem
**Date**: 2026-03-19
**Focus**: Using FMCSTransfer (task 995) to fill sorries in AlgebraicBaseCompleteness.lean

## Summary

Task 995 created the FMCS domain transfer infrastructure (`FMCSTransfer.lean`) that provides sorry-free `forward_F` and `backward_P` proofs for any domain D when given an embedding/retraction pair from `CanonicalMCS`. However, the two sorries in `AlgebraicBaseCompleteness.lean` (lines 104 and 155) **cannot be directly filled using FMCSTransfer** without first constructing the `FMCSTransfer Int` instance, which requires an Int-indexed dovetailing chain construction. This task requires either (A) implementing the Int chain construction, or (B) restructuring the completeness proof to use `CanonicalMCS` directly as the domain.

## Findings

### Current State of AlgebraicBaseCompleteness.lean

**Two Sorries at Lines 104 and 155:**

1. **Line 104** (`singleFamilyBFMCS`): Constructs a single-family BFMCS from an FMCS. This sorry is explicitly marked as "BLOCKED" because modal backward requires `phi -> Box phi`, which is not a theorem of TM. The code comment recommends using modal saturation instead.

2. **Line 155** (`construct_bfmcs_from_mcs`): Constructs a temporally coherent BFMCS containing a given MCS M at time 0 (where D = Int). The sorry blocks the main completeness theorem at line 247.

**Main Completeness Theorem** (line 247): `algebraic_base_completeness` uses `construct_bfmcs_from_mcs` to get a BFMCS Int containing the MCS that extends `{neg(phi)}`.

### Task 995 FMCSTransfer Infrastructure

**Location**: `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

The `FMCSTransfer D` structure requires:
- `embed : CanonicalMCS ->o D` (monotone embedding)
- `retract : D -> CanonicalMCS` (retraction function)
- `retract_left_inverse : forall w, retract (embed w) = w`
- `embed_retract_eq : forall d, embed (retract d) = d` (surjectivity)
- `retract_lt` and `embed_lt` (strict monotonicity)

The key theorem `fmcs_domain_transfer` provides:
- A transferred FMCS on D
- Sorry-free `transfer_forward_F` and `transfer_backward_P`

**Critical Gap**: Task 995 provides the **transfer mechanism** but NOT the `FMCSTransfer Int` instance. The summary explicitly notes:
> "Int: Requires dovetailing chain construction (separate task)"

### The Dovetailing Chain Problem

**IntBFMCS.lean** (lines 556-574) shows why `intFMCS_forward_F` and `intFMCS_backward_P` have sorries:

The basic Int chain construction (`intChainMCS`) uses simple successor/predecessor MCS iteration:
- `posChain n+1 = successorMCS(posChain n)` - extends g_content
- `negChain n+1 = predecessorMCS(negChain n)` - extends h_content

**Problem**: When `F(phi) in mcs(t)`, `canonical_forward_F` gives a witness MCS W, but W may NOT be in the basic chain. The chain at position `t+1` is a different MCS (the generic Lindenbaum extension of g_content).

**Solution Needed**: A dovetailing/enriched chain construction that:
1. Enumerates all (t, phi) pairs with F/P obligations
2. At each step, chooses the witness MCS from `canonical_forward_F`/`canonical_backward_P`
3. Ensures all obligations are eventually witnessed in the Int-indexed chain

### Alternative Approach: Direct CanonicalMCS Construction

**Key Insight from CanonicalFMCS.lean (lines 207-312)**:

The `CanonicalMCS` domain (ALL maximal consistent sets) has **sorry-free** forward_F and backward_P:
- `canonicalMCS_forward_F`: Witness from `canonical_forward_F` IS a CanonicalMCS element
- `canonicalMCS_backward_P`: Witness from `canonical_backward_P` IS a CanonicalMCS element

**Problem**: Validity is quantified over ALL `D` with `AddCommGroup + LinearOrder + IsOrderedAddMonoid`. `CanonicalMCS` does NOT have `AddCommGroup`, so it cannot directly instantiate `valid phi`.

**However**, the completeness proof structure in `algebraic_base_completeness` (line 247) DOES use `D := Int` explicitly:
```lean
obtain ⟨B, h_tc, fam, hfam, t, h_M_eq⟩ :=
  construct_bfmcs_from_mcs (D := Int) M h_mcs
```

### Two Implementation Paths

**Path A: Implement FMCSTransfer Int (Recommended)**

1. Define the embedding/retraction pair between CanonicalMCS and Int:
   - `embed : CanonicalMCS ->o Int` via dovetailing enumeration
   - `retract : Int -> CanonicalMCS` selects the MCS at that position

2. Prove the six FMCSTransfer conditions:
   - `retract_left_inverse`: retract (embed w) = w
   - `embed_retract_eq`: embed (retract d) = d (surjectivity - every Int has an MCS)
   - `retract_lt` and `embed_lt` (strict monotonicity)

3. Apply `transferredTemporalCoherentFamily` to get sorry-free BFMCS Int

**Estimated Effort**: Medium-high (requires dovetailing chain design)

**Path B: Restructure Proof (Simpler but Limited)**

The completeness proof only needs ONE countermodel. Instead of using `BFMCS Int`:

1. Construct the countermodel using `CanonicalMCS` as the domain
2. Show validity fails by exhibiting a `TaskModel` over `CanonicalMCS`
3. Problem: `CanonicalMCS` lacks `AddCommGroup`, violating `valid` quantification

**Workaround**: Define a weaker validity predicate `valid_preorder` that only requires `Preorder D`, prove completeness for that, then show `valid phi -> valid_preorder phi`.

**Estimated Effort**: Medium (requires new validity definition and additional lemmas)

### Recommended Approach: FMCSTransfer with Dovetailing

The cleanest path is Path A:

1. **Create dovetailing enumeration** in a new file `IntDovetailingChain.lean`:
   - Define `enum : Nat -> CanonicalMCS` that enumerates all MCSes
   - Ensure the enumeration satisfies F/P witness requirements
   - Define `embed` and `retract` from the enumeration

2. **Prove FMCSTransfer Int instance**:
   - Use the dovetailing chain properties

3. **Fill sorries in AlgebraicBaseCompleteness.lean**:
   - Line 104: Either mark as deprecated (not needed) or implement using modal saturation
   - Line 155: Use `transferredTemporalCoherentFamily` from FMCSTransfer

### Type Signature for construct_bfmcs_from_mcs

The sorry at line 155 has signature:
```lean
noncomputable def construct_bfmcs_from_mcs
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
       (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
       M = fam.mcs t
```

For `D = Int`, the implementation would:
1. Build the dovetailing Int chain containing M at position 0
2. Create a single-family BFMCS (modal coherence is trivial for single family)
3. Return the BFMCS with the temporal coherence proof from FMCSTransfer

## Dependencies and Available Infrastructure

### Available (Sorry-Free):
- `FMCSTransfer` structure and transfer theorems (FMCSTransfer.lean)
- `canonical_forward_F`, `canonical_backward_P` (CanonicalFrame.lean)
- `canonicalMCSBFMCS` with sorry-free F/P (CanonicalFMCS.lean)
- `parametric_algebraic_representation_conditional` (ParametricRepresentation.lean)

### Missing (Needs Implementation):
- `FMCSTransfer Int` instance
- Dovetailing chain construction for Int
- The `embed : CanonicalMCS ->o Int` and `retract : Int -> CanonicalMCS` functions

## Recommendations

1. **Create new file** `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean`:
   - Define the dovetailing chain enumeration
   - Construct `FMCSTransfer Int` instance
   - Prove all six conditions

2. **Update AlgebraicBaseCompleteness.lean**:
   - Import `IntFMCSTransfer`
   - Replace `singleFamilyBFMCS` sorry (line 104) with a comment marking it as deprecated
   - Implement `construct_bfmcs_from_mcs` (line 155) using `transferredTemporalCoherentFamily`

3. **Alternative minimal fix**: If dovetailing is too complex, consider adding an explicit sorry for the Int chain embedding and documenting it as a known gap. This would reduce the algebraic base completeness to one well-characterized sorry.

## Risk Analysis

| Risk | Impact | Mitigation |
|------|--------|------------|
| Dovetailing complexity | High | Start with simpler bijective enumeration, add F/P witness prioritization |
| Type class constraints | Medium | Carefully check CanonicalMCS vs Int instances |
| Modal saturation needed | Low | Single-family BFMCS has trivial modal coherence |

## Success Criteria

- [ ] `construct_bfmcs_from_mcs` implemented without sorry
- [ ] `algebraic_base_completeness` compiles without sorry
- [ ] `lake build` succeeds with no new sorries
- [ ] No new axioms introduced

## References

- Task 995: FMCS domain transfer lemma (completed)
- Task 986: IntBFMCS construction (blocked by dovetailing)
- Task 987: Algebraic base completeness (abandoned, superseded by 997)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

## Context Extension Recommendations

None identified.

## Next Steps

1. Design the dovetailing enumeration for `CanonicalMCS -> Int`
2. Implement `IntFMCSTransfer.lean` with the embedding/retraction pair
3. Wire `construct_bfmcs_from_mcs` using the transfer infrastructure
4. Verify `algebraic_base_completeness` compiles without sorry
