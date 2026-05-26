# Research Report: Derived Operator Normalization Tactic (modal_norm)

**Task**: #190 -- Derived operator normalization tactic
**Date**: 2026-05-26
**Session**: sess_1779809662_d9784a
**Type**: Full research report (round 2)

## 1. Formula Type Inventory

### 1.1 Primitive Constructors (6)

The `Formula` inductive type (Formula.lean:70-84) has exactly 6 constructors:

| Constructor | Signature | Description |
|-------------|-----------|-------------|
| `atom` | `Atom -> Formula` | Propositional variable |
| `bot` | `Formula` | Falsum |
| `imp` | `Formula -> Formula -> Formula` | Implication |
| `box` | `Formula -> Formula` | Modal necessity |
| `untl` | `Formula -> Formula -> Formula` | Until (event, guard) |
| `snce` | `Formula -> Formula -> Formula` | Since (event, guard) |

### 1.2 Derived Operators (15)

All are `def` abbreviations in `Formula.lean:112-383`:

| Operator | Definition | Full Primitive Expansion | Term Size Ratio |
|----------|-----------|--------------------------|-----------------|
| `top` | `bot.imp bot` | `imp bot bot` | 1:1 |
| `neg phi` | `phi.imp bot` | `imp phi bot` | 1:1 |
| `and phi psi` | `(phi.imp psi.neg).neg` | `imp (imp phi (imp psi bot)) bot` | 1:2.3 |
| `or phi psi` | `phi.neg.imp psi` | `imp (imp phi bot) psi` | 1:1.7 |
| `diamond phi` | `phi.neg.box.neg` | `imp (box (imp phi bot)) bot` | 1:2.3 |
| `some_future phi` | `untl phi top` | `untl phi (imp bot bot)` | 1:1.5 |
| `some_past phi` | `snce phi top` | `snce phi (imp bot bot)` | 1:1.5 |
| `all_future phi` | `(some_future phi.neg).neg` | `imp (untl (imp phi bot) (imp bot bot)) bot` | 1:3.5 |
| `all_past phi` | `(some_past phi.neg).neg` | `imp (snce (imp phi bot) (imp bot bot)) bot` | 1:3.5 |
| `next phi` | `untl phi bot` | `untl phi bot` | 1:1 |
| `prev phi` | `snce phi bot` | `snce phi bot` | 1:1 |
| `weak_future phi` | `phi.and phi.all_future` | (deeply nested) | 1:6+ |
| `weak_past phi` | `phi.and phi.all_past` | (deeply nested) | 1:6+ |
| `always phi` | `phi.all_past.and (phi.and phi.all_future)` | (deeply nested) | 1:15+ |
| `sometimes phi` | `phi.neg.always.neg` | (deeply nested) | 1:20+ |

Additionally, `iff` is defined in `ModalS5.lean:486` as `(A.imp B).and (B.imp A)`.

### 1.3 Operator Dependency Graph

```
Level 0 (primitives): atom, bot, imp, box, untl, snce
Level 1 (single step): neg, top, next, prev
Level 2 (uses Level 1): and, or, diamond, some_future, some_past
Level 3 (uses Level 2): all_future, all_past
Level 4 (uses Level 3): weak_future, weak_past
Level 5 (uses Level 4): always
Level 6 (uses Level 5): sometimes
```

This dependency structure determines the order of unfolding lemmas: the tactic must unfold from Level 6 down to Level 0 for full normalization. With `simp only [...]`, Lean handles this automatically via repeated rewriting.

## 2. Existing Normalization Infrastructure

### 2.1 Aesop Norm Unfold Rules (AesopRules.lean:249-274)

Four operators have `@[aesop norm unfold]` annotations:

```lean
@[aesop norm unfold] def normalize_diamond := @Formula.diamond
@[aesop norm unfold] def normalize_always := @Formula.always
@[aesop norm unfold] def normalize_sometimes := @Formula.sometimes
@[aesop norm unfold] def normalize_some_past := @Formula.some_past
```

