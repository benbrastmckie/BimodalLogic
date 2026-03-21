# Research Report: Dependent-Type Conventions for LaTeX-Lean Consistency

**Task**: 503 - Update LaTeX to use dependent-type conventions for Lean consistency  
**Started**: 2025-01-14T10:30:00Z  
**Completed**: 2025-01-14T10:45:00Z  
**Effort**: 15 minutes  
**Priority**: High  
**Dependencies**: None  
**Sources/Inputs**: 
- LaTeX files in Theories/Logos/latex/subfiles/
- Lean 4 implementation in Theories/Logos/SubTheories/Foundation/
- Lean 4 documentation on dependent type theory
- Mathematical notation standards for dependent types

**Artifacts**: 
- This research report (research-001.md)

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

The current LaTeX documentation uses set-theoretic formulations that misalign with Lean's dependent-type implementation. Key issues include representing verifier functions as sets rather than function types, using classical set notation instead of dependent product types, and inconsistent notation between LaTeX and Lean code. This research identifies specific discrepancies and provides recommendations for updating LaTeX to match Lean's dependent-type conventions.

## Context & Scope

This research focuses on updating LaTeX files in Theories/Logos/latex/subfiles/ to use dependent-type theory conventions that align with Lean 4 definitions. The scope includes:

1. Current set-theoretic formulations in LaTeX that need conversion
2. Lean's dependent-type representations of the same concepts  
3. Notation mismatches between LaTeX documentation and Lean code
4. Best practices for maintaining consistency between documentation and implementation

The research examined key files including 01-ConstitutiveFoundation.tex, 03-ExplanatoryExtension-Semantics.tex, and corresponding Lean implementations in Interpretation.lean, Frame.lean, and Semantics.lean.

## Key Findings

### 1. Set-Theoretic vs. Dependent-Type Representations

**Current LaTeX (Set-Theoretic)**:
```latex
\item \textbf{n-place predicates} $\interp{F} = \langle \verifierset{F}, \falsifierset{F} \rangle$ where:
  \begin{itemize}
    \item $\verifierset{F}$: set of \textit{verifier functions} $\statespace^n \to \statespace$
    \item $\falsifierset{F}$: set of \textit{falsifier functions} $\statespace^n \to \statespace$
  \end{itemize}
```

**Lean Implementation (Dependent-Type)**:
```lean
structure PredicateInterp (F : ConstitutiveFrame) (n : Nat) where
  verifierFns : Set ((Fin n → F.State) → F.State)
  falsifierFns : Set ((Fin n → F.State) → F.State)
```

**Issue**: LaTeX describes verifier functions as sets of functions with standard mathematical notation, while Lean uses dependent function types `(Fin n → F.State) → F.State` which properly capture the dependency between input arity and function type.

### 2. Function Type Notation Inconsistencies

**Current LaTeX**:
- Uses classical notation: `f : Sⁿ → S`
- Function symbols: `I(f) : Sⁿ → S`
- Constants: `I(c) ∈ S`

**Lean Implementation**:
- Uses dependent notation: `(Fin n → F.State) → F.State`
- Function symbols: `FunctionInterp F n := (Fin n → F.State) → F.State`
- Constants: `FunctionInterp F 0` (nullary functions as constants)

**Issue**: The LaTeX notation `Sⁿ → S` suggests a simple function type, while Lean's `(Fin n → F.State) → F.State` captures the precise dependent typing where the domain type depends on the arity parameter `n`.

### 3. Variable Assignment and Term Evaluation

**Current LaTeX**:
```latex
\item \textbf{Variable Assignment} $\assignment$ is a function from variables to states: $\assignment : \mathrm{Var} \to \statespace$
```

**Lean Implementation**:
```lean
def VarAssignment (F : ConstitutiveFrame) := String → F.State
```

**Issue**: While semantically equivalent, the notation could be more consistent with Lean's dependent-type style.

### 4. Verification Clauses

**Current LaTeX**:
```latex
\model, \assignment, s \verifies F(t_1, \ldots, t_n) &\iff \exists f \in \verifierset{F} : s = f(\sem{t_1}^\assignment_\model, \ldots, \sem{t_n}^\assignment_\model)
```

**Lean Implementation**:
```lean
| ConstitutiveFormula.pred P ts =>
  let args : Fin ts.length → M.frame.State := fun i => evalTerm M σ (ts.get i)
  ∃ f ∈ (M.interp.predicate P ts.length).verifierFns,
    s = f (fun i => args (Fin.cast (by rfl) i))
```

**Issue**: LaTeX uses tuple notation `(t₁, ..., tₙ)` while Lean uses indexed families `Fin n → State` which is more type-theoretically precise.

## Detailed Analysis

