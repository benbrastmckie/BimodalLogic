# Research Report: Task #179

**Task**: Research Lean 4 best practices and infrastructure for tactics and derived theorems
**Date**: 2026-05-20
**Mode**: Team Research (4 teammates)

## Summary

Four-agent parallel research into Lean 4 best practices for building tactic and derivation infrastructure for the ProofChecker bimodal logic formalization. The investigation covered modern metaprogramming patterns (Teammate A), prior art from comparable Lean 4 projects (Teammate B), critical analysis of assumptions and risks (Teammate C), and strategic alignment with the project roadmap (Teammate D).

**Central finding**: The project should adopt a "design now, code later" approach. The upcoming FrameClass parameterization (task 168) will change core type signatures, making premature tactic development wasteful. However, `@[simp]` lemma tagging and custom simp set registration are zero-risk improvements that can proceed immediately and survive all planned refactoring.

## Key Findings

### 1. Existing Custom Tactics Are Almost Entirely Unused (Critic — High Confidence)

The project already invested ~3,500 lines in `Automation/` — and nearly none of it is used in real proofs:
- `modal_search`: 3 uses (all in `Examples/BimodalProofs.lean`)
- `apply_axiom`, `modal_t`, `tm_auto`, `assumption_search`, all operator-specific tactics: **0 uses** outside Automation/ itself

Before investing more hours in custom tactics, the research must answer: **why were the existing ones not adopted?** The `apply_axiom` and `modal_t` macros are even identical in implementation. The Aesop integration was deprecated due to proof reconstruction errors caused by `DerivationTree` being `Type` (not `Prop`) — a fundamental architectural constraint.

### 2. `@[simp]` Lemma Sets Are the Highest-Leverage Immediate Improvement (All Teammates — High Confidence)

All four teammates independently converged on this recommendation. Lean 4's `registerSimpAttr` enables domain-specific simp sets without polluting the global database:

```lean
-- Automation/SimpSets.lean
initialize registerSimpAttr `tm_simp "TM formula simplification lemmas"
initialize registerSimpAttr `tm_derive "TM derivation construction lemmas"
initialize registerSimpAttr `tm_sem "TM semantic truth/validity lemmas"
initialize registerSimpAttr `tm_ctx "TM context membership lemmas"
```

**Current state**: Only 147 lemmas are tagged `@[simp]` across the codebase. Key untagged candidates:
- **Formula normalization**: `Formula.neg`, `Formula.or`, `Formula.and`, `Formula.diamond` definitions
- **Satisfaction lemmas**: `bot_false`, `imp_iff`, `box_iff`, `atom_iff_of_domain` in Truth.lean
- **Context membership**: `List.mem_cons` patterns (167 occurrences in Metalogic/)
- **Derivation helpers**: `identity`, `imp_trans`, `b_combinator` in Combinators.lean

The FormalizedFormalLogic/Foundation project systematically tags all satisfaction lemmas `@[simp]`, and this pattern should be adopted.

### 3. Task 168 (FrameClass Parameterization) Creates a Hard Sequencing Constraint (Critic + Horizons — High Confidence)

Building tactics **before** task 168 is almost certainly wasted work:
- Task 168 will change `DerivationTree`'s type signature (parameterizing over `FrameClass`)
- Every tactic that pattern-matches on `DerivationTree` will need rewriting
- Every Aesop rule constructing `DerivationTree` terms will need updating
- Every `@[simp]` lemma about `DerivationTree` will need adjusting

**Exception**: `@[simp]` attributes on Formula definitions and semantic Truth lemmas are safe — these types won't change during the FrameClass refactor.

### 4. FormalizedFormalLogic/Foundation Is the Key Reference Architecture (All Teammates — Medium-High Confidence)

The [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) project provides the most relevant reference for ProofChecker's refactoring:

- **Frame as Structure, FrameClass as Set**: `structure Frame` with `abbrev FrameClass := Set Frame` — avoids typeclass diamond issues
- **Hilbert Systems Parameterized Over Axiom Sets**: `inductive Hilbert.Normal (Ax : Axiom α)` enables proving theorems generic across logics
- **Entailment Typeclasses**: `HasNecessitation`, `HasMP`, etc. allow writing generic lemmas for any logic with a given capability
- **Deduction Theorem as Meta-theorem**: Used to automate Hilbert-style proofs, reducing combinator chains to natural deduction style
- **Separate Meta/ directory**: Proof automation is cleanly separated from core logic

This architecture is directly relevant to task 168's FrameClass design and should be studied before implementation begins.

### 5. Context/Weakening Automation Is the Highest-Leverage Tactic (Horizons — High Confidence)

The most verbose repetitive code is not modal reasoning but **plumbing**:
- `DerivationTree.weakening` calls with manual subset proofs (`by intro; simp`) appear throughout
- `DerivationTree.modus_ponens Γ _ _ h1 h2` is extremely verbose
- `DerivationTree.axiom Γ _ (Axiom.foo φ ψ)` is pure boilerplate

A tactic automating context weakening would reduce proof lengths by 30-50% in Theorems/ and is **independent of FrameClass parameterization** — thus safe to build now (or design now for post-168 implementation).

### 6. The "80/20" Alternative Is Underappreciated (Critic — Medium Confidence)

Before custom metaprogramming, simpler approaches achieve most of the benefit:
- **`@[simp]` audit and tagging** — immediate, zero-risk, high impact
- **Better helper lemmas** — extending Combinators.lean with `box_imp_trans`, `context_mp`, `weakening_mp` etc.
- **`decide` for propositional membership** — could close many verbose `List.mem_cons` chains if `DecidableEq Formula` is available
- **Naming cleanup** (task 175) — many proofs are hard to write because names like `bfmcs`, `drm`, `cud` are unreadable

