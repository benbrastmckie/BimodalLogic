# Implementation Plan: Loogle CLI Integration

**Task Number**: 197  
**Task Title**: Integrate Loogle CLI tool into lean-research-agent  
**Plan Version**: 001  
**Created**: 2025-12-27  
**Status**: NOT STARTED  
**Estimated Total Effort**: 3 hours  
**Language**: lean  
**Priority**: Medium

---

## Metadata

**Research Inputs**:
- Main Report: `.opencode/specs/197_loogle_cli_integration/reports/research-001.md`
- Summary: `.opencode/specs/197_loogle_cli_integration/summaries/research-summary.md`
- API Documentation: `.opencode/context/project/lean4/tools/loogle-api.md`

**Research Findings Summary**:
- Loogle binary verified at `/home/benjamin/.cache/loogle/.lake/build/bin/loogle`
- JSON output format well-documented and structured
- Persistent interactive mode recommended for optimal performance (0.1-2s queries)
- Index persistence critical for fast startup (5-10s with index vs 60-120s without)
- Five query modes supported: constant, name fragment, type pattern, conclusion, combined

**Key Technical Decisions**:
1. Use persistent interactive mode with pre-built index
2. Implement graceful fallback to web search if Loogle unavailable
3. Store index at `~/.cache/lean-research-agent/loogle-mathlib.index`
4. Implement timeout handling (10s queries, 180s startup)
5. Monitor process health and restart on crash

---

## Overview

### Problem Statement

The lean-research-agent currently lacks integration with Loogle, a powerful CLI tool for searching Lean 4 and Mathlib definitions and theorems by type signature. This forces the agent to rely on web search fallback, which is slower and less precise than type-based search. The agent has placeholder code (lines 276-282) acknowledging this limitation and logs "tool_unavailable" warnings.

### Scope

**In Scope**:
- Implement Loogle binary availability check
- Add persistent interactive mode integration
- Implement JSON response parsing
- Add type-based and name-based search capabilities
- Update lean-research-agent to use Loogle for Lean research
- Implement graceful fallback to web search
- Add timeout handling for startup and queries
- Update tool_availability status in return format
- Add error logging for Loogle failures

**Out of Scope**:
- Loogle binary installation (already installed)
- Web API integration (CLI is sufficient and faster)
- Multi-module support beyond Mathlib (future enhancement)
- Query result caching (future optimization)
- Parallel query execution (future optimization)

### Constraints

**Technical Constraints**:
- Must maintain backward compatibility with web search fallback
- Must not break existing lean-research-agent functionality
- Must handle Loogle unavailability gracefully
- Must respect delegation depth limits (< 3)
- Index building can take 60-120 seconds on first run

**Resource Constraints**:
- Loogle process memory usage: 2-4 GB during index build
- Index file size: 50-100 MB
- Query timeout: 10 seconds maximum
- Startup timeout: 180 seconds maximum

**Quality Constraints**:
- Must follow subagent-return-format.md for return objects
- Must log errors to errors.json per error schema
- Must maintain existing research report quality
- No emojis in code or documentation

### Definition of Done

- [ ] Loogle binary check implemented at `/home/benjamin/.cache/loogle/.lake/build/bin/loogle`
- [ ] Persistent interactive mode integration working
- [ ] JSON response parsing implemented and tested
- [ ] Type-based searches (e.g., `?a → ?b → ?a ∧ ?b`) work correctly
- [ ] Name-based searches (e.g., `"replicate"`) work correctly
- [ ] Research reports include Loogle findings with proper attribution
- [ ] Return format shows `tool_availability.loogle: true` when available
- [ ] Graceful fallback to web search when Loogle unavailable
- [ ] Timeout handling prevents hanging (10s queries, 180s startup)
- [ ] Index persistence strategy documented
- [ ] Error logging to errors.json when Loogle fails
- [ ] No "tool_unavailable" warnings for Loogle when binary is available
- [ ] All existing lean-research-agent tests still pass
- [ ] Integration tested with real research queries

---

## Goals and Non-Goals

### Goals

1. **Enable Type-Based Search**: Allow lean-research-agent to search Mathlib by type signatures
2. **Improve Research Quality**: Provide more precise, Lean-specific search results
3. **Reduce Latency**: Achieve 0.1-2s query times vs 2-5s web search
4. **Maintain Reliability**: Ensure graceful degradation when Loogle unavailable
5. **Complete Tool Integration**: Remove "tool_unavailable" warnings for Loogle

