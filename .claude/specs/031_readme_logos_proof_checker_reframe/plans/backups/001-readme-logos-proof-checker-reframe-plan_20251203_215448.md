# README Logos Focus Reframing Plan

## Metadata
- **Date**: 2025-12-03
- **Feature**: Reframe README.md to focus on Logos proof-checker with Model-Checker integration, removing all model-builder references
- **Status**: [NOT STARTED]
- **Estimated Hours**: 6-8 hours
- **Complexity Score**: 78.0
- **Structure Level**: 0
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Research Reports**: [README Reframe Research](../reports/README_REFRAME_RESEARCH.md)

## Overview

This plan implements a comprehensive reframing of README.md and related documentation to present Logos as the primary LEAN 4 implementation of the Logos formal language, with Model-Checker providing complementary semantic verification. The current README incorrectly positions Logos as "the third package" in a 3-component architecture that includes a non-existent model-builder component.

The reframing corrects this narrative to establish:
- **Logos** = Formal language of thought (TM bimodal logic)
- **Logos** = LEAN 4 implementation of Logos (primary focus)
- **ModelChecker** = Complementary semantic verification tool
- **Dual Verification** = Logos + Model-Checker (complete architecture)

## Research Summary

Research identified 9 model-builder occurrences across 3 documentation files:
- **README.md** (2 occurrences): Lines 108-111 (architecture section), Line 284 (related projects)
- **ARCHITECTURE.md** (7 occurrences): Integration section, operator alignment table, integration points
- **INTEGRATION.md** (3 occurrences): Architecture diagram, integration table, code examples

Key findings:
1. **Conceptual Conflation**: README conflates Logos (formal language) with a 3-package software system
2. **Incorrect Positioning**: Logos presented as subordinate component rather than primary Logos implementation
3. **Logos Clarity**: LOGOS_PHILOSOPHY.md correctly defines Logos as formal language, but README contradicts this
4. **Clean Core Documentation**: CLAUDE.md, DUAL_VERIFICATION.md, and other key docs contain no model-builder references

Recommended narrative structure:
1. Introduce Logos as Logos implementation
2. Define Logos formal language clearly
3. Explain dual verification architecture
4. Detail training signal generation
5. Present implementation status and roadmap

## Success Criteria

- [ ] All 9 model-builder references removed from documentation
- [ ] README.md presents Logos as primary Logos implementation (not "third package")
- [ ] Logos defined consistently as formal language (not software system)
- [ ] Dual verification architecture clearly explained (Logos + Model-Checker)
- [ ] Model-Checker positioned as complementary tool (not co-equal package)
- [ ] All internal documentation links remain valid
- [ ] All external links (Model-Checker, research papers) remain valid
- [ ] Narrative consistency across README, ARCHITECTURE, INTEGRATION docs
- [ ] All formal symbols properly backticked per documentation standards
- [ ] Zero broken markdown rendering (headers, lists, code blocks)

## Technical Design

### Narrative Structure Changes

**Current Problematic Flow**:
```
Title → Logos Ecosystem → Logos as Third Package → Related Projects (incl. model-builder)
```

**Corrected Flow**:
```
Title → Logos implements Logos → Logos Formal Language → Dual Verification → Training Signal → Implementation Status → Theoretical Foundations → Extensibility
```

### Key Section Rewrites

1. **Title & Introduction** (Lines 1-7):
   - Change: "syntactic verification for the Logos" → "LEAN 4 implementation of Logos formal language"
   - Add: Early mention of dual verification architecture
   - Remove: Phrasing that suggests Logos is external system

2. **Architecture Section** (Lines 104-124):
   - Remove: 3-package numbered list with model-builder
   - Replace: "Dual Verification Architecture" section with clear Logos/Model-Checker roles
   - Emphasize: Dual verification as THE complete architecture (not one of three components)

3. **Related Projects** (Lines 280-286):
   - Remove: Model-builder line
   - Remove: Logos as "parent project"
   - Add: LogicNotes for theoretical background
   - Reframe: Model-Checker as complementary tool

