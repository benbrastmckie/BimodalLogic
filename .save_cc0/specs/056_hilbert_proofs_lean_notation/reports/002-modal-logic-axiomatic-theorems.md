# Research Report: Modal Logic Axiomatic Theorems

**Topic**: Modal Logic Axiomatic Theorems from Modal Axiomatic Systems section
**Date**: 2025-12-09
**Researcher**: Claude (research-specialist)

## Executive Summary

This report documents modal logic theorems from the "Propositional Modal Logic: Axiomatic Systems" section and "Problem Set: Axiomatic Proofs" in LogicNotes.tex (lines 471-553), converts each to Lean 4 notation compatible with Logos TM logic, and identifies which are already proven.

## Modal Axiom Schemata (K, D, T, B, 4, 5)

From lines 477-483:

1. **K** (Distribution): `□(A → B) → (□A → □B)`
2. **D** (Seriality): `□A → ◇A`
3. **T** (Reflexivity): `□A → A`
4. **B** (Symmetry): `A → □◇A`
5. **4** (Transitivity): `□A → □□A`
6. **5** (Euclidean): `◇A → □◇A`

## Modal Systems Definitions (lines 499-504)

- **K System**: All K axioms + necessitation rule
- **T System**: All K and T axioms
- **D System**: All K and D axioms
- **B System**: All K, B, and T axioms
- **S4 System**: All K, T, and 4 axioms
- **S5 System**: All K, T, and 5 axioms

## Problem Set Theorems (lines 527-552)

### K System Theorems

1. If `K ⊢ A → B`, then `K ⊢ □A → □B`
2. If `A K ⊢ B`, then `□A K ⊢ □B`
3. `K ⊢ □(A ∧ B) ↔ (□A ∧ □B)`
4. `K ⊢ (□A ∨ □B) → □(A ∨ B)`
5. `K ⊢ □(A → B) → □(¬B → ¬A)`
6. If `K ⊢ A → B`, then `K ⊢ ◇A → ◇B`
7. `K ⊢ ◇(A ∨ B) ↔ (◇A ∨ ◇B)`

### T System Theorems

8. `T ⊢ □A → ◇A`
9. `T ⊢ ¬□(A ∧ ¬A)`

### D System Theorems

10. `D ⊢ ◇(A → A)`

### B System Theorems

11. `B ⊢ □A → ◇A`

### S4 System Theorems

12. `S4 ⊢ (◇A ∧ □B) → ◇(A ∧ □B)`
13. `S4 ⊢ □A → □◇□A`
14. `S4 ⊢ ◇◇A ↔ ◇A`
15. `S4 ⊢ ◇□◇A ↔ ◇A`

### S5 System Theorems

16. `S5 ⊢ ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)`
17. `S5 ⊢ ◇□A ↔ □A`
18. `S5 ⊢ □A → □□A`
19. `S5 ⊢ A → □◇A`
20. `S5 ⊢ ◇□A → A`

## Lean 4 Notation Conversion

Using Logos Formula syntax:
- Box (necessity): `φ.box` or `□φ`
- Diamond (possibility): `φ.diamond` or `◇φ`
- Implication: `φ.imp ψ` or `φ → ψ`
- Negation: `φ.neg` or `¬φ`
- Conjunction: `φ.and ψ` or `φ ∧ ψ`
- Disjunction: `φ.or ψ` or `φ ∨ ψ`
- Biconditional: `φ.iff ψ` or `φ ↔ ψ`
- Derivability: `Γ ⊢ φ`

### Converted Modal Axioms

1. **K**: `theorem modal_k (A B : Formula) : [] ⊢ (A.imp B).box.imp (A.box.imp B.box)` - AXIOM in Logos
2. **D**: `theorem modal_d (A : Formula) : [] ⊢ A.box.imp A.diamond`
3. **T**: `theorem modal_t (A : Formula) : [] ⊢ A.box.imp A` - AXIOM in Logos
4. **B**: `theorem modal_b (A : Formula) : [] ⊢ A.imp (A.diamond.box)` - AXIOM in Logos
5. **4**: `theorem modal_4 (A : Formula) : [] ⊢ A.box.imp (A.box.box)` - AXIOM in Logos
6. **5**: `theorem modal_5 (A : Formula) : [] ⊢ A.diamond.imp (A.diamond.box)` - THEOREM in Logos

### Converted Problem Set Theorems

1. `theorem box_mono {A B : Formula} (h : [] ⊢ A.imp B) : [] ⊢ A.box.imp B.box` - THEOREM in Logos
2. `theorem box_mono_context {A B : Formula} (h : [A] ⊢ B) : [A.box] ⊢ B.box`
3. `theorem box_conj_iff (A B : Formula) : [] ⊢ (A.and B).box.iff (A.box.and B.box)`
4. `theorem box_disj_intro (A B : Formula) : [] ⊢ (A.box.or B.box).imp ((A.or B).box)`
5. `theorem box_contrapose (A B : Formula) : [] ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box)`
6. `theorem diamond_mono {A B : Formula} (h : [] ⊢ A.imp B) : [] ⊢ A.diamond.imp B.diamond` - THEOREM in Logos
7. `theorem diamond_disj_iff (A B : Formula) : [] ⊢ (A.or B).diamond.iff (A.diamond.or B.diamond)`
8. `theorem t_box_to_diamond (A : Formula) : [] ⊢ A.box.imp A.diamond`
9. `theorem t_box_consistent (A : Formula) : [] ⊢ (A.and A.neg).box.neg`
10. `theorem d_diamond_tautology (A : Formula) : [] ⊢ (A.imp A).diamond`
11. `theorem b_box_to_diamond (A : Formula) : [] ⊢ A.box.imp A.diamond`
12. `theorem s4_diamond_box_conj (A B : Formula) : [] ⊢ (A.diamond.and B.box).imp ((A.and B.box).diamond)`
13. `theorem s4_box_diamond_box (A : Formula) : [] ⊢ A.box.imp ((A.box.diamond).box)`
14. `theorem s4_diamond_diamond (A : Formula) : [] ⊢ (A.diamond.diamond).iff A.diamond` - THEOREM in Logos (diamond_4)
15. `theorem s4_diamond_box_diamond (A : Formula) : [] ⊢ (A.diamond.box.diamond).iff A.diamond`
16. `theorem s5_diamond_conj_diamond (A B : Formula) : [] ⊢ ((A.and B.diamond).diamond).iff (A.diamond.and B.diamond)`
17. `theorem s5_diamond_box (A : Formula) : [] ⊢ (A.box.diamond).iff A.box`
18. `theorem s5_box_box (A : Formula) : [] ⊢ A.box.imp (A.box.box)` - AXIOM in Logos (modal_4)
19. `theorem s5_mb (A : Formula) : [] ⊢ A.imp (A.diamond.box)` - AXIOM in Logos (modal_b)
20. `theorem s5_diamond_box_to_truth (A : Formula) : [] ⊢ (A.box.diamond).imp A`

