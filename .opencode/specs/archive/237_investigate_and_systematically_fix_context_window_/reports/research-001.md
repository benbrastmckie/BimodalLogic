# Research Report: Context Window Bloat in Workflow Commands

**Task**: 237  
**Created**: 2025-12-28  
**Status**: Research Complete  
**Researcher**: researcher  

---

## Executive Summary

Investigation reveals that workflow commands (/research, /plan, /revise, /implement) are loading approximately **206KB of context files in Stage 4** (after routing), but the command files themselves are being loaded during routing (Stages 1-3), causing the orchestrator's context window to jump to 58% before any actual work begins.

**Root Cause**: Command files (22-30KB each) are loaded during orchestrator routing, and these files contain embedded references to Stage 4 context loading that signal the intent to load an additional 206KB of context. The orchestrator is likely pre-loading or reserving context window space for the anticipated Stage 4 context load, resulting in 58% usage before delegation.

**Key Finding**: The architecture correctly defers context loading to Stage 4, but the command file size and embedded context references create routing-stage bloat.

**Recommended Fix**: Reduce command file sizes by 60-70% through aggressive deduplication and move all Stage 4 context references to a separate execution context file that is NOT loaded during routing.

---

## Research Questions Answered

### 1. At what stage is context being loaded?

**Answer**: Context is loaded at TWO stages:

**Routing Stage (Stages 1-3)**:
- Orchestrator loads command file (22-30KB)
- Orchestrator loads minimal context (55KB):
  - subagent-return-format.md (11KB)
  - subagent-delegation-guide.md (18KB)
  - status-markers.md (27KB)
- **Total routing context**: ~85KB + command file (22-30KB) = **107-115KB**

**Execution Stage (Stage 4)**:
- Command loads 7 context files (206KB total):
  - command-lifecycle.md (40KB)
  - TODO.md (109KB)
  - state.json (varies, typically <5KB)
  - status-markers.md (27KB)
  - subagent-return-format.md (11KB)
  - subagent-delegation-guide.md (18KB)
  - git-commits.md (2KB)
- **Total execution context**: **206KB**

**Combined Total**: 107-115KB (routing) + 206KB (execution) = **313-321KB**

### 2. Which context files are being loaded and how large are they?

**Orchestrator Context (Routing)**:
```
subagent-return-format.md:      11,098 bytes (11KB)
subagent-delegation-guide.md:   17,579 bytes (18KB)
status-markers.md:              26,763 bytes (27KB)
Total:                          55,440 bytes (55KB)
```

**Command Files (Routing)**:
```
research.md:   23KB
plan.md:       22KB
revise.md:     22KB
implement.md:  30KB
```

**Stage 4 Context Files (Execution)**:
```
command-lifecycle.md:           39,877 bytes (40KB)
TODO.md:                       109,312 bytes (109KB)
status-markers.md:              26,763 bytes (27KB)
subagent-return-format.md:      11,098 bytes (11KB)
subagent-delegation-guide.md:   17,579 bytes (18KB)
git-commits.md:                  1,974 bytes (2KB)
state.json:                     ~2-5KB (varies)
Total:                         ~206KB
```

**Duplication Analysis**:
- status-markers.md: Loaded TWICE (routing + execution)
- subagent-return-format.md: Loaded TWICE (routing + execution)
- subagent-delegation-guide.md: Loaded TWICE (routing + execution)
- **Duplicated context**: 55KB loaded twice = **55KB waste**

### 3. Is context being loaded speculatively before knowing which command will execute?

**Answer**: YES, partially.

The orchestrator loads the command file during routing to determine which agent to invoke. The command file contains:
1. Routing logic (Stages 1-3): ~30% of file
2. Execution logic (Stages 4-8): ~70% of file
3. Embedded Stage 4 context references

The orchestrator must load the entire command file (including execution logic) just to extract routing decisions, resulting in speculative loading of execution-related content.

**Evidence**:
- research.md: 648 lines, but only ~200 lines needed for routing
- plan.md: 623 lines, but only ~180 lines needed for routing
- implement.md: 773 lines, but only ~230 lines needed for routing

**Waste**: ~60-70% of command file content is execution-related but loaded during routing.

### 4. Are there duplicated context loads across agent boundaries?

**Answer**: YES, significant duplication.

