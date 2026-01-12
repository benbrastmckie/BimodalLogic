# Research Report: Task #436

**Task**: Update license to ModelChecker standard
**Date**: 2026-01-12
**Focus**: Compare current license with ModelChecker standard and identify required changes

## Summary

The ProofChecker project currently uses the MIT License while the ModelChecker project uses GPL-3.0-or-later. This task requires changing from MIT to GPL-3.0 to align with the ModelChecker standard, updating the LICENSE file content and all references in documentation.

## Findings

### Current ProofChecker License

**File**: `/home/benjamin/Projects/ProofChecker/LICENSE`

- **License Type**: MIT License
- **Copyright Year**: 2025
- **Copyright Holder**: "Benjamin" (incomplete name)

```
MIT License
Copyright (c) 2025 Benjamin
```

**Documentation References**:
- `README.md` line 63: TOC mentions "MIT License"
- `README.md` line 299-301: License section states "MIT License - see [LICENSE](LICENSE) for details."

### ModelChecker License Standard

**File**: `/home/benjamin/Projects/ModelChecker/Code/LICENSE`

- **License Type**: GNU General Public License v3
- **Copyright Year**: 2024
- **Copyright Holder**: "Benjamin Brast-McKie" (full name)

```
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (c) 2024 Benjamin Brast-McKie
```

**Key GPL-3.0 Elements**:
1. Freedom to redistribute and modify
2. Requires derivative works to use same license
3. No warranty clause
4. Reference to full license text at gnu.org

**Package Metadata** (from `pyproject.toml`):
- `license = { text = "GPL-3.0-or-later" }`
- Classifier: `"License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)"`

**README Reference**:
- `README.md` line 299-301: "This project is licensed under GPL-3.0. See [Code/LICENSE](Code/LICENSE) for details."

### Theory-Specific Licenses in ModelChecker

ModelChecker also has theory-specific LICENSE.md files (e.g., `/home/benjamin/Projects/ModelChecker/Code/src/model_checker/theory_lib/logos/LICENSE.md`) with:
- GPL-3.0 license statement
- Software implementation copyright
- Semantic theory attribution
- Derivative work guidelines
- Substantial contributions definition
- Example attribution format

### License Compatibility Considerations

**MIT to GPL-3.0 Change**:
- MIT is permissive; GPL-3.0 is copyleft
- This is a policy change (more restrictive)
- No legal issues switching own project's license
- Existing forks under MIT remain valid for their snapshots

**Mathlib/Lean Ecosystem**:
- Mathlib uses Apache-2.0 (GPL-3.0 compatible)
- Lean compiler uses Apache-2.0
- No compatibility issues with dependencies

## Recommendations

### 1. Update LICENSE File (Required)

Replace current MIT LICENSE with GPL-3.0 standard text:
- Use same format as ModelChecker/Code/LICENSE
- Update copyright year to 2025 (or 2024-2025 range)
- Use full name "Benjamin Brast-McKie"

### 2. Update README.md References (Required)

Update two locations:
- Line 63: TOC entry should change from "MIT License" to "GPL-3.0 License"
- Line 299-301: License section should state "This project is licensed under GPL-3.0. See [LICENSE](LICENSE) for details."

### 3. Optional Enhancements

Consider (but not required for this task):
- Adding theory-specific LICENSE.md files for Bimodal and Logos theories
- Adding CITATION.md for academic attribution
- Adding contributor guidelines for derivative works

## Implementation Approach

**Phase 1: Update LICENSE file**
- Replace entire content with GPL-3.0 text matching ModelChecker format

**Phase 2: Update README.md**
- Update TOC entry (line 63)
- Update License section (lines 299-301)

**Estimated Effort**: 30 minutes (as stated: 1 hour with buffer)

## References

- Current ProofChecker LICENSE: `/home/benjamin/Projects/ProofChecker/LICENSE`
- ModelChecker LICENSE: `/home/benjamin/Projects/ModelChecker/Code/LICENSE`
- ModelChecker theory LICENSE example: `/home/benjamin/Projects/ModelChecker/Code/src/model_checker/theory_lib/logos/LICENSE.md`
- GPL-3.0 full text: https://www.gnu.org/licenses/gpl-3.0.txt

## Next Steps

Run `/plan 436` to create implementation plan for license update.
