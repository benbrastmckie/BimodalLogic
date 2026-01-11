# Implementation Plan: Task #361

**Task**: Create installation documentation
**Version**: 002
**Created**: 2026-01-11
**Revision of**: implementation-001.md
**Reason**: User requested restructuring: rename GIT_GOING.md to USING_GIT.md, move editor documentation from BASIC_INSTALLATION.md to GETTING_STARTED.md, add NeoVim support with link to https://github.com/benbrastmckie/.config

## Revision Summary

### Previous Plan Status
- Phase 1: [NOT STARTED] - Directory Setup and Index
- Phase 2: [NOT STARTED] - CLAUDE_CODE.md (Entry Point)
- Phase 3: [NOT STARTED] - BASIC_INSTALLATION.md (Manual Installation)
- Phase 4: [NOT STARTED] - GETTING_STARTED.md (First Steps)
- Phase 5: [NOT STARTED] - GIT_GOING.md (Git/GitHub Setup)
- Phase 6: [NOT STARTED] - Update Documentation Index Files

### Key Changes
1. **Rename GIT_GOING.md to USING_GIT.md** - More descriptive filename
2. **Remove editor content from BASIC_INSTALLATION.md** - BASIC_INSTALLATION.md is what Claude Code uses for automated installation; keep it focused on elan/Lean/Mathlib only
3. **Move editor content to GETTING_STARTED.md** - Include terminal basics AND editor setup (VS Code and NeoVim)
4. **Add NeoVim support** - Link to https://github.com/benbrastmckie/.config as an alternative to VS Code
5. **Update CLAUDE_CODE.md** - Reference USING_GIT.md instead of GIT_GOING.md

## Overview

Create a comprehensive installation documentation suite in `Documentation/Installation/` with clear separation of concerns:
- **CLAUDE_CODE.md** - Entry point for AI-assisted setup
- **BASIC_INSTALLATION.md** - Pure installation (elan, Lean, Mathlib) without editor setup
- **GETTING_STARTED.md** - Terminal basics + Editor setup (VS Code and NeoVim) + First proof
- **USING_GIT.md** - Git/GitHub setup and workflows

## Phases

### Phase 1: Directory Setup and Index

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create `Documentation/Installation/` directory
2. Create README.md index file linking to all installation docs

**Files to modify**:
- `Documentation/Installation/` - Create directory
- `Documentation/Installation/README.md` - Create index file

**Steps**:
1. Create `Documentation/Installation/` directory
2. Write `README.md` with:
   - Overview of installation documentation
   - Quick navigation table to all guides
   - Recommended reading order for new users
   - Note: CLAUDE_CODE.md for AI-assisted setup, BASIC_INSTALLATION.md for manual
   - Links to related documentation (UserGuide, Development)

**Verification**:
- Directory exists with README.md
- README.md follows DIRECTORY_README_STANDARD.md format
- File list references: CLAUDE_CODE.md, BASIC_INSTALLATION.md, GETTING_STARTED.md, USING_GIT.md

---

### Phase 2: CLAUDE_CODE.md (Entry Point)

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create CLAUDE_CODE.md as primary entry point for AI-assisted installation
2. Reference BASIC_INSTALLATION.md for Claude to follow
3. Use USING_GIT.md (not GIT_GOING.md) for git references

**Files to modify**:
- `Documentation/Installation/CLAUDE_CODE.md` - Create new file (~300 lines)

**Steps**:
1. Write Section 1: Getting Started
   - What is Claude Code
   - Prerequisites (Anthropic subscription, terminal, editor, git)
   - Link to prerequisite guides (GETTING_STARTED.md for terminal/editor, USING_GIT.md for git)

2. Write Section 2: Install Claude Code
   - macOS, Windows, Linux installation commands
   - Verify and authenticate steps

3. Write Section 3: Install ProofChecker via Claude
   - Create workspace prompt
   - Request installation prompt - instruct Claude to follow BASIC_INSTALLATION.md
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
   - Links to GETTING_STARTED.md, USING_GIT.md, TUTORIAL.md

**Verification**:
- All sections complete
- References USING_GIT.md (not GIT_GOING.md)
- Cross-links to other installation docs work

---

### Phase 3: BASIC_INSTALLATION.md (Manual Installation - No Editor)

**Estimated effort**: 25 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create manual installation guide for Lean 4 + ProofChecker
2. Cover ONLY: elan, Lake, Mathlib, verification - NO editor setup
3. This is what Claude Code will use for automated installation

**Files to modify**:
- `Documentation/Installation/BASIC_INSTALLATION.md` - Create new file (~200 lines)

**Steps**:
1. Write Overview section
   - Why installation is straightforward
   - What gets installed (elan, Lean 4, Lake, Mathlib)
   - Note: For editor setup, see GETTING_STARTED.md

2. Write Prerequisites section
   - Git required (link to USING_GIT.md if not installed)
   - Internet connection

3. Write Installation via elan section
   - macOS: `curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh`
   - Windows: PowerShell installation
   - Linux: Same as macOS
   - Verify: `lean --version`, `lake --version`

4. Write Clone and Build section
   - git clone command
   - cd into project
   - `lake build` command
   - Note about Mathlib cache (~30 min first build)

5. Write Verification section
   - `lake build` success
   - `lake test` command

6. Write Common Issues section
   - Wrong Lean version
   - Mathlib cache timeout
   - Permission issues
   - Network issues during Mathlib download

7. Write Quick Command Reference table

