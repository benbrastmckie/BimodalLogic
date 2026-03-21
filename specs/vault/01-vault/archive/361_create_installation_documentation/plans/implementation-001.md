# Implementation Plan: Task #361

**Task**: Create installation documentation
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Create a comprehensive installation documentation suite in `docs/installation/` following the pattern from ModelChecker's documentation. The suite includes CLAUDE_CODE.md as the entry point (for AI-assisted installation), plus supporting guides for manual installation, getting started, and Git/GitHub workflows. All content is adapted for Lean 4 + Mathlib requirements.

## Phases

### Phase 1: Directory Setup and Index

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create `docs/installation/` directory
2. Create README.md index file linking to all installation docs

**Files to modify**:
- `docs/installation/` - Create directory
- `docs/installation/README.md` - Create index file

**Steps**:
1. Create `docs/installation/` directory
2. Write `README.md` with:
   - Overview of installation documentation
   - Quick navigation table to all guides
   - Recommended reading order for new users
   - Links to related documentation (UserGuide, Development)

**Verification**:
- Directory exists with README.md
- README.md follows DIRECTORY_README_STANDARD.md format

---

### Phase 2: CLAUDE_CODE.md (Entry Point)

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create CLAUDE_CODE.md as primary entry point for AI-assisted installation
2. Adapt ModelChecker's structure for Lean 4 specifics

**Files to modify**:
- `docs/installation/CLAUDE_CODE.md` - Create new file (~300 lines)

**Steps**:
1. Write Section 1: Getting Started
   - What is Claude Code
   - Prerequisites (Anthropic subscription, terminal, editor, git)
   - Link to prerequisite guides

2. Write Section 2: Install Claude Code
   - macOS, Windows, Linux installation commands
   - Verify and authenticate steps

3. Write Section 3: Install ProofChecker via Claude
   - Create workspace prompt
   - Request installation prompt (instruct Claude to use elan, lake build)
   - Working with projects prompt examples

4. Write Section 4: Set Up the Agent System
   - Copy .claude/ directory instructions
   - Restart Claude Code
   - Test with `/task "Test task"`
   - Available commands table

5. Write Section 5: Using gh CLI for GitHub
   - Installation instructions
   - Creating issues
   - Creating pull requests

6. Write Section 6: Tips and Troubleshooting
   - Effective prompts
   - Common issues (authentication, build cache, Mathlib download)

7. Write Section 7: Next Steps
   - Links to GETTING_STARTED, GIT_GOING, TUTORIAL

**Verification**:
- All sections complete
- Cross-links to other installation docs work
- Follows ModelChecker format and tone

---

### Phase 3: BASIC_INSTALLATION.md (Manual Installation)

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create manual installation guide for Lean 4 + ProofChecker
2. Cover elan, Lake, Mathlib, VS Code setup

**Files to modify**:
- `docs/installation/BASIC_INSTALLATION.md` - Create new file (~250 lines)

**Steps**:
1. Write Overview section
   - Why installation is straightforward
   - What gets installed (elan, Lean 4, Lake, Mathlib)

2. Write Prerequisites section
   - Check Lean 4 version command
   - Git prerequisite

3. Write Installation via elan section
   - macOS, Windows, Linux commands
   - Verify elan installation

4. Write Clone and Build section
   - git clone command
   - lake build command
   - Note about Mathlib cache (~30 min first build)

5. Write Verification section
   - lake build success
   - lake test command

6. Write VS Code Setup section
   - Install lean4 extension
   - Open project, wait for Lake build
   - Verify syntax highlighting

7. Write Common Beginner Mistakes section
   - Wrong Lean version
   - Not waiting for Mathlib cache
   - Permission issues

8. Write Quick Command Reference table

**Verification**:
- All installation steps tested conceptually
- Commands are accurate for Lean 4 v4.14.0
- Links to troubleshooting resources

---

### Phase 4: GETTING_STARTED.md (First Steps)

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create beginner-friendly guide for terminal, editor, and first proof
2. Adapt ModelChecker's terminal tutorial for Lean context

**Files to modify**:
- `docs/installation/GETTING_STARTED.md` - Create new file (~400 lines)

**Steps**:
1. Write Table of Contents