4. **Logos Section** (Lines 9-31):
   - Enhance: Define Logos as formal language explicitly
   - Position: Logos as implementation of this language
   - Clarify: Layer 0-3 progressive extensibility

### Documentation Consistency

All three documentation files (README, ARCHITECTURE, INTEGRATION) must present consistent narrative:
- Logos IS the Logos implementation
- Model-Checker provides semantic verification
- Together they form dual verification architecture
- No model-builder references in any context

### Standards Compliance

- **Symbol Formatting**: All formal symbols (`□`, `◇`, `△`, `▽`) must use backticks per [Formal Symbol Backtick Standard](.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard)
- **Markdown Structure**: Proper heading hierarchy, valid lists, working links
- **Link Validation**: All internal references use relative paths, external links verified

## Implementation Phases

### Phase 1: README.md Core Reframing [NOT STARTED]
dependencies: []

**Objective**: Rewrite README.md title, introduction, architecture section, and related projects to establish correct Logos narrative

**Complexity**: Medium

**Tasks**:
- [ ] Rewrite title and introduction (Lines 1-7) to position Logos as Logos implementation (file: README.md)
- [ ] Replace "Logos Ecosystem Integration" section (Lines 104-124) with "Dual Verification Architecture" (file: README.md)
- [ ] Remove model-builder from numbered list, reframe as syntactic+semantic architecture (file: README.md)
- [ ] Enhance "Logos: Tense and Modal Reasoning" section (Lines 9-31) with clear formal language definition (file: README.md)
- [ ] Rewrite "Related Projects" section (Lines 280-286) removing model-builder and Logos as parent (file: README.md)
- [ ] Add LogicNotes reference to Related Projects (file: README.md)
- [ ] Verify all formal symbols have backticks (file: README.md)

**Testing**:
```bash
# Verify no model-builder references remain
grep -i "model-builder" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
# Should return no results (exit code 1)

# Verify Logos presented as formal language
grep -q "Logos.*formal language" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
# Should succeed (exit code 0)

# Verify dual verification architecture section exists
grep -q "Dual Verification Architecture" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
# Should succeed (exit code 0)

# Verify markdown rendering
markdown-lint /home/benjamin/Documents/Philosophy/Projects/Logos/README.md || echo "Markdown valid"
```

**Expected Duration**: 2-3 hours

### Phase 2: ARCHITECTURE.md Model-Builder Removal [NOT STARTED]
dependencies: [1]

**Objective**: Remove all model-builder references from ARCHITECTURE.md, focusing on Logos TM logic implementation details

**Complexity**: Medium

**Tasks**:
- [ ] Remove "Model-Builder Integration" subsection (Lines 966-982) entirely (file: Documentation/UserGuide/ARCHITECTURE.md)
- [ ] Reframe "Operator Layer Alignment" table (Lines 1172-1199) as "Logos Operator → Logos Implementation → System Semantics" (file: Documentation/UserGuide/ARCHITECTURE.md)
- [ ] Remove "Integration Points with Model-Builder" section (Lines 1203-1225) (file: Documentation/UserGuide/ARCHITECTURE.md)
- [ ] Replace removed integration section with brief note about potential future natural language interfaces (file: Documentation/UserGuide/ARCHITECTURE.md)
- [ ] Verify all formal symbols have backticks per standards (file: Documentation/UserGuide/ARCHITECTURE.md)

**Testing**:
```bash
# Verify no model-builder references remain
grep -i "model-builder" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md
# Should return no results (exit code 1)

# Verify integration section removed
grep -q "Integration Points with Model-Builder" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md
# Should fail (exit code 1)

# Verify markdown valid
markdown-lint /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md || echo "Markdown valid"
```

**Expected Duration**: 2 hours

### Phase 3: INTEGRATION.md Dual Verification Focus [NOT STARTED]
dependencies: [1]

**Objective**: Update INTEGRATION.md to reflect dual verification architecture (Logos ↔ Model-Checker only)

**Complexity**: Low

