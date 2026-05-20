# Teammate A Findings: Tactics and Metaprogramming Infrastructure

**Task**: 179 — Research Lean 4 best practices and infrastructure for tactics and derived theorems
**Angle**: Primary — implementation approaches and patterns for tactics/metaprogramming
**Date**: 2026-05-20

---

## Key Findings

### 1. Custom Simp Sets via `register_simp_attr` (High Confidence)

Lean 4 provides `register_simp_attr` for creating domain-specific simp sets that don't pollute the global `@[simp]` database. This is the single most impactful infrastructure improvement available.

**How it works**: Register a custom attribute name during initialization. Tag lemmas with that attribute. Use `simp [my_attr]` or `simp only [my_attr]` to invoke just those lemmas.

```lean
-- In a dedicated file: Automation/SimpSets.lean
import Lean
initialize registerSimpAttr `tm_simp "bimodal TM logic simplification lemmas"
initialize registerSimpAttr `tm_derive "derivation tree construction lemmas"
initialize registerSimpAttr `tm_ctx "context membership and manipulation lemmas"
```

**Candidate lemmas for `@[tm_simp]`**:
- Formula unfolding: `Formula.or`, `Formula.and`, `Formula.neg`, `Formula.diamond`, `Formula.iff` definitions
- Context membership: `List.mem` simplification for formula contexts
- Derivation tree shortcuts: identity, weakening trivial cases

**Candidate lemmas for `@[tm_derive]`**:
- `identity` (A → A)
- `imp_trans` (transitivity of implication)
- `b_combinator` (composition)
- `theorem_flip` (argument swap)
- `dni` / `double_negation` (double negation intro/elim)
- `pairing` (conjunction intro)
- `ecq`, `raa`, `efq` (negation/contradiction rules)
- `contraposition` / `contrapose_imp`

**Why this matters**: Currently the ~30 propositional theorems and ~10 combinator theorems in `Theorems/` are used by fully qualified name throughout the codebase (e.g., `Bimodal.Theorems.Combinators.b_combinator` in `BooleanStructure.lean:190`). Tagging them with `@[tm_derive]` enables `simp only [tm_derive]` to close routine derivation goals automatically.

### 2. Aesop Rule Set Redesign (Medium-High Confidence)

The current Aesop integration is deprecated (`AesopRules.lean` notes deprecation since 2026-01-17) due to proof reconstruction issues with `DerivationTree`. However, Aesop has matured significantly. The key insight from current documentation:

**The `constructors` and `cases` builders should be avoided for custom inductive types like `DerivationTree`** — these likely caused the reconstruction errors. Instead, use:

```lean
declare_aesop_rule_sets [TMLogic] (default := false)

