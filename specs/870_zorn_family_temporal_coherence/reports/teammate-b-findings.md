# Teammate B: Multi-Witness Patterns Research

**Task**: 870 - Zorn-based family selection for temporal coherence
**Focus**: Mathlib patterns for multi-witness seed consistency
**Date**: 2026-02-11

## Summary

Researched Mathlib and local codebase patterns for proving `multi_witness_seed_consistent_future/past`. The key challenge is handling multiple F-obligations (psi_1, ..., psi_n where F psi_i is in mcs(s_i) for various s_i < t) and proving their union with GContent is consistent.

## Mathlib Patterns Found

### 1. MCS Disjunction Property (Local - Completeness.lean)

```lean
theorem set_mcs_disjunction_iff {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    (φ.or ψ) ∈ S ↔ (φ ∈ S ∨ ψ ∈ S)
```

**Critical for multi-witness**: In MCS, a disjunction holds iff some disjunct holds. This is needed in the proof sketch where G(neg psi_1 | ... | neg psi_k) in M implies some G(neg psi_j) in M.

### 2. Generalized K Rules (Local - GeneralizedNecessitation.lean)

```lean
noncomputable def generalized_temporal_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.all_future Γ) ⊢ Formula.all_future φ)

noncomputable def generalized_past_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.all_past Γ) ⊢ Formula.all_past φ)
```

**Already available**: These lift derivations under G/H. Key for: L_G |--> G(neg_disjunction) when L_G |- neg_disjunction.

### 3. Single-Witness Seed Consistency (Local - TemporalCoherentConstruction.lean)

```lean
theorem temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent ({psi} ∪ GContent M)
```

**Proof technique**: Deduction theorem on filtered list, then generalized_temporal_k, then contradict F psi = neg(G(neg psi)) with G(neg psi) in M.

### 4. De Morgan Laws (Mathlib - Logic.Basic)

```lean
theorem and_iff_not_or_not : a ∧ b ↔ ¬(¬a ∨ ¬b)
theorem or_iff_not_and_not : a ∨ b ↔ ¬(¬a ∧ ¬b)
```

**Useful for**: Converting between conjunctions and disjunctions of negations.

## Applicable Techniques

### Approach 1: Iterated Deduction Theorem

The proof sketch in ZornFamily.lean line 591-607 outlines this approach:

1. Given L ⊆ {psi_1, ..., psi_n} ∪ GContent(M) with L |- bot
2. Let L_psi = psis in L, L_G = GContent elements
3. By iterated deduction theorem: L_G |- neg(psi_1 & ... & psi_k)
4. By De Morgan: L_G |- neg(psi_1) | ... | neg(psi_k)
5. By generalized_temporal_k: G(L_G) |- G(neg(psi_1) | ... | neg(psi_k))
6. **Gap**: Need G(A | B) implies G(A) | G(B) (FALSE in general!)

**Issue**: G does NOT distribute over disjunction in normal modal logic. G(A | B) is WEAKER than G(A) | G(B). This approach requires a different technique.

### Approach 2: Finite Conjunction Reduction (Recommended)

Instead of distributing G over disjunction, reduce to single-witness case:

1. Given L ⊆ {psi_1, ..., psi_n} ∪ GContent(M) with L |- bot
2. Let L_psi = [psi_{i_1}, ..., psi_{i_k}] (the psis in L)
3. L = L_psi ++ L_G where L_G ⊆ GContent(M)
4. From L |- bot, derive: L_G |- neg(psi_{i_1}) | neg(psi_{i_2}) | ... | neg(psi_{i_k})
5. Apply generalized_temporal_k: G(L_G) |- G(neg(psi_{i_1}) | ... | neg(psi_{i_k}))
6. Since all G chi in G(L_G) are in M, we have G(neg_disjunction) in M
7. **Key insight**: Use De Morgan at MCS level:
   - G(neg A | neg B) = G(neg(A & B)) (propositional)
   - If G(neg(A & B)) in M, then neg(F(A & B)) in M
   - Need: F(A) in M and F(B) in M implies F(A & B) in M? NO, this fails.

