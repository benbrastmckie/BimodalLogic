# Research Report: Task #684

**Task**: Revise semantics and notation conventions
**Started**: 2026-01-26T18:00:00Z
**Completed**: 2026-01-26T19:00:00Z
**Effort**: 4-5 hours
**Priority**: Medium
**Language**: latex
**Sources/Inputs**:
- Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (lines 235, 259, 260-295)
- Theories/Logos/SubTheories/Dynamics/Truth.lean
- Theories/Logos/SubTheories/Foundation/Semantics.lean
- Theories/Logos/SubTheories/Dynamics/Syntax.lean
**Artifacts**:
- specs/684_revise_semantics_and_notation_conventions/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Current LaTeX uses confusing variable notation where `τ` appears in evolution definition (line 195) but semantic clauses use `\history` macro inconsistently
- Lambda abstraction and quantification conventions (lines 259-295) need systematic revision to match Lean's explicit variable binding approach
- Lean implementation uses clear 5-parameter evaluation (M, τ, t, σ, idx) that should be reflected consistently in LaTeX notation
- Recommend: adopt `\tau` uniformly for evolutions, clarify lambda/quantifier binding to match Lean's `lambdaApp` and `all` patterns

## Context & Scope

Task 684 addresses two grouped TODO items from 03-DynamicsFoundation.tex:

1. **Line 235 TODO**: Revise dynamical semantics to evaluate sentences at model, evolutions, time, variable assignment, and temporal index, using `\tau` for evolutions
2. **Line 259 TODO**: Clean up lambda abstraction and quantification conventions where lambdas bind the last free variable (if any) and universal quantifiers quantify the last open variable (if any)

The research examines how the LaTeX presentation compares to the actual Lean implementation to identify notation inconsistencies and clarify the semantic evaluation scheme.

## Findings

### Current LaTeX Semantics Structure (Lines 258-295)

**Truth Evaluation Context**:
```latex
Truth is evaluated relative to a model M, world-history \history,
time x : D, variable assignment \assignment, and temporal index
\tempindex = ⟨i₁, i₂, ...⟩
```

**Inconsistency**: The LaTeX uses `\history` macro in semantic clauses but the evolution definition (line 195) introduces `τ` as the variable name. This creates confusion about what symbol represents evolutions.

**Current semantic clause pattern**:
```latex
M, \history, x, \assignment, \tempindex \trueat \metaA
```

### Lean Implementation Analysis (Truth.lean)

**Lean evaluation function signature** (lines 102-105):
```lean
def truthAt (M : CoreModel D) (τ : WorldHistory M.frame) (t : D)
    (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame)
    (idx : TemporalIndex D)
    : Formula → Prop
```

**Key observations**:
1. Uses `τ` consistently for world-histories (not `\history`)
2. Explicit 5 parameters: M, τ, t, σ, idx
3. Time membership proof `ht : t ∈ τ.domain` required but implicit in notation
4. Variable assignment `σ` matches LaTeX `\assignment`
5. Temporal index `idx` matches LaTeX `\tempindex`

**Parameter naming consistency**:
- Model: M (both)
- Evolution: **τ** (Lean) vs **\history** (LaTeX) - INCONSISTENT
- Time: **t** (Lean) vs **x** (LaTeX) - INCONSISTENT
- Assignment: **σ** (Lean) vs **\assignment** (LaTeX) - needs macro check
- Index: **idx** (Lean) vs **\tempindex** (LaTeX) - needs macro check

### Lambda Abstraction Convention (Lines 288-295, TODO line 259)

**Current LaTeX definition** (lines 290-295):
```latex
\begin{definition}[Lambda and Quantification]
  M, \history, x, \assignment, \tempindex \trueat (λv.\metaA)(t)
    ⟺ M, \history, x, \assignsub{\sem{t}^\assignment_M}{v}, \tempindex \trueat \metaA

  M, \history, x, \assignment, \tempindex \trueat ∀\metaA(v)
    ⟺ M, \history, x, \assignsub{s}{v}, \tempindex \trueat \metaA(v) for all s : \statespace
\end{definition}
```

**Issues identified**:
1. **Notation confusion**: `(λv.\metaA)(t)` vs `∀\metaA(v)` - inconsistent argument position
2. **Implicit binding**: TODO says "lambdas bind the last free variable (if any)" but definition uses explicit `v`
3. **Quantifier notation**: `∀\metaA(v)` suggests application but quantifiers should bind variables

**Lean implementation** (Truth.lean lines 184-189):
```lean
| Formula.all x φ =>
    -- ∀x.A: true iff A is true for all states s
    ∀ s : M.frame.State, truthAt M τ t ht (σ.update x s) idx φ
| Formula.lambdaApp x φ term =>
    -- (λx.A)(t): substitute term value for x
    truthAt M τ t ht (σ.update x (evalTermCore M σ term)) idx φ
```

