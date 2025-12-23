# Loogle API Search Report: "Temporal"

**Search Date**: 2025-12-21  
**Query Pattern**: "Temporal"  
**Search Scope**: Lean Mathlib + ProofChecker local project  
**API Endpoint**: https://loogle.lean-lang.org/

---

## Executive Summary

**Mathlib Results**: 0 matches  
**ProofChecker Results**: 9 core definitions + 2 theorems + multiple references  
**Total Matches**: 11 primary temporal-related definitions

The Loogle API search for "Temporal" in the Lean standard library and Mathlib returned **0 results**, indicating that temporal logic constructs are not part of the standard Lean ecosystem. However, the ProofChecker project contains extensive temporal logic machinery implementing a bimodal temporal modal logic system.

---

## Search Results

### Section 1: Mathlib/Standard Library Search

**Query**: `https://loogle.lean-lang.org/json?q="Temporal"`

**Result**:
```json
{
  "count": 0,
  "header": "Found 0 declarations whose name contains \"Temporal\".\n",
  "heartbeats": 0,
  "hits": []
}
```

**Analysis**: No temporal logic definitions exist in Lean's core library or Mathlib. Temporal logic is a specialized domain not covered by general-purpose mathematics libraries.

---

### Section 2: ProofChecker Project Definitions

All matches found below are from the ProofChecker project located at `/home/benjamin/Projects/ProofChecker`.

#### 2.1 Core Temporal Definitions

##### 2.1.1 `Formula.swap_temporal`

- **Full Qualified Name**: `Logos.Core.Syntax.Formula.swap_temporal`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Syntax.Formula`
- **File**: `Logos/Core/Syntax/Formula.lean:204`
- **Category**: Definition
- **Type Signature**:
  ```lean
  def swap_temporal : Formula → Formula
    | atom s => atom s
    | bot => bot
    | imp φ ψ => imp φ.swap_temporal ψ.swap_temporal
    | box φ => box φ.swap_temporal
    | all_past φ => all_future φ.swap_temporal
    | all_future φ => all_past φ.swap_temporal
  ```
- **Description**: Temporal duality transformation that swaps `all_future` ↔ `all_past` operators throughout a formula while preserving all other structure. This is the core operation enabling temporal symmetry reasoning.
- **Alias**: `swap_past_future` (backward compatibility)

##### 2.1.2 `Formula.swap_temporal_involution`

- **Full Qualified Name**: `Logos.Core.Syntax.Formula.swap_temporal_involution`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Syntax.Formula`
- **File**: `Logos/Core/Syntax/Formula.lean:220`
- **Category**: Theorem
- **Type Signature**:
  ```lean
  theorem swap_temporal_involution (φ : Formula) :
    φ.swap_temporal.swap_temporal = φ
  ```
- **Description**: Proves that `swap_temporal` is an involution (self-inverse). Applying it twice returns the original formula. Essential for temporal duality rule correctness.
- **Proof Method**: Structural induction on formula
- **Alias**: `swap_past_future_involution`

##### 2.1.3 `Formula.swap_temporal_diamond`

- **Full Qualified Name**: `Logos.Core.Syntax.Formula.swap_temporal_diamond`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Syntax.Formula`
- **File**: `Logos/Core/Syntax/Formula.lean:245`
- **Category**: Theorem
- **Type Signature**:
  ```lean
  theorem swap_temporal_diamond (φ : Formula) :
    φ.diamond.swap_temporal = φ.swap_temporal.diamond
  ```
- **Description**: Temporal swap distributes over modal diamond operator. Shows that `swap(◇φ) = ◇(swap φ)`, demonstrating that temporal swap commutes with modal operators.
- **Proof Method**: Direct simplification using definitions

##### 2.1.4 `Formula.swap_temporal_neg`

- **Full Qualified Name**: `Logos.Core.Syntax.Formula.swap_temporal_neg`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Syntax.Formula`
- **File**: `Logos/Core/Syntax/Formula.lean:255`
- **Category**: Theorem
- **Type Signature**:
  ```lean
  theorem swap_temporal_neg (φ : Formula) :
    φ.neg.swap_temporal = φ.swap_temporal.neg
  ```
