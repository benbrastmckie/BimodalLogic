# Documentation Audit Report — Task 183

## Executive Summary

Audit of the `Theories/Bimodal/` documentation covering 152 active .lean files across 26 Lean-containing directories (excluding Boneyard). The codebase has strong module docstring coverage (100%) and good API docstring density (~2983 total), but READMEs are significantly stale in several areas and 8 Lean directories lack READMEs entirely.

---

## 1. README Audit

### Existing READMEs (16 in Lean-code directories)

| Directory | Rating | Issues |
|-----------|--------|--------|
| `Theories/Bimodal/` (root) | **Stale** | References non-existent `Examples/Demo.lean` and `LogicVariants.lean`; says "21 axiom schemata" but actual count is 40; references `Metalogic/BaseCompleteness.lean` which doesn't exist; Submodules section says "15 axiom schemata" for ProofSystem |
| `Syntax/` | **Stale** | Lists 5 files, missing `BigConj.lean` (6 active .lean files total) |
| `ProofSystem/` | **Severely Stale** | Says "15 TM axiom schemas" — actual system has 40 constructors; lists 3 files, missing `Substitution.lean`; axiom category counts (2+6+5+2=15) are outdated |
| `Semantics/` | **Accurate** | File list matches reality (5 files); links to `../Metalogic/Soundness/README.md` broken (no such directory) |
| `Metalogic/` | **Stale** | Dependency flowchart references non-existent files (`Bundle/TruthLemma.lean`, `Bundle/BFMCSTruth.lean`, `Bundle/Completeness.lean`); says "15 TM axioms" in soundness description; architecture diagram partially outdated |
| `Metalogic/Core/` | **Accurate** | File list matches (5 files), descriptions current |
| `Metalogic/Bundle/` | **Accurate** | File list matches (14 .lean files), architecture current, sorry status accurate |
| `Metalogic/Decidability/` | **Stale** | Missing FMP subdirectory (7 files); references `../Soundness/README.md` which doesn't exist |
| `Metalogic/Algebraic/` | **Accurate** | Current files match, archived items clearly marked |
| `Metalogic/Relational/` | **Accurate** | Correctly says "placeholder, currently empty" |
| `Metalogic/ConservativeExtension/` | **Accurate** | File list matches (4 .lean files) |
| `Automation/` | **Accurate** | File list matches (4 .lean files), usage examples reasonable |
| `Examples/` | **Accurate** | File list matches (2 .lean files) |
| `Theorems/` | **Stale** | Lists `Discreteness.lean` which doesn't exist; missing `TemporalDerived.lean` |
| `Theorems/Perpetuity/` | **Accurate** | File list matches (3 .lean files), principles correctly described |

### Rating Summary

- **Accurate**: 9 READMEs (ConservativeExtension, Core, Bundle, Algebraic, Relational, Automation, Examples, Perpetuity, Semantics)
- **Stale**: 5 READMEs (Root, Syntax, Metalogic, Decidability, Theorems)
- **Severely Stale**: 1 README (ProofSystem — axiom count is 15 vs actual 40)

### Missing READMEs (8 directories with .lean files)

| Directory | File Count | Priority |
|-----------|-----------|----------|
| `FrameConditions/` | 4 files | High (new directory, no README) |
| `Metalogic/BXCanonical/` | 7 files | High (active development) |
| `Metalogic/BXCanonical/Chronicle/` | 6 files | Medium |
| `Metalogic/BXCanonical/Filtration/` | 1 file | Low |
| `Metalogic/BXCanonical/Quasimodel/` | 6 files | Medium |
| `Metalogic/Decidability/FMP/` | 7 files | Medium |
| `Metalogic/WeakCanonical/` | 17 files | High (active development, largest) |
| `Metalogic/WeakCanonical/Separation/` | 13 files | Medium |

---

## 2. Module Docstring Coverage

**Result: 152/152 files have `/-! ... -/` module docstrings (100% coverage).**

### Quality Distribution (by docstring length)

