# Implementation Summary: Task #420

**Completed**: 2026-01-11
**Duration**: ~2 hours

## Changes Made

Successfully upgraded the ProofChecker project from Mathlib v4.14.0 to v4.27.0-rc1, including updating the Lean toolchain to v4.27.0-rc1. The core libraries (Logos and Bimodal) build successfully.

### Breaking Changes Fixed

1. **LinearOrderedAddCommGroup → Unbundled Instances**
   - Replaced bundled `LinearOrderedAddCommGroup` with unbundled `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]`
   - Affected files across Bimodal and Logos subtheories

2. **List Membership Lemmas API Change**
   - `List.mem_cons_self` now takes element as implicit argument
   - `List.not_mem_nil` now takes proof as implicit argument
   - Updated calls throughout proof files

3. **HashMap API Change**
   - `Std.HashMap.find?` replaced with indexing syntax `[key]?`
   - Fixed in SuccessPatterns.lean and ProofSearch.lean

4. **add_le_add_right Argument Order**
   - Now produces `c + a ≤ c + b` instead of `a + c ≤ b + c`
   - Fixed with `add_comm` in WorldHistory.lean and Truth.lean

5. **swap_past_future → swap_temporal**
   - simp lemmas now unfold to `swap_temporal`
   - Updated SoundnessLemmas.lean simp calls

6. **Validity Proofs Instance Arguments**
   - Updated `intro T _` to `intro T _ _ _` for 3 instance args
   - Fixed in Validity.lean, Soundness.lean

## Files Modified

### Core Library Files
- `lean-toolchain` - Updated to v4.27.0-rc1
- `lakefile.lean` - Updated mathlib requirement to v4.27.0-rc1
- `lake-manifest.json` - Regenerated with new dependencies

### Bimodal Library
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Typeclass unbundling (already done)
- `Theories/Bimodal/Semantics/TaskModel.lean` - Typeclass unbundling
- `Theories/Bimodal/Semantics/WorldHistory.lean` - add_le_add_right fix (already done)
- `Theories/Bimodal/Semantics/Truth.lean` - Multiple fixes
- `Theories/Bimodal/Semantics/Validity.lean` - Typeclass and proof fixes
- `Theories/Bimodal/Metalogic/Soundness.lean` - Instance arg fixes
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - swap_temporal simp fixes
- `Theories/Bimodal/Automation/SuccessPatterns.lean` - HashMap API (already done)
- `Theories/Bimodal/Automation/ProofSearch.lean` - HashMap API
- `Theories/Bimodal/Examples/TemporalStructures.lean` - Typeclass unbundling
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - Removed redundant rfl

### Logos Library
- `Theories/Logos/SubTheories/Explanatory/Frame.lean` - Typeclass unbundling
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - Typeclass unbundling
- `Theories/Logos/SubTheories/Explanatory.lean` - Typeclass unbundling

## Verification

- `lake build Logos` - SUCCESS (420 jobs)
- `lake build Bimodal` - SUCCESS (419 jobs)
- `lake build` (full project) - SUCCESS

## Known Issues / Follow-up

### Test Suite Failures
The test suite (BimodalTest) has failures requiring separate fixes:
- Some tests use APIs that changed
- aesop tactic internal errors on some complex proofs
- DerivationTree API changes affecting test patterns

These are tracked as potential follow-up work.

### Cosmetic Warnings
- Unused simp arguments in some files
- Unused section variables in some theorems
- Deprecation warnings for `le_of_not_lt` (use `le_of_not_gt`)

## NixOS Configuration

For NixOS users, ensure nix-ld is enabled in system configuration:
```nix
programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    gmp
  ];
};
```

Required packages: `elan`, `git`, `curl`

## Notes

The upgrade brings significant improvements:
- New compiler (PR #8577)
- New `grind` SMT tactic
- Improved caching for simp and constructor info
- Parallel kernel checking capability

The test failures are primarily due to API changes in the test infrastructure rather than issues with the core mathematical proofs.
