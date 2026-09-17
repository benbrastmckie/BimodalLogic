# LaTeX Edition (Frozen)

[Back to Development](README.md)

`latex/` holds a **frozen, superseded** LaTeX edition of the Bimodal Reference Manual
(`latex/BimodalReference.tex`, plus `BimodalDemo.tex`, chapter `subfiles/`, shared styles under
`assets/`, and the build config `latexmkrc`). It is not kept in sync with the Lean source or with
`typst/SYNC-MAP.md`'s pinning checks, and no new content should be added to it.

The maintained edition is `typst/BimodalReference.typ` (see
[typst/README.md](../../typst/README.md)); `README.md` links `latex/BimodalReference.pdf` only as
the superseded PDF. If the LaTeX PDF ever needs rebuilding:

```bash
cd latex
latexmk -pdf BimodalReference.tex   # or: latexmk -pvc BimodalReference.tex for continuous builds
```

`latexmkrc` configures XeLaTeX compilation and package paths; see [latex/README.md](../../latex/README.md)
for build-command and PDF-viewer detail. There is no per-theory `{Theory}/latex/` layout in this
repository — `latex/` is a single, self-contained directory for the one reference manual.

## Related Documentation

- [latex/README.md](../../latex/README.md) - Build instructions and latexmk usage
- [MODULE_ORGANIZATION.md](MODULE_ORGANIZATION.md) - Project directory structure

---

[Back to Development](README.md)
