# Research Report: Comprehensive Testing and Validation Methodologies

**Task**: 250 - Phase 2 Follow-up: Comprehensive Testing and Validation  
**Date**: 2024-12-29  
**Researcher**: OpenCode Research Agent  
**Session ID**: sess_1767023412_r250md

---

## Executive Summary

This research report provides comprehensive findings on testing methodologies, validation approaches, and best practices for ensuring 100% Stage 7 execution reliability in workflow command systems. The research covers seven key areas: testing methodologies, execution reliability measurement, context window profiling, code maintainability metrics, delegation safety patterns, automated test suite design, and metrics comparison methodologies.

**Key Findings**:
- The Testing Pyramid (70/20/10 split) provides optimal balance between speed, reliability, and coverage
- Context window management requires strategic artifact handling and metadata-based communication
- Delegation safety requires registry tracking, cycle detection, and timeout enforcement
- Parametrized testing frameworks enable efficient multi-command validation
- CI/CD pipelines provide automated reliability measurement and feedback loops

---

## 1. Testing Methodologies for Multi-Command Workflow Systems

### 1.1 The Testing Pyramid

The Testing Pyramid, introduced by Mike Cohn and refined by Martin Fowler, provides a foundational framework for test distribution:

**Recommended Distribution**:
- **70% Unit Tests**: Fast, isolated, testing individual components
- **20% Integration Tests**: Testing component interactions
- **10% End-to-End Tests**: Testing complete user workflows

**Source**: Martin Fowler - "The Practical Test Pyramid" (2018)

### 1.2 Test Pyramid Applied to Workflow Commands

For workflow command systems (/research, /plan, /implement, /revise):

**Unit Tests (70%)**:
- Individual command parser validation
- Stage transition logic
- Artifact generation functions
- Error handling routines
- Input validation
- Output formatting

**Integration Tests (20%)**:
- Command-to-orchestrator communication
- Artifact persistence and retrieval
- Delegation chain validation
- Registry state management
- Context window handling

**End-to-End Tests (10%)**:
- Complete command execution flows
- Multi-command workflows
- Real artifact generation
- Full delegation chains
- Production-like scenarios

### 1.3 Anti-Patterns to Avoid

**Ice Cream Cone** (Inverted Pyramid):
- Too many E2E tests
- Few integration tests
- Minimal unit tests
- Result: Slow, brittle, expensive

**Hourglass**:
- Many unit tests
- Few integration tests
- Many E2E tests
- Result: Missing integration bugs

**Source**: Google Testing Blog - "Just Say No to More End-to-End Tests" (2015)

### 1.4 Test Design Principles

**FIRST Principles** (for unit tests):
- **F**ast: < 0.1 seconds per test
- **I**solated: No dependencies between tests
- **R**epeatable: Same results every time
- **S**elf-validating: Pass/fail without manual inspection
- **T**imely: Written before or with production code

**Arrange-Act-Assert Pattern**:
```python
def test_research_command():
    # Arrange
    task = create_test_task(number=250)
    
    # Act
    result = execute_research_command(task)
    
    # Assert
    assert result.status == "completed"
    assert len(result.artifacts) > 0
```

---

## 2. Stage 7 Execution Reliability Measurement

### 2.1 Reliability Metrics

**Primary Metric**: Stage 7 Completion Rate
```
Completion Rate = (Successful Stage 7 Executions / Total Attempts) × 100%
Target: 100%
```

**Supporting Metrics**:
- **Mean Time Between Failures (MTBF)**: Time between Stage 7 failures
- **Mean Time To Recovery (MTTR)**: Time to fix Stage 7 failures
- **Error Rate by Stage**: Failures at each stage (1-7)
- **Retry Success Rate**: Success after retry attempts

### 2.2 Measurement Approaches

**Automated Test Runs**:
- 80 total test runs (20 per command)
- Randomized execution order
- Varied input scenarios
- Isolated test environments

**Continuous Monitoring**:
- Real-time execution tracking
- Stage transition logging
- Error capture and classification
- Performance metrics collection

**Statistical Analysis**:
- Confidence intervals (95% CI)
- Standard deviation calculation
- Outlier detection
- Trend analysis