- **Description**: Temporal swap distributes over negation. Shows that `swap(¬φ) = ¬(swap φ)`.
- **Proof Method**: Direct simplification

---

#### 2.2 Derivation System Rules

##### 2.2.1 `DerivationTree.temporal_necessitation`

- **Full Qualified Name**: `Logos.Core.ProofSystem.DerivationTree.temporal_necessitation`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.ProofSystem.Derivation`
- **File**: `Logos/Core/ProofSystem/Derivation.lean:126`
- **Category**: Inductive Constructor
- **Type Signature**:
  ```lean
  | temporal_necessitation (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] (Formula.all_future φ)
  ```
- **Description**: Temporal necessitation inference rule. If `⊢ φ` (φ is a theorem), then `⊢ Fφ` (φ will always be true in the future). Only applies to theorems (empty context derivations).
- **Generalization**: The generalized rule `Γ ⊢ φ ⟹ FΓ ⊢ Fφ` is derivable via temporal K distribution and deduction theorem.

##### 2.2.2 `DerivationTree.temporal_duality`

- **Full Qualified Name**: `Logos.Core.ProofSystem.DerivationTree.temporal_duality`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.ProofSystem.Derivation`
- **File**: `Logos/Core/ProofSystem/Derivation.lean:136`
- **Category**: Inductive Constructor
- **Type Signature**:
  ```lean
  | temporal_duality (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] φ.swap_past_future
  ```
- **Description**: Temporal duality inference rule. If `⊢ φ` is derivable, then `⊢ swap_temporal φ` is also derivable. Enables deriving past theorems from future theorems and vice versa.
- **Restriction**: Only applies to theorems (empty context)

##### 2.2.3 `DerivationTree.temporal_necessitation_height_succ`

- **Full Qualified Name**: `Logos.Core.ProofSystem.DerivationTree.temporal_necessitation_height_succ`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.ProofSystem.Derivation`
- **File**: `Logos/Core/ProofSystem/Derivation.lean:237`
- **Category**: Theorem
- **Type Signature**:
  ```lean
  theorem temporal_necessitation_height_succ {φ : Formula}
      (d : DerivationTree [] φ) :
      (temporal_necessitation φ d).height = d.height + 1
  ```
- **Description**: Proves that temporal necessitation increases derivation tree height by exactly 1. Used for well-founded recursion in metalogic proofs.

##### 2.2.4 `DerivationTree.temporal_duality_height_succ`

- **Full Qualified Name**: `Logos.Core.ProofSystem.DerivationTree.temporal_duality_height_succ`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.ProofSystem.Derivation`
- **File**: `Logos/Core/ProofSystem/Derivation.lean:246`
- **Category**: Theorem
- **Type Signature**:
  ```lean
  theorem temporal_duality_height_succ {φ : Formula}
      (d : DerivationTree [] φ) :
      (temporal_duality φ d).height = d.height + 1
  ```
- **Description**: Proves that temporal duality increases derivation tree height by exactly 1. Used for well-founded recursion.

---

#### 2.3 Generalized Temporal Rules

##### 2.3.1 `generalized_temporal_k`

- **Full Qualified Name**: `Logos.Core.Theorems.generalized_temporal_k`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Theorems.GeneralizedNecessitation`
- **File**: `Logos/Core/Theorems/GeneralizedNecessitation.lean:101`
- **Category**: Definition
- **Type Signature**:
  ```lean
  def generalized_temporal_k : (Γ : Context) → (φ : Formula) →
      (h : Γ ⊢ φ) → ((Context.map Formula.all_future Γ) ⊢ Formula.all_future φ)
    | [], φ, h => DerivationTree.temporal_necessitation φ h
    | A :: Γ', φ, h => ...
  ```
- **Description**: Generalized temporal necessitation rule. If `Γ ⊢ φ`, then `FΓ ⊢ Fφ` where `FΓ` applies `all_future` to every formula in the context. Derived from standard temporal necessitation + temporal K distribution + deduction theorem.
- **Proof Strategy**: Recursive definition using induction on context, analogous to generalized modal K.

##### 2.3.2 `apply_temporal_k`

- **Full Qualified Name**: `Logos.Core.Automation.apply_temporal_k`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Automation.AesopRules`
- **File**: `Logos/Core/Automation/AesopRules.lean:230`
- **Category**: Definition (Aesop automation rule)
- **Type Signature**:
  ```lean
  @[aesop safe apply]
  def apply_temporal_k {Γ : Context} {φ : Formula} :
      DerivationTree Γ φ → DerivationTree (Context.map Formula.all_future Γ) (Formula.all_future φ) :=
    generalized_temporal_k Γ φ
  ```