**Duplication Pattern 1: Orchestrator → Command**
- Orchestrator loads: subagent-return-format.md, subagent-delegation-guide.md, status-markers.md (55KB)
- Command Stage 4 loads: Same 3 files again (55KB)
- **Duplication**: 55KB

**Duplication Pattern 2: Command File Content**
- All 4 workflow commands share 80-90% identical structure
- Stage 1-8 pattern is identical across commands
- Only variations are status markers, routing logic, timeouts
- **Duplication**: ~500 lines × 4 commands = 2,000 lines of duplicated lifecycle logic

**Duplication Pattern 3: Validation Logic**
- Each command duplicates validation logic for:
  - Return format validation
  - Artifact validation
  - Status update validation
  - Git commit validation
- **Duplication**: ~150 lines × 4 commands = 600 lines

**Total Duplication**: ~2,600 lines of duplicated content across command files

### 5. What is the minimal context needed for routing decisions vs execution?

**Routing Context (Stages 1-3)**:

**Minimal Required**:
- Task number extraction and validation (~20 lines)
- Language field extraction (~10 lines)
- Routing decision logic (~50 lines)
- Delegation context preparation (~30 lines)
- **Total**: ~110 lines (~3-4KB)

**Currently Loaded**:
- Entire command file: 22-30KB (648-773 lines)
- Orchestrator context: 55KB
- **Total**: 77-85KB

**Waste**: 73-81KB loaded unnecessarily during routing (96% waste)

**Execution Context (Stage 4+)**:

**Required**:
- Full command lifecycle (Stages 4-8): ~400 lines
- Stage 4 context files: 206KB
- **Total**: ~220KB

**Optimal Split**:
- Routing file: 3-4KB (lightweight, fast)
- Execution file: 220KB (comprehensive, full context)
- **Total**: 223-224KB (vs current 313-321KB)
- **Savings**: 90-97KB (28-30% reduction)

### 6. How can we defer context loading to the appropriate stage?

**Solution 1: Split Command Files**

Create two files per command:
1. `{command}-routing.md`: Lightweight routing logic (3-4KB)
2. `{command}-execution.md`: Full execution logic (15-20KB)

**Routing File** (loaded in Stages 1-3):
```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports"
---

<routing>
  <stage_1_preflight>
    Parse task number, validate, update status to [RESEARCHING]
  </stage_1_preflight>
  
  <stage_2_language>
    Extract language, determine agent (lean → lean-research-agent, * → researcher)
  </stage_2_language>
  
  <stage_3_delegation>
    Prepare delegation context, timeout 3600s
    Delegate to: {command}-execution.md
  </stage_3_delegation>
</routing>
```

**Execution File** (loaded in Stage 4):
```markdown
---
name: research-execution
agent: orchestrator
context_files:
  - command-lifecycle.md
  - TODO.md
  - status-markers.md
  - subagent-return-format.md
  - subagent-delegation-guide.md
  - git-commits.md
---

<execution>
  <stage_4_invoke>...</stage_4_invoke>
  <stage_5_receive>...</stage_5_receive>
  <stage_6_process>...</stage_6_process>
  <stage_7_postflight>...</stage_7_postflight>
  <stage_8_return>...</stage_8_return>
</execution>
```

**Benefits**:
- Routing context: 3-4KB (vs 77-85KB current)
- Execution context: 220KB (loaded only after routing)
- **Routing savings**: 73-81KB (96% reduction)

**Solution 2: Eliminate Context Duplication**

Remove duplicated context files from orchestrator:
- Orchestrator should NOT load subagent-return-format.md, subagent-delegation-guide.md, status-markers.md
- These files only needed in Stage 4 (execution)
- Orchestrator only needs minimal routing logic

**Benefits**:
- Orchestrator context: 0KB (vs 55KB current)
- Stage 4 context: 206KB (unchanged)
- **Routing savings**: 55KB (100% reduction of orchestrator context)

**Solution 3: Aggressive Command File Deduplication**

Extract common lifecycle logic to command-lifecycle.md (already done):
- Remove Stages 4-8 from command files
- Keep only variations (status markers, routing, timeouts)
- Reference command-lifecycle.md for common logic

**Current State**:
- command-lifecycle.md: 40KB (1,139 lines)
- Command files: 22-30KB each (648-773 lines)
- **Duplication**: ~60-70% of command file content

