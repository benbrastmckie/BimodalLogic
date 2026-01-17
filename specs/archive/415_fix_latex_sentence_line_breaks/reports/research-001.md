# Research Report: Task #415

**Task**: Fix LaTeX sentence line breaks
**Date**: 2026-01-12
**Focus**: Identify and characterize sentence line break issues from task 405/406 refactor

## Summary

The task 406 refactor introduced incorrect sentence breaks where sentences were broken at clause boundaries (commas, relative clauses) rather than at sentence ends only. The convention requires each complete sentence on a single line; breaking mid-sentence is incorrect. The issue affects 2 files in Bimodal and potentially more in Logos.

## Findings

### The Problem Pattern

The documented convention in `.claude/rules/latex.md` states:

> **Long Sentence Breaks**: Break at natural clause boundaries (after comma, dependent clause, at conjunction)

However, this was misinterpreted. The **correct** interpretation is:
- Each **complete sentence** should be on one line
- **Only** break mid-sentence when a sentence is exceptionally long and would be unwieldy
- When breaking, break at clause boundaries (after commas, etc.)

The **incorrect** interpretation applied:
- Break at **every** clause boundary (comma, relative pronoun)
- Treat every comma as a break point

### Affected Files - Bimodal

**`Theories/Bimodal/latex/subfiles/00-Introduction.tex` (lines 9-13)**:

Current (incorrect):
```latex
The semantics is based on \emph{task frames},
which extend Kripke frames with temporal structure.
A task frame consists of world states connected by a \emph{task relation} indexed by temporal durations.
World histories are temporal slices through a task frame,
representing the unfolding of a world over time.
```

Issues:
- Line 9-10: "The semantics is based on \emph{task frames}, which extend..." is ONE sentence broken at a comma
- Line 12-13: "World histories are temporal slices..., representing..." is ONE sentence broken at a comma

Correct format:
```latex
The semantics is based on \emph{task frames}, which extend Kripke frames with temporal structure.
A task frame consists of world states connected by a \emph{task relation} indexed by temporal durations.
World histories are temporal slices through a task frame, representing the unfolding of a world over time.
```

### Affected Files - Logos

**`Theories/Logos/latex/subfiles/00-Introduction.tex` (lines 11-12)**:
```latex
Extending the expressive power of a language requires strategic extensions to the primitive semantic resources provided by the frame,
including precisely the resources needed and nothing more.
```
This is ONE sentence broken at a comma - should be one line.

**`Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex` (lines 11-12)**:
```latex
Evaluation is hyperintensional,
distinguishing propositions that agree on truth-value across all possible worlds but differ in their exact verification and falsification conditions.
```
This is ONE sentence broken at a comma - should be one line.

### Files Needing Review

A comprehensive scan is needed for any line ending with a comma followed by the next line starting with:
- lowercase letter
- "which", "that", "where", "when", "and", "or", "but"

Pattern to search:
```
grep -n ',$' *.tex | # lines ending with comma
```

Then manually check if these are complete sentences (rare) or broken sentences (needs fix).

### Correct vs Incorrect Breaks

**Correct (complete sentences each on own line)**:
```latex
Modal logic extends propositional logic with modal operators.
The necessity operator $\nec$ is interpreted over all accessible worlds.
The possibility operator $\pos$ is its dual.
```

**Correct (long sentence with acceptable mid-sentence break)**:
```latex
The canonical model construction proceeds by first extending the consistent set,
then defining accessibility via modal witnesses.
```
This break is acceptable because the sentence is very long, but it should only be used sparingly.

**Incorrect (normal-length sentence broken unnecessarily)**:
```latex
The semantics is based on \emph{task frames},
which extend Kripke frames with temporal structure.
```
This should be ONE line since it's not exceptionally long.

### Scope Assessment

Files to fix:
1. `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - 2 broken sentences (lines 9-10, 12-13)
2. `Theories/Logos/latex/subfiles/00-Introduction.tex` - 1 broken sentence (lines 11-12)
3. `Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex` - 1 broken sentence (lines 11-12)

Additional files may need review - should scan all .tex files for this pattern.

## Recommendations

1. **Fix the specific identified breaks**: Join lines where sentences were incorrectly broken mid-sentence

2. **Update documentation**: Clarify in `.claude/rules/latex.md` that:
   - Default: one complete sentence per line
   - Exception: Very long sentences (>120 chars) MAY break at clause boundaries
   - Never break short/medium sentences just because they have commas

3. **Create a verification pattern**: Add guidance on how to identify incorrect breaks:
   - Line ends with comma → check if next line completes the sentence
   - If next line starts with lowercase/relative pronoun, likely a broken sentence

## References

- `.claude/rules/latex.md` - Current LaTeX formatting rules
- `specs/405_document_latex_one_line_per_sentence_convention/reports/research-001.md` - Original convention research
- Brian Kernighan's semantic linefeeds rule (1974)

## Next Steps

1. Create implementation plan with:
   - Phase 1: Fix identified Bimodal file (00-Introduction.tex)
   - Phase 2: Fix identified Logos files (00-Introduction.tex, 01-ConstitutiveFoundation.tex)
   - Phase 3: Scan and fix any additional occurrences
   - Phase 4: Optionally update documentation to prevent recurrence
