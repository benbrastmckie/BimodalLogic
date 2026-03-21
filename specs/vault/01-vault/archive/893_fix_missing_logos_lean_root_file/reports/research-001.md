# Research Report: Fix Missing Logos.lean Root File

**Task**: 893 - fix_missing_logos_lean_root_file
**Date**: 2026-02-17
**Session**: sess_1771374081_edab3d

## Executive Summary

The `Theories/Logos.lean` root file is missing, causing `lake build` to fail immediately. Historical git evidence shows this file existed and was properly structured as a re-export of the Bimodal library. The solution is to restore the Logos.lean root file with its documented re-export pattern.

## Findings

### 1. Lakefile Configuration

The `lakefile.lean` defines Logos as the default target:
```lean
@[default_target]
lean_lib Logos where
  srcDir := "Theories"
  roots := #[`Logos]
  leanOptions := theoryLeanOptions
```

This configuration expects:
- Root module: `Logos` (file: `Theories/Logos.lean`)
- Source directory: `Theories/`
- Linter options applied

### 2. Current Directory Structure

**Theories/**:
- `Bimodal.lean` - root re-export for Bimodal library
- `Bimodal/` - full Bimodal implementation (complete)
- `README.md` - documentation
- **Missing**: `Logos.lean`

**Tests/**:
- `BimodalTest.lean` - root re-export
- `BimodalTest/` - test implementation
- **Missing**: `LogosTest.lean` (not critical for main build, but defined in lakefile)

### 3. Historical Evidence

Git history shows the file existed and was properly structured:

**Commit 3c9dc688** (2026-01-11, "task 376 phase 3: move Logos to Theories/"):
- Moved `Logos.lean` to `Theories/Logos.lean`
- Updated lakefile with srcDir and roots configuration

**Content from that commit** (`git show 3c9dc688:Theories/Logos.lean`):
```lean
-- Re-export public API (Bimodal library is now the core implementation)
import Bimodal

/-!
# Logos Library Root

This is the main entry point for the Logos library, which implements
an axiomatic proof system for the bimodal logic TM (Tense and Modality) with
task semantics.

## Overview

Logos provides:
- **Bimodal Logic TM**: Combining S5 modal logic (metaphysical necessity/possibility)
  with linear temporal logic (past/future operators)
- **Task Semantics**: Possible worlds as functions from times to world states
  constrained by task relations
- **Layered Architecture**: Layer 0 (Core TM) with planned extensions
- **Complete Metalogic**: Soundness and completeness proofs
- **Perpetuity Principles**: P1-P6 derived theorems

## Module Structure

The library is organized into the following submodules:

- `Bimodal.Syntax`: Formula types, parsing, DSL
- `Bimodal.ProofSystem`: Axioms, derivation trees, and inference rules
- `Bimodal.Semantics`: Task frame semantics
- `Bimodal.Metalogic`: Soundness and completeness proofs
- `Bimodal.Theorems`: Key theorems (perpetuity principles, etc.)
- `Bimodal.Automation`: Proof automation tactics

## Usage

Import the entire library:
\`\`\`lean
import Logos
\`\`\`

Or import specific modules:
\`\`\`lean
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms
\`\`\`
-/

namespace Logos

-- Version information
def version : String := "0.1.0"
```

### 4. Current Build Failure

```
lake build 2>&1
error: no such file or directory (error code: 2)
  file: /home/benjamin/Projects/ProofChecker/Theories/Logos.lean
```

The build fails at the job computation stage because Lake cannot find the root module file for the Logos target.

### 5. Bimodal.lean Pattern

The existing `Theories/Bimodal.lean` demonstrates the correct pattern:
```lean
-- Re-export public API (imports from Bimodal subdirectory)
import Bimodal
...
```

The Logos.lean should follow the same pattern: import Bimodal to re-export it.

## Fix Options Evaluation

| Option | Pros | Cons | Recommendation |
|--------|------|------|-----------------|
| **Restore Logos.lean** | Maintains intended architecture; restores public re-export API; matches lakefile intent | Requires maintaining root file | ✓ **RECOMMENDED** |
| Remove/comment Logos target | Simplifies lakefile; removes unused export | Breaks user API; changes intended design; means removing default target | Not recommended |
| Replace with Bimodal target | Simplifies; avoids duplication | Changes public API expectations; users expect "Logos" | Not recommended |

## Recommended Solution

**Restore the Logos.lean root file at `Theories/Logos.lean`** with the content from git commit 3c9dc688.

### Rationale

1. **Historical Precedent**: File existed and was consciously moved in task 376
2. **Architectural Intent**: Logos is designed as the public API, Bimodal as implementation
3. **Lakefile Design**: Default target is Logos (not Bimodal)
4. **User Expectations**: Public API should be `import Logos`, not `import Bimodal`
5. **Minimal Change**: Simply restores a previously working file

### Implementation Details

Create `Theories/Logos.lean` with:
- Import statement: `import Bimodal` (re-exports all Bimodal functionality)
- Module declaration: `namespace Logos`
- Documentation: Existing docstring explains purpose and structure
- Version info: Simple string constant

After restoration, `lake build` will succeed and the default target will build correctly.

## Secondary Issue: LogosTest

Note: The lakefile also defines a `LogosTest` target in `Tests/` that expects `Tests/LogosTest.lean`, but the file doesn't exist. Currently only `BimodalTest.lean` exists. This is not critical for the main build but should be addressed separately:

**Option A**: Create `Tests/LogosTest.lean` as a re-export of `BimodalTest`
**Option B**: Remove LogosTest from lakefile (if tests are Bimodal-only)

Recommend resolving this in a follow-up task to maintain consistency.

## Summary

The missing `Theories/Logos.lean` file breaks the default build. This file existed historically and implemented a clean re-export pattern. Restoring it from git history is the recommended fix, as it maintains the intended Logos/Bimodal API distinction and satisfies the lakefile configuration.
