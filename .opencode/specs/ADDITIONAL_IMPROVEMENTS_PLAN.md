# Additional Systematic Improvements Plan

**Created**: 2026-01-03  
**Status**: Proposed  
**Purpose**: Additional systematic improvements beyond SYSTEM_IMPROVEMENT_PLAN_v2.md  
**Context**: Builds on the foundation of command argument standardization and orchestrator optimization

---

## Executive Summary

This plan identifies **7 additional systematic improvement areas** for the ProofChecker .opencode system:

1. **Subagent Standardization** - Ensure all subagents follow consistent patterns
2. **Validation & Testing Infrastructure** - Expand automated validation
3. **Error Handling & Recovery** - Improve error tracking and self-healing
4. **Performance Monitoring** - Add metrics and observability
5. **Context File Consolidation** - Continue Task 267 and similar cleanup
6. **Documentation Completeness** - Fill gaps in guides and references
7. **Developer Experience Tools** - Add utilities for common tasks

**Expected Impact**:
- 50% reduction in subagent inconsistencies
- 80% test coverage for critical paths
- 90% reduction in unhandled errors
- Real-time performance visibility
- 30% faster onboarding for new developers

---

## Improvement Area 1: Subagent Standardization

### Current State Analysis

**Strengths**:
- Good frontmatter validation script (`validate_frontmatter.py`)
- Consistent frontmatter structure across agents
- Clear agent templates in `context/core/templates/`

**Issues Identified**:

1. **Inconsistent Input Parsing**
   - Some agents parse `task_number` from delegation context
   - Others parse from prompt string "Task: {number}"
   - No standard pattern documented

2. **Variable Workflow Stages**
   - Some agents have 6 stages, others have 8
   - Stage numbering inconsistent
   - No clear standard for stage structure

3. **Inconsistent Error Handling**
   - Different error message formats
   - Some agents use structured errors, others use plain text
   - No standard error taxonomy

4. **Context Loading Variations**
   - Different agents load different context files
   - No clear guidance on which files to load for which tasks
   - Some agents over-load context (>50KB)

### Proposed Improvements

#### 1.1 Create Subagent Input Parsing Standard

**File**: `.opencode/context/core/standards/subagent-input-parsing.md`

**Purpose**: Define how subagents should parse inputs from orchestrator delegation.

**Content Structure**:

```markdown
# Subagent Input Parsing Standard

## Overview

All subagents receive inputs via delegation context from the orchestrator. This standard defines how to parse and validate these inputs.

## Input Sources

### Primary: Delegation Context Parameters

Subagents receive structured parameters in delegation context:

```json
{
  "task_number": 258,
  "session_id": "sess_20260103_abc123",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "researcher"],
  "language": "lean",
  "additional_params": {...}
}
```

**Parsing Pattern**:
```xml
<step_1>
  <action>Extract parameters from delegation context</action>
  <process>
    1. Read task_number from delegation context
    2. Read session_id from delegation context
    3. Read delegation_depth from delegation context
    4. Read delegation_path from delegation context
    5. Read optional parameters (language, custom params)
  </process>
</step_1>
```

### Secondary: Prompt String (Legacy)

Some commands may pass task number in prompt string format: "Task: {number}"

**Parsing Pattern**:
```xml
<step_1_fallback>
  <action>Parse task number from prompt string if not in delegation context</action>
  <process>
    1. Check if task_number in delegation context
    2. If not present, parse from prompt string:
       - Pattern: "Task: {number}"
       - Extract number using regex: r"Task:\s*(\d+)"
    3. Validate extracted number is positive integer
  </process>
</step_1_fallback>
```

## Validation Rules

### Required Parameters

All subagents MUST validate:
- `task_number`: Positive integer, exists in TODO.md
- `session_id`: Non-empty string, valid session format
- `delegation_depth`: Integer 1-3
- `delegation_path`: Non-empty array

### Optional Parameters

Subagents MAY receive:
- `language`: String (lean, markdown, python, etc.)
- `custom_prompt`: String (user-provided instructions)
- `flags`: Object (command-specific flags)

## Error Handling

### Missing Required Parameter

```json
{
  "status": "failed",
  "summary": "Missing required parameter: task_number",
  "errors": [{
    "type": "missing_parameter",
    "parameter": "task_number",
    "message": "task_number is required but not provided in delegation context"
  }]
}
```

### Invalid Parameter Format

```json
{
  "status": "failed",
  "summary": "Invalid parameter format: task_number must be positive integer",
  "errors": [{
    "type": "invalid_parameter",
    "parameter": "task_number",
    "value": "abc",
    "expected": "positive integer",
    "message": "task_number 'abc' is not a valid positive integer"
  }]
}
```

## Implementation Checklist

When creating or updating a subagent:
- [ ] Define inputs_required section in frontmatter
- [ ] Parse parameters from delegation context (primary)
- [ ] Implement fallback parsing from prompt string (if needed)
- [ ] Validate all required parameters
- [ ] Return structured errors for invalid inputs
- [ ] Document parameter expectations in agent file
```

**Estimated Size**: ~100 lines

**Benefits**:
- Consistent input handling across all subagents
- Clear error messages for missing/invalid inputs
- Easier debugging and testing

#### 1.2 Create Subagent Workflow Stage Standard

**File**: `.opencode/context/core/standards/subagent-workflow-stages.md`

**Purpose**: Define standard workflow stages for all subagents.

**Content Structure**:

