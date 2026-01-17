# Research Report: Task #349

**Task**: Address all [FIX] tags in RECURSIVE_SEMANTICS.md documentation
**Date**: 2026-01-09
**Focus**: Systematic analysis of all [FIX] tags and required corrections

## Summary

The RECURSIVE_SEMANTICS.md document contains 25 [FIX] tags requiring corrections to notation, semantic clauses, constraints, and cross-references. This research identifies all fixes needed, provides Unicode symbols for notation changes, and extracts required content from the external LaTeX source (counterfactual_worlds.tex).

## Findings

### Category 1: Notation Standardization (I → | |)

**Lines affected**: 47, 54, 69, 211

The interpretation function should use semantic brackets `| |` instead of `I`:
- `I(f)` → `|f|`
- "Interpretation I assigns" → "Interpretation | | assigns"
- Causal Model should use `| |` for interpretation function

**Implementation**: Simple search-and-replace with attention to context.

### Category 2: Predicate Notation (v_F/f_F → |F|⁺/|F|⁻)

**Line affected**: 56

Current notation for predicate interpretation:
```
n-place predicates F → ordered pairs ⟨v_F, f_F⟩
  - v_F : Sⁿ → S is the verifier function
  - f_F : Sⁿ → S is the falsifier function
```

Required notation:
```
n-place predicates F → ordered pairs ⟨|F|⁺, |F|⁻⟩
  - |F|⁺ : set of functions Sⁿ → S (verifier functions)
  - |F|⁻ : set of functions Sⁿ → S (falsifier functions)
```

**Key change**: From single functions to **sets of functions** for verifiers and falsifiers.

### Category 3: Variable Assignment Notation (σ/greek → a/ā)

**Lines affected**: 63, 219, 283, 352

Replace Greek letters for variable assignments:
- σ → a (or ā using combining overline U+0305)
- Keep Greek letters (τ, α, β) for world-histories only

**Unicode options for bar-over-letter**:
- `ā` (U+0101) - precomposed Latin small letter a with macron
- `a̅` - letter a + U+0305 (COMBINING OVERLINE)
- `a̲` - underline variant if needed

**Recommendation**: Use `a̅` (a + combining overline) for visual distinction from world-history notation.

### Category 4: Turnstile Symbols

**Line affected**: 73, 227

Current symbols:
- `⊩⁺` for verification
- `⊩⁻` for falsification
- `⊨` for truth
- `⊭` for falsehood

**Unicode options for reversed turnstiles**:
- `⊣` (U+22A3) - LEFT TACK (reversed single turnstile)
- `⫤` (U+2AE4) - VERTICAL BAR DOUBLE LEFT TURNSTILE
- No perfect reversed `⊩` exists

**Recommendation**: Keep current notation (`⊩⁺`/`⊩⁻` and `⊨`/`⊭`) as the [FIX] notes allow this fallback. The superscript notation is clearer and more common in truthmaker semantics literature.

### Category 5: Include Model and Assignment in Clauses

**Lines affected**: 79-81, 92

All semantic clauses must include contextual parameters:
- Constitutive: `M, a̅, s ⊩⁺ A` (model, assignment, state)
- Causal: `M, τ, x, a̅ ⊨ A` (model, world-history, time, assignment)

Update all verification/falsification tables throughout both layers.

### Category 6: Lambda Abstraction Clauses

**Lines affected**: 26, 88, 240

Two additions required:

**Constitutive Layer** (line 88):
```
#### Lambda Abstraction (λ)

| | Condition |
|---|-----------|
| M, a̅, s ⊩⁺ (λx.A)(t) | iff M, a̅[⟦t⟧/x], s ⊩⁺ A |
| M, a̅, s ⊩⁻ (λx.A)(t) | iff M, a̅[⟦t⟧/x], s ⊩⁻ A |
```

**Causal Layer** (line 240):
```
| **λ-application** | M, τ, x, a̅ ⊨ (λx.A)(t) iff M, τ, x, a̅[⟦t⟧/x] ⊨ A |
```

**GLOSSARY.md update** (line 26): Add entry for lambda abstraction.

### Category 7: Task Relation Constraints

**Lines affected**: 174, 183, 187

**A. Remove Nullity as constraint, redefine possible states**:

Current:
```
| Nullity | s ⇒_0 s for all possible states s |
```

New approach:
- **Define** possible states: s ∈ P iff s ⇒_0 s
- Remove Nullity from constraint list

**B. Add Containment constraints** (from counterfactual_worlds.tex §sub:Containment):

```
| **Containment (L)** | If s ∈ P, d ⊑ s, and d ⇒_x r, then s ⇒_x t.r for some t ∈ S |
| **Containment (R)** | If t ∈ P, r ⊑ t, and d ⇒_x r, then s.d ⇒_x t for some s ∈ S |
```

**C. Add Maximality constraint** (from counterfactual_worlds.tex §sub:TaskSpace):

```
| **Maximality** | If s ∈ S and t ∈ P, there is a maximal t-compatible part r ∈ s_t |
```

### Category 8: State Modality Definitions

**Line affected**: 187