### 2.3 Reliability Testing Framework

**Test Suite Structure**:
```
tests/
├── unit/
│   ├── test_research_parser.py
│   ├── test_plan_generator.py
│   ├── test_implement_executor.py
│   └── test_revise_validator.py
├── integration/
│   ├── test_orchestrator_integration.py
│   ├── test_artifact_handling.py
│   └── test_delegation_chain.py
└── e2e/
    ├── test_research_workflow.py
    ├── test_plan_workflow.py
    ├── test_implement_workflow.py
    └── test_revise_workflow.py
```

**Parametrized Testing** (pytest):
```python
@pytest.mark.parametrize("command,task_number,expected_artifacts", [
    ("research", 250, 1),
    ("plan", 251, 2),
    ("implement", 252, 3),
    ("revise", 253, 1),
])
def test_command_execution(command, task_number, expected_artifacts):
    result = execute_command(command, task_number)
    assert result.status == "completed"
    assert len(result.artifacts) == expected_artifacts
```

**Source**: pytest Documentation - "How to parametrize fixtures and test functions"

---

## 3. Context Window Usage Profiling and Optimization

### 3.1 Context Window Challenges

**Problem**: Large language models have limited context windows (e.g., 200K tokens)

**Challenges in Workflow Systems**:
- Orchestrator context accumulation
- Artifact content duplication
- Delegation chain overhead
- Return object verbosity

### 3.2 Measurement Techniques

**Token Counting**:
```python
def measure_context_usage(content: str) -> dict:
    """Measure token usage for content."""
    tokens = count_tokens(content)
    return {
        "tokens": tokens,
        "percentage": (tokens / MAX_CONTEXT) * 100,
        "remaining": MAX_CONTEXT - tokens
    }
```

**Profiling Points**:
- Before command invocation
- After artifact generation
- During delegation
- At return object creation
- Post-orchestrator processing

### 3.3 Optimization Strategies

**Artifact Management** (from research):
- Store artifacts on disk, not in memory
- Pass file paths instead of content
- Use metadata summaries (< 100 tokens)
- Lazy loading when needed

**Return Object Optimization**:
```json
{
  "status": "completed",
  "summary": "Brief 3-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "research",
      "path": ".opencode/specs/250/reports/research-001.md",
      "summary": "One-line description"
    }
  ]
}
```

**Context Window Protection**:
- Metadata-based communication
- Artifact references, not content
- Compressed summaries
- Selective information passing

**Source**: OpenAI Research - "Techniques for training large neural networks" (2021)

---

## 4. Code Maintainability Metrics

### 4.1 Line Count Validation

**Target Metrics**:
- Orchestrator: < 100 lines
- Command files: Target line counts (varies by command)
- Support modules: < 200 lines per module

**Measurement Tools**:
```bash
# Count lines in orchestrator
wc -l .opencode/commands/orchestrator.py

# Count lines in all command files
find .opencode/commands -name "*.py" -exec wc -l {} +

# Generate report
cloc .opencode/commands --by-file
```

### 4.2 Complexity Metrics

**Cyclomatic Complexity**:
- Target: < 10 per function
- Tool: `radon` (Python)
- Command: `radon cc .opencode/commands -a`

**Maintainability Index**:
- Target: > 65 (good maintainability)
- Range: 0-100 (higher is better)
- Tool: `radon mi .opencode/commands`

**Halstead Metrics**:
- Program length
- Vocabulary size
- Volume
- Difficulty
- Effort

### 4.3 Code Quality Standards

**PEP 8 Compliance** (Python):
- Line length: < 88 characters (Black formatter)
- Function length: < 50 lines
- Class length: < 300 lines
- Module length: < 500 lines

**Documentation Coverage**:
- Docstrings for all public functions
- Type hints for parameters
- Return type annotations
- Example usage in docstrings

**Test Coverage**:
- Target: > 80% line coverage
- Critical paths: 100% coverage
- Tool: `pytest-cov`

---

## 5. Delegation Safety Validation Patterns

### 5.1 Registry Tracking

**Purpose**: Prevent infinite delegation loops and track delegation chains

