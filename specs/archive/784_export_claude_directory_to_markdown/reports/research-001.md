# Research Report: Task #784

**Task**: 784 - Export Claude Directory to Markdown
**Started**: 2026-01-30T12:00:00Z
**Completed**: 2026-01-30T12:30:00Z
**Effort**: 2 hours (estimated)
**Priority**: medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, .claude directory analysis
**Artifacts**: specs/784_export_claude_directory_to_markdown/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The .claude/ directory contains 243 files totaling 3.5MB across 80 directories
- Content is primarily markdown (210 files), with shell scripts, JSON configs, and YAML files
- Export should respect .gitignore exclusions (settings.local.json, logs/, *.tmp)
- Recommended approach: hierarchical markdown with TOC, preserving directory structure as headers

## Context & Scope

### Research Objectives

1. Understand the structure of the .claude/ directory
2. Identify what content should be included/excluded from export
3. Research best practices for markdown consolidation
4. Recommend implementation approach

### Directory Overview

```
.claude/                      # Root - 243 files, 3.5MB total
├── CLAUDE.md                 # Primary system documentation
├── README.md                 # Comprehensive architecture docs (1081 lines)
├── agents/                   # 9 agent definitions
│   └── archive/              # Archived agents
├── commands/                 # 13 slash commands
├── context/                  # Domain knowledge (largest section)
│   ├── core/                 # Reusable patterns
│   │   ├── architecture/     # System architecture docs
│   │   ├── checkpoints/      # Checkpoint patterns
│   │   ├── formats/          # Output formats
│   │   ├── orchestration/    # Delegation patterns
│   │   ├── patterns/         # Behavior patterns
│   │   ├── schemas/          # JSON/YAML schemas
│   │   ├── standards/        # Quality standards
│   │   ├── templates/        # File templates
│   │   ├── troubleshooting/  # Debug guides
│   │   └── workflows/        # Process workflows
│   └── project/              # Domain-specific
│       ├── latex/            # LaTeX patterns
│       ├── lean4/            # Lean 4 patterns
│       ├── logic/            # Logic domain
│       ├── math/             # Math domain
│       ├── meta/             # Meta patterns
│       ├── physics/          # Physics domain
│       ├── processes/        # Project processes
│       ├── repo/             # Repo knowledge
│       └── typst/            # Typst patterns
├── docs/                     # User documentation
│   ├── architecture/         # Architecture diagrams
│   ├── examples/             # Usage examples
│   ├── guides/               # How-to guides
│   └── templates/            # Doc templates
├── hooks/                    # Shell hooks
├── logs/                     # Runtime logs (excluded)
├── output/                   # Generated output
├── rules/                    # Auto-applied rules
├── scripts/                  # Utility scripts
├── skills/                   # 15 skill definitions
├── systemd/                  # Systemd configs
└── templates/                # File templates
```

## Findings

### 1. File Type Distribution

| Type | Count | Size Estimate | Include in Export |
|------|-------|---------------|-------------------|
| Markdown (.md) | 210 | ~3MB | Yes (primary content) |
| Shell scripts (.sh) | 17 | ~100KB | Yes (show implementation) |
| JSON (.json) | 5 | ~20KB | Partial (exclude local settings) |
| YAML (.yaml) | 1 | ~2KB | Yes |
| .gitignore | 1 | ~100B | Yes |
| Log files (.log) | 3 | Variable | No (gitignored) |
| Backup files (.bak, .backup) | 4 | Variable | No |

### 2. Content to Exclude

Based on .gitignore and content analysis:

**Exclude by .gitignore rules**:
- `settings.local.json` - Personal settings
- `hooks/*.log` - Hook logs
- `logs/` - All log files
- `*.tmp` - Temporary files

**Exclude by content type**:
- `*.bak`, `*.backup` - Backup files (found 4 in agents/archive/)
- `.gitignore` file itself (already documented by content)
- Binary or generated files

### 3. Largest Files (Top 10)

| File | Lines | Category |
|------|-------|----------|
| commands/todo.md | 1190 | Command |
| README.md | 1081 | Documentation |
| context/core/standards/error-handling.md | 1056 | Standard |
| context/core/formats/command-structure.md | 965 | Format |
| docs/guides/context-loading-best-practices.md | 896 | Guide |
| context/core/orchestration/orchestrator.md | 876 | Orchestration |
| context/core/orchestration/delegation.md | 859 | Orchestration |
| skills/skill-lake-repair/SKILL.md | 839 | Skill |
| docs/guides/permission-configuration.md | 778 | Guide |
| context/core/orchestration/routing.md | 776 | Orchestration |

### 4. Export Format Options

#### Option A: Single Concatenated Markdown File

**Pros**:
- Single file for easy sharing
- Simple implementation
- Works with any markdown viewer

**Cons**:
- Very large (~68,000 lines total)
- Hard to navigate without good TOC
- May exceed rendering limits in some viewers

