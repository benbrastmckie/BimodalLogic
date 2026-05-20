# Teammate C (Critic) Findings: Task 179

## Key Findings

### 1. Existing Custom Tactics Are Almost Entirely Unused (HIGH CONFIDENCE)

The most critical blind spot: the project already invested ~3,500 lines in `Automation/` (Tactics.lean: 1,416 lines, ProofSearch.lean: 1,384 lines, SuccessPatterns.lean: 423 lines, AesopRules.lean: 280 lines), and **nearly none of it is used in actual proofs**.

Usage outside `Automation/` and documentation files:
- `modal_search`: 3 uses (all in `Examples/BimodalProofs.lean`)
- `temporal_search`: 0 uses in real proofs
- `propositional_search`: 0 uses in real proofs
- `tm_auto`: 0 uses
- `apply_axiom`: 0 uses
- `modal_k_tactic`: 0 uses
- `temporal_k_tactic`: 0 uses
- `modal_4_tactic`: 0 uses
- `modal_b_tactic`: 0 uses
- `assumption_search`: 0 uses

**The project has already tried the "build custom tactics" approach and the tactics were never adopted.** Before investing 20-30 more hours building MORE tactics, the research must answer: why were the existing ones not used?

### 2. Aesop Integration Already Failed Once (HIGH CONFIDENCE)

The `AesopRules.lean` file is explicitly marked `DEPRECATED` (since 2026-01-17) because Aesop had "proof reconstruction errors with DerivationTree." The issue stems from `DerivationTree` being a `Type` (not `Prop`), which conflicts with Aesop's proof reconstruction. This is a fundamental architectural constraint, not a version-specific bug.

Any new tactic approach must either:
- Accept that `DerivationTree`-as-Type limits which automation frameworks work
- Propose changing `DerivationTree` to `Prop` (which would break computable height functions and pattern matching throughout Metalogic/)
- Work within the `TacticM`/metaprogramming approach that `modal_search` uses

### 3. The Sequencing Problem Is Severe (HIGH CONFIDENCE)

Task 168 (FrameClass parameterization) will fundamentally change the core types. Currently:
```lean
inductive DerivationTree : Context → Formula → Type where
```

Task 168 proposes parameterizing over `FrameClass`. The current codebase already has `isDenseCompatible` and `isDiscreteCompatible` as predicates on `DerivationTree` and `Axiom`. After task 168, the type signature of `DerivationTree` itself will change, which means:

- **Every tactic** that pattern-matches on `DerivationTree` (all of `modal_search`, the factory function `mkOperatorKTactic`, etc.) will need rewriting
- **Every Aesop rule** that constructs `DerivationTree` terms will need updating
- **Every `@[simp]` lemma** about `DerivationTree` will need adjusting

Building tactics BEFORE task 168 is almost certainly wasted work. The correct sequencing is:
1. Complete task 168 (FrameClass parameterization)
2. THEN build tactics that work with the final type signatures

### 4. Actual Proof Patterns Don't Need Custom Tactics (MEDIUM CONFIDENCE)

The dominant proof pattern in `Theorems/` (6,450 lines) is explicit term construction:
- `have ... := DerivationTree.modus_ponens ...` (182 occurrences)
- `have ... := DerivationTree.axiom ...` (113 occurrences)
- `DerivationTree.weakening` (50 occurrences)
- `exact ...` (167 occurrences)

These are mostly 3-7 line Hilbert-style proof chains. The pattern is repetitive but each proof is subtly different (different axiom instantiations, different formula structures). What would actually help is:
- **Better helper lemmas** (like `imp_trans`, `mp`, `identity` in Combinators.lean) that compose the raw constructor calls
- **More `@[simp]` lemmas** for simplification (only 147 currently tagged)
- **Abbreviation cleanup** (task 175) so proofs are readable

NOT full metaprogramming tactics.

### 5. Metalogic/ Is Where The Real Proof Mass Lives (HIGH CONFIDENCE)

The module sizes tell the story:
- `Metalogic/`: 62,116 lines (78% of codebase)
- `Theorems/`: 6,450 lines (8%)
- `Automation/`: 3,503 lines (4%) — mostly unused
- `Semantics/`: 1,790 lines
- Everything else: <4,000 lines combined

The Metalogic proofs use completely different patterns than the Theorems:
- `intro` (1,623 uses), `simp` (1,871 uses), `obtain` (793 uses), `cases` (170), `induction` (288)
- These are standard Lean/Mathlib tactics, not domain-specific ones

Any infrastructure investment should focus on the Metalogic proof patterns, not the Hilbert-style Theorem proofs.

### 6. 20-30 Hours Estimate Is Unrealistic for the Stated Scope (MEDIUM CONFIDENCE)

The task description mentions: "systematic library of tactics, derived theorems in the proof theory, semantic lemmas, and any other general results." This is at least 4 separate workstreams:

1. Tactic development (metaprogramming — high complexity)
2. Derived theorem library (Hilbert-style proof engineering)
3. Semantic lemma library (type-theoretic, Mathlib-dependent)
4. "Any other general results" (unbounded scope)

