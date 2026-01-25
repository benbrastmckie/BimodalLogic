# Research Report: Task #678

**Task**: Fix Constitutive Foundation LaTeX definitions  
**Date**: 2026-01-25  
**Language**: LaTeX  
**Session ID**: sess_1769375343_7cfd86

## Summary

Research completed for four LaTeX definition gaps in `02-ConstitutiveFoundation.tex`. Analysis identifies the required mathematical notation standards, examines the Lean implementation for term algebra structure, and provides specific LaTeX code recommendations for each fix.

## Findings

### Finding 1: Well-Formed Sentences Definition (Line 32)

**Current State**: FIX comment requests standard BNF-style definition with double colon and pipes

**Standard Practice**: Formal language grammars use BNF (Backus-Naur Form) with `::=` for productions and `|` for alternatives.

**Lean Implementation** (Foundation/Syntax.lean:74-93):
```lean
inductive ConstitutiveFormula where
  | atom : String → ConstitutiveFormula
  | pred : String → List Term → ConstitutiveFormula
  | bot : ConstitutiveFormula
  | top : ConstitutiveFormula
  | neg : ConstitutiveFormula → ConstitutiveFormula
  | and : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
  | or : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
  | ident : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
  | lambdaApp : String → ConstitutiveFormula → Term → ConstitutiveFormula
```

**Recommended LaTeX**:
```latex
\begin{definition}[Well-Formed Formulas]\label{def:wff}
The set of \emph{well-formed formulas} is defined inductively:
\begin{align*}
  \metaA \Define{}& p \mid F(t_1, \ldots, t_n) \mid \top \mid \bot \\
  \mid{}& \neg\metaA \mid (\metaA \land \metaB) \mid (\metaA \lor \metaB) \\
  \mid{}& (\metaA \equiv \metaB) \mid (\lambda x.\metaA)(t)
\end{align*}
where $p$ ranges over sentence letters, $F$ over predicates, $t, t_i$ over terms, and $x$ over variables.
\end{definition}
```

**LaTeX Symbol**: Use `\Define` (mapped to `\Coloneq` producing `::=`) for inductive/BNF definitions, distinct from `\define` (single colon `:=`) used for definitional equations

**Placement**: After line 30 (syntactic primitives list), before "Derived Operators" subsection

---

### Finding 2: Non-Primitive Symbol Definitions (Line 34)

**Current State**: FIX comment requests quantifier definitions using lambda notation

**Lean Implementation** (Foundation/Syntax.lean:100-121):
```lean
def imp (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .or (.neg φ) ψ

def iff (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .and (imp φ ψ) (imp ψ φ)

def essence (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .ident (.and φ ψ) ψ

def ground (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .ident (.or φ ψ) ψ
```

**Note**: Lean code does NOT define quantifiers. This is because the Constitutive Foundation does NOT include first-order quantifiers - only lambda abstraction for predicate formation.

**Recommended LaTeX**:
```latex
\begin{remark}[Quantifiers]
First-order quantifiers are \textit{not} primitive in the Constitutive Foundation.
Generalized quantification is expressed via lambda abstraction:
\begin{itemize}
  \item Universal quantification: $\forall x.\metaA$ abbreviates $\forall(\lambda x.\metaA)$ where $\forall$ is a second-order predicate on properties
  \item Existential quantification: $\exists x.\metaA$ abbreviates $\exists(\lambda x.\metaA)$ where $\exists$ is a second-order predicate on properties
\end{itemize}
These are typically added in the Dynamical Foundation layer where contingent predication is supported.
\end{remark}
```

**Placement**: In the "Derived Operators" subsection (line 36+), after biconditional definition

**Rationale**: The FIX comment appears based on a misunderstanding. The Constitutive Foundation intentionally excludes first-order quantifiers - only lambda abstraction exists for building predicates from formulas.

---

### Finding 3: Term Algebra Definition (Line 130)

**Current State**: FIX comment requests term algebra definition matching Lean code

**Lean Implementation** (Foundation/Syntax.lean:38-66):
```lean
inductive Term where
  | var : String → Term
  | const : String → Term
  | app : String → List Term → Term

namespace Term
  partial def freeVars : Term → List String
    | var x => [x]
    | const _ => []
    | app _ ts => ts.flatMap fun t => t.freeVars

  partial def subst (t : Term) (x : String) (s : Term) : Term :=
    match t with
    | var y => if y = x then s else var y
    | const c => const c
    | app f ts => app f (ts.map fun t' => t'.subst x s)
end Term
```