| Size | Count | Notes |
|------|-------|-------|
| 3-15 lines | ~5 | Minimal: re-export modules (WeakCanonical.lean, Core.lean, BXCanonical.lean, FMCS.lean) |
| 16-50 lines | ~30 | Standard: lists Main Definitions and Main Results |
| 51-200 lines | ~80 | Rich: includes design notes, references, implementation details |
| 200+ lines | ~37 | Extensive: full proof strategies, literature references, dependency flowcharts |

### Key Observations

- All 152 files have module docstrings, no gaps
- Re-export/aggregator modules (`.lean` files that only `import`) have appropriately minimal docstrings
- Complex metalogic files (EFGames, Separation, Chronicle) have extensive docstrings documenting proof strategies
- Module docstrings commonly include: `## Main Definitions`, `## Main Results`, `## Implementation Notes`, `## References`

---

## 3. Comment Patterns

### Tag Counts

| Pattern | Count | Notes |
|---------|-------|-------|
| `TODO:` | 2 | Both in `Automation/Tactics.lean` (BX refactor notes) |
| `NOTE:` | 43 | Mostly removal/refactoring notes in SoundnessLemmas.lean (17), rest scattered |
| `FIX:` | 0 | None |
| `QUESTION:` | 0 | None |
| `#check` | 19 | Demonstrative usage in Theorems.lean, Bimodal.lean, Decidability.lean, FrameClass.lean |
| API docstrings (`/--`) | 2983 | Across 133 files |
| Block comments (`/- ... -/`) | 2 | Explanatory notes, not commented-out code |
| Commented-out definitions | ~6 | Very minimal |

### Files Without API Docstrings

19 files lack any `/--` docstrings. All are re-export/aggregator modules that contain no definitions:
- Root re-exports: `Automation.lean`, `Examples.lean`, `FrameConditions.lean`, `ProofSystem.lean`, `Semantics.lean`, `Syntax.lean`, `Theorems.lean`
- Sub-re-exports: `Metalogic.lean`, `Metalogic/Metalogic.lean`, `Core/Core.lean`, `WeakCanonical.lean`, etc.
- FMCS.lean (Bundle) — this one probably should have API docstrings given its definitions

### NOTE: Pattern Distribution

The 43 `NOTE:` comments break down as:
- **17 in SoundnessLemmas.lean**: All document removed axiom constructors from refactoring tasks
- **3 in Core/RestrictedMCS.lean**: Document removed lemmas
- **2 in BXCanonical/CanonicalChain.lean**: Document removed lemmas
- **Rest scattered**: Implementation notes in WeakCanonical files

### `#check` Usage

All 19 `#check` commands serve as inline API demonstrations, not debugging artifacts:
- `Theorems.lean`: Shows key theorem names for quick reference
- `Decidability.lean`: Shows main entry points
- `FrameClass.lean`: Verifies typeclass instances

---

## 4. Mathlib Documentation Conventions

### Directory READMEs (Mathlib Pattern)

Mathlib uses **minimal** directory READMEs:
- Brief 1-2 sentence description of the directory scope
- Optional: hierarchy listing of subfolders with dependency notes
- Pattern: "Files in earlier subfolders should not import files in later ones"
- No module inventories, no status tables, no ASCII flowcharts

### Module Docstrings (Mathlib Pattern)

```lean
/-!
# Title - Brief Description

Brief description of what the module contains (1-2 paragraphs).

## Main Definitions

- `DefName`: One-line description

## Main Results

- `theorem_name`: One-line description of statement

## Notation

- `a ⋖ b` means that `b` covers `a`.

## Implementation Notes

(optional) Design decisions.

## References

(optional) Papers or books.
-/
```

### API Docstrings (Mathlib Pattern)

```lean
/-- Brief one-line description of what this def/theorem does. -/
```

Or for complex items:
```lean
/-- Multi-line description.

More context on the definition or usage pattern. -/
```

### Comparison: ProofChecker vs Mathlib

