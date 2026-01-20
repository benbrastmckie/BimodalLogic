# Research Report: Task #622

**Task**: prove_applyRule_decreases_complexity
**Date**: 2026-01-19
**Focus**: Prove the `applyRule_decreases_complexity` lemma in Saturation.lean

## Summary

The `applyRule_decreases_complexity` lemma requires case analysis on all 16 tableau rules to show that applying each rule produces formulas with strictly smaller total complexity than the original formula. The proof pattern is straightforward: unfold `totalComplexity` and use `simp` with `Formula.complexity` and `SignedFormula.pos`/`SignedFormula.neg`, followed by `omega`. The existing complexity lemmas (`complexity_imp_sum`, `complexity_box`, `complexity_all_future`, `complexity_all_past`) provide the key inequalities needed.

## Findings

### Location and Current State

- **File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`
- **Lines**: 328-338
- **Current proof skeleton**: Uses `cases rule <;> simp only [applyRule] at h <;> try (cases sf.sign <;> simp at h hApplicable)` followed by `all_goals sorry`

### Theorem Signature

```lean
theorem applyRule_decreases_complexity (rule : TableauRule) (sf : SignedFormula) (result : RuleResult)
    (h : applyRule rule sf = result) (hApplicable : result ≠ .notApplicable) :
    match result with
    | .linear formulas => totalComplexity formulas < sf.formula.complexity
    | .branching branches => ∀ branch ∈ branches, totalComplexity branch < sf.formula.complexity
    | .notApplicable => True
```

### The 16 Tableau Rules

| Rule | Sign | Input Formula | Output | Type |
|------|------|---------------|--------|------|
| `andPos` | pos | `(A.imp (B.imp .bot)).imp .bot` | `[pos A, pos B]` | Linear |
| `andNeg` | neg | `(A.imp (B.imp .bot)).imp .bot` | `[[neg A], [neg B]]` | Branching |
| `orPos` | pos | `(A.imp .bot).imp B` | `[[pos A], [pos B]]` | Branching |
| `orNeg` | neg | `(A.imp .bot).imp B` | `[neg A, neg B]` | Linear |
| `impPos` | pos | `A.imp B` | `[[neg A], [pos B]]` | Branching |
| `impNeg` | neg | `A.imp B` | `[pos A, neg B]` | Linear |
| `negPos` | pos | `A.imp .bot` | `[neg A]` | Linear |
| `negNeg` | neg | `A.imp .bot` | `[pos A]` | Linear |
| `boxPos` | pos | `A.box` | `[pos A]` | Linear |
| `boxNeg` | neg | `A.box` | `[neg A]` | Linear |
| `diamondPos` | pos | `((A.imp .bot).box).imp .bot` | `[pos A]` | Linear |
| `diamondNeg` | neg | `((A.imp .bot).box).imp .bot` | `[neg A]` | Linear |
| `allFuturePos` | pos | `A.all_future` | `[pos A]` | Linear |
| `allFutureNeg` | neg | `A.all_future` | `[neg A]` | Linear |
| `allPastPos` | pos | `A.all_past` | `[pos A]` | Linear |
| `allPastNeg` | neg | `A.all_past` | `[neg A]` | Linear |

### Existing Complexity Lemmas (lines 234-255)

These lemmas are already proven and available:

```lean
theorem complexity_imp_left (φ ψ : Formula) : φ.complexity < (Formula.imp φ ψ).complexity
theorem complexity_imp_right (φ ψ : Formula) : ψ.complexity < (Formula.imp φ ψ).complexity
theorem complexity_imp_sum (φ ψ : Formula) : φ.complexity + ψ.complexity < (Formula.imp φ ψ).complexity
theorem complexity_box (φ : Formula) : φ.complexity < (Formula.box φ).complexity
theorem complexity_all_future (φ : Formula) : φ.complexity < (Formula.all_future φ).complexity
theorem complexity_all_past (φ : Formula) : φ.complexity < (Formula.all_past φ).complexity
```

### Complexity Calculations for Compound Patterns

The complex decomposition functions (`asAnd?`, `asOr?`, `asNeg?`, `asDiamond?`) match specific formula patterns:

| Pattern | Formula Structure | Complexity Formula |
|---------|-------------------|-------------------|
| And `A ∧ B` | `(A.imp (B.imp .bot)).imp .bot` | `5 + A.complexity + B.complexity` |
| Or `A ∨ B` | `(A.imp .bot).imp B` | `3 + A.complexity + B.complexity` |
| Neg `¬A` | `A.imp .bot` | `2 + A.complexity` |
| Diamond `◇A` | `((A.imp .bot).box).imp .bot` | `5 + A.complexity` |

### Verified Proof Patterns

The following proof patterns were verified to work:

**Linear rules producing one formula:**
```lean
example (φ : Formula) :
    totalComplexity [SignedFormula.pos φ] < (Formula.box φ).complexity := by
  unfold totalComplexity
  simp only [List.foldl, SignedFormula.pos, Formula.complexity]
  omega