-- Safe apply rules (won't backtrack)
@[aesop safe apply (rule_sets := [TMLogic])]
def derive_identity (Γ : Context) (A : Formula) : Γ ⊢ A.imp A := ...

-- Unsafe rules with success probability
@[aesop unsafe 90% apply (rule_sets := [TMLogic])]
def derive_axiom_mt (Γ : Context) (φ : Formula) : Γ ⊢ (φ.box).imp φ := ...

-- Norm rules for simplification during search
@[aesop norm simp (rule_sets := [TMLogic])]
theorem formula_or_def : Formula.or A B = (A.neg).imp B := ...
```

**Critical fix**: Set `(config := { enableSimp := false })` or `(config := { useSimpAll := false })` when calling Aesop on `DerivationTree` goals to avoid the reconstruction issues. The `apply` builder (not `constructors`) is the correct choice for manually-defined derivation rules.

### 3. Tactic Architecture: Three-Tier Design (High Confidence)

Based on analysis of the existing codebase and Lean 4 best practices, the tactic library should follow a three-tier design:

**Tier 1 — Macros** (simplest, for aliases and one-step rules):
```lean
-- These already exist and are well-designed:
macro "apply_axiom" : tactic => `(tactic| (apply DerivationTree.axiom; refine ?_))
macro "modal_t" : tactic => `(tactic| (apply DerivationTree.axiom; refine ?_))
```

**Tier 2 — Elaboration tactics** (for context-aware multi-step tactics):
```lean
-- New: derive combinator chains automatically
elab "tm_mp_chain" : tactic => do
  -- Search context for implications matching the goal
  -- Apply modus ponens chains automatically
  ...

-- New: context manipulation
elab "tm_weaken" terms:term,* : tactic => do
  -- Add formulas to context via weakening rule
  ...

elab "tm_deduction" : tactic => do
  -- Apply deduction theorem to transform Γ, A ⊢ B into Γ ⊢ A → B
  ...
```

**Tier 3 — Proof search** (existing `modal_search` family):
The current `ProofSearch.lean` (1384 lines) with IDDFS/BestFirst/BoundedDFS strategies is sophisticated and well-designed. The main improvement opportunity is integration with the simp-set infrastructure to make search more focused.

### 4. Missing Infrastructure: Derivation Combinators (High Confidence)

The project heavily uses a pattern of manually chaining `imp_trans`, `b_combinator`, `theorem_flip`, and `DerivationTree.modus_ponens` — visible throughout `Perpetuity/Bridge.lean` and `Metalogic/Algebraic/BooleanStructure.lean`. This pattern should be automated.

**Recommended: `calc`-style tactic for derivation chains**:

```lean
-- Current verbose pattern:
have step1 : ⊢ A.imp B := ...
have step2 : ⊢ B.imp C := ...
have step3 : ⊢ A.imp C := imp_trans step1 step2

-- Proposed: derivation calc block
example : ⊢ A.imp C := by
  tm_chain
    · exact step1  -- A → B
    · exact step2  -- B → C
```

Or more powerfully, a tactic that searches for `imp_trans` chains:

```lean
elab "tm_trans" : tactic => do
  -- Given goal ⊢ A.imp C
  -- Search hypotheses for B such that ⊢ A.imp B and ⊢ B.imp C exist
  -- Apply imp_trans automatically
  ...
```

### 5. FormalizedFormalLogic/Foundation Project Patterns (Medium Confidence)

The most mature Lean 4 modal logic formalization ([FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation)) provides instructive patterns:

- Separates `Meta/` directory for proof automation from core logic
- Uses a `Deduction` module structure similar to this project's `DerivationTree`
- Maintains "Zoo diagrams" for automated relationship visualization between proof systems
- Relies on Mathlib integration via a supplementary library (`Vospiel`)

Key architectural difference: that project formalizes multiple logics (K, S4, S5, GL, Grz, intuitionistic) with shared infrastructure. The ProofChecker project should similarly abstract common derivation patterns into reusable infrastructure that works across frame classes (Base, Dense, Discrete).

### 6. Lean 4 TacticM Best Practices (2025-2026) (High Confidence)

From the Lean 4 metaprogramming book and language reference:

**Always use `withMainContext`** before accessing local context:
```lean
elab "my_tactic" : tactic => withMainContext do
  let goal ← getMainGoal
  let goalType ← goal.getType
  let lctx ← getLCtx
  ...
```

**Use `liftMetaTactic`** to bridge `MetaM` and `TacticM`:
```lean
elab "my_tactic" : tactic =>
  liftMetaTactic fun mvarId => do
    let newGoals ← mvarId.apply (mkConst ``myLemma)
    return newGoals
```

**Use `Lean.Meta.isDefEq`** for matching (not structural equality):
```lean
if ← isDefEq declType goalType then ...
```

**Pattern matching on `Expr`** for goal discrimination:
```lean
match goalType with
| .app (.app (.const ``DerivationTree _) ctx) formula => ...
| _ => throwError "Expected derivability goal"
```

The existing project code in `Tactics.lean` already follows most of these patterns correctly (e.g., `mkOperatorKTactic` at line 289). The factory function pattern there is good practice.

### 7. Semantic Lemma Simp Set (Medium Confidence)

The `SoundnessLemmas.lean` file (2422 lines) contains many semantic lemmas that could benefit from simp-set tagging:

```lean
initialize registerSimpAttr `tm_sem "TM semantic truth and validity lemmas"
```

Candidate lemmas:
- `truth_at` unfolding lemmas in `Truth.lean`
- `bot_false`, `imp_iff`, `box_iff` — these are the workhorses of soundness proofs
- `valid_implies_valid_dense`, `valid_implies_valid_discrete` — frame class implications
- `time_shift_preserves_truth` — shift invariance

This would significantly reduce the verbosity of soundness proofs in `SoundnessLemmas.lean` and `Soundness.lean`.

---

## Recommended Approach

### Phase 1: Foundation (Low Risk, High Impact)

1. **Create `Automation/SimpSets.lean`** with `register_simp_attr` for `tm_simp`, `tm_derive`, `tm_ctx`, `tm_sem`
2. **Tag existing theorems** in `Combinators.lean` and `Propositional.lean` with `@[tm_derive]`
3. **Tag semantic lemmas** in `Truth.lean` and `Validity.lean` with `@[tm_sem]`
4. **Tag formula definition lemmas** with `@[tm_simp]` (or, unfolding)

### Phase 2: Derivation Automation (Medium Risk, High Impact)

5. **Create `tm_trans` tactic** for automatic `imp_trans` chaining
6. **Create `tm_mp` tactic** for automatic modus ponens with context search
7. **Create `tm_weaken` tactic** for context manipulation
8. **Create `tm_deduction` tactic** for deduction theorem application

### Phase 3: Aesop Rehabilitation (Medium Risk, Medium Impact)

9. **Redesign `TMLogic` Aesop rule set** using `apply` builder (not `constructors`)
10. **Test with `enableSimp := false`** to avoid reconstruction errors
11. **Benchmark against `modal_search`** for coverage and speed

### Phase 4: Integration (Low Risk)

12. **Update `tm_auto`/`modal_search`** to use simp sets as pre-processing
13. **Refactor `Bridge.lean`** (993 lines) using new tactics as proof-of-concept
14. **Document tactic usage** with examples in `Examples/`

---

## Evidence/Examples

### Example: Current vs. Improved Code

**Current** (`Perpetuity/Bridge.lean:248`):
```lean
have step := imp_trans lift_bot_b k_step_raw
```
This pattern repeats ~20 times in Bridge.lean alone, with manual intermediate `have` bindings.

**Improved** (with `tm_trans`):
```lean
exact by tm_trans  -- automatically finds the chain
```

**Current** (`BooleanStructure.lean:188-190`):
```lean
have h : ⊢ (ψ.imp χ).imp ((¬φ).imp ψ).imp ((¬φ).imp χ) :=
  Bimodal.Theorems.Combinators.b_combinator
```

**Improved** (with simp sets):
```lean
have h : ⊢ (ψ.imp χ).imp ((¬φ).imp ψ).imp ((¬φ).imp χ) := by
  simp only [tm_derive]
-- Or even better, if the goal can be closed:
exact by tm_auto
```

### Example: Custom Simp Set Registration

```lean
-- Automation/SimpSets.lean
import Lean

initialize Lean.Meta.registerSimpAttr `tm_simp
  "TM logic formula simplification lemmas"

initialize Lean.Meta.registerSimpAttr `tm_derive
  "TM derivation construction lemmas"

initialize Lean.Meta.registerSimpAttr `tm_ctx
  "TM context membership lemmas"

initialize Lean.Meta.registerSimpAttr `tm_sem
  "TM semantic truth and validity lemmas"
```

```lean
-- Theorems/Combinators.lean (modified)
@[tm_derive]
def identity (A : Formula) : ⊢ A.imp A := by ...

@[tm_derive]
def imp_trans {A B C : Formula} (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C := by ...

@[tm_derive]
def b_combinator {A B C : Formula} : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C)) := by ...
```

### Example: Aesop Rule Set (Revised)

```lean
-- Automation/AesopRules.lean (revised)
declare_aesop_rule_sets [TMLogic] (default := false)

-- Axiom application (safe — always correct when goal matches)
@[aesop safe apply (rule_sets := [TMLogic])]
theorem tm_axiom_mt (Γ : Context) (φ : Formula) :
    DerivationTree Γ ((φ.box).imp φ) :=
  DerivationTree.axiom Γ _ (Axiom.modal_t φ)

-- Modus ponens (unsafe — needs matching hypotheses)
@[aesop unsafe 80% apply (rule_sets := [TMLogic])]
theorem tm_mp (Γ : Context) (φ ψ : Formula)
    (h1 : DerivationTree Γ (φ.imp ψ)) (h2 : DerivationTree Γ φ) :
    DerivationTree Γ ψ :=
  DerivationTree.modus_ponens Γ φ ψ h1 h2

-- Assumption (safe — direct context lookup)
@[aesop safe apply (rule_sets := [TMLogic])]
theorem tm_assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) :
    DerivationTree Γ φ :=
  DerivationTree.assumption Γ φ h

-- Usage:
example (p : Formula) : ⊢ (p.box).imp p := by
  aesop (rule_sets := [TMLogic]) (config := { enableSimp := false })
```

---

## Confidence Levels

| Recommendation | Confidence | Rationale |
|---|---|---|
| Custom simp sets (`register_simp_attr`) | **High** | Official Lean 4 API, well-documented, zero-risk refactoring |
| Three-tier tactic architecture | **High** | Matches existing structure, proven patterns in Mathlib |
| Derivation combinator tactics (`tm_trans`, `tm_mp`) | **High** | Clear repetitive pattern in codebase, standard metaprogramming |
| Aesop rule set redesign | **Medium** | Aesop has matured but the `DerivationTree` issue needs testing |
| Semantic lemma simp set | **Medium** | High impact but requires careful selection of which lemmas to tag |
| FormalizedFormalLogic patterns | **Medium** | Different project structure, but useful architectural reference |
| `tm_deduction` tactic | **Medium** | Deduction theorem is complex (well-founded recursion on height), automation requires care |

---

## Sources

- [Lean 4 Simp Sets Documentation](https://lean-lang.org/doc/reference/latest/The-Simplifier/Simp-sets/)
- [Lean 4 Custom Tactics Documentation](https://lean-lang.org/doc/reference/latest/Tactic-Proofs/Custom-Tactics/)
- [Aesop README](https://github.com/leanprover-community/aesop/blob/master/README.md)
- [Lean 4 Metaprogramming Book — Tactics](https://leanprover-community.github.io/lean4-metaprogramming-book/main/09_tactics.html)
- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation)
- [Mathlib Metaprogramming Wiki](https://github.com/leanprover-community/mathlib4/wiki/Metaprogramming-for-dummies)
- [Lean 4 Simp Guide](https://leanprover-community.github.io/extras/simp.html)
- [Lean 4.22.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.22.0/)
