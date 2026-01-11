# Research Report: Task #382

**Task**: Create Spatial/ subtheory stub
**Date**: 2026-01-11
**Focus**: Determine structure and content for Spatial extension stub following existing patterns

## Summary

The Spatial subtheory stub should follow the simple stub pattern used by Epistemic and Normative extensions, not the full implementation pattern of Foundation and Explanatory. The stub should document planned spatial operators (Here, Somewhere, Everywhere, Near) and frame extension requirements (location space, spatial relations) while deferring implementation.

## Findings

### Existing SubTheory Patterns

There are two distinct patterns in the SubTheories directory:

**1. Full Implementation Pattern** (Foundation, Explanatory):
- Module root file imports submodules
- Multiple implementation files: Frame.lean, Syntax.lean, Semantics.lean/Truth.lean
- Complete namespace and code structure
- Used for: Foundation (6 files), Explanatory (3 files)

**2. Simple Stub Pattern** (Epistemic, Normative):
- Single file in subdirectory (e.g., `Epistemic/Epistemic.lean`)
- Module root file with same content as subdirectory file
- Documentation header with:
  - Layer number and extension name
  - List of planned operators
  - Status marker: "Planned for future development"
  - Prerequisites and dependencies
  - Reference to layer-extensions.md section
- Minimal namespace with placeholder comments for extension points

### Spatial Extension Specification

From recursive-semantics.md and layer-extensions.md:

**Frame Extension**:
- Location space L = set of spatial locations
- Spatial relations: adjacency, containment, distance
- Open question: Should locations be mereological (with parts) or set-theoretic?

**Operators** (from documentation):
| Operator | Reading |
|----------|---------|
| Here(A) | A holds at the current location |
| Somewhere(A) | A holds at some location |
| Everywhere(A) | A holds at all locations |
| Near(A) | A holds at an adjacent location |

**Prerequisites**: Explanatory Extension (Core) completion
**Status**: Not started (documentation says "[DETAILS] pending specification")

### Directory Structure Requirements

Following the Epistemic/Normative pattern, Spatial needs:
```
SubTheories/
├── Spatial/
│   └── Spatial.lean      # Stub implementation file
└── Spatial.lean          # Module root (same content)
```

### Namespace Convention

Following established pattern:
- `Logos.SubTheories.Spatial`

### Import Convention

The stub should not import Foundation or Explanatory since no implementation exists yet. Compare:
- Epistemic.lean: No imports (pure stub)
- Normative.lean: No imports (pure stub)
- Explanatory.lean: Imports its submodules (has implementation)
- Foundation.lean: Imports its submodules (has implementation)

## Recommendations

1. **Use simple stub pattern**: Create minimal files matching Epistemic/Normative structure
2. **Include all documented operators**: List Here, Somewhere, Everywhere, Near in documentation
3. **Document open questions**: Preserve the question about mereological vs set-theoretic locations
4. **Add extension points**: Include placeholder comments for Formula type and LocationSpace
5. **Cross-reference documentation**: Reference layer-extensions.md Section 5 and recursive-semantics.md

## References

- `Theories/Logos/SubTheories/Epistemic.lean` - Pattern for simple stub
- `Theories/Logos/SubTheories/Normative.lean` - Pattern for simple stub
- `Theories/Logos/docs/Research/recursive-semantics.md` (lines 531-557) - Spatial specification
- `Theories/Logos/docs/Research/layer-extensions.md` (line 11, 322) - Extension listing
- `Theories/Logos/LaTeX/subfiles/07-Spatial.tex` - LaTeX documentation

## Next Steps

1. Create `SubTheories/Spatial/` directory
2. Create `SubTheories/Spatial/Spatial.lean` with stub content
3. Create `SubTheories/Spatial.lean` module root (duplicate of above)
4. Verify `lake build Logos` still succeeds
