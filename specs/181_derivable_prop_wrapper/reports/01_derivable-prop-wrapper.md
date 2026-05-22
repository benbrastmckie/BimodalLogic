# Research Report: Derivable Prop-Valued Wrapper

**Task**: #181 -- Add Derivable Prop-valued wrapper alongside DerivationTree
**Date**: 2026-05-22
**Session**: sess_1779465180_1e8c5e

## Summary

This report provides a complete analysis for adding a `Derivable` Prop-valued wrapper (`def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)`) alongside the existing Type-valued `DerivationTree`. The wrapper enables `simp` and `aesop` integration for derivability goals while preserving the computable proof tree structure for height functions, pattern matching, and Metalogic infrastructure. All proposed definitions have been verified to compile against the current codebase via `lean_run_code`.

## 1. Current DerivationTree API Surface

### 1.1 Inductive Type

Defined in `Theories/Bimodal/ProofSystem/Derivation.lean`:

```lean
inductive DerivationTree : Context -> Formula -> Type where
  | axiom (G : Context) (p : Formula) (h : Axiom p) : DerivationTree G p
  | assumption (G : Context) (p : Formula) (h : p in G) : DerivationTree G p
  | modus_ponens (G : Context) (p ps : Formula)
      (d1 : DerivationTree G (p.imp ps))
      (d2 : DerivationTree G p) : DerivationTree G ps
  | necessitation (p : Formula)
      (d : DerivationTree [] p) : DerivationTree [] (Formula.box p)
  | temporal_necessitation (p : Formula)
      (d : DerivationTree [] p) : DerivationTree [] (Formula.all_future p)
  | temporal_duality (p : Formula)
      (d : DerivationTree [] p) : DerivationTree [] p.swap_temporal
  | weakening (G D : Context) (p : Formula)
      (d : DerivationTree G p)
      (h : G <= D) : DerivationTree D p
```

Key properties:
- **7 constructors** covering axioms, assumptions, modus ponens, two necessitation rules, temporal duality, and weakening
- **Type-valued** (not Prop) -- enables pattern matching and computable functions
- Notation: `G |- p` for `DerivationTree G p`, `|- p` for `DerivationTree [] p`

### 1.2 Computable Functions on DerivationTree

The following functions require pattern matching on the Type-valued tree:

| Function | Location | Usage |
|----------|----------|-------|
| `height` | Derivation.lean | Well-founded recursion measure for deduction theorem |
| `isDenseCompatible` | Derivation.lean | Frame class guard for soundness theorem |
| `isDiscreteCompatible` | Derivation.lean | Frame class guard for discrete soundness |
| `usedFormulas` | MaximalConsistent.lean | Extract formulas used in a derivation |
| `collectDerivInl` | Lifting.lean | Atom collection in conservative extension |
| `substDerivation` | Lifting.lean | Substitution on derivation trees |

These functions are the primary reason `DerivationTree` must remain Type-valued.

### 1.3 Usage Statistics

