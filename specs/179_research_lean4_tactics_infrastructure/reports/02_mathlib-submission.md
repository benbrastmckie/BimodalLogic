# Research Report: Mathlib Submission Compatibility Analysis

**Task**: #179 — Research Lean 4 Tactics Infrastructure (Round 2: Mathlib Compatibility)
**Date**: 2026-05-20
**Session**: sess_1779313857_e32cd5

## Summary

This report analyzes what would be required to submit ProofChecker (or parts of it) to Mathlib. The central conclusion is that **full submission to Mathlib is neither practical nor advisable**, but maintaining a **Mathlib-compatible standalone library** is achievable and provides the best of both worlds. Several structural patterns in the codebase would need significant rework for Mathlib compliance, while the domain itself (bimodal temporal-modal logic) falls outside Mathlib's current scope and community expertise.

## 1. Mathlib Submission Requirements and Review Process

### Current PR Process (2025-2026)

The Mathlib contribution workflow operates through GitHub PRs with a structured review system:

1. **Pre-submission**: Discuss plans on Zulip (mathlib4 channel) before writing code. This is strongly recommended for any non-trivial addition.
2. **PR creation**: Small, self-contained PRs are strongly preferred. The guidance states: "try to make many PRs containing small, self-contained pieces; in general, the smaller the better."
3. **Review**: Both maintainers and community members review for style, documentation, location, improvements, and library integration. Non-maintainer reviews are welcomed and encouraged.
4. **Merge queue**: Approved PRs receive "maintainer-merge" label, then "ready-to-merge" is auto-added, and an automated system processes merges.

### Review Timeline

- **Median wait time**: Approximately 2 weeks (as of 2025-2026)
- **Backlog**: ~300 PRs in queue at any given time
- **Goal**: The Mathlib Initiative targets review response under 1 week for 90% of cycles by September 2026
- **Large additions**: Can take significantly longer (months) as they require expert review and often multiple revision cycles

### Minimum Requirements for Acceptance

1. **No `sorry`**: All code must compile without errors or `sorry` on the master branch
2. **Style compliance**: Must follow naming conventions, formatting rules, documentation standards
3. **Generality**: Code must be sufficiently general and well-integrated with existing library
4. **Documentation**: Module docstrings (`/-! ... -/`) and declaration docstrings (`/-- ... -/`) required
5. **Copyright headers**: Standard copyright/author headers required on all files
6. **AI disclosure**: Any AI-generated code must be disclosed; "LLM-generated" label applied; AI code "fails to meet [Mathlib's] bar by a large margin" per the contribution guide

### Large Projects vs Incremental PRs

- **Small contributions** (fixes, single lemmas): Nearly always welcome
- **Extended theories** (adding to existing areas): Almost always welcome
- **New theories** (entirely new areas): The contribution guide suggests considering "standalone repositories with mathlib as a dependency" for specialized domains or rapid development

**Assessment for ProofChecker**: A brand-new area (bimodal temporal-modal logic TM) with 109,000 lines of code would face the "new theory" guidance. Mathlib would likely recommend maintaining it as a standalone library.

## 2. Naming Conventions and Style Guide Compliance

### Mathlib Naming Rules

Mathlib uses a systematic naming convention:

| Category | Convention | Example |
|----------|-----------|---------|
| Types, Props | `UpperCamelCase` | `Formula`, `DerivationTree`, `TaskFrame` |
| Theorems, terms | `snake_case` | `succ_ne_zero`, `mul_comm`, `lt_of_succ_le` |
| Hypotheses in names | Connected by `_of_` | `lt_of_not_ge`, `lt_of_le_of_ne` |
| Left/right variants | `_left`/`_right` suffix | `add_le_add_left` |
| Symbols to words | Standardized abbreviations | `imp` for `→`, `neg` for `¬`, `box` for `□` |

### Current ProofChecker Naming: Compliance Gaps

**Partially compliant names** (would need adjustment):