Update definitions table:
- **Possible state**: s ∈ P iff s ⇒_0 s (direct definition, not via connectivity)
- **Impossible state**: s ∉ P iff ¬(s ⇒_0 s)

### Category 9: Intensional vs Hyperintensional Clarification

**Line affected**: 157-160

Current text suggests intensional replaces hyperintensional. Correct to:

> The Causal Layer extends the Constitutive Layer with temporal structure and a task relation. While the foundation remains hyperintensional (distinguishing propositions by their exact verifiers/falsifiers), this layer adds intensional evaluation relative to world-histories and times to determine truth-values for all Causal Layer sentences.

### Category 10: Time Domain Restriction

**Line affected**: 221

Remove restriction `x ∈ dom(τ)`:

Current: "time x ∈ dom(τ)"
New: "time x ∈ D"

This allows evaluation at times outside the world-history's domain.

### Category 11: Atomic Truth Conditions Rewrite

**Lines affected**: 227, 234-238

Rewrite atomic sentence clauses to not depend on ⊩⁺/⊩⁻:

```
| M, τ, x, a̅ ⊨ F(t₁,...,tₙ) | iff there is some f ∈ |F|⁺ where f(⟦t₁⟧, ..., ⟦tₙ⟧) ⊑ τ(x) |
| M, τ, x, a̅ ⊭ F(t₁,...,tₙ) | iff there is some f ∈ |F|⁻ where f(⟦t₁⟧, ..., ⟦tₙ⟧) ⊑ τ(x) |
```

Add note about derivable equivalence: `⊨ A iff ¬(⊭ A)`.

### Category 12: Since/Until Operator Symbols

**Line affected**: 281

Change operator symbols:
- Until: `U` → `▷` (U+25B7 WHITE RIGHT-POINTING TRIANGLE)
- Since: `S` → `◁` (U+25C1 WHITE LEFT-POINTING TRIANGLE)

Update tables:
```
| **A ◁ B** (Since) | M, τ, x, a̅ ⊨ A ◁ B iff ... |
| **A ▷ B** (Until) | M, τ, x, a̅ ⊨ A ▷ B iff ... |
```

### Category 13: Imposition Notation

**Line affected**: 307

Change imposition symbol from `▷` to `→` to avoid conflict with Until:

Current: `t ▷_w w'`
New: `t →_w w'` or use different symbol like `⊳` (U+22B3)

**Recommendation**: Use `⊳` (WHITE RIGHT-POINTING TRIANGLE, mathematical) or subscripted arrow `→_t` for imposition.

### Category 14: Time Vector in Contextual Parameters

**Line affected**: 313

Add time vector v⃗ to all Causal Layer clauses:
- `M, τ, x, a̅, v⃗ ⊨ A`

Update Store/Recall section and propagate through all subsequent clauses.

## Unicode Symbol Reference

| Symbol | Unicode | Name | Use |
|--------|---------|------|-----|
| ā | U+0101 | Latin small letter a with macron | Variable assignment (precomposed) |
| a̅ | a+U+0305 | a + combining overline | Variable assignment (combining) |
| ⊩ | U+22A9 | FORCES | Verification relation |
| ⊨ | U+22A8 | TRUE/MODELS | Truth/satisfaction |
| ⊭ | U+22AD | NOT TRUE | Falsity/non-satisfaction |
| ⊣ | U+22A3 | LEFT TACK | Reversed turnstile |
| ▷ | U+25B7 | WHITE RIGHT-POINTING TRIANGLE | Until operator |
| ◁ | U+25C1 | WHITE LEFT-POINTING TRIANGLE | Since operator |
| ⊳ | U+22B3 | CONTAINS AS NORMAL SUBGROUP | Imposition (alternative) |
| ⇒ | U+21D2 | RIGHTWARDS DOUBLE ARROW | Task relation |
| ⊑ | U+2291 | SQUARE IMAGE OF OR EQUAL TO | Parthood |

## Recommendations

1. **Phase the implementation**: Start with notation changes (Categories 1-4), then semantic clauses (5-6), then constraints (7-8), then clarifications (9-14).

2. **Test rendering**: After each batch of changes, verify markdown renders correctly.

3. **Update GLOSSARY.md** simultaneously:
   - Add lambda abstraction entry
   - Add Since (◁) and Until (▷) operators with new symbols
   - Update interpretation function notation if mentioned

4. **Preserve [FIX] tags temporarily**: Consider commenting out rather than deleting during implementation to track progress.

5. **External source handling**: The Containment and Maximality constraints from counterfactual_worlds.tex should be adapted to markdown format with proper attribution.

## References

- counterfactual_worlds.tex §sub:Containment (lines 1435-1455)
- counterfactual_worlds.tex §sub:TaskSpace (lines 719-810)
- [Unicode Tacks and Turnstiles](http://xahlee.info/comp/unicode_tacks_turnstiles.html)
- [Combining Overline](https://symbl.cc/en/0305/)
- [Double Turnstile - Wikipedia](https://en.wikipedia.org/wiki/Double_turnstile)

## Next Steps

1. Create implementation plan with specific edits per section
2. Implement notation changes across both layers
3. Add lambda abstraction clauses
4. Add Containment and Maximality constraints
5. Update GLOSSARY.md
6. Final review and verification