2. Write Section: Before You Begin - Using the Terminal
   - What is the terminal
   - Opening the terminal (macOS, Windows, Linux)
   - Basic commands (pwd, ls, cd, mkdir)
   - Understanding paths
   - Tips for beginners

3. Write Section: Setting Up Your Editor
   - Why VS Code is recommended for Lean
   - Installing VS Code
   - Installing lean4 extension
   - Recommended settings

4. Write Section: Creating Your First Proof
   - Open project in VS Code
   - Navigate to example file
   - Understanding a simple proof
   - Modifying and verifying

5. Write Section: Understanding Project Structure
   - Bimodal/ directory overview
   - BimodalTest/ directory overview
   - Logos/ directory overview
   - lakefile.lean explanation

6. Write Section: Running Examples
   - Running lake build
   - Running lake test
   - Exploring test files

7. Write Section: Exploring Bimodal Logic
   - Link to TUTORIAL.md
   - Key theorems to explore

8. Write Section: Next Steps
   - Links to TUTORIAL, CONTRIBUTING, ARCHITECTURE

**Verification**:
- Terminal section is beginner-friendly
- VS Code setup steps are complete
- Links to existing documentation work

---

### Phase 5: GIT_GOING.md (Git/GitHub Setup)

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create Git/GitHub setup guide
2. Cover SSH keys, basic commands, contributing workflow

**Files to modify**:
- `docs/installation/GIT_GOING.md` - Create new file (~350 lines)

**Steps**:
1. Write What is GitHub section

2. Write Prerequisites section
   - Link to terminal guide

3. Write Installing Git section
   - macOS, Windows, Linux commands
   - Verify installation

4. Write Creating a GitHub Account section
   - Step-by-step signup
   - Choosing username

5. Write Configuring Git section
   - Set user.name and user.email
   - Verify settings

6. Write SSH Keys section
   - Check for existing keys
   - Generate new key
   - Add to GitHub
   - Test connection
   - Using SSH URLs

7. Write Basic Git Concepts section
   - Repository, commit, branch, remote, clone, push, pull, fork, PR

8. Write Essential Git Commands section
   - Starting new project
   - Working with existing projects
   - Creating branches

9. Write Contributing to ProofChecker section
   - Fork repository
   - Clone fork
   - Create feature branch
   - Make changes and commit
   - Create pull request
   - Keep fork updated

10. Write Troubleshooting section
    - Permission denied
    - Failed to push
    - Merge conflicts

**Verification**:
- SSH key instructions are complete
- Contributing workflow is accurate for ProofChecker
- All commands are tested conceptually

---

### Phase 6: Update Documentation Index Files

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update docs/README.md to include Installation section
2. Update root README.md installation section to link to new docs

**Files to modify**:
- `docs/README.md` - Add Installation section
- `README.md` - Update Installation section links

**Steps**:
1. Read docs/README.md
2. Add Installation section with links to:
   - CLAUDE_CODE.md (recommended entry point)
   - BASIC_INSTALLATION.md
   - GETTING_STARTED.md
   - GIT_GOING.md

3. Read root README.md Installation section
4. Update to reference new detailed guides
5. Keep Quick Start section but add "For detailed installation" link

**Verification**:
- docs/README.md has Installation section
- Root README.md links to new installation docs
- All links work correctly

---

## Dependencies

- ModelChecker reference documentation (read during research)
- Existing docs/user-guide/TUTORIAL.md (for cross-links)
- Existing docs/development/CONTRIBUTING.md (for cross-links)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean 4 installation commands outdated | Medium | Low | Reference official elan docs, use current version |
| Mathlib cache time varies | Low | Medium | Note "approximately 30 minutes" with caveat |
| ModelChecker links may change | Low | Low | Use relative links within repo where possible |

## Success Criteria

- [ ] docs/installation/ directory exists with 5 files
- [ ] CLAUDE_CODE.md is complete entry point (~300 lines)
- [ ] BASIC_INSTALLATION.md covers Lean 4 + Lake setup
- [ ] GETTING_STARTED.md covers terminal, editor, first proof
- [ ] GIT_GOING.md covers SSH, commands, contributing
- [ ] docs/README.md updated with Installation section
- [ ] Root README.md Installation section links to new docs
- [ ] All cross-links between documents work

## Rollback Plan

Delete `docs/installation/` directory and revert changes to docs/README.md and root README.md if implementation fails. No existing files are being modified except the two index files.