### Current Set-Theoretic Formulations to Update

1. **Predicate Interpretation (Lines 72-76, 01-ConstitutiveFoundation.tex)**:
   ```latex
   \item \textbf{n-place predicates} $\interp{F} = \langle \verifierset{F}, \falsifierset{F} \rangle$ where:
     \begin{itemize}
       \item $\verifierset{F}$: set of \textit{verifier functions} $\statespace^n \to \statespace$
       \item $\falsifierset{F}$: set of \textit{falsifier functions} $\statespace^n \to \statespace$
     \end{itemize}
   ```

2. **Function Symbol Interpretation (Line 71)**:
   ```latex
   \item \textbf{n-place function symbols} $\interp{f} : \statespace^n \to \statespace$
   ```

3. **Term Extension Definition (Lines 109-111)**:
   ```latex
   \item \textbf{Function application} $f(t_1, \ldots, t_n)$: $\sem{f(t_1, \ldots, t_n)}^\assignment_\model = \interp{f}(\sem{t_1}^\assignment_\model, \ldots, \sem{t_n}^\assignment_\model)$
   ```

4. **Atomic Verification (Lines 128-131)**:
   ```latex
   \model, \assignment, s \verifies F(t_1, \ldots, t_n) &\iff \exists f \in \verifierset{F} : s = f(\sem{t_1}^\assignment_\model, \ldots, \sem{t_n}^\assignment_\model)
   ```

### Proper Dependent-Type Notation for LaTeX

Based on Lean 4 dependent-type conventions, the following notation should be used:

1. **Function Types**: Use Pi-type notation `(x : A) → B x` for dependent functions
2. **Arity-dependent Types**: Use `(Fin n → State) → State` instead of `Stateⁿ → State`
3. **Variable Assignments**: Maintain `String → State` notation (already consistent)
4. **Indexed Families**: Use `Fin n → State` instead of tuple notation `(t₁, ..., tₙ)`

## Recommendations

### Immediate Updates Required

1. **Update Function Type Notation**:
   - Replace `Sⁿ → S` with `(Fin n → S) → S` throughout
   - Replace `f(t₁, ..., tₙ)` with `f (λ i : Fin n, t_i)`
   - Update all verification clauses to use indexed families

2. **Update Predicate Interpretation**:
   ```latex
   \item \textbf{n-place predicates} $\interp{F} = \langle \verifierset{F}, \falsifierset{F} \rangle$ where:
     \begin{itemize}
       \item $\verifierset{F}$: set of \textit{verifier functions} $(\mathtt{Fin}\;n \to \statespace) \to \statespace$
       \item $\falsifierset{F}$: set of \textit{falsifier functions} $(\mathtt{Fin}\;n \to \statespace) \to \statespace$
     \end{itemize}
   ```

3. **Update Function Symbol Interpretation**:
   ```latex
   \item \textbf{n-place function symbols} $\interp{f} : (\mathtt{Fin}\;n \to \statespace) \to \statespace$
   ```

4. **Update Atomic Verification Clauses**:
   ```latex
   \model, \assignment, s \verifies F(t_1, \ldots, t_n) &\iff \exists f \in \verifierset{F} : s = f(\lambda i : \mathtt{Fin}\;n, \sem{t_i}^\assignment_\model)
   ```

### Notation Standards to Adopt

1. **Use `\mathtt{Fin}` for the finite type**: This matches Lean's `Fin` type
2. **Use lambda notation for indexed families**: `\lambda i : \mathtt{Fin}\;n, t_i`
3. **Maintain consistency with Lean's type signatures**: Ensure all LaTeX type notation matches Lean's dependent types exactly
4. **Use proper set-theoretic notation for sets of functions**: Keep `Set (A → B)` notation when referring to sets of functions

### Files Requiring Updates

1. **Primary Files**:
   - `01-ConstitutiveFoundation.tex` (Lines 71-76, 109-111, 128-131)
   - `03-ExplanatoryExtension-Semantics.tex` (Similar verification clauses)

2. **Secondary Files** (likely contain similar patterns):
   - `02-ExplanatoryExtension-Syntax.tex`
   - `04-ExplanatoryExtension-Axioms.tex`
   - Other files with function type notation

## Code Examples

### Before (Current Set-Theoretic Notation)

