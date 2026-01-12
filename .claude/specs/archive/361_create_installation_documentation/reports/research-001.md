# Research Report: Task #361

**Task**: Create installation documentation
**Date**: 2026-01-11
**Focus**: Documentation structure and content requirements for ProofChecker installation

## Summary

This task requires creating a documentation suite for ProofChecker installation following the pattern from ModelChecker's installation documentation. The documentation needs to be adapted for Lean 4 + Mathlib dependencies rather than Python + pip. A new `docs/installation/` directory should be created with CLAUDE_CODE.md as the entry point, linking to supporting guides for prerequisites.

## Findings

### ModelChecker Documentation Structure

The ModelChecker project has a comprehensive installation documentation suite in `Docs/installation/`:

| File | Purpose | Lines |
|------|---------|-------|
| `CLAUDE_CODE.md` | Entry point for AI-assisted installation | 326 |
| `BASIC_INSTALLATION.md` | Core installation via pip | 226 |
| `GETTING_STARTED.md` | Terminal basics, editor setup, first project | 558 |
| `GIT_GOING.md` | Git/GitHub setup and workflows | 475 |

**Key Features**:
- CLAUDE_CODE.md serves as master entry point
- Progressive disclosure: beginners can follow step-by-step
- Cross-linked navigation between documents
- Covers prerequisites, installation, verification, troubleshooting
- Agent system setup instructions included

### ProofChecker Requirements (Different from ModelChecker)

ProofChecker is a Lean 4 project with different dependencies:

| Requirement | ModelChecker | ProofChecker |
|-------------|--------------|--------------|
| Language | Python 3.8+ | Lean 4 v4.14.0+ |
| Package Manager | pip | Lake (Lean's package manager) |
| Main Dependency | z3-solver, networkx | Mathlib v4.14.0 |
| Build System | pip install | lake build |
| IDE | Any text editor | VS Code with lean4 extension (strongly recommended) |
| Test Command | model-checker --version | lake test |

**Lean-Specific Installation Requirements**:
1. **elan** - Lean version manager (like rustup for Rust)
2. **Lake** - Lean's build tool (included with Lean 4)
3. **Mathlib** - Large mathematical library (auto-fetched by Lake)
4. **lean4 extension** - VS Code extension for IDE support

### Existing ProofChecker Documentation

Current documentation in `docs/`:
- `UserGuide/TUTORIAL.md` - Has basic installation section (39 lines)
- `Development/CONTRIBUTING.md` - Has development setup section
- `README.md` (root) - Has minimal "Quick Start" section

**Gap Analysis**:
- No dedicated installation directory
- No beginner-friendly terminal tutorial
- No Git/GitHub setup guide
- No Claude Code integration guide
- No troubleshooting section
- Existing tutorials assume LEAN 4 familiarity

### Document Content Requirements

#### CLAUDE_CODE.md (Entry Point)
Adapted sections needed:
1. What is Claude Code
2. Prerequisites (Anthropic subscription, terminal, editor, git)
3. Install Claude Code
4. Install ProofChecker (via Claude prompts)
5. Set up the Agent System (copy .claude/ directory)
6. Using gh CLI for GitHub
7. Tips and Troubleshooting
8. Next Steps

#### BASIC_INSTALLATION.md (Manual Installation)
ProofChecker-specific content:
1. Overview - What gets installed (Lean 4, Lake, Mathlib)
2. Prerequisites - Check/install Lean 4
3. Installation via elan
4. Clone and build project
5. Verification (lake build, lake test)
6. NixOS-specific instructions (shell.nix if applicable)
7. Common beginner mistakes
8. Quick command reference

#### GETTING_STARTED.md (First Steps)
Adapted content:
1. Using the Terminal (largely reusable from ModelChecker)
2. Setting Up Your Editor (VS Code with lean4 extension)
3. Creating Your First Proof
4. Understanding Project Structure
5. Running Examples
6. Exploring the Bimodal Logic
7. Next Steps

#### GIT_GOING.md (Git/GitHub)
Content is largely platform-agnostic and can be adapted:
1. What is GitHub
2. Installing Git
3. Creating GitHub Account
4. Configuring Git
5. SSH Keys
6. Basic Git Concepts
7. Essential Commands
8. Contributing to ProofChecker (fork/clone/PR workflow)
9. Troubleshooting

### Directory Structure Recommendation

```
docs/installation/
├── README.md              # Index linking to all installation docs
├── CLAUDE_CODE.md         # Entry point for AI-assisted setup
├── BASIC_INSTALLATION.md  # Manual installation guide
├── GETTING_STARTED.md     # Terminal, editor, first proof
├── GIT_GOING.md           # Git/GitHub setup
└── TROUBLESHOOTING.md     # Common issues and solutions
```

### Agent System Integration

ProofChecker uses `.claude/` directory with:
- Task management commands (/task, /research, /plan, /implement)
- Language-based routing for Lean development
- MCP tools for lean-lsp integration

CLAUDE_CODE.md should include instructions for:
1. Copying .claude/ directory into user's project
2. Restarting Claude Code to load commands
3. Testing with `/task "Test task"`
4. Link to agent system documentation

## Recommendations

1. **Create docs/installation/ directory** - New subdirectory for installation-specific documentation

2. **Adapt, don't copy verbatim** - ModelChecker's structure is excellent but content needs Lean 4 specifics

3. **Prioritize VS Code** - lean4 extension is critical for productivity; emphasize more than in Python docs

4. **Include Mathlib context** - Explain the ~30 minute first build time for Mathlib cache

5. **Cross-link with existing docs** - Link to TUTORIAL.md, CONTRIBUTING.md for deeper content

6. **Add MCP integration section** - Unique to ProofChecker: lean-lsp MCP server for tool access

## References

- `/home/benjamin/Projects/ModelChecker/Docs/installation/CLAUDE_CODE.md`
- `/home/benjamin/Projects/ModelChecker/Docs/installation/BASIC_INSTALLATION.md`
- `/home/benjamin/Projects/ModelChecker/Docs/installation/GETTING_STARTED.md`
- `/home/benjamin/Projects/ModelChecker/Docs/installation/GIT_GOING.md`
- `/home/benjamin/Projects/ProofChecker/README.md`
- `/home/benjamin/Projects/ProofChecker/lakefile.lean`
- `/home/benjamin/Projects/ProofChecker/docs/user-guide/TUTORIAL.md`
- `/home/benjamin/Projects/ProofChecker/docs/development/CONTRIBUTING.md`
- [elan installation](https://github.com/leanprover/elan)
- [Lean 4 documentation](https://lean-lang.org/documentation/)
- [lean4 VS Code extension](https://marketplace.visualstudio.com/items?itemName=leanprover.lean4)

## Next Steps

1. Create `docs/installation/` directory
2. Create `README.md` as index for installation section
3. Create `CLAUDE_CODE.md` as entry point
4. Create `BASIC_INSTALLATION.md` with Lean 4 specifics
5. Create `GETTING_STARTED.md` adapted for Lean/ProofChecker
6. Create `GIT_GOING.md` with ProofChecker-specific fork/PR workflow
7. Optionally create `TROUBLESHOOTING.md` for common issues
8. Update root README.md to link to new installation docs
9. Update `docs/README.md` to include installation section