**Key Lean patterns**:
1. `Formula.all x φ` - universal quantifier with explicit variable name `x` bound in `φ`
2. `Formula.lambdaApp x φ term` - lambda application with explicit variable `x`, formula `φ`, term `term`
3. Both use `σ.update x s` to extend assignment (not "bind last free variable")
4. Clear separation: `all` quantifies over states, `lambdaApp` substitutes term value

**Notation Definition 69-75**:
```latex
\begin{definition}[Quantifier Notation]
The notation ∀v.\metaA abbreviates ∀(λv.\metaA) where:
- λv.\metaA binds the variable v in \metaA
- ∀ is the universal quantifier applied to the resulting property
Similarly, ∃v.\metaA abbreviates ∃(λv.\metaA) where ∃ := ¬∀¬.
\end{definition}
```

**Confusion**: Definition 69-75 says `∀v.A` is syntactic sugar for `∀(λv.A)`, but Definition 290-295 treats lambda and quantifier as separate semantic clauses. This creates ambiguity about whether:
- (a) `∀v.A` is primitive syntax with special semantics, OR
- (b) `∀v.A` abbreviates `∀(λv.A)` and reduces to lambda application

**Lean approach**: Treats `all` and `lambdaApp` as SEPARATE constructors (Syntax.lean lines 85-88), suggesting (a) is correct.

### Constitutive Foundation Semantics Comparison

**Foundation layer verification** (Semantics.lean lines 84-92):
```lean
| ConstitutiveFormula.lambdaApp x φ t =>
    -- Lambda application: s verifies (λx.φ)(t) iff s verifies φ[⟦t⟧/x]
    verifies M (σ.update x (evalTerm M σ t)) s φ
```

**Key difference**: Constitutive layer uses VERIFICATION relation `M, σ, s ⊩⁺ φ` (hyperintensional), while Dynamics layer uses TRUTH relation `M, τ, t, σ, idx ⊨ φ` (intensional).

### Variable Naming Convention (NOTE line 286)

**LaTeX NOTE** (line 286):
```
NOTE: I want to avoid using x, y, z as first-order variables,
using v_1, v_2, v_3, ... instead since x, y, z are reserved
for times in the metalanguage.
```

**Current usage**:
- **Metalanguage times**: x, y, z (LaTeX lines 262, 268, 292, etc.)
- **Object language variables**: v (LaTeX line 292)
- **Lean times**: t, y (Truth.lean)
- **Lean variables**: x (Syntax.lean line 86-88)

**Inconsistency**: Lean uses `x` for bound variables in `all` and `lambdaApp`, conflicting with LaTeX's intended reservation of x/y/z for times.

## Recommendations

### 1. Adopt Uniform Evolution Notation (TODO line 235)

**Change**: Replace `\history` macro with `\tau` throughout semantic clauses to match:
- Evolution definition (line 195 uses τ)
- Lean implementation (uses τ consistently)
- Mathematical convention (τ commonly denotes time-indexed structures)

**Before**:
```latex
M, \history, x, \assignment, \tempindex \trueat \metaA
```

**After**:
```latex
M, τ, x, σ, i⃗ ⊨ A
```

**Rationale**: Using `τ` directly (not a macro) makes the notation self-documenting and matches Lean's explicit parameter naming.

### 2. Clarify Lambda/Quantifier Semantics (TODO line 259)

**Issue**: Current presentation conflates syntactic sugar (Definition 69-75) with semantic clauses (Definition 290-295).

**Recommendation**: Separate into two definitions:

**Definition A: Syntactic Conventions** (combine with line 49 metalinguistic conventions per FIX item 1)
```latex
\begin{definition}[Syntactic Sugar]
The following are abbreviations for primitive syntax:
- ∀v.A := ∀(λv.A) where λv.A binds variable v in A
- ∃v.A := ∃(λv.A) where ∃ := ¬∀¬
- A → B := ¬A ∨ B (material conditional)
- A ↔ B := (A → B) ∧ (B → A) (biconditional)
\end{definition}
```

**Definition B: Semantic Clauses for Primitives**
```latex
\begin{definition}[Lambda Application and Universal Quantification]
For primitive operators (not syntactic sugar):

M, τ, x, σ, i⃗ ⊨ (λv.A)(t) ⟺ M, τ, x, σ[⟦t⟧^σ_M / v], i⃗ ⊨ A

M, τ, x, σ, i⃗ ⊨ ∀(P) ⟺ M, τ, x, σ[s/v_last], i⃗ ⊨ P(v_last) for all s : S
  where v_last is the last free variable in P (if any)
\end{definition}
```

**Rationale**:
- Makes clear that `∀v.A` is syntactic sugar expanding to `∀(λv.A)`
- Semantic evaluation only needs clauses for primitive `∀` and `λ`
- Matches Lean's separation of `all` and `lambdaApp` constructors

### 3. Align Variable Naming with Lean

**Current LaTeX naming**:
- Times: x, y, z (metalanguage)
- Variables: v, v_1, v_2, ... (object language)

**Lean naming**:
- Times: t, y (lowercase)
- Variables: x (string identifier)

