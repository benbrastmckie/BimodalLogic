# Seed Research Report: Propositional Fragment Decision Procedure

**Task**: #191 — Propositional fragment decision procedure
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The propositional fragment of TM logic is axiomatized by four schemata: `prop_k` (distribution), `prop_s` (weakening), `ex_falso` (explosion), and `peirce` (classical reasoning). Together these form a complete axiomatization of classical propositional logic — every tautology is derivable, and every derivable formula with no modal/temporal operators is a tautology. This completeness is well-known but currently unexploited in the codebase: every propositional theorem in `Theorems/Propositional.lean` (1712 lines) and `Theorems/Combinators.lean` (673 lines) is proven by explicit term-level construction, manually chaining `DerivationTree.axiom`, `DerivationTree.modus_ponens`, and `imp_trans`.

A verified decision procedure would let `decide` close any propositional derivability goal automatically. This eliminates the need for manual Hilbert-style proofs of propositional tautologies and provides a foundation for the `tm_prove` master dispatch tactic (task 192). The procedure itself — a verified decision procedure for classical propositional logic embedded inside a modal logic framework — is independently publishable.

The key enabler is task 181's `Derivable` wrapper. A `Decidable (Derivable [] p)` instance for propositional `p` requires the Prop-valued predicate; it cannot be stated for the Type-valued `DerivationTree`.

## Current State

### Axiom System (Axioms.lean:74-88)

The four propositional axiom constructors in the `Axiom` inductive type:

```lean
| prop_k (φ ψ χ : Formula) : Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
| prop_s (φ ψ : Formula) : Axiom (φ.imp (ψ.imp φ))
| ex_falso (φ : Formula) : Axiom (Formula.bot.imp φ)
| peirce (φ ψ : Formula) : Axiom (((φ.imp ψ).imp φ).imp φ)
```

This is the K+S+EFQ+Peirce Hilbert system, which is complete for classical propositional logic.

### Formula Type (Formula.lean:70-85)

The `Formula` inductive has 6 constructors: `atom`, `bot`, `imp`, `box`, `untl`, `snce`. A formula is "propositional" iff it uses only `atom`, `bot`, and `imp`. The derived operators `neg`, `and`, `or` are all defined in terms of `imp` and `bot`, so they are propositional.

Key existing infrastructure:
- `Formula.atoms : Formula → Finset Atom` (Formula.lean:529) — extracts the set of atoms
- `Formula.complexity : Formula → Nat` (Formula.lean:162) — structural measure
- `DecidableEq Formula` (derived, Formula.lean:85)
- `BEq Formula` and `LawfulBEq Formula` (Formula.lean:192-247)

### Existing Computable Search (ProofSearch.lean)

`matches_axiom` (ProofSearch.lean:302-377) already does computable pattern matching on axiom schemata. `matchAxiom` (ProofSearch.lean:396-517) returns the actual `Sigma Axiom` witness. `bounded_search_with_proof` (ProofSearch.lean:886-959) can construct `DerivationTree` proof terms for propositional goals via axiom matching and context-based modus ponens.

### Existing Propositional Proofs

All proofs in `Theorems/Propositional.lean` (1712 lines) and `Theorems/Combinators.lean` (673 lines) use explicit term construction — manual `DerivationTree.axiom`, `DerivationTree.modus_ponens`, and helper lemmas like `imp_trans`, `identity`, `b_combinator`, `theorem_flip`. The proofs are typically 5-30 lines each for theorems like `lem`, `ecq`, `raa`, `efq`, `lce`, `rce`, `double_negation`, `rcp`.

## Proposed Approach

### Option A: Truth-Table Evaluation (Recommended for simplicity)

1. **Define `isPropositional : Formula → Bool`** — returns true iff formula uses only `atom`, `bot`, `imp`.

2. **Define `BoolEval : (Atom → Bool) → Formula → Bool`** — evaluate a propositional formula under a Boolean assignment:
   ```lean
   def BoolEval (v : Atom → Bool) : Formula → Bool
     | .atom a => v a
     | .bot => false
     | .imp φ ψ => !BoolEval v φ || BoolEval v ψ
     | _ => false  -- non-propositional: vacuously false
   ```

