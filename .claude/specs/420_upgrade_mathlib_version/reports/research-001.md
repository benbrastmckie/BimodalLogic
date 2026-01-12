# Research Report: Task #420

**Task**: Upgrade Mathlib version
**Date**: 2026-01-11
**Focus**: NixOS requirements for Lean 4/Mathlib upgrade

## Summary

Upgrading from Mathlib v4.14.0 to a newer version (targeting v4.26.0 or v4.27.0-rc1) requires updating the Lean toolchain from v4.14.0 to the corresponding version. On NixOS, the recommended approach is using elan from nixpkgs, which automatically patches downloaded binaries. The upgrade path involves significant improvements but requires testing for breaking changes across 12+ intermediate versions.

## Current Project Configuration

- **Lean toolchain**: v4.14.0
- **Mathlib**: v4.14.0
- **Dependencies**: batteries, aesop, Qq, proofwidgets, plausible, LeanSearchClient, importGraph, Cli
- **Build system**: Lake (lakefile.lean)

## Findings

### NixOS Requirements

#### Software Requirements
1. **elan** (from nixpkgs) - Manages Lean toolchain versions, automatically patches binaries for NixOS
2. **git** - Required for Lake to download dependencies
3. **curl** - Required by Lean for network operations

#### Installation Approaches (Ranked by Ease)

1. **nixpkgs elan** (Recommended for simplicity):
   ```nix
   environment.systemPackages = [ pkgs.elan ];
   ```
   - Automatically patches downloaded Lean binaries
   - Works with standard `lean-toolchain` file
   - Handles toolchain switching automatically

2. **lean4-nix flake** (For reproducible builds):
   ```nix
   pkgs = import nixpkgs {
     inherit system;
     overlays = [ (lean4-nix.readToolchainFile ./lean-toolchain) ];
   };
   ```
   - Minimum supported version: v4.11.0
   - From v4.22.0+: requires `bootstrap` and `buildLeanPackage` functions
   - More complex but fully reproducible

3. **Standalone lean4 package** (Not recommended):
   - Fixed version in nixpkgs
   - Version may not match project requirements

#### Recommended NixOS Configuration

```nix
# configuration.nix or flake.nix
{
  environment.systemPackages = with pkgs; [
    elan      # Lean version manager
    git       # For lake dependencies
    curl      # For lean downloads
  ];

  # Optional: Cachix for faster builds
  nix.settings = {
    trusted-substituters = [ "https://lean4.cachix.org/" ];
    trusted-public-keys = [ "lean4.cachix.org-1:..." ];
  };
}
```

### Available Mathlib/Lean Versions

| Mathlib Version | Lean Version | Release Date |
|-----------------|--------------|--------------|
| v4.27.0-rc1 | v4.27.0-rc1 | 2025-12-14 |
| v4.26.0 | v4.26.0 | 2025-12-13 |
| v4.25.0 | v4.25.0 | 2025-11-14 |
| v4.24.0 | v4.24.0 | 2025-10-14 |
| v4.23.0 | v4.23.0 | 2025-09-15 |
| v4.22.0 | v4.22.0 | 2025-08-14 |
| v4.21.0 | v4.21.0 | 2025-06-30 |
| v4.20.0 | v4.20.0 | 2025-06-02 |
| v4.14.0 (current) | v4.14.0 | 2024-12-02 |

### Key Improvements Since v4.14.0