| Current Name | Issue | Mathlib-Style Name |
|-------------|-------|-------------------|
| `ecq` | Opaque abbreviation | `bot_of_and_neg` or `absurd_of_pair` |
| `raa` | Opaque abbreviation | `imp_bot_imp` or `neg_imp_of_imp` |
| `efq` | Opaque abbreviation | `neg_imp` or `imp_of_neg` |
| `lce` | Opaque abbreviation | `and_left` or `conj_elim_left` |
| `rce` | Opaque abbreviation | `and_right` or `conj_elim_right` |
| `ldi` | Opaque abbreviation | `or_inl` or `disj_intro_left` |
| `rdi` | Opaque abbreviation | `or_inr` or `disj_intro_right` |
| `rcp` | Opaque abbreviation | `imp_of_neg_imp_neg` or `contrapose` |
| `lem` | Ambiguous (lemma?) | `em` (Mathlib standard for excluded middle) |
| `dni` | Opaque abbreviation | `not_not_intro` |

**Names that are mostly fine** (descriptive, snake_case):

| Current Name | Assessment |
|-------------|-----------|
| `t_box_to_diamond` | Good descriptive pattern, though Mathlib might prefer `diamond_of_box` |
| `box_contrapose` | Good |
| `box_disj_intro` | Good |
| `s5_diamond_box` | Acceptable, though namespace-qualified would be cleaner |
| `imp_trans` | Standard |
| `identity` | Fine for a combinator name |

**Deeply problematic names** (Metalogic abbreviations):

| Name | Meaning | Issue |
|------|---------|-------|
| `bfmcs` | "bounded finitely maximal consistent set" | Completely opaque |
| `drm` | "defect-reducing maximal (extension)" | Completely opaque |
| `cud` | unknown | Completely opaque |
| `sdc` | unknown | Completely opaque |
| `dd_` | "defect-directed (chain)" | Opaque prefix |
| `tc_` | "temporal chain" | Opaque prefix |
| `fuc_` | "forward until chain" | Opaque prefix |
| `buc_` | "backward until chain" | Opaque prefix |

**Mathlib explicitly prohibits** opaque abbreviations. Every name should be guessable from the mathematical content.

### Mathlib Naming for Logic (Reference: `FirstOrder.Language`)

Mathlib's existing model theory uses patterns like:
- `FirstOrder.Language.Theory` — namespace qualification for domain
- `FirstOrder.Language.Sentence` — descriptive type names
- `FirstOrder.Language.Theory.IsComplete` — property as qualified name

The ProofChecker project would need a namespace like `Bimodal.TM` or `Modal.Bimodal` with theorem names following the `_of_` / descriptive pattern.

## 3. Import/Dependency Compatibility

### Current Mathlib Dependencies

The project imports from these Mathlib modules (40 import statements across 20 files):

| Category | Imports | Files Using |
|----------|---------|-------------|
| Order/Algebra | `Algebra.Order.Group.Defs`, `Algebra.Order.Group.Int`, `Algebra.Order.Ring.Rat`, `Algebra.Order.Archimedean.Basic` | TaskFrame, Soundness, Tests |
| Order theory | `Order.Zorn`, `Order.BooleanAlgebra.*`, `Order.SuccPred.*`, `Order.Basic`, `Order.CountableDenseLinearOrder` | MaximalConsistent, BooleanStructure, Completeness |
| Data | `Data.Rat.*`, `Data.Finset.*`, `Data.Fintype.*`, `Data.Set.Finite.Basic`, `Data.Setoid.Basic`, `Data.List.Chain`, `Data.Int.SuccPred`, `Data.Finite.Defs`, `Data.Countable.Basic` | Chronicle, Decidability, Metalogic |
| Topology | `Topology.Instances.Real.Lemmas`, `Topology.Instances.NNReal.Lemmas` | ChronicleToCountermodel |
| Tactic | `Tactic.DeriveCountable` | ConservativeExtension |

**Key observation**: The project uses Mathlib as a *utility library* for algebraic/order structures, not as a foundation for its core logic types. There are no conflicts because the project defines entirely new types (`Formula`, `DerivationTree`, `TaskFrame`, `Axiom`) that do not overlap with anything in Mathlib.

### Does Mathlib Already Have Modal Logic?

**No.** Confirmed by three independent checks:

1. **Loogle search** for "Kripke": zero results
2. **LeanSearch** for "modal logic Kripke frame accessibility relation": zero relevant results (returned `RelEmbedding.acc` — unrelated)
3. **LeanFinder** for "modal logic box diamond necessity possibility operator": zero relevant results (returned `Heyting.term` and `FirstOrder` notation — unrelated)
4. **Mathlib overview page**: No section for modal logic, temporal logic, proof theory, or Kripke semantics

