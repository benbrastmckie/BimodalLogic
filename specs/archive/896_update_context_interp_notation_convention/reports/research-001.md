# Research Report: Task #896

**Task**: 896 - update_context_interp_notation_convention
**Started**: 2026-02-17T12:00:00Z
**Completed**: 2026-02-17T12:30:00Z
**Effort**: Small
**Dependencies**: None
**Sources/Inputs**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` (line 585)
- `/home/benjamin/Projects/Logos/Theory/latex/assets/logos-notation.sty`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/standards/notation-conventions.md`
**Artifacts**:
- This report
**Standards**: report-format.md

## Executive Summary

- Found NOTE: tag at line 585 of 02-ConstitutiveFoundation.tex defining a notation convention for interpretation vs extension
- The convention distinguishes: `\ext{t}` for term **extension** (denotation) vs `\interp{\cdot}` for **semantic interpretation** of sentences
- Best placement is in `.claude/context/project/latex/standards/notation-conventions.md` under a new "Semantic Functions" section
- Current `\sem` macro should be renamed to `\ext` in documentation; a new `\interp` usage pattern should be documented

## Context & Scope

This task originated from a /learn scan that found a NOTE: tag in the Logos LaTeX project. The goal is to codify an important notation decision so that future work maintains consistency.

### Source NOTE: Tag (line 585)

```latex
% NOTE: \interp{\cdot}^\assignment_\model should be used instead of
% \sem{}^\assignment_\model which is what is used for the extension of
% terms. Also, rename \sem to \ext to indicate this is for the extension
% of a term
```

### Related FIX: Tag (line 583)

There is also a FIX: tag at line 583 that provides additional context about why this distinction matters:

```latex
% FIX: include $\equiv$ in the remark below, where
% \sem{\metaA \equiv \metaB} = \neg\bot if \sem{\metaA} = \sem{\metaB}
% and \bot otherwise. I also want to include \forall and \lambda and
% F(t_1, \ldots, t_n) so that a model and assignment provide an
% interpretation function which is a homomorphism from closed sentences
% to propositions. It is important to define \interp{\cdot}^\assignment_\model
% to do so in order to state the propositional operations for \lambda
% and \forall (this definition should be given prior to this remark)
```

## Findings

### Current Macro Definitions (logos-notation.sty)

| Macro | Definition | Current Usage | Notes |
|-------|------------|---------------|-------|
| `\sem{t}` | `\llbracket t \rrbracket` | Extension of terms | Line 210 - should become `\ext` |
| `\interp{f}` | `\|f\|` | Interpretation of non-logical symbols | Line 275 - exists but differently scoped |

### Semantic Distinction

The NOTE establishes two distinct semantic functions:

1. **Extension Function** (`\ext{t}` - proposed rename from `\sem`):
   - **Type**: `Term -> S` (terms to states)
   - **Notation**: `\ext{t}^\sigma_M` renders as `[[t]]^sigma_M`
   - **Purpose**: Maps terms to their denotations in the state space
   - **Example**: `\ext{v}^\sigma_M = sigma(v)` for variables

2. **Interpretation Function** (`\interp{\cdot}` - for sentences):
   - **Type**: `Sent -> P` (sentences to bilateral propositions)
   - **Notation**: `\interp{A}^\sigma_M` renders as `|A|^sigma_M`
   - **Purpose**: Maps sentences to bilateral propositions (constituting the homomorphism)
   - **Example**: `\interp{A \land B}^\sigma_M = \interp{A}^\sigma_M \land \interp{B}^\sigma_M`

### Why This Matters

The distinction is crucial for stating that evaluation induces a homomorphism from sentences to propositions:

```
Sentential operators        Propositional operations
      neg A          -->         neg |A|
      A land B       -->         |A| land |B|
      A lor B        -->         |A| lor |B|
```

Without separate notation:
- `\sem` for both terms and sentences creates ambiguity
- The homomorphism property cannot be clearly stated

### Current Context Documentation

The existing `.claude/context/project/latex/standards/notation-conventions.md` file:
- Documents most Logos notation
- Has a section "Core Extension Notation" that includes `\sem`
- Does NOT distinguish between term extension and sentence interpretation
- Should be updated to reflect the `\sem` -> `\ext` rename and add `\interp` for sentences

### Recommended Location

Add a new section to `.claude/context/project/latex/standards/notation-conventions.md`:

**Section Title**: "Semantic Functions: Extension vs Interpretation"

This should be placed after "Variable Assignment" (line 64-67) and before "Temporal Order" (line 69).

## Decisions

1. **Documentation location**: Update `.claude/context/project/latex/standards/notation-conventions.md`
2. **Rename in docs**: Document `\sem` -> `\ext` rename (actual .sty change is separate task)
3. **Add new usage**: Document `\interp{\cdot}^\sigma_M` for sentence interpretation
4. **Keep existing**: The `\interp{f}` for non-logical symbol interpretation remains unchanged

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Confusion with existing `\interp{f}` | Medium | Low | Clearly distinguish in documentation: `\interp{f}` for symbols, `\interp{\cdot}` for sentences |
| .sty not updated to match docs | Medium | Medium | Note that this task is docs-only; separate task needed for .sty |
| Existing uses of `\sem` in other files | High | Low | Document as "will be renamed"; don't break existing files |

## Implementation Recommendation

Add the following section to `notation-conventions.md` after line 67 (after "Variable Assignment" section):

```markdown
### Semantic Functions: Extension vs Interpretation

**Important**: The Logos system distinguishes between:
- **Term extension** (`\ext`): Maps terms to denotations in state space
- **Sentence interpretation** (`\interp`): Maps sentences to bilateral propositions

| Concept | Macro | Notation | Type | Usage |
|---------|-------|----------|------|-------|
| Term extension | `\ext{t}^\sigma_M` | [[t]]^sigma_M | Term -> S | Denotation of terms |
| Sentence interpretation | `\interp{A}^\sigma_M` | \|A\|^sigma_M | Sent -> P | Interpretation as bilateral proposition |

**Note**: The `\sem` macro is being renamed to `\ext` to clarify this distinction. The notation `\sem` will be deprecated in favor of `\ext` for term extension.

#### Why This Matters

The distinction enables stating that semantic evaluation is a homomorphism:
- `\interp{neg A}^\sigma_M = neg \interp{A}^\sigma_M`
- `\interp{A land B}^\sigma_M = \interp{A}^\sigma_M land \interp{B}^\sigma_M`

#### Current `\interp` Usage

Note that `\interp{f}` (for non-logical symbols) has a different scope:
- `\interp{f}` renders as `|f|` and gives the interpretation of predicates/functions
- `\interp{\cdot}^\sigma_M` gives the interpretation of closed sentences as propositions
```

## Appendix

### Search Queries Used

- `Glob: .claude/context/**/*.md` - Found context file structure
- `Grep: logos|Logos` - Found Logos-related context (30 files)
- `Grep: \\sem|\\interp|\\ext` in Logos/Theory/latex - Found current usage patterns

### References

- Source NOTE: `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` line 585
- Macro definitions: `/home/benjamin/Projects/Logos/Theory/latex/assets/logos-notation.sty` lines 210, 275
- Target context file: `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/standards/notation-conventions.md`