**Missing** from aesop normalization: `neg`, `and`, `or`, `top`, `some_future`, `all_future`, `all_past`, `next`, `prev`, `weak_future`, `weak_past`, `iff`.

**Status**: These rules are part of a DEPRECATED system (AesopRules.lean:11-15). The `tm_auto` tactic now delegates to `modal_search` instead of Aesop. The aesop rules are preserved for reference only.

### 2.2 Simp Lemmas (Formula.lean)

The `@[simp]` lemmas in Formula.lean are for `swap_temporal` and `needsPositiveHypotheses` -- NOT for operator unfolding. There are NO `@[simp]` lemmas that unfold the derived operators to primitives.

However, `simp only [Formula.neg, Formula.diamond, ...]` works because `simp` can unfold `def` definitions by name. This is used extensively across 26 files with ~350 occurrences (see Section 4 for details).

### 2.3 Substitution Lemmas (Substitution.lean:87-115)

The substitution file provides `@[simp]` lemmas that commute substitution with derived operators:

```lean
@[simp] theorem subst_neg : (neg phi).subst q r = neg (phi.subst q r)
@[simp] theorem subst_and : (Formula.and phi psi).subst q r = ...
@[simp] theorem subst_or : (Formula.or phi psi).subst q r = ...
@[simp] theorem subst_diamond : (diamond phi).subst q r = ...
@[simp] theorem subst_some_past : (some_past phi).subst q r = ...
@[simp] theorem subst_some_future : (some_future phi).subst q r = ...
```

These are NOT unfolding lemmas -- they preserve the derived form. But they demonstrate that `@[simp]` works well with these operators.

### 2.4 Pattern Matching in ProofSearch.lean

**Critical observation**: The `matches_axiom` function (ProofSearch.lean:302-377) uses a MIX of derived and primitive patterns:

- `.diamond (.box phi)` -- uses derived `diamond` in a pattern (line 334)
- `.all_future (.some_past phi')` -- uses derived `all_future` and `some_past` (line 343)
- `.and (.all_past phi1) (.and phi2 (.all_future phi3))` -- uses `and`, `all_past`, `all_future` (line 348)
- `.imp (.all_future (.imp phi .bot)) .bot` -- manual expansion of `some_future` (line 369)

This works at the computable level because Lean expands `def` abbreviations during pattern compilation. The `.diamond _` pattern is compiled to `.imp (.box (.imp _ .bot)) .bot`.

The `matchAxiom` function (ProofSearch.lean:396-517) uses ONLY primitive patterns for direct axiom witness construction. It explicitly expands derived operators:
- `modal_5_collapse`: matches `.imp (.box (.imp phi .bot)) .bot` (expanded diamond)
- `modal_b`: matches `.imp (.box (.imp phi' .bot)) .bot` (expanded diamond)
- `connect_future`: matches `.all_future (.imp (.all_past (.imp phi' .bot)) .bot)` (expanded some_past inside all_future)

**Conclusion**: `matchAxiom` already works on primitives. The normalization tactic primarily benefits the meta-level (Tactics.lean) and user-facing proof states.

### 2.5 Tactics.lean Pattern Matching

The `tryAxiomMatch` function (Tactics.lean:511-588) works at the Lean Expr meta-level, matching against `mkConst` names like `Formula.box`, `Formula.imp`, etc. It does NOT unfold derived operators. When a goal is stated using `diamond`, the Expr tree contains `Formula.diamond` applications that `tryAxiomMatch` does not recognize.

Similarly, `extractUnboxedContext` (line 730) checks for `.app (.const ``Formula.box _) inner` patterns. A formula like `diamond phi` at the meta level would appear as `.app (.const ``Formula.diamond _) phi`, which would NOT match the `.box` pattern.

**This is the primary problem modal_norm solves**: at the meta-level, Lean Exprs preserve the `def` application structure. A `diamond phi` Expr is `@Formula.diamond phi`, not `Formula.imp (Formula.box (Formula.imp phi Formula.bot)) Formula.bot`. The tactic needs to unfold these before pattern matching.