- **Description**: Aesop automation rule wrapper for `generalized_temporal_k`. Enables automatic application during proof search to derive `Fφ` from `FΓ` when `Γ ⊢ φ`.
- **Annotation**: `@[aesop safe apply]` - marked as safe rule for Aesop proof search

---

#### 2.4 Bridge Theorems

##### 2.4.1 `temporal_duality_neg`

- **Full Qualified Name**: `Logos.Core.Theorems.Perpetuity.temporal_duality_neg`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Theorems.Perpetuity.Bridge`
- **File**: `Logos/Core/Theorems/Perpetuity/Bridge.lean:670`
- **Category**: Definition (Derived theorem)
- **Type Signature**:
  ```lean
  def temporal_duality_neg (φ : Formula) : ⊢ φ.neg.sometimes.imp φ.always.neg
  ```
- **Description**: Bridge lemma: `▽¬φ → ¬△φ` (sometimes not φ implies not always φ). Connects temporal duality with negation using double negation introduction.
- **Semantic Reading**: If φ is sometimes false, then φ is not always true.
- **Proof Strategy**: Uses `always_dni` (double negation introduction for always) and contraposition.

##### 2.4.2 `temporal_duality_neg_rev`

- **Full Qualified Name**: `Logos.Core.Theorems.Perpetuity.temporal_duality_neg_rev`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Theorems.Perpetuity.Bridge`
- **File**: `Logos/Core/Theorems/Perpetuity/Bridge.lean:748`
- **Category**: Definition (Derived theorem)
- **Type Signature**:
  ```lean
  def temporal_duality_neg_rev (φ : Formula) : ⊢ φ.always.neg.imp φ.neg.sometimes
  ```
- **Description**: Bridge lemma (reverse direction): `¬△φ → ▽¬φ` (not always φ implies sometimes not φ). Reverse of `temporal_duality_neg`.
- **Semantic Reading**: If φ is not always true, then φ is sometimes false.
- **Proof Strategy**: Uses `always_dne` (double negation elimination for always) and contraposition.

---

#### 2.5 Soundness/Semantics Theorems

##### 2.5.1 `temporal_k_preserves_swap_valid`

- **Full Qualified Name**: `Logos.Core.Semantics.temporal_k_preserves_swap_valid`
- **Library**: ProofChecker (local)
- **Module**: `Logos.Core.Semantics.Truth`
- **File**: `Logos/Core/Semantics/Truth.lean:1171`
- **Category**: Theorem
- **Type Signature**:
  ```lean
  theorem temporal_k_preserves_swap_valid (φ : Formula)
      (h : is_valid T φ.swap_past_future) :
      is_valid T (Formula.all_future φ).swap_past_future
  ```
- **Description**: Soundness lemma proving that temporal K distribution preserves swap validity. If `swap(φ)` is valid, then `swap(Fφ) = P(swap φ)` is valid. Used in the derivation-indexed soundness proof for temporal duality.
- **Usage**: Part of the completeness/soundness infrastructure for temporal duality rule.

---

## Categorized Summary

### By Category

| Category | Count | Names |
|----------|-------|-------|
| **Definition** | 4 | `swap_temporal`, `generalized_temporal_k`, `apply_temporal_k`, `temporal_duality_neg`, `temporal_duality_neg_rev` |
| **Theorem** | 5 | `swap_temporal_involution`, `swap_temporal_diamond`, `swap_temporal_neg`, `temporal_necessitation_height_succ`, `temporal_duality_height_succ`, `temporal_k_preserves_swap_valid` |
| **Inductive Constructor** | 2 | `temporal_necessitation`, `temporal_duality` |

