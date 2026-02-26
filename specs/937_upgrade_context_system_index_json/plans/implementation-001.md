# Implementation Plan: Task #937

- **Task**: 937 - Upgrade context system with index.json
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/937_upgrade_context_system_index_json/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a machine-readable context index system (index.json) with load_when conditions for dynamic context discovery. This replaces static @-reference lists in agent files with jq-based queries, enabling intelligent context loading based on language, operation, tier, and agent type. The system includes a generation script for populating entries, a validation script for integrity checks, and comprehensive query documentation.

### Research Integration

Key findings from research-001.md:
- Theory repository's index.json schema provides proven patterns for load_when conditions
- 147 context files in ProofChecker ready for indexing
- jq query patterns documented with known anti-patterns (Issue #1132 escaping)
- Generation script recommended for initial population and updates

## Goals & Non-Goals

**Goals**:
- Create index.json with embedded JSON Schema for self-documentation
- Generate entries for all 147 context files with load_when conditions
- Create generation script for automated index population and updates
- Create validation script for integrity verification
- Update agent files to use dynamic context discovery via jq queries
- Create index-query.md utility documentation

**Non-Goals**:
- Removing existing index.md human-readable index (keep for backward compatibility)
- Changing context file organization or subdomain structure
- Creating new agent types or modifying agent routing logic

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Manual entry curation is time-consuming | M | H | Create generation script with sensible defaults based on file paths |
| load_when conditions incorrectly assigned | M | M | Validate with sample queries; review in Phase 3 |
| jq escaping issues (Claude Code bug #1132) | L | H | Document workarounds in index-query.md |
| Orphaned files not in index | L | M | Validation script checks for unindexed files |
| Agents don't adopt new pattern | M | L | Update all agent files systematically in Phase 5 |

## Implementation Phases

### Phase 1: Create index.json Schema and Structure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Establish the index.json file with embedded JSON Schema and empty entries array

**Tasks**:
- [ ] Create `.claude/context/index.json` with JSON Schema header
- [ ] Include schema definitions for entry and load_conditions
- [ ] Set version "1.0.0" and generated_at timestamp
- [ ] Set file_count to 0 and entries to empty array
- [ ] Validate schema structure is syntactically correct

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/index.json` - Create new file with schema

**Verification**:
- `jq '.' .claude/context/index.json` succeeds (valid JSON)
- Schema definitions include entry and load_conditions
- Version field present and valid

---

### Phase 2: Create Generation Script [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Create script that scans context files and generates index entries

**Tasks**:
- [ ] Create `.claude/scripts/generate-context-index.sh`
- [ ] Implement file scanning for `.claude/context/**/*.md`
- [ ] Extract domain from path (core/project)
- [ ] Extract subdomain and category from path components
- [ ] Generate topics from filename and directory
- [ ] Generate summary from first paragraph or heading
- [ ] Count lines via `wc -l` for line_count field
- [ ] Assign default load_when based on subdomain patterns:
  - `lean4/*` -> languages: ["lean"]
  - `logic/*` -> languages: ["logic", "lean"]
  - `core/*` -> operations: ["any"], tiers: ["orchestrator", "command"]
- [ ] Output complete index.json with all entries
- [ ] Handle edge cases (missing summaries, special characters)

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/scripts/generate-context-index.sh` - Create new file

**Verification**:
- Script runs without errors
- Generated index.json contains ~147 entries
- Each entry has required fields (path, domain, subdomain, topics, summary, load_when)
- line_count values are positive integers

---

### Phase 3: Curate load_when Conditions [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Review and refine load_when conditions for accuracy and specificity

**Tasks**:
- [ ] Run generation script to create initial index.json
- [ ] Review entries in `core/patterns/` - assign specific agents
- [ ] Review entries in `core/workflows/` - assign operations
- [ ] Review entries in `project/lean4/` - assign lean-specific agents
- [ ] Review entries in `project/logic/` - assign cross-domain languages
- [ ] Add `conditions` field for situational files (e.g., "when proof stuck")
- [ ] Mark any deprecated files with `deprecated: true`
- [ ] Verify no duplicate paths exist
- [ ] Test sample jq queries against curated entries:
  - Find all lean-research-agent files
  - Find all implementation operation files
  - Find files under 200 lines

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/context/index.json` - Update entries with curated load_when

**Verification**:
- `jq '.entries | length' .claude/context/index.json` returns ~147
- Sample queries return expected results
- No entries with empty load_when objects

---

### Phase 4: Create Validation Script and Documentation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Create validation script and index-query.md utility documentation

**Tasks**:
- [ ] Create `.claude/scripts/validate-context-index.sh`
- [ ] Implement JSON Schema validation (using jq or external tool)
- [ ] Verify all entry paths exist on disk
- [ ] Check for duplicate paths in entries
- [ ] Report orphaned files not in index
- [ ] Report deprecated entries
- [ ] Create `.claude/context/core/utils/index-query.md` with:
  - Quick reference table of common queries
  - Field reference with types and constraints
  - 10+ named query patterns with examples
  - Anti-patterns section (jq escaping issues, optional field handling)
  - Compound query examples

**Timing**: 1 hour

**Files to modify**:
- `.claude/scripts/validate-context-index.sh` - Create new file
- `.claude/context/core/utils/index-query.md` - Create new file

**Verification**:
- Validation script runs without errors
- No orphaned files reported (all context files in index)
- No duplicate paths detected
- index-query.md contains comprehensive query documentation

---

### Phase 5: Update Agent Files [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Replace static @-reference lists with dynamic discovery in all agent files

**Tasks**:
- [ ] Update `.claude/agents/lean-research-agent.md`:
  - Add "Dynamic Context Discovery" section with jq query examples
  - Replace static @-reference lists with query patterns
  - Keep "Critical Files" for always-loaded context
- [ ] Update `.claude/agents/lean-implementation-agent.md` similarly
- [ ] Update `.claude/agents/general-research-agent.md` similarly
- [ ] Update `.claude/agents/general-implementation-agent.md` similarly
- [ ] Update `.claude/agents/planner-agent.md` similarly
- [ ] Review and update any other agent files found
- [ ] Update `.claude/CLAUDE.md` to reference index.json capability
- [ ] Update `.claude/context/index.md` to note machine-readable index.json

**Timing**: 1 hour

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add dynamic discovery
- `.claude/agents/lean-implementation-agent.md` - Add dynamic discovery
- `.claude/agents/general-research-agent.md` - Add dynamic discovery
- `.claude/agents/general-implementation-agent.md` - Add dynamic discovery
- `.claude/agents/planner-agent.md` - Add dynamic discovery
- `.claude/CLAUDE.md` - Reference new capability
- `.claude/context/index.md` - Note index.json companion

**Verification**:
- All agent files contain dynamic discovery section
- jq query examples in agent files execute correctly
- CLAUDE.md mentions index.json capability

---

## Testing & Validation

- [ ] `jq '.' .claude/context/index.json` succeeds (valid JSON)
- [ ] `jq '.entries | length' .claude/context/index.json` returns ~147
- [ ] `.claude/scripts/generate-context-index.sh` runs without errors
- [ ] `.claude/scripts/validate-context-index.sh` runs without errors and reports no issues
- [ ] Sample jq query: `jq -r '.entries[] | select(.load_when.agents[]? == "lean-research-agent") | .path' .claude/context/index.json` returns expected files
- [ ] Sample jq query: `jq -r '.entries[] | select(.line_count < 200) | .path' .claude/context/index.json` returns expected files
- [ ] All agent files updated with dynamic discovery sections
- [ ] No orphaned context files (all indexed)

## Artifacts & Outputs

- `.claude/context/index.json` - Machine-readable context index (~147 entries)
- `.claude/scripts/generate-context-index.sh` - Generation script
- `.claude/scripts/validate-context-index.sh` - Validation script
- `.claude/context/core/utils/index-query.md` - Query utility documentation
- Updated agent files with dynamic context discovery

## Rollback/Contingency

If implementation fails:
1. Delete `.claude/context/index.json` (agents fall back to static @-references)
2. Delete generation and validation scripts
3. Revert agent file changes via git
4. Existing `index.md` remains functional for human reference

The system is additive - existing static @-references continue to work, so partial implementation is safe.