## 3. Usage Pattern Analysis

### 3.1 Derived Operator Frequency (Across All Theories Files)

| Operator | Occurrences | Rank |
|----------|-------------|------|
| `neg` | 4138 | 1 |
| `and` | 1770 | 2 |
| `all_future` | 1055 | 3 |
| `some_future` | 878 | 4 |
| `all_past` | 722 | 5 |
| `or` | 510 | 6 |
| `some_past` | 506 | 7 |
| `diamond` | 309 | 8 |
| `top` | 226 | 9 |
| `always` | 132 | 10 |
| `sometimes` | 33 | 11 |
| `prev` | 13 | 12 |
| `next` | 12 | 13 |
| `weak_future` | 0 | 14 |
| `weak_past` | 0 | 15 |

### 3.2 Derived Operator Frequency (Theorems Directory Only)

| Operator | Occurrences |
|----------|-------------|
| `neg` | 560 |
| `and` | 337 |
| `diamond` | 180 |
| `all_future` | 110 |
| `always` | 104 |
| `or` | 85 |
| `all_past` | 56 |
| `sometimes` | 19 |
| `some_future` | 18 |
| `top` | 11 |
| `some_past` | 3 |

### 3.3 Files Already Using Manual Normalization

26 files already use `simp only [Formula.neg, Formula.diamond, ...]` patterns with approximately 350 call sites. The most prominent:

- `Metalogic/BXCanonical/Quasimodel/Realization.lean` -- heavy temporal operator unfolding
- `Metalogic/WeakCanonical/Separation/` -- multiple files with operator unfolding
- `Metalogic/SoundnessLemmas.lean` -- swap_temporal + operator unfolding
- `ProofSystem/Substitution.lean` -- substitution commutation proofs

### 3.4 Impact Estimate

- **Immediate benefit**: A `modal_norm` tactic replaces the ad-hoc `simp only [Formula.neg, Formula.and, ...]` patterns in ~350 call sites across 26 files, providing a single canonical normalization interface.
- **Proof search benefit**: Preprocessing goals with `modal_norm` before `modal_search` eliminates the Expr-level mismatch described in Section 2.5.
- **New development benefit**: Future proofs can use `modal_norm` as a standard preprocessing step rather than manually enumerating which derived operators to unfold.

## 4. Tactic Design Proposal

### 4.1 Architecture Overview

```
Normalization.lean
  |
  +-- Unfolding lemma declarations (@[modal_norm_unfold])
  +-- modal_norm macro (full normalization)
  +-- prop_norm macro (propositional operators only)
  +-- modal_op_norm macro (modal operators only)
  +-- temporal_norm macro (temporal operators only)
```

### 4.2 Custom Simp Attribute (Recommended Approach)

Use `Lean.Meta.registerSimpAttr` to create a dedicated `@[modal_norm_unfold]` attribute:

```lean
-- File: Theories/Bimodal/Automation/Normalization.lean
import Bimodal.Syntax.Formula
import Lean

open Bimodal.Syntax

-- Register custom simp attribute for modal normalization
initialize modalNormExt : Lean.Meta.SimpExtension :=
  Lean.Meta.registerSimpAttr `modal_norm_unfold
    "Unfold derived modal/temporal operators to primitives"
```

**Pros**: Extensible (new operators can add `@[modal_norm_unfold]`), self-documenting, integrable with Lean's simp infrastructure.

**Cons**: Requires `initialize` block (one-time setup cost), slightly more complex than a plain macro.

### 4.3 Alternative: Plain Macro (Simpler Approach)

```lean
-- Full normalization to primitives
macro "modal_norm" : tactic =>
  `(tactic| simp only [
    Formula.neg, Formula.top, Formula.and, Formula.or,
    Formula.diamond, Formula.some_future, Formula.some_past,
    Formula.all_future, Formula.all_past, Formula.next, Formula.prev,
    Formula.weak_future, Formula.weak_past, Formula.always, Formula.sometimes])
```