**Issue**: This approach also fails because F doesn't distribute over conjunction.

### Approach 3: Induction on L_psis Length (Most Promising)

Prove by induction on the number of psis in L:

**Base case (k=0)**: L ⊆ GContent(M) is consistent (proven as GContent_consistent)

**Base case (k=1)**: Single psi in L. This IS the single-witness case already proven.

**Inductive case (k -> k+1)**:
- Assume consistency for any list with k psis from same MCS M
- Given L with k+1 psis: [psi_0, psi_1, ..., psi_k]
- Key: All F(psi_i) are in the SAME MCS M

The inductive step requires showing: if {psi_0, ..., psi_{k-1}} ∪ GContent(M) is consistent and F(psi_k) in M, then {psi_0, ..., psi_k} ∪ GContent(M) is consistent.

**Critical lemma needed**:
```lean
lemma extend_multi_witness_consistency (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (Psis : List Formula) (psi_new : Formula)
    (h_F_old : ∀ psi ∈ Psis, Formula.some_future psi ∈ M)
    (h_F_new : Formula.some_future psi_new ∈ M)
    (h_cons : SetConsistent ({phi | phi ∈ Psis} ∪ GContent M)) :
    SetConsistent ({phi | phi ∈ (psi_new :: Psis)} ∪ GContent M)
```

This requires showing that adding one more psi to a consistent multi-witness seed preserves consistency.

### Approach 4: Direct Contradiction with Finitary Witness Selection

Alternative approach using the finiteness of L directly:

1. Given L ⊆ {psi_1, ..., psi_n} ∪ GContent(M) with L |- bot
2. L is finite, so L_psi = {psi_i : psi_i in L} is finite
3. For each psi_i in L_psi: F(psi_i) in M, so by MCS: neg(G(neg(psi_i))) in M
4. Therefore G(neg(psi_i)) NOT in M for all psi_i in L_psi
5. Build contradiction: Need to show that L |- bot implies some G(neg(psi_j)) in M

**Key derivation**: From L_psi ++ L_G |- bot:
- Apply deduction once to get L_G ++ [psi_1, ..., psi_{k-1}] |- psi_k -> bot = neg(psi_k)
- Apply generalized_temporal_k: G(L_G ++ [psi_1, ..., psi_{k-1}]) |- G(neg(psi_k))
- But G([psi_1, ..., psi_{k-1}]) is NOT in M (psi_i are witnesses, not necessarily have G(psi_i) in M)

**This doesn't work directly** because psi_i are not in GContent(M).

## Gaps in Mathlib/Local Codebase

### Gap 1: Multi-Formula Deduction Infrastructure

Missing: A systematic way to apply deduction theorem to extract a disjunction of negations from a conjunction of hypotheses.

**Needed lemma**:
```lean
lemma multi_deduction_to_disjunction (L_psis : List Formula) (L_G : List Formula)
    (h : (L_psis ++ L_G) ⊢ Formula.bot) :
    L_G ⊢ list_disjunction (L_psis.map Formula.neg)
```

This exists implicitly via iterated deduction theorem but needs explicit construction.

### Gap 2: G Does NOT Distribute Over Disjunction

In normal modal logic: G(A | B) does NOT imply G(A) | G(B).

**Counter-example**: G(A | B) says "at all future times, A or B holds" - different times could use different disjuncts.

This is a fundamental limitation, not fixable.

### Gap 3: List-Based Disjunction/Conjunction Operations

Missing: Recursive definitions and lemmas for:
```lean
def list_disjunction : List Formula -> Formula
def list_conjunction : List Formula -> Formula

lemma list_disjunction_in_mcs_iff : list_disjunction L ∈ M ↔ ∃ phi ∈ L, phi ∈ M
lemma list_conjunction_in_mcs_iff : list_conjunction L ∈ M ↔ ∀ phi ∈ L, phi ∈ M
```

## Proposed Solution

### Solution: Reduce to Single-Witness via Different Reference Point

**Key insight**: The problem arises because F-obligations come from DIFFERENT times s_i. But when extending to time t, we need consistency with GContent from a SINGLE reference MCS.

