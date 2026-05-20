# Teammate B Findings: Alternative Patterns and Prior Art

**Task**: 179 — Research Lean 4 best practices and infrastructure for tactics and derived theorems
**Date**: 2026-05-20
**Focus**: Alternative patterns, prior art from other Lean 4 logic projects, and organizational strategies

---

## Key Findings

### 1. FormalizedFormalLogic/Foundation — The Most Mature Lean 4 Modal Logic Project

The [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) project is the most comprehensive Lean 4 logic formalization, covering propositional, first-order, modal, provability, and interpretability logics. Key design choices relevant to ProofChecker:

**Frame as Structure, FrameClass as Set**:
```lean
structure Frame where
  World : Type
  Rel : Rel World World
  [world_nonempty : Nonempty World]

abbrev FrameClass := Set (Frame)
```
- Uses `structure` for `Frame`, not a typeclass — avoids diamond inheritance issues
- Frame classes are simply `Set Frame`, making them first-class mathematical objects
- `CoeSort` and `CoeFun` instances for ergonomic access: `F.World` via coercion, `F x y` for relation

**Hilbert Systems Parameterized Over Axiom Sets**:
```lean
inductive Hilbert.Normal {α} (Ax : Axiom α) : Logic α
  | axm {φ} (s : Substitution _) : φ ∈ Ax → Normal Ax (φ⟦s⟧)
  | mdp {φ ψ} : Normal Ax (φ 🡒 ψ) → Normal Ax φ → Normal Ax ψ
  | nec {φ}   : Normal Ax φ → Normal Ax (□φ)
  | implyK φ ψ    : Normal Ax $ Axioms.ImplyK φ ψ
  | implyS φ ψ χ  : Normal Ax $ Axioms.ImplyS φ ψ χ
  | ec φ ψ        : Normal Ax $ Axioms.ElimContra φ ψ
```
- The proof system is parameterized by `Ax : Axiom α`, an axiom set
- This allows proving theorems that hold for *any* normal modal logic containing a given axiom set
- Different logics (K, T, S4, S5, GL, etc.) are simply different instantiations
- ProofChecker's `DerivationTree` uses a monolithic `Axiom` inductive instead — refactoring to parameterize over axiom subsets would enable reuse across frame classes

**Entailment Typeclasses for Logic Hierarchies**:
```lean
instance : Entailment.Łukasiewicz (Hilbert.Normal Ax) where ...
instance : Entailment.Necessitation (Hilbert.Normal Ax) where ...
```
- Logic capabilities (Łukasiewicz propositional, necessitation, etc.) are typeclasses
- This enables writing generic lemmas like "any logic with Necessitation satisfies K-distribution"
- Separation of concerns: propositional reasoning is independent of modal/temporal structure

**Confidence**: High — this project is actively maintained with monthly reports and covers similar territory to ProofChecker.

### 2. Kripke Semantics: Simp-Oriented Satisfaction Lemmas

The Foundation project's satisfaction relation uses a pattern that ProofChecker should adopt:

```lean
@[simp] lemma atom_def : x ⊧ atom a ↔ M a x := by simp [Satisfies]
@[simp] lemma box_def  : x ⊧ □φ ↔ ∀ y, x ≺ y → y ⊧ φ := by simp [Satisfies]
@[simp] lemma dia_def  : x ⊧ ◇φ ↔ ∃ y, x ≺ y ∧ y ⊧ φ := by simp [Satisfies]
```

Every connective gets a `@[simp]` lemma reducing it to its definition. This means `simp` can normalize any satisfaction statement automatically.

ProofChecker's `Truth.lean` has similar lemmas (`bot_false`, `imp_iff`, `box_iff`) but they are **not tagged `@[simp]`**, requiring manual application. Tagging these systematically would significantly reduce proof boilerplate in soundness/completeness proofs.

**Confidence**: High — this is a standard and proven pattern.

### 3. Custom Simp Sets for Domain-Specific Automation

Lean 4 supports registering custom simp sets via `registerSimpAttr`:

```lean
initialize modalSimpExt : SimpExtension ← registerSimpAttr `modal_simp "modal logic simplifications"
initialize temporalSimpExt : SimpExtension ← registerSimpAttr `temporal_simp "temporal logic simplifications"
initialize derivSimpExt : SimpExtension ← registerSimpAttr `deriv_simp "derivation tree simplifications"
```

Then lemmas can be tagged:
```lean
@[modal_simp] theorem box_imp_self (φ : Formula) : ⊢ (□φ).imp φ := ...
@[temporal_simp] theorem G_implies_F (φ : Formula) : ⊢ (Formula.all_future φ).imp (Formula.some_future φ) := ...
```

And used in proofs:
```lean
example : ... := by simp [modal_simp, temporal_simp]
```

This would be superior to ProofChecker's current approach of manually specifying lemma lists or relying on a monolithic `modal_search` tactic. It allows incremental composition of automation.

**Best practice from Mathlib**: Use `simp only [modal_simp]` in library code for reproducibility; reserve `simp [modal_simp]` for exploration, then freeze with `simp?`.

**Confidence**: High — `registerSimpAttr` is standard Lean 4 infrastructure.

### 4. lean4-pdl: Tableau-Based Decision Procedures

The [lean4-pdl](https://github.com/m4lvin/lean4-pdl) project implements Propositional Dynamic Logic with:
- A verified tableau decision procedure
- Craig Interpolation property
- CI with doc-gen4 documentation generation
- A companion Haskell prover for executable reference testing

Relevant pattern for ProofChecker: their approach of having an executable reference implementation alongside the verified formalization. ProofChecker's `ProofSearch.lean` (1384 lines) implements search algorithms but they aren't verified — a separate verified decision procedure based on the Decidability module could provide stronger guarantees.

**Confidence**: Medium — the decision procedure approach is sound but represents significant additional work.

### 5. Small Scale Reflection (LeanSSR) for Logic Formalization

The [LeanSSR paper](https://arxiv.org/pdf/2403.12733) introduces Small Scale Reflection techniques for Lean 4. Key ideas applicable to ProofChecker:

- **Boolean reflection**: Represent decidable propositions as `Bool` computations, then reflect back to `Prop` for logical reasoning
- **Hypothesis management**: Structured rewriting and hypothesis chaining without explicit naming
- **View patterns**: Type-driven automatic application of equivalences

For ProofChecker, this could help with:
- Decidable fragments of formula equivalence (e.g., syntactic equality, formula complexity comparisons)
- Boolean-valued versions of context membership checks
- Streamlining the many `cases`/`match` patterns in soundness lemmas

**Confidence**: Medium — SSR is powerful but has a learning curve and may not be worth the investment for a logic library.

### 6. External ATP Integration: lean-auto and lean-smt

Two recent tools provide bridges to external automated theorem provers:

**lean-auto** (May 2025): Translates Lean goals to TPTP format for Zipperposition (superposition prover) and SMT solvers. On Mathlib4, it solved 54,570 out of 149,142 benchmark problems.

**lean-smt** (2025): Translates Lean goals to SMT-LIB for cvc5 with full proof reconstruction. Uses FFI for efficient communication.

These are relevant because many ProofChecker goals (especially in propositional reasoning and simple modal steps) are decidable and could be dispatched by SMT solvers. However, the infrastructure cost of integrating these tools may not justify the benefit for a specialized logic library.

**Confidence**: Low for adoption now — these tools are best for general-purpose automation, not domain-specific logic reasoning.

### 7. Mathlib Organization Patterns ("Growing Mathlib" Paper)

The ["Growing Mathlib" paper](https://arxiv.org/abs/2508.21593) (CICM 2025) provides actionable guidance for large Lean 4 libraries:

**Type Class Hierarchy**:
- Bundled design preferred but avoid multiplicative expansion when extending along two axes
- Strategic unbundling gave 33% speedup for typeclass synthesis, 19% build improvement
- ProofChecker's `FrameClass.lean` already uses marker typeclasses well, but the hierarchy could benefit from bundling frame conditions more tightly

**Compilation Optimization**:
- Use `simp only` instead of `simp` (smaller search space)
- Mark definitions with appropriate transparency (`reducible`, `semireducible`, `irreducible`)
- Use specialized tactics before powerful general ones
- `noncomputable` sections avoid code generation overhead — ProofChecker already uses `noncomputable section` throughout Theorems/

**Linting and Quality**:
- 26 syntax linters + 17 environment linters in Mathlib
- Every file should have a valid copyright header and module documentation
- Use "shake tool" to identify unused imports
- ProofChecker should adopt import-shaking to reduce build graph depth

**Deprecation Pattern**: Preserve old names with deprecation markers during refactoring — critical for ProofChecker's planned deep refactor (task 168 onwards).

**Confidence**: High — these are proven practices from the largest Lean 4 library.

### 8. Testing and Validation Infrastructure

Patterns observed across projects:

**Example-based tactic testing**:
```lean
-- Test that modal_search closes this goal
example (p : Formula) : [p.box] ⊢ p := by modal_search
-- Test failure case
-- example (p : Formula) : [] ⊢ p := by modal_search  -- should fail
```

**doc-gen4 integration**: Both Foundation and lean4-pdl generate documentation. ProofChecker could benefit from this for the Theorems and Automation modules.

**CI builds**: All serious projects use GitHub Actions for `lake build` CI. ProofChecker should ensure zero-sorry CI enforcement.

**Confidence**: High — standard practices.

---

## Recommended Approach

### Priority 1: Custom Simp Sets (Immediate Impact)
Create `@[modal_simp]`, `@[temporal_simp]`, and `@[truth_simp]` simp sets. Tag all satisfaction/truth lemmas in `Truth.lean` and all derived theorems in `Theorems/` with appropriate attributes. This provides immediate automation improvements with minimal refactoring.

### Priority 2: Simp-Tagged Satisfaction Lemmas
Systematically tag `bot_false`, `imp_iff`, `box_iff`, `atom_iff_of_domain`, etc. with `@[simp]` following the Foundation project pattern. This reduces boilerplate in Metalogic proofs.

### Priority 3: Entailment Typeclasses for Cross-Logic Reuse
Define typeclasses like `HasNecessitation`, `HasModalT`, `HasTemporalK` that capture individual axiom capabilities. Write generic lemmas parameterized by these classes. This prepares the ground for task 168 (FrameClass parameterization) by making theorems reusable across frame classes.

### Priority 4: Import Shaking and Build Optimization
Run Mathlib's `shake` tool to identify unused imports. Review `noncomputable` usage. Use `simp only` in library code.

### Priority 5: Deprecation Infrastructure for Deep Refactor
Before task 168, establish deprecation aliases for any definitions that will be renamed. This allows dependent code (tests, examples) to migrate gradually.

---

## Evidence/Examples

### Example: Custom Simp Set for Modal Logic

```lean
-- In Automation/SimpSets.lean
import Lean

