# Research Report: Strengthen sorry-debt-policy language and guidance

- **Task**: 831 - strengthen_sorry_debt_policy_language
- **Started**: 2026-02-03T12:00:00Z
- **Completed**: 2026-02-03T12:30:00Z
- **Effort**: 30 minutes
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/context/project/lean4/standards/sorry-debt-policy.md`
  - `.claude/agents/lean-research-agent.md`
  - `.claude/agents/lean-implementation-agent.md`
  - `.claude/rules/lean4.md`
  - `.claude/context/project/logic/processes/verification-workflow.md`
  - `specs/archive/` (20+ reports/plans sampled)
- **Artifacts**: specs/831_strengthen_sorry_debt_policy_language/reports/research-001.md
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- Found 2 instances of "acceptable" language in sorry-debt-policy.md requiring replacement
- Identified 20+ files in specs/archive using "acceptable sorry" patterns in reports/plans
- Verification-workflow.md contains problematic "acceptable if" language (line 320)
- Current policy lacks explicit guidance on transitive inheritance in reports/plans
- Proposed new category name: "Tolerated During Development (Technical Debt)"
- New section needed: "How to Characterize Sorries in Reports and Plans"

## Context & Scope

Task 831 requires revising sorry-debt-policy.md to:
1. Eliminate "acceptable sorry" language
2. Add clear guidance on transitive inheritance
3. Replace "Acceptable for Development" category with "Tolerated During Development (Technical Debt)"
4. Add framing guidance: "Document what exists, explain WHY it exists, specify the remediation path - never call a sorry acceptable"

## Findings

### 1. "Acceptable" Language in sorry-debt-policy.md

**Line 17**:
```markdown
- **Never acceptable in publication-ready proofs**
```
- **Analysis**: This usage is APPROPRIATE - it's prohibition language
- **Action**: Keep (or strengthen to "Never permitted")

**Line 34 (Category heading)**:
```markdown
### 1. Construction Assumptions (Acceptable for Development)
```
- **Analysis**: PROBLEMATIC - normalizes the word "acceptable" for sorries
- **Action**: Replace with "Tolerated During Development (Technical Debt)"

**Line 35**:
```markdown
Accepted as axiomatic within the current architecture.
```
- **Analysis**: PROBLEMATIC - uses "accepted" language
- **Action**: Replace with "Treated as axiomatic within the current architecture. THIS IS STILL DEBT."

### 2. Files Referencing sorry-debt-policy.md

Three files reference the policy directly:
1. `.claude/rules/lean4.md` (line 185) - reference only, no problematic language
2. `.claude/agents/lean-research-agent.md` (line 87) - reference only
3. `.claude/agents/lean-implementation-agent.md` (line 85) - reference only

### 3. "Acceptable sorry" Language in Other .claude/ Files

**verification-workflow.md (line 320)**:
```markdown
**Exception**: Documented `sorry` placeholders for future work are acceptable if:
- Clearly marked with comments
- Documented in SORRY_REGISTRY.md
- Have a resolution plan
```
- **Action**: Reframe as "tolerated during development if..." and add "but NEVER acceptable for publication"

### 4. Pattern Analysis: Archived Reports Using "Acceptable Sorry"

Sampled 20+ files from `specs/archive/`. Common problematic patterns:

| Pattern | Example | Occurrences |
|---------|---------|-------------|
| "acceptable sorry" | "1 sorry (modal_backward) - acceptable" | 15+ |
| "acceptable limitation" | "sorry is acceptable per research" | 10+ |
| "acceptable for publication" | "sorry state is acceptable for a publishable result" | 5+ |
| "<5 acceptable" | "0 ideal, <5 acceptable" | 3+ |
| "accepted as" | "accepted as axiomatic" | 5+ |

**Specific Examples Found**:

1. `specs/826_fdsm_completeness_saturated_construction/plans/implementation-001.md:237`:
   > "Total sorry count reduced from 27 to target (0 ideal, <5 acceptable)"

2. `specs/818_refactor_bimodal_metalogic_modules/reports/research-003.md:179`:
   > "1 modal sorry: construction assumption (acceptable or solvable via multi-family)"

3. `specs/archive/808_audit_coherentconstruction_taskrelation_sorries/reports/research-001.md:188`:
   > "The audit confirms that the current sorry state is acceptable for a publishable completeness result"

4. `specs/archive/808_audit_coherentconstruction_taskrelation_sorries/plans/implementation-001.md:29`:
   > "Document why each sorry is acceptable for publication"

### 5. Transitive Inheritance - Current Policy Gap

The current policy mentions transitive inheritance (lines 19-30) but:
- Does NOT provide guidance on how to characterize this in reports/plans
- Does NOT explicitly prohibit claiming theorems as "proven" when they depend on sorry
- Uses "Truly sorry-free" language that implies some sorries ARE acceptable

### 6. Proposed Text Changes

#### Change 1: Replace Category Heading (Line 34)

**BEFORE**:
```markdown
### 1. Construction Assumptions (Acceptable for Development)
Accepted as axiomatic within the current architecture. Example:
```

**AFTER**:
```markdown
### 1. Construction Assumptions (Tolerated During Development - Technical Debt)
Treated as axiomatic within the current architecture. **This is still mathematical debt that must be documented and tracked.** Example:
```

#### Change 2: Add New Section After Line 31 (Before "## Sorry Categories")

**NEW SECTION**:
```markdown
## Characterizing Sorries in Reports and Plans