```markdown
# Subagent Workflow Stage Standard

## Overview

All subagents follow a standardized workflow structure with numbered stages. This ensures consistency and makes workflows easier to understand and debug.

## Standard 8-Stage Workflow

### Stage 1: Parse and Validate Inputs
- Extract parameters from delegation context
- Validate required parameters
- Parse optional parameters
- Return early if validation fails

### Stage 2: Load Task Context
- Read task from TODO.md
- Load project state.json (if exists)
- Extract task metadata (language, priority, etc.)
- Load research/plan artifacts (if exist)

### Stage 3: Execute Core Work
- Perform agent-specific work
- Create artifacts
- Track progress

### Stage 4: Create Artifacts
- Write primary artifacts (reports, plans, code)
- Create summary artifact (if multi-file output)
- Validate artifacts created successfully

### Stage 5: Update Status (via status-sync-manager)
- Delegate to status-sync-manager
- Update TODO.md status
- Update state.json
- Update project state.json
- Atomic multi-file update

### Stage 6: Create Git Commit (via git-workflow-manager)
- Delegate to git-workflow-manager
- Create scoped commit
- Include task number in message
- Validate commit succeeded

### Stage 7: Prepare Return
- Format return per subagent-return-format.md
- Include status, summary, artifacts, metadata
- Validate return format

### Stage 8: Return to Orchestrator
- Return formatted result
- Orchestrator validates and relays to user

## Simplified 6-Stage Workflow (for simple agents)

For agents that don't need status updates or git commits:

### Stage 1: Parse and Validate Inputs
### Stage 2: Load Context
### Stage 3: Execute Work
### Stage 4: Create Artifacts
### Stage 5: Prepare Return
### Stage 6: Return to Orchestrator

## Stage Numbering Rules

1. **Always start at Stage 1** (no Stage 0)
2. **Use sequential numbering** (1, 2, 3, 4, 5, 6, 7, 8)
3. **Don't skip stages** (if you have 6 stages, number 1-6)
4. **Document stage purpose** in `<action>` tag
5. **Include checkpoints** at end of each stage

## Example: Research Agent Workflow

```xml
<workflow_execution>
  <stage id="1" name="ParseAndValidateInputs">
    <action>Extract and validate delegation context parameters</action>
    <checkpoint>All required parameters validated</checkpoint>
  </stage>
  
  <stage id="2" name="LoadTaskContext">
    <action>Read task from TODO.md and load project state</action>
    <checkpoint>Task context loaded successfully</checkpoint>
  </stage>
  
  <stage id="3" name="ConductResearch">
    <action>Execute research using appropriate tools</action>
    <checkpoint>Research completed, findings documented</checkpoint>
  </stage>
  
  <stage id="4" name="CreateArtifacts">
    <action>Write research report and summary</action>
    <checkpoint>Artifacts created and validated</checkpoint>
  </stage>
  
  <stage id="5" name="UpdateStatus">
    <action>Delegate to status-sync-manager to update status to [RESEARCHED]</action>
    <checkpoint>Status updated atomically across all files</checkpoint>
  </stage>
  
  <stage id="6" name="CreateGitCommit">
    <action>Delegate to git-workflow-manager to create scoped commit</action>
    <checkpoint>Git commit created successfully</checkpoint>
  </stage>
  
  <stage id="7" name="PrepareReturn">
    <action>Format return per subagent-return-format.md</action>
    <checkpoint>Return formatted and validated</checkpoint>
  </stage>
  
  <stage id="8" name="ReturnToOrchestrator">
    <action>Return formatted result to orchestrator</action>
    <checkpoint>Result returned successfully</checkpoint>
  </stage>
</workflow_execution>
```

## Migration Guide

To update existing agents to follow this standard:

1. **Audit current stages**: Count and list current stages
2. **Map to standard**: Identify which standard stages apply
3. **Renumber**: Update stage IDs to be sequential
4. **Add missing stages**: Add any missing standard stages
5. **Update documentation**: Update stage descriptions
6. **Test**: Verify agent still works correctly
```

**Estimated Size**: ~120 lines

**Benefits**:
- Consistent workflow structure across all agents
- Easier to understand and debug workflows
- Clear expectations for what each stage does

#### 1.3 Expand Frontmatter Validation

**File**: `.opencode/scripts/validate_frontmatter.py` (update existing)

**Changes**:

1. **Add workflow stage validation**:
   ```python
   def validate_workflow_stages(data: Dict) -> List[str]:
       """Validate workflow stages follow standard."""
       errors = []
       
       # Check for workflow_execution section
       if "workflow_execution" not in data:
           return []  # Optional section
       
       workflow = data["workflow_execution"]
       if not isinstance(workflow, dict):
           return ["workflow_execution must be an object"]
       
       # Extract stages
       stages = []
       for key, value in workflow.items():
           if key.startswith("stage_"):
               stages.append((key, value))
       
       if not stages:
           return []  # No stages defined
       
       # Validate stage numbering
       stage_numbers = []
       for key, value in stages:
           match = re.match(r'stage_(\d+)', key)
           if match:
               stage_numbers.append(int(match.group(1)))
       
       # Check sequential numbering
       if stage_numbers:
           stage_numbers.sort()
           expected = list(range(1, len(stage_numbers) + 1))
           if stage_numbers != expected:
               errors.append(
                   f"Workflow stages not sequential: {stage_numbers} "
                   f"(expected {expected})"
               )
       
       return errors
   ```

2. **Add input parsing validation**:
   ```python
   def validate_input_parsing(data: Dict) -> List[str]:
       """Validate inputs_required section."""
       errors = []
       
       if "inputs_required" not in data:
           return []  # Optional section
       
       inputs = data["inputs_required"]
       if not isinstance(inputs, dict):
           return ["inputs_required must be an object"]
       
       # Check for required standard parameters
       required_params = ["task_number", "session_id", "delegation_depth", "delegation_path"]
       for param in required_params:
           if param not in inputs:
               errors.append(f"Missing required input parameter: {param}")
       
       return errors
   ```

3. **Add context loading size validation**:
   ```python
   def validate_context_loading_size(data: Dict) -> List[str]:
       """Validate context loading doesn't exceed budget."""
       errors = []
       
       if "context_loading" not in data:
           return []
       
       context = data["context_loading"]
       max_size = context.get("max_context_size", 0)
       
       # Warn if exceeds recommended limits
       if max_size > 60000:
           errors.append(
               f"max_context_size ({max_size}) exceeds recommended limit (60000)"
           )
       
       return errors
   ```

**Benefits**:
- Automated validation of subagent standards
- Catch inconsistencies early
- Enforce best practices

#### 1.4 Create Subagent Audit Script

**File**: `.opencode/scripts/audit_subagents.py`

**Purpose**: Audit all subagents for compliance with standards.

**Features**:
- Check frontmatter completeness
- Validate workflow stage structure
- Check input parsing patterns
- Validate context loading
- Generate compliance report

**Output**:
```
Subagent Compliance Audit Report
=================================

Total Subagents: 15
Compliant: 12 (80%)
Non-Compliant: 3 (20%)

Issues Found:
-------------

researcher.md:
  [WARN] Workflow stages not sequential: [1, 2, 3, 5, 6, 7, 8] (missing stage 4)
  [INFO] Context loading size: 48KB (within limit)

planner.md:
  [PASS] All checks passed

implementer.md:
  [WARN] Missing input parameter: language
  [INFO] Context loading size: 52KB (within limit)

...

Recommendations:
----------------
1. Fix workflow stage numbering in researcher.md
2. Add language parameter to implementer.md inputs_required
3. Review context loading in 3 agents exceeding 55KB
```