**Pros**: Zero infrastructure, no `initialize` block, works immediately.

**Cons**: Not extensible (hardcoded list), no attribute for discovery, must update macro when new operators are added.

### 4.4 Recommended: Hybrid Approach

Use the plain macro for immediate utility, but structure it so migration to the attribute-based approach is straightforward:

```lean
-- Theories/Bimodal/Automation/Normalization.lean
import Bimodal.Syntax.Formula
import Lean

open Bimodal.Syntax

namespace Bimodal.Automation

/-! ## Normalization Lemmas

Each derived operator has a definitional unfolding lemma.
These are collected into simp-based normalization tactics.
-/

-- Level 1: Single-step from primitives
theorem neg_unfold (phi : Formula) : phi.neg = phi.imp .bot := rfl
theorem top_unfold : Formula.top = Formula.bot.imp .bot := rfl
theorem next_unfold (phi : Formula) : phi.next = Formula.untl phi .bot := rfl
theorem prev_unfold (phi : Formula) : phi.prev = Formula.snce phi .bot := rfl

-- Level 2: Uses Level 1
theorem and_unfold (phi psi : Formula) :
    phi.and psi = (phi.imp psi.neg).neg := rfl
theorem or_unfold (phi psi : Formula) :
    phi.or psi = phi.neg.imp psi := rfl
theorem diamond_unfold (phi : Formula) :
    phi.diamond = phi.neg.box.neg := rfl
theorem some_future_unfold (phi : Formula) :
    phi.some_future = Formula.untl phi Formula.top := rfl
theorem some_past_unfold (phi : Formula) :
    phi.some_past = Formula.snce phi Formula.top := rfl

-- Level 3: Uses Level 2
theorem all_future_unfold (phi : Formula) :
    phi.all_future = (phi.neg.some_future).neg := rfl
theorem all_past_unfold (phi : Formula) :
    phi.all_past = (phi.neg.some_past).neg := rfl

-- Level 4: Uses Level 3
theorem weak_future_unfold (phi : Formula) :
    phi.weak_future = phi.and phi.all_future := rfl
theorem weak_past_unfold (phi : Formula) :
    phi.weak_past = phi.and phi.all_past := rfl

-- Level 5: Uses Level 4
theorem always_unfold (phi : Formula) :
    phi.always = phi.all_past.and (phi.and phi.all_future) := rfl

-- Level 6: Uses Level 5
theorem sometimes_unfold (phi : Formula) :
    phi.sometimes = phi.neg.always.neg := rfl

/-! ## Normalization Tactics -/

/-- Full normalization: unfold ALL derived operators to the 6 primitives.
    After `modal_norm`, the goal contains only: atom, bot, imp, box, untl, snce. -/
macro "modal_norm" : tactic =>
  `(tactic| simp only [
    sometimes_unfold, always_unfold,
    weak_future_unfold, weak_past_unfold,
    all_future_unfold, all_past_unfold,
    some_future_unfold, some_past_unfold,
    diamond_unfold, and_unfold, or_unfold,
    neg_unfold, top_unfold, next_unfold, prev_unfold])

/-- Propositional normalization: unfold only propositional derived operators
    (neg, top, and, or). Preserves modal and temporal structure. -/
macro "prop_norm" : tactic =>
  `(tactic| simp only [neg_unfold, top_unfold, and_unfold, or_unfold])

/-- Modal normalization: unfold only the diamond operator.
    Preserves propositional and temporal structure. -/
macro "modal_op_norm" : tactic =>
  `(tactic| simp only [diamond_unfold])

/-- Temporal normalization: unfold temporal derived operators
    (some_future, some_past, all_future, all_past, next, prev,
    weak_future, weak_past, always, sometimes).
    Preserves propositional and modal structure. -/