### Non-Goals

1. **Replace Web Search Entirely**: Web search remains valuable for documentation and discussions
2. **Support All Loogle Features**: Focus on core search modes (constant, name, type, conclusion)
3. **Optimize for Multiple Modules**: Mathlib coverage is sufficient for current needs
4. **Implement Advanced Caching**: Basic integration first, optimizations later
5. **Provide Interactive UI**: CLI integration only, no web interface

---

## Risks and Mitigations

### Risk 1: Index Build Timeout on First Run

**Severity**: Medium  
**Probability**: High  
**Impact**: Agent startup delayed by 60-120 seconds on first run

**Mitigation**:
- Pre-build index during agent initialization (one-time cost)
- Store index in persistent location (`~/.cache/lean-research-agent/`)
- Use `--read-index` for fast startup (5-10s) on subsequent runs
- Document index rebuild process for Mathlib updates

### Risk 2: Loogle Process Crashes During Operation

**Severity**: Medium  
**Probability**: Low  
**Impact**: Research queries fail until process restarted

**Mitigation**:
- Implement process health monitoring (check `poll()` status)
- Automatic restart on crash with exponential backoff
- Fallback to web search if restart fails
- Log crashes to errors.json for debugging

### Risk 3: Query Timeout on Complex Patterns

**Severity**: Low  
**Probability**: Medium  
**Impact**: Some complex queries may timeout

**Mitigation**:
- Set reasonable timeout (10s for queries)
- Simplify query patterns if timeout occurs
- Retry with suggestions from Loogle error responses
- Fallback to web search for timed-out queries

### Risk 4: Index Corruption or Staleness

**Severity**: Low  
**Probability**: Low  
**Impact**: Incorrect or incomplete search results

**Mitigation**:
- Validate index age (rebuild if > 7 days old)
- Detect index corruption (process crash on load)
- Automatic rebuild on corruption detection
- Document manual rebuild procedure

---

## Implementation Phases

### Phase 1: Binary Check and Index Management [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objectives**:
- Implement Loogle binary availability check
- Implement index freshness validation
- Implement index build/rebuild logic
- Add index path configuration

**Tasks**:
1. Add binary path constant: `/home/benjamin/.cache/loogle/.lake/build/bin/loogle`
2. Implement `check_loogle_binary()` function to verify binary exists and is executable
3. Add index path constant: `~/.cache/lean-research-agent/loogle-mathlib.index`
4. Implement `is_index_fresh(max_age_days=7)` function to check index age
5. Implement `build_loogle_index()` function to create index with `--write-index`
6. Add index validation logic to agent initialization

**Acceptance Criteria**:
- Binary check returns true when Loogle installed
- Binary check returns false when Loogle not found
- Index freshness check validates age correctly
- Index build creates valid index file
- Index rebuild triggered when age > 7 days

**Dependencies**: None

**Risks**: Index build may timeout on slow systems (mitigated by 180s timeout)

---

### Phase 2: Interactive Mode Integration [NOT STARTED]

**Estimated Effort**: 1.0 hours

**Objectives**:
- Implement persistent interactive mode process management
- Implement stdin/stdout communication
- Implement startup synchronization (wait for "Loogle is ready")
- Implement process health monitoring

**Tasks**:
1. Create `LoogleClient` class with process lifecycle management
2. Implement `start()` method to launch Loogle with `--json --interactive --read-index`
3. Implement startup synchronization to wait for "Loogle is ready.\n"
4. Implement `query(query_string, timeout=10)` method for stdin/stdout communication
5. Implement `check_health()` method to monitor process status
6. Implement `restart()` method with exponential backoff
7. Implement `close()` method for graceful shutdown
8. Add timeout handling for startup (180s) and queries (10s)

**Acceptance Criteria**:
- LoogleClient starts successfully with pre-built index
- Startup completes within 10s when index available
- Query method sends query and receives JSON response
- Health check detects process crashes
- Restart logic recovers from crashes
- Close method terminates process cleanly

**Dependencies**: Phase 1 (index must exist)

**Risks**: Process communication may hang (mitigated by timeouts and health checks)

---

### Phase 3: Query Generation and Response Parsing [NOT STARTED]

**Estimated Effort**: 0.75 hours

