# LEAN Style Guide for Logos

This document defines coding conventions for the Logos project, adapted from Mathlib4 conventions with project-specific additions.

## 1. Naming Conventions

### Variables
- **Type variables**: Use Greek letters (`α`, `β`, `γ`) or single uppercase letters (`A`, `B`, `C`)
- **Propositions**: Use lowercase letters (`p`, `q`, `r`) or `h` for hypotheses
- **Formulas**: Use `φ`, `ψ`, `χ` (phi, psi, chi)
- **Contexts**: Use `Γ`, `Δ` (Gamma, Delta) for proof contexts
- **Models**: Use `M`, `N` for models, `F` for frames
- **World histories**: Use `τ`, `σ` (tau, sigma)
- **Times**: Use `t`, `s` for specific times, `x`, `y` for time differences

```lean
-- Good
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := ...
lemma modal_saturation (Γ : MaxConsistentSet) (φ : Formula) : ...

-- Avoid
theorem soundness (ctx : Context) (form : Formula) : ...  -- too verbose
theorem soundness (a : Context) (b : Formula) : ...       -- non-descriptive
```

### Types and Structures
- **Types**: PascalCase (`Formula`, `TaskFrame`, `WorldHistory`)
- **Structures**: PascalCase (`TaskModel`, `ProofBuilder`)
- **Inductives**: PascalCase (`Axiom`, `Derivable`)
- **Classes**: PascalCase with descriptive name (`DecidableEq`, `Inhabited`)

```lean
-- Good
inductive Formula : Type
structure TaskFrame where
structure TaskModel (F : TaskFrame) where

-- Avoid
inductive formula : Type        -- lowercase
structure task_frame where      -- snake_case for type
```

### Functions, Definitions, and Theorems
- **Functions**: snake_case (`truth_at`, `swap_temporal`, `canonical_history`)
- **Definitions**: snake_case (`neg`, `diamond`, `always`, `some_past`, `some_future`)
- **Theorems**: snake_case with descriptive name (`soundness`, `weak_completeness`)
- **Lemmas**: snake_case, often prefixed by subject (`modal_saturation`, `truth_lemma`)

```lean
-- Good
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : F.Time) : Formula → Prop := ...
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := ...
lemma modal_t_valid (φ : Formula) : valid (φ.box.imp φ) := ...

-- Avoid
def TruthAt ...                 -- PascalCase for function
theorem Soundness ...           -- PascalCase for theorem
def truthAt ...                 -- camelCase
```

### Namespaces
- Match directory structure: `Logos.Syntax`, `Logos.ProofSystem`
- Use descriptive, hierarchical names
- Open namespaces sparingly; prefer qualified names for clarity

```lean
-- Good
namespace Logos.Syntax
namespace Logos.Semantics.TaskFrame

-- Avoid
namespace Syntax                -- missing project prefix
namespace PS                    -- abbreviations unclear
```

## 2. Formatting Standards

### Line Length
- Maximum 100 characters per line
- Break long lines at logical points (after `→`, before `∧`, after `by`)

```lean
-- Good (≤100 chars)
theorem strong_completeness (Γ : Context) (φ : Formula) :
  Γ ⊨ φ → Γ ⊢ φ := by
  sorry

-- Avoid
theorem strong_completeness (Γ : Context) (φ : Formula) : Γ ⊨ φ → Γ ⊢ φ := by sorry  -- too long
```

### Indentation
- Use 2 spaces (no tabs)
- Continuation lines indented 2 spaces from start of statement
- Tactic blocks indented 2 spaces inside `by`

```lean
-- Good
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : F.Time) :
  Formula → Prop
  | Formula.atom p => t ∈ τ.domain ∧ τ(t) ∈ M.valuation p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t φ → truth_at M τ t ψ
  | Formula.box φ => ∀ σ : WorldHistory F, truth_at M σ t φ
  | Formula.all_past φ => ∀ s < t, truth_at M τ s φ
  | Formula.all_future φ => ∀ s > t, truth_at M τ s φ

theorem soundness (Γ : Context) (φ : Formula) :
  Γ ⊢ φ → Γ ⊨ φ := by
  intro h
  induction h with
  | axiom Γ φ hax =>
    intro F M τ t hΓ
    cases hax with
    | modal_t φ => exact modal_t_valid φ F M τ t
```