## Already Derived in Logos

Based on `Logos/Core/ProofSystem/Axioms.lean` and `Logos/Core/Theorems/Perpetuity.lean`:

### Core Axioms (Already Present)

1. **K** (modal_k_dist) - AXIOM: `modal_k_dist (φ ψ : Formula) : Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))`
2. **T** (modal_t) - AXIOM: `modal_t (φ : Formula) : Axiom (Formula.box φ |>.imp φ)`
3. **B** (modal_b) - AXIOM: `modal_b (φ : Formula) : Axiom (φ.imp (Formula.box φ.diamond))`
4. **4** (modal_4) - AXIOM: `modal_4 (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.box φ)))`

### Core Theorems (Already Proven)

5. **5** (modal_5) - THEOREM: `theorem modal_5 (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.box` (Perpetuity.lean:884)
6. **box_mono** - THEOREM: `theorem box_mono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.box.imp B.box` (Perpetuity.lean:1611)
7. **diamond_mono** - THEOREM: `theorem diamond_mono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.diamond.imp B.diamond` (Perpetuity.lean:1621)
8. **diamond_4** - THEOREM: `theorem diamond_4 (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond` (Perpetuity.lean:789)
9. **mb_diamond** - THEOREM: `theorem mb_diamond (φ : Formula) : ⊢ φ.imp (φ.diamond.box)` (Perpetuity.lean:1185)

### NOT Yet Derived (11 theorems)

Note: D axiom is NOT in Logos (Logos uses S5 which includes T, making D redundant)

2. **modal_d** (D axiom): `□A → ◇A`
3. **box_mono_context**: If `A ⊢ B`, then `□A ⊢ □B`
4. **box_conj_iff**: `□(A ∧ B) ↔ (□A ∧ □B)` (partial: box_conj_intro exists, need elimination direction)
5. **box_disj_intro**: `(□A ∨ □B) → □(A ∨ B)`
6. **box_contrapose**: `□(A → B) → □(¬B → ¬A)`
7. **diamond_disj_iff**: `◇(A ∨ B) ↔ (◇A ∨ ◇B)`
8. **t_box_to_diamond**: `□A → ◇A` (derivable from T + D)
9. **t_box_consistent**: `¬□(A ∧ ¬A)`
10. **d_diamond_tautology**: `◇(A → A)`
11. **s4_diamond_box_conj**: `(◇A ∧ □B) → ◇(A ∧ □B)`
12. **s4_box_diamond_box**: `□A → □◇□A`
13. **s4_diamond_box_diamond**: `◇□◇A ↔ ◇A`
14. **s5_diamond_conj_diamond**: `◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)`
15. **s5_diamond_box**: `◇□A ↔ □A`
16. **s5_diamond_box_to_truth**: `◇□A → A`

## Key Findings

- **9 theorems/axioms already present**: K, T, B, 4, 5, box_mono, diamond_mono, diamond_4, mb_diamond
- **11 theorems not yet derived**: D axiom, box_mono_context, box_conj_iff, box_disj_intro, box_contrapose, diamond_disj_iff, t_box_to_diamond, t_box_consistent, d_diamond_tautology, s4_diamond_box_conj, s4_box_diamond_box, s4_diamond_box_diamond, s5_diamond_conj_diamond, s5_diamond_box, s5_diamond_box_to_truth

## Recommendations

1. **Immediate additions** (simple S5 theorems):
   - t_box_to_diamond (derivable from modal_t + S5)
   - box_conj_iff (complete the biconditional)
   - diamond_disj_iff (duality of box_conj_iff)

2. **Medium priority** (S5-specific):
   - s5_diamond_box: `◇□A ↔ □A` (characteristic S5 theorem)
   - s5_diamond_box_to_truth: `◇□A → A`
   - box_disj_intro, box_contrapose

3. **Low priority** (D system - not needed for S5):
   - modal_d axiom (redundant in S5 which has T)
   - d_diamond_tautology

4. **Complex theorems** (require significant proof work):
   - s4_diamond_box_conj, s4_box_diamond_box, s4_diamond_box_diamond
   - s5_diamond_conj_diamond

## Notes

- Logos implements S5 modal logic (not K, D, T, B, or S4 separately)
- D axiom is derivable from T in S5 (if necessarily true, then true, hence possible)
- Some theorems require disjunction reasoning which may need additional infrastructure
- box_conj_intro exists (Perpetuity.lean:965), need box_conj_elim for full biconditional