**Recommendation**: Document the divergence explicitly:

```latex
\begin{remark}[Naming Conventions]
In this LaTeX presentation:
- Metalanguage times are denoted x, y, z ∈ D
- Object language variables are denoted v₁, v₂, v₃, ...
- States are denoted s, t, r ∈ S

In the Lean implementation (Truth.lean):
- Times use t, y as identifiers
- Variables use x as String type
- States use s, t, r as identifiers

This notational divergence is intentional to avoid confusion
between metalanguage time variables and object language term variables.
\end{remark}
```

### 4. Semantic Evaluation Header Revision

**Current** (line 260-262):
```latex
Truth is evaluated relative to a model M, world-history \history,
time x : D, variable assignment \assignment, and temporal index
\tempindex = ⟨i₁, i₂, ...⟩:
```

**Recommended revision**:
```latex
Truth is evaluated relative to five parameters:
- M: a dynamical model
- τ: a world-history (evolution τ : X → S over convex X ⊆ D)
- x: a time point (x ∈ D such that x ∈ dom(τ))
- σ: a variable assignment (σ : Var → S)
- i⃗: a temporal index (i⃗ = ⟨i₁, i₂, ...⟩ storing times for recall operators)

Notation: M, τ, x, σ, i⃗ ⊨ A
```

**Rationale**: Explicit parameter list with types clarifies the evaluation scheme and matches Lean's function signature.

### 5. Address Quantifier Binding Ambiguity

**Current TODO says**: "universal quantifiers quantify the last open variable (if any)"

**Problem**: This is vague. What does "last open variable" mean?
- Leftmost free variable?
- Rightmost free variable?
- Variable with highest index?

**Lean approach**: `Formula.all x φ` explicitly names the bound variable `x`.

**Recommendation**: Match Lean's explicit binding:

```latex
The universal quantifier ∀ applies to a property (one-place predicate):
  ∀(P) where P : S → Prop

The syntactic sugar ∀v.A abbreviates ∀(λv.A), which:
1. First applies lambda to create property λv.A : S → Prop
2. Then applies universal quantifier to that property

Semantic evaluation:
  M, τ, x, σ, i⃗ ⊨ ∀v.A
  ⟺ M, τ, x, σ, i⃗ ⊨ ∀(λv.A)           [by syntactic sugar]
  ⟺ for all s : S, M, τ, x, σ[s/v], i⃗ ⊨ A  [by ∀ and λ semantics]
```

**Avoids**: Vague "last free variable" language
**Achieves**: Explicit reduction via syntactic sugar + primitive semantics

## Decisions

1. **Use τ consistently**: Replace `\history` with `\tau` in semantic clauses to match evolution definition and Lean implementation
2. **Separate sugar from semantics**: Move quantifier notation (∀v.A := ∀(λv.A)) to syntactic conventions section, keep only primitive ∀ and λ in semantic clauses
3. **Document naming divergence**: Explicitly note LaTeX uses x/y/z for times while Lean uses t/y, and justify the choice
4. **5-parameter header**: Rewrite truth evaluation introduction to list all 5 parameters explicitly with types

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Changing notation breaks cross-references | Medium | Use search-replace carefully, check all citations |
| Reader confusion with syntactic sugar | Medium | Add explicit remark explaining reduction sequence |
| Lean/LaTeX naming divergence | Low | Document intentional differences with clear rationale |
| Macro replacement errors | High | Keep `\history` macro defined as `\tau` for backward compatibility initially |

## Appendix

### Key LaTeX Lines Examined

- **Line 195**: Evolution definition using `τ : X → \statespace`
- **Line 214**: World-history definition using `\history` macro
- **Line 235**: TODO about revising dynamical semantics
- **Line 259**: TODO about lambda/quantifier conventions
- **Line 260-262**: Current truth evaluation header
- **Lines 265-271**: Atomic truth definition
- **Lines 284-295**: Lambda abstraction and quantification definition
- **Line 286**: NOTE about variable naming (v₁, v₂, ... instead of x, y, z)

### Lean Files Examined

- **Truth.lean lines 102-105**: `truthAt` function signature
- **Truth.lean lines 184-189**: `all` and `lambdaApp` semantic clauses
- **Syntax.lean lines 85-88**: `Formula.all` and `Formula.lambdaApp` constructors
- **Semantics.lean lines 84-92**: Constitutive layer `lambdaApp` verification

### Related Context

This research connects to:
- **Task 683**: Variable naming convention updates (completed)
- **Task 682**: Dynamics foundation LaTeX fixes (completed, includes notation consistency)
- **Task 690**: Constitutive foundation LaTeX issues (includes quantifier notation per line 49)

### Search Queries Used

1. `**/*.lean` - Found 1200+ Lean files
2. `Theories/Logos/**/*.lean` - Found 27 Logos-specific files
3. `**/03-DynamicsFoundation.tex` - Found target LaTeX file
4. `lambda|quantif|forall|exists` in Theories/Logos - Found 23KB of matches showing lambda/quantifier usage patterns