### Declarations
- Flush-left (no indentation for `def`, `theorem`, `lemma`, `structure`)
- Type signature on same line if short, next line if long
- Opening `where` on same line as declaration

```lean
-- Good
def neg (φ : Formula) : Formula := φ.imp Formula.bot

theorem deduction_theorem (Γ : Context) (φ ψ : Formula) :
  (φ :: Γ) ⊢ ψ → Γ ⊢ (φ.imp ψ) := by
  sorry

structure TaskFrame where
  WorldState : Type
  Time : Type
  time_group : OrderedAddCommGroup Time
  task_rel : WorldState → Time → WorldState → Prop
```

### Spacing
- One blank line between top-level declarations
- No trailing whitespace
- Single space around binary operators (`→`, `∧`, `∨`, `=`, `:=`)
- No space after `(`, `[`, `{` or before `)`, `]`, `}`

```lean
-- Good
def and (φ ψ : Formula) : Formula := neg (φ.imp (neg ψ))
def or (φ ψ : Formula) : Formula := (neg φ).imp ψ

theorem example_theorem (φ : Formula) : ⊢ (φ.imp φ) := by
  sorry

-- Avoid
def and(φ ψ:Formula):Formula:=neg (φ.imp(neg ψ))  -- missing spaces
def or (φ ψ : Formula) : Formula := (neg φ).imp ψ
                                                   -- extra blank lines
theorem example_theorem (φ : Formula) : ⊢ (φ.imp φ) := by
```

### Code Comments with Formal Symbols

When writing inline comments that reference formal symbols (modal operators, propositional variables, meta-logical symbols), wrap these symbols in backticks for improved readability in editor tooltips and documentation generators.

**Good Examples**:
```lean
-- MT axiom: `□φ → φ` (reflexivity of necessity)
theorem modal_t (φ : Formula) : ⊢ (φ.box.imp φ) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Perpetuity principle P1: `□φ → always φ`
theorem perpetuity_1 (φ : Formula) : ⊢ (φ.box.imp (always φ)) := by
  sorry

-- Soundness: if `Γ ⊢ φ` then `Γ ⊨ φ`
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
  sorry
```

**Avoid (but acceptable)**:
```lean
-- MT axiom: □φ → φ (reflexivity of necessity)
-- Perpetuity principle P1: □φ → always φ
-- Soundness: if Γ ⊢ φ then Γ ⊨ φ
```

**Rationale**:
- Backticks improve visual clarity in VS Code hover tooltips
- Consistent with markdown documentation standards (see `.claude/docs/reference/standards/documentation-standards.md`)
- Monospace rendering distinguishes formal symbols from prose text

**Special Cases**:

1. **Multi-line docstrings** (`/-! ... -/`): Backticks are optional but encouraged
   ```lean
   /-!
   The perpetuity principle P1 states that `□φ → always φ`.
   Alternatively acceptable: □φ → always φ (in docstring context).
   -/
   ```

2. **Single-line docstrings** (`/-- ... -/`): Use backticks for inline formula references
   ```lean
   /-- The soundness theorem: if `Γ ⊢ φ` then `Γ ⊨ φ`. -/
   theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
     sorry
   ```

3. **Code examples in docstrings**: Symbols in code blocks do NOT need additional backticks
   ```lean
   /-- Apply modus ponens.

   Example:
   ```lean
   -- This is already a code block, no backticks needed
   theorem mp_example : [P.imp Q, P] ⊢ Q := by ...
   ```
   -/
   ```

### Unicode Operator Notation

Logos uses Unicode symbols for logical operators with prefix notation declarations. When using or defining notation, follow these guidelines:

**Available Notations**:
```lean
-- Modal operators
□φ    -- Necessity (box)
◇φ    -- Possibility (diamond)

-- Temporal operators
△φ    -- Always/at all times (upward triangle, U+25B3)
▽φ    -- Sometimes/at some time (downward triangle, U+25BD)
```