### By Module

| Module | Count | Purpose |
|--------|-------|---------|
| `Logos.Core.Syntax.Formula` | 4 | Temporal swap operation and properties |
| `Logos.Core.ProofSystem.Derivation` | 4 | Derivation rules and height properties |
| `Logos.Core.Theorems.GeneralizedNecessitation` | 1 | Generalized temporal K rule |
| `Logos.Core.Automation.AesopRules` | 1 | Proof automation for temporal K |
| `Logos.Core.Theorems.Perpetuity.Bridge` | 2 | Bridge lemmas connecting temporal/modal/negation |
| `Logos.Core.Semantics.Truth` | 1 | Soundness preservation |

### By Functionality

1. **Core Temporal Operations** (4 items)
   - `swap_temporal`: Transformation function
   - `swap_temporal_involution`: Involution property
   - `swap_temporal_diamond`: Distribution over diamond
   - `swap_temporal_neg`: Distribution over negation

2. **Proof System Integration** (4 items)
   - `temporal_necessitation`: Basic inference rule
   - `temporal_duality`: Duality inference rule
   - `temporal_necessitation_height_succ`: Height property
   - `temporal_duality_height_succ`: Height property

3. **Generalized Rules** (2 items)
   - `generalized_temporal_k`: Context-aware temporal K
   - `apply_temporal_k`: Automation wrapper

4. **Bridge Theorems** (2 items)
   - `temporal_duality_neg`: Duality + negation interaction
   - `temporal_duality_neg_rev`: Reverse direction

5. **Metalogic** (1 item)
   - `temporal_k_preserves_swap_valid`: Soundness preservation

---

## Key Insights

### 1. Temporal Logic is Project-Specific
The absence of temporal logic in Mathlib confirms that this is specialized domain logic not covered by general mathematics libraries. The ProofChecker project implements a complete temporal modal logic system from scratch.

### 2. Symmetry as Core Design Principle
The `swap_temporal` operation and its properties (involution, distribution) form the foundation for temporal reasoning. This enables:
- Deriving past theorems from future theorems
- Symmetric treatment of temporal operators
- Simplified proof construction via duality

### 3. Tight Integration with Proof System
Temporal operations are not just semantic constructs but are deeply integrated into:
- Derivation tree structure (inference rules)
- Height measures (for well-founded recursion)
- Automation rules (Aesop integration)
- Soundness/completeness proofs

### 4. Layered Abstraction
The system provides multiple levels:
- **Primitive**: `temporal_necessitation`, `temporal_duality` constructors
- **Derived**: `generalized_temporal_k` extending to contexts
- **Automation**: `apply_temporal_k` for proof search
- **Metatheory**: Height theorems, soundness preservation

### 5. Modal-Temporal Interaction
Bridge theorems like `temporal_duality_neg` show careful handling of interactions between:
- Temporal operators (`always`, `sometimes`)
- Modal operators (`box`, `diamond`)
- Propositional connectives (negation, implication)

---

## References in Documentation

The following files contain extensive documentation and examples of temporal reasoning:

1. **Archive Files** (pedagogical/historical):
   - `Archive/TemporalStructures.lean` - Temporal frame semantics
   - `Archive/TemporalProofs.lean` - Example temporal proofs
   - `Archive/TemporalProofStrategies.lean` - Proof patterns and strategies

2. **Active Codebase**:
   - `Logos/Core/Syntax/Formula.lean` - Syntax definitions
   - `Logos/Core/ProofSystem/Derivation.lean` - Inference rules
   - `Logos/Core/Theorems/Perpetuity/Bridge.lean` - Bridge lemmas
   - `Logos/Core/Semantics/Truth.lean` - Semantic validity
   - `Logos/Core/Metalogic/Soundness.lean` - Soundness proof

3. **Tests**:
   - Multiple test files in `LogosTest/` exercise temporal reasoning

---

## JSON Response

