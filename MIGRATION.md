# Migration Guide: ProofChecker → Logos

**Date**: 2025-12-04
**Version**: 0.1.0 → 0.2.0

This guide documents the project rename from ProofChecker to Logos and the reorganization into a layered architecture.

## Summary of Changes

### 1. Project Rename
- **Old**: ProofChecker
- **New**: Logos

### 2. Layer Architecture
- **Old Structure**: Flat namespace (`ProofChecker.Syntax`, `ProofChecker.Semantics`, etc.)
- **New Structure**: Layered namespace (`Logos.Core.Syntax`, `Logos.Core.Semantics`, etc.)

### 3. Directory Reorganization
- Core modules moved to `Logos/Core/` subdirectory
- Test modules moved to `LogosTest/Core/` subdirectory
- Layer extension stubs created: `Logos.Explanatory`, `Logos.Epistemic`, `Logos.Normative`

## Migration Steps

### For Users

If you were using ProofChecker in your projects, update your imports:

**Old imports**:
```lean
import ProofChecker
import ProofChecker.Syntax.Formula
import ProofChecker.Semantics.TaskFrame
```

**New imports**:
```lean
import Logos
import Logos.Core.Syntax.Formula
import Logos.Core.Semantics.TaskFrame
```

### For Contributors

1. **Update local repository**:
   ```bash
   git fetch origin
   git checkout main
   git pull origin main
   ```

2. **Update namespace references** in your code:
   - Replace `ProofChecker` → `Logos.Core` in namespace declarations
   - Replace `ProofChecker` → `Logos.Core` in import statements
   - Replace `ProofCheckerTest` → `LogosTest.Core` in test files

3. **Update documentation** references:
   - All documentation now refers to "Logos" instead of "ProofChecker"
   - File paths updated to reflect `Logos/Core/` structure

## Namespace Mapping

| Old Namespace | New Namespace |
|---------------|---------------|
| `ProofChecker.Syntax` | `Logos.Core.Syntax` |
| `ProofChecker.ProofSystem` | `Logos.Core.ProofSystem` |
| `ProofChecker.Semantics` | `Logos.Core.Semantics` |
| `ProofChecker.Metalogic` | `Logos.Core.Metalogic` |
| `ProofChecker.Theorems` | `Logos.Core.Theorems` |
| `ProofChecker.Automation` | `Logos.Core.Automation` |
| `ProofCheckerTest.*` | `LogosTest.Core.*` |

## Directory Structure

### Old Structure
```
ProofChecker/
├── ProofChecker.lean
├── ProofChecker/
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Metalogic/
│   ├── Theorems/
│   └── Automation/
└── ProofCheckerTest/
    └── (test directories)
```

### New Structure
```
Logos/
├── Logos.lean
├── Core/
│   ├── Core.lean
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Metalogic/
│   ├── Theorems/
│   └── Automation/
├── Explanatory/      # Layer 1 (future)
├── Epistemic/        # Layer 2 (future)
└── Normative/        # Layer 3 (future)
LogosTest/
└── Core/
    └── (test directories)
```

## Breaking Changes

### 1. Import Paths
All import paths now include `.Core` layer:
- **Breaking**: `import ProofChecker.Syntax` no longer works
- **Fix**: Use `import Logos.Core.Syntax`

### 2. Namespace Declarations
All namespace declarations now include `.Core` layer:
- **Breaking**: `namespace ProofChecker.Syntax` no longer works
- **Fix**: Use `namespace Logos.Core.Syntax`

### 3. Test Namespaces
All test namespaces now include `.Core` layer:
- **Breaking**: `namespace ProofCheckerTest.Syntax` no longer works
- **Fix**: Use `namespace LogosTest.Core.Syntax`

## Semantic Preservation

**No semantic changes**: All proofs, axioms, and semantics remain identical. This refactor is purely organizational:
- All 8 axioms unchanged
- All 7 inference rules unchanged
- Task semantics unchanged
- Perpetuity principles unchanged
- All proofs preserved

## Build System Changes

### lakefile.toml
- Package name changed from `"ProofChecker"` to `"Logos"`
- Library names updated: `"ProofChecker"` → `"Logos"`, `"ProofCheckerTest"` → `"LogosTest"`
- Test executable root updated: `"ProofCheckerTest.Main"` → `"LogosTest.Main"`

### Build Commands (Unchanged)
```bash
lake build        # Build entire project
lake test         # Run test suite
lake lint         # Run linter
lake clean        # Clean build artifacts
```

## Rationale

### Why Rename?
The name "Logos" better reflects the philosophical foundations (formal language of thought) and provides clearer branding distinct from generic "proof checker" tools.

### Why Layer Architecture?
The layer architecture enables progressive extension from Core TM logic to explanatory, epistemic, and normative reasoning while maintaining clean separation of concerns and independent testability.

## Support

For questions or issues with migration:
- Open an issue on GitHub
- See [CONTRIBUTING.md](Documentation/ProjectInfo/CONTRIBUTING.md)
- Consult [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md) for architectural details

## Historical References

When citing the project in its ProofChecker phase (pre-v0.2.0), use:
```bibtex
@software{proofchecker2025,
  title = {ProofChecker: LEAN 4 Proof System for Bimodal Logic TM},
  author = {Your Name},
  year = {2025},
  note = {Renamed to Logos in v0.2.0},
  url = {https://github.com/yourusername/ProofChecker}
}
```

For the Logos phase (v0.2.0+), use:
```bibtex
@software{logos2025,
  title = {Logos: LEAN 4 Formal Language of Thought},
  author = {Your Name},
  year = {2025},
  url = {https://github.com/yourusername/ProofChecker}
}
```

---

**Migration Date**: 2025-12-04
**Refactor Branch**: `refactor/logos-layer-architecture`
**Target Release**: v0.2.0