**Usage Guidelines**:
1. **Prefer prefix notation**: Use `△p` rather than `p.always` for conciseness when appropriate
2. **Mixed usage acceptable**: Both `△p` and `p.always` are valid; choose based on context clarity
3. **Documentation**: Always show both notations in tutorials: "always/`△`" and "sometimes/`▽`"
4. **Precedence**: Triangle operators have precedence 80 (same as modal operators)

**Good Examples**:
```lean
-- Using triangle notation for perpetuity principles
theorem perpetuity_1 (φ : Formula) : ⊢ (□φ → △φ) := by sorry
theorem perpetuity_2 (φ : Formula) : ⊢ (▽φ → ◇φ) := by sorry

-- Mixed notation is acceptable
example (p : Formula) : △p = p.always := rfl
example (p : Formula) : ▽(p.imp q) = (p.imp q).sometimes := rfl
```

**Avoid**:
```lean
-- Don't mix inconsistent styles unnecessarily
theorem perpetuity_1 (φ : Formula) : ⊢ (□φ → always φ) := by sorry  -- inconsistent
theorem perpetuity_2 (φ : Formula) : ⊢ (sometimes φ → ◇φ) := by sorry  -- inconsistent

-- Prefer: Use either all Unicode or all text consistently per theorem
```

## 3. Import Organization

### Import Order
1. Standard library imports
2. Mathlib imports (when used)
3. Project imports (Logos.*)
4. Blank line between groups

```lean
-- Good
import Init.Data.List
import Mathlib.Order.Basic
import Mathlib.Data.Set.Basic

import Logos.Syntax.Formula
import Logos.Syntax.Context
import Logos.ProofSystem.Axioms
```

### Relative vs Absolute Imports
- Use absolute imports for cross-package references
- Use relative imports within the same package/directory

```lean
-- In Logos/Semantics/Truth.lean
import Logos.Syntax.Formula        -- absolute (different package)
import Logos.Semantics.TaskFrame   -- relative would also work
```

## 4. Documentation Requirements

### Module Docstrings
Every file must begin with a module docstring describing its purpose:

```lean
/-!
# Task Frame Semantics

This module defines task frames and world histories for the bimodal logic TM.

## Main Definitions

* `TaskFrame` - A task frame consisting of world states, times, and task relation
* `WorldHistory` - A function from a convex set of times to world states
* `TaskModel` - A task frame with valuation function

## Main Theorems

* `time_shift_invariance` - Truth is invariant under time shifts

## Implementation Notes

Task semantics represents possible worlds as functions from times to world states,
constrained by a task relation that captures transitions between states.

## References

* "Possible Worlds" paper - TM logic specification
* Logos Architecture Guide - Documentation/UserGuide/ARCHITECTURE.md
-/
```

### Declaration Docstrings
Every public definition, theorem, and structure requires a docstring:

```lean
/-- The formula type for the bimodal logic TM.

Formulas are built from:
* `atom p` - Atomic propositions
* `bot` - Falsity (⊥)
* `imp φ ψ` - Implication (φ → ψ)
* `box φ` - Necessity (□φ)
* `past φ` - Universal past (Past φ)
* `future φ` - Universal future (Future φ)

Derived operators (negation, conjunction, etc.) are defined as abbreviations. -/
inductive Formula : Type
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula
  | future : Formula → Formula

/-- Negation as derived operator: ¬φ ≡ φ → ⊥ -/
def neg (φ : Formula) : Formula := φ.imp Formula.bot

/-- The soundness theorem for TM: derivability implies semantic consequence.

If `Γ ⊢ φ` (φ is derivable from Γ), then `Γ ⊨ φ` (φ is a semantic consequence of Γ).
This is proven by induction on the derivation. -/
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
  sorry
```

### Example Formatting
Include examples in docstrings where helpful:

```lean
/-- Apply modus ponens to derive ψ from φ → ψ and φ.

## Example

```lean
example (P Q : Formula) : [P.imp Q, P] ⊢ Q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp
```
-/
def modus_ponens (Γ : Context) (φ ψ : Formula)
  (h1 : Γ ⊢ φ.imp ψ) (h2 : Γ ⊢ φ) : Γ ⊢ ψ := ...
```

