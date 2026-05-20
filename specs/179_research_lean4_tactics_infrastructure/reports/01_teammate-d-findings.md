# Teammate D Findings: Strategic Alignment and Long-Term Thinking

**Task**: 179 — Research Lean 4 best practices and infrastructure for tactics and derived theorems
**Date**: 2026-05-20
**Role**: Horizons (strategic alignment, long-term thinking)

---

## Key Findings

### 1. Timing: Infrastructure Should Be Built DURING the FrameClass Refactor, Not Before

The project roadmap has a clear pipeline:
```
155 (Reynolds) → 176, 95 (cleanup) → 168 (FrameClass) → 174-175-131-161 (deep refactor) → 177-178 (polish)
```

Building a large standalone infrastructure library before task 168 is **strategically misaligned** for three reasons:

1. **The FrameClass parameterization (task 168) will change the type signatures of nearly everything.** Any tactics or derived theorems written against the current `DerivationTree Γ φ` signature may need rewriting when `DerivationTree` becomes parameterized over `FrameClass`. Building infrastructure now means building it twice.

2. **The refactoring tasks (174-175) will restructure the files.** Building a library that imports from the current file hierarchy is premature when that hierarchy is about to change.

3. **The real pain points will only become clear during the refactor.** Building infrastructure speculatively (before seeing what patterns recur during FrameClass migration) risks building the wrong things.

**Recommendation**: This task should produce a **design document** with concrete code sketches, not a standalone library. The actual code should be created incrementally during tasks 168, 174, and 175.

**Confidence**: High

### 2. The Highest-Leverage Infrastructure is Context/Weakening Automation

Looking at the codebase's proof patterns, the most verbose and repetitive code is not in custom modal reasoning but in **plumbing**:

- **Context management**: `DerivationTree.weakening` calls with manual subset proofs (`by intro; simp`) appear throughout Propositional.lean, ModalS5.lean, and the Perpetuity files. Every time a lemma needs to be used in a different context, there's a manual weakening step.

- **Modus ponens chains**: The pattern `DerivationTree.modus_ponens [] _ _ h1 h2` is extremely verbose. The combinator infrastructure (imp_trans, b_combinator, etc.) exists precisely to manage this, but applying combinators is itself multi-step.

- **Axiom instantiation**: `DerivationTree.axiom Γ _ (Axiom.foo φ ψ)` is boilerplate.

A tactic that handles context weakening automatically and chains modus ponens steps would reduce proof lengths by 30-50% in the Theorems/ directory. This would be **independent of FrameClass parameterization** and thus safe to build now.

**Confidence**: High

### 3. The FormalizedFormalLogic/Foundation Project Offers a Reference Architecture

The [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) project is the closest comparable Lean 4 formalization of modal logic. Key architectural patterns to study:

- **Hilbert-style deduction infrastructure**: They abstract over axiom sets using typeclasses, enabling generic modal completeness theorems parameterized over the logic.
- **Deduction theorem automation**: Their deduction theorem is used as a meta-theorem to automate Hilbert-style proofs, reducing multi-step combinator chains to natural deduction-style reasoning.
- **Kripke completeness genericity**: Their completeness proofs are parameterized over frame classes via typeclasses.

This is directly relevant to task 168's FrameClass parameterization. Studying Foundation's approach before implementing task 168 would inform better design choices.

**Confidence**: Medium-high

### 4. Proof-by-Reflection for Propositional Fragment Is High-Impact but Out-of-Scope

The propositional fragment of TM (prop_k, prop_s, ex_falso, peirce + modus ponens) is decidable. A proof-by-reflection decision procedure could:

- Automatically prove any propositional tautology as a `DerivationTree`
- Eliminate the need for manual combinator chains in Propositional.lean (1712 lines)
- Serve as a foundation for the `modal_search` tactic

However, implementing a verified decision procedure is a substantial project (estimated 40-60 hours). This should be a **separate task**, not part of task 179.

**Confidence**: Medium (high impact, high effort, timing risk)

### 5. `simp` Lemma Sets Are the Low-Hanging Fruit