**Estimated Size**: ~200 lines

**Benefits**:
- Automated compliance checking
- Clear visibility into subagent quality
- Actionable recommendations

### Deliverables

- [ ] New standard: `subagent-input-parsing.md` (~100 lines)
- [ ] New standard: `subagent-workflow-stages.md` (~120 lines)
- [ ] Updated script: `validate_frontmatter.py` (+100 lines)
- [ ] New script: `audit_subagents.py` (~200 lines)
- [ ] Compliance report for all existing subagents

### Testing

- [ ] Run `audit_subagents.py` on all existing agents
- [ ] Fix top 3 compliance issues
- [ ] Re-run audit to verify fixes
- [ ] Document remaining issues as technical debt

---

## Improvement Area 2: Validation & Testing Infrastructure

### Current State Analysis

**Strengths**:
- Good frontmatter validation script
- Clear return format standard
- Artifact validation in orchestrator

**Gaps**:

1. **No Integration Tests**
   - No automated tests for complete workflows
   - Manual testing only
   - No regression detection

2. **No Command Tests**
   - Commands not tested independently
   - Argument parsing not validated
   - Error handling not verified

3. **No Subagent Tests**
   - Subagents not tested in isolation
   - Return format not validated automatically
   - Delegation patterns not tested

4. **No Performance Tests**
   - No benchmarks for context loading
   - No timeout testing
   - No memory usage tracking

### Proposed Improvements

#### 2.1 Create Integration Test Framework

**File**: `.opencode/scripts/test_integration.py`

**Purpose**: Test complete workflows end-to-end.

**Test Cases**:

```python
class TestResearchWorkflow:
    """Test /research command end-to-end."""
    
    def test_research_simple_task(self):
        """Test research on simple markdown task."""
        # Create test task
        task_number = create_test_task("Test research workflow", language="markdown")
        
        # Execute /research
        result = execute_command(f"/research {task_number}")
        
        # Validate result
        assert result["status"] == "completed"
        assert len(result["artifacts"]) > 0
        
        # Validate artifacts exist
        for artifact in result["artifacts"]:
            assert os.path.exists(artifact["path"])
            assert os.path.getsize(artifact["path"]) > 0
        
        # Validate status updated
        task = read_task(task_number)
        assert task["status"] == "[RESEARCHED]"
        
        # Cleanup
        cleanup_test_task(task_number)
    
    def test_research_lean_task(self):
        """Test research on Lean task (routes to lean-research-agent)."""
        # Create test task
        task_number = create_test_task("Test Lean research", language="lean")
        
        # Execute /research
        result = execute_command(f"/research {task_number}")
        
        # Validate routing
        assert result["metadata"]["agent_type"] == "lean-research"
        
        # Validate result
        assert result["status"] == "completed"
        
        # Cleanup
        cleanup_test_task(task_number)
    
    def test_research_invalid_task(self):
        """Test research with invalid task number."""
        # Execute /research with non-existent task
        result = execute_command("/research 99999")
        
        # Validate error
        assert result["status"] == "failed"
        assert "not found" in result["summary"].lower()
```

**Estimated Size**: ~400 lines

**Benefits**:
- Automated regression testing
- Confidence in changes
- Clear test coverage metrics

#### 2.2 Create Command Test Framework

**File**: `.opencode/scripts/test_commands.py`

**Purpose**: Test commands in isolation (argument parsing, routing, validation).

**Test Cases**:

```python
class TestCommandArgumentParsing:
    """Test command argument parsing."""
    
    def test_research_parses_task_number(self):
        """Test /research parses task number from $ARGUMENTS."""
        # Mock $ARGUMENTS
        os.environ["ARGUMENTS"] = "258"
        
        # Parse arguments
        args = parse_command_arguments("research")
        
        # Validate
        assert args["task_number"] == 258
        assert args["command_type"] == "task-based"
    
    def test_meta_parses_empty_arguments(self):
        """Test /meta handles empty $ARGUMENTS."""
        # Mock $ARGUMENTS
        os.environ["ARGUMENTS"] = ""
        
        # Parse arguments
        args = parse_command_arguments("meta")
        
        # Validate
        assert args["command_type"] == "direct"
        assert args["user_input"] == ""
    
    def test_research_validates_task_exists(self):
        """Test /research validates task exists."""
        # Mock $ARGUMENTS with non-existent task
        os.environ["ARGUMENTS"] = "99999"
        
        # Validate
        with pytest.raises(TaskNotFoundError):
            validate_task_exists(99999)
```

**Estimated Size**: ~300 lines

**Benefits**:
- Validate argument parsing logic
- Test error handling
- Ensure routing works correctly

#### 2.3 Create Subagent Test Framework

**File**: `.opencode/scripts/test_subagents.py`

**Purpose**: Test subagents in isolation (input parsing, return format, delegation).

**Test Cases**:

```python
class TestResearcherAgent:
    """Test researcher subagent."""
    
    def test_parses_delegation_context(self):
        """Test researcher parses delegation context correctly."""
        # Create delegation context
        context = {
            "task_number": 258,
            "session_id": "sess_test_123",
            "delegation_depth": 1,
            "delegation_path": ["orchestrator", "research", "researcher"]
        }
        
        # Invoke researcher
        result = invoke_subagent("researcher", context)
        
        # Validate parsed correctly
        assert result["metadata"]["task_number"] == 258
        assert result["metadata"]["session_id"] == "sess_test_123"
    
    def test_returns_standard_format(self):
        """Test researcher returns standard format."""
        # Create test task
        task_number = create_test_task("Test return format")
        
        # Invoke researcher
        result = invoke_subagent("researcher", {"task_number": task_number})
        
        # Validate return format
        assert "status" in result
        assert "summary" in result
        assert "artifacts" in result
        assert "metadata" in result
        assert "session_id" in result
        
        # Cleanup
        cleanup_test_task(task_number)
    
    def test_validates_artifacts_created(self):
        """Test researcher creates artifacts before returning completed."""
        # Create test task
        task_number = create_test_task("Test artifact validation")
        
        # Invoke researcher
        result = invoke_subagent("researcher", {"task_number": task_number})
        
        # If status is completed, artifacts must exist
        if result["status"] == "completed":
            assert len(result["artifacts"]) > 0
            for artifact in result["artifacts"]:
                assert os.path.exists(artifact["path"])
                assert os.path.getsize(artifact["path"]) > 0
        
        # Cleanup
        cleanup_test_task(task_number)
```

**Estimated Size**: ~500 lines

