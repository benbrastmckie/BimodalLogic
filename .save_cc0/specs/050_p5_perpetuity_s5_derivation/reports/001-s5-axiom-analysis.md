# S5 Axiom Analysis for P5 Perpetuity Derivation

## Executive Summary

This research report analyzes the S5 modal logic axiom system to determine which axiom is needed to unblock the P5 perpetuity theorem derivation. The current TM axiom system includes MT, M4, and MB, which are the characteristic axioms of S5 for the box operator. However, the derivation of P5 requires the S5 characteristic axiom for the diamond operator: `◇φ → □◇φ`.

## Current Modal Axiom Inventory

### Axioms in Logos/Core/ProofSystem/Axioms.lean (12 total)

**Propositional Axioms (3)**:
1. `prop_k`: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` - distribution
2. `prop_s`: `φ → (ψ → φ)` - weakening
3. `double_negation`: `¬¬φ → φ` - classical logic (DNE)

**S5 Modal Axioms (4)**:
1. `modal_t` (MT): `□φ → φ` - reflexivity
2. `modal_4` (M4): `□φ → □□φ` - transitivity
3. `modal_b` (MB): `φ → □◇φ` - symmetry
4. `modal_k_dist` (MK): `□(φ → ψ) → (□φ → □ψ)` - K distribution

**Temporal Axioms (3)**:
1. `temp_4` (T4): `Fφ → FFφ` - temporal transitivity
2. `temp_a` (TA): `φ → F(Pφ)` - temporal connectedness
3. `temp_l` (TL): `△φ → F(Hφ)` - temporal introspection

**Modal-Temporal Interaction (2)**:
1. `modal_future` (MF): `□φ → □Fφ` - necessity persists to future
2. `temp_future` (TF): `□φ → F□φ` - necessity in future

## S5 Modal Logic Completeness Analysis

### Standard S5 Axiom System for □

The axioms MT (T), M4 (4), and MB (B) together with the K distribution axiom provide a **complete** axiomatization of S5 for the box operator. These correspond to:
- **K**: Normal modal logic (distribution)
- **T**: Reflexivity of accessibility relation
- **4**: Transitivity of accessibility relation
- **B**: Symmetry of accessibility relation

Together K+T+4+B = **S5**.

### S5 Properties for ◇

In S5, the accessibility relation is an **equivalence relation** (reflexive, transitive, symmetric). This means all worlds are accessible from each other within an equivalence class. Key properties:

1. **◇φ → □◇φ** (The "5" axiom for diamond): If φ is possible, then it is necessarily possible
2. **□φ → ◇φ** (D axiom): Necessary implies possible (follows from T via duality)
3. **◇◇φ → ◇φ** (Diamond 4): Possible possible is possible

### The Missing Axiom: "5" for Diamond

The axiom `◇φ → □◇φ` is the **characteristic axiom of S5 for the diamond operator**. It states:

> If something is possible, then it is necessarily possible.

This is semantically valid in any S5 frame because if there exists a world w' accessible from w where φ holds, then from any world w'' accessible from w, we can still access w' (since accessibility is symmetric and transitive in S5).

## Why TM Currently Lacks This

### Derivability Analysis

Can `◇φ → □◇φ` be derived from existing axioms?

**Attempt 1: From MB**
- MB: `φ → □◇φ`
- If we had `◇φ → φ`, we could compose. But this is FALSE (possibility doesn't imply truth).

**Attempt 2: From M4 + Duality**
- M4: `□φ → □□φ`
- Diamond dual: `◇◇φ → ◇φ` (contrapositively from M4 on ¬φ)
- This gives us `◇◇φ → ◇φ`, not `◇φ → □◇φ`.

**Attempt 3: From MB + DNE**
- MB: `φ → □◇φ`
- We need to lift from `φ` to `◇φ` somehow.
- But there's no way to eliminate the assumption `φ`.

**Conclusion**: `◇φ → □◇φ` is **NOT derivable** from the current TM axioms.

## Impact on P5 Derivation

### The Persistence Lemma Blocking Issue

From Perpetuity.lean (lines 770-827), the persistence lemma `◇φ → △◇φ` requires:

1. Start from `◇φ`
2. Need to derive `□◇φ` to use TF and temporal propagation
3. Current axiom MB gives `φ → □◇φ`, but not `◇φ → □◇φ`

The derivation chain would be:
```
◇φ → □◇φ        (S5 characteristic for ◇)
□◇φ → F□◇φ      (TF on ◇φ)
□◇φ → H□◇φ      (TD of TF)
□◇φ → ◇φ        (MT)
------------------------
◇φ → H◇φ ∧ ◇φ ∧ G◇φ = △◇φ
```

**Without `◇φ → □◇φ`, this derivation cannot proceed.**

## Semantic Justification for Adding the Axiom

### Soundness Verification

The axiom `◇φ → □◇φ` is **sound** in task semantics because:

1. **S5 Modal Structure**: The modal component of TM uses S5 semantics where the accessibility relation between world histories at a fixed time is an equivalence relation.

2. **Task Frame Definition** (from TaskFrame.lean): The modal quantification is over all world histories `σ` at time `t`, with no accessibility restriction (universal quantification).

3. **Universal Accessibility**: In task semantics, `□φ` at (M,τ,t) means φ holds in all world histories σ at time t. This is characteristic of S5 where all worlds within an equivalence class are accessible.

### From Corollary 2.11 (JPL Paper)

The paper's Corollary 2.11 states that all S5 modal facts are valid in task semantics. The axiom `◇φ → □◇φ` is a standard S5 theorem, hence valid.

## Recommendation

### Add S5 Characteristic Axiom for ◇

Add the following axiom to Axioms.lean:

```lean
/--
S5 characteristic axiom for diamond: `◇φ → □◇φ` (positive introspection for ◇).