### 7. Metalogic/ Is 78% of the Codebase and Uses Standard Tactics (Critic — High Confidence)

Module sizes: Metalogic/ has ~62k lines (78% of codebase) vs Theorems/ at 6.4k lines (8%). The Metalogic proofs use completely different patterns: `simp` (1,871 uses), `intro` (1,623), `obtain` (793), `cases` (170), `induction` (288) — standard Lean/Mathlib tactics, not domain-specific ones. Any infrastructure investment should prioritize making Metalogic/ proofs better, not just Theorems/.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate C/D | Resolution |
|----------|-----------|-------------|------------|
| Build tactics now vs later | Build 4-phase library now | Design now, code during tasks 168-175 | **Design now, code later** — sequencing argument is compelling; FrameClass refactor invalidates premature code |
| Aesop rehabilitation | Redesign with `enableSimp := false` | Failure was architectural (`DerivationTree : Type`) | **Defer Aesop work to post-168** — test whether the Type constraint is resolved by FrameClass parameterization |
| Custom tactic scope | Full metaprogramming (tm_trans, tm_mp, tm_weaken, tm_deduction) | Simple helper lemmas achieve 80% of benefit | **Start with helper lemmas and simp sets** — validate need for metaprogramming by measuring impact first |
| Effort estimate | 20-30 hours for research + implementation | 20-30 hours realistic for research only | **Research + design document = 12-16 hours; code implementation woven into tasks 168-175** |

### Gaps Identified

1. **Build performance impact** — No teammate measured current build times or projected impact of heavy metaprogramming on incremental compilation
2. **Adoption barriers** — Why were the existing 3,500 lines of tactics never used? Was it ergonomics, documentation, discoverability, or simply that the proofs were written before the tactics existed?
3. **`DerivationTree : Type` constraint** — Whether this can be mitigated (e.g., via `Propify` wrappers or parallel Prop-valued derivability predicates) or whether it permanently limits automation frameworks
4. **Mathlib compatibility** — Whether adopting Mathlib patterns (bundled typeclasses, import shaking) would cause conflicts with the current dependency structure

### Recommendations

#### Tier 1: Do Now (Pre-168, Zero Risk)

1. **Create `Automation/SimpSets.lean`** — Register `tm_simp`, `tm_derive`, `tm_ctx`, `tm_sem` simp sets
2. **Tag Formula definitions** — `@[simp]` on `Formula.neg_def`, `Formula.or_def`, `Formula.and_def`, `Formula.diamond_def`
3. **Tag satisfaction lemmas** — `@[simp, tm_sem]` on `bot_false`, `imp_iff`, `box_iff`, `atom_iff_of_domain` in Truth.lean
4. **Tag derivation helpers** — `@[tm_derive]` on `identity`, `imp_trans`, `b_combinator`, `pairing`, `dni`, `ecq`, `raa`, `efq` etc. in Combinators.lean and Propositional.lean
5. **Audit context membership** — Determine if `decide` can close the 167 `List.mem_cons` patterns in Metalogic/

#### Tier 2: Design Now, Build During Task 168

6. **Study FormalizedFormalLogic/Foundation** — Extract concrete patterns for FrameClass parameterization, entailment typeclasses, generic Hilbert calculus
7. **Design context automation tactic** (`tm_weaken`) — Automatically applies weakening with subset proof generation
8. **Design derivation combinator tactic** (`tm_chain`) — Chains `imp_trans` applications automatically
9. **Design the post-168 tactic architecture** — What the three-tier design (macros, elab tactics, proof search) looks like against FrameClass-parameterized types

#### Tier 3: Evaluate During Refactor

10. **Aesop rule set** — Re-evaluate after task 168 changes the DerivationTree type
11. **Proof-by-reflection for propositional fragment** — Separate task (40-60 hours), not part of this task
12. **External ATP integration** (lean-auto/lean-smt) — Overkill for domain-specific logic; skip

#### Tier 4: Out of Scope

13. **LeanSSR adoption** — High learning curve, diminishing returns
14. **Rewriting existing sorry-free proofs** — Don't fix what isn't broken until the refactor
15. **Custom notation system** — Premature without FrameClass parameterization

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: tactic patterns and metaprogramming | completed | high |
| B | Alternatives: prior art and organizational patterns | completed | high |
| C | Critic: gaps, blind spots, sequencing risks | completed | high |
| D | Horizons: strategic alignment and roadmap | completed | high |

## References

### Projects
- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) — Lean 4 modal/temporal logic formalization (primary reference)
- [lean4-pdl](https://github.com/m4lvin/lean4-pdl) — Propositional Dynamic Logic with verified tableau

### Documentation
- [Lean 4 Simp Sets Documentation](https://lean-lang.org/doc/reference/latest/The-Simplifier/Simp-sets/)
- [Lean 4 Custom Tactics Documentation](https://lean-lang.org/doc/reference/latest/Tactic-Proofs/Custom-Tactics/)
- [Lean 4 Metaprogramming Book](https://leanprover-community.github.io/lean4-metaprogramming-book/)
- [Aesop README](https://github.com/leanprover-community/aesop/blob/master/README.md)

### Papers
- [Growing Mathlib (CICM 2025)](https://arxiv.org/abs/2508.21593) — Large library maintenance patterns
- [Small Scale Reflection for Lean 4](https://arxiv.org/pdf/2403.12733) — SSR techniques
- [lean-auto (2025)](https://arxiv.org/abs/2505.14929) — ATP integration
- [lean-smt (2025)](https://arxiv.org/abs/2505.15796) — SMT integration
- [Lean Coalition Logic Completeness (ITP 2024)](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28)