**Benefits**:
- Test subagents independently
- Validate return format compliance
- Ensure artifact creation

#### 2.4 Create Performance Test Framework

**File**: `.opencode/scripts/test_performance.py`

**Purpose**: Benchmark performance and detect regressions.

**Test Cases**:

```python
class TestPerformance:
    """Test performance benchmarks."""
    
    def test_orchestrator_routing_time(self):
        """Test orchestrator routing completes in <1s."""
        # Create test task
        task_number = create_test_task("Test routing performance")
        
        # Measure routing time
        start = time.time()
        route_decision = orchestrator_route(f"/research {task_number}")
        end = time.time()
        
        # Validate
        assert (end - start) < 1.0  # <1 second
        
        # Cleanup
        cleanup_test_task(task_number)
    
    def test_context_loading_size(self):
        """Test context loading stays within budget."""
        # Load orchestrator context
        context_size = measure_context_size("orchestrator")
        
        # Validate
        assert context_size < 10000  # <10KB for orchestrator
    
    def test_research_workflow_time(self):
        """Test research workflow completes in <60s."""
        # Create test task
        task_number = create_test_task("Test workflow performance")
        
        # Measure workflow time
        start = time.time()
        result = execute_command(f"/research {task_number}")
        end = time.time()
        
        # Validate
        assert (end - start) < 60.0  # <60 seconds
        
        # Cleanup
        cleanup_test_task(task_number)
```

**Estimated Size**: ~200 lines

**Benefits**:
- Performance regression detection
- Context budget enforcement
- Timeout validation

### Deliverables

- [ ] New test framework: `test_integration.py` (~400 lines)
- [ ] New test framework: `test_commands.py` (~300 lines)
- [ ] New test framework: `test_subagents.py` (~500 lines)
- [ ] New test framework: `test_performance.py` (~200 lines)
- [ ] CI/CD integration (GitHub Actions workflow)
- [ ] Test coverage report

### Testing

- [ ] Run all test frameworks
- [ ] Achieve 80% coverage for critical paths
- [ ] Fix failing tests
- [ ] Document test patterns

---

## Improvement Area 3: Error Handling & Recovery

### Current State Analysis

**Strengths**:
- errors.json tracking
- /errors command for analysis
- Error diagnostics agent

**Gaps**:

1. **Inconsistent Error Formats**
   - Different agents use different error structures
   - No standard error taxonomy
   - Hard to aggregate and analyze

2. **Limited Self-Healing**
   - Some self-healing for missing files
   - No automatic retry logic
   - No circuit breaker patterns

3. **No Error Metrics**
   - No error rate tracking
   - No error severity classification
   - No alerting on critical errors

4. **Limited Recovery Guidance**
   - Errors logged but not actionable
   - No automatic fix suggestions
   - Manual intervention required

### Proposed Improvements

#### 3.1 Create Error Taxonomy Standard

**File**: `.opencode/context/core/standards/error-taxonomy.md`

**Purpose**: Define standard error types, severities, and formats.

**Content Structure**:

```markdown
# Error Taxonomy Standard

## Overview

This standard defines a comprehensive error taxonomy for the .opencode system, including error types, severities, and structured formats.

## Error Types

### System Errors

**Type**: `system_error`

**Subtypes**:
- `file_not_found`: Required file doesn't exist
- `permission_denied`: Insufficient permissions
- `disk_full`: Out of disk space
- `timeout`: Operation exceeded timeout

**Example**:
```json
{
  "type": "system_error",
  "subtype": "file_not_found",
  "severity": "error",
  "message": "Required file not found: .opencode/specs/TODO.md",
  "context": {
    "file_path": ".opencode/specs/TODO.md",
    "operation": "read_task"
  },
  "recovery": "Create TODO.md using /todo command"
}
```

### Validation Errors

**Type**: `validation_error`

**Subtypes**:
- `invalid_format`: Data doesn't match expected format
- `missing_field`: Required field is missing
- `invalid_value`: Value is invalid
- `constraint_violation`: Business rule violated

**Example**:
```json
{
  "type": "validation_error",
  "subtype": "missing_field",
  "severity": "error",
  "message": "Task entry missing required field: Language",
  "context": {
    "task_number": 258,
    "missing_field": "Language",
    "file": ".opencode/specs/TODO.md"
  },
  "recovery": "Add Language field to task entry"
}
```

### Delegation Errors

**Type**: `delegation_error`

**Subtypes**:
- `cycle_detected`: Delegation cycle detected
- `max_depth_exceeded`: Delegation depth limit exceeded
- `timeout`: Delegation timed out
- `agent_not_found`: Target agent doesn't exist

**Example**:
```json
{
  "type": "delegation_error",
  "subtype": "timeout",
  "severity": "error",
  "message": "Delegation timed out after 3600s",
  "context": {
    "session_id": "sess_20260103_abc123",
    "agent": "researcher",
    "timeout": 3600,
    "elapsed": 3601
  },
  "recovery": "Retry with longer timeout or break into smaller tasks"
}
```

### Integration Errors

**Type**: `integration_error`

**Subtypes**:
- `api_error`: External API call failed
- `tool_error`: Tool invocation failed
- `network_error`: Network connectivity issue

**Example**:
```json
{
  "type": "integration_error",
  "subtype": "api_error",
  "severity": "warning",
  "message": "LeanSearch API returned 500 error",
  "context": {
    "api": "leansearch",
    "endpoint": "/search",
    "status_code": 500
  },
  "recovery": "Retry with exponential backoff or use fallback search"
}
```

## Error Severities

### Critical
- System cannot continue
- Data loss risk
- Immediate intervention required
- Examples: disk full, permission denied on critical files

### Error
- Operation failed
- User action blocked
- Workflow cannot proceed
- Examples: task not found, validation failed, delegation timeout

### Warning
- Operation succeeded with issues
- Degraded functionality
- User should be aware
- Examples: API rate limit, slow response, deprecated feature

### Info
- Informational message
- No action required
- Useful for debugging
- Examples: cache miss, fallback used, retry succeeded

## Structured Error Format

All errors MUST follow this format:

```json
{
  "type": "error_type",
  "subtype": "error_subtype",
  "severity": "critical|error|warning|info",
  "message": "Human-readable error message",
  "context": {
    "key": "value",
    ...
  },
  "recovery": "Suggested recovery action",
  "timestamp": "2026-01-03T10:00:00Z",
  "session_id": "sess_20260103_abc123",
  "agent": "researcher",
  "task_number": 258
}
```

## Error Handling Patterns

### Retry with Exponential Backoff

For transient errors (network, API):

```python
def retry_with_backoff(func, max_retries=3, base_delay=1):
    for attempt in range(max_retries):
        try:
            return func()
        except TransientError as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            time.sleep(delay)
