# Lean 4 Documentation Standards and Best Practices Research Report

**Research Date:** 2025-12-24  
**Topic:** Lean 4 Docstring Syntax, Documentation Tools, and API Documentation Best Practices  
**Status:** Complete

## Executive Summary

This report provides comprehensive research on Lean 4 documentation standards, focusing on docstring syntax, documentation generation tools (especially doc-gen4), and best practices from mathlib4 and the broader Lean community. The research covers official Lean 4 documentation standards, community conventions, and practical examples from well-documented projects.

**Key Findings:**
1. Lean 4 uses `/-- ... -/` for docstrings with full Markdown and LaTeX support
2. doc-gen4 is the official documentation generator, integrated via Lake facets
3. mathlib4 has comprehensive documentation standards that serve as the de facto community standard
4. Module docstrings (`/-! ... -/`) provide file-level documentation with structured sections
5. Documentation quality is enforced through linters (`docBlame`, `docBlameThm`)

## 1. Lean 4 Docstring Syntax and Conventions

### 1.1 Basic Docstring Syntax

Lean 4 uses special comment delimiters for documentation:

- **Declaration docstrings:** `/-- ... -/` (placed immediately before the declaration)
- **Module docstrings:** `/-! ... -/` (for file headers and section comments)
- **Regular comments:** `/- ... -/` (for implementation notes, TODOs)
- **Inline comments:** `--` (for short or in-line comments)

### 1.2 Declaration Docstrings

**Syntax Rules:**
- Delimiters `/--` and `-/` should be on the same line as the text for single-line docstrings
- For multi-line docstrings, delimiters can be on their own lines
- Subsequent lines should NOT be indented (this is a Lean 4 requirement)
- Complete sentences should end with a period
- Named theorems should be **bold** (e.g., `**mean value theorem**`)

**Example from mathlib4:**
```lean
/-- If `q ≠ 0`, the `p`-adic norm of a rational `q` is `p ^ (-padicValRat p q)`.
If `q = 0`, the `p`-adic norm of `q` is `0`. -/
def padicNorm (p : ℕ) (q : ℚ) : ℚ :=
  if q = 0 then 0 else (p : ℚ) ^ (-padicValRat p q)
```

**Example with "lying" documentation (acceptable):**
```lean
/-- `padicValRat` defines the valuation of a rational `q` to be the valuation of `q.num` 
minus the valuation of `q.den`. If `q = 0` or `p = 1`, then `padicValRat p q` defaults to `0`. -/
def padicValRat (p : ℕ) (q : ℚ) : ℤ :=
  padicValInt p q.num - padicValNat p q.den
```

### 1.3 Module Docstrings (File Headers)

Module docstrings use `/-! ... -/` and follow a strict structure:

**Required Structure:**
1. **Title** (first-level header `#`)
2. **Summary** of file contents
3. **Main definitions** (optional if covered in summary)
4. **Main statements** (optional if covered in summary)
5. **Notation** (required if notation is introduced)
6. **Implementation notes** (design decisions, type class usage, simp canonical forms)
7. **References** (citations to papers, books, Wikipedia)
8. **Tags** (keywords for text search)

**Example from mathlib4 (PadicNorm.lean):**
```lean
/-!
# p-adic norm

This file defines the `p`-adic norm on `ℚ`.

The `p`-adic valuation on `ℚ` is the difference of the multiplicities of `p` in the numerator and
denominator of `q`. This function obeys the standard properties of a valuation, with the appropriate
assumptions on `p`.

The valuation induces a norm on `ℚ`. This norm is a nonarchimedean absolute value.
It takes values in {0} ∪ {1/p^k | k ∈ ℤ}.

## Implementation notes

Much, but not all, of this file assumes that `p` is prime. This assumption is inferred automatically
by taking `[Fact p.Prime]` as a type class argument.

## References

* [F. Q. Gouvêa, *p-adic numbers*][gouvea1997]
* [R. Y. Lewis, *A formal proof of Hensel's lemma over the p-adic integers*][lewis2019]
* <https://en.wikipedia.org/wiki/P-adic_number>

## Tags

p-adic, p adic, padic, norm, valuation
-/
```