When documenting sorries in research reports, implementation plans, or summaries, follow this framing:

**Guiding Principle**: Document what exists, explain WHY it exists, specify the remediation path - never call a sorry acceptable.

### Required Elements

1. **State the fact**: "This file contains N sorries"
2. **Categorize each**: Which category from the taxonomy below
3. **Explain the reason**: Why does this sorry exist
4. **Specify remediation**: What would remove it (even if not planned)
5. **Note transitivity**: What depends on this sorry

### Prohibited Framing

Do NOT use these phrases:
- "acceptable sorry" / "sorry is acceptable"
- "acceptable limitation"
- "sorry is fine" / "okay to have sorry"
- "sorry count is acceptable"
- "<N sorries acceptable"

### Required Framing

USE these phrases instead:
- "tolerated during development"
- "technical debt requiring documentation"
- "blocks publication if not resolved"
- "inherited by all dependents"

### Example Transformations

| Prohibited | Required |
|------------|----------|
| "1 sorry is acceptable" | "1 sorry remains (construction assumption) - documented, blocks transitive sorry-freedom" |
| "sorry state acceptable for publication" | "publication requires resolving all N sorries or documenting as explicit axioms" |
| "<5 acceptable" | "target: 0 sorries; current: N sorries (categorized in SORRY_REGISTRY.md)" |
| "acceptable architectural limitation" | "documented architectural debt - remediation path: [specific approach]" |

### Transitive Inheritance in Reports

ALL sorries propagate transitively through imports. When reporting on a theorem:

1. **Direct sorries**: Sorries in the theorem's proof
2. **Inherited sorries**: Sorries in any lemma the theorem uses
3. **Publication status**: "Transitively sorry-free" or "Depends on N sorries in [files]"

**Critical**: A theorem claimed as "proven" in a publication MUST be transitively sorry-free.
```

#### Change 3: Strengthen Transitive Section (Lines 19-30)

**BEFORE**:
```markdown
### Transitive Sorry Inheritance

A proof is only as sound as its dependencies. If theorem A uses lemma B which contains `sorry`, then A is also unproven.

**Truly sorry-free** means: the theorem AND all its transitive dependencies contain no sorries.

```lean
-- Check transitive sorry-freedom with:
#check @MyTheorem  -- Hover shows axioms used; sorry appears as axiom
```