initialize modalSimpExt : Lean.Meta.SimpExtension ←
  Lean.Meta.registerSimpAttr `modal_simp "Simp lemmas for modal logic derivations"

initialize temporalSimpExt : Lean.Meta.SimpExtension ←
  Lean.Meta.registerSimpAttr `temporal_simp "Simp lemmas for temporal logic derivations"

initialize truthSimpExt : Lean.Meta.SimpExtension ←
  Lean.Meta.registerSimpAttr `truth_simp "Simp lemmas for truth/satisfaction evaluation"
```

```lean
-- In Semantics/Truth.lean (add annotations)
@[simp, truth_simp] theorem bot_false ... := ...
@[simp, truth_simp] theorem imp_iff ... := ...
@[simp, truth_simp] theorem box_iff ... := ...

-- In Theorems/ModalS5.lean (add annotations)
@[modal_simp] def t_box_to_diamond ... := ...
@[modal_simp] def box_contrapose ... := ...
```

```lean
-- Usage in proofs
theorem some_soundness_lemma ... := by
  simp only [truth_simp]
  ...
```

### Example: Entailment Typeclass Pattern

```lean
-- Define capability typeclasses
class HasMP (L : Context → Formula → Type) where
  mp : L Γ (φ.imp ψ) → L Γ φ → L Γ ψ

class HasNec (L : Context → Formula → Type) where
  nec : L [] φ → L [] (Formula.box φ)

class HasWeakening (L : Context → Formula → Type) where
  weaken : L Γ φ → (∀ x, x ∈ Γ → x ∈ Δ) → L Δ φ

-- Generic lemma
def box_mp [HasMP L] [HasNec L] [HasWeakening L]
    (h1 : L [] (φ.imp ψ)) (h2 : L [] φ) : L [] (Formula.box ψ) :=
  HasNec.nec (HasMP.mp h1 h2)
```

---

## Confidence Summary

| Recommendation | Confidence | Effort | Impact |
|---|---|---|---|
| Custom simp sets | High | Low (1-2 days) | High — reduces proof boilerplate across all modules |
| Simp-tagged satisfaction lemmas | High | Low (1 day) | High — immediate automation improvement in Metalogic |
| Entailment typeclasses | High | Medium (3-5 days) | Medium-High — enables cross-frame reuse |
| Import shaking | High | Low (0.5 day) | Medium — build time improvement |
| Deprecation infrastructure | High | Low (1 day) | Medium — prevents breakage during refactor |
| SSR adoption | Medium | High (1-2 weeks) | Medium — diminishing returns for this project |
| lean-auto/lean-smt integration | Low | High (2+ weeks) | Low — overkill for domain-specific logic |
| Verified decision procedure | Medium | Very High | High — but not cost-effective now |

---

## Sources

- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) — Lean 4 logic formalization
- [lean4-pdl](https://github.com/m4lvin/lean4-pdl) — PDL tableau in Lean 4
- [Lean 4 Metaprogramming Book](https://leanprover-community.github.io/lean4-metaprogramming-book/) — Custom tactic patterns
- [Lean 4 Simp Sets Reference](https://lean-lang.org/doc/reference/latest/The-Simplifier/Simp-sets/) — Custom simp set registration
- [Growing Mathlib (CICM 2025)](https://arxiv.org/abs/2508.21593) — Large library maintenance
- [Small Scale Reflection for Lean 4](https://arxiv.org/pdf/2403.12733) — SSR techniques
- [lean-auto](https://arxiv.org/abs/2505.14929) — ATP integration
- [lean-smt](https://arxiv.org/abs/2505.15796) — SMT integration
- [Mathlib4 All Tactics](https://github.com/haruhisa-enomoto/mathlib4-all-tactics) — Tactic reference
- [Lean 4 Type Classes](https://lean-lang.org/theorem_proving_in_lean4/Type-Classes/) — Typeclass patterns