**Strategy for `multi_witness_seed_consistent_future`**:

When all F(psi_i) are in the SAME MCS M:
1. {psi_1} ∪ GContent(M) is consistent (single-witness, proven)
2. {psi_2} ∪ GContent(M) is consistent (single-witness)
3. Need: {psi_1, psi_2} ∪ GContent(M) is consistent

**New observation**: Since F(psi_1), F(psi_2) are BOTH in M:
- {psi_1} ∪ GContent(M) ∪ {psi_2} = {psi_1, psi_2} ∪ GContent(M)
- By single-witness: {psi_1} ∪ GContent(M) is consistent
- We need: adding psi_2 preserves consistency

**Lemma needed**: If F(psi) in M and S is consistent with GContent(M) ⊆ S, then S ∪ {psi} is consistent.

**Proof sketch**:
- Suppose S ∪ {psi} is inconsistent
- Then some L ⊆ S ∪ {psi} derives bot
- If psi not in L, then L ⊆ S contradicts S consistent
- If psi in L, by deduction: L\{psi} |- neg(psi)
- L\{psi} ⊆ S, so L\{psi} ⊆ "some consistent set extending GContent(M)"
- Apply generalized_temporal_k to parts that map under G
- **Issue**: L\{psi} may contain psi_1 from earlier iteration, which doesn't map under G

### Alternative: Co-Lindenbaum Approach

Instead of proving multi-witness consistency directly, use Lindenbaum lemma iteratively:

1. Start with GContent(M) (consistent by GContent_consistent)
2. For each F(psi_i) in M: Apply Lindenbaum to extend to MCS containing psi_i
3. Take intersection/union carefully

This is essentially what TemporalLindenbaum.lean does with the Henkin construction.

## Implementation Recommendation

### Short Term: Accept Sorry with Documentation

The `multi_witness_seed_consistent_future` and `multi_witness_seed_consistent_past` theorems at lines 650 and 680 represent genuine technical challenges. The proof sketch in comments is incomplete because G doesn't distribute over disjunction.

**Recommendation**: Document as technical debt with the understanding that:
1. The single-witness case is fully proven
2. The multi-witness case occurs in extensionSeed_consistent
3. A full proof requires either new infrastructure or a different proof strategy

### Medium Term: Build List-Based Derivation Infrastructure

Create helper functions:
```lean
def list_disjunction_neg (L : List Formula) : Formula :=
  L.foldr (fun phi acc => (Formula.neg phi).or acc) Formula.bot

lemma derives_list_disjunction_neg (L_psis L_G : List Formula)
    (h : (L_psis ++ L_G) ⊢ Formula.bot) :
    L_G ⊢ list_disjunction_neg L_psis
```

Then prove the multi-witness lemma by showing the G-lifted disjunction leads to contradiction via MCS disjunction property.

### Long Term: Temporal Saturation Approach

The cleanest solution may be to require the reference MCS M to already be temporally saturated. Then:
- F(psi) in M implies psi in M (by temporal saturation)
- GContent(M) ⊆ M
- So {psi_1, ..., psi_n} ∪ GContent(M) ⊆ M, which is consistent

This aligns with the TemporalLindenbaum.lean approach where MCS are built to be temporally saturated from the start.

## References

### Local Files
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - Main file with sorries
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Single-witness proof
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Past-witness proof
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - K-rule theorems
- `Theories/Bimodal/Metalogic/Completeness.lean` - MCS disjunction property
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS helper lemmas

### Mathlib
- `Mathlib.Logic.Basic` - De Morgan laws
- `Mathlib.Order.Zorn` - Zorn's lemma infrastructure

## Appendix: Why G Doesn't Distribute Over Disjunction

Consider a bi-infinite timeline with worlds w_t for t in Z.
- Let A = "it rains" and B = "it snows"
- Suppose at each time, either it rains or snows (but not predictably which)
- Then G(A | B) is true at t=0: at all future times, rain or snow
- But G(A) is false (some future time has no rain) and G(B) is false
- So G(A | B) does not imply G(A) | G(B)

This is a fundamental feature of temporal logic, not a bug. The proof must work around this.