macro "temporal_norm" : tactic =>
  `(tactic| simp only [
    sometimes_unfold, always_unfold,
    weak_future_unfold, weak_past_unfold,
    all_future_unfold, all_past_unfold,
    some_future_unfold, some_past_unfold,
    next_unfold, prev_unfold, top_unfold])

/-- Shallow normalization: unfold one level of derived operators.
    Useful for intermediate reasoning steps where full expansion is too aggressive.
    Only unfolds top-level derived operators, not their sub-terms. -/
macro "modal_norm1" : tactic =>
  `(tactic| simp only [
    sometimes_unfold, always_unfold,
    weak_future_unfold, weak_past_unfold,
    all_future_unfold, all_past_unfold,
    some_future_unfold, some_past_unfold,
    diamond_unfold, and_unfold, or_unfold,
    neg_unfold, top_unfold, next_unfold, prev_unfold]
    (config := { maxSteps := 1 }))

end Bimodal.Automation
```

**Note on `modal_norm1`**: The `maxSteps := 1` config limits `simp` to a single rewriting pass. This provides "one level" of unfolding. However, this may not be practical in practice since `simp` applies all matching rules in each step. An alternative is to define separate single-level macros (e.g., `unfold_always` that only unfolds `always` to `all_past.and (_.and _.all_future)` without further unfolding).

### 4.5 Hypothesis Normalization

The macros above normalize the goal. For normalizing hypotheses:

```lean
/-- Normalize a specific hypothesis. -/
macro "modal_norm_at" h:ident : tactic =>
  `(tactic| simp only [
    sometimes_unfold, always_unfold,
    weak_future_unfold, weak_past_unfold,
    all_future_unfold, all_past_unfold,
    some_future_unfold, some_past_unfold,
    diamond_unfold, and_unfold, or_unfold,
    neg_unfold, top_unfold, next_unfold, prev_unfold] at $h)

/-- Normalize all hypotheses and the goal. -/
macro "modal_norm_all" : tactic =>
  `(tactic| simp only [
    sometimes_unfold, always_unfold,
    weak_future_unfold, weak_past_unfold,
    all_future_unfold, all_past_unfold,
    some_future_unfold, some_past_unfold,
    diamond_unfold, and_unfold, or_unfold,
    neg_unfold, top_unfold, next_unfold, prev_unfold] at *)
```

### 4.6 Canonicalization of Negation

The task description mentions "optionally canonicalize negation to `imp ... bot`". This is already achieved by `neg_unfold`: since `neg phi` is defined as `phi.imp bot`, the lemma `neg_unfold` rewrites any `neg` application to the primitive `imp ... bot` form.

For the reverse direction (folding `imp phi bot` back to `neg phi`), a separate "fold" tactic could be useful for readability:

```lean
theorem neg_fold (phi : Formula) : phi.imp .bot = phi.neg := rfl

macro "modal_fold_neg" : tactic =>
  `(tactic| simp only [<- neg_unfold])
```

### 4.7 Integration with modal_search

The `modal_search` tactic in Tactics.lean should call `modal_norm` as an optional preprocessing step. Two integration points:

**Option A: Preprocessing in runModalSearch** (recommended):
```lean
def runModalSearch (cfg : SearchConfig) : TacticM Unit := do
  let goal <- getMainGoal
  let goalType <- goal.getType
  let some (_fc, _ctx, _formula) <- extractDerivationGoal goalType
    | throwError "modal_search: goal must be a derivability relation"
  -- NEW: Normalize derived operators before search
  if cfg.normalize then
    try evalTactic (<- `(tactic| modal_norm)) catch _ => pure ()
  let found <- searchProof goal cfg.depth cfg.depth
  if !found then
    throwError "modal_search: no proof found within depth {cfg.depth}"
```

**Option B: User-facing composition**:
```lean
-- Users can explicitly compose:
example (p : Formula) : |- p.diamond.imp p.diamond := by
  modal_norm  -- unfolds diamond to primitive form
  modal_search