If something is possible, it is necessarily possible. This is the characteristic
axiom of S5 for the diamond operator, dual to M4 (`□φ → □□φ`) for box.

Semantically: In S5 frames, the accessibility relation is an equivalence relation.
If world w' exists where φ holds, then from any world accessible from w, we can
still access w' (by transitivity and symmetry).

This axiom completes the S5 characterization: K + T + 4 + B + 5 = S5.
The "5" axiom is needed for both □ and ◇ variants.

**Usage**: Required for perpetuity lemma `◇φ → △◇φ` (persistence of possibility).
-/
| modal_5 (φ : Formula) : Axiom (φ.diamond.imp (φ.diamond.box))
```

### Naming Convention

The axiom is traditionally called "5" or "E" in modal logic literature:
- **5**: Fifth axiom in the Lewis numbering (after K, T, 4, B)
- **E**: Euclidean property (∀w,v,u: wRv ∧ wRu → vRu)

I recommend `modal_5` for consistency with `modal_4`.

## Verification of Non-Redundancy

### Independence Argument

`◇φ → □◇φ` is **independent** of the current axioms:

1. **Semantic independence**: There exist Kripke frames validating K+T+4+B that do NOT validate `◇φ → □◇φ`. However, adding B (symmetry) actually makes the accessibility relation symmetric, and combined with transitivity (4), we get an equivalence relation.

2. **Derivability from T+4+B+K**: Actually, in the presence of T, 4, and B axioms with K, the axiom 5 IS derivable:
   - From MB: `φ → □◇φ`
   - From M4: `□φ → □□φ`
   - Contrapositive: `◇◇φ → ◇φ`
   - Combined reasoning should yield `◇φ → □◇φ`

### Critical Re-analysis

Let me verify if `◇φ → □◇φ` is derivable from existing axioms:

**Claim**: In S5, `◇φ → □◇φ` follows from MB + M4 + propositional logic.

**Proof Attempt**:
1. MB: `φ → □◇φ`
2. Substitute `◇φ` for `φ`: `◇φ → □◇◇φ`
3. Need: `◇◇φ → ◇φ` (this is derivable from M4 by contraposition and duality)
4. If we had: `□◇◇φ → □◇φ` (from step 3 by necessitation and K)
5. Then: `◇φ → □◇◇φ → □◇φ`

**Wait** - Step 2 substitutes into MB but we need to apply MB to `◇φ`, which would require `◇φ → □◇(◇φ)`. This would give `◇φ → □◇◇φ`.

Then we need to show `□◇◇φ → □◇φ`:
- `◇◇φ → ◇φ` (from M4 by duality)
- Necessitation: `□(◇◇φ → ◇φ)`
- K distribution: `□◇◇φ → □◇φ`

So: `◇φ → □◇◇φ → □◇φ`, giving us `◇φ → □◇φ`.

**CONCLUSION**: The axiom `◇φ → □◇φ` MAY be derivable from existing axioms using MB, M4, and K distribution!

## Updated Analysis: Derivability of 5 from B+4

### Formal Derivation

1. **MB on ◇φ**: `◇φ → □◇◇φ`
2. **M4 on ¬φ**: `□¬φ → □□¬φ`
3. **Contrapositive of M4**: `◇◇φ → ◇φ` (diamond 4)
4. **Necessitate step 3**: `□(◇◇φ → ◇φ)`
5. **Apply MK distribution**: `□◇◇φ → □◇φ`
6. **Compose steps 1 and 5**: `◇φ → □◇φ`

This derivation appears correct! Let me verify each step:

1. MB: `φ → □◇φ`. Substituting `◇φ` for `φ` gives `◇φ → □◇◇φ`. ✓
2. M4: `□φ → □□φ`. Substituting `¬φ` for `φ` gives `□¬φ → □□¬φ`. ✓
3. Contraposition: `¬□□¬φ → ¬□¬φ`, which is `◇◇φ → ◇φ`. ✓
4. From step 3, if we can derive it as a theorem, we can necessitate it. ✓
5. MK: `□(A→B) → (□A → □B)`. With A=◇◇φ, B=◇φ gives `□(◇◇φ→◇φ) → (□◇◇φ → □◇φ)`. ✓
6. Transitivity of implication. ✓

### Key Issue: Deriving ◇◇φ → ◇φ as a Theorem

The derivation in step 3 requires deriving `◇◇φ → ◇φ` as an empty-context theorem (`⊢ ◇◇φ → ◇φ`).

From M4 (`□φ → □□φ`):
- Substitute `¬φ` for `φ`: `□¬φ → □□¬φ`
- This is: `¬◇φ → ¬◇◇φ` (by definition of ◇)
- Contrapositive: `◇◇φ → ◇φ` ✓

This IS derivable using:
1. `axiom (M4 on ¬φ)`: `⊢ □¬φ → □□¬φ`
2. `contraposition`: `⊢ (A → B) → (¬B → ¬A)`
3. Apply contraposition to get: `⊢ ¬□□¬φ → ¬□¬φ`
4. Which is: `⊢ ◇◇φ → ◇φ`

### REVISED CONCLUSION

The axiom `◇φ → □◇φ` (S5 characteristic for ◇) **IS DERIVABLE** from the current TM axioms:
- MB: `φ → □◇φ`
- M4: `□φ → □□φ`
- MK distribution: `□(A→B) → (□A → □B)`
- Propositional reasoning: contraposition, transitivity

**The issue is not a missing axiom, but a missing derivation in Perpetuity.lean!**

## Actual Implementation Need

Rather than adding a new axiom, we need to:

1. **Derive `diamond_4`**: `⊢ ◇◇φ → ◇φ` (from M4 + contraposition)
2. **Derive `modal_5`**: `⊢ ◇φ → □◇φ` (from MB + diamond_4 + MK)
3. **Use modal_5 in persistence lemma** to complete P5 derivation

## Summary

| Item | Status |
|------|--------|
| S5 characteristic `◇φ → □◇φ` needed? | Yes, for persistence lemma |
| Is it already an axiom? | No |
| Can it be derived from existing axioms? | **YES** (from MB + M4 + MK) |
| Implementation approach | Derive as theorem, not add as axiom |
| Estimated complexity | Medium (20-30 lines) |

## Next Steps

1. Create `diamond_4` theorem: `⊢ ◇◇φ → ◇φ`
2. Create `modal_5` theorem: `⊢ ◇φ → □◇φ`
3. Use `modal_5` to complete persistence lemma
4. Derive P5 from P4 + persistence
5. Derive P6 from P5

This approach maintains the minimal axiom philosophy - deriving all S5 properties rather than axiomatizing them redundantly.