```latex
\begin{definition}[Constitutive Model]
  A \emph{constitutive model} is a structure $\model = \langle \statespace, \parthood, \interp{\cdot} \rangle$ where $\langle \statespace, \parthood \rangle$ is a constitutive frame and $\interp{\cdot}$ is an interpretation function satisfying:
  \begin{itemize}
    \item \textbf{n-place function symbols} $\interp{f} : \statespace^n \to \statespace$ where $\interp{c} \in \statespace$ for constants 
    \item \textbf{n-place predicates} $\interp{F} = \langle \verifierset{F}, \falsifierset{F} \rangle$ where:
      \begin{itemize}
        \item $\verifierset{F}$: set of \textit{verifier functions} $\statespace^n \to \statespace$
        \item $\falsifierset{F}$: set of \textit{falsifier functions} $\statespace^n \to \statespace$
      \end{itemize}
  \end{itemize}
\end{definition}
```

### After (Dependent-Type Notation)

```latex
\begin{definition}[Constitutive Model]
  A \emph{constitutive model} is a structure $\model = \langle \statespace, \parthood, \interp{\cdot} \rangle$ where $\langle \statespace, \parthood \rangle$ is a constitutive frame and $\interp{\cdot}$ is an interpretation function satisfying:
  \begin{itemize}
    \item \textbf{n-place function symbols} $\interp{f} : (\mathtt{Fin}\;n \to \statespace) \to \statespace$ where $\interp{c} : (\mathtt{Fin}\;0 \to \statespace) \to \statespace$ for constants 
    \item \textbf{n-place predicates} $\interp{F} = \langle \verifierset{F}, \falsifierset{F} \rangle$ where:
      \begin{itemize}
        \item $\verifierset{F}$: set of \textit{verifier functions} $(\mathtt{Fin}\;n \to \statespace) \to \statespace$
        \item $\falsifierset{F}$: set of \textit{falsifier functions} $(\mathtt{Fin}\;n \to \statespace) \to \statespace$
      \end{itemize}
  \end{itemize}
\end{definition}
```

## Decisions

### Rationale for Dependent-Type Conventions

1. **Alignment with Lean Implementation**: Using dependent-type notation eliminates the cognitive dissonance between mathematical documentation and formal implementation
2. **Precision of Dependent Types**: The notation `(Fin n → State) → State` more precisely captures the arity-dependent nature of predicate and function interpretation
3. **Consistency with Type Theory**: Adopting type-theoretic notation aligns with modern mathematical foundations used in proof assistants

### Notation Choices

1. **`\mathtt{Fin}`**: Matches Lean's `Fin` type exactly
2. **Lambda notation**: `\lambda i : \mathtt{Fin}\;n, t_i` clearly indicates indexed families
3. **Parentheses for function types**: `(A → B)` clarifies type structure vs. mathematical expressions

## Risks & Mitigations

### Risks

1. **Reader Familiarity**: Mathematicians may be less familiar with dependent-type notation
2. **LaTeX Complexity**: More complex notation may introduce typesetting errors
3. **Documentation Migration**: Existing documents and references may become inconsistent

### Mitigations

1. **Include notation explanations**: Add brief explanations when introducing new notation
2. **Gradual migration**: Update most critical files first (constitutive foundation, core semantics)
3. **Cross-references**: Maintain consistency with existing `\leansrc{}` references to Lean code
4. **Validation**: Test LaTeX compilation after each significant change

## Implementation Strategy

### Phase 1: Core Updates
1. Update `01-ConstitutiveFoundation.tex` with dependent-type notation
2. Update `03-ExplanatoryExtension-Semantics.tex` verification clauses
3. Test compilation and verify consistency with Lean code

### Phase 2: Extended Updates  
1. Update remaining files with similar patterns
2. Add notation explanations where needed
3. Ensure all `\leansrc{}` references remain valid

### Phase 3: Validation
1. Compile entire LaTeX project
2. Cross-reference with Lean implementation for consistency
3. Review mathematical clarity and correctness

## Conclusion

The transition from set-theoretic to dependent-type conventions in LaTeX documentation is essential for maintaining consistency with the Lean 4 implementation. The key changes involve updating function type notation from classical `Sⁿ → S` to dependent `(Fin n → S) → S`, and replacing tuple notation with indexed families using lambda expressions. These changes will eliminate current inconsistencies between documentation and formal implementation while maintaining mathematical precision.

## Appendix: Sources and Citations

1. **Lean 4 Documentation**: "Theorem Proving in Lean 4 - Dependent Type Theory" - https://leanprover.github.io/theorem_proving_in_lean4/dependent_type_theory.html
2. **Mathematics in Lean**: "Sets and Functions" - https://leanprover-community.github.io/mathematics_in_lean/C04_Sets_and_Functions.html
3. **Lean Type System**: "Functions" reference documentation - https://lean-lang.org/doc/reference/4.19.0/The-Type-System/Functions/
4. **Logos Implementation**: Current Lean 4 codebase in Theories/Logos/SubTheories/Foundation/
5. **Current LaTeX Documentation**: Files in Theories/Logos/latex/subfiles/