**Publication requirement**: All theorems claimed as proven must be transitively sorry-free.
```

**AFTER**:
```markdown
### Transitive Sorry Inheritance

Sorries propagate through the dependency graph. If theorem A uses lemma B which contains `sorry`, then:
- A is **also unproven** (mathematically)
- A **inherits** B's mathematical debt
- Any claim about A must acknowledge B's sorry

**Transitively sorry-free** means: the theorem AND all its transitive dependencies contain no sorries. This is the ONLY valid state for publication.

```lean
-- Check transitive sorry-freedom with:
#check @MyTheorem  -- Hover shows axioms used; sorry appears as axiom
```

**Publication requirement**: All theorems claimed as proven must be transitively sorry-free. NO EXCEPTIONS.

**Reporting requirement**: When a sorry exists anywhere in the dependency chain, reports and plans must:
1. Identify all sorries (direct and inherited)
2. Document why each exists
3. Specify the remediation path
4. Note impact on dependent theorems
```

#### Change 4: Update verification-workflow.md (Line 320)

**BEFORE**:
```markdown
**Exception**: Documented `sorry` placeholders for future work are acceptable if:
- Clearly marked with comments
- Documented in SORRY_REGISTRY.md
- Have a resolution plan
```

**AFTER**:
```markdown
**Development tolerance**: Documented `sorry` placeholders may be tolerated during development if:
- Clearly marked with comments explaining WHY the sorry exists
- Documented in SORRY_REGISTRY.md with category and remediation path
- Have a concrete resolution plan

**Critical**: These sorries are NEVER acceptable for publication. They represent mathematical debt that blocks any downstream theorems from being claimed as proven.
```

## Decisions

1. **Keep "Never acceptable"**: The phrase "Never acceptable in publication-ready proofs" (line 17) uses "acceptable" in the correct prohibitive sense
2. **Replace category name**: "Acceptable for Development" -> "Tolerated During Development (Technical Debt)"
3. **Add characterization section**: New guidance section before Sorry Categories
4. **Strengthen transitive section**: More explicit about inheritance and reporting requirements
5. **Fix verification-workflow.md**: Remove "acceptable if" language

## Recommendations

### Priority 1: Update sorry-debt-policy.md

1. Replace "Acceptable for Development" with "Tolerated During Development (Technical Debt)"
2. Add "## Characterizing Sorries in Reports and Plans" section
3. Strengthen transitive inheritance section
4. Update category 1 description to emphasize debt, not acceptance

### Priority 2: Update verification-workflow.md

1. Replace "acceptable if" with "tolerated during development if"
2. Add "NEVER acceptable for publication" clarification

### Priority 3: Future Consideration (Not In Scope)

The archived reports/plans cannot be retroactively fixed, but the updated policy will guide future reports. Consider:
- Adding a linter rule to flag "acceptable sorry" in new artifacts
- Template updates to include proper sorry characterization prompts

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| New guidance too verbose | Keep new section focused; use tables for examples |
| Agents ignore new guidance | Reference policy from agent files (already done) |
| Legacy reports cause confusion | Policy applies forward-only; archives are historical |

## Appendix

### Files Analyzed

**Primary**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - full analysis
- `.claude/context/project/logic/processes/verification-workflow.md` - line 320

**Secondary (references)**:
- `.claude/rules/lean4.md`
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/lean-implementation-agent.md`

**Pattern sampling**:
- 20+ files in `specs/archive/` containing "acceptable sorry" patterns
- `specs/826_fdsm_completeness_saturated_construction/` (active task)
- `specs/818_refactor_bimodal_metalogic_modules/` (active task)

### Search Queries Used

```bash
# Find policy references
grep -r "sorry-debt-policy" .claude/

# Find "acceptable" patterns in .claude/
grep -ri "acceptable" .claude/ | grep -v ".md.backup"

# Find "acceptable sorry" patterns in specs/
grep -ri "acceptable.*sorry\|sorry.*acceptable" specs/
```