```

### Circuit Breaker

For repeated failures:

```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half-open
    
    def call(self, func):
        if self.state == "open":
            if time.time() - self.last_failure_time > self.timeout:
                self.state = "half-open"
            else:
                raise CircuitOpenError("Circuit breaker is open")
        
        try:
            result = func()
            if self.state == "half-open":
                self.state = "closed"
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            if self.failure_count >= self.failure_threshold:
                self.state = "open"
            raise
```

### Graceful Degradation

For non-critical failures:

```python
def search_with_fallback(query):
    try:
        # Try primary search (LeanSearch API)
        return leansearch_api.search(query)
    except APIError as e:
        log_warning("LeanSearch API failed, using fallback", error=e)
        # Fallback to local search
        return local_search(query)
```
```

**Estimated Size**: ~150 lines

**Benefits**:
- Consistent error handling
- Better error analysis
- Actionable recovery guidance

#### 3.2 Create Error Metrics Dashboard

**File**: `.opencode/scripts/error_metrics.py`

**Purpose**: Generate error metrics and trends.

**Features**:
- Error rate by type
- Error severity distribution
- Top failing operations
- Error trends over time
- Recovery success rate

**Output**:
```
Error Metrics Dashboard
=======================

Period: Last 7 days

Error Rate:
-----------
Total Errors: 42
Critical: 2 (5%)
Error: 15 (36%)
Warning: 20 (48%)
Info: 5 (12%)

Top Error Types:
----------------
1. delegation_error.timeout: 12 (29%)
2. validation_error.missing_field: 8 (19%)
3. integration_error.api_error: 6 (14%)
4. system_error.file_not_found: 5 (12%)
5. Other: 11 (26%)

Top Failing Operations:
-----------------------
1. /research: 15 errors
2. /implement: 10 errors
3. /plan: 8 errors
4. /review: 5 errors
5. /errors: 4 errors

Recovery Success Rate:
----------------------
Attempted: 30
Succeeded: 24 (80%)
Failed: 6 (20%)

Trends:
-------
Day 1: 8 errors
Day 2: 6 errors
Day 3: 5 errors
Day 4: 7 errors
Day 5: 6 errors
Day 6: 5 errors
Day 7: 5 errors

Trend: Stable (no significant increase/decrease)
```

**Estimated Size**: ~250 lines

**Benefits**:
- Visibility into error patterns
- Identify problem areas
- Track improvement over time

#### 3.3 Create Self-Healing Utilities

**File**: `.opencode/scripts/self_healing.py`

**Purpose**: Automatic recovery from common errors.

**Features**:

```python
class SelfHealing:
    """Self-healing utilities for common errors."""
    
    def heal_missing_file(self, file_path: str, file_type: str):
        """Create missing file from template."""
        if file_type == "TODO.md":
            self.create_todo_from_template()
        elif file_type == "state.json":
            self.create_state_from_template()
        elif file_type == "context_file":
            self.create_context_from_template(file_path)
    
    def heal_invalid_format(self, file_path: str, expected_format: str):
        """Fix invalid file format."""
        if expected_format == "yaml":
            self.fix_yaml_syntax(file_path)
        elif expected_format == "json":
            self.fix_json_syntax(file_path)
    
    def heal_missing_field(self, file_path: str, field: str, default_value: Any):
        """Add missing field with default value."""
        if file_path.endswith(".json"):
            self.add_json_field(file_path, field, default_value)
        elif file_path.endswith(".md"):
            self.add_markdown_field(file_path, field, default_value)
    
    def heal_delegation_timeout(self, session_id: str):
        """Recover from delegation timeout."""
        # Check if partial results exist
        partial_results = self.get_partial_results(session_id)
        if partial_results:
            # Resume from partial results
            return self.resume_from_partial(session_id, partial_results)
        else:
            # Retry with longer timeout
            return self.retry_with_longer_timeout(session_id)
```

**Estimated Size**: ~300 lines

**Benefits**:
- Automatic recovery from common errors
- Reduced manual intervention
- Improved system reliability

### Deliverables

- [ ] New standard: `error-taxonomy.md` (~150 lines)
- [ ] New script: `error_metrics.py` (~250 lines)
- [ ] New script: `self_healing.py` (~300 lines)
- [ ] Error dashboard integration
- [ ] Self-healing documentation

### Testing

- [ ] Test error taxonomy with real errors
- [ ] Generate error metrics report
- [ ] Test self-healing for common errors
- [ ] Measure recovery success rate

---

## Improvement Area 4: Performance Monitoring

### Current State Analysis

**Strengths**:
- Context loading strategy defined
- Timeout enforcement in place
- Session tracking

**Gaps**:

1. **No Performance Metrics**
   - No timing data collected
   - No context size tracking
   - No memory usage monitoring

2. **No Performance Baselines**
   - No benchmarks for comparison
   - No regression detection
   - No performance goals

3. **No Observability**
   - No real-time monitoring
   - No performance dashboards
   - No alerting on slow operations

### Proposed Improvements

#### 4.1 Create Performance Instrumentation

**File**: `.opencode/scripts/performance_monitor.py`

**Purpose**: Collect performance metrics during execution.

**Metrics to Collect**:

```python
class PerformanceMonitor:
    """Collect performance metrics."""
    
    def __init__(self):
        self.metrics = {
            "orchestrator_routing_time": [],
            "context_loading_time": [],
            "context_size_bytes": [],
            "delegation_time": [],
            "subagent_execution_time": [],
            "artifact_creation_time": [],
            "status_update_time": [],
            "git_commit_time": [],
            "total_workflow_time": []
        }
    
    def record_timing(self, operation: str, duration: float):
        """Record timing for operation."""
        if operation in self.metrics:
            self.metrics[operation].append(duration)
    
    def record_size(self, metric: str, size: int):
        """Record size metric."""
        if metric in self.metrics:
            self.metrics[metric].append(size)
    
    def get_stats(self, metric: str) -> Dict:
        """Get statistics for metric."""
        values = self.metrics.get(metric, [])
        if not values:
            return {}
        
        return {
            "count": len(values),
            "min": min(values),
            "max": max(values),
            "mean": sum(values) / len(values),
            "median": sorted(values)[len(values) // 2],
            "p95": sorted(values)[int(len(values) * 0.95)],
            "p99": sorted(values)[int(len(values) * 0.99)]
        }
```