For context, the existing 3,500 lines of Automation/ represent a previous investment that went largely unused. Realistic alternatives:
- **Research only** (this task): 20-30 hours is realistic for deep research
- **Research + implementation**: 40-60 hours minimum
- **Full infrastructure build**: 80+ hours

### 7. The Simpler "80/20" Alternative Is Being Overlooked (MEDIUM CONFIDENCE)

Before building custom tactics or metaprogramming, consider:

1. **`@[simp]` audit**: Only 147 lemmas are tagged. Systematically tagging key lemmas (membership, formula normalization, context operations) could dramatically improve `simp` effectiveness with zero metaprogramming.

2. **Better helper lemmas**: `Combinators.lean` (673 lines) provides `imp_trans`, `mp`, `identity`, `b_combinator`, `theorem_flip`, `pairing`, `dni`. Extending this with more compositional helpers (e.g., `box_imp_trans`, `context_mp`, `weakening_mp`) would reduce proof sizes with no custom tactic overhead.

3. **Notation/abbreviation cleanup** (task 175 already covers this): Many proofs are hard to write because names like `bfmcs`, `drm`, `cud` are unreadable, not because tactics are missing.

4. **`decide` for propositional membership**: Many proofs have verbose `List.mem_cons` chains (167 occurrences in Metalogic). If `Context` is `List Formula` with decidable equality, `decide` or `simp` could close these automatically.

### 8. Missing: Impact on Build Times (LOW CONFIDENCE)

Custom elaboration tactics and metaprogramming can significantly increase build times in Lean 4. The project currently has 0 build errors and presumably reasonable build times. The research should quantify:
- Current build time
- Expected impact of heavy metaprogramming on incremental builds
- Whether `modal_search` with depth-limited DFS already causes noticeable slowdowns

## Recommended Approach

1. **Reframe the task**: Change from "build a systematic library of tactics" to "identify minimum viable infrastructure that supports the Wave 3 deep refactor." The research output should be a prioritized menu of options, not a comprehensive plan.

2. **Sequence correctly**: Do NOT build tactics before task 168 (FrameClass parameterization). The type signatures will change. Instead:
   - Phase 1 (now, pre-168): `@[simp]` audit, helper lemma library, naming cleanup
   - Phase 2 (post-168): Custom tactics if the refactored types warrant them

3. **Audit the existing Automation/**: Determine whether the existing 3,500 lines should be kept, refactored, or deleted as part of the refactor. Dead code (unused tactics) should be pruned, not extended.

4. **Focus on Metalogic/ patterns**: That's 78% of the codebase. Identify the 5 most common repetitive proof patterns there and ask whether `simp` lemmas, `ext` lemmas, or simple helper tactics (not full metaprogramming) would help.

5. **Consider the maintenance burden**: Every custom tactic is technical debt. It needs to be maintained across Lean updates, it needs documentation, and it needs to be understood by anyone working on the project. For a ~25k-line (non-Metalogic) project, the overhead may exceed the benefit.

## Evidence/Examples

### Example: Unused tactic complexity vs simple alternative

Current `modal_4_tactic` (lines 378-408 of Tactics.lean): 30 lines of metaprogramming with deep pattern matching on `Expr` constructors to apply one axiom.

Alternative: A 2-line helper lemma:
```lean
def modal_4_apply (φ : Formula) (Γ : Context) : Γ ⊢ (φ.box).imp (φ.box.box) :=
  DerivationTree.axiom Γ _ (Axiom.modal_4 φ)
```

This achieves the same thing with zero metaprogramming, zero fragility, and zero maintenance cost.

### Example: `apply_axiom` and `modal_t` are identical

Both `apply_axiom` and `modal_t` expand to the same macro:
```lean
macro "apply_axiom" : tactic => `(tactic| (apply DerivationTree.axiom; refine ?_))
macro "modal_t" : tactic => `(tactic| (apply DerivationTree.axiom; refine ?_))
```

This suggests the tactic development wasn't coordinated — two names for the same expansion. New infrastructure should avoid this duplication.

### Example: Where `@[simp]` could help immediately

In Metalogic/, there are 167 occurrences of `List.mem_cons` patterns for context membership proofs. If formula `DecidableEq` is available (it should be), many of these could be closed by `simp` with appropriate lemmas tagged, or by `decide`.

## Confidence Levels

| Finding | Confidence |
|---------|-----------|
| 1. Existing tactics unused | **High** — grep evidence is conclusive |
| 2. Aesop failure is architectural | **High** — `DerivationTree : Type` is root cause |
| 3. Sequencing problem (task 168) | **High** — type signature changes are certain |
| 4. Proofs don't need custom tactics | **Medium** — some automation could help, just not the proposed kind |
| 5. Metalogic is where mass lives | **High** — line counts are objective |
| 6. Effort estimate unrealistic | **Medium** — depends on final scope |
| 7. 80/20 alternative overlooked | **Medium** — needs validation via trial |
| 8. Build time impact | **Low** — not yet measured |
