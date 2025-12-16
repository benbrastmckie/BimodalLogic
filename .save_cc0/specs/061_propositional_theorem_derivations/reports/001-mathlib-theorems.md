# Mathlib Theorems Research Report

**Research Task**: Discover Mathlib theorems and patterns for propositional logic derivations

**Date**: 2025-12-09

**Purpose**: Guide implementation of Tasks 21-29 (propositional theorem derivations) in Logos TM logic by identifying relevant Mathlib theorems, proof patterns, and classical reasoning infrastructure.

---

## Executive Summary

This research identifies key Mathlib4 theorems and proof patterns for implementing propositional logic derivations in Logos. The report covers:

1. **Classical Logic Infrastructure**: `Classical.byContradiction`, `Classical.em`, `False.elim`, and related constructs
2. **Conjunction/Disjunction Patterns**: `And.intro`, `And.left`, `And.right`, `Or.inl`, `Or.inr`, `Or.elim`
3. **Contraposition and Negation**: `mt`, `not_not_intro`, `imp_not_comm`, contrapose tactics
4. **Mathlib.Logic.Basic Theorems**: Comprehensive catalog of propositional equivalences
5. **Proof Strategy Insights**: How to adapt Mathlib patterns to Hilbert-style axiomatic derivations

**Key Finding**: Logos already has **8/8 Phase 1 theorems fully proven** (ECQ, RAA, EFQ, LDI, RDI, RCP, LCE, RCE), exceeding TODO expectations. The current system derives these from minimal axioms (prop_k, prop_s, double_negation) using combinator techniques and the deduction theorem.

---

## Section 1: Classical Logic Patterns

### Finding 1.1: Classical Reasoning Primitives in Lean 4 Core