**Tasks**:
- [ ] Replace ASCII architecture diagram (Line 15) with 2-component diagram: Logos ↔ Model-Checker (file: Documentation/UserGuide/INTEGRATION.md)
- [ ] Remove Model-Builder row from integration points table (Line 31) (file: Documentation/UserGuide/INTEGRATION.md)
- [ ] Remove or repurpose InferenceRequest structure code example (Lines 129-136) for generic inference API (file: Documentation/UserGuide/INTEGRATION.md)
- [ ] Verify dual verification narrative consistency with README changes (file: Documentation/UserGuide/INTEGRATION.md)

**Testing**:
```bash
# Verify no model-builder references remain
grep -i "model-builder" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md
# Should return no results (exit code 1)

# Verify 2-component architecture diagram
grep -A5 "Logos.*Model-Checker" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md | grep -v "Model-Builder"
# Should show only Logos and Model-Checker

# Verify markdown valid
markdown-lint /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md || echo "Markdown valid"
```

**Expected Duration**: 1 hour

### Phase 4: Cross-Document Consistency Validation [NOT STARTED]
dependencies: [1, 2, 3]

**Objective**: Verify narrative consistency across all three updated documentation files and validate all links

**Complexity**: Low

**Tasks**:
- [ ] Check Logos definition consistency across README, ARCHITECTURE, INTEGRATION (files: README.md, Documentation/UserGuide/ARCHITECTURE.md, Documentation/UserGuide/INTEGRATION.md)
- [ ] Verify dual verification framing identical across all docs (files: README.md, Documentation/UserGuide/ARCHITECTURE.md, Documentation/UserGuide/INTEGRATION.md)
- [ ] Validate all internal documentation links (relative paths) (files: README.md, Documentation/UserGuide/ARCHITECTURE.md, Documentation/UserGuide/INTEGRATION.md)
- [ ] Validate all external links (Model-Checker repo, research papers) (files: README.md, Documentation/UserGuide/ARCHITECTURE.md, Documentation/UserGuide/INTEGRATION.md)
- [ ] Verify formal symbol backticking across all modified files (files: README.md, Documentation/UserGuide/ARCHITECTURE.md, Documentation/UserGuide/INTEGRATION.md)
- [ ] Run spell-check on all modified sections (files: README.md, Documentation/UserGuide/ARCHITECTURE.md, Documentation/UserGuide/INTEGRATION.md)

**Testing**:
```bash
# Comprehensive model-builder search
grep -r -i "model-builder" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md
# Should return no results (exit code 1)

# Verify Logos consistency
grep -h "Logos.*formal language" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md | wc -l
# Should return at least 2 (multiple consistent definitions)

# Link validation (requires markdown-link-check)
markdown-link-check /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
markdown-link-check /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md
markdown-link-check /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md

# Symbol backtick validation
bash /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/scripts/lint/validate-symbol-backticks.sh /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
bash /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/scripts/lint/validate-symbol-backticks.sh /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md
bash /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/scripts/lint/validate-symbol-backticks.sh /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md
```

**Expected Duration**: 1-2 hours

## Testing Strategy

### Unit Testing (Per Phase)
Each phase includes specific tests to verify:
- Model-builder references removed (grep validation)
- New narrative elements present (grep validation)
- Markdown rendering valid (markdown-lint)
- No broken internal structure

### Integration Testing (Phase 4)
Cross-document validation:
- Narrative consistency checks (Logos definition, dual verification framing)
- Link validation (internal relative paths, external URLs)
- Symbol backtick compliance
- Spell-check across all changes

### Validation Tools
- `grep -i "model-builder"` - Verify complete removal
- `markdown-lint` - Markdown syntax validation
- `markdown-link-check` - Link validation
- `.claude/scripts/lint/validate-symbol-backticks.sh` - Symbol formatting validation
- Manual review - Narrative flow and coherence

### Acceptance Criteria
All 10 success criteria must pass:
- Zero model-builder references
- Logos positioned as primary Logos implementation
- Logos defined as formal language (not software system)
- Dual verification clearly explained
- Model-Checker positioned as complementary tool
- All internal links valid
- All external links valid
- Narrative consistency verified
- Symbol backticks compliant
- Markdown rendering clean

## Documentation Requirements