3. **Define `isTautology (p : Formula) : Bool`** — check all assignments. Extract atoms via `p.atoms`, enumerate all `2^n` assignments, check `BoolEval` under each.

4. **Prove soundness**: `isTautology p = true → Derivable [] p`. This requires constructing a derivation from the truth-table certificate. The standard approach: for each row of the truth table, build a derivation from the row's assumptions, then use Peirce's law / case analysis to eliminate assumptions.

5. **Prove completeness**: `Derivable [] p → isTautology p = true`. This follows from the soundness theorem for the full logic (propositional fragment preserves truth under all Boolean valuations).

6. **Register Decidable instance**:
   ```lean
   instance (p : Formula) [h : isPropositional p = true] : Decidable (Derivable [] p) :=
     if ht : isTautology p = true then isTrue (soundness_of_tautology ht)
     else isFalse (fun hd => absurd (completeness_to_tautology hd) ht)
   ```

### Option B: Analytic Tableaux

More efficient (avoids exponential blowup for large formulas) but significantly harder to formalize. A tableau checks satisfiability of the negation; if the tableau closes, the formula is a tautology. This would require:
- Defining signed formulas and branches
- Proving tableau soundness and completeness
- Converting closed tableaux to derivations

Option B is appropriate as a Tier 3 follow-up if performance matters for large formulas.

### Integration with `decide` Tactic

Once the `Decidable` instance exists, propositional goals become:
```lean
example : Derivable [] (p.imp (q.imp p)) := by decide
```

For non-trivial propositional goals, `decide` may be slow (exponential in atom count). A `decide_prop` tactic wrapper could:
1. Check `isPropositional` first
2. Use `native_decide` for better performance
3. Fall back to `modal_search` if not propositional

## Key Questions for Research Phase

1. How many atoms appear in the largest propositional theorems in `Theorems/Propositional.lean`? This determines whether truth-table evaluation is practical (feasible up to ~20 atoms).
2. Can we use `native_decide` for the evaluation step to avoid kernel-level performance issues?
3. What is the best Lean 4 pattern for enumerating all assignments to a `Finset Atom`? Does Mathlib have `Finset.pi` or similar?
4. How does the soundness proof work in detail — given `isTautology p = true`, how do we construct `Derivable [] p`? The standard proof-theoretic approach uses the deduction theorem, which is already available in `Metalogic/Core/DeductionTheorem.lean`.
5. Should the `Decidable` instance use a typeclass or an explicit predicate for `isPropositional`?
6. Is there a Mathlib precedent for verified propositional decision procedures? Check `Mathlib.Tactic.Decide` and related.

## Estimated Scope

- **Phase 1** (10h): `isPropositional`, `BoolEval`, `isTautology` definitions + basic properties
- **Phase 2** (15h): Soundness proof (`isTautology p = true → Derivable [] p`) — the hard part
- **Phase 3** (5h): Completeness proof (`Derivable [] p → isTautology p = true`)
- **Phase 4** (5h): `Decidable` instance, `decide_prop` tactic, integration tests
- **Total**: ~35 hours

## Dependencies

- **Depends on**: Task 181 (Derivable Prop-valued wrapper — needed for `Decidable` instance)
- **Depends on**: `Metalogic/Core/DeductionTheorem.lean` (for soundness proof construction)
- **Depended on by**: Task 192 (master tactic dispatch — uses `decide_prop` for propositional goals)

## References

- `Theories/Bimodal/ProofSystem/Axioms.lean:74-88` — propositional axiom schemata
- `Theories/Bimodal/Syntax/Formula.lean:70-85` — Formula type definition
- `Theories/Bimodal/Syntax/Formula.lean:529` — `Formula.atoms` atom extraction
- `Theories/Bimodal/Theorems/Propositional.lean` — 1712 lines of manual propositional proofs
- `Theories/Bimodal/Theorems/Combinators.lean` — 673 lines of combinator infrastructure
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` — deduction theorem (needed for soundness)
- `Theories/Bimodal/Automation/ProofSearch.lean:302-517` — existing computable axiom matching
- Enderton, H. *A Mathematical Introduction to Logic* (Ch. 1-2: propositional completeness)
- FormalizedFormalLogic/Foundation — Prop-valued provability patterns