**Implementation**:
```python
class DelegationRegistry:
    """Track active delegations to prevent cycles."""
    
    def __init__(self):
        self.active_delegations = {}
        self.max_depth = 3
    
    def register(self, session_id: str, agent: str, depth: int):
        """Register a new delegation."""
        if depth > self.max_depth:
            raise DelegationDepthExceeded(
                f"Max depth {self.max_depth} exceeded"
            )
        
        self.active_delegations[session_id] = {
            "agent": agent,
            "depth": depth,
            "timestamp": time.time()
        }
    
    def check_cycle(self, session_id: str, agent: str) -> bool:
        """Check if delegation would create a cycle."""
        if session_id in self.active_delegations:
            if self.active_delegations[session_id]["agent"] == agent:
                return True
        return False
```

### 5.2 Cycle Detection

**Graph-Based Detection**:
```python
def detect_delegation_cycle(delegation_path: list) -> bool:
    """Detect cycles in delegation chain using graph traversal."""
    visited = set()
    
    for agent in delegation_path:
        if agent in visited:
            return True  # Cycle detected
        visited.add(agent)
    
    return False
```

**Prevention Strategies**:
- Maximum delegation depth (3 levels)
- Agent type restrictions
- Session-based tracking
- Timeout enforcement

### 5.3 Timeout Enforcement

**Timeout Hierarchy**:
```python
TIMEOUTS = {
    "unit_test": 5,        # 5 seconds
    "integration_test": 30, # 30 seconds
    "e2e_test": 300,       # 5 minutes
    "command_execution": 1800,  # 30 minutes
    "total_workflow": 3600      # 1 hour
}
```

**Implementation**:
```python
import signal

def timeout_handler(signum, frame):
    raise TimeoutError("Command execution exceeded timeout")

def execute_with_timeout(func, timeout_seconds):
    """Execute function with timeout."""
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(timeout_seconds)
    
    try:
        result = func()
        signal.alarm(0)  # Cancel alarm
        return result
    except TimeoutError:
        return {"status": "failed", "error": "timeout"}
```

### 5.4 Validation Tests

**Registry Tests**:
```python
def test_delegation_registry_prevents_cycles():
    registry = DelegationRegistry()
    
    # Register first delegation
    registry.register("sess_123", "research", 1)
    
    # Attempt to create cycle
    assert registry.check_cycle("sess_123", "research") == True
    
def test_delegation_depth_limit():
    registry = DelegationRegistry()
    
    with pytest.raises(DelegationDepthExceeded):
        registry.register("sess_456", "plan", 4)  # Exceeds max depth
```

---

## 6. Automated Test Suite Design for 80-Run Validation

### 6.1 Test Suite Architecture

**Test Organization**:
```
tests/
├── conftest.py              # Shared fixtures
├── test_config.py           # Test configuration
├── unit/
│   ├── test_research.py     # 20 unit tests
│   ├── test_plan.py         # 20 unit tests
│   ├── test_implement.py    # 20 unit tests
│   └── test_revise.py       # 20 unit tests
├── integration/
│   └── test_commands.py     # Integration tests
└── e2e/
    └── test_workflows.py    # End-to-end tests
```

### 6.2 Parametrized Test Design

**Command Validation** (20 runs per command):
```python
import pytest

# Test data for 20 runs per command
RESEARCH_TEST_CASES = [
    {"task": 250, "topic": "testing", "expected_artifacts": 1},
    {"task": 251, "topic": "validation", "expected_artifacts": 1},
    # ... 18 more cases
]

@pytest.mark.parametrize("test_case", RESEARCH_TEST_CASES)
def test_research_command(test_case):
    """Test research command with various inputs."""
    result = execute_research(
        task_number=test_case["task"],
        topic=test_case["topic"]
    )
    
    assert result.status == "completed"
    assert len(result.artifacts) == test_case["expected_artifacts"]
    assert result.metadata["validation_result"] == "passed"
```

### 6.3 Test Execution Strategy

**Parallel Execution**:
```bash
# Run tests in parallel (4 workers)
pytest -n 4 tests/

# Run specific command tests
pytest tests/unit/test_research.py -v

# Run with coverage
pytest --cov=.opencode/commands --cov-report=html
```

