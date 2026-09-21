# Versioning Policy for ProofChecker

This document describes the versioning policy, deprecation timeline, and release process for ProofChecker.

## 1. Semantic Versioning Policy

ProofChecker follows [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH
```

### Version Components

| Component | When to Increment | Examples |
|-----------|------------------|----------|
| **MAJOR** | Breaking changes to public API | Removing a public function, changing type signatures |
| **MINOR** | New features, backward compatible | New theorems, new tactics, new operators |
| **PATCH** | Bug fixes, no API changes | Fixing proof errors, documentation fixes |

### Examples

```
0.1.0 → 0.2.0  # New feature: temporal tactics
0.2.0 → 0.2.1  # Bug fix: fixed soundness proof
0.2.1 → 1.0.0  # Breaking: changed Formula type definition
1.0.0 → 1.1.0  # New feature: Layer 1 operators
1.1.0 → 2.0.0  # Breaking: redesigned Semantics API
```

### Pre-1.0 Versions

During initial development (version < 1.0.0):
- MINOR version changes may include breaking changes
- API is considered unstable
- Use at own risk in production

### Version 1.0.0 Commitment

Version 1.0.0 indicates:
- Stable public API
- Complete Layer 0 (Core TM) implementation
- Soundness and completeness proofs verified
- Comprehensive documentation
- CI/CD fully operational

## 2. Deprecation Timeline

### Deprecation Process

1. **Mark deprecated**: Add `@[deprecated]` attribute with date
2. **Document**: Add entry to CHANGELOG.md
3. **Warn**: Compiler shows deprecation warning
4. **Remove**: Delete after deprecation period

### Deprecation Period

| Version Type | Deprecation Period |
|--------------|-------------------|
| Pre-1.0 | 1-2 minor versions (flexible) |
| Post-1.0 | 6 months minimum |
| Critical security | May be shorter with notice |

### Marking Deprecated Code

```lean
/-- Old function name (deprecated)
**Deprecated**: Use `new_function_name` instead.
Scheduled for removal in v1.2.0.
-/
@[deprecated new_function_name (since := "2025-01-15")]
def old_function_name := new_function_name

/-- Deprecated type alias -/
@[deprecated NewTypeName (since := "2025-01-15")]
abbrev OldTypeName := NewTypeName
```

### Deprecation Documentation

In CHANGELOG.md:
```markdown
## [0.3.0] - 2025-02-15

### Deprecated
- `old_function_name` - Use `new_function_name` instead (removal: v0.5.0)
- `OldTypeName` - Use `NewTypeName` instead (removal: v0.5.0)
```

## 3. Release Process

### Release Checklist

Before each release:

- [ ] All tests pass (`lake test`)
- [ ] No lint warnings (`lake lint`)
- [ ] No `sorry` in committed code
- [ ] CHANGELOG.md updated
- [ ] Version number updated in all three places it is recorded, which must agree: `def version`
      in `FormalSystem/Version.lean`, the `version:` field of `CITATION.cff` (with
      `date-released:`), and the tag itself. `lakefile.toml` has no version field
- [ ] Documentation is current
- [ ] Release notes written

### Creating a Release

```bash
# 1. Update the version in FormalSystem/Version.lean and in CITATION.cff
#    def version : String := "0.2.0"          (FormalSystem/Version.lean)
#    version: "0.2.0" / date-released: "..."  (CITATION.cff)

# 2. Move CHANGELOG.md's [Unreleased] entries into a new "## [0.2.0] - <date>" section

# 3. Commit version bump
git add FormalSystem/Version.lean CITATION.cff CHANGELOG.md
git commit -m "chore: Release v0.2.0"

# 4. Create tag
git tag -a v0.2.0 -m "Release v0.2.0"

# 5. Push tag
git push origin main
git push origin v0.2.0
```

Pushing the tag triggers `.github/workflows/release.yml`, which rebuilds, tests and lints the
tagged commit, refuses to continue unless the tag, `CITATION.cff` and
`FormalSystem/Version.lean` agree, and publishes a GitHub release whose notes are that version's
`CHANGELOG.md` section. To exercise the workflow without a tag, run it by hand
(`workflow_dispatch`) with `publish` left off: it performs every step except publishing and
uploads the release notes it would have used. Tags are created and pushed by the maintainer;
no automation in this repository does either.

### Release Notes Format

```markdown
# Release v0.2.0

## Highlights
- Brief summary of major changes

## New Features
- Feature 1 description
- Feature 2 description

## Bug Fixes
- Fix 1 description
- Fix 2 description

## Breaking Changes
- Breaking change 1 (migration guide below)

## Deprecations
- Deprecated item (scheduled removal: vX.Y.Z)

## Migration Guide
### Breaking Change 1
Old way:
```lean
-- old code
```

New way:
```lean
-- new code
```

## Contributors
- @contributor1
- @contributor2
```

### Release Schedule

| Release Type | Frequency | Contents |
|--------------|-----------|----------|
| Patch | As needed | Bug fixes only |
| Minor | Monthly | New features |
| Major | When necessary | Breaking changes |

## 4. Backward Compatibility

### Compatibility Policy

**Limited backward compatibility**: ProofChecker prioritizes clean design over backward compatibility.

| Aspect | Policy |
|--------|--------|
| Public API | Stable within major version |
| Internal API | May change in minor versions |
| File formats | Versioned, migration tools provided |
| Proof terms | May change (re-run proofs) |

### Breaking Change Guidelines

When making breaking changes:

1. **Justify**: Document why the change is necessary
2. **Announce**: Add to CHANGELOG.md well in advance
3. **Migrate**: Provide migration guide or scripts
4. **Support**: Answer questions during transition

### What Constitutes a Breaking Change

**Breaking**:
- Removing public definitions
- Changing type signatures
- Renaming without alias
- Changing semantics of existing functions

**Not Breaking**:
- Adding new definitions
- Adding optional parameters with defaults
- Performance improvements
- Bug fixes (unless relied upon)
- Documentation changes

## 5. CHANGELOG Format

### CHANGELOG.md Structure

```markdown
# Changelog

All notable changes to ProofChecker are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- New features not yet released

### Changed
- Changes to existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security fixes

## [0.2.0] - 2025-02-15

### Added
- Temporal tactics (`temporal_k`, `temporal_simp`)
- Perpetuity principle proofs (P1-P6)

### Changed
- Improved proof search performance

### Fixed
- Fixed edge case in modal_t validity proof

## [0.1.0] - 2025-01-15

### Added
- Initial release
- Core TM logic (Layer 0)
- S5 modal axioms
- Temporal axioms
- Basic tactics
```

### Keeping CHANGELOG Updated

- Update `[Unreleased]` section during development
- Move to versioned section at release time
- Link version headers to GitHub compare URLs

## 6. Version Query

### Checking Version

```lean
-- In code
#eval FormalSystem.version  -- "1.0.0"; defined in FormalSystem/Version.lean

-- From command line (the Lean toolchain, then the library's own version)
lake env lean --version
grep 'def version' FormalSystem/Version.lean
```

### Version Compatibility Checking

```lean
/-- Check minimum version requirement -/
def require_version (min_version : String) : Bool :=
  version_compare FormalSystem.version min_version ≥ 0

-- Use in code
#guard require_version "0.2.0"
```

## 7. Support Policy

### Supported Versions

| Version | Support Level | Until |
|---------|--------------|-------|
| Latest | Full support | Next release |
| Previous minor | Security fixes | 6 months after next minor |
| Older | No support | N/A |

### End of Support

When a version reaches end of support:
- No bug fixes
- No security patches
- Documentation remains available
- Users should upgrade

## References

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Contributing Guide](../../CONTRIBUTING.md)
- [Integration Guide](../user-guide/INTEGRATION.md)