**Target State**:
- command-lifecycle.md: 40KB (unchanged)
- Command files: 8-12KB each (200-300 lines)
- **Savings**: 14-18KB per command × 4 = 56-72KB total

**Solution 4: Lazy Context Loading**

Implement lazy loading for Stage 4 context:
- Do NOT load context files until Stage 4 actually executes
- Use context file references (not inline content) in command files
- Load context files on-demand in Stage 4

**Benefits**:
- Routing context: Command file only (22-30KB)
- Execution context: Loaded only when needed (206KB)
- **Routing savings**: 206KB not loaded until Stage 4

---

## Baseline Measurements

### Context Window Usage by Stage

**Routing Stage (Stages 1-3)**:
- Orchestrator base: ~10KB (orchestrator.md metadata)
- Orchestrator context: 55KB (3 files)
- Command file: 22-30KB
- **Total**: 87-95KB

**Estimated Token Usage**: 87-95KB ÷ 4 bytes/token ≈ **21,750-23,750 tokens**

**Context Window %**: 21,750-23,750 ÷ 200,000 tokens ≈ **11-12%**

**Execution Stage (Stage 4+)**:
- Routing context: 87-95KB (carried forward)
- Stage 4 context: 206KB
- **Total**: 293-301KB

**Estimated Token Usage**: 293-301KB ÷ 4 bytes/token ≈ **73,250-75,250 tokens**

**Context Window %**: 73,250-75,250 ÷ 200,000 tokens ≈ **37-38%**

**Discrepancy Analysis**:

The user reports 58% context usage before work begins, but our calculation shows 11-12% for routing and 37-38% for execution. This suggests:

1. **Additional context loaded**: There may be additional context files loaded that we haven't accounted for (e.g., project-specific context, agent files)
2. **Context reservation**: The orchestrator may be reserving context window space for anticipated Stage 4 loads
3. **Token estimation error**: Our 4 bytes/token estimate may be conservative (actual may be 3 bytes/token)

**Revised Estimate (3 bytes/token)**:
- Routing: 87-95KB ÷ 3 ≈ **29,000-31,667 tokens** (15-16%)
- Execution: 293-301KB ÷ 3 ≈ **97,667-100,333 tokens** (49-50%)

This aligns more closely with the reported 58% usage.

### File Size Inventory

**Command Files**:
```
errors.md:     13KB
implement.md:  30KB
meta.md:       31KB
plan.md:       22KB
research.md:   23KB
review.md:     25KB
revise.md:     22KB
task.md:       11KB
todo.md:       21KB
```

**Orchestrator Context**:
```
subagent-return-format.md:      11KB
subagent-delegation-guide.md:   18KB
status-markers.md:              27KB
Total:                          56KB
```

**Stage 4 Context**:
```
command-lifecycle.md:           40KB
TODO.md:                       109KB
status-markers.md:              27KB
subagent-return-format.md:      11KB
subagent-delegation-guide.md:   18KB
git-commits.md:                  2KB
state.json:                     ~3KB
Total:                         210KB
```

**Total Context Load**:
- Routing: 56KB (orchestrator) + 22-30KB (command) = **78-86KB**
- Execution: 210KB (Stage 4)
- **Grand Total**: **288-296KB**

### Context Loading Timing

**Stage 1 (Preflight)**: 
- Load: Command file (22-30KB)
- Time: Immediate (routing start)

**Stage 2 (CheckLanguage)**:
- Load: None (uses command file already loaded)
- Time: Routing

**Stage 3 (PrepareDelegation)**:
- Load: None (uses command file already loaded)
- Time: Routing

**Stage 4 (InvokeAgent)**:
- Load: 7 context files (210KB)
- Time: After routing, before delegation
- **Context jump**: 78-86KB → 288-296KB (3.7× increase)

**Stage 5-8**:
- Load: None (uses Stage 4 context)
- Time: Execution

**Timeline**:
```
T=0s:    Routing starts, load command file (22-30KB)
         Context: 22-30KB (11-15%)
         
T=1s:    Routing completes (Stages 1-3)
         Context: 78-86KB (39-43% with orchestrator context)
         
T=2s:    Stage 4 starts, load 7 context files (210KB)
         Context: 288-296KB (144-148%)
         ERROR: Context window overflow!
         
T=3s:    Execution begins
         Context: 288-296KB (maintained)
```

