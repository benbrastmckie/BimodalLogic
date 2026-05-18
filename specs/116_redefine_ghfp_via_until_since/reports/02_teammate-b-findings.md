# Teammate B Findings: Alternative Approaches

**Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
**Angle**: Alternative approaches and design decisions
**Date**: 2026-05-18

## Key Findings

### 1. `def` vs `abbrev` Decision: `def` is Correct but Needs Nuance

**Recommendation**: Use `def` (NOT `abbrev`) for `all_future`, `all_past`, `some_future`, `some_past`.

**Evidence**: The codebase has 321 pattern-match arms on `all_future`/`all_past` across non-Boneyard files. After the refactor, these constructors become `def`s, so no code can pattern-match on them. If `abbrev` were used, Lean would auto-unfold during unification, causing:
- `all_future phi` to unify with `(untl (phi.imp bot) (bot.imp bot)).imp bot` everywhere
- simp would see the expanded 5-constructor form instead of the abbreviation
- Term blowup in proof states and goals

With `def`, we get **controlled opacity**:
- `@[simp] lemma all_future_def` explicitly unfolds when needed
- Proof state displays `all_future phi` not the expansion
- `rfl`-based proofs for `needsPositiveHypotheses` etc. still work (since `all_future phi` has `imp` as its head, `needsPositiveHypotheses` returns `false`)

**Critical nuance**: After refactor, `needsPositiveHypotheses (all_future phi)` changes behavior:
- Currently: returns `true` (matches `| _ => true` wildcard, since `all_future` is a constructor)
- After refactor with `def`: `all_future phi` = `(untl (phi.neg) top).neg` = `imp (untl ...) bot`, so it matches `| imp _ _ => false` and returns `false`

This is a **semantic change** to the `needsPositiveHypotheses` function. The plan doesn't mention this correctly.

### 2. `top` Definition: Four Inconsistent Versions Exist

The codebase has FOUR separate local `top` definitions:

| Location | Definition | Scope |
|----------|-----------|-------|
| `LindenbaumQuotient.lean:330` | `def top_quot := toQuot (Formula.bot.imp Formula.bot)` | local |
| `ChronicleToCountermodel.lean:171` | `def top_formula := Formula.bot.imp Formula.bot` | local |
| `TemporalClosure.lean:588` | `abbrev Formula.top := .imp .bot .bot` | private-ish |
| `TemporalDerived.lean:61` | `private abbrev top := Formula.neg Formula.bot` | private |

All are semantically equivalent (`neg bot = bot.imp bot`), but the naming is inconsistent.

**Recommendation**: Add a **canonical** `def Formula.top : Formula := Formula.bot.imp Formula.bot` in `Formula.lean` alongside the other definitions (`neg`, `and`, `or`, `diamond`). Then replace all local definitions with the canonical one. This consolidation should happen as Phase 0 or part of Phase 1.

### 3. Incremental Migration ("Bridge") Strategy Assessment

**Feasibility**: LOW. The bridge approach (add `def`s alongside constructors, prove equivalence, migrate, then remove constructors) creates a naming conflict: you'd have `Formula.all_future` as both a constructor AND a `def`.

**Workaround**: Name the `def` versions differently during bridge (e.g., `def all_future'`), prove `all_future' phi = all_future phi`, migrate all uses, then swap names. But this doubles the work: you write migration code that is itself thrown away.

**Verdict**: Big-bang removal is the correct strategy for this refactor. The bridge approach adds complexity without reducing risk, because the real risk is in the 321 pattern-match sites that must be eliminated regardless.

### 4. CRITICAL: Separation Module Semantic Breakage (492 References)

The original research completely missed the `WeakCanonical/` subtree, which contains **492 references across 15 files**. The Separation module (`WeakCanonical/Separation/`) defines syntactic predicates that **fundamentally break** after the refactor:

**`is_U_free`**: Currently `| .all_future phi => is_U_free phi`. After refactor, `all_future phi` expands to `(untl (phi.neg) top).neg`, which matches `| .imp ... => ...` in `is_U_free`, then the inner `untl` returns `false`. So `is_U_free (all_future phi)` would **incorrectly return `false`** for any formula.

**`is_S_free`**: Same problem. `all_past phi` expands to contain `snce`, so `is_S_free (all_past phi)` returns `false` incorrectly.

**`is_future_only`**: `| .all_future phi => is_future_only phi` becomes unreachable after refactor.

**`is_past_only`**: Same problem.

**`is_syntactically_separated`**: `| .all_future phi => is_S_free phi` becomes unreachable.

**`has_single_U_type`**: `| .all_future psi => has_single_U_type psi A B` becomes unreachable.

**All of `int_truth`**: Currently has direct cases for `all_past`/`all_future`. After refactor, `int_truth M t (all_future phi)` would unfold through `imp` and `untl` cases, arriving at the correct result semantically but via a longer path. This is correct but requires adding simp lemmas to bridge.

**Impact**: The GHR94 hierarchy (Lemmas 10.2.5-10.2.8), separation theorem, temporal closure, and DedekindZ completeness all depend on these predicates. This is a **blocking issue** that requires dedicated handling — either:
- (A) Rewrite all syntactic predicates to recognize the expanded G/H pattern (complex regex-like matching)
- (B) Add `all_future`/`all_past` pattern recognition functions and call them from the predicates
- (C) Accept that these predicates now need simp-lemma bridges

**This is the highest-risk area of the entire refactor**, worse than SubformulaClosure.

### 5. ConservativeExtension/ExtFormula: Legacy Dead Code

**Critical finding**: `ExtFormula` is an **independent inductive type** with only 6 constructors: `atom | bot | imp | box | all_past | all_future`. It does NOT have `untl` or `snce`.

