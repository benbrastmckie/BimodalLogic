# Teammate A Research: G-Lift Mechanism Analysis

## Key Findings

### 1. The G-Lift Mechanism (Lines 1066-1082)

`G_lift_from_context` is the core mechanism enabling temporal consistency proofs. Its structure:

```lean
theorem G_lift_from_context (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ctx : List Formula) (phi : Formula)
    (h_deriv : DerivationTree ctx phi)
    (h_ctx_G : forall x in ctx, Formula.all_future x in M) :
    Formula.all_future phi in M
```

**Mechanism Details**:
- Base case (empty context): Use temporal necessitation rule - if `[] |- phi` then `G(phi)` is a theorem, hence in any MCS
- Inductive case:
  1. Apply deduction theorem to get `rest |- a -> phi`
  2. Recursively G-lift to get `G(a -> phi) in M`
  3. Use K-axiom: `G(A -> B) -> (G(A) -> G(B))`
  4. Apply modus ponens twice with `G(a) in M` (from `h_ctx_G`)

**Critical Requirement**: ALL elements of context must have their G in M. This is a **hard requirement** - there is no partial G-lift mechanism.

### 2. temporal_theory_witness_consistent (Lines 1110-1149)

This proof demonstrates the working base case for `{phi} ∪ temporal_box_seed M`:

**Structure**:
1. Assume L ⊆ {phi} ∪ temporal_box_seed M with L |- bot
2. Filter L into L_no_phi (elements != phi)
3. Key property: L_no_phi ⊆ temporal_box_seed M
4. By deduction theorem: L_no_phi |- neg(phi)
5. **G-lift applies** because all of L_no_phi has G in M
6. Result: G(neg phi) in M
7. Contradiction: F(phi) = neg(G(neg phi)) in M contradicts G(neg phi) in M

**Why It Works**: After extracting phi, the remaining context L_no_phi is entirely contained in temporal_box_seed M. By definition:
- G_theory M = {G(a) | G(a) in M} - these elements ARE G-formulas already in M
- box_theory M = {box(a) | box(a) in M} ∪ {neg(box(a)) | box(a) not in M}

For G_theory: G(G(a)) in M follows from 4-axiom (G(G(a)) -> G(a), so if G(a) in M then G(G(a)) in M by T-axiom direction)

For box_theory: G(box(a)) in M follows from G(box) axiom interaction

### 3. The F-Formula Barrier

**Why F-formulas Cannot Be G-Lifted**:

F(psi) = neg(G(neg psi))

For G-lifting to work, we need: `F(psi) in M -> G(F(psi)) in M`

But G(F(psi)) = G(neg(G(neg psi))) = neg(F(G(neg psi))) [using F = negGneg]

This is NOT guaranteed. In fact:
- F(psi) in M means "eventually psi"
- G(F(psi)) would mean "always eventually psi" (infinitely often)
- These are semantically distinct - eventual occurrence doesn't imply repeated occurrence

**The Core Problem**: When L contains F-formulas from F_unresolved_theory:
1. Extracting one F-formula F(psi) gives: L_no_F |- G(neg psi)
2. But L_no_F may still contain phi and OTHER F-formulas
3. These remaining F-formulas block G-lifting

### 4. Current Proof State Analysis

The proof at lines 1372-2102 has two `sorry` locations:

**Sorry 1 (line 2068)**: In the branch where:
- phi in L_no_F (extracted F(psi), phi remains)
- L_no_phi ⊆ temporal_box_seed M (after further extracting phi)
- neg(G(phi)) in M (the problematic case)

The proof successfully:
- G-lifts to get G(phi -> G(neg psi)) in M
- Shows this is in G_theory M ⊆ f_preserving_seed
- Constructs derivation [F(psi), phi, G(phi -> G(neg psi))] |- bot

But this doesn't help because we're trying to prove consistency, not find inconsistency.

**Sorry 2 (line 2073)**: In the branch where:
- L_no_phi has elements from F_unresolved_theory M
- Needs recursion/induction on F-formula count

### 5. Proposed Approaches

