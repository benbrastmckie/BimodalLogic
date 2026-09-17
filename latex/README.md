# LaTeX Documentation

> **Frozen edition**: this LaTeX source is a superseded reference edition and is not kept in
> sync with the Lean source. The maintained edition is [`typst/BimodalReference.typ`](../typst/README.md).

LaTeX source for the Bimodal TM Logic reference document.

## Contents

| File | Description |
|------|-------------|
| BimodalReference.tex | Main reference document |
| BimodalDemo.tex | Demo/tutorial document |
| BimodalReference.pdf | Compiled reference (generated) |
| BimodalDemo.pdf | Compiled demo (generated) |
| latexmkrc | LaTeX build configuration |

## Subdirectories

- `subfiles/` - Chapter source files
- `assets/` - Style files and notation packages
- `build/` - Build artifacts

## Building

```bash
cd latex
latexmk -pdf BimodalReference.tex
```

## Related Documentation

- [Parent README](../README.md)
- [Typst Documentation](../typst/README.md) - Maintained edition

---

*Last Updated: 2026-08-25*
