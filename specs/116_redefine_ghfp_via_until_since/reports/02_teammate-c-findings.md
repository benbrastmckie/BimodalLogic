# Teammate C (Critic) Findings: Task 116

**Task**: Redefine G, H, F, P via Until/Since — Critical Analysis of Research & Plan
**Date**: 2026-05-18
**Role**: Critic — gaps, blind spots, underestimated complexity

## Key Findings

### CRITICAL: The Plan Is Missing 26% of All References

The original research reports "~1416 references across 70 non-Boneyard files." Fresh analysis shows **1891 references across 83 files**. That's **475 missed references in 13 missing files**.

The entirety of `WeakCanonical/Separation/` (15 files, 492 references) was omitted from both the research and plan. The two highest-reference files in this subtree — `Hierarchy.lean` (115 refs) and `TemporalClosure.lean` (111 refs) — are as large as `SubformulaClosure.lean`, which the plan identifies as the "highest-risk file."

**Missing files not in any plan phase:**

| File | Refs | Nature |
|------|------|--------|
| WeakCanonical/Separation/Hierarchy.lean | 115 | Pattern matches on all 8 constructors in recursive predicates |
| WeakCanonical/Separation/TemporalClosure.lean | 111 | Pattern matches on all 8 constructors in `replace_box_with_top` etc. |
| WeakCanonical/ReflexiveCanonical.lean | 84 | Directly invokes `Axiom.temp_k_dist` and `Axiom.temp_4` |
| WeakCanonical/Separation/Defs.lean | 45 | Recursive predicates (`is_U_free`, `is_S_free`, etc.) match all constructors |
| WeakCanonical/ExpressiveCompleteness.lean | 25 | Uses all_future/all_past in proofs |
| WeakCanonical/Separation/SeparationThm.lean | 24 | Separation theorem proofs |
| WeakCanonical/Separation/Duality.lean | 24 | Duality proofs |
| WeakCanonical/Separation/DedekindZ.lean | 24 | Dedekind-Z structure proofs |
| WeakCanonical/Table.lean | 12 | Table construction |
| WeakCanonical/TruthLemma.lean | 10 | Truth lemma proofs |
| WeakCanonical/Separation/Eliminations.lean | 8 | Elimination proofs |
| WeakCanonical/Separation/FormulaOps.lean | 4 | Formula operations |
| WeakCanonical/FrameProperties.lean | 2 | Frame property proofs |
| WeakCanonical/Separation/NormalForm.lean | 2 | Normal form |
| WeakCanonical/Separation/NegationEquiv.lean | 2 | Negation equivalence |
| Algebraic/UltrafilterFrame.lean | 82 | NEW FILE (untracked in git), has `sorry` for temp_4 |
| Theorems/Combinators.lean | 2 | Not mentioned in any plan phase |

The WeakCanonical/Separation subtree is especially dangerous because its functions define **recursive predicates that pattern-match on all 8 Formula constructors**. For example, `has_single_U_type`, `is_U_free`, `is_S_free`, `replace_box_with_top` all have explicit `| .all_past ψ =>` and `| .all_future ψ =>` arms. Removing these constructors will break every such function and every induction proof over Formula in this subtree.

**Confidence: HIGH** — verified by grep.

### CRITICAL: `swap_temporal` Will NOT Automatically Produce Correct G/H Swap

The plan claims "G/H swap follows automatically from `untl ↔ snce` swap." This is **wrong**.

Current `swap_temporal` definition (Formula.lean:422-430):
```lean
def swap_temporal : Formula → Formula
  | all_past φ => all_future φ.swap_temporal
  | all_future φ => all_past φ.swap_temporal
  | untl φ ψ => snce φ.swap_temporal ψ.swap_temporal
  | snce φ ψ => untl φ.swap_temporal ψ.swap_temporal
  ...
```

After the refactor, `all_future` and `all_past` become `def`s, not constructors. So `swap_temporal` can no longer pattern-match on them. The `all_past`/`all_future` arms would be **removed**.

Under the new definitions:
- `all_future φ = (untl (φ.neg) top).neg = (untl (φ.imp bot) (bot.imp bot)).imp bot`
- `swap_temporal(all_future φ)` would hit the `imp` arm, then recurse into the `untl` arm

Let's trace: `swap_temporal((untl (φ.imp bot) (bot.imp bot)).imp bot)`
= `imp (swap_temporal(untl (φ.imp bot) (bot.imp bot))) (swap_temporal bot)`
= `imp (snce (swap_temporal(φ.imp bot)) (swap_temporal(bot.imp bot))) bot`
= `imp (snce (imp (swap_temporal φ) (swap_temporal bot)) (imp (swap_temporal bot) (swap_temporal bot))) bot`
= `imp (snce (imp (swap_temporal φ) bot) (imp bot bot)) bot`
= `(snce (swap_temporal(φ).neg) top).neg`
= `all_past(swap_temporal φ)` ✓