**Problem**: The context window jumps from 39-43% (routing) to 144-148% (execution), causing overflow.

**Correction**: The 200K token budget is for the ENTIRE conversation, not per-stage. The 58% usage likely includes:
- Previous conversation history
- Orchestrator context (56KB)
- Command file (22-30KB)
- Anticipated Stage 4 context (210KB)
- **Total**: ~288-296KB ≈ 96-99K tokens ≈ **48-50% of 200K budget**

This aligns with the reported 58% when including conversation history and other overhead.

---

## Root Cause Analysis

### Primary Root Cause: Premature Command File Loading

**Problem**: The orchestrator loads the entire command file (22-30KB, 648-773 lines) during routing (Stages 1-3) to extract routing decisions, but only ~30% of the file content is relevant to routing. The remaining 70% is execution logic (Stages 4-8) that should not be loaded until Stage 4.

**Impact**:
- Routing context bloat: 15-21KB of unnecessary content loaded
- Context window waste: 60-70% of command file content unused during routing
- Premature context reservation: Orchestrator may reserve space for anticipated Stage 4 loads

**Evidence**:
- research.md: 648 lines, ~200 needed for routing (69% waste)
- plan.md: 623 lines, ~180 needed for routing (71% waste)
- implement.md: 773 lines, ~230 needed for routing (70% waste)

### Secondary Root Cause: Context File Duplication

**Problem**: Three context files are loaded TWICE:
1. Orchestrator loads during routing: subagent-return-format.md (11KB), subagent-delegation-guide.md (18KB), status-markers.md (27KB)
2. Command loads in Stage 4: Same 3 files again

**Impact**:
- Duplicated context: 56KB loaded twice
- Context window waste: 56KB of redundant content
- Memory inefficiency: Same content stored in two locations

**Evidence**:
- orchestrator.md context_loaded: 3 files (56KB)
- command Stage 4 context_loading: Same 3 files (56KB)
- Total duplication: 56KB

### Tertiary Root Cause: Large TODO.md File

**Problem**: TODO.md is 109KB and loaded in Stage 4 for every workflow command, but most commands only need a small portion (the specific task entry).

**Impact**:
- Excessive context load: 109KB for ~1-2KB of relevant content
- Context window waste: 99% of TODO.md content unused
- Scaling problem: TODO.md grows over time, making problem worse

**Evidence**:
- TODO.md size: 109,312 bytes
- Typical task entry: ~1-2KB
- Waste: ~107KB (98%)

### Quaternary Root Cause: Command File Content Duplication

**Problem**: All 4 workflow commands share 80-90% identical structure (8-stage lifecycle pattern), resulting in ~2,600 lines of duplicated content across command files.

**Impact**:
- Maintenance burden: Changes to lifecycle require updating 4 files
- Context window waste: Same content loaded 4 times (once per command)
- Inconsistency risk: Lifecycle variations may diverge over time

**Evidence**:
- command-lifecycle.md: 1,139 lines (common pattern)
- Command files: 648-773 lines each (80-90% duplicated)
- Total duplication: ~2,600 lines

---

## Recommendations

### Recommendation 1: Split Command Files (HIGH PRIORITY)

**Action**: Split each workflow command into two files:
1. `{command}-routing.md`: Lightweight routing logic (3-4KB, ~100-120 lines)
2. `{command}-execution.md`: Full execution logic (15-20KB, ~400-500 lines)

**Routing File Structure**:
```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports"
execution_file: research-execution.md
---

<routing>
  <stage_1_preflight>
    Parse task number: Extract first argument
    Validate: Task exists, not [COMPLETED]
    Update status: [RESEARCHING]
  </stage_1_preflight>
  
  <stage_2_language>
    Extract language: grep -A 20 "^### ${task_number}\." TODO.md | grep "Language"
    Route: lean → lean-research-agent, * → researcher
  </stage_2_language>
  
  <stage_3_delegation>
    Timeout: 3600s
    Special context: divide_topics (from --divide flag)
    Delegate to: research-execution.md
  </stage_3_delegation>
</routing>
```

**Execution File Structure**:
```markdown
---
name: research-execution
agent: orchestrator
context_files:
  - command-lifecycle.md
  - TODO.md (task entry only)
  - status-markers.md
  - subagent-return-format.md
  - subagent-delegation-guide.md
  - git-commits.md
---

<execution>
  Follow command-lifecycle.md Stages 4-8.
  
  Variations:
  - Status: [RESEARCHING] → [RESEARCHED]
  - Artifacts: reports/research-001.md, summaries/research-summary.md
  - Git: "task {number}: research completed"
</execution>
```

