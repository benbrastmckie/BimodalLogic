# Research Report: Task #867

**Task**: 867 - check_lean_lsp_mcp_github_issues
**Started**: 2026-02-10T00:00:00Z
**Completed**: 2026-02-10T00:15:00Z
**Effort**: Low
**Dependencies**: None
**Sources/Inputs**: GitHub API via gh CLI, codebase documentation
**Artifacts**: specs/867_check_lean_lsp_mcp_github_issues/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Issue #115 (lean_diagnostic_messages halts) is **OPEN** - the bug is not yet fixed
- Issue #118 in the codebase documentation refers to a *different* issue (build concurrency) than intended
- The actual blocking issue for lean_diagnostic_messages is issue #115
- No specific issue exists for lean_file_outline hanging; issue #97 (related) is **CLOSED**
- Recommendation: Update blocked-mcp-tools.md to correct the issue number references

## Context & Scope

The project has blocked two MCP tools due to hanging behavior:
- `lean_diagnostic_messages` - documented as lean-lsp-mcp #118
- `lean_file_outline` - documented as lean-lsp-mcp #115

This research verifies the current status of these GitHub issues and whether the underlying bugs have been resolved.

## Findings

### Repository Location

The lean-lsp-mcp repository is located at `oOo0oOo/lean-lsp-mcp` (not joshuaferrara/lean-lsp-mcp as the old URL structure might suggest).

### Issue #115: Server Halts on lean_diagnostic_messages

**Status**: OPEN (still a problem)
**Title**: "server halts on `lean_diagnostic_messages` tool calls after import edits"
**Created**: 2026-01-13
**URL**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/115

**Problem Description**:
The server hangs indefinitely when `lean_diagnostic_messages` is called after file imports have been edited (e.g., adding `import Mathlib`). The tool works correctly on the first call, but subsequent calls after import changes cause the MCP server to halt and never respond.

**Key Details**:
- Reproducible by editing imports in a Lean file
- `lake build` works fine after the same edit
- Restarting the server allows the tool to work again (until next import edit)
- Tested on leanprover/lean4:v4.24.0

**Conclusion**: This is the actual hanging issue affecting `lean_diagnostic_messages`. The documentation incorrectly references #118.

### Issue #118: Build Concurrency Modes

**Status**: OPEN
**Title**: "Add configurable build concurrency modes"
**Created**: 2026-01-23
**URL**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/118

**Problem Description**:
This is a *feature request* for configurable build concurrency, not a bug report about hanging tools. It discusses memory exhaustion when multiple concurrent `lake build` processes run.

**Conclusion**: This issue is **not** related to the lean_diagnostic_messages hanging behavior. The codebase documentation has the wrong issue number.

### Issue #97: Diagnostics Truncated After file_outline

**Status**: CLOSED (fixed on 2025-12-21)
**Title**: "`diagnostic_messages` truncated when called after `file_outline`"
**Created**: 2025-12-21
**URL**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/97

**Problem Description**:
When `file_outline` was called right before `diagnostic_messages`, the diagnostic output would be truncated or empty.

**Conclusion**: This related interaction bug has been fixed.

### Issue #63: Diagnostic Messages Misses Kernel Errors

**Status**: OPEN
**Title**: "lean_diagnostic_messages misses kernel errors"
**Created**: 2025-11-16
**URL**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/63

**Problem Description**:
`lean_diagnostic_messages` fails to report certain kernel errors and normal errors that follow them. The behavior is inconsistent - errors are only missed when a kernel error is the first error in the file.

**Conclusion**: This is an additional open bug affecting `lean_diagnostic_messages` reliability, but not the hanging issue.

### lean_file_outline Status

**No specific hanging issue found** for `lean_file_outline`. The codebase documentation states:
- Issue #115 is for `lean_file_outline`
- But issue #115 is actually about `lean_diagnostic_messages` hanging

The only `file_outline` related issue found was #97 (interaction with diagnostics), which is **CLOSED**.

**Possible explanations**:
1. The file_outline hanging behavior may be related to the same underlying issue as #115
2. The file_outline issue may have been resolved and never had its own GitHub issue
3. There may have been an issue that was closed/merged into another

## Decisions

### Documentation Corrections Needed

The blocked-mcp-tools.md file has incorrect issue references:

| Tool | Current Reference | Correct Reference |
|------|------------------|-------------------|
| `lean_diagnostic_messages` | #118 | #115 |
| `lean_file_outline` | #115 | Unknown (no specific issue exists) |

### Recommended Actions

1. **Keep lean_diagnostic_messages blocked**: Issue #115 is still open; the hanging bug is not fixed
2. **Re-evaluate lean_file_outline**: No open issue exists for this tool hanging. Consider testing to verify if it's still problematic
3. **Update documentation**: Correct issue number references in blocked-mcp-tools.md and CLAUDE.md

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Enabling lean_file_outline prematurely | Medium | Low | Test manually before unblocking |
| Issue #115 remaining open indefinitely | Medium | Medium | Use alternative tools as documented |
| Additional diagnostic issues (#63) | High | Low | Continue using lake build for authoritative errors |

## Appendix

### Search Queries Used

1. `gh issue list --repo oOo0oOo/lean-lsp-mcp --state all --limit 150`
2. `gh issue view 115 --repo oOo0oOo/lean-lsp-mcp`
3. `gh issue view 118 --repo oOo0oOo/lean-lsp-mcp`
4. `gh search issues "file_outline" --repo oOo0oOo/lean-lsp-mcp`
5. `gh issue view 97 --repo oOo0oOo/lean-lsp-mcp`
6. `gh issue view 63 --repo oOo0oOo/lean-lsp-mcp`

### References

- [Issue #115: Server halts on lean_diagnostic_messages](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115)
- [Issue #118: Build concurrency modes](https://github.com/oOo0oOo/lean-lsp-mcp/issues/118)
- [Issue #97: Diagnostics truncated after file_outline](https://github.com/oOo0oOo/lean-lsp-mcp/issues/97) (CLOSED)
- [Issue #63: Diagnostic messages misses kernel errors](https://github.com/oOo0oOo/lean-lsp-mcp/issues/63)
- Codebase: `.claude/context/core/patterns/blocked-mcp-tools.md`