**Objectives**:
- Implement query generation from research topics
- Implement JSON response parsing
- Implement result categorization (definitions, theorems, tactics)
- Implement error handling for query failures

**Tasks**:
1. Implement `generate_loogle_queries(topic, context)` to create query list
2. Add context-specific query patterns (modal logic, temporal logic)
3. Implement `parse_loogle_response(json_response)` to extract hits
4. Implement `categorize_results(hits)` to separate definitions/theorems/tactics
5. Implement error response handling (parse "error" field, use "suggestions")
6. Add query sanitization (remove control chars, limit length to 500)
7. Implement retry logic with suggestions on query errors

**Acceptance Criteria**:
- Query generation creates valid Loogle queries from topics
- Modal logic context generates modal-specific queries (□, ◇)
- Temporal logic context generates temporal-specific queries (Until, Eventually)
- JSON parsing extracts name, type, module, doc fields correctly
- Results categorized into definitions, theorems, tactics
- Error responses parsed and suggestions used for retry
- Query sanitization prevents injection attacks

**Dependencies**: Phase 2 (LoogleClient must be functional)

**Risks**: Query generation may produce invalid patterns (mitigated by error handling and suggestions)

---

### Phase 4: Integration into lean-research-agent [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objectives**:
- Update lean-research-agent to use Loogle for research
- Implement fallback to web search
- Update tool_availability status
- Update research report generation
- Remove tool_unavailable warnings

**Tasks**:
1. Update step_1 to initialize LoogleClient during agent startup
2. Update step_3 to use Loogle for Lean library research
3. Implement fallback logic: try Loogle first, use web search if fails
4. Update return format to set `tool_availability.loogle: true` when available
5. Update research report to include Loogle findings with attribution
6. Remove tool_unavailable logging for Loogle when binary available
7. Update key_findings to include Loogle-specific metrics
8. Add Loogle query log to research artifacts (optional)

**Acceptance Criteria**:
- lean-research-agent initializes LoogleClient on startup
- Research queries use Loogle when available
- Fallback to web search works when Loogle unavailable
- tool_availability.loogle reflects actual availability
- Research reports attribute findings to Loogle
- No tool_unavailable warnings when Loogle working
- key_findings includes Loogle query count and hit count

**Dependencies**: Phase 3 (query generation and parsing must work)

**Risks**: Integration may break existing web search fallback (mitigated by thorough testing)

---

### Phase 5: Testing and Documentation [NOT STARTED]

**Estimated Effort**: 0.25 hours

**Objectives**:
- Test Loogle integration with real research queries
- Verify fallback behavior
- Update documentation
- Verify error logging

**Tasks**:
1. Test type-based search: `?a → ?b → ?a ∧ ?b`
2. Test name-based search: `"replicate"`
3. Test constant search: `List.map`
4. Test combined search: `List.map, "assoc"`
5. Test fallback when Loogle unavailable (rename binary temporarily)
6. Test timeout handling (complex query with short timeout)
7. Test process crash recovery (kill process during query)
8. Verify errors.json logging when Loogle fails
9. Update loogle-api.md with integration examples (already complete)
10. Verify no regressions in existing lean-research-agent tests

**Acceptance Criteria**:
- All query types work correctly
- Fallback to web search works when Loogle unavailable
- Timeout handling prevents hanging
- Process crash recovery works
- errors.json contains proper error entries
- Documentation is complete and accurate
- No regressions in existing functionality

**Dependencies**: Phase 4 (full integration must be complete)

**Risks**: Testing may reveal edge cases (mitigated by comprehensive test coverage)

---

## Testing and Validation

### Unit Tests

**Binary Check Tests**:
- Test binary exists and is executable
- Test binary not found returns false
- Test binary path is correct

**Index Management Tests**:
- Test index freshness validation
- Test index build creates valid file
- Test index rebuild on staleness
- Test index corruption detection

**LoogleClient Tests**:
- Test startup with index
- Test startup without index (slow path)
- Test query execution
- Test JSON parsing
- Test error handling
- Test process crash recovery
- Test graceful shutdown

**Query Generation Tests**:
- Test query generation from topics
- Test modal logic context queries
- Test temporal logic context queries
- Test query sanitization
- Test result categorization

### Integration Tests

**End-to-End Research Tests**:
- Test research workflow with Loogle available
- Test research workflow with Loogle unavailable
- Test fallback behavior
- Test research report generation
- Test tool_availability status