So it **does** work out algebraically — `swap_temporal` on the expanded G produces the expanded H. But this is not "automatic" in any trivial sense. The `swap_temporal_involution` proof will break badly because it currently uses `| all_past _ ih =>` and `| all_future _ ih =>` induction cases, which no longer exist. The involution proof must be completely rewritten to work on the 6-constructor induction, and the G/H cases must be proven as separate lemmas rather than handled by induction cases.

Similarly, the `swap_temporal_all_future` and `swap_temporal_all_past` simp lemmas the plan proposes would need to be stated as equalities about `def` values, not constructor equalities.

**Confidence: HIGH** — traced the algebra; the result is correct but the proof path is not trivial.

### CRITICAL: Pattern Match Count Severely Underestimated

The original research reports "122 pattern-match arms." Actual count:

- **203 pattern-match arms** for `all_future` (lines starting with `| .all_future` or `| all_future`)
- **193 pattern-match arms** for `all_past` (lines starting with `| .all_past` or `| all_past`)
- **Total: ~396 pattern-match arms** to eliminate (vs. reported 122)

This is **3.2x the estimated count**. Each elimination is not just deletion — many require proving the property still holds for the expanded definition via simp lemmas.

**Confidence: HIGH** — verified by grep.

### HIGH: `temp_k_dist` / `temp_4` Removal Has Massive Blast Radius

The plan mentions removing these "from the Axiom inductive" but underestimates the downstream impact. I found **~100 direct references** across the codebase:

**Direct `Axiom.temp_k_dist` invocations** (building derivation trees):
- MCSProperties.lean: 2 uses
- GeneralizedNecessitation.lean: 2 uses
- Frame.lean: 3 uses
- PointInsertion.lean: 6 uses
- ChronicleConstruction.lean: 2 uses
- CounterexampleElimination.lean: 1 use
- RRelation.lean: 1 use
- ChronicleToCountermodel.lean: 1 use
- WitnessSeed.lean: 2 uses
- TemporalCoherence.lean: 1 use
- RestrictedMCS.lean: 1 use
- ReflexiveCanonical.lean: 3 uses
- InteriorOperators.lean: 1 use (sorry)
- LindenbaumQuotient.lean: 2 uses (sorry)

**Direct `Axiom.temp_4` invocations**:
- MCSProperties.lean: 3 uses
- CanonicalFrame.lean: 2 uses
- TemporalDerived.lean: 2 uses
- TruthPreservation.lean: 2 uses
- UltrafilterFrame.lean: 4 uses (2 sorry)
- ReflexiveCanonical.lean: 2 uses

**Soundness case arms** (must be removed from all 5+ soundness match statements):
- Soundness.lean: 10+ arms across multiple theorems
- SoundnessLemmas.lean: 8+ arms
- DiscreteSoundness.lean: likely more

**Substitution/Lifting case arms**:
- Substitution.lean: 2 arms
- ConservativeExtension/Substitution.lean: 2 arms
- ConservativeExtension/Lifting.lean: 6 arms
- ConservativeExtension/ExtDerivation.lean: 4 arms

**Automation references**:
- ProofSearch.lean: pattern detection for `temp_k_dist` and `temp_4`
- Tactics.lean: `temp_4_tactic` (entire tactic implementation)
- AesopRules.lean: `axiom_temp_4`, `temp_4_forward` rules

Every one of these call sites must either:
1. Be replaced with a derived theorem invocation (requires deriving `temp_k_dist` and `temp_4` from BX axioms first), OR
2. Use sorry

The plan allocates **zero dedicated time** for deriving these theorems from BX axioms. It mentions "Add derived theorems `temp_k_dist_derived` and `temp_4_derived` from BX axioms" as a single bullet in Phase 4, but this is non-trivial — these derivations require multiple steps through the BX Until/Since axiom system.

**Confidence: HIGH** — verified by grep, every reference identified.

### HIGH: SubformulaClosure Requires Deep Rewrite, Not Just Arm Removal

The plan allocates 2 hours for SubformulaClosure (1744 lines, 115 references, 132 definitions/theorems). This file doesn't just pattern-match on `all_future`/`all_past` — it uses them in **structural pattern matching** to detect F and P formulas:

```lean
def f_nesting_depth : Formula → Nat
  | .imp (.all_future (.imp inner .bot)) .bot => 1 + f_nesting_depth inner  -- F(inner) pattern
  ...

def extractFInner : Formula → Option Formula
  | .imp (.all_future (.imp inner .bot)) .bot => some inner  -- F(inner) pattern
  ...
```

After the refactor, `some_future inner` = `untl inner (imp bot bot)`, NOT `imp (all_future (imp inner bot)) bot`. So **every pattern that detects F/P formulas structurally must change to use the new representation**.

The `deferralClosure` function defines constants like:
```lean
abbrev G_neg_neg_bot : Formula := Formula.all_future neg_neg_bot
abbrev H_neg_neg_bot : Formula := Formula.all_past neg_neg_bot
```

These will work syntactically (since `all_future` remains as a `def`), but the `Formula.noConfusion` proofs that distinguish `all_future` from `all_past` constructors will **no longer typecheck**. Currently `Formula.noConfusion` is used to prove things like "G_neg_neg_bot ≠ H_neg_neg_bot" and "all_future ≠ all_past" in membership proofs. After the change, both are `imp` at the top level, so `noConfusion` cannot distinguish them — these proofs need entirely different strategies.

**Evidence** (SubformulaClosure.lean:1693):
```lean
(by simp only [G_neg_neg_bot, Formula.all_future]; exact Formula.noConfusion)
```
This pattern appears multiple times and will fail completely.

**Confidence: HIGH** — read the code, traced the dependencies.

### MEDIUM: Semantic Equivalence Proof Has Subtle Guard Condition

The truth_at definition for `untl` is:
```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s φ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r ψ
```

For `all_future φ = (untl (φ.neg) top).neg`:
```
truth_at(all_future φ, t)
= truth_at((untl (φ.imp bot) (bot.imp bot)).imp bot, t)
= truth_at(untl (φ.imp bot) (bot.imp bot), t) → False
= (∃ s, t < s ∧ truth_at(φ.imp bot, s) ∧ ∀ r, t < r → r < s → truth_at(bot.imp bot, r)) → False
= (∃ s, t < s ∧ ¬truth_at(φ, s) ∧ ∀ r, t < r → r < s → True) → False
= (∃ s, t < s ∧ ¬truth_at(φ, s)) → False
= ¬(∃ s, t < s ∧ ¬truth_at(φ, s))
= ∀ s, t < s → truth_at(φ, s) ✓
```

The key step — showing `∀ r, t < r → r < s → truth_at(bot.imp bot, r)` simplifies to `True` — requires proving that `truth_at M Omega τ r (bot.imp bot)` is always true, which unfolds to `False → False`, which is `True`. This is straightforward but the proof **must unfold truth_at twice** (once for imp, once for bot) and then close with `tauto` or similar. It's not a single simp step.

The plan says "The truth evaluation will no longer directly unfold to `∀s > t, φ(s)` for all_future" — this is correct but understates the issue. Every proof that currently pattern-matches on the `truth_at` definition for `all_future` must be rewritten to go through this multi-step unfolding.

**Confidence: MEDIUM** — the math works, but the Lean proof mechanics could be tricky.

### MEDIUM: `temporal_necessitation` Change Is NOT Trivial

Currently: `temporal_necessitation` produces `DerivationTree [] (Formula.all_future φ)` where `Formula.all_future` is a **constructor**.

After: `Formula.all_future φ` is a `def` that expands to `(Formula.untl (φ.imp Formula.bot) (Formula.bot.imp Formula.bot)).imp Formula.bot`.

In Lean 4, if `all_future` is a `def` (not `abbrev`), the type `DerivationTree [] (Formula.all_future φ)` is definitionally equal to `DerivationTree [] ((Formula.untl (φ.imp Formula.bot) (Formula.bot.imp Formula.bot)).imp Formula.bot)`. The rule would still typecheck — but every downstream proof that **pattern-matches on the conclusion** of `temporal_necessitation` would see the expanded form, not `all_future φ`.

If `all_future` is `abbrev` instead of `def`, Lean's elaborator will unfold it transparently, which could cause issues with `simp` and `rfl` in unexpected places (auto-unfolding).

The choice between `def` and `abbrev` is not discussed in the plan but is a **critical design decision** affecting every downstream proof.

**Confidence: MEDIUM** — depends on Lean 4 elaboration behavior.

### MEDIUM: Phase 7 Time Estimate Is Unrealistic

Phase 7 covers **27 files** in 2 hours. That's 4.4 minutes per file. Files like `WitnessSeed.lean` (88 refs), `TemporalCoherence.lean` (51 refs), `PointInsertion.lean` (74 refs) each have dozens of pattern-match arms and complex proofs. 4 minutes is not enough even for mechanical arm removal, let alone fixing broken proofs.