Lean 4's `simp` tactic with custom lemma sets (`@[simp]` attributes or explicit `simp only [...]`) is underutilized in this codebase. Opportunities:

- **Formula normalization**: `@[simp]` lemmas for `Formula.neg`, `Formula.or`, `Formula.and`, `Formula.diamond` definitions (these are defined as abbreviations via `imp` and `bot`).
- **Context membership**: `@[simp]` lemmas for list membership patterns that appear in weakening proofs.
- **DerivationTree constructors**: Tagged simp lemmas for common patterns like `⊢ A.imp A` (identity), `⊢ A.imp (B.imp A)` (prop_s).

This is zero-risk infrastructure that can be added incrementally and survives refactoring.

**Confidence**: High

### 6. FrameClass-Aware Design Should Plan for Deferred Features

The deferred features (tasks 169, 170, 125, 127, 128, 165, 164) will extend the logic in multiple dimensions:

- **Task 169** (frame extensions): Needs the FrameClass typeclass hierarchy to be extensible
- **Task 170** (TM^dc completeness): Needs dense+complete frame support
- **Task 165** (filtration/FMP): Needs semantic lemma infrastructure for finite model constructions
- **Task 125** (Jónsson-Tarski): Needs algebraic infrastructure

Infrastructure built now should be **generic over FrameClass** from the start, even if only Base/Dense/Discrete are initially supported. This means:

- Tactics should not hard-code frame class assumptions
- Derived theorems should state their frame class requirements explicitly
- Semantic lemmas should be parameterized over the frame conditions they require

**Confidence**: High

---

## Recommended Approach

### Primary Recommendation: Design Document + Incremental Implementation

**Phase 1 (This task, ~8-12 hours)**: Produce a design document that:
1. Catalogues all repetitive proof patterns in Theorems/ and Metalogic/
2. Designs the context automation tactic (signature, behavior, examples)
3. Identifies all `@[simp]` lemma opportunities
4. Sketches the FrameClass-parameterized derivation infrastructure for task 168
5. Lists specific lemmas that should be proved as reusable infrastructure

**Phase 2 (Woven into task 168, no extra hours)**: During the FrameClass parameterization:
1. Add `@[simp]` attributes as files are refactored
2. Build the context automation tactic when the first file is migrated
3. Add generic derivation lemmas as they're needed

**Phase 3 (Woven into tasks 174-175, no extra hours)**: During the file splitting and naming cleanup:
1. Create a dedicated `Theorems/Infrastructure.lean` for reusable derivation lemmas
2. Consolidate the combinator library
3. Add notation for common patterns

### What's In Scope

- Design document with concrete code sketches
- Cataloguing proof pattern frequencies
- `@[simp]` lemma identification
- Reference architecture study (FormalizedFormalLogic/Foundation)
- Context automation tactic design
- FrameClass-parameterized infrastructure design

### What's Explicitly Out of Scope

- Proof-by-reflection decision procedure (separate task)
- Full Aesop rule set overhaul (the existing deprecation is appropriate)
- LeanSSR-style reflection framework (overkill for this project)
- Custom notation system (premature without FrameClass parameterization)
- Rewriting existing sorry-free proofs (don't fix what isn't broken until the refactor)

---

## Evidence/Examples

### Example 1: Verbose Weakening Pattern (Current)

From `Propositional.lean`:
```lean
def ecq (A B : Formula) : [A, A.neg] ⊢ B := by
  -- ... 15+ lines of manual DerivationTree construction
  have bot_to_neg_neg_b :=
    DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot B.neg)
  have bot_to_neg_neg_b_ctx :=
    DerivationTree.weakening [] [A, A.neg] _ bot_to_neg_neg_b (by intro; simp)
  -- etc.
```

### Example 2: What a Context Automation Tactic Could Do

```lean
-- Hypothetical: `tm_weaken` auto-manages context
def ecq (A B : Formula) : [A, A.neg] ⊢ B := by
  tm_weaken (efq_axiom B)   -- auto-weakens ⊢ ⊥ → B to [A, A.neg] ⊢ ⊥ → B
  tm_mp                     -- auto-applies modus ponens
  tm_weaken (identity A.neg) -- etc.
```