**Benefits**:
- Routing context: 3-4KB (vs 22-30KB current) = **18-26KB savings per command**
- Execution context: 15-20KB (loaded only in Stage 4)
- Total savings: 18-26KB × 4 commands = **72-104KB**
- Context window reduction: **36-52% at routing stage**

**Implementation Effort**: 8-12 hours
- Split 4 command files: 4 hours
- Test routing logic: 2 hours
- Test execution logic: 2 hours
- Update orchestrator: 2 hours
- Documentation: 2 hours

**Risk**: LOW (routing and execution logic already well-separated in current files)

### Recommendation 2: Eliminate Orchestrator Context Duplication (HIGH PRIORITY)

**Action**: Remove duplicated context files from orchestrator.md:
- Remove: subagent-return-format.md, subagent-delegation-guide.md, status-markers.md
- Keep: Only minimal routing logic in orchestrator

**Rationale**: These files are only needed in Stage 4 (execution), not during routing. The orchestrator only needs to:
1. Load command file
2. Extract routing decision
3. Delegate to command execution

**Benefits**:
- Orchestrator context: 0KB (vs 56KB current) = **56KB savings**
- Stage 4 context: 210KB (unchanged)
- Total savings: **56KB**
- Context window reduction: **28% at routing stage**

**Implementation Effort**: 2-4 hours
- Update orchestrator.md: 1 hour
- Test routing: 1 hour
- Verify Stage 4 loading: 1 hour
- Documentation: 1 hour

