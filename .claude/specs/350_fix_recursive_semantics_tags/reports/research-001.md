# Research Report: Task #350

**Task**: Address all FIX tags in RECURSIVE_SEMANTICS.md systematically
**Date**: 2026-01-10
**Focus**: Analysis of FIX tags, external references, and cross-document consistency

## Summary

The RECURSIVE_SEMANTICS.md document contains 18 FIX tags requiring systematic revision. The changes involve renaming "Layer" to "Extension", restructuring the dependency hierarchy, adding new semantic content, removing formatting inconsistencies, and updating related documents for consistency. External references to IdentityAboutness.tex and counterfactual_worlds.tex provide key definitions for bilattice structures and world-history equivalence.

## Findings

### 1. Terminology and Structural Changes

**FIX tags requiring terminology updates:**

| Line | Change Required |
|------|-----------------|
| 14 | Rename "Layer" → "Extension" throughout; rename "Constitutive Layer" → "Constitutive Foundation"; rename "Causal Layer" → "Core Extension" |
| 14 | Restructure hierarchy: Epistemic/Normative/Spatial Extensions are modular plugins for Agential Extension |
| 16 | Remove alliteration "Logos layered logic system" |
| 22 | Add new "Spatial Extension" and dependency diagram |

**New Dependency Structure:**
```
Constitutive Foundation (base)
        ↓
   Core Extension (required)
        ↓
   ┌────┴────┬────────────┐
   ↓         ↓            ↓
Epistemic  Normative   Spatial    (modular, at least one required)
Extension  Extension   Extension
   └─────────┴────────────┘
              ↓
      Agential Extension
```

### 2. Semantic Content Additions

**FIX tags requiring new content:**

| Line | Content to Add |
|------|----------------|
| 18 | Explain frame/language correspondence principle: frames provide semantic primitives to interpret language; extending expressive power requires strategic frame extensions in step with language |
| 58 | Note constitutive frame is non-modal (no possibility/compatibility definable) |
| 75 | Add containment constraint: for any f in v_F or f_F, states a_1,...,a_n are parts of f(a_1,...,a_n) but f(a_1,...,a_n) may have additional parts |
| 84 | Explain 1-place predicate intuition: v_F and f_F include functions taking an object (state) and returning that object with a verifying/falsifying property instance |
| 153 | Define essence and ground via identity: A ⊑ B := A ∧ B ≡ B (essence); A ≤ B := A ∨ B ≡ B (ground); note negation distribution |
| 182 | Clarify identity sentences and evaluation overlap between Constitutive and Core Extensions |
| 190 | Add Syntactic Primitives subsection for Core Extension |
| 272 | Add universal quantifier semantics and actuality predicate 'Act' |

### 3. Notation Changes

**FIX tags requiring notation updates:**

| Line | Change |
|------|--------|
| 88 | Variable assignment: "a̅" → "v_1", "v_2", etc. (compatible with LaTeX, markdown, Lean) |
| 251 | Rename "time vector" → "temporal index" |
| 335 | Use '→' instead of '⊳' for imposition notation |

### 4. Formatting Cleanup

**FIX tags for formatting consistency:**

| Lines | Change |
|-------|--------|
| 215, 239, 262, 335 | Remove all "**Note**:" labels |

### 5. External References

**From IdentityAboutness.tex (lines 749-778):**

The bilattice structure is defined as:
- **Bilattice**: A structure B = ⟨P, ⊑, ≤, ¬⟩ where ⟨P, ≤⟩ and ⟨P, ⊑⟩ are complete lattices with at least two elements, and ¬ is a unary operator satisfying:
  1. ¬¬X = X
  2. X ≤ Y = ¬X ⊑ ¬Y
  3. X ⊑ Y = ¬X ≤ ¬Y

- **Content Fusion**: J ⊓ K = {x.y : x ∈ J, y ∈ K}
- **Conjunction**: X ∧ Y = ⟨X⁺ ⊓ Y⁺, X⁻ ∪ Y⁻ ∪ (X⁻ ⊓ Y⁻)⟩
- **Disjunction**: X ∨ Y = ⟨X⁺ ∪ Y⁺ ∪ (X⁺ ⊓ Y⁺), X⁻ ⊓ Y⁻⟩