**Test Isolation**:
- Each test uses unique session ID
- Temporary directories for artifacts
- Clean state before/after tests
- No shared mutable state

### 6.4 Test Reporting

**Metrics to Capture**:
```python
class TestMetrics:
    """Capture test execution metrics."""
    
    def __init__(self):
        self.total_runs = 0
        self.passed = 0
        self.failed = 0
        self.execution_times = []
        self.context_usage = []
        self.errors = []
    
    def record_result(self, result):
        """Record test result."""
        self.total_runs += 1
        if result.status == "passed":
            self.passed += 1
        else:
            self.failed += 1
            self.errors.append(result.error)
        
        self.execution_times.append(result.duration)
        self.context_usage.append(result.context_tokens)
    
    def generate_report(self):
        """Generate test metrics report."""
        return {
            "total_runs": self.total_runs,
            "pass_rate": (self.passed / self.total_runs) * 100,
            "avg_execution_time": sum(self.execution_times) / len(self.execution_times),
            "avg_context_usage": sum(self.context_usage) / len(self.context_usage),
            "errors": self.errors
        }
```

**Source**: pytest Documentation - Parametrization and Test Organization

---

## 7. Metrics Comparison and Reporting Best Practices

### 7.1 Before/After Metrics Framework

**Metrics to Compare**:

| Metric | Before (Phase 1) | After (Phase 2) | Target |
|--------|------------------|-----------------|--------|
| Stage 7 Completion Rate | TBD | TBD | 100% |
| Avg Context Usage | TBD | TBD | < 50% |
| Orchestrator Lines | TBD | < 100 | < 100 |
| Command File Lines | TBD | TBD | Target |
| Test Pass Rate | TBD | TBD | 100% |
| Avg Execution Time | TBD | TBD | < 30s |
| Delegation Depth | TBD | ≤ 3 | ≤ 3 |

### 7.2 Statistical Comparison

**Hypothesis Testing**:
```python
from scipy import stats

def compare_metrics(before: list, after: list) -> dict:
    """Compare before/after metrics using t-test."""
    t_stat, p_value = stats.ttest_ind(before, after)
    
    return {
        "t_statistic": t_stat,
        "p_value": p_value,
        "significant": p_value < 0.05,
        "improvement": (sum(after) / len(after)) - (sum(before) / len(before))
    }
```

**Confidence Intervals**:
```python
def calculate_confidence_interval(data: list, confidence=0.95):
    """Calculate confidence interval for metrics."""
    mean = sum(data) / len(data)
    std_err = stats.sem(data)
    ci = stats.t.interval(confidence, len(data)-1, mean, std_err)
    
    return {
        "mean": mean,
        "ci_lower": ci[0],
        "ci_upper": ci[1],
        "confidence": confidence
    }
```

### 7.3 Visualization and Reporting

**Metrics Dashboard**:
```python
import matplotlib.pyplot as plt

def generate_metrics_dashboard(before, after):
    """Generate visual comparison of metrics."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Completion Rate
    axes[0, 0].bar(["Before", "After"], 
                   [before["completion_rate"], after["completion_rate"]])
    axes[0, 0].set_title("Stage 7 Completion Rate")
    axes[0, 0].set_ylim(0, 100)
    
    # Context Usage
    axes[0, 1].bar(["Before", "After"],
                   [before["context_usage"], after["context_usage"]])
    axes[0, 1].set_title("Average Context Usage (%)")
    
    # Execution Time
    axes[1, 0].bar(["Before", "After"],
                   [before["exec_time"], after["exec_time"]])
    axes[1, 0].set_title("Average Execution Time (s)")
    
    # Test Pass Rate
    axes[1, 1].bar(["Before", "After"],
                   [before["pass_rate"], after["pass_rate"]])
    axes[1, 1].set_title("Test Pass Rate (%)")
    axes[1, 1].set_ylim(0, 100)
    
    plt.tight_layout()
    plt.savefig("metrics_comparison.png")
```

### 7.4 Report Structure