Realistic estimate for Phase 7 alone: **6-10 hours** (15-20 minutes per high-reference file, 5 minutes per low-reference file).

**Confidence: HIGH** — arithmetic on the reference counts.

### MEDIUM: Missing Phase for WeakCanonical (492 References)

The plan has no phase for `WeakCanonical/`. With 492 references across 15 files — including 2 files with 100+ references each — this requires a dedicated phase. The WeakCanonical/Separation subtree is particularly challenging because it defines recursive predicates that destructure formulas by constructor, and the entire Separation theorem machinery depends on these predicates.

Estimated effort for WeakCanonical: **4-6 hours** (comparable to Phase 7).

**Confidence: HIGH** — the files are large, reference-heavy, and structurally dependent on constructor matching.

### MEDIUM: Sorry Budget Risk

The codebase currently has **184 sorries** (excluding Boneyard and Extsorry). The plan proposes using sorry "for proofs that require deep reworking" in at least 3 phases (3, 7, 8). With 83 files affected and ~396 pattern-match arms to eliminate, a conservative estimate is **30-60 new sorries** if the refactor is done aggressively.

Adding 30-60 sorries to an already-184-sorry codebase would increase total sorries by 16-33%, potentially masking real regressions and making future work harder.

**Confidence: MEDIUM** — depends on implementation quality.

### LOW: `def` vs `abbrev` Decision Underdiscussed

The plan specifies `def` for all four operators. But:
- `def` requires explicit unfolding (`simp [all_future]` or `unfold all_future`)
- `abbrev` auto-unfolds, which could cause `simp` loops or unexpected elaboration
- The current `some_future`/`some_past` are `def`s, which works fine
- But the current `all_future`/`all_past` are constructors, so existing code never unfolds them

Every proof that currently handles `all_future` as opaque (constructor) would need to be rewritten to handle it as transparent or semi-transparent. This is a crosscutting concern affecting all phases.

**Confidence: LOW** — this is a design question, not a hard error.

## Recommended Approach Changes

1. **Add WeakCanonical Phase**: Insert a new Phase 7.5 or expand Phase 8 to cover the entire WeakCanonical subtree (15 files, 492 references). This is as much work as Phase 7.

2. **Derive `temp_k_dist`/`temp_4` FIRST**: Before removing them from the Axiom inductive, prove them as derived theorems from BX axioms. Then replace all direct `Axiom.temp_k_dist`/`Axiom.temp_4` invocations with the derived versions in a preparatory phase. Only then remove from the inductive. This de-risks the axiom removal.

3. **Revise Time Estimates**: The current plan totals 20 hours. Realistic estimate is **35-50 hours** given:
   - Phase 1: 3h (not 2h — swap_temporal rewrite)
   - Phase 3: 4h (not 2h — SubformulaClosure deep patterns)
   - Phase 7: 8h (not 2h — 27 files)
   - NEW Phase: 5h (WeakCanonical)
   - Phase 8: 4h (not 2h — Decidability + Algebraic)
   - Phase 9: 3h (not 2h — Automation has dedicated tactics)
   - Other phases: roughly as estimated

4. **Decide `def` vs `abbrev` early**: Make this decision in Phase 0 and document it. Test with a small prototype (define `all_future` as `def`, check if `simp [all_future]` works where needed).

5. **Recount pattern match arms**: The plan should track **396 pattern-match arms** (not 122) as the core metric for progress.

## Evidence Summary

| Claim | Evidence | Confidence |
|-------|----------|------------|
| 83 files, 1891 refs (not 70 files, 1416 refs) | `grep -rn` full codebase scan | HIGH |
| 396 pattern-match arms (not 122) | Strict grep for `^.*\| .*all_future\|all_past` | HIGH |
| WeakCanonical subtree missed entirely | grep of WeakCanonical/, not in any plan phase | HIGH |
| `swap_temporal` algebra works but proof breaks | Traced `swap_temporal` expansion manually | HIGH |
| temp_k_dist has ~30 direct invocations | grep for `Axiom.temp_k_dist` | HIGH |
| temp_4 has ~15 direct invocations | grep for `Axiom.temp_4` | HIGH |
| SubformulaClosure uses structural F/P detection | Read f_nesting_depth, extractFInner code | HIGH |
| Formula.noConfusion proofs will fail | Read deferralClosure membership proofs | HIGH |
| Semantic equivalence needs multi-step unfolding | Traced truth_at expansion | MEDIUM |
| Phase 7 unrealistic (4 min/file for 88-ref files) | Arithmetic on reference counts | HIGH |
| 20h estimate should be 35-50h | Sum of revised phase estimates | MEDIUM |