The closest Mathlib has is `Mathlib.ModelTheory.*` which covers first-order model theory (languages, structures, satisfiability) — a completely different formalism.

### FormalizedFormalLogic/Foundation: The Key Reference

Foundation is the most relevant existing Lean 4 formalization of modal logic:
- **195 files** in `Modal/` directory alone
- Covers K, T, S4, S5, GL, Grz, and more
- Uses Hilbert-style systems with parameterized axiom sets
- Includes Kripke completeness proofs
- Has a `Vospiel` module providing "supplemental definitions and theorems for mathlib"
- **Does NOT submit its modal logic to Mathlib** — it maintains as a standalone library with Mathlib as a dependency

**Key architectural difference from ProofChecker**:

| Aspect | Foundation | ProofChecker |
|--------|-----------|-------------|
| Formula type | `Formula α` (polymorphic over atoms) | `Formula` (fixed `Atom` type) |
| Axiom encoding | `Axiom α := Set (Formula α)` | `inductive Axiom : Formula → Type` |
| Entailment | Typeclass-based (`Entailment S F`) | Concrete `DerivationTree` inductive |
| Frame | `structure Frame` (World + Rel) | `structure TaskFrame D` (specialized) |
| Kripke model | `structure Model extends Frame` | `TaskModel` with world histories |
| Scope | General modal logic cube | Single bimodal logic TM |

Foundation's choice to remain standalone despite being the most comprehensive Lean 4 modal logic library is strong evidence that ProofChecker should do the same.

## 4. Docstring and Documentation Requirements

### Mathlib Documentation Standards

**Module docstrings** (`/-! ... -/`): Required at the top of every file. Must include:
- Title
- Summary of main definitions and theorems
- Notation used (if applicable)
- Literature references (if applicable)

**Declaration docstrings** (`/-- ... -/`): Expected on all public definitions and theorems. Multi-line docs should not indent subsequent lines.

**File headers**: Must include copyright, author list, module declaration.

### ProofChecker's Current Compliance

**Good news**: The project has strong docstring coverage.
- 199 of 207 files (96%) have module docstrings
- Major definitions and theorems have declaration docstrings
- Module docstrings follow the `/-! ... -/` format correctly

**Gaps for Mathlib compliance**:

1. **No copyright headers**: Files start with `import` directly, without a copyright/author block. Mathlib requires:
   ```lean
   /-
   Copyright (c) 2024 Author Name. All rights reserved.
   Released under Apache 2.0 license as described in the file LICENSE.
   Authors: Author Name
   -/
   ```

2. **Some internal definitions lack docstrings**: While major theorems are documented, helper lemmas and intermediate definitions in Metalogic/ sometimes lack docstrings.

3. **Line length**: Mathlib requires lines under 100 characters. The project may have violations (not audited).

4. **Comment style**: The project uses `-- ` inline comments extensively for proof explanations. Mathlib is fine with this but prefers `/- -/` for implementation notes and `-- ` for brief inline comments.

## 5. Specific Tensions with Current ProofChecker Patterns

### 5.1 `DerivationTree : Type` vs Mathlib's `Prop` Approach

**This is the most significant structural tension.**

```lean
-- ProofChecker: DerivationTree is a Type
inductive DerivationTree : Context → Formula → Type where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : DerivationTree Γ φ
  | modus_ponens ...
```

```lean
-- Foundation: Uses Prop-based entailment
class Entailment (S : Type*) (F : Type*) where
  Prov : S → F → Prop
-- With notation: 𝓢 ⊢ φ : Prop and 𝓢 ⊢! φ : Type (Nonempty wrapper)
```

**Impact for Mathlib**:
- Mathlib's standard pattern is `Prop`-based derivability with proof irrelevance
- `Type`-based derivation trees are legitimate for proof theory (they encode proof structure, not just provability)
- However, this prevents integration with standard Lean `simp`/`aesop` automation that expects `Prop` goals
- Round 1 research confirmed Aesop integration failed specifically because of this `Type` constraint