#### Lean 4.22.0 (Target Minimum)
- **New Compiler**: Old compiler replaced with new one (PR #8577)
- **grind Tactic**: New SMT-style tactic with cutsat and Grobner basis solver
- **Caching Improvements**:
  - `simp` consults its cache more often
  - `hasTrivialStructure?` function now cached
  - Constructor info caching in toIR
- **Compiler Optimizations**: LCNF pass pipeline improved

#### Lean 4.18.0
- **grind Tactic**: Linear integer inequality normalizer completed
- **Ordered Map Structures**: DTreeMap, TreeMap, TreeSet added to std lib
- **Deprecated**: `simp_arith` (use `+arith` option)

#### Lean 4.17.0
- **Parallel Kernel Checking**: Can run parallel to elaboration
- **Async Framework**: Basic async + timers using libuv
- **BitVec Support**: UIntX/USize in bv_decide

#### Lean 4.15.0
- **Breaking Change**: May need additional implicit arguments in expressions
- **Timezone Fixes**: Better fallback for tzdata directory

#### Lean 4.14.0 (Current)
- **Syntax Changes**: `inductive :=` deprecated for `where` variant
- **Tactic Config Syntax**: `simp +contextual` instead of `simp (config := {...})`
- **Attribute**: `attribute [simp <-]` for reverse direction
- **Lake**: Auto-updates toolchain on `lake update`

### Breaking Changes to Watch

1. **Implicit Arguments** (v4.15.0): Some expressions may need additional implicits
2. **Syntax Deprecations** (v4.14.0): `inductive :=` -> `where`
3. **Tactic Deprecations** (v4.18.0): `simp_arith` -> `simp +arith`
4. **Have/Let Semantics** (v4.22.0): Nondependent `let` transformed to `have`
5. **Compiler Changes** (v4.22.0): New compiler may surface previously hidden issues

### Upgrade Strategy

**Option A: Direct Upgrade** (Fast but risky)
- Jump directly to v4.26.0 or v4.27.0-rc1
- Fix all breaking changes at once
- Risk: Large number of errors to debug

**Option B: Incremental Upgrade** (Safer but slower)
- Upgrade through each stable release: v4.15 -> v4.16 -> ... -> v4.26
- Fix breaking changes incrementally
- Better for understanding what changed
- Mathlib recommends this approach for large projects

**Option C: Milestone Upgrade** (Balanced)
- Upgrade to key milestones: v4.14 -> v4.18 -> v4.22 -> v4.26
- Corresponds to major feature releases
- Moderate complexity

### Upgrade Procedure

1. **Preparation**:
   ```bash
   git status  # Ensure clean
   lake clean  # Optional but recommended
   rm -rf .lake  # Remove old cache
   ```

2. **Update toolchain**:
   ```bash
   echo "leanprover/lean4:v4.26.0" > lean-toolchain
   ```

3. **Update lakefile.lean**:
   ```lean
   require mathlib from git
     "https://github.com/leanprover-community/mathlib4.git" @ "v4.26.0"
   ```

4. **Fetch new dependencies**:
   ```bash
   lake update -R
   ```

5. **Get cached oleans**:
   ```bash
   lake exe cache get
   ```

6. **Build and fix errors**:
   ```bash
   lake build
   ```

## Recommendations

1. **Target Version**: v4.26.0 (stable, recent, well-tested)
2. **Upgrade Strategy**: Option C (Milestone Upgrade) - v4.14 -> v4.22 -> v4.26
3. **NixOS Setup**: Use elan from nixpkgs for simplicity

### Phased Implementation

**Phase 1**: Upgrade to v4.22.0
- Gets most compiler and caching improvements
- New grind tactic available
- Moderate number of breaking changes

**Phase 2**: Upgrade to v4.26.0
- Stabilize on latest stable release
- Additional refinements and fixes

## References

- [Lean Release Notes](https://lean-lang.org/doc/reference/latest/releases/)
- [Lean 4.22.0 Release](https://lean-lang.org/doc/reference/latest/releases/v4.22.0/)
- [Mathlib4 GitHub](https://github.com/leanprover-community/mathlib4)
- [Mathlib4 Tags](https://github.com/leanprover-community/mathlib4/tags)
- [Mathlib Changelog](https://mathlib-changelog.org/v4)
- [lean4-nix](https://github.com/lenianiva/lean4-nix)
- [elan README](https://github.com/leanprover/elan/blob/master/README.md)
- [NixOS and Lean Discussion](https://leanprover-community.github.io/archive/stream/113488-general/topic/NixOS.20and.20Lean.html)
- [Using Mathlib4 as a Dependency](https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency)
- [Updating Lean Dependencies Guide](https://malv.in/posts/2024-12-09-howto-update-lean-dependencies.html)

## Next Steps

1. Ensure NixOS has elan, git, curl available
2. Create a backup branch before upgrade
3. Test upgrade path in phases (v4.22 first, then v4.26)
4. Run full build after each phase to identify breaking changes
5. Check `@[deprecated]` warnings for guidance on API changes
