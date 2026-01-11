# LaTeX Context README

## Purpose

LaTeX-specific context for Logos documentation. Use these files for document structure, mathematical notation, theorem environments, and compilation processes.

## Canonical Sources

- **Logic notation**: `project/logic/standards/notation-standards.md`
- **Logos notation**: `Logos/LaTeX/assets/logos-notation.sty`
- **Semantic specification**: `Documentation/Research/RECURSIVE_SEMANTICS.md`

## LaTeX-Specific Files

### Standards
- `standards/latex-style-guide.md` - Document class, packages, formatting rules
- `standards/notation-conventions.md` - Mathematical symbols and logos-notation.sty usage
- `standards/document-structure.md` - Main document and subfile organization

### Patterns
- `patterns/theorem-environments.md` - Definition, theorem, proof, remark usage
- `patterns/cross-references.md` - Labels, refs, and Lean cross-references

### Templates
- `templates/subfile-template.md` - Boilerplate for new subfiles

### Tools
- `tools/compilation-guide.md` - Build process and troubleshooting

## When to Load

Load these files when:
1. Creating new LaTeX documentation
2. Adding mathematical content to existing documents
3. Setting up new subfiles
4. Troubleshooting compilation issues

## Related Context

- `project/logic/standards/notation-standards.md` - General logical notation
- `project/lean4/` - Lean 4 development context (for cross-references)