Furthermore, `ExtFormula` is **already broken/incompatible**:
- `embedAtom : String → ExtAtom` takes `String`, but `Formula.atom` takes `Atom` (a struct with `base : String` + `fresh_index : Option Nat`)
- `embedFormula` pattern-matches on only 6 of Formula's 8 constructors — missing `untl`/`snce`
- The module is NOT imported by the Metalogic barrel or Bimodal barrel — it's effectively dead code

**Recommendation for task 116**: Explicitly scope out ConservativeExtension. It needs a separate task to either:
1. Add `untl`/`snce` to ExtFormula and fix Atom handling
2. Archive to Boneyard if the conservative extension approach is superseded

### 6. FrameConditions: No Impact

The `FrameConditions/` directory has **zero references** to `all_future`/`all_past`. No action needed.

### 7. Test Suite Impact: 507 References Across 20 Files

The original research mentioned tests only in passing. The actual impact is **507 references across 20 test files**:

| Test Area | Files | Key Files |
|-----------|-------|-----------|
| Syntax | 3 | FormulaTest.lean, FormulaPropertyTest.lean, ContextTest.lean |
| ProofSystem | 4 | AxiomsTest.lean, DerivationTest.lean, DerivationBenchmark.lean, DerivationPropertyTest.lean |
| Semantics | 1 | SemanticBenchmark.lean |
| Automation | 4 | ProofSearchTest.lean, ProofSearchBenchmark.lean, EdgeCaseTest.lean, TacticsTest.lean |
| Theorems | 1 | PerpetuityTest.lean |
| Integration | 5 | Multiple integration test files |
| Property | 1 | Generators.lean |

These tests directly construct `Formula.all_future` and `Formula.all_past` values. After the refactor, these references become calls to the `def` versions, which should work transparently — but any test that pattern-matches on the result will break.

The `Property/Generators.lean` file likely generates random Formula values for property-based testing and may need updated generators that no longer produce `all_future`/`all_past` constructors.

### 8. Tableau Module: Already Pattern-Recognizes Expanded Forms

**Positive finding**: The Decidability/Tableau module already has functions that recognize the expanded def forms:

```lean
def asSomePast? : Formula → Option Formula
  | .imp (.all_past (.imp phi .bot)) .bot => some phi
  | _ => none

def asSomeFuture? : Formula → Option Formula
  | .imp (.all_future (.imp phi .bot)) .bot => some phi
  | _ => none
```

After the refactor, these need to be updated to recognize the new expansion pattern (which goes through `untl`/`snce` instead of `all_past`/`all_future`), but the **approach** of pattern-recognizing abbreviations already exists in the codebase. This could be generalized into a utility module.

### 9. Revised Reference Count

The original research reported ~1416 references across 70 files. The actual count:

| Category | References | Files |
|----------|-----------|-------|
| Theories (non-Boneyard) | 1891 | 83 |
| Tests | 507 | 20 |
| **Total** | **2398** | **103** |

The original research undercounted by **982 references** (41% undercount) due to missing the WeakCanonical subtree (492 refs, 15 files) and test suite (507 refs, 20 files).

## Recommended Approach

1. **Use `def` not `abbrev`** for all four abbreviations. Add `@[simp]` unfolding lemmas.

2. **Consolidate `top`** as a canonical `def Formula.top` in Formula.lean before the main refactor.

3. **Big-bang removal** is correct — no bridge approach.

4. **Add pattern-recognition utilities** for the abbreviation patterns:
   ```lean
   def Formula.asAllFuture? : Formula → Option Formula
     | .imp (.untl (.imp phi .bot) (.imp .bot .bot)) .bot => some phi
     | _ => none
   ```
   Use these in Separation predicates, Tableau rules, and proof search.

5. **WeakCanonical/Separation requires a dedicated phase** — the plan's current Phase 8 groups it with Decidability/Algebraic but the Separation module's 492 references and syntactic-predicate rewrite is its own major work item.

6. **ConservativeExtension should be scoped out** — it's broken independently of this task.

7. **Tests need a dedicated phase** — 507 references is a significant body of work.

8. **Revised effort estimate**: Original plan says 20 hours. With WeakCanonical (492 refs) and Tests (507 refs) properly accounted for, estimate should be **28-35 hours**.

## Evidence/Examples

### Pattern Match Elimination (321 Arms)
```lean
-- BEFORE (8 cases):
def complexity : Formula → Nat
  | atom _ => 1 | bot => 1 | imp φ ψ => 1 + ...
  | box φ => 1 + ... | all_past φ => 1 + ... | all_future φ => 1 + ...
  | untl φ ψ => 1 + ... | snce φ ψ => 1 + ...

-- AFTER (6 cases):
def complexity : Formula → Nat
  | atom _ => 1 | bot => 1 | imp φ ψ => 1 + ...
  | box φ => 1 + ... | untl φ ψ => 1 + ... | snce φ ψ => 1 + ...
-- Note: complexity(all_future phi) now auto-computed via imp/untl/bot cases
```

### Separation Breakage Example
```lean
-- is_U_free BEFORE: | .all_future φ => is_U_free φ  -- correct
-- is_U_free AFTER:  all_future phi = imp (untl ...) bot
--   matches: | .imp φ ψ => is_U_free φ && is_U_free ψ
--   inner:   | .untl _ _ => false                     -- WRONG!
```

## Confidence Level

- **`def` vs `abbrev` decision**: HIGH confidence
- **`top` consolidation**: HIGH confidence
- **WeakCanonical impact severity**: HIGH confidence (verified code, enumerated predicates)
- **ConservativeExtension dead code status**: HIGH confidence (verified type mismatches)
- **Reference counts**: HIGH confidence (grep-verified)
- **Effort estimate revision**: MEDIUM confidence (depends on proof difficulty)
