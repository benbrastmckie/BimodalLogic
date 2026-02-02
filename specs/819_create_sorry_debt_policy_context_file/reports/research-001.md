# Research Report: Task #819

**Task**: 819 - create_sorry_debt_policy_context_file
**Started**: 2026-02-02T23:28:40Z
**Completed**: 2026-02-02T23:45:00Z
**Effort**: 1-2 hours
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, existing context files, SORRY_REGISTRY.md
**Artifacts**: specs/819_create_sorry_debt_policy_context_file/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Project has established sorry tracking via SORRY_REGISTRY.md but lacks a formal policy context file for agents
- Two Boneyard locations exist with documented deprecation patterns: `Theories/Bimodal/Boneyard/` (versioned Metalogic approaches) and `Boneyard/` (root-level deprecated code)
- Current sorry count is ~317 across 49 files in active Theories/, with explicit exclusion of Boneyard and Examples in metrics
- Existing proof-conventions-lean.md has minimal sorry policy; new context file will expand to comprehensive guidance

## Context and Scope

The task requests creation of `.claude/context/project/lean4/standards/sorry-debt-policy.md` with:
1. Philosophy on sorries as mathematical debt
2. Remediation paths (Boneyard archival, refactoring, completion)
3. Discovery protocol for encountering existing sorries
4. References to project Boneyard locations

## Findings

### Codebase Patterns

#### Boneyard Structure and Usage