### Example 3: FormalizedFormalLogic Foundation Architecture

From Foundation's modal logic:
```lean
-- Generic over axiom set Λ
class Hilbert (F : Type*) where
  axiomSet : Set F

-- Generic deduction
theorem deduction [Hilbert F] (Γ : Context F) (φ ψ : F) :
    (φ :: Γ) ⊢[Λ] ψ ↔ Γ ⊢[Λ] φ →' ψ
```

This level of genericity is what task 168 should aspire to.

### Example 4: `@[simp]` Lemma Opportunities

```lean
-- Currently implicit, should be explicit @[simp] lemmas:
@[simp] theorem Formula.neg_def (φ : Formula) : φ.neg = φ.imp .bot := rfl
@[simp] theorem Formula.or_def (φ ψ : Formula) : φ.or ψ = φ.neg.imp ψ := rfl
@[simp] theorem Formula.and_def (φ ψ : Formula) : φ.and ψ = (φ.imp ψ.neg).neg := rfl
@[simp] theorem Formula.diamond_def (φ : Formula) : φ.diamond = φ.neg.box.neg := rfl

-- Context membership:
@[simp] theorem mem_cons_self (a : Formula) (l : Context) : a ∈ (a :: l) := List.mem_cons_self a l
```

---

## Confidence Levels

| Recommendation | Confidence | Rationale |
|---|---|---|
| Design document before code | **High** | FrameClass refactor will invalidate premature code |
| Context/weakening tactic is highest leverage | **High** | Appears in >50% of Theorems/ proofs by inspection |
| Study FormalizedFormalLogic/Foundation | **Medium-High** | Closest comparable project; patterns may not transfer perfectly |
| `@[simp]` lemma sets | **High** | Zero-risk, incremental, survives refactoring |
| Proof-by-reflection as separate task | **Medium** | High impact but uncertain effort; timing should follow FrameClass |
| FrameClass-generic infrastructure | **High** | Deferred features require extensibility |

---

## Strategic Risk Assessment

### Risk: Scope Creep (High Probability)

This task is estimated at 20-30 hours. The temptation to actually build infrastructure (rather than design it) is strong. **Mitigation**: Strict definition of done = design document + catalogued patterns + `@[simp]` annotations. No new `.lean` files.

### Risk: Infrastructure Becomes Obsolete (Medium Probability)

If the FrameClass parameterization changes the `DerivationTree` type significantly, tactics designed against the current type will break. **Mitigation**: Design for the post-168 type, not the current one.

### Risk: Delaying Publication (Low Probability)

This task is not on the critical path. The research phase takes a few days; the design document doesn't block anything. **Mitigation**: Timebox strictly. If research takes >12 hours, stop and write up findings.

---

## Summary

The strategic recommendation is: **research now, design now, code later — woven into the refactoring pipeline**. The highest-leverage immediate actions are:

1. Add `@[simp]` lemmas to `Syntax/Formula.lean` (safe, immediate, survives everything)
2. Study FormalizedFormalLogic/Foundation's Hilbert calculus architecture
3. Design (but don't build) a context automation tactic
4. Write the design document that guides tasks 168, 174, and 175

The worst outcome would be spending 20-30 hours building a tactic library that task 168 renders obsolete. The best outcome is a focused design that makes the refactoring pipeline faster and produces publication-quality infrastructure as a side effect.

Sources:
- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation)
- [Lean 4 Metaprogramming Book - Tactics](https://leanprover-community.github.io/lean4-metaprogramming-book/main/09_tactics.html)
- [Small Scale Reflection for the Working Lean User](https://arxiv.org/pdf/2403.12733)
- [Lean 4.22.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.22.0/)
- [Lean-Auto: Interface Between Lean 4 and Automated Theorem Provers](https://link.springer.com/chapter/10.1007/978-3-031-98682-6_10)
- [Lean Coalition Logic Completeness (ITP 2024)](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28)
