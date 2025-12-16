# Mathlib Theorems Research Report

## Executive Summary

This report surveys Lean 4 Mathlib resources for theorems relevant to deriving P5 perpetuity principle (`◇▽φ → △◇φ`) and the pairing combinator from K and S axioms. While Mathlib does not contain built-in S5 modal logic, several specialized projects provide modal logic formalizations. For propositional reasoning (contraposition, double negation), Mathlib provides comprehensive support through tactics and theorems.

---

## Findings

### 1. S5 Modal Logic Axioms (Characteristic Axiom `◇φ → □◇φ`)

**Status**: Not in core Mathlib, but available in specialized projects

**Key Finding**: The S5 characteristic axiom `◇φ → □◇φ` (possibility is necessarily possible) is **NOT** included in the Logos TM base system, which blocks the P5 derivation. External Lean 4 modal logic projects formalize S5:

- **FormalizedFormalLogic/Foundation**: Formalizes mathematical logic in Lean 4, including modal logic with `□` (box) and `◇` (diamond) operators, Kripke semantics, neighborhood semantics, and the Gödel-McKinsey-Tarski theorem
  - Repository: [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation)
  - Documentation: [Logic Formalization in Lean 4](https://formalizedformallogic.github.io/Book/)

- **lean4-logic (iehality/lean4-logic or hmonroe/lean4-logic2)**: Provides Hilbert-style deduction for modal logics K, KT, KD, S4, S5
  - Includes aliases for 𝐊𝐓𝟒 (S4) and 𝐊𝐓𝟓 (S5)
  - Provides soundness proofs for K extended with T, B, D, 4, 5 axioms

**S5 Axioms Overview** (from general modal logic sources):
- **Axiom K**: `□(φ → ψ) → (□φ → □ψ)` (necessity distributes over implication)
- **Axiom T**: `□φ → φ` (what is necessary is true)
- **Axiom 4**: `□φ → □□φ` (necessity is transitive)
- **Axiom 5**: `◇φ → □◇φ` (possibility is necessarily possible) ← **THIS IS THE BLOCKER**

**Accessibility Relation**: S5 semantics requires an equivalence relation (reflexive, symmetric, transitive) between possible worlds.

**Implication for Logos**: Adding Axiom 5 (`◇φ → □◇φ`) would unblock P5 derivation. This axiom states that if something is possible in the current world, it remains possible in all accessible worlds (which in S5 is all worlds).

### 2. Combinator Calculus (S, K, B, C Combinators)

**Status**: Not comprehensively formalized in Mathlib

**Key Finding**: While Mathlib includes computability theory (general recursive functions, Turing machines, primitive recursive functions), specific combinator calculus with S, K, B, C combinators is **not extensively documented** in mainstream Mathlib.

**Available Resources**:
- **Mathlib/Data/Nat/Pairing.lean**: Mathlib contains natural number pairing functions
  - File: [Mathlib/Data/Nat/Pairing.lean](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Data/Nat/Pairing.lean)
  - Note: This is for **numeric** pairing, not the propositional logic pairing combinator

**Combinator Calculus Background** (from general sources):
- **S combinator**: `S x y z = x z (y z)` - application combinator
- **K combinator**: `K x y = x` - constant function (weakening)
- **B combinator**: `B x y z = x (y z)` - function composition
- **C combinator**: `C x y z = x z y` - flip/permutation
- **I combinator**: `I x = x` - identity (derivable as `I = S K K`)

**Pairing Combinator Construction**: The pairing combinator `λa.λb.λf. f a b` can be constructed as:
```
pairing = S (S (K S) (S (K K) I)) (K I)
where I = S K K
```
This is estimated at ~40-50 lines of combinator manipulation in Lean.

**Implication for Logos**: The pairing combinator derivation is **semantically valid but syntactically tedious**. The TODO.md marks this as "SKIPPED - optional, low priority" because it adds no mathematical insight. Axiomatizing it is justified.

### 3. Double Negation and Contraposition Theorems

**Status**: Well-supported in Mathlib

**Key Finding**: Mathlib provides excellent support for classical logic reasoning patterns needed for perpetuity proofs.

**Contraposition**:
- **Tactic**: `contrapose` - transforms goal `A → B` to `¬B → ¬A`
  - Variant: `contrapose!` - applies `push_neg` to simplify negations
  - Documentation: [Contraposition in Lean](https://ouss122.github.io/Ou12Blog/blog/contradiction-contraposition-and-lean/)
  - Zulip discussion: [contrapose tactic](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/contrapose.html)

**Double Negation**:
- **Helper theorems**: `not_not` lemma for rewriting `¬¬φ ↔ φ`
- **Classical logic**: `Classical.byContradiction` has signature `(¬?m → False) → ?m`
- **Tactic**: `push_neg` - pushes negations inward to simplify compound negated statements
  - Reference: [Mathematics in Lean - Logic](https://leanprover-community.github.io/mathematics_in_lean/C03_Logic.html)

**Logos Implementation**: The Logos codebase already implements:
- `contraposition` theorem (Perpetuity.lean:336) - proven via B combinator
- `dni` (double negation introduction) axiom (Perpetuity.lean:203) - axiomatized with semantic justification
- DNE (double negation elimination) axiom in Axioms.lean:149

**Implication**: Logos has the propositional machinery needed for P4 (proven) and would have it for P5/P6 if the S5 axiom were added.

### 4. Modal Duality Theorems

**Status**: Not found in Mathlib for modal logic

**Key Finding**: The search did not return specific results for **modal duality theorems** in the context of modal logic formalized in Lean 4/Mathlib. Duality results in Mathlib relate to:
- **Linear algebra**: Dual vector spaces, dual basis, isomorphism with bidual
- **Linear programming**: [Duality theory formally verified](https://arxiv.org/html/2409.08119) (Lean 4.18.0, Mathlib revision 2025-04-01)

**Modal Duality Identities Needed for P6**:
- `◇(¬φ) ↔ ¬□φ` (diamond of negation equals negation of box)
- `▽(¬φ) ↔ ¬△φ` (sometimes negation equals negation of always)

**Logos Implementation Notes** (from Perpetuity.lean:886-897):
These dualities are **NOT definitionally equal** in the Formula structure:
- `φ.neg.diamond` = `(φ.neg).neg.box.neg` ≠ `φ.box.neg` (definitionally)
- `φ.neg.sometimes` = `(φ.neg).neg.always.neg` ≠ `φ.always.neg` (definitionally)

Proving these as theorems would require:
- Modal K distribution + DNE for modal case
- Temporal K distribution + DNE for temporal case
- Contraposition + double negation handling
- Estimated effort: 20-30 lines per duality lemma

**Implication**: Even with S5 axiom added, P6 derivation via duality would require proving the duality theorems first.

### 5. Temporal Duality and Always/Sometimes Operators

**Status**: Already implemented in Logos

**Key Finding**: Logos implements temporal duality via the `swap_temporal` function and temporal duality inference rule:

**Temporal Duality Rule** (Derivation.lean:152):
```lean
| temporal_duality (φ : Formula)
    (h : Derivable [] φ) : Derivable [] φ.swap_past_future
```

**Swap Temporal Function** (Formula.lean):
- Swaps `all_past` ↔ `all_future` operators
- Involutive property: `swap_temporal (swap_temporal φ) = φ`
- Used extensively in perpetuity proofs (e.g., `box_to_past` via temporal duality on MF)

**Derived Operators**:
- `always φ` = `φ.all_past.and (φ.and φ.all_future)` (Hφ ∧ φ ∧ Gφ)
- `sometimes φ` = `φ.neg.always.neg` (¬△¬φ)
- `diamond φ` = `φ.neg.box.neg` (¬□¬φ)

**Implication**: The temporal duality machinery is complete. The issue is purely on the modal side (missing S5 axiom).

---

## Recommendations

### Recommendation 1: Add S5 Axiom 5 to Unblock P5

**Action**: Add the S5 characteristic axiom `◇φ → □◇φ` to `Logos/Core/ProofSystem/Axioms.lean`

**Rationale**:
- This is the **only blocker** for deriving P5 (`◇▽φ → △◇φ`)
- The axiom is semantically valid in TM's task semantics (S5 modal structure)
- The paper assumes S5 modal logic (Theorem 2.9, Corollary 2.11)
- Logos already includes S5 axioms T, 4, B (just missing 5)

**Implementation**:
```lean
| modal_5 (φ : Formula) : Axiom (Formula.diamond φ |>.imp (Formula.box (Formula.diamond φ)))
```

**Semantic Justification**: In task semantics with S5 modal structure, if φ is possible at world w (∃w' accessible from w where φ), then by symmetry and transitivity of the accessibility relation, φ is possible from all accessible worlds, hence □◇φ.

**Dependencies**: None - this is an independent axiom addition

**Effort Estimate**: 2-4 hours (add axiom, prove soundness, update tests)

### Recommendation 2: Derive P5 Using Persistence Lemma

**Action**: Complete the `persistence` lemma proof (Perpetuity.lean:799) using the new S5 axiom

**Current Status**: Blocked at line 827 with comment "CANNOT derive ◇φ → □◇φ from TM axioms"

**Derivation Strategy** (from commented code):
1. From new axiom: `◇φ → □◇φ` (modal 5)
2. From TF axiom: `□◇φ → F□◇φ` (necessity persists to future)
3. From TD (temporal duality): `□◇φ → H□◇φ` (necessity extends to past)
4. Identity: `□◇φ → □◇φ`
5. Combine with `combine_imp_conj_3`: `◇φ → H□◇φ ∧ □◇φ ∧ F□◇φ`
6. Apply MT to each boxed component: `□◇φ → ◇φ`
7. Result: `◇φ → H◇φ ∧ ◇φ ∧ G◇φ = △◇φ`

**Effort Estimate**: 4-6 hours (complete proof, remove sorry, add tests)

### Recommendation 3: Derive P5 Directly, Then Derive P6 from P5

**Action**: Once P5 is a proven theorem (not axiom), derive P6 via duality

**P5 to P6 Derivation** (Perpetuity.lean:920-926 comments):
1. P5 for `¬φ`: `◇▽(¬φ) → △◇(¬φ)` (apply P5 to negated formula)
2. **Prove duality lemmas** (NEW WORK):
   - `◇(¬φ) ↔ ¬□φ` (modal duality)
   - `▽(¬φ) ↔ ¬△φ` (temporal duality)
3. Apply dualities to P5(¬φ):
   - Left side: `◇▽(¬φ) = ◇(¬△φ) = ¬□△φ` (by dualities)
   - Right side: `△◇(¬φ) = △(¬□φ)` (by modal duality)
4. Contrapose: `¬△(¬□φ) → □△φ`
5. Simplify left side: `¬△(¬□φ) = ▽□φ` (by temporal duality)
6. Result: `▽□φ → □△φ` (P6)

**Estimated Effort**:
- Prove modal duality lemma: 20-30 lines (4-6 hours)
- Prove temporal duality lemma: 20-30 lines (4-6 hours)
- Derive P6 from P5: 30-50 lines (6-8 hours)
- Total: **14-20 hours**

**Alternative**: Accept P6 as axiomatized (current MVP approach) if duality proofs prove too complex.

### Recommendation 4: Keep Pairing Combinator Axiomatized

**Action**: Accept `pairing` axiom (Perpetuity.lean:174) as semantically justified

**Rationale**:
- The derivation from S and K is **syntactically possible** but tedious (~40-50 lines)
- Adds no mathematical insight (standard combinator calculus result)
- Semantic validity is clear: if A and B are true, then A ∧ B is true
- Low priority (marked "SKIPPED - optional" in TODO.md)

**Alternative Approach**: If zero-axiom footprint is required, implement the S(S(KS)(S(KK)I))(KI) construction:
- Effort: 8-12 hours (per TODO.md estimate)
- Benefit: Pure syntactic derivation
- Cost: Obscures mathematical content with combinator manipulation

**Recommendation**: Keep axiomatized unless required for publication or formal certification.

### Recommendation 5: Verify Soundness of Modal 5 Axiom

**Action**: Prove soundness of `◇φ → □◇φ` in task semantics

**Location**: Add to `Logos/Core/Metalogic/Soundness.lean`

**Semantic Proof Sketch**:
- Assume `M,τ,t ⊨ ◇φ` (φ is possible at world τ, time t)
- By definition: `∃ρ ∈ histories(M). M,ρ,t ⊨ φ`
- Goal: Show `M,τ,t ⊨ □◇φ`, i.e., `∀ρ' ∈ histories(M). M,ρ',t ⊨ ◇φ`
- For any ρ', we need `∃ρ'' ∈ histories(M). M,ρ'',t ⊨ φ`
- We already have such a ρ (from assumption), so take ρ'' = ρ
- Thus `M,ρ',t ⊨ ◇φ` holds for all ρ'
- Therefore `M,τ,t ⊨ □◇φ`

**Key Property**: The accessibility relation in task semantics is an equivalence relation (S5 structure), so existence of a possible world is stable across all accessible worlds.

**Effort Estimate**: 2-4 hours (formalize proof, add to soundness theorem)

---

## Sources

- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) - Modal logic formalization in Lean 4
- [Logic Formalization in Lean 4](https://formalizedformallogic.github.io/Book/) - Documentation for FormalizedFormalLogic
- [lean4-logic](https://github.com/iehality/lean4-logic) - Hilbert-style modal logic (K, KT, S4, S5)
- [Mathlib/Data/Nat/Pairing.lean](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Data/Nat/Pairing.lean) - Natural number pairing
- [Contraposition in Lean](https://ouss122.github.io/Ou12Blog/blog/contradiction-contraposition-and-lean/) - Contradiction and contraposition tactics
- [Mathematics in Lean - Logic](https://leanprover-community.github.io/mathematics_in_lean/C03_Logic.html) - Logic chapter in Mathematics in Lean
- [Zulip contrapose discussion](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/contrapose.html) - Community discussion of contrapose tactic
- [S5 Modal Logic: A Deep Dive](https://www.numberanalytics.com/blog/s5-modal-logic-deep-dive) - General S5 axioms
- [Modal logic - Wikipedia](https://en.wikipedia.org/wiki/Modal_logic) - Background on modal logic systems
- [Combinatory logic - Esolang](https://esolangs.org/wiki/Combinatory_logic) - S, K, B, C combinator definitions
