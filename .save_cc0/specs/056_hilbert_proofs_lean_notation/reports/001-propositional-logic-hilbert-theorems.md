# Research Report: Propositional Logic Hilbert Theorems

**Topic**: Propositional Logic Hilbert Theorems from sec:PL-Hilbert-Proofs
**Date**: 2025-12-09
**Researcher**: Claude (research-specialist)

## Executive Summary

This report documents the 20 propositional logic theorems from the sec:PL-Hilbert-Proofs section in LogicNotes.tex, converts each to appropriate Lean 4 notation compatible with the Logos TM logic system, and identifies which theorems are already derived.

## Source Theorems from LogicNotes.tex

The following 20 theorems appear in sec:PL-Hilbert-Proofs (lines 377-398):

1. **HS** (Hypothetical syllogism): `A → B, B → C ⊢ A → C`
2. **HE** (Hypothetical exchange): `A → (B → C) ⊢ B → (A → C)`
3. **RAA** (Reductio ad absurdum): `⊢ A → (¬A → B)`
4. **EFQ** (Ex falso quodlibet): `⊢ ¬A → (A → B)`
5. **RCP** (Reverse contraposition): `¬A → ¬B ⊢ B → A`
6. **DNE** (Double negation elimination): `⊢ ¬¬A → A`
7. **DNI** (Double negation introduction): `⊢ A → ¬¬A`
8. **CP** (Contraposition): `A → B ⊢ ¬B → ¬A`
9. **NE** (Negation elimination): if `Γ, ¬A ⊢ ¬B` and `Γ, ¬A ⊢ B`, then `Γ ⊢ A`
10. **NI** (Negation introduction): if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`
11. **ECQ** (Ex contradictione quodlibet): `A, ¬A ⊢ B`
12. **LDI** (Left disjunction introduction): `A ⊢ A ∨ B`
13. **RDI** (Right disjunction introduction): `B ⊢ A ∨ B`
14. **CI** (Conjunction introduction): `A, B ⊢ A ∧ B`
15. **LCE** (Left conjunction elimination): `A ∧ B ⊢ A`
16. **RCE** (Right conjunction elimination): `A ∧ B ⊢ B`
17. **DE** (Disjunction elimination): if `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`
18. **BI** (Biconditional introduction): if `Γ, A ⊢ B` and `Γ, B ⊢ A`, then `Γ ⊢ A ↔ B`
19. **LBE** (Left biconditional elimination): `A ↔ B, A ⊢ B`
20. **RBE** (Right biconditional elimination): `A ↔ B, B ⊢ A`

## Lean 4 Notation Conversion

Using Logos Formula syntax:
- Implication: `A.imp B` or `A → B`
- Negation: `A.neg` or `¬A`
- Conjunction: `A.and B` or `A ∧ B`
- Disjunction: `A.or B` or `A ∨ B`
- Biconditional: `A.iff B` or `A ↔ B`
- Derivability: `Derivable Γ φ` or `Γ ⊢ φ`
- Empty context: `[]`

### Converted Theorems

1. **HS**: `theorem hs (A B C : Formula) (h1 : Γ ⊢ A.imp B) (h2 : Γ ⊢ B.imp C) : Γ ⊢ A.imp C`
2. **HE**: `theorem he (A B C : Formula) : Γ ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))`
3. **RAA**: `theorem raa (A B : Formula) : Γ ⊢ A.imp (A.neg.imp B)`
4. **EFQ**: `theorem efq (A B : Formula) : Γ ⊢ A.neg.imp (A.imp B)`
5. **RCP**: `theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A`
6. **DNE**: `theorem dne (A : Formula) : Γ ⊢ A.neg.neg.imp A`
7. **DNI**: `theorem dni (A : Formula) : Γ ⊢ A.imp A.neg.neg`
8. **CP**: `theorem cp (A B : Formula) (h : Γ ⊢ A.imp B) : Γ ⊢ B.neg.imp A.neg`
9. **NE**: `theorem ne (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A`
10. **NI**: `theorem ni (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg`
11. **ECQ**: `theorem ecq (A B : Formula) : [A, A.neg] ⊢ B`
12. **LDI**: `theorem ldi (A B : Formula) : [A] ⊢ A.or B`
13. **RDI**: `theorem rdi (A B : Formula) : [B] ⊢ A.or B`
14. **CI**: `theorem ci (A B : Formula) : [A, B] ⊢ A.and B`
15. **LCE**: `theorem lce (A B : Formula) : [A.and B] ⊢ A`
16. **RCE**: `theorem rce (A B : Formula) : [A.and B] ⊢ B`
17. **DE**: `theorem de (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) : ((A.or B) :: Γ) ⊢ C`
18. **BI**: `theorem bi (A B : Formula) (h1 : (A :: Γ) ⊢ B) (h2 : (B :: Γ) ⊢ A) : Γ ⊢ A.iff B`
19. **LBE**: `theorem lbe (A B : Formula) : [A.iff B, A] ⊢ B`
20. **RBE**: `theorem rbe (A B : Formula) : [A.iff B, B] ⊢ A`

## Already Derived in Logos

Based on analysis of `Logos/Core/Theorems/Perpetuity.lean` and `Logos/Core/ProofSystem/Axioms.lean`:

### Already Present

1. **DNE** - AXIOM: `axiom double_negation (φ : Formula) : Axiom (φ.neg.neg.imp φ)` (Axioms.lean:149)
2. **DNI** - AXIOM: `axiom dni (A : Formula) : ⊢ A.imp A.neg.neg` (Perpetuity.lean:523)
3. **CP** (Contraposition) - THEOREM: `theorem contraposition {A B : Formula} ...` (Perpetuity.lean:661)
4. **HE** (Hypothetical exchange / Flip) - THEOREM: `theorem theorem_flip {A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))` (Perpetuity.lean:146)
5. **CI** (Conjunction introduction / Pairing) - THEOREM: `theorem pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))` (Perpetuity.lean:487)
6. **HS** (Hypothetical syllogism) - THEOREM: `theorem imp_trans {A B C : Formula} ...` (Perpetuity.lean:82)

### NOT Yet Derived (14 theorems)

7. **RAA** (Reductio ad absurdum): `⊢ A → (¬A → B)`
8. **EFQ** (Ex falso quodlibet): `⊢ ¬A → (A → B)`
9. **RCP** (Reverse contraposition): `¬A → ¬B ⊢ B → A`
10. **NE** (Negation elimination): if `Γ, ¬A ⊢ ¬B` and `Γ, ¬A ⊢ B`, then `Γ ⊢ A`
11. **NI** (Negation introduction): if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`
12. **ECQ** (Ex contradictione quodlibet): `A, ¬A ⊢ B`
13. **LDI** (Left disjunction introduction): `A ⊢ A ∨ B`
14. **RDI** (Right disjunction introduction): `B ⊢ A ∨ B`
15. **LCE** (Left conjunction elimination): `A ∧ B ⊢ A`
16. **RCE** (Right conjunction elimination): `A ∧ B ⊢ B`
17. **DE** (Disjunction elimination): if `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`
18. **BI** (Biconditional introduction): if `Γ, A ⊢ B` and `Γ, B ⊢ A`, then `Γ ⊢ A ↔ B`
19. **LBE** (Left biconditional elimination): `A ↔ B, A ⊢ B`
20. **RBE** (Right biconditional elimination): `A ↔ B, B ⊢ A`

## Key Findings

- **6 theorems already derived**: DNE (axiom), DNI (axiom), CP, HE, CI, HS
- **14 theorems not yet derived**: RAA, EFQ, RCP, NE, NI, ECQ, LDI, RDI, LCE, RCE, DE, BI, LBE, RBE

## Recommendations

1. **Immediate additions** (theorems with simple proofs):
   - RAA, EFQ (ex falso reasoning)
   - LCE, RCE (conjunction elimination)
   - LDI, RDI (disjunction introduction)

2. **Medium priority** (require context manipulation):
   - NE, NI (negation rules with context)
   - DE (disjunction elimination with context)
   - BI, LBE, RBE (biconditional reasoning)

3. **Derived from existing**:
   - RCP can be derived from CP + DNE + DNI
   - ECQ can be derived from RAA or EFQ

## Notes

- Logos uses derived operators (`.and`, `.or`, `.iff`) defined in `Formula.lean`
- All theorems should be proven, not axiomatized (following Logos TDD principles)
- Some theorems (NE, NI, DE, BI) require context manipulation which may need additional infrastructure