| Aspect | ProofChecker | Mathlib |
|--------|-------------|---------|
| README depth | Very detailed (flowcharts, status tables, sorry counts) | Minimal (scope + hierarchy only) |
| Module docstrings | 100% coverage, often very detailed | Required by linter, standard format |
| API docstrings | 2983 total, good density | Required for all public defs |
| `#check` in source | 19 (demonstrative) | Not used in library files |
| Comment tags (NOTE/TODO) | 45 total | Rare; TODOs in READMEs only |
| Copyright headers | None | Required on every file |

### Recommendation

ProofChecker's documentation is significantly more detailed than Mathlib's convention. This is appropriate for a research project where proof architecture understanding is critical. The project should maintain its richer standard but adopt Mathlib's consistent formatting.

---

## 5. Script-Assisted Approach Feasibility

### Module Inventory Table Generation

A script can auto-generate tables for READMEs. Prototype tested:

```bash
for f in Theories/Bimodal/Syntax/*.lean; do
  lines=$(wc -l < "$f")
  defs=$(grep -c "^def \|^theorem \|^lemma \|..." "$f")
  echo "| $(basename $f) | $lines | $defs |"
done
```

**Output example (Syntax/)**:

| File | Lines | Definitions |
|------|-------|-------------|
| Atom.lean | 208 | 25 |
| BigConj.lean | 49 | 2 |
| Context.lean | 204 | 16 |
| Formula.lean | 566 | 41 |
| SubformulaClosure.lean | 1889 | 157 |
| Subformulas.lean | 229 | 22 |

### Missing Docstring Detection

```bash
find Theories/Bimodal -name "*.lean" ! -path "*/Boneyard/*" -exec grep -L "^/-!" {} \;
```
Currently returns empty (100% coverage). Can also detect thin docstrings:
```bash
# Files with docstrings < 10 lines
find ... -exec sh -c 'count=$(sed -n "/^\/-!/,/^-\//p" "$1" | wc -l); [ $count -lt 10 ] && echo "$1"' _ {} \;
```

### Sorry Audit Script

```bash
grep -rcn "sorry" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard | grep -v ":0"
```
Current: 145 sorry occurrences across 35 files.

### Feasibility Assessment

| Task | Difficulty | Automation Potential |
|------|-----------|---------------------|
| Module inventory tables for READMEs | Easy | High (fully scriptable) |
| Missing docstring detection | Easy | High (grep-based) |
| Stale README detection (file list mismatch) | Medium | High (compare ls vs README table) |
| Broken link detection | Medium | High (check file existence for all relative links) |
| Axiom count verification | Medium | Medium (requires parsing inductive type) |
| Sorry count per-directory | Easy | High (grep + sort) |
| Cross-reference validation | Hard | Medium (requires import parsing) |

---

## 6. Cross-Link Structure (Import Dependency Graph)

### Directory-Level Dependencies

```
Syntax (Layer 0 - no external deps)
  ^
  |
ProofSystem (Layer 0 - imports Syntax)
  ^
  |
Semantics (Layer 1 - imports Syntax)
  ^
  |
Metalogic (Layer 2 - imports ProofSystem, Semantics, Syntax, Theorems, Automation)
  ^              \
  |               v
Theorems (Layer 3 - imports ProofSystem, Syntax, Metalogic/Core)
  ^
  |
Automation (Layer 3 - imports ProofSystem, Semantics, Syntax, Theorems)
  |
  v
Examples (Layer 4 - imports Automation, ProofSystem, Semantics, Theorems)

FrameConditions (Layer 2 - imports ProofSystem, Semantics, Metalogic)
```

### Notable Cross-Dependencies

1. **Theorems imports Metalogic/Core**: For the deduction theorem (needed by propositional theorems)
2. **Metalogic imports Theorems**: For combinator lemmas used in completeness proofs
3. **Metalogic imports Automation**: Some metalogic files use automation tactics
4. **FrameConditions imports Metalogic**: For soundness results per frame class

### README Cross-Link Recommendations

Each README should link to:
- Its direct dependents (who imports from this directory)
- Its direct dependencies (what this directory imports)
- The parent directory README
- Sibling directories at the same layer