**Estimated Size**: ~200 lines

**Benefits**:
- Real-time performance data
- Identify bottlenecks
- Track improvements

#### 4.2 Create Performance Dashboard

**File**: `.opencode/scripts/performance_dashboard.py`

**Purpose**: Visualize performance metrics.

**Output**:
```
Performance Dashboard
=====================

Orchestrator Routing:
---------------------
Count: 150
Mean: 0.45s
Median: 0.42s
P95: 0.78s
P99: 1.2s
Status: ✓ Within budget (<1s)

Context Loading:
----------------
Count: 150
Mean: 8.2KB
Median: 7.8KB
P95: 9.5KB
P99: 9.8KB
Status: ✓ Within budget (<10KB)

Subagent Execution:
-------------------
researcher:
  Count: 50
  Mean: 45s
  Median: 42s
  P95: 58s
  P99: 62s
  Status: ✓ Within budget (<60s)

planner:
  Count: 40
  Mean: 25s
  Median: 23s
  P95: 32s
  P99: 35s
  Status: ✓ Within budget (<30s)

implementer:
  Count: 35
  Mean: 120s
  Median: 115s
  P95: 145s
  P99: 150s
  Status: ✓ Within budget (<120s)

Total Workflow Time:
--------------------
/research:
  Mean: 52s
  P95: 65s
  Status: ✓ Within budget (<60s)

/plan:
  Mean: 30s
  P95: 38s
  Status: ✓ Within budget (<30s)

/implement:
  Mean: 135s
  P95: 160s
  Status: ⚠ Approaching budget (120s)

Recommendations:
----------------
1. Optimize implementer execution time (approaching budget)
2. Monitor context loading (trending upward)
3. Consider caching for repeated operations
```

**Estimated Size**: ~250 lines

**Benefits**:
- Visual performance overview
- Identify performance regressions
- Track against budgets

#### 4.3 Create Performance Baselines

**File**: `.opencode/specs/PERFORMANCE_BASELINES.md`

**Purpose**: Document performance goals and baselines.

**Content**:
```markdown
# Performance Baselines

## Orchestrator

| Metric | Target | P95 | P99 | Status |
|--------|--------|-----|-----|--------|
| Routing Time | <1s | 0.78s | 1.2s | ✓ |
| Context Size | <10KB | 9.5KB | 9.8KB | ✓ |

## Commands

| Command | Target | P95 | P99 | Status |
|---------|--------|-----|-----|--------|
| /research | <60s | 65s | 72s | ⚠ |
| /plan | <30s | 38s | 42s | ⚠ |
| /implement | <120s | 160s | 180s | ⚠ |
| /review | <60s | 55s | 58s | ✓ |

## Subagents

| Agent | Target | P95 | P99 | Status |
|-------|--------|-----|-----|--------|
| researcher | <60s | 58s | 62s | ✓ |
| planner | <30s | 32s | 35s | ⚠ |
| implementer | <120s | 145s | 150s | ⚠ |

## Context Loading

| Agent | Target | P95 | P99 | Status |
|-------|--------|-----|-----|--------|
| orchestrator | <10KB | 9.5KB | 9.8KB | ✓ |
| researcher | <50KB | 48KB | 49KB | ✓ |
| planner | <50KB | 52KB | 54KB | ⚠ |
| implementer | <50KB | 51KB | 53KB | ⚠ |
```

**Estimated Size**: ~100 lines

**Benefits**:
- Clear performance goals
- Track against baselines
- Identify regressions

### Deliverables

- [ ] New script: `performance_monitor.py` (~200 lines)
- [ ] New script: `performance_dashboard.py` (~250 lines)
- [ ] New doc: `PERFORMANCE_BASELINES.md` (~100 lines)
- [ ] Performance monitoring integration
- [ ] Baseline measurements for all operations

### Testing

- [ ] Collect baseline metrics
- [ ] Generate performance dashboard
- [ ] Identify performance bottlenecks
- [ ] Set performance goals

---

## Improvement Area 5: Context File Consolidation

### Current State Analysis

**Strengths**:
- Task 246 achieved 72% reduction (3,715 → 1,045 lines)
- Clear core/ vs project/ separation
- Good context index

**Opportunities**:

1. **Task 267: Integrate context/meta/ into context/core/**
   - 4 meta files need proper organization
   - References need updating
   - Directory cleanup needed

2. **Duplicate Content**
   - Some standards duplicated across files
   - Inconsistent terminology
   - Opportunity for further consolidation

3. **Context File Sizes**
   - Some files approaching 300 lines
   - Could be split for better modularity
   - Opportunity for optimization

### Proposed Improvements

#### 5.1 Complete Task 267

**Goal**: Integrate context/meta/ into context/core/ with proper organization.

**Analysis**:

```
Current meta/ files:
- interview-patterns.md (5171 bytes) → core/workflows/interview-patterns.md
- architecture-principles.md (6641 bytes) → core/standards/architecture-principles.md
- domain-patterns.md (5781 bytes) → core/patterns/domain-patterns.md
- agent-templates.md (7254 bytes) → core/templates/agent-templates.md
```

**Migration Plan**:

1. **Move files**:
   ```bash
   mv context/meta/interview-patterns.md context/core/workflows/
   mv context/meta/architecture-principles.md context/core/standards/
   mv context/meta/domain-patterns.md context/core/patterns/
   mv context/meta/agent-templates.md context/core/templates/
   ```

2. **Update references**:
   - command/meta.md frontmatter
   - agent/subagents/meta/*.md (5 files)
   - context/index.md
   - README.md

3. **Remove empty directory**:
   ```bash
   rmdir context/meta/
   ```

4. **Validate**:
   ```bash
   grep -r "context/meta/" .opencode/
   # Should return no results
   ```

**Estimated Effort**: 2-3 hours

**Benefits**:
- Consistent directory structure
- Easier to find context files
- Follows core/ vs project/ convention

#### 5.2 Audit for Duplicate Content

**Script**: `.opencode/scripts/audit_duplicates.py`

**Purpose**: Find duplicate content across context files.

**Features**:
- Detect duplicate paragraphs
- Find inconsistent terminology
- Identify consolidation opportunities

**Output**:
```
Duplicate Content Audit
=======================

Duplicate Paragraphs:
---------------------
1. "All subagents return a consistent JSON format..." (3 occurrences)
   - core/standards/delegation.md:45
   - core/standards/subagent-return-format.md:12
   - ARCHITECTURE.md:54
   
   Recommendation: Keep in delegation.md, reference from others

2. "Status markers follow a standard format..." (2 occurrences)
   - core/system/state-management.md:23
   - common/standards/tasks.md:67
   
   Recommendation: Keep in state-management.md, reference from tasks.md

Inconsistent Terminology:
-------------------------
1. "subagent" vs "sub-agent" (mixed usage)
   Files: 12 files use "subagent", 3 files use "sub-agent"
   Recommendation: Standardize on "subagent"

2. "TODO.md" vs "TODO" (mixed usage)
   Files: 8 files use "TODO.md", 5 files use "TODO"
   Recommendation: Standardize on "TODO.md"

Consolidation Opportunities:
----------------------------
1. Error handling patterns duplicated across 4 files
   Total size: 450 lines
   Potential consolidation: Create error-handling.md standard
   Estimated savings: 300 lines

2. Git commit patterns duplicated across 3 files
   Total size: 120 lines
   Potential consolidation: Already exists in git-commits.md
   Estimated savings: 80 lines
```

**Estimated Size**: ~200 lines

**Benefits**:
- Identify consolidation opportunities
- Reduce duplication
- Improve consistency

#### 5.3 Split Large Context Files

**Goal**: Split files >250 lines into smaller, focused files.

**Candidates**:

```
Files >250 lines:
- core/standards/delegation.md (510 lines)
  → Split into: delegation-patterns.md, return-format.md, session-tracking.md
  
- core/system/state-management.md (535 lines)
  → Split into: status-markers.md, state-schemas.md, status-sync.md
  
- common/workflows/task-breakdown.md (270 lines)
  → Split into: task-decomposition.md, phase-planning.md
```

**Benefits**:
- Easier to navigate
- Faster to load
- More modular

**Trade-offs**:
- More files to manage
- More references to update
- May increase complexity

**Recommendation**: Only split if clear benefit (e.g., different agents load different parts).

### Deliverables

- [ ] Complete Task 267 (meta/ integration)
- [ ] New script: `audit_duplicates.py` (~200 lines)
- [ ] Duplicate content audit report
- [ ] Consolidation plan for duplicates
- [ ] Decision on splitting large files

### Testing

- [ ] Verify no broken references after Task 267
- [ ] Test /meta command still works
- [ ] Run duplicate audit
- [ ] Review consolidation opportunities

---

## Improvement Area 6: Documentation Completeness

### Current State Analysis

**Strengths**:
- Good ARCHITECTURE.md
- Clear README.md
- Migration docs with ADRs

**Gaps**:

1. **Missing Guides**
   - No troubleshooting guide
   - No performance tuning guide
   - No security guide

2. **Incomplete References**
   - No complete command reference
   - No complete agent reference
   - No complete context file reference

3. **No Examples**
   - Few real-world examples
   - No case studies
   - No best practices guide

### Proposed Improvements

#### 6.1 Create Troubleshooting Guide

**File**: `.opencode/docs/TROUBLESHOOTING.md`

**Content**:
```markdown
# Troubleshooting Guide

## Common Issues

### Issue: Command not found

**Symptom**: `Error: Command /{command} not found`

**Cause**: Command file doesn't exist at `.opencode/command/{command}.md`

**Solution**:
1. Check command file exists: `ls .opencode/command/{command}.md`
2. If missing, create using command template
3. Verify frontmatter is valid YAML

### Issue: Task not found

**Symptom**: `Error: Task {number} not found in TODO.md`

**Cause**: Task doesn't exist or TODO.md is corrupted

**Solution**:
1. Verify task exists: `grep "^### {number}\." .opencode/specs/TODO.md`
2. If missing, create task with `/task` command
3. If TODO.md corrupted, restore from git

### Issue: Delegation timeout

**Symptom**: `Warning: Delegation timed out after {timeout}s`

**Cause**: Subagent took too long to complete

**Solution**:
1. Check if partial results exist
2. Resume with same command
3. If repeated, increase timeout in command frontmatter
4. Consider breaking task into smaller pieces

[... more issues ...]
```

**Estimated Size**: ~300 lines

**Benefits**:
- Faster problem resolution
- Reduced support burden
- Better user experience

#### 6.2 Create Complete Command Reference

**File**: `.opencode/docs/COMMAND_REFERENCE.md`

**Content**:
```markdown
# Command Reference

## /research

**Purpose**: Conduct research and create reports

**Usage**: `/research TASK_NUMBER [PROMPT]`

**Arguments**:
- `TASK_NUMBER` (required): Task number from TODO.md
- `PROMPT` (optional): Custom research focus

**Examples**:
```bash
/research 258
/research 258 "Focus on API integration"
/research 258 --divide
```

**Routing**: Language-based (lean → lean-research-agent, default → researcher)

**Timeout**: 3600s (1 hour)

**Artifacts**:
- Research report: `.opencode/specs/{number}_{slug}/reports/research-001.md`
- Summary: `.opencode/specs/{number}_{slug}/summaries/research-summary.md`

**Status Transitions**:
- [NOT STARTED] → [RESEARCHING] → [RESEARCHED]

**See Also**: researcher.md, lean-research-agent.md

---

[... all other commands ...]
```

**Estimated Size**: ~400 lines

**Benefits**:
- Complete command documentation
- Easy reference
- Consistent format

#### 6.3 Create Best Practices Guide

**File**: `.opencode/docs/BEST_PRACTICES.md`

**Content**:
```markdown
# Best Practices Guide

## Task Management

### Create Atomic Tasks

**Good**:
```
/task "Add Language field validation to /task command"
```

**Bad**:
```
/task "Improve task management system"
```

**Why**: Atomic tasks are easier to research, plan, and implement.

### Use Descriptive Task Titles

**Good**:
```
/task "Implement LeanSearch REST API integration for proof search"
```

**Bad**:
```
/task "Add search"
```

**Why**: Descriptive titles make tasks easier to understand and search.

[... more best practices ...]
```

**Estimated Size**: ~250 lines

**Benefits**:
- Guidance for new users
- Consistent usage patterns
- Better outcomes

### Deliverables

- [ ] New guide: `TROUBLESHOOTING.md` (~300 lines)
- [ ] New reference: `COMMAND_REFERENCE.md` (~400 lines)
- [ ] New guide: `BEST_PRACTICES.md` (~250 lines)
- [ ] Update README with links to new docs

### Testing

- [ ] Review guides with users
- [ ] Verify all examples work
- [ ] Get feedback on clarity

---

## Improvement Area 7: Developer Experience Tools

### Current State Analysis

**Strengths**:
- Good validation scripts
- Clear templates
- Helpful error messages

**Gaps**:

1. **No Development Utilities**
   - No command generator
   - No agent generator
   - No context file generator

2. **No Debugging Tools**
   - No session inspector
   - No delegation tracer
   - No context visualizer

3. **No Productivity Tools**
   - No command aliases
   - No quick commands
   - No workflow shortcuts

### Proposed Improvements

#### 7.1 Create Command Generator

**File**: `.opencode/scripts/generate_command.py`

**Purpose**: Generate new command from template.

**Usage**:
```bash
python3 .opencode/scripts/generate_command.py \
  --name analyze \
  --description "Analyze codebase for patterns" \
  --type direct \
  --agent analyzer \
  --timeout 1800
```

**Output**: Creates `.opencode/command/analyze.md` with proper frontmatter and structure.

**Estimated Size**: ~150 lines

**Benefits**:
- Faster command creation
- Consistent structure
- Reduced errors

#### 7.2 Create Session Inspector

**File**: `.opencode/scripts/inspect_session.py`

**Purpose**: Inspect active and historical sessions.

**Usage**:
```bash
python3 .opencode/scripts/inspect_session.py sess_20260103_abc123
```

**Output**:
```
Session: sess_20260103_abc123
==============================

Status: completed
Command: /research
Subagent: researcher
Task: 258

Timeline:
---------
2026-01-03 10:00:00 - Session started
2026-01-03 10:00:01 - Routing completed (1s)
2026-01-03 10:00:02 - Delegation started
2026-01-03 10:00:45 - Research completed (43s)
2026-01-03 10:00:46 - Artifacts created (1s)
2026-01-03 10:00:48 - Status updated (2s)
2026-01-03 10:00:50 - Git commit created (2s)
2026-01-03 10:00:51 - Session completed (51s total)

Artifacts:
----------
- .opencode/specs/258_test_task/reports/research-001.md (2.5KB)
- .opencode/specs/258_test_task/summaries/research-summary.md (0.5KB)

Performance:
------------
Total time: 51s
Routing: 1s (2%)
Execution: 43s (84%)
Artifacts: 1s (2%)
Status update: 2s (4%)
Git commit: 2s (4%)
```

**Estimated Size**: ~200 lines

**Benefits**:
- Debug session issues
- Understand performance
- Track delegation flow

#### 7.3 Create Quick Commands

**File**: `.opencode/scripts/quick.sh`

**Purpose**: Shortcuts for common operations.

**Usage**:
```bash
# Quick research
./quick.sh research 258

# Quick plan
./quick.sh plan 258

# Quick implement
./quick.sh implement 258

# Quick status
./quick.sh status 258

# Quick errors
./quick.sh errors
```

**Estimated Size**: ~100 lines

**Benefits**:
- Faster workflows
- Less typing
- Better productivity

### Deliverables

- [ ] New script: `generate_command.py` (~150 lines)
- [ ] New script: `inspect_session.py` (~200 lines)
- [ ] New script: `quick.sh` (~100 lines)
- [ ] Documentation for new tools

### Testing

- [ ] Test command generator
- [ ] Test session inspector
- [ ] Test quick commands
- [ ] Get user feedback

---

## Implementation Roadmap

### Phase 1: Subagent Standardization (Week 1)
- [ ] Create subagent-input-parsing.md
- [ ] Create subagent-workflow-stages.md
- [ ] Update validate_frontmatter.py
- [ ] Create audit_subagents.py
- [ ] Run audit and fix top issues

### Phase 2: Validation & Testing (Week 2)
- [ ] Create test_integration.py
- [ ] Create test_commands.py
- [ ] Create test_subagents.py
- [ ] Create test_performance.py
- [ ] Achieve 80% test coverage

### Phase 3: Error Handling (Week 3)
- [ ] Create error-taxonomy.md
- [ ] Create error_metrics.py
- [ ] Create self_healing.py
- [ ] Test error recovery

### Phase 4: Performance Monitoring (Week 4)
- [ ] Create performance_monitor.py
- [ ] Create performance_dashboard.py
- [ ] Create PERFORMANCE_BASELINES.md
- [ ] Collect baseline metrics

### Phase 5: Context Consolidation (Week 5)
- [ ] Complete Task 267
- [ ] Create audit_duplicates.py
- [ ] Run duplicate audit
- [ ] Consolidate duplicates

### Phase 6: Documentation (Week 6)
- [ ] Create TROUBLESHOOTING.md
- [ ] Create COMMAND_REFERENCE.md
- [ ] Create BEST_PRACTICES.md
- [ ] Update README

### Phase 7: Developer Tools (Week 7)
- [ ] Create generate_command.py
- [ ] Create inspect_session.py
- [ ] Create quick.sh
- [ ] Document tools

---

## Success Metrics

### Subagent Standardization
- [ ] 100% of subagents follow input parsing standard
- [ ] 100% of subagents follow workflow stage standard
- [ ] 0 frontmatter validation errors

### Validation & Testing
- [ ] 80% test coverage for critical paths
- [ ] 100% of commands have integration tests
- [ ] 100% of subagents have unit tests

### Error Handling
- [ ] 90% of errors follow taxonomy
- [ ] 80% recovery success rate
- [ ] 50% reduction in manual interventions

### Performance Monitoring
- [ ] 100% of operations have baselines
- [ ] Real-time performance dashboard
- [ ] 0 performance regressions

### Context Consolidation
- [ ] Task 267 completed
- [ ] 30% reduction in duplicate content
- [ ] All files <300 lines

### Documentation
- [ ] 100% of commands documented
- [ ] 100% of common issues in troubleshooting guide
- [ ] 10+ best practices documented

### Developer Tools
- [ ] 50% faster command creation
- [ ] 100% of sessions inspectable
- [ ] 5+ quick commands available

---

## Conclusion

These 7 additional improvement areas build on the foundation of SYSTEM_IMPROVEMENT_PLAN_v2.md to create a more robust, maintainable, and developer-friendly .opencode system.

**Total Estimated Effort**: 7 weeks (1 week per area)

**Total New Files**: ~20 files
**Total New Lines**: ~3,500 lines
**Total Scripts**: ~10 scripts

**Expected Benefits**:
- 50% reduction in subagent inconsistencies
- 80% test coverage for critical paths
- 90% reduction in unhandled errors
- Real-time performance visibility
- 30% faster onboarding for new developers

**Next Steps**:
1. Review this plan
2. Prioritize improvement areas
3. Start with Phase 1 (Subagent Standardization)
4. Iterate based on feedback
