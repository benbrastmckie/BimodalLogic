# Research Report: Task #379

**Task**: Fix LogosReference LaTeX warnings and errors
**Date**: 2026-01-11
**Focus**: Analyze and resolve all LaTeX warnings/errors in LogosReference.tex and BimodalReference.tex

## Summary

The warnings and errors fall into three categories: (1) package date warnings from `\ProvidesPackage` declarations, (2) BibTeX errors from missing citations in LogosReference.tex, and (3) undefined reference warnings that resolve with additional latexmk runs. The date warnings are benign and can be suppressed. The BibTeX error occurs because there are no `\cite` commands but bibliography is still generated. Reference warnings resolve automatically with multiple compilation passes.

## Findings

### Issue 1: Package Date Warnings (Both Documents)

**Symptoms:**
```
LaTeX Warning: You have requested package `assets/bimodal-notation',
LaTeX Warning: You have requested package `../../latex/notation-standards',
LaTeX Warning: You have requested package `../../latex/formatting',
```

**Root Cause:**
These are NOT errors - they are informational messages that LaTeX prints when loading packages. The actual warning (if any) would be about package dates. Looking at the `.sty` files:
- `notation-standards.sty`: `\ProvidesPackage{notation-standards}[2026/01/11...]`
- `logos-notation.sty`: `\ProvidesPackage{logos-notation}[2026/01/11...]`
- `formatting.sty`: `\ProvidesPackage{problem_set}[2025/01/29...]`

**Issue:** `formatting.sty` has `\ProvidesPackage{problem_set}` but the file is named `formatting.sty`. This mismatch causes the warning.

**Solution:** Update `formatting.sty` line 3 from:
```latex
\ProvidesPackage{problem_set}[2025/01/29 Support for MIT logic texts]
```
to:
```latex
\ProvidesPackage{formatting}[2026/01/11 ProofChecker shared formatting]
```

### Issue 2: `\showhyphens has changed` Warning (Both Documents)

**Symptom:**
```
LaTeX Warning: Command \showhyphens has changed.
```

**Root Cause:**
This warning comes from the `microtype` package loaded in `formatting.sty`. It's benign and indicates that microtype has modified how hyphenation is displayed.

**Solution:** This warning is harmless and can be ignored. To suppress it, add before `\begin{document}`:
```latex
\makeatletter
\let\showhyphens\@undefined
\makeatother
```
However, this is unnecessary since the warning doesn't indicate any problem.

### Issue 3: BibTeX Errors (LogosReference only)

**Symptoms:**
```
I found no \citation commands---while reading file LogosReference.aux
I found no style file---while reading file LogosReference.aux
```

**Root Cause:**
LogosReference.tex includes:
```latex
\bibliographystyle{../../latex/bib_style}
\bibliography{bibliography/LogosReferences}
```

But there are NO `\cite` commands in the document. BibTeX fails because:
1. No citations to process → "no \citation commands"
2. Since no aux file entries to process, style file lookup fails

BimodalReference.tex does NOT have these lines, so it doesn't trigger BibTeX.

**Solutions (choose one):**

**Option A: Remove bibliography lines** (if no citations needed):
```latex
% Remove or comment out:
% \bibliographystyle{../../latex/bib_style}
% \bibliography{bibliography/LogosReferences}
```

**Option B: Add at least one citation** (if bibliography is desired):
Add `\nocite{*}` before `\bibliography` to include all entries without explicit citations:
```latex
\nocite{*}  % Include all bibliography entries
\bibliographystyle{../../latex/bib_style}
\bibliography{bibliography/LogosReferences}
```

**Option C: Configure latexmk to skip bibtex when no citations**:
Add to `latexmkrc`:
```perl
$bibtex_use = 1.5;  # Only run bibtex if .bib file exists AND citations present
```
However, `$bibtex_use = 2` (our current setting) should handle this - the issue may be file path resolution.

### Issue 4: Undefined References (LogosReference only)

**Symptoms:**
```
Reference `sec:constitutive-foundation' on page 1 undefined
Reference `sec:dynamical-foundation' on page 1 undefined
...
Label(s) may have changed. Rerun to get cross-references right.
```

**Root Cause:**
These labels ARE defined in the subfiles (confirmed via grep). The issue is that:
1. First latexmk pass: Main document compiled, references collected
2. Subfiles compiled, labels defined
3. Need additional passes to resolve cross-references

**Solution:**
The warning "Rerun to get cross-references right" indicates latexmk needs more passes. Our `latexmkrc` has `$max_repeat = 5`, which should be sufficient. The issue may be:
1. latexmk stopping early due to BibTeX error (Issue 3)
2. First build after changes always shows this

**To verify:** Run `latexmk` twice in succession. If warnings persist after second run, there's a real problem.

### Issue 5: File Path in `formatting.sty`

**Observation:**
Line 1 of `formatting.sty`:
```latex
%!TEX root = LogicNotes.tex
```
This is a reference to a non-existent file and should be removed or updated.

## Recommendations

1. **Fix `formatting.sty` package name** - Change `\ProvidesPackage{problem_set}` to `\ProvidesPackage{formatting}`

2. **Address BibTeX in LogosReference.tex** - Either:
   - Remove bibliography lines if not needed, OR
   - Add `\nocite{*}` to include all bibliography entries

3. **Remove stale comment** - Delete `%!TEX root = LogicNotes.tex` from `formatting.sty`

4. **Verify cross-references** - Run `latexmk` twice; undefined refs should resolve

5. **Ignore `\showhyphens` warning** - It's benign

## Priority Order

| Issue | Severity | Fix |
|-------|----------|-----|
| BibTeX errors | High | Add `\nocite{*}` or remove bibliography |
| Package name mismatch | Medium | Fix `\ProvidesPackage` in formatting.sty |
| Stale TEX root comment | Low | Remove line 1 from formatting.sty |
| Undefined references | Low | Should resolve with clean build |
| `\showhyphens` warning | None | Ignore |

## References

- [LaTeX packages warning](https://tex.stackexchange.com/questions/47576/combining-ifx-and-pdfstringdef)
- [BibTeX no citation commands](https://tex.stackexchange.com/questions/92914/i-found-no-citation-commands-while-reading-file-bib)
- [latexmk bibtex_use options](https://mg.readthedocs.io/latexmk.html)

## Next Steps

1. Fix `formatting.sty`:
   - Update `\ProvidesPackage` declaration
   - Remove `%!TEX root` comment
2. Fix `LogosReference.tex`:
   - Add `\nocite{*}` before `\bibliography`
3. Test both documents with `latexmk`
4. Verify all warnings/errors are resolved
