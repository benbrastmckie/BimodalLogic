# Loogle CLI Integration Research Summary

**Task**: 197  
**Date**: 2025-12-27  
**Session**: sess_1735304400_lr197a  
**Status**: Completed

## Key Findings

### Binary Location
- **Path**: `/home/benjamin/.cache/loogle/.lake/build/bin/loogle`
- **Status**: Available and functional
- **Version**: Lean 4 (v4.27.0-rc1)

### CLI Interface
- **Options**: `--json`, `--interactive`, `--read-index`, `--write-index`, `--module`
- **JSON Output**: Well-structured with `hits`, `count`, `header`, `heartbeats`, `suggestions`
- **Query Modes**: Constant, name fragment, type pattern, conclusion, combined

### Performance Characteristics
- **Index Build**: 60-120 seconds (first run, Mathlib)
- **Index Load**: 5-10 seconds (with `--read-index`)
- **Query Time**: 0.1-2 seconds (after index ready)
- **Interactive Startup**: 5-180 seconds (depends on index availability)

### Query Syntax
1. **Constant Search**: `Real.sin` - finds all declarations mentioning constant
2. **Name Fragment**: `"differ"` - case-insensitive substring matching
3. **Type Pattern**: `?a → ?b → ?a ∧ ?b` - pattern matching with metavariables
4. **Conclusion**: `|- tsum _ = _ * tsum _` - matches conclusion only
5. **Combined**: `Real.sin, tsum, _ * _` - AND logic across filters

## Recommended Integration Approach

### 1. Persistent Interactive Mode (Best)
- Start Loogle once in interactive mode with pre-built index
- Send queries via stdin, read JSON responses from stdout
- Advantages: Fast queries (0.1-2s), no process overhead
- Implementation: Python subprocess with stdin/stdout pipes

### 2. Index Management
- Pre-build index during agent initialization
- Store in `~/.cache/lean-research-agent/loogle-mathlib.index`
- Rebuild when Mathlib updates or index age > 7 days
- Index size: ~50-100 MB

### 3. Error Handling
- Implement timeouts (10s for queries, 180s for startup)
- Graceful fallback to web search if Loogle unavailable
- Retry with suggestions on query errors
- Monitor process health and restart on crash

### 4. Integration Points
- Initialize LoogleClient at agent startup
- Use for type-based searches in research workflow
- Cache query results (LRU cache, 1000 entries)
- Log tool availability and performance metrics

## Implementation Complexity

**Level**: Medium

**Challenges**:
1. Index building performance (60-120s first run)
2. Process lifecycle management (startup, health monitoring, restart)
3. Timeout handling for slow queries
4. Graceful degradation to web search

**Mitigations**:
1. Index persistence with `--read-index`
2. Interactive mode for persistent process
3. Configurable timeouts with fallback
4. Multi-tier fallback strategy

## Next Steps

1. **Implement LoogleClient Class**
   - Interactive mode with stdin/stdout communication
   - Timeout handling for startup and queries
   - Process health monitoring and restart logic

2. **Add Index Management**
   - Build index during agent initialization
   - Store in persistent location
   - Validate index freshness and rebuild if needed

3. **Integrate into Research Workflow**
   - Add Loogle queries to research methods
   - Implement fallback to web search
   - Generate Loogle queries from research topics

4. **Error Handling**
   - Log tool unavailability to errors.json
   - Handle timeout, crash, and JSON parse errors
   - Implement retry logic with suggestions

5. **Testing**
   - Unit tests for LoogleClient
   - Integration tests for research workflow
   - Performance benchmarks
   - Fallback behavior tests

## Expected Benefits

- **Speed**: 0.1-2s queries vs 2-5s web search
- **Accuracy**: Type-based search more precise than text search
- **Coverage**: Complete Mathlib coverage
- **Flexibility**: Multiple query modes (constant, pattern, conclusion)
- **Offline**: Works without internet (after index built)

## Tool Status

| Tool | Status | Notes |
|------|--------|-------|
| Loogle Binary | ✅ Available | `/home/benjamin/.cache/loogle/.lake/build/bin/loogle` |
| Loogle Source | ✅ Available | `/home/benjamin/.cache/loogle/` |
| JSON Output | ✅ Supported | `--json` flag |
| Interactive Mode | ✅ Supported | `--interactive` flag |
| Index Persistence | ✅ Supported | `--write-index`, `--read-index` |
| Web API | ✅ Available | `https://loogle.lean-lang.org/json?q=` |

## References

- **Research Report**: `.opencode/specs/197_loogle_cli_integration/reports/research-001.md`
- **API Documentation**: `.opencode/context/project/lean4/tools/loogle-api.md`
- **Loogle GitHub**: https://github.com/nomeata/loogle
- **Loogle Web**: https://loogle.lean-lang.org/
- **Source Code**: `/home/benjamin/.cache/loogle/Loogle.lean`

## Conclusion

Loogle CLI integration is feasible and recommended for lean-research-agent. The persistent interactive mode with pre-built index provides excellent performance (0.1-2s queries) and comprehensive Mathlib coverage. Implementation complexity is medium, primarily due to index management and process lifecycle handling. The benefits significantly outweigh the implementation costs.

**Recommendation**: Proceed with implementation using the persistent interactive mode pattern documented in the research report.