The space of bilateral propositions forms a non-interlaced bilattice where negation swaps the two orderings.

**From counterfactual_worlds.tex (lines 1750-1842):**

The equivalent definition for world-histories is:
- **Maximal Possible Evolutions** M_Z = **World-Histories** H_Z (Theorem at line 1822)

Key constraint definitions:
- **Parthood**: If d ⊑ s and s → t, then d → r for some r ⊑ t
- **Nullity**: □ = t iff □ → t or t → □
- **Containment**: If s → s, d ⊑ s, and d → r, then s → t.r for some t ∈ S
- **Maximality**: If s ∈ S and t ∈ P, there is some maximal t-compatible part r ∈ s_t

### 6. Definition Reordering

**FIX tag at line 204:**

The definitions of possible states P and maximal t-compatible parts must be moved BEFORE the Containment and Maximality constraints that reference them. Current order places definitions at lines 220-230, but they're needed at lines 204-214.

### 7. Related Documents Requiring Updates

**Documents to update for consistency (per line 3):**

| Document | Updates Needed |
|----------|----------------|
| LAYER_EXTENSIONS.md | Rename layers to extensions; update dependency diagram; add Spatial Extension; fix "compatibility" reference at line 33 |
| METHODOLOGY.md | Update layer terminology to extension terminology |
| GLOSSARY.md | Update all "Layer" → "Extension" terminology; change "Variable Assignment" notation from "a̅" to "v" notation; add Spatial Extension terms |

**Specific GLOSSARY.md updates:**
- Line 11-18: Update layer names
- Line 128: Change "Variable Assignment" from "a̅" to "v_1, v_2, ..."
- Line 89: Remove or update '⊳' for imposition

### 8. Identity Sentences Clarification

**From IdentityAboutness.tex (line 473):**

Identity sentences are formed from extensional sentences:
- Extensional sentences: A ::= p | ¬A | A ∧ A | A ∨ A
- Identity sentences: A ≡ B for any A, B ∈ extensional sentences

The Constitutive Foundation evaluates identity sentences only. Non-identity sentences require the Core Extension for evaluation against world-histories and times.

## Recommendations

1. **Phase the implementation** into logical groups:
   - Phase 1: Terminology changes (Layer → Extension, alliteration removal)
   - Phase 2: Notation changes (variable assignment, time vector, imposition)
   - Phase 3: Content additions (frame/language, containment, essence/ground, etc.)
   - Phase 4: Structural changes (definition reordering, Syntactic Primitives subsection)
   - Phase 5: New extension (Spatial Extension with diagram)
   - Phase 6: Cross-document consistency updates

2. **Create dependency diagram** using ASCII or Mermaid syntax showing:
   - Constitutive Foundation as base
   - Core Extension as required intermediate
   - Epistemic/Normative/Spatial as modular plugins
   - Agential Extension requiring at least one middle extension

3. **Preserve existing content** where possible, adding clarifications rather than rewriting working sections

4. **Verify mathematical consistency** when adding bilattice and essence/ground definitions

## References

- `/home/benjamin/Projects/Philosophy/Papers/IdentityAboutness/IdentityAboutness.tex` - Bilattice structure (lines 749-778), identity sentences (line 473)
- `/home/benjamin/Projects/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` - World-history equivalence (lines 1822-1842), constraint definitions (lines 1753-1766)
- `docs/Research/LAYER_EXTENSIONS.md` - Current layer architecture
- `docs/UserGuide/METHODOLOGY.md` - Current methodology documentation
- `docs/Reference/GLOSSARY.md` - Current glossary

## Next Steps

1. Create implementation plan with 6 phases as recommended
2. Begin with terminology changes as they affect the most content
3. Test notation changes for LaTeX/markdown/Lean compatibility
4. Draft Spatial Extension section before integrating
5. Update all three related documents after main document is complete
