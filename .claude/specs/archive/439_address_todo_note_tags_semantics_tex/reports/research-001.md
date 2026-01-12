# Research Report: Task #439

**Task**: Address TODO and NOTE tags in 02-Semantics.tex
**Date**: 2026-01-12
**Focus**: Consistency with possible_worlds.tex and improved LaTeX formatting

## Summary

The 02-Semantics.tex file contains 23 TODO/NOTE tags requiring attention. The TODOs primarily concern:
1. Notation consistency with the source paper (possible_worlds.tex)
2. Definition order and completeness
3. Semantic clause accuracy (especially for modal and temporal operators)
4. Better explanatory text bridging Lean code and paper content

## Findings

### 1. Critical Notation Changes Required

**Task Relation Notation** (Lines 10-12):
- Current: `R(w, x, u)`
- Paper uses: `w ⇒_x u` (line 862 of possible_worlds.tex)
- Recommendation: Define `\Rightarrow_x` macro in bimodal-notation.sty

**Temporal Type Symbol** (Line 12):
- Current: `T` for temporal type
- Paper uses: `D` with `\D = ⟨D, +, ≤⟩` as "temporal order" (line 853)
- Note: This conflicts since `T` is used as type parameter in Lean. Keep `T` but clarify it represents durations.

**World History Variables** (Line 62):
- Current: `h` (history)
- Paper uses: `τ` and `σ` consistently
- Recommendation: Use `\tau` and `\sigma` throughout

FIX: use `I` for the interpretation function instead of `V`

**Interpretation Function** (Lines 112-116):
- Current: `V` for "valuation"
- Paper uses: `|·|` notation with `|p_i| ⊆ W` (line 889)
- Can keep `V` but rename to "interpretation function" as requested

### 2. Definition Order Issues

The current order is problematic:
1. Task Frame ✓
2. World History (references convexity before defining it)
3. Convex Domain (should come BEFORE World History)
4. Respects Task (should come BEFORE World History)

**Paper order (app:TaskSemantics, lines 1831-1866)**:
1. Language definition
2. Frame definition (including task relation)
3. World history definition (with convexity inline)
4. Model definition
5. Truth conditions

### 3. Semantic Clause Errors

**CRITICAL: Box (Necessity) Clause is WRONG** (Lines 145-147):
```latex
% Current (INCORRECT):
\truthat{\model}{\history}{t}{\nec\varphi} &\iff
  \forall \history'.\, \text{states}'(t) = \text{states}(t) \to
    \truthat{\model}{\history'}{t}{\varphi}
```

**Paper definition (line 1868)**:
```latex
% Correct:
\M,\tau,x \vDash \Box \varphi \textit{iff}
  \M,\sigma,x \vDash \varphi \text{ for all } \sigma \in H_{\F}
```