Grep across the codebase reveals:
- **300+ references** to `DerivationTree` across 20+ files
- **Metalogic/** uses DerivationTree for structural operations (height, pattern matching, induction)
- **Theorems/** uses DerivationTree constructors directly to build proof trees
- **Automation/** has custom tactics that inspect DerivationTree goals
- **40+ uses** of `Nonempty (DerivationTree ...)` already exist in Metalogic/ for consistency/completeness

### 1.4 Existing `Nonempty (DerivationTree ...)` Pattern

The codebase already uses `Nonempty (DerivationTree G p)` in several places:

```lean
-- MaximalConsistent.lean
def Consistent (G : Context) : Prop := -Nonempty (DerivationTree G Formula.bot)

-- Completeness.lean
theorem completeness : valid p -> Nonempty (DerivationTree [] p)

-- Bundle/Construction.lean
def ContextDerivable (G : List Formula) (p : Formula) : Prop :=
  Nonempty (Bimodal.ProofSystem.DerivationTree G p)
```

This confirms that the `Nonempty` wrapper pattern is already established in the codebase. The `ContextDerivable` in `Bundle/Construction.lean` is essentially the same definition we propose, but scoped locally to that file.

## 2. Proposed Derivable Definition and Core Lemmas

### 2.1 Core Definition

```lean
/-- Prop-valued derivability predicate.
    `Derivable G p` holds iff there exists a derivation tree for p from G. -/
def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)
```

### 2.2 Coercion from DerivationTree

```lean
/-- Lift a concrete derivation tree to a derivability proof. -/
theorem Derivable.ofTree {G : Context} {p : Formula}
    (d : DerivationTree G p) : Derivable G p :=
  Nonempty.intro d
```

### 2.3 Core Lemmas (Mirroring All 7 Constructors)

Each DerivationTree constructor gets a corresponding Derivable lemma:

```lean
/-- Axiom rule. -/
theorem Derivable.ax (G : Context) (p : Formula) (h : Axiom p) : Derivable G p :=
  Nonempty.intro (DerivationTree.axiom G p h)

/-- Assumption rule. -/
theorem Derivable.assume (G : Context) (p : Formula) (h : p in G) : Derivable G p :=
  Nonempty.intro (DerivationTree.assumption G p h)

/-- Modus ponens. -/
theorem Derivable.mp (G : Context) (p ps : Formula)
    (h1 : Derivable G (p.imp ps)) (h2 : Derivable G p) : Derivable G ps

/-- Necessitation (modal). -/
theorem Derivable.nec {p : Formula}
    (h : Derivable [] p) : Derivable [] (Formula.box p)

/-- Temporal necessitation. -/
theorem Derivable.temp_nec {p : Formula}
    (h : Derivable [] p) : Derivable [] (Formula.all_future p)

/-- Temporal duality. -/
theorem Derivable.temp_dual {p : Formula}
    (h : Derivable [] p) : Derivable [] p.swap_temporal

/-- Weakening. -/
theorem Derivable.weaken {G D : Context} {p : Formula}
    (h : Derivable G p) (hsub : G <= D) : Derivable D p
```

All of these have been verified to compile. The proofs follow a uniform pattern: destructure `Nonempty` with `obtain`, apply the DerivationTree constructor, wrap in `Nonempty.intro`.

### 2.4 Key Derived Lemmas

Beyond the basic constructors, these derived lemmas should be added:

```lean
/-- Derivable implies Consistent (contrapositive). -/
theorem Derivable.consistent_of_not_bot {G : Context}
    (h : -Derivable G Formula.bot) : Consistent G := h

/-- Restate Consistent in terms of Derivable. -/
theorem consistent_iff_not_derivable_bot (G : Context) :
    Consistent G <-> -Derivable G Formula.bot := Iff.rfl

/-- Proof irrelevance: any two proofs of Derivable are equal. -/
theorem Derivable.proof_irrel {G : Context} {p : Formula}
    (h1 h2 : Derivable G p) : h1 = h2 :=
  Subsingleton.elim h1 h2
```

### 2.5 Notation

Two options for notation:

**Option A (recommended)**: Dedicated notation with `!` suffix
```lean
notation:50 G " |-! " p => Derivable G p
notation:50 "|-! " p => Derivable [] p
```

This follows the FormalizedFormalLogic/Foundation convention where `|-!` denotes Prop-valued provability (their `Prov` uses `|-!` for the Nonempty-wrapped version).

**Option B**: No new notation, just use `Derivable G p`

Option A is recommended because:
1. It parallels the existing `|-` notation for DerivationTree
2. It follows Foundation's established convention
3. It makes the distinction between Type and Prop clear at the call site

## 3. File Placement Recommendation

### Recommended: New file `Theories/Bimodal/ProofSystem/Derivable.lean`

**Rationale**:

1. **Separation of concerns**: `Derivation.lean` is 352 lines and focused on the Type-valued tree with its height functions and frame compatibility predicates. Adding Derivable there would mix two different abstraction levels.

2. **Import graph**: `Derivable.lean` imports only `Derivation.lean` and adds no new dependencies. Downstream files that need Derivable can import it without pulling in additional transitive dependencies.

3. **Precedent**: The existing `Bundle/Construction.lean` already defines a local `ContextDerivable` for its own needs, confirming that a separate Prop-level abstraction is natural.

4. **Maintainability**: Future additions to the Derivable API (more derived lemmas, simp/aesop attributes, transitivity lemmas) can grow in this file without bloating Derivation.lean.

### File structure:

```
Theories/Bimodal/ProofSystem/
  Axioms.lean          -- Axiom schemata (existing)
  Derivation.lean      -- DerivationTree : Type (existing)
  Derivable.lean       -- Derivable : Prop (NEW)
  Substitution.lean    -- Substitution rules (existing)
```

### Import additions:

The `ProofSystem.lean` aggregator file should add:
```lean
import Bimodal.ProofSystem.Derivable
```

This makes `Derivable` available to all downstream users of the proof system.

## 4. Simp/Aesop Integration Strategy

### 4.1 The Original Problem

The task 179 research confirmed that aesop integration with Type-valued `DerivationTree` fails due to "proof reconstruction errors." Specifically:

- `aesop` generates Prop-valued intermediate goals during its search
- When the target is `Type`-valued (`DerivationTree G p`), aesop cannot reconstruct the proof term from its Prop-level search
- The existing `AesopRules.lean` was deprecated (2026-01-17) in favor of `modal_search` for this reason
- Verified: `aesop` on a bare `DerivationTree` goal fails with "made no progress"

### 4.2 How Derivable Fixes This

With `Derivable : Prop`:
- `simp` can reason about Prop goals using standard rewriting
- `aesop` can search through Prop goals without proof reconstruction issues
- Proof irrelevance (`Subsingleton.elim`) means aesop never needs to produce a specific witness
- The `@[aesop]` attributes on Derivable lemmas will register correctly

### 4.3 Recommended Attribute Strategy

```lean
-- Base rules (safe -- always applicable)
@[aesop safe apply]  theorem Derivable.ax ...
@[aesop safe apply]  theorem Derivable.assume ...
@[aesop safe apply]  theorem Derivable.weaken ...

-- Inference rules (unsafe with probability -- may branch)
@[aesop unsafe 50% apply]  theorem Derivable.mp ...

-- Necessitation (safe but restricted to empty context)
@[aesop safe apply]  theorem Derivable.nec ...
@[aesop safe apply]  theorem Derivable.temp_nec ...
@[aesop safe apply]  theorem Derivable.temp_dual ...
```

**Key design decisions**:

1. **`mp` must be `unsafe`** with moderate probability (50%). Modus ponens introduces a metavariable for the intermediate formula, which causes unbounded search if marked `safe`. This mirrors the existing `AesopRules.lean` design choice.

2. **`ax` is `safe`** because Lean's unifier determines whether a formula matches an axiom schema -- there is no search branching.

3. **`weaken` is `safe`** because it only needs a subset proof, which `simp` can typically discharge.

4. **Consider a custom rule set** (`TMDerivable`). The rule set declaration must be in a separate file that is imported by the file registering rules (Lean 4 aesop constraint -- rule sets are not visible in the declaring file). Alternatively, register on the default rule set initially for simplicity.

### 4.4 Simp Lemmas

```lean
@[simp] theorem Derivable.ax_simp (G : Context) (p : Formula) (h : Axiom p) :
    Derivable G p := Derivable.ax G p h

@[simp] theorem Derivable.assume_simp (G : Context) (p : Formula) (h : p in G) :
    Derivable G p := Derivable.assume G p h
```

**Warning**: Do not mark `Derivable.mp` as `@[simp]` -- it would cause infinite loops due to the metavariable in the antecedent.

### 4.5 Interaction with Existing Tactics

The existing custom tactics in `Automation/Tactics.lean` pattern-match on `DerivationTree` goals:

```lean
| .app (.app (.const ``DerivationTree _) _context) formula => ...
```

These will continue to work unchanged on DerivationTree goals. For Derivable goals, we have two options:

**Option A (recommended for now)**: Do not modify existing tactics. Users choose between:
- `DerivationTree` goals: use `modal_search`, `apply_axiom`, `try_assumption`, etc.
- `Derivable` goals: use `aesop`, `simp`, or manual `apply` chains

**Option B (future)**: Add parallel tactic patterns that recognize `Derivable` goals and internally construct `DerivationTree` proofs, then wrap in `Nonempty.intro`.

## 5. Impact Analysis on Existing Code

### 5.1 No Breaking Changes

Adding `Derivable.lean` introduces only new definitions. No existing code needs modification because:
- `DerivationTree` remains unchanged
- Existing notation `|-` and `|- ` remains unchanged
- No existing file imports `Derivable.lean` initially
- The `Consistent` definition (`-Nonempty (DerivationTree G Formula.bot)`) is definitionally equal to `-Derivable G Formula.bot`

### 5.2 Files That Could Benefit from Derivable

| File | Current Pattern | Potential Simplification |
|------|----------------|------------------------|
| `MaximalConsistent.lean` | `Nonempty (DerivationTree G Formula.bot)` | `Derivable G Formula.bot` |
| `Completeness.lean` | `Nonempty (DerivationTree [] p)` | `Derivable [] p` |
| `RestrictedMCS.lean` | `Nonempty (DerivationTree L Formula.bot)` | `Derivable L Formula.bot` |
| `AlgebraicCompleteness.lean` | `-Nonempty (DerivationTree [] p.neg)` | `-Derivable [] p.neg` |
| `Bundle/Construction.lean` | Local `ContextDerivable` | Could import global `Derivable` |
| `Chronicle/RRelation.lean` | `Nonempty (DerivationTree L p)` | `Derivable L p` |
| `Decidability/FMP/*.lean` | `Nonempty (DerivationTree [] phi)` | `Derivable [] phi` |

**Migration recommendation**: These changes are purely cosmetic and should be done in a separate follow-up task (not task 181) to keep the initial PR small and reviewable.

### 5.3 Files That MUST Keep DerivationTree (Type-Valued)

| File | Reason |
|------|--------|
| `Derivation.lean` | `height`, `isDenseCompatible`, `isDiscreteCompatible` require pattern matching |
| `MaximalConsistent.lean` | `usedFormulas` extracts data from the tree |
| `DeductionTheorem.lean` | Structural recursion on derivation tree by height |
| `Soundness.lean` | `induction d` on derivation tree structure |
| `Lifting.lean` | `collectDerivInl`, `substDerivation` operate on tree structure |
| All `Theorems/*.lean` | Build explicit proof trees using constructors |

These files fundamentally need the Type-valued tree and should not be changed.

## 6. Mathlib Precedent for This Pattern

### 6.1 Nonempty Wrappers in Mathlib

Mathlib uses `Nonempty` wrappers in several patterns:

- `Nonempty (PLift a)` paired with concrete `PLift a` terms
- `nonempty_subtype` providing `Nonempty (Subtype p) <-> Exists p`
- `Nonempty.some` for extracting witnesses when needed

The general pattern is: Type-valued inductive for computation, Prop-valued `Nonempty` wrapper for logical reasoning.

### 6.2 FormalizedFormalLogic/Foundation Pattern

The most directly relevant precedent is Foundation's modal logic library:

```lean
-- Foundation uses:
class Entailment (S : Type*) (F : Type*) where
  Prov : S -> F -> Prop
-- With notation: S |- p : Prop and S |-! p : Type (Nonempty wrapper)
```

Foundation actually inverts the convention: their base is Prop and the `!` suffix denotes Type. In ProofChecker's case, the base is Type and we propose the `!` suffix for Prop. This is fine because ProofChecker's architecture is structurally different (explicit derivation trees vs. typeclass-based provability).

### 6.3 Category Theory Pattern

Mathlib's category theory uses a similar dual pattern:
- Concrete morphisms `X --> Y : Type` for computation
- `Nonempty (X --> Y)` for existence reasoning

## 7. Implementation Recommendations

### 7.1 Phase 1: Core Definition (Task 181 Scope)

Create `Theories/Bimodal/ProofSystem/Derivable.lean` with:

1. `Derivable` definition
2. `Derivable.ofTree` coercion
3. All 7 constructor-mirroring lemmas (`ax`, `assume`, `mp`, `nec`, `temp_nec`, `temp_dual`, `weaken`)
4. Notation `|-!` (optional, can defer)
5. `consistent_iff_not_derivable_bot` bridge lemma
6. Module docstring explaining the relationship to DerivationTree

Update `Theories/Bimodal/ProofSystem.lean` to include the new import.

### 7.2 Phase 2: Aesop Integration (Can Be Same Task or Follow-Up)

Add `@[aesop]` attributes to the Derivable lemmas:
- `@[aesop safe apply]` on `ax`, `assume`, `weaken`, `nec`, `temp_nec`, `temp_dual`
- `@[aesop unsafe 50% apply]` on `mp`

This requires importing `Aesop` in `Derivable.lean`. Since `Aesop` is already a project dependency (used in `AesopRules.lean`), this adds no new dependency.

### 7.3 Phase 3: Migration (Follow-Up Task)

Replace `Nonempty (DerivationTree ...)` patterns across the codebase with `Derivable`. This is cosmetic but improves readability.

### 7.4 Naming Convention

| DerivationTree Constructor | Derivable Lemma | Rationale |
|---------------------------|-----------------|-----------|
| `DerivationTree.axiom` | `Derivable.ax` | Avoid clash with `Axiom` type |
| `DerivationTree.assumption` | `Derivable.assume` | Shorter, standard |
| `DerivationTree.modus_ponens` | `Derivable.mp` | Standard abbreviation |
| `DerivationTree.necessitation` | `Derivable.nec` | Standard abbreviation |
| `DerivationTree.temporal_necessitation` | `Derivable.temp_nec` | Parallel naming |
| `DerivationTree.temporal_duality` | `Derivable.temp_dual` | Parallel naming |
| `DerivationTree.weakening` | `Derivable.weaken` | Verb form |

**Alternative naming**: Use full names (`Derivable.axiom_rule`, `Derivable.modus_ponens`, etc.) for maximum clarity. The shorter names are recommended because:
1. They follow the existing abbreviation patterns in `Combinators.lean` (`mp`, `imp_trans`)
2. They are unambiguous in the `Derivable` namespace
3. They reduce line length in proof terms

### 7.5 Estimated Effort

- **Phase 1**: ~100 lines of Lean code, ~30 minutes implementation time
- **Phase 2**: ~10 additional attribute annotations, ~15 minutes
- **Phase 3**: ~50 find-and-replace changes across 10 files, separate task

## 8. Verified Code Snippet

The following complete definition has been verified to compile against the current codebase:

```lean
import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Context

open Bimodal.Syntax
open Bimodal.ProofSystem

def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)

theorem Derivable.ofTree {G : Context} {p : Formula}
    (d : DerivationTree G p) : Derivable G p := Nonempty.intro d

theorem Derivable.ax (G : Context) (p : Formula) (h : Axiom p) : Derivable G p :=
  Nonempty.intro (DerivationTree.axiom G p h)

theorem Derivable.assume (G : Context) (p : Formula) (h : p in G) : Derivable G p :=
  Nonempty.intro (DerivationTree.assumption G p h)

theorem Derivable.mp (G : Context) (p ps : Formula)
    (h1 : Derivable G (p.imp ps)) (h2 : Derivable G p) : Derivable G ps := by
  obtain |d1| := h1; obtain |d2| := h2
  exact Nonempty.intro (DerivationTree.modus_ponens G p ps d1 d2)

theorem Derivable.weaken {G D : Context} {p : Formula}
    (h : Derivable G p) (hsub : G <= D) : Derivable D p := by
  obtain |d| := h
  exact Nonempty.intro (DerivationTree.weakening G D p d hsub)

theorem Derivable.nec {p : Formula}
    (h : Derivable [] p) : Derivable [] (Formula.box p) := by
  obtain |d| := h
  exact Nonempty.intro (DerivationTree.necessitation p d)

theorem Derivable.temp_nec {p : Formula}
    (h : Derivable [] p) : Derivable [] (Formula.all_future p) := by
  obtain |d| := h
  exact Nonempty.intro (DerivationTree.temporal_necessitation p d)

theorem Derivable.temp_dual {p : Formula}
    (h : Derivable [] p) : Derivable [] p.swap_temporal := by
  obtain |d| := h
  exact Nonempty.intro (DerivationTree.temporal_duality p d)
```

**Verified properties**:
- Proof irrelevance: `Subsingleton.elim h1 h2` works for any two `Derivable G p` proofs
- Consistent bridge: `Consistent G <-> -Derivable G Formula.bot` is `Iff.rfl`
- Basic usage: `Derivable.mp _ p q (Derivable.assume _ _ (by simp)) (Derivable.assume _ _ (by simp))` compiles

## References

- Task 179 research: `specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md` (Section 5.1, Tier B recommendation 7)
- Task 179 team research: `specs/179_research_lean4_tactics_infrastructure/reports/01_team-research.md` (aesop failure analysis)
- Existing `ContextDerivable`: `Theories/Bimodal/Metalogic/Bundle/Construction.lean:166`
- Existing `Consistent`: `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean:59`
- FormalizedFormalLogic/Foundation: Entailment typeclass pattern
- AesopRules.lean deprecation notice: `Theories/Bimodal/Automation/AesopRules.lean:12-17`