#### Approach A: Strong Induction on F-Formula Count
**Confidence: Medium-High (70%)**

Instead of case-based reasoning, use strong induction on |L ∩ F_unresolved_theory M|.

Base case: |L ∩ F_unresolved| = 0 means L ⊆ {phi} ∪ temporal_box_seed M, handled by existing temporal_theory_witness_consistent.

Inductive case: Extract one F-formula, use IH on the remaining context.

**Challenge**: The extracted formula gives L_no_F |- G(neg psi), but we need to connect this to the smaller F-count context.

#### Approach B: Semantic Model Argument
**Confidence: Low-Medium (40%)**

Instead of purely syntactic consistency, construct a model where f_preserving_seed is satisfiable:

1. Take M's canonical model state
2. Build successor state satisfying phi and preserving F-obligations
3. Use model-theoretic consistency

**Challenge**: We're in the algebraic completeness proof - need to stay syntactic.

#### Approach C: Careful Tracking of Formula Dependencies
**Confidence: Medium (55%)**

The key insight from sorry 1: we derived G(phi -> G(neg psi)) in M.

If G(phi) in M, we get G(neg psi) in M, contradicting F(psi) in M.
If G(phi) not in M, then F(neg phi) in M.

But F(phi) in M (hypothesis) and F(neg phi) in M are compatible.

**New Angle**: Perhaps the issue is that the proof strategy is fundamentally wrong for the neg(G(phi)) case. We may need to track whether phi itself is an F-formula or has special structure.

#### Approach D: Weaker Consistency Result
**Confidence: High (80%)**

Perhaps f_preserving_seed is NOT always consistent. Maybe the theorem needs additional hypotheses.

Looking at line 2024 comment: "So we have a problem: under the given hypotheses, f_preserving_seed is inconsistent."

This suggests the current f_preserving_seed definition may be too ambitious. Consider:
- Adding constraints on which F-formulas to include
- Requiring F-formulas to be "independent" in some sense
- Using a smaller seed that still achieves the goal

#### Approach E: Different Seed Definition
**Confidence: Medium-High (65%)**

Instead of including ALL of F_unresolved_theory M, include only F-formulas that are "compatible" with phi:

```
f_preserving_seed M phi = {phi} ∪ temporal_box_seed M ∪
  { F(psi) | F(psi) in M ∧ psi not in M ∧ consistent_with(F(psi), phi) }
```

Where consistent_with checks that we can't derive G(neg psi) from {phi} ∪ temporal_box_seed M.

### 6. Root Cause Analysis

The fundamental issue is a **structural mismatch**:

1. **G-lift requires homogeneous context**: All premises must be G-liftable
2. **f_preserving_seed is heterogeneous**: Contains G-liftable (temporal_box_seed) and non-G-liftable (F_unresolved_theory, phi) elements
3. **Extraction doesn't preserve homogeneity**: Extracting one F-formula still leaves potentially non-G-liftable context

The temporal_theory_witness_consistent proof works because extracting phi leaves a HOMOGENEOUS G-liftable context. With F_unresolved_theory added, this property breaks.

## Code References

| Line | Content |
|------|---------|
| 1052-1058 | G_of_temporal_box_seed - why temporal_box_seed elements are G-liftable |
| 1066-1082 | G_lift_from_context - the core G-lift mechanism |
| 1110-1149 | temporal_theory_witness_consistent - working base case |
| 1275-1276 | f_preserving_seed definition |
| 2068 | Sorry 1 - neg(G(phi)) case |
| 2073 | Sorry 2 - F-formulas in L_no_phi |
| 2024-2027 | Key comment admitting the problem |

## Recommendations

1. **Investigate whether theorem is provable as stated**: The comment at line 2024 suggests it may not be.

2. **Try Approach A (induction)**: Most likely to succeed if theorem is provable.

3. **Consider Approach E (weaker seed)**: If current definition is too strong.

4. **Examine existing completeness proofs**: How do Blackburn/de Rijke/Venema or similar texts handle F-preservation in temporal logic completeness?