**Recommended LaTeX**:
```latex
\begin{definition}[Term Algebra]\label{def:term-algebra}
The set $\Term$ of \emph{terms} is defined inductively:
\begin{align*}
  t \Define x \mid c \mid f(t_1, \ldots, t_n)
\end{align*}
where $x$ ranges over variables, $c$ over individual constants (0-place function symbols), and $f$ over $n$-place function symbols.

The \emph{free variables} $\FV(t)$ of a term are defined by:
\begin{align*}
  \FV(x) &= \{x\} \\
  \FV(c) &= \emptyset \\
  \FV(f(t_1, \ldots, t_n)) &= \bigcup_{i=1}^n \FV(t_i)
\end{align*}

\emph{Substitution} $t[s/x]$ (replacing $x$ with $s$ in $t$) is defined by:
\begin{align*}
  y[s/x] &= \begin{cases} s & \text{if } y = x \\ y & \text{otherwise} \end{cases} \\
  c[s/x] &= c \\
  f(t_1, \ldots, t_n)[s/x] &= f(t_1[s/x], \ldots, t_n[s/x])
\end{align*}
\end{definition}
```

**Placement**: Immediately before line 132 (variant assignment definition), in "Variable Assignment" subsection

**Note**: Requires defining `\FV` macro in notation file if not already present

---

### Finding 4: Reduction Operator (Line 249)

**Current State**: FIX comment requests adding reduction operator `\Rightarrow` defined as conjunction of essence and ground

**Lean Implementation**: No `reduction` definition exists in Foundation/Syntax.lean. This appears to be a theoretical extension not yet implemented.

**Recommended LaTeX**:
```latex
\begin{definition}[Reduction]\label{def:reduction}
\emph{Reduction} combines essence and ground:
\begin{align}
  \metaA \Rightarrow \metaB \define (\metaA \essence \metaB) \land (\metaA \ground \metaB)
\end{align}
This expresses that $\metaA$ is both a conjunctive part (essential to) and a disjunctive part (grounds) of $\metaB$.
\end{definition}
```

**Placement**: Immediately after def:essence-ground (line 256), before the remark about essence/ground interrelation

**Lean Recommendation**: Consider adding to Foundation/Syntax.lean:
```lean
/--
Reduction relation as derived: A ⇒ B := (A ⊑ B) ∧ (A ≤ B)
"A reduces to B" - A is both essential to and grounds B
-/
def reduction (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .and (essence φ ψ) (ground φ ψ)
```

**Note**: LaTeX symbol `\Rightarrow` already exists. For Lean notation, could use `⇒` (U+21D2).

---

## Recommendations

### Implementation Order

1. **Phase 1**: Add term algebra definition (line 130)
   - Clear technical content, no ambiguity
   - Directly mirrors Lean implementation

2. **Phase 2**: Add well-formed formulas definition (line 32)
   - Standard BNF notation
   - Consolidates syntax specification

3. **Phase 3**: Add reduction operator (line 249)
   - Simple extension of existing definitions
   - Consider corresponding Lean implementation

4. **Phase 4**: Add quantifier remark (line 34)
   - Clarifies intentional omission
   - Documents relationship to lambda abstraction
   - Lower priority (corrects misconception rather than filling gap)

### Notation Requirements

Ensure these macros exist in `logos-notation.sty`:
- `\Define` → `\Coloneq` (produces `::=` for inductive/BNF definitions) - **ADD THIS**
- `\define` (produces `:=` for definitional equations) - likely exists
- `\metaA`, `\metaB` (meta-variables for formulas) - likely exist
- `\Term` (term set) - may need adding
- `\FV` (free variables function) - may need adding
- Standard symbols: `\top`, `\bot`, `\neg`, `\land`, `\lor`, `\equiv`, `\Rightarrow` - should exist

**Notation Distinction**:
| Macro | Symbol | Usage |
|-------|--------|-------|
| `\Define` | `::=` | Inductive/BNF grammars (e.g., `t \Define x \mid c`) |
| `\define` | `:=` | Definitional equations (e.g., `A \to B \define \neg A \lor B`) |

### Semantic Linefeeds

All additions should follow semantic linefeeds rule (one sentence per line) per `.claude/rules/latex.md`.

### Cross-Reference Links

Update cross-references in existing definitions:
- Reference def:term-algebra from def:term-extension
- Reference def:wff from def:constitutive-model

## References

- Source File: `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`
- Lean Implementation: `Theories/Logos/SubTheories/Foundation/Syntax.lean`
- LaTeX Rules: `.claude/rules/latex.md`
- Notation File: `Theories/Logos/latex/logos-notation.sty`

## Next Steps

1. Create implementation plan with 4 phases matching findings above
2. Verify `logos-notation.sty` contains required macros
3. Implement LaTeX additions following semantic linefeeds
4. Consider parallel Lean implementation of reduction operator
5. Build PDF to verify no compilation errors