```

**Linear rules producing two formulas:**
```lean
example (φ ψ : Formula) :
    totalComplexity [SignedFormula.pos φ, SignedFormula.neg ψ] < (φ.imp ψ).complexity := by
  unfold totalComplexity
  simp only [List.foldl]
  show 0 + φ.complexity + ψ.complexity < (φ.imp ψ).complexity
  have h := complexity_imp_sum φ ψ
  omega
```

**Branching rules:**
```lean
example (φ ψ : Formula) :
    totalComplexity [SignedFormula.neg φ] < ((φ.imp (ψ.imp .bot)).imp .bot).complexity := by
  unfold totalComplexity
  simp only [List.foldl, SignedFormula.neg, Formula.complexity]
  omega
```

### Key Implementation Insight

The minimum formula complexity is 1 (for atoms and bot), so all compound formulas have complexity >= 2. This ensures that the strict inequality `subformula.complexity < compound.complexity` always holds, since each constructor adds at least 1 to the complexity.

## Proof Strategy

The proof should proceed as follows:

1. **Case split on rule**: `cases rule`
2. **Case split on sign**: For rules that check sign, case split on `sf.sign`
3. **Handle pattern matching**: For rules using `asAnd?`, `asOr?`, `asNeg?`, `asDiamond?`, need to extract the matched subformulas
4. **Simplify**: `unfold totalComplexity` and `simp only [List.foldl, SignedFormula.pos, SignedFormula.neg, Formula.complexity]`
5. **Finish with arithmetic**: `omega`

### Handling Pattern Matching Cases

For rules like `andPos`, `andNeg`, `orPos`, `orNeg`, `negPos`, `negNeg`, `diamondPos`, `diamondNeg`, the proof needs to:
1. Extract the subformulas from the Option.some case
2. Use the resulting formulas to show the complexity decrease

The current proof skeleton already handles some of this with:
```lean
cases rule <;> simp only [applyRule] at h <;>
try (cases sf.sign <;> simp at h hApplicable)
```

### Special Cases for Branching Rules

For branching rules (andNeg, orPos, impPos), the goal becomes:
```lean
∀ branch ∈ branches, totalComplexity branch < sf.formula.complexity
```

This requires proving the inequality for each branch separately using `intro branch hmem` followed by membership analysis.

## Dependencies

- `Bimodal.Metalogic_v2.Decidability.BranchClosure` (already imported)
- Existing complexity lemmas in Saturation.lean (lines 234-255)

## Recommendations

1. **Start with simple cases**: Implement box, all_future, all_past rules first as they have the simplest structure
2. **Create helper lemmas**: Consider extracting proof terms for repeated patterns
3. **Use `decide` tactic**: For simple boolean checks on rule applicability
4. **Use `simp only` with explicit lemma list**: Avoid uncontrolled simplification

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Pattern matching complexity | Medium | Use `match` expressions explicitly when needed |
| Goal state explosion | Medium | Use `all_goals` with targeted tactics |
| Performance on 16 cases | Low | Each case is simple arithmetic; total proof should be fast |

## Estimated Effort

- **Simple cases (12 linear rules)**: 1-2 hours
- **Branching cases (3 rules + impPos)**: 1-2 hours
- **Testing and refinement**: 1 hour
- **Total**: 3-5 hours

## References

- Saturation.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`
- Tableau.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Decidability/Tableau.lean`
- SignedFormula.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Decidability/SignedFormula.lean`
- Formula.lean (complexity def): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean`

## Next Steps

Run `/plan 622` to create an implementation plan with detailed phases for each rule category.
