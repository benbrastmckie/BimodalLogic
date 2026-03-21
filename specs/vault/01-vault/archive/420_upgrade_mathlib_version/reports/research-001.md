# Research Report: Task #420

**Task**: Upgrade Mathlib version
**Date**: 2026-01-11
**Status**: IN PROGRESS
**Focus**: NixOS requirements for Lean 4/Mathlib upgrade

## Summary

Upgrading from Mathlib v4.14.0 to v4.27.0-rc1 (required by Mathlib v4.26.0+). The Lean toolchain has been updated from v4.14.0 to v4.27.0-rc1. On NixOS, elan from nixpkgs is used with nix-ld for binary patching.

## Upgrade Status

### Completed

1. **Toolchain updated**: `lean-toolchain` now specifies `leanprover/lean4:v4.27.0-rc1`
2. **Lakefile updated**: `lakefile.lean` now requires `mathlib @ "v4.27.0-rc1"`
3. **Dependencies fetched**: `lake update -R` completed successfully
4. **Mathlib cache downloaded**: `lake exe cache get` completed
5. **NixOS configuration updated**: Added `programs.nix-ld` to `~/.dotfiles/configuration.nix` for elan binary patching
6. **Breaking changes fixed**:
   - `LinearOrderedAddCommGroup` replaced with unbundled `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]` in:
     - `Theories/Bimodal/Semantics/TaskFrame.lean`
     - `Theories/Bimodal/Semantics/WorldHistory.lean`
   - `List.mem_cons_self` usage fixed (now a proof term, not a function) in:
     - `Theories/Bimodal/Syntax/Context.lean`
   - `List.not_mem_nil` usage fixed in:
     - `Theories/Bimodal/ProofSystem/Derivation.lean`
   - `Std.HashMap.find?` replaced with `[key]?` indexing syntax in:
     - `Theories/Bimodal/Automation/SuccessPatterns.lean`

### Remaining Issues

Two build errors remain:

1. **WorldHistory.lean** (lines 243-244, 253):
   - `add_le_add_right` argument order changed
   - Fix applied but needs verification

2. **Perpetuity/Principles.lean** (line 837):
   - `rfl` tactic error: "No goals to be solved"
   - The `simp only` on line 836 now fully solves the goal
   - Fix: Remove the `rfl` line

### Pending System Change

- Run `sudo nixos-rebuild switch --flake ~/.dotfiles#omen` to enable nix-ld
- This ensures elan-downloaded binaries work correctly after system updates

## Current Project Configuration

- **Lean toolchain**: v4.27.0-rc1 (upgraded from v4.14.0)
- **Mathlib**: v4.27.0-rc1 (upgraded from v4.14.0)
- **Dependencies**: batteries, aesop, Qq, proofwidgets, plausible, LeanSearchClient, importGraph, Cli
- **Build system**: Lake (lakefile.lean)

## Breaking Changes Encountered

### 1. LinearOrderedAddCommGroup Removed

The bundled typeclass `LinearOrderedAddCommGroup` no longer exists. Replace with unbundled version:

```lean
-- Before
structure Foo (T : Type*) [LinearOrderedAddCommGroup T] where

-- After
structure Foo (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T] where
```

### 2. List Membership Lemmas Changed

`List.mem_cons_self` and `List.not_mem_nil` are now proof terms, not functions:

```lean
-- Before
exact ⟨φ, List.mem_cons_self φ _⟩
exact False.elim (List.not_mem_nil _ h)

-- After
exact ⟨φ, List.mem_cons_self ..⟩
exact False.elim (List.not_mem_nil h)
```

### 3. HashMap API Changed

`Std.HashMap.find?` method replaced with indexing syntax:

```lean
-- Before
db.patterns.find? key

-- After
db.patterns[key]?
```

### 4. add_le_add_right Argument Order

The lemma now produces `c + a ≤ c + b` instead of `a + c ≤ b + c`:

```lean
-- Before
have h : x + Δ ≤ y + Δ := add_le_add_right hxy Δ

-- After
have h : x + Δ ≤ y + Δ := by rw [add_comm x, add_comm y]; exact add_le_add_right hxy Δ
```

## NixOS Requirements

### Software Requirements
1. **elan** (from nixpkgs) - Manages Lean toolchain versions
2. **git** - Required for Lake to download dependencies
3. **curl** - Required by Lean for network operations
4. **nix-ld** - Required to run elan-downloaded binaries

### NixOS Configuration Added

```nix
# Added to configuration.nix
programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    gmp
  ];
};
```

## Next Steps

1. Fix remaining build errors in:
   - `Theories/Bimodal/Semantics/WorldHistory.lean`
   - `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`
2. Run `sudo nixos-rebuild switch` to enable nix-ld
3. Run `lake build` to verify full build succeeds
4. Create upgrade completion report

## References

- [Lean Release Notes](https://lean-lang.org/doc/reference/latest/releases/)
- [Mathlib4 GitHub](https://github.com/leanprover-community/mathlib4)
- [Mathlib Changelog](https://mathlib-changelog.org/v4)