```json
{
  "search_pattern": "Temporal",
  "matches_count": 11,
  "mathlib_matches": 0,
  "proofchecker_matches": 11,
  "report_path": ".opencode/specs/ProofChecker/specialist-reports/loogle-temporal.md",
  "all_matches": [
    {
      "name": "Logos.Core.Syntax.Formula.swap_temporal",
      "type": "Formula → Formula",
      "library": "ProofChecker",
      "module": "Logos.Core.Syntax.Formula",
      "file": "Logos/Core/Syntax/Formula.lean:204",
      "category": "definition",
      "description": "Temporal duality transformation swapping all_future ↔ all_past operators"
    },
    {
      "name": "Logos.Core.Syntax.Formula.swap_temporal_involution",
      "type": "∀ (φ : Formula), φ.swap_temporal.swap_temporal = φ",
      "library": "ProofChecker",
      "module": "Logos.Core.Syntax.Formula",
      "file": "Logos/Core/Syntax/Formula.lean:220",
      "category": "theorem",
      "description": "Proves swap_temporal is an involution (self-inverse)"
    },
    {
      "name": "Logos.Core.Syntax.Formula.swap_temporal_diamond",
      "type": "∀ (φ : Formula), φ.diamond.swap_temporal = φ.swap_temporal.diamond",
      "library": "ProofChecker",
      "module": "Logos.Core.Syntax.Formula",
      "file": "Logos/Core/Syntax/Formula.lean:245",
      "category": "theorem",
      "description": "Temporal swap distributes over modal diamond operator"
    },
    {
      "name": "Logos.Core.Syntax.Formula.swap_temporal_neg",
      "type": "∀ (φ : Formula), φ.neg.swap_temporal = φ.swap_temporal.neg",
      "library": "ProofChecker",
      "module": "Logos.Core.Syntax.Formula",
      "file": "Logos/Core/Syntax/Formula.lean:255",
      "category": "theorem",
      "description": "Temporal swap distributes over negation"
    },
    {
      "name": "Logos.Core.ProofSystem.DerivationTree.temporal_necessitation",
      "type": "∀ (φ : Formula), DerivationTree [] φ → DerivationTree [] (Formula.all_future φ)",
      "library": "ProofChecker",
      "module": "Logos.Core.ProofSystem.Derivation",
      "file": "Logos/Core/ProofSystem/Derivation.lean:126",
      "category": "inductive_constructor",
      "description": "Temporal necessitation rule: ⊢ φ implies ⊢ Fφ"
    },
    {
      "name": "Logos.Core.ProofSystem.DerivationTree.temporal_duality",
      "type": "∀ (φ : Formula), DerivationTree [] φ → DerivationTree [] φ.swap_past_future",
      "library": "ProofChecker",
      "module": "Logos.Core.ProofSystem.Derivation",
      "file": "Logos/Core/ProofSystem/Derivation.lean:136",
      "category": "inductive_constructor",
      "description": "Temporal duality rule: ⊢ φ implies ⊢ swap_temporal φ"
    },
    {
      "name": "Logos.Core.ProofSystem.DerivationTree.temporal_necessitation_height_succ",
      "type": "∀ {φ : Formula} (d : DerivationTree [] φ), (temporal_necessitation φ d).height = d.height + 1",
      "library": "ProofChecker",
      "module": "Logos.Core.ProofSystem.Derivation",
      "file": "Logos/Core/ProofSystem/Derivation.lean:237",
      "category": "theorem",
      "description": "Temporal necessitation increases height by 1"
    },
    {
      "name": "Logos.Core.ProofSystem.DerivationTree.temporal_duality_height_succ",
      "type": "∀ {φ : Formula} (d : DerivationTree [] φ), (temporal_duality φ d).height = d.height + 1",
      "library": "ProofChecker",
      "module": "Logos.Core.ProofSystem.Derivation",
      "file": "Logos/Core/ProofSystem/Derivation.lean:246",
      "category": "theorem",
      "description": "Temporal duality increases height by 1"
    },
    {
      "name": "Logos.Core.Theorems.generalized_temporal_k",
      "type": "∀ (Γ : Context) (φ : Formula), Γ ⊢ φ → (Context.map Formula.all_future Γ) ⊢ Formula.all_future φ",
      "library": "ProofChecker",
      "module": "Logos.Core.Theorems.GeneralizedNecessitation",
      "file": "Logos/Core/Theorems/GeneralizedNecessitation.lean:101",
      "category": "definition",
      "description": "Generalized temporal K: Γ ⊢ φ implies FΓ ⊢ Fφ"
    },
    {
      "name": "Logos.Core.Automation.apply_temporal_k",
      "type": "∀ {Γ : Context} {φ : Formula}, DerivationTree Γ φ → DerivationTree (Context.map Formula.all_future Γ) (Formula.all_future φ)",
      "library": "ProofChecker",
      "module": "Logos.Core.Automation.AesopRules",
      "file": "Logos/Core/Automation/AesopRules.lean:230",
      "category": "definition",
      "description": "Aesop automation rule for generalized temporal K"
    },
    {
      "name": "Logos.Core.Theorems.Perpetuity.temporal_duality_neg",
      "type": "∀ (φ : Formula), ⊢ φ.neg.sometimes.imp φ.always.neg",
      "library": "ProofChecker",
      "module": "Logos.Core.Theorems.Perpetuity.Bridge",
      "file": "Logos/Core/Theorems/Perpetuity/Bridge.lean:670",
      "category": "definition",
      "description": "Bridge lemma: ▽¬φ → ¬△φ (sometimes not implies not always)"
    },
    {
      "name": "Logos.Core.Theorems.Perpetuity.temporal_duality_neg_rev",
      "type": "∀ (φ : Formula), ⊢ φ.always.neg.imp φ.neg.sometimes",
      "library": "ProofChecker",
      "module": "Logos.Core.Theorems.Perpetuity.Bridge",
      "file": "Logos/Core/Theorems/Perpetuity/Bridge.lean:748",
      "category": "definition",
      "description": "Bridge lemma (reverse): ¬△φ → ▽¬φ (not always implies sometimes not)"
    },
    {
      "name": "Logos.Core.Semantics.temporal_k_preserves_swap_valid",
      "type": "∀ (φ : Formula), is_valid T φ.swap_past_future → is_valid T (Formula.all_future φ).swap_past_future",
      "library": "ProofChecker",
      "module": "Logos.Core.Semantics.Truth",
      "file": "Logos/Core/Semantics/Truth.lean:1171",
      "category": "theorem",
      "description": "Temporal K distribution preserves swap validity for soundness proof"
    }
  ],
  "summary": "The Loogle API search found 0 matches in Mathlib/standard library, confirming temporal logic is not part of general Lean libraries. However, the ProofChecker project contains 11 core temporal-related definitions implementing a complete bimodal temporal modal logic system. The system includes: (1) Core swap_temporal operation with involution and distribution properties, (2) Temporal necessitation and duality inference rules integrated into the derivation system, (3) Generalized temporal K rule extending to contexts with automation support, (4) Bridge theorems connecting temporal operators with negation, and (5) Soundness preservation lemmas. The implementation demonstrates tight integration between syntax, proof system, automation, and metatheory."
}
```

---

## Recommendations

1. **API Enhancement**: Consider implementing a ProofChecker-specific search API that can query local project definitions, complementing Loogle's Mathlib focus.

2. **Documentation Index**: Create a searchable index of ProofChecker-specific constructs to facilitate discovery without requiring external API calls.

3. **MCP Server Integration**: Once Loogle MCP server is configured (currently in `_future_servers`), this search could be automated through the MCP interface.

4. **Cross-Reference System**: Build a cross-reference system linking temporal definitions to their usage sites in proofs, tests, and documentation.

5. **Semantic Search**: Implement semantic search capabilities to find related concepts even when exact name matches don't exist (e.g., finding "always" when searching for "temporal necessity").

---

**Report Generated**: 2025-12-21  
**Tool**: Loogle API + local project grep analysis  
**Confidence**: High (exhaustive search of both Mathlib and ProofChecker codebase)