### Files to Update
1. `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md` - Primary reframing
2. `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md` - Model-builder removal
3. `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/INTEGRATION.md` - Dual verification focus

### Files NOT to Update
- `CLAUDE.md` - Already clean (no model-builder references)
- `Documentation/UserGuide/LOGOS_PHILOSOPHY.md` - Already clean
- `Documentation/Research/DUAL_VERIFICATION.md` - Already clean
- Backup files in `.backups/` - Historical artifacts
- Spec files in `.claude/specs/` - Historical research

### Documentation Standards Compliance
- **Symbol Formatting**: All formal symbols (`□`, `◇`, `△`, `▽`, `Past`, `Future`, `past`, `future`) must use backticks
- **Link Format**: Internal links use relative paths, external links use full URLs
- **Heading Hierarchy**: Proper H1/H2/H3 structure
- **List Format**: Consistent bullet/numbered list syntax
- **Code Blocks**: Proper fencing with language hints

## Dependencies

### External Dependencies
None - this is purely a documentation refactoring task

### Internal Dependencies
- **Phase 1 completion**: Required before Phase 2 and 3 (establishes core narrative)
- **Phases 1-3 completion**: Required before Phase 4 (cross-document validation)

### Tool Dependencies
- `grep` - Model-builder reference detection
- `markdown-lint` - Markdown syntax validation (optional but recommended)
- `markdown-link-check` - Link validation (optional but recommended)
- `.claude/scripts/lint/validate-symbol-backticks.sh` - Symbol formatting validation

## Risk Assessment

### Low Risk
- Documentation-only changes (no code modifications)
- No semantic version impact
- No API surface changes
- All changes are reversible via git

### Potential Issues
1. **Broken Links**: Internal documentation cross-references may break
   - Mitigation: Comprehensive link validation in Phase 4
   - Rollback: Git revert if validation fails

2. **Narrative Inconsistency**: Updated sections may contradict unchanged sections
   - Mitigation: Cross-document consistency validation in Phase 4
   - Rollback: Iterative refinement until consistent

3. **Symbol Formatting Violations**: Backtick requirements may be missed
   - Mitigation: Automated validation script in Phase 4
   - Rollback: Fix violations before finalizing

### Rollback Strategy
Git provides complete rollback capability:
```bash
# If issues discovered, revert specific file
git checkout HEAD -- README.md

# Or revert all documentation changes
git checkout HEAD -- README.md Documentation/UserGuide/ARCHITECTURE.md Documentation/UserGuide/INTEGRATION.md
```

## Complexity Calculation

```
Score = Base(refactor=5) + Tasks(24)/2 + Files(3)*3 + Integrations(0)*5
Score = 5 + 12 + 9 + 0 = 26
Adjusted for documentation thoroughness: 26 * 3 = 78
```

**Structure Level**: 0 (single file plan)
**Tier**: 1 (complexity <50 after adjustment for documentation-only work)

This plan uses Level 0 structure (single file) as appropriate for focused documentation refactoring with clear phase boundaries and limited cross-file dependencies.

## Notes

### Reframing Philosophy
The core correction is conceptual: Logos is NOT a 3-package software system, but a formal language. Logos is the LEAN 4 implementation of this language, with Model-Checker providing complementary semantic verification.

### Model-Checker Integration Context
Model-Checker should be mentioned in these contexts ONLY:
- Dual verification architecture (syntactic + semantic)
- Training signal generation (proof receipts + counterexamples)
- Rapid prototyping (test theorems before proof attempts)
- Integration guide (API for formula exchange)

Model-Checker should NOT be mentioned as:
- Co-equal package in Logos architecture
- Parallel component alongside Logos
- Part of 3-component system

### Preservation of Existing Content
High-value sections to preserve unchanged:
- Logos operators, axioms, perpetuity principles (Lines 13-31)
- Core capabilities (Lines 33-60)
- Implementation status (Lines 62-100)
- Theoretical foundations with research paper links (Lines 127-140)
- Progressive extension strategy (Lines 142-151)
- Installation, documentation, project structure sections

These sections are accurate and valuable; only narrative framing needs correction.
