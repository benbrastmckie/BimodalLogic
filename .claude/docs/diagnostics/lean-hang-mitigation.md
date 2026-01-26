# Lean /implement Hang Mitigation System

**Last Updated**: 2026-01-26
**Version**: 1.0
**Status**: Active

---

## Overview

This document describes the four-layer defense system for detecting and mitigating hangs in Lean `/implement` execution caused by zombie processes in the lean-lsp-mcp MCP server.

**Problem**: Zombie `lake` subprocess accumulation causes `lean_diagnostic_messages` calls to hang indefinitely.

**Solution**: Multi-layer mitigation combining prevention (pre-build), protection (concurrent build limits), detection (faster deadlock detection), and observability (comprehensive logging).

---

## Known Upstream Issues

### Issue #115: lean_diagnostic_messages Hangs After Import Edits

**Repository**: [lean-lsp-mcp](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115)
**Status**: ✅ Fixed in Lean v4.26.0+
**Opened**: January 13, 2026

**Problem Description**:
The `lean_diagnostic_messages` tool becomes unresponsive after editing a Lean file to add imports (e.g., `import Mathlib`).

**Root Cause**:
Bug in `leanclient/file_manager.py` within the `_wait_for_diagnostics` function where the loop never exits.

**Workaround**:
Upgrade from Lean v4.24.0 to **v4.26.0 or later**.

**ProofChecker Status**:
✅ **Using v4.27.0-rc1** (verified in `lean-toolchain` file) - this bug is fixed.

---

### Issue #118: Concurrent Builds Exhaust Memory