### 1.4 Sectioning Comments

Use `/-! ... -/` for section headers within files:

```lean
/-! ### Declarations about `BinderInfo` -/

/-- The brackets corresponding to a given `BinderInfo`. -/
def brackets : BinderInfo → String × String
  | BinderInfo.implicit => ("{", "}")
  | BinderInfo.strictImplicit => ("{{", "}}")
  | BinderInfo.instImplicit => ("[", "]")
  | _ => ("(", ")")
```

**Rules:**
- Use third-level headers `###` for section titles
- Sectioning comments are for display/readability only (no semantic meaning)
- Can be used inside or outside of `section`/`namespace` blocks

### 1.5 Markdown and LaTeX Support

**Markdown Features:**
- Backticks for code/identifiers: `` `Nat.add` ``
- Fully-qualified names become links in online docs: `` `finset.card_pos` ``
- Bold text: `**theorem name**`
- Lists, headers, emphasis all supported
- Raw URLs should be in angle brackets: `<https://example.com>`

**LaTeX Math:**
- Inline math: `$ ... $`
- Display math: `$$ ... $$`
- Environments: `\begin{*} ... \end{*}` (without dollar signs)
- Uses MathJax rendering (similar to Math StackExchange)

**Example:**
```lean
/-- The `p`-adic norm of `q` is `1` if `q` is prime and not equal to `p`.
This follows from the fact that $\nu_p(q) = 0$ when $p \neq q$. -/
theorem padicNorm_of_prime_of_ne {q : ℕ} [p_prime : Fact p.Prime] [q_prime : Fact q.Prime]
    (neq : p ≠ q) : padicNorm p q = 1 := by
  have p : padicValRat p q = 0 := mod_cast padicValNat_primes neq
  rw [padicNorm, p]
  simp [q_prime.1.ne_zero]
```

### 1.6 Citing References

References should be added to `docs/references.bib` and cited using:

**Citation Styles:**
1. **Bracket style:** `[Boole1854]` → becomes `[Boo54]` link
2. **Custom text:** `[Grundlagen der Geometrie][hilbert1999]` → becomes linked text

**Example:**
```lean
/-!
## References

* [F. Q. Gouvêa, *p-adic numbers*][gouvea1997]
* [R. Y. Lewis, *A formal proof of Hensel's lemma over the p-adic integers*][lewis2019]
-/
```

## 2. Lean 4 Documentation Tools

### 2.1 doc-gen4: The Official Documentation Generator

**Overview:**
- Official documentation generator for Lean 4
- Generates HTML documentation from Lean source code
- Integrated via Lake facets
- Used by mathlib4 and most Lean 4 projects

**Repository:** <https://github.com/leanprover/doc-gen4>

### 2.2 Setting Up doc-gen4

**Recommended Setup (Nested Project Approach):**

1. Create a `docbuild` subdirectory in your project
2. Create `docbuild/lakefile.toml`:

```toml
name = "docbuild"
reservoir = false
version = "0.1.0"
packagesDir = "../.lake/packages"

[[require]]
name = "Your Library Name"
path = "../"

[[require]]
scope = "leanprover"
name = "doc-gen4"
# Use main for latest, or v4.x for stable versions
rev = "main"
```

3. Run `lake update doc-gen4` in the `docbuild` directory
4. For mathlib4 dependencies: `MATHLIB_NO_CACHE_ON_UPDATE=1 lake update doc-gen4`

### 2.3 Generating Documentation

**Basic Usage:**
```bash
cd docbuild
lake build YourLibraryName:docs
```

**Multiple Libraries:**
```bash
lake build Test:docs YourLibraryName:docs
```

