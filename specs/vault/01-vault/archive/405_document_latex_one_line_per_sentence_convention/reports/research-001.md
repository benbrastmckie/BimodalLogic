# Research Report: Task #405

**Task**: Document LaTeX one-line-per-sentence convention
**Date**: 2026-01-12
**Focus**: Identify where to document the convention and best practices

## Summary

The "one sentence per line" (also called "semantic linefeeds") convention is a well-established LaTeX best practice dating back to 1974.
The project already has LaTeX documentation in `.claude/context/project/latex/` but lacks this critical formatting rule.
Implementation requires updating the existing style guide and creating a new rules file.

## Findings

### Existing Documentation Structure

The project has comprehensive LaTeX context files:
- `.claude/context/project/latex/README.md` - Index of LaTeX resources
- `.claude/context/project/latex/standards/latex-style-guide.md` - Formatting rules (needs update)
- `.claude/context/project/latex/standards/document-structure.md` - Document organization
- `.claude/context/project/latex/standards/notation-conventions.md` - Mathematical symbols

No `.claude/rules/latex.md` exists (unlike `lean4.md` for Lean files).

### Current LaTeX File State

Both `BimodalReference.tex` and `LogosReference.tex` currently mix multiple sentences on single lines:

**BimodalReference.tex (lines 6-9)**:
```latex
Bimodal TM is a logic combining S5 metaphysical necessity ($\nec$) with linear
temporal operators for past ($\allpast$) and future ($\allfuture$). The logic
provides a framework for reasoning about necessary truths across time...
```

**LogosReference.tex (line 10)**:
```latex
A semantic frame provides the primitive structures used to interpret a formal language. Extending the expressive power of a language requires strategic extensions...
```

### Best Practices Research

The "semantic linefeeds" convention, documented by Brian Kernighan in 1974:

> "Start each sentence on a new line.
> Make lines short, and break lines at natural places, such as after commas and semicolons, rather than randomly."

**Key benefits**:
1. **Version control**: Diffs show only changed sentences, not entire paragraphs
2. **Editor efficiency**: Text editors manipulate lines easily; sentences become units
3. **Review clarity**: PR reviews can comment on specific sentences
4. **No output impact**: LaTeX ignores single line breaks in compilation

**Convention rules**:
1. Each sentence starts on a new line
2. A period/sentence-end is always followed by a line break
3. Long sentences may break at natural clause boundaries (after commas, semicolons)
4. No automatic line wrapping/reflow
5. Preserve protected spaces before citations: `Ref.~\cite{foo}`

### Documentation Locations

**Primary updates needed**:

1. **`.claude/context/project/latex/standards/latex-style-guide.md`**
   - Add "Source File Formatting" section
   - Document one-sentence-per-line rule
   - Add clause-break guidelines
   - Add examples (pass/fail)

2. **`.claude/rules/latex.md`** (new file)
   - Create rules file triggered by `**/*.tex` paths
   - Document formatting enforcement
   - Match pattern of `lean4.md`

3. **`.claude/context/project/latex/README.md`**
   - Reference the new formatting convention

## Recommendations

1. **Add to style guide**: Insert a "Source File Formatting" section in `latex-style-guide.md` with:
   - One sentence per line rule
   - Clause-break guidelines for long sentences
   - No automated line wrapping
   - Pass/fail examples

2. **Create rules file**: New `.claude/rules/latex.md` with:
   - Frontmatter: `paths: "**/*.tex"`
   - Formatting rules summary
   - Quick reference for enforcement

3. **Update subfiles first**: The main `.tex` files include subfiles, so enforcement should also apply to subfiles.

## References

- [Semantic Linefeeds (Brandon Rhodes, 2012)](https://rhodesmill.org/brandon/2012/one-sentence-per-line/)
- [LaTeX Best Practices (Patrick Emonts)](https://patrickemonts.com/post/latex_best_practice/)
- [Writing collaborative papers with LaTeX](https://www.dmsussman.org/resources/latexcollaboration/)
- Brian Kernighan, "UNIX for Beginners" (1974) - original source of the convention

## Next Steps

1. Create implementation plan with phases:
   - Phase 1: Update documentation files
   - Phase 2: (Task 406) Reformat BimodalReference.tex
   - Phase 3: (Task 407) Reformat LogosReference.tex