**Assessment**: This is a design choice appropriate for proof-theoretic work (where proof structure matters), but it places ProofChecker outside Mathlib's usual patterns. It is not disqualifying per se, but it means most standard automation tools will not work out of the box.

### 5.2 `noncomputable section`

**Usage in ProofChecker**: The project uses `noncomputable` extensively (30+ declarations), primarily for:
- Classical existence proofs in completeness (maximal consistent sets via Zorn's lemma)
- Deduction theorem infrastructure
- Derived theorems using the deduction theorem
- `Denumerable Formula` instance

**Mathlib's stance**: Mathlib allows and frequently uses `noncomputable` for classical constructions. This is not a problem. The Lindenbaum algebra, Zorn's lemma applications, and classical existence proofs are all standard patterns in Mathlib.

**Assessment**: No conflict. The `noncomputable` usage is appropriate and Mathlib-compatible.

### 5.3 Custom `Axiom` Inductive Type

```lean
-- ProofChecker
inductive Axiom : Formula → Type where
  | prop_k (φ ψ χ : Formula) : Axiom ((φ.imp (ψ.imp χ)).imp ...)
  | modal_t (φ : Formula) : Axiom (φ.box.imp φ)
  -- 40 constructors total
```

```lean
-- Foundation
abbrev Axiom (α) := Set (Formula α)
-- Individual axiom schemas defined as separate defs
```

**Impact**: Foundation's set-based approach is more flexible (arbitrary axiom combinations via set union), while ProofChecker's inductive approach gives stronger pattern-matching capabilities. Mathlib would likely prefer the set-based or typeclass-based approach as it's more composable.

**Assessment**: Moderate tension. Not disqualifying but would need restructuring for maximum Mathlib compatibility.

### 5.4 Task Frame Semantics

The `TaskFrame` structure is highly domain-specific:
```lean
structure TaskFrame (D : Type*) [OrderedAddCommGroup D] [LinearOrder D] where
  W : Type*                           -- world states
  task_rel : W → D → W → Prop        -- task relation
  nullity_identity : ...              -- zero duration = identity
  forward_comp : ...                  -- compositionality
  converse : ...                      -- temporal symmetry
```

**Assessment**: This is too specialized for Mathlib. Standard Kripke frames (`World × Rel`) might have a home in Mathlib; task frames with ordered abelian group-valued temporal durations would not. This is the sort of structure that belongs in a domain-specific library.

### 5.5 `Formula` as Fixed Inductive Type

ProofChecker's `Formula` has a fixed `Atom` type:
```lean
inductive Formula : Type where
  | atom : Atom → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | untl : Formula → Formula → Formula
  | snce : Formula → Formula → Formula
```

Foundation parameterizes over the atom type: `inductive Formula (α : Type*)`.

**Assessment**: Mathlib would expect the polymorphic version. The fixed atom type is a minor architectural choice that limits generality. For a standalone library this is fine; for Mathlib submission it would need to be parameterized.

### 5.6 Hilbert-Style vs Natural Deduction

Mathlib does not have a strong preference here — it contains neither for propositional/modal logic. Foundation uses Hilbert-style, which matches ProofChecker. This is not a tension.

### 5.7 Universe Polymorphism

ProofChecker uses `Type` (not `Type*` or universe-polymorphic types) in several places to "avoid universe level issues." Mathlib strongly prefers universe polymorphism.

**Assessment**: Moderate tension. Several type signatures would need universe variables.

## 6. Is Modal/Temporal Logic Welcome in Mathlib?

### Current Status

- **No modal logic exists in Mathlib** (confirmed by search)
- **No Kripke semantics exists in Mathlib** (confirmed by search)
- **No temporal logic exists in Mathlib** (confirmed by search)
- **No evidence of modal logic PRs** having been submitted or proposed
- **No Zulip discussions found** specifically proposing modal logic for Mathlib

### Would It Be Welcome?

**Basic modal logic** (propositional + box/diamond + Kripke frames): Potentially yes, as it is "typically taught in mathematics/logic departments" (Mathlib's criterion). However:
- There are no active maintainers with modal logic expertise
- The review process would be slow (expert reviewers needed)
- The Mathlib community would likely suggest starting with a standalone library

**Bimodal TM logic** specifically: Almost certainly too specialized. This is a custom logic combining S5 with Until-Since temporal operators under Burgess-Xu axiomatization with task-frame semantics. This is cutting-edge research, not university-level standard material.

### What Could Potentially Go Into Mathlib

In decreasing order of likelihood:

1. **Kripke frame structures** — Basic `Frame` (World + Rel), `FrameClass`, standard frame conditions (reflexive, transitive, symmetric, serial). This is generic enough for Mathlib.
2. **Propositional modal syntax** — `Formula α` with atom/bot/imp/box. Very general, used across all modal logics.
3. **Basic soundness/completeness for K/S4/S5** — Standard textbook results that apply broadly.
4. **Lindenbaum-Tarski algebra** — The `BooleanAlgebra` instance on the quotient. This connects to existing Mathlib algebra.
5. **Everything else** (task frames, Until-Since, BX axioms, perpetuity principles): Not suitable for Mathlib.

### FormalizedFormalLogic/Foundation's Example

Foundation has ~195 files of modal logic and has **not submitted any of it to Mathlib**. Their `Vospiel` module provides "supplemental definitions and theorems for mathlib" — suggesting they contribute utility lemmas to Mathlib but keep the logic formalization separate.

This is the established precedent in the Lean 4 ecosystem.

## 7. Practical Recommendations

### Primary Recommendation: Mathlib-Compatible Standalone Library

**Do NOT attempt full Mathlib submission.** Instead, maintain ProofChecker as a standalone library that imports Mathlib and follows Mathlib-compatible patterns where practical.

**Rationale**:
1. Bimodal TM logic is too specialized for Mathlib
2. The 109,000-line codebase would need massive restructuring
3. Mathlib's review queue (2 weeks per PR) makes iterative development impractical
4. Foundation (the key reference) took the same approach
5. Mathlib's contribution guide explicitly suggests standalone libraries for specialized domains

### What to Do Instead

#### Tier A: Adopt for Internal Quality (High Priority)

These changes improve the codebase regardless of Mathlib submission:

1. **Naming cleanup** (aligns with task 175): Replace all opaque abbreviations (`ecq` -> `bot_of_and_neg`, `bfmcs` -> `bounded_finitely_maximal_consistent_set`, etc.). This improves readability for any user.

2. **Copyright headers**: Add standard headers to all files. Required for any open-source project:
   ```lean
   /-
   Copyright (c) 2024-2026 Benjamin Brast-McKie. All rights reserved.
   Released under [LICENSE] license as described in the file LICENSE.
   Authors: Benjamin Brast-McKie
   -/
   ```

3. **100-character line length**: Audit and fix. Improves readability everywhere.

4. **Universe polymorphism where feasible**: Use `Type*` instead of `Type` in core definitions (Formula, TaskFrame, DerivationTree) where universe issues can be resolved.

#### Tier B: Consider for Future Reuse (Medium Priority)

These changes would make components extractable for the broader community:

5. **Parameterize `Formula` over atom type**: `Formula (α : Type*)` instead of fixed `Atom`. Enables others to instantiate with their own atom types.

6. **Separate generic modal logic from TM-specific content**: A clean `Modal.Basic` module with:
   - Generic `Formula α` (atom/bot/imp/box only)
   - Generic `KripkeFrame` structure
   - Standard frame classes (reflexive, transitive, symmetric)
   - Basic K/T/S4/S5 soundness

   Then TM-specific extensions in a separate module that adds Until/Since, task frames, etc.

7. **Prop-valued derivability predicate**: Add alongside `DerivationTree`:
   ```lean
   def Derivable (Γ : Context) (φ : Formula) : Prop := Nonempty (DerivationTree Γ φ)
   ```
   This enables `simp`/`aesop` integration while preserving the `Type`-valued tree for proof theory.

#### Tier C: Optional for Mathlib Contribution (Low Priority)

Only if the project eventually wants to contribute basic modal logic to Mathlib:

8. **Extract a minimal `Mathlib.Logic.Modal` proposal**: ~500 lines covering basic Kripke frames and K/S5 completeness. Discuss on Zulip before writing any code.

9. **Lindenbaum-Tarski contribution**: The `BooleanAlgebra LindenbaumAlg` instance connects to existing Mathlib algebra and could be contributed as an interesting example of Boolean algebras arising from logic.

### What NOT to Do

1. **Do not rewrite the entire codebase to Mathlib style** — This would cost hundreds of hours and yield no practical benefit
2. **Do not attempt to submit task frame semantics to Mathlib** — Too specialized
3. **Do not wait for Mathlib submission before publishing** — Standalone libraries are the norm in the Lean ecosystem for specialized formalizations
4. **Do not introduce a `Prop`-valued DerivationTree replacement** as the primary type — The `Type`-valued tree is architecturally correct for proof theory; add a `Derivable` wrapper for automation compatibility instead

### Relationship with FormalizedFormalLogic/Foundation

ProofChecker and Foundation are complementary, not competing:
- **Foundation**: Broad coverage of the modal logic cube (K, T, S4, S5, GL, Grz, etc.) with general-purpose architecture
- **ProofChecker**: Deep formalization of one specific bimodal logic (TM) with custom semantics (task frames)

Potential collaboration paths:
- Use Foundation's `Formula α` and entailment typeclasses as a shared interface
- Contribute ProofChecker's Lindenbaum-Tarski BooleanAlgebra proofs upstream
- Share Kripke completeness techniques

However, adopting Foundation as a dependency would require restructuring ProofChecker's core types, which is not justified unless the project needs Foundation's features (multiple modal logics, the modal cube).

## Appendix A: Mathlib Import Summary

The project currently imports 24 distinct Mathlib modules. All are standard mathematical utilities — none involve logic formalization:

**Order/Algebra** (7): `Algebra.Order.Group.Defs`, `Algebra.Order.Group.Int`, `Algebra.Order.Ring.Rat`, `Algebra.Order.Archimedean.Basic`, `Order.BooleanAlgebra.Defs`, `Order.BooleanAlgebra.Basic`, `Order.Basic`

**Order/Combinatorics** (5): `Order.Zorn`, `Order.SuccPred.Basic`, `Order.SuccPred.Archimedean`, `Order.SuccPred.LinearLocallyFinite`, `Order.CountableDenseLinearOrder`, `Order.Preorder.Chain`

**Data** (8): `Data.Rat.Defs`, `Data.Rat.Denumerable`, `Data.Rat.Cast.Order`, `Data.Finset.Basic`, `Data.Finset.Powerset`, `Data.Finset.Union`, `Data.Fintype.Basic`, `Data.Fintype.Card`, `Data.Fintype.Powerset`, `Data.Fintype.Quotient`, `Data.Set.Finite.Basic`, `Data.Setoid.Basic`, `Data.List.Chain`, `Data.Int.SuccPred`, `Data.Finite.Defs`, `Data.Countable.Basic`

**Topology** (2): `Topology.Instances.Real.Lemmas`, `Topology.Instances.NNReal.Lemmas`

**Tactic** (1): `Tactic.DeriveCountable`

## Appendix B: Sorry Audit

Active sorry sites in the codebase (excluding Boneyard):

| File | Count | Critical Path? | Notes |
|------|-------|----------------|-------|
| `BXCanonical/Completeness.lean` | 4 | Partially | Some on critical path, some documented as closed |
| `WeakCanonical/TruthLemma.lean` | 3 | No | Documented as non-critical-path; intermediate guard conditions |

Total: ~7 sorry sites in active code. The BXCanonical completeness sorries would need resolution before any Mathlib submission (Mathlib requires zero sorry), but they are on the existing roadmap regardless.

## References

### Mathlib Documentation
- [How to Contribute to Mathlib](https://leanprover-community.github.io/contribute/index.html)
- [Mathlib Naming Conventions](https://leanprover-community.github.io/contribute/naming.html)
- [Library Style Guidelines](https://leanprover-community.github.io/contribute/style.html)
- [Pull Request Review Guide](https://leanprover-community.github.io/contribute/pr-review.html)
- [Mathematics in Mathlib (Overview)](https://leanprover-community.github.io/mathlib-overview.html)
- [Mathlib Initiative Roadmap](https://mathlib-initiative.org/roadmap/)

### Lean Ecosystem Projects
- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) — Lean 4 formalization of mathematical logic (modal, first-order, provability)
- [FormalizedFormalLogic Documentation](https://formalizedformallogic.github.io/Foundation/)
- [Mathlib4 Repository](https://github.com/leanprover-community/mathlib4)