**Risk**: LOW (orchestrator doesn't use these files during routing)

### Recommendation 3: Implement Selective TODO.md Loading (MEDIUM PRIORITY)

**Action**: Load only the specific task entry from TODO.md instead of the entire file.

**Approach 1: Bash Extraction**
```bash
# Extract only task 237 entry
grep -A 50 "^### 237\." TODO.md > /tmp/task-237.md
# Load /tmp/task-237.md instead of full TODO.md
```

**Approach 2: State.json Reference**
```json
{
  "task_number": 237,
  "description": "...",
  "language": "markdown",
  "status": "researching"
}
```
Load state.json instead of TODO.md for task metadata.

**Benefits**:
- Context reduction: 109KB → 1-2KB = **107KB savings**
- Scaling: Context usage independent of TODO.md size
- Performance: Faster loading, less parsing

**Implementation Effort**: 6-10 hours
- Implement extraction logic: 3 hours
- Update all commands: 2 hours
- Test extraction: 2 hours
- Handle edge cases: 2 hours
- Documentation: 1 hour

**Risk**: MEDIUM (requires careful extraction logic to avoid missing task data)

### Recommendation 4: Aggressive Command File Deduplication (MEDIUM PRIORITY)

**Action**: Remove Stages 4-8 from command files, keep only variations.

**Current State**:
- Command files: 648-773 lines (60-70% duplicated)
- command-lifecycle.md: 1,139 lines (common pattern)

**Target State**:
- Command files: 200-300 lines (only variations)
- command-lifecycle.md: 1,139 lines (unchanged)

**Example Minimal Command File**:
```markdown
---
name: research
agent: orchestrator
---

<workflow_execution>
  Follow command-lifecycle.md 8-stage pattern.
  
  <variations>
    <status>
      Initial: [NOT STARTED]
      In-Progress: [RESEARCHING]
      Completion: [RESEARCHED]
    </status>
    
    <routing>
      lean → lean-research-agent
      * → researcher
    </routing>
    
    <timeout>3600s</timeout>
    
    <artifacts>
      reports/research-001.md
      summaries/research-summary.md
    </artifacts>
    
    <git_commit>
      "task {number}: research completed"
    </git_commit>
  </variations>
</workflow_execution>
```

**Benefits**:
- Command file size: 8-12KB (vs 22-30KB current) = **14-18KB savings per command**
- Total savings: 14-18KB × 4 commands = **56-72KB**
- Maintenance: Single source of truth for lifecycle logic
- Consistency: Guaranteed identical lifecycle across commands

**Implementation Effort**: 12-16 hours
- Refactor 4 command files: 6 hours
- Update command-lifecycle.md: 2 hours
- Test all commands: 4 hours
- Update documentation: 2 hours
- Regression testing: 2 hours

**Risk**: MEDIUM (requires careful extraction of variations, thorough testing)

### Recommendation 5: Implement Lazy Context Loading (LOW PRIORITY)

**Action**: Defer loading of Stage 4 context files until Stage 4 actually executes.

**Current Behavior**:
- Stage 4 context files referenced in command file
- Orchestrator may pre-load or reserve space for these files

**Target Behavior**:
- Stage 4 context files NOT referenced in command file
- Loaded on-demand when Stage 4 executes
- No pre-loading or reservation

**Benefits**:
- Routing context: No Stage 4 context loaded
- Execution context: Loaded only when needed
- Context window: More efficient allocation

**Implementation Effort**: 16-24 hours
- Design lazy loading mechanism: 4 hours
- Implement loading logic: 6 hours
- Update all commands: 4 hours
- Test loading behavior: 4 hours
- Handle edge cases: 4 hours
- Documentation: 2 hours

**Risk**: HIGH (requires significant changes to context loading mechanism, may introduce timing issues)

### Recommendation 6: Implement Context Window Monitoring (LOW PRIORITY)

**Action**: Add context window usage tracking to orchestrator.

**Features**:
- Track context usage at each stage
- Log context window % at routing and execution
- Alert when context usage exceeds thresholds
- Provide context usage breakdown in errors.json

**Benefits**:
- Visibility: Clear understanding of context usage
- Debugging: Identify context bloat sources
- Optimization: Data-driven context reduction
- Monitoring: Detect context window regressions

**Implementation Effort**: 8-12 hours
- Design monitoring mechanism: 2 hours
- Implement tracking: 4 hours
- Add logging: 2 hours
- Create dashboard/report: 2 hours
- Documentation: 2 hours

**Risk**: LOW (monitoring only, no functional changes)

---

## Implementation Priority

### Phase 1: Quick Wins (2-6 hours)

**Goal**: Reduce routing context by 50-60% with minimal risk.

**Actions**:
1. **Eliminate Orchestrator Context Duplication** (Recommendation 2)
   - Effort: 2-4 hours
   - Savings: 56KB (28% reduction)
   - Risk: LOW

**Expected Result**: Routing context drops from 78-86KB to 22-30KB (64-72% reduction).

### Phase 2: Command File Optimization (12-20 hours)

**Goal**: Reduce command file sizes by 60-70%.

**Actions**:
1. **Split Command Files** (Recommendation 1)
   - Effort: 8-12 hours
   - Savings: 72-104KB (36-52% reduction)
   - Risk: LOW

2. **Aggressive Deduplication** (Recommendation 4)
   - Effort: 12-16 hours
   - Savings: 56-72KB (additional)
   - Risk: MEDIUM

**Expected Result**: Command files drop from 22-30KB to 3-4KB (85-87% reduction).

### Phase 3: TODO.md Optimization (6-10 hours)

**Goal**: Reduce TODO.md context load by 98%.

**Actions**:
1. **Selective TODO.md Loading** (Recommendation 3)
   - Effort: 6-10 hours
   - Savings: 107KB (98% reduction)
   - Risk: MEDIUM

**Expected Result**: TODO.md context drops from 109KB to 1-2KB (98% reduction).

### Phase 4: Advanced Optimization (16-36 hours)

**Goal**: Implement lazy loading and monitoring.

**Actions**:
1. **Lazy Context Loading** (Recommendation 5)
   - Effort: 16-24 hours
   - Savings: Variable (depends on usage patterns)
   - Risk: HIGH

2. **Context Window Monitoring** (Recommendation 6)
   - Effort: 8-12 hours
   - Savings: N/A (monitoring only)
   - Risk: LOW

**Expected Result**: Context usage optimized dynamically, monitoring in place.

---

## Expected Outcomes

### Baseline (Current State)

**Routing Context (Stages 1-3)**:
- Orchestrator: 56KB
- Command file: 22-30KB
- **Total**: 78-86KB (39-43% of 200K token budget)

**Execution Context (Stage 4+)**:
- Routing context: 78-86KB
- Stage 4 context: 210KB
- **Total**: 288-296KB (144-148% of 200K token budget)

**Problem**: Context window overflow at Stage 4.

### After Phase 1 (Eliminate Duplication)

**Routing Context**:
- Orchestrator: 0KB (vs 56KB)
- Command file: 22-30KB
- **Total**: 22-30KB (11-15% of 200K token budget)

**Execution Context**:
- Routing context: 22-30KB
- Stage 4 context: 210KB
- **Total**: 232-240KB (116-120% of 200K token budget)

**Improvement**: Routing context reduced by 64-72%, but still overflow at Stage 4.

### After Phase 2 (Command File Optimization)

**Routing Context**:
- Orchestrator: 0KB
- Command file: 3-4KB (vs 22-30KB)
- **Total**: 3-4KB (1.5-2% of 200K token budget)

**Execution Context**:
- Routing context: 3-4KB
- Stage 4 context: 210KB
- **Total**: 213-214KB (106-107% of 200K token budget)

**Improvement**: Routing context reduced by 96%, execution context still slightly over budget.

### After Phase 3 (TODO.md Optimization)

**Routing Context**:
- Orchestrator: 0KB
- Command file: 3-4KB
- **Total**: 3-4KB (1.5-2% of 200K token budget)

**Execution Context**:
- Routing context: 3-4KB
- Stage 4 context: 103KB (vs 210KB, TODO.md reduced from 109KB to 1-2KB)
- **Total**: 106-107KB (53-54% of 200K token budget)

**Improvement**: Routing context <2%, execution context <55% (well within budget).

### Final Target (All Phases)

**Routing Context**: <5KB (<2.5% of budget)
**Execution Context**: <110KB (<55% of budget)
**Total Context**: <115KB (<58% of budget)

**Comparison to Baseline**:
- Routing: 78-86KB → 3-5KB (94-96% reduction)
- Execution: 288-296KB → 106-110KB (62-64% reduction)
- **Total savings**: 178-186KB (62-64% reduction)

---

## Specific Fixes to Reduce Routing-Stage Context to <10%

### Fix 1: Remove Orchestrator Context Files (IMMEDIATE)

**File**: `.opencode/agent/orchestrator.md`

**Change**:
```diff
- <context_loaded>
-   @.opencode/context/core/standards/subagent-return-format.md
-   @.opencode/context/core/workflows/subagent-delegation-guide.md
-   @.opencode/context/core/system/status-markers.md
- </context_loaded>
+ <context_loaded>
+   <!-- No context files loaded during routing -->
+   <!-- Context files loaded in Stage 4 by command execution files -->
+ </context_loaded>
```

**Impact**: 56KB reduction (28% of routing context)

### Fix 2: Split research.md into Routing and Execution (IMMEDIATE)

**Create**: `.opencode/command/research-routing.md`
```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
execution_file: research-execution.md
---

<routing>
  <stage_1_preflight>
    Parse task number from $ARGUMENTS
    Validate task exists and not [COMPLETED]
    Update status to [RESEARCHING]
  </stage_1_preflight>
  
  <stage_2_language>
    Extract language: grep -A 20 "^### ${task_number}\." TODO.md | grep "Language"
    Route: lean → lean-research-agent, * → researcher
  </stage_2_language>
  
  <stage_3_delegation>
    Timeout: 3600s
    Special: divide_topics (from --divide flag)
    Delegate to: research-execution.md
  </stage_3_delegation>
</routing>
```

**Create**: `.opencode/command/research-execution.md`
```markdown
---
name: research-execution
agent: orchestrator
context_files:
  - command-lifecycle.md
  - TODO.md (task entry only)
  - status-markers.md
  - subagent-return-format.md
  - subagent-delegation-guide.md
  - git-commits.md
---

<execution>
  Follow command-lifecycle.md Stages 4-8.
  
  <variations>
    <status>
      Completion: [RESEARCHED]
      Partial: [RESEARCHING]
    </status>
    
    <artifacts>
      reports/research-001.md
      summaries/research-summary.md
    </artifacts>
    
    <git_commit>
      "task {number}: research completed"
    </git_commit>
  </variations>
</execution>
```

**Impact**: 19KB reduction (research.md 23KB → 4KB routing file)

### Fix 3: Repeat for plan.md, revise.md, implement.md (IMMEDIATE)

**Impact**: 
- plan.md: 22KB → 4KB (18KB reduction)
- revise.md: 22KB → 4KB (18KB reduction)
- implement.md: 30KB → 4KB (26KB reduction)
- **Total**: 62KB reduction

### Fix 4: Implement Selective TODO.md Loading (SHORT-TERM)

**File**: `.opencode/command/research-execution.md`

**Change**:
```diff
  context_files:
    - command-lifecycle.md
-   - TODO.md
+   - TODO.md (task entry only via grep extraction)
    - status-markers.md
    - subagent-return-format.md
    - subagent-delegation-guide.md
    - git-commits.md
```

**Implementation**:
```bash
# Extract only task 237 entry (50 lines)
grep -A 50 "^### ${task_number}\." TODO.md > /tmp/task-${task_number}.md
# Load /tmp/task-${task_number}.md instead of full TODO.md
```

**Impact**: 107KB reduction (TODO.md 109KB → 2KB task entry)

### Combined Impact of All Fixes

**Routing Context**:
- Baseline: 78-86KB (39-43%)
- After Fix 1: 22-30KB (11-15%)
- After Fix 2-3: 3-11KB (1.5-5.5%)
- **Final**: 3-11KB (1.5-5.5%)

**Execution Context**:
- Baseline: 288-296KB (144-148%)
- After Fix 4: 181-189KB (90-95%)
- **Final**: 181-189KB (90-95%)

**Result**: Routing context reduced to <6% (target: <10% [YES])

---

## Conclusion

The context window bloat in workflow commands is caused by:
1. **Premature command file loading**: 60-70% of command file content is execution logic loaded during routing
2. **Context file duplication**: 56KB of context files loaded twice (orchestrator + Stage 4)
3. **Large TODO.md file**: 109KB loaded for every command, 98% unused
4. **Command file duplication**: 2,600 lines of duplicated lifecycle logic across 4 commands

**Recommended fixes** (in priority order):
1. **Eliminate orchestrator context duplication** (2-4 hours, 56KB savings, LOW risk)
2. **Split command files into routing and execution** (8-12 hours, 72-104KB savings, LOW risk)
3. **Implement selective TODO.md loading** (6-10 hours, 107KB savings, MEDIUM risk)
4. **Aggressive command file deduplication** (12-16 hours, 56-72KB savings, MEDIUM risk)

**Expected outcome**: Routing context reduced from 78-86KB (39-43%) to 3-11KB (1.5-5.5%), achieving the <10% target.

**Total implementation effort**: 28-42 hours across 4 phases.

**Risk assessment**: LOW to MEDIUM (most fixes are structural refactoring with clear separation of concerns).

---

## Sources and Citations

1. **Command Files**:
   - `.opencode/command/research.md` (648 lines, 23KB)
   - `.opencode/command/plan.md` (623 lines, 22KB)
   - `.opencode/command/revise.md` (617 lines, 22KB)
   - `.opencode/command/implement.md` (773 lines, 30KB)

2. **Orchestrator**:
   - `.opencode/agent/orchestrator.md` (1,093 lines, 37KB)

3. **Context Files**:
   - `.opencode/context/core/workflows/command-lifecycle.md` (1,139 lines, 40KB)
   - `.opencode/specs/TODO.md` (109KB)
   - `.opencode/context/core/system/status-markers.md` (27KB)
   - `.opencode/context/core/standards/subagent-return-format.md` (11KB)
   - `.opencode/context/core/workflows/subagent-delegation-guide.md` (18KB)
   - `.opencode/context/core/system/git-commits.md` (2KB)

4. **File Size Measurements**:
   - `wc -c` output for all context files
   - `ls -lh` output for command files

5. **Architecture Documentation**:
   - command-lifecycle.md Stage 4 context loading pattern
   - orchestrator.md context_loaded section
   - Command file Stage 4 context_loading sections

---

## Next Steps

1. **Review findings** with project stakeholders
2. **Prioritize fixes** based on effort/impact ratio
3. **Implement Phase 1** (eliminate duplication) as quick win
4. **Test routing context** reduction after Phase 1
5. **Proceed to Phase 2** (command file optimization) if Phase 1 successful
6. **Monitor context usage** throughout implementation
7. **Document changes** in command-lifecycle.md and orchestrator.md
8. **Create regression tests** to prevent context bloat in future

---

**Research completed**: 2025-12-28  
**Researcher**: researcher  
**Session ID**: sess_1735455494_ctx237