## 5. Deprecation Protocol

### Marking Deprecated Definitions
Use the `@[deprecated]` attribute with date and replacement:

```lean
@[deprecated (since := "2025-01-15")]
def old_function (x : Nat) : Nat := x + 1

@[deprecated new_function (since := "2025-01-15")]
def old_function_with_replacement (x : Nat) : Nat := x + 1
```

### Deprecation Timeline
1. Add `@[deprecated]` attribute with date
2. Update all internal usages to new API
3. Document deprecation in CHANGELOG.md
4. Delete after 6 months (or next major version)

### Creating Aliases
When renaming, create an alias pointing to the new name:

```lean
-- Old name (deprecated)
@[deprecated truth_at (since := "2025-01-15")]
abbrev eval_at := truth_at
```

## 6. Code Examples (LEAN, not Python)

### Correct Patterns

```lean
-- Pattern matching on formula structure
def complexity : Formula → Nat
  | Formula.atom _ => 1
  | Formula.bot => 1
  | Formula.imp φ ψ => φ.complexity + ψ.complexity + 1
  | Formula.box φ => φ.complexity + 1
  | Formula.all_past φ => φ.complexity + 1
  | Formula.all_future φ => φ.complexity + 1

-- Using `by` for tactic proofs
theorem modal_t_implies_reflexive (φ : Formula) :
  ⊢ (φ.box.imp φ) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Using `calc` for equational reasoning
example (a b c : Nat) (h1 : a = b) (h2 : b = c) : a = c := calc
  a = b := h1
  _ = c := h2

-- Using `have` for intermediate steps
theorem example_proof (φ ψ : Formula) (h : ⊢ φ.imp ψ) (h2 : ⊢ φ) : ⊢ ψ := by
  have h3 : [] ⊢ φ.imp ψ := h
  have h4 : [] ⊢ φ := h2
  exact Derivable.modus_ponens [] φ ψ h3 h4
```

### Incorrect Patterns (Avoid)

```lean
-- Avoid: Python-style function definitions
def complexity(formula):      -- WRONG: This is Python, not LEAN
  if isinstance(formula, Atom):
    return 1

-- Avoid: Incomplete pattern matches without explicit sorry
def incomplete : Formula → Nat
  | Formula.atom _ => 1
  -- Missing cases will cause errors

-- Avoid: Magic numbers without explanation
def some_function (n : Nat) : Nat := n + 42  -- What is 42?

-- Avoid: Overly complex single expressions
def very_complex := (fun x => (fun y => x + y + (if x > 0 then 1 else 0)) 3) 2  -- Hard to read
```

## 7. Additional Guidelines

### Error Handling
- Use `Option` for operations that may fail
- Document failure conditions in docstrings
- Fail fast with meaningful error information

### Performance
- Prefer `List` for small collections, `Array` for large
- Use `@[inline]` for small, frequently called functions
- Consider memoization for repeated computations

### Testing
- Every public definition needs tests
- Use `#guard` for simple assertions
- Use `example` for proof tests
- See [TESTING_STANDARDS.md](TESTING_STANDARDS.md) for details

### Git Commits
- Reference issue numbers where applicable
- Keep commits focused on single logical changes
- Write descriptive commit messages

## 8. Prohibited Elements

### No Emojis

Do not use emojis in code, comments, or documentation. Use text-based alternatives instead:

- **Status indicators**: Use `[COMPLETE]`, `[PARTIAL]`, `[NOT STARTED]`, `[FAILED]`
- **Checkmarks/crosses**: Use `**DO**` and `**DON'T**` or `YES`/`NO`
- **Emphasis**: Use bold, italics, or section headers

**Mathematical symbols are NOT emojis** and must be preserved:
- Logical operators: `↔`, `→`, `∧`, `∨`, `¬`
- Modal operators: `□`, `◇`
- Temporal operators: `△`, `▽`
- Turnstile symbols: `⊢`, `⊨`

These Unicode mathematical symbols are essential to the formal notation and should always be used.

