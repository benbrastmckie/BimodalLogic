# LaTeX Documentation

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
cd Theories/Bimodal/latex
latexmk -pdf BimodalReference.tex
```

## Related Documentation

- [Parent README](../README.md)
- [Typst Documentation](../typst/README.md) - Alternative Typst version

---

*Last Updated: 2026-03-16*