**Theories/Bimodal/Boneyard/** - Primary Boneyard location with comprehensive README:
- Contains versioned Metalogic approaches (v1 through v5) that were superseded
- Individual deprecated files: `SyntacticApproach.lean`, `DurationConstruction.lean`, `DeprecatedCompleteness.lean`, `TrivialFMP.lean`
- Subdirectories: `Compat/`, `Metalogic/`, `Metalogic_v2/`, `Metalogic_v3/`, `Metalogic_v4/`, `Metalogic_v5/`
- README.md (111 lines) documents:
  - Why each approach was deprecated (fundamental obstacles, not just implementation issues)
  - Key insights from failed approaches
  - Related task numbers for traceability
  - Clear "DO NOT USE" warning for active development

**Boneyard/** (root level):
- Contains `Metalogic_v4/` with `Completeness/`, `FMP/`, `Representation/` subdirectories
- Appears to be overflow from Theories/Bimodal/Boneyard/ for larger deprecated codebases

**Key Pattern**: Boneyard README documents *why* code was deprecated, preserving the learning. This is essential for avoiding repeated failed approaches.

#### Sorry Tracking Mechanisms

**SORRY_REGISTRY.md** (`docs/project-info/SORRY_REGISTRY.md`):
- Detailed tracking of active placeholders by file
- Resolution context with task numbers and dates
- Verification commands for counting sorries
- Update instructions for maintenance

**Repository Health Metrics** (state.json):
- `sorry_count` field tracks total occurrences
- Excludes `/Boneyard/` and `/Examples/` from counts
- Status classification: "good" (<100), "manageable" (<300), "concerning" (>=300)

**Current Counts** (from grep):
- 317 sorry occurrences across 49 files in Theories/
- Heavy concentration in metalogic completeness work (39 in Completeness.lean alone)
- Many are documented construction assumptions, not random gaps

#### Existing Sorry Policy References

**proof-conventions-lean.md** (lines 32-35):
```
### Sorry Policy (Lean)
- No `sorry` or `admit` in main; development branches must document registry links.
- If a temporary sorry is unavoidable during local work: add a docstring TODO and reference `docs/project-info/SORRY_REGISTRY.md`, then remove before merge.
```

**lean-implementation-agent.md** (line 207):
- Lists "Create empty or placeholder proofs (sorry, admit)" as prohibited action

**lake.md and skill-lake-repair**:
- Missing case repairs use `sorry` as temporary placeholders
- Documented as "fixes that compile but indicate incomplete work"

### Sorry Categories Discovered

Based on codebase analysis, sorries fall into distinct categories:

1. **Construction Assumptions**: Accepted as axiomatic for single-family approach (e.g., `modal_backward` in Construction.lean)
2. **Documentation Examples**: In Examples/ and ProofSearch.lean - intentional for demonstration
3. **Temporary Development**: Work-in-progress with clear resolution path
4. **Fundamental Obstacles**: Code that should move to Boneyard (mathematically impossible or wrong approach)

### Metrics Exclusion Patterns

The `/todo` command counts sorries with exclusions:
```bash
grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l
```

This pattern should be documented in the policy for consistency.

### External References

No web search performed as codebase patterns are comprehensive. The project has mature sorry-handling patterns that can be formalized into policy.

## Recommendations

### Policy Structure

The sorry-debt-policy.md should be organized as:

1. **Philosophy Section**
   - Sorries as mathematical debt (not technical debt)
   - Never acceptable in publication-ready proofs
   - Distinction from regular technical debt

2. **Sorry Categories**
   - Construction assumptions (documented, accepted)
   - Development placeholders (temporary, must resolve)
   - Documentation examples (intentional, excluded from counts)
   - Fundamental obstacles (candidates for Boneyard)

3. **Remediation Paths**
   - **Path A: Proof Completion** - Fill the gap with valid proof
   - **Path B: Architectural Refactoring** - Change approach to avoid the gap
   - **Path C: Boneyard Archival** - Archive fundamentally flawed code with documentation

4. **Discovery Protocol**
   - When encountering sorry during implementation:
     1. Check SORRY_REGISTRY.md for context
     2. Assess category (construction assumption vs fixable gap)
     3. If fixable: include in current task scope if related
     4. If construction assumption: document and continue
     5. If fundamental obstacle: flag for Boneyard archival

5. **Boneyard References**
   - Primary: `Theories/Bimodal/Boneyard/`
   - Overflow: `Boneyard/`
   - README requirements for archived code

6. **Metrics Integration**
   - How sorry_count is computed (exclusions)
   - Status thresholds
   - When to escalate

### Format Recommendations

Following existing context file patterns:
- Use same header structure as `proof-conventions-lean.md`
- Include cross-references to related files
- Provide concrete examples from codebase
- Keep under 200 lines for readability

## Decisions

1. **Scope**: Policy file focuses on Lean-specific sorry handling; general "debt" concepts remain in other docs
2. **Examples**: Use real examples from current codebase (Construction.lean, TruthLemma.lean)
3. **Integration**: Reference but do not duplicate SORRY_REGISTRY.md content
4. **Metrics**: Document the grep pattern used by /todo for consistency

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Policy conflicts with existing conventions | Medium | Cross-reference and align with proof-conventions-lean.md |
| Over-documentation of sorry handling | Low | Keep policy focused; reference external docs |
| Boneyard paths become stale | Low | Use relative paths; document pattern not specific directories |

## Appendix

### Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/README.md`
- `/home/benjamin/Projects/ProofChecker/docs/project-info/SORRY_REGISTRY.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/lean4/standards/proof-conventions-lean.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/lean4/standards/lean4-style-guide.md`
- `/home/benjamin/Projects/ProofChecker/.claude/rules/state-management.md`
- `/home/benjamin/Projects/ProofChecker/.claude/commands/todo.md`

### Search Queries Used

- `grep -r "sorry" Theories/ --include="*.lean"` - 317 matches
- `grep -r "Boneyard" .claude/` - References in metrics and commands
- `glob .claude/context/**/*.md` - 90+ context files for format reference

### Key Codebase Examples for Policy

**Construction Assumption (acceptable)**:
```lean
-- Theories/Bimodal/Metalogic/Bundle/Construction.lean:219-220
-- In the single-family simplification, we accept this as a sorry.
sorry
```

**Fundamental Obstacle (Boneyard candidate)**:
```lean
-- From Boneyard/README.md documentation
-- The `IsLocallyConsistent` definition only captures soundness, not negation-completeness
```

**Temporary Development (must resolve)**:
```lean
-- Active work in Metalogic/FMP/ConsistentSatisfiable.lean
-- Has clear resolution path via validity bridge
```

## Next Steps

Run `/plan 819` to create implementation plan based on this research.