```

**Recommendation**: Implement Option B first (zero integration risk), then upgrade to Option A after validating that normalization does not break existing tests.

## 5. Interaction Analysis

### 5.1 Effect on modal_search's tryAxiomMatch

After `modal_norm`, the goal Expr will contain only primitive constructors. The `tryAxiomMatch` function (Tactics.lean:511) uses `mkAppM` with axiom constructor names. Since Lean's unifier handles definitional equality, `tryAxiomMatch` should work equally well on normalized and un-normalized forms. However, normalization makes the matching more PREDICTABLE:

- **Without normalization**: The Expr for `p.diamond.box.imp p.box` contains `@Formula.diamond p` which the unifier must unfold to match `Axiom.modal_5_collapse`.
- **With normalization**: The Expr is `(p.imp .bot).box.imp .bot).box.imp p.box`, and the unifier directly matches the expanded form of `modal_5_collapse`.

### 5.2 Effect on Aesop Rule Sets

The existing `@[aesop norm unfold]` rules in AesopRules.lean are DEPRECATED and not used by `tm_auto`. The new `modal_norm` tactic supersedes them completely. If Aesop is re-enabled in the future, the `@[modal_norm_unfold]` attribute (if the attribute-based approach is adopted) could be used to extend Aesop's normalization.

### 5.3 Effect on Deduction Theorem (Task 189)

The deduction theorem tactic (if implemented) will produce goals involving derived operators from the input formula. Running `modal_norm` before the deduction theorem would normalize the input, potentially simplifying the deduction theorem's pattern matching. Running it after would normalize the output for downstream consumption.

### 5.4 Effect on matchAxiom (ProofSearch.lean)

The computable `matchAxiom` function already pattern-matches on expanded forms. Normalization does not affect computable pattern matching because Lean auto-expands `def` abbreviations during compilation. However, if a `Formula.normalize` function is added (see Section 6.3), it could be called before `matchAxiom` to provide a belt-and-suspenders guarantee.

### 5.5 Term Size Blowup

Full normalization increases term size significantly for complex operators:

| Operator | Original Nodes | Normalized Nodes | Blowup Factor |
|----------|---------------|-----------------|----------------|
| `neg phi` | 2 + phi | 3 + phi | ~1.5x |
| `and phi psi` | 2 + phi + psi | 7 + phi + psi | ~1.7x |
| `diamond phi` | 2 + phi | 7 + phi | ~3.5x |
| `all_future phi` | 2 + phi | 9 + phi | ~4.5x |
| `always phi` | 2 + phi | 35+ + 3*phi | ~15x |
| `sometimes phi` | 2 + phi | 40+ + 3*phi | ~20x |

For `always` and `sometimes`, the blowup is severe. This is why selective normalization (`prop_norm`, `temporal_norm`, `modal_op_norm`) is important -- users should normalize only what is needed for the proof at hand.

## 6. Additional Design Considerations

### 6.1 whnf vs simp for Normalization

Since derived operators are `def` abbreviations, Lean's `whnf` (weak head normal form) will unfold them. However:

- `whnf` only unfolds the outermost application, not recursively.
- `simp` applies rewrite rules exhaustively until no more rules apply.
- For full normalization to primitives, `simp only [...]` is the right tool because we need recursive unfolding through the entire formula tree.
- For "unfold just the top-level operator", a `whnf`-based approach or `unfold` would suffice, but the macro approach with `simp only` handles both cases uniformly.

### 6.2 Bidirectional Normalization (Fold Direction)

A "fold" tactic that introduces derived operators from their primitive expansions would be useful for goal readability:

```lean
macro "modal_fold" : tactic =>
  `(tactic| simp only [
    <- sometimes_unfold, <- always_unfold,
    <- weak_future_unfold, <- weak_past_unfold,
    <- all_future_unfold, <- all_past_unfold,
    <- some_future_unfold, <- some_past_unfold,
    <- diamond_unfold, <- and_unfold, <- or_unfold,
    <- neg_unfold, <- top_unfold, <- next_unfold, <- prev_unfold])
```

