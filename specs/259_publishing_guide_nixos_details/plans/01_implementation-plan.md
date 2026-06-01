# Implementation Plan: Update PUBLISHING_GUIDE.md for NixOS Users

- **Task**: 259 - Update PUBLISHING_GUIDE.md to include details for NixOS users
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/259_publishing_guide_nixos_details/reports/01_nixos-publishing-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Add NixOS-specific instructions to `docs/training/PUBLISHING_GUIDE.md` at four insertion points identified during research. The edits provide parallel NixOS subsections alongside existing Linux/macOS instructions, covering dependency installation (ephemeral and persistent), CLI download, token management, and troubleshooting. No structural changes to the existing guide are required.

### Research Integration

The research report identified three NixOS pain points (pip install failure on read-only Nix store, huggingface-cli availability only via python3Packages, keyring login issues) and four concrete edit locations. All four pip dependencies are confirmed available as nixpkgs packages. The project's existing NixOS documentation style (ephemeral nix-shell + persistent home-manager subsections) serves as the formatting reference.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add NixOS dependency installation instructions (nix-shell ephemeral + home-manager persistent + venv fallback) under Step 1
- Add NixOS note for CLI download under Quick Start
- Add NixOS token management note under Step 4
- Add NixOS troubleshooting entry for pip install failures

**Non-Goals**:
- Updating `data/hf-dataset/PUBLISHING.md` (operator guide, out of scope)
- Adding a `flake.nix` or `shell.nix` to the repository
- Restructuring existing guide sections or adding platform-comparison tables

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| nixpkgs package names change in future releases | L | L | Document channel-independent nix-shell pattern; note names are for nixpkgs 24.x/unstable |
| NixOS subsections make guide too long | L | L | Keep each NixOS block to 4-8 lines; use collapsible details if needed |
| python3Packages.datasets version lags behind HF releases | M | M | Include venv alternative as fallback for users needing newer versions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Add NixOS content to PUBLISHING_GUIDE.md [COMPLETED]

**Goal**: Insert NixOS-specific instructions at all four identified locations in `docs/training/PUBLISHING_GUIDE.md`.

**Tasks**:
- [x] Insert "NixOS Users" subsection under "Step 1 -- Install Dependencies" (after the existing `pip install` block at line 90), covering ephemeral nix-shell, persistent home-manager, and venv fallback
- [x] Insert NixOS note under "CLI Download" in Quick Start (after the `pip install huggingface_hub` line at line 56), noting `nix-shell -p python3Packages.huggingface-hub` provides `huggingface-cli`
- [x] Insert NixOS token note under "Step 4 -- Upload" (near line 116), recommending `HF_TOKEN` env-var to avoid keyring issues
- [x] Add "pip install fails on NixOS" entry to the Troubleshooting section (after line 259), with nix-shell and venv solutions

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `docs/training/PUBLISHING_GUIDE.md` - Add NixOS subsections at 4 insertion points

**Verification**:
- All four NixOS blocks are present in the guide
- Existing content is unchanged (no structural modifications)
- nix-shell commands reference correct package names: `python3Packages.datasets`, `python3Packages.huggingface-hub`, `python3Packages.pyarrow`, `python3Packages.pyyaml`
- Guide renders correctly in Markdown preview

## Testing & Validation

- [x] Verify all four insertion points contain NixOS content
- [x] Verify existing guide content is not altered
- [x] Verify nix-shell package names match nixpkgs conventions
- [x] Verify Markdown formatting renders correctly (code blocks, blockquotes, headings)

## Artifacts & Outputs

- `specs/259_publishing_guide_nixos_details/plans/01_implementation-plan.md` (this plan)
- `docs/training/PUBLISHING_GUIDE.md` (modified file, after implementation)

## Rollback/Contingency

Revert with `git checkout docs/training/PUBLISHING_GUIDE.md` to restore the original guide. All changes are confined to a single file with no side effects.