The current clause restricts to histories with the same state at time t (that's the stability operator `⊡`!). The correct box quantifies over ALL histories at the evaluation time.

**CRITICAL: Tense Operators are WRONG** (Lines 148-151):
```latex
% Current (INCORRECT - only quantifies within domain):
\truthat{\model}{\history}{t}{\allpast\varphi} &\iff
  \forall s \le t.\, s \in \domain \to \truthat{\model}{\history}{s}{\varphi}
```

**Paper definition (lines 1869-1870)**:
```latex
% Correct:
\M,\tau,x \vDash \Past \varphi \textit{iff}
  \M,\tau,y \vDash \varphi \text{ for all } y\in D \text{ where } y < x
```

The paper quantifies over ALL times y < x in D (the full temporal order), not just times in the history's domain. This is a significant semantic difference!

**Note**: The Lean implementation at Truth.lean:101-102 restricts to domain:
```lean
| Formula.all_past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ
```
This may be intentional design choice - needs verification with user.

### 4. Styling and Formatting Issues

**Biconditional Symbol** (Line 132):
- Current: Uses `\iff` (standard LaTeX)
- Paper uses: `~\textit{iff}~` for metalanguage biconditionals
- Add to notation-standards.sty: `\newcommand{\Iff}{~\textit{iff}~}`

**Object vs Metalanguage** (Line 134):
- Current: Uses `\to` and `\rightarrow` in metalanguage
- Paper: Reserves these for object language
- Metalanguage should use plain English connectives

**Satisfaction Symbol**:
- Current: `\satisfies` = `\models` = `⊨`
- Paper: Uses `\vDash` (same)
- Current `\valid` using single turnstile is incorrect; should be removed

### 5. Table Formatting

Tables at lines 44-54 and 97-108:
- Drop "Description" column as TODO suggests
- Ensure all items are defined before table appears
- Remove "(see below)" and "(see code)" placeholders

### 6. Missing Content

**Sentence Letters** (Lines 116-117):
- TODO requests explaining that strings represent sentence letters
- Should distinguish propositions (instantaneous ways for system) vs world states (unique configurations)

**Time-Shift Definition** (Lines 167-179):
- Current definition is informal and unclear
- Paper provides formal definition at line 1877 (def:time-shift-histories):
```
τ ≈_y^x σ iff there exists order automorphism ā: D → D where y = ā(x),
dom(σ) = ā⁻¹(dom(τ)), and σ(z) = τ(ā(z)) for all z ∈ dom(σ)
```

### 7. Theorems to Review/Remove

**Valid iff Empty Consequence** (Lines 226-228):
- TODO suggests removal if not in Lean code
- Check Bimodal/Semantics/Validity.lean for this theorem
- If absent, remove from LaTeX

### 8. snake_case Commands (Line 165)

TODO suggests defining commands for Lean identifiers. Add to bimodal-notation.sty:
```latex
\newcommand{\taskrel}{\texttt{task\_rel}}
\newcommand{\timeshift}{\texttt{time\_shift}}
\newcommand{\respectstask}{\texttt{respects\_task}}
```

## Recommendations

### Phase 1: Critical Semantic Corrections
1. Fix box (necessity) clause to quantify over ALL histories
2. Clarify tense operators re: domain restriction (verify with user)
3. Add intended readings for semantic primitives

### Phase 2: Notation Updates
1. Add `\Rightarrow_x` task relation notation to bimodal-notation.sty
2. Add `\Iff` metalanguage biconditional
3. Use `\tau`, `\sigma` for world histories
4. Define snake_case Lean identifier commands

### Phase 3: Definition Restructuring
1. Move Convex Domain before World History
2. Move Respects Task before World History
3. Ensure all table items defined before tables

### Phase 4: Content Enrichment
1. Add intuitive explanations from paper (line 860-861 for task relation reading)
2. Improve Time-Shift definition to match paper's formal version
3. Add glosses for semantic clauses (from paper line 890+)

### Phase 5: Cleanup
1. Remove "(see below)" placeholders
2. Remove Description column from tables where appropriate
3. Verify and potentially remove "Valid iff Empty Consequence" theorem
4. Shorten theorem names as requested

## Key Files Referenced

| File | Purpose |
|------|---------|
| possible_worlds.tex lines 850-950 | Main semantics definitions |
| possible_worlds.tex lines 1831-2010 | Appendix formal definitions |
| Bimodal/Semantics/Truth.lean | Lean truth evaluation |
| Bimodal/Semantics/TaskFrame.lean | Lean frame definition |
| bimodal-notation.sty | LaTeX notation macros |

## Next Steps

1. Clarify with user: Should tense operators quantify over full D or just domain?
2. Create implementation plan addressing phases above
3. Update bimodal-notation.sty first (prerequisite for other changes)
4. Revise 02-Semantics.tex systematically

## Effort Estimate

- Phase 1 (Critical): 1-2 hours
- Phase 2 (Notation): 1 hour
- Phase 3 (Restructure): 1 hour
- Phase 4 (Content): 2-3 hours
- Phase 5 (Cleanup): 0.5-1 hour

**Total**: 5.5-8 hours
