# Research Report: Task #387

**Task**: Standardize Research/ file names and fix references
**Date**: 2026-01-11
**Focus**: General research

## Summary

The `docs/Research/` directory contains 7 files with inconsistent naming conventions. Four files use ALL_CAPS (DUAL_VERIFICATION.md, PROOF_LIBRARY_DESIGN.md, README.md, THEORY_COMPARISON.md), while three use lowercase-hyphenated format (deduction-theorem-necessity-research.md, noncomputable-research.md, property-based-testing-lean4.md). The lowercase-hyphenated files redundantly include "research" in their names. There are extensive references throughout the codebase (~230 occurrences) that must be updated.

## Findings

### Current File Inventory

**docs/Research/** (7 files):
| Current Name | Naming Style | Issue |
|-------------|--------------|-------|
| DUAL_VERIFICATION.md | ALL_CAPS | Inconsistent with modern style |
| PROOF_LIBRARY_DESIGN.md | ALL_CAPS | Inconsistent with modern style |
| THEORY_COMPARISON.md | ALL_CAPS | Inconsistent with modern style |
| README.md | ALL_CAPS | Standard README, keep as-is |
| deduction-theorem-necessity-research.md | lowercase-hyphenated | Redundant "research" suffix |
| noncomputable-research.md | lowercase-hyphenated | Redundant "research" suffix |
| property-based-testing-lean4.md | lowercase-hyphenated | Clean (no redundancy) |

### Theory-Specific Research Directories

**Theories/Logos/docs/Research/** (4 files):
- CONCEPTUAL_ENGINEERING.md (ALL_CAPS)
- LAYER_EXTENSIONS.md (ALL_CAPS)
- RECURSIVE_SEMANTICS.md (ALL_CAPS)
- README.md (standard)

**Theories/Bimodal/docs/Research/** (8 files):
- LEANSEARCH_API_SPECIFICATION.md (ALL_CAPS)
- MODAL_TEMPORAL_PROOF_SEARCH.md (ALL_CAPS)
- PROOF_SEARCH_AUTOMATION.md (ALL_CAPS)
- leansearch-best-first-search.md (lowercase)
- leansearch-priority-queue.md (lowercase)
- leansearch-proof-caching-memoization.md (lowercase)
- temporal-logic-automation-research.md (lowercase, redundant suffix)
- README.md (standard)

### Reference Count Analysis

Grep found ~230 references to `docs/Research/` across the codebase:
- README.md (project root): 12 references
- docs/Research/README.md: 18 internal references
- Theories/Logos/*: ~30 references
- Theories/Bimodal/*: ~15 references
- .claude/specs/* (historical): ~150+ references (many in archive)
- .opencode/specs/* (historical): ~25 references

### Broken Reference Risk

Some references point to files that were moved during Task 374 (project documentation refactor):
- `docs/Research/RECURSIVE_SEMANTICS.md` → now at `Theories/Logos/docs/Research/`
- `docs/Research/LAYER_EXTENSIONS.md` → now at `Theories/Logos/docs/Research/`
- `docs/Research/CONCEPTUAL_ENGINEERING.md` → now at `Theories/Logos/docs/Research/`
- `docs/Research/MODAL_TEMPORAL_PROOF_SEARCH.md` → now at `Theories/Bimodal/docs/Research/`

## Recommendations

### Naming Convention

Adopt **lowercase-hyphenated** naming for all research files (except README.md):
- Consistent with modern documentation standards
- Easier to type in URLs and command lines
- Follows Lean 4/Mathlib documentation conventions

### Proposed Renames

**docs/Research/**:
| Current | Proposed |
|---------|----------|
| DUAL_VERIFICATION.md | dual-verification.md |
| PROOF_LIBRARY_DESIGN.md | proof-library-design.md |
| THEORY_COMPARISON.md | theory-comparison.md |
| deduction-theorem-necessity-research.md | deduction-theorem-necessity.md |
| noncomputable-research.md | noncomputable.md |
| property-based-testing-lean4.md | property-based-testing-lean4.md (unchanged) |

**Theories/Logos/docs/Research/**:
| Current | Proposed |
|---------|----------|
| CONCEPTUAL_ENGINEERING.md | conceptual-engineering.md |
| LAYER_EXTENSIONS.md | layer-extensions.md |
| RECURSIVE_SEMANTICS.md | recursive-semantics.md |

**Theories/Bimodal/docs/Research/**:
| Current | Proposed |
|---------|----------|
| LEANSEARCH_API_SPECIFICATION.md | leansearch-api-specification.md |
| MODAL_TEMPORAL_PROOF_SEARCH.md | modal-temporal-proof-search.md |
| PROOF_SEARCH_AUTOMATION.md | proof-search-automation.md |
| temporal-logic-automation-research.md | temporal-logic-automation.md |

### Implementation Strategy

1. **Phase 1: Rename files** - Use `git mv` to preserve history
2. **Phase 2: Update active references** - Fix links in:
   - README.md (project root)
   - docs/Research/README.md
   - Theories/*/docs/**/*.md
   - Theories/*/*.lean (doc comments)
3. **Phase 3: Skip archive references** - References in `.claude/specs/archive/` and `.opencode/specs/archive/` are historical and should not be updated

### Scope Limitation

Focus only on:
- `docs/Research/` (7 files)
- `Theories/Logos/docs/Research/` (4 files)
- `Theories/Bimodal/docs/Research/` (8 files)

Do NOT update:
- Historical references in archive directories
- References in implementation plans/reports (they document historical state)

## References

- Task 374: Refactor project documentation (moved many files)
- Task 378: Refactor documentation structure

## Next Steps

1. Create implementation plan with phased approach
2. Rename files using `git mv`
3. Update active references via grep + Edit
4. Verify no broken links with link checker