**Comprehensive Metrics Report**:
```markdown
# Phase 2 Validation Report

## Executive Summary
- Total test runs: 80 (20 per command)
- Overall pass rate: X%
- Stage 7 completion rate: X%
- Average context usage: X%

## Detailed Metrics

### Command Performance
| Command | Runs | Pass Rate | Avg Time | Context % |
|---------|------|-----------|----------|-----------|
| /research | 20 | X% | Xs | X% |
| /plan | 20 | X% | Xs | X% |
| /implement | 20 | X% | Xs | X% |
| /revise | 20 | X% | Xs | X% |

### Code Quality
- Orchestrator: X lines (target: < 100)
- Command files: Within targets
- Test coverage: X%
- Complexity: Average X (target: < 10)

### Delegation Safety
- Max depth observed: X (limit: 3)
- Cycles detected: X (target: 0)
- Timeouts: X (target: 0)

## Before/After Comparison
[Statistical analysis and visualizations]

## Recommendations
[Based on findings]
```

---

## 8. CI/CD Integration for Continuous Validation

### 8.1 Continuous Integration Principles

**CI/CD Pipeline Stages**:
1. **Build**: Validate code syntax and dependencies
2. **Test**: Run automated test suite
3. **Analyze**: Code quality and coverage analysis
4. **Deploy**: Deploy to staging/production
5. **Monitor**: Track metrics and errors

**Source**: Atlassian - "Continuous integration vs. delivery vs. deployment"

### 8.2 GitHub Actions Workflow

**Example Workflow** (.github/workflows/test.yml):
```yaml
name: Comprehensive Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov radon
    
    - name: Run unit tests
      run: pytest tests/unit -v --cov
    
    - name: Run integration tests
      run: pytest tests/integration -v
    
    - name: Run E2E tests
      run: pytest tests/e2e -v
    
    - name: Check code quality
      run: |
        radon cc .opencode/commands -a
        radon mi .opencode/commands
    
    - name: Validate line counts
      run: python scripts/validate_line_counts.py
    
    - name: Generate metrics report
      run: python scripts/generate_metrics.py
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

**Source**: GitHub Docs - "Understanding GitHub Actions"

### 8.3 Automated Metrics Collection

**Metrics Collection Script**:
```python
def collect_ci_metrics():
    """Collect metrics during CI run."""
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "commit": os.getenv("GITHUB_SHA"),
        "branch": os.getenv("GITHUB_REF"),
        "test_results": run_tests(),
        "code_quality": analyze_code(),
        "line_counts": count_lines(),
        "coverage": get_coverage()
    }
    
    # Save to metrics database
    save_metrics(metrics)
    
    # Generate trend report
    generate_trend_report(metrics)