---

## 7. Specific Issues Found

### Broken File References (in READMEs)

| README | Reference | Status |
|--------|-----------|--------|
| Root | `Examples/Demo.lean` | Does not exist |
| Root | `LogicVariants.lean` | Does not exist |
| Root | `Metalogic/BaseCompleteness.lean` | Does not exist |
| Metalogic | `Bundle/TruthLemma.lean` | Does not exist |
| Metalogic | `Bundle/BFMCSTruth.lean` | Does not exist |
| Metalogic | `Bundle/Completeness.lean` | Does not exist |
| Decidability | `../Soundness/README.md` | Directory doesn't exist (file is at `../Soundness.lean`) |
| Semantics | `../Metalogic/Soundness/README.md` | Directory doesn't exist |

### Outdated Counts

| README | Claim | Reality |
|--------|-------|---------|
| Root | "21 axiom schemata" | 40 constructors in Axiom inductive |
| ProofSystem | "15 TM axiom schemas" | 40 constructors |
| Metalogic | "All 15 TM axioms" | 40 constructors |
| Root | "7 inference rules" | Needs verification against current DerivationTree |

### Missing File Entries in READMEs

| README | Missing File |
|--------|-------------|
| Syntax | `BigConj.lean` |
| ProofSystem | `Substitution.lean` |
| Theorems | `TemporalDerived.lean` (present), lists non-existent `Discreteness.lean` |
| Decidability | Entire `FMP/` subdirectory (7 files) |

---

## 8. Recommendations for Implementation

### Priority 1: Fix Severely Stale READMEs
1. **ProofSystem/README.md** — Rewrite with correct 40-axiom count, add Substitution.lean
2. **Root README** — Fix axiom counts, remove Demo.lean/LogicVariants.lean references, fix BaseCompleteness.lean reference

### Priority 2: Create Missing READMEs
1. **WeakCanonical/** (17 files, active development)
2. **BXCanonical/** (7 files + 3 subdirectories)
3. **FrameConditions/** (4 files, new module)
4. **Decidability/FMP/** (7 files)

### Priority 3: Fix Broken Links and Stale Entries
1. Remove references to non-existent files in Metalogic README flowchart
2. Fix Soundness directory references (it's a file, not a directory)
3. Update file listings in Syntax, Theorems, Decidability READMEs

### Priority 4: Standardize Format
1. Adopt consistent README template across all directories
2. Consider script-generated module inventory tables (refreshable)
3. Add "Last verified" dates and verification commands to all READMEs

### Script Infrastructure
- **`scripts/readme-inventory.sh`**: Generate module tables for any directory
- **`scripts/readme-lint.sh`**: Check broken links, missing files, outdated counts
- **`scripts/docstring-coverage.sh`**: Report on module and API docstring coverage

---

## Appendix: File Counts by Directory

| Directory | .lean Files | Has README | Sorry Files |
|-----------|------------|------------|-------------|
| Syntax/ | 6 | Yes | 0 |
| ProofSystem/ | 4 | Yes | 0 |
| Semantics/ | 5 | Yes | 0 |
| Automation/ | 4 | Yes | 0 |
| Examples/ | 2 | Yes | 0 |
| FrameConditions/ | 4 | **No** | 0 |
| Theorems/ | 7 (+3 in Perpetuity) | Yes | 3 |
| Metalogic/Core/ | 5 | Yes | 0 |
| Metalogic/Bundle/ | 14 | Yes | 6 |
| Metalogic/Decidability/ | 8 (+7 in FMP) | Yes (partial) | 0 |
| Metalogic/Algebraic/ | 11 | Yes | 0 |
| Metalogic/BXCanonical/ | 7 (+13 in subdirs) | **No** | 5 |
| Metalogic/WeakCanonical/ | 17 (+13 in Separation) | **No** | 6 |
| Metalogic/ConservativeExtension/ | 4 | Yes | 0 |
| Metalogic/Relational/ | 0 | Yes (placeholder) | 0 |
| **Total** | **152** | **16 of 24** | **35 files** |