**Performance Tests**:
- Measure startup time with index (target: < 10s)
- Measure query latency (target: < 2s)
- Measure index build time (baseline: 60-120s)

### Validation Criteria

**Functional Validation**:
- All query types return valid results
- Fallback works when Loogle unavailable
- Timeout handling prevents hanging
- Process recovery works after crash

**Quality Validation**:
- Research reports include Loogle findings
- Findings properly attributed to Loogle
- Return format follows subagent-return-format.md
- Error logging follows error schema

**Performance Validation**:
- Query latency < 2s (95th percentile)
- Startup time < 10s with index
- No memory leaks in long-running process

---

## Artifacts and Outputs

### Code Artifacts

**Modified Files**:
- `.opencode/agent/subagents/lean-research-agent.md` - Main integration point

**New Files** (if implementation requires separate modules):
- None (integration is within lean-research-agent.md)

**Documentation Artifacts**:
- `.opencode/context/project/lean4/tools/loogle-api.md` - Already created during research

### Research Artifacts

**Existing Artifacts** (from research phase):
- `.opencode/specs/197_loogle_cli_integration/reports/research-001.md` - Comprehensive research report
- `.opencode/specs/197_loogle_cli_integration/summaries/research-summary.md` - Research summary
- `.opencode/context/project/lean4/tools/loogle-api.md` - API documentation

### Test Artifacts

**Test Results**:
- Unit test results for LoogleClient
- Integration test results for lean-research-agent
- Performance benchmark results

**Error Logs**:
- `.opencode/errors.json` - Error entries for Loogle failures

---

## Rollback and Contingency

### Rollback Plan

**If Integration Fails**:
1. Revert changes to lean-research-agent.md
2. Restore web search as primary research method
3. Keep tool_unavailable warnings in place
4. Document failure reason in errors.json

**Rollback Triggers**:
- Loogle integration breaks existing functionality
- Performance degradation (queries > 10s consistently)
- Frequent process crashes (> 3 per hour)
- Index corruption issues (> 1 per day)

### Contingency Plans

**Contingency 1: Loogle Binary Unavailable**
- Use web search fallback exclusively
- Log tool_unavailable to errors.json
- Document Loogle installation instructions
- Continue research with reduced quality

**Contingency 2: Index Build Fails**
- Use Loogle without index (slower startup)
- Increase startup timeout to 300s
- Document index build failure in errors.json
- Consider using web API as alternative

**Contingency 3: Process Crashes Frequently**
- Disable persistent mode, use one-shot queries
- Increase timeout to 30s per query
- Log crashes to errors.json for debugging
- Fallback to web search if crashes persist

**Contingency 4: Query Timeouts Excessive**
- Reduce timeout to 5s
- Simplify query patterns
- Use web search for complex queries
- Document timeout issues in errors.json

---

## Dependencies and Prerequisites

### External Dependencies

**Required**:
- Loogle binary at `/home/benjamin/.cache/loogle/.lake/build/bin/loogle` (already installed)
- Mathlib .olean files in Loogle cache (already present)
- Python subprocess module (standard library)
- JSON parsing library (standard library)

**Optional**:
- Pre-built index file (created during Phase 1)

### Internal Dependencies

**Code Dependencies**:
- lean-research-agent.md (existing)
- subagent-return-format.md (existing)
- error schema in errors.json (existing)

**Context Dependencies**:
- `.opencode/context/project/lean4/` (existing)
- `.opencode/context/project/lean4/tools/loogle-api.md` (created during research)

### Knowledge Prerequisites

**Required Knowledge**:
- Loogle CLI interface and options
- JSON output format structure
- Interactive mode communication protocol
- Index persistence strategy
- Query syntax (constant, name, type, conclusion)

**Documentation**:
- Research report: `.opencode/specs/197_loogle_cli_integration/reports/research-001.md`
- API documentation: `.opencode/context/project/lean4/tools/loogle-api.md`

---

## Success Metrics

### Quantitative Metrics

**Performance Metrics**:
- Query latency: < 2s (95th percentile)
- Startup time: < 10s with index
- Index build time: 60-120s (baseline)
- Process uptime: > 99% (< 1% crash rate)