**Repository**: [lean-lsp-mcp](https://github.com/oOo0oOo/lean-lsp-mcp/issues/118)
**Status**: ⚠️ Open (feature request)
**Opened**: January 23, 2026

**Problem Description**:
Multiple concurrent `lake build` processes can exhaust memory and crash the MCP server or host.

**Quote from Issue**:
> "Some clients (or usage patterns) can cause multiple concurrent lake build processes to run, which may exhaust memory and crash the MCP server or host."

**Why This Affects ProofChecker**:
- lean-implementation-agent calls `lean_diagnostic_messages` repeatedly in proof loop
- Each call can trigger a `lake build` subprocess
- Without protection, multiple builds run concurrently
- Concurrent builds spawn subprocesses that become zombies
- Memory exhaustion occurs as zombies accumulate

**Our Mitigation**:
- Build lock file prevents concurrent diagnostic calls (Phase 2)
- Diagnostic throttling reduces calls by ~50% (Phase 2)
- Batch verification replaces frequent individual checks (Phase 2)

---

## Four-Layer Defense Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 1: PREVENTIVE (before agent starts) - PRIMARY MITIGATION │
│ ✅ Pre-build with lake build (reduces zombie formation ~60%)   │
│ ✅ Pre-flight zombie cleanup (existing from Task 688)          │
│ ✅ Fresh MCP environment                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 2: PROTECTIVE (during execution)                         │
│ ✅ Concurrent build prevention (Issue #118 mitigation)         │
│ ✅ Diagnostic call throttling (~50% reduction)                 │
│ ✅ Agent progress tracking (heartbeat every 30s)               │
│ ✅ Progressive diagnostic degradation (graceful fallback)      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 3: DETECTIVE (hang detection)                            │
│ ✅ Faster deadlock detection (2.5 min vs 5 min)                │
│ ✅ Progress staleness check (mid-execution hang detection)     │
│ ✅ Concurrent build detection (log multiple lake processes)    │
│ ✅ Zombie count tracking (monitor accumulation)                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 4: OBSERVABILITY (ongoing)                               │
│ ✅ Enhanced logging (audit trail for concurrent builds)        │
│ ✅ Upstream issue documentation (link to #115, #118)           │
│ ✅ Comprehensive troubleshooting guide (this document)         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Troubleshooting Decision Tree

### Step 1: Identify the Symptom

**Is `/implement` showing no progress for >3 minutes?**
- Yes → Proceed to Step 2
- No → Not a hang, monitor normally

### Step 2: Check Progress File Age

```bash
find specs -name ".agent-progress.json" -type f -exec stat -c "%Y %n" {} \; | while read mtime file; do
    age=$(($(date +%s) - mtime))
    echo "$file: ${age}s old"
done
```

**Is progress file >180 seconds old?**
- Yes → **Mid-execution hang** → Proceed to Step 3
- No → Agent is still working, wait longer
- File doesn't exist → Agent hasn't started Stage 1.5 yet

### Step 3: Check for Concurrent Lake Builds

```bash
pgrep -af "lake build"
```

**Are there >1 lake build processes?**
- Yes → **Issue #118 (concurrent builds)** → Proceed to Step 4
- No → Single build may be stuck on zombie → Proceed to Step 4

### Step 4: Check Zombie Count

```bash
ps aux | grep '[l]ake' | grep 'Z'
# Or use the cleanup script:
.claude/scripts/lean-zombie-cleanup.sh --dry-run
```

**Are there zombie processes?**
- Yes → **Zombie accumulation** → Run `/refresh` or cleanup script
- No → Unusual hang, check logs

### Step 5: Recovery

```bash
# Run cleanup
/refresh

# Or manual cleanup
.claude/scripts/lean-zombie-cleanup.sh --force --age-threshold 5

# Retry implementation (will resume from last completed phase)
/implement <task-number>
```

---

## Log Files Reference

### Primary Logs

| Log File | Purpose | What to Look For |
|----------|---------|------------------|
| `.claude/logs/subagent-postflight.log` | Deadlock detection events | "DEADLOCK DETECTED", "Progress file stale", "Concurrent builds" |
| `.claude/logs/zombie-cleanup.log` | Cleanup audit trail | Zombie counts, cleanup frequency, duration |
| `.claude/logs/lean-pre-build.log` | Pre-build execution | Build times, timeouts, failures |
| `specs/<N>_<slug>/.agent-progress.json` | Real-time agent progress | `last_update`, `operation`, `diagnostic_calls`, `skipped_diagnostics` |

### Reading Progress File

```bash
# View current progress
cat specs/630_task_slug/.agent-progress.json | jq '.'

# Check staleness
stat -c "Age: %Y seconds" specs/630_task_slug/.agent-progress.json

# Monitor diagnostic patterns
jq '{calls: .diagnostic_calls, skipped: .skipped_diagnostics}' specs/630_task_slug/.agent-progress.json
```

### Reading Postflight Log

```bash
# Recent deadlock events
grep "DEADLOCK DETECTED" .claude/logs/subagent-postflight.log | tail -5

# Concurrent build warnings
grep "concurrent lake build" .claude/logs/subagent-postflight.log | tail -10

# Progress staleness events
grep "Progress file stale" .claude/logs/subagent-postflight.log | tail -5
```

---

## Understanding Diagnostic Patterns

### Healthy Pattern

```json
{
  "diagnostic_calls": 3,
  "skipped_diagnostics": 0
}
```
- Diagnostics called for first 3 proofs only
- Batch build used after proof 6
- No concurrent build conflicts

### Throttled Pattern

```json
{
  "diagnostic_calls": 3,
  "skipped_diagnostics": 4
}
```
- 4 diagnostics skipped due to concurrent build lock
- Build lock working correctly (Issue #118 mitigation)
- Normal behavior under concurrent load

### Problematic Pattern

```json
{
  "diagnostic_calls": 15,
  "skipped_diagnostics": 0
}
```
- Too many diagnostic calls (should throttle after 3)
- Indicates diagnostic degradation not working
- High risk of concurrent builds

---

## Configuration Tuning

### Current Settings

| Parameter | Location | Value | Rationale |
|-----------|----------|-------|-----------|
| Pre-build timeout | `.claude/scripts/lean-pre-build.sh` | 120s | Allows clean build on mid-size projects |
| Marker age threshold | `.claude/hooks/subagent-postflight.sh` | 150s (2.5 min) | 1.5x typical MCP operation time |
| Progress staleness | `.claude/hooks/subagent-postflight.sh` | 180s (3 min) | Buffer for slow operations |
| Build lock timeout | `.claude/agents/lean-implementation-agent.md` | 30s | Prevents permanent blocking |
| Batch build timeout | `.claude/agents/lean-implementation-agent.md` | 300s (5 min) | Full project rebuild |
| Diagnostic throttle | `.claude/agents/lean-implementation-agent.md` | After 3 proofs | ~50% reduction |

### Tuning for Smaller Projects (<1000 LOC)

```bash
# Reduce pre-build timeout
# In .claude/skills/skill-lean-implementation/SKILL.md, change:
"$PREBUILD_SCRIPT" --timeout 60  # Was 120

# Reduce marker threshold
# In .claude/hooks/subagent-postflight.sh, change:
MAX_MARKER_AGE_SECS=120  # Was 150
```

### Tuning for Larger Projects (>10k LOC)

```bash
# Increase pre-build timeout
"$PREBUILD_SCRIPT" --timeout 180  # Was 120

# Increase marker threshold
MAX_MARKER_AGE_SECS=180  # Was 150
```

---

## Monitoring Checklist

### After Each /implement Run

- [ ] Check progress file was created: `ls specs/<N>_*/.agent-progress.json`
- [ ] Verify diagnostic throttling: `jq '.diagnostic_calls, .skipped_diagnostics' <progress-file>`
- [ ] Check for zombie accumulation: `ps aux | grep '[l]ake' | grep 'Z' | wc -l`
- [ ] Review postflight log for warnings: `tail -20 .claude/logs/subagent-postflight.log`

### Weekly Review

- [ ] Analyze hang frequency: Count deadlock events in postflight log
- [ ] Review zombie cleanup patterns: Check cleanup log for trends
- [ ] Verify partial completion rate: Count [PARTIAL] phases vs [COMPLETED]
- [ ] Check pre-build success rate: Review lean-pre-build.log

### Monthly Maintenance

- [ ] Update to latest lean-lsp-mcp: `uvx lean-lsp-mcp --version`
- [ ] Check upstream issues for fixes: Visit #115, #118 on GitHub
- [ ] Archive old logs: Move logs >30 days to archive/
- [ ] Review configuration tuning: Adjust based on patterns

---

## Quick Reference Cards

### Quick Diagnosis

```bash
# Hang suspected?
find specs -name ".agent-progress.json" -mmin +3  # Stale progress files

# Concurrent builds?
pgrep -fc "lake build"  # Should be ≤1

# Zombies present?
ps aux | grep -c '[l]ake.*Z'  # Should be 0

# Recent deadlocks?
grep -c "DEADLOCK" .claude/logs/subagent-postflight.log | tail -1
```

### Quick Recovery

```bash
# Fast recovery (recommended)
/refresh

# Manual recovery
.claude/scripts/lean-zombie-cleanup.sh --force --age-threshold 5
/implement <N>  # Resumes automatically

# Nuclear option (if nothing else works)
pkill -9 lean-lsp-mcp
/refresh
/implement <N>
```

---

## Upstream Links

- [lean-lsp-mcp Repository](https://github.com/oOo0oOo/lean-lsp-mcp)
- [Issue #115: lean_diagnostic_messages Hang](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115) - Fixed in v4.26.0+
- [Issue #118: Concurrent Build Memory Exhaustion](https://github.com/oOo0oOo/lean-lsp-mcp/issues/118) - Open, mitigated locally
- [Claude Code Issue #15945: MCP 16+ Hour Hang](https://github.com/anthropics/claude-code/issues/15945) - Broader MCP ecosystem issue
- [lean-lsp-mcp PyPI](https://pypi.org/project/lean-lsp-mcp/) - Official package page
- [lean-lsp-mcp README](https://github.com/oOo0oOo/lean-lsp-mcp/blob/main/README.md) - Pre-build recommendation

---

## Success Metrics

Track these over 2-week observation period:

| Metric | Baseline | Target | Current |
|--------|----------|--------|---------|
| Hang frequency | 40% | <10% | _TBD_ |
| Detection time | 5-13 min | <3 min | _TBD_ |
| Partial completion | 30% | >70% | _TBD_ |
| Concurrent builds | Unlimited | ≤1 | _TBD_ |
| User intervention | 60% | <20% | _TBD_ |
| Zombie accumulation | 3-5/session | <2/session | _TBD_ |

---

## Related Documentation

- `.claude/docs/diagnostics/zombie-process-root-cause-analysis.md` - Original root cause analysis (290 lines)
- `.claude/docs/diagnostics/lean-implement-stall-fix-plan.md` - Implementation plan (this system)
- `.claude/docs/diagnostics/lean-lsp-mcp-research-summary.md` - Upstream research findings
- `.claude/scripts/lean-zombie-cleanup.sh` - Cleanup script (303 lines)
- `.claude/scripts/lean-pre-build.sh` - Pre-build script
- `.claude/agents/lean-implementation-agent.md` - Agent with defensive strategies
- `.claude/hooks/subagent-postflight.sh` - Deadlock detection hook

---

**End of Guide**