```

---

## 9. Recommendations

### 9.1 Immediate Actions

1. **Implement Testing Pyramid**:
   - Create 70% unit tests for all commands
   - Add 20% integration tests for orchestrator
   - Maintain 10% E2E tests for workflows

2. **Set Up Parametrized Tests**:
   - Configure pytest with 20 test cases per command
   - Use fixtures for common test data
   - Enable parallel execution

3. **Establish Metrics Baseline**:
   - Measure current Stage 7 completion rate
   - Profile context window usage
   - Count lines in all command files

4. **Implement Delegation Safety**:
   - Add delegation registry
   - Implement cycle detection
   - Enforce timeout limits

### 9.2 Testing Strategy

**Phase 1: Unit Testing** (Week 1)
- Write unit tests for all command parsers
- Test artifact generation functions
- Validate error handling

**Phase 2: Integration Testing** (Week 2)
- Test orchestrator integration
- Validate delegation chains
- Test artifact persistence

**Phase 3: E2E Testing** (Week 3)
- Create workflow test scenarios
- Test multi-command sequences
- Validate production-like conditions

**Phase 4: Metrics Collection** (Week 4)
- Run 80-test validation suite
- Collect all metrics
- Generate comparison report

### 9.3 Success Criteria

**Must Achieve**:
- [ ] 100% Stage 7 completion rate (80/80 tests)
- [ ] Orchestrator < 100 lines
- [ ] All command files within target line counts
- [ ] Zero delegation cycles detected
- [ ] Zero timeout violations
- [ ] Context usage < 50% average

**Should Achieve**:
- [ ] Test execution time < 5 minutes
- [ ] Code coverage > 80%
- [ ] Cyclomatic complexity < 10
- [ ] Zero flaky tests

---

## 10. Tools and Resources

### 10.1 Testing Frameworks

**Python**:
- pytest: Test framework with parametrization
- pytest-cov: Coverage reporting
- pytest-xdist: Parallel test execution
- hypothesis: Property-based testing

**Code Quality**:
- radon: Complexity metrics
- pylint: Code analysis
- black: Code formatting
- mypy: Type checking

### 10.2 CI/CD Tools

**GitHub Actions**:
- Workflow automation
- Matrix testing
- Artifact storage
- Metrics reporting

**Monitoring**:
- Prometheus: Metrics collection
- Grafana: Visualization
- Sentry: Error tracking

### 10.3 Documentation

**Key References**:
1. Martin Fowler - "The Practical Test Pyramid"
2. Google Testing Blog - "Just Say No to More End-to-End Tests"
3. pytest Documentation - Parametrization Guide
4. GitHub Actions Documentation
5. Atlassian - CI/CD Best Practices

---

## 11. Conclusion

This research provides a comprehensive framework for validating 100% Stage 7 execution reliability through:

1. **Structured Testing**: Testing Pyramid (70/20/10) ensures optimal coverage
2. **Automated Validation**: 80-run test suite with parametrization
3. **Context Management**: Metadata-based communication protects context window
4. **Code Quality**: Line count and complexity metrics ensure maintainability
5. **Delegation Safety**: Registry, cycle detection, and timeouts prevent failures
6. **Metrics Tracking**: Before/after comparison validates improvements
7. **CI/CD Integration**: Automated testing in deployment pipeline

**Next Steps**:
1. Implement parametrized test suite (80 tests)
2. Establish metrics baseline
3. Execute comprehensive validation
4. Generate before/after comparison report
5. Document findings and recommendations

---

## Appendices

### Appendix A: Test Case Templates

**Unit Test Template**:
```python
def test_command_function():
    """Test individual command function."""
    # Arrange
    input_data = create_test_input()
    
    # Act
    result = command_function(input_data)
    
    # Assert
    assert result.is_valid()
    assert result.meets_requirements()
```

**Integration Test Template**:
```python
def test_command_integration():
    """Test command integration with orchestrator."""
    # Arrange
    orchestrator = create_test_orchestrator()
    command = create_test_command()
    
    # Act
    result = orchestrator.execute(command)
    
    # Assert
    assert result.status == "completed"
    assert result.artifacts_persisted()
```

**E2E Test Template**:
```python
def test_complete_workflow():
    """Test complete workflow execution."""
    # Arrange
    workflow = create_test_workflow()
    
    # Act
    result = execute_workflow(workflow)
    
    # Assert
    assert result.all_stages_completed()
    assert result.artifacts_generated()
    assert result.metrics_within_limits()
```

### Appendix B: Metrics Collection Schema

```json
{
  "test_run": {
    "id": "run_20241229_001",
    "timestamp": "2024-12-29T10:00:00Z",
    "command": "research",
    "task_number": 250,
    "status": "completed",
    "duration_seconds": 25.3,
    "context_tokens": 45000,
    "context_percentage": 22.5,
    "artifacts": [
      {
        "type": "research",
        "path": ".opencode/specs/250/reports/research-001.md",
        "size_bytes": 15000,
        "validation": "passed"
      }
    ],
    "delegation": {
      "depth": 1,
      "path": ["orchestrator", "research"],
      "cycles_detected": 0,
      "timeout_violations": 0
    },
    "errors": []
  }
}
```

### Appendix C: Glossary

- **Stage 7**: Final stage of command execution (validation and return)
- **Context Window**: Maximum tokens an LLM can process
- **Delegation Chain**: Sequence of agent invocations
- **Delegation Depth**: Number of levels in delegation chain
- **Artifact**: Generated file (report, plan, code, etc.)
- **Orchestrator**: Main command routing and execution manager
- **Test Pyramid**: Testing strategy with 70/20/10 distribution
- **Parametrization**: Running same test with different inputs
- **CI/CD**: Continuous Integration/Continuous Deployment
- **MTBF**: Mean Time Between Failures
- **MTTR**: Mean Time To Recovery

---

**End of Research Report**