**Caveat**: Folding is non-deterministic -- the same primitive pattern may correspond to multiple derived operators (e.g., `imp phi bot` could be `neg phi` or part of `and`). In practice, `simp` applies rules greedily left-to-right, so the fold order matters. List higher-level operators first to get the most "folded" result.

### 6.3 Computable Normalization Function

For use in the computable proof search (ProofSearch.lean), a `Formula.normalize` function that converts derived forms to primitive at the term level:

```lean
def Formula.toPrimitive : Formula -> Formula
  | atom a => atom a
  | bot => bot
  | imp phi psi => imp phi.toPrimitive psi.toPrimitive
  | box phi => box phi.toPrimitive
  | untl phi psi => untl phi.toPrimitive psi.toPrimitive
  | snce phi psi => snce phi.toPrimitive psi.toPrimitive
```

This is trivial because the derived operators are `def` abbreviations -- they are already expanded by the time this function sees them. The function just recursively visits the formula tree. However, this could be useful for a defensive normalization pass before `matchAxiom` to guarantee that no `whnf`-lazy expansions remain.

**Key insight**: Since all derived operators are `def`s, `toPrimitive` is actually the identity function on well-typed formulas. Lean's kernel automatically expands `def`s during type checking. The function is more useful as documentation and for `#eval` debugging.

### 6.4 File Placement

The normalization file should be placed at:
```
Theories/Bimodal/Automation/Normalization.lean
```

It imports only `Bimodal.Syntax.Formula` and `Lean` (for macro support). It should be imported by `Tactics.lean` (for integration with `modal_search`) and can be independently imported by any proof file that needs normalization.

## 7. Implementation Plan Recommendations

### Phase 1: Core Normalization (1-2 hours)
- Create `Automation/Normalization.lean`
- Define all 15 `_unfold` lemmas (all are `rfl`)
- Define `modal_norm`, `prop_norm`, `modal_op_norm`, `temporal_norm` macros
- Add basic tests

### Phase 2: Hypothesis Variants (30 minutes)
- Define `modal_norm_at` and `modal_norm_all` macros
- Add tests with hypothesis normalization

### Phase 3: Fold Direction (30 minutes)
- Define `modal_fold` and selective fold variants
- Add round-trip tests (norm then fold should approximate identity)

### Phase 4: Integration with modal_search (1-2 hours)
- Add `normalize : Bool := false` field to `SearchConfig`
- Add optional `modal_norm` call in `runModalSearch`
- Verify all existing tests pass
- Add new tests that require normalization

### Phase 5: Lakefile Integration and Verification (30 minutes)
- Add `Normalization.lean` to lakefile imports
- Run `lake build` to verify no regressions
- Update documentation

**Total estimated effort**: 4-6 hours (reduced from seed report's 12-hour estimate because the computable `Formula.normalize` function and canonical form theory are unnecessary given that derived operators are `def` abbreviations).

## 8. Key Findings Summary

1. **All 15 derived operators are `def` abbreviations**, making unfolding lemmas trivially `rfl`. No proof effort is needed for the lemmas themselves.

2. **The primary beneficiary is the meta-level tactic code** (Tactics.lean), where Lean Exprs preserve `def` application structure and do not auto-expand derived operators.

3. **350 existing call sites** across 26 files manually enumerate operator unfolding via `simp only [Formula.neg, ...]`. The `modal_norm` tactic provides a single canonical replacement.

4. **Selective normalization is essential** due to term size blowup: `always` expands by ~15x, `sometimes` by ~20x. Users should normalize only what is needed.

5. **The plain macro approach is recommended** over the `registerSimpAttr` approach for simplicity and zero-infrastructure requirements. Migration to the attribute-based approach can be done later if extensibility is needed.

6. **Integration with modal_search should be opt-in** (not default) to avoid breaking existing behavior. Users compose `modal_norm; modal_search` explicitly.

7. **Pattern matching at the computable level already works correctly** because Lean expands `def` abbreviations during pattern compilation. The normalization tactic is primarily needed at the meta (Expr) level.