**Source**: [Lean 4 Init.Core](https://github.com/leanprover/lean4/blob/master/src/Init/Core.lean)

Lean 4 provides foundational classical logic constructs:

- **`Decidable.em`**: `(p : Prop) [Decidable p] : p ∨ ¬p` - Excluded middle (decidable version)
- **`Decidable.byContradiction`**: `[Decidable p] (h : ¬p → False) : p` - Proof by contradiction
- **`Decidable.of_not_not`**: `[Decidable p] : ¬¬p → p` - Double negation elimination

**Logos Equivalent**:
- Axiom `double_negation`: `¬¬φ → φ` (classical DNE axiom)
- Theorem `lem`: `⊢ A ∨ ¬A` (derived from `identity` via disjunction definition)
- Theorem `raa`: `⊢ A → (¬A → B)` (reductio ad absurdum, **COMPLETE**)

**Insight**: Logos uses axiomatic DNE rather than `byContradiction` as primitive, which is philosophically cleaner for Hilbert-style systems.

---

### Finding 1.2: Ex Falso Quodlibet Patterns

**Source**: [Theorem Proving in Lean 4 - Propositions and Proofs](https://lean-lang.org/theorem_proving_in_lean4/propositions_and_proofs.html)

Lean 4 represents the principle of explosion via:

- **`False.elim`**: `False → C` - From falsehood, derive anything (polymorphic over `Sort u`)
- **`absurd`**: Combines contradictory hypotheses to prove anything
- **Negation Definition**: `¬p` is defined as `p → False`

**Example from Lean Documentation**:
```lean
open Classical
variable (p : Prop)
example (h : ¬¬p) : p := byCases (fun h1 : p => h1) (fun h1 : ¬p => absurd h1 h)
```

**Logos Implementation** (from `Propositional.lean`):

```lean
-- Ex Falso Quodlibet: ⊢ ¬A → (A → B)
theorem efq (A B : Formula) : ⊢ A.neg.imp (A.imp B)

-- Ex Contradictione Quodlibet: [A, ¬A] ⊢ B
theorem ecq (A B : Formula) : [A, A.neg] ⊢ B
```

**Key Difference**: Logos derives EFQ/ECQ from axioms rather than using built-in `False.elim`, demonstrating completeness of the axiomatic system.

---

### Finding 1.3: Proof by Contradiction (RAA)

**Source**: [Logic and Proof - Classical Reasoning](https://leanprover-community.github.io/logic_and_proof/classical_reasoning.html)

Natural deduction expresses RAA as:

> If, by making an assumption ¬φ, we can infer a contradiction as a consequence, then we may infer φ.

In Lean 4, this is `byContradiction`:
```lean
open Classical
variable (A : Prop)
example : A := byContradiction (fun h : ¬A ↦ show False from sorry)
```

**Logos Implementation**:
```lean
-- Reductio ad Absurdum: ⊢ A → (¬A → B)
theorem raa (A B : Formula) : ⊢ A.imp (A.neg.imp B)
```

**Proof Strategy** (Logos):
1. Derive `⊥ → B` via DNE composition: `⊥ → ¬¬B → B`
2. Build `A → ¬¬A` using `theorem_app1`
3. Compose with `(¬¬A → ⊥) → (¬A → B)` via b_combinator
4. Chain all steps to get `A → (¬A → B)`

**Insight**: Logos proves RAA as a derived theorem, while Lean takes `byContradiction` as an axiom. This demonstrates the philosophical commitment to minimal axiomatic bases.

---

## Section 2: Conjunction and Disjunction Patterns

### Finding 2.1: Conjunction Introduction and Elimination

**Source**: [Lean 4 Documentation - Logical Connectives](https://lean-lang.org/doc/reference/4.21.0-rc3/Basic-Propositions/Logical-Connectives/)

Lean 4 provides built-in constructors for `And`:

- **`And.intro`**: `a → b → a ∧ b` - Conjunction introduction
- **`And.left`** (also `.1`, `h.left`): `a ∧ b → a` - Left elimination
- **`And.right`** (also `.2`, `h.right`): `a ∧ b → b` - Right elimination

**Mathlib Naming Convention** (from [Mathlib naming conventions](https://leanprover-community.github.io/contribute/naming.html)):
> Common "axiomatic" properties of an operation are put in a namespace that begins with the name of the operation. This includes intro and elim operations for logical connectives: `And.intro`, `And.elim`, `Or.intro_left`, `Or.intro_right`, `Or.elim`.

**Logos Implementation**:

```lean
-- Conjunction Introduction (pairing combinator - COMPLETE)
theorem pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))

-- Left Conjunction Elimination: [A ∧ B] ⊢ A
theorem lce (A B : Formula) : [A.and B] ⊢ A

-- Right Conjunction Elimination: [A ∧ B] ⊢ B
theorem rce (A B : Formula) : [A.and B] ⊢ B

-- Implication forms (using deduction theorem)
theorem lce_imp (A B : Formula) : ⊢ (A.and B).imp A
theorem rce_imp (A B : Formula) : ⊢ (A.and B).imp B
```

**Key Difference**:
- Logos conjunction is **defined** as `A ∧ B = ¬(A → ¬B)`
- Elimination requires deriving `¬¬A` (or `¬¬B`) then applying DNE
- The deduction theorem enables lifting context-based derivations to pure implications

**Proof Pattern for LCE**:
1. From conjunction `[(A → ¬B).neg]`, show `A.neg → (A → B.neg)` (via EFQ)
2. Contrapose to get `(A → B.neg).neg → A.neg.neg`
3. Apply conjunction assumption and DNE to extract `A`

---

### Finding 2.2: Disjunction Introduction and Elimination

**Source**: [Mathematics in Lean - Logic](https://leanprover-community.github.io/mathematics_in_lean/C03_Logic.html)

Lean 4 disjunction constructors:

- **`Or.inl`**: `a → a ∨ b` - Left introduction ("left injection")
- **`Or.inr`**: `b → a ∨ b` - Right introduction ("right injection")
- **`Or.elim`**: Proof by cases - from `a ∨ b`, `a → c`, and `b → c`, derive `c`

**Example Usage**:
```lean
example (h : y > 0) : y > 0 ∨ y < -1 := Or.inl h
example (h : y < -1) : y > 0 ∨ y < -1 := Or.inr h
```

**Logos Implementation**:

```lean
-- Left Disjunction Introduction: [A] ⊢ A ∨ B
theorem ldi (A B : Formula) : [A] ⊢ A.or B

-- Right Disjunction Introduction: [B] ⊢ A ∨ B
theorem rdi (A B : Formula) : [B] ⊢ A.or B
```

**Key Difference**:
- Logos disjunction is **defined** as `A ∨ B = ¬A → B`
- LDI proof: From `A`, need `¬A → B`, which uses EFQ pattern
- RDI proof: From `B`, need `¬A → B`, which is trivial via prop_s weakening

**Proof Pattern for LDI**:
1. Goal: `[A] ⊢ ¬A → B` (by disjunction definition)
2. Use EFQ: `⊢ ¬A → (A → B)`
3. From `A` in context and prop_s, get `¬A → A`
4. Compose using prop_k: `(¬A → (A → B)) → ((¬A → A) → (¬A → B))`

---

### Finding 2.3: Case Analysis and Proof Combinators

**Source**: [Logic and Proof - Propositional Logic in Lean](https://leanprover-community.github.io/logic_and_proof/propositional_logic_in_lean.html)

The `rcases` tactic for disjunction case analysis:
> The `rcases` tactic allows us to make use of a hypothesis of the form `A ∨ B`. In contrast to the use of `rcases` with conjunction or an existential quantifier, here the `rcases` tactic produces two goals.

**Logos Equivalent**:

```lean
-- Classical Merge Lemma: ⊢ (P → Q) → ((¬P → Q) → Q)
theorem classical_merge (P Q : Formula) : ⊢ (P.imp Q).imp ((P.neg.imp Q).imp Q)
```

**Proof Strategy**:
1. From `(P → Q)`, contrapose to get `(¬Q → ¬P)`
2. From `(¬P → Q)`, contrapose to get `(¬Q → ¬¬P)`
3. Use `contradiction_intro`: `(A → B) → ((A → ¬B) → ¬A)` to derive `¬¬Q`
4. Apply DNE to get `Q`

**Insight**: The `classical_merge` theorem provides case analysis on LEM (`P ∨ ¬P`) in Hilbert-style calculus, equivalent to Or.elim in natural deduction.

---

## Section 3: Contraposition and Biconditional Patterns

### Finding 3.1: Modus Tollens and Contraposition

**Source**: [Lean 4 Init.Core](https://github.com/leanprover/lean4/blob/master/src/Init/Core.lean)

Lean 4 Core provides:

- **`mt`**: `{a b : Prop} (h₁ : a → b) (h₂ : ¬b) : ¬a` - Modus tollens
- **`not_not_intro`**: `{p : Prop} (h : p) : ¬¬p` - Double negation introduction
- **`imp_not_comm`**: `(a → ¬b) ↔ (b → ¬a)` - Commutativity of negated implications

**Mathlib4 Additions** (from [Mathlib.Logic.Basic](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Basic.html)):

- **`not_imp_not`**: `¬a → ¬b ↔ b → a` - Contrapositive equivalence
- **`Not.imp_symm`**: `(¬a → b) → ¬b → a` - Negation implication symmetry
- **`not_imp_comm`**: `¬a → b ↔ ¬b → a` - Commuting negations in implications

**Logos Implementation**:

```lean
-- Double Negation Introduction (from Perpetuity.lean)
theorem dni (φ : Formula) : ⊢ φ.imp φ.neg.neg

-- Reverse Contraposition: (Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)
theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A

-- Contraposition (implication form): ⊢ (A → B) → (¬B → ¬A)
theorem contrapose_imp (A B : Formula) : ⊢ (A.imp B).imp (B.neg.imp A.neg)
```

**Proof Pattern for RCP** (Reverse Contraposition):
1. Apply DNI to B: `B → ¬¬B`
2. Contrapose hypothesis: `¬A → ¬B` becomes `¬¬B → ¬¬A`
3. Apply DNE to A: `¬¬A → A`
4. Compose: `B → ¬¬B → ¬¬A → A`

**Insight**: The `contrapose_imp` theorem is built from `b_combinator` and `theorem_flip`, showing how complex logical laws emerge from simple combinators.

---

### Finding 3.2: Contrapose Tactic in Mathlib

**Source**: [Mathlib.Tactic.Contrapose](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Tactic/Contrapose.html)

Mathlib provides the `contrapose` tactic:

> The contrapose tactic transforms the goal into its contrapositive when that goal is an implication or an iff. It also avoids creating a double negation if there already is a negation.

**Tactic Variants**:
- `contrapose`: `P → Q` becomes `¬Q → ¬P`
- `contrapose!`: Adds `push_neg` to simplify negations
- `contrapose h`: Reverts hypothesis `h`, contraposes, then reintroduces

**Example**:
```lean
-- Goal: P → Q
contrapose
-- Goal: ¬Q → ¬P
```

**Logos Application**: Could implement `contrapose` as a custom tactic using `contrapose_imp` theorem:

```lean
-- Potential tactic implementation
macro "contrapose" : tactic =>
  `(tactic| apply contrapose_imp; <continue>)
```

**Insight**: Mathlib's tactic infrastructure could inspire automation for Logos's Hilbert-style proofs, particularly for modal and temporal reasoning.

---

### Finding 3.3: Biconditional (Iff) Introduction and Elimination

**Source**: [Lean 4 Init.Core](https://github.com/leanprover/lean4/blob/master/src/Init/Core.lean)

Lean 4 `Iff` structure:
```lean
structure Iff (a b : Prop) where
  mp  : a → b  -- modus ponens (forward direction)
  mpr : b → a  -- modus ponens reverse (backward direction)
```

**Theorems**:
- **`Iff.refl`**: `a ↔ a` - Reflexivity
- **`Iff.symm`**: `(a ↔ b) → (b ↔ a)` - Symmetry
- **`Iff.trans`**: `(a ↔ b) → (b ↔ c) → (a ↔ c)` - Transitivity
- **`Iff.of_eq`**: `a = b → a ↔ b` - From equality

**Logos Implementation**:

```lean
-- Biconditional Introduction: From ⊢ A → B and ⊢ B → A, derive ⊢ (A ↔ B)
-- (represented as conjunction (A → B) ∧ (B → A))
theorem iff_intro (A B : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp A) :
    ⊢ (A.imp B).and (B.imp A)

-- Left Biconditional Elimination: From A ↔ B and A, derive B
theorem iff_elim_left (A B : Formula) : [((A.imp B).and (B.imp A)), A] ⊢ B

-- Right Biconditional Elimination: From A ↔ B and B, derive A
theorem iff_elim_right (A B : Formula) : [((A.imp B).and (B.imp A)), B] ⊢ A

-- Contraposition for Biconditionals: From ⊢ A ↔ B, derive ⊢ ¬A ↔ ¬B
theorem contrapose_iff (A B : Formula) (h : ⊢ (A.imp B).and (B.imp A)) :
    ⊢ (A.neg.imp B.neg).and (B.neg.imp A.neg)
```

**Key Difference**: Logos represents `A ↔ B` as `(A → B) ∧ (B → A)` rather than a distinct structure, maintaining uniformity with the Hilbert-style formula language.

---

## Section 4: De Morgan Laws and Distributivity

### Finding 4.1: De Morgan Laws in Mathlib

**Source**: [Mathlib.Logic.Basic](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Basic.html)

Mathlib provides multiple formulations:

- **`not_and_or`**: `¬(a ∧ b) ↔ ¬a ∨ ¬b` - Negation distributes over conjunction
- **`or_iff_not_and_not`**: `a ∨ b ↔ ¬(¬a ∧ ¬b)` - Disjunction equivalence
- **`and_iff_not_or_not`**: `a ∧ b ↔ ¬(¬a ∨ ¬b)` - Conjunction equivalence

**Logos Implementation** (Phase 4 - Plan 059):

```lean
-- De Morgan Law 1 (Forward): ⊢ ¬(A ∧ B) → (¬A ∨ ¬B)
theorem demorgan_conj_neg_forward (A B : Formula) :
    ⊢ (A.and B).neg.imp (A.neg.or B.neg)

-- De Morgan Law 1 (Backward): ⊢ (¬A ∨ ¬B) → ¬(A ∧ B)
theorem demorgan_conj_neg_backward (A B : Formula) :
    ⊢ (A.neg.or B.neg).imp (A.and B).neg

-- De Morgan Law 1 (Biconditional): ⊢ ¬(A ∧ B) ↔ (¬A ∨ ¬B)
theorem demorgan_conj_neg (A B : Formula) :
    ⊢ ((A.and B).neg.imp (A.neg.or B.neg)).and ((A.neg.or B.neg).imp (A.and B).neg)

-- De Morgan Law 2 (Forward): ⊢ ¬(A ∨ B) → (¬A ∧ ¬B)
theorem demorgan_disj_neg_forward (A B : Formula) :
    ⊢ (A.or B).neg.imp (A.neg.and B.neg)

-- De Morgan Law 2 (Backward): ⊢ (¬A ∧ ¬B) → ¬(A ∨ B)
theorem demorgan_disj_neg_backward (A B : Formula) :
    ⊢ (A.neg.and B.neg).imp (A.or B).neg

-- De Morgan Law 2 (Biconditional): ⊢ ¬(A ∨ B) ↔ (¬A ∧ ¬B)
theorem demorgan_disj_neg (A B : Formula) :
    ⊢ ((A.or B).neg.imp (A.neg.and B.neg)).and ((A.neg.and B.neg).imp (A.or B).neg)
```

**Proof Strategy Highlights**:

1. **Forward Direction (¬(A ∧ B) → (¬A ∨ ¬B))**:
   - Unfold definitions: `A ∧ B = ¬(A → ¬B)`, `¬A ∨ ¬B = ¬¬A → ¬B`
   - Goal becomes: `¬¬(A → ¬B) → (¬¬A → ¬B)`
   - Apply DNE to `(A → ¬B)`, then use b_combinator with DNE on A

2. **Backward Direction ((¬A ∨ ¬B) → ¬(A ∧ B))**:
   - Uses deduction theorem: prove `[A ∧ B, ¬¬A → ¬B] ⊢ ⊥`
   - Extract A and B from conjunction (lce_imp, rce_imp)
   - Apply DNI to A to get ¬¬A
   - From ¬¬A and hypothesis, derive ¬B
   - Contradiction with B from conjunction

**Insight**: The backward direction requires classical reasoning (deduction theorem with modal cases), demonstrating the power of the Logos deduction theorem.

---

### Finding 4.2: Implication and Disjunction Equivalences

**Source**: [Mathlib.Logic.Basic](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Basic.html)

Key equivalences extracted from WebFetch:

- **`imp_iff_not_or`**: `a → b ↔ ¬a ∨ b` - Implication as disjunction
- **`imp_iff_or_not`**: `b → a ↔ a ∨ ¬b` - Variant form
- **`not_imp`**: `¬(a → b) ↔ a ∧ ¬b` - Negated implication
- **`imp_or`**: `a → b ∨ c ↔ (a → b) ∨ (a → c)` - Distributivity

**Logos Definitions** (from `Formula.lean`):

```lean
-- Disjunction defined as: A ∨ B = ¬A → B
def or (φ ψ : Formula) : Formula := φ.neg.imp ψ

-- Conjunction defined as: A ∧ B = ¬(A → ¬B)
def and (φ ψ : Formula) : Formula := (φ.imp ψ.neg).neg
```

**Immediate Consequences**:
- `imp_iff_not_or` is **definitional** in Logos (A → B is literally ¬A → B when A = ¬C)
- `not_imp` follows from conjunction definition

**Potential Theorems to Derive** (not yet in codebase):
```lean
-- Material conditional: A → B is equivalent to ¬A ∨ B (when A atomic)
-- Already definitional for disjunction!

-- Implication distributivity over disjunction
theorem imp_or_dist (A B C : Formula) :
    ⊢ (A.imp (B.or C)).iff ((A.imp B).or (A.imp C))
```

---

## Section 5: Proof Strategy Insights for Axiomatic Derivations

### Finding 5.1: Combinator-Based Proof Construction

**Key Insight from Logos Codebase**: The existing proofs heavily use combinator theorems:

```lean
-- B combinator (composition): ⊢ (B → C) → (A → B) → (A → C)
theorem b_combinator {A B C : Formula} : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C))

-- Theorem flip (C combinator): ⊢ (A → B → C) → (B → A → C)
theorem theorem_flip {A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))

-- Identity: ⊢ A → A
theorem identity (A : Formula) : ⊢ A.imp A

-- Double negation introduction: ⊢ A → ¬¬A
theorem dni (φ : Formula) : ⊢ φ.imp φ.neg.neg

-- Implication transitivity: From ⊢ A → B and ⊢ B → C, derive ⊢ A → C
theorem imp_trans {A B C : Formula} (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C
```

**Proof Pattern**: Most complex theorems are built by:
1. Identifying the high-level logical structure
2. Breaking down into combinator applications (B, S/K, flip)
3. Using DNE/DNI for classical steps
4. Applying `imp_trans` for chaining

**Example from `rcp` (Reverse Contraposition)**:
```lean
-- Chain: B → ¬¬B → ¬¬A → A
-- Step 1: DNI for B
-- Step 2: Contrapose hypothesis using b_combinator + theorem_flip
-- Step 3: DNE for A
-- Step 4: Compose all using repeated b_combinator applications
```

**Mathlib Comparison**:
- Mathlib proofs use tactics (`intro`, `exact`, `apply`, `contrapose`)
- Logos proofs are **proof terms** built from combinator compositions
- This demonstrates **constructive proof objects** vs. **tactic scripts**

---

### Finding 5.2: Deduction Theorem as Meta-Level Combinator

**Key Discovery**: Logos implements a **full deduction theorem** in `Metalogic/DeductionTheorem.lean`:

```lean
theorem deduction_theorem (Γ : List Formula) (A B : Formula)
    (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B
```

**Significance**:
- Enables lifting context-based derivations to pure implications
- Powers the implication forms of conjunction/disjunction elimination
- Essential for classical reasoning patterns

**Mathlib Equivalent**: The tactic `intro h` in natural deduction, but at the **theorem level** rather than tactic level.

**Usage Pattern**:
```lean
-- From context-based derivation
have h_ctx : [A ∧ B] ⊢ A := lce A B

-- Lift to implication form
have h_imp : ⊢ (A ∧ B) → A := deduction_theorem [] (A ∧ B) A h_ctx
```

**Insight**: This is a **meta-logical** tool that Mathlib doesn't need (because natural deduction has intro rules), but is crucial for Hilbert systems.

---

### Finding 5.3: Classical Merge Pattern for Case Analysis

**Finding**: The `classical_merge` theorem provides case analysis in Hilbert calculus:

```lean
theorem classical_merge (P Q : Formula) : ⊢ (P.imp Q).imp ((P.neg.imp Q).imp Q)
```

**Proof Construction**:
1. Build `contradiction_intro`: `⊢ (A → B) → ((A → ¬B) → ¬A)`
2. Instantiate with `A = ¬Q`, `B = ¬P` to get: `(¬Q → ¬P) → ((¬Q → ¬¬P) → ¬¬Q)`
3. Use `contrapose_thm` to transform `(P → Q)` and `(¬P → Q)` into `(¬Q → ¬P)` and `(¬Q → ¬¬P)`
4. Apply DNE to get Q

**Mathlib Equivalent**: `Or.elim` or case analysis tactics.

**Usage**: Enables reasoning with LEM without directly invoking `lem` theorem.

**Insight**: This pattern could be automated into a `cases` tactic for Logos.

---

### Finding 5.4: Negation Manipulation via DNI/DNE

**Pattern Discovered**: Most proofs involving negation follow this workflow:

1. **Introduce double negation** via DNI (`theorem_app1`)
2. **Manipulate implications** at the ¬¬ level (more uniform structure)
3. **Eliminate double negation** via DNE at the end

**Example from LCE (Left Conjunction Elimination)**:
```lean
-- Goal: From [(A → ¬B).neg], derive A
-- Step 1: Show A.neg → (A → B.neg) via EFQ
-- Step 2: Contrapose to get (A → B.neg).neg → A.neg.neg
-- Step 3: Apply DNE to get A
```

**Mathlib Comparison**:
- Mathlib uses `push_neg` tactic to normalize negations
- Logos manually composes DNI/DNE with combinators

**Potential Automation**: Implement `push_neg` tactic for Logos using DNI/DNE theorems.

---

## Section 6: Theorem Coverage Analysis

### Finding 6.1: Current Implementation Status

**Phase 1 Complete** (8/8 theorems proven):
1. ✅ **ECQ** (Ex Contradictione Quodlibet): `[A, ¬A] ⊢ B`
2. ✅ **RAA** (Reductio ad Absurdum): `⊢ A → (¬A → B)`
3. ✅ **EFQ** (Ex Falso Quodlibet): `⊢ ¬A → (A → B)`
4. ✅ **LDI** (Left Disjunction Introduction): `[A] ⊢ A ∨ B`
5. ✅ **RDI** (Right Disjunction Introduction): `[B] ⊢ A ∨ B`
6. ✅ **RCP** (Reverse Contraposition): `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)`
7. ✅ **LCE** (Left Conjunction Elimination): `[A ∧ B] ⊢ A`
8. ✅ **RCE** (Right Conjunction Elimination): `[A ∧ B] ⊢ B`

**Additional Theorems Implemented**:
- ✅ `lce_imp`, `rce_imp` (implication forms using deduction theorem)
- ✅ `classical_merge` (case analysis)
- ✅ `iff_intro`, `iff_elim_left`, `iff_elim_right` (biconditional reasoning)
- ✅ `contrapose_imp`, `contrapose_iff` (contraposition infrastructure)
- ✅ De Morgan laws (4 forward/backward + 2 biconditionals = 6 theorems)
- ✅ `lem` (Law of Excluded Middle)

**TODO Tasks 21-29 Status**:
- **Tasks 21-25**: COMPLETE (RAA, EFQ, LCE, RCE, LDI, RDI, RCP all proven)
- **Tasks 26-29**: Need verification against TODO descriptions

---

### Finding 6.2: Mathlib Theorems Not Yet in Logos

**Potential Future Work** (from Mathlib.Logic.Basic):

1. **Negation Simplifications**:
   - `not_not_not`: `¬¬¬a ↔ ¬a` - Triple negation collapses
   - `not_congr`: `(a ↔ b) → (¬a ↔ ¬b)` - Negation congruence

2. **Implication Theorems**:
   - `imp_self`: `(a → a) ↔ True` - Trivial implication
   - `imp.swap`: `(a → b → c) ↔ (b → a → c)` - Already have as `theorem_flip`
   - `Peirce`: `((a → b) → a) → a` - Peirce's law

3. **Mixed Connective Laws**:
   - `and_or_imp`: `a ∧ b ∨ (a → c) ↔ a → b ∨ c` - Distributivity variant
   - `or_imp`: `a ∨ b → c ↔ (a → c) ∧ (b → c)` - Disjunction elimination as implication

4. **Distributivity**:
   - Conjunction over disjunction: `a ∧ (b ∨ c) ↔ (a ∧ b) ∨ (a ∧ c)`
   - Disjunction over conjunction: `a ∨ (b ∧ c) ↔ (a ∨ b) ∧ (a ∨ c)`

**Note**: Many of these may be derivable from existing Logos theorems but not yet proven.

---

### Finding 6.3: Gap Analysis - Missing Mathlib Patterns

**Identified Gaps**:

1. **Disjunction Elimination**: No direct `Or.elim` equivalent (can use `classical_merge` pattern)
2. **Proof by Cases Tactic**: No automation for case splitting (manual classical_merge application)
3. **Push Neg Normalization**: No automatic negation normalization (manual DNI/DNE composition)
4. **Decidability Infrastructure**: Mathlib has `Decidable` type class; Logos uses classical logic exclusively

**Why These Gaps Exist**:
- Logos uses **Hilbert-style calculus** (axioms + inference rules) vs. Mathlib's **natural deduction**
- Gaps are **architectural differences**, not missing functionality
- Classical reasoning is **axiomatic** (DNE axiom) rather than **derived** (from LEM)

**Workarounds**:
- Disjunction elimination: Use `classical_merge` with appropriate instantiations
- Case analysis: Build proof terms explicitly using combinators
- Negation: Use DNI/DNE composition patterns

---

## Section 7: Recommendations

### Recommendation 1: Update TODO Status

**Action**: Update `TODO.md` Tasks 21-25 to **COMPLETE** status.

**Justification**: All theorems are fully proven in `Propositional.lean`:
- Task 21 (RAA): `theorem raa` ✅
- Task 22 (EFQ): `theorem efq` ✅
- Task 23 (LCE/RCE): `theorem lce`, `theorem rce` ✅
- Task 24 (LDI/RDI): `theorem ldi`, `theorem rdi` ✅
- Task 25 (RCP): `theorem rcp` ✅

**Files to Update**:
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md`
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

---

### Recommendation 2: Verify TODO Tasks 26-29

**Action**: Review TODO descriptions for Tasks 26-29 to determine completion status.

**Current Knowledge**:
- Tasks 21-25: Confirmed COMPLETE
- Tasks 26-29: Not yet reviewed against TODO specs

**Next Steps**:
1. Read TODO.md lines 150-250 to get Tasks 26-29 descriptions
2. Check if corresponding theorems exist in `Propositional.lean`
3. Update task status accordingly

---

### Recommendation 3: Implement Disjunction Elimination (Future Work)

**Proposed Theorem**:
```lean
-- Disjunction Elimination: From A ∨ B, (A → C), and (B → C), derive C
theorem disj_elim (A B C : Formula)
    (h_disj : Γ ⊢ A.or B)
    (h_left : Γ ⊢ A.imp C)
    (h_right : Γ ⊢ B.imp C) :
    Γ ⊢ C
```

**Proof Strategy**:
1. Unfold `A ∨ B` as `¬A → B`
2. From `¬A → B` and `B → C`, derive `¬A → C` via b_combinator
3. From `A → C` and `¬A → C`, use `classical_merge` to get `C`

**Mathlib Parallel**: `Or.elim` in natural deduction.

**Impact**: Enables natural proof-by-cases patterns in Hilbert calculus.

---

### Recommendation 4: Create Propositional Tactic Suite

**Proposed Tactics** (inspired by Mathlib):

1. **`contrapose`**: Apply `contrapose_imp` theorem automatically
2. **`cases_on h`**: Apply `classical_merge` for case analysis on disjunction `h`
3. **`dne`**: Apply double negation elimination at goal
4. **`dni`**: Apply double negation introduction to hypothesis

**Implementation Pattern**:
```lean
-- Contrapose tactic
macro "contrapose" : tactic =>
  `(tactic| apply contrapose_imp)

-- DNE tactic
macro "dne" : tactic =>
  `(tactic| apply Axiom.double_negation; assumption)
```

**Impact**:
- Reduce proof term complexity
- Make Hilbert-style proofs more readable
- Bridge gap between Mathlib tactic style and Logos term style

---

### Recommendation 5: Document Combinator Proof Patterns

**Action**: Create a new documentation file `COMBINATOR_PROOF_PATTERNS.md` cataloging:

1. **Basic Combinators**: K (prop_s), S (prop_k), B (b_combinator), C (theorem_flip), I (identity)
2. **Derived Combinators**: dni, imp_trans, pairing
3. **Common Composition Patterns**:
   - Contraposition via B + C
   - Chain of implications via repeated B
   - Argument swapping via C
4. **Classical Reasoning Patterns**:
   - DNE elimination via axiom
   - DNI introduction via theorem_app1
   - Case analysis via classical_merge

**Benefit**:
- Preserve institutional knowledge of proof construction
- Enable future contributors to understand proof patterns
- Facilitate tactic development

---

### Recommendation 6: Benchmark Against Mathlib Coverage

**Proposed Analysis**:
1. Extract all theorems from `Mathlib.Logic.Basic` (approximately 200+ theorems)
2. Categorize by:
   - Propositional (∧, ∨, →, ¬, ↔)
   - Quantifiers (∀, ∃)
   - Decidability
   - Classical principles
3. Identify which are:
   - **Derivable** in Logos (via existing axioms/theorems)
   - **Definitional** (true by formula definitions)
   - **Not applicable** (decidability, natural deduction specific)
4. Create coverage report: `MATHLIB_COVERAGE_REPORT.md`

**Goal**: Establish completeness of Logos propositional fragment relative to Mathlib.

**Expected Outcome**: 90%+ coverage for classical propositional logic theorems.

---

## Appendix A: Key Theorem Signatures

### A.1 Mathlib.Logic.Basic Theorems

**Contraposition and Negation**:
```lean
-- Mathlib signatures
theorem not_imp_not : ¬a → ¬b ↔ b → a
theorem Not.imp_symm : (¬a → b) → ¬b → a
theorem not_imp_comm : ¬a → b ↔ ¬b → a
theorem mt : (a → b) → ¬b → ¬a
theorem not_not_intro : p → ¬¬p
```

**De Morgan Laws**:
```lean
theorem not_and_or : ¬(a ∧ b) ↔ ¬a ∨ ¬b
theorem or_iff_not_and_not : a ∨ b ↔ ¬(¬a ∧ ¬b)
theorem and_iff_not_or_not : a ∧ b ↔ ¬(¬a ∨ ¬b)
```

**Implication Equivalences**:
```lean
theorem imp_iff_not_or : a → b ↔ ¬a ∨ b
theorem not_imp : ¬(a → b) ↔ a ∧ ¬b
theorem imp_or : a → b ∨ c ↔ (a → b) ∨ (a → c)
```

**Classical Reasoning**:
```lean
theorem Classical.em : p ∨ ¬p
theorem Classical.byContradiction : (¬p → False) → p
theorem peirce : ((a → b) → a) → a
```

---

### A.2 Logos Propositional.lean Theorems

**Phase 1: Negation and Contradiction**:
```lean
theorem lem (A : Formula) : ⊢ A.or A.neg
theorem ecq (A B : Formula) : [A, A.neg] ⊢ B
theorem raa (A B : Formula) : ⊢ A.imp (A.neg.imp B)
theorem efq (A B : Formula) : ⊢ A.neg.imp (A.imp B)
```

**Phase 1: Conjunction and Disjunction**:
```lean
theorem lce (A B : Formula) : [A.and B] ⊢ A
theorem rce (A B : Formula) : [A.and B] ⊢ B
theorem ldi (A B : Formula) : [A] ⊢ A.or B
theorem rdi (A B : Formula) : [B] ⊢ A.or B
theorem lce_imp (A B : Formula) : ⊢ (A.and B).imp A
theorem rce_imp (A B : Formula) : ⊢ (A.and B).imp B
```

**Phase 1: Contraposition**:
```lean
theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A
theorem contrapose_imp (A B : Formula) : ⊢ (A.imp B).imp (B.neg.imp A.neg)
```

**Phase 3: Classical Reasoning**:
```lean
theorem classical_merge (P Q : Formula) : ⊢ (P.imp Q).imp ((P.neg.imp Q).imp Q)
theorem iff_intro (A B : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp A) :
    ⊢ (A.imp B).and (B.imp A)
theorem iff_elim_left (A B : Formula) : [((A.imp B).and (B.imp A)), A] ⊢ B
theorem iff_elim_right (A B : Formula) : [((A.imp B).and (B.imp A)), B] ⊢ A
theorem contrapose_iff (A B : Formula) (h : ⊢ (A.imp B).and (B.imp A)) :
    ⊢ (A.neg.imp B.neg).and (B.neg.imp A.neg)
```

**Phase 4: De Morgan Laws**:
```lean
theorem demorgan_conj_neg_forward (A B : Formula) : ⊢ (A.and B).neg.imp (A.neg.or B.neg)
theorem demorgan_conj_neg_backward (A B : Formula) : ⊢ (A.neg.or B.neg).imp (A.and B).neg
theorem demorgan_conj_neg (A B : Formula) :
    ⊢ ((A.and B).neg.imp (A.neg.or B.neg)).and ((A.neg.or B.neg).imp (A.and B).neg)
theorem demorgan_disj_neg_forward (A B : Formula) : ⊢ (A.or B).neg.imp (A.neg.and B.neg)
theorem demorgan_disj_neg_backward (A B : Formula) : ⊢ (A.neg.and B.neg).imp (A.or B).neg
theorem demorgan_disj_neg (A B : Formula) :
    ⊢ ((A.or B).neg.imp (A.neg.and B.neg)).and ((A.neg.and B.neg).imp (A.or B).neg)
```

---

## Appendix B: Sources

### Primary Documentation
- [Theorem Proving in Lean 4 - Propositions and Proofs](https://lean-lang.org/theorem_proving_in_lean4/propositions_and_proofs.html)
- [Mathematics in Lean - Logic](https://leanprover-community.github.io/mathematics_in_lean/C03_Logic.html)
- [Logic and Proof - Propositional Logic in Lean](https://leanprover-community.github.io/logic_and_proof/propositional_logic_in_lean.html)
- [Logic and Proof - Classical Reasoning](https://leanprover-community.github.io/logic_and_proof/classical_reasoning.html)

### API Documentation
- [Mathlib.Logic.Basic](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Basic.html)
- [Mathlib.Tactic.Contrapose](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Tactic/Contrapose.html)
- [Lean 4 Init.Core](https://github.com/leanprover/lean4/blob/master/src/Init/Core.lean)
- [Lean 4 Logical Connectives](https://lean-lang.org/doc/reference/4.21.0-rc3/Basic-Propositions/Logical-Connectives/)

### Reference Materials
- [Mathlib naming conventions](https://leanprover-community.github.io/contribute/naming.html)
- [Reductio ad Absurdum - Wikipedia](https://en.wikipedia.org/wiki/Reductio_ad_absurdum)
- [Reductio ad Absurdum - Internet Encyclopedia of Philosophy](https://iep.utm.edu/reductio/)
- [Combinatory Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-combinatory/)

---

## Revision History

- **2025-12-09**: Initial research report created
- **Researcher**: Claude Sonnet 4.5 (Lean 4 research specialist)
- **Output Path**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/061_propositional_theorem_derivations/reports/001-mathlib-theorems.md`