## 9. Linting and Quality Assurance

The Logos project uses a comprehensive linting system to enforce code quality standards and TM-specific conventions.

### Running Linters

```bash
# Run all linting (syntax + environment + text-based)
lake lint

# Run with verbose output
lake lint -- --verbose

# Auto-fix style issues (trailing whitespace, non-breaking spaces)
lake lint -- --fix

# Verify lint driver is configured
lake check-lint
```

### Linter Types

**1. Syntax Linters** (run during compilation)
- Enabled via `leanOptions` in `lakefile.lean`
- Check for unused variables, missing docs, deprecated patterns
- Cannot be suppressed (compilation-time checks)

**2. Environment Linters** (run post-build)
- `docBlameTheorems`: Enforces 100% theorem documentation
- `tmNamingConventions`: Checks TM-specific naming patterns
- `axiomDocumentation`: Ensures axioms have comprehensive docstrings
- `noSorryInProofs`: Warns about sorry placeholders (disabled by default)

**3. Text-Based Linters** (run on source files)
- `trailingWhitespace`: Detects trailing spaces/tabs (auto-fixable)
- `longLine`: Detects lines >100 characters (manual fix required)
- `nonBreakingSpace`: Detects U+00A0 characters (auto-fixable)

### Suppressing Linters

**Per-declaration suppression:**
```lean
@[nolint docBlame unusedArguments]
def myFunction := ...
```

**File/section scope:**
```lean
set_option linter.unusedVariables false in
def myFunction := ...
```

**Project-wide exceptions** (use sparingly):
Create `scripts/nolints.json`:
```json
[
  ["docBlame", "Logos.Core.Internal.Helper"],
  ["unusedArguments", "Logos.Test.Fixture"]
]
```

### TM-Specific Naming Conventions

The `tmNamingConventions` linter enforces:

1. **Modal operators** (box/diamond) should include 'modal' in name
   ```lean
   -- Good
   theorem modal_k_dist : ⊢ □(φ → ψ) → (□φ → □ψ)
   
   -- Linter warning
   theorem box_dist : ⊢ □(φ → ψ) → (□φ → □ψ)  -- Missing 'modal'
   ```

2. **Temporal operators** (past/future) should include 'temporal' in name
   ```lean
   -- Good
   theorem temporal_k_dist : ⊢ G(φ → ψ) → (Gφ → Gψ)
   
   -- Linter warning
   theorem future_dist : ⊢ G(φ → ψ) → (Gφ → Gψ)  -- Missing 'temporal'
   ```

3. **Exceptions**: Core `Formula` definitions and `Perpetuity` theorems are exempt

### Fixing Style Issues

**Auto-fixable issues:**
```bash
# Fix trailing whitespace and non-breaking spaces
lake lint -- --fix
```

**Manual fixes required:**
- Long lines (>100 characters): Break into multiple lines
- Complex expressions: Use intermediate `have` statements
- Long type signatures: Use line breaks after parameters

**Example of fixing long lines:**
```lean
-- Before (too long)
theorem very_long_theorem_name (φ ψ χ : Formula) (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) (h3 : Γ ⊢ χ) : Γ ⊢ φ ∧ ψ ∧ χ := by

-- After (properly formatted)
theorem very_long_theorem_name
    (φ ψ χ : Formula)
    (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) (h3 : Γ ⊢ χ) :
    Γ ⊢ φ ∧ ψ ∧ χ := by
```

### CI/CD Integration

Linting is enforced in the CI/CD pipeline:
- Lint failures **block builds and PR merges**
- Results uploaded as artifacts for debugging
- GitHub problem matchers provide inline annotations

### Quality Standards

- **Zero lint warnings** required for production code
- **100% docstring coverage** for public theorems
- **100-character line limit** strictly enforced
- **No sorry placeholders** in non-test code (when enabled)

## References

- [Mathlib4 Style Guide](https://leanprover-community.github.io/contribute/style.html)
- [LEAN 4 Documentation](https://lean-lang.org/documentation/)
- [Logos Architecture](../UserGuide/ARCHITECTURE.md)