**Output Location:**
- Documentation root: `docbuild/.lake/build/doc/index.html`
- Must be served via HTTP (not file://) due to Same Origin Policy
- Simple server: `python3 -m http.server` from `docbuild/.lake/build/doc`

**Note:** doc-gen4 always generates docs for `Lean`, `Init`, `Lake`, and `Std` in addition to specified targets.

### 2.4 doc-gen4 Features

**Capabilities:**
- Extracts docstrings and converts to HTML
- Renders Markdown and LaTeX math
- Creates cross-reference links between declarations
- Generates API reference pages
- Supports source code links (GitHub, local files, VSCode URLs)
- Provides search functionality (`/find/?pattern=...`)

**Source Location Configuration:**

Set `DOCGEN_SRC` environment variable:
- `DOCGEN_SRC="github"` (default) - links to GitHub source view
- `DOCGEN_SRC="file"` - local file references
- `DOCGEN_SRC="vscode"` - VSCode URLs for local editing

**Example:**
```bash
DOCGEN_SRC="vscode" lake build YourLibraryName:docs
```

**Disabling Equations:**

Set `DISABLE_EQUATIONS=1` to disable equation generation for definitions.

### 2.5 Integration with Zulip (docs# Links)

The `/find` endpoint enables `docs#` links in Lean Zulip:
- Format: `https://example.com/path/to/docs/find/?pattern=Nat.add#doc`
- Example: <https://leanprover-community.github.io/mathlib4_docs/find/?pattern=Nat.add#doc>
- Automatically resolves to declaration documentation

## 3. Best Practices from mathlib4 and Community

### 3.1 Documentation Requirements

**From mathlib4 contribution guidelines:**

1. **Every definition and major theorem MUST have a docstring**
2. **Lemmas SHOULD have docstrings** (especially if they have mathematical content or might be useful elsewhere)
3. **Module docstrings are REQUIRED** for all files
4. **Complete sentences MUST end with a period**

### 3.2 Linters for Documentation Quality

**docBlame Linter:**
- Lists all definitions without docstrings
- Run: `#lint only docBlame`

**docBlameThm Linter:**
- Lists theorems and lemmas without docstrings
- Run: `#lint only docBlameThm`

**Combined:**
```lean
#lint docBlameThm  -- Run all default linters plus docBlameThm
```

### 3.3 Documentation Style Guidelines

**From mathlib4 style guide:**

1. **Convey mathematical meaning** - docstrings should describe the mathematical content, not just implementation details
2. **Acceptable "lying"** - docstrings can slightly abstract from implementation if it aids understanding
3. **Use backticks for identifiers** - `` `Nat.add` `` for Lean declarations
4. **Use LaTeX for math** - `$p$-adic` instead of `p-adic`
5. **Bold named theorems** - `**mean value theorem**`
6. **Angle brackets for URLs** - `<https://example.com>` ensures clickability

### 3.4 Structure and Class Documentation

**Fields MUST have docstrings:**

```lean
structure PrincipalSeg {α β : Type*} (r : α → α → Prop) (s : β → β → Prop) extends r ↪r s where
  /-- The supremum of the principal segment -/
  top : β
  /-- The image of the order embedding is the set of elements `b` such that `s b top` -/
  down' : ∀ b, s b top ↔ ∃ a, toRelEmbedding a = b

class Module (R : Type u) (M : Type v) [Semiring R] [AddCommMonoid M] extends
    DistribMulAction R M where
  /-- Scalar multiplication distributes over addition from the right. -/
  protected add_smul : ∀ (r s : R) (x : M), (r + s) • x = r • x + s • x
  /-- Scalar multiplication by zero gives zero. -/
  protected zero_smul : ∀ x : M, (0 : R) • x = 0
```

### 3.5 Instance Documentation

**Use `where` syntax:**

```lean
instance instOrderBot : OrderBot ℕ where
  bot := 0
  bot_le := Nat.zero_le
```

**Reusing existing instances:**

```lean
instance instOrderBot : OrderBot ℕ where
  __ := instBot
  bot_le := Nat.zero_le
```

### 3.6 Copyright Headers

**Standard format:**

```lean
/-
Copyright (c) 2024 Joe Cool. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joe Cool
-/
import Mathlib.Data.Nat.Basic
import Mathlib.Algebra.Group.Defs
```

**Rules:**
- Use `Authors` (plural) even for single author
- No period at end of author line
- Separate authors with commas (no "and")
- No blank line between header and imports

### 3.7 Examples of Well-Documented Files

**Recommended examples from mathlib4:**
1. `Mathlib.NumberTheory.Padics.PadicNorm` - excellent structure and clarity
2. `Mathlib.Topology.Basic` - comprehensive file header and sectioning
3. `Mathlib.Analysis.Calculus.ContDiff.Basic` - complex mathematical content well-documented

## 4. Documentation Patterns for Different Declaration Types

### 4.1 Definitions

**Pattern:**
- State what the definition represents mathematically
- Mention special cases or edge cases
- Can abstract from implementation details

**Example:**
```lean
/-- If `q ≠ 0`, the `p`-adic norm of a rational `q` is `p ^ (-padicValRat p q)`.
If `q = 0`, the `p`-adic norm of `q` is `0`. -/
def padicNorm (p : ℕ) (q : ℚ) : ℚ :=
  if q = 0 then 0 else (p : ℚ) ^ (-padicValRat p q)
```

### 4.2 Theorems and Lemmas

**Pattern:**
- State the mathematical result clearly
- Reference named theorems in bold
- Mention key assumptions or conditions
- Can include brief proof sketch for complex results

**Example:**
```lean
/-- The `p`-adic norm is nonarchimedean: the norm of `p + q` is at most the max of the norm of `p`
and the norm of `q`. -/
protected theorem nonarchimedean {q r : ℚ} :
    padicNorm p (q + r) ≤ max (padicNorm p q) (padicNorm p r) := by
  wlog hle : padicValRat p q ≤ padicValRat p r generalizing q r
  · rw [add_comm, max_comm]
    exact this (le_of_not_ge hle)
  exact nonarchimedean_aux hle
```

### 4.3 Instances

**Pattern:**
- Describe what typeclass is being instantiated
- Mention key properties or methods
- Reference related instances if applicable

**Example:**
```lean
/-- The `p`-adic norm is an absolute value: positive-definite and multiplicative, satisfying the
triangle inequality. -/
instance : IsAbsoluteValue (padicNorm p) where
  abv_nonneg' := padicNorm.nonneg
  abv_eq_zero' := ⟨zero_of_padicNorm_eq_zero, fun hx ↦ by simp [hx]⟩
  abv_add' := padicNorm.triangle_ineq
  abv_mul' := padicNorm.mul
```

### 4.4 Tactics

**Pattern:**
- Describe what the tactic does
- Explain when to use it
- Give examples of typical usage
- Document tactic arguments and options

**Example (from mathlib4 patterns):**
```lean
/-- `ring` solves equations in commutative (semi)rings by normalizing both sides to a canonical form.
It handles addition, multiplication, and exponentiation by natural number literals.

Example:
```lean
example (x y : ℕ) : (x + y) ^ 2 = x ^ 2 + 2 * x * y + y ^ 2 := by ring
```
-/
```

### 4.5 Notation

**Pattern:**
- Show the notation clearly
- Explain what it represents
- Give usage examples
- Mention precedence if relevant

**Example:**
```lean
/-!
## Notation

* `|_|` : The barrification operator, see `bar_of_foo`.
* `⟨x, y⟩` : Ordered pair notation for products.
-/
```

## 5. Quality Standards and Recommendations

### 5.1 What Makes a Good Docstring

**Essential Elements:**
1. **Clarity** - Mathematical meaning should be immediately clear
2. **Completeness** - All important cases and edge cases mentioned
3. **Conciseness** - No unnecessary verbosity
4. **Accuracy** - Mathematically correct (even if abstracting from implementation)
5. **Usefulness** - Helps users understand when and how to use the declaration

### 5.2 Parameter Documentation

**Guidelines:**
- Implicit parameters usually don't need explicit documentation (inferred from context)
- Explicit parameters should be clear from the type signature
- Document parameters when:
  - Their role is not obvious from the name
  - There are special requirements or assumptions
  - The parameter represents a mathematical concept that needs explanation

**Example:**
```lean
/-- The `p`-adic norm of a natural `m` is one iff `p` doesn't divide `m`. -/
theorem nat_eq_one_iff (m : ℕ) : padicNorm p m = 1 ↔ ¬p ∣ m := by
  rw [← Int.natCast_dvd_natCast, ← int_eq_one_iff, Int.cast_natCast]
```

### 5.3 When to Include Examples

**Include examples when:**
- The usage is not immediately obvious
- There are multiple ways to use the declaration
- The declaration is a tactic or automation tool
- The mathematical concept is subtle or non-standard

**Example format:**
```lean
/-- `simp` simplifies expressions using a database of simplification lemmas.

Example:
```lean
example (x : ℕ) : x + 0 = x := by simp
```
-/
```

### 5.4 Documenting Complex Proof Tactics

**Pattern for tactic documentation:**
1. **Purpose** - What does the tactic do?
2. **When to use** - What problems does it solve?
3. **How it works** - Brief explanation of the approach
4. **Examples** - Typical usage patterns
5. **Limitations** - What it can't handle
6. **Related tactics** - Alternatives or complementary tactics

**Example structure:**
```lean
/-- `omega` is a tactic for solving linear arithmetic goals over integers and naturals.

It handles:
- Linear inequalities and equalities
- Divisibility constraints
- Natural number subtraction

Example:
```lean
example (x y : ℕ) (h : x + y = 10) (h' : x ≥ 3) : y ≤ 7 := by omega
```

Limitations: Does not handle multiplication by variables or nonlinear constraints.

See also: `linarith` for real-valued linear arithmetic.
-/
```

### 5.5 Documentation Anti-Patterns

**Avoid:**
1. **Empty or trivial docstrings** - "This is a definition of foo" adds no value
2. **Implementation details** - Unless relevant to usage
3. **Redundant information** - Don't repeat what's obvious from the type signature
4. **Outdated documentation** - Update docstrings when changing declarations
5. **Missing edge cases** - Always document special cases (zero, empty, etc.)

## 6. Integration with Development Workflow

### 6.1 Documentation in CI/CD

**Recommended practices:**
- Run `#lint` in CI to catch missing docstrings
- Generate documentation on every commit to main branch
- Deploy documentation to GitHub Pages or similar
- Use doc-gen4's `/find` endpoint for searchability

### 6.2 Documentation Maintenance

**Best practices:**
1. **Update docstrings when refactoring** - Keep documentation in sync with code
2. **Review documentation in PRs** - Check for clarity and completeness
3. **Use deprecation warnings** - Document deprecated declarations with `@[deprecated]`
4. **Version documentation** - Tag documentation releases with code releases

**Deprecation example:**
```lean
@[deprecated (since := "2024-12-24")]
alias old_name := new_name

@[deprecated "Use new_approach instead" (since := "2024-12-24")]
theorem old_theorem : ... := ...
```

### 6.3 Documentation Testing

**Approaches:**
1. **Docstring examples** - Ensure examples compile and work
2. **Link checking** - Verify cross-references are valid
3. **Linter enforcement** - Use `docBlame` and `docBlameThm` in CI
4. **Manual review** - Check generated HTML for formatting issues

## 7. Tools and Resources

### 7.1 Documentation Generation Tools

| Tool | Purpose | URL |
|------|---------|-----|
| doc-gen4 | Official Lean 4 documentation generator | <https://github.com/leanprover/doc-gen4> |
| Loogle | Search tool for Lean declarations | <https://loogle.lean-lang.org/> |
| LeanSearch | Natural language search for theorems | <https://leansearch.net/> |
| LeanExplore | Natural language search engine | <https://www.leanexplore.com/> |

### 7.2 Documentation Examples

| Project | Documentation URL | Notes |
|---------|------------------|-------|
| mathlib4 | <https://leanprover-community.github.io/mathlib4_docs/> | Gold standard for Lean 4 documentation |
| Lean 4 core | <https://lean-lang.org/doc/api/> | Official Lean 4 API docs |
| Lean 4 std | Included in mathlib4 docs | Standard library documentation |

### 7.3 Style Guides and References

| Resource | URL | Description |
|----------|-----|-------------|
| Documentation Style | <https://leanprover-community.github.io/contribute/doc.html> | Official mathlib4 documentation standards |
| Code Style Guide | <https://leanprover-community.github.io/contribute/style.html> | General Lean 4 style guidelines |
| Naming Conventions | <https://leanprover-community.github.io/contribute/naming.html> | Naming standards for declarations |
| Language Reference | <https://lean-lang.org/doc/reference/latest/> | Complete Lean 4 language specification |

## 8. Recommendations for ProofChecker Project

### 8.1 Immediate Actions

1. **Set up doc-gen4** - Create `docbuild` subdirectory with proper configuration
2. **Add module docstrings** - Ensure all files have proper `/-! ... -/` headers
3. **Document public API** - Add docstrings to all public definitions and theorems
4. **Enable linters** - Add `#lint docBlame docBlameThm` to test files

### 8.2 Documentation Structure

**Recommended file header template:**
```lean
/-
Copyright (c) 2024 [Authors]. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: [Author Names]
-/
import Logos.Core.Syntax.Formula
import Logos.Core.Semantics.TaskModel

/-!
# [File Title]

[Brief description of file contents]

## Main definitions

* `definition_name` - [description]

## Main results

* `theorem_name` - [description]

## Notation

* `notation` - [description]

## Implementation notes

[Design decisions, type class usage, etc.]

## References

* [Reference citations]

## Tags

[keywords for search]
-/
```

### 8.3 Priority Areas for Documentation

Based on the ProofChecker codebase:

1. **Core modules** - `Logos.Core.*` should have comprehensive documentation
2. **Public API** - All exported definitions and theorems
3. **Tactics** - `Logos.Core.Automation.Tactics` needs detailed usage examples
4. **Examples** - `Logos.Examples.*` should have explanatory docstrings
5. **Test files** - Document test patterns and property-based testing approaches

### 8.4 Long-term Documentation Goals

1. **Generate API reference** - Set up automated doc-gen4 builds
2. **Create user guide** - Supplement API docs with tutorials and examples
3. **Document proof patterns** - Create a guide to common proof strategies
4. **Maintain theory documentation** - Keep `docs/Research/` in sync with code
5. **Enable docs# links** - Set up `/find` endpoint for Zulip integration

## 9. Conclusion

Lean 4 has a well-established documentation ecosystem with clear standards and powerful tools. The key to good documentation is:

1. **Consistency** - Follow mathlib4 conventions
2. **Clarity** - Write for users, not just implementers
3. **Completeness** - Document all public API elements
4. **Maintenance** - Keep documentation in sync with code
5. **Automation** - Use doc-gen4 and linters to enforce standards

The mathlib4 project serves as an excellent model, with comprehensive documentation standards, active linter enforcement, and high-quality examples. By adopting these practices, the ProofChecker project can achieve similar documentation quality and usability.

## References

### Primary Sources

1. **Lean Community Documentation Style Guide**  
   <https://leanprover-community.github.io/contribute/doc.html>

2. **Lean Community Code Style Guide**  
   <https://leanprover-community.github.io/contribute/style.html>

3. **doc-gen4 Repository**  
   <https://github.com/leanprover/doc-gen4>

4. **mathlib4 API Documentation**  
   <https://leanprover-community.github.io/mathlib4_docs/>

5. **Lean 4 Language Reference**  
   <https://lean-lang.org/doc/reference/latest/>

### Example Files

1. **Mathlib.NumberTheory.Padics.PadicNorm**  
   <https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/NumberTheory/Padics/PadicNorm.lean>

2. **Mathlib.Topology.Basic**  
   <https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Topology/Basic.lean>

3. **Mathlib.Data.Nat.Basic**  
   <https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Data/Nat/Basic.lean>

### Tools and Resources

1. **Loogle Search** - <https://loogle.lean-lang.org/>
2. **LeanSearch** - <https://leansearch.net/>
3. **Lean 4 Playground** - <https://live.lean-lang.org/>
4. **Lean Zulip Chat** - <https://leanprover.zulipchat.com/>

---

**Report prepared by:** Web Research Specialist  
**Date:** 2025-12-24  
**Version:** 1.0