**Structure**:
```markdown
# .claude/ Directory Export

## Table of Contents
[Auto-generated TOC]

---

## agents/

### agents/document-converter-agent.md
[content]

### agents/general-research-agent.md
[content]

---

## commands/
...
```

#### Option B: Hierarchical Export with Collapsible Sections

**Pros**:
- Better navigation with collapsible sections
- Works in GitHub/GitLab markdown preview
- Can show/hide sections as needed

**Cons**:
- More complex implementation
- May not render in all viewers

**Structure**:
```markdown
# .claude/ Directory Export

<details>
<summary>agents/ (9 files)</summary>

### document-converter-agent.md
[content]

</details>

<details>
<summary>commands/ (13 files)</summary>
...
</details>
```

#### Option C: Multi-File Export (One per Directory)

**Pros**:
- Manageable file sizes
- Easy to navigate specific sections
- Can be versioned separately

**Cons**:
- Multiple files to share
- Need index/navigation

### 5. Recommended Approach

**Primary Recommendation: Option A with Smart TOC**

Rationale:
- Single file is easiest to share and search
- With proper TOC, navigation is manageable
- Can be post-processed into other formats

**Implementation Strategy**:

1. **Use shell script for export** (portable, version-controllable)
2. **Generate TOC automatically** from directory structure
3. **Include file metadata** (path, line count)
4. **Use horizontal rules** between major sections
5. **Preserve code blocks** for non-markdown files (shell scripts)
6. **Add export timestamp** for version tracking

### 6. Implementation Recommendations

#### Script Approach

```bash
#!/bin/bash
# .claude/scripts/export-to-markdown.sh

OUTPUT="docs/claude-directory-export.md"
EXCLUDE_PATTERNS=(
  "*.log"
  "*.tmp"
  "*.bak"
  "*.backup"
  "settings.local.json"
  "logs/*"
)

# Generate header with timestamp
echo "# .claude/ Directory Export" > "$OUTPUT"
echo "" >> "$OUTPUT"
echo "Generated: $(date -Iseconds)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Generate TOC
echo "## Table of Contents" >> "$OUTPUT"
# ... TOC generation logic

# Process each file
find .claude -type f -name "*.md" ... | while read file; do
  # Skip excluded patterns
  # Add section header
  # Include file content
done
```

#### File Processing Order

1. **Root files first**: README.md, CLAUDE.md, .gitignore
2. **Agents**: alphabetically
3. **Commands**: alphabetically
4. **Context**: by category (core/ before project/)
5. **Docs**: alphabetically
6. **Rules**: alphabetically
7. **Scripts**: alphabetically
8. **Skills**: alphabetically
9. **Other**: remaining files

#### Content Wrapping

- **Markdown files**: Include directly (may need header level adjustment)
- **Shell scripts**: Wrap in ```bash code blocks
- **JSON/YAML**: Wrap in ```json or ```yaml code blocks
- **Other files**: Wrap in ``` code blocks

### 7. Estimated Output Size

| Component | Est. Lines |
|-----------|------------|
| Header + TOC | ~500 |
| agents/ | ~3,000 |
| commands/ | ~5,000 |
| context/ | ~40,000 |
| docs/ | ~5,000 |
| rules/ | ~1,000 |
| scripts/ | ~2,000 |
| skills/ | ~10,000 |
| other | ~1,500 |
| **Total** | **~68,000 lines** |

Note: This is a large file but manageable for most markdown viewers and editors.

## Decisions

1. **Export format**: Single consolidated markdown file with hierarchical TOC
2. **Exclusions**: Follow .gitignore + exclude backup files
3. **Implementation**: Shell script for portability and maintainability
4. **Output location**: docs/claude-directory-export.md
5. **Code file handling**: Wrap non-markdown in appropriate code blocks
6. **Header adjustment**: Shift all headers down 2 levels to preserve structure under file headers

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Very large output file | Include collapsible sections for browsers that support `<details>` |
| Duplicate content from deprecated files | Filter known deprecated files or add deprecation notices |
| Header level conflicts | Adjust all file headers to be under file-as-section header |
| Special characters in content | Escape or fence appropriately |
| Binary/non-text files | Skip or provide placeholder with path reference |

## Appendix

### A. Search Queries Used

- `find .claude -type f | wc -l` - Count all files
- `du -sh .claude` - Total directory size
- `find .claude -type f -name "*.md" | wc -l` - Count markdown files
- `find .claude -type d | sort` - List directory structure

### B. Files Reviewed

- `.claude/.gitignore` - Exclusion patterns
- `.claude/README.md` - System architecture overview
- `.claude/CLAUDE.md` - Primary documentation
- `.claude/context/index.md` - Context organization

### C. Related Documentation

- `.claude/context/core/formats/report-format.md` - Report structure standard
- `.claude/context/core/standards/documentation.md` - Documentation standards