8. Write Next Steps section
   - For editor setup: see GETTING_STARTED.md
   - For Git/GitHub: see USING_GIT.md

**Verification**:
- NO editor content (VS Code, NeoVim)
- All installation steps are OS-specific where needed
- Commands accurate for Lean 4 v4.14.0

---

### Phase 4: GETTING_STARTED.md (Terminal, Editors, First Proof)

**Estimated effort**: 50 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create beginner-friendly guide for terminal usage
2. Provide editor setup for BOTH VS Code AND NeoVim
3. Guide through first proof experience

**Files to modify**:
- `Documentation/Installation/GETTING_STARTED.md` - Create new file (~450 lines)

**Steps**:
1. Write Table of Contents

2. Write Section: Using the Terminal
   - What is the terminal
   - Opening the terminal (macOS, Windows, Linux)
   - Basic commands (pwd, ls, cd, mkdir)
   - Understanding paths (absolute, relative, home directory)
   - Tips for beginners (tab completion, history, clear)

3. Write Section: Setting Up Your Editor
   - Introduction: Two recommended editors
   - Why a good editor matters for Lean

4. Write Subsection: VS Code (Recommended for Beginners)
   - Install VS Code
   - Install lean4 extension from marketplace
   - Open ProofChecker project
   - Wait for Lake build to complete
   - Verify: syntax highlighting, type info on hover

5. Write Subsection: NeoVim (For Advanced Users)
   - Introduction: Keyboard-driven workflow
   - Repository link: https://github.com/benbrastmckie/.config
   - Brief overview of what the config provides for Lean
   - Installation reference to the config repo's README
   - Note: Requires comfort with terminal and vim keybindings

6. Write Section: Your First Proof
   - Open project in your editor
   - Navigate to Bimodal/Examples/ or BimodalTest/
   - Understanding a simple proof file
   - Modifying and verifying (see goal state change)

7. Write Section: Understanding Project Structure
   - Bimodal/ directory overview (the main library)
   - BimodalTest/ directory overview (tests)
   - Logos/ directory overview (future extensions)
   - lakefile.lean explanation

8. Write Section: Running Examples
   - Running `lake build`
   - Running `lake test`
   - Exploring test files

9. Write Section: Next Steps
   - For Git/GitHub: USING_GIT.md
   - For deeper understanding: TUTORIAL.md
   - For contributing: CONTRIBUTING.md

**Verification**:
- Terminal section is beginner-friendly
- BOTH VS Code AND NeoVim documented
- NeoVim links to https://github.com/benbrastmckie/.config
- Links to existing documentation work

---

### Phase 5: USING_GIT.md (Git/GitHub Setup)

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create Git/GitHub setup guide (renamed from GIT_GOING.md)
2. Cover SSH keys, basic commands, contributing workflow

**Files to modify**:
- `Documentation/Installation/USING_GIT.md` - Create new file (~350 lines)

**Steps**:
1. Write What is GitHub section

2. Write Prerequisites section
   - Link to terminal guide in GETTING_STARTED.md

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
   - Generate new Ed25519 key
   - Add to GitHub
   - Test connection
   - Using SSH URLs vs HTTPS

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
    - Permission denied (publickey)
    - Failed to push some refs
    - Merge conflicts

**Verification**:
- SSH key instructions are complete
- Contributing workflow is accurate for ProofChecker
- All commands are correct

---

### Phase 6: Update Documentation Index Files

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update Documentation/README.md to include Installation section
2. Update root README.md installation section to link to new docs

**Files to modify**:
- `Documentation/README.md` - Add Installation section
- `README.md` - Update Installation section links

**Steps**:
1. Read Documentation/README.md
2. Add Installation section with links to:
   - CLAUDE_CODE.md (recommended for AI-assisted setup)
   - BASIC_INSTALLATION.md (manual installation)
   - GETTING_STARTED.md (terminal and editor setup)
   - USING_GIT.md (Git/GitHub setup)

3. Read root README.md Installation section
4. Update to reference new detailed guides
5. Keep Quick Start section but add "For detailed installation guides" link

**Verification**:
- Documentation/README.md has Installation section
- Root README.md links to new installation docs
- All links use USING_GIT.md (not GIT_GOING.md)
- All cross-links work correctly

---

## Dependencies

- ModelChecker reference documentation (read during research)
- NeoVim config repository: https://github.com/benbrastmckie/.config
- Existing Documentation/UserGuide/TUTORIAL.md (for cross-links)
- Existing Documentation/Development/CONTRIBUTING.md (for cross-links)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean 4 installation commands outdated | Medium | Low | Reference official elan docs |
| Mathlib cache time varies | Low | Medium | Note "approximately 30 minutes" with caveat |
| NeoVim config repo changes | Low | Low | Link to repo, don't duplicate instructions |

## Success Criteria

- [ ] Documentation/Installation/ directory exists with 5 files
- [ ] CLAUDE_CODE.md references USING_GIT.md (not GIT_GOING.md)
- [ ] BASIC_INSTALLATION.md has NO editor content
- [ ] GETTING_STARTED.md covers terminal + VS Code + NeoVim
- [ ] NeoVim section links to https://github.com/benbrastmckie/.config
- [ ] USING_GIT.md (not GIT_GOING.md) covers Git/GitHub
- [ ] Documentation/README.md updated with Installation section
- [ ] Root README.md Installation section links to new docs
- [ ] All cross-links between documents work

## Rollback Plan

Delete `Documentation/Installation/` directory and revert changes to Documentation/README.md and root README.md if implementation fails. No existing files are being modified except the two index files.