**Quality Metrics**:
- Loogle availability: 100% when binary present
- Fallback success rate: 100% when Loogle unavailable
- Query success rate: > 95% (excluding invalid queries)
- Result relevance: > 90% (manual evaluation)

**Coverage Metrics**:
- Query types supported: 5/5 (constant, name, type, conclusion, combined)
- Error scenarios handled: 4/4 (unavailable, timeout, crash, corruption)
- Test coverage: > 90% of integration code

### Qualitative Metrics

**User Experience**:
- No "tool_unavailable" warnings when Loogle working
- Research reports include precise type-based findings
- Faster research completion (0.1-2s vs 2-5s per query)
- More relevant Lean-specific results

**Code Quality**:
- Clean integration with existing lean-research-agent
- Proper error handling and logging
- Clear documentation and examples
- No breaking changes to existing functionality

**Maintainability**:
- Index management automated
- Process lifecycle well-managed
- Graceful degradation on failures
- Clear rollback procedures

---

## Timeline and Milestones

### Estimated Timeline

**Total Duration**: 3 hours

**Phase Breakdown**:
- Phase 1 (Binary Check and Index Management): 0.5 hours
- Phase 2 (Interactive Mode Integration): 1.0 hours
- Phase 3 (Query Generation and Response Parsing): 0.75 hours
- Phase 4 (Integration into lean-research-agent): 0.5 hours
- Phase 5 (Testing and Documentation): 0.25 hours

### Milestones

**Milestone 1: Index Management Complete** (0.5 hours)
- Binary check working
- Index build/rebuild working
- Index freshness validation working

**Milestone 2: LoogleClient Functional** (1.5 hours cumulative)
- Interactive mode startup working
- Query execution working
- Process health monitoring working

**Milestone 3: Query Integration Complete** (2.25 hours cumulative)
- Query generation working
- Response parsing working
- Result categorization working

**Milestone 4: lean-research-agent Updated** (2.75 hours cumulative)
- Loogle integration working
- Fallback working
- tool_availability updated
- Research reports updated

**Milestone 5: Testing Complete** (3.0 hours cumulative)
- All tests passing
- Documentation complete
- No regressions

---

## Notes and Considerations

### Implementation Notes

**Binary Path**:
- Use absolute path: `/home/benjamin/.cache/loogle/.lake/build/bin/loogle`
- Verify executable permissions before use
- Consider environment variable override for testing

**Index Location**:
- Store in user cache: `~/.cache/lean-research-agent/loogle-mathlib.index`
- Create directory if not exists (lazy creation)
- Document manual rebuild procedure

**Process Management**:
- Use subprocess.Popen for interactive mode
- Set bufsize=1 for line-buffered I/O
- Use text=True for string I/O (not bytes)
- Monitor process with poll() for health checks

**Timeout Strategy**:
- Startup: 180s (index build can be slow)
- Query: 10s (most queries < 2s, allow buffer)
- Shutdown: 5s (graceful termination)

### Future Enhancements

**Query Optimization**:
- Implement LRU cache for query results (1000 entries)
- Parallel query execution for multiple patterns
- Query simplification on timeout

**Multi-Module Support**:
- Support searching custom modules beyond Mathlib
- Multiple LoogleClient instances per module
- Module-specific index management

**Advanced Features**:
- Query result ranking by relevance
- Automatic query refinement based on results
- Integration with LeanSearch for semantic search
- Web API fallback for Loogle CLI

### Research Integration Notes

**Research Findings Applied**:
- Persistent interactive mode chosen over one-shot (research recommendation)
- Index persistence implemented (research recommendation)
- Timeout values based on research benchmarks
- JSON format parsing based on source code analysis
- Query syntax based on research examples

**Research Artifacts Referenced**:
- Main report for CLI interface specification
- Summary for integration approach
- API documentation for query syntax and examples

---

## Approval and Sign-off

**Plan Created By**: Planner Agent  
**Plan Created Date**: 2025-12-27  
**Plan Status**: Ready for Review  

**Reviewers**:
- [ ] Technical Review: Verify implementation approach
- [ ] Security Review: Verify query sanitization and index trust
- [ ] Performance Review: Verify timeout and resource limits

**Approval**:
- [ ] Approved for Implementation
- [ ] Assigned to: lean-implementation-orchestrator

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 001 | 2025-12-27 | Planner Agent | Initial plan created with 5 phases, 3 hour estimate |

---

**End of Implementation Plan**
